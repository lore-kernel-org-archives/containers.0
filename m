From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 20/38] C/R: i386 support
Date: Fri, 22 May 2009 08:55:14 +0400
Message-ID: <1242968132-1044-20-git-send-email-adobriyan__23175.1657593579$1242969815$gmane$org@gmail.com>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1242968132-1044-1-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Segment registers are abstracted to allow i386 => x86_64
migration (BTW, I'm not so sure if just making 32-bit selectors
the same will achieve same effect)

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 arch/x86/include/asm/unistd_32.h   |    2 +
 arch/x86/kernel/syscall_table_32.S |    2 +
 include/linux/kstate-image.h       |   30 ++++
 include/linux/kstate.h             |    2 +-
 kernel/kstate/Makefile             |    1 +
 kernel/kstate/kstate-x86_32.c      |  294 ++++++++++++++++++++++++++++++++++++
 6 files changed, 330 insertions(+), 1 deletions(-)
 create mode 100644 kernel/kstate/kstate-x86_32.c

diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index 6e72d74..48557e1 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -340,6 +340,8 @@
 #define __NR_inotify_init1	332
 #define __NR_preadv		333
 #define __NR_pwritev		334
+#define __NR_checkpoint		335
+#define __NR_restart		336
 
 #ifdef __KERNEL__
 
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index ff5c873..70d5441 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -334,3 +334,5 @@ ENTRY(sys_call_table)
 	.long sys_inotify_init1
 	.long sys_preadv
 	.long sys_pwritev
