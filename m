From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] c/r: Add AF_UNIX support (v3)
Date: Tue, 16 Jun 2009 08:55:16 -0700
Message-ID: <1245167716-28906-1-git-send-email-danms@us.ibm.com>
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
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
has been tested with a single and multiple processes, and with data inflight
at the time of checkpoint.  It supports socketpair()s, path-based, and
abstract sockets.

Changes in v3:
  - Move sock_file_checkpoint() above sock_file_restore()
  - Change __sock_file_*() functions to do_sock_file_*()
  - Adjust some of the struct cr_hdr_socket alignment
  - Improve the sock_copy_buffers() algorithm to avoid locking the source
    queue for the entire operation
  - Fix alignment in the socket header struct(s)
  - Move the per-protocol structure (ckpt_hdr_socket_un) out of the
    common socket header and read/write it separately
  - Fix missing call to sock_cptrst() in restore path
  - Break out the socket joining into another function
  - Fix failure to restore the socket address thus fixing getname()
  - Check the state values on restart
  - Fix case of state being TCP_CLOSE, which allows dgram sockets to be
    properly connected (if appropriate) to their peer and maintain the
    sockaddr for getname() operation
  - Fix restoring a listening socket that has been unlink()'d
  - Fix checkpointing sockets with an in-flight FD-passing SKB.  Fail
    with EBUSY.
  - Fix checkpointing listening sockets with an unaccepted connection.
    Fail with EBUSY.

Changes in v2:
  - Change GFP_KERNEL to GFP_ATOMIC in sock_copy_buffers() (this seems
    to be rather common in other uses of skb_copy())
  - Move the ckpt_hdr_socket structure definition to linux/socket.h
  - Fix whitespace issue
  - Move sock_file_checkpoint() to net/socket.c for symmetry

