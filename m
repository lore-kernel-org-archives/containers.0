From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH] flexible array implementation v4
Date: Fri, 24 Jul 2009 09:08:29 +0900
Message-ID: <20090724090829.14102188.kamezawa.hiroyu__31919.9639525779$1248394306$gmane$org@jp.fujitsu.com>
References: <20090723152647.D9391722@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090723152647.D9391722@kernel>
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
Cc: vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 23 Jul 2009 08:26:47 -0700
Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> 
> Remaining issues:
> - How should we deal with out-of-range indexes, especially
>   in flex_array_get() which returns void*?  ERR_PTR()?
>   BUG_ON()?  return NULL (current behavior)?
> - Should care be taken not to allow a flex_array_get() to
>   an index where no flex_array_put() was done?
> - Should we decay further than just packing things into the
>   'base' page?  Should we actually kmalloc() less than a
>   page at times when it will fit?
> 
> Changes from v3:
> - Now store ->total_nr_elements, and enforce stores,
>   accesses and preallocation limits below that.
> - Decay to an "elements_fit_in_base()" mode.  No second-
>   level pages are allocated and all elements are packed
>   into the flex_array->parts[] array that we used to use
>   only for second-level pointers.  Thanks hpa.
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
> --
> 
> Once a structure goes over PAGE_SIZE*2, we see occasional
> allocation failures.  Some people have chosen to switch
> over to things like vmalloc() that will let them keep
> array-like access to such a large structures.  But,
> vmalloc() has plenty of downsides.
> 
> Here's an alternative.  I think it's what Andrew was
> suggesting  here:
> 
> 	http://lkml.org/lkml/2009/7/2/518 
> 
> I call it a flexible array.  It does all of its work in
> PAGE_SIZE bits, so never does an order>0 allocation.
> The base level has PAGE_SIZE-2*sizeof(int) bytes of
> storage for pointers to the second level.  So, with a
> 32-bit arch, you get about 4MB (4183112 bytes) of total
> storage when the objects pack nicely into a page.  It
> is half that on 64-bit because the pointers are twice
> the size.  There's a table detailing this in the code.
> 
> There are kerneldocs for the functions, but here's an
> overview:
> 
> flex_array_alloc() - dynamically allocate a base structure
> flex_array_free() - free the array and all of the
> 		    second-level pages
> flex_array_free_parts() - free the second-level pages, but
> 			  not the base (for static bases)
> flex_array_put() - copy into the array at the given index
> flex_array_get() - copy out of the array at the given index
> flex_array_prealloc() - preallocate the second-level pages
> 			between the given indexes to
> 			guarantee no allocs will occur at
> 			put() time.
> 
> We could also potentially just pass the "element_size"
> into each of the API functions instead of storing it
> internally.  That would get us one more base pointer
> on 32-bit.
> 
> I've been testing this by running it in userspace.  The
> header and patch that I've been using are here, as well
> as the little script I'm using to generate the size table
> which goes in the kerneldocs.
> 
> 	http://sr71.net/~dave/linux/flexarray/
> 
> Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

Thanks.
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>


