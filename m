From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH RFC] User namespaces: general cleanups
Date: Thu, 9 Oct 2008 20:19:17 -0500
Message-ID: <20081010011917.GA8046@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

David, here is a new version taking into account your feedback from
yesterday.

Eric, it has changed quite a bit since you last looked at it, so if you
have a chance to take another look that'd be great.  It's still just the
general cleanup, no handling of cross-userns capabilities or file
accesses :)

thanks,
-serge

From da249dbe92c1b218f8194a7fd386e5fba91049c1 Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Thu, 9 Oct 2008 13:21:07 -0500
Subject: [PATCH 1/1] User namespaces: general cleanups

Move the user namespace from the nsproxy to the struct user_struct, because
	1. otherwise a struct cred or struct user_struct is insufficient to
	   unambiguously determine uid equivalence
	2. this nicely fits the hierarchical user namespace+struct user_struct
	   model.

When a user_namespace is created, the user which created it is
marked as its 'creator'.  The user_namespace pins the creator.
Each userid in a user_ns pins the user_ns.  This keeps refcounting
nice and simple.  Refcounting rules are as follows:

        The task pins the user struct.

        The user struct pins its user namespace.

        The user namespace pins the struct user which created it.

User namespaces are cloned during copy_creds().  Unsharing a new user_ns
is no longer possible.  (We could re-add that, but it'll cause code
duplication and doesn't seem useful if PAM doesn't need to clone user
namespaces).

Open question: do we need to sched_switch_user(task) for the new
user namespace?  My inclination is to say that ideally we want
scheduling to be based on the userid in the top level user_ns
anyway, so ignore the question for now.

Todo: remove debug printks

Changelog
	Oct 9: Move create_new_userns from create_new_namespaces
		to copy_creds().

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/init_task.h      |    1 -
 include/linux/nsproxy.h        |    1 -
 include/linux/sched.h          |    1 +
 include/linux/user_namespace.h |   13 ++------
 kernel/cred.c                  |   28 ++++++++++++++++++-
 kernel/fork.c                  |    5 +--
 kernel/nsproxy.c               |   15 +--------
 kernel/sys.c                   |    4 +-
 kernel/user.c                  |   52 ++++++++++++----------------------
 kernel/user_namespace.c        |   60 +++++++++++----------------------------
 10 files changed, 74 insertions(+), 106 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index edf0285..126c3c4 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -57,7 +57,6 @@ extern struct nsproxy init_nsproxy;
 	.mnt_ns		= NULL,						\
 	INIT_NET_NS(net_ns)                                             \
 	INIT_IPC_NS(ipc_ns)						\
-	.user_ns	= &init_user_ns,				\
 }
 
 #define INIT_SIGHAND(sighand) {						\
diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index c8a768e..afad7de 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -27,7 +27,6 @@ struct nsproxy {
 	struct ipc_namespace *ipc_ns;
 	struct mnt_namespace *mnt_ns;
 	struct pid_namespace *pid_ns;
-	struct user_namespace *user_ns;
 	struct net 	     *net_ns;
 };
 extern struct nsproxy init_nsproxy;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 86ba19c..86acc5f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -595,6 +595,7 @@ struct user_struct {
 	/* Hash table maintenance information */
 	struct hlist_node uidhash_node;
 	uid_t uid;
+	struct user_namespace *user_ns;
 
 #ifdef CONFIG_USER_SCHED
 	struct task_group *tg;
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index b5f41d4..d6e61a2 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -12,7 +12,7 @@
 struct user_namespace {
 	struct kref		kref;
 	struct hlist_head	uidhash_table[UIDHASH_SZ];
-	struct user_struct	*root_user;
+	struct user_struct	*creator;
 };
 
 extern struct user_namespace init_user_ns;
@@ -26,8 +26,7 @@ static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 	return ns;
 }
 
-extern struct user_namespace *copy_user_ns(int flags,
-					   struct user_namespace *old_ns);
+extern struct user_struct *create_new_userns(struct task_struct *tsk);
 extern void free_user_ns(struct kref *kref);
 
 static inline void put_user_ns(struct user_namespace *ns)
@@ -43,13 +42,9 @@ static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 	return &init_user_ns;
 }
 
