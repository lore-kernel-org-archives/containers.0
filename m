From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] [RFC] Track socket buffer owners
Date: Wed,  2 Sep 2009 11:22:40 -0700
Message-ID: <1251915760-20118-4-git-send-email-danms@us.ibm.com>
References: <1251915760-20118-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1251915760-20118-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

This patch is a superset of the previous attempt to store socket buffers
with their owners.  It defers the writing and reading of the socket buffers
until after the end of the file phase to avoid a recursive nose-dive of
checkpointing socket owners.

This also moves the join logic to the deferqueue as well, since that too
can lead us down a deep hole.  The buffer restore logic may perform a join
if it decides that the join is inevitable (but not yet performed) and
necessary.

Note that I've been staring at this for too long, so I'm sending it as an
RFC with hopes that it's not too much of a mess.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint.h     |    3 -
 include/linux/checkpoint_hdr.h |    6 +
 include/linux/net.h            |    4 +-
 include/net/af_unix.h          |    4 +-
 net/checkpoint.c               |  131 ++++++++++------
 net/unix/checkpoint.c          |  339 ++++++++++++++++++++++++++--------------
 6 files changed, 312 insertions(+), 175 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 761cad5..88861a1 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -84,9 +84,6 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
 			      struct socket *socket,
 			      struct sockaddr *loc, unsigned *loc_len,
 			      struct sockaddr *rem, unsigned *rem_len);
-extern struct ckpt_hdr_socket_queue *
-ckpt_sock_read_buffer_hdr(struct ckpt_ctx *ctx,
-			  uint32_t *bufsize);
 
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b75562c..6b74a51 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -414,6 +414,12 @@ struct ckpt_hdr_socket_queue {
 	__u32 total_bytes;
 } __attribute__ ((aligned(8)));
 
+struct ckpt_hdr_socket_buffer {
+	struct ckpt_hdr h;
+	__s32 src_objref;
+	__s32 dst_objref;
+};
+
 #define CKPT_UNIX_LINKED 1
 struct ckpt_hdr_socket_unix {
 	struct ckpt_hdr h;
diff --git a/include/linux/net.h b/include/linux/net.h
index 27187a4..96c7e22 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -148,7 +148,7 @@ struct msghdr;
 struct module;
 
 struct ckpt_ctx;
-struct ckpt_socket;
+struct ckpt_hdr_socket;
 
 struct proto_ops {
 	int		family;
@@ -197,7 +197,7 @@ struct proto_ops {
 	int		(*checkpoint)(struct ckpt_ctx *ctx,
 				      struct socket *sock);
 	int		(*restore)(struct ckpt_ctx *ctx, struct socket *sock,
-				   struct ckpt_socket *h);
+				   struct ckpt_hdr_socket *h);
 };
 
 struct net_proto_family {
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 1a1fd20..61f666b 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -71,10 +71,10 @@ static inline void unix_sysctl_unregister(struct net *net) {}
 
 #ifdef CONFIG_CHECKPOINT
 struct ckpt_ctx;
-struct ckpt_socket;
+struct ckpt_hdr_socket;
 extern int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock);
 extern int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
-			struct ckpt_socket *h);
+			struct ckpt_hdr_socket *h);
 #else
 #define unix_checkpoint NULL
 #define unix_restore NULL
