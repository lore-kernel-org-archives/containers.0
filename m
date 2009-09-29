From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] [RFC] Add c/r support for listening INET sockets
Date: Tue, 29 Sep 2009 18:16:18 -0400
Message-ID: <4AC28732.8040809@librato.com>
References: <1254164330-23072-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1254164330-23072-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Dan Smith wrote:
> This is an incremental step towards supporting checkpoint/restart on
> AF_INET sockets.  In this scenario, any sockets that were in TCP_LISTEN
> state are restored as they were.  Any that were connected are forced to
> TCP_CLOSE.  This should cover a range of use cases that involve
> applications that are tolerant of such an interruption.
> 
> Cc: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
> Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---

Good stuff... a few comments below.

[...]

> +
> +static int inet_read_buffer(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
> +{
> +	struct ckpt_hdr_socket_buffer *h;
> +	int len;
> +	int ret;
> +	struct sk_buff *skb;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFER);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_BUFFER);
> +	if (len < 0) {
> +		ret = len;

Note: skb wasn't initialized yet, ret will be negative (more below)...

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
> +	if (ret < 0)
> +		kfree_skb(skb);

skb may be uninitialized at this point (do I sound like gcc ?)


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
> +		ret = 0;
		^^^^^^^^
Unnecessary ?

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

I think you need to at least sanitize the in->laddr_len field - the
ops->bind() below assumes its valid.

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
> + }
> +

Oren.
