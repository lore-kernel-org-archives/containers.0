From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 3/3] Make sure we free the struct socket of SOCK_DEAD
	sockets
Date: Mon, 14 Sep 2009 15:09:11 -0400
Message-ID: <4AAE94D7.6060802@librato.com>
References: <1252946924-4401-1-git-send-email-danms@us.ibm.com>
	<1252946924-4401-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1252946924-4401-4-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Avoid the leak reported by Serge for sockets that don't get attached to
> a file.  Do this by orphaning the socket on restore if it is marked as
> SOCK_DEAD.  If it is needed later for sending a buffer, temporarily
> adopt it for that process.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

This works well for the case of successful restart, but I suspect it
doesn't cover two other cases:

1) Malicious user removes the SOCK_DEAD marking off a socket.
2) Restart fails after a socket is restored but before it is attached
to a process.

In both cases, the sk->sk_socket of a non-dead socket isn't freed.

Note that we could detect the inconsistency of case 1 at the end of
restart, if there are non-attached sockets that aren't dead. But I
doubt if it makes any difference, because it is harmless (assuming
that the cleanup is indeed fixed).

Oren.

> ---
>  net/checkpoint.c      |   13 ++++++++++++-
>  net/unix/checkpoint.c |   16 ++++++++++++++++
>  2 files changed, 28 insertions(+), 1 deletions(-)
> 
> diff --git a/net/checkpoint.c b/net/checkpoint.c
> index d22341a..0bfca77 100644
> --- a/net/checkpoint.c
> +++ b/net/checkpoint.c
> @@ -627,6 +627,7 @@ struct sock *do_sock_restore(struct ckpt_ctx *ctx)
>  {
>  	struct ckpt_hdr_socket *h;
>  	struct socket *sock;
> +	struct sock *sk;
>  	int ret;
>  
>  	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
> @@ -661,7 +662,14 @@ struct sock *do_sock_restore(struct ckpt_ctx *ctx)
>  
>  	ckpt_hdr_put(ctx, h);
>  
> -	return sock->sk;
> +	sk = sock->sk;
> +	if (sock_flag(sk, SOCK_DEAD)) {
> +		sock_orphan(sk);
> +		sock->sk = NULL;
> +		sock_release(sock);
> +	}
> +
> +	return sk;
>   err:
>  	ckpt_hdr_put(ctx, h);
>  	sock_release(sock);
> @@ -688,6 +696,9 @@ struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
>  	if (IS_ERR(sk))
>  		return ERR_PTR(PTR_ERR(sk));
>  
> +	/* We should have a struct socket if we were attached to a file */
> +	BUG_ON(!sk->sk_socket);
> +
>  	file = sock_alloc_attach_fd(sk->sk_socket);
>  	if (IS_ERR(file))
>  		return file;
> diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
> index 60f6a0c..da2b408 100644
> --- a/net/unix/checkpoint.c
> +++ b/net/unix/checkpoint.c
> @@ -180,6 +180,7 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
>  	struct kvec kvec;
>  	struct ckpt_hdr_socket_buffer *h;
>  	struct sock *sk;
> +	struct socket *sock = NULL;
>  	uint8_t sock_shutdown;
>  	uint8_t peer_shutdown = 0;
>  	void *buf;
> @@ -229,6 +230,15 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
>  			ckpt_debug("Failed to join: %i\n", ret);
>  			goto out;
>  		}
> +	} else
> +
> +	if (!sk->sk_socket) {
> +		ret = sock_create(sk->sk_family, sk->sk_type, 0, &sock);
> +		if (ret < 0)
> +			goto out;
> +		if (unix_sk(sk)->peer)
> +			sock->state = SS_CONNECTED;
> +		sock_graft(sk, sock);
>  	}
>  
>  	kvec.iov_len = len;
> @@ -275,6 +285,12 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
>  	ckpt_hdr_put(ctx, h);
>  	kfree(buf);
>  
> +	if (sock) {
> +		sock_orphan(sk);
> +		sock->sk = NULL;
> +		sock_release(sock);
> +	}
> +
>  	return ret;
>  }
>  
