From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/2] memcg: dirty pages accounting and limiting
	infrastructure
Date: Mon, 22 Feb 2010 21:44:42 +0530
Message-ID: <20100222161442.GE3063__39432.4189088822$1266855801$gmane$org@balbir.in.ibm.com>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-2-git-send-email-arighi@develer.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1266765525-30890-2-git-send-email-arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

* Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> [2010-02-21 16:18:44]:

> Infrastructure to account dirty pages per cgroup + add memory.dirty_bytes limit
> in cgroupfs.
> 
> Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
> ---
>  include/linux/memcontrol.h |   31 ++++++
>  mm/memcontrol.c            |  218 +++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 248 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 1f9b119..ba3fe0d 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -25,6 +25,16 @@ struct page_cgroup;
>  struct page;
>  struct mm_struct;
> 
> +/* Cgroup memory statistics items exported to the kernel */
> +enum memcg_page_stat_item {
> +	MEMCG_NR_FREE_PAGES,
> +	MEMCG_NR_RECLAIMABLE_PAGES,
> +	MEMCG_NR_FILE_DIRTY,
> +	MEMCG_NR_WRITEBACK,
> +	MEMCG_NR_WRITEBACK_TEMP,
> +	MEMCG_NR_UNSTABLE_NFS,
> +};
> +
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  /*
>   * All "charge" functions with gfp_mask should use GFP_KERNEL or
> @@ -48,6 +58,8 @@ extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *ptr);
> 
>  extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  					gfp_t gfp_mask);
> +extern void mem_cgroup_charge_dirty(struct page *page,
> +			enum zone_stat_item idx, int charge);
>  extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru);
>  extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru);
>  extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru);
> @@ -117,6 +129,10 @@ extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>  extern int do_swap_account;
>  #endif
> 
> +extern unsigned long mem_cgroup_dirty_bytes(void);
> +
> +extern u64 mem_cgroup_page_state(enum memcg_page_stat_item item);
> +
>  static inline bool mem_cgroup_disabled(void)
>  {
>  	if (mem_cgroup_subsys.disabled)
> @@ -144,6 +160,11 @@ static inline int mem_cgroup_cache_charge(struct page *page,
>  	return 0;
>  }
> 
> +static inline void mem_cgroup_charge_dirty(struct page *page,
> +			enum zone_stat_item idx, int charge)
> +{
> +}
> +
>  static inline int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
>  		struct page *page, gfp_t gfp_mask, struct mem_cgroup **ptr)
>  {
> @@ -312,6 +333,16 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  	return 0;
>  }
> 
> +static inline unsigned long mem_cgroup_dirty_bytes(void)
> +{
> +	return vm_dirty_bytes;
> +}
> +
> +static inline u64 mem_cgroup_page_state(enum memcg_page_stat_item item)
> +{
> +	return 0;
> +}
> +
>  #endif /* CONFIG_CGROUP_MEM_CONT */
> 
>  #endif /* _LINUX_MEMCONTROL_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 954032b..288b9a4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -64,13 +64,18 @@ enum mem_cgroup_stat_index {
>  	/*
>  	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
>  	 */
> -	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> +	MEM_CGROUP_STAT_CACHE,	   /* # of pages charged as cache */
>  	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
>  	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
>  	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
>  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
>  	MEM_CGROUP_STAT_EVENTS,	/* sum of pagein + pageout for internal use */
>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> +	MEM_CGROUP_STAT_FILE_DIRTY,   /* # of dirty pages in page cache */
> +	MEM_CGROUP_STAT_WRITEBACK,   /* # of pages under writeback */
> +	MEM_CGROUP_STAT_WRITEBACK_TEMP,   /* # of pages under writeback using
> +						temporary buffers */
> +	MEM_CGROUP_STAT_UNSTABLE_NFS,   /* # of NFS unstable pages */
> 
>  	MEM_CGROUP_STAT_NSTATS,
>  };
> @@ -225,6 +230,9 @@ struct mem_cgroup {
>  	/* set when res.limit == memsw.limit */
>  	bool		memsw_is_minimum;
> 
> +	/* control memory cgroup dirty pages */
> +	unsigned long dirty_bytes;
> +
>  	/*
>  	 * statistics. This must be placed at the end of memcg.
>  	 */
> @@ -519,6 +527,67 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>  	put_cpu();
>  }
> 
> +static struct mem_cgroup *get_mem_cgroup_from_page(struct page *page)
> +{
> +	struct page_cgroup *pc;
> +	struct mem_cgroup *mem = NULL;
> +
> +	pc = lookup_page_cgroup(page);
> +	if (unlikely(!pc))
> +		return NULL;
> +	lock_page_cgroup(pc);
> +	if (PageCgroupUsed(pc)) {
> +		mem = pc->mem_cgroup;
> +		if (mem)
> +			css_get(&mem->css);
> +	}
> +	unlock_page_cgroup(pc);
> +	return mem;
> +}

