From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/6] user namespaces: move user_ns from nsproxy into user
	struct
Date: Fri, 25 Jul 2008 19:27:35 -0500
Message-ID: <20080726002735.GB29874@us.ibm.com>
References: <20080726002700.GA29686@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080726002700.GA29686-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

From ec5f54faf5afd16cb6cef40ebaaf3da25989d185 Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Thu, 24 Jul 2008 17:52:41 -0500
Subject: [PATCH 2/6] user namespaces: move user_ns from nsproxy into user struct

When we get the sysfs support needed to support fair user scheduling
along with user namespaces, then we will need to be able to get the
user namespace from the user struct.

So we need the user_ns to be a part of struct user.  Once we can
access it from tsk->user, we no longer have a use for
tsk->nsproxy->user_ns.

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

This patch makes those changes.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/init_task.h      |    1 -
 include/linux/key.h            |    3 ++
 include/linux/nsproxy.h        |    1 -
 include/linux/sched.h          |    3 +-
 include/linux/user_namespace.h |   10 +++----
 kernel/fork.c                  |    3 +-
 kernel/nsproxy.c               |   10 +------
 kernel/sys.c                   |    4 +-
 kernel/user.c                  |   52 +++++++++++----------------------------
 kernel/user_namespace.c        |   36 +++++++--------------------
 security/keys/process_keys.c   |    7 ++++-
 11 files changed, 45 insertions(+), 85 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 93c45ac..ce87b8a 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -57,7 +57,6 @@ extern struct nsproxy init_nsproxy;
 	.mnt_ns		= NULL,						\
 	INIT_NET_NS(net_ns)                                             \
 	INIT_IPC_NS(ipc_ns)						\
-	.user_ns	= &init_user_ns,				\
 }
 
 #define INIT_SIGHAND(sighand) {						\
diff --git a/include/linux/key.h b/include/linux/key.h
index c45c962..ba53aef 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -277,6 +277,8 @@ extern ctl_table key_sysctls[];
  * the userspace interface
  */
 extern void switch_uid_keyring(struct user_struct *new_user);
+extern void switch_uid_keyring_task(struct task_struct *tsk,
+				struct user_struct *new_user);
 extern int copy_keys(unsigned long clone_flags, struct task_struct *tsk);
 extern int copy_thread_group_keys(struct task_struct *tsk);
 extern void exit_keys(struct task_struct *tsk);
@@ -305,6 +307,7 @@ extern void key_init(void);
 #define key_ref_to_ptr(k)		({ NULL; })
 #define is_key_possessed(k)		0
 #define switch_uid_keyring(u)		do { } while(0)
+#define switch_uid_keyring_task(t,u)	do { } while(0)
 #define __install_session_keyring(t, k)	({ NULL; })
 #define copy_keys(f,t)			0
 #define copy_thread_group_keys(t)	0
diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index 0e66b57..7c7fb20 100644
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
index cf36e14..2c2f036 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -600,7 +600,7 @@ struct user_struct {
 	/* Hash table maintenance information */
 	struct hlist_node uidhash_node;
 	uid_t uid;
-	struct user_namespace *user_namespace;
+	struct user_namespace *user_ns;
 
 #ifdef CONFIG_USER_SCHED
 	struct task_group *tg;
@@ -1744,6 +1744,7 @@ static inline struct user_struct *get_uid(struct user_struct *u)
 }
 extern void free_uid(struct user_struct *);
 extern void switch_uid(struct user_struct *);
+extern void task_switch_uid(struct task_struct *tsk, struct user_struct *);
 extern void release_uids(struct user_namespace *ns);
 
 #include <asm/current.h>
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index f9477c3..1b4959d 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -27,8 +27,7 @@ static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 	return ns;
 }
 
-extern struct user_namespace *copy_user_ns(int flags,
-					   struct user_namespace *old_ns);
+extern int create_new_userns(int flags, struct task_struct *tsk);
 extern void free_user_ns(struct kref *kref);
 
 static inline void put_user_ns(struct user_namespace *ns)
@@ -44,13 +43,12 @@ static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 	return &init_user_ns;
 }
 
-static inline struct user_namespace *copy_user_ns(int flags,
-						  struct user_namespace *old_ns)
+static inline int create_new_userns(int flags, struct task_struct *tsk)
 {
 	if (flags & CLONE_NEWUSER)
-		return ERR_PTR(-EINVAL);
+		return -EINVAL;
 
-	return old_ns;
+	return 0;
 }
 
 static inline void put_user_ns(struct user_namespace *ns)
