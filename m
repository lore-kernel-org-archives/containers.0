From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 3/3] c/r: cleanup - follow naming conventions
Date: Mon, 17 Aug 2009 16:12:11 -0400
Message-ID: <1250539931-12951-4-git-send-email-orenl@librato.com>
References: <1250539931-12951-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1250539931-12951-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

More cleanup of the sockets c/r code. Now that we use the methods from
struct proto_ops (checkpoint,restore), we no longer need the prefix
"sock_unix_..." for function names in net/unix/checkpoint.c; Instead
we follow the convention (e.g. in net/unix/afunix.c) "unix_...".

Speaking about code conventions, it is also customary to use 'sock'
for a struct socket, and a 'sk' for struct sock. This patch also makes
changes accordingly where necessary.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/net/af_unix.h |    6 +-
 net/checkpoint.c      |   91 +++++++++++++++-----------------
 net/unix/af_unix.c    |   12 ++--
 net/unix/checkpoint.c |  139 +++++++++++++++++++++++--------------------------
 4 files changed, 119 insertions(+), 129 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index e265e9e..eba9142 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -72,9 +72,9 @@ static inline void unix_sysctl_unregister(struct net *net) {}
 #ifdef CONFIG_CHECKPOINT
 struct ckpt_ctx;
 struct ckpt_hdr_socket;
-extern int sock_unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock);
-extern int sock_unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
-			     struct ckpt_hdr_socket *h);
+extern int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock);
+extern int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
+			struct ckpt_hdr_socket *h);
 #endif /* CONFIG_CHECKPOINT */
 
 #endif
