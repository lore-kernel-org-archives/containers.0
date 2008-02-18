From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] memory controller : backgorund reclaim and avoid
	excessive locking [5/5] lazy page_cgroup freeing
Date: Mon, 18 Feb 2008 11:11:05 +0900
Message-ID: <20080218111105.0f889403.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080214173624.d29b26d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20080218015840.CE6FF1E3C58@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080218015840.CE6FF1E3C58-Pcsii4f/SVk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 18 Feb 2008 10:58:40 +0900 (JST)
yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi) wrote:

> > +	/*
> > +	 * For lazy freeing (not GC)
> > +	 */
> > +	struct {
> > +		struct mem_cgroup_per_zone *mz;
> > +		int			num;
> > +#define GARBAGE_MAXSIZE		(16)
> > +		struct page_cgroup	*vec[GARBAGE_MAXSIZE];
> > +	} garbage[NR_CPUS];
> >  };
> 
> i think you want to dedicate cache lines.
> 
> > @@ -176,12 +185,14 @@ struct page_cgroup {
> >  	struct list_head lru;		/* per cgroup LRU list */
> >  	struct page *page;
> >  	struct mem_cgroup *mem_cgroup;
> > +	struct mem_cgroup_per_zone *mz;	/* now belongs to...*/
> 
> is this for performance?
> 
We need to find what zone pc is under...
Now, we can find it by pc->page.
But I don't want to trust pc->page of freed pages.

> > @@ -408,10 +427,12 @@ static void __mem_cgroup_move_lists(stru
> >  	if (active) {
> >  		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE) += 1;
> >  		pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
> > +		pc->mz = mz;
> >  		list_move(&pc->lru, &mz->active_list);
> >  	} else {
> >  		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) += 1;
> >  		pc->flags &= ~PAGE_CGROUP_FLAG_ACTIVE;
> > +		pc->mz = mz;
> >  		list_move(&pc->lru, &mz->inactive_list);
> >  	}
> >  }
> 
> isn't pc->mz already assigned by __mem_cgroup_add_list?
> 
Ah, yes. I can remove this.

> > @@ -1050,11 +1114,15 @@ mem_cgroup_force_empty_list(struct mem_c
> >  	if (list_empty(list))
> >  		return;
> >  retry:
> > +	all_free_garbages(mem);
> >  	count = FORCE_UNCHARGE_BATCH;
> >  	spin_lock_irqsave(&mz->lru_lock, flags);
> >  
> >  	while (--count && !list_empty(list)) {
> >  		pc = list_entry(list->prev, struct page_cgroup, lru);
> > +		/* If there are still garbage, exit and retry */
> > +		if (pc->flags & PAGE_CGROUP_FLAG_GARBAGE)
> > +			break;
> 
> i think mem_cgroup_isolate_pages needs a similar check.
> 
Yes. maybe my refresh miss..

Thanks,
-Kame


> YAMAMOTO Takashi
> 
