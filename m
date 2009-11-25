From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Avoid capable() call in UNIX buffer check unless necessary
Date: Wed, 25 Nov 2009 13:52:26 -0500
Message-ID: <4B0D7CEA.6090402@cs.columbia.edu>
References: <1258557477-28642-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258557477-28642-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Queued for v19-rc2, thanks.

Oren.

Dan Smith wrote:
> As pointed out by Serge, we shouldn't call capable() unless we know we'll
> need to exercise the ability.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
> ---
>  net/unix/checkpoint.c |   11 ++++++++++-
>  1 files changed, 10 insertions(+), 1 deletions(-)
> 
> diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
> index 23040ce..55dfac1 100644
> --- a/net/unix/checkpoint.c
> +++ b/net/unix/checkpoint.c
> @@ -278,9 +278,18 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
>  		unix_sk(sk)->peer->sk_shutdown &= ~SHUTDOWN_MASK;
>  	}
>  
> -	/* Make sure there's room in the send buffer */
> +	/* Make sure there's room in the send buffer: Worst case, we
> +	 * give them the benefit of the doubt and set the buffer limit
> +	 * to the system default.  This should cover the case where
> +	 * the user set the limit low after loading up the buffer.
> +	 *
> +	 * However, if there isn't room in the buffer and the system
> +	 * default won't accommodate them either, then increase the
> +	 * limit as needed, only if they have CAP_NET_ADMIN.
> +	 */
>  	sndbuf = sk->sk_sndbuf;
>  	if (((sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc)) < h->lin_len) &&
> +	    (h->lin_len > sysctl_wmem_max) &&
>  	    capable(CAP_NET_ADMIN))
>  		sk->sk_sndbuf += h->lin_len;
>  	else
