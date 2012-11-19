From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 07/16] userns: Make create_new_namespaces take a
	user_ns parameter
Date: Mon, 19 Nov 2012 07:12:32 -0800
Message-ID: <1353337961-12962-7-git-send-email-ebiederm@xmission.com>
References: <87lidx8wbo.fsf@xmission.com>
	<1353337961-12962-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353337961-12962-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Modify create_new_namespaces to explicitly take a user namespace
parameter, instead of implicitly through the task_struct.

This allows an implementation of unshare(CLONE_NEWUSER) where
the new user namespace is not stored onto the current task_struct
until after all of the namespaces are created.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/ipc_namespace.h |    7 ++++---
 include/linux/utsname.h       |    6 +++---
 ipc/namespace.c               |   10 ++++------
 kernel/nsproxy.c              |   22 +++++++++++++---------
 kernel/utsname.c              |    9 ++++-----
 5 files changed, 28 insertions(+), 26 deletions(-)

diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
index 5499c92..f03af70 100644
--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -133,7 +133,8 @@ static inline int mq_init_ns(struct ipc_namespace *ns) { return 0; }
 
 #if defined(CONFIG_IPC_NS)
 extern struct ipc_namespace *copy_ipcs(unsigned long flags,
-				       struct task_struct *tsk);
+	struct user_namespace *user_ns, struct ipc_namespace *ns);
+
 static inline struct ipc_namespace *get_ipc_ns(struct ipc_namespace *ns)
 {
 	if (ns)
@@ -144,12 +145,12 @@ static inline struct ipc_namespace *get_ipc_ns(struct ipc_namespace *ns)
 extern void put_ipc_ns(struct ipc_namespace *ns);
 #else
 static inline struct ipc_namespace *copy_ipcs(unsigned long flags,
-					      struct task_struct *tsk)
+	struct user_namespace *user_ns, struct ipc_namespace *ns)
 {
 	if (flags & CLONE_NEWIPC)
 		return ERR_PTR(-EINVAL);
 
-	return tsk->nsproxy->ipc_ns;
+	return ns;
 }
 
 static inline struct ipc_namespace *get_ipc_ns(struct ipc_namespace *ns)
diff --git a/include/linux/utsname.h b/include/linux/utsname.h
index 2b34520..221f4a0 100644
--- a/include/linux/utsname.h
+++ b/include/linux/utsname.h
@@ -33,7 +33,7 @@ static inline void get_uts_ns(struct uts_namespace *ns)
 }
 
 extern struct uts_namespace *copy_utsname(unsigned long flags,
-					  struct task_struct *tsk);
+	struct user_namespace *user_ns, struct uts_namespace *old_ns);
 extern void free_uts_ns(struct kref *kref);
 
 static inline void put_uts_ns(struct uts_namespace *ns)
@@ -50,12 +50,12 @@ static inline void put_uts_ns(struct uts_namespace *ns)
 }
 
 static inline struct uts_namespace *copy_utsname(unsigned long flags,
-						 struct task_struct *tsk)
+	struct user_namespace *user_ns, struct uts_namespace *old_ns)
 {
 	if (flags & CLONE_NEWUTS)
 		return ERR_PTR(-EINVAL);
 
-	return tsk->nsproxy->uts_ns;
+	return old_ns;
 }
 #endif
 
diff --git a/ipc/namespace.c b/ipc/namespace.c
index 6ed33c0..72c8682 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -16,7 +16,7 @@
 
 #include "util.h"
 
