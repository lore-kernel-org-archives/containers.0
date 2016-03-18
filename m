From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v2 2/3] Run dump pipe in container's namespace
Date: Fri, 18 Mar 2016 20:48:34 +0800
Message-ID: <a1ac975a165b63c8ee67f9785e50067be41a74ff.1458305141.git.zhaolei@cn.fujitsu.com>
References: <cover.1458305141.git.zhaolei@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1458305141.git.zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

In current system, when we set core_pattern to a pipe, both pipe program
and program's output are in host's filesystem.

For example, when we set following core_pattern:
 # echo "|/my_dump_pipe %s %c %p %u %g %t e" >/proc/sys/kernel/core_pattern
and trigger a segment fault in a container, my_dump_pipe is searched from
host's filesystem, and it will write coredump into host's filesystem too.

In a privileged container, user can destroy host system by following
command:
 # # In a container
 # echo "|/bin/dd of=/boot/vmlinuz" >/proc/sys/kernel/core_pattern
 # make_dump

Actually, all operation in a container should not change host's
environment, the container should use core_pattern as its private setting.
In detail, in core dump action:
1: Search pipe program in container's fs namespace.
2: Run pipe program in container's fs namespace to write coredump to it.

This patch fixed above problem running pipe program in user process's
context instead of kthread.

Test:
 # ################
 # # In host's system
 # ################
 #
 # ulimit -c 1024000
 # echo "|/dump_pipe" >/proc/sys/kernel/core_pattern
 # cat /dump_pipe
 #!/bin/sh
 cat >/tmp/host_dump_$1_$2_$3_$4_$5_$6
 # rm -f /tmp/*dump*
 # ./make_dump
 Segmentation fault (core dumped)
 # ls -l /tmp/*dump*
 -rw-r--r-- 1 root root 331776 Mar 16 16:57 /tmp/host_dump______
 #
 # lxc-start -n vm01
 #
 # ################
 # # In guest's system:
 # ################
 #
 # cat /proc/sys/kernel/core_pattern
 |/dump_pipe
 # cat /dump_pipe
 #!/bin/sh
 cat >/tmp/guest_dump_$1_$2_$3_$4_$5_$6
 # rm -f /tmp/*dump*
 # ./make_dump
 Segmentation fault (core dumped)
 # ls -l /tmp/*dump*
 -rw-r--r--    1 root     root       331776 Mar 16 09:02 /tmp/guest_dump______
 #

Signed-off-by: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/coredump.c         | 76 +++++++++++++++++++++++++++++++--------------------
 include/linux/sched.h |  1 +
 kernel/fork.c         |  6 ++++
 3 files changed, 53 insertions(+), 30 deletions(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index 9ea87e9..863c23a 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -496,33 +496,50 @@ static void wait_for_dump_helpers(struct file *file)
 	pipe_unlock(pipe);
 }
 
-/*
- * umh_pipe_setup
- * helper function to customize the process used
- * to collect the core in userspace.  Specifically
- * it sets up a pipe and installs it as fd 0 (stdin)
- * for the process.  Returns 0 on success, or
- * PTR_ERR on failure.
- * Note that it also sets the core limit to 1.  This
- * is a special value that we use to trap recursive
- * core dumps
- */
-static int umh_pipe_setup(struct subprocess_info *info, struct cred *new)
+struct pipeprg_data {
+	char **argv;
+	struct coredump_params *cp;
+};
+
+static int fork_callback(void *data)
 {
+	struct pipeprg_data *ppd = (struct pipeprg_data *)data;
 	struct file *files[2];
-	struct coredump_params *cp = (struct coredump_params *)info->data;
-	int err = create_pipe_files(files, 0);
-	if (err)
-		return err;
+	int ret;
+
+	/*
+	 * Sets up a pipe and installs it as fd 0 (stdin)
+	 * for the process.
+	 */
+	ret = create_pipe_files(files, 0);
+	if (ret)
+		do_exit(0);
 
-	cp->file = files[1];
+	ppd->cp->file = files[1];
 
-	err = replace_fd(0, files[0], 0);
+	ret = replace_fd(0, files[0], 0);
 	fput(files[0]);
-	/* and disallow core files too */
+	if (ret < 0)
+		do_exit(0);
+
+	/*
+	 * Sets the core limit to 1.  This
+	 * is a special value that we use to trap recursive
+	 * core dumps
+	 */
 	current->signal->rlim[RLIMIT_CORE] = (struct rlimit){1, 1};
 
-	return err;
+	set_fs(KERNEL_DS);
+	ret = do_execve(getname_kernel(ppd->argv[0]),
+			(const char __user *const __user *)ppd->argv,
+			(const char __user *const __user *)NULL);
+	if (ret) {
+		printk(KERN_WARNING "execute pipe program failed: %s ret=%d\n",
+		       ppd->argv[0], ret);
+		do_exit(0);
+	}
+
+	return ret;
 }
 
 void do_coredump(const siginfo_t *siginfo)
@@ -586,7 +603,8 @@ void do_coredump(const siginfo_t *siginfo)
 	if (ispipe) {
 		int dump_count;
 		char **helper_argv;
-		struct subprocess_info *sub_info;
+		struct pipeprg_data ppd;
+		pid_t pid;
 
 		if (ispipe < 0) {
 			printk(KERN_WARNING "format_corename failed\n");
@@ -633,19 +651,17 @@ void do_coredump(const siginfo_t *siginfo)
 			goto fail_dropcount;
 		}
 
-		retval = -ENOMEM;
-		sub_info = call_usermodehelper_setup(helper_argv[0],
-						helper_argv, NULL, GFP_KERNEL,
-						umh_pipe_setup, NULL, &cprm);
-		if (sub_info)
-			retval = call_usermodehelper_exec(sub_info,
-							  UMH_WAIT_EXEC);
+		ppd.argv = helper_argv;
+		ppd.cp = &cprm;
 
+		pid = user_thread(fork_callback, &ppd,
+				  CLONE_VFORK | CLONE_UNTRACED);
 		argv_free(helper_argv);
-		if (retval) {
+		if (pid < 0) {
 			printk(KERN_INFO "Core dump to |%s pipe failed\n",
 			       cn.corename);
-			goto close_fail;
+			retval = pid;
+			goto fail_dropcount;
 		}
 	} else {
 		struct inode *inode;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 56401e4..a1893f2 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2649,6 +2649,7 @@ extern long _do_fork(unsigned long, unsigned long, unsigned long, int __user *,
 extern long do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *);
 struct task_struct *fork_idle(int);
 extern pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags);
+extern pid_t user_thread(int (*fn)(void *), void *arg, unsigned long flags);
 
 extern void __set_task_comm(struct task_struct *tsk, const char *from, bool exec);
 static inline void set_task_comm(struct task_struct *tsk, const char *from)
diff --git a/kernel/fork.c b/kernel/fork.c
index 643a09b..71b3339 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1785,6 +1785,12 @@ pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags)
 		(unsigned long)arg, NULL, NULL, 0, 0);
 }
 
+pid_t user_thread(int (*fn)(void *), void *arg, unsigned long flags)
+{
+	return _do_fork(flags, (unsigned long)fn,
+		(unsigned long)arg, NULL, NULL, 0, 1);
+}
+
 #ifdef __ARCH_WANT_SYS_FORK
 SYSCALL_DEFINE0(fork)
 {
-- 
1.8.5.1
