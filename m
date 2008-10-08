From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] User namespaces: fix refcounting
Date: Wed, 8 Oct 2008 09:42:46 -0500
Message-ID: <20081008144246.GA26362@us.ibm.com>
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

Hi David,

attached is a respin of the three user namespace cleanup patches I've
been trying to push upstream.  I've ported them on top of James'
next-creds-subsys branch (and consolidated into a single patch bc the
splitup wasn't perfect anyway).

These are prep patches on top of which I can then start the real user
namespace work.  If this looks ok, then I will try to get it into
linux-next after next-creds-subsys goes in there.

Perhaps the most objectionable part of this to you may be the
__task_commit_creds().  In the case of clone(CLONE_NEWUSER),
current is not the task which will receive the new credentials, so
I need to be able to set creds on another task.  The other task is
however still being created, so it is safe in this case.  I kept
__task_commit_creds out of header files assuming that noone else
should be able to use it, ever.

Does this look ok to you?

thanks,
-serge

From b09c70161f58e1d74e84415f29bfaf124367b641 Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 7 Oct 2008 20:54:59 -0500
Subject: [PATCH 1/1] User namespaces: fix refcounting

When a task does clone(CLONE_NEWNS), the task's user is the 'creator' of the
new user_namespace, and the user_namespace is tacked onto a list of those
created by this user.

Move the user namespace from the nsproxy to the struct user_struct, because
	1. otherwise a struct cred or struct user_struct is insufficient to
	   unambiguously determine uid equivalence
	2. this nicely fits the hierarchical user namespace+struct user_struct
	   model.

When a user_namespace is created, the user which created it is
marked as its 'creator'.  The user_namespace pins the creator.
Each userid in a user_ns pins the user_ns.  This keeps refcounting
nice and simple.

At the same time, this patch simplifies the refcounting.  The current
user and userns locking works as follows:

        The task pins the user struct.

        The task pins the nsproxy, the nsproxy pins the user_ns.

        When a new user_ns is created, it creates a root user for
        it, and pins it.  When the nsproxy releases the user_ns,
        the userns tries to release all its user structs.

        So you see that the refcounting "works" for now, but only
        because the nsproxy (and therefore usr_ns) and user structs
        will be freed at the same time - when the last task using
        them is released.

        Now we need to put the user_ns in the struct user.  You can
        see that will mess up the refcounting.

        Fortunately, once the user_ns is available from tsk->user,
        we don't need it in nsproxy.

        So here is how the refcounting *should* be done:

        The task pins the user struct.

        The user struct pins its user namespace.

        The user namespace pins the struct user which created it.

        A user namespace now doesn't need to release its userids,
        because it is only released when its last user disappears.

Finally, this patch fixes a bug where not all credentials were
being reset for the first task in a new user namespace.  In
particular, if you did

	capset cap_sys_admin=ep ns_exec
        su - hallyn
          ns_exec -U /bin/sh
          id

then you'd see hallyn's userid and all preexisting groups.  With this patch,
cloning a new user namespace will set the task's uid and gid to 0, and reset
the group_info to the empty set assigned to init.

Changelog:
	Oct 07: Port on top of David Howell's credentials work.
        Aug 25: make free_user not inlined as it's not trivial.  (Eric
                Biederman suggestion)
        Aug 1: renamed user->user_namespace to user_ns, as the next
                patch did anyway.
        Aug 1: move put_user_ns call in one free_user() definition
                to move it outside the lock in free_user.  put_user_ns
                calls free_user on the user_ns->creator, which in
                turn would grab the lock again.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/init_task.h      |    1 -
 include/linux/nsproxy.h        |    1 -
 include/linux/sched.h          |    1 +
 include/linux/user_namespace.h |   11 +++----
 kernel/cred.c                  |    8 ++++-
 kernel/fork.c                  |    2 +-
 kernel/nsproxy.c               |   10 +-----
 kernel/sys.c                   |    4 +-
 kernel/user.c                  |   40 +++++++--------------------
 kernel/user_namespace.c        |   58 ++++++++++++++++++----------------------
 10 files changed, 53 insertions(+), 83 deletions(-)

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
index b5f41d4..03aedce 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -13,6 +13,7 @@ struct user_namespace {
 	struct kref		kref;
 	struct hlist_head	uidhash_table[UIDHASH_SZ];
 	struct user_struct	*root_user;
+	struct user_struct	*creator;
 };
 
 extern struct user_namespace init_user_ns;
@@ -26,8 +27,7 @@ static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 	return ns;
 }
 
-extern struct user_namespace *copy_user_ns(int flags,
-					   struct user_namespace *old_ns);
+extern int create_new_userns(int flags, struct task_struct *tsk);
 extern void free_user_ns(struct kref *kref);
 
 static inline void put_user_ns(struct user_namespace *ns)
