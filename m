From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH mmotm 2.5/4] memcg: disable irq at page cgroup lock (Re:
	[PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
	infrastructure)
Date: Tue, 9 Mar 2010 11:07:22 +0900
Message-ID: <20100309110722.6e0490f6.kamezawa.hiroyu__8726.08145368776$1268139056$gmane$org@jp.fujitsu.com>
References: <1267995474-9117-1-git-send-email-arighi@develer.com>
	<1267995474-9117-4-git-send-email-arighi@develer.com>
	<20100308104447.c124c1ff.nishimura@mxp.nes.nec.co.jp>
	<20100308105641.e2e714f4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308111724.3e48aee3.nishimura@mxp.nes.nec.co.jp>
	<20100308113711.d7a249da.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308170711.4d8b02f0.nishimura@mxp.nes.nec.co.jp>
	<20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309001252.GB13490@linux>
	<20100309091914.4b5f6661.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309102928.9f36d2bb.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100309102928.9f36d2bb.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Greg-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Peter-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 9 Mar 2010 10:29:28 +0900
Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
> > please go ahead in this direction. Nishimura-san, would you post an
> > independent patch ? If no, Andrea-san, please.
> > 
> This is the updated version.
> 
> Andrea-san, can you merge this into your patch set ?
> 
> ===
> From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
> 
> In current implementation, we don't have to disable irq at lock_page_cgroup()
> because the lock is never acquired in interrupt context.
> But we are going to call it in later patch in an interrupt context or with
> irq disabled, so this patch disables irq at lock_page_cgroup() and enables it
> at unlock_page_cgroup().
> 
> Signed-off-by: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>



> ---
>  include/linux/page_cgroup.h |   16 ++++++++++++++--
>  mm/memcontrol.c             |   43 +++++++++++++++++++++++++------------------
>  2 files changed, 39 insertions(+), 20 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 30b0813..0d2f92c 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -83,16 +83,28 @@ static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
>  	return page_zonenum(pc->page);
>  }
>  
> -static inline void lock_page_cgroup(struct page_cgroup *pc)
> +static inline void __lock_page_cgroup(struct page_cgroup *pc)
>  {
>  	bit_spin_lock(PCG_LOCK, &pc->flags);
>  }
>  
> -static inline void unlock_page_cgroup(struct page_cgroup *pc)
> +static inline void __unlock_page_cgroup(struct page_cgroup *pc)
>  {
>  	bit_spin_unlock(PCG_LOCK, &pc->flags);
>  }
>  
> +#define lock_page_cgroup(pc, flags)		\
> +	do {					\
> +		local_irq_save(flags);		\
> +		__lock_page_cgroup(pc);		\
> +	} while (0)
> +
> +#define unlock_page_cgroup(pc, flags)		\
> +	do {					\
> +		__unlock_page_cgroup(pc);	\
> +		local_irq_restore(flags);	\
> +	} while (0)
> +
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct page_cgroup;
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7fab84e..a9fd736 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1352,12 +1352,13 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>  {
>  	struct mem_cgroup *mem;
>  	struct page_cgroup *pc;
> +	unsigned long flags;
>  
>  	pc = lookup_page_cgroup(page);
>  	if (unlikely(!pc))
>  		return;
>  
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  	mem = pc->mem_cgroup;
>  	if (!mem)
>  		goto done;
> @@ -1371,7 +1372,7 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>  	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
>  
>  done:
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  }
>  
>  /*
> @@ -1705,11 +1706,12 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  	struct page_cgroup *pc;
>  	unsigned short id;
>  	swp_entry_t ent;
> +	unsigned long flags;
>  
>  	VM_BUG_ON(!PageLocked(page));
>  
>  	pc = lookup_page_cgroup(page);
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  	if (PageCgroupUsed(pc)) {
>  		mem = pc->mem_cgroup;
>  		if (mem && !css_tryget(&mem->css))
> @@ -1723,7 +1725,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  			mem = NULL;
>  		rcu_read_unlock();
>  	}
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  	return mem;
>  }
>  
> @@ -1736,13 +1738,15 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>  				     struct page_cgroup *pc,
>  				     enum charge_type ctype)
>  {
> +	unsigned long flags;
> +
>  	/* try_charge() can return NULL to *memcg, taking care of it. */
>  	if (!mem)
>  		return;
>  
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  	if (unlikely(PageCgroupUsed(pc))) {
> -		unlock_page_cgroup(pc);
> +		unlock_page_cgroup(pc, flags);
>  		mem_cgroup_cancel_charge(mem);
>  		return;
>  	}
> @@ -1772,7 +1776,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>  
>  	mem_cgroup_charge_statistics(mem, pc, true);
>  
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  	/*
>  	 * "charge_statistics" updated event counter. Then, check it.
>  	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
> @@ -1842,12 +1846,13 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
>  		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
>  {
>  	int ret = -EINVAL;
> -	lock_page_cgroup(pc);
> +	unsigned long flags;
> +	lock_page_cgroup(pc, flags);
>  	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
>  		__mem_cgroup_move_account(pc, from, to, uncharge);
>  		ret = 0;
>  	}
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  	/*
>  	 * check events
>  	 */
> @@ -1974,17 +1979,17 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  	 */
>  	if (!(gfp_mask & __GFP_WAIT)) {
>  		struct page_cgroup *pc;
> -
> +		unsigned long flags;
>  
>  		pc = lookup_page_cgroup(page);
>  		if (!pc)
>  			return 0;
> -		lock_page_cgroup(pc);
> +		lock_page_cgroup(pc, flags);
>  		if (PageCgroupUsed(pc)) {
> -			unlock_page_cgroup(pc);
> +			unlock_page_cgroup(pc, flags);
>  			return 0;
>  		}
> -		unlock_page_cgroup(pc);
> +		unlock_page_cgroup(pc, flags);
>  	}
>  
>  	if (unlikely(!mm && !mem))
> @@ -2166,6 +2171,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	struct page_cgroup *pc;
>  	struct mem_cgroup *mem = NULL;
>  	struct mem_cgroup_per_zone *mz;
> +	unsigned long flags;
>  
>  	if (mem_cgroup_disabled())
>  		return NULL;
> @@ -2180,7 +2186,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	if (unlikely(!pc || !PageCgroupUsed(pc)))
>  		return NULL;
>  
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  
>  	mem = pc->mem_cgroup;
>  
> @@ -2219,7 +2225,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	 */
>  
>  	mz = page_cgroup_zoneinfo(pc);
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  
>  	memcg_check_events(mem, page);
>  	/* at swapout, this memcg will be accessed to record to swap */
> @@ -2229,7 +2235,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	return mem;
>  
>  unlock_out:
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  	return NULL;
>  }
>  
> @@ -2417,17 +2423,18 @@ int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
>  	struct page_cgroup *pc;
>  	struct mem_cgroup *mem = NULL;
>  	int ret = 0;
> +	unsigned long flags;
>  
>  	if (mem_cgroup_disabled())
>  		return 0;
>  
>  	pc = lookup_page_cgroup(page);
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  	if (PageCgroupUsed(pc)) {
>  		mem = pc->mem_cgroup;
>  		css_get(&mem->css);
>  	}
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  
>  	if (mem) {
>  		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
> -- 
> 1.6.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo-Bw31MaZKKs0EbZ0PF+XxCw@public.gmane.org  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org"> email-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org </a>
> 
