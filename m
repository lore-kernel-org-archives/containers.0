From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 1/2] c/r: [x86_32] sys_restore to use ptregs prototype
Date: Sun,  6 Dec 2009 15:31:07 -0500
Message-ID: <1260131469-2917-2-git-send-email-orenl@cs.columbia.edu>
References: <1260131469-2917-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1260131469-2917-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Similar to other select syscalls (fork, clone, execve), sys_restart
needs to access the pt_regs structure, so that it can modify it to
restore the original state from the time of the checkpoint.

(This is less of an issue for x86-32, however is required for those
architectures that otherwise save/restore partial state (e.g. not all
registers) during syscall entry/exit, like x86-64.

This patch prepares to support c/r on x86-64, specifically:

* Changes the syscall prototype and definition to accept the pt_regs
  struct as an argument (into %eax register).

* Move arch/x86/mm/checkpoint*.c to arch/x86/kernel/...

* Split 32bit-dependent part of arch/x86/kernel/checkpoint.c into a
  new arch/x86/kernel/checkpoint_32.c

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 arch/x86/include/asm/syscalls.h      |    5 +
 arch/x86/kernel/Makefile             |    8 +
 arch/x86/{mm => kernel}/checkpoint.c |  293 +++++++++-------------------------
 arch/x86/kernel/checkpoint_32.c      |  191 ++++++++++++++++++++++
 arch/x86/kernel/entry_32.S           |    3 +
 arch/x86/kernel/syscall_table_32.S   |    2 +-
 arch/x86/mm/Makefile                 |    2 -
 checkpoint/sys.c                     |    5 +-
 include/linux/checkpoint.h           |    2 +
 include/linux/syscalls.h             |    2 -
 10 files changed, 288 insertions(+), 225 deletions(-)
 rename arch/x86/{mm => kernel}/checkpoint.c (77%)
 create mode 100644 arch/x86/kernel/checkpoint_32.c

diff --git a/arch/x86/include/asm/syscalls.h b/arch/x86/include/asm/syscalls.h
index 2cadb8e..1079447 100644
--- a/arch/x86/include/asm/syscalls.h
+++ b/arch/x86/include/asm/syscalls.h
@@ -43,6 +43,11 @@ int sys_clone(struct pt_regs *);
 int sys_eclone(struct pt_regs *);
 int sys_execve(struct pt_regs *);
 
+/* kernel/checkpoint_32.c */
+#ifdef CONFIG_CHECKPOINT
+long sys_restart(struct pt_regs *);
+#endif
+
 /* kernel/signal.c */
 asmlinkage int sys_sigsuspend(int, int, old_sigset_t);
 asmlinkage int sys_sigaction(int, const struct old_sigaction __user *,
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index d8e5d0c..2821fd6 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -117,6 +117,14 @@ obj-$(CONFIG_X86_CHECK_BIOS_CORRUPTION) += check.o
 
 obj-$(CONFIG_SWIOTLB)			+= pci-swiotlb.o
 
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
+
+###
+# 32 bit specific files
+ifeq ($(CONFIG_X86_32),y)
+	obj-$(CONFIG_CHECKPOINT)	+= checkpoint_32.o
+endif
+
 ###
 # 64 bit specific files
 ifeq ($(CONFIG_X86_64),y)
diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/kernel/checkpoint.c
similarity index 77%
rename from arch/x86/mm/checkpoint.c
rename to arch/x86/kernel/checkpoint.c
index 2752fdf..fbe9521 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/kernel/checkpoint.c
@@ -18,59 +18,11 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
-/*
- * helpers to encode/decode/validate registers/segments/eflags
- */
-
-static int check_eflags(__u32 eflags)
-{
-#define X86_EFLAGS_CKPT_MASK  \
-	(X86_EFLAGS_CF | X86_EFLAGS_PF | X86_EFLAGS_AF | X86_EFLAGS_ZF | \
-	 X86_EFLAGS_SF | X86_EFLAGS_TF | X86_EFLAGS_DF | X86_EFLAGS_OF | \
-	 X86_EFLAGS_NT | X86_EFLAGS_AC | X86_EFLAGS_ID | X86_EFLAGS_RF)
-
-	if ((eflags & ~X86_EFLAGS_CKPT_MASK) != (X86_EFLAGS_IF | 0x2))
-		return 0;
-	return 1;
-}
-
-static void restore_eflags(struct pt_regs *regs, __u32 eflags)
-{
-	/*
-	 * A task may have had X86_EFLAGS_RF set at checkpoint, .e.g:
-	 * 1) It ran in a KVM guest, and the guest was being debugged,
-	 * 2) The kernel was debugged using kgbd,
-	 * 3) From Intel's manual: "When calling an event handler,
-	 *    Intel 64 and IA-32 processors establish the value of the
-	 *    RF flag in the EFLAGS image pushed on the stack:
-	 *  - For any fault-class exception except a debug exception
-	 *    generated in response to an instruction breakpoint, the
-	 *    value pushed for RF is 1.
-	 *  - For any interrupt arriving after any iteration of a
-	 *    repeated string instruction but the last iteration, the
-	 *    value pushed for RF is 1.
-	 *  - For any trap-class exception generated by any iteration
-	 *    of a repeated string instruction but the last iteration,
-	 *    the value pushed for RF is 1.
-	 *  - For other cases, the value pushed for RF is the value
-	 *    that was in EFLAG.RF at the time the event handler was
-	 *    called.
-	 *  [from: http://www.intel.com/Assets/PDF/manual/253668.pdf]
-	 *
-	 * The RF flag may be set in EFLAGS by the hardware, or by
-	 * kvm/kgdb, or even by the user with ptrace or by setting a
-	 * suitable context when returning from a signal handler.
-	 *
-	 * Therefore, on restart we (1) prserve X86_EFLAGS_RF from
-	 * checkpoint time, and (2) preserve a X86_EFLAGS_RF of the
-	 * restarting process if it already exists on saved EFLAGS.
-	 * Disable preemption to protect EFLAG test-and-change.
-	 */
-	preempt_disable();
-	eflags |= (regs->flags & X86_EFLAGS_RF);
-	regs->flags = eflags;
-	preempt_enable();
-}
+extern int check_segment(__u16 seg);
+extern __u16 encode_segment(unsigned short seg);
+extern unsigned short decode_segment(__u16 seg);
+extern void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t);
+extern int load_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t);
 
 static int check_tls(struct desc_struct *desc)
 {
@@ -81,70 +33,6 @@ static int check_tls(struct desc_struct *desc)
 	return 1;
 }
 
