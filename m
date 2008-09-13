From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v5][PATCH 2/8] General infrastructure for checkpoint restart
Date: Sat, 13 Sep 2008 19:06:00 -0400
Message-ID: <1221347167-9956-3-git-send-email-orenl__12542.5217360773$1221347421$gmane$org@cs.columbia.edu>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1221347167-9956-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

checkpoint/sys.c - user/kernel data transfer, as well as setup of the
checkpoint/restart context (a per-checkpoint data structure for
housekeeping)

checkpoint/checkpoint.c - output wrappers and basic checkpoint handling

checkpoint/restart.c - input wrappers and basic restart handling

Patches to add the per-architecture support as well as the actual
work to do the memory checkpoint follow in subsequent patches.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 Makefile                       |    2 +-
 checkpoint/Makefile            |    2 +-
 checkpoint/checkpoint.c        |  174 ++++++++++++++++++++++++++++++++
 checkpoint/restart.c           |  189 ++++++++++++++++++++++++++++++++++
 checkpoint/sys.c               |  218 +++++++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint.h     |   60 +++++++++++
 include/linux/checkpoint_hdr.h |   75 ++++++++++++++
 include/linux/magic.h          |    3 +
 8 files changed, 717 insertions(+), 6 deletions(-)
 create mode 100644 checkpoint/checkpoint.c
 create mode 100644 checkpoint/restart.c
 create mode 100644 include/linux/checkpoint.h
 create mode 100644 include/linux/checkpoint_hdr.h

diff --git a/Makefile b/Makefile
index f448e00..a558ad2 100644
--- a/Makefile
+++ b/Makefile
@@ -619,7 +619,7 @@ export mod_strip_cmd
 
 
 ifeq ($(KBUILD_EXTMOD),)
-core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/
+core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/ checkpoint/
 
 vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, $(init-y) $(init-m) \
 		     $(core-y) $(core-m) $(drivers-y) $(drivers-m) \
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 07d018b..d2df68c 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -2,4 +2,4 @@
 # Makefile for linux checkpoint/restart.
 #
 
-obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o
+obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
new file mode 100644
index 0000000..e5e188f
--- /dev/null
+++ b/checkpoint/checkpoint.c
@@ -0,0 +1,174 @@
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
+#include <linux/magic.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
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
+	ret = cr_kwrite(ctx, h, sizeof(*h));
+	if (ret < 0)
+		return ret;
+	return cr_kwrite(ctx, buf, h->len);
+}
+
+/**
+ * cr_write_string - write a string
+ * @ctx: checkpoint context
+ * @str: string pointer
+ * @len: string length
+ */
+int cr_write_string(struct cr_ctx *ctx, char *str, int len)
+{
+	struct cr_hdr h;
+
+	h.type = CR_HDR_STRING;
+	h.len = len;
+	h.parent = 0;
+
+	return cr_write_obj(ctx, &h, str);
+}
+
+/* write the checkpoint header */
+static int cr_write_head(struct cr_ctx *ctx)
+{
+	struct cr_hdr h;
+	struct cr_hdr_head *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct new_utsname *uts;
+	struct timeval ktv;
+	int ret;
+
+	h.type = CR_HDR_HEAD;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	do_gettimeofday(&ktv);
+
+	hh->magic = CHECKPOINT_MAGIC_HEAD;
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
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+/* write the checkpoint trailer */
+static int cr_write_tail(struct cr_ctx *ctx)
+{
+	struct cr_hdr h;
+	struct cr_hdr_tail *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int ret;
+
+	h.type = CR_HDR_TAIL;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	hh->magic = CHECKPOINT_MAGIC_TAIL;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+/* dump the task_struct of a given task */
+static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_task *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int ret;
+
+	h.type = CR_HDR_TASK;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	hh->state = t->state;
+	hh->exit_state = t->exit_state;
+	hh->exit_code = t->exit_code;
+	hh->exit_signal = t->exit_signal;
+
+	hh->task_comm_len = TASK_COMM_LEN;
+
+	/* FIXME: save remaining relevant task_struct fields */
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		return ret;
+
+	return cr_write_string(ctx, t->comm, TASK_COMM_LEN);
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
+	ret = cr_write_head(ctx);
+	if (ret < 0)
+		goto out;
+	ret = cr_write_task(ctx, current);
+	if (ret < 0)
+		goto out;
+	ret = cr_write_tail(ctx);
+	if (ret < 0)
+		goto out;
+
+	/* on success, return (unique) checkpoint identifier */
+	ret = ctx->crid;
+
+ out:
+	return ret;
+}
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
new file mode 100644
index 0000000..ef6bc37
--- /dev/null
+++ b/checkpoint/restart.c
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
+#include <linux/version.h>
+#include <linux/sched.h>
+#include <linux/file.h>
+#include <linux/magic.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/**
+ * cr_read_obj - read a whole record (cr_hdr followed by payload)
+ * @ctx: checkpoint context
+ * @h: record descriptor
+ * @buf: record buffer
+ * @n: available buffer size
+ *
+ * Returns size of payload
+ */
+int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n)
+{
+	int ret;
+
+	ret = cr_kread(ctx, h, sizeof(*h));
+	if (ret < 0)
+		return ret;
+
+	cr_debug("type %d len %d parent %d\n", h->type, h->len, h->parent);
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
+ *
+ * Returns object reference of the parent object
+ */
+int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type)
+{
+	struct cr_hdr h;
+	int ret;
+
+	ret = cr_read_obj(ctx, &h, buf, n);
+	if (!ret) {
+		if (h.type == type)
+			ret = h.parent;
+		else
+			ret = -EINVAL;
+	}
+	return ret;
+}
+
+/**
+ * cr_read_string - read a string
+ * @ctx: checkpoint context
+ * @str: string buffer
+ * @len: buffer buffer length
+ */
+int cr_read_string(struct cr_ctx *ctx, void *str, int len)
+{
+	return cr_read_obj_type(ctx, str, len, CR_HDR_STRING);
+}
+
+/* read the checkpoint header */
+static int cr_read_head(struct cr_ctx *ctx)
+{
+	struct cr_hdr_head *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int parent;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_HEAD);
+	if (parent < 0)
+		return parent;
+	else if (parent != 0)
+		return -EINVAL;
+
+	if (hh->magic != CHECKPOINT_MAGIC_HEAD || hh->rev != CR_VERSION ||
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
+	int parent;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_TAIL);
+	if (parent < 0)
+		return parent;
+	else if (parent != 0)
+		return -EINVAL;
+
+	if (hh->magic != CHECKPOINT_MAGIC_TAIL)
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
+	char *buf;
+	int parent, ret;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_TASK);
+	if (parent < 0)
+		return parent;
+	else if (parent != 0)
+		return -EINVAL;
+
+	/* upper limit for task_comm_len to prevent DoS */
+	if (hh->task_comm_len < 0 || hh->task_comm_len > PAGE_SIZE)
+		return -EINVAL;
+
+	buf = kmalloc(hh->task_comm_len, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+	ret = cr_read_string(ctx, buf, hh->task_comm_len);
+	if (!ret) {
+		/* if t->comm is too long, silently truncate */
+		memset(t->comm, 0, TASK_COMM_LEN);
+		memcpy(t->comm, buf, min(hh->task_comm_len, TASK_COMM_LEN));
+	}
+	kfree(buf);
+
+	/* FIXME: restore remaining relevant task_struct fields */
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
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
+	ret = cr_read_head(ctx);
+	if (ret < 0)
+		goto out;
+	ret = cr_read_task(ctx);
+	if (ret < 0)
+		goto out;
+	ret = cr_read_tail(ctx);
+	if (ret < 0)
+		goto out;
+
+	/* on success, adjust the return value if needed [TODO] */
+ out:
+	return ret;
+}
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 375129c..30863c6 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -10,6 +10,189 @@
 
 #include <linux/sched.h>
 #include <linux/kernel.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/uaccess.h>
