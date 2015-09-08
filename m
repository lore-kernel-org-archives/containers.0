From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: [RFC PATCH 1/2] userns: Implement per-userns nproc infrastructure
Date: Tue,  8 Sep 2015 11:11:12 +0300
Message-ID: <1441699873-26653-2-git-send-email-kernel@kyup.com>
References: <1441699873-26653-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1441699873-26653-1-git-send-email-kernel-6AxghH7DbtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Nikolay Borisov <n.borisov-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Nikolay Borisov <n.borisov-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org>

This patch add a simple hashtable to the user_namespace structure and
the necessary functions to work with it. The idea is to keep a
uid->nproc counts per-namespace.

Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
---
 include/linux/user_namespace.h |  15 +++++-
 kernel/user.c                  |   3 ++
 kernel/user_namespace.c        | 105 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 122 insertions(+), 1 deletion(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 8297e5b..6eb9414 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -5,6 +5,9 @@
 #include <linux/nsproxy.h>
 #include <linux/ns_common.h>
 #include <linux/sched.h>
+#include <linux/hashtable.h>
+#include <linux/spinlock.h>
+#include <linux/types.h>
 #include <linux/err.h>
 
 #define UID_GID_MAP_MAX_EXTENTS 5
@@ -21,7 +24,7 @@ struct uid_gid_map {	/* 64 bytes -- 1 cache line */
 #define USERNS_SETGROUPS_ALLOWED 1UL
 
 #define USERNS_INIT_FLAGS USERNS_SETGROUPS_ALLOWED
-
+#define NPROC_HASH_ORDER 7
 struct user_namespace {
 	struct uid_gid_map	uid_map;
 	struct uid_gid_map	gid_map;
@@ -33,6 +36,8 @@ struct user_namespace {
 	kgid_t			group;
 	struct ns_common	ns;
 	unsigned long		flags;
+	struct spinlock		nproc_hash_lock;
+	DECLARE_HASHTABLE(nproc_hash, NPROC_HASH_ORDER);
 
 	/* Register of per-UID persistent keyrings for this namespace */
 #ifdef CONFIG_PERSISTENT_KEYRINGS
@@ -72,6 +77,9 @@ extern ssize_t proc_projid_map_write(struct file *, const char __user *, size_t,
 extern ssize_t proc_setgroups_write(struct file *, const char __user *, size_t, loff_t *);
 extern int proc_setgroups_show(struct seq_file *m, void *v);
 extern bool userns_may_setgroups(const struct user_namespace *ns);
+extern void userns_nproc_inc(struct user_namespace *ns, uid_t uid);
+extern void userns_nproc_dec(struct user_namespace *ns, uid_t uid);
+extern uint32_t get_userns_nproc(struct user_namespace *ns, uid_t uid);
 #else
 
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
@@ -100,6 +108,11 @@ static inline bool userns_may_setgroups(const struct user_namespace *ns)
 {
 	return true;
 }
+
+
+static void userns_nproc_inc(ustruct user_namespace *ns, id_t uid) {}
+static void userns_nproc_dec(ustruct user_namespace *ns, id_t uid) {}
+static uint32_t get_userns_nproc(ustruct user_namespace *ns, id_t uid) { return 0; }
 #endif
 
 #endif /* _LINUX_USER_H */
diff --git a/kernel/user.c b/kernel/user.c
index b2a552f..3a0e36e 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -54,6 +54,9 @@ struct user_namespace init_user_ns = {
 #ifdef CONFIG_USER_NS
 	.ns.ops = &userns_operations,
 #endif
+	//Intentially leave the nproc_hash_lock uninitialised
+	//as it shouldn't be used in the init namespace
+
 	.flags = USERNS_INIT_FLAGS,
 #ifdef CONFIG_PERSISTENT_KEYRINGS
 	.persistent_keyring_register_sem =
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 2f919cc..654ece7 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -9,6 +9,7 @@
 #include <linux/nsproxy.h>
 #include <linux/slab.h>
 #include <linux/user_namespace.h>
+#include <linux/hashtable.h>
 #include <linux/proc_ns.h>
 #include <linux/highuid.h>
 #include <linux/cred.h>
@@ -26,6 +27,13 @@
 static struct kmem_cache *user_ns_cachep __read_mostly;
 static DEFINE_MUTEX(userns_state_mutex);
 
+struct userns_nproc_count {
+	uint32_t key;
+	atomic_t processes;
+	struct hlist_node node;
+	struct rcu_head rcu_head;
+};
+
 static bool new_idmap_permitted(const struct file *file,
 				struct user_namespace *ns, int cap_setid,
 				struct uid_gid_map *map);
@@ -129,6 +137,10 @@ int create_user_ns(struct cred *new)
 	ns->flags = parent_ns->flags;
 	mutex_unlock(&userns_state_mutex);
 
+	spin_lock_init(&ns->nproc_hash_lock);
+	hash_init(ns->nproc_hash);
+
+	pr_info("new user_ns created: %p\n", ns);
 	set_cred_user_ns(new, ns);
 
 #ifdef CONFIG_PERSISTENT_KEYRINGS
@@ -168,6 +180,9 @@ void free_user_ns(struct user_namespace *ns)
 		key_put(ns->persistent_keyring_register);
 #endif
 		ns_free_inum(&ns->ns);
+
+		BUG_ON(!hash_empty(ns->nproc_hash));
+
 		kmem_cache_free(user_ns_cachep, ns);
 		if (user)
 			atomic_dec(&user->user_namespaces);
@@ -248,6 +263,96 @@ static u32 map_id_up(struct uid_gid_map *map, u32 id)
 	return id;
 }
 
+static struct userns_nproc_count *find_nproc_count(struct user_namespace *ns,
+						   uid_t uid)
+{
+	struct userns_nproc_count *found = NULL;
+
+	hash_for_each_possible(ns->nproc_hash, found, node, uid)
+		if (found->key == uid)
+			return found;
+
+	return NULL;
+}
+
+void userns_nproc_inc(struct user_namespace *ns, uid_t uid)
+{
+	struct userns_nproc_count *nproc_count;
+
+	BUG_ON(!ns);
+
+	spin_lock(&ns->nproc_hash_lock);
+	nproc_count = find_nproc_count(ns, uid);
+
+	if (nproc_count) {
+		atomic_inc(&nproc_count->processes);
+		spin_unlock(&ns->nproc_hash_lock);
+	} else {
+		spin_unlock(&ns->nproc_hash_lock);
+
+		nproc_count = kzalloc(sizeof(struct userns_nproc_count), GFP_KERNEL);
+		if (!nproc_count)
+			return; //silent failure
+
+		atomic_set(&nproc_count->processes, 1);
+		nproc_count->key = uid;
+
+		spin_lock(&ns->nproc_hash_lock);
+		hash_add(ns->nproc_hash, &nproc_count->node, uid);
+		spin_unlock(&ns->nproc_hash_lock);
+	}
+
+	pr_info("\t%s:incrementing count in user_ns: %p for uid: %u old:%d new:%d\n", __func__,
+		ns, uid, atomic_read(&nproc_count->processes)-1, atomic_read(&nproc_count->processes));
+}
+
+void userns_nproc_dec(struct user_namespace *ns, uid_t uid)
+{
+	struct userns_nproc_count *nproc_count;
+	char comm[TASK_COMM_LEN];
+
+	BUG_ON(!ns);
+
+	spin_lock(&ns->nproc_hash_lock);
+	nproc_count = find_nproc_count(ns, uid);
+
+	if (!nproc_count || atomic_read(&nproc_count->processes) <= 0)
+		pr_info("Will bug on %s/%d for uid: %d\n", get_task_comm(comm, current), task_pid_nr(current), uid);
+
+	BUG_ON(!nproc_count);
+
+	pr_info("\t%s:decrementing count in user_ns: %p for uid: %u old:%d new:%d\n", __func__,
+		ns, uid, atomic_read(&nproc_count->processes)+1, atomic_read(&nproc_count->processes));
+
+	if (atomic_dec_and_test(&nproc_count->processes)) {
+		pr_info("\t%s:Freeing nproc_count node for uid %s/%d\n", __func__, get_task_comm(comm, current), task_pid_nr(current));
+
+		hash_del(&nproc_count->node);
+		kfree(nproc_count);
+	}
+
+	spin_unlock(&ns->nproc_hash_lock);
+}
+
+uint32_t get_userns_nproc(struct user_namespace *ns, uid_t uid)
+{
+	struct userns_nproc_count *nproc_count;
+	uint32_t ret;
+
+	BUG_ON(!ns);
+
+	spin_lock(&ns->nproc_hash_lock);
+	nproc_count = find_nproc_count(ns, uid);
+
+	BUG_ON(!nproc_count);
+
+	ret = atomic_read(&nproc_count->processes);
+	spin_unlock(&ns->nproc_hash_lock);
+
+	return ret;
+}
+
+
 /**
  *	make_kuid - Map a user-namespace uid pair into a kuid.
  *	@ns:  User namespace that the uid is in
-- 
2.5.0
