From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/4] Handle unconnected DGRAM sockets with buffers in-flight
Date: Thu, 13 Aug 2009 12:29:10 -0700
Message-ID: <1250191750-3864-5-git-send-email-danms@us.ibm.com>
References: <1250191750-3864-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1250191750-3864-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This patch avoids connecting an unconnected DGRAM socket to a fake peer as
part of the restore process.  Note that it will appear to rewrite all packets
received as coming from a single unbound sender.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/unix/checkpoint.c |   41 +++++++++++++++++++++++++++--------------
 1 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
index eb19e66..a499246 100644
--- a/net/unix/checkpoint.c
+++ b/net/unix/checkpoint.c
@@ -118,7 +118,8 @@ int sock_unix_checkpoint(struct ckpt_ctx *ctx,
 	return ret;
 }
 
-static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sock)
+static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sock,
+				    struct sockaddr *addr, unsigned int alen)
 {
 	struct msghdr msg;
 	struct kvec kvec;
@@ -146,6 +147,11 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sock)
 	if (ret < 0)
 		goto out;
 
+	if (addr) {
+		msg.msg_name = addr;
+		msg.msg_namelen = alen;
+	}
+
 	ret = kernel_sendmsg(sock->sk_socket, &msg, &kvec, 1, len);
 	ckpt_debug("kernel_sendmsg(%i): %i\n", len, ret);
 	if ((ret > 0) && (ret != len))
@@ -158,7 +164,8 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sock)
 
 static int sock_unix_read_buffers(struct ckpt_ctx *ctx,
 				  struct sock *sock,
-				  uint32_t *bufsize)
+				  uint32_t *bufsize,
+				  struct ckpt_hdr_socket_unix *un)
 {
 	uint8_t sock_shutdown;
 	struct ckpt_hdr_socket_queue *h;
@@ -174,7 +181,16 @@ static int sock_unix_read_buffers(struct ckpt_ctx *ctx,
 	sock->sk_shutdown &= ~SHUTDOWN_MASK;
 
 	for (i = 0; i < h->skb_count; i++) {
-		ret = sock_read_buffer_sendmsg(ctx, sock);
+		struct sockaddr *addr = NULL;
+		unsigned int len = un->laddr_len;
+
+		/* If we don't have a real peer, then we're not connected,
+		 * and thus need to send this to a specific address
+		 */
+		if (!un->peer)
+			addr = (struct sockaddr *)&un->laddr;
+
+		ret = sock_read_buffer_sendmsg(ctx, sock, addr, len);
 		ckpt_debug("read_buffer_sendmsg(%i): %i\n", i, ret);
 		if (ret < 0)
 			break;
@@ -283,10 +299,12 @@ static int sock_unix_restore_connected(struct ckpt_ctx *ctx,
 		if (ret < 0)
 			goto out;
 
-		ret = sock_unix_join(ctx, this, peer, un);
-		ckpt_debug("sock_unix_join: %i\n", ret);
-		if (ret)
-			goto out;
+		if (h->sock.state == TCP_ESTABLISHED) {
+			ret = sock_unix_join(ctx, this, peer, un);
+			ckpt_debug("sock_unix_join: %i\n", ret);
+			if (ret)
+				goto out;
+		}
 
 	} else {
 		ckpt_debug("Order Error\n");
@@ -314,18 +332,13 @@ static int sock_unix_restore_connected(struct ckpt_ctx *ctx,
 	peer->sk_sndbuf = sysctl_wmem_max;
 
 	/* Read my buffers and sendmsg() them back to me via my peer */
-
-	/* TODO: handle the unconnected case, as well, as the case
-	 *       where sendto() has been used on some of the buffers
-	 */
-
-	ret = sock_unix_read_buffers(ctx, peer, &peer->sk_sndbuf);
+	ret = sock_unix_read_buffers(ctx, peer, &peer->sk_sndbuf, un);
 	ckpt_debug("sock_unix_read_buffers: %i\n", ret);
 	if (ret)
 		goto out;
 
 	/* Read peer's buffers and expect 0 */
-	ret = sock_unix_read_buffers(ctx, peer, NULL);
+	ret = sock_unix_read_buffers(ctx, peer, NULL, un);
  out:
 	if (tmp && ret)
 		sock_release(tmp);
-- 
1.6.0.4
