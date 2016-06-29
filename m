From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: [PATCH 3/4] userns/inotify: Initial implementation of inotify
	per-userns
Date: Wed, 29 Jun 2016 16:37:04 +0300
Message-ID: <1467207425-22072-4-git-send-email-kernel@kyup.com>
References: <1467207425-22072-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1467207425-22072-1-git-send-email-kernel-6AxghH7DbtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: jack-AlSwsSmVLrQ@public.gmane.org, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

This is still very much a WIP and there are certain things which need 
to be addressed: 

Changes include:

 * Added 2 new sysctls:
    - inotify_reserved_user_instances and inotify_reserved_user_watches 
    these essentially     control the distribution of instances/watches 
    down the hierarchy. For example if we have instances/watches limit of 
    1024/256 and reserved instances/watches are set to 128/32 then at every 
    level of the hierarchy instances/watches are going to be reduced by 128/32, 
    so at userns level of 1 (e.g. init_user_ns->level_1_user_ns) each user would
    have 896/224 respectively. Currently the defaults are calculated so that at 
    least 8 levels of indirection are allowed. Those can be set only by global 
    root user.

 * When a user inside a NS creates an inotify context for the first time, 
 the code locks the whole namespace hierarchy up to the parent of the last 
 namespace which has a mapping for a user. And then proceeds to create all 
 the intermediary levels. And then unlocks them, this is a bit cumbersome 
 IMO but at least ensures that no hard-to-trace races occur.

There are also some things which need to be considered:

 * One problem currently not resovled is the cleanup of the intermediary
 state in namespaces. E.g. if we have a hierarchy of 4 namespaces and an 
 inotify instance is created in the bottom-most namespace, and later is 
 destroyed this guarantees that only the state in the bottom-most ns is 
 freed and not in the intermediary nodes. I guess some sort of hierarchical
 mechanism is needed to connect several inotify_state structs. I'm very
 much open to discussing how to fix this. Also due to the way locks are 
 acquired lockdep prints a splat, but it is a false-positive. 

 * Another thing which I think needs serious consideration is the semantic
 of the reserved sysctls. What should happen when they are changed - should
 those changes propagate to existing counter or shouldn't they? Depending
 on the outcome of that decision it's possible to blow the complexity of the
 solution through the roof. 


Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
---
 fs/notify/inotify/inotify.h      |  25 +++++
 fs/notify/inotify/inotify_user.c | 194 +++++++++++++++++++++++++++++++++++++++
 include/linux/fsnotify_backend.h |   3 +
 include/linux/user_namespace.h   |  10 ++
 kernel/user.c                    |   5 +
 kernel/user_namespace.c          |  22 ++++-
 6 files changed, 258 insertions(+), 1 deletion(-)

diff --git a/fs/notify/inotify/inotify.h b/fs/notify/inotify/inotify.h
index ed855ef6f077..64dd281e28a4 100644
--- a/fs/notify/inotify/inotify.h
+++ b/fs/notify/inotify/inotify.h
@@ -1,6 +1,8 @@
 #include <linux/fsnotify_backend.h>
 #include <linux/inotify.h>
 #include <linux/slab.h> /* struct kmem_cache */
