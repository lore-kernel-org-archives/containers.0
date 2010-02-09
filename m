From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] Make restore_obj() tolerate a preexisting object
	in the hash
Date: Tue, 9 Feb 2010 15:21:54 -0600
Message-ID: <20100209212154.GA32513@us.ibm.com>
References: <1265736604-24194-1-git-send-email-danms@us.ibm.com>
	<1265736604-24194-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1265736604-24194-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> ... as long as the pointer is the same as that returned from the restore
> function.  Also move the compulsory ref_drop() so that it only gets
> done if we created the new object.
> 
> The existing object tolerance is important for netdev restore because it
> means that I can refer to a peer by its objref instead of needing the
> (previously-rejected) veth_peer() function.  If this is not acceptable,
> then I'll need to keep a separate list of pairs.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/objhash.c |   19 +++++++++++--------
>  1 files changed, 11 insertions(+), 8 deletions(-)
> 
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index 0b06b06..6051c8d 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -1059,16 +1059,19 @@ int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h)
>  	if (IS_ERR(ptr))
>  		return PTR_ERR(ptr);
> 
> -	if (obj_find_by_objref(ctx, h->objref))
> +	obj = obj_find_by_objref(ctx, h->objref);
> +	if (obj && (obj->ptr != ptr))
>  		obj = ERR_PTR(-EINVAL);
> -	else
> +	else {
>  		obj = obj_new(ctx, ptr, h->objref, h->objtype);

Sorry, I *must* not be thinking straight, but...

don't you want to do the obj_new only if obj==NULL here?  So

if (obj) {
	if (obj->ptr != ptr)
		return -EINVAL;
	else
		return obj->objref;
}
obj = obj_new(...)
...

?

> -	/*
> -	 * Drop an extra reference to the object returned by ops->restore:
> -	 * On success, this clears the extra reference taken by obj_new(),
> -	 * and on failure, this cleans up the object itself.
> -	 */
> -	ops->ref_drop(ptr, 0);
> +		/*
> +		 * Drop an extra reference to the object returned by
> +		 * ops->restore: On success, this clears the extra
> +		 * reference taken by obj_new(), and on failure, this
> +		 * cleans up the object itself.
> +		 */
> +		ops->ref_drop(ptr, 0);
> +	}
>  	if (IS_ERR(obj)) {
>  		ops->ref_drop(ptr, 1);
>  		return PTR_ERR(obj);
> -- 
> 1.6.2.5
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
