From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 29/30] cr: tty/pty
Date: Fri, 10 Apr 2009 06:40:50 +0400
Message-ID: <20090410024050.GD27788__15374.6108328507$1239332031$gmane$org@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

FIXME: opened tty won't passed ->checkpoint check.

currently in desperate need on how to test it.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/linux/cr.h  |   37 ++++++++++++
 kernel/cr/Kconfig   |    1 
 kernel/cr/Makefile  |    1 
 kernel/cr/cpt-sys.c |    6 +
 kernel/cr/cr-pid.c  |   14 ++++
 kernel/cr/cr-tty.c  |  160 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/cr/cr.h      |    4 +
 7 files changed, 223 insertions(+)

--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -51,6 +51,7 @@ struct cr_object_header {
 #define CR_OBJ_MNT_NS		20
 #define CR_OBJ_NET_NS		21
 #define CR_OBJ_SOCK		22
+#define CR_OBJ_TTY		23
 	__u32	cr_type;	/* object type */
 	__u32	cr_len;		/* object length in bytes including header */
 } __packed;
@@ -381,4 +382,40 @@ struct cr_image_sock {
 	cr_pos_t	cr_pos_sk_net;
 	__u16		cr_sk_family;
 } __packed;
+
+struct cr_image_tty {
+	struct cr_object_header cr_hdr;
+
+	__u16		cr_driver_type;
+	__u16		cr_driver_subtype;
+	__u32		cr_driver_flags;
+	__u32		cr_index;
+	__u32		cr_link_index;
+	struct {
+		__u32	cr_c_iflag;
+		__u32	cr_c_oflag;
+		__u32	cr_c_cflag;
+		__u32	cr_c_lflag;
+		__u8	cr_c_line;
+		__u8	cr_c_cc[23];
+		__u32	cr_c_ispeed;
+		__u32	cr_c_ospeed;
+	} cr_termios;
+	__u8		cr_name[64];
+	cr_pos_t	cr_pos_pgrp;	/* CR_POS_UNDEF if tty->pgrp == NULL */
+	cr_pos_t	cr_pos_session;	/* CR_POS_UNDEF if tty->session == NULL */
+	__u64		cr_flags;
+	struct {
+		__u16	cr_ws_row;
+		__u16	cr_ws_col;
+		__u16	cr_ws_xpixel;
+		__u16	cr_ws_ypixel;
+	} cr_winsize;
+	__u8		cr_stopped;
+	__u8		cr_hw_stopped;
+	__u8		cr_flow_stopped;
+	__u8		cr_packet;
+	__u8		cr_low_latency;
+	__u8		cr_ctrl_status;
+} __packed;
 #endif
--- a/kernel/cr/Kconfig
+++ b/kernel/cr/Kconfig
@@ -1,5 +1,6 @@
 config CR
 	bool "Container checkpoint/restart"
+	depends on DEVPTS_MULTIPLE_INSTANCES
 	depends on NET_NS || (NET = n)
 	depends on PID_NS
 	depends on USER_NS
--- a/kernel/cr/Makefile
+++ b/kernel/cr/Makefile
@@ -12,6 +12,7 @@ cr-y += cr-pid.o
 cr-y += cr-signal.o
 cr-$(CONFIG_NET) += cr-socket.o
 cr-y += cr-task.o
+cr-y += cr-tty.o
 cr-y += cr-uts.o
 cr-$(CONFIG_X86_32) += cr-x86_32.o
 cr-$(CONFIG_X86_64) += cr-x86_64.o
