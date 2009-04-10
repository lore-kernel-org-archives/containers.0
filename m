From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 11/30] cr: i386 support
Date: Fri, 10 Apr 2009 06:35:53 +0400
Message-ID: <20090410023553.GL27788__7152.18425398252$1239331560$gmane$org@x200.localdomain>
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

Segment registers abstraction is done to allow i386 => x86_64 COMPAT=y
migration.

What is unsupported is in cr_arch_check_task_struct().

FIXME: support more that busyloop.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 arch/x86/include/asm/unistd_32.h   |    2 
 arch/x86/kernel/syscall_table_32.S |    2 
 include/linux/cr.h                 |   39 ++++++
 kernel/cr/Makefile                 |    1 
 kernel/cr/cr-x86_32.c              |  211 +++++++++++++++++++++++++++++++++++++
 kernel/cr/cr.h                     |    2 
 6 files changed, 256 insertions(+), 1 deletion(-)

--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -340,6 +340,8 @@
 #define __NR_inotify_init1	332
 #define __NR_preadv		333
 #define __NR_pwritev		334
+#define __NR_checkpoint		335
+#define __NR_restart		336
 
 #ifdef __KERNEL__
 
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -334,3 +334,5 @@ ENTRY(sys_call_table)
 	.long sys_inotify_init1
 	.long sys_preadv
 	.long sys_pwritev
+	.long sys_checkpoint		/* 335 */
+	.long sys_restart
--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -17,6 +17,7 @@ struct cr_image_header {
 
 	/* Mutable part. */
 	/* Arch of the kernel which dumped the image. */
+#define CR_ARCH_X86_32	1
 	__le32	cr_arch;
 	/*
 	 * Distributions are expected to leave image version alone and
@@ -59,6 +60,44 @@ struct cr_image_task_struct {
 	__u32		cr_len_arch;
 } __packed;
 
+#define CR_SEG_NULL		0
+#define CR_SEG_USER32_CS	1
+#define CR_SEG_USER32_DS	2
+#define CR_SEG_USER64_CS	3
+#define CR_SEG_USER64_DS	4
+#define CR_SEG_TLS		0x4000	/* 0100 0000 0000 00xx */
+#define CR_SEG_LDT		0x8000	/* 100x xxxx xxxx xxxx */
+
+struct cr_image_arch_x86_32 {
+	__u32		cr_ebx;
+	__u32		cr_ecx;
+	__u32		cr_edx;
+	__u32		cr_esi;
+	__u32		cr_edi;
+	__u32		cr_ebp;
+	__u32		cr_eax;
+	__u32		cr_orig_eax;
+	__u32		cr_eip;
+	__u32		cr_eflags;
+	__u32		cr_esp;
+
+	__u16		cr_cs;
+	__u16		cr_ds;
+	__u16		cr_es;
+	__u16		cr_fs;
+	__u16		cr_gs;
+	__u16		cr_ss;
+
+	__u32		cr_dr0;
+	__u32		cr_dr1;
+	__u32		cr_dr2;
+	__u32		cr_dr3;
+	__u32		cr_dr6;
+	__u32		cr_dr7;
+
+	__u64		cr_tls_array[3];
+} __packed;
+
 struct cr_image_mm_struct {
 	struct cr_object_header cr_hdr;
 
--- a/kernel/cr/Makefile
+++ b/kernel/cr/Makefile
@@ -4,3 +4,4 @@ cr-y += cr-context.o
 cr-y += cr-file.o
 cr-y += cr-mm.o
 cr-y += cr-task.o
+cr-$(CONFIG_X86_32) += cr-x86_32.o
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-x86_32.c
@@ -0,0 +1,211 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/sched.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+__u32 cr_image_header_arch(void)
+{
+	return CR_ARCH_X86_32;
+}
+
+int cr_arch_check_image_header(struct cr_image_header *i)
+{
+	if (i->cr_arch == cpu_to_le32(CR_ARCH_X86_32))
+		return 0;
+	return -EINVAL;
+}
+
+__u32 cr_task_struct_arch(struct task_struct *tsk)
+{
+	return CR_ARCH_X86_32;
+}
+
+int cr_arch_check_image_task_struct(struct cr_image_task_struct *i)
+{
+	if (i->cr_tsk_arch != CR_ARCH_X86_32)
+		return -EINVAL;
+	return 0;
+}
+
+unsigned int cr_arch_len_task_struct(struct task_struct *tsk)
+{
+	return sizeof(struct cr_image_arch_x86_32);
+}
+
+int cr_arch_check_task_struct(struct task_struct *tsk)
+{
+	if (tsk->thread.xstate) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	if (tsk->thread.vm86_info) {
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
+		return CR_SEG_USER32_CS;
+	if (reg == __USER_DS)
+		return CR_SEG_USER32_DS;
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
+	if (reg == CR_SEG_USER32_CS)
+		return __USER_CS;
+	if (reg == CR_SEG_USER32_DS)
+		return __USER_DS;
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
+int cr_arch_dump_task_struct(struct cr_context *ctx, struct task_struct *tsk)
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
+	i->cr_ds = encode_segment(regs->ds);
+	i->cr_es = encode_segment(regs->es);
+	i->cr_fs = encode_segment(regs->fs);
+	i->cr_gs = encode_segment(tsk->thread.gs);
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
+
+asmlinkage void ret_from_fork(void);
+static int cr_restore_task_struct_x86_32(struct task_struct *tsk, struct cr_image_arch_x86_32 *i)
+{
+	struct pt_regs *regs = task_pt_regs(tsk);
+
+	tsk->thread.sp = (unsigned long)regs;
+	tsk->thread.sp0 = (unsigned long)(regs + 1);
+	tsk->thread.ip = (unsigned long)ret_from_fork;
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
+
+	regs->cs = decode_segment(i->cr_cs);
+	regs->ds = decode_segment(i->cr_ds);
+	regs->es = decode_segment(i->cr_es);
+	regs->fs = decode_segment(i->cr_fs);
+	tsk->thread.gs = decode_segment(i->cr_gs);
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
+	return 0;
+}
+
+int cr_arch_restore_task_struct(struct task_struct *tsk, struct cr_image_task_struct *i)
+{
+	struct cr_image_arch_x86_32 *arch_i = (struct cr_image_arch_x86_32 *)(i + 1);
+
+	return cr_restore_task_struct_x86_32(tsk, arch_i);
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
 
-#if 0
+#if defined(CONFIG_X86_32)
 __u32 cr_image_header_arch(void);
 int cr_arch_check_image_header(struct cr_image_header *i);
