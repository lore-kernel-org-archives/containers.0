From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH 2/4] Switch caches notification dynamically
Date: Mon, 17 Sep 2007 11:32:42 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0709171130470.27057@schroedinger.engr.sgi.com>
References: <46EE70B4.6060902@openvz.org> <46EE7375.3040902@openvz.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46EE7375.3040902-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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

On Mon, 17 Sep 2007, Pavel Emelyanov wrote:

>  struct kmem_cache kmalloc_caches[PAGE_SHIFT] __cacheline_aligned;
>  EXPORT_SYMBOL(kmalloc_caches);
>  
> +static inline int is_kmalloc_cache(struct kmem_cache *s)
> +{
> +	int km_idx;
> +
> +	km_idx = s - kmalloc_caches;
> +	return km_idx >= 0 && km_idx < ARRAY_SIZE(kmalloc_caches);
> +}


Could be as simple at

	return s > kmalloc_caches && s < kmalloc_caches + 
ARRAY_SIZE(kmalloc_caches);


> +	if (buf[0] == '0') {
> +		if (any_slab_objects(s))
> +			/*
> +			 * we cannot turn this off because of the
> +			 * full slabs cannot be found in this case
> +			 */
> +			return -EBUSY;

The full slabs can be checked by subtracting the partial slabs from the 
allocated slabs in the per node structure.
