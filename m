From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v2][PATCH 3/9] x86 support for checkpoint/restart
Date: Wed, 20 Aug 2008 23:04:46 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0808202304180.17436__36063.5191239$1219288164$gmane$org@takamine.ncl.cs.columbia.edu>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0808202251500.17436-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
List-Id: containers.vger.kernel.org


(Following Dave Hansen's refactoring of the original post)

Add logic to save and restore architecture specific state, including
thread-specific state, CPU registers and FPU state.

Currently only x86-32 is supported. Compiling on x86-64 will trigger
an explicit error.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
  checkpoint/Makefile     |    1 +
  checkpoint/checkpoint.c |    9 ++-
  checkpoint/ckpt_arch.h  |    7 ++
  checkpoint/ckpt_x86.c   |  190 +++++++++++++++++++++++++++++++++++++++++++++++
  checkpoint/restart.c    |   11 ++-
  checkpoint/rstr_x86.c   |  176 +++++++++++++++++++++++++++++++++++++++++++
  include/asm-x86/ckpt.h  |   72 ++++++++++++++++++
  7 files changed, 463 insertions(+), 3 deletions(-)
  create mode 100644 checkpoint/ckpt_arch.h
  create mode 100644 checkpoint/ckpt_x86.c
  create mode 100644 checkpoint/rstr_x86.c
  create mode 100644 include/asm-x86/ckpt.h

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index d129878..29dbb2d 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -1 +1,2 @@
  obj-y += sys.o checkpoint.o restart.o
+obj-$(CONFIG_X86) += ckpt_x86.o rstr_x86.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 25343f5..949ed58 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -20,6 +20,7 @@

  #include "ckpt.h"
  #include "ckpt_hdr.h"
+#include "ckpt_arch.h"

  /**
   * cr_fill_fname - return pathname of a given file
@@ -166,7 +167,13 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
  	}

  	ret = cr_write_task_struct(ctx, t);
-	cr_debug("ret %d\n", ret);
+	cr_debug("task_struct: ret %d\n", ret);
+	if (!ret)
+		ret = cr_write_thread(ctx, t);
+	cr_debug("thread: ret %d\n", ret);
+	if (!ret)
+		ret = cr_write_cpu(ctx, t);
+	cr_debug("cpu: ret %d\n", ret);

  	return ret;
  }
diff --git a/checkpoint/ckpt_arch.h b/checkpoint/ckpt_arch.h
new file mode 100644
index 0000000..b7cc8c9
--- /dev/null
+++ b/checkpoint/ckpt_arch.h
@@ -0,0 +1,7 @@
+#include "ckpt.h"
+
+int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t);
+int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t);
+
+int cr_read_thread(struct cr_ctx *ctx);
+int cr_read_cpu(struct cr_ctx *ctx);
diff --git a/checkpoint/ckpt_x86.c b/checkpoint/ckpt_x86.c
new file mode 100644
index 0000000..ad6c8e8
--- /dev/null
+++ b/checkpoint/ckpt_x86.c
@@ -0,0 +1,190 @@
+/*
+ *  Checkpoint/restart - architecture specific support for x86
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
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
+	struct cr_hdr_thread *hh = ctx->hbuf;
+	struct thread_struct *thread;
+	struct desc_struct *desc;
+	int ntls = 0;
+	int n, ret;
+
+	h.type = CR_HDR_THREAD;
+	h.len = sizeof(*hh);
+	h.ptag = task_pid_vnr(t);
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
+	cr_debug("ntls %d\n", ntls);
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
+void cr_write_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
+
+	hh->bp = regs->bp;
+	hh->bx = regs->bx;
+	hh->ax = regs->ax;
+	hh->cx = regs->cx;
+	hh->dx = regs->dx;
+	hh->si = regs->si;
+	hh->di = regs->di;
+	hh->orig_ax = regs->orig_ax;
+	hh->ip = regs->ip;
+	hh->cs = regs->cs;
+	hh->flags = regs->flags;
+	hh->sp = regs->sp;
+	hh->ss = regs->ss;
+
+	hh->ds = regs->ds;
+	hh->es = regs->es;
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
+}
+
+void cr_write_cpu_debug(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+
+	/* debug regs */
+
+	preempt_disable();
+
+	/*
+	 * for checkpoint in process context (from within a container),
+	 * get the actual registers; otherwise get the saved values.
+	 */
+
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
+	hh->debugreg4 = 0;
+	hh->debugreg5 = 0;
+
+	hh->uses_debug = !!(task_thread_info(t)->flags & TIF_DEBUG);
+
+	preempt_enable();
+}
+
+void cr_write_cpu_fpu(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct thread_info *thread_info = task_thread_info(t);
+
+	/* i387 + MMU + SSE logic */
+
+	preempt_disable();
+
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
+	preempt_enable();
+}
+
+#endif	/* CONFIG_X86_64 */
+
+/* dump the cpu state and registers of a given task */
+int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_cpu *hh = ctx->hbuf;
+
+	h.type = CR_HDR_CPU;
+	h.len = sizeof(*hh);
+	h.ptag = task_pid_vnr(t);
+
+	cr_write_cpu_regs(hh, t);
+	cr_write_cpu_debug(hh, t);
+	cr_write_cpu_fpu(hh, t);
+
+	cr_debug("math %d debug %d\n", hh->used_math, hh->uses_debug);
+
+	return cr_write_obj(ctx, &h, hh);
+}
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index be7d08c..a85f48b 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -21,6 +21,7 @@

  #include "ckpt.h"
  #include "ckpt_hdr.h"
