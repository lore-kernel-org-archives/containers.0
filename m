From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH] c/r: define s390-specific checkpoint-restart code
Date: Fri, 16 Jan 2009 11:36:33 -0600
Message-ID: <20090116173633.GB8477@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936143AbZAPRqg@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: Linux Containers <containers@lists.osdl.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Mike Waychison <mikew@google.com>, Oren Laadan <orenl@cs.columbia.edu>, Andrew Morton <akpm@osdl.org>, linux-s390@vger.kernel.org, linux390@de.ibm.com
List-Id: containers.vger.kernel.org

Implement the s390 arch-specific checkpoint/restart helpers.  This
is on top of Oren Laadan's c/r code (which so far was x86_32-only)
submitted here: http://lkml.org/lkml/2008/12/29/38, plus two more
patches by Nathan Lynch to fix some 64-bit issues (see
https://lists.linux-foundation.org/pipermail/containers/2009-January/015313.html
and
https://lists.linux-foundation.org/pipermail/containers/2009-January/015314.html
).

With these, I am able to checkpoint and restart simple programs as per
Oren's patch intro.  While on x86 I never had to freeze a single task
to checkpoint it, on s390 I do need to.  That is a prereq for consistent
snapshots (esp with multiple processes) anyway so I don't see that as
a problem.

Oren, should we be putting a byte at the front of the format to
specify the architecture?

Changelog:
	Jan 15: Stopped restoring ksp and vdso_base

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 arch/s390/include/asm/checkpoint_hdr.h |   59 +++++++++++++++
 arch/s390/include/asm/unistd.h         |    4 -
 arch/s390/kernel/compat_wrapper.S      |   12 +++
 arch/s390/kernel/syscalls.S            |    2 
 arch/s390/mm/Makefile                  |    1 
 arch/s390/mm/checkpoint.c              |  122 +++++++++++++++++++++++++++++++++
 checkpoint/Kconfig                     |    2 
 checkpoint/checkpoint.c                |    2 
 checkpoint/restart.c                   |    2 
 9 files changed, 204 insertions(+), 2 deletions(-)
 create mode 100644 arch/s390/include/asm/checkpoint_hdr.h
 create mode 100644 arch/s390/mm/checkpoint.c

diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
new file mode 100644
index 0000000..3029923
--- /dev/null
+++ b/arch/s390/include/asm/checkpoint_hdr.h
@@ -0,0 +1,59 @@
+#ifndef __ASM_S390_CKPT_HDR_H
+#define __ASM_S390_CKPT_HDR_H
+/*
+ *  Checkpoint/restart - architecture specific headers s/390
+ *
+ *  Copyright (C) 2008 Oren Laadan
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
+ * Quoting Arnd Bergmann:
+ *   "This structure has an odd multiple of 32-bit members, which means
+ *   that if you put it into a larger structure that also contains 64-bit
+ *   members, the larger structure may get different alignment on x86-32
+ *   and x86-64, which you might want to avoid. I can't tell if this is
+ *   an actual problem here. ... In this case, I'm pretty sure that
+ *   sizeof(cr_hdr_task) on x86-32 is different from x86-64, since it
+ *   will be 32-bit aligned on x86-32."
+ */
+
+#ifdef __KERNEL__
+#include <asm/processor.h>
+#else
+#include <sys/user.h>
+#endif
+
+/*
+ * Notes
+ * NUM_GPRS defined in <asm/ptrace.h> to be 16
+ * NUM_FPRS defined in <asm/ptrace.h> to be 16
+ * NUM_APRS defined in <asm/ptrace.h> to be 16
+ */
+struct cr_hdr_cpu {
+	psw_t psw;
+	unsigned long args[1];
+	s390_fp_regs fp_regs;
+	unsigned long gprs[NUM_GPRS];
+	unsigned long orig_gpr2;
+	unsigned short svcnr;
+	unsigned short ilc;
+	unsigned int acrs[NUM_ACRS];
+	unsigned long ksp;
+	unsigned long prot_addr;
+	unsigned int trap_no;
+	per_struct per_info;
+	unsigned long ieee_instruction_pointer;
+	unsigned long pfault_wait;
+};
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
index 2a74581..b3f0f32 100644
--- a/arch/s390/mm/Makefile
+++ b/arch/s390/mm/Makefile
@@ -6,3 +6,4 @@ obj-y	 := init.o fault.o extmem.o mmap.o vmem.o pgtable.o
 obj-$(CONFIG_CMM) += cmm.o
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
 obj-$(CONFIG_PAGE_STATES) += page-states.o
