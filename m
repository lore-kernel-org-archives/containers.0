From: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Subject: [C/R ARM][PATCH 3/3] c/r: ARM implementation of checkpoint/restart
Date: Sun, 21 Mar 2010 21:06:05 -0400
Message-ID: <1269219965-23923-4-git-send-email-christofferdall__48196.3828242899$1269220033$gmane$org@christofferdall.dk>
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
Cc: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, rmk-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org
List-Id: containers.vger.kernel.org

Implements architecture specific requirements for checkpoint/restart on
ARM. The changes touch almost only c/r related code. Most of the work is
done in arch/arm/checkpoint.c, which implements checkpointing of the CPU
and necessary fields on the thread_info struct.

The ISA version (given by __LINUX_ARM_ARCH__) is checkpointed and verified
against the machine architecture on restart. If they differ, an error is
raised and restart aborted. It should be possible to restart on newer
architectures, but further investigation is warranted.

Regarding ThumbEE, the thumbee_state field on the thread_info is stored
in checkpoints when CONFIG_ARM_THUMBEE and 0 is stored otherwise. If
a value different than 0 is checkpointed and CONFIG_ARM_THUMBEE is not
set on the restore system, the restore is aborted. Feedback on this
implementation is very welcome.

We checkpoint whether the system is running with CONFIG_MMU or not and
require the same configuration for the system on which we restore the
process. It might be possible to allow something more fine-grained,
if it's worth the energy. Input on this item is also very welcome,
specifically from someone who knows the exact meaning of the end_brk
field.

Added support for syscall sys_checkpoint and sys_restart for ARM:
__NR_checkpoint         367
__NR_restart            368


Cc: rmk-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org
Signed-off-by: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 arch/arm/Kconfig                      |    4 +
 arch/arm/include/asm/checkpoint_hdr.h |   71 +++++++++
 arch/arm/include/asm/ptrace.h         |    1 +
 arch/arm/include/asm/unistd.h         |    2 +
 arch/arm/kernel/Makefile              |    1 +
 arch/arm/kernel/calls.S               |    2 +
 arch/arm/kernel/checkpoint.c          |  276 +++++++++++++++++++++++++++++++++
 arch/arm/kernel/signal.c              |    5 +
 arch/arm/kernel/sys_arm.c             |   13 ++
 include/linux/checkpoint_hdr.h        |    2 +
 10 files changed, 377 insertions(+), 0 deletions(-)
 create mode 100644 arch/arm/include/asm/checkpoint_hdr.h
 create mode 100644 arch/arm/kernel/checkpoint.c

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 184a6bd..fe83129 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -94,6 +94,10 @@ config HAVE_LATENCYTOP_SUPPORT
 	depends on !SMP
 	default y
 
+config CHECKPOINT_SUPPORT
+	bool
+	default y
+
 config LOCKDEP_SUPPORT
 	bool
 	default y
