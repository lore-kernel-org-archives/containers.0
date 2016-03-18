From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v2 1/3] Make _do_fork support return to caller's code
Date: Fri, 18 Mar 2016 20:48:33 +0800
Message-ID: <15f913a1d994fd752fe9de169570f01611653211.1458305141.git.zhaolei@cn.fujitsu.com>
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

Currently, _do_fork() have following action:
1: Called by user task
   New task return to user space code directly, bypass remain
   kernel space code.
2: Called by kthread
   New task run into callback function in kernel space specified
   by _do_fork() caller.

In somecase, we need to fork a new task in user process's context,
it is used for next patch to fix core dump's security problem in
container.

This patch add a argument named return_to_kernel to _do_fork(),
to make new task always return to kernel_space with this argument.

Signed-off-by: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 arch/alpha/kernel/process.c         |  4 ++--
 arch/arc/kernel/process.c           |  4 ++--
 arch/arm/kernel/process.c           |  4 ++--
 arch/arm64/kernel/process.c         |  5 +++--
 arch/avr32/kernel/process.c         |  5 +++--
 arch/blackfin/kernel/process.c      |  5 +++--
 arch/c6x/kernel/process.c           |  5 +++--
 arch/cris/arch-v10/kernel/process.c |  4 ++--
 arch/cris/arch-v32/kernel/process.c |  4 ++--
 arch/frv/kernel/process.c           |  4 ++--
 arch/h8300/kernel/process.c         |  4 ++--
 arch/hexagon/kernel/process.c       |  4 ++--
 arch/ia64/kernel/process.c          |  4 ++--
 arch/m32r/kernel/process.c          |  4 ++--
 arch/m68k/kernel/process.c          |  4 ++--
 arch/metag/kernel/process.c         |  5 +++--
 arch/microblaze/kernel/process.c    |  4 ++--
 arch/mips/kernel/process.c          |  4 ++--
 arch/mn10300/kernel/process.c       |  4 ++--
 arch/nios2/kernel/process.c         |  5 +++--
 arch/openrisc/kernel/process.c      |  4 ++--
 arch/parisc/kernel/process.c        |  5 +++--
 arch/powerpc/kernel/process.c       |  5 +++--
 arch/s390/kernel/process.c          |  4 ++--
 arch/score/kernel/process.c         |  4 ++--
 arch/sh/kernel/process_32.c         |  4 ++--
 arch/sh/kernel/process_64.c         |  4 ++--
 arch/sparc/kernel/process_32.c      |  4 ++--
 arch/sparc/kernel/process_64.c      |  4 ++--
 arch/tile/kernel/process.c          |  4 ++--
 arch/um/kernel/process.c            | 22 ++++++++++++----------
 arch/unicore32/kernel/process.c     |  4 ++--
 arch/x86/kernel/process_32.c        |  5 +++--
 arch/x86/kernel/process_64.c        |  5 +++--
 arch/xtensa/kernel/process.c        |  5 +++--
 include/linux/sched.h               | 11 ++++++-----
 kernel/fork.c                       | 24 ++++++++++++++----------
 37 files changed, 111 insertions(+), 93 deletions(-)

