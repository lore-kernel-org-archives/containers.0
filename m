From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: [PATCH 3/4] userns/inotify: Initial implementation of inotify
	per-userns
Date: Wed, 13 Jul 2016 15:14:12 +0300
Message-ID: <1468412053-30130-4-git-send-email-kernel@kyup.com>
References: <1468412053-30130-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1468412053-30130-1-git-send-email-kernel-6AxghH7DbtA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org
List-Id: containers.vger.kernel.org

So here is the first version of the hierarchical inotify limits. Changes
include:
 * Added 2 new sysctls:
    - inotify_reserved_user_instances and inotify_reserved_user_watches these essentially
    control the distribution of instances/watches down the hierarchy. For example if we
    have instances/watches limit of 1024/256 and reserved instances/watches are set to
    128/32 then at every level of the hierarchy instances/watches are going to be reduced
    by 128/32, so at userns level of 1 (e.g. init_user_ns->level_1_user_ns) each user would
    have 896/224 respectively. Currently the defaults are calculated so that at least 8 levels
    of indirection are allowed. Those can be set only by global root user.

 * Changed core userns code to support adding per-userns/per-user counters, this
 is happening in the nsuser_state structure.

 * Add necessary functionality to inotify to make use of the newly added
 userns infrastructure.

 * Moved the initialization of the inotify_max_user_instances/watches to
 user_namespaces_init so that it's initialised by the time inotify is
 bootstrapped.

Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
---
 fs/notify/inotify/inotify.h      |   2 +
 fs/notify/inotify/inotify_user.c |  93 +++++++++++++++++++++++++++++++++-
 include/linux/fsnotify_backend.h |   3 ++
 include/linux/user_namespace.h   |  45 +++++++++++++++++
 kernel/user_namespace.c          | 106 ++++++++++++++++++++++++++++++++++++++-
 5 files changed, 246 insertions(+), 3 deletions(-)

diff --git a/fs/notify/inotify/inotify.h b/fs/notify/inotify/inotify.h
index ed855ef6f077..8ead0a1a3cdb 100644
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
diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
index b8d08d0d0a4d..076a9990eff4 100644
--- a/fs/notify/inotify/inotify_user.c
+++ b/fs/notify/inotify/inotify_user.c
@@ -48,6 +48,8 @@
 static int inotify_max_user_instances __read_mostly;
 static int inotify_max_queued_events __read_mostly;
 static int inotify_max_user_watches __read_mostly;
+int inotify_reserved_user_instances __read_mostly;
+int inotify_reserved_user_watches   __read_mostly;
 
 static struct kmem_cache *inotify_inode_mark_cachep __read_mostly;
 
@@ -82,10 +84,96 @@ struct ctl_table inotify_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero
 	},
+	{
+		.procname	= "reserved_user_instances",
+		.data		= &inotify_reserved_user_instances,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+	},
+	{
+		.procname	= "reserved_user_watches",
+		.data		= &inotify_reserved_user_watches,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+	},
 	{ }
 };
 #endif /* CONFIG_SYSCTL */
 
