From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [WIP] resurrected powerpc checkpoint support
Date: Wed, 08 Jul 2009 12:07:22 -0500
Message-ID: <m3eisrdrxx.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This is a delta against Oren's v17-rc1.  The code is pretty much the
same as it was in v15; I mostly cherry-picked the original commits and
fixed the build breaks.  Single-task checkpoint and restart of 32-bit
bash works... sometimes.  I think I may be seeing the same issue I reported
for i386 here:

https://lists.linux-foundation.org/pipermail/containers/2009-June/018522.html

Note clone_with_pids is not implemented yet.

Tested with 64-bit kernel on Powerstation (970MP).

Comments welcome...

 arch/powerpc/Kconfig                      |    3 +
 arch/powerpc/include/asm/Kbuild           |    1 +
 arch/powerpc/include/asm/checkpoint_hdr.h |   13 +
 arch/powerpc/include/asm/ptrace.h         |    7 +
 arch/powerpc/include/asm/systbl.h         |    2 +
 arch/powerpc/include/asm/unistd.h         |    4 +-
 arch/powerpc/kernel/ptrace.c              |   88 ++++--
 arch/powerpc/mm/Makefile                  |    1 +
 arch/powerpc/mm/checkpoint.c              |  499 +++++++++++++++++++++++++++++
 checkpoint/process.c                      |   50 ---
 include/linux/Kbuild                      |    1 +
 include/linux/checkpoint_hdr.h            |    2 +
 12 files changed, 591 insertions(+), 80 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index d00131c..2ca160e 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -26,6 +26,9 @@ config MMU
 	bool
 	default y
 
+config CHECKPOINT_SUPPORT
+	def_bool y
+
 config GENERIC_CMOS_UPDATE
 	def_bool y
 
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index 5ab7d7f..20379f1 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -12,6 +12,7 @@ header-y += shmbuf.h
 header-y += socket.h
 header-y += termbits.h
 header-y += fcntl.h
+header-y += checkpoint_hdr.h
 header-y += poll.h
 header-y += sockios.h
 header-y += ucontext.h
diff --git a/arch/powerpc/include/asm/checkpoint_hdr.h b/arch/powerpc/include/asm/checkpoint_hdr.h
new file mode 100644
index 0000000..2d454c6
--- /dev/null
+++ b/arch/powerpc/include/asm/checkpoint_hdr.h
@@ -0,0 +1,13 @@
+#ifndef __ASM_POWERPC_CKPT_HDR_H
+#define __ASM_POWERPC_CKPT_HDR_H
+
+/* This must match _NSIG in <asm/signal.h> */
+#define CKPT_ARCH_NSIG 64
+
+#ifdef __powerpc64__
+#define CKPT_ARCH_ID CKPT_ARCH_PPC64
+#else
+#define CKPT_ARCH_ID CKPT_ARCH_PPC32
+#endif
+
+#endif /* __ASM_POWERPC_CKPT_HDR_H */
diff --git a/arch/powerpc/include/asm/ptrace.h b/arch/powerpc/include/asm/ptrace.h
index 8c34149..c6cb2c6 100644
--- a/arch/powerpc/include/asm/ptrace.h
+++ b/arch/powerpc/include/asm/ptrace.h
@@ -81,6 +81,8 @@ struct pt_regs {
 
 #ifndef __ASSEMBLY__
 
+#include <linux/types.h>
+
 #define instruction_pointer(regs) ((regs)->nip)
 #define user_stack_pointer(regs) ((regs)->gpr[1])
 #define regs_return_value(regs) ((regs)->gpr[3])
@@ -140,6 +142,11 @@ extern void user_enable_single_step(struct task_struct *);
 extern void user_enable_block_step(struct task_struct *);
 extern void user_disable_single_step(struct task_struct *);
 
+/* for reprogramming DABR/DAC during restart of a checkpointed task */
+extern bool debugreg_valid(unsigned long val, unsigned int index);
+extern void debugreg_update(struct task_struct *task, unsigned long val,
+			    unsigned int index);
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* __KERNEL__ */
diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index 370600c..3d44cf3 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -326,3 +326,5 @@ SYSCALL_SPU(perf_counter_open)
 COMPAT_SYS_SPU(preadv)
 COMPAT_SYS_SPU(pwritev)
 COMPAT_SYS(rt_tgsigqueueinfo)
+SYSCALL(checkpoint)
+SYSCALL(restart)
diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index cef080b..ef41ebb 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -345,10 +345,12 @@
 #define __NR_preadv		320
 #define __NR_pwritev		321
 #define __NR_rt_tgsigqueueinfo	322
+#define __NR_checkpoint		323
+#define __NR_restart		324
 
 #ifdef __KERNEL__
 
-#define __NR_syscalls		323
+#define __NR_syscalls		325
 
 #define __NR__exit __NR_exit
 #define NR_syscalls	__NR_syscalls
diff --git a/arch/powerpc/kernel/ptrace.c b/arch/powerpc/kernel/ptrace.c
index 9fa2c7d..15ab4be 100644
--- a/arch/powerpc/kernel/ptrace.c
+++ b/arch/powerpc/kernel/ptrace.c
@@ -754,22 +754,25 @@ void user_disable_single_step(struct task_struct *task)
 	clear_tsk_thread_flag(task, TIF_SINGLESTEP);
 }
 