@@ -43,13 +43,12 @@ static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 	return &init_user_ns;
 }
 
-static inline struct user_namespace *copy_user_ns(int flags,
-						  struct user_namespace *old_ns)
+static inline int create_new_userns(int flags, struct task_struct *tsk);
 {
 	if (flags & CLONE_NEWUSER)
-		return ERR_PTR(-EINVAL);
+		return -EINVAL;
 
-	return old_ns;
+	return 0;
 }
 
 static inline void put_user_ns(struct user_namespace *ns)
diff --git a/kernel/cred.c b/kernel/cred.c
index 13697ca..67c9e8c 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -341,9 +341,8 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
  * Always returns 0 thus allowing this function to be tail-called at the end
  * of, say, sys_setgid().
  */
-int commit_creds(struct cred *new)
+int __task_commit_creds(struct task_struct *task, struct cred *new)
 {
-	struct task_struct *task = current;
 	const struct cred *old;
 
 	BUG_ON(task->cred != task->real_cred);
@@ -405,6 +404,11 @@ int commit_creds(struct cred *new)
 	put_cred(old);
 	return 0;
 }
+
+int commit_creds(struct cred *new)
+{
+	return __task_commit_creds(current, new);
+}
 EXPORT_SYMBOL(commit_creds);
 
 /**
diff --git a/kernel/fork.c b/kernel/fork.c
index e65f424..a4eb85e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -933,7 +933,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	if (atomic_read(&p->real_cred->user->processes) >=
 			p->signal->rlim[RLIMIT_NPROC].rlim_cur) {
 		if (!capable(CAP_SYS_ADMIN) && !capable(CAP_SYS_RESOURCE) &&
-		    p->real_cred->user != current->nsproxy->user_ns->root_user)
+		    p->real_cred->user != current_user()->user_ns->root_user)
 			goto bad_fork_free;
 	}
 
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 1d3ef29..766c672 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -80,11 +80,9 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		goto out_pid;
 	}
 
-	new_nsp->user_ns = copy_user_ns(flags, tsk->nsproxy->user_ns);
-	if (IS_ERR(new_nsp->user_ns)) {
-		err = PTR_ERR(new_nsp->user_ns);
+	err = create_new_userns(flags, tsk);
+	if (err)
 		goto out_user;
-	}
 
 	new_nsp->net_ns = copy_net_ns(flags, tsk->nsproxy->net_ns);
 	if (IS_ERR(new_nsp->net_ns)) {
@@ -95,8 +93,6 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 	return new_nsp;
 
 out_net:
-	if (new_nsp->user_ns)
-		put_user_ns(new_nsp->user_ns);
 out_user:
 	if (new_nsp->pid_ns)
 		put_pid_ns(new_nsp->pid_ns);
@@ -173,8 +169,6 @@ void free_nsproxy(struct nsproxy *ns)
 		put_ipc_ns(ns->ipc_ns);
 	if (ns->pid_ns)
 		put_pid_ns(ns->pid_ns);
-	if (ns->user_ns)
-		put_user_ns(ns->user_ns);
 	put_net(ns->net_ns);
 	kmem_cache_free(nsproxy_cachep, ns);
 }
diff --git a/kernel/sys.c b/kernel/sys.c
index 68ce096..05ff7cc 100644
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
+			new_user != current_user()->user_ns->root_user) {
 		free_uid(new_user);
 		return -EAGAIN;
 	}
diff --git a/kernel/user.c b/kernel/user.c
index ed4dc57..94861ac 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -23,6 +23,7 @@ struct user_namespace init_user_ns = {
 		.refcount	= ATOMIC_INIT(2),
 	},
 	.root_user = &root_user,
+	.creator = &root_user,
 };
 EXPORT_SYMBOL_GPL(init_user_ns);
 
@@ -54,6 +55,7 @@ struct user_struct root_user = {
 	.files		= ATOMIC_INIT(0),
 	.sigpending	= ATOMIC_INIT(0),
 	.locked_shm     = 0,
+	.user_ns	= &init_user_ns,
 #ifdef CONFIG_USER_SCHED
 	.tg		= &init_task_group,
 #endif
@@ -314,12 +316,13 @@ done:
  * IRQ state (as stored in flags) is restored and uidhash_lock released
  * upon function exit.
  */
-static inline void free_user(struct user_struct *up, unsigned long flags)
+static void free_user(struct user_struct *up, unsigned long flags)
 {
 	/* restore back the count */
 	atomic_inc(&up->__count);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
 
+	put_user_ns(up->user_ns);
 	INIT_WORK(&up->work, remove_user_sysfs_dir);
 	schedule_work(&up->work);
 }
