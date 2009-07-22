From: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFCv2][PATCH] flexible array implementation
Date: Wed, 22 Jul 2009 15:55:56 -0400
Message-ID: <4A676ECC.1090400@google.com>
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

Dave Hansen wrote:
> Changes from v1:
> - to vs too typo
> - added __check_part_and_nr() and gave it a warning
> - fixed off-by-one check on __nr_part_ptrs()
> - addedFLEX_ARRAY_INIT() macro
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
> the size.
> 
> The interface is dirt simple.  4 functions:
> 	alloc_flex_array()
> 	free_flex_array()
> 	flex_array_put()
> 	flex_array_get()
> 
> put() appends an item into the array while get() takes
> indexes and does array-style access.
> 
> One thought is that we should perhaps make the base
> structure half the size on 32-bit arches.  That will
> ensure that someone testing on 32-bit will not get
> bitten by the size shrinking by half when moving to
> 64-bit.
> 
> We could also potentially just pass the "element_size"
> into each of the API functions instead of storing it
> internally.  That would get us one more base pointer
> on 32-bit.
> 
> The last improvement that I thought about was letting
> the individual array members span pages.  In this
> implementation, if you have a 2049-byte object, it
> will only pack one of them into each "part" with
> no attempt to pack them.  At this point, I don't think
> the added complexity would be worth it.
> 
> Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
> 
>  linux-2.6.git-dave/include/linux/flex_array.h |   45 +++++
>  linux-2.6.git-dave/lib/Makefile               |    2 
>  linux-2.6.git-dave/lib/flex_array.c           |  230 ++++++++++++++++++++++++++
>  3 files changed, 276 insertions(+), 1 deletion(-)
> 
> diff -puN /dev/null include/linux/flex_array.h
> --- /dev/null	2008-09-02 09:40:19.000000000 -0700
> +++ linux-2.6.git-dave/include/linux/flex_array.h	2009-07-21 14:55:35.000000000 -0700
> @@ -0,0 +1,45 @@
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
> + * This is meant too replace cases where an array-like
> + * structure has gotten to big to fit into kmalloc()
> + * and the developer is getting tempted to use
> + * vmalloc().
> + */
> +
> +struct flex_array {
> +	union {
> +		struct {
> +			int nr_elements;
> +			int element_size;
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
> +#define FLEX_ARRAY_INIT(size, total) {{{\
> +	.element_size = (size),		\
> +	.nr_elements = 0,		\
> +}}}
> +

It's not clear how this guy is used.  It will initialize a flex_array, 
but how is somebody expected to free the parts that get associated with it?

Is there a fancy way to make declaring a flex_array on stack a 
compile-time error?
