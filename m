From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add a cleanup routine for objhash socket objects
Date: Tue, 15 Sep 2009 15:04:13 -0500
Message-ID: <20090915200412.GA22405@us.ibm.com>
References: <1253033531-6764-1-git-send-email-danms@us.ibm.com>
	<1253033531-6764-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1253033531-6764-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> This cleanup routine checks for unattached sockets that we instantiated
> and calls sock_release() on them to avoid leaking the struct socket when
> their buffers are consumed and the struct sock is free'd.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

I realize it's being discussed on irc, but it looks good to me, so
whatever variation you end up doing,

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  checkpoint/objhash.c |   13 +++++++++++++
>  1 files changed, 13 insertions(+), 0 deletions(-)
> 
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index 9750483..5626707 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -247,6 +247,18 @@ static void obj_sock_drop(void *ptr)
>  	sock_put((struct sock *) ptr);
>  }
> 
> +static void cleanup_sock(void *ptr)
> +{
> +	struct sock *sk = (struct sock *) ptr;
> +
> +	if (sk->sk_socket && !sk->sk_socket->file) {
> +		struct socket *sock = sk->sk_socket;
> +		sock_orphan(sk);
> +		sock->sk = NULL;
> +		sock_release(sock);
> +	}
> +}
> +
>  static struct ckpt_obj_ops ckpt_obj_ops[] = {
>  	/* ignored object */
>  	{
> @@ -384,6 +396,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
>  		.ref_grab = obj_sock_grab,
>  		.checkpoint = checkpoint_sock,
>  		.restore = restore_sock,
> +		.cleanup = cleanup_sock,
>  	},
>  };
> 
> -- 
> 1.6.2.5
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
