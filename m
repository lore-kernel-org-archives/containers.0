From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Change select uses of ckpt_debug() to ckpt_err() in net c/r
Date: Tue, 17 Nov 2009 07:31:56 -0800
Message-ID: <1258471916-30535-1-git-send-email-danms@us.ibm.com>
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

This patch changes all the net c/r ckpt_debug() calls that describe a
fatal error that is about to derail the checkpoint or restart to
ckpt_err() calls.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/checkpoint.c      |   83 ++++++++++++++++++++++++++++++-------------------
 net/ipv4/checkpoint.c |    2 +-
 net/unix/checkpoint.c |   30 ++++++++++-------
 3 files changed, 70 insertions(+), 45 deletions(-)

diff --git a/net/checkpoint.c b/net/checkpoint.c
index 9081c55..23dbad3 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -119,26 +119,30 @@ int sock_restore_header_info(struct sk_buff *skb,
 			     struct sock *sk)
 {
 	if (h->mac_header + h->mac_len != h->network_header) {
-		ckpt_debug("skb mac_header %u+%u != network header %u\n",
-			   h->mac_header, h->mac_len, h->network_header);
+		ckpt_err(ctx, -EINVAL,
+			 "skb mac_header %u+%u != network header %u\n",
+			 h->mac_header, h->mac_len, h->network_header);
 		return -EINVAL;
 	}
 
 	if (h->network_header > h->lin_len) {
-		ckpt_debug("skb network header %u > linear length %u\n",
-			   h->network_header, h->lin_len);
+		ckpt_err(ctx, -EINVAL,
+			 "skb network header %u > linear length %u\n",
+			 h->network_header, h->lin_len);
 		return -EINVAL;
 	}
 
 	if (h->transport_header > h->lin_len) {
-		ckpt_debug("skb transport header %u > linear length %u\n",
-			   h->transport_header, h->lin_len);
+		ckpt_err(ctx, -EINVAL,
+			 "skb transport header %u > linear length %u\n",
+			 h->transport_header, h->lin_len);
 		return -EINVAL;
 	}
 
 	if (h->skb_len > SKB_MAX_ALLOC) {
-		ckpt_debug("skb total length %u larger than max of %lu\n",
-			   h->skb_len, SKB_MAX_ALLOC);
+		ckpt_err(ctx, -EINVAL,
+			 "skb total length %u larger than max of %lu\n",
+			 h->skb_len, SKB_MAX_ALLOC);
 		return -EINVAL;
 	}
 
@@ -178,7 +182,8 @@ static int sock_restore_skb_frag(struct ckpt_ctx *ctx,
 		return fraglen;
 
 	if (fraglen > PAGE_SIZE) {
-		ckpt_debug("skb frag size %i > PAGE_SIZE\n", fraglen);
+		ckpt_err(ctx, -EINVAL,
+			 "skb frag size %i > PAGE_SIZE\n", fraglen);
 		return -EINVAL;
 	}
 
@@ -191,8 +196,9 @@ static int sock_restore_skb_frag(struct ckpt_ctx *ctx,
 	kunmap(page);
 
 	if (ret) {
-		ckpt_debug("failed to read fragment: %i\n", ret);
 		ret = -EINVAL;
+		ckpt_err(ctx, ret,
+			 "failed to read fragment: %i\n", ret);
 		__free_page(page);
 	} else {
 		ckpt_debug("read %i for fragment %i\n", fraglen, frag_idx);
@@ -215,19 +221,22 @@ struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx,
 		return (struct sk_buff *)h;
 
 	if (h->lin_len > SKB_MAX_ALLOC) {
-		ckpt_debug("socket linear buffer too big (%u > %lu)\n",
-			   h->lin_len, SKB_MAX_ALLOC);
 		ret = -ENOSPC;
+		ckpt_err(ctx, ret,
+			 "socket linear buffer too big (%u > %lu)\n",
+			 h->lin_len, SKB_MAX_ALLOC);
 		goto out;
 	} else if (h->frg_len > SKB_MAX_ALLOC) {
-		ckpt_debug("socket frag size too big (%u > %lu\n",
-			   h->frg_len, SKB_MAX_ALLOC);
 		ret = -ENOSPC;
+		ckpt_err(ctx, ret,
+			 "socket frag size too big (%u > %lu\n",
+			 h->frg_len, SKB_MAX_ALLOC);
 		goto out;
 	} else if (h->nr_frags >= MAX_SKB_FRAGS) {
-		ckpt_debug("socket frag count too big (%u > %lu\n",
-			   h->nr_frags, MAX_SKB_FRAGS);
 		ret = -ENOSPC;
+		ckpt_err(ctx, ret,
+			 "socket frag count too big (%u > %lu\n",
+			 h->nr_frags, MAX_SKB_FRAGS);
 		goto out;
 	}
 
@@ -240,9 +249,8 @@ struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx,
 	ret = _ckpt_read_obj_type(ctx, skb_put(skb, h->lin_len),
 				  h->lin_len, CKPT_HDR_BUFFER);
 	ckpt_debug("read linear skb length %u: %i\n", h->lin_len, ret);
-	if (ret < 0) {
+	if (ret < 0)
 		goto out;
-	}
 
 	for (i = 0; i < h->nr_frags; i++) {
 		ret = sock_restore_skb_frag(ctx, skb, i);
@@ -254,9 +262,10 @@ struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx,
 	}
 
 	if (h->frg_len != 0) {
-		ckpt_debug("length %u remaining after reading frags\n",
-			   h->frg_len);
 		ret = -EINVAL;
+		ckpt_err(ctx, ret,
+			 "length %u remaining after reading frags\n",
+			 h->frg_len);
 		goto out;
 	}
 
@@ -651,32 +660,38 @@ static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
 		return -EINVAL;
 
 	if (CKPT_COPY_SOPT(op, sk, SO_REUSEADDR, &h->sock_common.reuse)) {
-		ckpt_debug("Failed to set SO_REUSEADDR");
+		ckpt_err(ctx, -EINVAL,
+			 "Failed to set SO_REUSEADDR");
 		return -EINVAL;
 	}
 
 	if (CKPT_COPY_SOPT(op, sk, SO_PRIORITY, &h->sock.priority)) {
-		ckpt_debug("Failed to set SO_PRIORITY");
+		ckpt_err(ctx, -EINVAL,
+			 "Failed to set SO_PRIORITY");
 		return -EINVAL;
 	}
 
 	if (CKPT_COPY_SOPT(op, sk, SO_RCVLOWAT, &h->sock.rcvlowat)) {
-		ckpt_debug("Failed to set SO_RCVLOWAT");
+		ckpt_err(ctx, -EINVAL,
+			 "Failed to set SO_RCVLOWAT");
 		return -EINVAL;
 	}
 
 	if (CKPT_COPY_SOPT(op, sk, SO_LINGER, &h->sock.linger)) {
-		ckpt_debug("Failed to set SO_LINGER");
+		ckpt_err(ctx, -EINVAL,
+			 "Failed to set SO_LINGER");
 		return -EINVAL;
 	}
 
 	if (sock_copy_timeval(op, sk, SO_SNDTIMEO, &h->sock.sndtimeo)) {
-		ckpt_debug("Failed to set SO_SNDTIMEO");
+		ckpt_err(ctx, -EINVAL,
+			 "Failed to set SO_SNDTIMEO");
 		return -EINVAL;
 	}
 
 	if (sock_copy_timeval(op, sk, SO_RCVTIMEO, &h->sock.rcvtimeo)) {
-		ckpt_debug("Failed to set SO_RCVTIMEO");
+		ckpt_err(ctx, -EINVAL,
+			 "Failed to set SO_RCVTIMEO");
 		return -EINVAL;
 	}
 
@@ -697,16 +712,19 @@ static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
 
 	if ((h->socket.state == SS_CONNECTED) &&
 	    (h->sock.state != TCP_ESTABLISHED)) {
-		ckpt_debug("socket/sock in inconsistent state: %i/%i",
-			   h->socket.state, h->sock.state);
+		ckpt_err(ctx, -EINVAL,
+			 "socket/sock in inconsistent state: %i/%i",
+			 h->socket.state, h->sock.state);
 		return -EINVAL;
 	} else if ((h->sock.state < TCP_ESTABLISHED) ||
 		   (h->sock.state >= TCP_MAX_STATES)) {
-		ckpt_debug("sock in invalid state: %i", h->sock.state);
+		ckpt_err(ctx, -EINVAL,
+			 "sock in invalid state: %i", h->sock.state);
 		return -EINVAL;
 	} else if (h->socket.state > SS_DISCONNECTING) {
-		ckpt_debug("socket in invalid state: %i",
-			   h->socket.state);
+		ckpt_err(ctx, -EINVAL,
+			 "socket in invalid state: %i",
+			 h->socket.state);
 		return -EINVAL;
 	}
 
@@ -913,8 +931,9 @@ struct sock *do_sock_restore(struct ckpt_ctx *ctx)
 		goto err;
 
 	if (!sock->ops->restore) {
-		ckpt_debug("proto_ops lacks checkpoint: %pS\n", sock->ops);
 		ret = -EINVAL;
+		ckpt_err(ctx, ret,
+			 "proto_ops lacks checkpoint: %pS\n", sock->ops);
 		goto err;
 	}
 
diff --git a/net/ipv4/checkpoint.c b/net/ipv4/checkpoint.c
index 777fc0b..2410415 100644
--- a/net/ipv4/checkpoint.c
+++ b/net/ipv4/checkpoint.c
@@ -336,8 +336,8 @@ static int inet_read_buffers(struct ckpt_ctx *ctx,
 			goto out;
 
 		if (ret > h->total_bytes) {
-			ckpt_debug("Buffers exceeded claim");
 			ret = -EINVAL;
+			ckpt_err(ctx, ret, "Buffers exceeded claim");
 			goto out;
 		}
 
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
index c6a1b27..23040ce 100644
--- a/net/unix/checkpoint.c
+++ b/net/unix/checkpoint.c
@@ -49,13 +49,15 @@ static int unix_deferred_join(void *data)
 
 	src = ckpt_obj_fetch(ctx, dq->src_objref, CKPT_OBJ_SOCK);
 	if (!src) {
-		ckpt_debug("Missing src sock ref %i\n", dq->src_objref);
+		ckpt_err(ctx, -EINVAL,
+			 "Missing src sock ref %i\n", dq->src_objref);
 		return -EINVAL;
 	}
 
 	dst = ckpt_obj_fetch(ctx, dq->dst_objref, CKPT_OBJ_SOCK);
 	if (!src) {
-		ckpt_debug("Missing dst sock ref %i\n", dq->dst_objref);
+		ckpt_err(ctx, -EINVAL,
+			 "Missing dst sock ref %i\n", dq->dst_objref);
 		return -EINVAL;
 	}
 
@@ -210,13 +212,14 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
 		return PTR_ERR(h);
 
 	if (h->lin_len > SKB_MAX_ALLOC) {
-		ckpt_debug("socket buffer too big (%u > %lu)\n",
-			   h->lin_len, SKB_MAX_ALLOC);
 		ret = -EINVAL;
+		ckpt_err(ctx, ret,
+			 "socket buffer too big (%u > %lu)\n",
+			 h->lin_len, SKB_MAX_ALLOC);
 		goto out;
 	} else if (h->nr_frags != 0) {
-		ckpt_debug("unix socket claims to have fragments\n");
 		ret = -EINVAL;
+		ckpt_err(ctx, ret, "unix socket claims to have fragments\n");
 		goto out;
 	}
 
@@ -250,13 +253,14 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
 		struct sock *pr;
 		pr = ckpt_obj_fetch(ctx, h->pr_objref, CKPT_OBJ_SOCK);
 		if (IS_ERR(pr)) {
-			ckpt_debug("Failed to get our peer: %li\n", PTR_ERR(pr));
 			ret = PTR_ERR(pr);
+			ckpt_err(ctx, ret,
+				 "Failed to get our peer: %li\n", PTR_ERR(pr));
 			goto out;
 		}
 		ret = unix_join(sk, pr);
 		if (ret < 0) {
-			ckpt_debug("Failed to join: %i\n", ret);
+			ckpt_err(ctx, ret, "Failed to join: %i\n", ret);
 			goto out;
 		}
 	}
@@ -317,8 +321,8 @@ static int unix_read_buffers(struct ckpt_ctx *ctx,
 			goto out;
 
 		if (ret > h->total_bytes) {
-			ckpt_debug("Buffers exceeded claim");
 			ret = -EINVAL;
+			ckpt_err(ctx, ret, "Buffers exceeded claim");
 			goto out;
 		}
 
@@ -343,7 +347,7 @@ static int unix_deferred_restore_buffers(void *data)
 
 	sk = ckpt_obj_fetch(ctx, dq->sk_objref, CKPT_OBJ_SOCK);
 	if (!sk) {
-		ckpt_debug("Missing sock ref %i\n", dq->sk_objref);
+		ckpt_err(ctx, -EINVAL, "Missing sock ref %i\n", dq->sk_objref);
 		return -EINVAL;
 	}
 
@@ -427,8 +431,9 @@ static int unix_restore_connected(struct ckpt_ctx *ctx,
 		sk->sk_peercred.uid = un->peercred_uid;
 		sk->sk_peercred.gid = un->peercred_gid;
 	} else {
-		ckpt_debug("peercred %i:%i would require setuid",
-			   un->peercred_uid, un->peercred_gid);
+		ckpt_err(ctx, -EPERM,
+			 "peercred %i:%i would require setuid",
+			 un->peercred_uid, un->peercred_gid);
 		return -EPERM;
 	}
 
@@ -631,7 +636,8 @@ int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
 	else if (h->sock.state == TCP_LISTEN)
 		ret = sock->ops->listen(sock, h->sock.backlog);
 	else
-		ckpt_debug("unsupported UNIX socket state %i\n", h->sock.state);
+		ckpt_err(ctx, ret,
+			 "unsupported UNIX socket state %i\n", h->sock.state);
  out:
 	ckpt_hdr_put(ctx, un);
 	kfree(cwd);
-- 
1.6.2.5
