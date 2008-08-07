From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 2/4] checkpoint/restart: x86 support
Date: Thu, 07 Aug 2008 15:40:35 -0700
Message-ID: <20080807224035.E56663BF__49904.5903831304$1218149165$gmane$org@kernel>
References: <20080807224033.FFB3A2C1@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080807224033.FFB3A2C1@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


The original version of Oren's patch contained a good hunk
of #ifdefs.  I've extracted all of those and created a bit
of an API for new architectures to follow.

Leaving Oren's sign-off because this is all still his code,
even though he hasn't seen it mangled like this before.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---

 linux-2.6.git-dave/ckpt/Makefile          |    1 
 linux-2.6.git-dave/ckpt/checkpoint.c      |    7 
 linux-2.6.git-dave/ckpt/ckpt_arch.h       |    6 
 linux-2.6.git-dave/ckpt/restart.c         |    7 
 linux-2.6.git-dave/ckpt/x86.c             |  269 ++++++++++++++++++++++++++++++
 linux-2.6.git-dave/include/asm-x86/ckpt.h |   46 +++++
 6 files changed, 336 insertions(+)

diff -puN ckpt/checkpoint.c~x86_part ckpt/checkpoint.c
--- linux-2.6.git/ckpt/checkpoint.c~x86_part	2008-08-04 13:29:59.000000000 -0700
+++ linux-2.6.git-dave/ckpt/checkpoint.c	2008-08-04 13:29:59.000000000 -0700
@@ -19,6 +19,7 @@
 
 #include "ckpt.h"
 #include "ckpt_hdr.h"
+#include "ckpt_arch.h"
 
 /**
  * cr_get_fname - return pathname of a given file
@@ -183,6 +184,12 @@ static int cr_write_task(struct cr_ctx *
 
 	ret = cr_write_task_struct(ctx, t);
 	CR_PRINTK("ret (task_struct) %d\n", ret);
+	if (!ret)
+		ret = cr_write_thread(ctx, t);
+	CR_PRINTK("ret (thread) %d\n", ret);
+	if (!ret)
+		ret = cr_write_cpu(ctx, t);
+	CR_PRINTK("ret (cpu) %d\n", ret);
 
 	return ret;
 }
diff -puN /dev/null ckpt/ckpt_arch.h
--- /dev/null	2007-04-11 11:48:27.000000000 -0700
+++ linux-2.6.git-dave/ckpt/ckpt_arch.h	2008-08-04 13:29:59.000000000 -0700
@@ -0,0 +1,6 @@
+#include "ckpt.h"
+
+int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t);
+int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t);
+int cr_read_thread(struct cr_ctx *ctx);
+int cr_read_cpu(struct cr_ctx *ctx);
diff -puN ckpt/Makefile~x86_part ckpt/Makefile
--- linux-2.6.git/ckpt/Makefile~x86_part	2008-08-04 13:29:59.000000000 -0700
+++ linux-2.6.git-dave/ckpt/Makefile	2008-08-04 13:29:59.000000000 -0700
@@ -1 +1,2 @@
 obj-y += sys.o checkpoint.o restart.o
+obj-$(CONFIG_X86) += x86.o
diff -puN ckpt/restart.c~x86_part ckpt/restart.c
--- linux-2.6.git/ckpt/restart.c~x86_part	2008-08-04 13:29:59.000000000 -0700
+++ linux-2.6.git-dave/ckpt/restart.c	2008-08-04 13:29:59.000000000 -0700
@@ -21,6 +21,7 @@
 
 #include "ckpt.h"
 #include "ckpt_hdr.h"
+#include "ckpt_arch.h"
 
 /**
  * cr_hbuf_get - reserve space on the hbuf
@@ -171,6 +172,12 @@ static int cr_read_task(struct cr_ctx *c
 
 	ret = cr_read_task_struct(ctx);
 	CR_PRINTK("ret (task_struct) %d\n", ret);
+	if (!ret)
+		ret = cr_read_thread(ctx);
+	CR_PRINTK("ret (thread) %d\n", ret);
+	if (!ret)
+		ret = cr_read_cpu(ctx);
+	CR_PRINTK("ret (cpu) %d\n", ret);
 
 	return ret;
 }
diff -puN /dev/null ckpt/x86.c
--- /dev/null	2007-04-11 11:48:27.000000000 -0700
+++ linux-2.6.git-dave/ckpt/x86.c	2008-08-04 13:29:59.000000000 -0700
@@ -0,0 +1,269 @@
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
+	if ((ret = cr_write_obj(ctx, &h, hh)) < 0)
+		return ret;
+
+	/* for simplicity dump the entire array, cherry-pick upon restart */
+	ret = cr_kwrite(ctx, thread->tls_array, sizeof(thread->tls_array));
+
+	CR_PRINTK("ntls %d\n", ntls);
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
+	CR_PRINTK("math %d debug %d\n", hh->used_math, hh->uses_debug);
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
+	CR_PRINTK("ntls %d\n", hh->ntls);
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
+        thread->gs = hh->gs;
+        thread->fs = hh->fs;
+	loadsegment(gs, hh->gs);
+	loadsegment(fs, hh->fs);
+
+	CR_PRINTK("math %d debug %d\n", hh->used_math, hh->uses_debug);
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
--- /dev/null	2007-04-11 11:48:27.000000000 -0700
+++ linux-2.6.git-dave/include/asm-x86/ckpt.h	2008-08-04 13:29:59.000000000 -0700
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
+        __u64 bx;
+        __u64 cx;
+        __u64 dx;
+        __u64 si;
+        __u64 di;
+        __u64 bp;
+        __u64 ax;
+        __u64 ds;
+        __u64 es;
+        __u64 orig_ax;
+        __u64 ip;
+        __u64 cs;
+        __u64 flags;
+        __u64 sp;
+        __u64 ss;
+        __u64 fs;
+        __u64 gs;
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