diff --git a/arch/alpha/kernel/process.c b/arch/alpha/kernel/process.c
index 84d1326..8c8b497 100644
--- a/arch/alpha/kernel/process.c
+++ b/arch/alpha/kernel/process.c
@@ -241,7 +241,7 @@ release_thread(struct task_struct *dead_task)
 int
 copy_thread(unsigned long clone_flags, unsigned long usp,
 	    unsigned long kthread_arg,
-	    struct task_struct *p)
+	    struct task_struct *p, int return_to_kernel)
 {
 	extern void ret_from_fork(void);
 	extern void ret_from_kernel_thread(void);
@@ -255,7 +255,7 @@ copy_thread(unsigned long clone_flags, unsigned long usp,
 	childti->pcb.ksp = (unsigned long) childstack;
 	childti->pcb.flags = 1;	/* set FEN, clear everything else */
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		/* kernel thread */
 		memset(childstack, 0,
 			sizeof(struct switch_stack) + sizeof(struct pt_regs));
diff --git a/arch/arc/kernel/process.c b/arch/arc/kernel/process.c
index a3f750e..252befc 100644
--- a/arch/arc/kernel/process.c
+++ b/arch/arc/kernel/process.c
@@ -88,7 +88,7 @@ asmlinkage void ret_from_fork(void);
  */
 int copy_thread(unsigned long clone_flags,
 		unsigned long usp, unsigned long kthread_arg,
-		struct task_struct *p)
+		struct task_struct *p, int return_to_kernel)
 {
 	struct pt_regs *c_regs;        /* child's pt_regs */
 	unsigned long *childksp;       /* to unwind out of __switch_to() */
@@ -115,7 +115,7 @@ int copy_thread(unsigned long clone_flags,
 	childksp[0] = 0;			/* fp */
 	childksp[1] = (unsigned long)ret_from_fork; /* blink */
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(c_regs, 0, sizeof(struct pt_regs));
 
 		c_callee->r13 = kthread_arg;
diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
index 4adfb46..f1acaf0 100644
--- a/arch/arm/kernel/process.c
+++ b/arch/arm/kernel/process.c
@@ -222,7 +222,7 @@ asmlinkage void ret_from_fork(void) __asm__("ret_from_fork");
 
 int
 copy_thread(unsigned long clone_flags, unsigned long stack_start,
-	    unsigned long stk_sz, struct task_struct *p)
+	    unsigned long stk_sz, struct task_struct *p, int return_to_kernel)
 {
 	struct thread_info *thread = task_thread_info(p);
 	struct pt_regs *childregs = task_pt_regs(p);
@@ -239,7 +239,7 @@ copy_thread(unsigned long clone_flags, unsigned long stack_start,
 	thread->cpu_domain = get_domain();
 #endif
 
-	if (likely(!(p->flags & PF_KTHREAD))) {
+	if (likely(!(p->flags & PF_KTHREAD)) && !return_to_kernel) {
 		*childregs = *current_pt_regs();
 		childregs->ARM_r0 = 0;
 		if (stack_start)
diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
index 88d742b..62a38eb 100644
--- a/arch/arm64/kernel/process.c
+++ b/arch/arm64/kernel/process.c
@@ -245,13 +245,14 @@ int arch_dup_task_struct(struct task_struct *dst, struct task_struct *src)
 asmlinkage void ret_from_fork(void) asm("ret_from_fork");
 
 int copy_thread(unsigned long clone_flags, unsigned long stack_start,
-		unsigned long stk_sz, struct task_struct *p)
+		unsigned long stk_sz, struct task_struct *p,
+		int return_to_kernel)
 {
 	struct pt_regs *childregs = task_pt_regs(p);
 
 	memset(&p->thread.cpu_context, 0, sizeof(struct cpu_context));
 
-	if (likely(!(p->flags & PF_KTHREAD))) {
+	if (likely(!(p->flags & PF_KTHREAD)) && !return_to_kernel) {
 		*childregs = *current_pt_regs();
 		childregs->regs[0] = 0;
 
diff --git a/arch/avr32/kernel/process.c b/arch/avr32/kernel/process.c
index 42a53e74..4ac993f 100644
--- a/arch/avr32/kernel/process.c
+++ b/arch/avr32/kernel/process.c
@@ -281,11 +281,12 @@ asmlinkage void syscall_return(void);
 
 int copy_thread(unsigned long clone_flags, unsigned long usp,
 		unsigned long arg,
-		struct task_struct *p)
+		struct task_struct *p,
+		int return_to_kernel)
 {
 	struct pt_regs *childregs = task_pt_regs(p);
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(childregs, 0, sizeof(struct pt_regs));
 		p->thread.cpu_context.r0 = arg;
 		p->thread.cpu_context.r1 = usp; /* fn */
diff --git a/arch/blackfin/kernel/process.c b/arch/blackfin/kernel/process.c
index 4aa5545..23d8655 100644
--- a/arch/blackfin/kernel/process.c
+++ b/arch/blackfin/kernel/process.c
@@ -112,14 +112,15 @@ asmlinkage int bfin_clone(unsigned long clone_flags, unsigned long newsp)
 int
 copy_thread(unsigned long clone_flags,
 	    unsigned long usp, unsigned long topstk,
-	    struct task_struct *p)
+	    struct task_struct *p,
+	    int return_to_kernel)
 {
 	struct pt_regs *childregs;
 	unsigned long *v;
 
 	childregs = (struct pt_regs *) (task_stack_page(p) + THREAD_SIZE) - 1;
 	v = ((unsigned long *)childregs) - 2;
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(childregs, 0, sizeof(struct pt_regs));
 		v[0] = usp;
 		v[1] = topstk;
diff --git a/arch/c6x/kernel/process.c b/arch/c6x/kernel/process.c
index 3ae9f5a..31fa2ad 100644
--- a/arch/c6x/kernel/process.c
+++ b/arch/c6x/kernel/process.c
@@ -112,13 +112,14 @@ void start_thread(struct pt_regs *regs, unsigned int pc, unsigned long usp)
  */
 int copy_thread(unsigned long clone_flags, unsigned long usp,
 		unsigned long ustk_size,
-		struct task_struct *p)
+		struct task_struct *p,
+		int return_to_kernel)
 {
 	struct pt_regs *childregs;
 
 	childregs = task_pt_regs(p);
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		/* case of  __kernel_thread: we return to supervisor space */
 		memset(childregs, 0, sizeof(struct pt_regs));
 		childregs->sp = (unsigned long)(childregs + 1);
diff --git a/arch/cris/arch-v10/kernel/process.c b/arch/cris/arch-v10/kernel/process.c
index 02b7834..d03a6bf 100644
--- a/arch/cris/arch-v10/kernel/process.c
+++ b/arch/cris/arch-v10/kernel/process.c
@@ -95,7 +95,7 @@ asmlinkage void ret_from_fork(void);
 asmlinkage void ret_from_kernel_thread(void);
 
 int copy_thread(unsigned long clone_flags, unsigned long usp,
-		unsigned long arg, struct task_struct *p)
+		unsigned long arg, struct task_struct *p, int return_to_kernel)
 {
 	struct pt_regs *childregs = task_pt_regs(p);
 	struct switch_stack *swstack = ((struct switch_stack *)childregs) - 1;
@@ -104,7 +104,7 @@ int copy_thread(unsigned long clone_flags, unsigned long usp,
 	 * remember that the task_struct doubles as the kernel stack for the task
 	 */
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(swstack, 0,
 			sizeof(struct switch_stack) + sizeof(struct pt_regs));
 		swstack->r1 = usp;
diff --git a/arch/cris/arch-v32/kernel/process.c b/arch/cris/arch-v32/kernel/process.c
index c7ce784..aa6b71f 100644
--- a/arch/cris/arch-v32/kernel/process.c
+++ b/arch/cris/arch-v32/kernel/process.c
@@ -103,7 +103,7 @@ extern asmlinkage void ret_from_kernel_thread(void);
 
 int
 copy_thread(unsigned long clone_flags, unsigned long usp,
-	unsigned long arg, struct task_struct *p)
+	unsigned long arg, struct task_struct *p, int return_to_kernel)
 {
 	struct pt_regs *childregs = task_pt_regs(p);
 	struct switch_stack *swstack = ((struct switch_stack *) childregs) - 1;
@@ -113,7 +113,7 @@ copy_thread(unsigned long clone_flags, unsigned long usp,
 	 * fix it up. Note: the task_struct doubles as the kernel stack for the
 	 * task.
 	 */
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(swstack, 0,
 			sizeof(struct switch_stack) + sizeof(struct pt_regs));
 		swstack->r1 = usp;
diff --git a/arch/frv/kernel/process.c b/arch/frv/kernel/process.c
index 5d40aeb77..5f7d8a8 100644
--- a/arch/frv/kernel/process.c
+++ b/arch/frv/kernel/process.c
@@ -127,7 +127,7 @@ inline unsigned long user_stack(const struct pt_regs *regs)
  */
 int copy_thread(unsigned long clone_flags,
 		unsigned long usp, unsigned long arg,
-		struct task_struct *p)
+		struct task_struct *p, int return_to_kernel)
 {
 	struct pt_regs *childregs;
 
@@ -144,7 +144,7 @@ int copy_thread(unsigned long clone_flags,
 	p->thread.lr	 = 0;
 	p->thread.frame0 = childregs;
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		childregs->gr9 = usp; /* function */
 		childregs->gr8 = arg;
 		p->thread.pc = (unsigned long) ret_from_kernel_thread;
diff --git a/arch/h8300/kernel/process.c b/arch/h8300/kernel/process.c
index dee4125..c6613bd 100644
--- a/arch/h8300/kernel/process.c
+++ b/arch/h8300/kernel/process.c
@@ -104,13 +104,13 @@ void flush_thread(void)
 
 int copy_thread(unsigned long clone_flags,
 		unsigned long usp, unsigned long topstk,
-		struct task_struct *p)
+		struct task_struct *p, int return_to_kernel)
 {
 	struct pt_regs *childregs;
 
 	childregs = (struct pt_regs *) (THREAD_SIZE + task_stack_page(p)) - 1;
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(childregs, 0, sizeof(struct pt_regs));
 		childregs->retpc = (unsigned long) ret_from_kernel_thread;
 		childregs->er4 = topstk; /* arg */
diff --git a/arch/hexagon/kernel/process.c b/arch/hexagon/kernel/process.c
index a9ebd47..920604b 100644
--- a/arch/hexagon/kernel/process.c
+++ b/arch/hexagon/kernel/process.c
@@ -69,7 +69,7 @@ unsigned long thread_saved_pc(struct task_struct *tsk)
  * Copy architecture-specific thread state
  */
 int copy_thread(unsigned long clone_flags, unsigned long usp,
-		unsigned long arg, struct task_struct *p)
+		unsigned long arg, struct task_struct *p, int return_to_kernel)
 {
 	struct thread_info *ti = task_thread_info(p);
 	struct hexagon_switch_stack *ss;
@@ -91,7 +91,7 @@ int copy_thread(unsigned long clone_flags, unsigned long usp,
 						    sizeof(*ss));
 	ss->lr = (unsigned long)ret_from_fork;
 	p->thread.switch_sp = ss;
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(childregs, 0, sizeof(struct pt_regs));
 		/* r24 <- fn, r25 <- arg */
 		ss->r24 = usp;
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index b515149..a5ff431 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -333,7 +333,7 @@ ia64_load_extra (struct task_struct *task)
 int
 copy_thread(unsigned long clone_flags,
 	     unsigned long user_stack_base, unsigned long user_stack_size,
-	     struct task_struct *p)
+	     struct task_struct *p, int return_to_kernel)
 {
 	extern char ia64_ret_from_clone;
 	struct switch_stack *child_stack, *stack;
@@ -375,7 +375,7 @@ copy_thread(unsigned long clone_flags,
 
 	ia64_drop_fpu(p);	/* don't pick up stale state from a CPU's fph */
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		if (unlikely(!user_stack_base)) {
 			/* fork_idle() called us */
 			return 0;
diff --git a/arch/m32r/kernel/process.c b/arch/m32r/kernel/process.c
index e69221d..aec7068 100644
--- a/arch/m32r/kernel/process.c
+++ b/arch/m32r/kernel/process.c
@@ -129,13 +129,13 @@ int dump_fpu(struct pt_regs *regs, elf_fpregset_t *fpu)
 }
 
 int copy_thread(unsigned long clone_flags, unsigned long spu,
-	unsigned long arg, struct task_struct *tsk)
+	unsigned long arg, struct task_struct *tsk, int return_to_kernel)
 {
 	struct pt_regs *childregs = task_pt_regs(tsk);
 	extern void ret_from_fork(void);
 	extern void ret_from_kernel_thread(void);
 
-	if (unlikely(tsk->flags & PF_KTHREAD)) {
+	if (unlikely(tsk->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(childregs, 0, sizeof(struct pt_regs));
 		childregs->psw = M32R_PSW_BIE;
 		childregs->r1 = spu;	/* fn */
diff --git a/arch/m68k/kernel/process.c b/arch/m68k/kernel/process.c
index c55ff71..2c3e3d3 100644
--- a/arch/m68k/kernel/process.c
+++ b/arch/m68k/kernel/process.c
@@ -130,7 +130,7 @@ asmlinkage int m68k_clone(struct pt_regs *regs)
 }
 
 int copy_thread(unsigned long clone_flags, unsigned long usp,
-		 unsigned long arg, struct task_struct *p)
+		 unsigned long arg, struct task_struct *p, int return_to_kernel)
 {
 	struct fork_frame {
 		struct switch_stack sw;
@@ -148,7 +148,7 @@ int copy_thread(unsigned long clone_flags, unsigned long usp,
 	 */
 	p->thread.fs = get_fs().seg;
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		/* kernel thread */
 		memset(frame, 0, sizeof(struct fork_frame));
 		frame->regs.sr = PS_S;
diff --git a/arch/metag/kernel/process.c b/arch/metag/kernel/process.c
index 7f54618..2e78cd4 100644
--- a/arch/metag/kernel/process.c
+++ b/arch/metag/kernel/process.c
@@ -178,7 +178,8 @@ void show_regs(struct pt_regs *regs)
  * Copy architecture-specific thread state
  */
 int copy_thread(unsigned long clone_flags, unsigned long usp,
-		unsigned long kthread_arg, struct task_struct *tsk)
+		unsigned long kthread_arg, struct task_struct *tsk,
+		int return_to_kernel)
 {
 	struct pt_regs *childregs = task_pt_regs(tsk);
 	void *kernel_context = ((void *) childregs +
@@ -195,7 +196,7 @@ int copy_thread(unsigned long clone_flags, unsigned long usp,
 						     ret_from_fork,
 						     0, 0);
 
-	if (unlikely(tsk->flags & PF_KTHREAD)) {
+	if (unlikely(tsk->flags & PF_KTHREAD) || return_to_kernel) {
 		/*
 		 * Make sure we don't leak any kernel data to child's regs
 		 * if kernel thread becomes a userspace thread in the future
diff --git a/arch/microblaze/kernel/process.c b/arch/microblaze/kernel/process.c
index b2dd3719..60e6e80 100644
--- a/arch/microblaze/kernel/process.c
+++ b/arch/microblaze/kernel/process.c
@@ -52,12 +52,12 @@ void flush_thread(void)
 }
 
 int copy_thread(unsigned long clone_flags, unsigned long usp,
-		unsigned long arg, struct task_struct *p)
+		unsigned long arg, struct task_struct *p, int return_to_kernel)
 {
 	struct pt_regs *childregs = task_pt_regs(p);
 	struct thread_info *ti = task_thread_info(p);
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		/* if we're creating a new kernel thread then just zeroing all
 		 * the registers. That's OK for a brand new thread.*/
 		memset(childregs, 0, sizeof(struct pt_regs));
diff --git a/arch/mips/kernel/process.c b/arch/mips/kernel/process.c
index eddd5fd..be41191 100644
--- a/arch/mips/kernel/process.c
+++ b/arch/mips/kernel/process.c
@@ -109,7 +109,7 @@ int arch_dup_task_struct(struct task_struct *dst, struct task_struct *src)
  * Copy architecture-specific thread state
  */
 int copy_thread(unsigned long clone_flags, unsigned long usp,
-	unsigned long kthread_arg, struct task_struct *p)
+	unsigned long kthread_arg, struct task_struct *p, int return_to_kernel)
 {
 	struct thread_info *ti = task_thread_info(p);
 	struct pt_regs *childregs, *regs = current_pt_regs();
@@ -123,7 +123,7 @@ int copy_thread(unsigned long clone_flags, unsigned long usp,
 	/*  Put the stack after the struct pt_regs.  */
 	childksp = (unsigned long) childregs;
 	p->thread.cp0_status = read_c0_status() & ~(ST0_CU2|ST0_CU1);
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		/* kernel thread */
 		unsigned long status = p->thread.cp0_status;
 		memset(childregs, 0, sizeof(struct pt_regs));
diff --git a/arch/mn10300/kernel/process.c b/arch/mn10300/kernel/process.c
index 3707da5..cbf0fbe 100644
--- a/arch/mn10300/kernel/process.c
+++ b/arch/mn10300/kernel/process.c
@@ -142,7 +142,7 @@ int arch_dup_task_struct(struct task_struct *dst, struct task_struct *src)
  */
 int copy_thread(unsigned long clone_flags,
 		unsigned long c_usp, unsigned long ustk_size,
-		struct task_struct *p)
+		struct task_struct *p, int return_to_kernel)
 {
 	struct thread_info *ti = task_thread_info(p);
 	struct pt_regs *c_regs;
@@ -163,7 +163,7 @@ int copy_thread(unsigned long clone_flags,
 	p->thread.wchan	= p->thread.pc;
 	p->thread.usp	= c_usp;
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(c_regs, 0, sizeof(struct pt_regs));
 		c_regs->a0 = c_usp; /* function */
 		c_regs->d0 = ustk_size; /* argument */
diff --git a/arch/nios2/kernel/process.c b/arch/nios2/kernel/process.c
index 2f8c74f..e1fe2c0 100644
--- a/arch/nios2/kernel/process.c
+++ b/arch/nios2/kernel/process.c
@@ -97,7 +97,8 @@ void flush_thread(void)
 }
 
 int copy_thread(unsigned long clone_flags,
-		unsigned long usp, unsigned long arg, struct task_struct *p)
+		unsigned long usp, unsigned long arg, struct task_struct *p,
+		int return_to_kernel)
 {
 	struct pt_regs *childregs = task_pt_regs(p);
 	struct pt_regs *regs;
@@ -105,7 +106,7 @@ int copy_thread(unsigned long clone_flags,
 	struct switch_stack *childstack =
 		((struct switch_stack *)childregs) - 1;
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(childstack, 0,
 			sizeof(struct switch_stack) + sizeof(struct pt_regs));
 
diff --git a/arch/openrisc/kernel/process.c b/arch/openrisc/kernel/process.c
index 7095dfe..a54fc66 100644
--- a/arch/openrisc/kernel/process.c
+++ b/arch/openrisc/kernel/process.c
@@ -143,7 +143,7 @@ extern asmlinkage void ret_from_fork(void);
 
 int
 copy_thread(unsigned long clone_flags, unsigned long usp,
-	    unsigned long arg, struct task_struct *p)
+	    unsigned long arg, struct task_struct *p, int return_to_kernel)
 {
 	struct pt_regs *userregs;
 	struct pt_regs *kregs;
@@ -164,7 +164,7 @@ copy_thread(unsigned long clone_flags, unsigned long usp,
 	sp -= sizeof(struct pt_regs);
 	kregs = (struct pt_regs *)sp;
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(kregs, 0, sizeof(struct pt_regs));
 		kregs->gpr[20] = usp; /* fn, kernel thread */
 		kregs->gpr[22] = arg;
diff --git a/arch/parisc/kernel/process.c b/arch/parisc/kernel/process.c
index 809905a..7ed7eb63 100644
--- a/arch/parisc/kernel/process.c
+++ b/arch/parisc/kernel/process.c
@@ -186,7 +186,8 @@ int dump_task_fpu (struct task_struct *tsk, elf_fpregset_t *r)
  */
 int
 copy_thread(unsigned long clone_flags, unsigned long usp,
-	    unsigned long kthread_arg, struct task_struct *p)
+	    unsigned long kthread_arg, struct task_struct *p,
+	    int return_to_kernel)
 {
 	struct pt_regs *cregs = &(p->thread.regs);
 	void *stack = task_stack_page(p);
@@ -197,7 +198,7 @@ copy_thread(unsigned long clone_flags, unsigned long usp,
 	extern void * const ret_from_kernel_thread;
 	extern void * const child_return;
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		/* kernel thread */
 		memset(cregs, 0, sizeof(struct pt_regs));
 		if (!usp) /* idle thread */
diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
index 3c5736e..208929f 100644
--- a/arch/powerpc/kernel/process.c
+++ b/arch/powerpc/kernel/process.c
@@ -1260,7 +1260,8 @@ static void setup_ksp_vsid(struct task_struct *p, unsigned long sp)
  * Copy architecture-specific thread state
  */
 int copy_thread(unsigned long clone_flags, unsigned long usp,
-		unsigned long kthread_arg, struct task_struct *p)
+		unsigned long kthread_arg, struct task_struct *p,
+		int return_to_kernel)
 {
 	struct pt_regs *childregs, *kregs;
 	extern void ret_from_fork(void);
@@ -1271,7 +1272,7 @@ int copy_thread(unsigned long clone_flags, unsigned long usp,
 	/* Copy registers */
 	sp -= sizeof(struct pt_regs);
 	childregs = (struct pt_regs *) sp;
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		/* kernel thread */
 		struct thread_info *ti = (void *)task_stack_page(p);
 		memset(childregs, 0, sizeof(struct pt_regs));
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index 2bba7df..8e8e9ef 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -118,7 +118,7 @@ int arch_dup_task_struct(struct task_struct *dst, struct task_struct *src)
 }
 
 int copy_thread(unsigned long clone_flags, unsigned long new_stackp,
-		unsigned long arg, struct task_struct *p)
+		unsigned long arg, struct task_struct *p, int return_to_kernel)
 {
 	struct thread_info *ti;
 	struct fake_frame
@@ -149,7 +149,7 @@ int copy_thread(unsigned long clone_flags, unsigned long new_stackp,
 	frame->sf.gprs[9] = (unsigned long) frame;
 
 	/* Store access registers to kernel stack of new process. */
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		/* kernel thread */
 		memset(&frame->childregs, 0, sizeof(struct pt_regs));
 		frame->childregs.psw.mask = PSW_KERNEL_BITS | PSW_MASK_DAT |
diff --git a/arch/score/kernel/process.c b/arch/score/kernel/process.c
index a1519ad3..937115c 100644
--- a/arch/score/kernel/process.c
+++ b/arch/score/kernel/process.c
@@ -69,14 +69,14 @@ void flush_thread(void) {}
  * set up the kernel stack and exception frames for a new process
  */
 int copy_thread(unsigned long clone_flags, unsigned long usp,
-		unsigned long arg, struct task_struct *p)
+		unsigned long arg, struct task_struct *p, int return_to_kernel)
 {
 	struct thread_info *ti = task_thread_info(p);
 	struct pt_regs *childregs = task_pt_regs(p);
 	struct pt_regs *regs = current_pt_regs();
 
 	p->thread.reg0 = (unsigned long) childregs;
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(childregs, 0, sizeof(struct pt_regs));
 		p->thread.reg12 = usp;
 		p->thread.reg13 = arg;
diff --git a/arch/sh/kernel/process_32.c b/arch/sh/kernel/process_32.c
index 2885fc9..c8fdba3 100644
--- a/arch/sh/kernel/process_32.c
+++ b/arch/sh/kernel/process_32.c
@@ -124,7 +124,7 @@ asmlinkage void ret_from_fork(void);
 asmlinkage void ret_from_kernel_thread(void);
 
 int copy_thread(unsigned long clone_flags, unsigned long usp,
-		unsigned long arg, struct task_struct *p)
+		unsigned long arg, struct task_struct *p, int return_to_kernel)
 {
 	struct thread_info *ti = task_thread_info(p);
 	struct pt_regs *childregs;
@@ -145,7 +145,7 @@ int copy_thread(unsigned long clone_flags, unsigned long usp,
 
 	childregs = task_pt_regs(p);
 	p->thread.sp = (unsigned long) childregs;
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(childregs, 0, sizeof(struct pt_regs));
 		p->thread.pc = (unsigned long) ret_from_kernel_thread;
 		childregs->regs[4] = arg;
diff --git a/arch/sh/kernel/process_64.c b/arch/sh/kernel/process_64.c
index e2062e6..31e116a 100644
--- a/arch/sh/kernel/process_64.c
+++ b/arch/sh/kernel/process_64.c
@@ -372,7 +372,7 @@ asmlinkage void ret_from_fork(void);
 asmlinkage void ret_from_kernel_thread(void);
 
 int copy_thread(unsigned long clone_flags, unsigned long usp,
-		unsigned long arg, struct task_struct *p)
+		unsigned long arg, struct task_struct *p, int return_to_kernel)
 {
 	struct pt_regs *childregs;
 
@@ -390,7 +390,7 @@ int copy_thread(unsigned long clone_flags, unsigned long usp,
 	childregs = (struct pt_regs *)(THREAD_SIZE + task_stack_page(p)) - 1;
 	p->thread.sp = (unsigned long) childregs;
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(childregs, 0, sizeof(struct pt_regs));
 		childregs->regs[2] = (unsigned long)arg;
 		childregs->regs[3] = (unsigned long)usp;
diff --git a/arch/sparc/kernel/process_32.c b/arch/sparc/kernel/process_32.c
index c5113c7..327bef8 100644
--- a/arch/sparc/kernel/process_32.c
+++ b/arch/sparc/kernel/process_32.c
@@ -306,7 +306,7 @@ extern void ret_from_fork(void);
 extern void ret_from_kernel_thread(void);
 
 int copy_thread(unsigned long clone_flags, unsigned long sp,
-		unsigned long arg, struct task_struct *p)
+		unsigned long arg, struct task_struct *p, int return_to_kernel)
 {
 	struct thread_info *ti = task_thread_info(p);
 	struct pt_regs *childregs, *regs = current_pt_regs();
@@ -342,7 +342,7 @@ int copy_thread(unsigned long clone_flags, unsigned long sp,
 	ti->ksp = (unsigned long) new_stack;
 	p->thread.kregs = childregs;
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		extern int nwindows;
 		unsigned long psr;
 		memset(new_stack, 0, STACKFRAME_SZ + TRACEREG_SZ);
diff --git a/arch/sparc/kernel/process_64.c b/arch/sparc/kernel/process_64.c
index 46a5964..0dcd4ba 100644
--- a/arch/sparc/kernel/process_64.c
+++ b/arch/sparc/kernel/process_64.c
@@ -617,7 +617,7 @@ asmlinkage long sparc_do_fork(unsigned long clone_flags,
  * Child  -->  %o0 == parents pid, %o1 == 1
  */
 int copy_thread(unsigned long clone_flags, unsigned long sp,
-		unsigned long arg, struct task_struct *p)
+		unsigned long arg, struct task_struct *p, int return_to_kernel)
 {
 	struct thread_info *t = task_thread_info(p);
 	struct pt_regs *regs = current_pt_regs();
@@ -636,7 +636,7 @@ int copy_thread(unsigned long clone_flags, unsigned long sp,
 				       sizeof(struct sparc_stackf));
 	t->fpsaved[0] = 0;
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		memset(child_trap_frame, 0, child_stack_sz);
 		__thread_flag_byte_ptr(t)[TI_FLAG_BYTE_CWP] = 
 			(current_pt_regs()->tstate + 1) & TSTATE_CWP;
diff --git a/arch/tile/kernel/process.c b/arch/tile/kernel/process.c
index b5f30d3..6b24d49 100644
--- a/arch/tile/kernel/process.c
+++ b/arch/tile/kernel/process.c
@@ -100,7 +100,7 @@ void arch_release_thread_info(struct thread_info *info)
 static void save_arch_state(struct thread_struct *t);
 
 int copy_thread(unsigned long clone_flags, unsigned long sp,
-		unsigned long arg, struct task_struct *p)
+		unsigned long arg, struct task_struct *p, int return_to_kernel)
 {
 	struct pt_regs *childregs = task_pt_regs(p);
 	unsigned long ksp;
@@ -126,7 +126,7 @@ int copy_thread(unsigned long clone_flags, unsigned long sp,
 	/* Record the pid of the task that created this one. */
 	p->thread.creator_pid = current->pid;
 
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		/* kernel thread */
 		memset(childregs, 0, sizeof(struct pt_regs));
 		memset(&callee_regs[2], 0,
diff --git a/arch/um/kernel/process.c b/arch/um/kernel/process.c
index 48af59a..40ac5bf 100644
--- a/arch/um/kernel/process.c
+++ b/arch/um/kernel/process.c
@@ -155,7 +155,8 @@ void fork_handler(void)
 }
 
 int copy_thread(unsigned long clone_flags, unsigned long sp,
-		unsigned long arg, struct task_struct * p)
+		unsigned long arg, struct task_struct *p,
+		int return_to_kernel)
 {
 	void (*handler)(void);
 	int kthread = current->flags & PF_KTHREAD;
@@ -163,7 +164,7 @@ int copy_thread(unsigned long clone_flags, unsigned long sp,
 
 	p->thread = (struct thread_struct) INIT_THREAD;
 
-	if (!kthread) {
+	if (!kthread && !return_to_kernel) {
 	  	memcpy(&p->thread.regs.regs, current_pt_regs(),
 		       sizeof(p->thread.regs.regs));
 		PT_REGS_SET_SYSCALL_RETURN(&p->thread.regs, 0);
@@ -182,15 +183,16 @@ int copy_thread(unsigned long clone_flags, unsigned long sp,
 
 	new_thread(task_stack_page(p), &p->thread.switch_buf, handler);
 
-	if (!kthread) {
-		clear_flushed_tls(p);
+	if (kthread || return_to_kernel)
+		return ret;
 
-		/*
-		 * Set a new TLS for the child thread?
-		 */
-		if (clone_flags & CLONE_SETTLS)
-			ret = arch_copy_tls(p);
-	}
+	clear_flushed_tls(p);
+
+	/*
+	 * Set a new TLS for the child thread?
+	 */
+	if (clone_flags & CLONE_SETTLS)
+		ret = arch_copy_tls(p);
 
 	return ret;
 }
diff --git a/arch/unicore32/kernel/process.c b/arch/unicore32/kernel/process.c
index b008e99..159961d 100644
--- a/arch/unicore32/kernel/process.c
+++ b/arch/unicore32/kernel/process.c
@@ -229,14 +229,14 @@ asmlinkage void ret_from_kernel_thread(void) __asm__("ret_from_kernel_thread");
 
 int
 copy_thread(unsigned long clone_flags, unsigned long stack_start,
-	    unsigned long stk_sz, struct task_struct *p)
+	    unsigned long stk_sz, struct task_struct *p, int return_to_kernel)
 {
 	struct thread_info *thread = task_thread_info(p);
 	struct pt_regs *childregs = task_pt_regs(p);
 
 	memset(&thread->cpu_context, 0, sizeof(struct cpu_context_save));
 	thread->cpu_context.sp = (unsigned long)childregs;
-	if (unlikely(p->flags & PF_KTHREAD)) {
+	if (unlikely(p->flags & PF_KTHREAD) || return_to_kernel) {
 		thread->cpu_context.pc = (unsigned long)ret_from_kernel_thread;
 		thread->cpu_context.r4 = stack_start;
 		thread->cpu_context.r5 = stk_sz;
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
diff --git a/arch/xtensa/kernel/process.c b/arch/xtensa/kernel/process.c
index 1c85323..7765634 100644
--- a/arch/xtensa/kernel/process.c
+++ b/arch/xtensa/kernel/process.c
@@ -189,7 +189,8 @@ int arch_dup_task_struct(struct task_struct *dst, struct task_struct *src)
  */
 
 int copy_thread(unsigned long clone_flags, unsigned long usp_thread_fn,
-		unsigned long thread_fn_arg, struct task_struct *p)
+		unsigned long thread_fn_arg, struct task_struct *p,
+		int return_to_kernel)
 {
 	struct pt_regs *childregs = task_pt_regs(p);
 
@@ -203,7 +204,7 @@ int copy_thread(unsigned long clone_flags, unsigned long usp_thread_fn,
 
 	p->thread.sp = (unsigned long)childregs;
 
-	if (!(p->flags & PF_KTHREAD)) {
+	if (!(p->flags & PF_KTHREAD) && !return_to_kernel) {
 		struct pt_regs *regs = current_pt_regs();
 		unsigned long usp = usp_thread_fn ?
 			usp_thread_fn : regs->areg[1];
diff --git a/include/linux/sched.h b/include/linux/sched.h
index a10494a..56401e4 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2612,18 +2612,18 @@ extern void mm_release(struct task_struct *, struct mm_struct *);
 
 #ifdef CONFIG_HAVE_COPY_THREAD_TLS
 extern int copy_thread_tls(unsigned long, unsigned long, unsigned long,
-			struct task_struct *, unsigned long);
+			struct task_struct *, unsigned long, int);
 #else
 extern int copy_thread(unsigned long, unsigned long, unsigned long,
-			struct task_struct *);
+			struct task_struct *, int);
 
 /* Architectures that haven't opted into copy_thread_tls get the tls argument
  * via pt_regs, so ignore the tls argument passed via C. */
 static inline int copy_thread_tls(
 		unsigned long clone_flags, unsigned long sp, unsigned long arg,
-		struct task_struct *p, unsigned long tls)
+		struct task_struct *p, unsigned long tls, int return_to_kernel)
 {
-	return copy_thread(clone_flags, sp, arg, p);
+	return copy_thread(clone_flags, sp, arg, p, return_to_kernel);
 }
 #endif
 extern void flush_thread(void);
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
