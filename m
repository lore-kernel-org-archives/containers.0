From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [RFC][PATCH] flexible array implementation
Date: Tue, 21 Jul 2009 13:18:39 -0700
Message-ID: <20090721131839.27f3a5aa.akpm__23259.3369241387$1248207639$gmane$org@linux-foundation.org>
References: <20090721160333.96AA4D3D@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090721160333.96AA4D3D@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 21 Jul 2009 09:03:33 -0700
Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> 
> Once a structure goes over PAGE_SIZE*2, we see occasional
> allocation failures.  Some people have chosen to switch
> over to things like vmalloc() that will let them keep
> array-like access to such a large structures.  But,
> vmalloc() has plenty of downsides.

Thanks for looking into this.

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

flex_array_alloc() and flex_array_free(), please.

> 	flex_array_put()
> 	flex_array_get()

It's important to document the arguments too!  The lack of an `index'
arg to flex_array_put() was important info.

> put() appends an item into the array while get() takes
> indexes and does array-style access.

The interface is rather unexpected.  Some callers will want
random-access writes and will have sparse data sets.  Can we make it
more array-like?

What are the constraints of this implementation?  Maximum index, maximum
number of elements, etc?

What are the locking rules?  Caller-provided, obviously (and
correctly).  If the caller wants to use a spinlock the caller must use
GFP_ATOMIC and handle the fallout when that fails.  (But they'd need to
handle the fallout with mutex/GFP_KERNEL too).

> One thought is that we should perhaps make the base
> structure half the size on 32-bit arches.  That will
> ensure that someone testing on 32-bit will not get
> bitten by the size shrinking by half when moving to
> 64-bit.

{scratches head}

If you say so ;)

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

I expect the majority of callers will be storing plain old pointers in here.

In fact the facility would be quite useful if it explicitly stored and
returned void*'s, like radix-tree and IDR.

Do we know of any potential callers which would want flex_array to
store elements by value in this manner?

> ...
>
> +struct flex_array *alloc_flex_array(int element_size, int total, gfp_t flags)
> +{
> +	struct flex_array *ret;
> +	int max_size = __nr_part_ptrs() * __elements_per_part(element_size);
> +
> +	/* max_size will end up 0 if element_size > PAGE_SIZE */
> +	if (total > max_size)
> +		return NULL;
> +	ret = kzalloc(sizeof(struct flex_array), flags);
> +	if (!ret)
> +		return NULL;
> +	ret->element_size = element_size;
> +	return ret;
> +}

I expect that a decent proportion of users of this facility will only
ever want a single flex_array.  So they'll want to be able to define and
initialise their flex_array at compile-time.

That looks pretty easy to do?