+static inline void __init_counters(struct nsuser_state *state,
+				   struct nsuser_state *parent,
+				   struct user_namespace *ns)
+{
+	if (ns == &init_user_ns) {
+		page_counter_init(&state->inotify_watches, NULL);
+		page_counter_init(&state->inotify_instances, NULL);
+		page_counter_limit(&state->inotify_watches,
+				   init_user_ns.inotify_max_user_watches);
+		page_counter_limit(&state->inotify_instances,
+				   init_user_ns.inotify_max_user_instances);
+	} else {
+		page_counter_init(&state->inotify_watches,
+				  &parent->inotify_watches);
+		page_counter_init(&state->inotify_instances,
+				  &parent->inotify_instances);
+		page_counter_limit(&state->inotify_watches, ns->inotify_max_user_watches);
+		page_counter_limit(&state->inotify_instances, ns->inotify_max_user_instances);
+	}
+}
+
+static noinline int inotify_init_state(struct user_namespace *ns, kuid_t uid)
+{
+	struct nsuser_state *state;
+	struct page_counter *cnt;
+
+	/* We can work with the data without the lock held, since liveliness
+	 * of data is guaranteed as long as the namespace is alive
+	 */
+	spin_lock_bh(&nsuser_state_lock);
+	state = get_nsuser_state(ns, uid);
+	spin_unlock_bh(&nsuser_state_lock);
+
+	if (!state) {
+
+		state = kzalloc(sizeof(struct nsuser_state), GFP_KERNEL);
+		if (!state)
+			return -ENOMEM;
+
+		state->uid = uid;
+		state->ns = ns;
+
+		if (ns == &init_user_ns)
+			__init_counters(state, NULL, ns);
+		else {
+			struct nsuser_state *parent_state;
+
+			spin_lock_bh(&nsuser_state_lock);
+			parent_state = get_nsuser_state(ns->parent, ns->owner);
+			spin_unlock_bh(&nsuser_state_lock);
+
+			BUG_ON(!parent_state);
+
+			__init_counters(state, parent_state, ns);
+		}
+
+		page_counter_charge(&state->inotify_instances, 1);
+
+		spin_lock_bh(&nsuser_state_lock);
+		hash_add(nsstate_hash, &state->node, __kuid_val(uid));
+		spin_unlock_bh(&nsuser_state_lock);
+	} else {
+		if (!page_counter_try_charge(&state->inotify_instances, 1, &cnt))
+			return -EMFILE;
+	}
+
+	return 0;
+}
+
+
 static inline __u32 inotify_arg_to_mask(u32 arg)
 {
 	__u32 mask;
@@ -819,8 +907,9 @@ static int __init inotify_user_setup(void)
 	inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark, SLAB_PANIC);
 
 	inotify_max_queued_events = 16384;
-	inotify_max_user_instances = 128;
-	inotify_max_user_watches = 8192;
+	/* These reserves should allow for 8 levels of nesting in userns */
+	inotify_reserved_user_instances = 32;
+	inotify_reserved_user_watches = 1024;
 
 	return 0;
 }
diff --git a/include/linux/fsnotify_backend.h b/include/linux/fsnotify_backend.h
index 29f917517299..eb83a10afac7 100644
--- a/include/linux/fsnotify_backend.h
+++ b/include/linux/fsnotify_backend.h
@@ -170,6 +170,9 @@ struct fsnotify_group {
 			spinlock_t	idr_lock;
 			struct idr      idr;
 			struct user_struct      *user;
+			struct user_namespace *userns;
+			kuid_t uid; /* id in the userns this group is
+				      associated with */
 		} inotify_data;
 #endif
 #ifdef CONFIG_FANOTIFY
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 8297e5b341d8..3116a2df1cee 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -6,6 +6,9 @@
 #include <linux/ns_common.h>
 #include <linux/sched.h>
 #include <linux/err.h>
+#include <linux/hashtable.h>
+#include <linux/spinlock.h>
+#include <linux/page_counter.h>
 
 #define UID_GID_MAP_MAX_EXTENTS 5
 
