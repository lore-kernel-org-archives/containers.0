From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 14/30] cr: x86_64 support
Date: Fri, 10 Apr 2009 06:36:49 +0400
Message-ID: <20090410023649.GO27788__10757.6354909272$1239331874$gmane$org@x200.localdomain>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Now x86 matrix of migration is:

	task/kernel		kernel
	------------------------------
	i386/i386	=>	i386
	i386/i386	=>	x86_64
	i386/x86_64	=>	i386
	i386/x86_64	=>	x86_64
	x86_64/x86_64	=>	x86_64

FIXME: support more that busyloop

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 arch/x86/ia32/ia32entry.S        |    2 
 arch/x86/include/asm/unistd_64.h |    4 
 include/linux/cr.h               |   41 ++++
 kernel/cr/Makefile               |    1 
 kernel/cr/cr-x86_64.c            |  365 +++++++++++++++++++++++++++++++++++++++
 kernel/cr/cr.h                   |    2 
 6 files changed, 414 insertions(+), 1 deletion(-)

--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -830,4 +830,6 @@ ia32_sys_call_table:
 	.quad sys_inotify_init1
 	.quad compat_sys_preadv
 	.quad compat_sys_pwritev
+	.quad sys_checkpoint		/* 335 */
+	.quad sys_restart
 ia32_syscall_end:
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -657,6 +657,10 @@ __SYSCALL(__NR_inotify_init1, sys_inotify_init1)
 __SYSCALL(__NR_preadv, sys_preadv)
 #define __NR_pwritev				296
 __SYSCALL(__NR_pwritev, sys_pwritev)
+#define __NR_checkpoint				297
+__SYSCALL(__NR_checkpoint, sys_checkpoint)
+#define __NR_restart				298
+__SYSCALL(__NR_restart, sys_restart)
 
 
 #ifndef __NO_STUBS
--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -18,6 +18,7 @@ struct cr_image_header {
 	/* Mutable part. */
 	/* Arch of the kernel which dumped the image. */
 #define CR_ARCH_X86_32	1
+#define CR_ARCH_X86_64	2
 	__le32	cr_arch;
 	/*
 	 * Distributions are expected to leave image version alone and
@@ -101,6 +102,46 @@ struct cr_image_arch_x86_32 {
 	/* __u8	cr_xstate[cr_len_xstate]; */
 } __packed;
 