-static inline struct user_namespace *copy_user_ns(int flags,
-						  struct user_namespace *old_ns)
+static inline struct user_struct *create_new_userns(struct task_struct *tsk)
 {
-	if (flags & CLONE_NEWUSER)
-		return ERR_PTR(-EINVAL);
-
-	return old_ns;
+	return ERR_PTR(-EINVAL);
 }
 
 static inline void put_user_ns(struct user_namespace *ns)
diff --git a/kernel/cred.c b/kernel/cred.c
index 13697ca..abaf318 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -274,6 +274,7 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 	struct thread_group_cred *tgcred;
 #endif
 	struct cred *new;
+	struct user_struct *new_root = NULL;
 
 	mutex_init(&p->cred_exec_mutex);
 
@@ -289,9 +290,34 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 		return 0;
 	}
 
+	if (clone_flags & CLONE_NEWUSER) {
+		/*
+		 * hopefully the capability check goes away when userns support
+		 * is complete
+		 */
+		if (!capable(CAP_SYS_ADMIN))
+			return -EPERM;
+		if (clone_flags & CLONE_THREAD)
+			return -EINVAL;
+		new_root = create_new_userns(p);
+		if (IS_ERR(new_root))
+			return PTR_ERR(new_root);
+	}
+
 	new = prepare_creds();
-	if (!new)
+	if (!new) {
+		free_uid(new_root);
 		return -ENOMEM;
+	}
+
+	/* If we created a new user_ns, make its root user
+	 * our user */
+	if (new_root) {
+		new->uid = new->euid = new->suid = new->fsuid = 0;
+		new->gid = new->egid = new->sgid = new->fsgid = 0;
+		free_uid(new->user);
+		new->user = new_root;
+	}
 
 #ifdef CONFIG_KEYS
 	/* new threads get their own thread keyrings if their parent already
diff --git a/kernel/fork.c b/kernel/fork.c
index e65f424..b533278 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -933,7 +933,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	if (atomic_read(&p->real_cred->user->processes) >=
 			p->signal->rlim[RLIMIT_NPROC].rlim_cur) {
 		if (!capable(CAP_SYS_ADMIN) && !capable(CAP_SYS_RESOURCE) &&
-		    p->real_cred->user != current->nsproxy->user_ns->root_user)
+		    p->real_cred->user != INIT_USER)
 			goto bad_fork_free;
 	}
 
@@ -1553,8 +1553,7 @@ asmlinkage long sys_unshare(unsigned long unshare_flags)
 	err = -EINVAL;
 	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
 				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
-				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWUSER|
-				CLONE_NEWNET))
+				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET))
 		goto bad_unshare_out;
 
 	/*
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 1d3ef29..63598dc 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -80,12 +80,6 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		goto out_pid;
 	}
 
-	new_nsp->user_ns = copy_user_ns(flags, tsk->nsproxy->user_ns);
-	if (IS_ERR(new_nsp->user_ns)) {
-		err = PTR_ERR(new_nsp->user_ns);
-		goto out_user;
-	}
-
 	new_nsp->net_ns = copy_net_ns(flags, tsk->nsproxy->net_ns);
 	if (IS_ERR(new_nsp->net_ns)) {
 		err = PTR_ERR(new_nsp->net_ns);
@@ -95,9 +89,6 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 	return new_nsp;
 
 out_net:
-	if (new_nsp->user_ns)
-		put_user_ns(new_nsp->user_ns);
-out_user:
 	if (new_nsp->pid_ns)
 		put_pid_ns(new_nsp->pid_ns);
 out_pid:
@@ -130,7 +121,7 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 	get_nsproxy(old_ns);
 
 	if (!(flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
-				CLONE_NEWUSER | CLONE_NEWPID | CLONE_NEWNET)))
+				CLONE_NEWPID | CLONE_NEWNET)))
 		return 0;
 
 	if (!capable(CAP_SYS_ADMIN)) {
@@ -173,8 +164,6 @@ void free_nsproxy(struct nsproxy *ns)
 		put_ipc_ns(ns->ipc_ns);
 	if (ns->pid_ns)
 		put_pid_ns(ns->pid_ns);
-	if (ns->user_ns)
-		put_user_ns(ns->user_ns);
 	put_net(ns->net_ns);
 	kmem_cache_free(nsproxy_cachep, ns);
 }
@@ -189,7 +178,7 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 	int err = 0;
 
 	if (!(unshare_flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
-			       CLONE_NEWUSER | CLONE_NEWNET)))
+			       CLONE_NEWNET)))
 		return 0;
 
 	if (!capable(CAP_SYS_ADMIN))
diff --git a/kernel/sys.c b/kernel/sys.c
index 68ce096..d2bed52 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -565,13 +565,13 @@ static int set_user(struct cred *new)
 {
 	struct user_struct *new_user;
 
-	new_user = alloc_uid(current->nsproxy->user_ns, new->uid);
+	new_user = alloc_uid(current_user()->user_ns, new->uid);
 	if (!new_user)
 		return -EAGAIN;
 
 	if (atomic_read(&new_user->processes) >=
 				current->signal->rlim[RLIMIT_NPROC].rlim_cur &&
-			new_user != current->nsproxy->user_ns->root_user) {
+			new_user != INIT_USER) {
 		free_uid(new_user);
 		return -EAGAIN;
 	}
diff --git a/kernel/user.c b/kernel/user.c
index ed4dc57..1390387 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -20,9 +20,9 @@
 
 struct user_namespace init_user_ns = {
 	.kref = {
-		.refcount	= ATOMIC_INIT(2),
+		.refcount	= ATOMIC_INIT(1),
 	},
-	.root_user = &root_user,
+	.creator = &root_user,
 };
 EXPORT_SYMBOL_GPL(init_user_ns);
 
@@ -48,12 +48,14 @@ static struct kmem_cache *uid_cachep;
  */
 static DEFINE_SPINLOCK(uidhash_lock);
 