+	.long sys_checkpoint		/* 335 */
+	.long sys_restart
diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index 348f59f..8df5c4a 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -27,6 +27,7 @@ struct kstate_image_header {
 
 	/* Mutable part. */
 	/* Arch of the kernel which dumped the image. */
+#define KSTATE_ARCH_I386	1
 	__le32	kernel_arch;
 	/*
 	 * Distributions are expected to leave image version alone and
@@ -70,6 +71,35 @@ struct kstate_image_task_struct {
 	__u32		tsk_arch;
 } __packed;
 
+#define KSTATE_SEG_NULL		0
+#define KSTATE_SEG_USER32_CS	1
+#define KSTATE_SEG_USER32_DS	2
+#define KSTATE_SEG_TLS		0x4000	/* 0100 0000 0000 00xx */
+#define KSTATE_SEG_LDT		0x8000	/* 100x xxxx xxxx xxxx */
+
+struct kstate_image_task_struct_i386 {
+	__u32		ebx;
+	__u32		ecx;
+	__u32		edx;
+	__u32		esi;
+	__u32		edi;
+	__u32		ebp;
+	__u32		eax;
+	__u32		orig_eax;
+	__u32		eip;
+	__u32		eflags;
+	__u32		esp;
+
+	__u16		cs;
+	__u16		ds;
+	__u16		es;
+	__u16		fs;
+	__u16		gs;
+	__u16		ss;
+
+	__u64		tls_array[3];
+} __packed;
+
 struct kstate_image_mm_struct {
 	struct kstate_object_header hdr;
 
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index 3ae9e28..c4b55b6 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -67,7 +67,7 @@ int kstate_collect_all_file(struct kstate_context *ctx);
 int kstate_dump_all_file(struct kstate_context *ctx);
 int kstate_restore_file(struct kstate_context *ctx, kstate_ref_t *ref);
 
-#if 0
+#if defined(CONFIG_X86_32)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
 
diff --git a/kernel/kstate/Makefile b/kernel/kstate/Makefile
index eacd3cf..ca19a22 100644
--- a/kernel/kstate/Makefile
+++ b/kernel/kstate/Makefile
@@ -6,3 +6,4 @@ kstate-y += kstate-image.o
 kstate-y += kstate-mm.o
 kstate-y += kstate-object.o
 kstate-y += kstate-task.o
+kstate-$(CONFIG_X86_32) += kstate-x86_32.o
diff --git a/kernel/kstate/kstate-x86_32.c b/kernel/kstate/kstate-x86_32.c
new file mode 100644
index 0000000..809242c
--- /dev/null
+++ b/kernel/kstate/kstate-x86_32.c
@@ -0,0 +1,294 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/sched.h>
+
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+const __u32 kstate_kernel_arch = KSTATE_ARCH_I386;
+
+int kstate_arch_check_image_header(struct kstate_image_header *i)
+{
+	if (i->kernel_arch == cpu_to_le32(KSTATE_ARCH_I386))
+		return 0;
+	return -EINVAL;
+}
+
+__u32 kstate_task_struct_arch(struct task_struct *tsk)
+{
+	return KSTATE_ARCH_I386;
+}
+
+static int check_eflags(__u32 eflags)
+{
+	eflags &= ~X86_EFLAGS_CF;
+	eflags &= ~X86_EFLAGS_PF;
+	eflags &= ~X86_EFLAGS_AF;
+	eflags &= ~X86_EFLAGS_ZF;
+	eflags &= ~X86_EFLAGS_SF;
+	eflags &= ~X86_EFLAGS_TF;
+	eflags &= ~X86_EFLAGS_DF;
+	eflags &= ~X86_EFLAGS_OF;
+	eflags &= ~X86_EFLAGS_NT;
+	eflags &= ~X86_EFLAGS_AC;
+	eflags &= ~X86_EFLAGS_ID;
+	if (eflags != (X86_EFLAGS_IF|0x2)) {
+		pr_debug("%s: eflags %08x\n", __func__, eflags);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static int check_segment(__u16 seg)
+{
+	switch (seg) {
+	case KSTATE_SEG_NULL:
+	case KSTATE_SEG_USER32_CS:
+	case KSTATE_SEG_USER32_DS:
+		return 0;
+	}
+	if (seg & KSTATE_SEG_TLS) {
+		if ((seg & ~KSTATE_SEG_TLS) > GDT_ENTRY_TLS_MAX - GDT_ENTRY_TLS_MIN) {
+			pr_debug("%s: seg %04x, GDT_ENTRY_TLS_MIN %u, GDT_ENTRY_TLS_MAX %u\n", __func__, seg, GDT_ENTRY_TLS_MIN, GDT_ENTRY_TLS_MAX);
+			return -EINVAL;
+		}
+		return 0;
+	}
+	if (seg & KSTATE_SEG_LDT) {
+		if ((seg & ~KSTATE_SEG_LDT) > 0x1fff) {
+			pr_debug("%s: seg %04x\n", __func__, seg);
+			return -EINVAL;
+		}
+		return 0;
+	}
+	pr_debug("%s: seg %04x\n", __func__, seg);
+	return -EINVAL;
+}
+
+static int check_tls(struct desc_struct *desc)
+{
+	if (desc->l != 0 || desc->s != 1 || desc->dpl != 3)
+		return -EINVAL;
+	return 0;
+}
+
+int kstate_arch_check_image_task_struct(struct kstate_image_task_struct *tsk_i)
+{
+	struct kstate_image_task_struct_i386 *i = (void *)(tsk_i + 1);
+	int rv;
+
+	if (tsk_i->tsk_arch != KSTATE_ARCH_I386)
+		return -EINVAL;
+	if (tsk_i->hdr.obj_len < sizeof(*tsk_i) + sizeof(*i))
+		return -EINVAL;
+
+	rv = check_eflags(i->eflags);
+	if (rv < 0)
+		return rv;
+
+	if (i->cs == KSTATE_SEG_NULL)
+		return -EINVAL;
+	rv = check_segment(i->cs);
+	if (rv < 0)
+		return rv;
+	rv = check_segment(i->ds);
+	if (rv < 0)
+		return rv;
+	rv = check_segment(i->es);
+	if (rv < 0)
+		return rv;
+	rv = check_segment(i->fs);
+	if (rv < 0)
+		return rv;
+	rv = check_segment(i->gs);
+	if (rv < 0)
+		return rv;
+	rv = check_segment(i->ss);
+	if (rv < 0)
+		return rv;
+
+	if (i->tls_array[0]) {
+		rv = check_tls((struct desc_struct *)&i->tls_array[0]);
+		if (rv < 0)
+			return rv;
+	}
+	if (i->tls_array[1]) {
+		rv = check_tls((struct desc_struct *)&i->tls_array[1]);
+		if (rv < 0)
+			return rv;
+	}
+	if (i->tls_array[2]) {
+		rv = check_tls((struct desc_struct *)&i->tls_array[2]);
+		if (rv < 0)
+			return rv;
+	}
+
+	return 0;
+}
+
+unsigned int kstate_arch_len_task_struct(struct task_struct *tsk)
+{
+	return sizeof(struct kstate_image_task_struct_i386);
+}
+
+int kstate_arch_check_task_struct(struct task_struct *tsk)
+{
+	struct restart_block *rb;
+
+	if (tsk->thread.xstate) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	if (test_tsk_thread_flag(tsk, TIF_DEBUG)) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	rb = &task_thread_info(tsk)->restart_block;
+	if (rb->fn != current_thread_info()->restart_block.fn) {
+		WARN(1, "rb->fn = %pF\n", rb->fn);
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
+static __u16 encode_segment(u16 seg)
+{
+	if (seg == 0)
+		return KSTATE_SEG_NULL;
+	BUG_ON((seg & 3) != 3);
+	if (seg & 4)
+		return KSTATE_SEG_LDT | (seg >> 3);
+
+	if (seg == __USER_CS)
+		return KSTATE_SEG_USER32_CS;
+	if (seg == __USER_DS)
+		return KSTATE_SEG_USER32_DS;
+
+	if (GDT_ENTRY_TLS_MIN <= (seg >> 3) && (seg >> 3) <= GDT_ENTRY_TLS_MAX)
+		return KSTATE_SEG_TLS | ((seg >> 3) - GDT_ENTRY_TLS_MIN);
+	BUG();
+}
+
+static u16 decode_segment(__u16 seg)
+{
+	if (seg == KSTATE_SEG_NULL)
+		return 0;
+	if (seg == KSTATE_SEG_USER32_CS)
+		return __USER_CS;
+	if (seg == KSTATE_SEG_USER32_DS)
+		return __USER_DS;
+
+	if (seg & KSTATE_SEG_TLS) {
+		seg &= ~KSTATE_SEG_TLS;
+		return ((GDT_ENTRY_TLS_MIN + seg) << 3) | 3;
+	}
+	if (seg & KSTATE_SEG_LDT) {
+		seg &= ~KSTATE_SEG_LDT;
+		return (seg << 3) | 7;
+	}
+	BUG();
+}
+
+int kstate_arch_dump_task_struct(struct kstate_context *ctx, struct task_struct *tsk, void *arch_i)
+{
+	struct kstate_image_task_struct_i386 *i = arch_i;
+	struct pt_regs *regs = task_pt_regs(tsk);
+
+	i->ebx = regs->bx;
+	i->ecx = regs->cx;
+	i->edx = regs->dx;
+	i->esi = regs->si;
+	i->edi = regs->di;
+	i->ebp = regs->bp;
+	i->eax = regs->ax;
+	i->orig_eax = regs->orig_ax;
+	i->eip = regs->ip;
+	i->eflags = regs->flags;
+	i->esp = regs->sp;
+
+	i->cs = encode_segment(regs->cs);
+	i->ds = encode_segment(regs->ds);
+	i->es = encode_segment(regs->es);
+	i->fs = encode_segment(regs->fs);
+	i->gs = encode_segment(tsk->thread.gs);
+	i->ss = encode_segment(regs->ss);
+
+	BUILD_BUG_ON(sizeof(tsk->thread.tls_array[0]) != 8);
+	BUILD_BUG_ON(sizeof(tsk->thread.tls_array) != 3 * 8);
+	memcpy(i->tls_array, tsk->thread.tls_array, sizeof(i->tls_array));
+
+	return 0;
+}
+
+asmlinkage void ret_from_fork(void);
+static int restore_task_struct_i386(struct task_struct *tsk, struct kstate_image_task_struct_i386 *i)
+{
+	struct pt_regs *regs = task_pt_regs(tsk);
+
+	tsk->thread.sp = (unsigned long)regs;
+	tsk->thread.sp0 = (unsigned long)(regs + 1);
+	tsk->thread.ip = (unsigned long)ret_from_fork;
+
+	regs->bx = i->ebx;
+	regs->cx = i->ecx;
+	regs->dx = i->edx;
+	regs->si = i->esi;
+	regs->di = i->edi;
+	regs->bp = i->ebp;
+	regs->ax = i->eax;
+	regs->orig_ax = i->orig_eax;
+	regs->ip = i->eip;
+	regs->flags = i->eflags;
+	regs->sp = i->esp;
+
+	regs->cs = decode_segment(i->cs);
+	regs->ds = decode_segment(i->ds);
+	regs->es = decode_segment(i->es);
+	regs->fs = decode_segment(i->fs);
+	tsk->thread.gs = decode_segment(i->gs);
+	regs->ss = decode_segment(i->ss);
+
+	memcpy(tsk->thread.tls_array, i->tls_array, 3 * 8);
+
+	return 0;
+}
+
+int kstate_arch_restore_task_struct(struct task_struct *tsk, struct kstate_image_task_struct *i)
+{
+	return restore_task_struct_i386(tsk, (void *)(i + 1));
+}
+
+int kstate_arch_check_mm_struct(struct mm_struct *mm)
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
+unsigned int kstate_arch_len_mm_struct(struct mm_struct *mm)
+{
+	return 0;
+}
+
+int kstate_arch_dump_mm_struct(struct kstate_context *ctx, struct mm_struct *mm, void *arch_i)
+{
+	return 0;
+}
-- 
1.5.6.5
