From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] s390: fix fallout from major rewrite
Date: Thu, 30 Apr 2009 17:54:19 -0500
Message-ID: <20090430225419.GA16782@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch brings the s390 port to where it will compile,
boot, and checkpoint/restart a simple app.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/include/asm/checkpoint_hdr.h |   12 ++----------
 arch/s390/kernel/vdso.c                |    4 +++-
 arch/s390/mm/Makefile                  |    2 +-
 arch/s390/mm/checkpoint.c              |   26 +++++++++++---------------
 arch/s390/mm/checkpoint_s390.h         |   23 -----------------------
 5 files changed, 17 insertions(+), 50 deletions(-)
 delete mode 100644 arch/s390/mm/checkpoint_s390.h

diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
index 9324655..510e233 100644
--- a/arch/s390/include/asm/checkpoint_hdr.h
+++ b/arch/s390/include/asm/checkpoint_hdr.h
@@ -27,7 +27,7 @@
  * NUM_GPRS defined in <asm/ptrace.h> to be 16
  * NUM_FPRS defined in <asm/ptrace.h> to be 16
  * NUM_APRS defined in <asm/ptrace.h> to be 16
- * NUM_CKPT_WORDS defined in <asm/ptrace.h> to be 3
+ * NUM_CR_WORDS defined in <asm/ptrace.h> to be 3
  */
 struct ckpt_hdr_cpu {
 	struct ckpt_hdr h;
@@ -56,7 +56,7 @@ struct ckpt_hdr_cpu {
 	} fprs[NUM_FPRS];
 
 	/* per_struct */
-	__u64 per_control_regs[NUM_CKPT_WORDS];
+	__u64 per_control_regs[NUM_CR_WORDS];
 	__u64 starting_addr;
 	__u64 ending_addr;
 	__u64 address;
@@ -80,14 +80,6 @@ struct ckpt_hdr_header_arch {
 	struct ckpt_hdr h;
 };
 
-#ifdef __KERNEL__
-/* Functions for copying to/from the header structs */
-extern void ckpt_s390_regs(int op, struct ckpt_hdr_cpu *h,
-			   struct task_struct *t);
-extern void ckpt_s390_mm(int op, struct ckpt_hdr_mm_context *h,
-			 struct mm_struct *mm);
-#endif
-
 #endif /* __s390x__ */
 
 #endif /* __ASM_S390_CKPT_HDR__H */
diff --git a/arch/s390/kernel/vdso.c b/arch/s390/kernel/vdso.c
index 34b6e0c..bab43b3 100644
--- a/arch/s390/kernel/vdso.c
+++ b/arch/s390/kernel/vdso.c
@@ -241,8 +241,10 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	}
 
 	/* for restart(2), double check that we got we asked for */
-	if (start && addr != start)
+	if (start && vdso_base != start) {
+		rc = -EINVAL;
 		goto out_up;
+	}
 
 	/*
 	 * our vma flags don't have VM_WRITE so by default, the process
diff --git a/arch/s390/mm/Makefile b/arch/s390/mm/Makefile
index b16161e..d1c3fbf 100644
--- a/arch/s390/mm/Makefile
+++ b/arch/s390/mm/Makefile
@@ -6,4 +6,4 @@ obj-y	 := init.o fault.o extmem.o mmap.o vmem.o pgtable.o
 obj-$(CONFIG_CMM) += cmm.o
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
 obj-$(CONFIG_PAGE_STATES) += page-states.o
-obj-$(CONFIG_CHECKPOINT) += checkpoint.o restart.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint.o
diff --git a/arch/s390/mm/checkpoint.c b/arch/s390/mm/checkpoint.c
index 127acdf..3923792 100644
--- a/arch/s390/mm/checkpoint.c
+++ b/arch/s390/mm/checkpoint.c
@@ -9,19 +9,17 @@
  */
 
 #include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
 #include <linux/kernel.h>
 #include <asm/system.h>
 #include <asm/pgtable.h>
 #include <asm/elf.h>
-
-#include "checkpoint_s390.h"
+#include <asm/checkpoint_hdr.h>
 
 /**************************************************************************
  * Checkpoint
  */
 
