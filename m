From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 1/4] checkpoint-restart: general infrastructure
Date: Thu, 07 Aug 2008 15:40:34 -0700
Message-ID: <20080807224034.735B1F84__31018.4473208666$1218149207$gmane$org@kernel>
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


From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

This patch adds those interfaces, as well as all of the helpers
needed to easily manage the file format.  

The code is roughly broken out as follows:

ckpt/sys.c - user/kernel data transfer, as well as setting up of the
	     checkpoint/restart context (a per-checkpoint data
	     structure for housekeeping)
ckpt/checkpoint.c - output wrappers and basic checkpoint handling
ckpt/restart.c - input wrappers and basic restart handling

Patches to add the per-architecture support as well as the actual
work to do the memory checkpoint follow in subsequent patches.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---

 linux-2.6.git-dave/Makefile          |    2 
 linux-2.6.git-dave/ckpt/Makefile     |    1 
 linux-2.6.git-dave/ckpt/checkpoint.c |  207 +++++++++++++++++++++++++++++++
 linux-2.6.git-dave/ckpt/ckpt.h       |   82 ++++++++++++
 linux-2.6.git-dave/ckpt/ckpt_hdr.h   |   69 ++++++++++
 linux-2.6.git-dave/ckpt/restart.c    |  189 ++++++++++++++++++++++++++++
 linux-2.6.git-dave/ckpt/sys.c        |  233 +++++++++++++++++++++++++++++++++++
 7 files changed, 782 insertions(+), 1 deletion(-)

diff -puN /dev/null ckpt/checkpoint.c
--- /dev/null	2007-04-11 11:48:27.000000000 -0700
+++ linux-2.6.git-dave/ckpt/checkpoint.c	2008-08-07 15:37:22.000000000 -0700
@@ -0,0 +1,207 @@
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
+/* dump the entire state of a given task */
+static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
+{
+	int ret ;
+
+	BUG_ON(t->state == TASK_DEAD);
+
+	ret = cr_write_task_struct(ctx, t);
+	CR_PRINTK("ret (task_struct) %d\n", ret);
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
diff -puN /dev/null ckpt/ckpt.h
--- /dev/null	2007-04-11 11:48:27.000000000 -0700
+++ linux-2.6.git-dave/ckpt/ckpt.h	2008-08-05 09:04:27.000000000 -0700
@@ -0,0 +1,82 @@
+#ifndef _CKPT_CKPT_H_
+#define _CKPT_CKPT_H_
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
+
+#endif /* _CKPT_CKPT_H_ */
diff -puN /dev/null ckpt/ckpt_hdr.h
--- /dev/null	2007-04-11 11:48:27.000000000 -0700
+++ linux-2.6.git-dave/ckpt/ckpt_hdr.h	2008-08-07 15:37:22.000000000 -0700
@@ -0,0 +1,69 @@
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
+
diff -puN /dev/null ckpt/Makefile
--- /dev/null	2007-04-11 11:48:27.000000000 -0700
+++ linux-2.6.git-dave/ckpt/Makefile	2008-08-07 15:37:22.000000000 -0700
@@ -0,0 +1 @@
+obj-y += sys.o checkpoint.o restart.o
diff -puN /dev/null ckpt/restart.c
--- /dev/null	2007-04-11 11:48:27.000000000 -0700
+++ linux-2.6.git-dave/ckpt/restart.c	2008-08-07 15:37:22.000000000 -0700
@@ -0,0 +1,189 @@
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
+/* read the entire state of the current task */
+static int cr_read_task(struct cr_ctx *ctx)
+{
+	int ret;
+
+	ret = cr_read_task_struct(ctx);
+	CR_PRINTK("ret (task_struct) %d\n", ret);
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
diff -puN /dev/null ckpt/sys.c
--- /dev/null	2007-04-11 11:48:27.000000000 -0700
+++ linux-2.6.git-dave/ckpt/sys.c	2008-08-07 15:37:22.000000000 -0700
@@ -0,0 +1,233 @@
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
diff -puN Makefile~handle_a_single_task_with_private_memory_maps Makefile
--- linux-2.6.git/Makefile~handle_a_single_task_with_private_memory_maps	2008-08-05 09:04:27.000000000 -0700
+++ linux-2.6.git-dave/Makefile	2008-08-05 09:07:53.000000000 -0700
@@ -611,7 +611,7 @@ export mod_strip_cmd
 
 
 ifeq ($(KBUILD_EXTMOD),)
-core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/
+core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/ ckpt/
 
 vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, $(init-y) $(init-m) \
 		     $(core-y) $(core-m) $(drivers-y) $(drivers-m) \
_
