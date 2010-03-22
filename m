From: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Subject: [C/R ARM][PATCH 1/3] ARM: Rudimentary syscall interfaces
Date: Sun, 21 Mar 2010 21:06:03 -0400
Message-ID: <1269219965-23923-2-git-send-email-christofferdall__38687.7058343545$1269220027$gmane$org@christofferdall.dk>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1269219965-23923-1-git-send-email-christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Cc: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

This small commit introduces a global state of system calls for ARM
making it possible for a debugger or checkpointing to gain information
about another process' state with respect to system calls.

The patch is based on this proposal from Roland McGrath:
https://patchwork.kernel.org/patch/32101/

Cc: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 arch/arm/include/asm/syscall.h |   31 +++++++++++++++++++++++++++++++
 arch/arm/kernel/asm-offsets.c  |    1 +
 arch/arm/kernel/entry-common.S |    8 +++++++-
 arch/arm/kernel/ptrace.c       |    2 --
 arch/arm/kernel/signal.c       |   14 +++++++-------
 5 files changed, 46 insertions(+), 10 deletions(-)
 create mode 100644 arch/arm/include/asm/syscall.h

diff --git a/arch/arm/include/asm/syscall.h b/arch/arm/include/asm/syscall.h
new file mode 100644
index 0000000..3b3248f
--- /dev/null
+++ b/arch/arm/include/asm/syscall.h
@@ -0,0 +1,31 @@
+/*
+ * syscalls.h - Linux syscall interfaces for ARM
+ *
+ * Copyright (c) 2010 Christoffer Dall
+ *
+ * This file is released under the GPLv2.
+ * See the file COPYING for more details.
+ */
+
+#ifndef _ASM_ARM_SYSCALLS_H
+#define _ASM_ARM_SYSCALLS_H
+
+static inline int syscall_get_nr(struct task_struct *task,
+				 struct pt_regs *regs)
+{
+	return (int)(task_thread_info(task)->syscall);
+}
+
+static inline long syscall_get_return_value(struct task_struct *task,
+					    struct pt_regs *regs)
+{
+	return regs->ARM_r0;
+}
+
+static inline long syscall_get_error(struct task_struct *task,
+				     struct pt_regs *regs)
+{
+	return regs->ARM_r0;
+}
+
+#endif /* _ASM_ARM_SYSCALLS_H */
diff --git a/arch/arm/kernel/asm-offsets.c b/arch/arm/kernel/asm-offsets.c
index 4a88125..726a0ad 100644
--- a/arch/arm/kernel/asm-offsets.c
+++ b/arch/arm/kernel/asm-offsets.c
@@ -48,6 +48,7 @@ int main(void)
   DEFINE(TI_CPU,		offsetof(struct thread_info, cpu));
   DEFINE(TI_CPU_DOMAIN,		offsetof(struct thread_info, cpu_domain));
   DEFINE(TI_CPU_SAVE,		offsetof(struct thread_info, cpu_context));
+  DEFINE(TI_SYSCALL,		offsetof(struct thread_info, syscall));
   DEFINE(TI_USED_CP,		offsetof(struct thread_info, used_cp));
   DEFINE(TI_TP_VALUE,		offsetof(struct thread_info, tp_value));
   DEFINE(TI_FPSTATE,		offsetof(struct thread_info, fpstate));
diff --git a/arch/arm/kernel/entry-common.S b/arch/arm/kernel/entry-common.S
index 2c1db77..f694f4d 100644
--- a/arch/arm/kernel/entry-common.S
+++ b/arch/arm/kernel/entry-common.S
@@ -30,6 +30,9 @@ ret_fast_syscall:
 	tst	r1, #_TIF_WORK_MASK
 	bne	fast_work_pending
 
