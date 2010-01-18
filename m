From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] make checkpoint a ptregs syscall as well
Date: Mon, 18 Jan 2010 14:33:18 -0600
Message-ID: <20100118203318.GA22903@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

This is on top of the 64-bit patches which Oren posted on Dec 6, so
it does not work with my cr-next branch or Oren's ckpt-v19-rc2, and
s390 and powerpc will need corresponding patches.

Without this, restart of self-checkpoint fails (understandably) on the
amd64 test system I'm borrowing.

I have not yet tested restart of checkpointed 32-bit program on 64-bit
machine.  Or for that matter a 32bit kernel.

Thanks, Nathan, for finding the problem!  I should have guessed, based
on my symptoms.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/include/asm/syscalls.h    |    3 +++
 arch/x86/include/asm/unistd_64.h   |    2 +-
 arch/x86/kernel/checkpoint_64.c    |   10 ++++++++++
 arch/x86/kernel/entry_32.S         |    1 +
 arch/x86/kernel/entry_64.S         |    2 ++
 arch/x86/kernel/syscall_table_32.S |    2 +-
 checkpoint/sys.c                   |    5 ++---
 include/linux/checkpoint.h         |    2 ++
 include/linux/syscalls.h           |    2 --
 9 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/syscalls.h b/arch/x86/include/asm/syscalls.h
index 063cdd0..35b2060 100644
--- a/arch/x86/include/asm/syscalls.h
+++ b/arch/x86/include/asm/syscalls.h
@@ -45,6 +45,7 @@ int sys_execve(struct pt_regs *);
 
 /* kernel/checkpoint_32.c */
 #ifdef CONFIG_CHECKPOINT
+long sys_checkpoint(struct pt_regs *);
 long sys_restart(struct pt_regs *);
 #endif
 
@@ -90,6 +91,8 @@ long sys_arch_prctl(int, unsigned long);
 
 /* kernel/checkpoint_64.c */
 #ifdef CONFIG_CHECKPOINT
+asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags,
+				int logfd, struct pt_regs *regs);
 asmlinkage long sys_restart(pid_t pid, int fd, unsigned long flags, int logfd,
 			    struct pt_regs *regs);
 #endif
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index c360707..e443304 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -664,7 +664,7 @@ __SYSCALL(__NR_perf_event_open, sys_perf_event_open)
 #define __NR_eclone                   		299
 __SYSCALL(__NR_eclone, stub_eclone)
 #define __NR_checkpoint                   	300
-__SYSCALL(__NR_checkpoint, sys_checkpoint)
+__SYSCALL(__NR_checkpoint, stub_checkpoint)
 #define __NR_restart                   		301
 __SYSCALL(__NR_restart, stub_restart)
 
diff --git a/arch/x86/kernel/checkpoint_64.c b/arch/x86/kernel/checkpoint_64.c
index 87c1606..a63e88d 100644
--- a/arch/x86/kernel/checkpoint_64.c
+++ b/arch/x86/kernel/checkpoint_64.c
@@ -22,6 +22,16 @@
  * sys_restart needs to access and modify the pt_regs structure to
  * restore the original state from the time of the checkpoint.
  */
+asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags, int logfd,
+			    struct pt_regs *regs)
+{
+	return do_sys_checkpoint(pid, fd, flags, logfd);
+}
+
+/*
+ * sys_restart needs to access and modify the pt_regs structure to
+ * restore the original state from the time of the checkpoint.
+ */
 asmlinkage long sys_restart(pid_t pid, int fd, unsigned long flags, int logfd,
 			    struct pt_regs *regs)
 {
diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
index ecefd09..76ec9c4 100644
--- a/arch/x86/kernel/entry_32.S
+++ b/arch/x86/kernel/entry_32.S
@@ -727,6 +727,7 @@ PTREGSCALL(rt_sigreturn)
 PTREGSCALL(vm86)
 PTREGSCALL(vm86old)
 #ifdef CONFIG_CHECKPOINT
+PTREGSCALL(checkpoint)
 PTREGSCALL(restart)
 #endif
 
diff --git a/arch/x86/kernel/entry_64.S b/arch/x86/kernel/entry_64.S
index e692193..ec6f43f 100644
--- a/arch/x86/kernel/entry_64.S
+++ b/arch/x86/kernel/entry_64.S
@@ -700,8 +700,10 @@ END(\label)
 	PTREGSCALL stub_iopl, sys_iopl, %rsi
 	PTREGSCALL stub_eclone, sys_eclone, %r8
 #ifdef CONFIG_CHECKPOINT
+	PTREGSCALL stub_checkpoint, sys_checkpoint, %r8
 	PTREGSCALL stub_restart, sys_restart, %r8
 #else
+	PTREGSCALL stub_checkpoint, sys_ni_syscall, %r8
 	PTREGSCALL stub_restart, sys_ni_syscall, %r8
 #endif
 
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index 1ca053e..28fd000 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -337,5 +337,5 @@ ENTRY(sys_call_table)
 	.long sys_rt_tgsigqueueinfo	/* 335 */
 	.long sys_perf_event_open
 	.long ptregs_eclone
-	.long sys_checkpoint
+	.long ptregs_checkpoint
 	.long ptregs_restart
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 303e16f..c26682c 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -605,7 +605,7 @@ int walk_task_subtree(struct task_struct *root,
 /* checkpoint/restart syscalls */
 
 /**
- * sys_checkpoint - checkpoint a container
+ * do_sys_checkpoint - checkpoint a container
  * @pid: pid of the container init(1) process
  * @fd: file to which dump the checkpoint image
  * @flags: checkpoint operation flags
@@ -614,8 +614,7 @@ int walk_task_subtree(struct task_struct *root,
  * Returns positive identifier on success, 0 when returning from restart
  * or negative value on error
  */
-SYSCALL_DEFINE4(checkpoint, pid_t, pid, int, fd,
-		unsigned long, flags, int, logfd)
+long do_sys_checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
 {
 	struct ckpt_ctx *ctx;
 	long ret;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index fb0f5e8..f569fb0 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -60,6 +60,8 @@
 #define CKPT_LSM_INFO_LEN 200
 #define CKPT_LSM_STRING_MAX 1024
 
+extern long do_sys_checkpoint(pid_t pid, int fd, unsigned long flags,
+				int logfd);
 extern long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd);
 
 extern int walk_task_subtree(struct task_struct *task,
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 264a02e..a990ace 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -872,8 +872,6 @@ asmlinkage long sys_pselect6(int, fd_set __user *, fd_set __user *,
 asmlinkage long sys_ppoll(struct pollfd __user *, unsigned int,
 			  struct timespec __user *, const sigset_t __user *,
 			  size_t);
-asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags,
-			       int logfd);
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
-- 
1.6.0.6
