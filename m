From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/7] Make restore_obj() tolerate a preexisting object
	in the hash (v2)
Date: Fri, 19 Mar 2010 10:21:56 -0500
Message-ID: <20100319152156.GA528@us.ibm.com>
References: <1268945512-18814-1-git-send-email-danms@us.ibm.com>
	<1268945512-18814-2-git-send-email-danms@us.ibm.com>
	<20100319000434.GA5505@us.ibm.com>
	<8739zwgxua.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8739zwgxua.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> SH> I don't think this part of the comment is quite right here.  The
> SH> "on failure this cleans up the object itself" really is for the
> SH> ref_drop under IS_ERR() check below.
> 
> SH> The ref_drop here is for the ref taken by obj_new(), which is only
> SH> done in this path of course.
> 
> As just discussed on IRC, I couldn't really correct the comment
> because the logic it was describing was incorrect.  Below is a version
> with the correct comment *and* logic :)
> 
> -- 
> Dan Smith
> IBM Linux Technology Center
> email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
> 
> Make restore_obj() tolerate a preexisting object in the hash (v3)
> 
> ... as long as the pointer is the same as that returned from the restore
> function.  Also move the compulsory ref_drop() so that it only gets
> done if we created the new object.
> 
> The existing object tolerance is important for netdev restore because it
> means that I can refer to a peer by its objref instead of needing the
> (previously-rejected) veth_peer() function.  If this is not acceptable,
> then I'll need to keep a separate list of pairs.
> 
> Changes in v3:
>  - Fix the logic in the case where we need to do an obj_new() and fail,
>    so that we don't do ref_drop() twice
> 
> Changes in v2:
>  - Check that the type of the object already in the hash matches that
>    of the objref header we're reading.
>  - Add a comment about why and how we might get into this sort of
>    situation.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Thanks, Dan, for also fixing pre-existing bug  :)

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-serge

> 
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index 7208382..3b360cb 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -1064,17 +1064,32 @@ int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h)
>  	if (IS_ERR(ptr))
>  		return PTR_ERR(ptr);
> 
> -	if (obj_find_by_objref(ctx, h->objref))
> -		obj = ERR_PTR(-EINVAL);
> -	else
> +	obj = obj_find_by_objref(ctx, h->objref);
> +	if (!obj) {
>  		obj = obj_new(ctx, ptr, h->objref, h->objtype);
> -	/*
> -	 * Drop an extra reference to the object returned by ops->restore:
> -	 * On success, this clears the extra reference taken by obj_new(),
> -	 * and on failure, this cleans up the object itself.
> -	 */
> -	ops->ref_drop(ptr, 0);
> +		/*
> +		 * Drop an extra reference to the object returned by
> +		 * ops->restore to balance the one taken by obj_new()
> +		 */
> +		if (!IS_ERR(obj))
> +			ops->ref_drop(ptr, 0);
> +	} else if ((obj->ptr != ptr) || (obj->ops->obj_type != h->objtype)) {
> +		/* Normally, we expect an object to not already exist
> +		 * in the hash.  However, for some special scenarios
> +		 * where we're restoring sets of objects that must be
> +		 * co-allocated (such, as veth netdev pairs) we need
> +		 * to tolerate this case if the second restore returns
> +		 * the correct type and pointer, as specified in the
> +		 * existing object.  If either of those don't match,
> +		 * we fail.
> +		 */
> +		obj = ERR_PTR(-EINVAL);
> +	}
> +
>  	if (IS_ERR(obj)) {
> +		/* This releases our final reference on the object
> +		 * returned by ops->restore()
> +		 */
>  		ops->ref_drop(ptr, 1);
>  		return PTR_ERR(obj);
>  	}