+#include "ckpt_arch.h"

  /**
   * cr_hbuf_get - reserve space on the hbuf
@@ -63,7 +64,7 @@ int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n)
  	if (ret < 0)
  		return ret;

-	cr_debug("type %d len %d id %d (%d)\n", h->type, h->len, h->ptag, n);
+	cr_debug("type %d len %d ptag %d (%d)\n", h->type, h->len, h->ptag, n);

  	if (h->len < 0 || h->len > n)
  		return -EINVAL;
@@ -180,7 +181,13 @@ static int cr_read_task(struct cr_ctx *ctx)
  	int ret;

  	ret = cr_read_task_struct(ctx);
-	cr_debug("ret %d\n", ret);
+	cr_debug("task_struct: ret %d\n", ret);
+	if (!ret)
+		ret = cr_read_thread(ctx);
+	cr_debug("thread: ret %d\n", ret);
+	if (!ret)
+		ret = cr_read_cpu(ctx);
+	cr_debug("cpu: ret %d\n", ret);

  	return ret;
  }
diff --git a/checkpoint/rstr_x86.c b/checkpoint/rstr_x86.c
new file mode 100644
index 0000000..a24a7de
--- /dev/null
+++ b/checkpoint/rstr_x86.c
@@ -0,0 +1,176 @@
+/*
+ *  Checkpoint/restart - architecture specific support for x86
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <asm/ckpt.h>
+#include <asm/desc.h>
+#include <asm/i387.h>
+
+#include "ckpt.h"
+#include "ckpt_hdr.h"
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
+#if 0	/* activate when containers are used */
+	if (ret != task_pid_vnr(t))
+		return -EINVAL;
+#endif
+	cr_debug("ntls %d\n", hh->ntls);
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
+#ifdef CONFIG_X86_64
+
+#error "CONFIG_X86_64 unsupported yet."
+
+#else	/* !CONFIG_X86_64 */
+
+int cr_read_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
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
+	return 0;
+}
+
+int cr_read_cpu_debug(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	/* debug regs */
+
+	preempt_disable();
+
+	if (hh->uses_debug) {
+		set_debugreg(hh->debugreg0, 0);
+		set_debugreg(hh->debugreg1, 1);
+		/* ignore 4, 5 */
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
+
+int cr_read_cpu_fpu(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+
+	/* i387 + MMU + SSE */
+
+	preempt_disable();
+
+	__clear_fpu(t);		/* in case we used FPU in user mode */
+
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
+	preempt_enable();
+
+	return 0;
+}
+
+#endif	/* CONFIG_X86_64 */
+
+/* read the cpu state and registers for the current task */
+int cr_read_cpu(struct cr_ctx *ctx)
+{
+	struct cr_hdr_cpu *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct task_struct *t = current;
+	int ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_CPU);
+	if (ret < 0)
+		return ret;
+#if 0	/* activate when containers are used */
+	if (ret != task_pid_vnr(t))
+		return -EINVAL;
+#endif
+	/* FIX: sanity check for sensitive registers (eg. eflags) */
+
+	ret = cr_read_cpu_regs(hh, t);
+	if (!ret)
+		ret = cr_read_cpu_debug(hh, t);
+	if (!ret)
+		ret = cr_read_cpu_fpu(hh, t);
+
+	cr_debug("math %d debug %d\n", hh->used_math, hh->uses_debug);
+
+	return ret;
+}
diff --git a/include/asm-x86/ckpt.h b/include/asm-x86/ckpt.h
new file mode 100644
index 0000000..cd74657
--- /dev/null
+++ b/include/asm-x86/ckpt.h
@@ -0,0 +1,72 @@
+#ifndef __ASM_X86_CKPT_H
+#define __ASM_X86_CKPT_H
+/*
+ *  Checkpoint/restart - architecture specific headers x86
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <asm/processor.h>
+
+struct cr_hdr_thread {
+	/* NEED: restart blocks */
+
+	__s16 gdt_entry_tls_entries;
+	__s16 sizeof_tls_array;
+	__s16 ntls;	/* number of TLS entries to follow */
+} __attribute__ ((aligned (8)));
+
+struct cr_hdr_cpu {
+	/* see struct pt_regs (x86-64) */
+        __u64 r15;
+        __u64 r14;
+        __u64 r13;
+        __u64 r12;
+        __u64 bp;
+        __u64 bx;
+        __u64 r11;
+        __u64 r10;
+        __u64 r9;
+        __u64 r8;
+        __u64 ax;
+        __u64 cx;
+        __u64 dx;
+        __u64 si;
+        __u64 di;
+        __u64 orig_ax;
+        __u64 ip;
+        __u64 cs;
+        __u64 flags;
+        __u64 sp;
+        __u64 ss;
+
+	/* segment registers */
+        __u64 ds;
+        __u64 es;
+        __u64 fs;
+        __u64 gs;
+
+	/* debug registers */
+	__u64 debugreg0;
+	__u64 debugreg1;
+	__u64 debugreg2;
+	__u64 debugreg3;
+	__u64 debugreg4;
+	__u64 debugreg5;
+	__u64 debugreg6;
+	__u64 debugreg7;
+
+	__u16 uses_debug;
+	__u16 used_math;
+	__u16 has_fxsr;
+	__u16 _padding;
+
+	union thread_xstate xstate;	/* i387 */
+
+} __attribute__ ((aligned (8)));
+
+#endif /* __ASM_X86_CKPT_H */
-- 
1.5.4.3
