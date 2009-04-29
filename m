From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 10/54] Infrastructure for shared objects
Date: Tue, 28 Apr 2009 20:03:17 -0500
Message-ID: <20090429010317.GA25288@us.ibm.com>
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
> + * checkpoint_obj - if not already in hash, add object and checkpoint
> + * @ctx: checkpoint context
> + * @ptr: pointer to object
> + * @type: object type
> + *
> + * Look up the object pointed to by @ptr in the hash table. If it
> + * isn't already there, then add the object to the table, allocate a
> + * fresh unique id (objref) and save the object's state, and grab a
> + * reference to every object that is added. (Maintain the reference
> + * until the entire hash is free).
> + *
> + * [This is used during checkpoint].
> + *
> + * Returns: objref
> + */
> +int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
> +{
> +	struct ckpt_obj_ops *ops = &ckpt_obj_ops[type];
> +	struct ckpt_hdr_objref *h;
> +	struct ckpt_obj *obj;
> +	int objref, ret;
> +
> +	/* make sure we don't change this accidentally */
> +	BUG_ON(ops->obj_type != type);
> +
> +	obj = obj_find_by_ptr(ctx, ptr);
> +	if (obj) {
> +		BUG_ON(obj->ops->obj_type != type);
> +		return obj->objref;
> +	}
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_OBJREF);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	objref = obj_new(ctx, ptr, 0, ops);
> +	if (objref < 0)

	ckpt_hdr_put(ctx, h);    ?

> +		return objref;
> +
> +	h->objtype = type;
> +	h->objref = objref;
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	ckpt_hdr_put(ctx, h);

-serge