--- a/kernel/cr/cpt-sys.c
+++ b/kernel/cr/cpt-sys.c
@@ -101,6 +101,9 @@ static int cr_collect(struct cr_context *ctx)
 	rv = cr_collect_all_sighand_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_collect_all_tty_struct(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_collect_all_cred(ctx);
 	if (rv < 0)
 		return rv;
@@ -179,6 +182,9 @@ static int cr_dump(struct cr_context *ctx)
 	rv = cr_dump_all_fs_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_dump_all_tty(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_dump_all_uts_ns(ctx);
 	if (rv < 0)
 		return rv;
--- a/kernel/cr/cr-pid.c
+++ b/kernel/cr/cr-pid.c
@@ -226,6 +226,20 @@ int cr_collect_all_pid(struct cr_context *ctx)
 				return rv;
 		}
 	}
+	for_each_cr_object(ctx, obj, CR_CTX_TTY) {
+		struct tty_struct *tty = obj->o_obj;
+
+		if (tty->pgrp) {
+			rv = cr_collect_pid(ctx, tty->pgrp);
+			if (rv < 0)
+				return rv;
+		}
+		if (tty->session) {
+			rv = cr_collect_pid(ctx, tty->session);
+			if (rv < 0)
+				return rv;
+		}
+	}
 	/* FIXME pid refcount check should account references from proc inodes */
 	return 0;
 }
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-tty.c
@@ -0,0 +1,160 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/tty.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+static int cr_check_tty(struct tty_struct *tty)
+{
+	if (!tty->link) {
+		WARN(1, "tty %p, tty->link %p\n", tty, tty->link);
+		return -EINVAL;
+	}
+	if (tty->link->link != tty) {
+		WARN(1, "tty %p, tty->link %p, tty->link->link %p\n", tty, tty->link, tty->link->link);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static int __cr_collect_tty(struct cr_context *ctx, struct tty_struct *tty)
+{
+	int rv;
+
+	rv = cr_collect_object(ctx, tty, CR_CTX_TTY);
+	printk("collect tty %p: rv %d\n", tty, rv);
+	return rv;
+}
+
+static int cr_collect_tty(struct cr_context *ctx, struct tty_struct *tty)
+{
+	int rv;
+
+	rv = cr_check_tty(tty);
+	if (rv < 0)
+		return rv;
+	rv = __cr_collect_tty(ctx, tty);
+	if (rv < 0)
+		return rv;
+	if (tty->link) {
+		rv = cr_check_tty(tty->link);
+		if (rv < 0)
+			return rv;
+		rv = __cr_collect_tty(ctx, tty->link);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int cr_collect_all_tty_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_FILE) {
+		struct file *file = obj->o_obj;
+		struct inode *inode = file->f_path.dentry->d_inode;
+
+		if (!S_ISCHR(inode->i_mode))
+			continue;
+
+		switch (imajor(inode)) {
+		case UNIX98_PTY_SLAVE_MAJOR:
+			rv = cr_collect_tty(ctx, file->private_data);
+			if (rv < 0)
+				return rv;
+			break;
+		}
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_TTY) {
+		struct tty_struct *tty = obj->o_obj;
+
+		if (tty->driver->type == TTY_DRIVER_TYPE_PTY && tty->driver->subtype == PTY_TYPE_SLAVE) {
+			if (tty->link && tty->link->count)
+				obj->o_count++;
+		}
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_TTY) {
+		struct tty_struct *tty = obj->o_obj;
+		unsigned int cnt = tty->count;
+
+		if (obj->o_count != cnt) {
+			printk("%s: tty %p has external references %lu:%u\n", __func__, tty, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int cr_dump_tty(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct tty_struct *tty = obj->o_obj;
+	struct cr_image_tty *i;
+	struct cr_object *tmp;
+	int n;
+	int rv;
+
+	printk("dump tty = %p, type = %d, subtype = %d\n", tty, tty->driver->type, tty->driver->subtype);
+
+	i = cr_prepare_image(CR_OBJ_TTY, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	i->cr_driver_type = tty->driver->type;
+	i->cr_driver_subtype = tty->driver->subtype;
+	i->cr_driver_flags = tty->driver->flags;
+	i->cr_index = tty->index;
+	i->cr_link_index = tty->link->index;
+	i->cr_termios.cr_c_iflag = tty->termios->c_iflag;
+	i->cr_termios.cr_c_oflag = tty->termios->c_oflag;
+	i->cr_termios.cr_c_cflag = tty->termios->c_cflag;
+	i->cr_termios.cr_c_lflag = tty->termios->c_lflag;
+	i->cr_termios.cr_c_line = tty->termios->c_line;
+	BUILD_BUG_ON(NCCS > 23);
+	for (n = 0; n < NCCS; n++)
+		i->cr_termios.cr_c_cc[n] = tty->termios->c_cc[n];
+	i->cr_termios.cr_c_ispeed = tty->termios->c_ispeed;
+	i->cr_termios.cr_c_ospeed = tty->termios->c_ospeed;
+	BUILD_BUG_ON(sizeof(tty->name) > 64);
+	strlcpy(i->cr_name, tty->name, 64);
+	if (tty->pgrp) {
+		tmp = cr_find_obj_by_ptr(ctx, tty->pgrp, CR_CTX_PID);
+		i->cr_pos_pgrp = tmp->o_pos;
+	} else
+		i->cr_pos_pgrp = CR_POS_UNDEF;
+	if (tty->session) {
+		tmp = cr_find_obj_by_ptr(ctx, tty->session, CR_CTX_PID);
+		i->cr_pos_session = tmp->o_pos;
+	} else
+		i->cr_pos_session = CR_POS_UNDEF;
+	i->cr_flags = tty->flags;
+	i->cr_winsize.cr_ws_row = tty->winsize.ws_row;
+	i->cr_winsize.cr_ws_col = tty->winsize.ws_col;
+	i->cr_winsize.cr_ws_xpixel = tty->winsize.ws_xpixel;
+	i->cr_winsize.cr_ws_ypixel = tty->winsize.ws_ypixel;
+	i->cr_stopped = tty->stopped;
+	i->cr_hw_stopped = tty->hw_stopped;
+	i->cr_flow_stopped = tty->flow_stopped;
+	i->cr_packet = tty->packet;
+	i->cr_low_latency = tty->low_latency;
+	i->cr_ctrl_status = tty->ctrl_status;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+
+int cr_dump_all_tty(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TTY) {
+		rv = cr_dump_tty(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
--- a/kernel/cr/cr.h
+++ b/kernel/cr/cr.h
@@ -3,6 +3,7 @@
 #define __KERNEL_CR_CR_H
 #include <linux/list.h>
 #include <linux/slab.h>
+#include <asm/signal.h>
 
 #include <linux/cr.h>
 
@@ -41,6 +42,7 @@ enum cr_context_obj_type {
 	CR_CTX_SOCK,
 #endif
 	CR_CTX_TASK_STRUCT,
+	CR_CTX_TTY,
 	CR_CTX_USER_NS,
 	CR_CTX_USER_STRUCT,
 	CR_CTX_UTS_NS,
@@ -125,6 +127,7 @@ static inline int cr_collect_all_sock(struct cr_context *ctx)
 }
 #endif
 int cr_collect_all_task_struct(struct cr_context *ctx);
+int cr_collect_all_tty_struct(struct cr_context *ctx);
 int cr_collect_all_user_ns(struct cr_context *ctx);
 int cr_collect_all_user_struct(struct cr_context *ctx);
 int cr_collect_all_uts_ns(struct cr_context *ctx);
@@ -158,6 +161,7 @@ static inline int cr_dump_all_sock(struct cr_context *ctx)
 }
 #endif
 int cr_dump_all_task_struct(struct cr_context *ctx);
+int cr_dump_all_tty(struct cr_context *ctx);
 int cr_dump_all_user_ns(struct cr_context *ctx);
 int cr_dump_all_user_struct(struct cr_context *ctx);
 int cr_dump_all_uts_ns(struct cr_context *ctx);
