From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 7/9] blkio-cgroup-v9: Page tracking hooks
Date: Wed, 22 Jul 2009 18:40:55 +0900 (JST)
Message-ID: <20090722.184055.226788113.ryov__3494.17628390274$1248255694$gmane$org@valinux.co.jp>
References: <20090721.231505.112612378.ryov@valinux.co.jp>
	<20090721.232316.183036419.ryov@valinux.co.jp>
	<20090722111714.8af6c5d8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090722111714.8af6c5d8.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> On Tue, 21 Jul 2009 23:23:16 +0900 (JST)
> Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:
> 
> > This patch contains several hooks that let the blkio-cgroup framework to know
> > which blkio-cgroup is the owner of a page before starting I/O against the page.
> 
> > @@ -464,6 +465,7 @@ int add_to_page_cache_locked(struct page
> >  					gfp_mask & GFP_RECLAIM_MASK);
> >  	if (error)
> >  		goto out;
> > +	blkio_cgroup_set_owner(page, current->mm);
> >  
> 
> This part is doubtful...Is this necessary ? 
> I recommend you that the caller should attach owner by itself.

I think that it is reasonable to add the hook right here rather than
to add many hooks to a variety of places.
 
> >  	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> >  	if (error == 0) {
> > Index: linux-2.6.31-rc3/mm/memory.c
> > ===================================================================
> > --- linux-2.6.31-rc3.orig/mm/memory.c
> > +++ linux-2.6.31-rc3/mm/memory.c
> > @@ -51,6 +51,7 @@
> >  #include <linux/init.h>
> >  #include <linux/writeback.h>
> >  #include <linux/memcontrol.h>
> > +#include <linux/biotrack.h>
> >  #include <linux/mmu_notifier.h>
> >  #include <linux/kallsyms.h>
> >  #include <linux/swapops.h>
> > @@ -2115,6 +2116,7 @@ gotten:
> >  		 */
> >  		ptep_clear_flush_notify(vma, address, page_table);
> >  		page_add_new_anon_rmap(new_page, vma, address);
> > +		blkio_cgroup_set_owner(new_page, mm);
> 
> plz do this in swap-out code.
> 
> >  		set_pte_at(mm, address, page_table, entry);
> >  		update_mmu_cache(vma, address, entry);
> >  		if (old_page) {
> > @@ -2580,6 +2582,7 @@ static int do_swap_page(struct mm_struct
> >  	flush_icache_page(vma, page);
> >  	set_pte_at(mm, address, page_table, pte);
> >  	page_add_anon_rmap(page, vma, address);
> > +	blkio_cgroup_reset_owner(page, mm);
> 
> and this.
> 
> 
> >  	/* It's better to call commit-charge after rmap is established */
> >  	mem_cgroup_commit_charge_swapin(page, ptr);
> >  
> > @@ -2644,6 +2647,7 @@ static int do_anonymous_page(struct mm_s
> >  		goto release;
> >  	inc_mm_counter(mm, anon_rss);
> >  	page_add_new_anon_rmap(page, vma, address);
> > +	blkio_cgroup_set_owner(page, mm);
> >  	set_pte_at(mm, address, page_table, entry);
> >  
> and this.
> 
> >  	/* No need to invalidate - it was non-present before */
> > @@ -2791,6 +2795,7 @@ static int __do_fault(struct mm_struct *
> >  		if (anon) {
> >  			inc_mm_counter(mm, anon_rss);
> >  			page_add_new_anon_rmap(page, vma, address);
> > +			blkio_cgroup_set_owner(page, mm);
> and this.
> 
> IMHO, later io for swap-out is caused by the caller of swapout, not page's
> owner. plz charge to them or,
>   - add special BLOCK CGROUP ID for the kernel's swap out. 

I think that it is not too bad to charge the owner of a page for
swap-out. From another perspective, it can be considered that swap-out
is caused by a process which uses a large amount of memory.

Thanks,
Ryo Tsuruta

> 
> Bye,
> -Kame
> 
> >  		} else {
> >  			inc_mm_counter(mm, file_rss);
> >  			page_add_file_rmap(page);
> > Index: linux-2.6.31-rc3/mm/page-writeback.c
> > ===================================================================
> > --- linux-2.6.31-rc3.orig/mm/page-writeback.c
> > +++ linux-2.6.31-rc3/mm/page-writeback.c
> > @@ -23,6 +23,7 @@
> >  #include <linux/init.h>
> >  #include <linux/backing-dev.h>
> >  #include <linux/task_io_accounting_ops.h>
> > +#include <linux/biotrack.h>
> >  #include <linux/blkdev.h>
> >  #include <linux/mpage.h>
> >  #include <linux/rmap.h>
> > @@ -1247,6 +1248,7 @@ int __set_page_dirty_nobuffers(struct pa
> >  			BUG_ON(mapping2 != mapping);
> >  			WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
> >  			account_page_dirtied(page, mapping);
> > +			blkio_cgroup_reset_owner_pagedirty(page, current->mm);
> >  			radix_tree_tag_set(&mapping->page_tree,
> >  				page_index(page), PAGECACHE_TAG_DIRTY);
> >  		}
> > Index: linux-2.6.31-rc3/mm/swap_state.c
> > ===================================================================
> > --- linux-2.6.31-rc3.orig/mm/swap_state.c
> > +++ linux-2.6.31-rc3/mm/swap_state.c
> > @@ -18,6 +18,7 @@
> >  #include <linux/pagevec.h>
> >  #include <linux/migrate.h>
> >  #include <linux/page_cgroup.h>
> > +#include <linux/biotrack.h>
> >  
> >  #include <asm/pgtable.h>
> >  
> > @@ -307,6 +308,7 @@ struct page *read_swap_cache_async(swp_e
> >  		 */
> >  		__set_page_locked(new_page);
> >  		SetPageSwapBacked(new_page);
> > +		blkio_cgroup_set_owner(new_page, current->mm);
> >  		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
> >  		if (likely(!err)) {
> >  			/*
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> > 