diff --git a/net/checkpoint.c b/net/checkpoint.c
index 9f92d7a..12ca1e6 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -1,7 +1,8 @@
 /*
  *  Copyright 2009 IBM Corporation
  *
- *  Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
+ *  Authors: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
+ *  	     Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
  *
  *  This program is free software; you can redistribute it and/or
  *  modify it under the terms of the GNU General Public License as
@@ -140,25 +141,23 @@ static int sock_write_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
 	return ret;
 }
 
-int ckpt_sock_getnames(struct ckpt_ctx *ctx,
-		       struct socket *socket,
+int ckpt_sock_getnames(struct ckpt_ctx *ctx, struct socket *sock,
 		       struct sockaddr *loc, unsigned *loc_len,
 		       struct sockaddr *rem, unsigned *rem_len)
 {
 	int ret;
 
-	ret = sock_getname(socket, loc, loc_len);
+	ret = sock_getname(sock, loc, loc_len);
 	if (ret) {
 		ckpt_write_err(ctx, "Unable to getname of local: %i", ret);
 		return -EINVAL;
 	}
 
-	ret = sock_getpeer(socket, rem, rem_len);
+	ret = sock_getpeer(sock, rem, rem_len);
 	if (ret) {
-		if ((socket->sk->sk_type != SOCK_DGRAM) &&
-		    (socket->sk->sk_state == TCP_ESTABLISHED)) {
-			ckpt_write_err(ctx, "Unable to getname of remote: %i",
-				       ret);
+		if ((sock->sk->sk_type != SOCK_DGRAM) &&
+		    (sock->sk->sk_state == TCP_ESTABLISHED)) {
+			ckpt_write_err(ctx, "socket get peer name: %i", ret);
 			return -EINVAL;
 		}
 		*rem_len = 0;
@@ -186,7 +185,7 @@ static int sock_cptrst_verify(struct ckpt_hdr_socket *h)
 	return 0;
 }
 
-static int sock_cptrst_opt(int op, struct socket *socket,
+static int sock_cptrst_opt(int op, struct socket *sock,
 			   int optname, char *opt, int len)
 {
 	mm_segment_t fs;
@@ -196,32 +195,32 @@ static int sock_cptrst_opt(int op, struct socket *socket,
 	set_fs(KERNEL_DS);
 
 	if (op == CKPT_CPT)
-		ret = sock_getsockopt(socket, SOL_SOCKET, optname, opt, &len);
+		ret = sock_getsockopt(sock, SOL_SOCKET, optname, opt, &len);
 	else
-		ret = sock_setsockopt(socket, SOL_SOCKET, optname, opt, len);
+		ret = sock_setsockopt(sock, SOL_SOCKET, optname, opt, len);
 
 	set_fs(fs);
 
 	return ret;
 }
 
-#define CKPT_COPY_SOPT(op, sock, name, opt) \
-	sock_cptrst_opt(op, sock->sk_socket, name, (char *)opt, sizeof(*opt))
+#define CKPT_COPY_SOPT(op, sk, name, opt) \
+	sock_cptrst_opt(op, sk->sk_socket, name, (char *)opt, sizeof(*opt))
 
-static int sock_cptrst_bufopts(int op, struct sock *sock,
+static int sock_cptrst_bufopts(int op, struct sock *sk,
 			       struct ckpt_hdr_socket *h)
 
 {
-	if (CKPT_COPY_SOPT(op, sock, SO_RCVBUF, &h->sock.rcvbuf))
+	if (CKPT_COPY_SOPT(op, sk, SO_RCVBUF, &h->sock.rcvbuf))
 		if ((op == CKPT_RST) &&
-		    CKPT_COPY_SOPT(op, sock, SO_RCVBUFFORCE, &h->sock.rcvbuf)) {
+		    CKPT_COPY_SOPT(op, sk, SO_RCVBUFFORCE, &h->sock.rcvbuf)) {
 			ckpt_debug("Failed to set SO_RCVBUF");
 			return -EINVAL;
 		}
 
-	if (CKPT_COPY_SOPT(op, sock, SO_SNDBUF, &h->sock.sndbuf))
+	if (CKPT_COPY_SOPT(op, sk, SO_SNDBUF, &h->sock.sndbuf))
 		if ((op == CKPT_RST) &&
-		    CKPT_COPY_SOPT(op, sock, SO_SNDBUFFORCE, &h->sock.sndbuf)) {
+		    CKPT_COPY_SOPT(op, sk, SO_SNDBUFFORCE, &h->sock.sndbuf)) {
 			ckpt_debug("Failed to set SO_SNDBUF");
 			return -EINVAL;
 		}
@@ -239,64 +238,62 @@ static int sock_cptrst_bufopts(int op, struct sock *sock,
 	return 0;
 }
 
-static int sock_cptrst(struct ckpt_ctx *ctx,
-		       struct sock *sock,
-		       struct ckpt_hdr_socket *h,
-		       int op)
+static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
+		       struct ckpt_hdr_socket *h, int op)
 {
-	if (sock->sk_socket) {
-		CKPT_COPY(op, h->socket.flags, sock->sk_socket->flags);
-		CKPT_COPY(op, h->socket.state, sock->sk_socket->state);
+	if (sk->sk_socket) {
+		CKPT_COPY(op, h->socket.flags, sk->sk_socket->flags);
+		CKPT_COPY(op, h->socket.state, sk->sk_socket->state);
 	}
 
-	CKPT_COPY(op, h->sock_common.bound_dev_if, sock->sk_bound_dev_if);
-	CKPT_COPY(op, h->sock_common.family, sock->sk_family);
+	CKPT_COPY(op, h->sock_common.bound_dev_if, sk->sk_bound_dev_if);
+	CKPT_COPY(op, h->sock_common.family, sk->sk_family);
 
-	CKPT_COPY(op, h->sock.shutdown, sock->sk_shutdown);
-	CKPT_COPY(op, h->sock.userlocks, sock->sk_userlocks);
-	CKPT_COPY(op, h->sock.no_check, sock->sk_no_check);
-	CKPT_COPY(op, h->sock.protocol, sock->sk_protocol);
-	CKPT_COPY(op, h->sock.err, sock->sk_err);
-	CKPT_COPY(op, h->sock.err_soft, sock->sk_err_soft);
-	CKPT_COPY(op, h->sock.type, sock->sk_type);
-	CKPT_COPY(op, h->sock.state, sock->sk_state);
-	CKPT_COPY(op, h->sock.backlog, sock->sk_max_ack_backlog);
+	CKPT_COPY(op, h->sock.shutdown, sk->sk_shutdown);
+	CKPT_COPY(op, h->sock.userlocks, sk->sk_userlocks);
+	CKPT_COPY(op, h->sock.no_check, sk->sk_no_check);
+	CKPT_COPY(op, h->sock.protocol, sk->sk_protocol);
+	CKPT_COPY(op, h->sock.err, sk->sk_err);
+	CKPT_COPY(op, h->sock.err_soft, sk->sk_err_soft);
+	CKPT_COPY(op, h->sock.type, sk->sk_type);
+	CKPT_COPY(op, h->sock.state, sk->sk_state);
+	CKPT_COPY(op, h->sock.backlog, sk->sk_max_ack_backlog);
 
 	/* TODO:
 	 * Break out setting each of the flags to use setsockopt() or
 	 * perform proper security check
 	 */
