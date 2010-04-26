From: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Subject: [C/R ARM v2][PATCH 3/3] c/r: ARM implementation of checkpoint/restart
Date: Mon, 26 Apr 2010 17:43:43 -0400
Message-ID: <1272318223-28438-4-git-send-email-christofferdall__48548.5552032062$1272499525$gmane$org@christofferdall.dk>
References: <1272318223-28438-1-git-send-email-christofferdall@christofferdall.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272318223-28438-1-git-send-email-christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
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

The following restrictions are enforced:
----------------------------------------

The CPU architecture (given by cpu_architecture()) is checkpointed and
verified against the CPU architecture on restart. We require that the
restart architecture must be at least as new as the checkpoint
architecture.

We checkpoint whether the system is running with CONFIG_MMU or not and
require the same configuration for the system on which we restore the
process. As discussed in the original post of these patches, it should be
possible to checkpoint a non-mmu process and restart it on an mmu system.
However, the implementation and testing is left for someone with knowledge
about both configurations. (See
https://lists.linux-foundation.org/pipermail/containers/2010-March/023996.html)

Obviously, processes using the old ARM ABI cannot be restarted on kernels
configured with CONFIG_AEABI and without CONFIG_OABI_COMPAT. The same goes
for restarting processes using AEABI on kernels configured without
CONFIG_AEABI. Unfortunately, if the kernel on which we checkpoint is
configured with CONFIG_OABI_COMPAT there is no way of knowing which ABI the
process actually uses. Therefore, we raise warnings on restart whenever in
doubt and continue with the restart process optimistically.

Other:
------
Regarding ThumbEE, the thumbee_state field on the thread_info is stored
in checkpoints when CONFIG_ARM_THUMBEE and 0 is stored otherwise. If
a value different than 0 is checkpointed and CONFIG_ARM_THUMBEE is not
set on the restore system, the restore is aborted. Feedback on this
implementation is very welcome.

Added support for syscall sys_checkpoint and sys_restart for ARM:
__NR_checkpoint         367
__NR_restart            368

Changelog[v2]:
	- Changed __LINUX_ARM_ARCH__ to cpu_architecture()
	- Support restart on newer ISA versions
	- More thorough checking of CONFIG_EABI and CONFIG_OABI_COMPAT
	  between checkpoint and restart kernels.
	- Simplified code by inlining small routines

Cc: rmk-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org
Signed-off-by: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 arch/arm/Kconfig                      |    4 +
 arch/arm/include/asm/checkpoint_hdr.h |   72 ++++++++
 arch/arm/include/asm/ptrace.h         |    1 +
 arch/arm/include/asm/unistd.h         |    2 +
 arch/arm/kernel/Makefile              |    1 +
 arch/arm/kernel/calls.S               |    2 +
 arch/arm/kernel/checkpoint.c          |  302 +++++++++++++++++++++++++++++++++
 arch/arm/kernel/signal.c              |    5 +
 arch/arm/kernel/sys_arm.c             |   13 ++
 include/linux/checkpoint_hdr.h        |    2 +
 10 files changed, 404 insertions(+), 0 deletions(-)
 create mode 100644 arch/arm/include/asm/checkpoint_hdr.h
 create mode 100644 arch/arm/kernel/checkpoint.c

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index c5408bf..14c7c84 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -100,6 +100,10 @@ config HAVE_LATENCYTOP_SUPPORT
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
index 0000000..38e8446
--- /dev/null
+++ b/arch/arm/include/asm/checkpoint_hdr.h
@@ -0,0 +1,72 @@
+#ifndef __ASM_ARM_CKPT_HDR_H
+#define __ASM_ARM_CKPT_HDR_H
+/*
+ *  Checkpoint/restart - architecture specific headers ARM
+ *
+ *  Copyright (C) 2008-2010 Oren Laadan
+ *  Copyright (C)      2010 Christoffer Dall
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
+	__u32	cpu_architecture;
+	__u8	mmu;		/* Checkpointed on mmu system */
+	__u8	aeabi;		/* Checkpointed on AEABI kernel */
+	__u8	oabi_compat;	/* Checkpointed on OABI compat. system */
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
index 9dcb11e..9999568 100644
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
index 8dcb42a..89484b4 100644
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
index 26d302c..bfe39d8 100644
--- a/arch/arm/kernel/Makefile
+++ b/arch/arm/kernel/Makefile
@@ -39,6 +39,7 @@ obj-$(CONFIG_ARM_THUMBEE)	+= thumbee.o
 obj-$(CONFIG_KGDB)		+= kgdb.o
 obj-$(CONFIG_ARM_UNWIND)	+= unwind.o
 obj-$(CONFIG_HAVE_TCM)		+= tcm.o
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
 
 obj-$(CONFIG_CRUNCH)		+= crunch.o crunch-bits.o
 AFLAGS_crunch-bits.o		:= -Wa,-mcpu=ep9312
diff --git a/arch/arm/kernel/calls.S b/arch/arm/kernel/calls.S
index 80047c8..7126034 100644
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
index 0000000..14911f8
--- /dev/null
+++ b/arch/arm/kernel/checkpoint.c
@@ -0,0 +1,302 @@
+/*
+ *  Checkpoint/restart - architecture specific support for ARM
+ *
+ *  Copyright (C) 2008-2010 Oren Laadan
+ *  Copyright (C)      2010 Christoffer Dall
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
+#ifdef CONFIG_AEABI
+	const u8 ckpt_aeabi = 1;
+#else
+	const u8 ckpt_aeabi = 0;
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
+/* dump the cpu state and registers of a given task */
+int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_cpu *h;
+	int ret;
+	struct pt_regs *regs = task_pt_regs(t);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CPU);
+	if (!h)
+		return -ENOMEM;
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
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int checkpoint_write_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *arch_hdr;
+	unsigned int cpu_arch = cpu_architecture();
+	int ret;
+
+
+	arch_hdr = ckpt_hdr_get_type(ctx, sizeof(*arch_hdr),
+				     CKPT_HDR_HEADER_ARCH);
+	if (!arch_hdr)
+		return -ENOMEM;
+
+	if (cpu_arch == CPU_ARCH_UNKNOWN)
+		ckpt_msg(ctx, "warning: cannot determine CPU architecutre. "
+			      "cannot validate compatibility on restore");
+	arch_hdr->cpu_architecture = cpu_arch;
+	arch_hdr->mmu = ckpt_mmu;
+	arch_hdr->oabi_compat = ckpt_oabi_compat;
+	arch_hdr->aeabi = ckpt_aeabi;
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
+	int ret;
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
+	if (h->thumbee_state != 0) {
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
+/* read the cpu state and registers for the current task */
+int restore_cpu(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_cpu *h;
+	struct task_struct *t = current;
+	struct pt_regs *regs = task_pt_regs(t);
+	int i;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CPU);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	/*
+	 * Restore user registers
+	 */
+	memcpy(regs, &h->uregs, 16 * sizeof(__u32));
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
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
+
+int restore_read_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *arch_hdr;
+	unsigned int cpu_arch = cpu_architecture();
+	int ret = -EINVAL;
+
+	arch_hdr = ckpt_read_obj_type(ctx, sizeof(*arch_hdr),
+				      CKPT_HDR_HEADER_ARCH);
+	if (IS_ERR(arch_hdr))
+		return PTR_ERR(arch_hdr);
+
+	if (cpu_arch == CPU_ARCH_UNKNOWN)
+		ckpt_msg(ctx, "warning: cannot determine CPU architecutre. "
+			      "cannot validate compatibility.");
+
+	if (arch_hdr->cpu_architecture == CPU_ARCH_UNKNOWN)
+		ckpt_msg(ctx, "warning: unknown checkpoint CPU architecture. "
+			      "cannot validate compatibility.");
+
+	if (arch_hdr->cpu_architecture > cpu_architecture()) {
+		ckpt_err(ctx, ret, "cannot restore on older ARM architecture");
+		goto out;
+	}
+
+	/* TODO: Maybe non-mmu to mmu checkpoint/restart is possible */
+	if (arch_hdr->mmu != ckpt_mmu) {
+		ckpt_err(ctx, ret, "checkpoint %s MMU, restore %s MMU",
+			arch_hdr->mmu ? "with" : "without",
+			ckpt_mmu ? "with" : "without");
+		goto out;
+	}
+
+	ret = 0;
+
+	if (!ckpt_oabi_compat && ckpt_aeabi) {
+		/* Only AEABI */
+		if (!arch_hdr->aeabi) {
+			ret = -EINVAL;
+			ckpt_err(ctx, ret, "process used OABI "
+				           "and CONFIG_OABI_COMPAT not set.");
+			goto out;
+		} else if (arch_hdr->oabi_compat) {
+			ckpt_msg(ctx, "warning: process may have used OABI "
+				      "and CONFIG_OABI_COMPAT not set.");
+		}
+	} else if (!ckpt_aeabi) {
+		/* Only old ABI */
+		if (arch_hdr->aeabi && !arch_hdr->oabi_compat) {
+			ret = -EINVAL;
+			ckpt_err(ctx, ret, "process used AEABI "
+				           "and CONFIG_AEABI not set.");
+			goto out;
+		} else if (arch_hdr->oabi_compat) {
+			ckpt_msg(ctx, "warning: process may have used AEABI "
+				      "and CONFIG_AEABI not set.");
+		}
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
+	return 0;
+}
diff --git a/arch/arm/kernel/signal.c b/arch/arm/kernel/signal.c
index 907d5a6..d37ef41 100644
--- a/arch/arm/kernel/signal.c
+++ b/arch/arm/kernel/signal.c
@@ -773,6 +773,11 @@ static void do_signal(struct pt_regs *regs, int syscall)
 	single_step_set(current);
 }
 
