From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/4] Update the UNIX buffer restore code to match the
	new format saved in the image file
Date: Wed, 11 Nov 2009 15:40:43 -0600
Message-ID: <20091111214043.GF8761@us.ibm.com>
References: <1257878856-25520-1-git-send-email-danms@us.ibm.com>
	<1257878856-25520-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1257878856-25520-4-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Anyway the patch itself seems fine :)

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  net/unix/checkpoint.c |   54 ++++++++++++++++++++++++++----------------------
>  1 files changed, 29 insertions(+), 25 deletions(-)
> 
> diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
> index 8b7cb22..bd1fc35 100644
> --- a/net/unix/checkpoint.c
> +++ b/net/unix/checkpoint.c
> @@ -200,7 +200,6 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
>  	uint8_t peer_shutdown = 0;
>  	void *buf = NULL;
>  	int sndbuf;
> -	int len;
>  	int ret = 0;
> 
>  	memset(&msg, 0, sizeof(msg));
> @@ -209,14 +208,30 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
>  	if (IS_ERR(h))
>  		return PTR_ERR(h);
> 
> -	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_BUFFER);
> -	if (len < 0) {
> -		ret = len;
> +	if (h->lin_len > SKB_MAX_ALLOC) {
> +		ckpt_debug("socket buffer too big (%llu > %lu)\n",
> +			   h->lin_len, SKB_MAX_ALLOC);
> +		ret = -EINVAL;
> +		goto out;
> +	} else if (h->nr_frags != 0) {
> +		ckpt_debug("unix socket claims to have fragments\n");
> +		ret = -EINVAL;
>  		goto out;
> -	} else if (len > SKB_MAX_ALLOC) {
> -		ckpt_debug("Socket buffer too big (%i > %lu)",
> -			   len, SKB_MAX_ALLOC);
> -		ret = -ENOSPC;
> +	}
> +
> +	buf = kmalloc(h->lin_len, GFP_KERNEL);
> +	if (!buf) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	kvec.iov_len = h->lin_len;
> +	kvec.iov_base = buf;
> +	ret = _ckpt_read_obj_type(ctx, kvec.iov_base,
> +				  h->lin_len, CKPT_HDR_BUFFER);
> +	ckpt_debug("read unix socket buffer %llu: %i\n", h->lin_len, ret);
> +	if (ret < h->lin_len) {
> +		ret = -EINVAL;
>  		goto out;
>  	}
> 
> @@ -245,18 +260,6 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
>  		}
>  	}
> 
> -	kvec.iov_len = len;
> -	buf = kmalloc(len, GFP_KERNEL);
> -	kvec.iov_base = buf;
> -	if (!buf) {
> -		ret = -ENOMEM;
> -		goto out;
> -	}
> -
> -	ret = ckpt_kread(ctx, kvec.iov_base, len);
> -	if (ret < 0)
> -		goto out;
> -
>  	msg.msg_name = addr;
>  	msg.msg_namelen = addrlen;
> 
> @@ -272,15 +275,16 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
> 
>  	/* Make sure there's room in the send buffer */
>  	sndbuf = sk->sk_sndbuf;
> -	if (((sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc)) < len) &&
> +	if (((sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc)) < h->lin_len) &&
>  	    capable(CAP_NET_ADMIN))
> -		sk->sk_sndbuf += len;
> +		sk->sk_sndbuf += h->lin_len;
>  	else
>  		sk->sk_sndbuf = sysctl_wmem_max;
> 
> -	ret = kernel_sendmsg(sk->sk_socket, &msg, &kvec, 1, len);
> -	ckpt_debug("kernel_sendmsg(%i,%i): %i\n", h->sk_objref, len, ret);
> -	if ((ret > 0) && (ret != len))
> +	ret = kernel_sendmsg(sk->sk_socket, &msg, &kvec, 1, h->lin_len);
> +	ckpt_debug("kernel_sendmsg(%i,%llu): %i\n",
> +		   h->sk_objref, h->lin_len, ret);
> +	if ((ret > 0) && (ret != h->lin_len))
>  		ret = -ENOMEM;
> 
>  	sk->sk_sndbuf = sndbuf;
> -- 
> 1.6.3.3
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