Sounds like a reusable routine, have I seen it before?

> +
> +void mem_cgroup_charge_dirty(struct page *page,
> +			enum zone_stat_item idx, int charge)
> +{
> +	struct mem_cgroup *mem;
> +	struct mem_cgroup_stat_cpu *cpustat;
> +	unsigned long flags;
> +	int cpu;
> +
> +	if (mem_cgroup_disabled())
> +		return;
> +	/* Translate the zone_stat_item into a mem_cgroup_stat_index */
> +	switch (idx) {
> +	case NR_FILE_DIRTY:
> +		idx = MEM_CGROUP_STAT_FILE_DIRTY;
> +		break;
> +	case NR_WRITEBACK:
> +		idx = MEM_CGROUP_STAT_WRITEBACK;
> +		break;
> +	case NR_WRITEBACK_TEMP:
> +		idx = MEM_CGROUP_STAT_WRITEBACK_TEMP;
> +		break;
> +	case NR_UNSTABLE_NFS:
> +		idx = MEM_CGROUP_STAT_UNSTABLE_NFS;
> +		break;
> +	default:
> +		return;
> +	}
> +	/* Charge the memory cgroup statistics */
> +	mem = get_mem_cgroup_from_page(page);
> +	if (!mem) {
> +		mem = root_mem_cgroup;
> +		css_get(&mem->css);
> +	}
> +
> +	local_irq_save(flags);
> +	cpu = get_cpu();

Kamezawa is in the process of changing these, so you might want to
look at and integrate with those patches when they are ready.

> +	cpustat = &mem->stat.cpustat[cpu];
> +	__mem_cgroup_stat_add_safe(cpustat, idx, charge);
> +	put_cpu();
> +	local_irq_restore(flags);
> +	css_put(&mem->css);
> +}
> +

I would not recommend introducing a function that is not used in the
patch.