diff --git a/arch/arm/include/asm/checkpoint_hdr.h b/arch/arm/include/asm/checkpoint_hdr.h
new file mode 100644
index 0000000..c08a4ae
--- /dev/null
+++ b/arch/arm/include/asm/checkpoint_hdr.h
@@ -0,0 +1,71 @@
+#ifndef __ASM_ARM_CKPT_HDR_H
+#define __ASM_ARM_CKPT_HDR_H
+/*
+ *  Checkpoint/restart - architecture specific headers ARM
+ *
+ *  Copyright (C) 2008-2010 Oren Laadan
+ *  Copyright	  2010	    Christoffer Dall
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#ifndef _CHECKPOINT_CKPT_HDR_H_
+#error asm/checkpoint_hdr.h included directly
+#endif
+
+#include <linux/types.h>
+
+/* ARM structure seen from kernel/userspace */
+#ifdef __KERNEL__
+#include <asm/processor.h>
+#endif
+
+#define CKPT_ARCH_ID	CKPT_ARCH_ARM
+
+/* arch dependent constants */
+#define CKPT_ARCH_NSIG  64
+#define CKPT_TTY_NCC  8
+
+#ifdef __KERNEL__
+
+#include <asm/signal.h>
+#if CKPT_ARCH_NSIG != _NSIG
+#error CKPT_ARCH_NSIG size is wrong per asm/signal.h and asm/checkpoint_hdr.h
+#endif
+
+#include <linux/tty.h>
+#if CKPT_TTY_NCC != NCC
+#error CKPT_TTY_NCC size is wrong per asm-generic/termios.h
+#endif
+
+#endif /* __KERNEL__ */
+
+
+struct ckpt_hdr_header_arch {
+	struct ckpt_hdr h;
+	__u32	linux_arm_arch;
+	__u8	mmu;		/* Checkpointed on mmu system */
+	__u8	oabi_compat;	/* Checkpointed on old ABI compat. system */
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_thread {
+	struct ckpt_hdr h;
+	__u32		syscall;
+	__u32		tp_value;
+	__u32		thumbee_state;
+} __attribute__((aligned(8)));
+
+
+struct ckpt_hdr_cpu {
+	struct ckpt_hdr h;
+	__u32		uregs[18];
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_mm_context {
+	struct ckpt_hdr h;
+	__u32		end_brk;
+} __attribute__((aligned(8)));
+
+#endif /* __ASM_ARM_CKPT_HDR__H */
diff --git a/arch/arm/include/asm/ptrace.h b/arch/arm/include/asm/ptrace.h
index eec6e89..624e5d1 100644
--- a/arch/arm/include/asm/ptrace.h
+++ b/arch/arm/include/asm/ptrace.h
@@ -57,6 +57,7 @@
 #define PSR_C_BIT	0x20000000
 #define PSR_Z_BIT	0x40000000
 #define PSR_N_BIT	0x80000000
+#define PSR_GE_BITS	0x000f0000
 
 /*
  * Groups of PSR bits
diff --git a/arch/arm/include/asm/unistd.h b/arch/arm/include/asm/unistd.h
index f295a6c..7ec526e 100644
--- a/arch/arm/include/asm/unistd.h
+++ b/arch/arm/include/asm/unistd.h
@@ -393,6 +393,8 @@
 #define __NR_perf_event_open		(__NR_SYSCALL_BASE+364)
 #define __NR_recvmmsg			(__NR_SYSCALL_BASE+365)
 #define __NR_eclone			(__NR_SYSCALL_BASE+366)
+#define __NR_checkpoint			(__NR_SYSCALL_BASE+367)
+#define __NR_restart			(__NR_SYSCALL_BASE+368)
 
 /*
  * The following SWIs are ARM private.
diff --git a/arch/arm/kernel/Makefile b/arch/arm/kernel/Makefile
index dd00f74..1669065 100644
--- a/arch/arm/kernel/Makefile
+++ b/arch/arm/kernel/Makefile
@@ -38,6 +38,7 @@ obj-$(CONFIG_ARM_THUMBEE)	+= thumbee.o
 obj-$(CONFIG_KGDB)		+= kgdb.o
 obj-$(CONFIG_ARM_UNWIND)	+= unwind.o
 obj-$(CONFIG_HAVE_TCM)		+= tcm.o
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
 
 obj-$(CONFIG_CRUNCH)		+= crunch.o crunch-bits.o
 AFLAGS_crunch-bits.o		:= -Wa,-mcpu=ep9312
diff --git a/arch/arm/kernel/calls.S b/arch/arm/kernel/calls.S
index 5ef0b03..aefb432 100644
--- a/arch/arm/kernel/calls.S
+++ b/arch/arm/kernel/calls.S
@@ -376,6 +376,8 @@
 		CALL(sys_perf_event_open)
 /* 365 */	CALL(sys_recvmmsg)
 		CALL(sys_eclone_wrapper)
+ 		CALL(sys_checkpoint)
+ 		CALL(sys_restart)
 #ifndef syscalls_counted
 .equ syscalls_padding, ((NR_syscalls + 3) & ~3) - NR_syscalls
 #define syscalls_counted
diff --git a/arch/arm/kernel/checkpoint.c b/arch/arm/kernel/checkpoint.c
new file mode 100644
index 0000000..1c9bb34
--- /dev/null
+++ b/arch/arm/kernel/checkpoint.c
@@ -0,0 +1,276 @@
+/*
+ *  Checkpoint/restart - architecture specific support for ARM
+ *
+ *  Copyright (C) 2008-2010 Oren Laadan
+ *  Copyright (C) 2010	    Christoffer Dall
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+#include <asm/processor.h>
+
+
+#ifdef CONFIG_MMU
+	const u8 ckpt_mmu = 1;
+#else
+	const u8 ckpt_mmu = 0;
+#endif
+
+#ifdef CONFIG_OABI_COMPAT
+	const u8 ckpt_oabi_compat = 1;
+#else
+	const u8 ckpt_oabi_compat = 0;
+#endif
+
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+/* dump the thread_struct of a given task */
+int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	int ret;
+	struct ckpt_hdr_thread *h;
+	struct thread_info *ti = task_thread_info(t);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_THREAD);
+	if (!h)
+		return -ENOMEM;
+
+	/*
+	 * Store the syscall information about the checkpointed process
+	 * as we need to know if the process was doing a syscall (and which)
+	 * during restart.
+	 */
+	h->syscall = ti->syscall;
+
+	/*
+	 * Store remaining thread-specific info.
+	 */
+	h->tp_value = ti->tp_value;
+#ifdef CONFIG_ARM_THUMBEE
+	h->thumbee_state = ti->thumbee_state;
+#else
+	/*
+	 * If restoring on system with ThumbeEE support,
+	 * zero will set ThumbEE state to unused.
+	 */
+	h->thumbee_state = 0;
+#endif
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct pt_regs *regs = task_pt_regs(t);
+
+	memcpy(&h->uregs, regs, sizeof(h->uregs));
+
+	/*
+	 * for checkpoint in process context (from within a container),
+	 * the actual syscall is taking place at this very moment; so
+	 * we (optimistically) subtitute the future return value (0) of
+	 * this syscall into r0, so that upon restart it will
+	 * succeed (or it will endlessly retry checkpoint...)
+	 */
+	if (t == current)
+		h->ARM_r0 = 0;
+}
+
+/* dump the cpu state and registers of a given task */
+int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_cpu *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CPU);
+	if (!h)
+		return -ENOMEM;
+
+	save_cpu_regs(h, t);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int checkpoint_write_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *arch_hdr;
+	int ret;
+
+	arch_hdr = ckpt_hdr_get_type(ctx, sizeof(*arch_hdr),
+				     CKPT_HDR_HEADER_ARCH);
+	if (!arch_hdr)
+		return -ENOMEM;
+
+	arch_hdr->linux_arm_arch = __LINUX_ARM_ARCH__;
+	arch_hdr->mmu = ckpt_mmu;
+	arch_hdr->oabi_compat = ckpt_oabi_compat;
+
+	ret = ckpt_write_obj(ctx, &arch_hdr->h);
+	ckpt_hdr_put(ctx, arch_hdr);
+
+	return ret;
+}
+
+/* dump the mm->context state */
+int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct ckpt_hdr_mm_context *h;
+	int ret = 0;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_MM_CONTEXT);
+	if (!h)
+		return -ENOMEM;
+
+#ifdef CONFIG_MMU
+	/*
+	 * We do not checkpoint kvm_seq as we do not know of any generally
+	 * exported functionality which would associate an ioremapped VMA
+	 * with a task. A driver might use this functionality, but should
+	 * implement its own checkpoint functionality to deal with this.
+	 */
+#else
+	h->end_brk = mm->context.end_brk;
+#endif
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/**************************************************************************
+ * Restart
+ */
+
+/* read the thread_struct into the current task */
+int restore_thread(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_thread *h;
+	int ret = 0;
+	struct thread_info *ti = task_thread_info(current);
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_THREAD);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ti->syscall = h->syscall;
+	ti->tp_value = h->tp_value;
+
+#ifdef CONFIG_ARM_THUMBEE
+	/*
+	 * If the checkpoint system did not support ThumbEE, this field
+	 * will be zero, equivalent to unused ThumbEE state.
+	 */
+	h->thumbee_state = ti->thumbee_state;
+#else
+	if (ti->thumbee_state != 0) {
+		ret = -EINVAL;
+		ckpt_err(ctx, ret, "Checkpoint had ThumbEE state but "
+				   "ARM_THUMBEE not configured.");
+	}
+#endif
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int load_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	int i;
+	struct pt_regs *regs = task_pt_regs(t);
+
+	memcpy(regs, &h->uregs, sizeof(struct pt_regs));
+
+	for (i = 0; i < 16; i++)
+		regs->uregs[i] = h->uregs[i];
+
+	/*
+	 * Restore only user-writable bits on the CPSR
+	 */
+	regs->ARM_cpsr = regs->ARM_cpsr |
+			 (h->ARM_cpsr & (PSR_N_BIT | PSR_Z_BIT |
+					 PSR_C_BIT | PSR_V_BIT |
+					 PSR_V_BIT | PSR_Q_BIT |
+					 PSR_E_BIT | PSR_GE_BITS));
+	regs->ARM_ORIG_r0 = h->ARM_ORIG_r0;
+
+	return 0;
+}
+
+/* read the cpu state and registers for the current task */
+int restore_cpu(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_cpu *h;
+	struct task_struct *t = current;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CPU);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = load_cpu_regs(h, t);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int restore_read_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *arch_hdr;
+	int ret = -EINVAL;
+
+	arch_hdr = ckpt_read_obj_type(ctx, sizeof(*arch_hdr),
+				      CKPT_HDR_HEADER_ARCH);
+	if (IS_ERR(arch_hdr))
+		return PTR_ERR(arch_hdr);
+
+	if (arch_hdr->linux_arm_arch != __LINUX_ARM_ARCH__) {
+		ckpt_err(ctx, ret, "incompatible ARM architecture versions");
+		goto out;
+	}
+
+	/* TODO: Maybe compatibility can be more fine-grained */
+	if (arch_hdr->mmu != ckpt_mmu) {
+		ckpt_err(ctx, ret, "checkpoint %s MMU, restore %s MMU",
+			arch_hdr->mmu ? "with" : "without",
+			ckpt_mmu ? "with" : "without");
+		goto out;
+	}
+
+	ret = 0;
+
+	if (arch_hdr->oabi_compat && !ckpt_oabi_compat) {
+		ckpt_msg(ctx, "warning: process may have used old ABI. "
+			      "CONFIG_OABI_COMPAT not set.");
+	}
+
+out:
+	ckpt_hdr_put(ctx, arch_hdr);
+	return ret;
+}
+
+int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct ckpt_hdr_mm_context *h;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_MM_CONTEXT);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+#if !CONFIG_MMU
+	mm->context.end_brk = h->end_brk;
+#endif
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/arch/arm/kernel/signal.c b/arch/arm/kernel/signal.c
index f695239..b42c39a 100644
--- a/arch/arm/kernel/signal.c
+++ b/arch/arm/kernel/signal.c
@@ -688,6 +688,11 @@ static void do_signal(struct pt_regs *regs)
 	single_step_set(current);
 }
 