diff --git a/net/checkpoint.c b/net/checkpoint.c
index 42a8853..cb37ef4 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -23,6 +23,12 @@
 
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/deferqueue.h>
+
+struct dq_buffers {
+	struct ckpt_ctx *ctx;
+	struct sock *sk;
+};
 
 static int sock_copy_buffers(struct sk_buff_head *from,
 			     struct sk_buff_head *to,
@@ -58,6 +64,7 @@ static int sock_copy_buffers(struct sk_buff_head *from,
 			break; /* The queue changed as we read it */
 
 		skb_morph(skbs[i], skb);
+		skbs[i]->sk = skb->sk;
 		skb_queue_tail(to, skbs[i]);
 
 		*total_bytes += skb->len;
@@ -82,12 +89,15 @@ static int sock_copy_buffers(struct sk_buff_head *from,
 }
 
 static int __sock_write_buffers(struct ckpt_ctx *ctx,
-				struct sk_buff_head *queue)
+				struct sk_buff_head *queue,
+				int dst_objref)
 {
 	struct sk_buff *skb;
-	int ret = 0;
 
 	skb_queue_walk(queue, skb) {
+		struct ckpt_hdr_socket_buffer *h;
+		int ret = 0;
+
 		/* FIXME: This could be a false positive for non-unix
 		 *        buffers, so add a type check here in the
 		 *        future
@@ -104,16 +114,35 @@ static int __sock_write_buffers(struct ckpt_ctx *ctx,
 		 * information contained in the skb.
 		 */
 
+		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFER);
+		if (!h)
+			return -ENOMEM;
+
+		BUG_ON(!skb->sk);
+		ret = checkpoint_obj(ctx, skb->sk, CKPT_OBJ_SOCK);
+		if (ret < 0)
+			goto end;
+		h->src_objref = ret;
+		h->dst_objref = dst_objref;
+
+		ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+		if (ret < 0)
+			goto end;
+
 		ret = ckpt_write_obj_type(ctx, skb->data, skb->len,
-					  CKPT_HDR_SOCKET_BUFFER);
-		if (ret)
+					  CKPT_HDR_BUFFER);
+	end:
+		ckpt_hdr_put(ctx, h);
+		if (ret < 0)
 			return ret;
 	}
 
 	return 0;
 }
 
-static int sock_write_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
+static int sock_write_buffers(struct ckpt_ctx *ctx,
+			      struct sk_buff_head *queue,
+			      int dst_objref)
 {
 	struct ckpt_hdr_socket_queue *h;
 	struct sk_buff_head tmpq;
@@ -132,7 +161,7 @@ static int sock_write_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
 	h->skb_count = ret;
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
 	if (!ret)
-		ret = __sock_write_buffers(ctx, &tmpq);
+		ret = __sock_write_buffers(ctx, &tmpq, dst_objref);
 
  out:
 	ckpt_hdr_put(ctx, h);
@@ -141,6 +170,44 @@ static int sock_write_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
 	return ret;
 }
 
+int sock_deferred_write_buffers(void *data)
+{
+	struct dq_buffers *dq = (struct dq_buffers *)data;
+	struct ckpt_ctx *ctx = dq->ctx;
+	int ret;
+	int dst_objref;
+
+	dst_objref = ckpt_obj_lookup(ctx, dq->sk, CKPT_OBJ_SOCK);
+	if (dst_objref < 0) {
+		ckpt_write_err(ctx,
+			       "Unable to get objref of owner socket: %i\n",
+			       dst_objref);
+		return dst_objref;
+	}
+
+	ret = sock_write_buffers(ctx, &dq->sk->sk_receive_queue, dst_objref);
+	ckpt_debug("write recv buffers: %i\n", ret);
+	if (ret < 0)
+		return ret;
+
+	ret = sock_write_buffers(ctx, &dq->sk->sk_write_queue, dst_objref);
+	ckpt_debug("write send buffers: %i\n", ret);
+
+	return ret;
+}
+
+int sock_defer_write_buffers(struct ckpt_ctx *ctx, struct sock *sk)
+{
+	struct dq_buffers dq;
+
+	dq.ctx = ctx;
+	dq.sk = sk;
+
+	return deferqueue_add(ctx->files_deferq, &dq, sizeof(dq),
+			      sock_deferred_write_buffers,
+			      sock_deferred_write_buffers);
+}
+
 int ckpt_sock_getnames(struct ckpt_ctx *ctx, struct socket *sock,
 		       struct sockaddr *loc, unsigned *loc_len,
 		       struct sockaddr *rem, unsigned *rem_len)
@@ -166,7 +233,7 @@ int ckpt_sock_getnames(struct ckpt_ctx *ctx, struct socket *sock,
 	return 0;
 }
 
