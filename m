From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 1/2] Run dump pipe in container's namespace
Date: Wed, 16 Mar 2016 17:23:18 +0800
Message-ID: <f27cec06b90060f2c32691c432f624584f95d251.1458119582.git.zhaolei@cn.fujitsu.com>
References: <cover.1458119582.git.zhaolei@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1458119582.git.zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

In current system, when we set core_pattern to a pipe, both pipe program
and program's output are in host's filesystem.

For example, when we set following core_pattern:
 # echo "|/my_dump_pipe %s %c %p %u %g %t e" >/proc/sys/kernel/core_pattern
and trigger a segment fault in a container, my_dump_pipe is searched from
host's filesystem, and it will write coredump into host's filesystem too.

In a privileged container, user can crush host system by following command:
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
 arch/x86/kernel/process_32.c |  5 +--
 arch/x86/kernel/process_64.c |  5 +--
 fs/coredump.c                | 76 +++++++++++++++++++++++++++-----------------
 include/linux/sched.h        |  5 +--
 kernel/fork.c                | 24 ++++++++------
 5 files changed, 69 insertions(+), 46 deletions(-)

diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index 9f95091..2b1862e 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -130,7 +130,8 @@ void release_thread(struct task_struct *dead_task)
 }
 
 int copy_thread_tls(unsigned long clone_flags, unsigned long sp,
-	unsigned long arg, struct task_struct *p, unsigned long tls)
+	unsigned long arg, struct task_struct *p, unsigned long tls,
+	int return_to_kernel)
 {
 	struct pt_regs *childregs = task_pt_regs(p);
 	struct task_struct *tsk;
@@ -140,7 +141,7 @@ int copy_thread_tls(unsigned long clone_flags, unsigned long sp,
 	p->thread.sp0 = (unsigned long) (childregs+1);
 	memset(p->thread.ptrace_bps, 0, sizeof(p->thread.ptrace_bps));
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		/* kernel thread */
 		memset(childregs, 0, sizeof(struct pt_regs));
 		p->thread.ip = (unsigned long) ret_from_kernel_thread;
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index b9d99e0..de05bc0 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -153,7 +153,8 @@ static inline u32 read_32bit_tls(struct task_struct *t, int tls)
 }
 
 int copy_thread_tls(unsigned long clone_flags, unsigned long sp,
-		unsigned long arg, struct task_struct *p, unsigned long tls)
+		unsigned long arg, struct task_struct *p, unsigned long tls,
+		int return_to_kernel)
 {
 	int err;
 	struct pt_regs *childregs;
@@ -173,7 +174,7 @@ int copy_thread_tls(unsigned long clone_flags, unsigned long sp,
 	savesegment(ds, p->thread.ds);
 	memset(p->thread.ptrace_bps, 0, sizeof(p->thread.ptrace_bps));
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		/* kernel thread */
 		memset(childregs, 0, sizeof(struct pt_regs));
 		childregs->sp = (unsigned long)childregs;
diff --git a/fs/coredump.c b/fs/coredump.c
index 9ea87e9..6287f00 100644
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
@@ -551,6 +568,8 @@ void do_coredump(const siginfo_t *siginfo)
 		 */
 		.mm_flags = mm->flags,
 	};
+	struct pipeprg_data ppd;
+	pid_t pid;
 
 	audit_core_dumps(siginfo->si_signo);
 
@@ -586,7 +605,6 @@ void do_coredump(const siginfo_t *siginfo)
 	if (ispipe) {
 		int dump_count;
 		char **helper_argv;
-		struct subprocess_info *sub_info;
 
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
 
+		pid = _do_fork(CLONE_VFORK, (unsigned long)fork_callback,
+			       (unsigned long)&ppd, NULL, NULL, 0, 1);
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
index a10494a..1647319 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2612,7 +2612,7 @@ extern void mm_release(struct task_struct *, struct mm_struct *);
 
 #ifdef CONFIG_HAVE_COPY_THREAD_TLS
 extern int copy_thread_tls(unsigned long, unsigned long, unsigned long,
-			struct task_struct *, unsigned long);
+			struct task_struct *, unsigned long, int);
 #else
 extern int copy_thread(unsigned long, unsigned long, unsigned long,
 			struct task_struct *);
@@ -2644,7 +2644,8 @@ extern int do_execveat(int, struct filename *,
 		       const char __user * const __user *,
 		       const char __user * const __user *,
 		       int);
-extern long _do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *, unsigned long);
+extern long _do_fork(unsigned long, unsigned long, unsigned long, int __user *,
+		     int __user *, unsigned long, int);
 extern long do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *);
 struct task_struct *fork_idle(int);
 extern pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags);
