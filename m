From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 10/54] Infrastructure for shared objects
Date: Wed, 29 Apr 2009 11:21:14 -0500
Message-ID: <20090429162114.GA2450@us.ibm.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<1240961064-13991-11-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1240961064-13991-11-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> +/**
> + * ckpt_obj_new - add an object to the obj_hash
> + * @ctx: checkpoint context
> + * @ptr: pointer to object
> + * @objref: object unique id
> + * @ops: object operations
> + *
> + * Returns: objref
> + *
> + * Add the object to the obj_hash. If @objref is zero, assign a unique
> + * object id and use @ptr as a hash key [checkpoint]. Else use @objref
> + * as a key [restart].
> + */
> +static int obj_new(struct ckpt_ctx *ctx, void *ptr, int objref,
> +		   struct ckpt_obj_ops *ops)
> +{
> +	struct ckpt_obj *obj;
> +	int i, ret;
> +
> +	obj = kmalloc(sizeof(*obj), GFP_KERNEL);
> +	if (!obj)
> +		return -ENOMEM;
> +
> +	obj->ptr = ptr;
> +	obj->ops = ops;
> +
> +	if (objref) {
> +		/* use @obj->objref to index (restart) */
> +		obj->objref = objref;
> +		i = hash_long((unsigned long) objref, CKPT_OBJ_HASH_NBITS);
> +	} else {
> +		/* use @obj->ptr to index, assign objref (checkpoint) */
> +		obj->objref = ctx->obj_hash->next_free_objref++;;
> +		i = hash_long((unsigned long) ptr, CKPT_OBJ_HASH_NBITS);
> +	}
> +
> +	ret = ops->ref_grab(obj->ptr);
> +	if (ret < 0)
> +		kfree(obj);
> +	else
> +		hlist_add_head(&obj->hash, &ctx->obj_hash->head[i]);
> +
> +	return (ret < 0 ? : obj->objref);
> +}

...

> +/**
> +* ckpt_obj_insert - add an object with a given objref to obj_hash
> +* @ctx: checkpoint context
> +* @ptr: pointer to object
> +* @objref: unique object id
> +* @type: object type
> +*
> +* Add the object pointer to by @ptr and identified by unique object id
> +* @objref to the hash table (indexed by @objref).  Grab a reference to
> +* every object added, and maintain it until the entire hash is freed.
> +*/
> +
> +int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
> +		    enum obj_type type)
> +{
> +	struct ckpt_obj_ops *ops = &ckpt_obj_ops[type];
> +
> +	ckpt_debug("%s objref %d\n", ops->obj_name, objref);
> +	return (obj_new(ctx, ptr, objref, ops) ? : 1);

This line doesn't make sense - obj_new can't return 0 ?

Also, the line isn't in this patch, but when you add the
obj_mm_* to objhash.c, the comment right above it claims
	/* inode object */

-serge
