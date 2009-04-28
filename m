From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 05/54] x86 support for checkpoint/restart
Date: Tue, 28 Apr 2009 19:23:35 -0400
Message-ID: <1240961064-13991-6-git-send-email-orenl@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240961064-13991-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Add logic to save and restore architecture specific state, including
thread-specific state, CPU registers and FPU state.

In addition, architecture capabilities are saved in an architecure
specific extension of the header (ckpt_hdr_head_arch); Currently this
includes only FPU capabilities.

Currently only x86-32 is supported. Compiling on x86-64 will trigger
an explicit error.

Changelog[v14]:
  - Use new interface ckpt_hdr_get/put()
  - Embed struct ckpt_hdr in struct ckpt_hdr...
  - Remove preempt_disable/enable() around init_fpu() and fix leak
  - Revert change to pr_debug(), back to ckpt_debug()
  - Move code related to task_struct to checkpoint/process.c

Changelog[v12]:
  - A couple of missed calls to ckpt_hbuf_put()
  - Replace obsolete ckpt_debug() with pr_debug()

Changelog[v9]:
  - Add arch-specific header that details architecture capabilities;
    split FPU restore to send capabilities only once.
  - Test for zero TLS entries in ckpt_write_thread()
  - Fix asm/checkpoint_hdr.h so it can be included from user-space

Changelog[v7]:
  - Fix save/restore state of FPU

Changelog[v5]:
  - Remove preempt_disable() when restoring debug registers

Changelog[v4]:
  - Fix header structure alignment

Changelog[v2]:
  - Pad header structures to 64 bits to ensure compatibility
  - Follow Dave Hansen's refactoring of the original post

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 arch/x86/include/asm/checkpoint_hdr.h |  100 ++++++++
 arch/x86/mm/Makefile                  |    2 +
 arch/x86/mm/checkpoint.c              |  445 +++++++++++++++++++++++++++++++++
 checkpoint/checkpoint.c               |    7 +-
 checkpoint/checkpoint_arch.h          |    9 +
 checkpoint/process.c                  |   22 ++-
 checkpoint/restart.c                  |    6 +
 include/linux/checkpoint_hdr.h        |    1 +
 8 files changed, 589 insertions(+), 3 deletions(-)
 create mode 100644 arch/x86/include/asm/checkpoint_hdr.h
 create mode 100644 arch/x86/mm/checkpoint.c
 create mode 100644 checkpoint/checkpoint_arch.h

diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
new file mode 100644
index 0000000..035abbb
--- /dev/null
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -0,0 +1,100 @@
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
+#include <linux/types.h>
+#include <linux/checkpoint_hdr.h>
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
+ *   sizeof(ckpt_hdr_task) on x86-32 is different from x86-64, since it
+ *   will be 32-bit aligned on x86-32."
+ */
+
+/* i387 structure seen from kernel/userspace */
+#ifdef __KERNEL__
+#include <asm/processor.h>
+#else
+#include <sys/user.h>
+#endif
+
+struct ckpt_hdr_header_arch {
+	struct ckpt_hdr h;
+	/* FIXME: add HAVE_HWFP */
+	__u16 has_fxsr;
+	__u16 has_xsave;
+	__u16 xstate_size;
+	__u16 _pading;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_thread {
+	struct ckpt_hdr h;
+	/* FIXME: restart blocks */
+	__u16 gdt_entry_tls_entries;
+	__u16 sizeof_tls_array;
+	__u16 ntls;	/* number of TLS entries to follow */
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_cpu {
+	struct ckpt_hdr h;
+	/* see struct pt_regs (x86-64) */
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
+	__u64 cs;
+	__u64 flags;
+	__u64 sp;
+	__u64 ss;
+
+	/* segment registers */
+	__u64 ds;
+	__u64 es;
+	__u64 fs;
+	__u64 gs;
+
+	/* debug registers */
+	__u64 debugreg0;
+	__u64 debugreg1;
+	__u64 debugreg2;
+	__u64 debugreg3;
+	__u64 debugreg6;
+	__u64 debugreg7;
+
+	__u32 uses_debug;
+	__u32 used_math;
+
+	/* thread_xstate contents follow (if used_math) */
+} __attribute__((aligned(8)));
+
+#endif /* __ASM_X86_CKPT_HDR__H */
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index fdd30d0..7d894a5 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -19,3 +19,5 @@ obj-$(CONFIG_K8_NUMA)		+= k8topology_64.o
 obj-$(CONFIG_ACPI_NUMA)		+= srat_$(BITS).o
 
 obj-$(CONFIG_MEMTEST)		+= memtest.o
+
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
new file mode 100644
index 0000000..86ca916
--- /dev/null
+++ b/arch/x86/mm/checkpoint.c
@@ -0,0 +1,445 @@
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
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
+#include <asm/desc.h>
+#include <asm/i387.h>
+
+#include <asm/checkpoint_hdr.h>
+#include <linux/checkpoint.h>
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+/* dump the thread_struct of a given task */
+int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_thread *h;
+	struct thread_struct *thread;
+	struct desc_struct *desc;
+	int ntls = 0;
+	int n, ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_THREAD);
+	if (!h)
+		return -ENOMEM;
+
+	thread = &t->thread;
+
+	/* calculate no. of TLS entries that follow */
+	desc = thread->tls_array;
+	for (n = GDT_ENTRY_TLS_ENTRIES; n > 0; n--, desc++) {
+		if (desc->a || desc->b)
+			ntls++;
+	}
+
+	h->gdt_entry_tls_entries = GDT_ENTRY_TLS_ENTRIES;
+	h->sizeof_tls_array = sizeof(thread->tls_array);
+	h->ntls = ntls;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	ckpt_debug("ntls %d\n", ntls);
+	if (ntls == 0)
+		return 0;
+
+	/*
+	 * For simplicity dump the entire array, cherry-pick upon restart
+	 * FIXME: the TLS descriptors in the GDT should be called out and
+	 * not tied to the in-kernel representation.
+	 */
+	ret = ckpt_kwrite(ctx, thread->tls_array, sizeof(thread->tls_array));
+
+	/* IGNORE RESTART BLOCKS FOR NOW ... */
+
+	return ret;
+}
+
+#ifdef CONFIG_X86_64
+
+#error "CONFIG_X86_64 unsupported yet."
+
+#else	/* !CONFIG_X86_64 */
+
+static void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
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
+	h->cs = regs->cs;
+	h->flags = regs->flags;
+	h->sp = regs->sp;
+	h->ss = regs->ss;
+
+	h->ds = regs->ds;
+	h->es = regs->es;
+
+	/*
+	 * for checkpoint in process context (from within a container)
+	 * the GS and FS registers should be saved from the hardware;
+	 * otherwise they are already sabed on the thread structure
+	 */
+	if (t == current) {
+		savesegment(gs, h->gs);
+		savesegment(fs, h->fs);
+	} else {
+		h->gs = thread->gs;
+		h->fs = thread->fs;
+	}
+
+	/*
+	 * for checkpoint in process context (from within a container),
+	 * the actual syscall is taking place at this very moment; so
+	 * we (optimistically) subtitute the future return value (0) of
+	 * this syscall into the orig_eax, so that upon restart it will
+	 * succeed (or it will endlessly retry checkpoint...)
+	 */
+	if (t == current) {
+		BUG_ON(h->orig_ax < 0);
+		h->ax = 0;
+	}
+}
+
+static void save_cpu_debug(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+
+	/* debug regs */
+
+	/*
+	 * for checkpoint in process context (from within a container),
+	 * get the actual registers; otherwise get the saved values.
+	 */
+
+	if (t == current) {
+		get_debugreg(h->debugreg0, 0);
+		get_debugreg(h->debugreg1, 1);
+		get_debugreg(h->debugreg2, 2);
+		get_debugreg(h->debugreg3, 3);
+		get_debugreg(h->debugreg6, 6);
+		get_debugreg(h->debugreg7, 7);
+	} else {
+		h->debugreg0 = thread->debugreg0;
+		h->debugreg1 = thread->debugreg1;
+		h->debugreg2 = thread->debugreg2;
+		h->debugreg3 = thread->debugreg3;
+		h->debugreg6 = thread->debugreg6;
+		h->debugreg7 = thread->debugreg7;
+	}
+
+	h->uses_debug = !!(task_thread_info(t)->flags & TIF_DEBUG);
+}
+
+static void save_cpu_fpu(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	h->used_math = tsk_used_math(t) ? 1 : 0;
+}
+
+static int checkpoint_cpu_fpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	void *xstate_buf;
+	int ret;
+
+	xstate_buf = ckpt_hdr_get(ctx, xstate_size);
+	if (!xstate_buf)
+		return -ENOMEM;
+
+	/* i387 + MMU + SSE logic */
+	preempt_disable();	/* needed it (t == current) */
+
+	/*
+	 * normally, no need to unlazy_fpu(), since TS_USEDFPU flag
+	 * was cleared when task was context-switched out...
+	 * except if we are in process context, in which case we do
+	 */
+	if (t == current && (task_thread_info(t)->status & TS_USEDFPU))
+		unlazy_fpu(current);
+
+	/*
+	 * For simplicity dump the entire structure.
+	 * FIX: need to be deliberate about what registers we are
+	 * dumping for traceability and compatibility.
+	 */
+	memcpy(xstate_buf, t->thread.xstate, xstate_size);
+	preempt_enable();	/* needed if (t == current) */
+
+	ret = ckpt_kwrite(ctx, xstate_buf, xstate_size);
+	_ckpt_hdr_put(ctx, xstate_buf, xstate_size);
+
+	return ret;
+}
+
+#endif	/* CONFIG_X86_64 */
+
+/* dump the cpu state and registers of a given task */
+int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_cpu *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CPU);
+	if (!h)
+		return -ENOMEM;
+
+	save_cpu_regs(h, t);
+	save_cpu_debug(h, t);
+	save_cpu_fpu(h, t);
+
+	ckpt_debug("math %d debug %d\n", h->used_math, h->uses_debug);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	if (h->used_math)
+		ret = checkpoint_cpu_fpu(ctx, t);
+ out:
+	ckpt_hdr_put(ctx, h);
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
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
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
+	struct task_struct *t = current;
+	struct thread_struct *thread = &t->thread;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_THREAD);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ckpt_debug("ntls %d\n", h->ntls);
+
+	ret = -EINVAL;
+	if (h->gdt_entry_tls_entries != GDT_ENTRY_TLS_ENTRIES ||
+	    h->sizeof_tls_array != sizeof(thread->tls_array) ||
+	    h->ntls > GDT_ENTRY_TLS_ENTRIES)
+		goto out;
+
+	if (h->ntls > 0) {
+		struct desc_struct *desc;
+		int size, cpu;
+
+		/*
+		 * restore TLS by hand: why convert to struct user_desc if
+		 * sys_set_thread_entry() will convert it back ?
+		 */
+
+		size = sizeof(*desc) * GDT_ENTRY_TLS_ENTRIES;
+		desc = kmalloc(size, GFP_KERNEL);
+		if (!desc) {
+			ret = -ENOMEM;
+			goto out;
+		}
+
+		ret = ckpt_kread(ctx, desc, size);
+		if (ret == 0) {
+			/*
+			 * FIX: add sanity checks (eg. that values makes
+			 * sense, that we don't overwrite old values, etc
+			 */
+			cpu = get_cpu();
+			memcpy(thread->tls_array, desc, size);
+			load_TLS(thread, cpu);
+			put_cpu();
+		}
+		kfree(desc);
+	}
+
+	ret = 0;
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+#ifdef CONFIG_X86_64
+
+#error "CONFIG_X86_64 unsupported yet."
+
+#else	/* !CONFIG_X86_64 */
+
+static int load_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
+
+	regs->bx = h->bx;
+	regs->cx = h->cx;
+	regs->dx = h->dx;
+	regs->si = h->si;
+	regs->di = h->di;
+	regs->bp = h->bp;
+	regs->ax = h->ax;
+	regs->ds = h->ds;
+	regs->es = h->es;
+	regs->orig_ax = h->orig_ax;
+	regs->ip = h->ip;
+	regs->cs = h->cs;
+	regs->flags = h->flags;
+	regs->sp = h->sp;
+	regs->ss = h->ss;
+
+	thread->gs = h->gs;
+	thread->fs = h->fs;
+	loadsegment(gs, h->gs);
+	loadsegment(fs, h->fs);
+
+	return 0;
+}
+
+static int load_cpu_debug(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	/* debug regs */
+
+	if (h->uses_debug) {
+		set_debugreg(h->debugreg0, 0);
+		set_debugreg(h->debugreg1, 1);
+		/* ignore 4, 5 */
+		set_debugreg(h->debugreg2, 2);
+		set_debugreg(h->debugreg3, 3);
+		set_debugreg(h->debugreg6, 6);
+		set_debugreg(h->debugreg7, 7);
+	}
+
+	return 0;
+}
+
+static int load_cpu_fpu(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	preempt_disable();
+
+	__clear_fpu(t);		/* in case we used FPU in user mode */
+
+	if (!h->used_math)
+		clear_used_math();
+
+	preempt_enable();
+	return 0;
+}
+
+static int restore_cpu_fpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	void *xstate_buf;
+	int ret;
+
+	xstate_buf = ckpt_hdr_get(ctx, xstate_size);
+	if (!xstate_buf)
+		return -ENOMEM;
+
+	ret = ckpt_kread(ctx, xstate_buf, xstate_size);
+	if (ret < 0)
+		goto out;
+
+	/* init_fpu() eventually also calls set_used_math() */
+	ret = init_fpu(current);
+	if (ret < 0)
+		goto out;
+
+	memcpy(t->thread.xstate, xstate_buf, xstate_size);
+ out:
+	_ckpt_hdr_put(ctx, xstate_buf, xstate_size);
+	return ret;
+}
+
+#endif	/* CONFIG_X86_64 */
+
+/* read the cpu state and registers for the current task */
+int restore_cpu(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_cpu *h;
+	struct task_struct *t = current;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CPU);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ckpt_debug("math %d debug %d\n", h->used_math, h->uses_debug);
+
+	/* FIX: sanity check for sensitive registers (eg. eflags) */
+
+	ret = load_cpu_regs(h, t);
+	if (ret < 0)
+		goto out;
+	ret = load_cpu_debug(h, t);
+	if (ret < 0)
+		goto out;
+	ret = load_cpu_fpu(h, t);
+	if (ret < 0)
+		goto out;
+
+	if (h->used_math)
+		ret = restore_cpu_fpu(ctx, t);
+ out:
+	ckpt_hdr_put(ctx, h);
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
+	    h->xstate_size != xstate_size)
+		ret = -EINVAL;
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 6ac3571..62ba0a6 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -22,6 +22,8 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
+#include "checkpoint_arch.h"
+
 /* unique checkpoint identifier (FIXME: should be per-container ?) */
 static atomic_t ctx_count = ATOMIC_INIT(0);
 
