From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/4] Set socket flags on restore using sock_setsockopt() where
	possible
Date: Thu, 13 Aug 2009 12:29:07 -0700
Message-ID: <1250191750-3864-2-git-send-email-danms@us.ibm.com>
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

Fail on the TIMESTAMPING_* flags for the moment, with a TODO in place to
handle them later.

Also remove other explicit flag checks because they're no longer copied
blindly into the socket object, so existing checks will be sufficient.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/checkpoint.c |  117 +++++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 103 insertions(+), 14 deletions(-)

diff --git a/net/checkpoint.c b/net/checkpoint.c
index ebbd68a..13c46c1 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -179,10 +179,6 @@ static int sock_cptrst_verify(struct ckpt_hdr_socket *h)
 	if (!ckpt_validate_errno(h->sock.err))
 		return -EINVAL;
 
-	/* None of our supported types use this flag */
-	if (h->sock.flags & SOCK_DESTROY)
-		return -EINVAL;
-
 	return 0;
 }
 
@@ -239,15 +235,99 @@ static int sock_cptrst_bufopts(int op, struct sock *sock,
 	return 0;
 }
 
+static int sock_rst_flags(struct socket *sock,
+			  struct ckpt_hdr_socket *h)
+{
+	int ret;
+	int v = 1;
+	unsigned long sk_flags = h->sock.flags;
+	unsigned long sock_flags = h->socket.flags;
+
+	if (test_and_clear_bit(SOCK_URGINLINE, &sk_flags)) {
+		ret = sock_setsockopt(sock, SOL_SOCKET, SO_OOBINLINE,
+				      (char *)&v, sizeof(v));
+		if (ret)
+			return ret;
+	}
+
+	if (test_and_clear_bit(SOCK_KEEPOPEN, &sk_flags)) {
+		ret = sock_setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE,
+				      (char *)&v, sizeof(v));
+		if (ret)
+			return ret;
+	}
+
+	if (test_and_clear_bit(SOCK_BROADCAST, &sk_flags)) {
+		ret = sock_setsockopt(sock, SOL_SOCKET, SO_BROADCAST,
+				      (char *)&v, sizeof(v));
+		if (ret)
+			return ret;
+	}
+
+	if (test_and_clear_bit(SOCK_RCVTSTAMP, &sk_flags)) {
+		ret = sock_setsockopt(sock, SOL_SOCKET, SO_TIMESTAMP,
+				      (char *)&v, sizeof(v));
+		if (ret)
+			return ret;
+	}
+
+	if (test_and_clear_bit(SOCK_RCVTSTAMPNS, &sk_flags)) {
+		ret = sock_setsockopt(sock, SOL_SOCKET, SO_TIMESTAMPNS,
+				      (char *)&v, sizeof(v));
+		if (ret)
+			return ret;
+	}
+
+	if (test_and_clear_bit(SOCK_DBG, &sk_flags)) {
+		ret = sock_setsockopt(sock, SOL_SOCKET, SO_DEBUG,
+				      (char *)&v, sizeof(v));
+		if (ret)
+			return ret;
+	}
+
+	if (test_and_clear_bit(SOCK_LOCALROUTE, &sk_flags)) {
+		ret = sock_setsockopt(sock, SOL_SOCKET, SO_DONTROUTE,
+				      (char *)&v, sizeof(v));
+		if (ret)
+			return ret;
+	}
+
+	if (test_and_clear_bit(SOCK_PASSCRED, &sock_flags)) {
+		ret = sock_setsockopt(sock, SOL_SOCKET, SO_PASSCRED,
+				      (char *)&v, sizeof(v));
+		if (ret)
+			return ret;
+	}
+
+	/* TODO: Handle SOCK_TIMESTAMPING_* flags */
+	if (test_bit(SOCK_TIMESTAMPING_TX_HARDWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_TX_SOFTWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_RX_HARDWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_RX_SOFTWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_SOFTWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_RAW_HARDWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_SYS_HARDWARE, &sk_flags)) {
+		ckpt_debug("SOF_TIMESTAMPING_* flags are not supported\n");
+		return -ENOSYS;
+	}
+
+	/* Anything that is still set in the flags that isn't part of
+	 * our protocol's default set, indicates an error
+	 */
+	if (sk_flags & ~sock->sk->sk_flags) {
+		ckpt_debug("Unhandled sock flags: %lx\n", sk_flags);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static int sock_cptrst(struct ckpt_ctx *ctx,
 		       struct sock *sock,
 		       struct ckpt_hdr_socket *h,
 		       int op)
 {
-	if (sock->sk_socket) {
-		CKPT_COPY(op, h->socket.flags, sock->sk_socket->flags);
-		CKPT_COPY(op, h->socket.state, sock->sk_socket->state);
-	}
+	CKPT_COPY(op, h->socket.state, sock->sk_socket->state);
 
 	CKPT_COPY(op, h->sock_common.bound_dev_if, sock->sk_bound_dev_if);
 	CKPT_COPY(op, h->sock_common.family, sock->sk_family);
@@ -262,12 +342,6 @@ static int sock_cptrst(struct ckpt_ctx *ctx,
 	CKPT_COPY(op, h->sock.state, sock->sk_state);
 	CKPT_COPY(op, h->sock.backlog, sock->sk_max_ack_backlog);
 
-	/* TODO:
-	 * Break out setting each of the flags to use setsockopt() or
-	 * perform proper security check
-	 */
-	CKPT_COPY(op, h->sock.flags, sock->sk_flags);
-
 	if (sock_cptrst_bufopts(op, sock, h))
 		return -EINVAL;
 
@@ -301,6 +375,21 @@ static int sock_cptrst(struct ckpt_ctx *ctx,
 		return -EINVAL;
 	}
 
+	if (op == CKPT_CPT) {
+		h->sock.flags = sock->sk_flags;
+		h->socket.flags = sock->sk_socket->flags;
+	} else {
+		int ret;
+		mm_segment_t old_fs;
+
+		old_fs = get_fs();
+		set_fs(KERNEL_DS);
+		ret = sock_rst_flags(sock->sk_socket, h);
+		set_fs(old_fs);
+		if (ret)
+			return ret;
+	}
+
 	if ((h->socket.state == SS_CONNECTED) &&
 	    (h->sock.state != TCP_ESTABLISHED)) {
 		ckpt_debug("socket/sock in inconsistent state: %i/%i",
-- 
1.6.0.4
