From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/4] Set socket flags on restore using sock_setsockopt()
	where possible
Date: Thu, 13 Aug 2009 15:44:14 -0400
Message-ID: <4A846D0E.90607@librato.com>
References: <1250191750-3864-1-git-send-email-danms@us.ibm.com>
	<1250191750-3864-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1250191750-3864-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Dan Smith wrote:
> Fail on the TIMESTAMPING_* flags for the moment, with a TODO in place to
> handle them later.
> 
> Also remove other explicit flag checks because they're no longer copied
> blindly into the socket object, so existing checks will be sufficient.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---

Nice cleanup.
See one comment below.

>  net/checkpoint.c |  117 +++++++++++++++++++++++++++++++++++++++++++++++------
>  1 files changed, 103 insertions(+), 14 deletions(-)
> 
> diff --git a/net/checkpoint.c b/net/checkpoint.c
> index ebbd68a..13c46c1 100644
> --- a/net/checkpoint.c
> +++ b/net/checkpoint.c
> @@ -179,10 +179,6 @@ static int sock_cptrst_verify(struct ckpt_hdr_socket *h)
>  	if (!ckpt_validate_errno(h->sock.err))
>  		return -EINVAL;
>  
> -	/* None of our supported types use this flag */
> -	if (h->sock.flags & SOCK_DESTROY)
> -		return -EINVAL;
> -
>  	return 0;
>  }
>  
> @@ -239,15 +235,99 @@ static int sock_cptrst_bufopts(int op, struct sock *sock,
>  	return 0;
>  }
>  
> +static int sock_rst_flags(struct socket *sock,
> +			  struct ckpt_hdr_socket *h)
> +{
> +	int ret;
> +	int v = 1;
> +	unsigned long sk_flags = h->sock.flags;
> +	unsigned long sock_flags = h->socket.flags;
> +
> +	if (test_and_clear_bit(SOCK_URGINLINE, &sk_flags)) {
> +		ret = sock_setsockopt(sock, SOL_SOCKET, SO_OOBINLINE,
> +				      (char *)&v, sizeof(v));
> +		if (ret)
> +			return ret;
> +	}
> +
> +	if (test_and_clear_bit(SOCK_KEEPOPEN, &sk_flags)) {
> +		ret = sock_setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE,
> +				      (char *)&v, sizeof(v));
> +		if (ret)
> +			return ret;
> +	}
> +
> +	if (test_and_clear_bit(SOCK_BROADCAST, &sk_flags)) {
> +		ret = sock_setsockopt(sock, SOL_SOCKET, SO_BROADCAST,
> +				      (char *)&v, sizeof(v));
> +		if (ret)
> +			return ret;
> +	}
> +
> +	if (test_and_clear_bit(SOCK_RCVTSTAMP, &sk_flags)) {
> +		ret = sock_setsockopt(sock, SOL_SOCKET, SO_TIMESTAMP,
> +				      (char *)&v, sizeof(v));
> +		if (ret)
> +			return ret;
> +	}
> +
> +	if (test_and_clear_bit(SOCK_RCVTSTAMPNS, &sk_flags)) {
> +		ret = sock_setsockopt(sock, SOL_SOCKET, SO_TIMESTAMPNS,
> +				      (char *)&v, sizeof(v));
> +		if (ret)
> +			return ret;
> +	}
> +
> +	if (test_and_clear_bit(SOCK_DBG, &sk_flags)) {
> +		ret = sock_setsockopt(sock, SOL_SOCKET, SO_DEBUG,
> +				      (char *)&v, sizeof(v));
> +		if (ret)
> +			return ret;
> +	}
> +
> +	if (test_and_clear_bit(SOCK_LOCALROUTE, &sk_flags)) {
> +		ret = sock_setsockopt(sock, SOL_SOCKET, SO_DONTROUTE,
> +				      (char *)&v, sizeof(v));
> +		if (ret)
> +			return ret;
> +	}
> +
> +	if (test_and_clear_bit(SOCK_PASSCRED, &sock_flags)) {
> +		ret = sock_setsockopt(sock, SOL_SOCKET, SO_PASSCRED,
> +				      (char *)&v, sizeof(v));
> +		if (ret)
> +			return ret;
> +	}
> +
> +	/* TODO: Handle SOCK_TIMESTAMPING_* flags */
> +	if (test_bit(SOCK_TIMESTAMPING_TX_HARDWARE, &sk_flags) ||
> +	    test_bit(SOCK_TIMESTAMPING_TX_SOFTWARE, &sk_flags) ||
> +	    test_bit(SOCK_TIMESTAMPING_RX_HARDWARE, &sk_flags) ||
> +	    test_bit(SOCK_TIMESTAMPING_RX_SOFTWARE, &sk_flags) ||
> +	    test_bit(SOCK_TIMESTAMPING_SOFTWARE, &sk_flags) ||
> +	    test_bit(SOCK_TIMESTAMPING_RAW_HARDWARE, &sk_flags) ||
> +	    test_bit(SOCK_TIMESTAMPING_SYS_HARDWARE, &sk_flags)) {
> +		ckpt_debug("SOF_TIMESTAMPING_* flags are not supported\n");
> +		return -ENOSYS;
> +	}
> +
> +	/* Anything that is still set in the flags that isn't part of
> +	 * our protocol's default set, indicates an error
> +	 */
> +	if (sk_flags & ~sock->sk->sk_flags) {
> +		ckpt_debug("Unhandled sock flags: %lx\n", sk_flags);
> +		return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
>  static int sock_cptrst(struct ckpt_ctx *ctx,
>  		       struct sock *sock,
>  		       struct ckpt_hdr_socket *h,
>  		       int op)
>  {
> -	if (sock->sk_socket) {
> -		CKPT_COPY(op, h->socket.flags, sock->sk_socket->flags);
> -		CKPT_COPY(op, h->socket.state, sock->sk_socket->state);
> -	}
> +	CKPT_COPY(op, h->socket.state, sock->sk_socket->state);

[...]

When you add support to new socket due to connect() that were not
yet accept()ed from the listening socket - there will be a case of
a sock without sock->sk_socket.

This probably means that we want the test for sock->sk_socket to
remain as is (and a similar one in sock_rst_flags above)

Super nit: perhaps s/rst/restore/ ?  Besides agreeing with current
practice, it may dodge a related rant from Linux :o

Oren.
