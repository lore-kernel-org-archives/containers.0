From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 3/3] c/r: define s390-specific checkpoint-restart code (v7)
Date: Tue,  3 Mar 2009 10:56:04 -0500
Message-ID: <1236095764-19325-4-git-send-email-danms@us.ibm.com>
References: <1236095764-19325-1-git-send-email-danms@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758710AbZCCP5k@vger.kernel.org>
In-Reply-To: <1236095764-19325-1-git-send-email-danms@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: containers@lists.osdl.org
Cc: linux-kernel@vger.kernel.org, "Serge E. Hallyn" <serue@us.ibm.com>
List-Id: containers.vger.kernel.org

Implement the s390 arch-specific checkpoint/restart helpers.  This
is on top of Oren Laadan's c/r code.

With these, I am able to checkpoint and restart simple programs as per
Oren's patch intro.  While on x86 I never had to freeze a single task
to checkpoint it, on s390 I do need to.  That is a prereq for consistent
snapshots (esp with multiple processes) anyway so I don't see that as
a problem.

Changelog:
    Feb 27:
            . Add checkpoint_s390.h
            . Fixed up save and restore of PSW, with the non-address bits
              properly masked out
    Feb 25:
            . Make checkpoint_hdr.h safe for inclusion in userspace
            . Replace comment about vsdo code
            . Add comment about restoring access registers
            . Write and read an empty cr_hdr_head_arch record to appease
              code (mktree) that expects it to be there
            . Utilize NUM_CR_WORDS in checkpoint_hdr.h
    Feb 24:
            . Use CR_COPY() to unify the un/loading of cpu and mm state
            . Fix fprs definition in cr_hdr_cpu
            . Remove debug WARN_ON() from checkpoint.c
    Feb 23:
            . Macro-ize the un/packing of trace flags
            . Fix the crash when externally-linked
            . Break out the restart functions into restart.c
            . Remove unneeded s390_enable_sie() call
    Jan 30:
            . Switched types in cr_hdr_cpu to __u64 etc.
              (Per Oren suggestion)
            . Replaced direct inclusion of structs in
              cr_hdr_cpu with the struct members.
              (Per Oren suggestion)
            . Also ended up adding a bunch of new things
              into restart (mm_segment, ksp, etc) in vain
              attempt to get code using fpu to not segfault
              after restart.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 arch/s390/include/asm/checkpoint_hdr.h |   88 ++++++++++++++++++++++
 arch/s390/include/asm/unistd.h         |    4 +-
 arch/s390/kernel/compat_wrapper.S      |   12 +++
 arch/s390/kernel/syscalls.S            |    2 +
 arch/s390/mm/Makefile                  |    1 +
 arch/s390/mm/checkpoint.c              |  125 ++++++++++++++++++++++++++++++++
 arch/s390/mm/checkpoint_s390.h         |   22 ++++++
 arch/s390/mm/restart.c                 |   81 +++++++++++++++++++++
 checkpoint/Kconfig                     |    2 +-
 9 files changed, 335 insertions(+), 2 deletions(-)
 create mode 100644 arch/s390/include/asm/checkpoint_hdr.h
 create mode 100644 arch/s390/mm/checkpoint.c
 create mode 100644 arch/s390/mm/checkpoint_s390.h
 create mode 100644 arch/s390/mm/restart.c

diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
new file mode 100644
index 0000000..0a405c2
--- /dev/null
+++ b/arch/s390/include/asm/checkpoint_hdr.h
@@ -0,0 +1,88 @@
+#ifndef __ASM_S390_CKPT_HDR_H
+#define __ASM_S390_CKPT_HDR_H
+/*
+ *  Checkpoint/restart - architecture specific headers s/390
+ *
+ *  Copyright IBM Corp. 2009
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/types.h>
+#include <asm/ptrace.h>
+
+#ifdef __KERNEL__
+#include <asm/processor.h>
+#else
+#include <sys/user.h>
+#endif
+
+#ifdef __s390x__
+
+/*
+ * Notes
+ * NUM_GPRS defined in <asm/ptrace.h> to be 16
+ * NUM_FPRS defined in <asm/ptrace.h> to be 16
+ * NUM_APRS defined in <asm/ptrace.h> to be 16
+ * NUM_CR_WORDS defined in <asm/ptrace.h> to be 3
+ */
+struct cr_hdr_cpu {
+	__u64 args[1];
+	__u64 gprs[NUM_GPRS];
+	__u64 orig_gpr2;
+	__u16 svcnr;
+	__u16 ilc;
+	__u32 acrs[NUM_ACRS];
+	__u64 ieee_instruction_pointer;
+
+	/* psw_t */
+	__u64 psw_t_mask;
+	__u64 psw_t_addr;
+
+	/* s390_fp_regs_t */
+	__u32 fpc;
+	union {
+		float f;
+		double d;
+		__u64 ui;
+		struct {
+			__u32 fp_hi;
+			__u32 fp_lo;
+		} fp;
+	} fprs[NUM_FPRS];
+
+	/* per_struct */
+	__u64 per_control_regs[NUM_CR_WORDS];
+	__u64 starting_addr;
+	__u64 ending_addr;
+	__u64 address;
+	__u16 perc_atmid;
+	__u8 access_id;
+	__u8 single_step;
+	__u8 instruction_fetch;
+};
+
+struct cr_hdr_mm_context {
+	unsigned long vdso_base;
+	int noexec;
+	int has_pgste;
+	int alloc_pgste;
+	unsigned long asce_bits;
+	unsigned long asce_limit;
+};
+
+struct cr_hdr_head_arch {
+};
+
+#ifdef __KERNEL__
+/* Functions for copying to/from the header structs */
+extern void cr_s390_regs(int op, struct cr_hdr_cpu *hh, struct task_struct *t);
+extern void cr_s390_mm(int op, struct cr_hdr_mm_context *hh,
+		       struct mm_struct *mm);
+#endif
+
+#endif /* __s390x__ */
+
+#endif /* __ASM_S390_CKPT_HDR__H */
diff --git a/arch/s390/include/asm/unistd.h b/arch/s390/include/asm/unistd.h
index c8ad350..ffe64a0 100644
--- a/arch/s390/include/asm/unistd.h
+++ b/arch/s390/include/asm/unistd.h
@@ -265,7 +265,9 @@
 #define __NR_pipe2		325
 #define __NR_dup3		326
 #define __NR_epoll_create1	327
-#define NR_syscalls 328
+#define __NR_checkpoint		328
+#define __NR_restart		329
+#define NR_syscalls 330
 
 /* 
  * There are some system calls that are not present on 64 bit, some
diff --git a/arch/s390/kernel/compat_wrapper.S b/arch/s390/kernel/compat_wrapper.S
index fc2c971..9546a81 100644
--- a/arch/s390/kernel/compat_wrapper.S
+++ b/arch/s390/kernel/compat_wrapper.S
@@ -1767,3 +1767,15 @@ sys_dup3_wrapper:
 sys_epoll_create1_wrapper:
 	lgfr	%r2,%r2			# int
 	jg	sys_epoll_create1	# branch to system call
+
+	.globl sys_checkpoint_wrapper
+sys_checkpoint_wrapper:
+	lgfr	%r2,%r2			# pid_t
+	lgfr	%r3,%r3			# int
+	llgfr	%r4,%r4			# unsigned long
+
+	.globl sys_restart_wrapper
+sys_restart_wrapper:
+	lgfr	%r2,%r2			# int
+	lgfr	%r3,%r3			# int
+	llgfr	%r4,%r4			# unsigned long
diff --git a/arch/s390/kernel/syscalls.S b/arch/s390/kernel/syscalls.S
index 2d61787..54316c8 100644
--- a/arch/s390/kernel/syscalls.S
+++ b/arch/s390/kernel/syscalls.S
@@ -336,3 +336,5 @@ SYSCALL(sys_inotify_init1,sys_inotify_init1,sys_inotify_init1_wrapper)
 SYSCALL(sys_pipe2,sys_pipe2,sys_pipe2_wrapper) /* 325 */
 SYSCALL(sys_dup3,sys_dup3,sys_dup3_wrapper)
 SYSCALL(sys_epoll_create1,sys_epoll_create1,sys_epoll_create1_wrapper)