-static int sock_cptrst_verify(struct ckpt_socket *h)
+static int sock_cptrst_verify(struct ckpt_hdr_socket *h)
 {
 	uint8_t userlocks_mask = SOCK_SNDBUF_LOCK | SOCK_RCVBUF_LOCK |
 		                 SOCK_BINDADDR_LOCK | SOCK_BINDPORT_LOCK;
@@ -204,7 +271,7 @@ static int sock_cptrst_opt(int op, struct socket *sock,
 	sock_cptrst_opt(op, sk->sk_socket, name, (char *)opt, sizeof(*opt))
 
 static int sock_cptrst_bufopts(int op, struct sock *sk,
-			       struct ckpt_socket *h)
+			       struct ckpt_hdr_socket *h)
 
 {
 	if (CKPT_COPY_SOPT(op, sk, SO_RCVBUF, &h->sock.rcvbuf))
@@ -270,7 +337,7 @@ static int sock_restore_flag(struct socket *sock,
 
 
 static int sock_restore_flags(struct socket *sock,
-                             struct ckpt_socket *h)
+                             struct ckpt_hdr_socket *h)
 {
        int ret;
        int i;
@@ -309,6 +376,9 @@ static int sock_restore_flags(struct socket *sock,
                return -ENOSYS;
        }
 
+       if (test_and_clear_bit(SOCK_DEAD, &sk_flags))
+	       sock_flag(sock->sk, SOCK_DEAD);
+
        /* Anything that is still set in the flags that isn't part of
         * our protocol's default set, indicates an error
         */
@@ -339,7 +409,7 @@ static int sock_copy_timeval(int op, struct sock *sk,
 }
 
 static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
-		       struct ckpt_socket *h, int op)
+		       struct ckpt_hdr_socket *h, int op)
 {
 	if (sk->sk_socket) {
 		CKPT_COPY(op, h->socket.state, sk->sk_socket->state);
@@ -459,10 +529,9 @@ static int __do_sock_checkpoint(struct ckpt_ctx *ctx, struct sock *sk)
 
 	/* part III: socket buffers */
 	if ((sk->sk_state != TCP_LISTEN) && (!sock_flag(sk, SOCK_DEAD))) {
-		ret = sock_write_buffers(ctx, &sk->sk_receive_queue);
+		ret = sock_defer_write_buffers(ctx, sk);
 		if (ret)
 			goto out;
-		ret = sock_write_buffers(ctx, &sk->sk_write_queue);
 	}
 
  out:
@@ -528,42 +597,6 @@ int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 	return ret;
 }
 
-struct ckpt_hdr_socket_queue *ckpt_sock_read_buffer_hdr(struct ckpt_ctx *ctx,
-							uint32_t *bufsize)
-{
-	struct ckpt_hdr_socket_queue *h;
-	int err = 0;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_QUEUE);
-	if (IS_ERR(h))
-		return h;
-
-	if (!bufsize) {
-		if (h->total_bytes != 0) {
-			ckpt_debug("Expected empty buffer, got %u\n",
-				   h->total_bytes);
-			err = -EINVAL;
-		}
-	} else if (h->total_bytes > *bufsize) {
-		/* NB: We let CAP_NET_ADMIN override the system buffer limit
-		 *     as setsockopt() does
-		 */
-		if (capable(CAP_NET_ADMIN))
-			*bufsize = h->total_bytes;
-		else {
-			ckpt_debug("Buffer total %u exceeds limit %u\n",
-			   h->total_bytes, *bufsize);
-			err = -EINVAL;
-		}
-	}
-
-	if (err) {
-		ckpt_hdr_put(ctx, h);
-		return ERR_PTR(err);
-	} else
-		return h;
-}
-
 static struct file *sock_alloc_attach_fd(struct socket *sock)
 {
 	struct file *file;
@@ -588,7 +621,7 @@ static struct file *sock_alloc_attach_fd(struct socket *sock)
 	return file;
 }
 
-struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
+struct sock *do_sock_restore(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_socket *h;
 	struct socket *sock;
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
index f4905db..a6b17d1 100644
--- a/net/unix/checkpoint.c
+++ b/net/unix/checkpoint.c
@@ -4,11 +4,23 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/user.h>
+#include <linux/deferqueue.h>
 #include <net/af_unix.h>
 #include <net/tcp_states.h>
 
 #define UNIX_ADDR_EMPTY(a) (a <= sizeof(short))
 
+struct dq_join {
+	struct ckpt_ctx *ctx;
+	int src_ref;
+	int dst_ref;
+};
+
+struct dq_buffers {
+	struct ckpt_ctx *ctx;
+	int sk_ref; /* objref of the socket these buffers belong to */
+};
+
 static inline int unix_need_cwd(struct sockaddr_un *addr, unsigned long len)
 {
 	return (!UNIX_ADDR_EMPTY(len)) &&
@@ -16,6 +28,54 @@ static inline int unix_need_cwd(struct sockaddr_un *addr, unsigned long len)
 		(addr->sun_path[0] != '/');
 }
 
+static int unix_join(struct sock *src, struct sock *dst)
+{
+	if (unix_sk(src)->peer != NULL)
+		return 0; /* We're second */
+
+	sock_hold(dst);
+	unix_sk(src)->peer = dst;
+
+	return 0;
+
+}
+
+static int unix_deferred_join(void *data)
+{
+	struct dq_join *dq = (struct dq_join *)data;
+	struct ckpt_ctx *ctx = dq->ctx;
+	struct sock *src;
+	struct sock *dst;
+
+	src = ckpt_obj_fetch(ctx, dq->src_ref, CKPT_OBJ_SOCK);
+	if (!src) {
+		ckpt_debug("Missing src sock ref %i\n", dq->src_ref);
+		return -EINVAL;
+	}
+
+	dst = ckpt_obj_fetch(ctx, dq->dst_ref, CKPT_OBJ_SOCK);
+	if (!src) {
+		ckpt_debug("Missing dst sock ref %i\n", dq->dst_ref);
+		return -EINVAL;
+	}
+
+	return unix_join(src, dst);
+}
+
+static int unix_defer_join(struct ckpt_ctx *ctx,
+			   int src_ref,
+			   int dst_ref)
+{
+	struct dq_join dq;
+
+	dq.ctx = ctx;
+	dq.src_ref = src_ref;
+	dq.dst_ref = dst_ref;
+
+	return deferqueue_add(ctx->files_deferq, &dq, sizeof(dq),
+			      unix_deferred_join, unix_deferred_join);
+}
+
 static int unix_write_cwd(struct ckpt_ctx *ctx,
 			  struct sock *sk, const char *sockpath)
 {
@@ -109,24 +169,63 @@ int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
 	return ret;
 }
 
-static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sk)
+static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
+				    struct sockaddr *addr,
+				    unsigned int addrlen)
 {
 	struct msghdr msg;
 	struct kvec kvec;
+	struct ckpt_hdr_socket_buffer *h;
+	struct sock *sk;
+	uint8_t sock_shutdown;
+	uint8_t peer_shutdown = 0;
 	void *buf;
 	int ret = 0;
 	int len;
+	int sndbuf;
 
 	memset(&msg, 0, sizeof(msg));
 
-	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_SOCKET_BUFFER);
-	if (len < 0)
-		return len;
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFER);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_BUFFER);
+	if (len < 0) {
+		ret = len;
+		goto out;
+	}
 
 	if (len > SKB_MAX_ALLOC) {
 		ckpt_debug("Socket buffer too big (%i > %lu)",
 			   len, SKB_MAX_ALLOC);
-		return -ENOSPC;
+		ret = -ENOSPC;
+		goto out;
+	}
+
+	sk = ckpt_obj_fetch(ctx, h->src_objref, CKPT_OBJ_SOCK);
+	if (IS_ERR(sk)) {
+		ret = PTR_ERR(sk);
+		goto out;
+	}
+
+	/* If we don't have a destination or a peer and we know the
+	 * destination of this skb, then we must need to join with our
+	 * peer
+	 */
+	if (!addrlen && !unix_sk(sk)->peer && (h->dst_objref != 0)) {
+		struct sock *pr;
+		pr = ckpt_obj_fetch(ctx, h->dst_objref, CKPT_OBJ_SOCK);
+		if (IS_ERR(pr)) {
+			ckpt_debug("Failed to get our peer: %li\n", PTR_ERR(pr));
+			ret = PTR_ERR(pr);
+			goto out;
+		}
+		ret = unix_join(sk, pr);
+		if (ret < 0) {
+			ckpt_debug("Failed to join: %i\n", ret);
+			goto out;
+		}
 	}
 
 	kvec.iov_len = len;
