From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Restore gso_type fields on sockets and buffers
Date: Mon, 16 Nov 2009 13:39:56 -0500
Message-ID: <4B019C7C.6070603@cs.columbia.edu>
References: <1258152014-9966-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258152014-9966-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

I'll pull this one for ckpt-v19-rc1 after I pull the inet-sock
patch-set.

Oren.


Dan Smith wrote:
> The sk_gso_type field gets set during TCP connect(), so we need to set that
> properly when we synthesize the connection post-restart.  Also, restore
> the gso_type field on socket buffers so that they're properly handled on
> the incoming path.  Instead of storing that per-buffer, use the value
> that should have been set on it from the socket in the first place,
> to avoid needing to make sure the user doesn't try to restore a UDP
> buffer into a TCP socket (for example).
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/checkpoint.h |    2 +-
>  net/checkpoint.c           |   10 +++++++---
>  net/ipv4/checkpoint.c      |   32 +++++++++++++++++++++++---------
>  3 files changed, 31 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index d4765f6..1c57abc 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -102,7 +102,7 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
>  			      struct socket *socket,
>  			      struct sockaddr *loc, unsigned *loc_len,
>  			      struct sockaddr *rem, unsigned *rem_len);
> -struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx);
> +struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx, struct sock *sk);
>  void sock_listening_list_free(struct list_head *head);
>  
>  /* ckpt kflags */
> diff --git a/net/checkpoint.c b/net/checkpoint.c
> index 32ccaba..cff3211 100644
> --- a/net/checkpoint.c
> +++ b/net/checkpoint.c
> @@ -115,7 +115,8 @@ static void sock_record_header_info(struct sk_buff *skb,
>  }
>  
>  int sock_restore_header_info(struct sk_buff *skb,
> -			     struct ckpt_hdr_socket_buffer *h)
> +			     struct ckpt_hdr_socket_buffer *h,
> +			     struct sock *sk)
>  {
>  	if (h->mac_header + h->mac_len != h->network_header) {
>  		ckpt_debug("skb mac_header %llu+%llu != network header %llu\n",
> @@ -158,6 +159,8 @@ int sock_restore_header_info(struct sk_buff *skb,
>  	skb->data = skb->head + skb->hdr_len;
>  	skb->len = h->skb_len;
>  
> +	skb_shinfo(skb)->gso_type = sk->sk_gso_type;
> +
>  	return 0;
>  }
>  
> @@ -199,7 +202,8 @@ static int sock_restore_skb_frag(struct ckpt_ctx *ctx,
>  	return ret < 0 ? ret : fraglen;
>  }
>  
> -struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx)
> +struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx,
> +				 struct sock *sk)
>  {
>  	struct ckpt_hdr_socket_buffer *h;
>  	struct sk_buff *skb = NULL;
> @@ -251,7 +255,7 @@ struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx)
>  		goto out;
>  	}
>  
> -	sock_restore_header_info(skb, h);
> +	sock_restore_header_info(skb, h, sk);
>  
>   out:
>  	ckpt_hdr_put(ctx, h);
> diff --git a/net/ipv4/checkpoint.c b/net/ipv4/checkpoint.c
> index ee41633..92a92b0 100644
> --- a/net/ipv4/checkpoint.c
> +++ b/net/ipv4/checkpoint.c
> @@ -184,9 +184,12 @@ static int sock_inet_tcp_cptrst(struct ckpt_ctx *ctx,
>  	return 0;
>  }
>  
> -static int sock_inet_restore_addrs(struct inet_sock *inet,
> -				   struct ckpt_hdr_socket_inet *hh)
> +static int sock_inet_restore_connection(struct sock *sk,
> +					struct ckpt_hdr_socket_inet *hh)
>  {
> +	struct inet_sock *inet = inet_sk(sk);
> +	int tcp_gso = sk->sk_family == AF_INET ? SKB_GSO_TCPV4 : SKB_GSO_TCPV6;
> +
>  	inet->daddr = hh->raddr.sin_addr.s_addr;
>  	inet->saddr = hh->laddr.sin_addr.s_addr;
>  	inet->rcv_saddr = inet->saddr;
> @@ -194,6 +197,15 @@ static int sock_inet_restore_addrs(struct inet_sock *inet,
>  	inet->dport = hh->raddr.sin_port;
>  	inet->sport = hh->laddr.sin_port;
>  
> +	if (sk->sk_protocol == IPPROTO_TCP)
> +		sk->sk_gso_type = tcp_gso;
> +	else if (sk->sk_protocol == IPPROTO_UDP)
> +		sk->sk_gso_type = SKB_GSO_UDP;
> +	else {
> +		ckpt_debug("Unsupported socket type while setting GSO\n");
> +		return -EINVAL;
> +	}
> +
>  	return 0;
>  }
>  
> @@ -213,7 +225,7 @@ static int sock_inet_cptrst(struct ckpt_ctx *ctx,
>  		CKPT_COPY(op, hh->saddr, inet->saddr);
>  		CKPT_COPY(op, hh->sport, inet->sport);
>  	} else {
> -		ret = sock_inet_restore_addrs(inet, hh);
> +		ret = sock_inet_restore_connection(sk, hh);
>  		if (ret)
>  			return ret;
>  	}
> @@ -291,11 +303,12 @@ int inet_collect(struct ckpt_ctx *ctx, struct socket *sock)
>  }
>  
>  static int inet_read_buffer(struct ckpt_ctx *ctx,
> -			    struct sk_buff_head *queue)
> +			    struct sk_buff_head *queue,
> +			    struct sock *sk)
>  {
>  	struct sk_buff *skb = NULL;
>  
> -	skb = sock_restore_skb(ctx);
> +	skb = sock_restore_skb(ctx, sk);
>  	if (IS_ERR(skb))
>  		return PTR_ERR(skb);
>  
> @@ -305,7 +318,8 @@ static int inet_read_buffer(struct ckpt_ctx *ctx,
>  }
>  
>  static int inet_read_buffers(struct ckpt_ctx *ctx,
> -			     struct sk_buff_head *queue)
> +			     struct sk_buff_head *queue,
> +			     struct sock *sk)
>  {
>  	struct ckpt_hdr_socket_queue *h;
>  	int ret = 0;
> @@ -316,7 +330,7 @@ static int inet_read_buffers(struct ckpt_ctx *ctx,
>  		return PTR_ERR(h);
>  
>  	for (i = 0; i < h->skb_count; i++) {
> -		ret = inet_read_buffer(ctx, queue);
> +		ret = inet_read_buffer(ctx, queue, sk);
>  		ckpt_debug("read inet buffer %i: %i", i, ret);
>  		if (ret < 0)
>  			goto out;
> @@ -344,12 +358,12 @@ static int inet_deferred_restore_buffers(void *data)
>  	struct sock *sk = dq->sk;
>  	int ret;
>  
> -	ret = inet_read_buffers(ctx, &sk->sk_receive_queue);
> +	ret = inet_read_buffers(ctx, &sk->sk_receive_queue, sk);
>  	ckpt_debug("(R) inet_read_buffers: %i\n", ret);
>  	if (ret < 0)
>  		return ret;
>  
> -	ret = inet_read_buffers(ctx, &sk->sk_write_queue);
> +	ret = inet_read_buffers(ctx, &sk->sk_write_queue, sk);
>  	ckpt_debug("(W) inet_read_buffers: %i\n", ret);
>  
>  	return ret;