-	CKPT_COPY(op, h->sock.flags, sock->sk_flags);
+	CKPT_COPY(op, h->sock.flags, sk->sk_flags);
 
-	if (sock_cptrst_bufopts(op, sock, h))
+	if (sock_cptrst_bufopts(op, sk, h))
 		return -EINVAL;
 
-	if (CKPT_COPY_SOPT(op, sock, SO_REUSEADDR, &h->sock_common.reuse)) {
+	if (CKPT_COPY_SOPT(op, sk, SO_REUSEADDR, &h->sock_common.reuse)) {
 		ckpt_debug("Failed to set SO_REUSEADDR");
 		return -EINVAL;
 	}
 
-	if (CKPT_COPY_SOPT(op, sock, SO_PRIORITY, &h->sock.priority)) {
+	if (CKPT_COPY_SOPT(op, sk, SO_PRIORITY, &h->sock.priority)) {
 		ckpt_debug("Failed to set SO_PRIORITY");
 		return -EINVAL;
 	}
 
-	if (CKPT_COPY_SOPT(op, sock, SO_RCVLOWAT, &h->sock.rcvlowat)) {
+	if (CKPT_COPY_SOPT(op, sk, SO_RCVLOWAT, &h->sock.rcvlowat)) {
 		ckpt_debug("Failed to set SO_RCVLOWAT");
 		return -EINVAL;
 	}
 
-	if (CKPT_COPY_SOPT(op, sock, SO_LINGER, &h->sock.linger)) {
+	if (CKPT_COPY_SOPT(op, sk, SO_LINGER, &h->sock.linger)) {
 		ckpt_debug("Failed to set SO_LINGER");
 		return -EINVAL;
 	}
 
-	if (CKPT_COPY_SOPT(op, sock, SO_SNDTIMEO, &h->sock.sndtimeo)) {
+	if (CKPT_COPY_SOPT(op, sk, SO_SNDTIMEO, &h->sock.sndtimeo)) {
 		ckpt_debug("Failed to set SO_SNDTIMEO");
 		return -EINVAL;
 	}
 
-	if (CKPT_COPY_SOPT(op, sock, SO_RCVTIMEO, &h->sock.rcvtimeo)) {
+	if (CKPT_COPY_SOPT(op, sk, SO_RCVTIMEO, &h->sock.rcvtimeo)) {
 		ckpt_debug("Failed to set SO_RCVTIMEO");
 		return -EINVAL;
 	}
@@ -405,7 +402,7 @@ struct ckpt_hdr_socket_queue *ckpt_sock_read_buffer_hdr(struct ckpt_ctx *ctx,
 		return h;
 }
 
-static struct file *sock_alloc_attach_fd(struct socket *socket)
+static struct file *sock_alloc_attach_fd(struct socket *sock)
 {
 	struct file *file;
 	int err;
@@ -414,7 +411,7 @@ static struct file *sock_alloc_attach_fd(struct socket *socket)
 	if (!file)
 		return ERR_PTR(ENOMEM);
 
-	err = sock_attach_fd(socket, file, 0);
+	err = sock_attach_fd(sock, file, 0);
 	if (err < 0) {
 		put_filp(file);
 		file = ERR_PTR(err);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 667397d..da6405d 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -523,8 +523,8 @@ static const struct proto_ops unix_stream_ops = {
 	.recvmsg =	unix_stream_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
-	.checkpoint =	sock_unix_checkpoint,
-	.restore =	sock_unix_restore,
+	.checkpoint =	unix_checkpoint,
+	.restore =	unix_restore,
 };
 
 static const struct proto_ops unix_dgram_ops = {
@@ -546,8 +546,8 @@ static const struct proto_ops unix_dgram_ops = {
 	.recvmsg =	unix_dgram_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
-	.checkpoint =	sock_unix_checkpoint,
-	.restore =	sock_unix_restore,
+	.checkpoint =	unix_checkpoint,
+	.restore =	unix_restore,
 };
 
 static const struct proto_ops unix_seqpacket_ops = {
@@ -569,8 +569,8 @@ static const struct proto_ops unix_seqpacket_ops = {
 	.recvmsg =	unix_dgram_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
-	.checkpoint =	sock_unix_checkpoint,
-	.restore =	sock_unix_restore,
+	.checkpoint =	unix_checkpoint,
+	.restore =	unix_restore,
 };
 
 static struct proto unix_proto = {
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
index d2431a4..772ab5f 100644
--- a/net/unix/checkpoint.c
+++ b/net/unix/checkpoint.c
@@ -8,17 +8,15 @@
 
 #define UNIX_ADDR_EMPTY(a) (a <= sizeof(short))
 
-static inline int sock_unix_need_cwd(struct sockaddr_un *addr,
-				     unsigned long len)
+static inline int unix_need_cwd(struct sockaddr_un *addr, unsigned long len)
 {
 	return (!UNIX_ADDR_EMPTY(len)) &&
 		addr->sun_path[0] &&
 		(addr->sun_path[0] != '/');
 }
 
-static int sock_unix_write_cwd(struct ckpt_ctx *ctx,
-			       struct sock *sock,
-			       const char *sockpath)
+static int unix_write_cwd(struct ckpt_ctx *ctx,
+			  struct sock *sk, const char *sockpath)
 {
 	struct path path;
 	char *buf;
@@ -31,8 +29,8 @@ static int sock_unix_write_cwd(struct ckpt_ctx *ctx,
 	if (!buf)
 		return -ENOMEM;
 
-	path.dentry = unix_sk(sock)->dentry;
-	path.mnt = unix_sk(sock)->mnt;
+	path.dentry = unix_sk(sk)->dentry;
+	path.mnt = unix_sk(sk)->mnt;
 
 	fqpath = ckpt_fill_fname(&path, &ctx->fs_mnt, buf, &len);
 	if (IS_ERR(fqpath)) {
@@ -55,16 +53,16 @@ static int sock_unix_write_cwd(struct ckpt_ctx *ctx,
 	return ret;
 }
 
-int sock_unix_checkpoint(struct ckpt_ctx *ctx, struct socket *socket)
+int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
 {
-	struct unix_sock *sk = unix_sk(socket->sk);
+	struct unix_sock *sk = unix_sk(sock->sk);
 	struct unix_sock *pr = unix_sk(sk->peer);
 	struct ckpt_hdr_socket_unix *un;
 	int new;
 	int ret = -ENOMEM;
 
-	if ((socket->sk->sk_state == TCP_LISTEN) &&
-	    !skb_queue_empty(&socket->sk->sk_receive_queue)) {
+	if ((sock->sk->sk_state == TCP_LISTEN) &&
+	    !skb_queue_empty(&sock->sk->sk_receive_queue)) {
 		ckpt_write_err(ctx, "listening socket has unaccepted peers");
 		return -EBUSY;
 	}
@@ -73,7 +71,7 @@ int sock_unix_checkpoint(struct ckpt_ctx *ctx, struct socket *socket)
 	if (!un)
 		return -EINVAL;
 
-	ret = ckpt_sock_getnames(ctx, socket,
+	ret = ckpt_sock_getnames(ctx, sock,
 				 (struct sockaddr *)&un->laddr, &un->laddr_len,
 				 (struct sockaddr *)&un->raddr, &un->raddr_len);
 	if (ret)
@@ -100,15 +98,15 @@ int sock_unix_checkpoint(struct ckpt_ctx *ctx, struct socket *socket)
 	if (ret < 0)
 		goto out;
 
-	if (sock_unix_need_cwd(&un->laddr, un->laddr_len))
-		ret = sock_unix_write_cwd(ctx, socket->sk, un->laddr.sun_path);
+	if (unix_need_cwd(&un->laddr, un->laddr_len))
+		ret = unix_write_cwd(ctx, sock->sk, un->laddr.sun_path);
  out:
 	ckpt_hdr_put(ctx, un);
 
 	return ret;
 }
 
-static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sock)
+static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sk)
 {
 	struct msghdr msg;
 	struct kvec kvec;
@@ -138,7 +136,7 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sock)
 	if (ret < 0)
 		goto out;
 
-	ret = kernel_sendmsg(sock->sk_socket, &msg, &kvec, 1, len);
+	ret = kernel_sendmsg(sk->sk_socket, &msg, &kvec, 1, len);
 	ckpt_debug("kernel_sendmsg(%i): %i\n", len, ret);
 	if ((ret > 0) && (ret != len))
 		ret = -ENOMEM;
@@ -148,9 +146,8 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sock)
 	return ret;
 }
 
-static int sock_unix_read_buffers(struct ckpt_ctx *ctx,
-				  struct sock *sock,
-				  uint32_t *bufsize)
+static int unix_read_buffers(struct ckpt_ctx *ctx,
+			     struct sock *sk, uint32_t *bufsize)
 {
 	uint8_t sock_shutdown;
 	struct ckpt_hdr_socket_queue *h;
@@ -162,11 +159,11 @@ static int sock_unix_read_buffers(struct ckpt_ctx *ctx,
 		return PTR_ERR(h);
 
 	/* If peer is shutdown, unshutdown it for this process */
-	sock_shutdown = sock->sk_shutdown;
-	sock->sk_shutdown &= ~SHUTDOWN_MASK;
+	sock_shutdown = sk->sk_shutdown;
+	sk->sk_shutdown &= ~SHUTDOWN_MASK;
 
 	for (i = 0; i < h->skb_count; i++) {
-		ret = sock_read_buffer_sendmsg(ctx, sock);
+		ret = sock_read_buffer_sendmsg(ctx, sk);
 		ckpt_debug("read_buffer_sendmsg(%i): %i\n", i, ret);
 		if (ret < 0)
 			break;
@@ -181,14 +178,14 @@ static int sock_unix_read_buffers(struct ckpt_ctx *ctx,
 		ret = 0;
 	}
 
-	sock->sk_shutdown = sock_shutdown;
+	sk->sk_shutdown = sock_shutdown;
 	ckpt_hdr_put(ctx, h);
 
 	return ret;
 }
 
-static struct unix_address *sock_unix_makeaddr(struct sockaddr_un *sun_addr,
-					       unsigned len)
+static struct unix_address *unix_makeaddr(struct sockaddr_un *sun_addr,
+					  unsigned len)
 {
 	struct unix_address *addr;
 
@@ -206,10 +203,9 @@ static struct unix_address *sock_unix_makeaddr(struct sockaddr_un *sun_addr,
 	return addr;
 }
 
-static int sock_unix_join(struct ckpt_ctx *ctx,
-			  struct sock *a,
-			  struct sock *b,
-			  struct ckpt_hdr_socket_unix *un)
+static int unix_join(struct ckpt_ctx *ctx,
+		     struct sock *a, struct sock *b,
+		     struct ckpt_hdr_socket_unix *un)
 {
 	struct unix_address *addr = NULL;
 
@@ -235,9 +231,9 @@ static int sock_unix_join(struct ckpt_ctx *ctx,
 	b->sk_peercred.gid = a->sk_peercred.gid;
 
 	if (!UNIX_ADDR_EMPTY(un->raddr_len))
-		addr = sock_unix_makeaddr(&un->raddr, un->raddr_len);
+		addr = unix_makeaddr(&un->raddr, un->raddr_len);
 	else if (!UNIX_ADDR_EMPTY(un->laddr_len))
-		addr = sock_unix_makeaddr(&un->laddr, un->laddr_len);
+		addr = unix_makeaddr(&un->laddr, un->laddr_len);
 
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
@@ -249,10 +245,10 @@ static int sock_unix_join(struct ckpt_ctx *ctx,
 	return 0;
 }
 
-static int sock_unix_restore_connected(struct ckpt_ctx *ctx,
-				       struct ckpt_hdr_socket *h,
-				       struct ckpt_hdr_socket_unix *un,
-				       struct socket *socket)
+static int unix_restore_connected(struct ckpt_ctx *ctx,
+				  struct ckpt_hdr_socket *h,
+				  struct ckpt_hdr_socket_unix *un,
+				  struct socket *sock)
 {
 	struct sock *this = ckpt_obj_fetch(ctx, un->this, CKPT_OBJ_SOCK);
 	struct sock *peer = ckpt_obj_fetch(ctx, un->peer, CKPT_OBJ_SOCK);
@@ -265,19 +261,19 @@ static int sock_unix_restore_connected(struct ckpt_ctx *ctx,
 
 		old->sk = NULL;
 		sock_release(old);
-		sock_graft(this, socket);
+		sock_graft(this, sock);
 
 	} else if ((PTR_ERR(this) == -EINVAL) && (PTR_ERR(peer) == -EINVAL)) {
 		/* We're first */
-		int family = socket->sk->sk_family;
-		int type = socket->sk->sk_type;
+		int family = sock->sk->sk_family;
+		int type = sock->sk->sk_type;
 
 		ret = sock_create(family, type, 0, &tmp);
 		ckpt_debug("sock_create: %i\n", ret);
 		if (ret)
 			goto out;
 
-		this = socket->sk;
+		this = sock->sk;
 		peer = tmp->sk;
 
 		ret = ckpt_obj_insert(ctx, this, un->this, CKPT_OBJ_SOCK);
@@ -288,8 +284,8 @@ static int sock_unix_restore_connected(struct ckpt_ctx *ctx,
 		if (ret < 0)
 			goto out;
 
-		ret = sock_unix_join(ctx, this, peer, un);
-		ckpt_debug("sock_unix_join: %i\n", ret);
+		ret = unix_join(ctx, this, peer, un);
+		ckpt_debug("unix_join: %i\n", ret);
 		if (ret)
 			goto out;
 
@@ -312,13 +308,13 @@ static int sock_unix_restore_connected(struct ckpt_ctx *ctx,
 	 *       where sendto() has been used on some of the buffers
 	 */
 
-	ret = sock_unix_read_buffers(ctx, peer, &peer->sk_sndbuf);
-	ckpt_debug("sock_unix_read_buffers: %i\n", ret);
+	ret = unix_read_buffers(ctx, peer, &peer->sk_sndbuf);
+	ckpt_debug("unix_read_buffers: %i\n", ret);
 	if (ret)
 		goto out;
 
 	/* Read peer's buffers and expect 0 */
-	ret = sock_unix_read_buffers(ctx, peer, NULL);
+	ret = unix_read_buffers(ctx, peer, NULL);
  out:
 	if (tmp && ret)
 		sock_release(tmp);
@@ -326,7 +322,7 @@ static int sock_unix_restore_connected(struct ckpt_ctx *ctx,
 	return ret;
 }
 
-static int sock_unix_unlink(const char *name)
+static int unix_unlink(const char *name)
 {
 	struct path spath;
 	struct path ppath;
@@ -364,10 +360,10 @@ static int sock_unix_unlink(const char *name)
 /* Call bind() for socket, optionally changing (temporarily) to @path first
  * if non-NULL
  */
-static int sock_unix_chdir_and_bind(struct socket *socket,
-				    const char *path,
-				    struct sockaddr *addr,
-				    unsigned long addrlen)
+static int unix_chdir_and_bind(struct socket *sock,
+			       const char *path,
+			       struct sockaddr *addr,
+			       unsigned long addrlen)
 {
 	struct sockaddr_un *un = (struct sockaddr_un *)addr;
 	int ret;
@@ -392,10 +388,10 @@ static int sock_unix_chdir_and_bind(struct socket *socket,
 		write_unlock(&current->fs->lock);
 	}
 
-	ret = sock_unix_unlink(un->sun_path);
+	ret = unix_unlink(un->sun_path);
 	ckpt_debug("unlink(%s): %i\n", un->sun_path, ret);
 	if ((ret == 0) || (ret == -ENOENT))
-		ret = sock_bind(socket, addr, addrlen);
+		ret = sock_bind(sock, addr, addrlen);
 
 	if (path) {
 		write_lock(&current->fs->lock);
@@ -409,42 +405,40 @@ static int sock_unix_chdir_and_bind(struct socket *socket,
 	return ret;
 }
 
-static int sock_unix_fakebind(struct socket *socket,
-			      struct sockaddr_un *addr,
-			      unsigned long len)
+static int unix_fakebind(struct socket *sock,
+			 struct sockaddr_un *addr, unsigned long len)
 {
 	struct unix_address *uaddr;
 
-	uaddr = sock_unix_makeaddr(addr, len);
+	uaddr = unix_makeaddr(addr, len);
 	if (IS_ERR(uaddr))
 		return PTR_ERR(uaddr);
 
-	unix_sk(socket->sk)->addr = uaddr;
+	unix_sk(sock->sk)->addr = uaddr;
 
 	return 0;
 }
 
-static int sock_unix_bind(struct ckpt_hdr_socket *h,
-			  struct ckpt_hdr_socket_unix *un,
-			  struct socket *socket,
-			  const char *path)
+static int unix_restore_bind(struct ckpt_hdr_socket *h,
+			     struct ckpt_hdr_socket_unix *un,
+			     struct socket *sock,
+			     const char *path)
 {
 	struct sockaddr *addr = (struct sockaddr *)&un->laddr;
 	unsigned long len = un->laddr_len;
 
 	if (!un->laddr.sun_path[0])
-		return sock_bind(socket, addr, len);
+		return sock_bind(sock, addr, len);
 	else if (!(un->flags & CKPT_UNIX_LINKED))
-		return sock_unix_fakebind(socket, &un->laddr, len);
+		return unix_fakebind(sock, &un->laddr, len);
 	else
-		return sock_unix_chdir_and_bind(socket, path, addr, len);
+		return unix_chdir_and_bind(sock, path, addr, len);
 }
 
 /* Some easy pre-flight checks before we get underway */
-static int sock_unix_precheck(struct socket *socket,
-			      struct ckpt_hdr_socket *h)
+static int unix_precheck(struct socket *sock, struct ckpt_hdr_socket *h)
 {
-	struct net *net = sock_net(socket->sk);
+	struct net *net = sock_net(sock->sk);
 
 	if ((h->socket.state == SS_CONNECTING) ||
 	    (h->socket.state == SS_DISCONNECTING) ||
@@ -472,7 +466,7 @@ static int sock_unix_precheck(struct socket *socket,
 	return 0;
 }
 
-int sock_unix_restore(struct ckpt_ctx *ctx, struct socket *socket,
+int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
 		      struct ckpt_hdr_socket *h)
 
 {
@@ -480,7 +474,7 @@ int sock_unix_restore(struct ckpt_ctx *ctx, struct socket *socket,
 	int ret = -EINVAL;
 	char *cwd = NULL;
 
-	ret = sock_unix_precheck(socket, h);
+	ret = unix_precheck(sock, h);
 	if (ret)
 		return ret;
 
@@ -491,7 +485,7 @@ int sock_unix_restore(struct ckpt_ctx *ctx, struct socket *socket,
 	if (un->peer < 0)
 		goto out;
 
-	if (sock_unix_need_cwd(&un->laddr, un->laddr_len)) {
+	if (unix_need_cwd(&un->laddr, un->laddr_len)) {
 		cwd = ckpt_read_string(ctx, PATH_MAX);
 		if (IS_ERR(cwd)) {
 			ret = PTR_ERR(cwd);
@@ -501,15 +495,15 @@ int sock_unix_restore(struct ckpt_ctx *ctx, struct socket *socket,
 
 	if ((h->sock.state != TCP_ESTABLISHED) &&
 	    !UNIX_ADDR_EMPTY(un->laddr_len)) {
-		ret = sock_unix_bind(h, un, socket, cwd);
+		ret = unix_restore_bind(h, un, sock, cwd);
 		if (ret)
 			goto out;
 	}
 
 	if ((h->sock.state == TCP_ESTABLISHED) || (h->sock.state == TCP_CLOSE))
-		ret = sock_unix_restore_connected(ctx, h, un, socket);
+		ret = unix_restore_connected(ctx, h, un, sock);
 	else if (h->sock.state == TCP_LISTEN)
-		ret = socket->ops->listen(socket, h->sock.backlog);
+		ret = sock->ops->listen(sock, h->sock.backlog);
 	else
 		ckpt_debug("unsupported UNIX socket state %i\n", h->sock.state);
  out:
@@ -517,4 +511,3 @@ int sock_unix_restore(struct ckpt_ctx *ctx, struct socket *socket,
 	kfree(cwd);
 	return ret;
 }
-
-- 
1.6.0.4
