From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Tue, 29 Jul 2008 23:27:17 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0807292325290.9868@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Expand the template sys_checkpoint and sys_restart to be able to dump
and restore a single task. The task's address space may consist of only
private, simple vma's - anonymous or file-mapped.

This big patch adds a mechanism to transfer data between kernel or user
space to and from the file given by the caller (sys.c), alloc/setup/free
of the checkpoint/restart context (sys.c), output wrappers and basic
checkpoint handling (checkpoint.c), memory dump (ckpt_mem.c), input
wrappers and basic restart handling (restart.c), and finally the memory
restore (rstr_mem.c).

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

---
  ckpt/Makefile     |    1 +
  ckpt/checkpoint.c |  366 ++++++++++++++++++++++++++++++++++++++++++++++
  ckpt/ckpt.h       |   78 ++++++++++
  ckpt/ckpt_hdr.h   |  143 ++++++++++++++++++
  ckpt/ckpt_mem.c   |  421 +++++++++++++++++++++++++++++++++++++++++++++++++++++
  ckpt/ckpt_mem.h   |   32 ++++
  ckpt/restart.c    |  328 +++++++++++++++++++++++++++++++++++++++++
  ckpt/rstr_mem.c   |  415 ++++++++++++++++++++++++++++++++++++++++++++++++++++
  ckpt/sys.c        |  239 ++++++++++++++++++++++++++++++
  9 files changed, 2023 insertions(+), 0 deletions(-)
  create mode 100644 ckpt/Makefile
  create mode 100644 ckpt/checkpoint.c
  create mode 100644 ckpt/ckpt.h
  create mode 100644 ckpt/ckpt_hdr.h
  create mode 100644 ckpt/ckpt_mem.c
  create mode 100644 ckpt/ckpt_mem.h
  create mode 100644 ckpt/restart.c
  create mode 100644 ckpt/rstr_mem.c
  create mode 100644 ckpt/sys.c

