From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Fix potential restart failure on uninitialized sockets
Date: Mon, 19 Jul 2010 22:45:49 -0400
Message-ID: <4C450DDD.4000703@cs.columbia.edu>
References: <1279134384-3856-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1279134384-3856-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Dan,

This looks fine.

Only one comment: please rename sock_should_do_buffers()
since it's exclusive for c/r and exported in checkpoint.h,
e.g. ckpt_sock_need_buffers(). No need to resend - I can
do it while pulling.

Oren.

On 07/14/2010 03:06 PM, Dan Smith wrote:
> The logic used to determine whether or not we should checkpoint or
> restore a socket's buffers was not unified and thus differed in a couple
> of places.  This caused a restart failure in the ipv4 code when the
> checkpoint decided to write buffers of an unbound socket and ipv4 restart
> didn't read them.
> 
> This adds a should-we-do-it function to checkpoint.h and makes the unified
> checkpoint code use it, as well as unix and ipv4.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/checkpoint.h |    5 +++++
>  net/checkpoint.c           |    2 +-
>  net/ipv4/checkpoint.c      |    6 +++---
>  net/unix/checkpoint.c      |    2 +-
>  4 files changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index a796308..d2279c1 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -38,6 +38,7 @@
>  #include <linux/err.h>
>  #include <linux/inetdevice.h>
>  #include <net/sock.h>
> +#include <net/tcp_states.h>
>  
>  /* sycall helpers */
>  extern long do_sys_checkpoint(pid_t pid, int fd,
> @@ -125,6 +126,10 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
>  			      struct sockaddr *rem, unsigned *rem_len);
>  extern struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx, struct sock *sk);
>  extern void sock_listening_list_free(struct list_head *head);
> +static inline int sock_should_do_buffers(struct sock *sk)
> +{
> +	return (sk->sk_state != TCP_LISTEN) && !sock_flag(sk, SOCK_DEAD);
> +}
>  
>  #ifdef CONFIG_NETNS_CHECKPOINT
>  extern int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr);
> diff --git a/net/checkpoint.c b/net/checkpoint.c
> index b1f56bf..1a03fbc 100644
> --- a/net/checkpoint.c
> +++ b/net/checkpoint.c
> @@ -776,7 +776,7 @@ static int __do_sock_checkpoint(struct ckpt_ctx *ctx, struct sock *sk)
>  		goto out;
>  
>  	/* part III: socket buffers */
> -	if ((sk->sk_state != TCP_LISTEN) && (!sock_flag(sk, SOCK_DEAD)))
> +	if (sock_should_do_buffers(sk))
>  		ret = sock_defer_write_buffers(ctx, sk);
>   out:
>  	ckpt_hdr_put(ctx, h);
> diff --git a/net/ipv4/checkpoint.c b/net/ipv4/checkpoint.c
> index bc4c998..e71e5d9 100644
> --- a/net/ipv4/checkpoint.c
> +++ b/net/ipv4/checkpoint.c
> @@ -537,10 +537,10 @@ int inet_restore(struct ckpt_ctx *ctx,
>  			 */
>  			ret = sock_defer_hash(ctx, sock->sk);
>  		}
> -
> -		if (!sock_flag(sock->sk, SOCK_DEAD))
> -			ret = inet_defer_restore_buffers(ctx, sock->sk);
>  	}
> +
> +	if (sock_should_do_buffers(sock->sk))
> +		ret = inet_defer_restore_buffers(ctx, sock->sk);
>   out:
>  	ckpt_hdr_put(ctx, in);
>  
> diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
> index c90a497..230b35d 100644
> --- a/net/unix/checkpoint.c
> +++ b/net/unix/checkpoint.c
> @@ -443,7 +443,7 @@ static int unix_restore_connected(struct ckpt_ctx *ctx,
>  		ckpt_debug("unix_defer_join: %i\n", ret);
>  	}
>  
> -	if (!dead && !ret)
> +	if (sock_should_do_buffers(sock->sk) && !ret)
>  		ret = unix_defer_restore_buffers(ctx, un->this);
>  
>  	return ret;
