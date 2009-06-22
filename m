From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Add AF_INET c/r support
Date: Mon, 22 Jun 2009 12:12:56 -0700
Message-ID: <1245697976-29159-1-git-send-email-danms@us.ibm.com>
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
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch adds AF_INET c/r support based on the framework established in
my AF_UNIX patch.  I've tested it by checkpointing a single app with a
pair of sockets connected over loopback.

I expect a pile of comments :)

A couple points about the operation:

 1. In order to properly hook up the established sockets with the matching
    listening parent socket, I added a new list to the ckpt_ctx and run the
    parent attachment in the deferqueue at the end of the restart process.
 2. I don't do anything to redirect or freeze traffic flowing to or from the
    remote system (to prevent a RST from breaking things).  I expect that
    userspace will bring down a veth device or freeze traffic to the remote
    system to handle this case.

Cc: Oren Laaden <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/sys.c                 |    2 +
 include/linux/checkpoint_hdr.h   |    1 +
 include/linux/checkpoint_types.h |    2 +
 include/linux/socket.h           |   95 ++++++++++
 net/checkpoint.c                 |  369 +++++++++++++++++++++++++++++++++-----
 5 files changed, 428 insertions(+), 41 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 38a5299..b6f18ea 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -242,6 +242,8 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
 	init_waitqueue_head(&ctx->waitq);
 
