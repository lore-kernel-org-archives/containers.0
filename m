From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v2][PATCH 2/9] General infrastructure for checkpoint restart
Date: Wed, 20 Aug 2008 23:04:13 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0808202303460.17436@takamine.ncl.cs.columbia.edu>
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


Add those interfaces, as well as helpers needed to easily manage the
file format. The code is roughly broken out as follows:

ckpt/sys.c - user/kernel data transfer, as well as setup of the
checkpoint/restart context (a per-checkpoint data structure for
housekeeping)

ckpt/checkpoint.c - output wrappers and basic checkpoint handling

ckpt/restart.c - input wrappers and basic restart handling

Patches to add the per-architecture support as well as the actual
work to do the memory checkpoint follow in subsequent patches.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
  Makefile                |    2 +-
  checkpoint/Makefile     |    1 +
  checkpoint/checkpoint.c |  191 +++++++++++++++++++++++++++++++++++++++
  checkpoint/ckpt.h       |   71 +++++++++++++++
  checkpoint/ckpt_hdr.h   |   86 ++++++++++++++++++
  checkpoint/restart.c    |  199 +++++++++++++++++++++++++++++++++++++++++
  checkpoint/sys.c        |  227 +++++++++++++++++++++++++++++++++++++++++++++++
  7 files changed, 776 insertions(+), 1 deletions(-)
  create mode 100644 checkpoint/Makefile
  create mode 100644 checkpoint/checkpoint.c
  create mode 100644 checkpoint/ckpt.h
  create mode 100644 checkpoint/ckpt_hdr.h
  create mode 100644 checkpoint/restart.c
  create mode 100644 checkpoint/sys.c

diff --git a/Makefile b/Makefile
index f3e2065..584c8f9 100644
--- a/Makefile
+++ b/Makefile
@@ -619,7 +619,7 @@ export mod_strip_cmd


  ifeq ($(KBUILD_EXTMOD),)