@@ -139,54 +238,123 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sk)
 	if (ret < 0)
 		goto out;
 
+	msg.msg_name = addr;
+	msg.msg_namelen = addrlen;
+
+	/* If peer is shutdown, unshutdown it for this process */
+	sock_shutdown = sk->sk_shutdown;
+	sk->sk_shutdown &= ~SHUTDOWN_MASK;
+
+	/* Unshutdown peer too, if necessary */
+	if (unix_sk(sk)->peer) {
+		peer_shutdown = unix_sk(sk)->peer->sk_shutdown;
+		unix_sk(sk)->peer->sk_shutdown &= ~SHUTDOWN_MASK;
+	}
+
+	/* Make sure there's room in the send buffer */
+	sndbuf = sk->sk_sndbuf;
+	if (capable(CAP_NET_ADMIN) &&
+	    ((sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc)) < len))
+		sk->sk_sndbuf += len;
+	else
+		sk->sk_sndbuf = sysctl_wmem_max;
+
 	ret = kernel_sendmsg(sk->sk_socket, &msg, &kvec, 1, len);
-	ckpt_debug("kernel_sendmsg(%i): %i\n", len, ret);
+	ckpt_debug("kernel_sendmsg(%i,%i): %i\n", h->src_objref, len, ret);
 	if ((ret > 0) && (ret != len))
 		ret = -ENOMEM;
