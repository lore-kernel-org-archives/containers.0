From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] User namespaces: general cleanups
Date: Fri, 10 Oct 2008 11:06:54 +0100
Message-ID: <30854.1223633214@redhat.com>
References: <20081010011917.GA8046@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081010011917.GA8046-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> +		new->uid = new->euid = new->suid = new->fsuid = 0;
> +		new->gid = new->egid = new->sgid = new->fsgid = 0;

Should the supplementary groups be zapped too?  Do the GIDs therein still have
meaning in the new user namespace?

Note also that eCryptFS is broken by your patch. 

I suggest adding the attached incremental patch.  It makes the following
changes:

 (1) Provides a current_user_ns() macro to wrap accesses to current's user
     namespace.

 (2) Fixes eCryptFS.

 (3) Renames create_new_userns() to create_user_ns() to be more consistent
     with the other associated functions and because the 'new' in the name is
     superfluous.

 (4) Moves the argument and permission checks made for CLONE_NEWUSER to the
     beginning of do_fork() so that they're done prior to making any attempts
     at allocation.

 (5) Calls create_user_ns() after prepare_creds(), and gives it the new creds
     to fill in rather than have it return the new root user.  I don't imagine
     the new root user being used for anything other than filling in a cred
     struct.

     This also permits me to get rid of a get_uid() and a free_uid(), as the
     reference the creds were holding on the old user_struct can just be
     transferred to the new namespace's creator pointer.

 (6) Makes create_user_ns() reset the UIDs and GIDs of the creds under
     preparation rather than doing it in copy_creds().

