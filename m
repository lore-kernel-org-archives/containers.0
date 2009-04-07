From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc3][PATCH 29/36] powerpc: checkpoint/restart implementation
Date: Tue,  7 Apr 2009 08:27:37 -0400
Message-ID: <1239107264-21775-30-git-send-email-orenl@cs.columbia.edu>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239107264-21775-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Support for checkpointing and restarting GPRs, FPU state, DABR, and
Altivec state.

The portion of the checkpoint image manipulated by this code begins
with a bitmask of features indicating the various contexts saved.
Fields in image that can vary depending on kernel configuration
(e.g. FP regs due to VSX) have their sizes explicitly recorded, except
for GPRS, so migrating between ppc32 and ppc64 won't work yet.

The restart code ensures that the task is not modified until the
checkpoint image is validated against the current kernel configuration
and hardware features (e.g. can't restart a task using Altivec on
non-Altivec systems).

What works:
* self and external checkpoint of simple (single thread, one open
  file) 32- and 64-bit processes on a ppc64 kernel

What doesn't work:
* restarting a 32-bit task from a 64-bit task and vice versa

Untested:
* ppc32 (but it builds)

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 arch/powerpc/include/asm/checkpoint_hdr.h |   15 +
 arch/powerpc/mm/Makefile                  |    1 +
 arch/powerpc/mm/checkpoint.c              |  500 +++++++++++++++++++++++++++++
 3 files changed, 516 insertions(+), 0 deletions(-)
 create mode 100644 arch/powerpc/include/asm/checkpoint_hdr.h
 create mode 100644 arch/powerpc/mm/checkpoint.c