+	mov	r2, #-1
+	str	r2, [tsk, #TI_SYSCALL]
+
 	/* perform architecture specific actions before user return */
 	arch_ret_to_user r1, lr
 
@@ -47,7 +50,6 @@ work_pending:
 	tst	r1, #_TIF_SIGPENDING|_TIF_NOTIFY_RESUME
 	beq	no_work_pending
 	mov	r0, sp				@ 'regs'
-	mov	r2, why				@ 'syscall'
 	bl	do_notify_resume
 	b	ret_slow_syscall		@ Check work again
 
@@ -62,6 +64,9 @@ ret_slow_syscall:
 	ldr	r1, [tsk, #TI_FLAGS]
 	tst	r1, #_TIF_WORK_MASK
 	bne	work_pending
+
+	mov	r2, #-1
+	str	r2, [tsk, #TI_SYSCALL]
 no_work_pending:
 	/* perform architecture specific actions before user return */
 	arch_ret_to_user r1, lr
@@ -274,6 +279,7 @@ ENTRY(vector_swi)
 	eor	scno, scno, #__NR_SYSCALL_BASE	@ check OS number
 #endif
 
+	str	scno, [tsk, #TI_SYSCALL]	@ store syscall nr. globally
 	stmdb	sp!, {r4, r5}			@ push fifth and sixth args
 	tst	ip, #_TIF_SYSCALL_TRACE		@ are we tracing syscalls?
 	bne	__sys_trace
diff --git a/arch/arm/kernel/ptrace.c b/arch/arm/kernel/ptrace.c
index a2ea385..44ab437 100644
--- a/arch/arm/kernel/ptrace.c
+++ b/arch/arm/kernel/ptrace.c
@@ -863,8 +863,6 @@ asmlinkage int syscall_trace(int why, struct pt_regs *regs, int scno)
 	ip = regs->ARM_ip;
 	regs->ARM_ip = why;
 
-	current_thread_info()->syscall = scno;
-
 	/* the 0x80 provides a way for the tracing parent to distinguish
 	   between a syscall stop and SIGTRAP delivery */
 	ptrace_notify(SIGTRAP | ((current->ptrace & PT_TRACESYSGOOD)
diff --git a/arch/arm/kernel/signal.c b/arch/arm/kernel/signal.c
index e7714f3..f695239 100644
--- a/arch/arm/kernel/signal.c
+++ b/arch/arm/kernel/signal.c
@@ -527,7 +527,7 @@ static inline void setup_syscall_restart(struct pt_regs *regs)
 static int
 handle_signal(unsigned long sig, struct k_sigaction *ka,
 	      siginfo_t *info, sigset_t *oldset,
-	      struct pt_regs * regs, int syscall)
+	      struct pt_regs *regs)
 {
 	struct thread_info *thread = current_thread_info();
 	struct task_struct *tsk = current;
@@ -537,7 +537,7 @@ handle_signal(unsigned long sig, struct k_sigaction *ka,
 	/*
 	 * If we were from a system call, check for system call restarting...
 	 */
-	if (syscall) {
+	if (thread->syscall != -1) {
 		switch (regs->ARM_r0) {
 		case -ERESTART_RESTARTBLOCK:
 		case -ERESTARTNOHAND:
@@ -601,7 +601,7 @@ handle_signal(unsigned long sig, struct k_sigaction *ka,
  * the kernel can handle, and then we build all the user-level signal handling
  * stack-frames in one go after that.
  */
-static void do_signal(struct pt_regs *regs, int syscall)
+static void do_signal(struct pt_regs *regs)
 {
 	struct k_sigaction ka;
 	siginfo_t info;
@@ -629,7 +629,7 @@ static void do_signal(struct pt_regs *regs, int syscall)
 			oldset = &current->saved_sigmask;
 		else
 			oldset = &current->blocked;
-		if (handle_signal(signr, &ka, &info, oldset, regs, syscall) == 0) {
+		if (handle_signal(signr, &ka, &info, oldset, regs) == 0) {
 			/*
 			 * A signal was successfully delivered; the saved
 			 * sigmask will have been stored in the signal frame,
@@ -647,7 +647,7 @@ static void do_signal(struct pt_regs *regs, int syscall)
 	/*
 	 * No signal to deliver to the process - restart the syscall.
 	 */
-	if (syscall) {
+	if (current_thread_info()->syscall != -1) {
 		if (regs->ARM_r0 == -ERESTART_RESTARTBLOCK) {
 			if (thumb_mode(regs)) {
 				regs->ARM_r7 = __NR_restart_syscall - __NR_SYSCALL_BASE;
@@ -689,10 +689,10 @@ static void do_signal(struct pt_regs *regs, int syscall)
 }
 
 asmlinkage void
-do_notify_resume(struct pt_regs *regs, unsigned int thread_flags, int syscall)
+do_notify_resume(struct pt_regs *regs, unsigned int thread_flags)
 {
 	if (thread_flags & _TIF_SIGPENDING)
-		do_signal(regs, syscall);
+		do_signal(regs);
 
 	if (thread_flags & _TIF_NOTIFY_RESUME) {
 		clear_thread_flag(TIF_NOTIFY_RESUME);
-- 
1.5.6.5
