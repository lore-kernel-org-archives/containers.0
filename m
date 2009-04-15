From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/9] bio-cgroup controller
Date: Wed, 15 Apr 2009 11:37:17 +0200
Message-ID: <20090415093716.GA5968__21842.1946665787$1239788502$gmane$org@linux>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-4-git-send-email-righi.andrea@gmail.com>
	<20090415111528.b796519a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090415111528.b796519a.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Apr 15, 2009 at 11:15:28AM +0900, KAMEZAWA Hiroyuki wrote:
> >  /*
> >   * Page Cgroup can be considered as an extended mem_map.
> > @@ -12,9 +12,16 @@
> >   */
> >  struct page_cgroup {
> >  	unsigned long flags;
> > -	struct mem_cgroup *mem_cgroup;
> >  	struct page *page;
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > +	struct mem_cgroup *mem_cgroup;
> > +#endif
> > +#ifdef CONFIG_CGROUP_BIO
> > +	int bio_cgroup_id;
> > +#endif
> > +#if defined(CONFIG_CGROUP_MEM_RES_CTLR) || defined(CONFIG_CGROUP_BIO)
> >  	struct list_head lru;		/* per cgroup LRU list */
> > +#endif
> >  };
> > 
> This #if is unnecessary..

OK.

> 
> And, now, CSS_ID is supported. I think it can be used and your own id is not
> necessary. (plz see swap accounting in memcontrol.c/page_cgroup.c if unsure.)

Agree. We can use css_id(&bio_cgroup->css), instead of introducing a new
custom id in the bio_cgroup structure.

> 
> And... I don't like to increase the size of struct page_cgroup.
> Could you find a way to encode bio_cgroup_id into "flags" ?
> unsigned long is too much now.

And also agree here. Maybe the lower 16 bits are enough for flags, now
only 3 bits are used and we can reserve the rest (upper 16 bits in
32-bit archs and 48 bits in 64-bit archs) for the bio_cgroup id. Or do
you think it's too much for any amount of reasonable cgroups we could
have in a system?

> > +/*
> > + * This function is used to make a given page have the bio-cgroup id of
> > + * the owner of this page.
> > + */
> > +void bio_cgroup_set_owner(struct page *page, struct mm_struct *mm)
> > +{
> > +	struct bio_cgroup *biog;
> > +	struct page_cgroup *pc;
> > +
> > +	if (bio_cgroup_disabled())
> > +		return;
> > +	pc = lookup_page_cgroup(page);
> > +	if (unlikely(!pc))
> > +		return;
> > +
> > +	pc->bio_cgroup_id = 0;	/* 0: default bio_cgroup id */
> > +	if (!mm)
> > +		return;
> > +	/*
> > +	 * Locking "pc" isn't necessary here since the current process is
> > +	 * the only one that can access the members related to bio_cgroup.
> > +	 */
> > +	rcu_read_lock();
> > +	biog = bio_cgroup_from_task(rcu_dereference(mm->owner));
> > +	if (unlikely(!biog))
> > +		goto out;
> > +	/*
> > +	 * css_get(&bio->css) isn't called to increment the reference
> > +	 * count of this bio_cgroup "biog" so pc->bio_cgroup_id might turn
> > +	 * invalid even if this page is still active.
> > +	 * This approach is chosen to minimize the overhead.
> > +	 */
> > +	pc->bio_cgroup_id = biog->id;
> > +out:
> > +	rcu_read_unlock();
> > +}
> > +
> > +/*
> > + * Change the owner of a given page if necessary.
> > + */
> > +void bio_cgroup_reset_owner(struct page *page, struct mm_struct *mm)
> > +{
> > +	/*
> > +	 * A little trick:
> > +	 * Just call bio_cgroup_set_owner() for pages which are already
> > +	 * active since the bio_cgroup_id member of page_cgroup can be
> > +	 * updated without any locks. This is because an integer type of
> > +	 * variable can be set a new value at once on modern cpus.
> > +	 */
> > +	bio_cgroup_set_owner(page, mm);
> > +}
> Hmm ? I think all operations are under lock_page() and there are no races.
> Isn't it ?
> 

We can check this with:

WARN_ON_ONCE(test_bit(PG_locked, &page->flags));

> > diff --git a/mm/swap_state.c b/mm/swap_state.c
> > index 3ecea98..c7ad256 100644
> > --- a/mm/swap_state.c
> > +++ b/mm/swap_state.c
> > @@ -17,6 +17,7 @@
> >  #include <linux/backing-dev.h>
> >  #include <linux/pagevec.h>
> >  #include <linux/migrate.h>
> > +#include <linux/biotrack.h>
> >  #include <linux/page_cgroup.h>
> >  
> >  #include <asm/pgtable.h>
> > @@ -308,6 +309,7 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
> >  		 */
> >  		__set_page_locked(new_page);
> >  		SetPageSwapBacked(new_page);
> > +		bio_cgroup_set_owner(new_page, current->mm);
> >  		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
> >  		if (likely(!err)) {
> 
> I bet this is dangerous. You can't guarantee current->mm is owner of this swap cache
> because this is "readahead". You can't find the owner of this swap-cache until
> it's mapped. I recommend you to ignore swap-in here because
> 
>   - swapin-readahead just read (1 << page_cluster) pages at once.
>   - until the end of swap-in, the process will make no progress.

OK.

> 
> I wonder it's better to delay bio-cgroup attaching to anon page until swap-out or
> direct-io. (add hook to try_to_unmap and catch owner there.)
> Maybe most of anon pages will have no I/O if swap-out doesn't occur.
> BTW, it seems DIO from HugeTLB is not handled.

Ryo, it would be great if you can look at this and fix/integrate into
the mainstream bio-cgroup. Otherwise I can try to to schedule this in my
work.

Thanks for your suggestions Kame!
-Andrea