-void s390_regs(int op, struct ckpt_hdr_cpu *h, struct task_struct *t)
+static void s390_copy_regs(int op, struct ckpt_hdr_cpu *h, struct task_struct *t)
 {
 	struct pt_regs *regs = task_pt_regs(t);
 	struct thread_struct *thr = &t->thread;
@@ -57,7 +55,7 @@ void s390_regs(int op, struct ckpt_hdr_cpu *h, struct task_struct *t)
 	CKPT_COPY_ARRAY(op, h->fprs, thr->fp_regs.fprs, NUM_FPRS);
 	CKPT_COPY_ARRAY(op, h->acrs, thr->acrs, NUM_ACRS);
 	CKPT_COPY_ARRAY(op, h->per_control_regs,
-		      thr->per_info.control_regs.words.cr, NUM_CKPT_WORDS);
+		      thr->per_info.control_regs.words.cr, NUM_CR_WORDS);
 }
 
 void s390_mm(int op, struct ckpt_hdr_mm_context *h, struct mm_struct *mm)
@@ -75,16 +73,16 @@ int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
 }
 
 /* dump the cpu state and registers of a given task */
-int checkoint_write_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
+int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_cpu *h;
 	int ret;
 
-	hh = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CPU);
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CPU);
 	if (!h)
 		return -ENOMEM;
 
-	s390_regs(CKPT_CPT, h, t);
+	s390_copy_regs(CKPT_CPT, h, t);
 
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
 	ckpt_hdr_put(ctx, h);
@@ -95,7 +93,7 @@ int checkoint_write_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
 /* Write an empty header since it is assumed to be there */
 int checkpoint_write_header_arch(struct ckpt_ctx *ctx)
 {
-	struct ckpt_hdr_head_arch *h;
+	struct ckpt_hdr_header_arch *h;
 	int ret;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_HEADER_ARCH);
@@ -134,7 +132,7 @@ int restore_thread(struct ckpt_ctx *ctx)
 	return 0;
 }
 
-int restore_read_cpu(struct ckpt_ctx *ctx)
+int restore_cpu(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_cpu *h;
 
@@ -142,7 +140,7 @@ int restore_read_cpu(struct ckpt_ctx *ctx)
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
-	checkpoint_s390_regs(CKPT_RST, h, current);
+	s390_copy_regs(CKPT_RST, h, current);
 
 	/* s390 does not restore the access registers after a syscall,
 	 * but does on a task switch.  Since we're switching tasks (in
@@ -157,7 +155,6 @@ int restore_read_cpu(struct ckpt_ctx *ctx)
 int restore_read_header_arch(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_header_arch *h;
-	int ret;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_HEADER_ARCH);
 	if (IS_ERR(h))
@@ -171,14 +168,13 @@ int restore_read_header_arch(struct ckpt_ctx *ctx)
 int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
 {
 	struct ckpt_hdr_mm_context *h;
-	int ret;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_MM_CONTEXT);
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
-	checkpoint_s390_mm(CKPT_RST, h, mm);
+	s390_mm(CKPT_RST, h, mm);
 
 	ckpt_hdr_put(ctx, h);
-	return ret;
+	return 0;
 }
diff --git a/arch/s390/mm/checkpoint_s390.h b/arch/s390/mm/checkpoint_s390.h
deleted file mode 100644
index c3bf24d..0000000
--- a/arch/s390/mm/checkpoint_s390.h
+++ /dev/null
@@ -1,23 +0,0 @@
-/*
- *  Checkpoint/restart - architecture specific support for s390
- *
- *  Copyright IBM Corp. 2009
- *
- *  This file is subject to the terms and conditions of the GNU General Public
- *  License.  See the file COPYING in the main directory of the Linux
- *  distribution for more details.
- */
-
-#ifndef _S390_CHECKPOINT_H
-#define _S390_CHECKPOINT_H
-
-#include <linux/checkpoint_hdr.h>
-#include <linux/sched.h>
-#include <linux/mm_types.h>
-
-extern void checkpoint_s390_regs(int op, struct ckpt_hdr_cpu *h,
-				 struct task_struct *t);
-extern void checkpoint_s390_mm(int op, struct ckpt_hdr_mm_context *h,
-			       struct mm_struct *mm);
-
-#endif /* _S390_CHECKPOINT_H */
-- 
1.6.1
