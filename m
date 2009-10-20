From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/4] Adjust TCP timestamp values by a scalar value
Date: Tue, 20 Oct 2009 14:06:42 -0700
Message-ID: <1256072803-3518-4-git-send-email-danms@us.ibm.com>
References: <1256072803-3518-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256072803-3518-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Adjust the sent and received TCP timestamp value by a scalar value
in the tcp_sock structure.  This will be zero most of the time, except
when the socket has been migrated with c/r.  If a socket is re-migrated,
we take the new adjusted value as the saved value so that on restart it
can be re-adjusted.  Also, copy this into the timewait sock so that
timestamps can continue to be adjusted in timewait state in the
minisocks code.

Note that TCP timestamps are just a jiffies stamp, which means they
have no relation to wall-clock time and thus a simple correction
factor should be enough to ensure correctness.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |    2 ++
 include/linux/tcp.h            |    3 +++
 include/net/tcp.h              |    3 ++-
 net/ipv4/checkpoint.c          |    8 ++++++++
 net/ipv4/syncookies.c          |    2 +-
 net/ipv4/tcp_input.c           |   14 +++++++-------
 net/ipv4/tcp_ipv4.c            |    2 +-
 net/ipv4/tcp_minisocks.c       |    8 ++++++--
 net/ipv4/tcp_output.c          |   20 ++++++++++----------
 net/ipv6/syncookies.c          |    2 +-
 net/ipv6/tcp_ipv6.c            |    2 +-
 11 files changed, 42 insertions(+), 24 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 0c10657..9c2f13d 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -649,6 +649,8 @@ struct ckpt_hdr_socket_inet {
 		__u32 keepalive_time;
 		__u32 keepalive_intvl;
 
+		__s32 tcp_ts;
+
 		__u16 urg_data;
 		__u16 advmss;
 		__u8 frto_counter;
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 8afac76..b845e21 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -399,6 +399,8 @@ struct tcp_sock {
 		u32		  probe_seq_end;
 	} mtu_probe;
 
+	s32	ts_adjust;	/* tcp_time_stamp adjustment factor */
+
 #ifdef CONFIG_TCP_MD5SIG
 /* TCP AF-Specific parts; only used by MD5 Signature support so far */
 	struct tcp_sock_af_ops	*af_specific;
@@ -420,6 +422,7 @@ struct tcp_timewait_sock {
 	u32			  tw_rcv_wnd;
 	u32			  tw_ts_recent;
 	long			  tw_ts_recent_stamp;
+	s32			  tw_ts_adjust;
 #ifdef CONFIG_TCP_MD5SIG
 	u16			  tw_md5_keylen;
 	u8			  tw_md5_key[TCP_MD5SIG_MAXKEYLEN];
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 88af843..96b4b27 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -409,7 +409,8 @@ extern int			tcp_recvmsg(struct kiocb *iocb, struct sock *sk,
 
 extern void			tcp_parse_options(struct sk_buff *skb,
 						  struct tcp_options_received *opt_rx,
-						  int estab);
+						  int estab,
+						  s32 ts_adjust);
 
 extern u8			*tcp_parse_md5sig_option(struct tcphdr *th);
 
diff --git a/net/ipv4/checkpoint.c b/net/ipv4/checkpoint.c
index 5913652..f858dbc 100644
--- a/net/ipv4/checkpoint.c
+++ b/net/ipv4/checkpoint.c
@@ -178,6 +178,14 @@ static int sock_inet_tcp_cptrst(struct ckpt_ctx *ctx,
 	CKPT_COPY(op, hh->tcp.keepalive_time, sk->keepalive_time);
 	CKPT_COPY(op, hh->tcp.keepalive_intvl, sk->keepalive_intvl);
 
+	if (op == CKPT_CPT)
+		hh->tcp.tcp_ts = tcp_time_stamp + sk->ts_adjust;
+	else
+		sk->ts_adjust = hh->tcp.tcp_ts - tcp_time_stamp;
+
+	ckpt_debug("TCP tcp_ts %i ts_adjust %i\n",
+		   hh->tcp.tcp_ts, sk->ts_adjust);
+
 	return 0;
 }
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index cd2b97f..31eafef 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -277,7 +277,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, 0);
+	tcp_parse_options(skb, &tcp_opt, 0, tp->ts_adjust);
 
 	if (tcp_opt.saw_tstamp)
 		cookie_check_timestamp(&tcp_opt);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2bdb0da..63cac78 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3699,7 +3699,7 @@ old_ack:
  * the fast version below fails.
  */
 void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
-		       int estab)
+		       int estab, s32 ts_adjust)
 {
 	unsigned char *ptr;
 	struct tcphdr *th = tcp_hdr(skb);
@@ -3756,8 +3756,8 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 				    ((estab && opt_rx->tstamp_ok) ||
 				     (!estab && sysctl_tcp_timestamps))) {
 					opt_rx->saw_tstamp = 1;
-					opt_rx->rcv_tsval = get_unaligned_be32(ptr);
-					opt_rx->rcv_tsecr = get_unaligned_be32(ptr + 4);
+					opt_rx->rcv_tsval = get_unaligned_be32(ptr) + ts_adjust;
+					opt_rx->rcv_tsecr = get_unaligned_be32(ptr + 4) + ts_adjust;
 				}
 				break;
 			case TCPOPT_SACK_PERM:
@@ -3799,9 +3799,9 @@ static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, struct tcphdr *th)
 			  | (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP)) {
 		tp->rx_opt.saw_tstamp = 1;
 		++ptr;
-		tp->rx_opt.rcv_tsval = ntohl(*ptr);
+		tp->rx_opt.rcv_tsval = ntohl(*ptr) + tp->ts_adjust;
 		++ptr;
-		tp->rx_opt.rcv_tsecr = ntohl(*ptr);
+		tp->rx_opt.rcv_tsecr = ntohl(*ptr) + tp->ts_adjust;
 		return 1;
 	}
 	return 0;
@@ -3821,7 +3821,7 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
 		if (tcp_parse_aligned_timestamp(tp, th))
 			return 1;
 	}
-	tcp_parse_options(skb, &tp->rx_opt, 1);
+	tcp_parse_options(skb, &tp->rx_opt, 1, tp->ts_adjust);
 	return 1;
 }
 
@@ -5366,7 +5366,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int saved_clamp = tp->rx_opt.mss_clamp;
 
-	tcp_parse_options(skb, &tp->rx_opt, 0);
+	tcp_parse_options(skb, &tp->rx_opt, 0, tp->ts_adjust);
 
 	if (th->ack) {
 		/* rfc793:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6d88219..e8efe7f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1222,7 +1222,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tmp_opt.mss_clamp = 536;
 	tmp_opt.user_mss  = tcp_sk(sk)->rx_opt.user_mss;
 
-	tcp_parse_options(skb, &tmp_opt, 0);
+	tcp_parse_options(skb, &tmp_opt, 0, 0);
 
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f8d67cc..4c72954 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -102,7 +102,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 
 	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
-		tcp_parse_options(skb, &tmp_opt, 0);
+		tcp_parse_options(skb, &tmp_opt, 0, tcptw->tw_ts_adjust);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent	= tcptw->tw_ts_recent;
@@ -292,6 +292,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 		tcptw->tw_snd_nxt	= tp->snd_nxt;
 		tcptw->tw_rcv_wnd	= tcp_receive_window(tp);
 		tcptw->tw_ts_recent	= tp->rx_opt.ts_recent;
+		tcptw->tw_ts_adjust	= tp->ts_adjust;
 		tcptw->tw_ts_recent_stamp = tp->rx_opt.ts_recent_stamp;
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
@@ -503,7 +504,10 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 
 	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(struct tcphdr)>>2)) {
-		tcp_parse_options(skb, &tmp_opt, 0);
+		/* C/R doesn't support request sockets yet, so we
+		 * don't need to worry about passing a ts_adjust here
+		 */
+		tcp_parse_options(skb, &tmp_opt, 0, 0);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent = req->ts_recent;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bd62712..38c165e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1487,7 +1487,7 @@ static int tcp_mtu_probe(struct sock *sk)
 
 	/* We're ready to send.  If this fails, the probe will
 	 * be resegmented into mss-sized pieces by tcp_write_xmit(). */
-	TCP_SKB_CB(nskb)->when = tcp_time_stamp;
+	TCP_SKB_CB(nskb)->when = tcp_time_stamp + tp->ts_adjust;
 	if (!tcp_transmit_skb(sk, nskb, 1, GFP_ATOMIC)) {
 		/* Decrement cwnd here because we are sending
 		 * effectively two packets. */
@@ -1568,7 +1568,7 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		    unlikely(tso_fragment(sk, skb, limit, mss_now)))
 			break;
 
-		TCP_SKB_CB(skb)->when = tcp_time_stamp;
+		TCP_SKB_CB(skb)->when = tcp_time_stamp + tp->ts_adjust;
 
 		if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
 			break;
@@ -1922,7 +1922,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	/* Make a copy, if the first transmission SKB clone we made
 	 * is still in somebody's hands, else make a clone.
 	 */
-	TCP_SKB_CB(skb)->when = tcp_time_stamp;
+	TCP_SKB_CB(skb)->when = tcp_time_stamp + tp->ts_adjust;
 
 	err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 
@@ -2138,7 +2138,7 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 	tcp_init_nondata_skb(skb, tcp_acceptable_seq(sk),
 			     TCPCB_FLAG_ACK | TCPCB_FLAG_RST);
 	/* Send it off. */
-	TCP_SKB_CB(skb)->when = tcp_time_stamp;
+	TCP_SKB_CB(skb)->when = tcp_time_stamp + tcp_sk(sk)->ts_adjust;
 	if (tcp_transmit_skb(sk, skb, 0, priority))
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTFAILED);
 
