From: Cao Shufeng <caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH_v4.1 1/3] Make call_usermodehelper_exec possible to set
	namespaces
Date: Wed, 22 Nov 2017 11:24:16 +0800
Message-ID: <1511321058-6089-2-git-send-email-caosf.fnst__9156.53965571455$1511321046$gmane$org@cn.fujitsu.com>
References: <1501655849-9149-1-git-send-email-caosf.fnst@cn.fujitsu.com>
	<1511321058-6089-1-git-send-email-caosf.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1511321058-6089-1-git-send-email-caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mashimiao.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, fnstml-container-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Current call_usermodehelper_work() can not set namespaces for
the executed program.

This patch add above function for call_usermodehelper_work().
The init_intermediate is introduced for init works which should
be done before fork(). So that we get a method to set namespaces
for children. The cleanup_intermediate is introduced for cleaning
up what we have done in init_intermediate, like switching back
the namespace.

This function is helpful for coredump to run pipe_program in
specific container environment.

Signed-off-by: Cao Shufeng <caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/coredump.c               |  3 ++-
 include/linux/umh.h         |  5 +++++
 init/do_mounts_initrd.c     |  3 ++-
 kernel/kmod.c               |  3 ++-
 kernel/umh.c                | 51 ++++++++++++++++++++++++++++++++++++++-------
 security/keys/request_key.c |  4 ++--
 6 files changed, 56 insertions(+), 13 deletions(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index 52c63d6..84c2b8a 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -647,7 +647,8 @@ void do_coredump(const siginfo_t *siginfo)
 		retval = -ENOMEM;
 		sub_info = call_usermodehelper_setup(helper_argv[0],
 						helper_argv, NULL, GFP_KERNEL,
-						umh_pipe_setup, NULL, &cprm);
+						NULL, NULL, umh_pipe_setup,
+						NULL, &cprm);
 		if (sub_info)
 			retval = call_usermodehelper_exec(sub_info,
 							  UMH_WAIT_EXEC);
diff --git a/include/linux/umh.h b/include/linux/umh.h
index 244aff6..832ff5d 100644
--- a/include/linux/umh.h
+++ b/include/linux/umh.h
@@ -24,6 +24,9 @@ struct subprocess_info {
 	char **envp;
 	int wait;
 	int retval;
+	bool cleaned;
+	void (*init_intermediate)(struct subprocess_info *info);
+	void (*cleanup_intermediate)(struct subprocess_info *info);
 	int (*init)(struct subprocess_info *info, struct cred *new);
 	void (*cleanup)(struct subprocess_info *info);
 	void *data;
@@ -35,6 +38,8 @@ call_usermodehelper(const char *path, char **argv, char **envp, int wait);
 extern struct subprocess_info *
 call_usermodehelper_setup(const char *path, char **argv, char **envp,
 			  gfp_t gfp_mask,
+			  void (*init_intermediate)(struct subprocess_info *info),
+			  void (*cleanup_intermediate)(struct subprocess_info *info),
 			  int (*init)(struct subprocess_info *info, struct cred *new),
 			  void (*cleanup)(struct subprocess_info *), void *data);
 
diff --git a/init/do_mounts_initrd.c b/init/do_mounts_initrd.c
index 53d4f0f..8bb34c0 100644
--- a/init/do_mounts_initrd.c
+++ b/init/do_mounts_initrd.c
@@ -73,7 +73,8 @@ static void __init handle_initrd(void)
 	current->flags |= PF_FREEZER_SKIP;
 
 	info = call_usermodehelper_setup("/linuxrc", argv, envp_init,
-					 GFP_KERNEL, init_linuxrc, NULL, NULL);
+					 GFP_KERNEL, NULL, NULL, init_linuxrc,
+					 NULL, NULL);
 	if (!info)
 		return;
 	call_usermodehelper_exec(info, UMH_WAIT_PROC);
diff --git a/kernel/kmod.c b/kernel/kmod.c
index bc6addd..41df494 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -92,7 +92,8 @@ static int call_modprobe(char *module_name, int wait)
 	argv[4] = NULL;
 
 	info = call_usermodehelper_setup(modprobe_path, argv, envp, GFP_KERNEL,
-					 NULL, free_modprobe_argv, NULL);
+					 NULL, NULL, NULL, free_modprobe_argv,
+					 NULL);
 	if (!info)
 		goto free_module_name;
 
diff --git a/kernel/umh.c b/kernel/umh.c
index 6ff9905..97e9bd8 100644
--- a/kernel/umh.c
+++ b/kernel/umh.c
@@ -25,6 +25,7 @@
 #include <linux/ptrace.h>
 #include <linux/async.h>
 #include <linux/uaccess.h>
+#include <linux/delay.h>
 
 #include <trace/events/module.h>
 
@@ -53,8 +54,15 @@ static void umh_complete(struct subprocess_info *sub_info)
 	 */
 	if (comp)
 		complete(comp);
