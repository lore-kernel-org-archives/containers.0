From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [RFC][PATCH] flexible array implementation
Date: Tue, 21 Jul 2009 15:33:56 -0700
Message-ID: <20090721153356.f62d8424.akpm__15814.9649425924$1248215703$gmane$org@linux-foundation.org>
References: <20090721160333.96AA4D3D@kernel>
	<20090721131839.27f3a5aa.akpm@linux-foundation.org>
	<1248213411.13249.5669.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248213411.13249.5669.camel@nimitz>
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
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 21 Jul 2009 14:56:51 -0700
Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> I've added some comments in the kerneldoc for the (newly renamed) alloc
> function:
> 
>  * The maximum number of elements is currently the number of elements
>  * that can be stored in a page times the number of page pointers
>  * that we can fit in the base structure or (using integer math):
>  *
>  *      (PAGE_SIZE/element_size) * (PAGE_SIZE-8)/sizeof(void *)
>  *
>  * Here's a table showing example capacities.  Note that the maximum
>  * index that the get/put() functions is just nr_objects-1.
>  *
>  * Element size | Objects  | Objects |
>  * PAGE_SIZE=4k |  32-bit  |  64-bit |
>  * ----------------------------------|
>  *      1 byte  |  4186112 | 2093056 |
>  *      2 bytes |  2093056 | 1046528 |
>  *      3 bytes |  1395030 |  697515 |
>  *      4 bytes |  1046528 |  523264 |
>  *     32 bytes |   130816 |   65408 |
>  *     33 bytes |   126728 |   63364 |
>  *   2048 bytes |     2044 |   10228 |
>  *   2049 bytes |     1022 |     511 |
>  *       void * |  1046528 |  261632 |

4-bytes on 32-bit and 8-bytes on 64-bit are the most interesting ones
(IMO).  So what we're basically saying is "2MB on 64-bit".

I wonder if that's enough for known likely callers.  Hopefully it is.