Cc: Oren Laaden <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c             |    7 +
 checkpoint/objhash.c           |   27 +++
 include/linux/checkpoint_hdr.h |   13 +
 include/linux/socket.h         |   59 +++++
 include/net/sock.h             |    9 +
 net/Makefile                   |    2 +
 net/checkpoint.c               |  493 ++++++++++++++++++++++++++++++++++++++++
 net/socket.c                   |   84 +++++++
 8 files changed, 694 insertions(+), 0 deletions(-)
 create mode 100644 net/checkpoint.c

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
index cd427d8..60870df 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -76,6 +76,12 @@ enum {
 	CKPT_HDR_IPC_MSG_MSG,
 	CKPT_HDR_IPC_SEM,
 
+ 	CKPT_HDR_FD_SOCKET = 601,
+ 	CKPT_HDR_SOCKET,
+ 	CKPT_HDR_SOCKET_BUFFERS,
+ 	CKPT_HDR_SOCKET_BUFFER,
+	CKPT_HDR_SOCKET_UN,
+
 	CKPT_HDR_TAIL = 9001,
 
 	CKPT_HDR_ERROR = 9999,
@@ -103,6 +109,7 @@ enum obj_type {
 	CKPT_OBJ_NS,
 	CKPT_OBJ_UTS_NS,
 	CKPT_OBJ_IPC_NS,
+	CKPT_OBJ_SOCK,
 	CKPT_OBJ_MAX
 };
 
@@ -225,6 +232,7 @@ enum file_type {
 	CKPT_FILE_IGNORE = 0,
 	CKPT_FILE_GENERIC,
 	CKPT_FILE_PIPE,
+	CKPT_FILE_SOCKET,
 	CKPT_FILE_MAX
 };
 
@@ -248,6 +256,11 @@ struct ckpt_hdr_file_pipe {
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
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 421afb4..3b5be70 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -23,6 +23,7 @@ struct __kernel_sockaddr_storage {
 #include <linux/uio.h>			/* iovec support		*/
 #include <linux/types.h>		/* pid_t			*/
 #include <linux/compiler.h>		/* __user			*/
+#include <linux/checkpoint_hdr.h>	/* ckpt_hdr			*/
 
 #ifdef __KERNEL__
 # ifdef CONFIG_PROC_FS
@@ -323,5 +324,63 @@ extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr *ka
 extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
 
 #endif
+
+struct ckpt_hdr_socket_un {
+	struct ckpt_hdr h;
+	__u32 this;
+	__u32 peer;
+	__u8 linked;
+} __attribute__ ((aligned(8)));
+
+struct ckpt_hdr_socket {
+	struct ckpt_hdr h;
+
+	struct ckpt_socket { /* struct socket */
+		__u64 flags;
+		__u8 state;
+	} socket __attribute__ ((aligned(8)));
+
+	struct ckpt_sock_common { /* struct sock_common */
+		__u32 bound_dev_if;
+		__u16 family;
+		__u8 state;
+		__u8 reuse;
+	} sock_common __attribute__ ((aligned(8)));
+
+	struct ckpt_sock { /* struct sock */
+		__u64 rcvlowat;
+		__u64 rcvtimeo;
+		__u64 sndtimeo;
+		__u64 flags;
+		__u64 lingertime;
+
+		__u32 err;
+		__u32 err_soft;
+		__u32 priority;
+		__s32 rcvbuf;
+		__s32 sndbuf;
+		__u16 type;
+		__u16 backlog;
+
+		__u8 protocol;
+		__u8 state;
+		__u8 shutdown;
+		__u8 userlocks;
+		__u8 no_check;
+	} sock __attribute__ ((aligned(8)));
+
+	/* common to all supported families */
+	__u32 laddr_len;
+	__u32 raddr_len;
+	struct sockaddr laddr;
+	struct sockaddr raddr;
+
+} __attribute__ ((aligned(8)));
+
+struct ckpt_hdr_socket_buffer {
+	struct ckpt_hdr h;
+	__u32 skb_count;
+} __attribute__ ((aligned(8)));
+
 #endif /* not kernel and not glibc */
 #endif /* _LINUX_SOCKET_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 4bb1ff9..a8b6af1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1482,4 +1482,13 @@ extern int sysctl_optmem_max;
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
 
+/* Checkpoint/Restart Functions */
+struct ckpt_ctx;
+struct ckpt_hdr_socket;
+extern int sock_file_checkpoint(struct ckpt_ctx *, void *);
+extern void *sock_file_restore(struct ckpt_ctx *);
+extern struct socket *do_sock_file_restore(struct ckpt_ctx *,
+					   struct ckpt_hdr_socket *);
+extern int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+
 #endif	/* _SOCK_H */
diff --git a/net/Makefile b/net/Makefile
index 9e00a55..c226ed1 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -65,3 +65,5 @@ ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
 endif
 obj-$(CONFIG_WIMAX)		+= wimax/
+
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
diff --git a/net/checkpoint.c b/net/checkpoint.c
new file mode 100644
index 0000000..fd47485
--- /dev/null
+++ b/net/checkpoint.c
@@ -0,0 +1,493 @@
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
+#include <linux/namei.h>
+
+/* Size of an empty struct sockaddr_un */
+#define UNIX_LEN_EMPTY 2
+
+static int sock_copy_buffers(struct sk_buff_head *from, struct sk_buff_head *to)
+{
+	int count = 0;
+	struct sk_buff *skb;
+
+	skb_queue_walk(from, skb) {
+		struct sk_buff *tmp;
+
+		tmp = dev_alloc_skb(skb->len);
+		if (!tmp)
+			return -ENOMEM;
+
+		spin_lock(&from->lock);
+		skb_morph(tmp, skb);
+		spin_unlock(&from->lock);
+
+		skb_queue_tail(to, tmp);
+		count++;
+	}
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
+		if (UNIXCB(skb).fp) {
+			ckpt_debug("unsupported fd-passing skb found\n");
+			return -EBUSY;
+		}
+
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
+	struct ckpt_hdr_socket_un *un;
+	int new;
+	int ret = -ENOMEM;
+
+	if ((sock->sk_state == TCP_LISTEN) &&
+	    !skb_queue_empty(&sock->sk_receive_queue)) {
+		ckpt_debug("listening socket has unaccepted peers");
+		return -EBUSY;
+	}
+
+	un = ckpt_hdr_get_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UN);
+	if (!un)
+		goto out;
+
+	un->linked = sk->dentry && (sk->dentry->d_inode->i_nlink > 0);
+
+	un->this = ckpt_obj_lookup_add(ctx, sk, CKPT_OBJ_SOCK, &new);
+	if (un->this < 0)
+		goto out;
+
+	if (sk->peer)
+		un->peer = ckpt_obj_lookup_add(ctx, pr, CKPT_OBJ_SOCK, &new);
+	else
+		un->peer = 0;
+
+	if (un->peer < 0) {
+		ret = un->peer;
+		goto out;
+	}
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) un);
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
+		CKPT_COPY(op, h->socket.flags, sock->sk_socket->flags);
+		CKPT_COPY(op, h->socket.state, sock->sk_socket->state);
+	}
+
+	CKPT_COPY(op, h->sock_common.reuse, sock->sk_reuse);
+	CKPT_COPY(op, h->sock_common.bound_dev_if, sock->sk_bound_dev_if);
+	CKPT_COPY(op, h->sock_common.family, sock->sk_family);
+
+	CKPT_COPY(op, h->sock.shutdown, sock->sk_shutdown);
+	CKPT_COPY(op, h->sock.userlocks, sock->sk_userlocks);
+	CKPT_COPY(op, h->sock.no_check, sock->sk_no_check);
+	CKPT_COPY(op, h->sock.protocol, sock->sk_protocol);
+	CKPT_COPY(op, h->sock.err, sock->sk_err);
+	CKPT_COPY(op, h->sock.err_soft, sock->sk_err_soft);
+	CKPT_COPY(op, h->sock.priority, sock->sk_priority);
+	CKPT_COPY(op, h->sock.rcvlowat, sock->sk_rcvlowat);
+	CKPT_COPY(op, h->sock.backlog, sock->sk_max_ack_backlog);
+	CKPT_COPY(op, h->sock.rcvtimeo, sock->sk_rcvtimeo);
+	CKPT_COPY(op, h->sock.sndtimeo, sock->sk_sndtimeo);
+	CKPT_COPY(op, h->sock.rcvbuf, sock->sk_rcvbuf);
+	CKPT_COPY(op, h->sock.sndbuf, sock->sk_sndbuf);
+	CKPT_COPY(op, h->sock.flags, sock->sk_flags);
+	CKPT_COPY(op, h->sock.lingertime, sock->sk_lingertime);
+	CKPT_COPY(op, h->sock.type, sock->sk_type);
+	CKPT_COPY(op, h->sock.state, sock->sk_state);
+
+	if ((h->socket.state == SS_CONNECTED) &&
+	    (h->sock.state != TCP_ESTABLISHED)) {
+		ckpt_debug("socket/sock in inconsistent state: %i/%i\n",
+			   h->socket.state, h->sock.state);
+		return -EINVAL;
+	} else if ((h->socket.state == SS_UNCONNECTED) &&
+		   (h->sock.state == TCP_ESTABLISHED)) {
+		ckpt_debug("socket/sock in inconsistent state: %i/%i\n",
+			   h->socket.state, h->sock.state);
+		return -EINVAL;
+	} else if ((h->sock.state < TCP_ESTABLISHED) ||
+		   (h->sock.state >= TCP_MAX_STATES)) {
+		ckpt_debug("sock in invalid state: %i\n", h->sock.state);
+		return -EINVAL;
+	} else if ((h->socket.state < SS_FREE) ||
+		   (h->socket.state > SS_DISCONNECTING)) {
+		ckpt_debug("socket in invalid state: %i\n", h->socket.state);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
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
+	h->laddr_len = sizeof(h->laddr);
+	h->raddr_len = sizeof(h->raddr);
+
+	if (socket->ops->getname(socket, &h->laddr, &h->laddr_len, 0)) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if ((sock->sk_state != TCP_LISTEN) &&
+	    (socket->ops->getname(socket, &h->raddr, &h->raddr_len, 1))) {
+		if (sock->sk_type != SOCK_DGRAM) {
+			ret = -EINVAL;
+			goto out;
+		}
+		h->raddr_len = 0;
+	}
+
+	sock_cptrst(ctx, sock, h, CKPT_CPT);
+
+	if (sock->sk_family == AF_UNIX) {
+		ret = sock_un_checkpoint(ctx, sock, h);
+		if (ret)
+			goto out;
+	} else {
+		ckpt_debug("unsupported socket type %i\n",
+			   sock->sk_family);
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
+static struct unix_address *sock_un_makeaddr(struct sockaddr_un *sun_addr,
+					     unsigned len)
+{
+	struct unix_address *addr;
+
+	addr = kmalloc(sizeof(*addr) + len, GFP_KERNEL);
+	if (!addr)
+		return ERR_PTR(ENOMEM);
+
+	memcpy(addr->name, sun_addr, len);
+	addr->len = len;
+	atomic_set(&addr->refcnt, 1);
+
+	return addr;
+}
+
+static int sock_un_join(struct sock *a,
+			struct sock *b,
+			struct ckpt_hdr_socket *h)
+{
+	struct unix_address *addr;
+
+	sock_hold(a);
+	sock_hold(b);
+
+	unix_sk(a)->peer = b;
+	unix_sk(b)->peer = a;
+
+	a->sk_peercred.pid = task_tgid_vnr(current);
+	current_euid_egid(&a->sk_peercred.uid,
+			  &a->sk_peercred.gid);
+
+	b->sk_peercred.pid = task_tgid_vnr(current);
+	current_euid_egid(&b->sk_peercred.uid,
+			  &b->sk_peercred.gid);
+
+	if (h->laddr_len == UNIX_LEN_EMPTY)
+		addr = sock_un_makeaddr((struct sockaddr_un *)&h->raddr,
+					h->raddr_len);
+	else
+		addr = sock_un_makeaddr((struct sockaddr_un *)&h->laddr,
+					h->laddr_len);
+	if (IS_ERR(addr))
+	    return PTR_ERR(addr);
+
+	atomic_inc(&addr->refcnt); /* Held by both ends */
+	unix_sk(a)->addr = unix_sk(b)->addr = addr;
+
+	return 0;
+}
+
+static int sock_un_unlink(const char *name)
+{
+	struct path spath;
+	struct path ppath;
+	int ret;
+
+	ret = kern_path(name, 0, &spath);
+	if (ret)
+		return ret;
+
+	ret = kern_path(name, LOOKUP_PARENT, &ppath);
+	if (ret)
+		goto out_s;
+
+	if (!spath.dentry) {
+		ckpt_debug("No dentry found for %s\n", name);
+		ret = -ENOENT;
+		goto out_p;
+	}
+
+	if (!ppath.dentry || !ppath.dentry->d_inode) {
+		ckpt_debug("No inode for parent of %s\n", name);
+		ret = -ENOENT;
+		goto out_p;
+	}
+
+	ret = vfs_unlink(ppath.dentry->d_inode, spath.dentry);
+ out_p:
+	path_put(&ppath);
+ out_s:
+	path_put(&spath);
+
+	return ret;
+}
+
+static int sock_un_restart(struct ckpt_ctx *ctx,
+			   struct ckpt_hdr_socket *h,
+			   struct socket *socket)
+{
+	struct sock *peer;
+	struct ckpt_hdr_socket_un *un;
+	int ret = 0;
+
+	un = ckpt_read_obj_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UN);
+	if (IS_ERR(un))
+		return PTR_ERR(un);
+
+	if (un->peer < 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	peer = ckpt_obj_fetch(ctx, un->peer, CKPT_OBJ_SOCK);
+
+	if ((h->sock.state == TCP_ESTABLISHED) ||
+	    (h->sock.state == TCP_CLOSE)) {
+		if (!IS_ERR(peer)) {
+			/* We're last, so join with peer */
+			struct sock *this = socket->sk;
+
+			ret = sock_un_join(this, peer, h);
+		} else {
+			/* We're first, so add our socket and wait for peer */
+			ckpt_obj_insert(ctx, socket->sk, un->this,
+					CKPT_OBJ_SOCK);
+		}
+
+	} else if (h->sock.state == TCP_LISTEN) {
+		ret = socket->ops->bind(socket,
+					(struct sockaddr *)&h->laddr,
+					h->laddr_len);
+		if (ret < 0)
+			goto out;
+
+		ret = socket->ops->listen(socket, h->sock.backlog);
+		if (ret < 0)
+			goto out;
+
+		/* We can unlink this blindly because we just created it
+		 * above and would have failed already without proper
+		 * permissions
+		 */
+		if (!un->linked) {
+			struct sockaddr_un *sun =
+				(struct sockaddr_un *)&h->laddr;
+			ret = sock_un_unlink(sun->sun_path);
+		}
+	} else
+		ckpt_debug("unsupported UNIX socket state %i\n", h->sock.state);
+ out:
+	ckpt_hdr_put(ctx, un);
+	return ret;
+}
+
+struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
+				    struct ckpt_hdr_socket *h)
+{
+	struct socket *socket;
+	int ret;
+
+	ret = sock_create(h->sock_common.family, h->sock.type, 0, &socket);
+	if (ret < 0)
+		return ERR_PTR(ret);
+
+	if (h->sock_common.family == AF_UNIX) {
+		ret = sock_un_restart(ctx, h, socket);
+		ckpt_debug("sock_un_restart: %i\n", ret);
+	} else {
+		ckpt_debug("unsupported family %i\n", h->sock_common.family);
+		ret = -EINVAL;
+	}
+
+	if (ret)
+		goto out;
+
+	sock_cptrst(ctx, socket->sk, h, CKPT_RST);
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
diff --git a/net/socket.c b/net/socket.c
index 791d71a..be8c562 100644
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
@@ -415,6 +421,84 @@ int sock_map_fd(struct socket *sock, int flags)
 	return fd;
 }
 
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
+	ret = do_sock_file_checkpoint(ctx, file);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
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
+	socket = do_sock_file_restore(ctx, h);
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
+
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
-- 
1.6.0.4