+	INIT_LIST_HEAD(&ctx->listen_sockets);
+
 	err = -EBADF;
 	ctx->file = fget(fd);
 	if (!ctx->file)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 46285f8..0a19767 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -87,6 +87,7 @@ enum {
 	CKPT_HDR_SOCKET_BUFFERS,
 	CKPT_HDR_SOCKET_BUFFER,
 	CKPT_HDR_SOCKET_UN,
+	CKPT_HDR_SOCKET_IN,
 
 	CKPT_HDR_TAIL = 9001,
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 27fbe26..d7db190 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -60,6 +60,8 @@ struct ckpt_ctx {
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
 
+	struct list_head listen_sockets;/* listening parent sockets */
+
 	/* [multi-process checkpoint] */
 	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
 	int nr_tasks;                   /* size of tasks array */
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 3b5be70..7b17371 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -332,6 +332,101 @@ struct ckpt_hdr_socket_un {
 	__u8 linked;
 } __attribute__ ((aligned(8)));
 
+struct ckpt_hdr_socket_in {
+	struct ckpt_hdr h;
+
+	__u32 daddr;
+	__u32 rcv_saddr;
+	__u32 saddr;
+	__u16 dport;
+	__u16 num;
+	__u16 sport;
+	__s16 uc_ttl;
+	__u16 cmsg_flags;
+	__u16 __pad;
+
+	struct {
+		__u64 timeout;
+		__u32 ato;
+		__u32 lrcvtime;
+		__u16 last_seg_size;
+		__u16 rcv_mss;
+		__u8 pending;
+		__u8 quick;
+		__u8 pingpong;
+		__u8 blocked;
+	} icsk_ack __attribute__ ((aligned(8)));
+
+	/* FIXME: Skipped opt, tos, multicast, cork settings */
+
+	struct {
+		__u64 last_synq_overflow;
+
+		__u32 rcv_nxt;
+		__u32 copied_seq;
+		__u32 rcv_wup;
+		__u32 snd_nxt;
+		__u32 snd_una;
+		__u32 snd_sml;
+		__u32 rcv_tstamp;
+		__u32 lsndtime;
+
+		__u32 snd_wl1;
+		__u32 snd_wnd;
+		__u32 max_window;
+		__u32 mss_cache;
+		__u32 window_clamp;
+		__u32 rcv_ssthresh;
+		__u32 frto_highmark;
+
+		__u32 srtt;
+		__u32 mdev;
+		__u32 mdev_max;
+		__u32 rttvar;
+		__u32 rtt_seq;
+
+		__u32 packets_out;
+		__u32 retrans_out;
+
+		__u32 snd_up;
+		__u32 rcv_wnd;
+		__u32 write_seq;
+		__u32 pushed_seq;
+		__u32 lost_out;
+		__u32 sacked_out;
+		__u32 fackets_out;
+		__u32 tso_deferred;
+		__u32 bytes_acked;
+
+		__s32 lost_cnt_hint;
+		__u32 retransmit_high;
+
+		__u32 lost_retrans_low;
+
+		__u32 prior_ssthresh;
+		__u32 high_seq;
+
+		__u32 retrans_stamp;
+		__u32 undo_marker;
+		__s32 undo_retrans;
+		__u32 total_retrans;
+
+		__u32 urg_seq;
+		__u32 keepalive_time;
+		__u32 keepalive_intvl;
+
+		__u16 urg_data;
+		__u16 advmss;
+		__u8 frto_counter;
+		__u8 nonagle;
+
+		__u8 ecn_flags;
+		__u8 reordering;
+
+		__u8 keepalive_probes;
+	} tcp __attribute__ ((aligned(8)));
+} __attribute__ ((aligned(8)));
+
 struct ckpt_hdr_socket {
 	struct ckpt_hdr h;
 
diff --git a/net/checkpoint.c b/net/checkpoint.c
index fd47485..9aa97bc 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -14,11 +14,61 @@
 #include <linux/file.h>
 
 #include <net/af_unix.h>
+#include <net/tcp.h>
 #include <net/tcp_states.h>
+#include <linux/tcp.h>
+#include <linux/in.h>
 
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/namei.h>
+#include <linux/deferqueue.h>
+
+struct ckpt_parent_sock {
+	struct sock *sock;
+	__u32 oref;
+	struct list_head list;
+};
+
+static int sock_add_parent(struct ckpt_ctx *ctx, struct sock *sock)
+{
+	struct ckpt_parent_sock *parent;
+	__u32 objref;
+	int new;
+
+	objref = ckpt_obj_lookup_add(ctx, sock, CKPT_OBJ_SOCK, &new);
+	if (!new)
+		return 0;
+	else if (objref < 0)
+		return objref;
+
+	parent = kmalloc(sizeof(*parent), GFP_KERNEL);
+	if (!parent)
+		return -ENOMEM;
+
+	parent->sock = sock;
+	parent->oref = objref;
+	INIT_LIST_HEAD(&parent->list);
+
+	list_add(&parent->list, &ctx->listen_sockets);
+
+	return 0;
+}
+
+static struct sock *sock_get_parent(struct ckpt_ctx *ctx, struct sock *sock)
+{
+	struct ckpt_parent_sock *parent;
+	struct inet_sock *c = inet_sk(sock);
+
+	list_for_each_entry(parent, &ctx->listen_sockets, list) {
+		struct inet_sock *p = inet_sk(parent->sock);
+
+		if (c->sport == p->sport)
+			return parent->sock;
+	}
+
+	return NULL;
+}
 
 /* Size of an empty struct sockaddr_un */
 #define UNIX_LEN_EMPTY 2
@@ -47,17 +97,23 @@ static int sock_copy_buffers(struct sk_buff_head *from, struct sk_buff_head *to)
 }
 
 static int __sock_write_buffers(struct ckpt_ctx *ctx,
+				uint16_t family,
 				struct sk_buff_head *queue)
 {
 	struct sk_buff *skb;
 	int ret = 0;
 
 	skb_queue_walk(queue, skb) {
-		if (UNIXCB(skb).fp) {
+		if ((family == AF_UNIX) && UNIXCB(skb).fp) {
 			ckpt_debug("unsupported fd-passing skb found\n");
 			return -EBUSY;
 		}
 
+		if (skb_shinfo(skb)->nr_frags) {
+			ckpt_debug("socket has fragments in flight\n");
+			return -EBUSY;
+		}
+
 		ret = ckpt_write_obj_type(ctx, skb->data, skb->len,
 					  CKPT_HDR_SOCKET_BUFFER);
 		if (ret)
@@ -67,7 +123,9 @@ static int __sock_write_buffers(struct ckpt_ctx *ctx,
 	return 0;
 }
 
-static int sock_write_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
+static int sock_write_buffers(struct ckpt_ctx *ctx,
+			      uint16_t family,
+			      struct sk_buff_head *queue)
 {
 	struct ckpt_hdr_socket_buffer *h;
 	struct sk_buff_head tmpq;
@@ -87,7 +145,7 @@ static int sock_write_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
 
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
 	if (!ret)
-		ret = __sock_write_buffers(ctx, &tmpq);
+		ret = __sock_write_buffers(ctx, family, &tmpq);
 
  out:
 	ckpt_hdr_put(ctx, h);
@@ -96,48 +154,117 @@ static int sock_write_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
 	return ret;
 }
 
-static int sock_un_checkpoint(struct ckpt_ctx *ctx,
-			      struct sock *sock,
-			      struct ckpt_hdr_socket *h)
+static int sock_in_tcp_cptrst(struct ckpt_ctx *ctx,
+			      struct tcp_sock *sk,
+			      struct ckpt_hdr_socket_in *hh,
+			      int op)
 {
-	struct unix_sock *sk = unix_sk(sock);
-	struct unix_sock *pr = unix_sk(sk->peer);
-	struct ckpt_hdr_socket_un *un;
-	int new;
-	int ret = -ENOMEM;
-
-	if ((sock->sk_state == TCP_LISTEN) &&
-	    !skb_queue_empty(&sock->sk_receive_queue)) {
-		ckpt_debug("listening socket has unaccepted peers");
-		return -EBUSY;
-	}
-
-	un = ckpt_hdr_get_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UN);
-	if (!un)
-		goto out;
-
-	un->linked = sk->dentry && (sk->dentry->d_inode->i_nlink > 0);
+	CKPT_COPY(op, hh->tcp.rcv_nxt, sk->rcv_nxt);
+	CKPT_COPY(op, hh->tcp.copied_seq, sk->copied_seq);
+	CKPT_COPY(op, hh->tcp.rcv_wup, sk->rcv_wup);
+	CKPT_COPY(op, hh->tcp.snd_nxt, sk->snd_nxt);
+	CKPT_COPY(op, hh->tcp.snd_una, sk->snd_una);
+	CKPT_COPY(op, hh->tcp.snd_sml, sk->snd_sml);
+	CKPT_COPY(op, hh->tcp.rcv_tstamp, sk->rcv_tstamp);
+	CKPT_COPY(op, hh->tcp.lsndtime, sk->lsndtime);
+
+	CKPT_COPY(op, hh->tcp.snd_wl1, sk->snd_wl1);
+	CKPT_COPY(op, hh->tcp.snd_wnd, sk->snd_wnd);
+	CKPT_COPY(op, hh->tcp.max_window, sk->max_window);
+	CKPT_COPY(op, hh->tcp.mss_cache, sk->mss_cache);
+	CKPT_COPY(op, hh->tcp.window_clamp, sk->window_clamp);
+	CKPT_COPY(op, hh->tcp.rcv_ssthresh, sk->rcv_ssthresh);
+	CKPT_COPY(op, hh->tcp.frto_highmark, sk->frto_highmark);
+	CKPT_COPY(op, hh->tcp.advmss, sk->advmss);
+	CKPT_COPY(op, hh->tcp.frto_counter, sk->frto_counter);
+	CKPT_COPY(op, hh->tcp.nonagle, sk->nonagle);
+
+	CKPT_COPY(op, hh->tcp.srtt, sk->srtt);
+	CKPT_COPY(op, hh->tcp.mdev, sk->mdev);
+	CKPT_COPY(op, hh->tcp.mdev_max, sk->mdev_max);
+	CKPT_COPY(op, hh->tcp.rttvar, sk->rttvar);
+	CKPT_COPY(op, hh->tcp.rtt_seq, sk->rtt_seq);
+
+	CKPT_COPY(op, hh->tcp.packets_out, sk->packets_out);
+	CKPT_COPY(op, hh->tcp.retrans_out, sk->retrans_out);
+
+	CKPT_COPY(op, hh->tcp.urg_data, sk->urg_data);
+	CKPT_COPY(op, hh->tcp.ecn_flags, sk->ecn_flags);
+	CKPT_COPY(op, hh->tcp.reordering, sk->reordering);
+	CKPT_COPY(op, hh->tcp.snd_up, sk->snd_up);
+
+	CKPT_COPY(op, hh->tcp.keepalive_probes, sk->keepalive_probes);
+
+	CKPT_COPY(op, hh->tcp.rcv_wnd, sk->rcv_wnd);
+	CKPT_COPY(op, hh->tcp.write_seq, sk->write_seq);
+	CKPT_COPY(op, hh->tcp.pushed_seq, sk->pushed_seq);
+	CKPT_COPY(op, hh->tcp.lost_out, sk->lost_out);
+	CKPT_COPY(op, hh->tcp.sacked_out, sk->sacked_out);
+	CKPT_COPY(op, hh->tcp.fackets_out, sk->fackets_out);
+	CKPT_COPY(op, hh->tcp.tso_deferred, sk->tso_deferred);
+	CKPT_COPY(op, hh->tcp.bytes_acked, sk->bytes_acked);
+
+	CKPT_COPY(op, hh->tcp.lost_cnt_hint, sk->lost_cnt_hint);
+	CKPT_COPY(op, hh->tcp.retransmit_high, sk->retransmit_high);
+
+	CKPT_COPY(op, hh->tcp.lost_retrans_low, sk->lost_retrans_low);
+
+	CKPT_COPY(op, hh->tcp.prior_ssthresh, sk->prior_ssthresh);
+	CKPT_COPY(op, hh->tcp.high_seq, sk->high_seq);
+
+	CKPT_COPY(op, hh->tcp.retrans_stamp, sk->retrans_stamp);
+	CKPT_COPY(op, hh->tcp.undo_marker, sk->undo_marker);
+	CKPT_COPY(op, hh->tcp.undo_retrans, sk->undo_retrans);
+	CKPT_COPY(op, hh->tcp.total_retrans, sk->total_retrans);
+
+	CKPT_COPY(op, hh->tcp.urg_seq, sk->urg_seq);
+	CKPT_COPY(op, hh->tcp.keepalive_time, sk->keepalive_time);
+	CKPT_COPY(op, hh->tcp.keepalive_intvl, sk->keepalive_intvl);
+
+	CKPT_COPY(op, hh->tcp.last_synq_overflow, sk->last_synq_overflow);
 
-	un->this = ckpt_obj_lookup_add(ctx, sk, CKPT_OBJ_SOCK, &new);
-	if (un->this < 0)
-		goto out;
+	return 0;
+}
 
-	if (sk->peer)
-		un->peer = ckpt_obj_lookup_add(ctx, pr, CKPT_OBJ_SOCK, &new);
-	else
-		un->peer = 0;
+static int sock_in_cptrst(struct ckpt_ctx *ctx,
+			  struct sock *sock,
+			  struct ckpt_hdr_socket_in *hh,
+			  int op)
+{
+	struct inet_sock *sk = inet_sk(sock);
+	struct inet_connection_sock *icsk = inet_csk(sock);
+	int ret;
 
-	if (un->peer < 0) {
-		ret = un->peer;
-		goto out;
+	CKPT_COPY(op, hh->daddr, sk->daddr);
+	CKPT_COPY(op, hh->rcv_saddr, sk->rcv_saddr);
+	CKPT_COPY(op, hh->dport, sk->dport);
+	CKPT_COPY(op, hh->num, sk->num);
+	CKPT_COPY(op, hh->saddr, sk->saddr);
+	CKPT_COPY(op, hh->sport, sk->sport);
+	CKPT_COPY(op, hh->uc_ttl, sk->uc_ttl);
+	CKPT_COPY(op, hh->cmsg_flags, sk->cmsg_flags);
+
+	CKPT_COPY(op, hh->icsk_ack.pending, icsk->icsk_ack.pending);
+	CKPT_COPY(op, hh->icsk_ack.quick, icsk->icsk_ack.quick);
+	CKPT_COPY(op, hh->icsk_ack.pingpong, icsk->icsk_ack.pingpong);
+	CKPT_COPY(op, hh->icsk_ack.blocked, icsk->icsk_ack.blocked);
+	CKPT_COPY(op, hh->icsk_ack.ato, icsk->icsk_ack.ato);
+	CKPT_COPY(op, hh->icsk_ack.timeout, icsk->icsk_ack.timeout);
+	CKPT_COPY(op, hh->icsk_ack.lrcvtime, icsk->icsk_ack.lrcvtime);
+	CKPT_COPY(op,
+		hh->icsk_ack.last_seg_size, icsk->icsk_ack.last_seg_size);
+	CKPT_COPY(op, hh->icsk_ack.rcv_mss, icsk->icsk_ack.rcv_mss);
+
+	if (sock->sk_protocol == IPPROTO_TCP)
+		ret = sock_in_tcp_cptrst(ctx, tcp_sk(sock), hh, op);
+	else if (sock->sk_protocol == IPPROTO_UDP)
+		ret = 0;
+	else {
+		ckpt_debug("unknown socket protocol type %d\n",
+			   sock->sk_protocol);
+		ret = -EINVAL;
 	}
 
-	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
-	if (ret < 0)
-		goto out;
-
-	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) un);
- out:
 	return ret;
 }
 
@@ -196,6 +323,75 @@ static int sock_cptrst(struct ckpt_ctx *ctx,
 	return 0;
 }
 
+static int sock_in_checkpoint(struct ckpt_ctx *ctx,
+			      struct sock *sock,
+			      struct ckpt_hdr_socket *h)
+{
+	int ret = -EINVAL;
+	struct ckpt_hdr_socket_in *in;
+
+	in = ckpt_hdr_get_type(ctx, sizeof(*in), CKPT_HDR_SOCKET_IN);
+	if (!in)
+		goto out;
+
+	ret = sock_in_cptrst(ctx, sock, in, CKPT_CPT);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) in);
+ out:
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
 int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 {
 	struct socket *socket = file->private_data;
@@ -230,6 +426,11 @@ int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 		ret = sock_un_checkpoint(ctx, sock, h);
 		if (ret)
 			goto out;
+	} else if (sock->sk_family == AF_INET) {
+		ret = sock_in_checkpoint(ctx, sock, h);
+		ckpt_debug("in_checkpoint: %i\n", ret);
+		if (ret)
+			goto out;
 	} else {
 		ckpt_debug("unsupported socket type %i\n",
 			   sock->sk_family);
@@ -237,11 +438,11 @@ int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 		goto out;
 	}
 
-	ret = sock_write_buffers(ctx, &sock->sk_receive_queue);
+	ret = sock_write_buffers(ctx, sock->sk_family, &sock->sk_receive_queue);
 	if (ret)
 		goto out;
 
-	ret = sock_write_buffers(ctx, &sock->sk_write_queue);
+	ret = sock_write_buffers(ctx, sock->sk_family, &sock->sk_write_queue);
 	if (ret)
 		goto out;
 
@@ -452,6 +653,89 @@ static int sock_un_restart(struct ckpt_ctx *ctx,
 	return ret;
 }
 
+struct dq_sock {
+	struct sock *sock;
+	struct ckpt_ctx *ctx;
+};
+
+static int __sock_hash_parent(void *data)
+{
+	struct dq_sock *dq = (struct dq_sock *)data;
+	struct sock *parent;
+
+	dq->sock->sk_prot->hash(dq->sock);
+
+	parent = sock_get_parent(dq->ctx, dq->sock);
+	if (parent) {
+		inet_sk(dq->sock)->num = ntohs(inet_sk(dq->sock)->sport);
+		local_bh_disable();
+		__inet_inherit_port(parent, dq->sock);
+		local_bh_enable();
+	} else {
+		inet_sk(dq->sock)->num = 0;
+		inet_hash_connect(&tcp_death_row, dq->sock);
+		inet_sk(dq->sock)->num = ntohs(inet_sk(dq->sock)->sport);
+	}
+
+	return 0;
+}
+
+static int sock_defer_hash(struct ckpt_ctx *ctx, struct sock *sock)
+{
+	struct dq_sock dq;
+
+	dq.sock = sock;
+	dq.ctx = ctx;
+
+	deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
+		       __sock_hash_parent, __sock_hash_parent);
+
+	return 0;
+}
+
+static int sock_in_restart(struct ckpt_ctx *ctx,
+			   struct ckpt_hdr_socket *h,
+			   struct socket *socket)
+{
+	int ret;
+	struct ckpt_hdr_socket_in *in;
+	struct sockaddr_in *l = (struct sockaddr_in *)&h->laddr;
+
+	in = ckpt_read_obj_type(ctx, sizeof(*in), CKPT_HDR_SOCKET_IN);
+	if (IS_ERR(in))
+		return PTR_ERR(in);
+
+	if (h->sock.state == TCP_ESTABLISHED) {
+		socket->state = h->socket.state;
+		socket->sk->sk_state = h->sock.state;
+
+		sock_cptrst(ctx, socket->sk, h, CKPT_RST);
+		ret = sock_in_cptrst(ctx, socket->sk, in, CKPT_RST);
+
+		/* Delay hashing this sock until the end so we can
+		 * hook it up with its parent (if appropriate)
+		 */
+		sock_defer_hash(ctx, socket->sk);
+
+	} else if (h->sock.state == TCP_LISTEN) {
+		socket->sk->sk_reuse = 2;
+		inet_sk(socket->sk)->freebind = 1;
+		ret = socket->ops->bind(socket,
+					(struct sockaddr *)l,
+					h->laddr_len);
+		if (ret < 0)
+			goto out;
+		ret = socket->ops->listen(socket, h->sock.backlog);
+		if (ret < 0)
+			goto out;
+
+		sock_add_parent(ctx, socket->sk);
+	}
+
+  out:
+	return ret;
+ }
+
 struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
 				    struct ckpt_hdr_socket *h)
 {
@@ -465,6 +749,9 @@ struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
 	if (h->sock_common.family == AF_UNIX) {
 		ret = sock_un_restart(ctx, h, socket);
 		ckpt_debug("sock_un_restart: %i\n", ret);
+	} else if (h->sock_common.family == AF_INET) {
+		ret = sock_in_restart(ctx, h, socket);
+		ckpt_debug("sock_in_restart: %i\n", ret);
 	} else {
 		ckpt_debug("unsupported family %i\n", h->sock_common.family);
 		ret = -EINVAL;
-- 
1.6.2.2
