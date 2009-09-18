From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] Fix ckpt_obj_lookup_add() leak detection logic
Date: Fri, 18 Sep 2009 13:01:12 -0400
Message-ID: <4AB3BCD8.1080102@librato.com>
References: <1253207274-7563-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253207274-7563-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Got it, thanks.

Dan Smith wrote:
> Since first is a pointer, it's never NULL and thus leak detection will
> always be performed (of CHECKPOINT_SUBTREE is set).  This fatally breaks
> the checkpoint process when that flag is enabled because any object (with
> a ref_users operation) that is added to the hash twice will be reported as
> a reverse leak.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/objhash.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index 8dfb0b0..b85aa77 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -679,7 +679,7 @@ int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
>  	ckpt_debug("%s objref %d first %d\n",
>  		   obj->ops->obj_name, obj->objref, *first);
>  
> -	if (first && obj_reverse_leak(ctx, obj))
> +	if (*first && obj_reverse_leak(ctx, obj))
>  		return -EBUSY;
>  
>  	obj->flags |= CKPT_OBJ_VISITED;