> ---
> 
>  linux-2.6.git-dave/include/linux/flex_array.h |   46 ++++
>  linux-2.6.git-dave/lib/Makefile               |    2 
>  linux-2.6.git-dave/lib/flex_array.c           |  269 ++++++++++++++++++++++++++
>  linux-2.6.git-dave/lib/go.sh                  |   17 +
>  4 files changed, 327 insertions(+), 7 deletions(-)
> 
> diff -puN /dev/null include/linux/flex_array.h
> --- /dev/null	2008-09-02 09:40:19.000000000 -0700
> +++ linux-2.6.git-dave/include/linux/flex_array.h	2009-07-23 08:21:07.000000000 -0700
> @@ -0,0 +1,46 @@
> +#ifndef _FLEX_ARRAY_H
> +#define _FLEX_ARRAY_H
> +
> +#include <linux/types.h>
> +#include <asm/page.h>
> +
> +#define FLEX_ARRAY_PART_SIZE PAGE_SIZE
> +#define FLEX_ARRAY_BASE_SIZE PAGE_SIZE
> +
> +struct flex_array_part;
> +
> +/*
> + * This is meant to replace cases where an array-like
> + * structure has gotten too big to fit into kmalloc()
> + * and the developer is getting tempted to use
> + * vmalloc().
> + */
> +
> +struct flex_array {
> +	union {
> +		struct {
> +			int element_size;
> +			int total_nr_elements;
> +			struct flex_array_part *parts[0];
> +		};
> +		/*
> +		 * This little trick makes sure that
> +		 * sizeof(flex_array) == PAGE_SIZE
> +		 */
> +		char padding[FLEX_ARRAY_BASE_SIZE];
> +	};
> +};
> +
> +#define FLEX_ARRAY_INIT(size, total) { { {\
> +	.element_size = (size),		\
> +	.total_nr_elements = (total),	\
> +} } }
> +
> +struct flex_array *flex_array_alloc(int element_size, int total, gfp_t flags);
> +int flex_array_prealloc(struct flex_array *fa, int start, int end, gfp_t flags);
> +void flex_array_free(struct flex_array *fa);
> +void flex_array_free_parts(struct flex_array *fa);
> +int flex_array_put(struct flex_array *fa, int element_nr, void *src, gfp_t flags);
> +void *flex_array_get(struct flex_array *fa, int element_nr);
> +
> +#endif /* _FLEX_ARRAY_H */
> diff -puN /dev/null lib/flex_array.c
> --- /dev/null	2008-09-02 09:40:19.000000000 -0700
> +++ linux-2.6.git-dave/lib/flex_array.c	2009-07-23 08:21:07.000000000 -0700
> @@ -0,0 +1,269 @@
> +/*
> + * Flexible array managed in PAGE_SIZE parts
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
> + *
> + * Copyright IBM Corporation, 2009
> + *
> + * Author: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> + */
> +
> +#include <linux/flex_array.h>
> +#include <linux/slab.h>
> +#include <linux/stddef.h>
> +
> +struct flex_array_part {
> +	char elements[FLEX_ARRAY_PART_SIZE];
> +};
> +
> +static inline int __elements_per_part(int element_size)
> +{
> +	return FLEX_ARRAY_PART_SIZE / element_size;
> +}
> +
> +static inline int bytes_left_in_base(void)
> +{
> +	int element_offset = offsetof(struct flex_array, parts);
> +	int bytes_left = FLEX_ARRAY_BASE_SIZE - element_offset;
> +	return bytes_left;
> +}
> +
> +static inline int nr_base_part_ptrs(void)
> +{
> +	return bytes_left_in_base() / sizeof(struct flex_array_part *);
> +}
> +
> +/*
> + * If a user requests an allocation which is small
> + * enough, we may simply use the space in the
> + * flex_array->parts[] array to store the user
> + * data.
> + */
> +static inline int elements_fit_in_base(struct flex_array *fa)
> +{
> +	int data_size = fa->element_size * fa->total_nr_elements;
> +	if (data_size <= bytes_left_in_base())
> +		return 1;
> +	return 0;
> +}
> +
> +/**
> + * flex_array_alloc - allocate a new flexible array
> + * @element_size:	the size of individual elements in the array
> + * @total:		total number of elements that this should hold
> + *
> + * Note: all locking must be provided by the caller.
> + *
> + * @total is used to size internal structures.  If the user ever
> + * accesses any array indexes >=@total, it will produce errors.
> + *
> + * The maximum number of elements is defined as: the number of
> + * elements that can be stored in a page times the number of
> + * page pointers that we can fit in the base structure or (using
> + * integer math):
> + *
> + * 	(PAGE_SIZE/element_size) * (PAGE_SIZE-8)/sizeof(void *)
> + *
> + * Here's a table showing example capacities.  Note that the maximum
> + * index that the get/put() functions is just nr_objects-1.   This
> + * basically means that you get 4MB of storage on 32-bit and 2MB on
> + * 64-bit.
> + *
> + *
> + * Element size | Objects | Objects |
> + * PAGE_SIZE=4k |  32-bit |  64-bit |
> + * ---------------------------------|
> + *      1 bytes | 4186112 | 2093056 |
> + *      2 bytes | 2093056 | 1046528 |
> + *      3 bytes | 1395030 |  697515 |
> + *      4 bytes | 1046528 |  523264 |
> + *     32 bytes |  130816 |   65408 |
> + *     33 bytes |  126728 |   63364 |
> + *   2048 bytes |    2044 |    1022 |
> + *   2049 bytes |    1022 |     511 |
> + *       void * | 1046528 |  261632 |
> + *
> + * Since 64-bit pointers are twice the size, we lose half the
> + * capacity in the base structure.  Also note that no effort is made
> + * to efficiently pack objects across page boundaries.
> + */
> +struct flex_array *flex_array_alloc(int element_size, int total, gfp_t flags)
> +{
> +	struct flex_array *ret;
> +	int max_size = nr_base_part_ptrs() * __elements_per_part(element_size);
> +
> +	/* max_size will end up 0 if element_size > PAGE_SIZE */
> +	if (total > max_size)
> +		return NULL;
> +	ret = kzalloc(sizeof(struct flex_array), flags);
> +	if (!ret)
> +		return NULL;
> +	ret->element_size = element_size;
> +	ret->total_nr_elements = total;
> +	return ret;
> +}
> +
> +static int fa_element_to_part_nr(struct flex_array *fa, int element_nr)
> +{
> +	return element_nr / __elements_per_part(fa->element_size);
> +}
> +
> +/**
> + * flex_array_free_parts - just free the second-level pages
> + * @src:	address of data to copy into the array
> + * @element_nr:	index of the position in which to insert
> + * 		the new element.
> + *
> + * This is to be used in cases where the base 'struct flex_array'
> + * has been statically allocated and should not be free.
> + */
> +void flex_array_free_parts(struct flex_array *fa)
> +{
> +	int part_nr;
> +	int max_part = nr_base_part_ptrs();
> +
> +	if (elements_fit_in_base(fa))
> +		return;
> +	for (part_nr = 0; part_nr < max_part; part_nr++)
> +		kfree(fa->parts[part_nr]);
> +}
> +
> +void flex_array_free(struct flex_array *fa)
> +{
> +	flex_array_free_parts(fa);
> +	kfree(fa);
> +}
> +
> +static int fa_index_inside_part(struct flex_array *fa, int element_nr)
> +{
> +	return (element_nr % __elements_per_part(fa->element_size));
> +}
> +
> +static int index_inside_part(struct flex_array *fa, int element_nr)
> +{
> +	int part_offset = fa_index_inside_part(fa, element_nr);
> +	return part_offset * fa->element_size;
> +}
> +
> +static struct flex_array_part *
> +__fa_get_part(struct flex_array *fa, int part_nr, gfp_t flags)
> +{
> +	struct flex_array_part *part = fa->parts[part_nr];
> +	if (!part) {
> +		/*
> +		 * This leaves the part pages uninitialized
> +		 * and with potentially random data, just
> +		 * as if the user had kmalloc()'d the whole.
> +		 * __GFP_ZERO can be used to zero it.
> +		 */
> +		part = kmalloc(FLEX_ARRAY_PART_SIZE, flags);
> +		if (!part)
> +			return NULL;
> +		fa->parts[part_nr] = part;
> +	}
> +	return part;
> +}
> +
> +/**
> + * flex_array_put - copy data into the array at @element_nr
> + * @src:	address of data to copy into the array
> + * @element_nr:	index of the position in which to insert
> + * 		the new element.
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
> +	if (element_nr >= fa->total_nr_elements)
> +		return -ENOSPC;
> +	if (elements_fit_in_base(fa))
> +		part = (struct flex_array_part *)&fa->parts[0];
> +	else
> +		part = __fa_get_part(fa, part_nr, flags);
> +	if (!part)
> +		return -ENOMEM;
> +	dst = &part->elements[index_inside_part(fa, element_nr)];
> +	memcpy(dst, src, fa->element_size);
> +	return 0;
> +}
> +
> +/**
> + * flex_array_prealloc - guarantee that array space exists
> + * @start:	index of first array element for which space is allocated
> + * @end:	index of last (inclusive) element for which space is allocated
> + *
> + * This will guarantee that no future calls to flex_array_put()
> + * will allocate memory.  It can be used if you are expecting to
> + * be holding a lock or in some atomic context while writing
> + * data into the array.
> + *
> + * Locking must be provided by the caller.
> + */
> +int flex_array_prealloc(struct flex_array *fa, int start, int end, gfp_t flags)
> +{
> +	int start_part;
> +	int end_part;
> +	int part_nr;
> +	struct flex_array_part *part;
> +
> +	if (start >= fa->total_nr_elements || end >= fa->total_nr_elements)
> +		return -ENOSPC;
> +	if (elements_fit_in_base(fa))
> +		return 0;
> +	start_part = fa_element_to_part_nr(fa, start);
> +      	end_part = fa_element_to_part_nr(fa, end);
> +	for (part_nr = start_part; part_nr <= end_part; part_nr++) {
> +		part = __fa_get_part(fa, part_nr, flags);
> +		if (!part)
> +			return -ENOMEM;
> +	}
> +	return 0;
> +}
> +
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
> +	int index;
> +
> +	if (element_nr >= fa->total_nr_elements)
> +		return NULL;
> +	if (!fa->parts[part_nr])
> +		return NULL;
> +	if (elements_fit_in_base(fa))
> +		part = (struct flex_array_part *)&fa->parts[0];
> +	else
> +		part = fa->parts[part_nr];
> +	index = index_inside_part(fa, element_nr);
> +	return &part->elements[index_inside_part(fa, element_nr)];
> +}
> diff -puN lib/Makefile~fa lib/Makefile
> --- linux-2.6.git/lib/Makefile~fa	2009-07-23 07:48:13.000000000 -0700
> +++ linux-2.6.git-dave/lib/Makefile	2009-07-23 07:48:13.000000000 -0700
> @@ -12,7 +12,7 @@ lib-y := ctype.o string.o vsprintf.o cmd
>  	 idr.o int_sqrt.o extable.o prio_tree.o \
>  	 sha1.o irq_regs.o reciprocal_div.o argv_split.o \
>  	 proportions.o prio_heap.o ratelimit.o show_mem.o \
> -	 is_single_threaded.o plist.o decompress.o
> +	 is_single_threaded.o plist.o decompress.o flex_array.o
>  
>  lib-$(CONFIG_MMU) += ioremap.o
>  lib-$(CONFIG_SMP) += cpumask.o
> diff -puN lib/go.sh~fa lib/go.sh
> --- linux-2.6.git/lib/go.sh~fa	2009-07-23 08:07:33.000000000 -0700
> +++ linux-2.6.git-dave/lib/go.sh	2009-07-23 08:21:07.000000000 -0700
> @@ -1,14 +1,19 @@
>  #!/bin/sh
>  set -e
>  for bits in 32 64; do
> -	gcc-3.4 -m$bits -I ../include -o flex_array.$bits flex_array.c ;
> +	gcc-3.4 -m$bits -I include -o flex_array.$bits lib/flex_array.c ;
>  done
>  
> +func fa
> +{
> +	./flex_array.$1 | grep ^max | awk '{print $4}'
> +}
> +
>  for i in 1 2 3 4 32 33 2048 2049; do
> -	m32="$(./flex_array.32 $i 100)"
> -	m64="$(./flex_array.64 $i 100)"
> +	m32="$(fa 32 $i 100)"
> +	m64="$(fa 64 $i 100)"
>  	printf " * %6d bytes | %7d | %7d |\n" $i $m32 $m64;
>  done
> -m32="$(./flex_array.32 4 100)"
> -m64="$(./flex_array.64 8 100)"
> -printf " *    void * | %7d | %7d |\n" $i $m32 $m64;
> +m32="$(fa 32 4 100)"
> +m64="$(fa 64 8 100)"
> +printf " *    void * | %7d | %7d |\n" $m32 $m64;
> _
> 