-core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/
+core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/ checkpoint/

  vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, $(init-y) $(init-m) \
  		     $(core-y) $(core-m) $(drivers-y) $(drivers-m) \
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
new file mode 100644
index 0000000..d129878
--- /dev/null
+++ b/checkpoint/Makefile
@@ -0,0 +1 @@
+obj-y += sys.o checkpoint.o restart.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
new file mode 100644
index 0000000..25343f5
--- /dev/null
+++ b/checkpoint/checkpoint.c
@@ -0,0 +1,191 @@
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
+#include <linux/utsname.h>
+#include <asm/ptrace.h>
+
+#include "ckpt.h"
+#include "ckpt_hdr.h"
+
+/**
+ * cr_fill_fname - return pathname of a given file
+ * @file: file pointer
+ * @buf: buffer for pathname
+ * @n: buffer length (in) and pathname length (out)
+ */
+char *cr_fill_fname(struct path *path, struct path *root, char *buf, int *n)
+{
+	char *fname;
+
+	BUG_ON(!buf);
+	fname = __d_path(path, root, buf, *n);
+	if (!IS_ERR(fname))
+		*n = (buf + (*n) - fname);
+	return fname;
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
+	h.ptag = 0;
+
+	return cr_write_obj(ctx, &h, str);
+}
+
+/* write the checkpoint header */
+static int cr_write_hdr(struct cr_ctx *ctx)
+{
+	struct cr_hdr h;
+	struct cr_hdr_head *hh = ctx->hbuf;
+	struct new_utsname *uts;
+	struct timeval ktv;
+
+	h.type = CR_HDR_HEAD;
+	h.len = sizeof(*hh);
+	h.ptag = 0;
+
+	do_gettimeofday(&ktv);
+
+	hh->magic = CR_MAGIC_HEAD;
+	hh->major = (LINUX_VERSION_CODE >> 16) & 0xff;
+	hh->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
+	hh->patch = (LINUX_VERSION_CODE) & 0xff;
+
+	hh->rev = CR_VERSION;
+
+	hh->flags = ctx->flags;
+	hh->time = ktv.tv_sec;
+
+	uts = utsname();
+	memcpy(hh->release, uts->release, __NEW_UTS_LEN);
+	memcpy(hh->version, uts->version, __NEW_UTS_LEN);
+	memcpy(hh->machine, uts->machine, __NEW_UTS_LEN);
+
+	return cr_write_obj(ctx, &h, hh);
+}
+
+/* write the checkpoint trailer */
+static int cr_write_tail(struct cr_ctx *ctx)
+{
+	struct cr_hdr h;
+	struct cr_hdr_tail *hh = ctx->hbuf;
+
+	h.type = CR_HDR_TAIL;
+	h.len = sizeof(*hh);
+	h.ptag = 0;
+
+	hh->magic = CR_MAGIC_TAIL;
+	hh->cksum = 1;	/* TBD ... */
+
+	return cr_write_obj(ctx, &h, hh);
+}
+
+/* dump the task_struct of a given task */
+static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_task *hh = ctx->hbuf;
+
+	h.type = CR_HDR_TASK;
+	h.len = sizeof(*hh);
+	h.ptag = 0;
+
+	hh->state = t->state;
+	hh->exit_state = t->exit_state;
+	hh->exit_code = t->exit_code;
+	hh->exit_signal = t->exit_signal;
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
+	if (t->state == TASK_DEAD) {
+		pr_warning("CR: task may not be in state TASK_DEAD\n");
+		return -EAGAIN;
+	}
+
+	ret = cr_write_task_struct(ctx, t);
+	cr_debug("ret %d\n", ret);
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
diff --git a/checkpoint/ckpt.h b/checkpoint/ckpt.h
new file mode 100644
index 0000000..7ecafb3
--- /dev/null
+++ b/checkpoint/ckpt.h
@@ -0,0 +1,71 @@
+#ifndef _CHECKPOINT_CKPT_H_
+#define _CHECKPOINT_CKPT_H_
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
+#define CR_VERSION  1
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
+	struct path *vfsroot;	/* container root */
+};
+
+/* cr_ctx: flags */
+#define CR_CTX_CKPT	0x1
+#define CR_CTX_RSTR	0x2
+
+/* allocation defaults */
+#define CR_TBUF_ORDER  1
+#define CR_TBUF_TOTAL  (PAGE_SIZE << CR_TBUF_ORDER)
+
+#define CR_HBUF_ORDER  1
+#define CR_HBUF_TOTAL  (PAGE_SIZE << CR_HBUF_ORDER)
+
+char *cr_fill_fname(struct path *path, struct path *root, char *buf, int *n);
+
+int cr_uwrite(struct cr_ctx *ctx, void *buf, int count);
+int cr_kwrite(struct cr_ctx *ctx, void *buf, int count);
+int cr_uread(struct cr_ctx *ctx, void *buf, int count);
+int cr_kread(struct cr_ctx *ctx, void *buf, int count);
+
+void *cr_hbuf_get(struct cr_ctx *ctx, int n);
+void cr_hbuf_put(struct cr_ctx *ctx, int n);
+
+struct cr_hdr;
+
+int cr_write_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf);
+int cr_write_str(struct cr_ctx *ctx, char *str, int n);
+
+int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n);
+int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type);
+int cr_read_str(struct cr_ctx *ctx, void *str, int n);
+
+int do_checkpoint(struct cr_ctx *ctx);
+int do_restart(struct cr_ctx *ctx);
+
+#define cr_debug(fmt, args...)  \
+	pr_debug("[CR:%s] " fmt, __func__, ## args)
+
+#endif /* _CHECKPOINT_CKPT_H_ */
diff --git a/checkpoint/ckpt_hdr.h b/checkpoint/ckpt_hdr.h
new file mode 100644
index 0000000..a478b7c
--- /dev/null
+++ b/checkpoint/ckpt_hdr.h
@@ -0,0 +1,86 @@
+#ifndef _CHECKPOINT_CKPT_HDR_H_
+#define _CHECKPOINT_CKPT_HDR_H_
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
+#include <linux/utsname.h>
+
+#define CR_MAGIC_HEAD  0x00feed0cc0a2d200LL
+#define CR_MAGIC_TAIL  0x002d2a0cc0deef00LL
+
+/*
+ * To maintain compatibility between 32-bit and 64-bit architecture flavors,
+ * keep data 64-bit aligned: use padding for structure members, and use
+ * __attribute__ ((aligned (8))) for the entire structure.
+ */
+
+/* records: generic header */
+
+struct cr_hdr {
+	__s16 type;
+	__s16 len;
+	__u32 ptag;
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
+	__u64 magic;
+
+	__u16 major;
+	__u16 minor;
+	__u16 patch;
+	__u16 rev;
+
+	__u64 time;	/* when checkpoint taken */
+	__u64 flags;	/* checkpoint options */
+
+	char release[__NEW_UTS_LEN];
+	char version[__NEW_UTS_LEN];
+	char machine[__NEW_UTS_LEN];
+} __attribute__ ((aligned (8)));
+
+struct cr_hdr_tail {
+	__u64 magic;
+	__u64 cksum;
+} __attribute__ ((aligned (8)));
+
+struct cr_hdr_task {
+	__u64 state;
+	__u32 exit_state;
+	__u32 exit_code, exit_signal;
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
+} __attribute__ ((aligned (8)));
+
+#endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
new file mode 100644
index 0000000..be7d08c
--- /dev/null
+++ b/checkpoint/restart.c
@@ -0,0 +1,199 @@
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
+	cr_debug("type %d len %d id %d (%d)\n", h->type, h->len, h->ptag, n);
+
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
+		ret = (h.type == type ? h.ptag : -EINVAL);
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
+	else if (ret != 0)
+		return -EINVAL;
+
+	if (hh->magic != CR_MAGIC_HEAD || hh->rev != CR_VERSION ||
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
+	/* FIX: verify compatibility of release, version and machine */
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
+	else if (ret != 0)
+		return -EINVAL;
+
+	if (hh->magic != CR_MAGIC_TAIL || hh->cksum != 1)
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
+	else if (ret != 0)
+		return -EINVAL;
+
+	/* for now, only restore t->comm */
+	if (hh->task_comm_len < 0 || hh->task_comm_len > TASK_COMM_LEN)
+		return -EINVAL;
+
+	/* current should already have correct pid and tgid */
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
+	cr_debug("ret %d\n", ret);
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
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
new file mode 100644
index 0000000..2891c48
--- /dev/null
+++ b/checkpoint/sys.c
@@ -0,0 +1,227 @@
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
+	free_pages((unsigned long) ctx->tbuf, CR_TBUF_ORDER);
+	free_pages((unsigned long) ctx->hbuf, CR_HBUF_ORDER);
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
+	ctx->tbuf = (void *) __get_free_pages(GFP_KERNEL, CR_TBUF_ORDER);
+	ctx->hbuf = (void *) __get_free_pages(GFP_KERNEL, CR_HBUF_ORDER);
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
+
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
+
+	return ret;
+}
-- 
1.5.4.3
