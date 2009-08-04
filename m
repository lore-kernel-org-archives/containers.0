From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v7)
Date: Tue, 4 Aug 2009 14:57:02 -0500
Message-ID: <20090804195702.GE10275@us.ibm.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com> <1249331463-11887-6-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1249331463-11887-6-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms@us.ibm.com):
> +static int sock_unix_checkpoint(struct ckpt_ctx *ctx,
> +			        struct socket *socket,
> +			        struct ckpt_hdr_socket *h)
> +{
> +	struct unix_sock *sk = unix_sk(socket->sk);
> +	struct unix_sock *pr = unix_sk(sk->peer);
> +	struct ckpt_hdr_socket_unix *un;
> +	int new;
> +	int ret = -ENOMEM;
> +
> +	if ((socket->sk->sk_state == TCP_LISTEN) &&
> +	    !skb_queue_empty(&socket->sk->sk_receive_queue)) {
> +		ckpt_write_err(ctx, "listening socket has unaccepted peers");
> +		return -EBUSY;
> +	}
> +
> +	un = ckpt_hdr_get_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UNIX);
> +	if (!un)
> +		goto out;

...

> + out:
> +	ckpt_hdr_put(ctx, un);

This will cause a null deref trying to get ptr->len in ckpt_hdr_put().

-serge
