From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 4/4] C/R: Fix storing IPv6 addresses and handle the
	"ipv6only" socket flag (v2)
Date: Sun, 25 Apr 2010 17:08:07 -0400
Message-ID: <4BD4AF37.10504@cs.columbia.edu>
References: <1270748932-26745-1-git-send-email-danms@us.ibm.com>
	<1270748932-26745-5-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1270748932-26745-5-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Hi Dan,

Dan Smith wrote:
> The first item is a result of sockaddr_in6 being larger than the base
> sockaddr structure, thus not being long enough to reserve enough space in
> the checkpoint header.
> 
> The second comes into play when things (like sshd) bind to INADDR6_ANY,
> set the "ipv6only" socket flag and then bind an IPv4 socket to the same
> port.
> 
> Changes in v2:
>  - Export the inet_* symbols used by inet6 so that CONFIG_IPV6=m
>    will compile
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/checkpoint_hdr.h |   13 +++++++++++--
>  net/ipv4/checkpoint.c          |   37 +++++++++++++++++++++++--------------
>  net/ipv6/af_inet6.c            |    2 ++
>  3 files changed, 36 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 98aa79c..7fde6b5 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -758,12 +758,21 @@ struct ckpt_hdr_socket_inet {
>  		struct in6_addr saddr;
>  		struct in6_addr rcv_saddr;
>  		struct in6_addr daddr;
> +		__u8 ipv6only;
>  	} inet6 __attribute__ ((aligned(8)));
>  
>  	__u32 laddr_len;
>  	__u32 raddr_len;
> -	struct sockaddr_in laddr;
> -	struct sockaddr_in raddr;
> +	union {
> +		struct sockaddr laddr;
> +		struct sockaddr_in laddr4;
> +		struct sockaddr_in6 laddr6;
> +	};
> +	union {
> +		struct sockaddr raddr;
> +		struct sockaddr_in raddr4;
> +		struct sockaddr_in6 raddr6;
> +	};
>  } __attribute__((aligned(8)));
>  
>  struct ckpt_hdr_file_socket {
> diff --git a/net/ipv4/checkpoint.c b/net/ipv4/checkpoint.c
> index b4024e7..1c43570 100644
> --- a/net/ipv4/checkpoint.c
> +++ b/net/ipv4/checkpoint.c
> @@ -190,12 +190,14 @@ static int sock_inet_restore_connection(struct sock *sk,
>  	struct inet_sock *inet = inet_sk(sk);
>  	int tcp_gso = sk->sk_family == AF_INET ? SKB_GSO_TCPV4 : SKB_GSO_TCPV6;
>  
> -	inet->inet_daddr = hh->raddr.sin_addr.s_addr;
> -	inet->inet_saddr = hh->laddr.sin_addr.s_addr;
> -	inet->inet_rcv_saddr = inet->inet_saddr;
> +	if (sk->sk_family == AF_INET) {
> +		inet->inet_daddr = hh->raddr4.sin_addr.s_addr;
> +		inet->inet_saddr = hh->laddr4.sin_addr.s_addr;
> +		inet->inet_rcv_saddr = inet->inet_saddr;
>  
> -	inet->inet_dport = hh->raddr.sin_port;
> -	inet->inet_sport = hh->laddr.sin_port;
> +		inet->inet_dport = hh->raddr4.sin_port;
> +		inet->inet_sport = hh->laddr4.sin_port;
> +	}
>  
>  	if (sk->sk_protocol == IPPROTO_TCP)
>  		sk->sk_gso_type = tcp_gso;
> @@ -266,6 +268,7 @@ static int sock_inet_cptrst(struct ckpt_ctx *ctx,
>  			ipv6_addr_copy(&inet6->rcv_saddr, &hh->inet6.rcv_saddr);
>  			ipv6_addr_copy(&inet6->daddr, &hh->inet6.daddr);
>  		}
> +		CKPT_COPY(op, hh->inet6.ipv6only, inet6->ipv6only);
>  	}
>  
>  	return ret;
> @@ -281,8 +284,8 @@ int inet_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
>  		return -EINVAL;
>  
>  	ret = ckpt_sock_getnames(ctx, sock,
> -				(struct sockaddr *)&in->laddr, &in->laddr_len,
> -				(struct sockaddr *)&in->raddr, &in->raddr_len);
> +				&in->laddr, &in->laddr_len,
> +				&in->raddr, &in->raddr_len);
>  	if (ret)
>  		goto out;
>  
> @@ -296,11 +299,13 @@ int inet_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
>  
>  	return ret;
>  }
> +EXPORT_SYMBOL_GPL(inet_checkpoint);

