From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] Add c/r support for listening INET sockets (v2)
Date: Thu, 01 Oct 2009 19:11:43 -0400
Message-ID: <4AC5372F.7030807@librato.com>
References: <1254324106-31750-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1254324106-31750-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org


Queued for ckpt-v18-dev.

Dan Smith wrote:
> This is an incremental step towards supporting checkpoint/restart on
> AF_INET sockets.  In this scenario, any sockets that were in TCP_LISTEN
> state are restored as they were.  Any that were connected are forced to
> TCP_CLOSE.  This should cover a range of use cases that involve
> applications that are tolerant of such an interruption.
> 
> Changes in v2:
>  - Fix whitespace
>  - Fix return in inet_checkpoint() on failed ckpt_hdr_get_type()
>  - Fix garbage free on error path of inet_read_buffer()
>  - Fix unnecessary ret=0 in inet_read_buffers()
>  - Add inet_precheck() (like unix) to validate the address lengths (and
>    more later)
> 
> Cc: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
> Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/checkpoint_hdr.h |   11 ++
>  include/net/inet_common.h      |    9 ++
>  net/checkpoint.c               |    9 ++
>  net/ipv4/Makefile              |    1 +
>  net/ipv4/af_inet.c             |    6 +
>  net/ipv4/checkpoint.c          |  222 ++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 258 insertions(+), 0 deletions(-)
>  create mode 100644 net/ipv4/checkpoint.c
> 
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 2ed523f..b5ce115 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -15,9 +15,11 @@
>  #ifdef __KERNEL__
>  #include <linux/socket.h>
>  #include <linux/un.h>
> +#include <linux/in.h>
>  #else
>  #include <sys/socket.h>
>  #include <sys/un.h>
> +#include <sys/in.h>
>  #endif
>  
>  /*
> @@ -106,6 +108,7 @@ enum {
>  	CKPT_HDR_SOCKET_QUEUE,
>  	CKPT_HDR_SOCKET_BUFFER,
>  	CKPT_HDR_SOCKET_UNIX,
> +	CKPT_HDR_SOCKET_INET,
>  
>  	CKPT_HDR_TAIL = 9001,
>  
> @@ -470,6 +473,14 @@ struct ckpt_hdr_socket_unix {
>  	struct sockaddr_un raddr;
>  } __attribute__ ((aligned(8)));
>  
> +struct ckpt_hdr_socket_inet {
> +	struct ckpt_hdr h;
> +	__u32 laddr_len;
> +	__u32 raddr_len;
> +	struct sockaddr_in laddr;
> +	struct sockaddr_in raddr;
> +} __attribute__((aligned(8)));
> +
>  struct ckpt_hdr_file_socket {
>  	struct ckpt_hdr_file common;
>  	__s32 sock_objref;
> diff --git a/include/net/inet_common.h b/include/net/inet_common.h
> index 18c7732..7ade732 100644
> --- a/include/net/inet_common.h
> +++ b/include/net/inet_common.h
> @@ -45,6 +45,15 @@ extern int			inet_ctl_sock_create(struct sock **sk,
>  						     unsigned char protocol,
>  						     struct net *net);
>  
> +#ifdef CONFIG_CHECKPOINT
> +struct ckpt_ctx;
> +struct ckpt_hdr_socket;
> +extern int inet_checkpoint(struct ckpt_ctx *ctx, struct socket *sock);
> +extern int inet_collect(struct ckpt_ctx *ctx, struct socket *sock);
> +extern int inet_restore(struct ckpt_ctx *cftx, struct socket *sock,
> +			struct ckpt_hdr_socket *h);
> +#endif /* CONFIG_CHECKPOINT */
> +
>  static inline void inet_ctl_sock_destroy(struct sock *sk)
>  {
>  	sk_release_kernel(sk);
> diff --git a/net/checkpoint.c b/net/checkpoint.c
> index a11ec7a..6960389 100644
> --- a/net/checkpoint.c
> +++ b/net/checkpoint.c
> @@ -711,6 +711,15 @@ struct sock *do_sock_restore(struct ckpt_ctx *ctx)
>  	if (ret < 0)
>  		goto err;
>  
> +	if ((h->sock_common.family == AF_INET) &&
> +	    (h->sock.state != TCP_LISTEN)) {
> +		/* Temporary hack to enable restore of TCP_LISTEN sockets
> +		 * while forcing anything else to a closed state
> +		 */
> +		sock->sk->sk_state = TCP_CLOSE;
> +		sock->state = SS_UNCONNECTED;
> +	}
> +
>  	ckpt_hdr_put(ctx, h);
>  	return sock->sk;
>   err:
> diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
> index 80ff87c..c00d8ce 100644
> --- a/net/ipv4/Makefile
> +++ b/net/ipv4/Makefile
> @@ -49,6 +49,7 @@ obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
>  obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
>  obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
>  obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
> +obj-$(CONFIG_CHECKPOINT) += checkpoint.o
>  
>  obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
>  		      xfrm4_output.o
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 566ea6c..7828885 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -857,6 +857,9 @@ const struct proto_ops inet_stream_ops = {
>  	.mmap		   = sock_no_mmap,
>  	.sendpage	   = tcp_sendpage,
>  	.splice_read	   = tcp_splice_read,
> +	.checkpoint        = inet_checkpoint,
> +	.restore           = inet_restore,
> +	.collect           = inet_collect,
>  #ifdef CONFIG_COMPAT
>  	.compat_setsockopt = compat_sock_common_setsockopt,
>  	.compat_getsockopt = compat_sock_common_getsockopt,
> @@ -882,6 +885,9 @@ const struct proto_ops inet_dgram_ops = {
>  	.recvmsg	   = sock_common_recvmsg,
>  	.mmap		   = sock_no_mmap,
>  	.sendpage	   = inet_sendpage,
> +	.checkpoint        = inet_checkpoint,
> +	.restore           = inet_restore,
> +	.collect           = inet_collect,
>  #ifdef CONFIG_COMPAT
>  	.compat_setsockopt = compat_sock_common_setsockopt,
>  	.compat_getsockopt = compat_sock_common_getsockopt,
> diff --git a/net/ipv4/checkpoint.c b/net/ipv4/checkpoint.c
> new file mode 100644
> index 0000000..9cbbf5e
> --- /dev/null
> +++ b/net/ipv4/checkpoint.c
> @@ -0,0 +1,222 @@
> +/*
> + *  Copyright 2009 IBM Corporation
> + *
> + *  Author(s): Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> + *
> + *  This program is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU General Public License as
> + *  published by the Free Software Foundation, version 2 of the
> + *  License.
> + */
> +
> +#include <linux/namei.h>
> +#include <linux/checkpoint.h>
> +#include <linux/checkpoint_hdr.h>
> +#include <linux/tcp.h>
> +#include <linux/in.h>
> +#include <linux/deferqueue.h>
> +#include <net/tcp_states.h>
> +#include <net/tcp.h>
> +
> +struct dq_sock {
> +	struct ckpt_ctx *ctx;
> +	struct sock *sk;
> +};
> +
> +struct dq_buffers {
> +	struct ckpt_ctx *ctx;
> +	struct sock *sk;
> +};
> +
> +int inet_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
> +{
> +	struct ckpt_hdr_socket_inet *in;
> +	int ret;
> +
> +	in = ckpt_hdr_get_type(ctx, sizeof(*in), CKPT_HDR_SOCKET_INET);
> +	if (!in)
> +		return -EINVAL;
> +
> +	ret = ckpt_sock_getnames(ctx, sock,
> +				(struct sockaddr *)&in->laddr, &in->laddr_len,
> +				(struct sockaddr *)&in->raddr, &in->raddr_len);
> +	if (ret)
> +		goto out;
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) in);
> + out:
> +	ckpt_hdr_put(ctx, in);
> +
> +	return ret;
> +}
> +
> +int inet_collect(struct ckpt_ctx *ctx, struct socket *sock)
> +{
> +	return ckpt_obj_collect(ctx, sock->sk, CKPT_OBJ_SOCK);
> +}
> +
> +static int inet_read_buffer(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
> +{
> +	struct ckpt_hdr_socket_buffer *h;
> +	int len;
> +	int ret;
> +	struct sk_buff *skb = NULL;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFER);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_BUFFER);
> +	if (len < 0) {
> +		ret = len;
> +		goto out;
> +	} else if (len > SKB_MAX_ALLOC) {
> +		ckpt_debug("Socket buffer too big (%i > %lu)",
> +			   len, SKB_MAX_ALLOC);
> +		ret = -ENOSPC;
> +		goto out;
> +	}
> +
> +	skb = alloc_skb(len, GFP_KERNEL);
> +	if (!skb) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	ret = ckpt_kread(ctx, skb_put(skb, len), len);
> +	if (ret < 0)
> +		goto out;
> +
> +	spin_lock(&queue->lock);
> +	skb_queue_tail(queue, skb);
> +	spin_unlock(&queue->lock);
> + out:
> +	ckpt_hdr_put(ctx, h);
> +
> +	if ((ret < 0) && skb)
> +		kfree_skb(skb);
> +
> +	return ret;
> +}
> +
> +static int inet_read_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
> +{
> +	struct ckpt_hdr_socket_queue *h;
> +	int ret = 0;
> +	int i;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_QUEUE);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	for (i = 0; i < h->skb_count; i++) {
> +		ret = inet_read_buffer(ctx, queue);
> +		ckpt_debug("read inet buffer %i: %i", i, ret);
> +		if (ret < 0)
> +			goto out;
> +
> +		if (ret > h->total_bytes) {
> +			ckpt_debug("Buffers exceeded claim");
> +			ret = -EINVAL;
> +			goto out;
> +		}
> +
> +		h->total_bytes -= ret;
> +	}
> +
> +	ret = h->skb_count;
> + out:
> +	ckpt_hdr_put(ctx, h);
> +
> +	return ret;
> +}
> +
> +static int inet_deferred_restore_buffers(void *data)
> +{
> +	struct dq_buffers *dq = (struct dq_buffers *)data;
> +	struct ckpt_ctx *ctx = dq->ctx;
> +	struct sock *sk = dq->sk;
> +	int ret;
> +
> +	ret = inet_read_buffers(ctx, &sk->sk_receive_queue);
> +	ckpt_debug("(R) inet_read_buffers: %i\n", ret);
> +	if (ret < 0)
> +		return ret;
> +
> +	ret = inet_read_buffers(ctx, &sk->sk_write_queue);
> +	ckpt_debug("(W) inet_read_buffers: %i\n", ret);
> +
> +	return ret;
> +}
> +
> +static int inet_defer_restore_buffers(struct ckpt_ctx *ctx, struct sock *sk)
> +{
> +	struct dq_buffers dq;
> +
> +	dq.ctx = ctx;
> +	dq.sk = sk;
> +
> +	return deferqueue_add(ctx->files_deferq, &dq, sizeof(dq),
> +			      inet_deferred_restore_buffers, NULL);
> +}
> +
> +static int inet_precheck(struct socket *sock, struct ckpt_hdr_socket_inet *in)
> +{
> +	if (in->laddr_len > sizeof(struct sockaddr_in)) {
> +		ckpt_debug("laddr_len is too big\n");
> +		return -EINVAL;
> +	}
> +
> +	if (in->raddr_len > sizeof(struct sockaddr_in)) {
> +		ckpt_debug("raddr_len is too big\n");
> +		return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
> +int inet_restore(struct ckpt_ctx *ctx,
> +		 struct socket *sock,
> +		 struct ckpt_hdr_socket *h)
> +{
> +	struct ckpt_hdr_socket_inet *in;
> +	int ret = 0;
> +
> +	in = ckpt_read_obj_type(ctx, sizeof(*in), CKPT_HDR_SOCKET_INET);
> +	if (IS_ERR(in))
> +		return PTR_ERR(in);
> +
> +	ret = inet_precheck(sock, in);
> +	if (ret < 0)
> +		goto out;
> +
> +	/* Listening sockets and those that are closed but have a local
> +	 * address need to call bind()
> +	 */
> +	if ((h->sock.state == TCP_LISTEN) ||
> +	    ((h->sock.state == TCP_CLOSE) && (in->laddr_len > 0))) {
> +		sock->sk->sk_reuse = 2;
> +		inet_sk(sock->sk)->freebind = 1;
> +		ret = sock->ops->bind(sock,
> +				      (struct sockaddr *)&in->laddr,
> +				      in->laddr_len);
> +		ckpt_debug("inet bind: %i\n", ret);
> +		if (ret < 0)
> +			goto out;
> +
> +		if (h->sock.state == TCP_LISTEN) {
> +			ret = sock->ops->listen(sock, h->sock.backlog);
> +			ckpt_debug("inet listen: %i\n", ret);
> +			if (ret < 0)
> +				goto out;
> +		}
> +	} else {
> +		if (!sock_flag(sock->sk, SOCK_DEAD))
> +			ret = inet_defer_restore_buffers(ctx, sock->sk);
> +	}
> + out:
> +	ckpt_hdr_put(ctx, in);
> +
> +	return ret;
> +}
> +