+#include <linux/capability.h>
+#include <linux/checkpoint.h>
+
+/*
+ * helpers to write/read to/from the image file descriptor
+ *
+ *   cr_uwrite() - write a user-space buffer to the checkpoint image
+ *   cr_kwrite() - write a kernel-space buffer to the checkpoint image
+ *   cr_uread() - read from the checkpoint image to a user-space buffer
+ *   cr_kread() - read from the checkpoint image to a kernel-space buffer
+ */
+
+/*
+ * FIXME: (temporarily added file_pos_read() and file_pos_write() because
+ * they are static in fs/read_write.c... should cleanup and remove later)
+ */
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
+		if (nwrite <= 0) {
+			if (nwrite == -EAGAIN)
+				nwrite = 0;
+			else
+				return nwrite;
+		}
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
+		if (nread <= 0) {
+			if (nread == -EAGAIN)
+				nread = 0;
+			else
+				return nread;
+		}
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
+/* unique checkpoint identifier (FIXME: should be per-container) */
+static atomic_t cr_ctx_count;
+
+void cr_ctx_free(struct cr_ctx *ctx)
+{
+	if (ctx->file)
+		fput(ctx->file);
+
+	free_pages((unsigned long) ctx->hbuf, CR_HBUF_ORDER);
+
+	kfree(ctx);
+}
+
+struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
+{
+	struct cr_ctx *ctx;
+
+	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
+	if (!ctx)
+		return ERR_PTR(-ENOMEM);
+
+	ctx->file = fget(fd);
+	if (!ctx->file) {
+		cr_ctx_free(ctx);
+		return ERR_PTR(-EBADF);
+	}
+
+	ctx->hbuf = (void *) __get_free_pages(GFP_KERNEL, CR_HBUF_ORDER);
+	if (!ctx->hbuf) {
+		cr_ctx_free(ctx);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	ctx->pid = pid;
+	ctx->flags = flags;
+
+	ctx->crid = atomic_inc_return(&cr_ctx_count);
+
+	return ctx;
+}
+
+/*
+ * During checkpoint and restart the code writes outs/reads in data
+ * to/from the chekcpoint image from/to a temporary buffer (ctx->hbuf).
+ * Because operations can be nested, one should call cr_hbuf_get() to
+ * reserve space in the buffer, and then cr_hbuf_put() when no longer
+ * needs that space.
+ */
+
+/**
+ * cr_hbuf_get - reserve space on the hbuf
+ * @ctx: checkpoint context
+ * @n: number of bytes to reserve
+ *
+ * Returns pointer to reserved space
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
 
 /**
  * sys_checkpoint - checkpoint a container
@@ -22,9 +205,23 @@
  */
 asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
 {
-	pr_debug("sys_checkpoint not implemented yet\n");
-	return -ENOSYS;
+	struct cr_ctx *ctx;
+	int ret;
+
+	/* no flags for now */
+	if (flags)
+		return -EINVAL;
+
+	ctx = cr_ctx_alloc(pid, fd, flags | CR_CTX_CKPT);
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	ret = do_checkpoint(ctx);
+
+	cr_ctx_free(ctx);
+	return ret;
 }
+
 /**
  * sys_restart - restart a container
  * @crid: checkpoint image identifier
@@ -36,6 +233,19 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
  */
 asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
 {
-	pr_debug("sys_restart not implemented yet\n");
-	return -ENOSYS;
+	struct cr_ctx *ctx;
+	int ret;
+
+	/* no flags for now */
+	if (flags)
+		return -EINVAL;
+
+	ctx = cr_ctx_alloc(crid, fd, flags | CR_CTX_RSTR);
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	ret = do_restart(ctx);
+
+	cr_ctx_free(ctx);
+	return ret;
 }
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
new file mode 100644
index 0000000..5e53ae6
--- /dev/null
+++ b/include/linux/checkpoint.h
@@ -0,0 +1,60 @@
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
+	void *hbuf;		/* temporary buffer for headers */
+	int hpos;		/* position in headers buffer */
+};
+
+/* cr_ctx: flags */
+#define CR_CTX_CKPT	0x1
+#define CR_CTX_RSTR	0x2
+
+/* allocation defaults */
+#define CR_HBUF_ORDER  1
+#define CR_HBUF_TOTAL  (PAGE_SIZE << CR_HBUF_ORDER)
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
+extern int cr_write_string(struct cr_ctx *ctx, char *str, int len);
+
+extern int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n);
+extern int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type);
+extern int cr_read_string(struct cr_ctx *ctx, void *str, int len);
+
+extern int do_checkpoint(struct cr_ctx *ctx);
+extern int do_restart(struct cr_ctx *ctx);
+
+#define cr_debug(fmt, args...)  \
+	pr_debug("[CR:%s] " fmt, __func__, ## args)
+
+#endif /* _CHECKPOINT_CKPT_H_ */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
new file mode 100644
index 0000000..79e4df2
--- /dev/null
+++ b/include/linux/checkpoint_hdr.h
@@ -0,0 +1,75 @@
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
+	__u32 parent;
+};
+
+/* header types */
+enum {
+	CR_HDR_HEAD = 1,
+	CR_HDR_STRING,
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
+} __attribute__((aligned(8)));
+
+struct cr_hdr_tail {
+	__u64 magic;
+} __attribute__((aligned(8)));
+
+struct cr_hdr_task {
+	__u32 state;
+	__u32 exit_state;
+	__u32 exit_code;
+	__u32 exit_signal;
+
+	__s32 task_comm_len;
+} __attribute__((aligned(8)));
+
+#endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/include/linux/magic.h b/include/linux/magic.h
index 1fa0c2c..c2b811c 100644
--- a/include/linux/magic.h
+++ b/include/linux/magic.h
@@ -42,4 +42,7 @@
 #define FUTEXFS_SUPER_MAGIC	0xBAD1DEA
 #define INOTIFYFS_SUPER_MAGIC	0x2BAD1DEA
 
+#define CHECKPOINT_MAGIC_HEAD  0x00feed0cc0a2d200LL
+#define CHECKPOINT_MAGIC_TAIL  0x002d2a0cc0deef00LL
+
 #endif /* __LINUX_MAGIC_H__ */
-- 
1.5.4.3