+
+	sk->sk_sndbuf = sndbuf;
+	sk->sk_shutdown = sock_shutdown;
+	if (peer_shutdown)
+		unix_sk(sk)->peer->sk_shutdown = peer_shutdown;
  out:
+	ckpt_hdr_put(ctx, h);
 	kfree(buf);
 
 	return ret;
 }
 
 static int unix_read_buffers(struct ckpt_ctx *ctx,
-			     struct sock *sk, uint32_t *bufsize)
+			     struct sockaddr *addr,
+			     unsigned int addrlen)
 {
-	uint8_t sock_shutdown;
 	struct ckpt_hdr_socket_queue *h;
 	int ret = 0;
 	int i;
 
-	h = ckpt_sock_read_buffer_hdr(ctx, bufsize);
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_QUEUE);
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
-	/* If peer is shutdown, unshutdown it for this process */
-	sock_shutdown = sk->sk_shutdown;
-	sk->sk_shutdown &= ~SHUTDOWN_MASK;
-
 	for (i = 0; i < h->skb_count; i++) {
-		ret = sock_read_buffer_sendmsg(ctx, sk);
+		ret = sock_read_buffer_sendmsg(ctx, addr, addrlen);
 		ckpt_debug("read_buffer_sendmsg(%i): %i\n", i, ret);
 		if (ret < 0)
-			break;
+			goto out;
 
 		if (ret > h->total_bytes) {
 			ckpt_debug("Buffers exceeded claim");
 			ret = -EINVAL;
-			break;
+			goto out;
 		}
 
 		h->total_bytes -= ret;
 		ret = 0;
 	}
 
-	sk->sk_shutdown = sock_shutdown;
+	ret = h->skb_count;
+ out:
 	ckpt_hdr_put(ctx, h);
 
 	return ret;
 }
 