-	else
+	else {
+		for(;;) {
+			if (sub_info->cleaned == false)
+				udelay(20);
+			else
+				break;
+		}
 		call_usermodehelper_freeinfo(sub_info);
+	}
 }
 
 /*
@@ -120,6 +128,9 @@ static void call_usermodehelper_exec_sync(struct subprocess_info *sub_info)
 
 	/* If SIGCLD is ignored sys_wait4 won't populate the status. */
 	kernel_sigaction(SIGCHLD, SIG_DFL);
+	if(sub_info->cleanup_intermediate) {
+		sub_info->cleanup_intermediate(sub_info);
+	}
 	pid = kernel_thread(call_usermodehelper_exec_async, sub_info, SIGCHLD);
 	if (pid < 0) {
 		sub_info->retval = pid;
@@ -170,6 +181,9 @@ static void call_usermodehelper_exec_work(struct work_struct *work)
 {
 	struct subprocess_info *sub_info =
 		container_of(work, struct subprocess_info, work);
+	if(sub_info->init_intermediate) {
+		sub_info->init_intermediate(sub_info);
+	}
 
 	if (sub_info->wait & UMH_WAIT_PROC) {
 		call_usermodehelper_exec_sync(sub_info);
@@ -182,6 +196,11 @@ static void call_usermodehelper_exec_work(struct work_struct *work)
 		 */
 		pid = kernel_thread(call_usermodehelper_exec_async, sub_info,
 				    CLONE_PARENT | SIGCHLD);
+
+		if(sub_info->cleanup_intermediate) {
+			sub_info->cleanup_intermediate(sub_info);
+		}
+		sub_info->cleaned = true;
 		if (pid < 0) {
 			sub_info->retval = pid;
 			umh_complete(sub_info);
@@ -347,25 +366,38 @@ static void helper_unlock(void)
  * @argv: arg vector for process
  * @envp: environment for process
  * @gfp_mask: gfp mask for memory allocation
- * @cleanup: a cleanup function
+ * @init_intermediate: init function which is called in parent task
+ * @cleanup_intermediate: clean function which is called in parent task
  * @init: an init function
+ * @cleanup: a cleanup function
  * @data: arbitrary context sensitive data
  *
  * Returns either %NULL on allocation failure, or a subprocess_info
  * structure.  This should be passed to call_usermodehelper_exec to
  * exec the process and free the structure.
  *
- * The init function is used to customize the helper process prior to
- * exec.  A non-zero return code causes the process to error out, exit,
- * and return the failure to the calling process
+ * The init_intermediate is called in the parent task of user mode
+ * helper. It's designed for init works which must be done in
+ * parent task, like switching the pid_ns_for_children.
+ *
+ * The cleanup_intermediate is used when we want to cleanup what
+ * we have done in init_intermediate, it is also called in parent
+ * task.
  *
- * The cleanup function is just before ethe subprocess_info is about to
+ * The init function is called after fork. It is used to customize the
+ * helper process prior to exec.  A non-zero return code causes the
+ * process to error out, exit, and return the failure to the
+ * calling process.
+ *
+ * The cleanup function is just before the subprocess_info is about to
  * be freed.  This can be used for freeing the argv and envp.  The
  * Function must be runnable in either a process context or the
  * context in which call_usermodehelper_exec is called.
  */
 struct subprocess_info *call_usermodehelper_setup(const char *path, char **argv,
 		char **envp, gfp_t gfp_mask,
+		void (*init_intermediate)(struct subprocess_info *info),
+		void (*cleanup_intermediate)(struct subprocess_info *info),
 		int (*init)(struct subprocess_info *info, struct cred *new),
 		void (*cleanup)(struct subprocess_info *info),
 		void *data)
@@ -385,8 +417,11 @@ struct subprocess_info *call_usermodehelper_setup(const char *path, char **argv,
 	sub_info->argv = argv;
 	sub_info->envp = envp;
 
-	sub_info->cleanup = cleanup;
+	sub_info->init_intermediate = init_intermediate;
+	sub_info->cleaned = false;
+	sub_info->cleanup_intermediate = cleanup_intermediate;
 	sub_info->init = init;
+	sub_info->cleanup = cleanup;
 	sub_info->data = data;
   out:
 	return sub_info;
@@ -481,7 +516,7 @@ int call_usermodehelper(const char *path, char **argv, char **envp, int wait)
 	gfp_t gfp_mask = (wait == UMH_NO_WAIT) ? GFP_ATOMIC : GFP_KERNEL;
 
 	info = call_usermodehelper_setup(path, argv, envp, gfp_mask,
-					 NULL, NULL, NULL);
+					 NULL, NULL, NULL, NULL, NULL);
 	if (info == NULL)
 		return -ENOMEM;
 
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index e8036cd..ae1025c 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -78,8 +78,8 @@ static int call_usermodehelper_keys(const char *path, char **argv, char **envp,
 	struct subprocess_info *info;
 
 	info = call_usermodehelper_setup(path, argv, envp, GFP_KERNEL,
-					  umh_keys_init, umh_keys_cleanup,
-					  session_keyring);
+					  NULL, NULL, umh_keys_init,
+					  umh_keys_cleanup, session_keyring);
 	if (!info)
 		return -ENOMEM;
 
-- 
2.1.0
