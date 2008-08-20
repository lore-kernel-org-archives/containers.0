From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC v2][PATCH 3/9] checkpoint/restart: x86 support
Date: Wed, 20 Aug 2008 12:26:00 -0700
Message-ID: <20080820192600.B0F4DD62__34932.4914430783$1219260621$gmane$org@nimitz>
References: <20080820192557.98788FAB@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080820192557.98788FAB@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


The original version of Oren's patch contained a good hunk
of #ifdefs.  I've extracted all of those and created a bit
of an API for new architectures to follow.

Leaving Oren's sign-off because this is all still his code,
even though he hasn't seen it mangled like this before.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---

 oren-cr.git-dave/checkpoint/Makefile     |    1 
 oren-cr.git-dave/checkpoint/checkpoint.c |    7 
 oren-cr.git-dave/checkpoint/ckpt.h       |    3 
 oren-cr.git-dave/checkpoint/ckpt_arch.h  |    6 
 oren-cr.git-dave/checkpoint/restart.c    |    7 
 oren-cr.git-dave/checkpoint/x86.c        |  270 +++++++++++++++++++++++++++++++
 oren-cr.git-dave/include/asm-x86/ckpt.h  |   46 +++++
 7 files changed, 340 insertions(+)

diff -puN checkpoint/checkpoint.c~0004-checkpoint-restart-x86-support checkpoint/checkpoint.c
--- oren-cr.git/checkpoint/checkpoint.c~0004-checkpoint-restart-x86-support	2008-08-20 12:12:49.000000000 -0700
+++ oren-cr.git-dave/checkpoint/checkpoint.c	2008-08-20 12:12:49.000000000 -0700
@@ -20,6 +20,7 @@
 
 #include "ckpt.h"
 #include "ckpt_hdr.h"