diff --git a/ckpt/Makefile b/ckpt/Makefile
new file mode 100644
index 0000000..41f205d
--- /dev/null
+++ b/ckpt/Makefile
@@ -0,0 +1 @@
+obj-y += sys.o checkpoint.o restart.o ckpt_mem.o rstr_mem.o
diff --git a/ckpt/checkpoint.c b/ckpt/checkpoint.c
new file mode 100644
index 0000000..1698a35
--- /dev/null
+++ b/ckpt/checkpoint.c
@@ -0,0 +1,366 @@
+/*
+ *  Checkpoint logic and helpers
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/version.h>
+#include <linux/sched.h>
+#include <linux/time.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/dcache.h>
+#include <linux/mount.h>
+#include <asm/ptrace.h>
+
+#if defined (CONFIG_X86)
+#include <asm/i387.h>
+#endif
+
+#include "ckpt.h"
+#include "ckpt_hdr.h"
+
+/**
+ * cr_get_fname - return pathname of a given file
+ * @file: file pointer
+ * @buf: buffer for pathname
+ * @n: buffer length (in) and pathname length (out)
+ *
+ * if the buffer provivded by the caller is too small, allocate a new
+ * buffer; caller should call cr_put_pathname() for cleanup
+ */
+char *cr_get_fname(struct path *path, struct path *root, char *buf, int *n)
+{
+	char *fname;
+
+	fname = __d_path(path, root, buf, *n);
+
+	if (IS_ERR(fname) && PTR_ERR(fname) == -ENAMETOOLONG) {
+		 if (!(buf = (char *) __get_free_pages(GFP_KERNEL, 0)))
+			 return ERR_PTR(-ENOMEM);
+		fname = __d_path(path, root, buf, PAGE_SIZE);
+		if (IS_ERR(fname))
+			free_pages((unsigned long) buf, 0);
+	}
+	if (!IS_ERR(fname))
+		*n = (buf + *n - fname);
+
+	return fname;
+}
+
+/**
+ * cr_put_fname - (possibly) cleanup pathname buffer
+ * @buf: original buffer that was given to cr_get_pathname()
+ * @fname: resulting pathname from cr_get_pathname()
+ * @n: length of original buffer
+ */
+void cr_put_fname(char *buf, char *fname, int n)
+{
+	if (fname && (fname < buf || fname >= buf + n))
+		free_pages((unsigned long) buf, 0);
+}
+
+/**
+ * cr_write_obj - write a record described by a cr_hdr
+ * @ctx: checkpoint context
+ * @h: record descriptor
+ * @buf: record buffer
+ */
+int cr_write_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf)
+{
+	int ret;
+
+	if ((ret = cr_kwrite(ctx, h, sizeof(*h))) < 0)
+		return ret;
+	return cr_kwrite(ctx, buf, h->len);
+}
+
+/**
+ * cr_write_str - write a string record
+ * @ctx: checkpoint context
+ * @str: string buffer
+ * @n: string length
+ */
+int cr_write_str(struct cr_ctx *ctx, char *str, int n)
+{
+	struct cr_hdr h;
+
+	h.type = CR_HDR_STR;
+	h.len = n;
+	h.id = 0;
+
+	return cr_write_obj(ctx, &h, str);
+}
+
+/* write the checkpoint header */
+static int cr_write_hdr(struct cr_ctx *ctx)
+{
+	struct cr_hdr h;
+	struct cr_hdr_head *hh = ctx->tbuf;
+	struct timeval ktv;
+
+	h.type = CR_HDR_HEAD;
+	h.len = sizeof(*hh);
+	h.id = 0;
+
+	do_gettimeofday(&ktv);
+
+	hh->magic = 0x00a2d200;
+	hh->major = (LINUX_VERSION_CODE >> 16) & 0xff;
+	hh->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
+	hh->patch = (LINUX_VERSION_CODE) & 0xff;
+
+	hh->version = 1;
+
+	hh->flags = ctx->flags;
+	hh->time = ktv.tv_sec;
+
+	return cr_write_obj(ctx, &h, hh);
+}
+
+/* write the checkpoint trailer */
+static int cr_write_tail(struct cr_ctx *ctx)
+{
+	struct cr_hdr h;
+	struct cr_hdr_tail *hh = ctx->tbuf;
+
+	h.type = CR_HDR_TAIL;
+	h.len = sizeof(*hh);
+	h.id = 0;
+
+	hh->magic = 0x002d2a00;
+	hh->cksum[0] = hh->cksum[1] = 1;	/* TBD ... */
+
+	return cr_write_obj(ctx, &h, hh);
+}
+
+/* dump the task_struct of a given task */
+static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_task *hh = ctx->tbuf;
+
+	h.type = CR_HDR_TASK;
+	h.len = sizeof(*hh);
+	h.id = ctx->pid;
+
+	hh->state = t->state;
+	hh->exit_state = t->exit_state;
+	hh->exit_code = t->exit_code;
+	hh->exit_signal = t->exit_signal;
+
+	hh->pid = t->pid;
+	hh->tgid = t->tgid;
+
+	hh->utime = t->utime;
+	hh->stime = t->stime;
+	hh->utimescaled = t->utimescaled;
+	hh->stimescaled = t->stimescaled;
+	hh->gtime = t->gtime;
+	hh->prev_utime = t->prev_utime;
+	hh->prev_stime = t->prev_stime;
+	hh->nvcsw = t->nvcsw;
+	hh->nivcsw = t->nivcsw;
+	hh->start_time_sec = t->start_time.tv_sec;
+	hh->start_time_nsec = t->start_time.tv_nsec;
+	hh->real_start_time_sec = t->real_start_time.tv_sec;
+	hh->real_start_time_nsec = t->real_start_time.tv_nsec;
+	hh->min_flt = t->min_flt;
+	hh->maj_flt = t->maj_flt;
+
+	hh->task_comm_len = TASK_COMM_LEN;
+	memcpy(hh->comm, t->comm, TASK_COMM_LEN);
+
+	return cr_write_obj(ctx, &h, hh);
+}
+
+#if defined(CONFIG_X86)
+/* dump the thread_struct of a given task */
+static int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
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
+#endif
+
+#if defined(CONFIG_X86)
+/* dump the cpu state and registers of a given task */
+static int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
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
+#endif
+
+/* dump the entire state of a given task */
+static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
+{
+	int ret ;
+
+	BUG_ON(t->state == TASK_DEAD);
+
+	ret = cr_write_task_struct(ctx, t);
+	CR_PRINTK("ret (task_struct) %d\n", ret);
+	if (!ret)
+		ret = cr_write_mm(ctx, t);
+	CR_PRINTK("ret (mm) %d\n", ret);
+	if (!ret)
+		ret = cr_write_thread(ctx, t);
+	CR_PRINTK("ret (thread) %d\n", ret);
+	if (!ret)
+		ret = cr_write_cpu(ctx, t);
+	CR_PRINTK("ret (cpu) %d\n", ret);
+
+	return ret;
+}
+
+int do_checkpoint(struct cr_ctx *ctx)
+{
+	int ret;
+
+	/* FIX: need to test whether container is checkpointable */
+
+	ret = cr_write_hdr(ctx);
+	if (!ret)
+		ret = cr_write_task(ctx, current);
+	if (!ret)
+		ret = cr_write_tail(ctx);
+
+	/* on success, return (unique) checkpoint identifier */
+	if (!ret)
+		ret = ctx->crid;
+
+	return ret;
+}
diff --git a/ckpt/ckpt.h b/ckpt/ckpt.h
new file mode 100644
index 0000000..699ecb9
--- /dev/null
+++ b/ckpt/ckpt.h
@@ -0,0 +1,78 @@
+/*
+ *  Generic container checkpoint-restart
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/path.h>
+#include <linux/fs.h>
+
+struct cr_pgarr;
+
+struct cr_ctx {
+	pid_t pid;		/* container identifier */
+	int crid;		/* unique checkpoint id */
+
+	unsigned long flags;
+	unsigned long oflags;	/* restart: old flags */
+
+	struct file *file;
+	int total;		/* total read/written */
+
+	void *tbuf;		/* temp: to avoid many alloc/dealloc */
+	void *hbuf;		/* header: to avoid many alloc/dealloc */
+	int hpos;
+
+	struct cr_pgarr *pgarr;
+	struct cr_pgarr *pgcur;
+
+	struct path *vfsroot;	/* container root */
+};
+
+/* cr_ctx: flags */
+#define CR_CTX_CKPT	0x1
+#define CR_CTX_RSTR	0x2
+
+/* allocation defaults */
+#define CR_ORDER_TBUF  1
+#define CR_ORDER_HBUF  1
+
+#define CR_TBUF_TOTAL  ((PAGE_SIZE << CR_ORDER_TBUF) / sizeof(void *))
+#define CR_HBUF_TOTAL  ((PAGE_SIZE << CR_ORDER_HBUF) / sizeof(void *))
+
+extern void cr_put_fname(char *buf, char *fname, int n);
+extern char *cr_get_fname(struct path *path, struct path *root, char *buf, int *n);
+
+extern int cr_uwrite(struct cr_ctx *ctx, void *buf, int count);
+extern int cr_kwrite(struct cr_ctx *ctx, void *buf, int count);
+extern int cr_uread(struct cr_ctx *ctx, void *buf, int count);
+extern int cr_kread(struct cr_ctx *ctx, void *buf, int count);
+
+extern void *cr_hbuf_get(struct cr_ctx *ctx, int n);
+extern void cr_hbuf_put(struct cr_ctx *ctx, int n);
+
+struct cr_hdr;
+
+extern int cr_write_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf);
+extern int cr_write_str(struct cr_ctx *ctx, char *str, int n);
+extern int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
+
+extern int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n);
+extern int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type);
+extern int cr_read_str(struct cr_ctx *ctx, void *str, int n);
+extern int cr_read_mm(struct cr_ctx *ctx);
+
+extern int do_checkpoint(struct cr_ctx *ctx);
+extern int do_restart(struct cr_ctx *ctx);
+
+/* debugging */
+#if 0
+#define CR_PRINTK(str, args...)  \
+	printk(KERN_ERR "cr@%s#%d: " str, __func__, __LINE__, ##args)
+#else
+#define CR_PRINTK(...)		do {} while (0)
+#endif
diff --git a/ckpt/ckpt_hdr.h b/ckpt/ckpt_hdr.h
new file mode 100644
index 0000000..d5e2043
--- /dev/null
+++ b/ckpt/ckpt_hdr.h
@@ -0,0 +1,143 @@
+/*
+ *  Generic container checkpoint-restart
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
+#if defined(CONFIG_X86)
+#include <asm/processor.h>
+#endif
+
+struct cr_hdr {
+	__s16 type;
+	__s16 len;
+	__u32 id;
+};
+
+enum {
+	CR_HDR_HEAD = 1,
+	CR_HDR_STR,
+
+	CR_HDR_TASK = 101,
+	CR_HDR_THREAD,
+	CR_HDR_CPU,
+
+	CR_HDR_MM = 201,
+	CR_HDR_VMA,
+	CR_HDR_MM_CONTEXT,
+
+	CR_HDR_TAIL = 5001
+};
+
+struct cr_hdr_head {
+	__u32 magic;
+	__u16 major;
+	__u16 minor;
+	__u16 patch;
+	__u16 version;
+	__u32 flags;	/* checkpoint options */
+	__u64 time;	/* when checkpoint taken */
+};
+
+struct cr_hdr_tail {
+	__u32 magic;
+	__u32 cksum[2];
+};
+
+struct cr_hdr_task {
+	__u64 state;
+	__u32 exit_state;
+	__u32 exit_code, exit_signal;
+
+	__u16 pid;
+	__u16 tgid;
+
+	__u64 utime, stime, utimescaled, stimescaled;
+	__u64 gtime;
+	__u64 prev_utime, prev_stime;
+	__u64 nvcsw, nivcsw;
+	__u64 start_time_sec, start_time_nsec;
+	__u64 real_start_time_sec, real_start_time_nsec;
+	__u64 min_flt, maj_flt;
+
+	__s16 task_comm_len;
+	char comm[TASK_COMM_LEN];
+};
+
+#if defined(CONFIG_X86)
+struct cr_hdr_thread {
+	/* NEED: restart blocks */
+	__s16 gdt_entry_tls_entries;
+	__s16 sizeof_tls_array;
+	__s16 ntls;	/* number of TLS entries to follow */
+};
+#endif
+
+#if defined(CONFIG_X86)
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
+#endif
+
+struct cr_hdr_mm {
+	__u32 tag;	/* sharing identifier */
+	__u64 start_code, end_code, start_data, end_data;
+	__u64 start_brk, brk, start_stack;
+	__u64 arg_start, arg_end, env_start, env_end;
+	__s16 map_count;
+};
+
+#if defined(CONFIG_X86)
+struct cr_hdr_mm_context {
+	__s16 ldt_entry_size;
+	__s16 nldt;
+};
+#endif
+
+struct cr_hdr_vma {
+	__u32 how;
+
+	__u64 vm_start;
+	__u64 vm_end;
+	__u64 vm_page_prot;
+	__u64 vm_flags;
+	__u64 vm_pgoff;
+
+	__s16 npages;
+	__s16 namelen;
+};
diff --git a/ckpt/ckpt_mem.c b/ckpt/ckpt_mem.c
new file mode 100644
index 0000000..12caad0
--- /dev/null
+++ b/ckpt/ckpt_mem.c
@@ -0,0 +1,421 @@
+/*
+ *  Checkpoint memory contents
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/file.h>
+#include <linux/pagemap.h>
+#include <linux/mm_types.h>
+
+#if defined(CONFIG_X86)
+#include <asm/ldt.h>
+#endif
+
+#include "ckpt.h"
+#include "ckpt_hdr.h"
+#include "ckpt_mem.h"
+
+/*
+ * utilities to alloc, free, and handle 'struct cr_pgarr'
+ * (common to ckpt_mem.c and rstr_mem.c)
+ */
+
+#define CR_ORDER_PGARR  0
+#define CR_PGARR_TOTAL  ((PAGE_SIZE << CR_ORDER_PGARR) / sizeof(void *))
+
+/* release pages referenced by a page-array */
+void _cr_pgarr_release(struct cr_ctx *ctx, struct cr_pgarr *pgarr)
+{
+	int n;
+
+	/* only checkpoint keeps references to pages */
+	if (ctx->flags & CR_CTX_CKPT) {
+		CR_PRINTK("release pages (nused %d)\n", pgarr->nused);
+		for (n = pgarr->nused; n--; )
+			page_cache_release(pgarr->pages[n]);
+	}
+	pgarr->nused = 0;
+	pgarr->nleft = CR_PGARR_TOTAL;
+}
+
+/* release pages referenced by chain of page-arrays */
+void cr_pgarr_release(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr;
+
+	for (pgarr = ctx->pgarr; pgarr; pgarr = pgarr->next)
+		_cr_pgarr_release(ctx, pgarr);
+}
+
+/* free a chain of page-arrays */
+void cr_pgarr_free(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr, *pgnxt;
+
+	for (pgarr = ctx->pgarr; pgarr; pgarr = pgnxt) {
+		_cr_pgarr_release(ctx, pgarr);
+		free_pages((unsigned long) ctx->pgarr->addrs, CR_ORDER_PGARR);
+		free_pages((unsigned long) ctx->pgarr->pages, CR_ORDER_PGARR);
+		pgnxt = pgarr->next;
+		kfree(pgarr);
+	}
+}
+
+/* allocate and add a new page-array to chain */
+struct cr_pgarr *cr_pgarr_alloc(struct cr_ctx *ctx, struct cr_pgarr **pgnew)
+{
+	struct cr_pgarr *pgarr = ctx->pgcur;
+
+	if (pgarr && pgarr->next) {
+		ctx->pgcur = pgarr->next;
+		return pgarr->next;
+	}
+
+	if ((pgarr = kzalloc(sizeof(*pgarr), GFP_KERNEL))) {
+		pgarr->nused = 0;
+		pgarr->nleft = CR_PGARR_TOTAL;
+		pgarr->addrs = (unsigned long *)
+			__get_free_pages(GFP_KERNEL, CR_ORDER_PGARR);
+		pgarr->pages = (struct page **)
+			__get_free_pages(GFP_KERNEL, CR_ORDER_PGARR);
+		if (likely(pgarr->addrs && pgarr->pages)) {
+			*pgnew = pgarr;
+			ctx->pgcur = pgarr;
+			return pgarr;
+		} else if (pgarr->addrs)
+			free_pages((unsigned long) pgarr->addrs,
+				   CR_ORDER_PGARR);
+		kfree(pgarr);
+	}
+
+	return NULL;
+}
+
+/* return current page-array (and allocate if needed) */
+struct cr_pgarr *cr_pgarr_prep(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr = ctx->pgcur;
+
+	if (unlikely(!pgarr->nleft))
+		pgarr = cr_pgarr_alloc(ctx, &pgarr->next);
+	return pgarr;
+}
+
+/*
+ * Checkpoint is outside the context of the checkpointee, so one cannot
+ * simply read pages from user-space. Instead, we scan the address space
+ * of the target to cherry-pick pages of interest. Selected pages are
+ * enlisted in a page-array chain (attached to the checkpoint context).
+ * To save their contents, each page is mapped to kernel memory and then
+ * dumped to the file descriptor.
+ */
+
+/**
+ * cr_vma_fill_pgarr - fill a page-array with addr/page tuples for a vma
+ * @ctx - checkpoint context
+ * @pgarr - page-array to fill
+ * @vma - vma to scan
+ * @start - start address (updated)
+ */
+static int cr_vma_fill_pgarr(struct cr_ctx *ctx, struct cr_pgarr *pgarr,
+			     struct vm_area_struct *vma, unsigned long *start)
+{
+	unsigned long end = vma->vm_end;
+	unsigned long addr = *start;
+	struct page **pagep;
+	unsigned long *addrp;
+	int cow, nr, ret = 0;
+
+	nr = pgarr->nleft;
+	pagep = &pgarr->pages[pgarr->nused];
+	addrp = &pgarr->addrs[pgarr->nused];
+	cow = !!vma->vm_file;
+
+	while (addr < end) {
+		struct page *page;
+
+		/* simplified version of get_user_pages(): already have vma,
+		* only need FOLL_TOUCH, and (for now) ignore fault stats */
+
+		cond_resched();
+		while (!(page = follow_page(vma, addr, FOLL_TOUCH))) {
+			ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
+			if (ret & VM_FAULT_ERROR) {
+				if (ret & VM_FAULT_OOM)
+					ret = -ENOMEM;
+				else if (ret & VM_FAULT_SIGBUS)
+					ret = -EFAULT;
+				else
+					BUG();
+				break;
+			}
+			cond_resched();
+		}
+
+		if (IS_ERR(page)) {
+			ret = PTR_ERR(page);
+			break;
+		}
+
+		if (page == ZERO_PAGE(0))
+			page = NULL;	/* zero page: ignore */
+		else if (cow && page_mapping(page) != NULL)
+			page = NULL;	/* clean cow: ignore */
+		else {
+			get_page(page);
+			*(addrp++) = addr;
+			*(pagep++) = page;
+			if (--nr == 0) {
+				addr += PAGE_SIZE;
+				break;
+			}
+		}
+
+		addr += PAGE_SIZE;
+	}
+
+	if (unlikely(ret < 0)) {
+		nr = pgarr->nleft - nr;
+		while (nr--)
+			page_cache_release(*(--pagep));
+		return ret;
+	}
+
+	*start = addr;
+	return (pgarr->nleft - nr);
+}
+
+/**
+ * cr_vma_scan_pages - scan vma for pages that will need to be dumped
+ * @ctx - checkpoint context
+ * @vma - vma to scan
+ *
+ * a list of addr/page tuples is kept in ctx->pgarr page-array chain
+ */
+static int cr_vma_scan_pages(struct cr_ctx *ctx, struct vm_area_struct *vma)
+{
+	unsigned long addr = vma->vm_start;
+	unsigned long end = vma->vm_end;
+	struct cr_pgarr *pgarr;
+	int nr, total = 0;
+
+	while (addr < end) {
+		if (!(pgarr = cr_pgarr_prep(ctx)))
+			return -ENOMEM;
+		if ((nr = cr_vma_fill_pgarr(ctx, pgarr, vma, &addr)) < 0)
+			return nr;
+		pgarr->nleft -= nr;
+		pgarr->nused += nr;
+		total += nr;
+	}
+
+	CR_PRINTK("total %d\n", total);
+	return total;
+}
+
+/**
+ * cr_vma_dump_pages - dump pages listed in the ctx page-array chain
+ * @ctx - checkpoint context
+ * @total - total number of pages
+ */
+static int cr_vma_dump_pages(struct cr_ctx *ctx, int total)
+{
+	struct cr_pgarr *pgarr;
+	int ret;
+
+	if (!total)
+		return 0;
+
+	for (pgarr = ctx->pgarr; pgarr; pgarr = pgarr->next) {
+		ret = cr_kwrite(ctx, pgarr->addrs,
+			       pgarr->nused * sizeof(*pgarr->addrs));
+		if (ret < 0)
+			return ret;
+	}
+
+	for (pgarr = ctx->pgarr; pgarr; pgarr = pgarr->next) {
+		struct page **pages = pgarr->pages;
+		int nr = pgarr->nused;
+		void *ptr;
+
+		while (nr--) {
+			ptr = kmap(*pages);
+			ret = cr_kwrite(ctx, ptr, PAGE_SIZE);
+			kunmap(*pages);
+			if (ret < 0)
+				return ret;
+			pages++;
+		}
+	}
+
+	return total;
+}
+
+static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
+{
+	struct cr_hdr h;
+	struct cr_hdr_vma *hh = ctx->tbuf;
+	char *fname = NULL;
+	int how, nr, ret;
+
+	h.type = CR_HDR_VMA;
+	h.len = sizeof(*hh);
+	h.id = ctx->pid;
+
+	hh->vm_start = vma->vm_start;
+	hh->vm_end = vma->vm_end;
+	hh->vm_page_prot = vma->vm_page_prot.pgprot;
+	hh->vm_flags = vma->vm_flags;
+	hh->vm_pgoff = vma->vm_pgoff;
+
+	if (vma->vm_flags & (VM_SHARED | VM_IO | VM_HUGETLB | VM_NONLINEAR)) {
+		printk(KERN_WARNING "CR: unknown VMA %#lx\n", vma->vm_flags);
+		return -ETXTBSY;
+	}
+
+	/* by default assume anon memory */
+	how = CR_VMA_ANON;
+
+	/* if there is a backing file, assume private-mapped */
+	/* (NEED: check if the file is unlinked) */
+	if (vma->vm_file) {
+		nr = PAGE_SIZE;
+		fname = cr_get_fname(&vma->vm_file->f_path,
+				     ctx->vfsroot, ctx->tbuf, &nr);
+		if (IS_ERR(fname))
+			return PTR_ERR(fname);
+		hh->namelen = nr;
+		how = CR_VMA_FILE;
+	} else
+		hh->namelen = 0;
+
+	hh->how = how;
+
+	/*
+	 * it seems redundant now, but we do it in 3 steps for because:
+	 * first, the logic is simpler when we how many pages before
+	 * dumping them; second, a future optimization will defer the
+	 * writeout (dump, and free) to a later step; in which case all
+	 * the pages to be dumped will be aggregated on the checkpoint ctx
+	 */
+
+	/* (1) scan: scan through the PTEs of the vma, both to count the
+	 * pages to dump, and make those pages COW. keep the list of pages
+	 * (and a reference to each page) on the checkpoint ctx */
+	nr = cr_vma_scan_pages(ctx, vma);
+	if (nr < 0) {
+		cr_put_fname(ctx->tbuf, fname, PAGE_SIZE);
+		return nr;
+	}
+
+	hh->npages = nr;
+	ret = cr_write_obj(ctx, &h, hh);
+
+	if (!ret && hh->namelen)
+		ret = cr_write_str(ctx, fname, hh->namelen);
+
+	cr_put_fname(ctx->tbuf, fname, PAGE_SIZE);
+
+	if (ret < 0)
+		return ret;
+
+	/* (2) dump: write out the addresses of all pages in the list (on
+	 * the checkpoint ctx) followed by the contents of all pages */
+	ret = cr_vma_dump_pages(ctx, nr);
+
+	/* (3) free: free the extra references to the pages in the list */
+	cr_pgarr_release(ctx);
+
+	return ret;
+}
+
+#if defined(CONFIG_X86)
+static int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
+{
+	struct cr_hdr h;
+	struct cr_hdr_mm_context *hh = ctx->tbuf;
+	int ret;
+
+	h.type = CR_HDR_MM_CONTEXT;
+	h.len = sizeof(*hh);
+	h.id = ctx->pid;
+
+	mutex_lock(&mm->context.lock);
+
+	hh->ldt_entry_size = LDT_ENTRY_SIZE;
+	hh->nldt = mm->context.size;
+
+	CR_PRINTK("nldt %d\n", hh->nldt);
+
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret < 0)
+		return ret;
+
+	ret = cr_kwrite(ctx, mm->context.ldt, hh->nldt * LDT_ENTRY_SIZE);
+
+	mutex_unlock(&mm->context.lock);
+
+	return ret;
+}
+#endif
+
+int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_mm *hh = ctx->tbuf;
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	int ret;
+
+	h.type = CR_HDR_MM;
+	h.len = sizeof(*hh);
+	h.id = ctx->pid;
+
+	mm = get_task_mm(t);
+
+	hh->tag = 1;	/* non-zero will mean first time encounter */
+
+	hh->start_code = mm->start_code;
+	hh->end_code = mm->end_code;
+	hh->start_data = mm->start_data;
+	hh->end_data = mm->end_data;
+	hh->start_brk = mm->start_brk;
+	hh->brk = mm->brk;
+	hh->start_stack = mm->start_stack;
+	hh->arg_start = mm->arg_start;
+	hh->arg_end = mm->arg_end;
+	hh->env_start = mm->env_start;
+	hh->env_end = mm->env_end;
+
+	hh->map_count = mm->map_count;
+
+	/* FIX: need also mm->flags */
+
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret < 0)
+		goto out;
+
+	/* write the vma's */
+	down_read(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if ((ret = cr_write_vma(ctx, vma)) < 0)
+			break;
+	}
+	up_read(&mm->mmap_sem);
+
+	if (ret < 0)
+		goto out;
+
+	ret = cr_write_mm_context(ctx, mm);
+
+ out:
+	mmput(mm);
+	return ret;
+}
diff --git a/ckpt/ckpt_mem.h b/ckpt/ckpt_mem.h
new file mode 100644
index 0000000..f9846eb
--- /dev/null
+++ b/ckpt/ckpt_mem.h
@@ -0,0 +1,32 @@
+/*
+ *  Generic container checkpoint-restart
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/mm_types.h>
+
+/* page-array chains: each pgarr hols a list of <addr,page> tuples */
+struct cr_pgarr {
+	unsigned long *addrs;
+	struct page **pages;
+	struct cr_pgarr *next;
+	unsigned short nleft;
+	unsigned short nused;
+};
+
+/* vma subtypes */
+enum {
+	CR_VMA_ANON = 1,
+	CR_VMA_FILE
+};
+
+extern void _cr_pgarr_release(struct cr_ctx *ctx, struct cr_pgarr *pgarr);
+extern void cr_pgarr_release(struct cr_ctx *ctx);
+extern void cr_pgarr_free(struct cr_ctx *ctx);
+extern struct cr_pgarr *cr_pgarr_alloc(struct cr_ctx *ctx, struct cr_pgarr **pgnew);
+extern struct cr_pgarr *cr_pgarr_prep(struct cr_ctx *ctx);
diff --git a/ckpt/restart.c b/ckpt/restart.c
new file mode 100644
index 0000000..9f52851
--- /dev/null
+++ b/ckpt/restart.c
@@ -0,0 +1,328 @@
+/*
+ *  Restart logic and helpers
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/*
+ * During restart the code reads in data from the chekcpoint image into a
+ * temporary buffer (ctx->hbuf). Because operations can be nested, one
+ * should call cr_hbuf_get() to reserve space in the buffer, and then
+ * cr_hbuf_put() when it no longer needs that space
+ */
+
+#include <linux/version.h>
+#include <linux/sched.h>
+#include <linux/file.h>
+
+#if defined(CONFIG_X86)
+#include <asm/desc.h>
+#include <asm/i387.h>
+#endif
+
+#include "ckpt.h"
+#include "ckpt_hdr.h"
+
+/**
+ * cr_hbuf_get - reserve space on the hbuf
+ * @ctx: checkpoint context
+ * @n: number of bytes to reserve
+ */
+void *cr_hbuf_get(struct cr_ctx *ctx, int n)
+{
+	void *ptr;
+
+	BUG_ON(ctx->hpos + n > CR_HBUF_TOTAL);
+	ptr = (void *) (((char *) ctx->hbuf) + ctx->hpos);
+	ctx->hpos += n;
+	return ptr;
+}
+
+/**
+ * cr_hbuf_put - unreserve space on the hbuf
+ * @ctx: checkpoint context
+ * @n: number of bytes to reserve
+ */
+void cr_hbuf_put(struct cr_ctx *ctx, int n)
+{
+	BUG_ON(ctx->hpos < n);
+	ctx->hpos -= n;
+}
+
+/**
+ * cr_read_obj - read a whole record (cr_hdr followed by payload)
+ * @ctx: checkpoint context
+ * @h: record descriptor
+ * @buf: record buffer
+ * @n: available buffer size
+ */
+int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n)
+{
+	int ret;
+
+	ret = cr_kread(ctx, h, sizeof(*h));
+	if (ret < 0)
+		return ret;
+
+	CR_PRINTK("type %d len %d id %d (%d)\n", h->type, h->len, h->id, n);
+	if (h->len < 0 || h->len > n)
+		return -EINVAL;
+
+	return cr_kread(ctx, buf, h->len);
+}
+
+/**
+ * cr_read_obj_type - read a whole record of expected type
+ * @ctx: checkpoint context
+ * @buf: record buffer
+ * @n: available buffer size
+ * @type: expected record type
+ */
+int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type)
+{
+	struct cr_hdr h;
+	int ret;
+
+	ret = cr_read_obj(ctx, &h, buf, n);
+	if (!ret)
+		ret = (h.type == type ? h.id : -EINVAL);
+	return ret;
+}
+
+/**
+ * cr_read_str - read a string record
+ * @ctx: checkpoint context
+ * @str: string buffer
+ * @n: string length
+ */
+int cr_read_str(struct cr_ctx *ctx, void *str, int n)
+{
+	return cr_read_obj_type(ctx, str, n, CR_HDR_STR);
+}
+
+/* read the checkpoint header */
+static int cr_read_hdr(struct cr_ctx *ctx)
+{
+	struct cr_hdr_head *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_HEAD);
+	if (ret < 0)
+		return ret;
+
+	if (hh->magic != 0x00a2d200 || hh->version != 1 ||
+	    hh->major != ((LINUX_VERSION_CODE >> 16) & 0xff) ||
+	    hh->minor != ((LINUX_VERSION_CODE >> 8) & 0xff) ||
+	    hh->patch != ((LINUX_VERSION_CODE) & 0xff))
+		return -EINVAL;
+
+	if (hh->flags & ~CR_CTX_CKPT)
+		return -EINVAL;
+
+	ctx->oflags = hh->flags;
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return 0;
+}
+
+/* read the checkpoint trailer */
+static int cr_read_tail(struct cr_ctx *ctx)
+{
+	struct cr_hdr_tail *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_TAIL);
+	if (ret < 0)
+		return ret;
+
+	if (hh->magic != 0x002d2a00 ||
+	    hh->cksum[0] != 1 || hh->cksum[1] != 1)
+		return -EINVAL;
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return 0;
+}
+
+/* read the task_struct into the current task */
+static int cr_read_task_struct(struct cr_ctx *ctx)
+{
+	struct cr_hdr_task *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct task_struct *t = current;
+	int ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_TASK);
+	if (ret < 0)
+		return ret;
+
+	/* for now, only restore t->comm */
+	if (hh->task_comm_len < 0 || hh->task_comm_len > TASK_COMM_LEN)
+		return -EINVAL;
+
+	memset(t->comm, 0, TASK_COMM_LEN);
+	memcpy(t->comm, hh->comm, hh->task_comm_len);
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return 0;
+}
+
+#if defined(CONFIG_X86)
+/* read the thread_struct into the current task */
+static int cr_read_thread(struct cr_ctx *ctx)
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
+#endif
+
+#if defined(CONFIG_X86)
+/* read the cpu state nad registers for the current task */
+static int cr_read_cpu(struct cr_ctx *ctx)
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
+#endif
+
+/* read the entire state of the current task */
+static int cr_read_task(struct cr_ctx *ctx)
+{
+	int ret;
+
+	ret = cr_read_task_struct(ctx);
+	CR_PRINTK("ret (task_struct) %d\n", ret);
+	if (!ret)
+		ret = cr_read_mm(ctx);
+	CR_PRINTK("ret (mm) %d\n", ret);
+	if (!ret)
+		ret = cr_read_thread(ctx);
+	CR_PRINTK("ret (thread) %d\n", ret);
+	if (!ret)
+		ret = cr_read_cpu(ctx);
+	CR_PRINTK("ret (cpu) %d\n", ret);
+
+	return ret;
+}
+
+int do_restart(struct cr_ctx *ctx)
+{
+	int ret;
+
+	ret = cr_read_hdr(ctx);
+	if (!ret)
+		ret = cr_read_task(ctx);
+	if (!ret)
+		ret = cr_read_tail(ctx);
+
+	return ret;
+}
diff --git a/ckpt/rstr_mem.c b/ckpt/rstr_mem.c
new file mode 100644
index 0000000..97fc14a
--- /dev/null
+++ b/ckpt/rstr_mem.c
@@ -0,0 +1,415 @@
+/*
+ *  Restart memory contents
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <asm/unistd.h>
+
+#include <linux/sched.h>
+#include <linux/fcntl.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/uaccess.h>
+#include <linux/mm_types.h>
+#include <linux/mman.h>
+#include <linux/mm.h>
+#include <linux/err.h>
+#include <asm/cacheflush.h>
+
+#if defined(CONFIG_X86)
+#include <asm/desc.h>
+#include <asm/ldt.h>
+#endif
+
+#include "ckpt.h"
+#include "ckpt_hdr.h"
+#include "ckpt_mem.h"
+
+/*
+ * Unlike checkpoint, restart is executed in the context of each restarting
+ * process: vma regions are restored via a call to mmap(), and the data is
+ * read in directly to the address space of the current process
+ */
+
+/**
+ * cr_vma_read_pages_addr - read addresses of pages to page-array chain
+ * @ctx - restart context
+ * @npages - number of pages
+ */
+static int cr_vma_read_pages_addr(struct cr_ctx *ctx, int npages)
+{
+	struct cr_pgarr *pgarr;
+	int nr, ret;
+
+	while (npages) {
+		if (!(pgarr = cr_pgarr_prep(ctx)))
+			return -ENOMEM;
+		nr = min(npages, (int) pgarr->nleft);
+		ret = cr_kread(ctx, pgarr->addrs, nr * sizeof(unsigned long));
+		if (ret < 0)
+			return ret;
+		pgarr->nleft -= nr;
+		pgarr->nused += nr;
+		npages -= nr;
+	}
+	return 0;
+}
+
+/**
+ * cr_vma_read_pages_data - read in data of pages in page-array chain
+ * @ctx - restart context
+ * @npages - number of pages
+ */
+static int cr_vma_read_pages_data(struct cr_ctx *ctx, int npages)
+{
+	struct cr_pgarr *pgarr;
+	unsigned long *addrs;
+	int nr, ret;
+
+	for (pgarr = ctx->pgarr; npages; pgarr = pgarr->next) {
+		addrs = pgarr->addrs;
+		nr = pgarr->nused;
+		npages -= nr;
+		while (nr--) {
+			ret = cr_uread(ctx, (void *) *(addrs++), PAGE_SIZE);
+			if (ret < 0)
+				return ret;
+		}
+	}
+
+	return 0;
+}
+
+/* change the protection of an address range to be writable/non-writable.
+ * this is useful when restoring the memory of a read-only vma */
+static int cr_vma_writable(struct mm_struct *mm, unsigned long start,
+			   unsigned long end, int writable)
+{
+	struct vm_area_struct *vma, *prev;
+	unsigned long flags = 0;
+	int ret = -EINVAL;
+
+	CR_PRINTK("vma %#lx-%#lx writable %d\n", start, end, writable);
+
+	down_write(&mm->mmap_sem);
+	vma = find_vma_prev(mm, start, &prev);
+	if (unlikely(!vma || vma->vm_start > end || vma->vm_end < start))
+		goto out;
+	if (writable && !(vma->vm_flags & VM_WRITE))
+		flags = vma->vm_flags | VM_WRITE;
+	else if (!writable && (vma->vm_flags & VM_WRITE))
+		flags = vma->vm_flags & ~VM_WRITE;
+	CR_PRINTK("flags %#lx\n", flags);
+	if (flags)
+		ret = mprotect_fixup(vma, &prev, vma->vm_start,
+				     vma->vm_end, flags);
+ out:
+	up_write(&mm->mmap_sem);
+	return ret;
+}
+
+/**
+ * cr_vma_read_pages - read in pages for to restore a vma
+ * @ctx - restart context
+ * @cr_vma - vma descriptor from restart
+ */
+static int cr_vma_read_pages(struct cr_ctx *ctx, struct cr_hdr_vma *cr_vma)
+{
+	struct mm_struct *mm = current->mm;
+	int ret = 0;
+
+	if (!cr_vma->npages)
+		return 0;
+
+	/* in the unlikely case that this vma is read-only */
+	if (!(cr_vma->vm_flags & VM_WRITE))
+		ret = cr_vma_writable(mm, cr_vma->vm_start, cr_vma->vm_end, 1);
+
+	if (!ret)
+		ret = cr_vma_read_pages_addr(ctx, cr_vma->npages);
+	if (!ret)
+		ret = cr_vma_read_pages_data(ctx, cr_vma->npages);
+	if (ret < 0)
+		return ret;
+
+	cr_pgarr_release(ctx);	/* reset page-array chain */
+
+	/* restore original protection for this vma */
+	if (!(cr_vma->vm_flags & VM_WRITE))
+		ret = cr_vma_writable(mm, cr_vma->vm_start, cr_vma->vm_end, 0);
+
+	return ret;
+}
+
+/**
+ * cr_calc_map_prot_bits - convert vm_flags to mmap protection
+ * orig_vm_flags: source vm_flags
+ */
+static unsigned long cr_calc_map_prot_bits(unsigned long orig_vm_flags)
+{
+	unsigned long vm_prot = 0;
+
+	if (orig_vm_flags & VM_READ)
+		vm_prot |= PROT_READ;
+	if (orig_vm_flags & VM_WRITE)
+		vm_prot |= PROT_WRITE;
+	if (orig_vm_flags & VM_EXEC)
+		vm_prot |= PROT_EXEC;
+	if (orig_vm_flags & PROT_SEM)   /* only (?) with IPC-SHM  */
+		vm_prot |= PROT_SEM;
+
+	return vm_prot;
+}
+
+/**
+ * cr_calc_map_flags_bits - convert vm_flags to mmap flags
+ * orig_vm_flags: source vm_flags
+ */
+static unsigned long cr_calc_map_flags_bits(unsigned long orig_vm_flags)
+{
+	unsigned long vm_flags = 0;
+
+	vm_flags = MAP_FIXED;
+	if (orig_vm_flags & VM_GROWSDOWN)
+		vm_flags |= MAP_GROWSDOWN;
+	if (orig_vm_flags & VM_DENYWRITE)
+		vm_flags |= MAP_DENYWRITE;
+	if (orig_vm_flags & VM_EXECUTABLE)
+		vm_flags |= MAP_EXECUTABLE;
+	if (orig_vm_flags & VM_MAYSHARE)
+		vm_flags |= MAP_SHARED;
+	else
+		vm_flags |= MAP_PRIVATE;
+
+	return vm_flags;
+}
+
+static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
+{
+	struct cr_hdr_vma *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	unsigned long vm_size, vm_flags, vm_prot, vm_pgoff;
+	unsigned long addr;
+	unsigned long flags;
+	struct file *file = NULL;
+	char *fname = NULL;
+	int ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_VMA);
+	if (ret < 0)
+		return ret;
+
+	CR_PRINTK("vma %#lx-%#lx npages %d namelen %d\n",
+		  (unsigned long) hh->vm_start, (unsigned long) hh->vm_end,
+		  (int) hh->npages, (int) hh->namelen);
+
+	if (hh->vm_end < hh->vm_start)
+		return -EINVAL;
+	if (hh->npages < 0 || hh->namelen < 0)
+		return -EINVAL;
+
+	vm_size = hh->vm_end - hh->vm_start;
+	vm_prot = cr_calc_map_prot_bits(hh->vm_flags);
+	vm_flags = cr_calc_map_flags_bits(hh->vm_flags);
+	vm_pgoff = hh->vm_pgoff;
+
+	if (hh->namelen) {
+		fname = ctx->tbuf;
+		ret = cr_read_str(ctx, fname, PAGE_SIZE);
+		if (ret < 0)
+			return ret;
+	}
+
+	CR_PRINTK("vma fname '%s' how %d\n", fname, hh->how);
+
+	switch (hh->how) {
+
+	case CR_VMA_ANON:		/* anonymous private mapping */
+		if (hh->namelen)
+			return -EINVAL;
+		/* vm_pgoff for anonymous mapping is the "global" page
+		   offset (namely from addr 0x0), so we force a zero */
+		vm_pgoff = 0;
+		break;
+
+	case CR_VMA_FILE:		/* private mapping from a file */
+		if (!hh->namelen)
+			return -EINVAL;
+		/* O_RDWR only needed if both (VM_WRITE|VM_SHARED) are set */
+		flags = hh->vm_flags & (VM_WRITE | VM_SHARED);
+		flags = (flags == (VM_WRITE | VM_SHARED) ? O_RDWR : O_RDONLY);
+		file = filp_open(fname, flags, 0);
+		if (IS_ERR(file))
+			return PTR_ERR(file);
+		break;
+
+	default:
+		return -EINVAL;
+
+	}
+
+	addr = do_mmap_pgoff(file, (unsigned long) hh->vm_start,
+			     vm_size, vm_prot, vm_flags, vm_pgoff);
+	CR_PRINTK("vma size %#lx prot %#lx flags %#lx pgoff %#lx => %#lx\n",
+		  vm_size, vm_prot, vm_flags, vm_pgoff, addr);
+
+	/* the file (if opened) is now referenced by the vma */
+	if (file)
+		filp_close(file, NULL);
+
+	if (IS_ERR((void*) addr))
+		return (PTR_ERR((void *) addr));
+
+	/*
+	 * CR_VMA_ANON: read in memory as is
+	 * CR_VMA_FILE: read in memory as is
+	 * (more to follow ...)
+	 */
+
+	switch (hh->how) {
+	case CR_VMA_ANON:
+	case CR_VMA_FILE:
+		/* standard case: read the data into the memory */
+		ret = cr_vma_read_pages(ctx, hh);
+		break;
+	}
+
+	if (ret < 0)
+		return ret;
+
+	if (vm_prot & PROT_EXEC)
+		flush_icache_range(hh->vm_start, hh->vm_end);
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	CR_PRINTK("vma retval %d\n", ret);
+	return 0;
+}
+
+#if defined(CONFIG_X86)
+
+extern asmlinkage int sys_modify_ldt(int func, void __user *ptr, unsigned long bytecount);
+
+static int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
+{
+	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int n, ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM_CONTEXT);
+	if (ret < 0)
+		return ret;
+
+	CR_PRINTK("nldt %d\n", hh->nldt);
+
+	if (hh->nldt < 0 || hh->ldt_entry_size != LDT_ENTRY_SIZE)
+		return -EINVAL;
+
+	/* to utilize the syscall modify_ldt() we first convert the data
+	 * in the checkpoint image from 'struct desc_struct' to 'struct
+	 * user_desc' with reverse logic of inclue/asm/desc.h:fill_ldt() */
+
+	for (n = 0; n < hh->nldt; n++) {
+		struct user_desc info;
+		struct desc_struct desc;
+		mm_segment_t old_fs;
+
+		ret = cr_kread(ctx, &desc, LDT_ENTRY_SIZE);
+		if (ret < 0)
+			return ret;
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
+		ret = sys_modify_ldt(1, &info, sizeof(info));
+		set_fs(old_fs);
+
+		if (ret < 0)
+			return ret;
+	}
+
+	load_LDT(&mm->context);
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return 0;
+}
+#endif
+
+static int cr_destroy_mm(struct mm_struct *mm)
+{
+	struct vm_area_struct *vmnext = mm->mmap;
+	struct vm_area_struct *vma;
+	int ret;
+
+	while (vmnext) {
+		vma = vmnext;
+		vmnext = vmnext->vm_next;
+		ret = do_munmap(mm, vma->vm_start, vma->vm_end-vma->vm_start);
+		if (ret < 0)
+			return ret;
+	}
+	return 0;
+}
+
+int cr_read_mm(struct cr_ctx *ctx)
+{
+	struct cr_hdr_mm *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct mm_struct *mm;
+	int nr, ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM);
+	if (ret < 0)
+		return ret;
+
+	CR_PRINTK("map_count %d\n", hh->map_count);
+
+	/* XXX need more sanity checks */
+	if (hh->start_code > hh->end_code ||
+	    hh->start_data > hh->end_data || hh->map_count < 0)
+		return -EINVAL;
+
+	mm = current->mm;
+
+	/* point of no return -- destruct current mm */
+	down_write(&mm->mmap_sem);
+	ret = cr_destroy_mm(mm);
+	up_write(&mm->mmap_sem);
+
+	if (ret < 0)
+		return ret;
+
+	mm->start_code = hh->start_code;
+	mm->end_code = hh->end_code;
+	mm->start_data = hh->start_data;
+	mm->end_data = hh->end_data;
+	mm->start_brk = hh->start_brk;
+	mm->brk = hh->brk;
+	mm->start_stack = hh->start_stack;
+	mm->arg_start = hh->arg_start;
+	mm->arg_end = hh->arg_end;
+	mm->env_start = hh->env_start;
+	mm->env_end = hh->env_end;
+
+	/* FIX: need also mm->flags */
+
+	for (nr = hh->map_count; nr; nr--) {
+		ret = cr_read_vma(ctx, mm);
+		if (ret < 0)
+			return ret;
+	}
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return cr_read_mm_context(ctx, mm);
+}
diff --git a/ckpt/sys.c b/ckpt/sys.c
new file mode 100644
index 0000000..95ebfc7
--- /dev/null
+++ b/ckpt/sys.c
@@ -0,0 +1,239 @@
+/*
+ *  Generic container checkpoint-restart
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/sched.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/uaccess.h>
+#include <linux/capability.h>
+
+#include "ckpt.h"
+#include "ckpt_mem.h"
+
+/*
+ * helpers to write/read to/from the image file descriptor
+ *
+ *   cr_uwrite() - write a user-space buffer to the checkpoint image
+ *   cr_kwrite() - write a kernel-space buffer to the checkpoint image
+ *   cr_uread() - read from the checkpoint image to a user-space buffer
+ *   cr_kread() - read from the checkpoint image to a kernel-space buffer
+ *
+ */
+
+/* (temporarily added file_pos_read() and file_pos_write() because they
+ * are static in fs/read_write.c... should cleanup and remove later) */
+static inline loff_t file_pos_read(struct file *file)
+{
+	return file->f_pos;
+}
+
+static inline void file_pos_write(struct file *file, loff_t pos)
+{
+	file->f_pos = pos;
+}
+
+int cr_uwrite(struct cr_ctx *ctx, void *buf, int count)
+{
+	struct file *file = ctx->file;
+	ssize_t nwrite;
+	int nleft;
+
+	for (nleft = count; nleft; nleft -= nwrite) {
+		loff_t pos = file_pos_read(file);
+		nwrite = vfs_write(file, (char __user *) buf, nleft, &pos);
+		file_pos_write(file, pos);
+		if (unlikely(nwrite <= 0))	/* zero tolerance */
+			return (nwrite ? : -EIO);
+		buf += nwrite;
+	}
+
+	ctx->total += count;
+	return 0;
+}
+
+int cr_kwrite(struct cr_ctx *ctx, void *buf, int count)
+{
+	mm_segment_t oldfs;
+	int ret;
+
+	oldfs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = cr_uwrite(ctx, buf, count);
+	set_fs(oldfs);
+
+	return ret;
+}
+
+int cr_uread(struct cr_ctx *ctx, void *buf, int count)
+{
+	struct file *file = ctx->file;
+	ssize_t nread;
+	int nleft;
+
+	for (nleft = count; nleft; nleft -= nread) {
+		loff_t pos = file_pos_read(file);
+		nread = vfs_read(file, (char __user *) buf, nleft, &pos);
+		file_pos_write(file, pos);
+		if (unlikely(nread <= 0))	/* zero tolerance */
+			return (nread ? : -EIO);
+		buf += nread;
+	}
+
+	ctx->total += count;
+	return 0;
+}
+
+int cr_kread(struct cr_ctx *ctx, void *buf, int count)
+{
+	mm_segment_t oldfs;
+	int ret;
+
+	oldfs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = cr_uread(ctx, buf, count);
+	set_fs(oldfs);
+
+	return ret;
+}
+
+
+/*
+ * helpers to manage CR contexts: allocated for each checkpoint and/or
+ * restart operation, and persists until the operation is completed.
+ */
+
+static atomic_t cr_ctx_count;	/* unique checkpoint identifier */
+
+void cr_ctx_free(struct cr_ctx *ctx)
+{
+
+	if (ctx->file)
+		fput(ctx->file);
+	if (ctx->vfsroot)
+		path_put(ctx->vfsroot);
+
+	cr_pgarr_free(ctx);
+
+	free_pages((unsigned long) ctx->tbuf, CR_ORDER_TBUF);
+	free_pages((unsigned long) ctx->hbuf, CR_ORDER_HBUF);
+
+	kfree(ctx);
+}
+
+struct cr_ctx *cr_ctx_alloc(pid_t pid, struct file *file, unsigned long flags)
+{
+	struct cr_ctx *ctx;
+
+	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
+	if (!ctx)
+		return NULL;
+
+	ctx->tbuf = (void *) __get_free_pages(GFP_KERNEL, CR_ORDER_TBUF);
+	ctx->hbuf = (void *) __get_free_pages(GFP_KERNEL, CR_ORDER_HBUF);
+	if (!ctx->tbuf || !ctx->hbuf)
+		goto nomem;
+
+	if (!cr_pgarr_alloc(ctx, &ctx->pgarr))
+		goto nomem;
+
+	ctx->pid = pid;
+	ctx->flags = flags;
+
+	ctx->file = file;
+	get_file(file);
+
+	/* assume checkpointer is in container's root vfs */
+	ctx->vfsroot = &current->fs->root;
+	path_get(ctx->vfsroot);
+
+	ctx->crid = atomic_inc_return(&cr_ctx_count);
+
+	return ctx;
+
+ nomem:
+	cr_ctx_free(ctx);
+	return NULL;
+}
+
+/**
+ * sys_checkpoint - checkpoint a container
+ * @pid: pid of the container init(1) process
+ * @fd: file to which dump the checkpoint image
+ * @flags: checkpoint operation flags
+ */
+asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
+{
+	struct cr_ctx *ctx;
+	struct file *file;
+	int fput_needed;
+	int ret;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	file = fget_light(fd, &fput_needed);
+	if (!file)
+		return -EBADF;
+
+	/* no flags for now */
+	if (flags)
+		return -EINVAL;
+
+	ctx = cr_ctx_alloc(pid, file, flags | CR_CTX_CKPT);
+	if (!ctx) {
+		fput_light(file, fput_needed);
+		return -ENOMEM;
+	}
+
+	ret = do_checkpoint(ctx);
+
+	cr_ctx_free(ctx);
+	fput_light(file, fput_needed);
+	CR_PRINTK("ckpt retval = %d\n", ret);
+	return ret;
+}
+
+/**
+ * sys_restart - restart a container
+ * @crid: checkpoint image identifier
+ * @fd: file from which read the checkpoint image
+ * @flags: restart operation flags
+ */
+asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
+{
+	struct cr_ctx *ctx;
+	struct file *file;
+	int fput_needed;
+	int ret;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	file = fget_light(fd, &fput_needed);
+	if (!file)
+		return -EBADF;
+
+	/* no flags for now */
+	if (flags)
+		return -EINVAL;
+
+	ctx = cr_ctx_alloc(crid, file, flags | CR_CTX_RSTR);
+	if (!ctx) {
+		fput_light(file, fput_needed);
+		return -ENOMEM;
+	}
+
+	ret = do_restart(ctx);
+
+	cr_ctx_free(ctx);
+	fput_light(file, fput_needed);
+	CR_PRINTK("restart retval = %d\n", ret);
+	return ret;
+}
-- 
1.5.4.3
