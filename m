From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/3] c/r: add checkpoint/restore methods to struct proto_ops
Date: Mon, 17 Aug 2009 16:12:10 -0400
Message-ID: <1250539931-12951-3-git-send-email-orenl@librato.com>
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

This patch adds checkpoint and restore methods to struct proto_ops
which should allow compilation of af-unix sockets as a module. It also
simplifies the code.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/net.h   |    7 ++++++
 include/net/af_unix.h |   29 ++------------------------
 net/checkpoint.c      |   53 +++++++++++++++++++++++-------------------------
 net/unix/af_unix.c    |    6 +++++
 net/unix/checkpoint.c |    6 ++--
 5 files changed, 44 insertions(+), 57 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 2c4a75d..96c7e22 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -147,6 +147,9 @@ struct sockaddr;
 struct msghdr;
 struct module;
 
+struct ckpt_ctx;
+struct ckpt_hdr_socket;
+
 struct proto_ops {
 	int		family;
 	struct module	*owner;
@@ -191,6 +194,10 @@ struct proto_ops {
 				      int offset, size_t size, int flags);
 	ssize_t 	(*splice_read)(struct socket *sock,  loff_t *ppos,
 				       struct pipe_inode_info *pipe, size_t len, unsigned int flags);
+	int		(*checkpoint)(struct ckpt_ctx *ctx,
+				      struct socket *sock);
+	int		(*restore)(struct ckpt_ctx *ctx, struct socket *sock,
+				   struct ckpt_hdr_socket *h);
 };
 
 struct net_proto_family {
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 35b5b9c..e265e9e 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -72,32 +72,9 @@ static inline void unix_sysctl_unregister(struct net *net) {}
 #ifdef CONFIG_CHECKPOINT
 struct ckpt_ctx;
 struct ckpt_hdr_socket;
-
-#ifdef CONFIG_UNIX_MODULE
-/* FIXME: Our current scheme won't work with CONFIG_UNIX=m */
-#error "CONFIG_UNIX=m not currently supported by CONFIG_CHECKPOINT"
-#endif
-
-#ifdef CONFIG_UNIX
-extern int sock_unix_checkpoint(struct ckpt_ctx *ctx, struct socket *socket);
-extern int sock_unix_restore(struct ckpt_ctx *ctx,
-			     struct ckpt_hdr_socket *h,
-			     struct socket *socket);
-#else
-static inline int sock_unix_checkpoint(struct ckpt_ctx *ctx,
-				       struct socket *socket,
-				       struct ckpt_hdr_socket *h)
-{
-	return -ENOSYS;
-}
-
-static inline int sock_unix_restore(struct ckpt_ctx *ctx,
-				    struct ckpt_hdr_socket *h,
-				    struct socket *socket)
-{
-	return -ENOSYS;
-}
-#endif /* CONFIG_UNIX */
+extern int sock_unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock);
+extern int sock_unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
+			     struct ckpt_hdr_socket *h);
 #endif /* CONFIG_CHECKPOINT */
 
 #endif