@@ -2176,7 +2176,7 @@ int tcp_send_synack(struct sock *sk)
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_ACK;
 		TCP_ECN_send_synack(tcp_sk(sk), skb);
 	}
-	TCP_SKB_CB(skb)->when = tcp_time_stamp;
+	TCP_SKB_CB(skb)->when = tcp_time_stamp + tcp_sk(sk)->ts_adjust;
 	return tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 }
 
@@ -2229,7 +2229,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 		TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
 	else
 #endif
-	TCP_SKB_CB(skb)->when = tcp_time_stamp;
+	TCP_SKB_CB(skb)->when = tcp_time_stamp + tp->ts_adjust;
 	tcp_header_size = tcp_synack_options(sk, req, mss,
 					     skb, &opts, &md5) +
 			  sizeof(struct tcphdr);
@@ -2352,7 +2352,7 @@ int tcp_connect(struct sock *sk)
 	TCP_ECN_send_syn(sk, buff);
 
 	/* Send it off. */
-	TCP_SKB_CB(buff)->when = tcp_time_stamp;
+	TCP_SKB_CB(buff)->when = tcp_time_stamp + tp->ts_adjust;
 	tp->retrans_stamp = TCP_SKB_CB(buff)->when;
 	skb_header_release(buff);
 	__tcp_add_write_queue_tail(sk, buff);
@@ -2457,7 +2457,7 @@ void tcp_send_ack(struct sock *sk)
 	tcp_init_nondata_skb(buff, tcp_acceptable_seq(sk), TCPCB_FLAG_ACK);
 
 	/* Send it off, this clears delayed acks for us. */
-	TCP_SKB_CB(buff)->when = tcp_time_stamp;
+	TCP_SKB_CB(buff)->when = tcp_time_stamp + tcp_sk(sk)->ts_adjust;
 	tcp_transmit_skb(sk, buff, 0, GFP_ATOMIC);
 }
 
@@ -2489,7 +2489,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 	 * send it.
 	 */
 	tcp_init_nondata_skb(skb, tp->snd_una - !urgent, TCPCB_FLAG_ACK);
-	TCP_SKB_CB(skb)->when = tcp_time_stamp;
+	TCP_SKB_CB(skb)->when = tcp_time_stamp + tp->ts_adjust;
 	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
 }
 
@@ -2524,7 +2524,7 @@ int tcp_write_wakeup(struct sock *sk)
 			tcp_set_skb_tso_segs(sk, skb, mss);
 
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
-		TCP_SKB_CB(skb)->when = tcp_time_stamp;
+		TCP_SKB_CB(skb)->when = tcp_time_stamp + tp->ts_adjust;
 		err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 		if (!err)
 			tcp_event_new_data_sent(sk, skb);
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 8c25139..9337ec6 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -185,7 +185,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, 0);
+	tcp_parse_options(skb, &tcp_opt, 0, tp->ts_adjust);
 
 	if (tcp_opt.saw_tstamp)
 		cookie_check_timestamp(&tcp_opt);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d849dd5..3a83570 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1202,7 +1202,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
 
-	tcp_parse_options(skb, &tmp_opt, 0);
+	tcp_parse_options(skb, &tmp_opt, 0, 0);
 
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
-- 
1.6.2.5