-static struct ipc_namespace *create_ipc_ns(struct task_struct *tsk,
+static struct ipc_namespace *create_ipc_ns(struct user_namespace *user_ns,
 					   struct ipc_namespace *old_ns)
 {
 	struct ipc_namespace *ns;
@@ -46,19 +46,17 @@ static struct ipc_namespace *create_ipc_ns(struct task_struct *tsk,
 	ipcns_notify(IPCNS_CREATED);
 	register_ipcns_notifier(ns);
 
-	ns->user_ns = get_user_ns(task_cred_xxx(tsk, user_ns));
+	ns->user_ns = get_user_ns(user_ns);
 
 	return ns;
 }
 
 struct ipc_namespace *copy_ipcs(unsigned long flags,
-				struct task_struct *tsk)
+	struct user_namespace *user_ns, struct ipc_namespace *ns)
 {
-	struct ipc_namespace *ns = tsk->nsproxy->ipc_ns;
-
 	if (!(flags & CLONE_NEWIPC))
 		return get_ipc_ns(ns);
-	return create_ipc_ns(tsk, ns);
+	return create_ipc_ns(user_ns, ns);
 }
 
 /*
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 4357a0a..2ddd816 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -57,7 +57,8 @@ static inline struct nsproxy *create_nsproxy(void)
  * leave it to the caller to do proper locking and attach it to task.
  */
 static struct nsproxy *create_new_namespaces(unsigned long flags,
-			struct task_struct *tsk, struct fs_struct *new_fs)
+	struct task_struct *tsk, struct user_namespace *user_ns,
+	struct fs_struct *new_fs)
 {
 	struct nsproxy *new_nsp;
 	int err;
@@ -66,31 +67,31 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 	if (!new_nsp)
 		return ERR_PTR(-ENOMEM);
 
-	new_nsp->mnt_ns = copy_mnt_ns(flags, tsk->nsproxy->mnt_ns, task_cred_xxx(tsk, user_ns), new_fs);
+	new_nsp->mnt_ns = copy_mnt_ns(flags, tsk->nsproxy->mnt_ns, user_ns, new_fs);
 	if (IS_ERR(new_nsp->mnt_ns)) {
 		err = PTR_ERR(new_nsp->mnt_ns);
 		goto out_ns;
 	}
 
-	new_nsp->uts_ns = copy_utsname(flags, tsk);
+	new_nsp->uts_ns = copy_utsname(flags, user_ns, tsk->nsproxy->uts_ns);
 	if (IS_ERR(new_nsp->uts_ns)) {
 		err = PTR_ERR(new_nsp->uts_ns);
 		goto out_uts;
 	}
 
-	new_nsp->ipc_ns = copy_ipcs(flags, tsk);
+	new_nsp->ipc_ns = copy_ipcs(flags, user_ns, tsk->nsproxy->ipc_ns);
 	if (IS_ERR(new_nsp->ipc_ns)) {
 		err = PTR_ERR(new_nsp->ipc_ns);
 		goto out_ipc;
 	}
 
-	new_nsp->pid_ns = copy_pid_ns(flags, task_cred_xxx(tsk, user_ns), tsk->nsproxy->pid_ns);
+	new_nsp->pid_ns = copy_pid_ns(flags, user_ns, tsk->nsproxy->pid_ns);
 	if (IS_ERR(new_nsp->pid_ns)) {
 		err = PTR_ERR(new_nsp->pid_ns);
 		goto out_pid;
 	}
 
-	new_nsp->net_ns = copy_net_ns(flags, task_cred_xxx(tsk, user_ns), tsk->nsproxy->net_ns);
+	new_nsp->net_ns = copy_net_ns(flags, user_ns, tsk->nsproxy->net_ns);
 	if (IS_ERR(new_nsp->net_ns)) {
 		err = PTR_ERR(new_nsp->net_ns);
 		goto out_net;
@@ -152,7 +153,8 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 		goto out;
 	}
 
-	new_ns = create_new_namespaces(flags, tsk, tsk->fs);
+	new_ns = create_new_namespaces(flags, tsk,
+				       task_cred_xxx(tsk, user_ns), tsk->fs);
 	if (IS_ERR(new_ns)) {
 		err = PTR_ERR(new_ns);
 		goto out;
@@ -186,6 +188,7 @@ void free_nsproxy(struct nsproxy *ns)
 int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 		struct nsproxy **new_nsp, struct fs_struct *new_fs)
 {
+	struct user_namespace *user_ns;
 	int err = 0;
 
 	if (!(unshare_flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
@@ -195,7 +198,8 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 	if (!nsown_capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	*new_nsp = create_new_namespaces(unshare_flags, current,
+	user_ns = current_user_ns();
+	*new_nsp = create_new_namespaces(unshare_flags, current, user_ns,
 				new_fs ? new_fs : current->fs);
 	if (IS_ERR(*new_nsp)) {
 		err = PTR_ERR(*new_nsp);
@@ -252,7 +256,7 @@ SYSCALL_DEFINE2(setns, int, fd, int, nstype)
 	if (nstype && (ops->type != nstype))
 		goto out;
 
-	new_nsproxy = create_new_namespaces(0, tsk, tsk->fs);
+	new_nsproxy = create_new_namespaces(0, tsk, current_user_ns(), tsk->fs);
 	if (IS_ERR(new_nsproxy)) {
 		err = PTR_ERR(new_nsproxy);
 		goto out;
diff --git a/kernel/utsname.c b/kernel/utsname.c
index 4a9362f..fdc619e 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -32,7 +32,7 @@ static struct uts_namespace *create_uts_ns(void)
  * @old_ns: namespace to clone
  * Return NULL on error (failure to kmalloc), new ns otherwise
  */
-static struct uts_namespace *clone_uts_ns(struct task_struct *tsk,
+static struct uts_namespace *clone_uts_ns(struct user_namespace *user_ns,
 					  struct uts_namespace *old_ns)
 {
 	struct uts_namespace *ns;
@@ -43,7 +43,7 @@ static struct uts_namespace *clone_uts_ns(struct task_struct *tsk,
 
 	down_read(&uts_sem);
 	memcpy(&ns->name, &old_ns->name, sizeof(ns->name));
-	ns->user_ns = get_user_ns(task_cred_xxx(tsk, user_ns));
+	ns->user_ns = get_user_ns(user_ns);
 	up_read(&uts_sem);
 	return ns;
 }
@@ -55,9 +55,8 @@ static struct uts_namespace *clone_uts_ns(struct task_struct *tsk,
  * versa.
  */
 struct uts_namespace *copy_utsname(unsigned long flags,
-				   struct task_struct *tsk)
+	struct user_namespace *user_ns, struct uts_namespace *old_ns)
 {
-	struct uts_namespace *old_ns = tsk->nsproxy->uts_ns;
 	struct uts_namespace *new_ns;
 
 	BUG_ON(!old_ns);
@@ -66,7 +65,7 @@ struct uts_namespace *copy_utsname(unsigned long flags,
 	if (!(flags & CLONE_NEWUTS))
 		return old_ns;
 
-	new_ns = clone_uts_ns(tsk, old_ns);
+	new_ns = clone_uts_ns(user_ns, old_ns);
 
 	put_uts_ns(old_ns);
 	return new_ns;
-- 
1.7.5.4