diff --git a/net/checkpoint.c b/net/checkpoint.c
index b97cb89..9f92d7a 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -326,10 +326,15 @@ static int sock_cptrst(struct ckpt_ctx *ctx,
 int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 {
 	struct ckpt_hdr_file_socket *h;
-	struct socket *socket = file->private_data;
-	struct sock *sock = socket->sk;
+	struct socket *sock = file->private_data;
+	struct sock *sk = sock->sk;
 	int ret;
 
+	if (!sock->ops->checkpoint) {
+		ckpt_write_err(ctx, "socket (proto_ops: %pS)", sock->ops);
+		return -ENOSYS;
+	}
+
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
 	if (!h)
 		return -ENOMEM;
@@ -337,7 +342,7 @@ int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 	h->common.f_type = CKPT_FILE_SOCKET;
 
 	/* part I: common to all sockets */
-	ret = sock_cptrst(ctx, sock, &h->socket, CKPT_CPT);
+	ret = sock_cptrst(ctx, sk, &h->socket, CKPT_CPT);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_file_common(ctx, file, &h->common);
@@ -348,22 +353,16 @@ int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 		goto out;
 
 	/* part II: per socket type state */
-	if (sock->sk_family == AF_UNIX) {
-		ret = sock_unix_checkpoint(ctx, socket);
-	} else {
-		ckpt_write_err(ctx, "unsupported socket family %i",
-			       sock->sk_family);
-		ret = -ENOSYS;
-	}
+	ret = sock->ops->checkpoint(ctx, sock);
 	if (ret < 0)
 		goto out;
 
 	/* part III: socket buffers */
-	if (sock->sk_state != TCP_LISTEN) {
-		ret = sock_write_buffers(ctx, &sock->sk_receive_queue);
+	if (sk->sk_state != TCP_LISTEN) {
+		ret = sock_write_buffers(ctx, &sk->sk_receive_queue);
 		if (ret)
 			goto out;
-		ret = sock_write_buffers(ctx, &sock->sk_write_queue);
+		ret = sock_write_buffers(ctx, &sk->sk_write_queue);
 	}
  out:
 	ckpt_hdr_put(ctx, h);
@@ -428,7 +427,7 @@ struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 {
 	struct ckpt_hdr_file_socket *hh = (struct ckpt_hdr_file_socket *) ptr;
 	struct ckpt_hdr_socket *h = &hh->socket;
-	struct socket *socket;
+	struct socket *sock;
 	struct file *file;
 	int ret;
 
@@ -436,35 +435,33 @@ struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 	    ptr->h.len != sizeof(*hh) || ptr->f_type != CKPT_FILE_SOCKET)
 		return ERR_PTR(-EINVAL);
 
-	if ((h->sock.type != SOCK_DGRAM) && (h->sock.type != SOCK_STREAM)) {
-		ckpt_debug("Socket type %i not supported", h->sock.type);
+	if (h->sock.type & ~SOCK_TYPE_MASK)
 		return ERR_PTR(-EINVAL);
-	}
 
-	ret = sock_create(h->sock_common.family, h->sock.type, 0, &socket);
+	ret = sock_create(h->sock_common.family, h->sock.type, 0, &sock);
 	if (ret < 0)
 		return ERR_PTR(ret);
 
+	if (!sock->ops->restore) {
+		ckpt_debug("proto_ops lacks checkpoint: %pS\n", sock->ops);
+		ret = -EINVAL;
+		goto err;
+	}
+
 	/*
 	 * part II: per socket type state
 	 * (also takes care of part III: socket buffer)
 	 */
-	if (h->sock_common.family == AF_UNIX) {
-		ret = sock_unix_restore(ctx, h, socket);
-		ckpt_debug("sock_unix_restore: %i\n", ret);
-	} else {
-		ckpt_debug("unsupported family %i\n", h->sock_common.family);
-		ret = -ENOSYS;
-	}
+	ret = sock->ops->restore(ctx, sock, h);
 	if (ret < 0)
 		goto err;
 
 	/* part I: common to all sockets */
-	ret = sock_cptrst(ctx, socket->sk, h, CKPT_RST);
+	ret = sock_cptrst(ctx, sock->sk, h, CKPT_RST);
 	if (ret < 0)
 		goto err;
 
-	file = sock_alloc_attach_fd(socket);
+	file = sock_alloc_attach_fd(sock);
 	if (IS_ERR(file)) {
 		ret = PTR_ERR(file);
 		goto err;
@@ -478,7 +475,7 @@ struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 	return file;
 
  err:
-	sock_release(socket);
+	sock_release(sock);
 	return ERR_PTR(ret);
 }
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index fc3ebb9..667397d 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -523,6 +523,8 @@ static const struct proto_ops unix_stream_ops = {
 	.recvmsg =	unix_stream_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
+	.checkpoint =	sock_unix_checkpoint,
+	.restore =	sock_unix_restore,
 };
 
 static const struct proto_ops unix_dgram_ops = {
@@ -544,6 +546,8 @@ static const struct proto_ops unix_dgram_ops = {
 	.recvmsg =	unix_dgram_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
+	.checkpoint =	sock_unix_checkpoint,
+	.restore =	sock_unix_restore,
 };
 
 static const struct proto_ops unix_seqpacket_ops = {
@@ -565,6 +569,8 @@ static const struct proto_ops unix_seqpacket_ops = {
 	.recvmsg =	unix_dgram_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
+	.checkpoint =	sock_unix_checkpoint,
+	.restore =	sock_unix_restore,
 };
 
 static struct proto unix_proto = {
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
index 69fdcf1..d2431a4 100644
--- a/net/unix/checkpoint.c
+++ b/net/unix/checkpoint.c
@@ -472,9 +472,9 @@ static int sock_unix_precheck(struct socket *socket,
 	return 0;
 }
 
-int sock_unix_restore(struct ckpt_ctx *ctx,
-		      struct ckpt_hdr_socket *h,
-		      struct socket *socket)
+int sock_unix_restore(struct ckpt_ctx *ctx, struct socket *socket,
+		      struct ckpt_hdr_socket *h)
+
 {
 	struct ckpt_hdr_socket_unix *un;
 	int ret = -EINVAL;
-- 
1.6.0.4
