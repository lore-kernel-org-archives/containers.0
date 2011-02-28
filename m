From: ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
Subject: [PATCH 10/10] x86_32 support for checkpoint/restart
Date: Mon, 28 Feb 2011 17:40:32 -0600
Message-ID: <1298936432-29607-11-git-send-email-ntl__35091.6294999935$1298937221$gmane$org@pobox.com>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1298936432-29607-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Add logic to save and restore architecture specific state, including
thread-specific state, CPU registers and FPU state.

In addition, architecture capabilities are saved in an architecture
specific extension of the header (ckpt_hdr_head_arch).

Based on original code by Oren Laadan.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
[ntl: aggregated arch/x86 bits spread through various c/r patches]
Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 arch/x86/Kconfig                   |    4 +
 arch/x86/include/asm/checkpoint.h  |   17 +
 arch/x86/include/asm/elf.h         |    5 +
 arch/x86/include/asm/ldt.h         |    7 +
 arch/x86/include/asm/unistd_32.h   |    4 +-
 arch/x86/kernel/Makefile           |    2 +
 arch/x86/kernel/checkpoint.c       |  677 ++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/syscall_table_32.S |    2 +
 arch/x86/vdso/vdso32-setup.c       |   25 ++-
 9 files changed, 738 insertions(+), 5 deletions(-)
 create mode 100644 arch/x86/include/asm/checkpoint.h
 create mode 100644 arch/x86/kernel/checkpoint.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index e330da2..7a2a64d 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -101,6 +101,10 @@ config STACKTRACE_SUPPORT
 config HAVE_LATENCYTOP_SUPPORT
 	def_bool y
 
+config CHECKPOINT_SUPPORT
+	bool
+	default y if X86_32
+
 config MMU
 	def_bool y
 
diff --git a/arch/x86/include/asm/checkpoint.h b/arch/x86/include/asm/checkpoint.h
new file mode 100644
index 0000000..334d3be
--- /dev/null
+++ b/arch/x86/include/asm/checkpoint.h
@@ -0,0 +1,17 @@
+#ifndef __ASM_X86_CKPT_HDR_H
+#define __ASM_X86_CKPT_HDR_H
+/*
+ *  Checkpoint/restart - architecture specific headers x86
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#ifdef CONFIG_X86_32
+#define CKPT_ARCH_ID	CKPT_ARCH_X86_32
+#endif
+
+#endif /* __ASM_X86_CKPT_HDR__H */
diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index f2ad216..8a6c45e 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -320,4 +320,9 @@ extern int syscall32_setup_pages(struct linux_binprm *, int exstack);
 extern unsigned long arch_randomize_brk(struct mm_struct *mm);
 #define arch_randomize_brk arch_randomize_brk
 
+#ifdef CONFIG_X86_32
+#define arch_restore_vdso arch_restore_vdso
+extern int arch_restore_vdso(unsigned long addr);
+#endif /* CONFIG_X86_32 */
+
 #endif /* _ASM_X86_ELF_H */
