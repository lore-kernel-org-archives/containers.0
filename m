From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v4][PATCH 4/9] Memory management (dump)
Date: Wed, 10 Sep 2008 14:38:58 -0700
Message-ID: <1221082738.6781.59.camel__9500.27421718023$1221083229$gmane$org@nimitz>
References: <1220946154-15174-1-git-send-email-orenl@cs.columbia.edu>
	<1220946154-15174-5-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1220946154-15174-5-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2008-09-09 at 03:42 -0400, Oren Laadan wrote:
> array chain
> + */
> +static int cr_vma_scan_pages(struct cr_ctx *ctx, struct vm_area_struct *vma)
> +{
> +       unsigned long addr = vma->vm_start;
> +       unsigned long end = vma->vm_end;
> +       struct cr_pgarr *pgarr;
> +       int nr, total = 0;
> +
> +       while (addr < end) {
> +               pgarr = cr_pgarr_prep(ctx);
> +               if (!pgarr)
> +                       return -ENOMEM;
> +               nr = cr_vma_fill_pgarr(ctx, pgarr, vma, &addr);
> +               if (nr < 0)
> +                       return nr;
> +               pgarr->nr_free -= nr;
> +               pgarr->nr_used += nr;
> +               total += nr;
> +       }
> +
> +       cr_debug("total %d\n", total);
> +       return total;
> +}

This confuses me.  cr_vma_fill_pgarr() if it runs into an error attempts
to free up the pgarr references from the current pgarr that was just
filled.  But, that could only be a portion of a large VMA.  If it can't
free up the entire VMA worth of references (at least), why does it even
try to free a portion?  Why not just return since the upper levels need
to clean up the other portions anyway?

Also, is it really necessary to track the total amount filled in here?
I kinda gums up the code.

-- Dave
