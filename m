From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 10/16] userns: Implement unshare of the user namespace
Date: Mon, 19 Nov 2012 07:12:35 -0800
Message-ID: <1353337961-12962-10-git-send-email-ebiederm__32894.2338972867$1353338053$gmane$org@xmission.com>
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

- Add CLONE_THREAD to the unshare flags if CLONE_NEWUSER is selected
  As changing user namespaces is only valid if all there is only
  a single thread.
- Restore the code to add CLONE_VM if CLONE_THREAD is selected and
  the code to addCLONE_SIGHAND if CLONE_VM is selected.
  Making the constraints in the code clear.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/nsproxy.h        |    2 +-
 include/linux/user_namespace.h |    9 +++++++++
 kernel/fork.c                  |   25 ++++++++++++++++++++++---
 kernel/nsproxy.c               |    8 ++++----
 kernel/user_namespace.c        |   15 +++++++++++++++
 5 files changed, 51 insertions(+), 8 deletions(-)

diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index cc37a55..10e5947 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -67,7 +67,7 @@ void exit_task_namespaces(struct task_struct *tsk);
 void switch_task_namespaces(struct task_struct *tsk, struct nsproxy *new);
 void free_nsproxy(struct nsproxy *ns);
 int unshare_nsproxy_namespaces(unsigned long, struct nsproxy **,
-	struct fs_struct *);
+	struct cred *, struct fs_struct *);
 int __init nsproxy_cache_init(void);
 
 static inline void put_nsproxy(struct nsproxy *ns)
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 95142ca..17651f0 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -39,6 +39,7 @@ static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 }
 
 extern int create_user_ns(struct cred *new);
+extern int unshare_userns(unsigned long unshare_flags, struct cred **new_cred);
 extern void free_user_ns(struct kref *kref);
 
 static inline void put_user_ns(struct user_namespace *ns)
@@ -66,6 +67,14 @@ static inline int create_user_ns(struct cred *new)
 	return -EINVAL;
 }
 
+static inline int unshare_userns(unsigned long unshare_flags,
+				 struct cred **new_cred)
+{
+	if (unshare_flags & CLONE_NEWUSER)
+		return -EINVAL;
+	return 0;
+}
+
 static inline void put_user_ns(struct user_namespace *ns)
 {
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index 8c29abb..38e53b8 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1687,7 +1687,7 @@ static int check_unshare_flags(unsigned long unshare_flags)
 	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
 				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
 				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET|
-				CLONE_NEWPID))
+				CLONE_NEWUSER|CLONE_NEWPID))
 		return -EINVAL;
 	/*
 	 * Not implemented, but pretend it works if there is nothing to
@@ -1754,11 +1754,17 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
 {
 	struct fs_struct *fs, *new_fs = NULL;
 	struct files_struct *fd, *new_fd = NULL;
+	struct cred *new_cred = NULL;
 	struct nsproxy *new_nsproxy = NULL;
 	int do_sysvsem = 0;
 	int err;
 
 	/*
+	 * If unsharing a user namespace must also unshare the thread.
+	 */
+	if (unshare_flags & CLONE_NEWUSER)
+		unshare_flags |= CLONE_THREAD;
+	/*
 	 * If unsharing a pid namespace must also unshare the thread.
 	 */
 	if (unshare_flags & CLONE_NEWPID)
@@ -1795,11 +1801,15 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
 	err = unshare_fd(unshare_flags, &new_fd);
 	if (err)
 		goto bad_unshare_cleanup_fs;
-	err = unshare_nsproxy_namespaces(unshare_flags, &new_nsproxy, new_fs);
+	err = unshare_userns(unshare_flags, &new_cred);
 	if (err)
 		goto bad_unshare_cleanup_fd;
+	err = unshare_nsproxy_namespaces(unshare_flags, &new_nsproxy,
+					 new_cred, new_fs);
+	if (err)
+		goto bad_unshare_cleanup_cred;
 
-	if (new_fs || new_fd || do_sysvsem || new_nsproxy) {
+	if (new_fs || new_fd || do_sysvsem || new_cred || new_nsproxy) {
 		if (do_sysvsem) {
 			/*
 			 * CLONE_SYSVSEM is equivalent to sys_exit().
@@ -1832,11 +1842,20 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
 		}
 
 		task_unlock(current);
+
+		if (new_cred) {
+			/* Install the new user namespace */
+			commit_creds(new_cred);
+			new_cred = NULL;
+		}
 	}
 
 	if (new_nsproxy)
 		put_nsproxy(new_nsproxy);
 
+bad_unshare_cleanup_cred:
+	if (new_cred)
+		put_cred(new_cred);
 bad_unshare_cleanup_fd:
 	if (new_fd)
 		put_files_struct(new_fd);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 2ddd816..78e2ecb 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -186,7 +186,7 @@ void free_nsproxy(struct nsproxy *ns)
  * On success, returns the new nsproxy.
  */
 int unshare_nsproxy_namespaces(unsigned long unshare_flags,
-		struct nsproxy **new_nsp, struct fs_struct *new_fs)
+	struct nsproxy **new_nsp, struct cred *new_cred, struct fs_struct *new_fs)
 {
 	struct user_namespace *user_ns;
 	int err = 0;
@@ -195,12 +195,12 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 			       CLONE_NEWNET | CLONE_NEWPID)))
 		return 0;
 
-	if (!nsown_capable(CAP_SYS_ADMIN))
+	user_ns = new_cred ? new_cred->user_ns : current_user_ns();
+	if (!ns_capable(user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
 
-	user_ns = current_user_ns();
 	*new_nsp = create_new_namespaces(unshare_flags, current, user_ns,
-				new_fs ? new_fs : current->fs);
+					 new_fs ? new_fs : current->fs);
 	if (IS_ERR(*new_nsp)) {
 		err = PTR_ERR(*new_nsp);
 		goto out;
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index a946077..ce92f7e 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -82,6 +82,21 @@ int create_user_ns(struct cred *new)
 	return 0;
 }
 
+int unshare_userns(unsigned long unshare_flags, struct cred **new_cred)
+{
+	struct cred *cred;
+
+	if (!(unshare_flags & CLONE_NEWUSER))
+		return 0;
+
+	cred = prepare_creds();
+	if (!cred)
+		return -ENOMEM;
+
+	*new_cred = cred;
+	return create_user_ns(cred);
+}
+
 void free_user_ns(struct kref *kref)
 {
 	struct user_namespace *parent, *ns =
-- 
1.7.5.4