diff --git a/kernel/fork.c b/kernel/fork.c
index 2e391c7..643a09b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1245,7 +1245,8 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 					int __user *child_tidptr,
 					struct pid *pid,
 					int trace,
-					unsigned long tls)
+					unsigned long tls,
+					int return_to_kernel)
 {
 	int retval;
 	struct task_struct *p;
@@ -1451,7 +1452,8 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	retval = copy_io(clone_flags, p);
 	if (retval)
 		goto bad_fork_cleanup_namespaces;
-	retval = copy_thread_tls(clone_flags, stack_start, stack_size, p, tls);
+	retval = copy_thread_tls(clone_flags, stack_start, stack_size, p, tls,
+				 return_to_kernel);
 	if (retval)
 		goto bad_fork_cleanup_io;
 
@@ -1673,7 +1675,7 @@ static inline void init_idle_pids(struct pid_link *links)
 struct task_struct *fork_idle(int cpu)
 {
 	struct task_struct *task;
-	task = copy_process(CLONE_VM, 0, 0, NULL, &init_struct_pid, 0, 0);
+	task = copy_process(CLONE_VM, 0, 0, NULL, &init_struct_pid, 0, 0, 0);
 	if (!IS_ERR(task)) {
 		init_idle_pids(task->pids);
 		init_idle(task, cpu);
@@ -1693,7 +1695,8 @@ long _do_fork(unsigned long clone_flags,
 	      unsigned long stack_size,
 	      int __user *parent_tidptr,
 	      int __user *child_tidptr,
-	      unsigned long tls)
+	      unsigned long tls,
+	      int return_to_kernel)
 {
 	struct task_struct *p;
 	int trace = 0;
@@ -1718,7 +1721,7 @@ long _do_fork(unsigned long clone_flags,
 	}
 
 	p = copy_process(clone_flags, stack_start, stack_size,
-			 child_tidptr, NULL, trace, tls);
+			 child_tidptr, NULL, trace, tls, return_to_kernel);
 	/*
 	 * Do this prior waking up the new thread - the thread pointer
 	 * might get invalid after that point, if the thread exits quickly.
@@ -1769,7 +1772,7 @@ long do_fork(unsigned long clone_flags,
 	      int __user *child_tidptr)
 {
 	return _do_fork(clone_flags, stack_start, stack_size,
-			parent_tidptr, child_tidptr, 0);
+			parent_tidptr, child_tidptr, 0, 0);
 }
 #endif
 
@@ -1779,14 +1782,14 @@ long do_fork(unsigned long clone_flags,
 pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags)
 {
 	return _do_fork(flags|CLONE_VM|CLONE_UNTRACED, (unsigned long)fn,
-		(unsigned long)arg, NULL, NULL, 0);
+		(unsigned long)arg, NULL, NULL, 0, 0);
 }
 
 #ifdef __ARCH_WANT_SYS_FORK
 SYSCALL_DEFINE0(fork)
 {
 #ifdef CONFIG_MMU
-	return _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0);
+	return _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0, 0);
 #else
 	/* can not support in nommu mode */
 	return -EINVAL;
@@ -1798,7 +1801,7 @@ SYSCALL_DEFINE0(fork)
 SYSCALL_DEFINE0(vfork)
 {
 	return _do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, 0,
-			0, NULL, NULL, 0);
+			0, NULL, NULL, 0, 0);
 }
 #endif
 
@@ -1826,7 +1829,8 @@ SYSCALL_DEFINE5(clone, unsigned long, clone_flags, unsigned long, newsp,
 		 unsigned long, tls)
 #endif
 {
-	return _do_fork(clone_flags, newsp, 0, parent_tidptr, child_tidptr, tls);
+	return _do_fork(clone_flags, newsp, 0, parent_tidptr, child_tidptr,
+			tls, 0);
 }
 #endif
 
-- 
1.8.5.1
