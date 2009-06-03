From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] c/r: Add AF_UNIX support
Date: Wed,  3 Jun 2009 08:18:25 -0700
Message-ID: <1244042305-7770-1-git-send-email-danms@us.ibm.com>
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
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
has been tested with a single and multiple processes, and with data inflight
at the time of checkpoint.  It supports both socketpair()s and path-based
sockets.

I have an almost-working AF_INET follow-on to this which I can submit after
this is reviewed and tweaked into acceptance.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c             |    7 +
 checkpoint/objhash.c           |   27 +++
 include/linux/checkpoint_hdr.h |   71 ++++++++
 include/net/sock.h             |    8 +
 net/Makefile                   |    2 +
 net/socket.c                   |   58 ++++++
 net/socket_cr.c                |  378 ++++++++++++++++++++++++++++++++++++++++
 7 files changed, 551 insertions(+), 0 deletions(-)
 create mode 100644 net/socket_cr.c

diff --git a/checkpoint/files.c b/checkpoint/files.c
index b264e40..bb2cca0 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <net/sock.h>
 
 
 /**************************************************************************
@@ -440,6 +441,12 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_PIPE,
 		.restore = pipe_file_restore,
 	},
+	/* socket */
+	{
+		.file_name = "SOCKET",
+		.file_type = CKPT_FILE_SOCKET,
+		.restore = sock_file_restore,
+	},
 };
 
 static struct file *do_restore_file(struct ckpt_ctx *ctx)
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 045a920..7819e5e 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -19,6 +19,7 @@
 #include <linux/ipc_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <net/sock.h>
 
 struct ckpt_obj;
 struct ckpt_obj_ops;
@@ -177,6 +178,22 @@ static int obj_ipc_ns_users(void *ptr)
 	return atomic_read(&((struct ipc_namespace *) ptr)->count);
 }
 
+static int obj_sock_grab(void *ptr)
+{
+	sock_hold((struct sock *) ptr);
+	return 0;
+}
+
+static void obj_sock_drop(void *ptr)
+{
+	sock_put((struct sock *) ptr);
+}
+
+static int obj_sock_users(void *ptr)
+{
+	return atomic_read(&((struct sock *) ptr)->sk_refcnt);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -254,6 +271,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_bad,
 		.restore = restore_bad,
 	},
+	/* sock object */
+	{
+		.obj_name = "SOCKET",
+		.obj_type = CKPT_OBJ_SOCK,
+		.ref_drop = obj_sock_drop,
+		.ref_grab = obj_sock_grab,
+		.ref_users = obj_sock_users,
+		.checkpoint = sock_file_checkpoint,
+		.restore = sock_file_restore,
+	},
 };
 
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index cd427d8..252331a 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -12,6 +12,13 @@
 
 #include <linux/types.h>
 #include <linux/utsname.h>
