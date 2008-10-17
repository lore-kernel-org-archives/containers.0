From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 03/10] Introduce context structure needed during
	checkpointing/restart
Date: Sat, 18 Oct 2008 03:11:31 +0400
Message-ID: <1224285098-573-4-git-send-email-major@openvz.org>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-2-git-send-email-major@openvz.org>
	<1224285098-573-3-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224285098-573-3-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Add functions for context allocation/destroy.
Introduce functions to read/write image.
Introduce image header and object header.

Signed-off-by: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 checkpoint/checkpoint.h |   40 +++++++++++++++
 checkpoint/cpt_image.h  |   63 ++++++++++++++++++++++++
 checkpoint/sys.c        |  125 +++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 225 insertions(+), 3 deletions(-)
 create mode 100644 checkpoint/cpt_image.h

diff --git a/checkpoint/checkpoint.h b/checkpoint/checkpoint.h
index 381a9bf..8ea73f5 100644
--- a/checkpoint/checkpoint.h
+++ b/checkpoint/checkpoint.h
@@ -10,6 +10,8 @@
  *
  */
 
+#include "cpt_image.h"
+
 struct cpt_operations
 {
 	struct module * owner;
@@ -17,3 +19,41 @@ struct cpt_operations
 	int (*restart)(int ctid, int fd, unsigned long flags);
 };
 extern struct cpt_operations cpt_ops;
+
+enum cpt_ctx_state
+{
+	CPT_CTX_ERROR = -1,
+	CPT_CTX_IDLE = 0,
+	CPT_CTX_DUMPING,
+	CPT_CTX_UNDUMPING
+};
+
+typedef struct cpt_context
+{
+	pid_t		pid;		/* should be changed to ctid later */
+	int		ctx_id;		/* context id */
+	struct list_head ctx_list;
+	int		refcount;
+	int		ctx_state;
+	struct semaphore main_sem;
+
+	int		errno;
+
+	struct file	*file;
+	loff_t		current_object;
+
+	struct list_head object_array[CPT_OBJ_MAX];
+
+	int		(*write)(const void *addr, size_t count, struct cpt_context *ctx);
+	int		(*read)(void *addr, size_t count, struct cpt_context *ctx);
+} cpt_context_t;
+
+extern int debug_level;
+
+#define cpt_printk(lvl, fmt, args...)	do {	\
+		if (lvl <= debug_level)		\
+			printk(fmt, ##args);	\
+	} while (0)
+
+#define eprintk(a...) cpt_printk(1, "CPT ERR: " a)
+#define dprintk(a...) cpt_printk(1, "CPT DBG: " a)
diff --git a/checkpoint/cpt_image.h b/checkpoint/cpt_image.h
new file mode 100644
index 0000000..0338dd0
--- /dev/null
+++ b/checkpoint/cpt_image.h
@@ -0,0 +1,63 @@
+/*
+ *  Copyright (C) 2008 Parallels, Inc.
+ *
+ *  Author: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ *
+ */
+
+#ifndef __CPT_IMAGE_H_
+#define __CPT_IMAGE_H_ 1
+
+enum _cpt_object_type
+{
+	CPT_OBJ_TASK = 0,
+	CPT_OBJ_MAX,
+	/* The objects above are stored in memory while checkpointing */
+
+	CPT_OBJ_HEAD = 1024,
+};
+
+enum _cpt_content_type {
+	CPT_CONTENT_VOID,
+	CPT_CONTENT_ARRAY,
+	CPT_CONTENT_DATA,
+	CPT_CONTENT_NAME,
+	CPT_CONTENT_REF,
+	CPT_CONTENT_MAX
+};
+
+#define CPT_SIGNATURE0 0x79
+#define CPT_SIGNATURE1 0x1c
+#define CPT_SIGNATURE2 0x01
+#define CPT_SIGNATURE3 0x63
+
+struct cpt_head
+{
+	__u8	cpt_signature[4];	/* Magic number */
+	__u32	cpt_hdrlen;		/* Header length */
+	__u16	cpt_image_major;	/* Format of this file */
+	__u16	cpt_image_minor;	/* Format of this file */
+	__u16	cpt_image_sublevel;	/* Format of this file */
+	__u16	cpt_image_extra;	/* Format of this file */
+	__u16	cpt_arch;		/* Architecture */
+#define CPT_ARCH_I386		0
+	__u16	cpt_pad1;
+	__u32	cpt_pad2;
+	__u64	cpt_time;		/* Time */
+} __attribute__ ((aligned (8)));
+
+/* Common object header. */
+struct cpt_object_hdr
+{
+	__u64	cpt_len;		/* Size of current chunk of data */
+	__u32	cpt_hdrlen;		/* Size of header */
+	__u16	cpt_type;		/* Type of object */
+	__u16	cpt_content;		/* Content type: array, reference... */
+} __attribute__ ((aligned (8)));
+
+#endif /* __CPT_IMAGE_H_ */
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 010e4eb..a561a06 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -13,21 +13,140 @@
 #include <linux/sched.h>
 #include <linux/fs.h>
 #include <linux/file.h>
