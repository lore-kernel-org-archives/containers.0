From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Date: Wed, 3 Mar 2010 12:50:30 +0100
Message-ID: <20100303115030.GC1990__25192.7274898209$1267617069$gmane$org@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<20100303111238.7133f8af.nishimura@mxp.nes.nec.co.jp>
	<20100303122906.9c613ab2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303150137.f56d7084.nishimura@mxp.nes.nec.co.jp>
	<20100303151549.5d3d686a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303172132.fc6d9387.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100303172132.fc6d9387.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Greg-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Mar 03, 2010 at 05:21:32PM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 3 Mar 2010 15:15:49 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> 
> > Agreed.
> > Let's try how we can write a code in clean way. (we have time ;)
> > For now, to me, IRQ disabling while lock_page_cgroup() seems to be a little
> > over killing. What I really want is lockless code...but it seems impossible
> > under current implementation.
> > 
> > I wonder the fact "the page is never unchareged under us" can give us some chances
> > ...Hmm.
> > 
> 
> How about this ? Basically, I don't like duplicating information...so,
> # of new pcg_flags may be able to be reduced.
> 
> I'm glad this can be a hint for Andrea-san.

Many thanks! I already wrote pretty the same code, but at this point I
think I'll just apply and test this one. ;)

-Andrea

