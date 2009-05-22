From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 23/38] C/R: x86_64 support
Date: Fri, 22 May 2009 08:55:17 +0400
Message-ID: <1242968132-1044-23-git-send-email-adobriyan__17629.8959217549$1242969605$gmane$org@gmail.com>
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

In theory and in practice, x86_64 COMPAT=y kernel will restore i386 images
and in other direction. There are small problems still and it doesn't work,
but mentioning anyway.

Right now x86_64 kernel restores only x86_64 images and 64-bit tasks.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 arch/x86/ia32/ia32entry.S        |    2 +
 arch/x86/include/asm/unistd_64.h |    4 +
 include/linux/kstate-image.h     |   36 ++++
 include/linux/kstate.h           |    2 +-
 kernel/kstate/Makefile           |    1 +
 kernel/kstate/kstate-x86_64.c    |  336 ++++++++++++++++++++++++++++++++++++++
 6 files changed, 380 insertions(+), 1 deletions(-)
 create mode 100644 kernel/kstate/kstate-x86_64.c

diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index a505202..b12e911 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -830,4 +830,6 @@ ia32_sys_call_table:
 	.quad sys_inotify_init1
 	.quad compat_sys_preadv
 	.quad compat_sys_pwritev
+	.quad sys_checkpoint		/* 335 */
+	.quad sys_restart
 ia32_syscall_end:
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index f818294..a839c66 100644
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
diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index 3c93432..d697d97 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -28,6 +28,7 @@ struct kstate_image_header {
 	/* Mutable part. */
 	/* Arch of the kernel which dumped the image. */
 #define KSTATE_ARCH_I386	1
+#define KSTATE_ARCH_X86_64	2
 	__le32	kernel_arch;
 	/*
 	 * Distributions are expected to leave image version alone and
@@ -74,6 +75,8 @@ struct kstate_image_task_struct {
 #define KSTATE_SEG_NULL		0
 #define KSTATE_SEG_USER32_CS	1
 #define KSTATE_SEG_USER32_DS	2
+#define KSTATE_SEG_USER64_CS	3
+#define KSTATE_SEG_USER64_DS	4
 #define KSTATE_SEG_TLS		0x4000	/* 0100 0000 0000 00xx */
 #define KSTATE_SEG_LDT		0x8000	/* 100x xxxx xxxx xxxx */
 
@@ -110,6 +113,39 @@ struct kstate_image_task_struct_i386 {
 	/* __u8	xstate[len_xstate]; */
 } __packed;
 
+struct kstate_image_task_struct_x86_64 {
+	__u64		r15;
+	__u64		r14;
+	__u64		r13;
+	__u64		r12;
+	__u64		rbp;
+	__u64		rbx;
+	__u64		r11;
+	__u64		r10;
+	__u64		r9;
+	__u64		r8;
+	__u64		rax;
+	__u64		rcx;
+	__u64		rdx;
+	__u64		rsi;
+	__u64		rdi;
+	__u64		orig_rax;
+	__u64		rip;
+	__u64		rflags;
+	__u64		rsp;
+
+	__u64		fs;
+	__u64		gs;
+	__u16		cs;
+	__u16		ds;
+	__u16		es;
+	__u16		fsindex;
+	__u16		gsindex;
+	__u16		ss;
+
+	__u64		tls_array[3];
+} __packed;
+
 struct kstate_image_mm_struct {
 	struct kstate_object_header hdr;
 
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index c4b55b6..95898ec 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -67,7 +67,7 @@ int kstate_collect_all_file(struct kstate_context *ctx);
 int kstate_dump_all_file(struct kstate_context *ctx);
 int kstate_restore_file(struct kstate_context *ctx, kstate_ref_t *ref);
 
-#if defined(CONFIG_X86_32)
+#if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
 
diff --git a/kernel/kstate/Makefile b/kernel/kstate/Makefile
index ca19a22..0678fc9 100644
--- a/kernel/kstate/Makefile
+++ b/kernel/kstate/Makefile
@@ -7,3 +7,4 @@ kstate-y += kstate-mm.o
 kstate-y += kstate-object.o
 kstate-y += kstate-task.o
 kstate-$(CONFIG_X86_32) += kstate-x86_32.o
+kstate-$(CONFIG_X86_64) += kstate-x86_64.o
diff --git a/kernel/kstate/kstate-x86_64.c b/kernel/kstate/kstate-x86_64.c
new file mode 100644
index 0000000..0d85704
--- /dev/null
+++ b/kernel/kstate/kstate-x86_64.c
@@ -0,0 +1,336 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/sched.h>
+
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+const __u32 kstate_kernel_arch = KSTATE_ARCH_X86_64;
+
+int kstate_arch_check_image_header(struct kstate_image_header *i)
+{
+	if (i->kernel_arch == cpu_to_le32(KSTATE_ARCH_X86_64))
+		return 0;
+	return -EINVAL;
+}
+
+__u32 kstate_task_struct_arch(struct task_struct *tsk)
+{
+	return KSTATE_ARCH_X86_64;
+}
+
+static int check_rflags(__u64 rflags)
+{
+	rflags &= ~X86_EFLAGS_CF;
+	rflags &= ~X86_EFLAGS_PF;
+	rflags &= ~X86_EFLAGS_AF;
+	rflags &= ~X86_EFLAGS_ZF;
+	rflags &= ~X86_EFLAGS_SF;
+	rflags &= ~X86_EFLAGS_TF;
+	rflags &= ~X86_EFLAGS_DF;
+	rflags &= ~X86_EFLAGS_OF;
+	rflags &= ~X86_EFLAGS_NT;
+	rflags &= ~X86_EFLAGS_AC;
+	rflags &= ~X86_EFLAGS_ID;
+	if (rflags != (X86_EFLAGS_IF|0x2)) {
+		pr_debug("%s: rflags %016llx\n", __func__, (unsigned long long)rflags);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static int check_segment64(__u16 seg)
+{
+	switch (seg) {
+	case KSTATE_SEG_NULL:
+	case KSTATE_SEG_USER64_CS:
+	case KSTATE_SEG_USER64_DS:
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
+static int check_image_task_struct_x86_64(struct kstate_image_task_struct *tsk_i)
+{
+	struct kstate_image_task_struct_x86_64 *i = (void *)(tsk_i + 1);
+	int rv;
+
+	if (tsk_i->hdr.obj_len < sizeof(*tsk_i) + sizeof(*i))
+		return -EINVAL;
+
+	rv = check_rflags(i->rflags);
+	if (rv < 0)
+		return rv;
+
+	if (i->fs >= TASK_SIZE_MAX)
+		return -EINVAL;
+	if (i->gs >= TASK_SIZE_MAX)
+		return -EINVAL;
+
+	if (i->cs == KSTATE_SEG_NULL)
+		return -EINVAL;
+	rv = check_segment64(i->cs);
+	if (rv < 0)
+		return rv;
+	rv = check_segment64(i->ds);
+	if (rv < 0)
+		return rv;
+	rv = check_segment64(i->es);
+	if (rv < 0)
+		return rv;
+	rv = check_segment64(i->fsindex);
+	if (rv < 0)
+		return rv;
+	rv = check_segment64(i->gsindex);
+	if (rv < 0)
+		return rv;
+	rv = check_segment64(i->ss);
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
+int kstate_arch_check_image_task_struct(struct kstate_image_task_struct *i)
+{
+	if (i->tsk_arch == KSTATE_ARCH_X86_64)
+		return check_image_task_struct_x86_64(i);
+	return -EINVAL;
+}
+
+unsigned int kstate_arch_len_task_struct(struct task_struct *tsk)
+{
+	return sizeof(struct kstate_image_task_struct_x86_64);
+}
+
+int kstate_arch_check_task_struct(struct task_struct *tsk)
+{
+	struct restart_block *rb;
+
+#ifdef CONFIG_COMPAT
+	if (test_tsk_thread_flag(tsk, TIF_IA32)) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#endif
+	if (test_tsk_thread_flag(tsk, TIF_DEBUG)) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	if (tsk->thread.xstate) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	rb = &task_thread_info(tsk)->restart_block;
+	if (rb->fn != current_thread_info()->restart_block.fn) {
+		WARN(1, "rb->fn = %pF\n", rb->fn);
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
+		return KSTATE_SEG_USER64_CS;
+	if (seg == __USER_DS)
+		return KSTATE_SEG_USER64_DS;
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
+	if (seg == KSTATE_SEG_USER64_CS)
+		return __USER_CS;
+	if (seg == KSTATE_SEG_USER64_DS)
+		return __USER_DS;
+
+	BUILD_BUG_ON(GDT_ENTRY_TLS_MAX - GDT_ENTRY_TLS_MIN + 1 != 3);
+	if ((seg & KSTATE_SEG_TLS) == KSTATE_SEG_TLS) {
+		seg &= ~KSTATE_SEG_TLS;
+		if (seg <= GDT_ENTRY_TLS_MAX - GDT_ENTRY_TLS_MIN)
+			return ((GDT_ENTRY_TLS_MIN + seg) << 3) | 3;
+	}
+	if ((seg & KSTATE_SEG_LDT) == KSTATE_SEG_LDT) {
+		seg &= ~KSTATE_SEG_LDT;
+		return (seg << 3) | 7;
+	}
+	BUG();
+}
+
+static int dump_task_struct_x86_64(struct kstate_context *ctx, struct task_struct *tsk, void *arch_i)
+{
+	struct kstate_image_task_struct_x86_64 *i = arch_i;
+	struct pt_regs *regs = task_pt_regs(tsk);
+
+	i->r15 = regs->r15;
+	i->r14 = regs->r14;
+	i->r13 = regs->r13;
+	i->r12 = regs->r12;
+	i->rbp = regs->bp;
+	i->rbx = regs->bx;
+	i->r11 = regs->r11;
+	i->r10 = regs->r10;
+	i->r9 = regs->r9;
+	i->r8 = regs->r8;
+	i->rax = regs->ax;
+	i->rcx = regs->cx;
+	i->rdx = regs->dx;
+	i->rsi = regs->si;
+	i->rdi = regs->di;
+	i->orig_rax = regs->orig_ax;
+	i->rip = regs->ip;
+	i->rflags = regs->flags;
+	i->rsp = regs->sp;
+
+	i->fs = tsk->thread.fs;
+	i->gs = tsk->thread.gs;
+	i->cs = encode_segment(regs->cs);
+	i->ds = encode_segment(tsk->thread.ds);
+	i->es = encode_segment(tsk->thread.es);
+	i->fsindex = encode_segment(tsk->thread.fsindex);
+	i->gsindex = encode_segment(tsk->thread.gsindex);
+	i->ss = encode_segment(regs->ss);
+
+	BUILD_BUG_ON(sizeof(tsk->thread.tls_array[0]) != 8);
+	BUILD_BUG_ON(sizeof(tsk->thread.tls_array) != 3 * 8);
+	memcpy(i->tls_array, tsk->thread.tls_array, sizeof(i->tls_array));
+
+	return 0;
+}
+
+int kstate_arch_dump_task_struct(struct kstate_context *ctx, struct task_struct *tsk, void *arch_i)
+{
+	return dump_task_struct_x86_64(ctx, tsk, arch_i);
+}
+
+static int restore_task_struct_x86_64(struct task_struct *tsk, struct kstate_image_task_struct_x86_64 *i)
+{
+	struct pt_regs *regs = task_pt_regs(tsk);
+
+	tsk->thread.sp = (unsigned long)regs;
+	tsk->thread.sp0 = (unsigned long)(regs + 1);
+
+	regs->r15 = i->r15;
+	regs->r14 = i->r14;
+	regs->r13 = i->r13;
+	regs->r12 = i->r12;
+	regs->bp = i->rbp;
+	regs->bx = i->rbx;
+	regs->r11 = i->r11;
+	regs->r10 = i->r10;
+	regs->r9 = i->r9;
+	regs->r8 = i->r8;
+	regs->ax = i->rax;
+	regs->cx = i->rcx;
+	regs->dx = i->rdx;
+	regs->si = i->rsi;
+	regs->di = i->rdi;
+	regs->orig_ax = i->orig_rax;
+	regs->ip = i->rip;
+	regs->flags = i->rflags;
+	regs->sp = i->rsp;
+	tsk->thread.usersp = regs->sp;
+
+	tsk->thread.fs = i->fs;
+	tsk->thread.gs = i->gs;
+	regs->cs = decode_segment(i->cs);
+	tsk->thread.ds = decode_segment(i->ds);
+	tsk->thread.es = decode_segment(i->es);
+	tsk->thread.fsindex = decode_segment(i->fsindex);
+	tsk->thread.gsindex = decode_segment(i->gsindex);
+	regs->ss = decode_segment(i->ss);
+
+	memcpy(tsk->thread.tls_array, i->tls_array, sizeof(i->tls_array));
+
+	set_tsk_thread_flag(tsk, TIF_FORK);
+	return 0;
+}
+
+int kstate_arch_restore_task_struct(struct task_struct *tsk, struct kstate_image_task_struct *i)
+{
+	if (i->tsk_arch == KSTATE_ARCH_X86_64) {
+		return restore_task_struct_x86_64(tsk, (void *)(i + 1));
+	}
+	BUG();
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