-#include <linux/notifier.h>
+#include <linux/uaccess.h>
 #include <linux/module.h>
 
 #include "checkpoint.h"
+#include "cpt_image.h"
 
 MODULE_LICENSE("GPL");
 
+/* Debug level, constant for now */
+int debug_level = 1;
+
+static int file_write(const void *addr, size_t count, struct cpt_context *ctx)
+{
+	mm_segment_t oldfs;
+	ssize_t err = -EBADF;
+	struct file *file = ctx->file;
+
+	oldfs = get_fs(); set_fs(KERNEL_DS);
+	if (file)
+		err = file->f_op->write(file, addr, count, &file->f_pos);
+	set_fs(oldfs);
+	if (err != count)
+		return err >= 0 ? -EIO : err;
+	return 0;
+}
+
+static int file_read(void *addr, size_t count, struct cpt_context *ctx)
+{
+	mm_segment_t oldfs;
+	ssize_t err = -EBADF;
+	struct file *file = ctx->file;
+
+	oldfs = get_fs(); set_fs(KERNEL_DS);
+	if (file)
+		err = file->f_op->read(file, addr, count, &file->f_pos);
+	set_fs(oldfs);
+	if (err != count)
+		return err >= 0 ? -EIO : err;
+	return 0;
+}
+
+struct cpt_context * context_alloc(void)
+{
+	struct cpt_context *ctx;
+	int i;
+
+	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
+	if (!ctx)
+		return NULL;
+
+	init_MUTEX(&ctx->main_sem);
+	ctx->refcount = 1;
+
+	ctx->current_object = -1;
+	ctx->write = file_write;
+	ctx->read = file_read;
+	for (i = 0; i < CPT_OBJ_MAX; i++) {
+		INIT_LIST_HEAD(&ctx->object_array[i]);
+	}
+
+	return ctx;
+}
+
+void context_release(struct cpt_context *ctx)
+{
+	ctx->ctx_state = CPT_CTX_ERROR;
+
+	kfree(ctx);
+}
+
+static void context_put(struct cpt_context *ctx)
+{
+	if (!--ctx->refcount)
+		context_release(ctx);
+}
+
 static int checkpoint(pid_t pid, int fd, unsigned long flags)
 {
-	return -ENOSYS; 
+	struct file *file;
+	struct cpt_context *ctx;
+	int err;
+
+	err = -EBADF;
+	file = fget(fd);
+	if (!file)
+		goto out;
+
+	err = -ENOMEM;
+	ctx = context_alloc();
+	if (!ctx)
+		goto out_file;
+
+	ctx->file = file;
+	ctx->ctx_state = CPT_CTX_DUMPING;
+
+	/* checkpoint */
+	err = -ENOSYS;
+
+	context_put(ctx);
+
+out_file:
+	fput(file);
+out:
+	return err; 
 }
 
 static int restart(int ctid, int fd, unsigned long flags)
 {
-	return -ENOSYS; 
+	struct file *file;
+	struct cpt_context *ctx;
+	int err;
+
+	err = -EBADF;
+	file = fget(fd);
+	if (!file)
+		goto out;
+
+	err = -ENOMEM;
+	ctx = context_alloc();
+	if (!ctx)
+		goto out_file;
+
+	ctx->file = file;
+	ctx->ctx_state = CPT_CTX_UNDUMPING;
+
+	/* restart */
+	err = -ENOSYS;
+
+	context_put(ctx);
+
+out_file:
+	fput(file);
+out:
+	return err; 
 }
 
 static int __init init_cptrst(void)
-- 
1.5.6