+/* root_user.__count is 2, 1 for init task cred, 1 for init_user_ns->creator */
 struct user_struct root_user = {
-	.__count	= ATOMIC_INIT(1),
+	.__count	= ATOMIC_INIT(2),
 	.processes	= ATOMIC_INIT(1),
 	.files		= ATOMIC_INIT(0),
 	.sigpending	= ATOMIC_INIT(0),
 	.locked_shm     = 0,
+	.user_ns	= &init_user_ns,
 #ifdef CONFIG_USER_SCHED
 	.tg		= &init_task_group,
 #endif
@@ -314,12 +316,15 @@ done:
  * IRQ state (as stored in flags) is restored and uidhash_lock released
  * upon function exit.
  */
-static inline void free_user(struct user_struct *up, unsigned long flags)
+static void free_user(struct user_struct *up, unsigned long flags)
 {
+	printk(KERN_NOTICE "%s: freeing uid (%d) in ns (%p)\n",
+		__func__, up->uid, up->user_ns);
 	/* restore back the count */
 	atomic_inc(&up->__count);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
 
+	put_user_ns(up->user_ns);
 	INIT_WORK(&up->work, remove_user_sysfs_dir);
 	schedule_work(&up->work);
 }
@@ -335,13 +340,16 @@ static inline void uids_mutex_unlock(void) { }
  * IRQ state (as stored in flags) is restored and uidhash_lock released
  * upon function exit.
  */
-static inline void free_user(struct user_struct *up, unsigned long flags)
+static void free_user(struct user_struct *up, unsigned long flags)
 {
+	printk(KERN_NOTICE "%s: freeing uid (%d) in ns (%p)\n",
+		__func__, up->uid, up->user_ns);
 	uid_hash_remove(up);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
 	sched_destroy_user(up);
 	key_put(up->uid_keyring);
 	key_put(up->session_keyring);
+	put_user_ns(up->user_ns);
 	kmem_cache_free(uid_cachep, up);
 }
 
@@ -357,7 +365,7 @@ struct user_struct *find_user(uid_t uid)
 {
 	struct user_struct *ret;
 	unsigned long flags;
-	struct user_namespace *ns = current->nsproxy->user_ns;
+	struct user_namespace *ns = current_user()->user_ns;
 
 	spin_lock_irqsave(&uidhash_lock, flags);
 	ret = uid_hash_find(uid, uidhashentry(ns, uid));
@@ -404,6 +412,8 @@ struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
 		if (sched_create_user(new) < 0)
 			goto out_free_user;
 
+		new->user_ns = get_user_ns(ns);
+
 		if (uids_user_create(new))
 			goto out_destoy_sched;
 
@@ -432,10 +442,13 @@ struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
 
 	uids_mutex_unlock();
 
+	printk(KERN_NOTICE "%s: allocated a uid (%d) in user_ns (%p)\n",
+			__func__, uid, ns);
 	return up;
 
 out_destoy_sched:
 	sched_destroy_user(new);
+	put_user_ns(new->user_ns);
 out_free_user:
 	kmem_cache_free(uid_cachep, new);
 out_unlock:
@@ -443,33 +456,6 @@ out_unlock:
 	return NULL;
 }
 
-#ifdef CONFIG_USER_NS
-void release_uids(struct user_namespace *ns)
-{
-	int i;
-	unsigned long flags;
-	struct hlist_head *head;
-	struct hlist_node *nd;
-
-	spin_lock_irqsave(&uidhash_lock, flags);
-	/*
-	 * collapse the chains so that the user_struct-s will
-	 * be still alive, but not in hashes. subsequent free_uid()
-	 * will free them.
-	 */
-	for (i = 0; i < UIDHASH_SZ; i++) {
-		head = ns->uidhash_table + i;
-		while (!hlist_empty(head)) {
-			nd = head->first;
-			hlist_del_init(nd);
-		}
-	}
-	spin_unlock_irqrestore(&uidhash_lock, flags);
-
-	free_uid(ns->root_user);
-}
-#endif
-
 static int __init uid_cache_init(void)
 {
 	int n;
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 0d9c51d..86200b1 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -9,17 +9,16 @@
 #include <linux/nsproxy.h>
 #include <linux/slab.h>
 #include <linux/user_namespace.h>
+#include <linux/cred.h>
 
 /*
- * Clone a new ns copying an original user ns, setting refcount to 1
- * @old_ns: namespace to clone
- * Return NULL on error (failure to kmalloc), new ns otherwise
+ * Return a new user_struct which is root in a new user_ns.  This is called by
+ * copy_creds(), which will finish setting the target task's credentials.
  */
-static struct user_namespace *clone_user_ns(struct user_namespace *old_ns)
+struct user_struct *create_new_userns(struct task_struct *tsk)
 {
 	struct user_namespace *ns;
-	struct user_struct *new_user;
-	struct cred *new;
+	struct user_struct *root_user;
 	int n;
 
 	ns = kmalloc(sizeof(struct user_namespace), GFP_KERNEL);
@@ -31,48 +30,22 @@ static struct user_namespace *clone_user_ns(struct user_namespace *old_ns)
 	for (n = 0; n < UIDHASH_SZ; ++n)
 		INIT_HLIST_HEAD(ns->uidhash_table + n);
 
-	/* Insert new root user.  */
-	ns->root_user = alloc_uid(ns, 0);
-	if (!ns->root_user) {
+	/* Alloc new root user.  */
+	root_user = alloc_uid(ns, 0);
+	if (!root_user) {
 		kfree(ns);
 		return ERR_PTR(-ENOMEM);
 	}
 
-	/* Reset current->user with a new one */
-	new_user = alloc_uid(ns, current_uid());
-	if (!new_user) {
-		free_uid(ns->root_user);
-		kfree(ns);
-		return ERR_PTR(-ENOMEM);
-	}
-
-	/* Install the new user */
-	new = prepare_creds();
-	if (!new) {
-		free_uid(new_user);
-		free_uid(ns->root_user);
-		kfree(ns);
-	}
-	free_uid(new->user);
-	new->user = new_user;
-	commit_creds(new);
-	return ns;
-}
-
-struct user_namespace * copy_user_ns(int flags, struct user_namespace *old_ns)
-{
-	struct user_namespace *new_ns;
-
-	BUG_ON(!old_ns);
-	get_user_ns(old_ns);
-
-	if (!(flags & CLONE_NEWUSER))
-		return old_ns;
+	/* save away and pin the creating user */
+	ns->creator = tsk->cred->user;  /* tsk is still being created */
+	get_uid(ns->creator);
 
-	new_ns = clone_user_ns(old_ns);
+	/* alloc_uid() incremented the userns refcount.  Just set it to 1 */
+	kref_set(&ns->kref, 1);
 
-	put_user_ns(old_ns);
-	return new_ns;
+	printk(KERN_NOTICE "allocated a user_ns (%p)\n", ns);
+	return root_user;
 }
 
 void free_user_ns(struct kref *kref)
@@ -80,7 +53,8 @@ void free_user_ns(struct kref *kref)
 	struct user_namespace *ns;
 
 	ns = container_of(kref, struct user_namespace, kref);
-	release_uids(ns);
+	free_uid(ns->creator);
+	printk(KERN_NOTICE "freeing a user_ns (%p)\n", ns);
 	kfree(ns);
 }
 EXPORT_SYMBOL(free_user_ns);
-- 
1.5.4.3
