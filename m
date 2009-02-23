From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] c/r: define s390-specific checkpoint-restart code (v4)
Date: Mon, 23 Feb 2009 16:39:03 -0500
Message-ID: <1235425143-9949-1-git-send-email-danms@us.ibm.com>
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

Implement the s390 arch-specific checkpoint/restart helpers.  This
is on top of Oren Laadan's c/r code.

With these, I am able to checkpoint and restart simple programs as per
Oren's patch intro.  While on x86 I never had to freeze a single task
to checkpoint it, on s390 I do need to.  That is a prereq for consistent
snapshots (esp with multiple processes) anyway so I don't see that as
a problem.

Changelog:
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

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/include/asm/checkpoint_hdr.h |   99 +++++++++++++++++++++++++++
 arch/s390/include/asm/unistd.h         |    4 +-
 arch/s390/kernel/compat_wrapper.S      |   12 +++
 arch/s390/kernel/syscalls.S            |    2 +
 arch/s390/mm/Makefile                  |    1 +
 arch/s390/mm/checkpoint.c              |  106 +++++++++++++++++++++++++++++
 arch/s390/mm/restart.c                 |  117 ++++++++++++++++++++++++++++++++
 checkpoint/Kconfig                     |    2 +-
 8 files changed, 341 insertions(+), 2 deletions(-)
 create mode 100644 arch/s390/include/asm/checkpoint_hdr.h
 create mode 100644 arch/s390/mm/checkpoint.c
 create mode 100644 arch/s390/mm/restart.c

diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
new file mode 100644
index 0000000..6f19cfe
--- /dev/null
+++ b/arch/s390/include/asm/checkpoint_hdr.h
@@ -0,0 +1,99 @@
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
+
+/*
+ * To maintain compatibility between 32-bit and 64-bit architecture flavors,
+ * keep data 64-bit aligned: use padding for structure members, and use
+ * __attribute__((aligned (8))) for the entire structure.
+ *
+ */
+
+#ifdef __KERNEL__
+#include <asm/processor.h>
+#else
+#include <sys/user.h>
+#endif
+
+#ifdef __s390x__
+
+#define CR_390_PACK_TRACE_FLAGS(hdr, thread)	\
+  do {						\
+    hdr->em_instr = 0;				\
+    if (thread->per_info.single_step)		\
+      hdr->em_instr |= 1;			\
+    if (thread->per_info.instruction_fetch)	\
+      hdr->em_instr |= 2;			\
+} while (0)
+
+#define CR_390_UNPACK_TRACE_FLAGS(hdr, thread)	\
+  do {						\
+    if (hdr->em_instr & 1)			\
+      thread->per_info.single_step = 1;		\
+    if (hdr->em_instr & 2)			\
+      thread->per_info.instruction_fetch = 1;	\
+  } while (0)
+
+/*
+ * Notes
+ * NUM_GPRS defined in <asm/ptrace.h> to be 16
+ * NUM_FPRS defined in <asm/ptrace.h> to be 16
+ * NUM_APRS defined in <asm/ptrace.h> to be 16
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
+	struct {
+		float f;
+		double d;
+		__u64 ui;
+		__u32 fp_hi;
+		__u32 fp_lo;
+	} fprs[NUM_FPRS];
+
+	/* per_struct */
+	__u64 per_control_regs[3];
+	__u32 em_instr;
+	__u64 starting_addr;
+	__u64 ending_addr;
+	__u16 perc_atmid;
+	__u64 address;
+	__u8 access_id;
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
index 0000000..a588dc9
--- /dev/null
+++ b/arch/s390/mm/checkpoint.c
@@ -0,0 +1,106 @@
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
+int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
+{
+	return 0;
+}
+
+static void cr_save_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
+
+	hh->fpc = thread->fp_regs.fpc;
+	memcpy(&hh->fprs, &thread->fp_regs.fprs, NUM_FPRS*sizeof(freg_t));
+	memcpy(hh->acrs, &thread->acrs[0], NUM_ACRS * sizeof(unsigned int));
+	hh->psw_t_mask = regs->psw.mask;
+	hh->psw_t_addr = regs->psw.addr;
+
+	hh->args[0] = regs->args[0];
+	hh->svcnr = regs->svcnr;
+	hh->ilc = regs->ilc;
+	memcpy(hh->gprs, regs->gprs, NUM_GPRS*sizeof(unsigned long));
+	hh->orig_gpr2 = regs->orig_gpr2;
+
+	hh->ieee_instruction_pointer = thread->ieee_instruction_pointer;
+
+	/* per_info */
+	memcpy(&hh->per_control_regs, &thread->per_info.control_regs.words,
+		3 * sizeof(unsigned long));
+	CR_390_PACK_TRACE_FLAGS(hh, thread);
+	hh->starting_addr = thread->per_info.starting_addr;
+	hh->ending_addr = thread->per_info.ending_addr;
+	hh->perc_atmid = thread->per_info.lowcore.words.perc_atmid;
+	hh->address = thread->per_info.lowcore.words.address;
+	hh->access_id = thread->per_info.lowcore.words.access_id;
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
+	cr_save_cpu_regs(hh, t);
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	WARN_ON_ONCE(ret < 0);
+
+	return ret;
+}
+
+int cr_write_head_arch(struct cr_ctx *ctx)
+{
+	return 0;
+}
+
+/* Nothing to do for mm context state */
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
+#if 0
+	/* Oren's v13 is on an older kernel which has no vdso_base */
+	/* on newer kernel, we'll have to enable this */
+	hh->vdso_base = mm->context.vdso_base;
+	pr_debug(KERN_NOTICE "checkpointing vdso_base %lx\n", hh->vdso_base);
+#else
+	hh->vdso_base = 0;
+#endif
+	hh->noexec = mm->context.noexec;
+	hh->has_pgste = mm->context.has_pgste;
+	hh->alloc_pgste = mm->context.alloc_pgste;
+	hh->asce_bits = mm->context.asce_bits;
+	hh->asce_limit = mm->context.asce_limit;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
diff --git a/arch/s390/mm/restart.c b/arch/s390/mm/restart.c
new file mode 100644
index 0000000..32b1b15
--- /dev/null
+++ b/arch/s390/mm/restart.c
@@ -0,0 +1,117 @@
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
+int cr_read_thread(struct cr_ctx *ctx)
+{
+	return 0;
+}
+
+int cr_read_cpu(struct cr_ctx *ctx)
+{
+	struct cr_hdr_cpu *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct thread_struct *thread = &current->thread;
+	struct pt_regs *regs = task_pt_regs(current);
+	int parent, ret;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_CPU);
+	if  (parent < 0) {
+		ret = parent;
+		goto out;
+	}
+	ret = 0;
+
+	regs->psw.addr &= ~PSW_ADDR_INSN;
+	regs->psw.addr |= hh->psw_t_addr & PSW_ADDR_INSN;
+
+	regs->args[0] = hh->args[0];
+
+	/* ilc is syscall restart addr.  it looks like we must
+	  restore it since we restore psw.addr */
+	regs->ilc = hh->ilc;
+	memcpy(regs->gprs, hh->gprs, NUM_GPRS*sizeof(unsigned long));
+	regs->orig_gpr2 = hh->orig_gpr2;
+	/* svcnr is the current system call.  but it's on ptregs so
+	   restore it */
+	regs->svcnr = hh->svcnr;
+
+	memcpy(thread->acrs, hh->acrs, NUM_ACRS * sizeof(unsigned int));
+	restore_access_regs(thread->acrs);
+
+	/* ieee_instruction_pointer points to a faulting address
+	   on FPE.  restore it (for ptrace) */
+	thread->ieee_instruction_pointer = hh->ieee_instruction_pointer;
+
+	/* s390_fp_regs_t */
+	thread->fp_regs.fpc = hh->fpc;
+	memcpy(&thread->fp_regs.fprs, &hh->fprs, NUM_FPRS*sizeof(freg_t));
+
+	/* per_struct - restore it */
+	memcpy(&thread->per_info.control_regs.words, &hh->per_control_regs,
+		3 * sizeof(unsigned long));
+	CR_390_UNPACK_TRACE_FLAGS(hh, thread);
+	thread->per_info.starting_addr = hh->starting_addr;
+	thread->per_info.ending_addr = hh->ending_addr;
+	thread->per_info.lowcore.words.perc_atmid = hh->perc_atmid;
+	thread->per_info.lowcore.words.address = hh->address;
+	thread->per_info.lowcore.words.access_id = hh->access_id;
+
+out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+int cr_read_head_arch(struct cr_ctx *ctx)
+{
+	return 0;
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
+#if 0
+	/* enable  this when s390 defines vdso-base */
+	mm->context.vdso_base = hh->vdso_base;
+	pr_debug("read vdso_base %lx\n", hh->vdso_base);
+#endif
+	pr_debug("i had  nx %d haspgste %d apgste %d bits %lx limit %lx\n",
+		 mm->context.noexec, mm->context.has_pgste,
+		 mm->context.alloc_pgste, mm->context.asce_bits,
+		 mm->context.asce_limit);
+	mm->context.noexec = hh->noexec;
+	mm->context.has_pgste = hh->has_pgste;
+	mm->context.alloc_pgste = hh->alloc_pgste;
+	mm->context.asce_limit = hh->asce_limit;
+	mm->context.asce_bits = hh->asce_bits;
+	pr_debug("restoring nx %d haspgste %d apgste %d bits %lx limit %lx\n",
+		 hh->noexec, hh->has_pgste, hh->alloc_pgste,
+		 hh->asce_bits, hh->asce_limit);
+	ret = 0;
+
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
