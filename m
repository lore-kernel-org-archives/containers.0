From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v3][PATCH 4/9] Memory management (dump)
Date: Thu, 04 Sep 2008 11:25:25 -0700
Message-ID: <1220552725.23386.46.camel__29724.1033790216$1220553016$gmane$org@nimitz>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0809040403120.5982@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0809040403120.5982-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2008-09-04 at 04:03 -0400, Oren Laadan wrote:
> +/* free a chain of page-arrays */
> +void cr_pgarr_free(struct cr_ctx *ctx)
> +{
> +       struct cr_pgarr *pgarr, *pgnxt;
> +
> +       for (pgarr = ctx->pgarr; pgarr; pgarr = pgnxt) {
> +               _cr_pgarr_release(ctx, pgarr);
> +               free_pages((unsigned long) ctx->pgarr->addrs, CR_PGARR_ORDER);
> +               free_pages((unsigned long) ctx->pgarr->pages, CR_PGARR_ORDER);
> +               pgnxt = pgarr->next;
> +               kfree(pgarr);
> +       }
> +}

What we effectively have here is:

void *addrs[CR_PGARR_TOTAL];
void *pages[CR_PGARR_TOTAL];

right?

Would any of this get simpler if we just had:

struct cr_page {
	struct page *page;
	unsigned long vaddr;
};

struct cr_pgarr {
       struct cr_page *cr_pages;
       struct cr_pgarr *next;
       unsigned short nleft;
       unsigned short nused;
};

Also, we do have lots of linked list implementations in the kernel.
They do lots of fun stuff like poisoning and checking for
initialization.  We should use them instead of rolling our own.  It lets
us do other fun stuff like list_for_each().

Also, just looking at this structure 'nleft' and 'nused' sound a bit
redundant.  I know from looking at the code that this is how many have
been filled and read back at restore time, but that is not very obvious
looking at the structure.  I think we can do a bit better in the
structure itself.

The length of the arrays is fixed at compile-time, right?  Should we
just make that explicit as well?  

-- Dave
