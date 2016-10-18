From: Cao Shufeng <caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v3.1 1/3] Make call_usermodehelper_exec possible to set pid
	namespace
Date: Tue, 18 Oct 2016 18:06:35 +0800
Message-ID: <1476785197-5048-2-git-send-email-caosf.fnst@cn.fujitsu.com>
References: <1476785197-5048-1-git-send-email-caosf.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1476785197-5048-1-git-send-email-caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mashimiao.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Current call_usermodehelper_exec() can not set pid namespace for
the executed program, because we need addition fork to make pid
namespace active.

This patch add above function for call_usermodehelper_exec().
When init_intermediate callback return -EAGAIN, the usermodehelper
will fork again to make pid namespace active, and run program
in the child process.

This function is helpful for coredump to run pipe_program in
specific container environment.

Signed-off-by: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/coredump.c               |   3 +-
 include/linux/kmod.h        |   2 +
 init/do_mounts_initrd.c     |   3 +-
 kernel/kmod.c               | 133 ++++++++++++++++++++++++++++++++++++++------
 lib/kobject_uevent.c        |   3 +-
 security/keys/request_key.c |   4 +-
 6 files changed, 127 insertions(+), 21 deletions(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index 281b768..ceb0ee8 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -641,7 +641,8 @@ void do_coredump(const siginfo_t *siginfo)
 		retval = -ENOMEM;
 		sub_info = call_usermodehelper_setup(helper_argv[0],
 						helper_argv, NULL, GFP_KERNEL,
-						umh_pipe_setup, NULL, &cprm);
+						NULL, umh_pipe_setup,
+						NULL, &cprm);
 		if (sub_info)
 			retval = call_usermodehelper_exec(sub_info,
 							  UMH_WAIT_EXEC);
diff --git a/include/linux/kmod.h b/include/linux/kmod.h
index fcfd2bf..8fb8c0e 100644
--- a/include/linux/kmod.h
+++ b/include/linux/kmod.h
@@ -61,6 +61,7 @@ struct subprocess_info {
 	char **envp;
 	int wait;
 	int retval;
+	int (*init_intermediate)(struct subprocess_info *info);
 	int (*init)(struct subprocess_info *info, struct cred *new);
 	void (*cleanup)(struct subprocess_info *info);
 	void *data;
@@ -71,6 +72,7 @@ call_usermodehelper(char *path, char **argv, char **envp, int wait);
 
 extern struct subprocess_info *
 call_usermodehelper_setup(char *path, char **argv, char **envp, gfp_t gfp_mask,
+			  int (*init_intermediate)(struct subprocess_info *info),
 			  int (*init)(struct subprocess_info *info, struct cred *new),
 			  void (*cleanup)(struct subprocess_info *), void *data);
 
diff --git a/init/do_mounts_initrd.c b/init/do_mounts_initrd.c
index a1000ca..bb5dce5 100644
--- a/init/do_mounts_initrd.c
+++ b/init/do_mounts_initrd.c
@@ -72,7 +72,8 @@ static void __init handle_initrd(void)
 	current->flags |= PF_FREEZER_SKIP;
 
 	info = call_usermodehelper_setup("/linuxrc", argv, envp_init,
-					 GFP_KERNEL, init_linuxrc, NULL, NULL);
+					 GFP_KERNEL, NULL, init_linuxrc, NULL,
+					 NULL);
 	if (!info)
 		return;
 	call_usermodehelper_exec(info, UMH_WAIT_PROC);
diff --git a/kernel/kmod.c b/kernel/kmod.c
index 0277d12..30a5802 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -91,7 +91,7 @@ static int call_modprobe(char *module_name, int wait)
 	argv[4] = NULL;
 
 	info = call_usermodehelper_setup(modprobe_path, argv, envp, GFP_KERNEL,
-					 NULL, free_modprobe_argv, NULL);
+					 NULL, NULL, free_modprobe_argv, NULL);
 	if (!info)
 		goto free_module_name;
 
@@ -209,14 +209,11 @@ static void umh_complete(struct subprocess_info *sub_info)
 		call_usermodehelper_freeinfo(sub_info);
 }
 
-/*
- * This is the task which runs the usermode application
- */
-static int call_usermodehelper_exec_async(void *data)
+static int __call_usermodehelper_exec_doexec(void *data)
 {
 	struct subprocess_info *sub_info = data;
 	struct cred *new;
-	int retval;
+	int retval = 0;
 
 	spin_lock_irq(&current->sighand->siglock);
 	flush_signal_handlers(current, 1);
@@ -228,10 +225,11 @@ static int call_usermodehelper_exec_async(void *data)
 	 */
 	set_user_nice(current, 0);
 
-	retval = -ENOMEM;
 	new = prepare_kernel_cred(current);
-	if (!new)
+	if (!new) {
+		retval = -ENOMEM;
 		goto out;
+	}
 
 	spin_lock(&umh_sysctl_lock);
 	new->cap_bset = cap_intersect(usermodehelper_bset, new->cap_bset);
@@ -248,20 +246,121 @@ static int call_usermodehelper_exec_async(void *data)
 	}
 
 	commit_creds(new);
-
 	retval = do_execve(getname_kernel(sub_info->path),
-			   (const char __user *const __user *)sub_info->argv,
-			   (const char __user *const __user *)sub_info->envp);
+		   (const char __user *const __user *)sub_info->argv,
+		   (const char __user *const __user *)sub_info->envp);
+
 out:
-	sub_info->retval = retval;
+	return retval;
+}
+
+static int call_usermodehelper_exec_doexec(void *data)
+{
+	struct subprocess_info *sub_info = data;
+	int ret = __call_usermodehelper_exec_doexec(data);
+
 	/*
-	 * call_usermodehelper_exec_sync() will call umh_complete
-	 * if UHM_WAIT_PROC.
+	 * If it is called in non-sync mode:
+	 * On fail:
+	 *   should set sub_info->retval, call umh_complete and exit process.
+	 * On success:
+	 *   should set sub_info->retval, call umh_complete and return to
+	 *   user-mode program.
+	 * It it is called in sync mode:
+	 * On fail:
+	 *   should set sub_info->retval and exit process, the parent process
+	 *   will wait and call umh_complete()
+	 * On success:
+	 *   should return to user-mode program, the parent process will wait
+	 *   and get program's ret from wait(), and call umh_complete().
 	 */
+	sub_info->retval = ret;
+
 	if (!(sub_info->wait & UMH_WAIT_PROC))
 		umh_complete(sub_info);
-	if (!retval)
+
+	if (!ret)
 		return 0;
+
+	/*
+	 * see comment in call_usermodehelper_exec_sync() before change
+	 * it to do_exit(ret).
+	 */
+	do_exit(0);
+}
+
+/*
+ * This is the task which runs the usermode application
+ */
+static int call_usermodehelper_exec_async(void *data)
+{
+	struct subprocess_info *sub_info = data;
+	int ret = 0;
+	int refork = 0;
+
+	if (sub_info->init_intermediate) {
+		ret = sub_info->init_intermediate(sub_info);
+		switch (ret) {
+		case 0:
+			break;
+		case -EAGAIN:
+			/*
+			 * if pid namespace is changed,
+			 * we need refork to make it active.
+			 */
+			ret = 0;
+			refork = 1;
+			break;
+		default:
+			goto out;
+		}
+	}
+
+	if (refork) {
+		/*
+		 * Code copyed from call_usermodehelper_exec_work() and
+		 * call_usermodehelper_exec_sync(), see comments in these
+		 * functions for detail.
+		 */
+		pid_t pid;
+
+		if (sub_info->wait & UMH_WAIT_PROC) {
+			kernel_sigaction(SIGCHLD, SIG_DFL);
+			pid = kernel_thread(call_usermodehelper_exec_doexec,
+					    sub_info, SIGCHLD);
+			if (pid < 0) {
+				ret = pid;
+			} else {
+				ret = -ECHILD;
+				sys_wait4(pid, (int __user *)&ret, 0, NULL);
+			}
+			kernel_sigaction(SIGCHLD, SIG_IGN);
+
+			sub_info->retval = ret;
+		} else {
+			pid = kernel_thread(call_usermodehelper_exec_doexec,
+					    sub_info, SIGCHLD);
+			if (pid < 0) {
+				sub_info->retval = pid;
+				umh_complete(sub_info);
+			}
+		}
+	} else {
+		ret = __call_usermodehelper_exec_doexec(data);
+
+out:
+		/*
+		 * see comment in call_usermodehelper_exec_doexec() for detail
+		 */
+		sub_info->retval = ret;
+
+		if (!(sub_info->wait & UMH_WAIT_PROC))
+			umh_complete(sub_info);
+
+		if (!ret)
+			return 0;
+	}
+
 	do_exit(0);
 }
 
@@ -518,6 +617,7 @@ static void helper_unlock(void)
  */
 struct subprocess_info *call_usermodehelper_setup(char *path, char **argv,
 		char **envp, gfp_t gfp_mask,
+		int (*init_intermediate)(struct subprocess_info *info),
 		int (*init)(struct subprocess_info *info, struct cred *new),
 		void (*cleanup)(struct subprocess_info *info),
 		void *data)
@@ -533,6 +633,7 @@ struct subprocess_info *call_usermodehelper_setup(char *path, char **argv,
 	sub_info->envp = envp;
 
 	sub_info->cleanup = cleanup;
+	sub_info->init_intermediate = init_intermediate;
 	sub_info->init = init;
 	sub_info->data = data;
   out:
@@ -619,7 +720,7 @@ int call_usermodehelper(char *path, char **argv, char **envp, int wait)
 	gfp_t gfp_mask = (wait == UMH_NO_WAIT) ? GFP_ATOMIC : GFP_KERNEL;
 
 	info = call_usermodehelper_setup(path, argv, envp, gfp_mask,
-					 NULL, NULL, NULL);
+					 NULL, NULL, NULL, NULL);
 	if (info == NULL)
 		return -ENOMEM;
 
diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index f6c2c1e..7e571f0 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -345,7 +345,8 @@ int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
 		retval = -ENOMEM;
 		info = call_usermodehelper_setup(env->argv[0], env->argv,
 						 env->envp, GFP_KERNEL,
-						 NULL, cleanup_uevent_env, env);
+						 NULL, NULL, cleanup_uevent_env,
+						 env);
 		if (info) {
 			retval = call_usermodehelper_exec(info, UMH_NO_WAIT);
 			env = NULL;	/* freed by cleanup_uevent_env */
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index 43affcf..3abff78 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -78,8 +78,8 @@ static int call_usermodehelper_keys(char *path, char **argv, char **envp,
 	struct subprocess_info *info;
 
 	info = call_usermodehelper_setup(path, argv, envp, GFP_KERNEL,
-					  umh_keys_init, umh_keys_cleanup,
-					  session_keyring);
+					 NULL, umh_keys_init, umh_keys_cleanup,
+					 session_keyring);
 	if (!info)
 		return -ENOMEM;
 
-- 
2.7.4
