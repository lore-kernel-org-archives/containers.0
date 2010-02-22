From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] memcg: dirty pages accounting and limiting
	infrastructure
Date: Mon, 22 Feb 2010 10:58:40 -0500
Message-ID: <20100222155840.GC13823__5893.93441700867$1266854516$gmane$org@redhat.com>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-2-git-send-email-arighi@develer.com>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Feb 21, 2010 at 04:18:44PM +0100, Andrea Righi wrote:
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
> +	cpustat = &mem->stat.cpustat[cpu];
> +	__mem_cgroup_stat_add_safe(cpustat, idx, charge);
> +	put_cpu();
> +	local_irq_restore(flags);
> +	css_put(&mem->css);
> +}
> +

We seem to be doing same operation as existing "mem_cgroup_update_file_mapped"
function is doing to udpate some stats. Can we just reuse that? We
probably can create one core function which take index of stat to update
and update_file_mapped and other variants for memcg dirty ratio can make
use of it.

In fact instead of single function charge_dirty() accounting for
WRITEBACK, we well as other states like UNSTABLE_NFS is not very intutive.
May be we can have indivdual functions.

mem_cgroup_update_dirty()
mem_cgroup_update_writeback()
mem_cgroup_update_unstable_nfs() etc.

Thanks
Vivek