@@ -22,6 +25,21 @@ struct uid_gid_map {	/* 64 bytes -- 1 cache line */
 
 #define USERNS_INIT_FLAGS USERNS_SETGROUPS_ALLOWED
 
+#define NSSTATE_HASHTABLE_BITS 10
+extern DECLARE_HASHTABLE(nsstate_hash, NSSTATE_HASHTABLE_BITS);
+extern spinlock_t nsuser_state_lock;
+
+/* Generic struct to hold various peruser/perns state */
+struct nsuser_state {
+	struct hlist_node node; /* keyed at nstate_hash */
+	void *ns; /* ns in which uid is valid */
+	kuid_t uid;
+#ifdef CONFIG_INOTIFY_USER
+	struct page_counter inotify_watches; /* How many inotify watches does this user */
+	struct page_counter inotify_instances; /* How many inotify devs does this user have opened? */
+#endif
+};
+
 struct user_namespace {
 	struct uid_gid_map	uid_map;
 	struct uid_gid_map	gid_map;
@@ -39,11 +57,28 @@ struct user_namespace {
 	struct key		*persistent_keyring_register;
 	struct rw_semaphore	persistent_keyring_register_sem;
 #endif
+
+#ifdef CONFIG_INOTIFY_USER
+	int inotify_max_user_instances;
+	int inotify_max_user_watches;
+#endif
 };
 
 extern struct user_namespace init_user_ns;
 
 #ifdef CONFIG_USER_NS
+static inline struct nsuser_state *get_nsuser_state(struct user_namespace *ns,
+						    kuid_t uid)
+{
+       struct nsuser_state *state;
+
+       WARN_ON(!spin_is_locked(&nsuser_state_lock));
+
+       hash_for_each_possible(nsstate_hash, state, node, __kuid_val(uid))
+               if (state->ns == ns && uid_eq(state->uid, uid))
+                       return state;
+       return NULL;
+}
 
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 {
@@ -74,6 +109,16 @@ extern int proc_setgroups_show(struct seq_file *m, void *v);
 extern bool userns_may_setgroups(const struct user_namespace *ns);
 #else
 
+static inline struct nsuser_state *get_nsuser_state(struct user_namespace *ns,
+						    kuid_t uid)
+{
+       struct nsuser_state *state;
+       hash_for_each_possible(nsstate_hash, state, node, &init_user_ns)
+               if (uid_eq(uid, state->uid) && state->ns == ns);
+                       return state;
+       return NULL;
+}
+
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 {
 	return &init_user_ns;
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 9bafc211930c..cb51e3607d2d 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -22,10 +22,20 @@
 #include <linux/ctype.h>
 #include <linux/projid.h>
 #include <linux/fs_struct.h>
+#include <linux/spinlock.h>
+#include <linux/kernel.h>
 
 static struct kmem_cache *user_ns_cachep __read_mostly;
 static DEFINE_MUTEX(userns_state_mutex);
 
+DEFINE_HASHTABLE(nsstate_hash, NSSTATE_HASHTABLE_BITS);
+DEFINE_SPINLOCK(nsuser_state_lock);
+
+#ifdef CONFIG_INOTIFY_USER
+extern int inotify_reserved_user_instances;
+extern int inotify_reserved_user_watches;
+#endif
+
 static bool new_idmap_permitted(const struct file *file,
 				struct user_namespace *ns, int cap_setid,
 				struct uid_gid_map *map);
@@ -60,10 +70,13 @@ static void set_cred_user_ns(struct cred *cred, struct user_namespace *user_ns)
 int create_user_ns(struct cred *new)
 {
 	struct user_namespace *ns, *parent_ns = new->user_ns;
+	struct nsuser_state *state, *parent_state;
 	kuid_t owner = new->euid;
 	kgid_t group = new->egid;
 	int ret;
-
+#ifdef CONFIG_INOTIFY_USER
+	int tmp;
+#endif
 	if (parent_ns->level > 32)
 		return -EUSERS;
 
@@ -88,9 +101,16 @@ int create_user_ns(struct cred *new)
 	if (!ns)
 		return -ENOMEM;
 
+	state = kmalloc(sizeof(struct nsuser_state), GFP_KERNEL);
+	if (!state) {
+		kmem_cache_free(user_ns_cachep, ns);
+		return -ENOMEM;
+	}
+
 	ret = ns_alloc_inum(&ns->ns);
 	if (ret) {
 		kmem_cache_free(user_ns_cachep, ns);
+		kfree(state);
 		return ret;
 	}
 	ns->ns.ops = &userns_operations;
@@ -101,6 +121,13 @@ int create_user_ns(struct cred *new)
 	ns->level = parent_ns->level + 1;
 	ns->owner = owner;
 	ns->group = group;
+#ifdef CONFIG_INOTIFY_USER
+	tmp = parent_ns->inotify_max_user_instances - inotify_reserved_user_instances;
+	ns->inotify_max_user_instances = max(0, tmp);
+
+	tmp = parent_ns->inotify_max_user_watches - inotify_reserved_user_watches;
+	ns->inotify_max_user_watches = max(0, tmp);
+#endif
 
 	/* Inherit USERNS_SETGROUPS_ALLOWED from our parent */
 	mutex_lock(&userns_state_mutex);
@@ -112,8 +139,63 @@ int create_user_ns(struct cred *new)
 #ifdef CONFIG_PERSISTENT_KEYRINGS
 	init_rwsem(&ns->persistent_keyring_register_sem);
 #endif
+
+	spin_lock_bh(&nsuser_state_lock);
+	parent_state = get_nsuser_state(parent_ns, owner);
+	spin_unlock_bh(&nsuser_state_lock);
+	if (!parent_state) {
+		struct nsuser_state *grandfather_state;
+
+		spin_lock_bh(&nsuser_state_lock);
+		/* init_user_ns doesn't have a parent */
+		if (parent_ns == &init_user_ns)
+			grandfather_state = get_nsuser_state(parent_ns, parent_ns->owner);
+		else
+			grandfather_state = get_nsuser_state(parent_ns->parent, parent_ns->owner);
+		spin_unlock_bh(&nsuser_state_lock);
+
+		state->uid = owner;
+		state->ns = parent_ns;
+
+#ifdef CONFIG_INOTIFY_USER
+		page_counter_init(&state->inotify_watches,
+				  &grandfather_state->inotify_watches);
+		page_counter_init(&state->inotify_instances,
+				  &grandfather_state->inotify_instances);
+		page_counter_limit(&state->inotify_watches,
+				   parent_ns->inotify_max_user_watches);
+		page_counter_limit(&state->inotify_instances,
+				   parent_ns->inotify_max_user_instances);
+#endif
+
+		spin_lock_bh(&nsuser_state_lock);
+		hash_add(nsstate_hash, &state->node, __kuid_val(owner));
+		spin_unlock_bh(&nsuser_state_lock);
+	}
+
 	return 0;
 }
+/* Delete all state related to a user ns. All processes of a
+ * namespace should be dead by this time and no references
+ * to the peruser/perns state variables should be live.As such
+ * we can be modifying the hashtable without holding the lock
+ */
+static void free_nsuser_state(struct user_namespace *ns)
+{
+	int bkt;
+	struct hlist_node *tmp;
+	struct nsuser_state *state;
+
+	hash_for_each_safe(nsstate_hash, bkt, tmp, state, node) {
+		if (state->ns == ns) {
+			BUG_ON(page_counter_read(&state->inotify_instances));
+			BUG_ON(page_counter_read(&state->inotify_watches));
+
+			hash_del(&state->node);
+			kfree(state);
+		}
+	}
+}
 
 int unshare_userns(unsigned long unshare_flags, struct cred **new_cred)
 {
@@ -141,6 +223,10 @@ void free_user_ns(struct user_namespace *ns)
 
 	do {
 		parent = ns->parent;
+
+		spin_lock_bh(&nsuser_state_lock);
+		free_nsuser_state(ns);
+		spin_unlock_bh(&nsuser_state_lock);
 #ifdef CONFIG_PERSISTENT_KEYRINGS
 		key_put(ns->persistent_keyring_register);
 #endif
@@ -1000,7 +1086,25 @@ const struct proc_ns_operations userns_operations = {
 
 static __init int user_namespaces_init(void)
 {
+	struct nsuser_state *root_state = kmalloc(sizeof(struct nsuser_state),
+						  GFP_KERNEL);
+
+	init_user_ns.inotify_max_user_instances = 256;
+	init_user_ns.inotify_max_user_watches = 8192;
+
+#ifdef CONFIG_INOTIFY_USE
+	page_counter_init(&root_state->inotify_watches, NULL);
+	page_counter_init(&root_state->inotify_instances, NULL);
+	page_counter_limit(&root_state->inotify_watches,
+			   init_user_ns.inotify_max_user_watches);
+	page_counter_limit(&root_state->inotify_instances,
+					   init_user_ns.inotify_max_user_instances);
+#endif
+	root_state->uid = GLOBAL_ROOT_UID;
+	root_state->ns = &init_user_ns;
+	hash_add(nsstate_hash, &root_state->node, __kuid_val(GLOBAL_ROOT_UID));
 	user_ns_cachep = KMEM_CACHE(user_namespace, SLAB_PANIC);
+
 	return 0;
 }
 subsys_initcall(user_namespaces_init);
-- 
2.5.0
