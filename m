From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFCv2][PATCH] flexible array implementation
Date: Wed, 22 Jul 2009 11:25:03 +0800
Message-ID: <4A66868F.4010001__11297.7288583808$1248233323$gmane$org@cn.fujitsu.com>
References: <20090721220017.60A219D3@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090721220017.60A219D3@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

> +/**
> + * flex_array_put - copy data into the array at @element_nr
> + * @src:	address of data to copy into the array
> + * @element_nr:	index of the position in which to insert
> + * 		the new element.

@fa and @flags are not documented.

> + *
> + * Note that this *copies* the contents of @src into
> + * the array.  If you are trying to store an array of
> + * pointers, make sure to pass in &ptr instead of ptr.
> + *
> + * Locking must be provided by the caller.
> + */
> +int flex_array_put(struct flex_array *fa, int element_nr, void *src, gfp_t flags)
> +{
> +	int part_nr = fa_element_to_part_nr(fa, element_nr);
> +	struct flex_array_part *part;
> +	void *dst;
> +
> +	part = __fa_get_part(fa, part_nr, flags);
> +	if (!part)
> +		return -ENOMEM;

So this may allocate memory, and has disavantages:

- If flex_array_put() is called in atomic context, flags has to be GFP_ATOMIC.
- and thus it may fail.

Since we pass the total_elem to flex_array_alloc(), how about add a flag,
and if the flag is set, the alloc() will also allocate all fa_parts?

And add __flex_array_put(), which assumes fa_parts has been allocated.

> +	dst = &part->elements[offset_inside_part(fa, element_nr)];
> +	memcpy(dst, src, fa->element_size);
> +	return 0;
> +}
> +