@@ -135,7 +137,10 @@ static int checkpoint_write_header(struct ckpt_ctx *ctx)
 	ret = ckpt_write_buffer(ctx, uts->machine, sizeof(uts->machine));
  up:
 	up_read(&uts_sem);
-	return ret;
+	if (ret < 0)
+		return ret;
+
+	return checkpoint_write_header_arch(ctx);
 }
 
 /* write the checkpoint trailer */
diff --git a/checkpoint/checkpoint_arch.h b/checkpoint/checkpoint_arch.h
new file mode 100644
index 0000000..2ee4d7f
--- /dev/null
+++ b/checkpoint/checkpoint_arch.h
@@ -0,0 +1,9 @@
+#include <linux/checkpoint.h>
+
+extern int checkpoint_write_header_arch(struct ckpt_ctx *ctx);
+extern int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t);
+
+extern int restore_read_header_arch(struct ckpt_ctx *ctx);
+extern int restore_thread(struct ckpt_ctx *ctx);
+extern int restore_cpu(struct ckpt_ctx *ctx);
diff --git a/checkpoint/process.c b/checkpoint/process.c
index bf7545e..0578182 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -15,6 +15,8 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
+#include "checkpoint_arch.h"
+
 /***********************************************************************
  * Checkpoint
  */