diff --git a/arch/x86/include/asm/ldt.h b/arch/x86/include/asm/ldt.h
index 46727eb..f2845f9 100644
--- a/arch/x86/include/asm/ldt.h
+++ b/arch/x86/include/asm/ldt.h
@@ -37,4 +37,11 @@ struct user_desc {
 #define MODIFY_LDT_CONTENTS_CODE	2
 
 #endif /* !__ASSEMBLY__ */
+
+#ifdef __KERNEL__
+#include <linux/linkage.h>
+asmlinkage int sys_modify_ldt(int func, void __user *ptr,
+			      unsigned long bytecount);
+#endif
+
 #endif /* _ASM_X86_LDT_H */
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index b766a5e..a2d589f 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -346,10 +346,12 @@
 #define __NR_fanotify_init	338
 #define __NR_fanotify_mark	339
 #define __NR_prlimit64		340
+#define __NR_checkpoint		341
+#define __NR_restart		342
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 341
+#define NR_syscalls 343
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 1e99475..f44a19d 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -111,6 +111,8 @@ obj-$(CONFIG_X86_CHECK_BIOS_CORRUPTION) += check.o
 
 obj-$(CONFIG_SWIOTLB)			+= pci-swiotlb.o
 
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
+
 ###
 # 64 bit specific files
 ifeq ($(CONFIG_X86_64),y)
diff --git a/arch/x86/kernel/checkpoint.c b/arch/x86/kernel/checkpoint.c
new file mode 100644
index 0000000..ecb458a
--- /dev/null
+++ b/arch/x86/kernel/checkpoint.c
@@ -0,0 +1,677 @@
+/*
+ *  Checkpoint/restart - architecture specific support for x86
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/checkpoint.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/preempt.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+
+#include <asm/checkpoint.h>
+#include <asm/desc_defs.h>
+#include <asm/desc.h>
+#include <asm/i387.h>
+#include <asm/ldt.h>
+#include <asm/syscalls.h>
+#include <asm/thread_info.h>
+
+/* arch dependent header types */
+enum {
+	CKPT_HDR_CPU_FPU = 201,
+#define CKPT_HDR_CPU_FPU CKPT_HDR_CPU_FPU
+	CKPT_HDR_MM_CONTEXT_LDT,
+#define CKPT_HDR_MM_CONTEXT_LDT CKPT_HDR_MM_CONTEXT_LDT
+};
+
+struct ckpt_hdr_header_arch {
+	struct ckpt_hdr h;
+	/* FIXME: add HAVE_HWFP */
+	__u16 has_fxsr;
+	__u16 has_xsave;
+	__u16 xstate_size;
+};
+
+struct ckpt_hdr_thread {
+	struct ckpt_hdr h;
+	__u32 thread_info_flags;
+	__u16 gdt_entry_tls_entries;
+	__u16 sizeof_tls_array;
+};
+
+/* designed to work for both x86_32 and x86_64 */
+struct ckpt_hdr_cpu {
+	struct ckpt_hdr h;
+	/* see struct pt_regs (x86_64) */
+	__u64 r15;
+	__u64 r14;
+	__u64 r13;
+	__u64 r12;
+	__u64 bp;
+	__u64 bx;
+	__u64 r11;
+	__u64 r10;
+	__u64 r9;
+	__u64 r8;
+	__u64 ax;
+	__u64 cx;
+	__u64 dx;
+	__u64 si;
+	__u64 di;
+	__u64 orig_ax;
+	__u64 ip;
+	__u64 sp;
+
+	__u64 flags;
+
+	/* segment registers */
+	__u64 fs;
+	__u64 gs;
+
+	__u16 fsindex;
+	__u16 gsindex;
+	__u16 cs;
+	__u16 ss;
+	__u16 ds;
+	__u16 es;
+
+	__u32 used_math;
+
+	/* thread_xstate contents follow (if used_math) */
+};
+
+#define CKPT_X86_SEG_NULL	0
+#define CKPT_X86_SEG_USER32_CS	1
+#define CKPT_X86_SEG_USER32_DS	2
+#define CKPT_X86_SEG_TLS	0x4000	/* 0100 0000 0000 00xx */
+#define CKPT_X86_SEG_LDT	0x8000	/* 100x xxxx xxxx xxxx */
+
+struct ckpt_hdr_mm_context {
+	struct ckpt_hdr h;
+	__u64 vdso;
+	__u32 ldt_entry_size;
+	__u32 nldt;
+};
+
+#ifdef CONFIG_X86_32
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
+static void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
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
+	_gs = task_user_gs(t);
+
+	h->fsindex = encode_segment(regs->fs);
+	h->gsindex = encode_segment(_gs);
+}
+
+asmlinkage void ret_from_fork(void);
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
+	thread->sp = (unsigned long)regs;
+	thread->sp0 = (unsigned long)(regs + 1);
+	thread->ip = (unsigned long)ret_from_fork;
+	thread->gs = regs->gs;
+	lazy_load_gs(regs->gs);
+
+	return 0;
+}
+
+#endif /* CONFIG_X86_32 */
+
+static int check_tls(struct desc_struct *desc)
+{
+	if (!desc->a && !desc->b)
+		return 1;
+	if (desc->l != 0 || desc->s != 1 || desc->dpl != 3)
+		return 0;
+	return 1;
+}
+
+#define CKPT_X86_TIF_UNSUPPORTED   (_TIF_SECCOMP | _TIF_IO_BITMAP)
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+static int may_checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+#ifdef CONFIG_X86_32
+	if (t->thread.vm86_info) {
+		ckpt_debug("Task in VM86 mode\n");
+		return -EBUSY;
+	}
+#endif
+
+	/* debugregs not (yet) supported */
+	if (test_tsk_thread_flag(t, TIF_DEBUG)) {
+		ckpt_debug("Task with debugreg set\n");
+		return -EBUSY;
+	}
+
+	if (task_thread_info(t)->flags & CKPT_X86_TIF_UNSUPPORTED) {
+		ckpt_debug("Bad thread info flags %#lx\n",
+			 (unsigned long)task_thread_info(t)->flags);
+		return -EBUSY;
+	}
+	return 0;
+}
+
+/* dump the thread_struct of a given task */
+int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_thread *h;
+	int tls_size;
+	int ret;
+
+	BUG_ON(t == current);
+
+	ret = may_checkpoint_thread(ctx, t);
+	if (ret < 0)
+		return ret;
+
+	tls_size = sizeof(t->thread.tls_array);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h) + tls_size, CKPT_HDR_THREAD);
+	if (!h)
+		return -ENOMEM;
+
+	h->thread_info_flags =
+		task_thread_info(t)->flags & ~CKPT_X86_TIF_UNSUPPORTED;
+	h->gdt_entry_tls_entries = GDT_ENTRY_TLS_ENTRIES;
+	h->sizeof_tls_array = tls_size;
+
+	/* For simplicity dump the entire array */
+	memcpy(h + 1, t->thread.tls_array, tls_size);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	kfree(h);
+	return ret;
+}
+
+static void save_cpu_fpu(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	h->used_math = tsk_used_math(t) ? 1 : 0;
+}
+
+static int checkpoint_cpu_fpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, xstate_size + sizeof(*h),
+			      CKPT_HDR_CPU_FPU);
+	if (!h)
+		return -ENOMEM;
+
+	/*
+	 * For simplicity dump the entire structure.
+	 * FIX: need to be deliberate about what registers we are
+	 * dumping for traceability and compatibility.
+	 */
+	memcpy(h + 1, t->thread.fpu.state, xstate_size);
+
+	ret = ckpt_write_obj(ctx, h);
+	kfree(h);
+
+	return ret;
+}
+
+/* dump the cpu state and registers of a given task */
+int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_cpu *h;
+	int ret;
+
+	BUG_ON(t == current);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CPU);
+	if (!h)
+		return -ENOMEM;
+
+	save_cpu_regs(h, t);
+	save_cpu_fpu(h, t);
+
+	ckpt_debug("math %d\n", h->used_math);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	if (h->used_math)
+		ret = checkpoint_cpu_fpu(ctx, t);
+ out:
+	kfree(h);
+	return ret;
+}
+
+int checkpoint_write_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_HEADER_ARCH);
+	if (!h)
+		return -ENOMEM;
+
+	/* FPU capabilities */
+	h->has_fxsr = cpu_has_fxsr;
+	h->has_xsave = cpu_has_xsave;
+	h->xstate_size = xstate_size;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	kfree(h);
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
+	BUG_ON(mm == current->mm);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_MM_CONTEXT);
+	if (!h)
+		return -ENOMEM;
+
+	mutex_lock(&mm->context.lock);
+
+	h->vdso = (unsigned long) mm->context.vdso;
+	h->ldt_entry_size = LDT_ENTRY_SIZE;
+	h->nldt = mm->context.size;
+
+	ckpt_debug("nldt %d vdso %#llx\n", h->nldt, h->vdso);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	kfree(h);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj_type(ctx, mm->context.ldt,
+				  mm->context.size * LDT_ENTRY_SIZE,
+				  CKPT_HDR_MM_CONTEXT_LDT);
+ out:
+	mutex_unlock(&mm->context.lock);
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
+	struct thread_struct *thread = &current->thread;
+	struct desc_struct *desc;
+	int tls_size;
+	int i, cpu, ret;
+
+	tls_size = sizeof(thread->tls_array);
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h) + tls_size, CKPT_HDR_THREAD);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->thread_info_flags & CKPT_X86_TIF_UNSUPPORTED)
+		goto out;
+	if (h->gdt_entry_tls_entries != GDT_ENTRY_TLS_ENTRIES)
+		goto out;
+	if (h->sizeof_tls_array != tls_size)
+		goto out;
+
+	/*
+	 * restore TLS by hand: why convert to struct user_desc if
+	 * sys_set_thread_entry() will convert it back ?
+	 */
+	desc = (struct desc_struct *) (h + 1);
+
+	for (i = 0; i < GDT_ENTRY_TLS_ENTRIES; i++) {
+		if (!check_tls(&desc[i]))
+			goto out;
+	}
+
+	cpu = get_cpu();
+	memcpy(thread->tls_array, desc, tls_size);
+	load_TLS(thread, cpu);
+	put_cpu();
+
+	/* TODO: restore TIF flags as necessary (e.g. TIF_NOTSC) */
+
+	ret = 0;
+ out:
+	kfree(h);
+	return ret;
+}
+
+static int load_cpu_fpu(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	__clear_fpu(t);		/* in case we used FPU in user mode */
+
+	if (!h->used_math)
+		clear_used_math();
+
+	return 0;
+}
+
+static int restore_cpu_fpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr *h;
+	int ret;
+
+	/* init_fpu() eventually also calls set_used_math() */
+	ret = init_fpu(current);
+	if (ret < 0)
+		return ret;
+
+	h = ckpt_read_obj_type(ctx, xstate_size + sizeof(*h),
+			       CKPT_HDR_CPU_FPU);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	memcpy(t->thread.fpu.state, h + 1, xstate_size);
+
+	kfree(h);
+	return ret;
+}
+
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
+	 */
+	eflags |= (regs->flags & X86_EFLAGS_RF);
+	regs->flags = eflags;
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
+
+/* read the cpu state and registers for a restarting task */
+int restore_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_cpu *h;
+	int ret;
+
+	BUG_ON(t == current);
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CPU);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ckpt_debug("math %d\n", h->used_math);
+
+	ret = load_cpu_regs(h, t);
+	if (ret < 0)
+		goto out;
+	ret = load_cpu_eflags(h, t);
+	if (ret < 0)
+		goto out;
+	ret = load_cpu_fpu(h, t);
+	if (ret < 0)
+		goto out;
+
+	if (h->used_math)
+		ret = restore_cpu_fpu(ctx, t);
+ out:
+	kfree(h);
+	return ret;
+}
+
+int restore_read_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *h;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_HEADER_ARCH);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	/* FIX: verify compatibility of architecture features */
+
+	/* verify FPU capabilities */
+	if (h->has_fxsr != cpu_has_fxsr ||
+	    h->has_xsave != cpu_has_xsave ||
+	    h->xstate_size != xstate_size) {
+		ret = -EINVAL;
+		ckpt_debug("incompatible FPU capabilities");
+	}
+
+	kfree(h);
+	return ret;
+}
+
+int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct ckpt_hdr_mm_context *h;
+	unsigned int n;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_MM_CONTEXT);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ckpt_debug("nldt %d vdso %#lx (%p)\n",
+		 h->nldt, (unsigned long) h->vdso, mm->context.vdso);
+
+	/* FIXME: CONFIG_COMPAT_VDSO=y makes this fail */
+	ret = -EINVAL;
+	if (h->vdso != (unsigned long) mm->context.vdso)
+		goto out;
+	if (h->ldt_entry_size != LDT_ENTRY_SIZE)
+		goto out;
+
+	ret = _ckpt_read_obj_type(ctx, NULL,
+				  h->nldt * LDT_ENTRY_SIZE,
+				  CKPT_HDR_MM_CONTEXT_LDT);
+	if (ret < 0)
+		goto out;
+
+	/*
+	 * to utilize the syscall modify_ldt() we first convert the data
+	 * in the checkpoint image from 'struct desc_struct' to 'struct
+	 * user_desc' with reverse logic of include/asm/desc.h:fill_ldt()
+	 */
+	for (n = 0; n < h->nldt; n++) {
+		struct user_desc info;
+		struct desc_struct desc;
+		mm_segment_t old_fs;
+
+		ret = ckpt_kread(ctx, &desc, LDT_ENTRY_SIZE);
+		if (ret < 0)
+			break;
+
+		info.entry_number = n;
+		info.base_addr = desc.base0 | (desc.base1 << 16);
+		info.limit = desc.limit0;
+		info.seg_32bit = desc.d;
+		info.contents = desc.type >> 2;
+		info.read_exec_only = (desc.type >> 1) ^ 1;
+		info.limit_in_pages = desc.g;
+		info.seg_not_present = desc.p ^ 1;
+		info.useable = desc.avl;
+
+		old_fs = get_fs();
+		set_fs(get_ds());
+		ret = sys_modify_ldt(1, (struct user_desc __user *) &info,
+				     sizeof(info));
+		set_fs(old_fs);
+
+		if (ret < 0)
+			break;
+	}
+ out:
+	kfree(h);
+	return ret;
+}
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index b35786d..07f48b6 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -340,3 +340,5 @@ ENTRY(sys_call_table)
 	.long sys_fanotify_init
 	.long sys_fanotify_mark
 	.long sys_prlimit64		/* 340 */
