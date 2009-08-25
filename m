From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] Set socket flags on restore using sock_setsockopt() where
	possible (v3)
Date: Tue, 25 Aug 2009 01:54:21 -0400
Message-ID: <4A937C8D.1070302@librato.com>
References: <1251140047-14246-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1251140047-14246-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


This one added, too.

Dan Smith wrote:
> Fail on the TIMESTAMPING_* flags for the moment, with a TODO in place to
> handle them later.
> 
> Also remove other explicit flag checks because they're no longer copied
> blindly into the socket object, so existing checks will be sufficient.
> 
> Changes in v3:
>  - Move socket flag restore procedures into some common functions and a
>    mapping list.  While definitely nicer to look at, my diffstat shows it
>    as only saving a single line of code over the previous, while dropping
>    the ability to print symbolic flag names in the error messages.
> 
> Changes in v2:
>  - Avoid removing the sock->sk_socket check before sync'ing the socket.flags
>  - Rename sock_rst_flags() to sock_restore_flags()
>  - Rebase on top of Oren's cleanup patch
> 
> Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  net/checkpoint.c |  112 ++++++++++++++++++++++++++++++++++++++++++++++++-----
>  1 files changed, 101 insertions(+), 11 deletions(-)
> 
> diff --git a/net/checkpoint.c b/net/checkpoint.c
> index c64483e..44dc3f1 100644
> --- a/net/checkpoint.c
> +++ b/net/checkpoint.c
> @@ -178,10 +178,6 @@ static int sock_cptrst_verify(struct ckpt_hdr_socket *h)
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
> @@ -238,11 +234,96 @@ static int sock_cptrst_bufopts(int op, struct sock *sk,
>  	return 0;
>  }
>  
> +struct sock_flag_mapping {
> +	int opt;
> +	int flag;
> +};
> +
> +struct sock_flag_mapping sk_flag_map[] = {
> +	{SO_OOBINLINE, SOCK_URGINLINE},
> +	{SO_KEEPALIVE, SOCK_KEEPOPEN},
> +	{SO_BROADCAST, SOCK_BROADCAST},
> +	{SO_TIMESTAMP, SOCK_RCVTSTAMP},
> +	{SO_TIMESTAMPNS, SOCK_RCVTSTAMPNS},
> +	{SO_DEBUG, SOCK_DBG},
> +	{SO_DONTROUTE, SOCK_LOCALROUTE},
> +};
> +
> +struct sock_flag_mapping sock_flag_map[] = {
> +	{SO_PASSCRED, SOCK_PASSCRED},
> +};
> +
> +static int sock_restore_flag(struct socket *sock,
> +			     unsigned long *flags,
> +			     int flag,
> +			     int option)
> +{
> +	int v = 1;
> +	int ret = 0;
> +
> +	if (test_and_clear_bit(flag, flags))
> +		ret = sock_setsockopt(sock, SOL_SOCKET, option,
> +				      (char *)&v, sizeof(v));
> +
> +	return ret;
> +}
> +
> +
> +static int sock_restore_flags(struct socket *sock,
> +                             struct ckpt_hdr_socket *h)
> +{
> +       int ret;
> +       int i;
> +       unsigned long sk_flags = h->sock.flags;
> +       unsigned long sock_flags = h->socket.flags;
> +
> +       for (i = 0; i < ARRAY_SIZE(sk_flag_map); i++) {
> +	       int opt = sk_flag_map[i].opt;
> +	       int flag = sk_flag_map[i].flag;
> +	       ret = sock_restore_flag(sock, &sk_flags, flag, opt);
> +	       if (ret) {
> +		       ckpt_debug("Failed to set skopt %i: %i\n", opt, ret);
> +		       return ret;
> +	       }
> +       }
> +
> +       for (i = 0; i < ARRAY_SIZE(sock_flag_map); i++) {
> +	       int opt = sock_flag_map[i].opt;
> +	       int flag = sock_flag_map[i].flag;
> +	       ret = sock_restore_flag(sock, &sock_flags, flag, opt);
> +	       if (ret) {
> +		       ckpt_debug("Failed to set sockopt %i: %i\n", opt, ret);
> +		       return ret;
> +	       }
> +       }
> +
> +       /* TODO: Handle SOCK_TIMESTAMPING_* flags */
> +       if (test_bit(SOCK_TIMESTAMPING_TX_HARDWARE, &sk_flags) ||
> +           test_bit(SOCK_TIMESTAMPING_TX_SOFTWARE, &sk_flags) ||
> +           test_bit(SOCK_TIMESTAMPING_RX_HARDWARE, &sk_flags) ||
> +           test_bit(SOCK_TIMESTAMPING_RX_SOFTWARE, &sk_flags) ||
> +           test_bit(SOCK_TIMESTAMPING_SOFTWARE, &sk_flags) ||
> +           test_bit(SOCK_TIMESTAMPING_RAW_HARDWARE, &sk_flags) ||
> +           test_bit(SOCK_TIMESTAMPING_SYS_HARDWARE, &sk_flags)) {
> +               ckpt_debug("SOF_TIMESTAMPING_* flags are not supported\n");
> +               return -ENOSYS;
> +       }
> +
> +       /* Anything that is still set in the flags that isn't part of
> +        * our protocol's default set, indicates an error
> +        */
> +       if (sk_flags & ~sock->sk->sk_flags) {
> +               ckpt_debug("Unhandled sock flags: %lx\n", sk_flags);
> +               return -EINVAL;
> +       }
> +
> +       return 0;
> +}
> +
>  static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
>  		       struct ckpt_hdr_socket *h, int op)
>  {
>  	if (sk->sk_socket) {
> -		CKPT_COPY(op, h->socket.flags, sk->sk_socket->flags);
>  		CKPT_COPY(op, h->socket.state, sk->sk_socket->state);
>  	}
>  
> @@ -259,12 +340,6 @@ static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
>  	CKPT_COPY(op, h->sock.state, sk->sk_state);
>  	CKPT_COPY(op, h->sock.backlog, sk->sk_max_ack_backlog);
>  
> -	/* TODO:
> -	 * Break out setting each of the flags to use setsockopt() or
> -	 * perform proper security check
> -	 */
> -	CKPT_COPY(op, h->sock.flags, sk->sk_flags);
> -
>  	if (sock_cptrst_bufopts(op, sk, h))
>  		return -EINVAL;
>  
> @@ -298,6 +373,21 @@ static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
>  		return -EINVAL;
>  	}
>  
> +	if (op == CKPT_CPT) {
> +		h->sock.flags = sk->sk_flags;
> +		h->socket.flags = sk->sk_socket->flags;
> +	} else {
> +		int ret;
> +		mm_segment_t old_fs;
> +
> +		old_fs = get_fs();
> +		set_fs(KERNEL_DS);
> +		ret = sock_restore_flags(sk->sk_socket, h);
> +		set_fs(old_fs);
> +		if (ret)
> +			return ret;
> +	}
> +
>  	if ((h->socket.state == SS_CONNECTED) &&
>  	    (h->sock.state != TCP_ESTABLISHED)) {
>  		ckpt_debug("socket/sock in inconsistent state: %i/%i",
