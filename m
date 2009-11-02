From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 10/12] net/{,unix}/checkpoint.c ckpt_write_err->ckpt_err
Date: Mon,  2 Nov 2009 16:23:38 -0600
Message-ID: <1257200620-15499-11-git-send-email-serue@us.ibm.com>
References: <1257200620-15499-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257200620-15499-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/checkpoint.c      |   10 +++++-----
 net/unix/checkpoint.c |    5 +++--
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/checkpoint.c b/net/checkpoint.c
index dd23efd..19025cc 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -103,7 +103,7 @@ static int __sock_write_buffers(struct ckpt_ctx *ctx,
 		 *        future
 		 */
 		if (UNIXCB(skb).fp) {
-			ckpt_write_err(ctx, "TE", "af_unix: pass fd", -EBUSY);
+			ckpt_err(ctx, "%(T)%(E)af_unix: pass fd\n", -EBUSY);
 			return -EBUSY;
 		}
 
@@ -178,7 +178,7 @@ int sock_deferred_write_buffers(void *data)
 
 	dst_objref = ckpt_obj_lookup(ctx, dq->sk, CKPT_OBJ_SOCK);
 	if (dst_objref < 0) {
-		ckpt_write_err(ctx, "TE", "socket: owner gone?", dst_objref);
+		ckpt_err(ctx, "%(T)%(E)socket: owner gone?\n", dst_objref);
 		return dst_objref;
 	}
 
@@ -215,7 +215,7 @@ int ckpt_sock_getnames(struct ckpt_ctx *ctx, struct socket *sock,
 
 	ret = sock_getname(sock, loc, loc_len);
 	if (ret) {
-		ckpt_write_err(ctx, "TEP", "socket: getname local", ret, sock);
+		ckpt_err(ctx, "%(T)%(E)%(P)socket: getname local\n", ret, sock);
 		return -EINVAL;
 	}
 
@@ -223,7 +223,7 @@ int ckpt_sock_getnames(struct ckpt_ctx *ctx, struct socket *sock,
 	if (ret) {
 		if ((sock->sk->sk_type != SOCK_DGRAM) &&
 		    (sock->sk->sk_state == TCP_ESTABLISHED)) {
-			ckpt_write_err(ctx, "TEP", "socket: getname peer",
+			ckpt_err(ctx, "%(T)%(E)%(P)socket: getname peer\n",
 				       ret, sock);
 			return -EINVAL;
 		}
@@ -503,7 +503,7 @@ static int __do_sock_checkpoint(struct ckpt_ctx *ctx, struct sock *sk)
 	int ret;
 
 	if (!sock->ops->checkpoint) {
-		ckpt_write_err(ctx, "TEVP", "socket: proto_ops",
+		ckpt_err(ctx, "%(T)%(E)%(V)%(P)socket: proto_ops\n",
 			       -ENOSYS, sock->ops, sock);
 		return -ENOSYS;
 	}
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
index 8b7cb22..055f0a5 100644
--- a/net/unix/checkpoint.c
+++ b/net/unix/checkpoint.c
@@ -126,8 +126,9 @@ int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
 
 	if ((sock->sk->sk_state == TCP_LISTEN) &&
 	    !skb_queue_empty(&sock->sk->sk_receive_queue)) {
-		ckpt_write_err(ctx, "TEP", "af_unix: listen with pending peers",
-			       -EBUSY, sock);
+		ckpt_err(ctx,
+			 "%(T)%(E)%(P)af_unix: listen with pending peers\n",
+			 -EBUSY, sock);
 		return -EBUSY;
 	}
 
-- 
1.6.1
