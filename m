From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/3] epoll: Add support for checkpointing large numbers
	of epoll items
Date: Fri, 23 Oct 2009 19:51:59 -0400
Message-ID: <4AE2419F.7040506@librato.com>
References: <ce2e15faf44e254b80578c6c62e71d8685516896.1255971848.git.matthltc@us.ibm.com>
	<d0fd1f3eb4eaa326488f59955e5b4790080f3073.1255971848.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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



Matt Helsley wrote:
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

An allocation may or may not succeed for num_items; however, it if
does succeed, it may unnecessarily fragment the memory.

So I wonder if it's simpler to set the chunk size to 1-2 pages, like
in the pids code ?

The other advantage is that if we eventually optimize by allocating
a generic buffer for the c/r (e.g. ctx->buffer), we could easily
reuse it here.

[...]

Oren.