-int ptrace_set_debugreg(struct task_struct *task, unsigned long addr,
-			       unsigned long data)
+/**
+ * debugreg_valid() - validate the value to be written to a debug register
+ * @val:	The prospective contents of the register.
+ * @index:	Must be zero.
+ *
+ * Returns true if @val is an acceptable value for the register indicated by
+ * @index, false otherwise.
+ */
+bool debugreg_valid(unsigned long val, unsigned int index)
 {
-	/* For ppc64 we support one DABR and no IABR's at the moment (ppc64).
-	 *  For embedded processors we support one DAC and no IAC's at the
-	 *  moment.
-	 */
-	if (addr > 0)
-		return -EINVAL;
+	/* We support only one debug register for now */
+	if (index != 0)
+		return false;
 
 	/* The bottom 3 bits in dabr are flags */
-	if ((data & ~0x7UL) >= TASK_SIZE)
-		return -EIO;
+	if ((val & ~0x7UL) >= TASK_SIZE)
+		return false;
 
 #ifndef CONFIG_BOOKE
-
 	/* For processors using DABR (i.e. 970), the bottom 3 bits are flags.
 	 *  It was assumed, on previous implementations, that 3 bits were
 	 *  passed together with the data address, fitting the design of the
@@ -783,47 +786,74 @@ int ptrace_set_debugreg(struct task_struct *task, unsigned long addr,
 	 */
 
 	/* Ensure breakpoint translation bit is set */
-	if (data && !(data & DABR_TRANSLATION))
-		return -EIO;
-
-	/* Move contents to the DABR register */
-	task->thread.dabr = data;
-
-#endif
-#if defined(CONFIG_BOOKE)
-
+	if (val && !(val & DABR_TRANSLATION))
+		return false;
+#else
 	/* As described above, it was assumed 3 bits were passed with the data
 	 *  address, but we will assume only the mode bits will be passed
 	 *  as to not cause alignment restrictions for DAC-based processors.
 	 */
 
+	/* Read or Write bits must be set */
+	if (!(val & 0x3UL))
+		return -EINVAL;
+#endif
+	return true;
+}
+
+/**
+ * debugreg_update() - update a debug register associated with a task
+ * @task:	The task whose register state is to be modified.
+ * @val:	The value to be written to the debug register.
+ * @index:	Specifies the debug register.  Currently unused.
+ *
+ * Set a task's DABR/DAC to @val, which should be validated with
+ * debugreg_valid() beforehand.
+ */
+void debugreg_update(struct task_struct *task, unsigned long val,
+		     unsigned int index)
+{
+#ifndef CONFIG_BOOKE
+	task->thread.dabr = val;
+#else
 	/* DAC's hold the whole address without any mode flags */
-	task->thread.dabr = data & ~0x3UL;
+	task->thread.dabr = val & ~0x3UL;
 
 	if (task->thread.dabr == 0) {
 		task->thread.dbcr0 &= ~(DBSR_DAC1R | DBSR_DAC1W | DBCR0_IDM);
 		task->thread.regs->msr &= ~MSR_DE;
-		return 0;
 	}
 
-	/* Read or Write bits must be set */
-
-	if (!(data & 0x3UL))
-		return -EINVAL;
-
 	/* Set the Internal Debugging flag (IDM bit 1) for the DBCR0
 	   register */
 	task->thread.dbcr0 = DBCR0_IDM;
 
 	/* Check for write and read flags and set DBCR0
 	   accordingly */
-	if (data & 0x1UL)
+	if (val & 0x1UL)
 		task->thread.dbcr0 |= DBSR_DAC1R;
-	if (data & 0x2UL)
+	if (val & 0x2UL)
 		task->thread.dbcr0 |= DBSR_DAC1W;
 
 	task->thread.regs->msr |= MSR_DE;
 #endif
+}
+
+static int ptrace_set_debugreg(struct task_struct *task, unsigned long addr,
+			       unsigned long data)
+{
+	/* For ppc64 we support one DABR and no IABR's at the moment (ppc64).
+	 * For embedded processors we support one DAC and no IAC's at the
+	 * moment.
+	 */
+	if (addr > 0)
+		return -EINVAL;
+
+	if (!debugreg_valid(data, 0))
+		return -EIO;
+
+	debugreg_update(task, data, 0);
+
 	return 0;
 }
 
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 3e68363..aa8733c 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -31,3 +31,4 @@ obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
 obj-$(CONFIG_PPC_SUBPAGE_PROT)	+= subpage-prot.o
 obj-$(CONFIG_NOT_COHERENT_CACHE) += dma-noncoherent.o
 obj-$(CONFIG_HIGHMEM)		+= highmem.o
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
diff --git a/arch/powerpc/mm/checkpoint.c b/arch/powerpc/mm/checkpoint.c
new file mode 100644
index 0000000..9f7de42
--- /dev/null
+++ b/arch/powerpc/mm/checkpoint.c
@@ -0,0 +1,499 @@
+/*
+ *  Checkpoint/restart - architecture specific support for powerpc.
+ *  Based on x86 implementation.
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *  Copyright 2009 IBM Corp.
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#define DEBUG 1 /* for pr_debug */
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/kernel.h>
+#include <asm/processor.h>
+#include <asm/ptrace.h>
+#include <asm/system.h>
+
+enum ckpt_cpu_feature {
+	CKPT_USED_FP,
+	CKPT_USED_DEBUG,
+	CKPT_USED_ALTIVEC,
+	CKPT_USED_SPE,
+	CKPT_USED_VSX,
+	CKPT_FTR_END = 31,
+};
+
+#define x(ftr) (1UL << ftr)
+
+/* features this kernel can handle for restart */
+enum {
+	CKPT_FTRS_POSSIBLE =
+#ifdef CONFIG_PPC_FPU
+	x(CKPT_USED_FP) |
+#endif
+	x(CKPT_USED_DEBUG) |
+#ifdef CONFIG_ALTIVEC
+	x(CKPT_USED_ALTIVEC) |
+#endif
+#ifdef CONFIG_SPE
+	x(CKPT_USED_SPE) |
+#endif
+#ifdef CONFIG_VSX
+	x(CKPT_USED_VSX) |
+#endif
+	0,
+};
+
+#undef x
+
+struct ckpt_hdr_cpu {
+	struct ckpt_hdr h;
+	u32 features_used;
+	u32 pt_regs_size;
+	u32 fpr_size;
+	struct pt_regs pt_regs;
+	/* relevant fields from thread_struct */
+	double fpr[32][TS_FPRWIDTH];
+	u32 fpscr;
+	s32 fpexc_mode;
+	u64 dabr;
+	/* Altivec/VMX state */
+	vector128 vr[32];
+	vector128 vscr;
+	u64 vrsave;
+	/* SPE state */
+	u32 evr[32];
+	u64 acc;
+	u32 spefscr;
+};
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+static void ckpt_cpu_feature_set(struct ckpt_hdr_cpu *hdr,
+				 enum ckpt_cpu_feature ftr)
+{
+	hdr->features_used |= 1ULL << ftr;
+}
+
+static bool ckpt_cpu_feature_isset(const struct ckpt_hdr_cpu *hdr,
+				 enum ckpt_cpu_feature ftr)
+{
+	return hdr->features_used & (1ULL << ftr);
+}
+
+/* determine whether an image has feature bits set that this kernel
+ * does not support */
+static bool ckpt_cpu_features_unknown(const struct ckpt_hdr_cpu *hdr)
+{
+	return hdr->features_used & ~CKPT_FTRS_POSSIBLE;
+}
+
+static void checkpoint_gprs(struct ckpt_hdr_cpu *cpu_hdr,
+			    struct task_struct *task)
+{
+	struct pt_regs *pt_regs;
+
+	pr_debug("%s: saving GPRs\n", __func__);
+
+	cpu_hdr->pt_regs_size = sizeof(*pt_regs);
+	pt_regs = task_pt_regs(task);
+	cpu_hdr->pt_regs = *pt_regs;
+}
+
+#ifdef CONFIG_PPC_FPU
+static void checkpoint_fpu(struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task)
+{
+	/* easiest to save FP state unconditionally */
+
+	pr_debug("%s: saving FPU state\n", __func__);
+
+	if (task == current)
+		flush_fp_to_thread(task);
+
+	cpu_hdr->fpr_size = sizeof(cpu_hdr->fpr);
+	cpu_hdr->fpscr = task->thread.fpscr.val;
+	cpu_hdr->fpexc_mode = task->thread.fpexc_mode;
+
+	memcpy(cpu_hdr->fpr, task->thread.fpr, sizeof(cpu_hdr->fpr));
+
+	ckpt_cpu_feature_set(cpu_hdr, CKPT_USED_FP);
+}
+#else
+static void checkpoint_fpu(struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task)
+{
+	return;
+}
+#endif
+
+#ifdef CONFIG_ALTIVEC
+static void checkpoint_altivec(struct ckpt_hdr_cpu *cpu_hdr,
+			       struct task_struct *task)
+{
+	if (!cpu_has_feature(CPU_FTR_ALTIVEC))
+		return;
+
+	if (!task->thread.used_vr)
+		return;
+
+	pr_debug("%s: saving Altivec state\n", __func__);
+
+	if (task == current)
+		flush_altivec_to_thread(task);
+
+	cpu_hdr->vrsave = task->thread.vrsave;
+	memcpy(cpu_hdr->vr, task->thread.vr, sizeof(cpu_hdr->vr));
+	ckpt_cpu_feature_set(cpu_hdr, CKPT_USED_ALTIVEC);
+}
+#else
+static void checkpoint_altivec(struct ckpt_hdr_cpu *cpu_hdr,
+			       struct task_struct *task)
+{
+	return;
+}
+#endif
+
+#ifdef CONFIG_SPE
+static void checkpoint_spe(struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task)
+{
+	if (!cpu_has_feature(CPU_FTR_SPE))
+		return;
+
+	if (!task->thread.used_spe)
+		return;
+
+	pr_debug("%s: saving SPE state\n", __func__);
+
+	if (task == current)
+		flush_spe_to_thread(task);
+
+	cpu_hdr->acc = task->thread.acc;
+	cpu_hdr->spefscr = task->thread.spefscr;
+	memcpy(cpu_hdr->evr, task->thread.evr, sizeof(cpu_hdr->evr));
+	ckpt_cpu_feature_set(cpu_hdr, CKPT_USED_SPE);
+}
+#else
+static void checkpoint_spe(struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task)
+{
+	return;
+}
+#endif
+
+static void checkpoint_dabr(struct ckpt_hdr_cpu *cpu_hdr,
+			    const struct task_struct *task)
+{
+	if (!task->thread.dabr)
+		return;
+
+	cpu_hdr->dabr = task->thread.dabr;
+	ckpt_cpu_feature_set(cpu_hdr, CKPT_USED_DEBUG);
+}
+
+/* dump the thread_struct of a given task */
+int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	return 0;
+}
+
+/* dump the cpu state and registers of a given task */
+int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_cpu *cpu_hdr;
+	int rc;
+
+	rc = -ENOMEM;
+	cpu_hdr = ckpt_hdr_get_type(ctx, sizeof(*cpu_hdr), CKPT_HDR_CPU);
+	if (!cpu_hdr)
+		goto err;
+
+	checkpoint_gprs(cpu_hdr, t);
+	checkpoint_fpu(cpu_hdr, t);
+	checkpoint_dabr(cpu_hdr, t);
+	checkpoint_altivec(cpu_hdr, t);
+	checkpoint_spe(cpu_hdr, t);
+
+	rc = ckpt_write_obj(ctx, (struct ckpt_hdr *) cpu_hdr);
+err:
+	ckpt_hdr_put(ctx, cpu_hdr);
+	return rc;
+}
+
+int checkpoint_write_header_arch(struct ckpt_ctx *ctx)
+{
+	return 0;
+}
+
+/* dump the mm->context state */
+int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	return 0;
+}
+
+/**************************************************************************
+ * Restart
+ */
+
+/* read the thread_struct into the current task */
+int restore_thread(struct ckpt_ctx *ctx)
+{
+	return 0;
+}
+
+/* Based on the MSR value from a checkpoint image, produce an MSR
+ * value that is appropriate for the restored task.  Right now we only
+ * check for MSR_SF (64-bit) for PPC64.
+ */
+static unsigned long sanitize_msr(unsigned long msr_ckpt)
+{
+#ifdef CONFIG_PPC32
+	return MSR_USER;
+#else
+	if (msr_ckpt & MSR_SF)
+		return MSR_USER64;
+	return MSR_USER32;
+#endif
+}
+
+static int restore_gprs(const struct ckpt_hdr_cpu *cpu_hdr,
+			struct task_struct *task, bool update)
+{
+	struct pt_regs *regs;
+	int rc;
+
+	rc = -EINVAL;
+	if (cpu_hdr->pt_regs_size != sizeof(*regs))
+		goto out;
+
+	rc = 0;
+	if (!update)
+		goto out;
+
+	regs = task_pt_regs(task);
+	*regs = cpu_hdr->pt_regs;
+
+	regs->msr = sanitize_msr(regs->msr);
+out:
+	return rc;
+}
+
+#ifdef CONFIG_PPC_FPU
+static int restore_fpu(const struct ckpt_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = -EINVAL;
+	if (cpu_hdr->fpr_size != sizeof(task->thread.fpr))
+		goto out;
+
+	rc = 0;
+	if (!update || !ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_FP))
+		goto out;
+
+	task->thread.fpscr.val = cpu_hdr->fpscr;
+	task->thread.fpexc_mode = cpu_hdr->fpexc_mode;
+
+	memcpy(task->thread.fpr, cpu_hdr->fpr, sizeof(task->thread.fpr));
+out:
+	return rc;
+}
+#else
+static int restore_fpu(const struct ckpt_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	WARN_ON_ONCE(ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_FP));
+	return 0;
+}
+#endif
+
+static int restore_dabr(const struct ckpt_hdr_cpu *cpu_hdr,
+			struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = 0;
+	if (!ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_DEBUG))
+		goto out;
+
+	rc = -EINVAL;
+	if (!debugreg_valid(cpu_hdr->dabr, 0))
+		goto out;
+
+	rc = 0;
+	if (!update)
+		goto out;
+
+	debugreg_update(task, cpu_hdr->dabr, 0);
+out:
+	return rc;
+}
+
+#ifdef CONFIG_ALTIVEC
+static int restore_altivec(const struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = 0;
+	if (!ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_ALTIVEC))
+		goto out;
+
+	rc = -EINVAL;
+	if (!cpu_has_feature(CPU_FTR_ALTIVEC))
+		goto out;
+
+	rc = 0;
+	if (!update)
+		goto out;
+
+	task->thread.vrsave = cpu_hdr->vrsave;
+	task->thread.used_vr = 1;
+
+	memcpy(task->thread.vr, cpu_hdr->vr, sizeof(cpu_hdr->vr));
+out:
+	return rc;
+}
+#else
+static int restore_altivec(const struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task, bool update)
+{
+	WARN_ON_ONCE(ckpt_cpu_feature_isset(CKPT_USED_ALTIVEC));
+	return 0;
+}
+#endif
+
+#ifdef CONFIG_SPE
+static int restore_spe(const struct ckpt_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = 0;
+	if (!ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_SPE))
+		goto out;
+
+	rc = -EINVAL;
+	if (!cpu_has_feature(CPU_FTR_SPE))
+		goto out;
+
+	rc = 0;
+	if (!update)
+		goto out;
+
+	task->thread.acc = cpu_hdr->acc;
+	task->thread.spefscr = cpu_hdr->spefscr;
+	task->thread.used_spe = 1;
+
+	memcpy(task->thread.evr, cpu_hdr->evr, sizeof(cpu_hdr->evr));
+out:
+	return rc;
+}
+#else
+static int restore_spe(const struct ckpt_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	WARN_ON_ONCE(ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_SPE));
+	return 0;
+}
+#endif
+
+struct restore_func_desc {
+	int (*func)(const struct ckpt_hdr_cpu *, struct task_struct *, bool);
+	const char *info;
+};
+
+typedef int (*restore_func_t)(const struct ckpt_hdr_cpu *,
+			      struct task_struct *, bool);
+
+static const restore_func_t restore_funcs[] = {
+	restore_gprs,
+	restore_fpu,
+	restore_dabr,
+	restore_altivec,
+	restore_spe,
+};
+
+static bool bitness_match(const struct ckpt_hdr_cpu *cpu_hdr,
+			  const struct task_struct *task)
+{
+	/* 64-bit image */
+	if (cpu_hdr->pt_regs.msr & MSR_SF) {
+		if (task->thread.regs->msr & MSR_SF)
+			return true;
+		else
+			return false;
+	}
+
+	/* 32-bit image */
+	if (task->thread.regs->msr & MSR_SF)
+		return false;
+
+	return true;
+}
+
+int restore_cpu(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_cpu *cpu_hdr;
+	bool update;
+	int rc;
+	int i;
+
+	cpu_hdr = ckpt_read_obj_type(ctx, sizeof(*cpu_hdr), CKPT_HDR_CPU);
+	if (IS_ERR(cpu_hdr))
+		return PTR_ERR(cpu_hdr);
+
+	rc = -EINVAL;
+	if (ckpt_cpu_features_unknown(cpu_hdr))
+		goto err;
+
+	/* temporary: restoring a 32-bit image from a 64-bit task and
+	 * vice-versa is known not to work (probably not restoring
+	 * thread_info correctly); detect this and fail gracefully.
+	 */
+	if (!bitness_match(cpu_hdr, current))
+		goto err;
+
+	/* We want to determine whether there's anything wrong with
+	 * the checkpoint image before changing the task at all.  Run
+	 * a "check" phase (update = false) first.
+	 */
+	update = false;
+commit:
+	for (i = 0; i < ARRAY_SIZE(restore_funcs); i++) {
+		rc = restore_funcs[i](cpu_hdr, current, update);
+		if (rc == 0)
+			continue;
+		pr_debug("%s: restore_func[%i] failed\n", __func__, i);
+		WARN_ON_ONCE(update);
+		goto err;
+	}
+
+	if (!update) {
+		update = true;
+		goto commit;
+	}
+
+err:
+	ckpt_hdr_put(ctx, cpu_hdr);
+	return rc;
+}
+
+int restore_read_header_arch(struct ckpt_ctx *ctx)
+{
+	return 0;
+}
+
+int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	return 0;
+}
diff --git a/checkpoint/process.c b/checkpoint/process.c
index a93df3d..cfdce42 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -229,28 +229,6 @@ int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 		ckpt_debug("restart_block: posix_cpu expire %lld now %lld\n",
 			 expire, base);
 