+	.long sys_checkpoint
+	.long sys_restart
diff --git a/arch/x86/vdso/vdso32-setup.c b/arch/x86/vdso/vdso32-setup.c
index 36df991..267aa64 100644
--- a/arch/x86/vdso/vdso32-setup.c
+++ b/arch/x86/vdso/vdso32-setup.c
@@ -309,11 +309,9 @@ int __init sysenter_setup(void)
 	return 0;
 }
 
-/* Setup a VMA at program startup for the vsyscall page */
-int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
+static int __arch_setup_additional_pages(unsigned long addr)
 {
 	struct mm_struct *mm = current->mm;
-	unsigned long addr;
 	int ret = 0;
 	bool compat;
 
@@ -326,12 +324,18 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	   changes it via sysctl */
 	compat = (vdso_enabled == VDSO_COMPAT);
 
+	/* We don't know how to handle compat with sys_restart yet */
+	if (WARN_ON_ONCE(compat && addr != 0)) {
+		ret = -ENOSYS;
+		goto up_fail;
+	}
+
 	map_compat_vdso(compat);
 
 	if (compat)
 		addr = VDSO_HIGH_BASE;
 	else {
-		addr = get_unmapped_area(NULL, 0, PAGE_SIZE, 0, 0);
+		addr = get_unmapped_area(NULL, addr, PAGE_SIZE, 0, 0);
 		if (IS_ERR_VALUE(addr)) {
 			ret = addr;
 			goto up_fail;
@@ -372,6 +376,19 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	return ret;
 }
 
+/* Setup a VMA at program startup for the vsyscall page */
+int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
+{
+	return __arch_setup_additional_pages(0);
+}
+
+#ifdef CONFIG_X86_32
+int arch_restore_vdso(unsigned long addr)
+{
+	return __arch_setup_additional_pages(addr);
+}
+#endif /* CONFIG_X86_32 */
+
 #ifdef CONFIG_X86_64
 
 subsys_initcall(sysenter_setup);
-- 
1.7.4