diff --git a/kernel/fork.c b/kernel/fork.c
index adefc11..42cc45f 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -917,8 +917,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	retval = -EAGAIN;
 	if (atomic_read(&p->user->processes) >=
 			p->signal->rlim[RLIMIT_NPROC].rlim_cur) {
-		if (!capable(CAP_SYS_ADMIN) && !capable(CAP_SYS_RESOURCE) &&
-		    p->user != current->nsproxy->user_ns->root_user)
+		if (!capable(CAP_SYS_ADMIN) && !capable(CAP_SYS_RESOURCE))
 			goto bad_fork_free;
 	}
 
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index adc7851..861d6f4 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -81,11 +81,9 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
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
@@ -96,8 +94,6 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 	return new_nsp;
 
 out_net:
-	if (new_nsp->user_ns)
-		put_user_ns(new_nsp->user_ns);
 out_user:
 	if (new_nsp->pid_ns)
 		put_pid_ns(new_nsp->pid_ns);
@@ -180,8 +176,6 @@ void free_nsproxy(struct nsproxy *ns)
 		put_ipc_ns(ns->ipc_ns);
 	if (ns->pid_ns)
 		put_pid_ns(ns->pid_ns);
-	if (ns->user_ns)
-		put_user_ns(ns->user_ns);
 	put_net(ns->net_ns);
 	kmem_cache_free(nsproxy_cachep, ns);
 }
diff --git a/kernel/sys.c b/kernel/sys.c
index 14e9728..b8623be 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -568,13 +568,13 @@ static int set_user(uid_t new_ruid, int dumpclear)
 {
 	struct user_struct *new_user;
 
-	new_user = alloc_uid(current->nsproxy->user_ns, new_ruid);
+	new_user = alloc_uid(current->user->user_ns, new_ruid);
 	if (!new_user)
 		return -EAGAIN;
 
 	if (atomic_read(&new_user->processes) >=
 				current->signal->rlim[RLIMIT_NPROC].rlim_cur &&
-			new_user != current->nsproxy->user_ns->root_user) {
+			!capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN)) {
 		free_uid(new_user);
 		return -EAGAIN;
 	}