@@ -335,13 +338,14 @@ static inline void uids_mutex_unlock(void) { }
  * IRQ state (as stored in flags) is restored and uidhash_lock released
  * upon function exit.
  */
-static inline void free_user(struct user_struct *up, unsigned long flags)
+static void free_user(struct user_struct *up, unsigned long flags)
 {
 	uid_hash_remove(up);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
 	sched_destroy_user(up);
 	key_put(up->uid_keyring);
 	key_put(up->session_keyring);
+	put_user_ns(up->user_ns);
 	kmem_cache_free(uid_cachep, up);
 }
 
@@ -357,7 +361,7 @@ struct user_struct *find_user(uid_t uid)
 {
 	struct user_struct *ret;
 	unsigned long flags;
-	struct user_namespace *ns = current->nsproxy->user_ns;
+	struct user_namespace *ns = current_user()->user_ns;
 
 	spin_lock_irqsave(&uidhash_lock, flags);
 	ret = uid_hash_find(uid, uidhashentry(ns, uid));
@@ -404,6 +408,8 @@ struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
 		if (sched_create_user(new) < 0)
 			goto out_free_user;
 
+		new->user_ns = get_user_ns(ns);
+
 		if (uids_user_create(new))
 			goto out_destoy_sched;
 
@@ -436,6 +442,7 @@ struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
 
 out_destoy_sched:
 	sched_destroy_user(new);
+	put_user_ns(new->user_ns);
 out_free_user:
 	kmem_cache_free(uid_cachep, new);
 out_unlock:
@@ -443,33 +450,6 @@ out_unlock:
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
index 0d9c51d..8e00166 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -9,22 +9,30 @@
 #include <linux/nsproxy.h>
 #include <linux/slab.h>
 #include <linux/user_namespace.h>
+#include <linux/cred.h>
+
+extern int __task_commit_creds(struct task_struct *tsk, struct cred *new);
 
 /*
  * Clone a new ns copying an original user ns, setting refcount to 1
  * @old_ns: namespace to clone
  * Return NULL on error (failure to kmalloc), new ns otherwise
+ * The caller (either clone or unshare) must set the target task's
+ * credentials accordingly.  We can't do it here, bc in the case of
+ * clone, current isn't the new task.
  */
-static struct user_namespace *clone_user_ns(struct user_namespace *old_ns)
+int create_new_userns(int flags, struct task_struct *tsk)
 {
 	struct user_namespace *ns;
-	struct user_struct *new_user;
 	struct cred *new;
 	int n;
 
+	if (!(flags & CLONE_NEWUSER))
+		return 0;
+
 	ns = kmalloc(sizeof(struct user_namespace), GFP_KERNEL);
 	if (!ns)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 
 	kref_init(&ns->kref);
 
@@ -35,44 +43,30 @@ static struct user_namespace *clone_user_ns(struct user_namespace *old_ns)
 	ns->root_user = alloc_uid(ns, 0);
 	if (!ns->root_user) {
 		kfree(ns);
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 	}
 
-	/* Reset current->user with a new one */
-	new_user = alloc_uid(ns, current_uid());
-	if (!new_user) {
-		free_uid(ns->root_user);
-		kfree(ns);
-		return ERR_PTR(-ENOMEM);
-	}
+	/* alloc_uid() incremented the userns refcount.  drop it again */
+	put_user_ns(ns);
+
+	/* save away and pin the creating user */
+	ns->creator = current_user();
+	atomic_inc(&ns->creator->__count);
 
-	/* Install the new user */
+	/* now create and commit the new credentials */
 	new = prepare_creds();
 	if (!new) {
-		free_uid(new_user);
 		free_uid(ns->root_user);
 		kfree(ns);
+		return -ENOMEM;
 	}
 	free_uid(new->user);
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
-
-	new_ns = clone_user_ns(old_ns);
+	new->user = ns->root_user;
+	new->uid = new->euid = new->suid = new->fsuid = 0;
+	new->gid = new->egid = new->sgid = new->fsgid = 0;
+	__task_commit_creds(tsk, new);
 
-	put_user_ns(old_ns);
-	return new_ns;
+	return 0;
 }
 
 void free_user_ns(struct kref *kref)
@@ -80,7 +74,7 @@ void free_user_ns(struct kref *kref)
 	struct user_namespace *ns;
 
 	ns = container_of(kref, struct user_namespace, kref);
-	release_uids(ns);
+	free_uid(ns->creator);
 	kfree(ns);
 }
 EXPORT_SYMBOL(free_user_ns);
-- 
1.5.4.3