> 
> ==
> ---
>  include/linux/page_cgroup.h |   44 ++++++++++++++++++++-
>  mm/memcontrol.c             |   91 +++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 132 insertions(+), 3 deletions(-)
> 
> Index: mmotm-2.6.33-Mar2/include/linux/page_cgroup.h
> ===================================================================
> --- mmotm-2.6.33-Mar2.orig/include/linux/page_cgroup.h
> +++ mmotm-2.6.33-Mar2/include/linux/page_cgroup.h
> @@ -39,6 +39,11 @@ enum {
>  	PCG_CACHE, /* charged as cache */
>  	PCG_USED, /* this object is in use. */
>  	PCG_ACCT_LRU, /* page has been accounted for */
> +	PCG_MIGRATE_LOCK, /* used for mutual execution of account migration */
> +	PCG_ACCT_DIRTY,
> +	PCG_ACCT_WB,
> +	PCG_ACCT_WB_TEMP,
> +	PCG_ACCT_UNSTABLE,
>  };
>  
>  #define TESTPCGFLAG(uname, lname)			\
> @@ -73,6 +78,23 @@ CLEARPCGFLAG(AcctLRU, ACCT_LRU)
>  TESTPCGFLAG(AcctLRU, ACCT_LRU)
>  TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
>  
> +SETPCGFLAG(AcctDirty, ACCT_DIRTY);
> +CLEARPCGFLAG(AcctDirty, ACCT_DIRTY);
> +TESTPCGFLAG(AcctDirty, ACCT_DIRTY);
> +
> +SETPCGFLAG(AcctWB, ACCT_WB);
> +CLEARPCGFLAG(AcctWB, ACCT_WB);
> +TESTPCGFLAG(AcctWB, ACCT_WB);
> +
> +SETPCGFLAG(AcctWBTemp, ACCT_WB_TEMP);
> +CLEARPCGFLAG(AcctWBTemp, ACCT_WB_TEMP);
> +TESTPCGFLAG(AcctWBTemp, ACCT_WB_TEMP);
> +
> +SETPCGFLAG(AcctUnstableNFS, ACCT_UNSTABLE);
> +CLEARPCGFLAG(AcctUnstableNFS, ACCT_UNSTABLE);
> +TESTPCGFLAG(AcctUnstableNFS, ACCT_UNSTABLE);
> +
> +
>  static inline int page_cgroup_nid(struct page_cgroup *pc)
>  {
>  	return page_to_nid(pc->page);
> @@ -82,7 +104,9 @@ static inline enum zone_type page_cgroup
>  {
>  	return page_zonenum(pc->page);
>  }
> -
> +/*
> + * lock_page_cgroup() should not be held under mapping->tree_lock
> + */
>  static inline void lock_page_cgroup(struct page_cgroup *pc)
>  {
>  	bit_spin_lock(PCG_LOCK, &pc->flags);
> @@ -93,6 +117,24 @@ static inline void unlock_page_cgroup(st
>  	bit_spin_unlock(PCG_LOCK, &pc->flags);
>  }
>  
> +/*
> + * Lock order is
> + * 	lock_page_cgroup()
> + * 		lock_page_cgroup_migrate()
> + * This lock is not be lock for charge/uncharge but for account moving.
> + * i.e. overwrite pc->mem_cgroup. The lock owner should guarantee by itself
> + * the page is uncharged while we hold this.
> + */
> +static inline void lock_page_cgroup_migrate(struct page_cgroup *pc)
> +{
> +	bit_spin_lock(PCG_MIGRATE_LOCK, &pc->flags);
> +}
> +
> +static inline void unlock_page_cgroup_migrate(struct page_cgroup *pc)
> +{
> +	bit_spin_unlock(PCG_MIGRATE_LOCK, &pc->flags);
> +}
> +
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct page_cgroup;
>  
> Index: mmotm-2.6.33-Mar2/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.33-Mar2.orig/mm/memcontrol.c
> +++ mmotm-2.6.33-Mar2/mm/memcontrol.c
> @@ -87,6 +87,10 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
>  	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
> +	MEM_CGROUP_STAT_DIRTY,
> +	MEM_CGROUP_STAT_WBACK,
> +	MEM_CGROUP_STAT_WBACK_TEMP,
> +	MEM_CGROUP_STAT_UNSTABLE_NFS,
>  
>  	MEM_CGROUP_STAT_NSTATS,
>  };
> @@ -1360,6 +1364,86 @@ done:
>  }
>  
>  /*
> + * Update file cache's status for memcg. Before calling this,
> + * mapping->tree_lock should be held and preemption is disabled.
> + * Then, it's guarnteed that the page is not uncharged while we
> + * access page_cgroup. We can make use of that.
> + */
> +void mem_cgroup_update_stat_locked(struct page *page, int idx, bool set)
> +{
> +	struct page_cgroup *pc;
> +	struct mem_cgroup *mem;
> +
> +	pc = lookup_page_cgroup(page);
> +	/* Not accounted ? */
> +	if (!PageCgroupUsed(pc))
> +		return;
> +	lock_page_cgroup_migrate(pc);
> +	/*
> +	 * It's guarnteed that this page is never uncharged.
> +	 * The only racy problem is moving account among memcgs.
> +	 */
> +	switch (idx) {
> +	case MEM_CGROUP_STAT_DIRTY:
> +		if (set)
> +			SetPageCgroupAcctDirty(pc);
> +		else
> +			ClearPageCgroupAcctDirty(pc);
> +		break;
> +	case MEM_CGROUP_STAT_WBACK:
> +		if (set)
> +			SetPageCgroupAcctWB(pc);
> +		else
> +			ClearPageCgroupAcctWB(pc);
> +		break;
> +	case MEM_CGROUP_STAT_WBACK_TEMP:
> +		if (set)
> +			SetPageCgroupAcctWBTemp(pc);
> +		else
> +			ClearPageCgroupAcctWBTemp(pc);
> +		break;
> +	case MEM_CGROUP_STAT_UNSTABLE_NFS:
> +		if (set)
> +			SetPageCgroupAcctUnstableNFS(pc);
> +		else
> +			ClearPageCgroupAcctUnstableNFS(pc);
> +		break;
> +	default:
> +		BUG();
> +		break;
> +	}
> +	mem = pc->mem_cgroup;
> +	if (set)
> +		__this_cpu_inc(mem->stat->count[idx]);
> +	else
> +		__this_cpu_dec(mem->stat->count[idx]);
> +	unlock_page_cgroup_migrate(pc);
> +}
> +
> +static void move_acct_information(struct mem_cgroup *from,
> +				struct mem_cgroup *to,
> +				struct page_cgroup *pc)
> +{
> +	/* preemption is disabled, migration_lock is held. */
> +	if (PageCgroupAcctDirty(pc)) {
> +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_DIRTY]);
> +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_DIRTY]);
> +	}
> +	if (PageCgroupAcctWB(pc)) {
> +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_WBACK]);
> +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_WBACK]);
> +	}
> +	if (PageCgroupAcctWBTemp(pc)) {
> +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_WBACK_TEMP]);
> +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_WBACK_TEMP]);
> +	}
> +	if (PageCgroupAcctUnstableNFS(pc)) {
> +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
> +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
> +	}
> +}
> +
> +/*
>   * size of first charge trial. "32" comes from vmscan.c's magic value.
>   * TODO: maybe necessary to use big numbers in big irons.
>   */
> @@ -1794,15 +1878,16 @@ static void __mem_cgroup_move_account(st
>  	VM_BUG_ON(!PageCgroupUsed(pc));
>  	VM_BUG_ON(pc->mem_cgroup != from);
>  
> +	preempt_disable();
> +	lock_page_cgroup_migrate(pc);
>  	page = pc->page;
>  	if (page_mapped(page) && !PageAnon(page)) {
>  		/* Update mapped_file data for mem_cgroup */
> -		preempt_disable();
>  		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
>  		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> -		preempt_enable();
>  	}
>  	mem_cgroup_charge_statistics(from, pc, false);
> +	move_acct_information(from, to, pc);
>  	if (uncharge)
>  		/* This is not "cancel", but cancel_charge does all we need. */
>  		mem_cgroup_cancel_charge(from);
> @@ -1810,6 +1895,8 @@ static void __mem_cgroup_move_account(st
>  	/* caller should have done css_get */
>  	pc->mem_cgroup = to;
>  	mem_cgroup_charge_statistics(to, pc, true);
> +	unlock_page_cgroup_migrate(pc);
> +	preempt_enable();
>  	/*
>  	 * We charges against "to" which may not have any tasks. Then, "to"
>  	 * can be under rmdir(). But in current implementation, caller of
> 