diff --git a/kernel/user.c b/kernel/user.c
index cfe8309..034dae5 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -54,7 +54,7 @@ struct user_struct root_user = {
 	.files		= ATOMIC_INIT(0),
 	.sigpending	= ATOMIC_INIT(0),
 	.locked_shm     = 0,
-	.user_namespace	= &init_user_ns,
+	.user_ns	= &init_user_ns,
 #ifdef CONFIG_USER_SCHED
 	.tg		= &init_task_group,
 #endif
@@ -323,7 +323,7 @@ done:
  */
 static inline void free_user(struct user_struct *up, unsigned long flags)
 {
-	put_user_ns(up->user_namespace);
+	put_user_ns(up->user_ns);
 	/* restore back the count */
 	atomic_inc(&up->__count);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
@@ -350,7 +350,7 @@ static inline void free_user(struct user_struct *up, unsigned long flags)
 	sched_destroy_user(up);
 	key_put(up->uid_keyring);
 	key_put(up->session_keyring);
-	put_user_ns(up->user_namespace);
+	put_user_ns(up->user_ns);
 	kmem_cache_free(uid_cachep, up);
 }
 
@@ -366,7 +366,7 @@ struct user_struct *find_user(uid_t uid)
 {
 	struct user_struct *ret;
 	unsigned long flags;
-	struct user_namespace *ns = current->nsproxy->user_ns;
+	struct user_namespace *ns = current->user->user_ns;
 
 	spin_lock_irqsave(&uidhash_lock, flags);
 	ret = uid_hash_find(uid, uidhashentry(ns, uid));
@@ -413,7 +413,7 @@ struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
 		if (sched_create_user(new) < 0)
 			goto out_free_user;
 
-		new->user_namespace = get_user_ns(ns);
+		new->user_ns = get_user_ns(ns);
 
 		if (uids_user_create(new))
 			goto out_destoy_sched;
@@ -447,7 +447,7 @@ struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
 
 out_destoy_sched:
 	sched_destroy_user(new);
-	put_user_ns(new->user_namespace);
+	put_user_ns(new->user_ns);
 out_free_user:
 	kmem_cache_free(uid_cachep, new);
 out_unlock:
@@ -455,7 +455,7 @@ out_unlock:
 	return NULL;
 }
 
-void switch_uid(struct user_struct *new_user)
+void task_switch_uid(struct task_struct *tsk, struct user_struct *new_user)
 {
 	struct user_struct *old_user;
 
@@ -464,12 +464,12 @@ void switch_uid(struct user_struct *new_user)
 	 * cheaply with the new uid cache, so if it matters
 	 * we should be checking for it.  -DaveM
 	 */
-	old_user = current->user;
+	old_user = tsk->user;
 	atomic_inc(&new_user->processes);
 	atomic_dec(&old_user->processes);
-	switch_uid_keyring(new_user);
-	current->user = new_user;
-	sched_switch_user(current);
+	switch_uid_keyring_task(tsk, new_user);
+	tsk->user = new_user;
+	sched_switch_user(tsk);
 
 	/*
 	 * We need to synchronize with __sigqueue_alloc()
@@ -479,38 +479,16 @@ void switch_uid(struct user_struct *new_user)
 	 * structure.
 	 */
 	smp_mb();
-	spin_unlock_wait(&current->sighand->siglock);
+	spin_unlock_wait(&tsk->sighand->siglock);
 
 	free_uid(old_user);
-	suid_keys(current);
+	suid_keys(tsk);
 }
 
-#ifdef CONFIG_USER_NS
-void release_uids(struct user_namespace *ns)
+void switch_uid(struct user_struct *new_user)
 {
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
+	task_switch_uid(current, new_user);
 }
-#endif
 
 static int __init uid_cache_init(void)
 {
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index e8db443..0045dd0 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -16,14 +16,17 @@
  * @old_ns: namespace to clone
  * Return NULL on error (failure to kmalloc), new ns otherwise
  */
-static struct user_namespace *clone_user_ns(struct user_namespace *old_ns)
+int create_new_userns(int flags, struct task_struct *tsk)
 {
 	struct user_namespace *ns;
 	int n;
 
+	if (!(flags & CLONE_NEWUSER))
+		return 0;
+
 	ns = kmalloc(sizeof(struct user_namespace), GFP_KERNEL);
 	if (!ns)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 
 	kref_init(&ns->kref);
 
@@ -34,37 +37,19 @@ static struct user_namespace *clone_user_ns(struct user_namespace *old_ns)
 	ns->root_user = alloc_uid(ns, 0);
 	if (!ns->root_user) {
 		kfree(ns);
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 	}
 
 	/* pin the creating user */
-	ns->creator = current->user;
+	ns->creator = tsk->user;
 	atomic_inc(&ns->creator->__count);
 
-	/*
-	 * The alloc_uid() incremented the userns refcount,
-	 * so drop it again 
-	 */
+	/* alloc_uid() incremented the userns refcount.  drop it again */
 	put_user_ns(ns);
 
-	switch_uid(ns->root_user);
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
+	task_switch_uid(tsk, ns->root_user);
 
-	put_user_ns(old_ns);
-	return new_ns;
+	return 0;
 }
 
 void free_user_ns(struct kref *kref)
@@ -72,7 +57,6 @@ void free_user_ns(struct kref *kref)
 	struct user_namespace *ns;
 
 	ns = container_of(kref, struct user_namespace, kref);
-	release_uids(ns);
 	free_uid(ns->creator);
 	kfree(ns);
 }
diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index 5be6d01..8d1cfb2 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -119,7 +119,8 @@ error:
 /*
  * deal with the UID changing
  */
-void switch_uid_keyring(struct user_struct *new_user)
+void switch_uid_keyring_task(struct task_struct *task,
+				struct user_struct *new_user)
 {
 #if 0 /* do nothing for now */
 	struct key *old;
@@ -142,6 +143,10 @@ void switch_uid_keyring(struct user_struct *new_user)
 
 } /* end switch_uid_keyring() */
 
+void switch_uid_keyring(struct user_struct *new_user)
+{
+	switch_uid_keyring_task(current, new_user);
+}
 /*****************************************************************************/
 /*
  * install a fresh thread keyring, discarding the old one
-- 
1.5.4.3