+static int unix_deferred_restore_buffers(void *data)
+{
+	struct dq_buffers *dq = (struct dq_buffers *)data;
+	struct ckpt_ctx *ctx = dq->ctx;
+	struct sock *sk;
+	struct sockaddr *addr = NULL;
+	unsigned int addrlen = 0;
+	int ret;
+
+	sk = ckpt_obj_fetch(ctx, dq->sk_ref, CKPT_OBJ_SOCK);
+	if (!sk) {
+		ckpt_debug("Missing sock ref %i\n", dq->sk_ref);
+		return -EINVAL;
+	}
+
+	if ((sk->sk_type == SOCK_DGRAM) && (unix_sk(sk)->addr != NULL)) {
+		addr = (struct sockaddr *)&unix_sk(sk)->addr->name;
+		addrlen = unix_sk(sk)->addr->len;
+	}
+
+	ret = unix_read_buffers(ctx, addr, addrlen);
+	ckpt_debug("read recv buffers: %i\n", ret);
+	if (ret < 0)
+		return ret;
+
+	ret = unix_read_buffers(ctx, addr, addrlen);
+	ckpt_debug("read send buffers: %i\n", ret);
+	if (ret != 0)
+		ret = -EINVAL; /* No send buffers for UNIX sockets */
+
+	return ret;
+}
+
+static int unix_defer_restore_buffers(struct ckpt_ctx *ctx, int sk_ref)
+{
+	struct dq_buffers dq;
+
+	dq.ctx = ctx;
+	dq.sk_ref = sk_ref;
+
+	return deferqueue_add(ctx->files_deferq, &dq, sizeof(dq),
+			      unix_deferred_restore_buffers,
+			      unix_deferred_restore_buffers);
+}
+
 static struct unix_address *unix_makeaddr(struct sockaddr_un *sun_addr,
 					  unsigned len)
 {
@@ -206,91 +374,33 @@ static struct unix_address *unix_makeaddr(struct sockaddr_un *sun_addr,
 	return addr;
 }
 
-static int unix_join(struct ckpt_ctx *ctx,
-		     struct sock *a, struct sock *b,
-		     struct ckpt_hdr_socket_unix *un)
-{
-	struct unix_address *addr = NULL;
-
-	/* FIXME: Do we need to call some security hooks here? */
-
-	sock_hold(a);
-	sock_hold(b);
-
-	unix_sk(a)->peer = b;
-	unix_sk(b)->peer = a;
-
-	if (!UNIX_ADDR_EMPTY(un->raddr_len))
-		addr = unix_makeaddr(&un->raddr, un->raddr_len);
-	else if (!UNIX_ADDR_EMPTY(un->laddr_len))
-		addr = unix_makeaddr(&un->laddr, un->laddr_len);
-
-	if (IS_ERR(addr))
-		return PTR_ERR(addr);
-	else if (addr) {
-		atomic_inc(&addr->refcnt); /* Held by both ends */
-		unix_sk(a)->addr = unix_sk(b)->addr = addr;
-	}
-
-	return 0;
-}
-
 static int unix_restore_connected(struct ckpt_ctx *ctx,
-				  struct ckpt_socket *h,
+				  struct ckpt_hdr_socket *h,
 				  struct ckpt_hdr_socket_unix *un,
 				  struct socket *sock)
 {
-	struct sock *this = ckpt_obj_fetch(ctx, un->this, CKPT_OBJ_SOCK);
-	struct sock *peer = ckpt_obj_fetch(ctx, un->peer, CKPT_OBJ_SOCK);
-	struct socket *tmp = NULL;
+	struct sock *sk = sock->sk;
+	struct sockaddr *addr = NULL;
+	unsigned int addrlen = 0;
 	int ret;
-
-	if (!IS_ERR(this) && !IS_ERR(peer)) {
-		/* We're last */
-		struct socket *old = this->sk_socket;
-
-		old->sk = NULL;
-		sock_release(old);
-		sock_graft(this, sock);
-
-	} else if ((PTR_ERR(this) == -EINVAL) && (PTR_ERR(peer) == -EINVAL)) {
-		/* We're first */
-		int family = sock->sk->sk_family;
-		int type = sock->sk->sk_type;
-
-		ret = sock_create(family, type, 0, &tmp);
-		ckpt_debug("sock_create: %i\n", ret);
-		if (ret)
-			goto out;
-
-		this = sock->sk;
-		peer = tmp->sk;
-
-		ret = ckpt_obj_insert(ctx, this, un->this, CKPT_OBJ_SOCK);
-		if (ret < 0)
-			goto out;
-
-		ret = ckpt_obj_insert(ctx, peer, un->peer, CKPT_OBJ_SOCK);
-		if (ret < 0)
-			goto out;
-
-		ret = unix_join(ctx, this, peer, un);
-		ckpt_debug("unix_join: %i\n", ret);
-		if (ret)
-			goto out;
-
-	} else {
-		ckpt_debug("Order Error\n");
-		ret = PTR_ERR(this);
-		goto out;
+	unsigned long flags = h->sock.flags;
+	int dead = test_bit(SOCK_DEAD, &flags);
+
+	if (un->peer == 0) {
+		/* These get propagated to the msghdr, so only set them
+		 * if we're not connected to a peer, else we'll get an error
+		 * when we sendmsg()
+		 */
+		addr = (struct sockaddr *)&un->laddr;
+		addrlen = un->laddr_len;
 	}
 
-	this->sk_peercred.pid = task_tgid_vnr(current);
+	sk->sk_peercred.pid = task_tgid_vnr(current);
 
 	if (may_setuid(ctx->realcred->user->user_ns, un->peercred_uid) &&
 	    may_setgid(un->peercred_gid)) {
-		this->sk_peercred.uid = un->peercred_uid;
-		this->sk_peercred.gid = un->peercred_gid;
+		sk->sk_peercred.uid = un->peercred_uid;
+		sk->sk_peercred.gid = un->peercred_gid;
 	} else {
 		ckpt_debug("peercred %i:%i would require setuid",
 			   un->peercred_uid, un->peercred_gid);
@@ -298,30 +408,16 @@ static int unix_restore_connected(struct ckpt_ctx *ctx,
 		goto out;
 	}
 
-	/* Prime the socket's buffer limit with the maximum.  These will be
-	 * overwritten with the values in the checkpoint stream in a later
-	 * phase.
-	 */
-	peer->sk_userlocks |= SOCK_SNDBUF_LOCK;
-	peer->sk_sndbuf = sysctl_wmem_max;
-
-	/* Read my buffers and sendmsg() them back to me via my peer */
-
-	/* TODO: handle the unconnected case, as well, as the case
-	 *       where sendto() has been used on some of the buffers
-	 */
-
-	ret = unix_read_buffers(ctx, peer, &peer->sk_sndbuf);
-	ckpt_debug("unix_read_buffers: %i\n", ret);
-	if (ret)
-		goto out;
+	if (!dead && (un->peer > 0)) {
+		ret = unix_defer_join(ctx, un->this, un->peer);
+		ckpt_debug("unix_defer_join: %i\n", ret);
+		if (ret)
+			goto out;
+	}
 
-	/* Read peer's buffers and expect 0 */
-	ret = unix_read_buffers(ctx, peer, NULL);
+	if (!dead)
+		ret = unix_defer_restore_buffers(ctx, un->this);
  out:
-	if (tmp && ret)
-		sock_release(tmp);
-
 	return ret;
 }
 
@@ -422,15 +518,19 @@ static int unix_fakebind(struct socket *sock,
 	return 0;
 }
 
-static int unix_restore_bind(struct ckpt_socket *h,
+static int unix_restore_bind(struct ckpt_hdr_socket *h,
 			     struct ckpt_hdr_socket_unix *un,
 			     struct socket *sock,
 			     const char *path)
 {
 	struct sockaddr *addr = (struct sockaddr *)&un->laddr;
 	unsigned long len = un->laddr_len;
+	unsigned long flags = h->sock.flags;
+	int dead = test_bit(SOCK_DEAD, &flags);
 
-	if (!un->laddr.sun_path[0])
+	if (dead)
+		return unix_fakebind(sock, &un->laddr, len);
+	else if (!un->laddr.sun_path[0])
 		return sock_bind(sock, addr, len);
 	else if (!(un->flags & CKPT_UNIX_LINKED))
 		return unix_fakebind(sock, &un->laddr, len);
@@ -439,9 +539,10 @@ static int unix_restore_bind(struct ckpt_socket *h,
 }
 
 /* Some easy pre-flight checks before we get underway */
-static int unix_precheck(struct socket *sock, struct ckpt_socket *h)
+static int unix_precheck(struct socket *sock, struct ckpt_hdr_socket *h)
 {
 	struct net *net = sock_net(sock->sk);
+	unsigned long sk_flags = h->sock.flags;
 
 	if ((h->socket.state == SS_CONNECTING) ||
 	    (h->socket.state == SS_DISCONNECTING) ||
@@ -461,7 +562,7 @@ static int unix_precheck(struct socket *sock, struct ckpt_socket *h)
 		return -EINVAL;
 	}
 
-	if (h->sock.flags & SOCK_USE_WRITE_QUEUE) {
+	if (test_bit(SOCK_USE_WRITE_QUEUE, &sk_flags)) {
 		ckpt_debug("AF_UNIX socket has SOCK_USE_WRITE_QUEUE set");
 		return -EINVAL;
 	}
@@ -470,7 +571,7 @@ static int unix_precheck(struct socket *sock, struct ckpt_socket *h)
 }
 
 int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
-		      struct ckpt_socket *h)
+		      struct ckpt_hdr_socket *h)
 
 {
 	struct ckpt_hdr_socket_unix *un;
-- 
1.6.2.5
