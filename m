From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v4][PATCH 4/9] Memory management (dump)
Date: Wed, 10 Sep 2008 09:55:28 -0700
Message-ID: <1221065728.6781.19.camel__27321.7449932874$1221066035$gmane$org@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2008-09-09 at 03:42 -0400, Oren Laadan wrote:
> +       while (addr < end) {
> +               struct page *page;
> +
> +               /*
> +                * simplified version of get_user_pages(): already have vma,
> +                * only need FOLL_TOUCH, and (for now) ignore fault stats.
> +                *
> +                * FIXME: consolidate with get_user_pages()
> +                */
> +
> +               cond_resched();
> +               while (!(page = follow_page(vma, addr, FOLL_TOUCH))) {
> +                       ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
> +                       if (ret & VM_FAULT_ERROR) {
> +                               if (ret & VM_FAULT_OOM)
> +                                       ret = -ENOMEM;
> +                               else if (ret & VM_FAULT_SIGBUS)
> +                                       ret = -EFAULT;
> +                               else
> +                                       BUG();
> +                               break;
> +                       }
> +                       cond_resched();
> +                       ret = 0;
> +               }

get_user_pages() is really the wrong thing to use here.  It makes pages
*present* so that we can do things like hand them off to a driver.  For
checkpointing, we really don't care about that.  It's a waste of time,
for instance to perform faults to fill the mappings up with zero pages
and page tables.  Just think of what will happen the first time we touch
a very large, very sparse anonymous area.  We'll probably kill the
system just allocating page tables.  Take a look at the comment in
follow_page().  This is a similar operation to core dumping, and we need
to be careful.

This might be fine for a proof of concept, but it needs to be thought
out much more thoroughly before getting merged.  I guess I'm
volunteering to go do that.

-- Dave