diff --git a/arch/powerpc/include/asm/checkpoint_hdr.h b/arch/powerpc/include/asm/checkpoint_hdr.h
new file mode 100644
index 0000000..9f0d099
--- /dev/null
+++ b/arch/powerpc/include/asm/checkpoint_hdr.h
@@ -0,0 +1,15 @@
+#ifndef __ASM_PPC_CKPT_HDR_H
+#define __ASM_PPC_CKPT_HDR_H
+/*
+ *  Checkpoint/restart - architecture specific headers ppc
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* nothing to see here */
+
+#endif /* __ASM_PPC_CKPT_HDR__H */
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 953cc4a..02ecbcb 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -26,3 +26,4 @@ obj-$(CONFIG_NEED_MULTIPLE_NODES) += numa.o
 obj-$(CONFIG_PPC_MM_SLICES)	+= slice.o
 obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
 obj-$(CONFIG_PPC_SUBPAGE_PROT)	+= subpage-prot.o
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
diff --git a/arch/powerpc/mm/checkpoint.c b/arch/powerpc/mm/checkpoint.c
new file mode 100644
index 0000000..731874b
--- /dev/null
+++ b/arch/powerpc/mm/checkpoint.c
@@ -0,0 +1,500 @@
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
+enum cr_cpu_feature {
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
+struct cr_hdr_cpu {
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
+static void cr_cpu_feature_set(struct cr_hdr_cpu *hdr, enum cr_cpu_feature ftr)
+{
+	hdr->features_used |= 1ULL << ftr;
+}
+
+static bool cr_cpu_feature_isset(const struct cr_hdr_cpu *hdr,
+				 enum cr_cpu_feature ftr)
+{
+	return hdr->features_used & (1ULL << ftr);
+}
+
+/* determine whether an image has feature bits set that this kernel
+ * does not support */
+static bool cr_cpu_features_unknown(const struct cr_hdr_cpu *hdr)
+{
+	return hdr->features_used & ~CKPT_FTRS_POSSIBLE;
+}
+
+static void checkpoint_gprs(struct cr_hdr_cpu *cpu_hdr,
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
+static void checkpoint_fpu(struct cr_hdr_cpu *cpu_hdr,
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
+	cr_cpu_feature_set(cpu_hdr, CKPT_USED_FP);
+}
+#else
+static void checkpoint_fpu(struct cr_hdr_cpu *cpu_hdr,
+			   struct task_struct *task)
+{
+	return;
+}
+#endif
+
+#ifdef CONFIG_ALTIVEC
+static void checkpoint_altivec(struct cr_hdr_cpu *cpu_hdr,
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
+	cr_cpu_feature_set(cpu_hdr, CKPT_USED_ALTIVEC);
+}
+#else
+static void checkpoint_altivec(struct cr_hdr_cpu *cpu_hdr,
+			       struct task_struct *task)
+{
+	return;
+}
+#endif
+
+#ifdef CONFIG_SPE
+static void checkpoint_spe(struct cr_hdr_cpu *cpu_hdr,
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
+	cr_cpu_feature_set(cpu_hdr, CKPT_USED_SPE);
+}
+#else
+static void checkpoint_spe(struct cr_hdr_cpu *cpu_hdr,
+			   struct task_struct *task)
+{
+	return;
+}
+#endif
+
+static void checkpoint_dabr(struct cr_hdr_cpu *cpu_hdr,
+			    const struct task_struct *task)
+{
+	if (!task->thread.dabr)
+		return;
+
+	cpu_hdr->dabr = task->thread.dabr;
+	cr_cpu_feature_set(cpu_hdr, CKPT_USED_DEBUG);
+}
+
+/* dump the thread_struct of a given task */
+int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
+{
+	return 0;
+}
+
+/* dump the cpu state and registers of a given task */
+int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr_cpu *cpu_hdr;
+	struct cr_hdr cr_hdr;
+	int rc;
+
+	cr_hdr.type = CR_HDR_CPU;
+	cr_hdr.len = sizeof(*cpu_hdr);
+
+	rc = -ENOMEM;
+	cpu_hdr = kzalloc(sizeof(*cpu_hdr), GFP_KERNEL);
+	if (!cpu_hdr)
+		goto err;
+
+	checkpoint_gprs(cpu_hdr, t);
+	checkpoint_fpu(cpu_hdr, t);
+	checkpoint_dabr(cpu_hdr, t);
+	checkpoint_altivec(cpu_hdr, t);
+	checkpoint_spe(cpu_hdr, t);
+
+	rc = cr_write_obj(ctx, &cr_hdr, cpu_hdr);
+err:
+	kfree(cpu_hdr);
+	return rc;
+}
+
+int cr_write_head_arch(struct cr_ctx *ctx)
+{
+	return 0;
+}
+
+/* dump the mm->context state */
+int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
+{
+	return 0;
+}
+
+/* restart APIs */
+
+/* read the thread_struct into the current task */
+int cr_read_thread(struct cr_ctx *ctx)
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
+static int restore_gprs(const struct cr_hdr_cpu *cpu_hdr,
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
+static int restore_fpu(const struct cr_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = -EINVAL;
+	if (cpu_hdr->fpr_size != sizeof(task->thread.fpr))
+		goto out;
+
+	rc = 0;
+	if (!update || !cr_cpu_feature_isset(cpu_hdr, CKPT_USED_FP))
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
+static int restore_fpu(const struct cr_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	WARN_ON_ONCE(cr_cpu_feature_isset(cpu_hdr, CKPT_USED_FP));
+	return 0;
+}
+#endif
+
+static int restore_dabr(const struct cr_hdr_cpu *cpu_hdr,
+			struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = 0;
+	if (!cr_cpu_feature_isset(cpu_hdr, CKPT_USED_DEBUG))
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
+static int restore_altivec(const struct cr_hdr_cpu *cpu_hdr,
+			   struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = 0;
+	if (!cr_cpu_feature_isset(cpu_hdr, CKPT_USED_ALTIVEC))
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
+static int restore_altivec(const struct cr_hdr_cpu *cpu_hdr,
+			   struct task_struct *task, bool update)
+{
+	WARN_ON_ONCE(cr_cpu_feature_isset(CKPT_USED_ALTIVEC));
+	return 0;
+}
+#endif
+
+#ifdef CONFIG_SPE
+static int restore_spe(const struct cr_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = 0;
+	if (!cr_cpu_feature_isset(cpu_hdr, CKPT_USED_SPE))
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
+static int restore_spe(const struct cr_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	WARN_ON_ONCE(cr_cpu_feature_isset(cpu_hdr, CKPT_USED_SPE));
+	return 0;
+}
+#endif
+
+struct restore_func_desc {
+	int (*func)(const struct cr_hdr_cpu *, struct task_struct *, bool);
+	const char *info;
+};
+
+typedef int (*restore_func_t)(const struct cr_hdr_cpu *,
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
+static bool bitness_match(const struct cr_hdr_cpu *cpu_hdr,
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
+int cr_read_cpu(struct cr_ctx *ctx)
+{
+	struct cr_hdr_cpu *cpu_hdr;
+	bool update;
+	int rc;
+	int i;
+
+	rc = -ENOMEM;
+	cpu_hdr = kzalloc(sizeof(*cpu_hdr), GFP_KERNEL);
+	if (!cpu_hdr)
+		goto err;
+
+	rc = cr_read_obj_type(ctx, cpu_hdr, sizeof(*cpu_hdr), CR_HDR_CPU);
+	if (rc < 0)
+		goto err;
+
+	rc = -EINVAL;
+	if (cr_cpu_features_unknown(cpu_hdr))
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
+	kfree(cpu_hdr);
+	return rc;
+}
+
+int cr_read_head_arch(struct cr_ctx *ctx)
+{
+	return 0;
+}
+
+int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
+{
+	return 0;
+}
-- 
1.5.4.3
