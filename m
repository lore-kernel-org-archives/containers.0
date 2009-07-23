From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH] flexible array implementation v3
Date: Thu, 23 Jul 2009 11:44:28 -0400
Message-ID: <4A68855C.1060702@cs.columbia.edu>
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
Cc: vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
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

Probably premature, but -- I wonder if it's worth adding interfaces to:

* copy a range of elements at once (perhaps to/from regular array ?
or userspace ? -- depending on potential users)

* (macro ?) iterate through elements (better have it ready for users
of flex_array before, than convert their code later on)

Oren.
