From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Change the logic in obj_sock_adjust_users()
Date: Thu, 16 Sep 2010 00:50:20 -0400
Message-ID: <4C91A20C.4010708@cs.columbia.edu>
References: <1284071121-17701-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1284071121-17701-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Simple enough - queued for v22-dev.

Oren

On 09/09/2010 06:25 PM, Dan Smith wrote:
> The explicit decrement of obj->users isn't correct for all cases of
> SOCK_DEAD, so this patch changes it to the result of ref_users() to
> avoid the false positive in the leak check.  I have confirmed with
> sockets in both SOCK_DEAD situations that we don't leak them with
> this change.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/checkpoint/objhash.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/checkpoint/objhash.c b/kernel/checkpoint/objhash.c
> index a7b8b7d..62c34ff 100644
> --- a/kernel/checkpoint/objhash.c
> +++ b/kernel/checkpoint/objhash.c
> @@ -546,7 +546,7 @@ static void ckpt_obj_users_inc(struct ckpt_ctx *ctx, void *ptr, int increment)
>   * obj_sock_adjust_users - remove implicit reference on DEAD sockets
>   * @obj: CKPT_OBJ_SOCK object to adjust
>   *
> - * Sockets that have been disconnected from their struct file have
> + * Sockets that have been disconnected from their struct file may have
>   * a reference count one less than normal sockets.  The objhash's
>   * assumption of such a reference is therefore incorrect, so we correct
>   * it here.
> @@ -556,7 +556,7 @@ static inline void obj_sock_adjust_users(struct ckpt_obj *obj)
>  	struct sock *sk = (struct sock *)obj->ptr;
>  
>  	if (sock_flag(sk, SOCK_DEAD)) {
> -		obj->users--;
> +		obj->users = obj->ops->ref_users(obj->ptr);
>  		ckpt_debug("Adjusting SOCK %i count to %i\n",
>  			   obj->objref, obj->users);
>  	}
