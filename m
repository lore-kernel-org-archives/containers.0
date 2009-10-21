From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] epoll: Add support for checkpointing large numbers
	of epoll items
Date: Wed, 21 Oct 2009 09:59:50 -0500
Message-ID: <20091021145950.GA13327@us.ibm.com>
References: <ce2e15faf44e254b80578c6c62e71d8685516896.1255971848.git.matthltc@us.ibm.com>
	<d0fd1f3eb4eaa326488f59955e5b4790080f3073.1255971848.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <d0fd1f3eb4eaa326488f59955e5b4790080f3073.1255971848.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Currently we allocate memory to output all of the epoll items in one
> big chunk. At 20 bytes per item, and since epoll was designed to
> support on the order of 10,000 items, we may find ourselves kmalloc'ing
> 200,000 bytes. That's an order 7 allocation whereas the heuristic for
> difficult allocations, PAGE_ALLOC_COST_ORDER, is 3.
> 
> Instead, output the epoll header and items separately. Chunk the output
> much like the pid array gets chunked. This ensures that even sub-order 0
> allocations will enable checkpoint of large epoll sets. A subsequent
> patch will do something similar for the restore path.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Feels a bit auto-tune-magic-happy :) but looks good

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  fs/eventpoll.c |   71 ++++++++++++++++++++++++++++++++++++-------------------
>  1 files changed, 46 insertions(+), 25 deletions(-)
> 
> diff --git a/fs/eventpoll.c b/fs/eventpoll.c
> index 4706ec5..2506b40 100644
> --- a/fs/eventpoll.c
> +++ b/fs/eventpoll.c
> @@ -1480,7 +1480,7 @@ static int ep_items_checkpoint(void *data)
>  	struct rb_node *rbp;
>  	struct eventpoll *ep;
>  	__s32 epfile_objref;
> -	int i, num_items, ret;
> +	int num_items = 0, nchunk, ret;
> 
>  	ctx = dq_entry->ctx;
> 
> @@ -1489,9 +1489,8 @@ static int ep_items_checkpoint(void *data)
> 
>  	ep = dq_entry->epfile->private_data;
>  	mutex_lock(&ep->mtx);
> -	for (i = 0, rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp), i++) {}
> +	for (rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp), num_items++) {}
>  	mutex_unlock(&ep->mtx);
> -	num_items = i;
> 
>  	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_EPOLL_ITEMS);
>  	if (!h)
> @@ -1503,36 +1502,58 @@ static int ep_items_checkpoint(void *data)
>  	if (ret || !num_items)
>  		return ret;
> 
> -	items = kzalloc(sizeof(*items)*num_items, GFP_KERNEL);
> +	ret = ckpt_write_obj_type(ctx, NULL, sizeof(*items)*num_items,
> +				  CKPT_HDR_BUFFER);
> +	if (ret < 0)
> +		return ret;
> +
> +	nchunk = num_items;
> +	do {
> +		items = kzalloc(sizeof(*items)*nchunk, GFP_KERNEL);
> +		if (items)
> +			break;
> +		nchunk = nchunk >> 1;
> +	} while (nchunk > 0);
>  	if (!items)
>  		return -ENOMEM;
> +
> +	/*
> +	 * Walk the rbtree copying items into the chunk of memory and then
> +	 * writing them to the checkpoint image
> +	 */
>  	ret = 0;
> -	i = 0;
>  	mutex_lock(&ep->mtx);
> -	for (rbp = rb_first(&ep->rbr); i < num_items && rbp; rbp = rb_next(rbp),
> -	     i++) {
> -		struct epitem *epi;
> -		int objref;
> -
> -		epi = rb_entry(rbp, struct epitem, rbn);
> -		items[i].fd = epi->ffd.fd;
> -		items[i].events = epi->event.events;
> -		items[i].data = epi->event.data;
> -		objref = ckpt_obj_lookup(ctx, epi->ffd.file, CKPT_OBJ_FILE);
> -		if (objref <= 0) {
> -			ret = -EBUSY; /* missing item -- checkpoint obj leak */
> -			break;
> +	rbp = rb_first(&ep->rbr);
> +	while ((num_items > 0) && rbp) {
> +		int n = min(num_items, nchunk);
> +		int j;
> +
> +		for (j = 0; rbp && j < n; j++, rbp = rb_next(rbp)) {
> +			struct epitem *epi;
> +			int objref;
> +
> +			epi = rb_entry(rbp, struct epitem, rbn);
> +			items[j].fd = epi->ffd.fd;
> +			items[j].events = epi->event.events;
> +			items[j].data = epi->event.data;
> +			objref = ckpt_obj_lookup(ctx, epi->ffd.file,
> +						 CKPT_OBJ_FILE);
> +			if (objref <= 0)
> +				goto unlock;
> +			items[j].file_objref = objref;
>  		}
> -		items[i].file_objref = objref;
> +		ret = ckpt_kwrite(ctx, items, n*sizeof(*items));
> +		if (ret < 0)
> +			break;
> +		num_items -= n;
>  	}
> +unlock:
>  	mutex_unlock(&ep->mtx);
> -	if (i == num_items && rbp)
> -		ret = -EBUSY; /* extra item(s) -- checkpoint obj leak */
> -	if (!ret)
> -		ret = ckpt_write_buffer(ctx, items, sizeof(*items)*num_items);
> -	else
> -		ckpt_write_err(ctx, "E", "checkpoint leak detected.\n", ret);
>  	kfree(items);
> +	if (num_items != 0 || (num_items == 0 && rbp))
> +		ret = -EBUSY; /* extra item(s) -- checkpoint obj leak */
> +	if (ret)
> +		ckpt_write_err(ctx, "E", " checkpointing epoll items.\n", ret);
>  	return ret;
>  }
> 
> -- 
> 1.5.6.3
> 
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