-#ifdef CONFIG_COMPAT
-	} else if (fn == compat_nanosleep_restart) {
-
-		h->function_type = CKPT_RESTART_BLOCK_NANOSLEEP;
-		h->arg_0 = restart_block->nanosleep.index;
-		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
-		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
-		expire = restart_block->nanosleep.expires;
-		ckpt_debug("restart_block: compat expire %lld now %lld\n",
-			 expire, base);
-
-	} else if (fn == compat_clock_nanosleep_restart) {
-
-		h->function_type = CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP;
-		h->arg_0 = restart_block->nanosleep.index;
-		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
-		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
-		expire = restart_block->nanosleep.expires;
-		ckpt_debug("restart_block: compat_clock expire %lld now %lld\n",
-			 expire, base);
-
-#endif
 	} else if (fn == futex_wait_restart) {
 
 		h->function_type = CKPT_RESTART_BLOCK_FUTEX;
@@ -567,34 +545,6 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 		restart_block.arg2 = ts.tv_sec;
 		restart_block.arg3 = ts.tv_nsec;
 		break;
-#ifdef CONFIG_COMPAT
-	case CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP:
-		clockid = h->arg_0;
-		if (clockid < 0 || invalid_clockid(clockid))
-			break;
-		restart_block.fn = compat_nanosleep_restart;
-		restart_block.nanosleep.index = clockid;
-		restart_block.nanosleep.rmtp =
-			(struct timespec __user *) (unsigned long) h->arg_1;
-		restart_block.nanosleep.compat_rmtp =
-			(struct compat_timespec __user *)
-				(unsigned long) h->arg_2;
-		resatrt_block.nanosleep.expires = expire;
-		break;
-	case CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP:
-		clockid = h->arg_0;
-		if (clockid < 0 || invalid_clockid(clockid))
-			break;
-		restart_block.fn = compat_clock_nanosleep_restart;
-		restart_block.nanosleep.index = clockid;
-		restart_block.nanosleep.rmtp =
-			(struct timespec __user *) (unsigned long) h->arg_1;
-		restart_block.nanosleep.compat_rmtp =
-			(struct compat_timespec __user *)
-				(unsigned long) h->arg_2;
-		resatrt_block.nanosleep.expires = expire;
-		break;
-#endif
 	case CKPT_RESTART_BLOCK_FUTEX:
 		restart_block.fn = futex_wait_restart;
 		restart_block.futex.uaddr = (u32 *) (unsigned long) h->arg_0;
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 861c7fa..b6677b9 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -46,6 +46,7 @@ header-y += can.h
 header-y += cdk.h
 header-y += checkpoint_types.h
 header-y += checkpoint_hdr.h
+header-y += checkpoint.h
 header-y += chio.h
 header-y += coda_psdev.h
 header-y += coff.h
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b5243e1..d999b5c 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -98,6 +98,8 @@ enum {
 	/* do not change order (will break ABI) */
 	CKPT_ARCH_X86_32 = 1,
 	CKPT_ARCH_S390X,
+	CKPT_ARCH_PPC32,
+	CKPT_ARCH_PPC64,
 };
 
 /* shared objrects (objref) */
