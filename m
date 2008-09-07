From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v3][PATCH 4/9] Memory management (dump)
Date: Sat, 06 Sep 2008 21:54:05 -0400
Message-ID: <48C3343D.9000407@cs.columbia.edu>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>	
	<Pine.LNX.4.64.0809040403120.5982@takamine.ncl.cs.columbia.edu>
	<1220552725.23386.46.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1220552725.23386.46.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Thu, 2008-09-04 at 04:03 -0400, Oren Laadan wrote:
>> +/* free a chain of page-arrays */
>> +void cr_pgarr_free(struct cr_ctx *ctx)
>> +{
>> +       struct cr_pgarr *pgarr, *pgnxt;
>> +
>> +       for (pgarr = ctx->pgarr; pgarr; pgarr = pgnxt) {
>> +               _cr_pgarr_release(ctx, pgarr);
>> +               free_pages((unsigned long) ctx->pgarr->addrs, CR_PGARR_ORDER);
>> +               free_pages((unsigned long) ctx->pgarr->pages, CR_PGARR_ORDER);
>> +               pgnxt = pgarr->next;
>> +               kfree(pgarr);
>> +       }
>> +}
> 
> What we effectively have here is:
> 
> void *addrs[CR_PGARR_TOTAL];
> void *pages[CR_PGARR_TOTAL];
> 
> right?
> 
> Would any of this get simpler if we just had:
> 
> struct cr_page {
> 	struct page *page;
> 	unsigned long vaddr;
> };
> 
> struct cr_pgarr {
>        struct cr_page *cr_pages;
>        struct cr_pgarr *next;
>        unsigned short nleft;
>        unsigned short nused;
> };

The reason I use separate arrays instead of an array of tuples is that
the logic is to write all vaddr at once - simply by dumping the array
of vaddrs.

> 
> Also, we do have lots of linked list implementations in the kernel.
> They do lots of fun stuff like poisoning and checking for
> initialization.  We should use them instead of rolling our own.  It lets
> us do other fun stuff like list_for_each().
> 
> Also, just looking at this structure 'nleft' and 'nused' sound a bit
> redundant.  I know from looking at the code that this is how many have
> been filled and read back at restore time, but that is not very obvious
> looking at the structure.  I think we can do a bit better in the
> structure itself.
> 
> The length of the arrays is fixed at compile-time, right?  Should we
> just make that explicit as well?  

The length of the array may be tunable, or even adaptive (e.g. based
on statistics from recent checkpoints), in the future.

Oren.