+#include <linux/socket.h>
+
+/* In userspace, bring in the struct sockaddr_* definitions */
+#ifndef __KERNEL__
+#include <sys/socket.h>
+#include <sys/types.h>
+#endif
 
 /*
  * To maintain compatibility between 32-bit and 64-bit architecture flavors,
@@ -76,6 +83,11 @@ enum {
 	CKPT_HDR_IPC_MSG_MSG,
 	CKPT_HDR_IPC_SEM,
 
+ 	CKPT_HDR_FD_SOCKET = 601,
+ 	CKPT_HDR_SOCKET,
+ 	CKPT_HDR_SOCKET_BUFFERS,
+ 	CKPT_HDR_SOCKET_BUFFER,
+
 	CKPT_HDR_TAIL = 9001,
 
 	CKPT_HDR_ERROR = 9999,
@@ -103,6 +115,7 @@ enum obj_type {
 	CKPT_OBJ_NS,
 	CKPT_OBJ_UTS_NS,
 	CKPT_OBJ_IPC_NS,
+	CKPT_OBJ_SOCK,
 	CKPT_OBJ_MAX
 };
 
@@ -225,6 +238,7 @@ enum file_type {
 	CKPT_FILE_IGNORE = 0,
 	CKPT_FILE_GENERIC,
 	CKPT_FILE_PIPE,
+	CKPT_FILE_SOCKET,
 	CKPT_FILE_MAX
 };
 
@@ -248,6 +262,11 @@ struct ckpt_hdr_file_pipe {
 	__s32 pipe_objref;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_file_socket {
+	struct ckpt_hdr_file common;
+	__u16 family;
+} __attribute__((aligned(8)));
+
 struct ckpt_hdr_file_pipe_state {
 	struct ckpt_hdr h;
 	__s32 pipe_len;
@@ -394,4 +413,56 @@ struct ckpt_hdr_ipc_sem {
 #define CKPT_TST_OVERFLOW_64(a, b) \
 	((sizeof(a) > sizeof(b)) && ((a) > LONG_MAX))
 
+struct ckpt_hdr_socket {
+	struct ckpt_hdr h;
+
+	/* sock_common */
+	__u16 family;
+	__u8 state;
+	__u8 reuse;
+	__u32 bound_dev_if;
+
+	/* sock */
+	__u8 protocol;
+	__u16 type;
+	__u8 sock_state;
+	__u8 shutdown;
+	__u8 userlocks;
+	__u8 no_check;
+	__u32 err;
+	__u32 err_soft;
+	__u32 priority;
+	__u64 rcvlowat;
+	__u64 rcvtimeo;
+	__u64 sndtimeo;
+	__u16 backlog;
+	__s32 rcvbuf;
+	__s32 sndbuf;
+	__u64 flags;
+	__u64 lingertime;
+
+	/* socket */
+	__u64 socket_flags;
+	__u8 socket_state;
+
+	/* common to all supported families */
+	struct sockaddr laddr;
+	struct sockaddr raddr;
+	__u32 laddr_len;
+	__u32 raddr_len;
+
+	union {
+		struct {
+			__u32 this;
+			__u32 peer;
+		} un;
+	};
+
+} __attribute__ ((aligned(8)));
+
+struct ckpt_hdr_socket_buffer {
+	struct ckpt_hdr h;
+	__u32 skb_count;
+} __attribute__ ((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/include/net/sock.h b/include/net/sock.h
index 4bb1ff9..ced8cd9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1482,4 +1482,12 @@ extern int sysctl_optmem_max;
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
 
+/* Checkpoint/Restart Functions */
+struct ckpt_ctx;
+struct ckpt_hdr_socket;
+extern int sock_file_checkpoint(struct ckpt_ctx *, void *);
+extern struct socket *__sock_file_restore(struct ckpt_ctx *,
+					  struct ckpt_hdr_socket *);
+extern void *sock_file_restore(struct ckpt_ctx *);
+
 #endif	/* _SOCK_H */
diff --git a/net/Makefile b/net/Makefile
index 9e00a55..1c68a4e 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -65,3 +65,5 @@ ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
 endif
 obj-$(CONFIG_WIMAX)		+= wimax/
+
+obj-$(CONFIG_CHECKPOINT)	+= socket_cr.o
diff --git a/net/socket.c b/net/socket.c
index 791d71a..d1a187d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -96,6 +96,9 @@
 #include <net/sock.h>
 #include <linux/netfilter.h>
 
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 			 unsigned long nr_segs, loff_t pos);
@@ -140,6 +143,9 @@ static const struct file_operations socket_file_ops = {
 	.sendpage =	sock_sendpage,
 	.splice_write = generic_splice_sendpage,
 	.splice_read =	sock_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint =   sock_file_checkpoint,
+#endif
 };
 
 /*
@@ -415,6 +421,58 @@ int sock_map_fd(struct socket *sock, int flags)
 	return fd;
 }
 
+static struct file *sock_alloc_attach_fd(struct socket *socket)
+{
+	struct file *file;
+	int err;
+
+	file = get_empty_filp();
+	if (!file)
+		return ERR_PTR(ENOMEM);
+
+	err = sock_attach_fd(socket, file, 0);
+	if (err < 0) {
+		put_filp(file);
+		file = ERR_PTR(err);
+	}
+
+	return file;
+}
+
+void *sock_file_restore(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_socket *h = NULL;
+	struct socket *socket = NULL;
+	struct file *file = NULL;
+	int err;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
+	if (IS_ERR(h))
+		return h;
+
+	socket = __sock_file_restore(ctx, h);
+	if (IS_ERR(socket)) {
+		err = PTR_ERR(socket);
+		goto err_put;
+	}
+
+	file = sock_alloc_attach_fd(socket);
+	if (IS_ERR(file)) {
+		err = PTR_ERR(file);
+		goto err_release;
+	}
+
+	ckpt_hdr_put(ctx, h);
+
+	return file;
+ err_release:
+	sock_release(socket);
+ err_put:
+	ckpt_hdr_put(ctx, h);
+
+	return ERR_PTR(err);
+}
+
 static struct socket *sock_from_file(struct file *file, int *err)
 {
 	if (file->f_op == &socket_file_ops)
diff --git a/net/socket_cr.c b/net/socket_cr.c
new file mode 100644
index 0000000..76759fe
--- /dev/null
+++ b/net/socket_cr.c
@@ -0,0 +1,378 @@
+/*
+ *  Copyright 2009 IBM Corporation
+ *
+ *  Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ */
+
+#include <linux/socket.h>
+#include <linux/mount.h>
+#include <linux/file.h>
+
+#include <net/af_unix.h>
+#include <net/tcp_states.h>
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+static int sock_copy_buffers(struct sk_buff_head *from, struct sk_buff_head *to)
+{
+	int count = 0;
+	struct sk_buff *skb;
+
+	spin_lock(&from->lock);
+
+	skb_queue_walk(from, skb) {
+		struct sk_buff *tmp;
+
+		tmp = skb_copy(skb, GFP_KERNEL);
+		if (!tmp) {
+			count = -ENOMEM;
+			goto out;
+		}
+		skb_queue_tail(to, tmp);
+		count++;
+	}
+ out:
+	spin_unlock(&from->lock);
+
+	return count;
+}
+
+static int __sock_write_buffers(struct ckpt_ctx *ctx,
+				struct sk_buff_head *queue)
+{
+	struct sk_buff *skb;
+	int ret = 0;
+
+	skb_queue_walk(queue, skb) {
+		ret = ckpt_write_obj_type(ctx, skb->data, skb->len,
+					  CKPT_HDR_SOCKET_BUFFER);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int sock_write_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
+{
+	struct ckpt_hdr_socket_buffer *h;
+	struct sk_buff_head tmpq;
+	int ret = -ENOMEM;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFERS);
+	if (!h)
+		goto out;
+
+	skb_queue_head_init(&tmpq);
+
+	h->skb_count = sock_copy_buffers(queue, &tmpq);
+	if (h->skb_count < 0) {
+		ret = h->skb_count;
+		goto out;
+	}
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (!ret)
+		ret = __sock_write_buffers(ctx, &tmpq);
+
+ out:
+	ckpt_hdr_put(ctx, h);
+	__skb_queue_purge(&tmpq);
+
+	return ret;
+}
+
+static int sock_un_checkpoint(struct ckpt_ctx *ctx,
+			      struct sock *sock,
+			      struct ckpt_hdr_socket *h)
+{
+	struct unix_sock *sk = unix_sk(sock);
+	struct unix_sock *pr = unix_sk(sk->peer);
+	int new;
+	int ret;
+
+	h->un.this = ckpt_obj_lookup_add(ctx, sk, CKPT_OBJ_SOCK, &new);
+	if (h->un.this < 0)
+		goto out;
+
+	if (sk->peer)
+		h->un.peer = ckpt_obj_lookup_add(ctx, pr, CKPT_OBJ_SOCK, &new);
+	else
+		h->un.peer = 0;
+
+	if (h->un.peer < 0) {
+		ret = h->un.peer;
+		goto out;
+	}
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+ out:
+	return ret;
+}
+
+static int sock_cptrst(struct ckpt_ctx *ctx,
+		       struct sock *sock,
+		       struct ckpt_hdr_socket *h,
+		       int op)
+{
+	if (sock->sk_socket) {
+		CKPT_COPY(op, h->socket_flags, sock->sk_socket->flags);
+		CKPT_COPY(op, h->socket_state, sock->sk_socket->state);
+	}
+
+	CKPT_COPY(op, h->reuse, sock->sk_reuse);
+	CKPT_COPY(op, h->shutdown, sock->sk_shutdown);
+	CKPT_COPY(op, h->userlocks, sock->sk_userlocks);
+	CKPT_COPY(op, h->no_check, sock->sk_no_check);
+	CKPT_COPY(op, h->protocol, sock->sk_protocol);
+	CKPT_COPY(op, h->err, sock->sk_err);
+	CKPT_COPY(op, h->err_soft, sock->sk_err_soft);
+	CKPT_COPY(op, h->priority, sock->sk_priority);
+	CKPT_COPY(op, h->rcvlowat, sock->sk_rcvlowat);
+	CKPT_COPY(op, h->backlog, sock->sk_max_ack_backlog);
+	CKPT_COPY(op, h->rcvtimeo, sock->sk_rcvtimeo);
+	CKPT_COPY(op, h->sndtimeo, sock->sk_sndtimeo);
+	CKPT_COPY(op, h->rcvbuf, sock->sk_rcvbuf);
+	CKPT_COPY(op, h->sndbuf, sock->sk_sndbuf);
+	CKPT_COPY(op, h->bound_dev_if, sock->sk_bound_dev_if);
+	CKPT_COPY(op, h->flags, sock->sk_flags);
+	CKPT_COPY(op, h->lingertime, sock->sk_lingertime);
+
+	return 0;
+}
+
+int __sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct socket *socket = file->private_data;
+	struct sock *sock = socket->sk;
+	struct ckpt_hdr_socket *h;
+	int ret = 0;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
+	if (!h)
+		return -ENOMEM;
+
+	h->family = sock->sk_family;
+	h->state = socket->state;
+	h->sock_state = sock->sk_state;
+	h->reuse = sock->sk_reuse;
+	h->type = sock->sk_type;
+	h->protocol = sock->sk_protocol;
+
+	h->laddr_len = sizeof(h->laddr);
+	h->raddr_len = sizeof(h->raddr);
+
+	if (socket->ops->getname(socket, &h->laddr, &h->laddr_len, 0)) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if ((h->sock_state != TCP_LISTEN) &&
+	    (h->type != SOCK_DGRAM) &&
+	    (socket->ops->getname(socket, &h->raddr, &h->raddr_len, 1))) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	sock_cptrst(ctx, sock, h, CKPT_CPT);
+
+	if (h->family == AF_UNIX) {
+		ret = sock_un_checkpoint(ctx, sock, h);
+		if (ret)
+			goto out;
+	} else {
+		ckpt_debug("unsupported socket type %i\n", h->family);
+		ret = EINVAL;
+		goto out;
+	}
+
+	ret = sock_write_buffers(ctx, &sock->sk_receive_queue);
+	if (ret)
+		goto out;
+
+	ret = sock_write_buffers(ctx, &sock->sk_write_queue);
+	if (ret)
+		goto out;
+
+	/* FIXME: write out-of-order queue for TCP */
+ out:
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+static int sock_read_buffer(struct ckpt_ctx *ctx,
+			    struct sock *sock,
+			    struct sk_buff **skb)
+{
+	struct ckpt_hdr *h;
+	int ret = 0;
+	int len;
+
+	h = ckpt_read_buf_type(ctx, SKB_MAX_ALLOC, CKPT_HDR_SOCKET_BUFFER);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	len = h->len - sizeof(*h);
+
+	*skb = sock_alloc_send_skb(sock, len, MSG_DONTWAIT, &ret);
+	if (*skb == NULL) {
+		ret = ENOMEM;
+		goto out;
+	}
+
+	memcpy(skb_put(*skb, len), (char *)(h + 1), len);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int sock_read_buffers(struct ckpt_ctx *ctx,
+			     struct sock *sock,
+			     struct sk_buff_head *queue)
+{
+	struct ckpt_hdr_socket_buffer *h;
+	int ret = 0;
+	int i;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFERS);
+	if (IS_ERR(h)) {
+		ret = PTR_ERR(h);
+		goto out;
+	}
+
+	for (i = 0; i < h->skb_count; i++) {
+		struct sk_buff *skb = NULL;
+
+		ret = sock_read_buffer(ctx, sock, &skb);
+		if (ret)
+			break;
+
+		skb_queue_tail(queue, skb);
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+static int sock_un_restart(struct ckpt_ctx *ctx,
+			   struct ckpt_hdr_socket *h,
+			   struct socket *socket)
+{
+	struct sock *peer;
+	int ret = 0;
+
+	if (h->sock_state == TCP_ESTABLISHED) {
+		peer = ckpt_obj_fetch(ctx, h->un.peer, CKPT_OBJ_SOCK);
+		if (peer && !IS_ERR(peer)) {
+			/* We're last, so join with peer */
+			struct sock *this = socket->sk;
+
+			sock_hold(this);
+			sock_hold(peer);
+
+			unix_sk(this)->peer = peer;
+			unix_sk(peer)->peer = this;
+
+			this->sk_peercred.pid = task_tgid_vnr(current);
+			current_euid_egid(&this->sk_peercred.uid,
+					  &this->sk_peercred.gid);
+
+			peer->sk_peercred.pid = task_tgid_vnr(current);
+			current_euid_egid(&peer->sk_peercred.uid,
+					  &peer->sk_peercred.gid);
+		} else {
+			/* We're first, so add our socket and wait for peer */
+			ckpt_obj_insert(ctx, socket->sk, h->un.this,
+					CKPT_OBJ_SOCK);
+		}
+
+	} else if (h->sock_state == TCP_LISTEN) {
+		ret = socket->ops->bind(socket,
+					(struct sockaddr *)&h->laddr,
+					h->laddr_len);
+		if (ret < 0)
+			goto out;
+
+		ret = socket->ops->listen(socket, h->backlog);
+		if (ret < 0)
+			goto out;
+	} else
+		ckpt_debug("unsupported UNIX socket state %i\n", h->state);
+
+	socket->state = h->state;
+	socket->sk->sk_state = h->sock_state;
+ out:
+	return ret;
+}
+
+struct socket *__sock_file_restore(struct ckpt_ctx *ctx,
+				   struct ckpt_hdr_socket *h)
+{
+	struct socket *socket;
+	int ret;
+
+	ret = sock_create(h->family, h->type, 0, &socket);
+	if (ret < 0)
+		return ERR_PTR(ret);
+
+	if (h->family == AF_UNIX) {
+		ret = sock_un_restart(ctx, h, socket);
+		ckpt_debug("sock_un_restart: %i\n", ret);
+	} else {
+		ckpt_debug("unsupported family %i\n", h->family);
+		ret = -EINVAL;
+	}
+
+	if (ret)
+		goto out;
+
+	ret = sock_read_buffers(ctx, socket->sk, &socket->sk->sk_receive_queue);
+	if (ret)
+		goto out;
+
+	ret = sock_read_buffers(ctx, socket->sk, &socket->sk->sk_write_queue);
+	if (ret)
+		goto out;
+ out:
+	if (ret) {
+		sock_release(socket);
+		socket = ERR_PTR(ret);
+	}
+
+	return socket;
+}
+
+int sock_file_checkpoint(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct ckpt_hdr_file_socket *h;
+	int ret;
+	struct file *file = ptr;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+
+	h->common.f_type = CKPT_FILE_SOCKET;
+
+	ret = checkpoint_file_common(ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	ret = __sock_file_checkpoint(ctx, file);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+
-- 
1.6.0.4