-static int check_segment(__u16 seg)
-{
-	int ret = 0;
-
-	switch (seg) {
-	case CKPT_X86_SEG_NULL:
-	case CKPT_X86_SEG_USER32_CS:
-	case CKPT_X86_SEG_USER32_DS:
-		return 1;
-	}
-	if (seg & CKPT_X86_SEG_TLS) {
-		seg &= ~CKPT_X86_SEG_TLS;
-		if (seg <= GDT_ENTRY_TLS_MAX - GDT_ENTRY_TLS_MIN)
-			ret = 1;
-	} else if (seg & CKPT_X86_SEG_LDT) {
-		seg &= ~CKPT_X86_SEG_LDT;
-		if (seg <= 0x1fff)
-			ret = 1;
-	}
-	return ret;
-}
-
-static __u16 encode_segment(unsigned short seg)
-{
-	if (seg == 0)
-		return CKPT_X86_SEG_NULL;
-	BUG_ON((seg & 3) != 3);
-
-	if (seg == __USER_CS)
-		return CKPT_X86_SEG_USER32_CS;
-	if (seg == __USER_DS)
-		return CKPT_X86_SEG_USER32_DS;
-
-	if (seg & 4)
-		return CKPT_X86_SEG_LDT | (seg >> 3);
-
-	seg >>= 3;
-	if (GDT_ENTRY_TLS_MIN <= seg && seg <= GDT_ENTRY_TLS_MAX)
-		return CKPT_X86_SEG_TLS | (seg - GDT_ENTRY_TLS_MIN);
-
-	printk(KERN_ERR "c/r: (decode) bad segment %#hx\n", seg);
-	BUG();
-}
-
-static unsigned short decode_segment(__u16 seg)
-{
-	if (seg == CKPT_X86_SEG_NULL)
-		return 0;
-	if (seg == CKPT_X86_SEG_USER32_CS)
-		return __USER_CS;
-	if (seg == CKPT_X86_SEG_USER32_DS)
-		return __USER_DS;
-
-	if (seg & CKPT_X86_SEG_TLS) {
-		seg &= ~CKPT_X86_SEG_TLS;
-		return ((GDT_ENTRY_TLS_MIN + seg) << 3) | 3;
-	}
-	if (seg & CKPT_X86_SEG_LDT) {
-		seg &= ~CKPT_X86_SEG_LDT;
-		return (seg << 3) | 7;
-	}
-	BUG();
-}
-
 #define CKPT_X86_TIF_UNSUPPORTED   (_TIF_SECCOMP | _TIF_IO_BITMAP)
 
 /**************************************************************************
@@ -153,10 +41,12 @@ static unsigned short decode_segment(__u16 seg)
 
 static int may_checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
 {
+#ifdef CONFIG_X86_32
 	if (t->thread.vm86_info) {
 		ckpt_err(ctx, -EBUSY, "%(T)Task in VM86 mode\n");
 		return -EBUSY;
 	}
+#endif
 	if (task_thread_info(t)->flags & CKPT_X86_TIF_UNSUPPORTED) {
 		ckpt_err(ctx, -EBUSY, "%(T)Bad thread info flags %#lx\n",
 			 task_thread_info(t)->flags);
@@ -195,64 +85,10 @@ int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
-#ifdef CONFIG_X86_32
-
-static void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
-{
-	struct thread_struct *thread = &t->thread;
-	struct pt_regs *regs = task_pt_regs(t);
-	unsigned long _gs;
-
-	h->bp = regs->bp;
-	h->bx = regs->bx;
-	h->ax = regs->ax;
-	h->cx = regs->cx;
-	h->dx = regs->dx;
-	h->si = regs->si;
-	h->di = regs->di;
-	h->orig_ax = regs->orig_ax;
-	h->ip = regs->ip;
-
-	h->flags = regs->flags;
-	h->sp = regs->sp;
-
-	h->cs = encode_segment(regs->cs);
-	h->ss = encode_segment(regs->ss);
-	h->ds = encode_segment(regs->ds);
-	h->es = encode_segment(regs->es);
-
-	/*
-	 * for checkpoint in process context (from within a container)
-	 * the GS segment register should be saved from the hardware;
-	 * otherwise it is already saved on the thread structure
-	 */
-	if (t == current)
-		_gs = get_user_gs(regs);
-	else
-		_gs = thread->gs;
-
-	h->fsindex = encode_segment(regs->fs);
-	h->gsindex = encode_segment(_gs);
-
-	/*
-	 * for checkpoint in process context (from within a container),
-	 * the actual syscall is taking place at this very moment; so
-	 * we (optimistically) subtitute the future return value (0) of
-	 * this syscall into the orig_eax, so that upon restart it will
-	 * succeed (or it will endlessly retry checkpoint...)
-	 */
-	if (t == current) {
-		BUG_ON(h->orig_ax < 0);
-		h->ax = 0;
-	}
-}
-
 static void save_cpu_debug(struct ckpt_hdr_cpu *h, struct task_struct *t)
 {
 	struct thread_struct *thread = &t->thread;
 
-	/* debug regs */
-
 	/*
 	 * for checkpoint in process context (from within a container),
 	 * get the actual registers; otherwise get the saved values.
@@ -315,8 +151,6 @@ static int checkpoint_cpu_fpu(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
-#endif	/* CONFIG_X86_32 */
-
 /* dump the cpu state and registers of a given task */
 int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
 {
@@ -438,6 +272,13 @@ int restore_thread(struct ckpt_ctx *ctx)
 	load_TLS(thread, cpu);
 	put_cpu();
 
+#if defined(CONFIG_X86_64) && defined(CONFIG_COMPAT)
+	if (h->thread_info_flags & _TIF_IA32)
+		set_thread_flag(TIF_IA32);
+	else
+		clear_thread_flag(TIF_IA32);
+#endif
+
 	/* TODO: restore TIF flags as necessary (e.g. TIF_NOTSC) */
 
 	ret = 0;
@@ -446,49 +287,6 @@ int restore_thread(struct ckpt_ctx *ctx)
 	return ret;
 }
 
-#ifdef CONFIG_X86_32
-
-static int load_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
-{
-	struct thread_struct *thread = &t->thread;
-	struct pt_regs *regs = task_pt_regs(t);
-
-	if (!check_eflags(h->flags))
-		return -EINVAL;
-	if (h->cs == CKPT_X86_SEG_NULL)
-		return -EINVAL;
-	if (!check_segment(h->cs) || !check_segment(h->ds) ||
-	    !check_segment(h->es) || !check_segment(h->ss) ||
-	    !check_segment(h->fsindex) || !check_segment(h->gsindex))
-		return -EINVAL;
-
-	regs->bp = h->bp;
-	regs->bx = h->bx;
-	regs->ax = h->ax;
-	regs->cx = h->cx;
-	regs->dx = h->dx;
-	regs->si = h->si;
-	regs->di = h->di;
-	regs->orig_ax = h->orig_ax;
-	regs->ip = h->ip;
-
-	restore_eflags(regs, h->flags);
-	regs->sp = h->sp;
-
-	regs->ds = decode_segment(h->ds);
-	regs->es = decode_segment(h->es);
-	regs->cs = decode_segment(h->cs);
-	regs->ss = decode_segment(h->ss);
-
-	regs->fs = decode_segment(h->fsindex);
-	regs->gs = decode_segment(h->gsindex);
-
-	thread->gs = regs->gs;
-	lazy_load_gs(regs->gs);
-
-	return 0;
-}
-
 static int load_cpu_debug(struct ckpt_hdr_cpu *h, struct task_struct *t)
 {
 	int ret;
@@ -548,7 +346,65 @@ static int restore_cpu_fpu(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
-#endif	/* CONFIG_X86_32 */
+static int check_eflags(__u32 eflags)
+{
+#define X86_EFLAGS_CKPT_MASK  \
+	(X86_EFLAGS_CF | X86_EFLAGS_PF | X86_EFLAGS_AF | X86_EFLAGS_ZF | \
+	 X86_EFLAGS_SF | X86_EFLAGS_TF | X86_EFLAGS_DF | X86_EFLAGS_OF | \
+	 X86_EFLAGS_NT | X86_EFLAGS_AC | X86_EFLAGS_ID | X86_EFLAGS_RF)
+
+	if ((eflags & ~X86_EFLAGS_CKPT_MASK) != (X86_EFLAGS_IF | 0x2))
+		return 0;
+	return 1;
+}
+
+static void restore_eflags(struct pt_regs *regs, __u32 eflags)
+{
+	/*
+	 * A task may have had X86_EFLAGS_RF set at checkpoint, .e.g:
+	 * 1) It ran in a KVM guest, and the guest was being debugged,
+	 * 2) The kernel was debugged using kgbd,
+	 * 3) From Intel's manual: "When calling an event handler,
+	 *    Intel 64 and IA-32 processors establish the value of the
+	 *    RF flag in the EFLAGS image pushed on the stack:
+	 *  - For any fault-class exception except a debug exception
+	 *    generated in response to an instruction breakpoint, the
+	 *    value pushed for RF is 1.
+	 *  - For any interrupt arriving after any iteration of a
+	 *    repeated string instruction but the last iteration, the
+	 *    value pushed for RF is 1.
+	 *  - For any trap-class exception generated by any iteration
+	 *    of a repeated string instruction but the last iteration,
+	 *    the value pushed for RF is 1.
+	 *  - For other cases, the value pushed for RF is the value
+	 *    that was in EFLAG.RF at the time the event handler was
+	 *    called.
+	 *  [from: http://www.intel.com/Assets/PDF/manual/253668.pdf]
+	 *
+	 * The RF flag may be set in EFLAGS by the hardware, or by
+	 * kvm/kgdb, or even by the user with ptrace or by setting a
+	 * suitable context when returning from a signal handler.
+	 *
+	 * Therefore, on restart we (1) prserve X86_EFLAGS_RF from
+	 * checkpoint time, and (2) preserve a X86_EFLAGS_RF of the
+	 * restarting process if it already exists on saved EFLAGS.
+	 * Disable preemption to protect EFLAG test-and-change.
+	 */
+	preempt_disable();
+	eflags |= (regs->flags & X86_EFLAGS_RF);
+	regs->flags = eflags;
+	preempt_enable();
+}
+
+static int load_cpu_eflags(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct pt_regs *regs = task_pt_regs(t);
+
+	if (!check_eflags(h->flags))
+		return -EINVAL;
+	restore_eflags(regs, h->flags);
+	return 0;
+}
 
 /* read the cpu state and registers for the current task */
 int restore_cpu(struct ckpt_ctx *ctx)
@@ -566,6 +422,9 @@ int restore_cpu(struct ckpt_ctx *ctx)
 	ret = load_cpu_regs(h, t);
 	if (ret < 0)
 		goto out;
+	ret = load_cpu_eflags(h, t);
+	if (ret < 0)
+		goto out;
 	ret = load_cpu_debug(h, t);
 	if (ret < 0)
 		goto out;
diff --git a/arch/x86/kernel/checkpoint_32.c b/arch/x86/kernel/checkpoint_32.c
new file mode 100644
index 0000000..d5ea6a0
--- /dev/null
+++ b/arch/x86/kernel/checkpoint_32.c
@@ -0,0 +1,191 @@
+/*
+ *  Checkpoint/restart - architecture specific support for x86_32
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
+#include <asm/desc.h>
+#include <asm/i387.h>
+#include <asm/elf.h>
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/*
+ * sys_restart needs to access and modify the pt_regs structure to
+ * restore the original state from the time of the checkpoint.
+ */
+long sys_restart(struct pt_regs *regs)
+{
+	unsigned long flags;
+	int fd, logfd;
+	pid_t pid;
+
+	pid = regs->bx;
+	fd = regs->cx;
+	flags = regs->dx;
+	logfd = regs->di;
+
+	return do_sys_restart(pid, fd, flags, logfd);
+}
+
+/* helpers to encode/decode/validate segments */
+
+static int check_segment(__u16 seg)
+{
+	int ret = 0;
+
+	switch (seg) {
+	case CKPT_X86_SEG_NULL:
+	case CKPT_X86_SEG_USER32_CS:
+	case CKPT_X86_SEG_USER32_DS:
+		return 1;
+	}
+	if (seg & CKPT_X86_SEG_TLS) {
+		seg &= ~CKPT_X86_SEG_TLS;
+		if (seg <= GDT_ENTRY_TLS_MAX - GDT_ENTRY_TLS_MIN)
+			ret = 1;
+	} else if (seg & CKPT_X86_SEG_LDT) {
+		seg &= ~CKPT_X86_SEG_LDT;
+		if (seg <= 0x1fff)
+			ret = 1;
+	}
+	return ret;
+}
+
+static __u16 encode_segment(unsigned short seg)
+{
+	if (seg == 0)
+		return CKPT_X86_SEG_NULL;
+	BUG_ON((seg & 3) != 3);
+
+	if (seg == __USER_CS)
+		return CKPT_X86_SEG_USER32_CS;
+	if (seg == __USER_DS)
+		return CKPT_X86_SEG_USER32_DS;
+
+	if (seg & 4)
+		return CKPT_X86_SEG_LDT | (seg >> 3);
+
+	seg >>= 3;
+	if (GDT_ENTRY_TLS_MIN <= seg && seg <= GDT_ENTRY_TLS_MAX)
+		return CKPT_X86_SEG_TLS | (seg - GDT_ENTRY_TLS_MIN);
+
+	printk(KERN_ERR "c/r: (decode) bad segment %#hx\n", seg);
+	BUG();
+}
+
+static unsigned short decode_segment(__u16 seg)
+{
+	if (seg == CKPT_X86_SEG_NULL)
+		return 0;
+	if (seg == CKPT_X86_SEG_USER32_CS)
+		return __USER_CS;
+	if (seg == CKPT_X86_SEG_USER32_DS)
+		return __USER_DS;
+
+	if (seg & CKPT_X86_SEG_TLS) {
+		seg &= ~CKPT_X86_SEG_TLS;
+		return ((GDT_ENTRY_TLS_MIN + seg) << 3) | 3;
+	}
+	if (seg & CKPT_X86_SEG_LDT) {
+		seg &= ~CKPT_X86_SEG_LDT;
+		return (seg << 3) | 7;
+	}
+	BUG();
+}
+
+void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
+	unsigned long _gs;
+
+	h->bp = regs->bp;
+	h->bx = regs->bx;
+	h->ax = regs->ax;
+	h->cx = regs->cx;
+	h->dx = regs->dx;
+	h->si = regs->si;
+	h->di = regs->di;
+	h->orig_ax = regs->orig_ax;
+	h->ip = regs->ip;
+
+	h->flags = regs->flags;
+	h->sp = regs->sp;
+
+	h->cs = encode_segment(regs->cs);
+	h->ss = encode_segment(regs->ss);
+	h->ds = encode_segment(regs->ds);
+	h->es = encode_segment(regs->es);
+
+	/*
+	 * for checkpoint in process context (from within a container)
+	 * the GS segment register should be saved from the hardware;
+	 * otherwise it is already saved on the thread structure
+	 */
+	if (t == current)
+		_gs = get_user_gs(regs);
+	else
+		_gs = thread->gs;
+
+	h->fsindex = encode_segment(regs->fs);
+	h->gsindex = encode_segment(_gs);
+
+	/*
+	 * for checkpoint in process context (from within a container),
+	 * the actual syscall is taking place at this very moment; so
+	 * we (optimistically) subtitute the future return value (0) of
+	 * this syscall into the orig_eax, so that upon restart it will
+	 * succeed (or it will endlessly retry checkpoint...)
+	 */
+	if (t == current) {
+		BUG_ON(h->orig_ax < 0);
+		h->ax = 0;
+	}
+}
+
+int load_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
+
+	if (h->cs == CKPT_X86_SEG_NULL)
+		return -EINVAL;
+	if (!check_segment(h->cs) || !check_segment(h->ds) ||
+	    !check_segment(h->es) || !check_segment(h->ss) ||
+	    !check_segment(h->fsindex) || !check_segment(h->gsindex))
+		return -EINVAL;
+
+	regs->bp = h->bp;
+	regs->bx = h->bx;
+	regs->ax = h->ax;
+	regs->cx = h->cx;
+	regs->dx = h->dx;
+	regs->si = h->si;
+	regs->di = h->di;
+	regs->orig_ax = h->orig_ax;
+	regs->ip = h->ip;
+
+	regs->sp = h->sp;
+
+	regs->ds = decode_segment(h->ds);
+	regs->es = decode_segment(h->es);
+	regs->cs = decode_segment(h->cs);
+	regs->ss = decode_segment(h->ss);
+
+	regs->fs = decode_segment(h->fsindex);
+	regs->gs = decode_segment(h->gsindex);
+
+	thread->gs = regs->gs;
+	lazy_load_gs(regs->gs);
+
+	return 0;
+}
diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
index 7e7f3c8..ecefd09 100644
--- a/arch/x86/kernel/entry_32.S
+++ b/arch/x86/kernel/entry_32.S
@@ -726,6 +726,9 @@ PTREGSCALL(sigreturn)
 PTREGSCALL(rt_sigreturn)
 PTREGSCALL(vm86)
 PTREGSCALL(vm86old)
+#ifdef CONFIG_CHECKPOINT
+PTREGSCALL(restart)
+#endif
 
 .macro FIXUP_ESPFIX_STACK
 /*
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index a1bc7f7..1ca053e 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -338,4 +338,4 @@ ENTRY(sys_call_table)
 	.long sys_perf_event_open
 	.long ptregs_eclone
 	.long sys_checkpoint
-	.long sys_restart
+	.long ptregs_restart
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 735c0b2..06630d2 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -26,5 +26,3 @@ obj-$(CONFIG_K8_NUMA)		+= k8topology_64.o
 obj-$(CONFIG_ACPI_NUMA)		+= srat_$(BITS).o
 
 obj-$(CONFIG_MEMTEST)		+= memtest.o
-
-obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index afcfa1e..89056d6 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -648,7 +648,7 @@ SYSCALL_DEFINE4(checkpoint, pid_t, pid, int, fd,
 }
 
 /**
- * sys_restart - restart a container
+ * do_sys_restart - restart a container
  * @pid: pid of task root (in coordinator's namespace), or 0
  * @fd: file from which read the checkpoint image
  * @flags: restart operation flags
@@ -657,8 +657,7 @@ SYSCALL_DEFINE4(checkpoint, pid_t, pid, int, fd,
  * Returns negative value on error, or otherwise returns in the realm
  * of the original checkpoint
  */
-SYSCALL_DEFINE4(restart, pid_t, pid, int, fd,
-		unsigned long, flags, int, logfd)
+long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd)
 {
 	struct ckpt_ctx *ctx = NULL;
 	long ret;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index c6c8d56..d81c59c 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -60,6 +60,8 @@
 #define CKPT_LSM_INFO_LEN 200
 #define CKPT_LSM_STRING_MAX 1024
 
+extern long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd);
+
 extern int walk_task_subtree(struct task_struct *task,
 			     int (*func)(struct task_struct *, void *),
 			     void *data);
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 9ed192f..264a02e 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -874,8 +874,6 @@ asmlinkage long sys_ppoll(struct pollfd __user *, unsigned int,
 			  size_t);
 asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags,
 			       int logfd);
-asmlinkage long sys_restart(pid_t pid, int fd, unsigned long flags,
-			    int logfd);
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
-- 
1.6.3.3
