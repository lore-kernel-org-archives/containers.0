From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] cr: be more informative with obj_new errors
Date: Fri, 9 Apr 2010 16:15:14 -0500
Message-ID: <20100409211514.GA18061@hallyn.com>
References: <1270847578-26250-1-git-send-email-serue@us.ibm.com>
	<1270847578-26250-2-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1270847578-26250-2-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Serge Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> If some checkpoint object type was mis-registered or mis-used,
> at least give some info to help deduce the caller.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/checkpoint/objhash.c |   13 +++++++++++--
>  1 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/checkpoint/objhash.c b/kernel/checkpoint/objhash.c
> index af1e5e7..6a3937e 100644
> --- a/kernel/checkpoint/objhash.c
> +++ b/kernel/checkpoint/objhash.c
> @@ -188,9 +188,18 @@ static struct ckpt_obj *obj_new(struct ckpt_ctx *ctx, void *ptr,
>  	int i, ret;
>  
>  	/* explicitly disallow null pointers */
> -	BUG_ON(!ptr);
> +	if (!ptr) {
> +		ckpt_err(ctx, -EINVAL, "checkpointing NULL type %d\n", type);
> +		return -EINVAL;

Gah, sorry, that should be an ERR_PTR(-EINVAL) of course

> +	}
> +
>  	/* make sure we don't change this accidentally */
> -	BUG_ON(ops->obj_type != type);
> +	if (ops->obj_type != type)
> +	{
> +		ckpt_err(ctx, -EINVAL, "type mismatch: %d->ops->obj_type %d\n",
> +			type, ops->obj_type);
> +		return ERR_PTR(-EINVAL);
> +	}
>  
>  	obj = kzalloc(sizeof(*obj), GFP_KERNEL);
>  	if (!obj)
> -- 
> 1.7.0.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