+#include <linux/page_counter.h>
+#include <linux/user_namespace.h>
 
 struct inotify_event_info {
 	struct fsnotify_event fse;
@@ -15,6 +17,14 @@ struct inotify_inode_mark {
 	int wd;
 };
 
+struct inotify_state {
+	struct hlist_node node;
+	uid_t uid; /* user_namespace ptr */
+	struct page_counter watches; /* How many inotify watches does this user */
+	struct page_counter instances; /* How many inotify devs does this user have opened? */
+};
+
+
 static inline struct inotify_event_info *INOTIFY_E(struct fsnotify_event *fse)
 {
 	return container_of(fse, struct inotify_event_info, fse);
@@ -30,3 +40,18 @@ extern int inotify_handle_event(struct fsnotify_group *group,
 				const unsigned char *file_name, u32 cookie);
 
 extern const struct fsnotify_ops inotify_fsnotify_ops;
+
+/* Helpers for manipulating various inotify state, stored in user_struct */
+static inline struct inotify_state *__find_inotify_state(struct user_namespace *ns,
+                                                         uid_t uid)
+{
+       struct inotify_state *state;
+
+       WARN_ON(!mutex_is_locked(&ns->inotify_lock));
+
+       hash_for_each_possible(ns->inotify_counts, state, node, uid)
+               if (state->uid == uid)
+                       return state;
+
+       return NULL;
+}
diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
index b8d08d0d0a4d..06797ae76527 100644
--- a/fs/notify/inotify/inotify_user.c
+++ b/fs/notify/inotify/inotify_user.c
@@ -48,6 +48,8 @@
 static int inotify_max_user_instances __read_mostly;
 static int inotify_max_queued_events __read_mostly;
 static int inotify_max_user_watches __read_mostly;
+int inotify_reserved_user_instances __read_mostly;
+int inotify_reserved_user_watches   __read_mostly;
 
 static struct kmem_cache *inotify_inode_mark_cachep __read_mostly;
 
@@ -57,6 +59,17 @@ static struct kmem_cache *inotify_inode_mark_cachep __read_mostly;
 
 static int zero;
 
+
+static int proc_dointvec_minmax_root(struct ctl_table *table, int write,
+				void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	/* Allows writes only from the root user of the machine */
+	if (write && !uid_eq(current_uid(), GLOBAL_ROOT_UID))
+		return -EPERM;
+
+	return proc_dointvec_minmax(table, write, buffer, lenp, ppos);
+}
+
 struct ctl_table inotify_table[] = {
 	{
 		.procname	= "max_user_instances",
@@ -82,10 +95,186 @@ struct ctl_table inotify_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero
 	},
+	{
+		.procname	= "reserved_user_instances",
+		.data		= &inotify_reserved_user_instances,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax_root,
+		.extra1		= &zero,
+	},
+	{
+		.procname	= "reserved_user_watches",
+		.data		= &inotify_reserved_user_watches,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax_root,
+		.extra1		= &zero,
+	},
 	{ }
 };
 #endif /* CONFIG_SYSCTL */
 
+static inline void __init_counters(struct inotify_state *state,
+				   struct inotify_state *parent,
+				   struct user_namespace *ns)
+{
+	if (ns == &init_user_ns) {
+		page_counter_init(&state->watches, NULL);
+		page_counter_init(&state->instances, NULL);
+		page_counter_limit(&state->watches,
+				   init_user_ns.inotify_max_user_watches);
+		page_counter_limit(&state->instances,
+						   init_user_ns.inotify_max_user_instances);
+	} else {
+
+		page_counter_init(&state->watches, &parent->watches);
+		page_counter_init(&state->instances,&parent->instances);
+		page_counter_limit(&state->watches, ns->inotify_max_user_watches);
+		page_counter_limit(&state->instances, ns->inotify_max_user_instances);
+	}
+}
+
+struct creation_ctx {
+	uid_t uid;
+	struct user_namespace *ns;
+};
+
+static noinline int __create_parent_state(struct user_namespace *ns, uid_t uid)
+{
+	int i = 1, j = 0, k = 0;
+	int ret = 0;
+	struct inotify_state *state;
+	struct user_namespace *parent_ns, *current_ns = ns;
+	struct page_counter *cnt;
+	bool locked_parent = false;
+	struct creation_ctx *pns = kzalloc(32*sizeof(struct creation_ctx), GFP_KERNEL);
+	if (!pns)
+		return -ENOMEM;
+
+	pns[0].ns = ns;
+	pns[0].uid = uid;
+
+	/* Walk up the hierarchy to see in which NS we need to build state */
+	for (parent_ns = ns->parent; parent_ns;
+	     current_ns = parent_ns, parent_ns = parent_ns->parent) {
+
+		uid_t owner_uid = from_kuid(parent_ns, current_ns->owner);
+
+		mutex_lock(&parent_ns->inotify_lock);
+		state = __find_inotify_state(parent_ns, owner_uid);
+
+		pns[i].ns = parent_ns;
+		pns[i].uid = owner_uid;
+		++i;
+
+		/* When we stop at a particular level in the hierarchy also make
+		 * sure the parent is also locked
+		 */
+		if (state) {
+			if (parent_ns->parent) {
+				mutex_lock(&parent_ns->parent->inotify_lock);
+				locked_parent = true;
+			}
+			break;
+		}
+	}
+
+	j = k = i;
+
+	/* For every remembered NS in which we do not have state, create some,
+	 * by walking backwards (towards the child namespace we wanted to create
+	 * inotify state in the first place)*/
+	for (--i; i!=-1; i--) {
+		uid_t parent_uid;
+		struct inotify_state *parent_state = NULL;
+
+		/* 1. Get state from parent */
+		current_ns = pns[i].ns;
+		if (current_ns != &init_user_ns) {
+			parent_uid = from_kuid(current_ns->parent, current_ns->owner);
+			parent_state = __find_inotify_state(current_ns->parent, parent_uid);
+			BUG_ON(!parent_state);
+		}
+
+	        state = kzalloc(sizeof(struct inotify_state), GFP_KERNEL);
+	        if (!state) {
+			ret = -ENOMEM;
+			goto out;
+		}
+
+		/* 2. Init */
+		state->uid = pns[i].uid;
+		__init_counters(state, parent_state, current_ns);
+
+		/* 3. Finally add to the hash table */
+		hash_add(current_ns->inotify_counts, &state->node, state->uid);
+	}
+
+	state = __find_inotify_state(ns, uid);
+	BUG_ON(!state);
+	BUG_ON(page_counter_read(&state->instances) != 0);
+
+	/* This can fail if the hierarchical limits are exceeded */
+	if (!page_counter_try_charge(&state->instances, 1, &cnt))
+		ret = -EMFILE;
+out:
+	/* This doesn't unlock pns[0] since it is the child ns which is going to
+	 * be unlocked in inotify_init_state
+	 */
+	for (--j; j; j--) {
+		mutex_unlock(&pns[j].ns->inotify_lock);
+	}
+
+	if (locked_parent) {
+		--k;
+		mutex_unlock(&pns[k].ns->parent->inotify_lock);
+	}
+	kfree(pns);
+	return ret;
+}
+
+static noinline int inotify_init_state(struct user_namespace *ns, uid_t uid)
+{
+	int ret = 0;
+	struct inotify_state *state;
+	struct page_counter *cnt;
+
+	mutex_lock(&ns->inotify_lock);
+	state =  __find_inotify_state(ns, uid);
+
+	if (!state) {
+
+		if (ns == &init_user_ns) {
+			state = kzalloc(sizeof(struct inotify_state), GFP_KERNEL);
+			if (!state) {
+				ret = -ENOMEM;
+				goto out;
+			}
+
+			state->uid = uid;
+			__init_counters(state, NULL, ns);
+			page_counter_charge(&state->instances, 1);
+			hash_add(ns->inotify_counts, &state->node, uid);
+		} else {
+			ret = __create_parent_state(ns, uid);
+			if (ret < 0)
+				goto out;
+		}
+
+	} else {
+		if (!page_counter_try_charge(&state->instances, 1, &cnt)) {
+			ret = -EMFILE;
+			goto out;
+		}
+	}
+
+out:
+       mutex_unlock(&ns->inotify_lock);
+       return ret;
+}
+
+
 static inline __u32 inotify_arg_to_mask(u32 arg)
 {
 	__u32 mask;
@@ -821,6 +1010,11 @@ static int __init inotify_user_setup(void)
 	inotify_max_queued_events = 16384;
 	inotify_max_user_instances = 128;
 	inotify_max_user_watches = 8192;
+	init_user_ns.inotify_max_user_instances = 256;
+	init_user_ns.inotify_max_user_watches = 8192;
+	/* These reserves should allow for 8 levels of nesting in userns */
+	inotify_reserved_user_instances = 32;
+	inotify_reserved_user_watches = 1024;
 
 	return 0;
 }
diff --git a/include/linux/fsnotify_backend.h b/include/linux/fsnotify_backend.h
index 29f917517299..a4723b7e08bb 100644
--- a/include/linux/fsnotify_backend.h
+++ b/include/linux/fsnotify_backend.h
@@ -170,6 +170,9 @@ struct fsnotify_group {
 			spinlock_t	idr_lock;
 			struct idr      idr;
 			struct user_struct      *user;
+			struct user_namespace *userns;
+			uid_t uid; /* id in the userns this group is
+				      associated with */
 		} inotify_data;
 #endif
 #ifdef CONFIG_FANOTIFY
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 8297e5b341d8..d34d8ef68e27 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -6,6 +6,8 @@
 #include <linux/ns_common.h>
 #include <linux/sched.h>
 #include <linux/err.h>
+#include <linux/hashtable.h>
+#include <linux/spinlock.h>
 
 #define UID_GID_MAP_MAX_EXTENTS 5
 
@@ -39,6 +41,14 @@ struct user_namespace {
 	struct key		*persistent_keyring_register;
 	struct rw_semaphore	persistent_keyring_register_sem;
 #endif
+
+#ifdef CONFIG_INOTIFY_USER
+#define INOTIFY_HASHTABLE_BITS 6
+	struct mutex inotify_lock;
+	DECLARE_HASHTABLE(inotify_counts, INOTIFY_HASHTABLE_BITS);
+	int inotify_max_user_instances;
+	int inotify_max_user_watches;
+#endif
 };
 
 extern struct user_namespace init_user_ns;
diff --git a/kernel/user.c b/kernel/user.c
index b069ccbfb0b0..6dcb8eea358d 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -59,6 +59,11 @@ struct user_namespace init_user_ns = {
 	.persistent_keyring_register_sem =
 	__RWSEM_INITIALIZER(init_user_ns.persistent_keyring_register_sem),
 #endif
+
+#ifdef CONFIG_INOTIFY_USER
+	.inotify_lock =__MUTEX_INITIALIZER(init_user_ns.inotify_lock),
+	.inotify_counts = __HASHTABLE_INITIALIZER(INOTIFY_HASHTABLE_BITS),
+#endif
 };
 EXPORT_SYMBOL_GPL(init_user_ns);
 
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 9bafc211930c..bce1b7427ec4 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -22,10 +22,17 @@
 #include <linux/ctype.h>
 #include <linux/projid.h>
 #include <linux/fs_struct.h>
+#include <linux/spinlock.h>
+#include <linux/kernel.h>
 
 static struct kmem_cache *user_ns_cachep __read_mostly;
 static DEFINE_MUTEX(userns_state_mutex);
 
+#ifdef CONFIG_INOTIFY_USER
+extern int inotify_reserved_user_instances;
+extern int inotify_reserved_user_watches;
+#endif
+
 static bool new_idmap_permitted(const struct file *file,
 				struct user_namespace *ns, int cap_setid,
 				struct uid_gid_map *map);
@@ -63,7 +70,9 @@ int create_user_ns(struct cred *new)
 	kuid_t owner = new->euid;
 	kgid_t group = new->egid;
 	int ret;
-
+#ifdef CONFIG_INOTIFY_USER
+	int tmp;
+#endif
 	if (parent_ns->level > 32)
 		return -EUSERS;
 
@@ -112,6 +121,17 @@ int create_user_ns(struct cred *new)
 #ifdef CONFIG_PERSISTENT_KEYRINGS
 	init_rwsem(&ns->persistent_keyring_register_sem);
 #endif
+
+#ifdef CONFIG_INOTIFY_USER
+	mutex_init(&ns->inotify_lock);
+	hash_init(ns->inotify_counts);
+
+	tmp = parent_ns->inotify_max_user_instances - inotify_reserved_user_instances;
+	ns->inotify_max_user_instances = max(0, tmp);
+
+	tmp = parent_ns->inotify_max_user_watches - inotify_reserved_user_watches;
+	ns->inotify_max_user_watches = max(0, tmp);
+#endif
 	return 0;
 }
 
-- 
2.5.0