+int task_has_saved_sigmask(struct task_struct *task)
+{
+	return !!(task_thread_info(task)->flags & _TIF_RESTORE_SIGMASK);
+}
+
 asmlinkage void
 do_notify_resume(struct pt_regs *regs, unsigned int thread_flags, int syscall)
 {
diff --git a/arch/arm/kernel/sys_arm.c b/arch/arm/kernel/sys_arm.c
index c23f133..11e27a1 100644
--- a/arch/arm/kernel/sys_arm.c
+++ b/arch/arm/kernel/sys_arm.c
@@ -27,6 +27,7 @@
 #include <linux/ipc.h>
 #include <linux/uaccess.h>
 #include <linux/slab.h>
+#include <linux/checkpoint.h>
 
 /* Fork a new task - this creates a new program thread.
  * This is called indirectly via a small wrapper
@@ -166,3 +167,15 @@ asmlinkage long sys_arm_fadvise64_64(int fd, int advice,
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
index 36386ad..bf20b45 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -208,6 +208,8 @@ enum {
 #define CKPT_ARCH_PPC32 CKPT_ARCH_PPC32
 	CKPT_ARCH_PPC64,
 #define CKPT_ARCH_PPC64 CKPT_ARCH_PPC64
+	CKPT_ARCH_ARM,
+#define CKPT_ARCH_ARM CKPT_ARCH_ARM
 };
 
 /* shared objrects (objref) */
-- 
1.5.6.5