+obj-$(CONFIG_CHECKPOINT_RESTART) += checkpoint.o
diff --git a/arch/s390/mm/checkpoint.c b/arch/s390/mm/checkpoint.c
new file mode 100644
index 0000000..076a0a3
--- /dev/null
+++ b/arch/s390/mm/checkpoint.c
@@ -0,0 +1,122 @@
+/*
+ *  Checkpoint/restart - architecture specific support for s390
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/kernel.h>
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
+	memcpy(&hh->psw, &regs->psw, sizeof(psw_t));
+	hh->args[0] = regs->args[0];
+	hh->svcnr = regs->svcnr;
+	hh->ilc = regs->ilc;
+	memcpy(hh->gprs, regs->gprs, NUM_GPRS*sizeof(unsigned long));
+	hh->orig_gpr2 = regs->orig_gpr2;
+
+	memcpy(&hh->fp_regs, &thread->fp_regs, sizeof(s390_fp_regs));
+	memcpy(hh->acrs, thread->acrs, NUM_ACRS * sizeof(unsigned int));
+	hh->prot_addr = thread->prot_addr;
+	hh->trap_no = thread->trap_no;
+	memcpy(&hh->per_info, &thread->per_info, sizeof(per_struct));
+	hh->ieee_instruction_pointer = thread->ieee_instruction_pointer;
+	hh->pfault_wait = thread->pfault_wait;
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
+	return 0;
+}
+
+/* restart APIs */
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
+	regs->psw.addr |= hh->psw.addr & PSW_ADDR_INSN;
+	regs->args[0] = hh->args[0];
+	regs->svcnr = hh->svcnr;
+	regs->ilc = hh->ilc;
+	memcpy(regs->gprs, hh->gprs, NUM_GPRS*sizeof(unsigned long));
+	regs->orig_gpr2 = hh->orig_gpr2;
+
+	memcpy(&thread->fp_regs, &hh->fp_regs, sizeof(s390_fp_regs));
+	memcpy(thread->acrs, hh->acrs, NUM_ACRS * sizeof(unsigned int));
+	thread->prot_addr = hh->prot_addr;
+	thread->trap_no = hh->trap_no;
+	memcpy(&thread->per_info, &hh->per_info, sizeof(per_struct));
+	thread->ieee_instruction_pointer = hh->ieee_instruction_pointer;
+	thread->pfault_wait = hh->pfault_wait;
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
+int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int rparent)
+{
+	return 0;
+}
diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
index ffaa635..31e7594 100644
--- a/checkpoint/Kconfig
+++ b/checkpoint/Kconfig
@@ -1,7 +1,7 @@
 config CHECKPOINT_RESTART
 	prompt "Enable checkpoint/restart (EXPERIMENTAL)"
 	def_bool n
-	depends on X86_32 && EXPERIMENTAL
+	depends on (X86_32 || S390) && EXPERIMENTAL
 	help
 	  Application checkpoint/restart is the ability to save the
 	  state of a running application so that it can later resume
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index fbcd9eb..06e15fc 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -8,6 +8,8 @@
  *  distribution for more details.
  */
 
+#define DEBUG 1
+
 #include <linux/version.h>
 #include <linux/sched.h>
 #include <linux/ptrace.h>
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 6b4cd75..f65a63e 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -8,6 +8,8 @@
  *  distribution for more details.
  */
 
+#define DEBUG 1
+
 #include <linux/version.h>
 #include <linux/sched.h>
 #include <linux/wait.h>