@@ -53,7 +55,15 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	ret = checkpoint_task_struct(ctx, t);
 	ckpt_debug("ret %d\n", ret);
-
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_thread(ctx, t);
+	ckpt_debug("thread: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_cpu(ctx, t);
+	ckpt_debug("cpu: ret %d\n", ret);
+ out:
 	return ret;
 }
 
@@ -92,6 +102,14 @@ int restore_task(struct ckpt_ctx *ctx)
 
 	ret = restore_task_struct(ctx);
 	ckpt_debug("ret %d\n", ret);
-
+	if (ret < 0)
+		goto out;
+	ret = restore_thread(ctx);
+	ckpt_debug("thread: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_cpu(ctx);
+	ckpt_debug("cpu: ret %d\n", ret);
+ out:
 	return ret;
 }
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index d71c0f0..9adcc90 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -19,6 +19,8 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
+#include "checkpoint_arch.h"
+
 /**
  * _ckpt_read_obj - read an object (ckpt_hdr followed by payload)
  * @ctx: checkpoint context
@@ -258,6 +260,10 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		goto out;
 	ret = _ckpt_read_buffer(ctx, uts->machine, sizeof(uts->machine));
+	if (ret < 0)
+		goto out;
+
+	ret = restore_read_header_arch(ctx);
  out:
 	kfree(uts);
 	ckpt_hdr_put(ctx, h);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 45378aa..9716f4b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -41,6 +41,7 @@ struct ckpt_hdr {
 /* header types */
 enum {
 	CKPT_HDR_HEADER = 1,
+	CKPT_HDR_HEADER_ARCH,
 	CKPT_HDR_BUFFER,
 	CKPT_HDR_STRING,
 
-- 
1.5.4.3