+SYSCALL(sys_checkpoint,sys_checkpoint,sys_checkpoint_wrapper)
+SYSCALL(sys_restart,sys_restart,sys_restart_wrapper)
diff --git a/arch/s390/mm/Makefile b/arch/s390/mm/Makefile
index 2a74581..040fbb7 100644
--- a/arch/s390/mm/Makefile
+++ b/arch/s390/mm/Makefile
@@ -6,3 +6,4 @@ obj-y	 := init.o fault.o extmem.o mmap.o vmem.o pgtable.o
 obj-$(CONFIG_CMM) += cmm.o
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
 obj-$(CONFIG_PAGE_STATES) += page-states.o
+obj-$(CONFIG_CHECKPOINT_RESTART) += checkpoint.o restart.o
diff --git a/arch/s390/mm/checkpoint.c b/arch/s390/mm/checkpoint.c
new file mode 100644
index 0000000..113c865
--- /dev/null
+++ b/arch/s390/mm/checkpoint.c
@@ -0,0 +1,125 @@
+/*
+ *  Checkpoint/restart - architecture specific support for s390
+ *
+ *  Copyright IBM Corp. 2009
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/kernel.h>
+#include <asm/system.h>
+#include <asm/pgtable.h>
+
+#include "checkpoint_s390.h"
+
+void cr_s390_regs(int op, struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	struct pt_regs *regs = task_pt_regs(t);
+	struct thread_struct *thr = &t->thread;
+
+	/* Save the whole PSW to facilitate forensic debugging, but only
+	 * restore the address portion to avoid letting userspace do
+	 * bad things by manipulating its value.
+	 */
+	if (op == CR_CPT) {
+		CR_COPY(op, hh->psw_t_addr, regs->psw.addr);
+	} else {
+		regs->psw.addr &= ~PSW_ADDR_INSN;
+		regs->psw.addr |= hh->psw_t_addr;
+	}
+
+	CR_COPY(op, hh->args[0], regs->args[0]);
+	CR_COPY(op, hh->orig_gpr2, regs->orig_gpr2);
+	CR_COPY(op, hh->svcnr, regs->svcnr);
+	CR_COPY(op, hh->ilc, regs->ilc);
+	CR_COPY(op, hh->ieee_instruction_pointer,
+		thr->ieee_instruction_pointer);
+	CR_COPY(op, hh->psw_t_mask, regs->psw.mask);
+	CR_COPY(op, hh->fpc, thr->fp_regs.fpc);
+	CR_COPY(op, hh->starting_addr, thr->per_info.starting_addr);
+	CR_COPY(op, hh->ending_addr, thr->per_info.ending_addr);
+	CR_COPY(op, hh->address, thr->per_info.lowcore.words.address);
+	CR_COPY(op, hh->perc_atmid, thr->per_info.lowcore.words.perc_atmid);
+	CR_COPY(op, hh->access_id, thr->per_info.lowcore.words.access_id);
+	CR_COPY(op, hh->single_step, thr->per_info.single_step);
+	CR_COPY(op, hh->instruction_fetch, thr->per_info.instruction_fetch);
+
+	CR_COPY_ARRAY(op, hh->gprs, regs->gprs, NUM_GPRS);
+ 	CR_COPY_ARRAY(op, hh->fprs, thr->fp_regs.fprs, NUM_FPRS);
+	CR_COPY_ARRAY(op, hh->acrs, thr->acrs, NUM_ACRS);
+	CR_COPY_ARRAY(op, hh->per_control_regs,
+		      thr->per_info.control_regs.words.cr, NUM_CR_WORDS);
+
+}
+
+void cr_s390_mm(int op, struct cr_hdr_mm_context *hh, struct mm_struct *mm)
+{
+	CR_COPY(op, hh->noexec, mm->context.noexec);
+	CR_COPY(op, hh->has_pgste, mm->context.has_pgste);
+	CR_COPY(op, hh->alloc_pgste, mm->context.alloc_pgste);
+	CR_COPY(op, hh->asce_bits, mm->context.asce_bits);
+	CR_COPY(op, hh->asce_limit, mm->context.asce_limit);
+}
+
+int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
+{
+	return 0;
+}
+
+/* dump the cpu state and registers of a given task */
+int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_cpu *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int ret;
+
+	h.type = CR_HDR_CPU;
+	h.len = sizeof(*hh);
+	h.parent = task_pid_vnr(t);
+
+	cr_s390_regs(CR_CPT, hh, t);
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
+
+/* Write an empty header since it is assumed to be there */
+int cr_write_head_arch(struct cr_ctx *ctx)
+{
+	struct cr_hdr h;
+	struct cr_hdr_head_arch *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int ret;
+
+	h.type = CR_HDR_HEAD_ARCH;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	ret = cr_write_obj(ctx, &h, &hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
+
+int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
+{
+	struct cr_hdr h;
+	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int ret;
+
+	h.type = CR_HDR_MM_CONTEXT;
+	h.len = sizeof(*hh);
+	h.parent = parent;
+
+	cr_s390_mm(CR_CPT, hh, mm);
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
diff --git a/arch/s390/mm/checkpoint_s390.h b/arch/s390/mm/checkpoint_s390.h
new file mode 100644
index 0000000..52a5e6f
--- /dev/null
+++ b/arch/s390/mm/checkpoint_s390.h
@@ -0,0 +1,22 @@
+/*
+ *  Checkpoint/restart - architecture specific support for s390
+ *
+ *  Copyright IBM Corp. 2009
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#ifndef _S390_CHECKPOINT_H
+#define _S390_CHECKPOINT_H
+
+#include <linux/checkpoint_hdr.h>
+#include <linux/sched.h>
+#include <linux/mm_types.h>
+
+extern void cr_s390_regs(int op, struct cr_hdr_cpu *hh, struct task_struct *t);
+extern void cr_s390_mm(int op, struct cr_hdr_mm_context *hh,
+		       struct mm_struct *mm);
+
+#endif /* _S390_CHECKPOINT_H */
diff --git a/arch/s390/mm/restart.c b/arch/s390/mm/restart.c
new file mode 100644
index 0000000..7da4111
--- /dev/null
+++ b/arch/s390/mm/restart.c
@@ -0,0 +1,81 @@
+/*
+ *  Checkpoint/restart - architecture specific support for s390
+ *
+ *  Copyright IBM Corp. 2009
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/kernel.h>
+#include <asm/system.h>
+#include <asm/pgtable.h>
+
+#include "checkpoint_s390.h"
+
+int cr_read_thread(struct cr_ctx *ctx)
+{
+	return 0;
+}
+
+int cr_read_cpu(struct cr_ctx *ctx)
+{
+	struct cr_hdr_cpu *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int parent, ret;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_CPU);
+	if  (parent < 0) {
+		ret = parent;
+		goto out;
+	}
+	ret = 0;
+
+	cr_s390_regs(CR_RST, hh, current);
+
+	/* s390 does not restore the access registers after a syscall,
+	 * but does on a task switch.  Since we're switching tasks (in
+	 * a way), we need to replicate that behavior here.
+	 */
+	restore_access_regs(hh->acrs);
+out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+int cr_read_head_arch(struct cr_ctx *ctx)
+{
+	struct cr_hdr_head_arch *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int parent, ret = 0;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_HEAD_ARCH);
+	if (parent < 0)
+		ret = parent;
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
+
+
+int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int rparent)
+{
+	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int parent, ret = -EINVAL;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM_CONTEXT);
+	if (parent < 0) {
+		ret = parent;
+		goto out;
+	}
+	if (parent != rparent)
+		goto out;
+
+	cr_s390_mm(CR_RST, hh, mm);
+	ret = 0;
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
index ffaa635..cb1d29d 100644
--- a/checkpoint/Kconfig
+++ b/checkpoint/Kconfig
@@ -1,7 +1,7 @@
 config CHECKPOINT_RESTART
 	prompt "Enable checkpoint/restart (EXPERIMENTAL)"
 	def_bool n
-	depends on X86_32 && EXPERIMENTAL
+	depends on (X86_32 || (S390 && 64BIT)) && EXPERIMENTAL
 	help
 	  Application checkpoint/restart is the ability to save the
 	  state of a running application so that it can later resume
-- 
1.6.1
