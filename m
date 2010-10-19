From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Clear the objhash before completing restart,	but
	delay free (v2)
Date: Tue, 19 Oct 2010 11:46:33 -0700
Message-ID: <20101019184633.GB10119@count0.beaverton.ibm.com>
References: <1287496991-18207-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1287496991-18207-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, matthltc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 19, 2010 at 07:03:11AM -0700, Dan Smith wrote:
> This patch causes the restart coordinator to clear the object hash
> before releasing the restarted tasks.  It does this to make sure
> that any objects being held exclusively by the hash are released
> before the tasks start running again.
> 
> If we continue to postpone clearing the object hash until restart
> returns to userspace there can be a race where the restarted tasks
> behave differently due to the references held by the objhash.
> One specific example of this is restarting half-closed pipes.
> Without this patch we've got a race between the coordinator --
> about to clear the object hash -- and two restarted tasks connected
> via a half-closed pipe. Because the object hash contains a reference
> to both ends of the pipe one end of the pipe will not be closed
> and EPIPE/SIGPIPE won't be handled when reading from the pipe
> for instance. As far as the restarted userspace task can tell the
> pipe may briefly appear to re-open. Moving the object hash clear
> prevents this race and others like it.
> 
> Note that eventually the coordinator would close the pipe and correct
> behavior would be restored. Thus this bug would only affect the
> correctness of userspace -- after a close() the pipe may briefly re-open
> and allow more data to be sent before automatically closing again.
> 
> To avoid the overhead of actually freeing the object hash's structures
> at the same time, this adds a queue to ckpt_obj_hash and pushes
> the ckpt_obj structures there to be free()'d later during the cleanup
> process.
> 
> Changes in v2:
>  - Avoid adding another list_head to ckpt_obj by re-using the hlist
>    hash node for the free list
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Looks good.

Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  include/linux/checkpoint.h  |    1 +
>  kernel/checkpoint/objhash.c |   18 +++++++++++++++---
>  kernel/checkpoint/restart.c |    2 ++
>  3 files changed, 18 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index a11d40e..f888363 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -179,6 +179,7 @@ extern void restore_notify_error(struct ckpt_ctx *ctx);
>  extern int ckpt_obj_module_get(void);
>  extern void ckpt_obj_module_put(void);
> 
> +extern void ckpt_obj_hash_clear(struct ckpt_ctx *ctx);
>  extern void ckpt_obj_hash_free(struct ckpt_ctx *ctx);
>  extern int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx);
> 
> diff --git a/kernel/checkpoint/objhash.c b/kernel/checkpoint/objhash.c
> index 62c34ff..4aae0c0 100644
> --- a/kernel/checkpoint/objhash.c
> +++ b/kernel/checkpoint/objhash.c
> @@ -36,6 +36,7 @@ struct ckpt_obj {
>  struct ckpt_obj_hash {
>  	struct hlist_head *head;
>  	struct hlist_head list;
> +	struct hlist_head free;
>  	int next_free_objref;
>  };
> 
> @@ -128,8 +129,9 @@ int ckpt_obj_module_get(void)
>  #define CKPT_OBJ_HASH_NBITS  10
>  #define CKPT_OBJ_HASH_TOTAL  (1UL << CKPT_OBJ_HASH_NBITS)
> 
> -static void obj_hash_clear(struct ckpt_obj_hash *obj_hash)
> +void ckpt_obj_hash_clear(struct ckpt_ctx *ctx)
>  {
> +	struct ckpt_obj_hash *obj_hash = ctx->obj_hash;
>  	struct hlist_head *h = obj_hash->head;
>  	struct hlist_node *n, *t;
>  	struct ckpt_obj *obj;
> @@ -139,7 +141,9 @@ static void obj_hash_clear(struct ckpt_obj_hash *obj_hash)
>  		hlist_for_each_entry_safe(obj, n, t, &h[i], hash) {
>  			if (obj->ops->ref_drop)
>  				obj->ops->ref_drop(obj->ptr, 1);
> -			kfree(obj);
> +			hlist_del_init(&obj->hash);
> +			hlist_del(&obj->next);
> +			hlist_add_head(&obj->hash, &obj_hash->free);
>  		}
>  	}
>  }
> @@ -149,7 +153,14 @@ void ckpt_obj_hash_free(struct ckpt_ctx *ctx)
>  	struct ckpt_obj_hash *obj_hash = ctx->obj_hash;
> 
>  	if (obj_hash) {
> -		obj_hash_clear(obj_hash);
> +		struct hlist_node *pos, *n;
> +		struct ckpt_obj *obj;
> +
> +		ckpt_obj_hash_clear(ctx);
> +
> +		hlist_for_each_entry_safe(obj, pos, n, &obj_hash->free, hash)
> +			kfree(obj);
> +
>  		kfree(obj_hash->head);
>  		kfree(ctx->obj_hash);
>  		ctx->obj_hash = NULL;
> @@ -173,6 +184,7 @@ int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx)
>  	obj_hash->head = head;
>  	obj_hash->next_free_objref = 1;
>  	INIT_HLIST_HEAD(&obj_hash->list);
> +	INIT_HLIST_HEAD(&obj_hash->free);
> 
>  	ctx->obj_hash = obj_hash;
>  	return 0;
> diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
> index 17270b8..f2241a9 100644
> --- a/kernel/checkpoint/restart.c
> +++ b/kernel/checkpoint/restart.c
> @@ -1349,6 +1349,8 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
>  	if (ret < 0)
>  		ckpt_err(ctx, ret, "restart failed (coordinator)\n");
> 
> +	ckpt_obj_hash_clear(ctx);
> +
>  	if (ckpt_test_error(ctx)) {
>  		destroy_descendants(ctx);
>  		ret = ckpt_get_error(ctx);
> -- 
> 1.7.2.2
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
