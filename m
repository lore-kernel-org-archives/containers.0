From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH 1/4] Add notification about some major slab events
Date: Mon, 24 Sep 2007 14:05:07 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0709241402360.30982@schroedinger.engr.sgi.com>
References: <46F38B67.3020609@openvz.org> <46F38C1D.2080902@openvz.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46F38C1D.2080902-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 21 Sep 2007, Pavel Emelyanov wrote:

> @@ -1486,7 +1597,7 @@ load_freelist:
>  	object = c->page->freelist;
>  	if (unlikely(!object))
>  		goto another_slab;
> -	if (unlikely(SlabDebug(c->page)))
> +	if (unlikely(SlabDebug(c->page)) || (s->flags & SLAB_NOTIFY))
>  		goto debug;

There is no need to check s->flags & SLAB_NOTIFY here. Just make sure that 
SlabDebug() is always set on allocated slabs. Set SlabDebug when a slab 
page is allocated is sufficient.
  
>  debug:
>  	object = c->page->freelist;
> -	if (!alloc_debug_processing(s, c->page, object, addr))
> +	if (SlabDebug(c->page) &&
> +			!alloc_debug_processing(s, c->page, object, addr))
>  		goto another_slab;
>  

SlabDebug will always be set and does not need to be tested.

> +	if ((s->flags & SLAB_NOTIFY) &&
> +			slub_alloc_notify(s, object, gfpflags) < 0) {
> +		object = NULL;
> +		goto out;
> +	}

Looks like the above piece is the only addition we need in __slab_alloc().

> @@ -1620,7 +1739,7 @@ static void __slab_free(struct kmem_cach
>  
>  	slab_lock(page);
>  
> -	if (unlikely(SlabDebug(page)))
> +	if (unlikely(SlabDebug(page)) || (s->flags & SLAB_NOTIFY))
>  		goto debug;

Not needed either.

>  checks_ok:
>  	prior = object[offset] = page->freelist;
> @@ -1657,8 +1776,12 @@ slab_empty:
>  	return;
>  
>  debug:
> -	if (!free_debug_processing(s, page, x, addr))
> +	if (SlabDebug(page) && !free_debug_processing(s, page, x, addr))
>  		goto out_unlock;

Ditto.

> +
> +	if (s->flags & SLAB_NOTIFY)
> +		slub_free_notify(s, x);
> +

Yup we need this for __slab_free.