This belongs to a separate patch ?  Especially for as long as we
need to keep our patchset clean, until it makes it to -mm

>  
>  int inet_collect(struct ckpt_ctx *ctx, struct socket *sock)
>  {
>  	return ckpt_obj_collect(ctx, sock->sk, CKPT_OBJ_SOCK);
>  }
> +EXPORT_SYMBOL_GPL(inet_collect);

Ditto.

>  
>  static int inet_read_buffer(struct ckpt_ctx *ctx,
>  			    struct sk_buff_head *queue,
> @@ -387,19 +392,19 @@ static int inet_precheck(struct socket *sock, struct ckpt_hdr_socket_inet *in)
>  	__u8 nonagle_mask = TCP_NAGLE_OFF | TCP_NAGLE_CORK | TCP_NAGLE_PUSH;
>  	__u8 ecn_mask = TCP_ECN_OK | TCP_ECN_QUEUE_CWR | TCP_ECN_DEMAND_CWR;
>  
> -	if ((htons(in->laddr.sin_port) < PROT_SOCK) &&
> +	if ((htons(in->laddr4.sin_port) < PROT_SOCK) &&
>  	    !capable(CAP_NET_BIND_SERVICE)) {
>  		ckpt_debug("unable to bind to port %hu\n",
> -			   htons(in->laddr.sin_port));
> +			   htons(in->laddr4.sin_port));
>  		return -EINVAL;
>  	}
>  
> -	if (in->laddr_len > sizeof(struct sockaddr_in)) {
> +	if (in->laddr_len > sizeof(in->laddr6)) {
>  		ckpt_debug("laddr_len is too big\n");
>  		return -EINVAL;
>  	}
>  
> -	if (in->raddr_len > sizeof(struct sockaddr_in)) {
> +	if (in->raddr_len > sizeof(in->laddr6)) {
>  		ckpt_debug("raddr_len is too big\n");
>  		return -EINVAL;
>  	}
> @@ -496,11 +501,14 @@ int inet_restore(struct ckpt_ctx *ctx,
>  	 */
>  	if ((h->sock.state == TCP_LISTEN) ||
>  	    ((h->sock.state == TCP_CLOSE) && (in->laddr_len > 0))) {
> +		if (in->inet6.ipv6only) {
> +			struct ipv6_pinfo *np = inet6_sk(sock->sk);
> +			np->ipv6only = 1;
> +		}
> +
>  		sock->sk->sk_reuse = 2;
>  		inet_sk(sock->sk)->freebind = 1;
> -		ret = sock->ops->bind(sock,
> -				      (struct sockaddr *)&in->laddr,
> -				      in->laddr_len);
> +		ret = sock->ops->bind(sock, &in->laddr, in->laddr_len);
>  		ckpt_debug("inet bind: %i\n", ret);
>  		if (ret < 0)
>  			goto out;
> @@ -547,3 +555,4 @@ int inet_restore(struct ckpt_ctx *ctx,
>  
>  	return ret;
>  }
> +EXPORT_SYMBOL_GPL(inet_restore);

Ditto.

> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 12e69d3..9acb55a 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -523,6 +523,8 @@ const struct proto_ops inet6_stream_ops = {
>  	.mmap		   = sock_no_mmap,
>  	.sendpage	   = tcp_sendpage,
>  	.splice_read	   = tcp_splice_read,
> +	.checkpoint	   = inet_checkpoint,
> +	.restore	   = inet_restore,
>  #ifdef CONFIG_COMPAT
>  	.compat_setsockopt = compat_sock_common_setsockopt,
>  	.compat_getsockopt = compat_sock_common_getsockopt,

Oren.