+int task_has_saved_sigmask(struct task_struct *task)
+{
+	return !!(task_thread_info(task)->flags & _TIF_RESTORE_SIGMASK);
+}
+
 asmlinkage void
 do_notify_resume(struct pt_regs *regs, unsigned int thread_flags)
 {
diff --git a/arch/arm/kernel/sys_arm.c b/arch/arm/kernel/sys_arm.c
index fd8199d..eb178ad 100644
--- a/arch/arm/kernel/sys_arm.c
+++ b/arch/arm/kernel/sys_arm.c
@@ -27,6 +27,7 @@
 #include <linux/file.h>
 #include <linux/ipc.h>
 #include <linux/uaccess.h>
+#include <linux/checkpoint.h>
 
 struct mmap_arg_struct {
 	unsigned long addr;
@@ -295,3 +296,15 @@ asmlinkage long sys_arm_fadvise64_64(int fd, int advice,
 {
 	return sys_fadvise64_64(fd, offset, len, advice);
 }
+
+asmlinkage long sys_checkpoint(unsigned long pid, unsigned long fd,
+			       unsigned long flags, unsigned long logfd)
+{
+	return do_sys_checkpoint(pid, fd, flags, logfd);
+}
+
+asmlinkage long sys_restart(unsigned long pid, unsigned long fd,
+			    unsigned long flags, unsigned long logfd)
+{
+	return do_sys_restart(pid, fd, flags, logfd);
+}
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 41412d1..8309a3b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -202,6 +202,8 @@ enum {
 #define CKPT_ARCH_PPC32 CKPT_ARCH_PPC32
 	CKPT_ARCH_PPC64,
 #define CKPT_ARCH_PPC64 CKPT_ARCH_PPC64
+	CKPT_ARCH_ARM,
+#define CKPT_ARCH_ARM CKPT_ARCH_ARM
 };
 
 /* shared objrects (objref) */
-- 
1.5.6.5
