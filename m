From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH] flexible array implementation v3
Date: Thu, 23 Jul 2009 10:44:50 +0900
Message-ID: <20090723104450.e0d421ca.kamezawa.hiroyu__25015.3168257841$1248313637$gmane$org@jp.fujitsu.com>
References: <20090722175345.7154C2F2@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090722175345.7154C2F2@kernel>
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
Cc: vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 22 Jul 2009 10:53:45 -0700
Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> 
> 
> Changes from v2:
> - renamed some of the index functions
> - added preallocation function
> - added flex_array_free_parts() for use with
>   statically allocated bases
> - killed append() function
> 
> Changes from v1:
> - to vs too typo
> - added __check_part_and_nr() and gave it a warning
> - fixed off-by-one check on __nr_part_ptrs()
> - added FLEX_ARRAY_INIT() macro
> - some kerneldoc comments about the capacity
>   with various sized objects
> - comments to note lack of locking semantice
> 

Seems nice, thank you. but a nitpick..

+struct flex_array *flex_array_alloc(int element_size, int total, gfp_t flags)
+{
+	struct flex_array *ret;
+	int max_size = nr_base_part_ptrs() * __elements_per_part(element_size);
+
+	/* max_size will end up 0 if element_size > PAGE_SIZE */
+	if (total > max_size)
+		return NULL;

Can't we store "total" somewhere and do error check ?

And some magic value as following can't be defined for 'total' ?

#define FLEX_ARRAY_MAX_ELEMENTS		(-1) // Use maximum flex array.


> +/**
> + * flex_array_get - pull data back out of the array
> + * @element_nr:	index of the element to fetch from the array
> + *
> + * Returns a pointer to the data at index @element_nr.  Note
> + * that this is a copy of the data that was passed in.  If you
> + * are using this to store pointers, you'll get back &ptr.
> + *
> + * Locking must be provided by the caller.
> + */
> +void *flex_array_get(struct flex_array *fa, int element_nr)
> +{
> +	int part_nr = fa_element_to_part_nr(fa, element_nr);
> +	struct flex_array_part *part;
> +	int offset;
> +
> +	if (__check_part_nr(fa, part_nr))
> +		return NULL;
return -EINVAL, here ?
(Can't we compared with stored "total" ?)

> +	if (!fa->parts[part_nr])
> +		return NULL;
> +

The caller can't know whether
 - there are no entry or
 - NULL(0) is stored at the array.

Then, he has to check gotten value is valid or not by himself.

Can't we return -ENOENT here(especially when prealloc() is called) ?
But ah, anyway, all-zero elements in allocated array exists ;(
and the user can get value from an entry never be put.

If we can fill the first 4bytes of _unused_ index by some magic code like this
#define FLEX_ARRAY_UNUSED_MAGIC		(0xa5a5a5a5)
(if maintaining bitmap/status of usage is nonsense)
and flex_array_get() can return -ENOENT, the users will feel easy.

Overprotection ;) ?


Thanks,
-Kame

> +	part = fa->parts[part_nr];
> +	offset = index_inside_part(fa, element_nr);
> +	return &part->elements[index_inside_part(fa, element_nr)];
> +}
