From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 5/9] blkio-cgroup-v9: The body of blkio-cgroup
Date: Wed, 22 Jul 2009 11:11:20 +0900
Message-ID: <20090722111120.e4fe974f.kamezawa.hiroyu__30602.9055653655$1248228963$gmane$org@jp.fujitsu.com>
References: <20090721.231004.226793074.ryov@valinux.co.jp>
	<20090721.231211.71098738.ryov@valinux.co.jp>
	<20090721.231313.104044139.ryov@valinux.co.jp>
	<20090721.231405.189716609.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090721.231405.189716609.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 21 Jul 2009 23:14:05 +0900 (JST)
Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:

> The body of blkio-cgroup.
> + * blkio_cgroup_set_owner() - set the owner ID of a page.
> + * @page:	the page we want to tag
> + * @mm:		the mm_struct of a page owner
> + *
> + * Make a given page have the blkio-cgroup ID of the owner of this page.
> + */
> +void blkio_cgroup_set_owner(struct page *page, struct mm_struct *mm)


> + * blkio_cgroup_reset_owner() - reset the owner ID of a page
> + * @page:	the page we want to tag
> + * @mm:		the mm_struct of a page owner
> + *
> + * Change the owner of a given page if necessary.
> + */
> +void blkio_cgroup_reset_owner(struct page *page, struct mm_struct *mm)
> +{
> +	blkio_cgroup_set_owner(page, mm);
> +}


> +void blkio_cgroup_reset_owner_pagedirty(struct page *page, struct mm_struct *mm)
> +{
> +	if (!page_is_file_cache(page))
> +		return;
> +	if (current->flags & PF_MEMALLOC)
> +		return;
> +
> +	blkio_cgroup_reset_owner(page, mm);
> +}
> +

Hmm, why pass "mm" not "thread" ? Do we need to take care of mm->ownder ?
Why "current" is bad ?

Thanks,
-Kame