+#include "ckpt_arch.h"
 
 /**
  * cr_get_fname - return pathname of a given file
@@ -184,6 +185,12 @@ static int cr_write_task(struct cr_ctx *
 
 	ret = cr_write_task_struct(ctx, t);
 	pr_debug("ret (task_struct) %d\n", ret);
+	if (!ret)
+		ret = cr_write_thread(ctx, t);
+	pr_debug("ret (thread) %d\n", ret);
+	if (!ret)
+		ret = cr_write_cpu(ctx, t);
+	pr_debug("ret (cpu) %d\n", ret);
 
 	return ret;
 }
diff -puN /dev/null checkpoint/ckpt_arch.h
--- /dev/null	2008-04-22 10:49:52.000000000 -0700
+++ oren-cr.git-dave/checkpoint/ckpt_arch.h	2008-08-20 12:12:49.000000000 -0700
@@ -0,0 +1,6 @@
+#include "ckpt.h"
+
+int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t);
+int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t);
+int cr_read_thread(struct cr_ctx *ctx);
+int cr_read_cpu(struct cr_ctx *ctx);
diff -puN checkpoint/ckpt.h~0004-checkpoint-restart-x86-support checkpoint/ckpt.h
--- oren-cr.git/checkpoint/ckpt.h~0004-checkpoint-restart-x86-support	2008-08-20 12:12:49.000000000 -0700
+++ oren-cr.git-dave/checkpoint/ckpt.h	2008-08-20 12:12:49.000000000 -0700
@@ -54,6 +54,9 @@ extern int cr_kwrite(struct cr_ctx *ctx,
 extern int cr_uread(struct cr_ctx *ctx, void *buf, int count);
 extern int cr_kread(struct cr_ctx *ctx, void *buf, int count);
 
+extern void *cr_hbuf_get(struct cr_ctx *ctx, int size);
+extern void cr_hbuf_put(struct cr_ctx *ctx, int n);
+
 struct cr_hdr;
 
 extern int cr_write_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf);
diff -puN checkpoint/Makefile~0004-checkpoint-restart-x86-support checkpoint/Makefile
--- oren-cr.git/checkpoint/Makefile~0004-checkpoint-restart-x86-support	2008-08-20 12:12:49.000000000 -0700
+++ oren-cr.git-dave/checkpoint/Makefile	2008-08-20 12:12:49.000000000 -0700
@@ -1 +1,2 @@
 obj-y += sys.o checkpoint.o restart.o
+obj-$(CONFIG_X86) += x86.o
diff -puN checkpoint/restart.c~0004-checkpoint-restart-x86-support checkpoint/restart.c
--- oren-cr.git/checkpoint/restart.c~0004-checkpoint-restart-x86-support	2008-08-20 12:12:49.000000000 -0700
+++ oren-cr.git-dave/checkpoint/restart.c	2008-08-20 12:12:49.000000000 -0700
@@ -22,6 +22,7 @@
 
 #include "ckpt.h"
 #include "ckpt_hdr.h"
+#include "ckpt_arch.h"
 
 /**
  * cr_hbuf_get - reserve space on the hbuf
@@ -172,6 +173,12 @@ static int cr_read_task(struct cr_ctx *c
 
 	ret = cr_read_task_struct(ctx);
 	pr_debug("ret (task_struct) %d\n", ret);
+	if (!ret)
+		ret = cr_read_thread(ctx);
+	pr_debug("ret (thread) %d\n", ret);
+	if (!ret)
+		ret = cr_read_cpu(ctx);
+	pr_debug("ret (cpu) %d\n", ret);
 
 	return ret;
 }
diff -puN /dev/null checkpoint/x86.c
--- /dev/null	2008-04-22 10:49:52.000000000 -0700
+++ oren-cr.git-dave/checkpoint/x86.c	2008-08-20 12:12:49.000000000 -0700
@@ -0,0 +1,270 @@
+#include <asm/ckpt.h>
+#include <asm/desc.h>
+#include <asm/i387.h>
+
+#include "ckpt.h"
+#include "ckpt_hdr.h"
+
+/* dump the thread_struct of a given task */
+int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_thread *hh = ctx->tbuf;
+	struct thread_struct *thread;
+	struct desc_struct *desc;
+	int ntls = 0;
+	int n, ret;
+
+	h.type = CR_HDR_THREAD;
+	h.len = sizeof(*hh);
+	h.id = ctx->pid;
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
+	hh->gdt_entry_tls_entries = GDT_ENTRY_TLS_ENTRIES;
+	hh->sizeof_tls_array = sizeof(thread->tls_array);
+	hh->ntls = ntls;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret < 0)
+		return ret;
+
+	/* for simplicity dump the entire array, cherry-pick upon restart */
+	ret = cr_kwrite(ctx, thread->tls_array, sizeof(thread->tls_array));
+
+	pr_debug("ntls %d\n", ntls);
+
+	/* IGNORE RESTART BLOCKS FOR NOW ... */
+
+	return ret;
+}
+
+/* dump the cpu state and registers of a given task */
+int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_cpu *hh = ctx->tbuf;
+	struct thread_struct *thread;
+	struct thread_info *thread_info;
+	struct pt_regs *regs;
+
+	h.type = CR_HDR_CPU;
+	h.len = sizeof(*hh);
+	h.id = ctx->pid;
+
+	thread = &t->thread;
+	thread_info = task_thread_info(t);
+	regs = task_pt_regs(t);
+
+	hh->bx = regs->bx;
+	hh->cx = regs->cx;
+	hh->dx = regs->dx;
+	hh->si = regs->si;
+	hh->di = regs->di;
+	hh->bp = regs->bp;
+	hh->ax = regs->ax;
+	hh->ds = regs->ds;
+	hh->es = regs->es;
+	hh->orig_ax = regs->orig_ax;
+	hh->ip = regs->ip;
+	hh->cs = regs->cs;
+	hh->flags = regs->flags;
+	hh->sp = regs->sp;
+	hh->ss = regs->ss;
+
+	/* for checkpoint in process context (from within a container)
+	   the GS and FS registers should be saved from the hardware;
+	   otherwise they are already sabed on the thread structure */
+	if (t == current) {
+		savesegment(gs, hh->gs);
+		savesegment(fs, hh->fs);
+	} else {
+		hh->gs = thread->gs;
+		hh->fs = thread->fs;
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
+		BUG_ON(hh->orig_ax < 0);
+		hh->ax = 0;
+	}
+
+	preempt_disable();
+
+	/* i387 + MMU + SSE logic */
+	hh->used_math = tsk_used_math(t) ? 1 : 0;
+	if (hh->used_math) {
+		/* normally, no need to unlazy_fpu(), since TS_USEDFPU flag
+		 * have been cleared when task was conexted-switched out...
+		 * except if we are in process context, in which case we do */
+		if (thread_info->status & TS_USEDFPU)
+			unlazy_fpu(current);
+
+		hh->has_fxsr = cpu_has_fxsr;
+		memcpy(&hh->xstate, &thread->xstate, sizeof(thread->xstate));
+	}
+
+	/* debug regs */
+
+	/*
+	 * for checkpoint in process context (from within a container),
+	 * get the actual registers; otherwise get the saved values.
+	 */
+	if (t == current) {
+		get_debugreg(hh->debugreg0, 0);
+		get_debugreg(hh->debugreg1, 1);
+		get_debugreg(hh->debugreg2, 2);
+		get_debugreg(hh->debugreg3, 3);
+		get_debugreg(hh->debugreg6, 6);
+		get_debugreg(hh->debugreg7, 7);
+	} else {
+		hh->debugreg0 = thread->debugreg0;
+		hh->debugreg1 = thread->debugreg1;
+		hh->debugreg2 = thread->debugreg2;
+		hh->debugreg3 = thread->debugreg3;
+		hh->debugreg6 = thread->debugreg6;
+		hh->debugreg7 = thread->debugreg7;
+	}
+
+	hh->uses_debug = !!(thread_info->flags & TIF_DEBUG);
+
+	preempt_enable();
+
+	pr_debug("math %d debug %d\n", hh->used_math, hh->uses_debug);
+
+	return cr_write_obj(ctx, &h, hh);
+}
+
+/* read the thread_struct into the current task */
+int cr_read_thread(struct cr_ctx *ctx)
+{
+	struct cr_hdr_thread *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct task_struct *t = current;
+	struct thread_struct *thread = &t->thread;
+	int ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_THREAD);
+	if (ret < 0)
+		return ret;
+
+	pr_debug("ntls %d\n", hh->ntls);
+
+	if (hh->gdt_entry_tls_entries != GDT_ENTRY_TLS_ENTRIES ||
+	    hh->sizeof_tls_array != sizeof(thread->tls_array) ||
+	    hh->ntls < 0 || hh->ntls > GDT_ENTRY_TLS_ENTRIES)
+		return -EINVAL;
+
+	if (hh->ntls > 0) {
+
+		/* restore TLS by hand: why convert to struct user_desc if
+		 * sys_set_thread_entry() will convert it back ? */
+
+		struct desc_struct *buf = ctx->tbuf;
+		int size = sizeof(*buf) * GDT_ENTRY_TLS_ENTRIES;
+		int cpu;
+
+		BUG_ON(size > CR_TBUF_TOTAL);
+
+		ret = cr_kread(ctx, buf, size);
+		if (ret < 0)
+			return ret;
+
+		/* FIX: add sanity checks (eg. that values makes sense, that
+		 * that we don't overwrite old values, etc */
+
+		cpu = get_cpu();
+		memcpy(thread->tls_array, buf, size);
+		load_TLS(thread, cpu);
+		put_cpu();
+	}
+
+	return 0;
+}
+
+/* read the cpu state nad registers for the current task */
+int cr_read_cpu(struct cr_ctx *ctx)
+{
+	struct cr_hdr_cpu *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct task_struct *t = current;
+	struct thread_struct *thread;
+	struct thread_info *thread_info;
+	struct pt_regs *regs;
+	int ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_CPU);
+	if (ret < 0)
+		return ret;
+
+	/* FIX: sanity check for sensitive registers (eg. eflags) */
+
+	thread = &t->thread;
+	thread_info = task_thread_info(t);
+	regs = task_pt_regs(t);
+
+	regs->bx = hh->bx;
+	regs->cx = hh->cx;
+	regs->dx = hh->dx;
+	regs->si = hh->si;
+	regs->di = hh->di;
+	regs->bp = hh->bp;
+	regs->ax = hh->ax;
+	regs->ds = hh->ds;
+	regs->es = hh->es;
+	regs->orig_ax = hh->orig_ax;
+	regs->ip = hh->ip;
+	regs->cs = hh->cs;
+	regs->flags = hh->flags;
+	regs->sp = hh->sp;
+	regs->ss = hh->ss;
+
+	thread->gs = hh->gs;
+	thread->fs = hh->fs;
+	loadsegment(gs, hh->gs);
+	loadsegment(fs, hh->fs);
+
+	pr_debug("math %d debug %d\n", hh->used_math, hh->uses_debug);
+
+	/* FIX: this should work ... (someone double check !) */
+
+	preempt_disable();
+
+	/* i387 + MMU + SSE */
+	__clear_fpu(t);		/* in case we used FPU in user mode */
+	if (!hh->used_math)
+		clear_used_math();
+	else {
+		if (hh->has_fxsr != cpu_has_fxsr) {
+			force_sig(SIGFPE, t);
+			return -EINVAL;
+		}
+		memcpy(&thread->xstate, &hh->xstate, sizeof(thread->xstate));
+		set_used_math();
+	}
+
+	/* debug regs */
+	if (hh->uses_debug) {
+		set_debugreg(hh->debugreg0, 0);
+		set_debugreg(hh->debugreg1, 1);
+		set_debugreg(hh->debugreg2, 2);
+		set_debugreg(hh->debugreg3, 3);
+		set_debugreg(hh->debugreg6, 6);
+		set_debugreg(hh->debugreg7, 7);
+	}
+
+	preempt_enable();
+
+	return 0;
+}
diff -puN /dev/null include/asm-x86/ckpt.h
--- /dev/null	2008-04-22 10:49:52.000000000 -0700
+++ oren-cr.git-dave/include/asm-x86/ckpt.h	2008-08-20 12:12:49.000000000 -0700
@@ -0,0 +1,46 @@
+#ifndef __ASM_X86_CKPT_H
+#define __ASM_X86_CKPT_H
+
+#include <asm/processor.h>
+
+struct cr_hdr_thread {
+	/* NEED: restart blocks */
+	__s16 gdt_entry_tls_entries;
+	__s16 sizeof_tls_array;
+	__s16 ntls;	/* number of TLS entries to follow */
+};
+
+struct cr_hdr_cpu {
+	__u64 bx;
+	__u64 cx;
+	__u64 dx;
+	__u64 si;
+	__u64 di;
+	__u64 bp;
+	__u64 ax;
+	__u64 ds;
+	__u64 es;
+	__u64 orig_ax;
+	__u64 ip;
+	__u64 cs;
+	__u64 flags;
+	__u64 sp;
+	__u64 ss;
+	__u64 fs;
+	__u64 gs;
+
+	__u64 debugreg0;
+	__u64 debugreg1;
+	__u64 debugreg2;
+	__u64 debugreg3;
+	__u64 debugreg6;
+	__u64 debugreg7;
+
+	__u8 uses_debug;
+
+	__u8 used_math;
+	__u8 has_fxsr;
+	union thread_xstate xstate;	/* i387 */
+};
+
+#endif /* __ASM_X86_CKPT_H */
_