>  static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
>  					enum lru_list idx)
>  {
> @@ -992,6 +1061,97 @@ static unsigned int get_swappiness(struct mem_cgroup *memcg)
>  	return swappiness;
>  }
> 
> +static unsigned long get_dirty_bytes(struct mem_cgroup *memcg)
> +{
> +	struct cgroup *cgrp = memcg->css.cgroup;
> +	unsigned long dirty_bytes;
> +
> +	/* root ? */
> +	if (cgrp->parent == NULL)
> +		return vm_dirty_bytes;
> +
> +	spin_lock(&memcg->reclaim_param_lock);
> +	dirty_bytes = memcg->dirty_bytes;
> +	spin_unlock(&memcg->reclaim_param_lock);

Can't the read be RCU protected? Do we need a spin lock here?

> +
> +	return dirty_bytes;
> +}
> +
> +unsigned long mem_cgroup_dirty_bytes(void)
> +{
> +	struct mem_cgroup *memcg;
> +	unsigned long dirty_bytes;
> +
> +	if (mem_cgroup_disabled())
> +		return vm_dirty_bytes;
> +
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(current);
> +	if (memcg == NULL)
> +		dirty_bytes = vm_dirty_bytes;
> +	else
> +		dirty_bytes = get_dirty_bytes(memcg);
> +	rcu_read_unlock();
> +
> +	return dirty_bytes;
> +}
> +
> +u64 mem_cgroup_page_state(enum memcg_page_stat_item item)
> +{
> +	struct mem_cgroup *memcg;
> +	struct cgroup *cgrp;
> +	u64 ret = 0;
> +
> +	if (mem_cgroup_disabled())
> +		return 0;
> +
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(current);
> +	if (memcg == NULL)
> +		goto out;
> +	cgrp = memcg->css.cgroup;
> +	/* Use system-wide statistics for the root cgroup */
> +	if (cgrp->parent == NULL)
> +		goto out;
> +	switch (item) {
> +	case MEMCG_NR_FREE_PAGES:
> +		ret = res_counter_read_u64(&memcg->res, RES_LIMIT) -
> +			res_counter_read_u64(&memcg->res, RES_USAGE);
> +		/*
> +		 * Translate free memory in pages and ensure we never return 0.
> +		 */
> +		ret = (ret >> PAGE_SHIFT) + 1;
> +		break;
> +	case MEMCG_NR_RECLAIMABLE_PAGES:
> +		ret = mem_cgroup_read_stat(&memcg->stat, LRU_ACTIVE_ANON) +
> +			mem_cgroup_read_stat(&memcg->stat, LRU_ACTIVE_FILE) +
> +			mem_cgroup_read_stat(&memcg->stat, LRU_INACTIVE_ANON) +
> +			mem_cgroup_read_stat(&memcg->stat, LRU_INACTIVE_FILE);
> +		break;
> +	case MEMCG_NR_FILE_DIRTY:
> +		ret = mem_cgroup_read_stat(&memcg->stat,
> +				MEM_CGROUP_STAT_FILE_DIRTY);
> +		break;
> +	case MEMCG_NR_WRITEBACK:
> +		ret = mem_cgroup_read_stat(&memcg->stat,
> +				MEM_CGROUP_STAT_WRITEBACK);
> +		break;
> +	case MEMCG_NR_WRITEBACK_TEMP:
> +		ret = mem_cgroup_read_stat(&memcg->stat,
> +				MEM_CGROUP_STAT_WRITEBACK_TEMP);
> +		break;
> +	case MEMCG_NR_UNSTABLE_NFS:
> +		ret = mem_cgroup_read_stat(&memcg->stat,
> +				MEM_CGROUP_STAT_UNSTABLE_NFS);
> +		break;
> +	default:
> +		WARN_ON(1);
> +	}
> +out:
> +	rcu_read_unlock();
> +	return ret;
> +}
> +
>  static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
>  {
>  	int *val = data;
> @@ -2874,6 +3034,10 @@ enum {
>  	MCS_PGPGIN,
>  	MCS_PGPGOUT,
>  	MCS_SWAP,
> +	MCS_FILE_DIRTY,
> +	MCS_WRITEBACK,
> +	MCS_WRITEBACK_TEMP,
> +	MCS_UNSTABLE_NFS,
>  	MCS_INACTIVE_ANON,
>  	MCS_ACTIVE_ANON,
>  	MCS_INACTIVE_FILE,
> @@ -2896,6 +3060,10 @@ struct {
>  	{"pgpgin", "total_pgpgin"},
>  	{"pgpgout", "total_pgpgout"},
>  	{"swap", "total_swap"},
> +	{"filedirty", "dirty_pages"},
> +	{"writeback", "writeback_pages"},
> +	{"writeback_tmp", "writeback_temp_pages"},
> +	{"nfs", "nfs_unstable"},
>  	{"inactive_anon", "total_inactive_anon"},
>  	{"active_anon", "total_active_anon"},
>  	{"inactive_file", "total_inactive_file"},
> @@ -2924,6 +3092,14 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
>  		val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_SWAPOUT);
>  		s->stat[MCS_SWAP] += val * PAGE_SIZE;
>  	}
> +	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_FILE_DIRTY);
> +	s->stat[MCS_FILE_DIRTY] += val;
> +	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_WRITEBACK);
> +	s->stat[MCS_WRITEBACK] += val;
> +	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_WRITEBACK_TEMP);
> +	s->stat[MCS_WRITEBACK_TEMP] += val;
> +	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_UNSTABLE_NFS);
> +	s->stat[MCS_UNSTABLE_NFS] += val;
> 
>  	/* per zone stat */
>  	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
> @@ -3049,6 +3225,41 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  	return 0;
>  }
> 
> +static u64 mem_cgroup_dirty_bytes_read(struct cgroup *cgrp, struct cftype *cft)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +
> +	return get_dirty_bytes(memcg);
> +}
> +
> +static int mem_cgroup_dirty_bytes_write(struct cgroup *cgrp, struct cftype *cft,
> +				       u64 val)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	struct mem_cgroup *parent;
> +
> +	if (cgrp->parent == NULL)
> +		return -EINVAL;
> +
> +	parent = mem_cgroup_from_cont(cgrp->parent);
> +
> +	cgroup_lock();
> +
> +	/* If under hierarchy, only empty-root can set this value */
> +	if ((parent->use_hierarchy) ||
> +	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
> +		cgroup_unlock();
> +		return -EINVAL;
> +	}
> +
> +	spin_lock(&memcg->reclaim_param_lock);
> +	memcg->dirty_bytes = val;
> +	spin_unlock(&memcg->reclaim_param_lock);
> +
> +	cgroup_unlock();
> +
> +	return 0;
> +}
> 
>  static struct cftype mem_cgroup_files[] = {
>  	{
> @@ -3098,6 +3309,11 @@ static struct cftype mem_cgroup_files[] = {
>  		.read_u64 = mem_cgroup_swappiness_read,
>  		.write_u64 = mem_cgroup_swappiness_write,
>  	},
> +	{
> +		.name = "dirty_bytes",
> +		.read_u64 = mem_cgroup_dirty_bytes_read,
> +		.write_u64 = mem_cgroup_dirty_bytes_write,
> +	},
>  };
> 
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> -- 
> 1.6.3.3
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

-- 
	Three Cheers,
	Balbir