David
---
diff --git a/fs/ecryptfs/messaging.c b/fs/ecryptfs/messaging.c
index 92bf606..eecb8b5 100644
--- a/fs/ecryptfs/messaging.c
+++ b/fs/ecryptfs/messaging.c
@@ -376,7 +376,7 @@ int ecryptfs_process_response(struct ecryptfs_message *msg, uid_t euid,
 	struct ecryptfs_msg_ctx *msg_ctx;
 	size_t msg_size;
 	struct nsproxy *nsproxy;
-	struct user_namespace *current_user_ns;
+	struct user_namespace *tsk_user_ns;
 	uid_t ctx_euid;
 	int rc;
 
@@ -401,9 +401,9 @@ int ecryptfs_process_response(struct ecryptfs_message *msg, uid_t euid,
 		mutex_unlock(&ecryptfs_daemon_hash_mux);
 		goto wake_up;
 	}
-	current_user_ns = nsproxy->user_ns;
+	tsk_user_ns = __task_cred(msg_ctx->task)->user->user_ns;
 	ctx_euid = task_euid(msg_ctx->task);
-	rc = ecryptfs_find_daemon_by_euid(&daemon, ctx_euid, current_user_ns);
+	rc = ecryptfs_find_daemon_by_euid(&daemon, ctx_euid, tsk_user_ns);
 	rcu_read_unlock();
 	mutex_unlock(&ecryptfs_daemon_hash_mux);
 	if (rc) {
@@ -421,11 +421,11 @@ int ecryptfs_process_response(struct ecryptfs_message *msg, uid_t euid,
 		       euid, ctx_euid);
 		goto unlock;
 	}
-	if (current_user_ns != user_ns) {
+	if (tsk_user_ns != user_ns) {
 		rc = -EBADMSG;
 		printk(KERN_WARNING "%s: Received message from user_ns "
 		       "[0x%p]; expected message from user_ns [0x%p]\n",
-		       __func__, user_ns, nsproxy->user_ns);
+		       __func__, user_ns, tsk_user_ns);
 		goto unlock;
 	}
 	if (daemon->pid != pid) {
@@ -486,8 +486,7 @@ ecryptfs_send_message_locked(unsigned int transport, char *data, int data_len,
 	uid_t euid = current_euid();
 	int rc;
 
-	rc = ecryptfs_find_daemon_by_euid(&daemon, euid,
-					  current->nsproxy->user_ns);
+	rc = ecryptfs_find_daemon_by_euid(&daemon, euid, current_user_ns());
 	if (rc || !daemon) {
 		rc = -ENOTCONN;
 		printk(KERN_ERR "%s: User [%d] does not have a daemon "
diff --git a/fs/ecryptfs/miscdev.c b/fs/ecryptfs/miscdev.c
index 047ac60..efd95a0 100644
--- a/fs/ecryptfs/miscdev.c
+++ b/fs/ecryptfs/miscdev.c
@@ -47,8 +47,7 @@ ecryptfs_miscdev_poll(struct file *file, poll_table *pt)
 
 	mutex_lock(&ecryptfs_daemon_hash_mux);
 	/* TODO: Just use file->private_data? */
-	rc = ecryptfs_find_daemon_by_euid(&daemon, euid,
-					  current->nsproxy->user_ns);
+	rc = ecryptfs_find_daemon_by_euid(&daemon, euid, current_user_ns());
 	BUG_ON(rc || !daemon);
 	mutex_lock(&daemon->mux);
 	mutex_unlock(&ecryptfs_daemon_hash_mux);
@@ -95,11 +94,9 @@ ecryptfs_miscdev_open(struct inode *inode, struct file *file)
 		       "count; rc = [%d]\n", __func__, rc);
 		goto out_unlock_daemon_list;
 	}
-	rc = ecryptfs_find_daemon_by_euid(&daemon, euid,
-					  current->nsproxy->user_ns);
+	rc = ecryptfs_find_daemon_by_euid(&daemon, euid, current_user_ns());
 	if (rc || !daemon) {
-		rc = ecryptfs_spawn_daemon(&daemon, euid,
-					   current->nsproxy->user_ns,
+		rc = ecryptfs_spawn_daemon(&daemon, euid, current_user_ns(),
 					   task_pid(current));
 		if (rc) {
 			printk(KERN_ERR "%s: Error attempting to spawn daemon; "
@@ -153,8 +150,7 @@ ecryptfs_miscdev_release(struct inode *inode, struct file *file)
 	int rc;
 
 	mutex_lock(&ecryptfs_daemon_hash_mux);
-	rc = ecryptfs_find_daemon_by_euid(&daemon, euid,
-					  current->nsproxy->user_ns);
+	rc = ecryptfs_find_daemon_by_euid(&daemon, euid, current_user_ns());
 	BUG_ON(rc || !daemon);
 	mutex_lock(&daemon->mux);
 	BUG_ON(daemon->pid != task_pid(current));
@@ -254,8 +250,7 @@ ecryptfs_miscdev_read(struct file *file, char __user *buf, size_t count,
 
 	mutex_lock(&ecryptfs_daemon_hash_mux);
 	/* TODO: Just use file->private_data? */
-	rc = ecryptfs_find_daemon_by_euid(&daemon, euid,
-					  current->nsproxy->user_ns);
+	rc = ecryptfs_find_daemon_by_euid(&daemon, euid, current_user_ns());
 	BUG_ON(rc || !daemon);
 	mutex_lock(&daemon->mux);
 	if (daemon->flags & ECRYPTFS_DAEMON_ZOMBIE) {
@@ -295,7 +290,7 @@ check_list:
 		goto check_list;
 	}
 	BUG_ON(euid != daemon->euid);
-	BUG_ON(current->nsproxy->user_ns != daemon->user_ns);
+	BUG_ON(current_user_ns() != daemon->user_ns);
 	BUG_ON(task_pid(current) != daemon->pid);
 	msg_ctx = list_first_entry(&daemon->msg_ctx_out_queue,
 				   struct ecryptfs_msg_ctx, daemon_out_list);
@@ -468,7 +463,7 @@ ecryptfs_miscdev_write(struct file *file, const char __user *buf,
 			goto out_free;
 		}
 		rc = ecryptfs_miscdev_response(&data[i], packet_size,
-					       euid, current->nsproxy->user_ns,
+					       euid, current_user_ns(),
 					       task_pid(current), seq);
 		if (rc)
 			printk(KERN_WARNING "%s: Failed to deliver miscdev "
diff --git a/include/linux/cred.h b/include/linux/cred.h
index 26c1ab1..7db0049 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -315,6 +315,7 @@ static inline void put_cred(const struct cred *_cred)
 #define current_fsgid() 	(current_cred_xxx(fsgid))
 #define current_cap()		(current_cred_xxx(cap_effective))
 #define current_user()		(current_cred_xxx(user))
+#define current_user_ns()	(current_cred_xxx(user)->user_ns)
 #define current_security()	(current_cred_xxx(security))
 
 #define current_uid_gid(_uid, _gid)		\
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index d6e61a2..315bcd3 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -26,7 +26,7 @@ static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 	return ns;
 }
 
-extern struct user_struct *create_new_userns(struct task_struct *tsk);
+extern int create_user_ns(struct cred *new);
 extern void free_user_ns(struct kref *kref);
 
 static inline void put_user_ns(struct user_namespace *ns)
@@ -42,9 +42,9 @@ static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 	return &init_user_ns;
 }
 
-static inline struct user_struct *create_new_userns(struct task_struct *tsk)
+static inline int create_user_ns(struct cred *new)
 {
-	return ERR_PTR(-EINVAL);
+	return -EINVAL;
 }
 
 static inline void put_user_ns(struct user_namespace *ns)
diff --git a/kernel/cred.c b/kernel/cred.c
index e98106e..d0f99d8 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -274,7 +274,7 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 	struct thread_group_cred *tgcred;
 #endif
 	struct cred *new;
-	struct user_struct *new_root = NULL;
+	int ret;
 
 	mutex_init(&p->cred_exec_mutex);
 
@@ -289,33 +289,14 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 		return 0;
 	}
 
-	if (clone_flags & CLONE_NEWUSER) {
-		/*
-		 * hopefully the capability check goes away when userns support
-		 * is complete
-		 */
-		if (!capable(CAP_SYS_ADMIN))
-			return -EPERM;
-		if (clone_flags & CLONE_THREAD)
-			return -EINVAL;
-		new_root = create_new_userns(p);
-		if (IS_ERR(new_root))
-			return PTR_ERR(new_root);
-	}
-
 	new = prepare_creds();
-	if (!new) {
-		free_uid(new_root);
+	if (!new)
 		return -ENOMEM;
-	}
 
-	/* If we created a new user_ns, make its root user
-	 * our user */
-	if (new_root) {
-		new->uid = new->euid = new->suid = new->fsuid = 0;
-		new->gid = new->egid = new->sgid = new->fsgid = 0;
-		free_uid(new->user);
-		new->user = new_root;
+	if (clone_flags & CLONE_NEWUSER) {
+		ret = create_user_ns(new);
+		if (ret < 0)
+			goto error_put;
 	}
 
 #ifdef CONFIG_KEYS
@@ -333,10 +314,8 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 	 * bit */
 	if (!(clone_flags & CLONE_THREAD)) {
 		tgcred = kmalloc(sizeof(*tgcred), GFP_KERNEL);
-		if (!tgcred) {
-			put_cred(new);
-			return -ENOMEM;
-		}
+		if (!tgcred)
+			goto nomem_put;
 		atomic_set(&tgcred->usage, 1);
 		spin_lock_init(&tgcred->lock);
 		tgcred->process_keyring = NULL;
@@ -350,6 +329,12 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 	atomic_inc(&new->user->processes);
 	p->cred = p->real_cred = get_cred(new);
 	return 0;
+
+nomem_put:
+	ret = -ENOMEM;
+error_put:
+	put_cred(new);
+	return ret;
 }
 
 /**
diff --git a/kernel/fork.c b/kernel/fork.c
index c3bb673..2e167d5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1318,6 +1318,20 @@ long do_fork(unsigned long clone_flags,
 	long nr;
 
 	/*
+	 * Do some preliminary argument and permissions checking before we
+	 * actually start allocating stuff
+	 */
+	if (clone_flags & CLONE_NEWUSER) {
+		if (clone_flags & CLONE_THREAD)
+			return -EINVAL;
+		/* hopefully this check will go away when userns support is
+		 * complete
+		 */
+		if (!capable(CAP_SYS_ADMIN))
+			return -EPERM;
+	}
+
+	/*
 	 * We hope to recycle these flags after 2.6.26
 	 */
 	if (unlikely(clone_flags & CLONE_STOPPED)) {
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 86200b1..5da3c41 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -12,10 +12,14 @@
 #include <linux/cred.h>
 
 /*
- * Return a new user_struct which is root in a new user_ns.  This is called by
- * copy_creds(), which will finish setting the target task's credentials.
+ * Create a new user namespace, deriving the creator from the user in the
+ * passed credentials, and replacing that user with the new root user for the
+ * new namespace.
+ *
+ * This is called by copy_creds(), which will finish setting the target task's
+ * credentials.
  */
-struct user_struct *create_new_userns(struct task_struct *tsk)
+int create_user_ns(struct cred *new)
 {
 	struct user_namespace *ns;
 	struct user_struct *root_user;
@@ -23,7 +27,7 @@ struct user_struct *create_new_userns(struct task_struct *tsk)
 
 	ns = kmalloc(sizeof(struct user_namespace), GFP_KERNEL);
 	if (!ns)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 
 	kref_init(&ns->kref);
 
@@ -34,18 +38,20 @@ struct user_struct *create_new_userns(struct task_struct *tsk)
 	root_user = alloc_uid(ns, 0);
 	if (!root_user) {
 		kfree(ns);
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 	}
 
-	/* save away and pin the creating user */
-	ns->creator = tsk->cred->user;  /* tsk is still being created */
-	get_uid(ns->creator);
+	/* set the new root user in the credentials under preparation */
+	ns->creator = new->user;
+	new->user = root_user;
+	new->uid = new->euid = new->suid = new->fsuid = 0;
+	new->gid = new->egid = new->sgid = new->fsgid = 0;
 
 	/* alloc_uid() incremented the userns refcount.  Just set it to 1 */
 	kref_set(&ns->kref, 1);
 
 	printk(KERN_NOTICE "allocated a user_ns (%p)\n", ns);
-	return root_user;
+	return 0;
 }
 
 void free_user_ns(struct kref *kref)
