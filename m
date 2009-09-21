From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] Collect sockets
Date: Mon, 21 Sep 2009 13:44:37 -0700
Message-ID: <1253565877-7303-3-git-send-email-danms@us.ibm.com>
References: <1253565877-7303-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253565877-7303-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c  |    6 +++++
 include/net/af_unix.h |    2 +
 include/net/sock.h    |    1 +
 net/checkpoint.c      |   59 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/socket.c          |    1 +
 net/unix/af_unix.c    |    3 ++
 net/unix/checkpoint.c |   15 ++++++++++++
 7 files changed, 87 insertions(+), 0 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index ee9dbfd..96634b0 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -280,6 +280,11 @@ static int obj_tty_users(void *ptr)
 	return atomic_read(&((struct tty_struct *) ptr)->kref.refcount);
 }
 
+static int obj_sock_users(void *ptr)
+{
+	return atomic_read(&((struct sock *) ptr)->sk_refcnt);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -414,6 +419,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.obj_type = CKPT_OBJ_SOCK,
 		.ref_drop = obj_sock_drop,
 		.ref_grab = obj_sock_grab,
+		.ref_users = obj_sock_users,
 		.checkpoint = checkpoint_sock,
 		.restore = restore_sock,
 	},
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 61f666b..e42a714 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -75,6 +75,8 @@ struct ckpt_hdr_socket;
 extern int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock);
 extern int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
 			struct ckpt_hdr_socket *h);
+extern int unix_collect(struct ckpt_ctx *ctx, struct socket *sock);
+
 #else
 #define unix_checkpoint NULL
 #define unix_restore NULL
diff --git a/include/net/sock.h b/include/net/sock.h
index 1100a5c..ec351f9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1655,6 +1655,7 @@ extern void *restore_sock(struct ckpt_ctx *ctx);
 extern int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
 extern struct file *sock_file_restore(struct ckpt_ctx *ctx,
 				      struct ckpt_hdr_file *h);
+extern int sock_file_collect(struct ckpt_ctx *ctx, struct file *file);
 #endif
 
 #endif	/* _SOCK_H */
diff --git a/net/checkpoint.c b/net/checkpoint.c
index 626b8ef..a11ec7a 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -592,6 +592,65 @@ int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 	return ret;
 }
 
+static int sock_collect_skbs(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
+{
+	struct sk_buff_head tmpq;
+	struct sk_buff *skb;
+	int ret = 0;
+	int bytes;
+
+	skb_queue_head_init(&tmpq);
+
+	ret = sock_copy_buffers(queue, &tmpq, &bytes);
+	if (ret < 0)
+		return ret;
+
+	skb_queue_walk(&tmpq, skb) {
+		/* Socket buffers do not maintain a ref count on their
+		 * owning sock because they're counted in sock_wmem_alloc.
+		 * So, we only need to collect sockets from the queue that
+		 * won't be collected any other way (i.e. DEAD sockets that
+		 * are hanging around only because they're waiting for us
+		 * to process their skb.
+		 */
+
+		if (!ckpt_obj_lookup(ctx, skb->sk, CKPT_OBJ_SOCK) &&
+		    sock_flag(skb->sk, SOCK_DEAD)) {
+			ret = ckpt_obj_collect(ctx, skb->sk, CKPT_OBJ_SOCK);
+			if (ret < 0)
+				break;
+		}
+	}
+
+	__skb_queue_purge(&tmpq);
+
+	return ret;
+}
+
+int sock_file_collect(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct socket *sock = file->private_data;
+	struct sock *sk = sock->sk;
+	int ret;
+
+	ret = sock_collect_skbs(ctx, &sk->sk_write_queue);
+	if (ret < 0)
+		return ret;
+
+	ret = sock_collect_skbs(ctx, &sk->sk_receive_queue);
+	if (ret < 0)
+		return ret;
+
+	ret = ckpt_obj_collect(ctx, sk, CKPT_OBJ_SOCK);
+	if (ret < 0)
+		return ret;
+
+	if (sock->ops->collect)
+		ret = sock->ops->collect(ctx, sock);
+
+	return ret;
+}
+
 static struct file *sock_alloc_attach_fd(struct socket *sock)
 {
 	struct file *file;
diff --git a/net/socket.c b/net/socket.c
index 2de0861..0a4d539 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -142,6 +142,7 @@ static const struct file_operations socket_file_ops = {
 	.splice_read =	sock_splice_read,
 #ifdef CONFIG_CHECKPOINT
 	.checkpoint =   sock_file_checkpoint,
+	.collect = sock_file_collect,
 #endif
 };
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index da6405d..b3d4f16 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -525,6 +525,7 @@ static const struct proto_ops unix_stream_ops = {
 	.sendpage =	sock_no_sendpage,
 	.checkpoint =	unix_checkpoint,
 	.restore =	unix_restore,
+	.collect =      unix_collect,
 };
 
 static const struct proto_ops unix_dgram_ops = {
@@ -548,6 +549,7 @@ static const struct proto_ops unix_dgram_ops = {
 	.sendpage =	sock_no_sendpage,
 	.checkpoint =	unix_checkpoint,
 	.restore =	unix_restore,
+	.collect =      unix_collect,
 };
 
 static const struct proto_ops unix_seqpacket_ops = {
@@ -571,6 +573,7 @@ static const struct proto_ops unix_seqpacket_ops = {
 	.sendpage =	sock_no_sendpage,
 	.checkpoint =	unix_checkpoint,
 	.restore =	unix_restore,
+	.collect =      unix_collect,
 };
 
 static struct proto unix_proto = {
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
index 6a6114b..fd6d944 100644
--- a/net/unix/checkpoint.c
+++ b/net/unix/checkpoint.c
@@ -173,6 +173,21 @@ int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
 	return ret;
 }
 
+int unix_collect(struct ckpt_ctx *ctx, struct socket *sock)
+{
+	struct unix_sock *sk = unix_sk(sock->sk);
+	int ret;
+
+	ret = ckpt_obj_collect(ctx, sock->sk, CKPT_OBJ_SOCK);
+	if (ret < 0)
+		return ret;
+
+	if (sk->peer)
+		ret = ckpt_obj_collect(ctx, sk->peer, CKPT_OBJ_SOCK);
+
+	return 0;
+}
+
 static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
 				    struct sockaddr *addr,
 				    unsigned int addrlen)
-- 
1.6.2.5