+struct cr_image_arch_x86_64 {
+	__u64		cr_r15;
+	__u64		cr_r14;
+	__u64		cr_r13;
+	__u64		cr_r12;
+	__u64		cr_rbp;
+	__u64		cr_rbx;
+	__u64		cr_r11;
+	__u64		cr_r10;
+	__u64		cr_r9;
+	__u64		cr_r8;
+	__u64		cr_rax;
+	__u64		cr_rcx;
+	__u64		cr_rdx;
+	__u64		cr_rsi;
+	__u64		cr_rdi;
+	__u64		cr_orig_rax;
+	__u64		cr_rip;
+	__u64		cr_rflags;
+	__u64		cr_rsp;
+
+	__u64		cr_fs;
+	__u64		cr_gs;
+	__u16		cr_cs;
+	__u16		cr_ds;
+	__u16		cr_es;
+	__u16		cr_fsindex;
+	__u16		cr_gsindex;
+	__u16		cr_ss;
+
+	__u64		cr_dr0;
+	__u64		cr_dr1;
+	__u64		cr_dr2;
+	__u64		cr_dr3;
+	__u64		cr_dr6;
+	__u64		cr_dr7;
+
+	__u64		cr_tls_array[3];
+} __packed;
+
 struct cr_image_mm_struct {
 	struct cr_object_header cr_hdr;
 
--- a/kernel/cr/Makefile
+++ b/kernel/cr/Makefile
@@ -5,3 +5,4 @@ cr-y += cr-file.o
 cr-y += cr-mm.o
 cr-y += cr-task.o
 cr-$(CONFIG_X86_32) += cr-x86_32.o
+cr-$(CONFIG_X86_64) += cr-x86_64.o
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-x86_64.c
@@ -0,0 +1,365 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/sched.h>
+#include <asm/i387.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+__u32 cr_image_header_arch(void)
+{
+	return CR_ARCH_X86_64;
+}
+
+int cr_arch_check_image_header(struct cr_image_header *i)
+{
+	if (i->cr_arch == cpu_to_le32(CR_ARCH_X86_64))
+		return 0;
+#ifdef CONFIG_COMPAT
+	if (i->cr_arch == cpu_to_le32(CR_ARCH_X86_32))
+		return 0;
+#endif
+	return -EINVAL;
+}
+
+__u32 cr_task_struct_arch(struct task_struct *tsk)
+{
+#ifdef CONFIG_COMPAT
+	if (test_tsk_thread_flag(tsk, TIF_IA32))
+		return CR_ARCH_X86_32;
+#endif
+	return CR_ARCH_X86_64;
+}
+
+int cr_arch_check_image_task_struct(struct cr_image_task_struct *i)
+{
+	if (i->cr_tsk_arch == CR_ARCH_X86_64)
+		return 0;
+#ifdef CONFIG_COMPAT
+	if (i->cr_tsk_arch == CR_ARCH_X86_32)
+		return 0;
+#endif
+	return -EINVAL;
+}
+
+unsigned int cr_arch_len_task_struct(struct task_struct *tsk)
+{
+	unsigned int len;
+
+	len = sizeof(struct cr_image_arch_x86_64);
+#ifdef CONFIG_COMPAT
+	if (test_tsk_thread_flag(tsk, TIF_IA32))
+		len = sizeof(struct cr_image_arch_x86_32);
+#endif
+	return len;
+}
+
+int cr_arch_check_task_struct(struct task_struct *tsk)
+{
+	if (tsk->thread.xstate) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	if (tsk->thread.io_bitmap_ptr) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#ifdef CONFIG_X86_DS
+	if (tsk->thread.ds_ctx) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#endif
+	return 0;
+}
+
+static __u16 encode_segment(u16 reg)
+{
+	if (reg == 0)
+		return CR_SEG_NULL;
+	BUG_ON((reg & 3) != 3);
+	if (reg & 4)
+		return CR_SEG_LDT | (reg >> 3);
+
+	if (reg == __USER_CS)
+		return CR_SEG_USER64_CS;
+	if (reg == __USER_DS)
+		return CR_SEG_USER64_DS;
+#ifdef CONFIG_COMPAT
+	if (reg == __USER32_CS)
+		return CR_SEG_USER32_CS;
+	if (reg == __USER32_DS)
+		return CR_SEG_USER32_DS;
+#endif
+
+	if (GDT_ENTRY_TLS_MIN <= (reg >> 3) && (reg >> 3) <= GDT_ENTRY_TLS_MAX)
+		return CR_SEG_TLS | ((reg >> 3) - GDT_ENTRY_TLS_MIN);
+	BUG();
+}
+
+static u16 decode_segment(__u16 reg)
+{
+	if (reg == CR_SEG_NULL)
+		return 0;
+
+	if (reg == CR_SEG_USER64_CS)
+		return __USER_CS;
+	if (reg == CR_SEG_USER64_DS)
+		return __USER_DS;
+#ifdef CONFIG_COMPAT
+	if (reg == CR_SEG_USER32_CS)
+		return __USER32_CS;
+	if (reg == CR_SEG_USER32_DS)
+		return __USER32_DS;
+#endif
+
+	BUILD_BUG_ON(GDT_ENTRY_TLS_MAX - GDT_ENTRY_TLS_MIN + 1 != 3);
+	if ((reg & CR_SEG_TLS) == CR_SEG_TLS) {
+		reg &= ~CR_SEG_TLS;
+		if (reg <= GDT_ENTRY_TLS_MAX - GDT_ENTRY_TLS_MIN)
+			return ((GDT_ENTRY_TLS_MIN + reg) << 3) | 3;
+	}
+	if ((reg & CR_SEG_LDT) == CR_SEG_LDT) {
+		reg &= ~CR_SEG_LDT;
+		return (reg << 3) | 7;
+	}
+	BUG();
+}
+
+#ifdef CONFIG_COMPAT
+static int cr_dump_task_struct_x86_32(struct cr_context *ctx, struct task_struct *tsk)
+{
+	struct cr_image_arch_x86_32 *i;
+	struct pt_regs *regs = task_pt_regs(tsk);
+	int rv;
+
+	i = kzalloc(sizeof(*i), GFP_KERNEL);
+	if (!i)
+		return -ENOMEM;
+
+	i->cr_ebx = regs->bx;
+	i->cr_ecx = regs->cx;
+	i->cr_edx = regs->dx;
+	i->cr_esi = regs->si;
+	i->cr_edi = regs->di;
+	i->cr_ebp = regs->bp;
+	i->cr_eax = regs->ax;
+	i->cr_orig_eax = regs->orig_ax;
+	i->cr_eip = regs->ip;
+	i->cr_eflags = regs->flags;
+	i->cr_esp = regs->sp;
+
+	i->cr_cs = encode_segment(regs->cs);
+	i->cr_ds = encode_segment(tsk->thread.ds);
+	i->cr_es = encode_segment(tsk->thread.es);
+	i->cr_fs = encode_segment(tsk->thread.fsindex);
+	i->cr_gs = encode_segment(tsk->thread.gsindex);
+	i->cr_ss = encode_segment(regs->ss);
+
+	i->cr_dr0 = tsk->thread.debugreg0;
+	i->cr_dr1 = tsk->thread.debugreg1;
+	i->cr_dr2 = tsk->thread.debugreg2;
+	i->cr_dr3 = tsk->thread.debugreg3;
+	i->cr_dr6 = tsk->thread.debugreg6;
+	i->cr_dr7 = tsk->thread.debugreg7;
+
+	BUILD_BUG_ON(sizeof(tsk->thread.tls_array[0]) != 8);
+	BUILD_BUG_ON(sizeof(tsk->thread.tls_array) != 3 * 8);
+	memcpy(i->cr_tls_array, tsk->thread.tls_array, sizeof(i->cr_tls_array));
+
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+#endif
+
+static int cr_dump_task_struct_x86_64(struct cr_context *ctx, struct task_struct *tsk)
+{
+	struct cr_image_arch_x86_64 *i;
+	struct pt_regs *regs = task_pt_regs(tsk);
+	int rv;
+
+	i = kzalloc(sizeof(*i), GFP_KERNEL);
+	if (!i)
+		return -ENOMEM;
+
+	i->cr_r15 = regs->r15;
+	i->cr_r14 = regs->r14;
+	i->cr_r13 = regs->r13;
+	i->cr_r12 = regs->r12;
+	i->cr_rbp = regs->bp;
+	i->cr_rbx = regs->bx;
+	i->cr_r11 = regs->r11;
+	i->cr_r10 = regs->r10;
+	i->cr_r9 = regs->r9;
+	i->cr_r8 = regs->r8;
+	i->cr_rax = regs->ax;
+	i->cr_rcx = regs->cx;
+	i->cr_rdx = regs->dx;
+	i->cr_rsi = regs->si;
+	i->cr_rdi = regs->di;
+	i->cr_orig_rax = regs->orig_ax;
+	i->cr_rip = regs->ip;
+	i->cr_rflags = regs->flags;
+	i->cr_rsp = regs->sp;
+
+	i->cr_fs = tsk->thread.fs;
+	i->cr_gs = tsk->thread.gs;
+	i->cr_cs = encode_segment(regs->cs);
+	i->cr_ds = encode_segment(tsk->thread.ds);
+	i->cr_es = encode_segment(tsk->thread.es);
+	i->cr_fsindex = encode_segment(tsk->thread.fsindex);
+	i->cr_gsindex = encode_segment(tsk->thread.gsindex);
+	i->cr_ss = encode_segment(regs->ss);
+
+	i->cr_dr0 = tsk->thread.debugreg0;
+	i->cr_dr1 = tsk->thread.debugreg1;
+	i->cr_dr2 = tsk->thread.debugreg2;
+	i->cr_dr3 = tsk->thread.debugreg3;
+	i->cr_dr6 = tsk->thread.debugreg6;
+	i->cr_dr7 = tsk->thread.debugreg7;
+
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+
+int cr_arch_dump_task_struct(struct cr_context *ctx, struct task_struct *tsk)
+{
+#ifdef CONFIG_COMPAT
+	if (test_tsk_thread_flag(tsk, TIF_IA32))
+		return cr_dump_task_struct_x86_32(ctx, tsk);
+#endif
+	return cr_dump_task_struct_x86_64(ctx, tsk);
+}
+
+#ifdef CONFIG_COMPAT
+static int cr_restore_task_struct_x86_32(struct task_struct *tsk, struct cr_image_arch_x86_32 *i)
+{
+	struct pt_regs *regs = task_pt_regs(tsk);
+
+	tsk->thread.sp = (unsigned long)regs;
+	tsk->thread.sp0 = (unsigned long)(regs + 1);
+
+	regs->bx = i->cr_ebx;
+	regs->cx = i->cr_ecx;
+	regs->dx = i->cr_edx;
+	regs->si = i->cr_esi;
+	regs->di = i->cr_edi;
+	regs->bp = i->cr_ebp;
+	regs->ax = i->cr_eax;
+	regs->orig_ax = i->cr_orig_eax;
+	regs->ip = i->cr_eip;
+	regs->flags = i->cr_eflags;
+	regs->sp = i->cr_esp;
+	tsk->thread.usersp = regs->sp;
+
+	regs->cs = decode_segment(i->cr_cs);
+	tsk->thread.ds = decode_segment(i->cr_ds);
+	tsk->thread.es = decode_segment(i->cr_es);
+	tsk->thread.fs = 0;
+	tsk->thread.fsindex = decode_segment(i->cr_fs);
+	tsk->thread.gs = 0;
+	tsk->thread.gsindex = decode_segment(i->cr_gs);
+	regs->ss = decode_segment(i->cr_ss);
+
+	tsk->thread.debugreg0 = i->cr_dr0;
+	tsk->thread.debugreg1 = i->cr_dr1;
+	tsk->thread.debugreg2 = i->cr_dr2;
+	tsk->thread.debugreg3 = i->cr_dr3;
+	tsk->thread.debugreg6 = i->cr_dr6;
+	tsk->thread.debugreg7 = i->cr_dr7;
+
+	memcpy(tsk->thread.tls_array, i->cr_tls_array, 3 * 8);
+
+	set_tsk_thread_flag(tsk, TIF_FORK);
+	set_tsk_thread_flag(tsk, TIF_IA32);
+	return 0;
+}
+#endif
+
+static int cr_restore_task_struct_x86_64(struct task_struct *tsk, struct cr_image_arch_x86_64 *i)
+{
+	struct pt_regs *regs = task_pt_regs(tsk);
+
+	tsk->thread.sp = (unsigned long)regs;
+	tsk->thread.sp0 = (unsigned long)(regs + 1);
+
+	regs->r15 = i->cr_r15;
+	regs->r14 = i->cr_r14;
+	regs->r13 = i->cr_r13;
+	regs->r12 = i->cr_r12;
+	regs->bp = i->cr_rbp;
+	regs->bx = i->cr_rbx;
+	regs->r11 = i->cr_r11;
+	regs->r10 = i->cr_r10;
+	regs->r9 = i->cr_r9;
+	regs->r8 = i->cr_r8;
+	regs->ax = i->cr_rax;
+	regs->cx = i->cr_rcx;
+	regs->dx = i->cr_rdx;
+	regs->si = i->cr_rsi;
+	regs->di = i->cr_rdi;
+	regs->orig_ax = i->cr_orig_rax;
+	regs->ip = i->cr_rip;
+	regs->flags = i->cr_rflags;
+	regs->sp = i->cr_rsp;
+	tsk->thread.usersp = regs->sp;
+
+	tsk->thread.fs = i->cr_fs;
+	tsk->thread.gs = i->cr_gs;
+	regs->cs = decode_segment(i->cr_cs);
+	tsk->thread.ds = decode_segment(i->cr_ds);
+	tsk->thread.es = decode_segment(i->cr_es);
+	tsk->thread.fsindex = decode_segment(i->cr_fsindex);
+	tsk->thread.gsindex = decode_segment(i->cr_gsindex);
+	regs->ss = decode_segment(i->cr_ss);
+
+	tsk->thread.debugreg0 = i->cr_dr0;
+	tsk->thread.debugreg1 = i->cr_dr1;
+	tsk->thread.debugreg2 = i->cr_dr2;
+	tsk->thread.debugreg3 = i->cr_dr3;
+	tsk->thread.debugreg6 = i->cr_dr6;
+	tsk->thread.debugreg7 = i->cr_dr7;
+
+	set_tsk_thread_flag(tsk, TIF_FORK);
+	return 0;
+}
+
+int cr_arch_restore_task_struct(struct task_struct *tsk, struct cr_image_task_struct *i)
+{
+	if (i->cr_tsk_arch == CR_ARCH_X86_64) {
+		struct cr_image_arch_x86_64 *arch_i = (struct cr_image_arch_x86_64 *)(i + 1);
+
+		return cr_restore_task_struct_x86_64(tsk, arch_i);
+	}
+#ifdef CONFIG_COMPAT
+	if (i->cr_tsk_arch == CR_ARCH_X86_32) {
+		struct cr_image_arch_x86_32 *arch_i = (struct cr_image_arch_x86_32 *)(i + 1);
+
+		return cr_restore_task_struct_x86_32(tsk, arch_i);
+	}
+#endif
+	BUG();
+}
+
+int cr_arch_check_mm_struct(struct mm_struct *mm)
+{
+	mutex_lock(&mm->context.lock);
+	if (mm->context.ldt || mm->context.size != 0) {
+		mutex_unlock(&mm->context.lock);
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	mutex_unlock(&mm->context.lock);
+	return 0;
+}
+
+unsigned int cr_arch_len_mm_struct(struct mm_struct *mm)
+{
+	return 0;
+}
+
+int cr_arch_dump_mm_struct(struct cr_context *ctx, struct mm_struct *mm)
+{
+	return 0;
+}
--- a/kernel/cr/cr.h
+++ b/kernel/cr/cr.h
@@ -78,7 +78,7 @@ int cr_restore_file(struct cr_context *ctx, loff_t pos);
 int cr_restore_mm_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_task_struct(struct cr_context *ctx, loff_t pos);
 
-#if defined(CONFIG_X86_32)
+#if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 __u32 cr_image_header_arch(void);
 int cr_arch_check_image_header(struct cr_image_header *i);
