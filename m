From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
	infrastructure
Date: Fri, 5 Mar 2010 23:14:02 +0100
Message-ID: <20100305221401.GA1578__31215.3391809717$1267827342$gmane$org@linux>
References: <1267699215-4101-1-git-send-email-arighi@develer.com>
	<1267699215-4101-4-git-send-email-arighi@develer.com>
	<20100305101234.909001e8.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100305101234.909001e8.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 05, 2010 at 10:12:34AM +0900, Daisuke Nishimura wrote:
> On Thu,  4 Mar 2010 11:40:14 +0100, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:
> > Infrastructure to account dirty pages per cgroup and add dirty limit
> > interfaces in the cgroupfs:
> > 
> >  - Direct write-out: memory.dirty_ratio, memory.dirty_bytes
> > 
> >  - Background write-out: memory.dirty_background_ratio, memory.dirty_background_bytes
> > 
> > Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
> > ---
> >  include/linux/memcontrol.h |   80 ++++++++-
> >  mm/memcontrol.c            |  420 +++++++++++++++++++++++++++++++++++++++-----
> >  2 files changed, 450 insertions(+), 50 deletions(-)
> > 
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 1f9b119..cc3421b 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -19,12 +19,66 @@
> >  
> >  #ifndef _LINUX_MEMCONTROL_H
> >  #define _LINUX_MEMCONTROL_H
> > +
> > +#include <linux/writeback.h>
> >  #include <linux/cgroup.h>
> > +
> >  struct mem_cgroup;
> >  struct page_cgroup;
> >  struct page;
> >  struct mm_struct;
> >  
> > +/* Cgroup memory statistics items exported to the kernel */
> > +enum mem_cgroup_page_stat_item {
> > +	MEMCG_NR_DIRTYABLE_PAGES,
> > +	MEMCG_NR_RECLAIM_PAGES,
> > +	MEMCG_NR_WRITEBACK,
> > +	MEMCG_NR_DIRTY_WRITEBACK_PAGES,
> > +};
> > +
> > +/* Dirty memory parameters */
> > +struct dirty_param {
> > +	int dirty_ratio;
> > +	unsigned long dirty_bytes;
> > +	int dirty_background_ratio;
> > +	unsigned long dirty_background_bytes;
> > +};
> > +
> > +/*
> > + * Statistics for memory cgroup.
> > + */
> > +enum mem_cgroup_stat_index {
> > +	/*
> > +	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> > +	 */
> > +	MEM_CGROUP_STAT_CACHE,	   /* # of pages charged as cache */
> > +	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> > +	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> > +	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
> > +	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> > +	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> > +	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
> > +	MEM_CGROUP_STAT_FILE_DIRTY,   /* # of dirty pages in page cache */
> > +	MEM_CGROUP_STAT_WRITEBACK,   /* # of pages under writeback */
> > +	MEM_CGROUP_STAT_WRITEBACK_TEMP,   /* # of pages under writeback using
> > +						temporary buffers */
> > +	MEM_CGROUP_STAT_UNSTABLE_NFS,   /* # of NFS unstable pages */
> > +
> > +	MEM_CGROUP_STAT_NSTATS,
> > +};
> > +
> I must have said it earlier, but I don't think exporting all of these flags
> is a good idea.
> Can you export only mem_cgroup_page_stat_item(of course, need to add MEMCG_NR_FILE_MAPPED)?
> We can translate mem_cgroup_page_stat_item to mem_cgroup_stat_index by simple arithmetic
> if you define MEM_CGROUP_STAT_FILE_MAPPED..MEM_CGROUP_STAT_UNSTABLE_NFS sequentially.

Agreed.

> 
> > +/*
> > + * TODO: provide a validation check routine. And retry if validation
> > + * fails.
> > + */
> > +static inline void get_global_dirty_param(struct dirty_param *param)
> > +{
> > +	param->dirty_ratio = vm_dirty_ratio;
> > +	param->dirty_bytes = vm_dirty_bytes;
> > +	param->dirty_background_ratio = dirty_background_ratio;
> > +	param->dirty_background_bytes = dirty_background_bytes;
> > +}
> > +
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> >  /*
> >   * All "charge" functions with gfp_mask should use GFP_KERNEL or
> > @@ -117,6 +171,10 @@ extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> >  extern int do_swap_account;
> >  #endif
> >  
> > +extern bool mem_cgroup_has_dirty_limit(void);
> > +extern void get_dirty_param(struct dirty_param *param);
> > +extern s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item);
> > +
> >  static inline bool mem_cgroup_disabled(void)
> >  {
> >  	if (mem_cgroup_subsys.disabled)
> > @@ -125,7 +183,8 @@ static inline bool mem_cgroup_disabled(void)
> >  }
> >  
> >  extern bool mem_cgroup_oom_called(struct task_struct *task);
> > -void mem_cgroup_update_file_mapped(struct page *page, int val);
> > +void mem_cgroup_update_stat(struct page *page,
> > +			enum mem_cgroup_stat_index idx, int val);
> >  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> >  						gfp_t gfp_mask, int nid,
> >  						int zid);
> > @@ -300,8 +359,8 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> >  {
> >  }
> >  
> > -static inline void mem_cgroup_update_file_mapped(struct page *page,
> > -							int val)
> > +static inline void mem_cgroup_update_stat(struct page *page,
> > +			enum mem_cgroup_stat_index idx, int val)
> >  {
> >  }
> >  
> > @@ -312,6 +371,21 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> >  	return 0;
> >  }
> >  
> > +static inline bool mem_cgroup_has_dirty_limit(void)
> > +{
> > +	return false;
> > +}
> > +
> > +static inline void get_dirty_param(struct dirty_param *param)
> > +{
> > +	get_global_dirty_param(param);
> > +}
> > +
> > +static inline s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item)
> > +{
> > +	return -ENOSYS;
> > +}
> > +
> >  #endif /* CONFIG_CGROUP_MEM_CONT */
> >  
> >  #endif /* _LINUX_MEMCONTROL_H */
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 497b6f7..9842e7b 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -73,28 +73,23 @@ static int really_do_swap_account __initdata = 1; /* for remember boot option*/
> >  #define THRESHOLDS_EVENTS_THRESH (7) /* once in 128 */
> >  #define SOFTLIMIT_EVENTS_THRESH (10) /* once in 1024 */
> >  
> > -/*
> > - * Statistics for memory cgroup.
> > - */
> > -enum mem_cgroup_stat_index {
> > -	/*
> > -	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> > -	 */
> > -	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> > -	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> > -	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> > -	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
> > -	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> > -	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> > -	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
> > -
> > -	MEM_CGROUP_STAT_NSTATS,
> > -};
> > -
> >  struct mem_cgroup_stat_cpu {
> >  	s64 count[MEM_CGROUP_STAT_NSTATS];
> >  };
> >  
> > +/* Per cgroup page statistics */
> > +struct mem_cgroup_page_stat {
> > +	enum mem_cgroup_page_stat_item item;
> > +	s64 value;
> > +};
> > +
> > +enum {
> > +	MEM_CGROUP_DIRTY_RATIO,
> > +	MEM_CGROUP_DIRTY_BYTES,
> > +	MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
> > +	MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
> > +};
> > +
> >  /*
> >   * per-zone information in memory controller.
> >   */
> > @@ -208,6 +203,9 @@ struct mem_cgroup {
> >  
> >  	unsigned int	swappiness;
> >  
> > +	/* control memory cgroup dirty pages */
> > +	struct dirty_param dirty_param;
> > +
> >  	/* set when res.limit == memsw.limit */
> >  	bool		memsw_is_minimum;
> >  
> > @@ -1033,6 +1031,156 @@ static unsigned int get_swappiness(struct mem_cgroup *memcg)
> >  	return swappiness;
> >  }
> >  
> > +static bool dirty_param_is_valid(struct dirty_param *param)
> > +{
> > +	if (param->dirty_ratio && param->dirty_bytes)
> > +		return false;
> > +	if (param->dirty_background_ratio && param->dirty_background_bytes)
> > +		return false;
> > +	return true;
> > +}
> > +
> > +static void
> > +__mem_cgroup_get_dirty_param(struct dirty_param *param, struct mem_cgroup *mem)
> > +{
> > +	param->dirty_ratio = mem->dirty_param.dirty_ratio;
> > +	param->dirty_bytes = mem->dirty_param.dirty_bytes;
> > +	param->dirty_background_ratio = mem->dirty_param.dirty_background_ratio;
> > +	param->dirty_background_bytes = mem->dirty_param.dirty_background_bytes;
> > +}
> > +
> > +/*
> > + * get_dirty_param() - get dirty memory parameters of the current memcg
> > + * @param:	a structure is filled with the dirty memory settings
> > + *
> > + * The function fills @param with the current memcg dirty memory settings. If
> > + * memory cgroup is disabled or in case of error the structure is filled with
> > + * the global dirty memory settings.
> > + */
> > +void get_dirty_param(struct dirty_param *param)
> > +{
> > +	struct mem_cgroup *memcg;
> > +
> > +	if (mem_cgroup_disabled()) {
> > +		get_global_dirty_param(param);
> > +		return;
> > +	}
> > +	/*
> > +	 * It's possible that "current" may be moved to other cgroup while we
> > +	 * access cgroup. But precise check is meaningless because the task can
> > +	 * be moved after our access and writeback tends to take long time.
> > +	 * At least, "memcg" will not be freed under rcu_read_lock().
> > +	 */
> > +	while (1) {
> > +		rcu_read_lock();
> > +		memcg = mem_cgroup_from_task(current);
> > +		if (likely(memcg))
> > +			__mem_cgroup_get_dirty_param(param, memcg);
> > +		else
> > +			get_global_dirty_param(param);
> > +		rcu_read_unlock();
> > +		/*
> > +		 * Since global and memcg dirty_param are not protected we try
> > +		 * to speculatively read them and retry if we get inconsistent
> > +		 * values.
> > +		 */
> > +		if (likely(dirty_param_is_valid(param)))
> > +			break;
> > +	}
> > +}
> > +
> > +static inline bool mem_cgroup_can_swap(struct mem_cgroup *memcg)
> > +{
> > +	if (!do_swap_account)
> > +		return nr_swap_pages > 0;
> > +	return !memcg->memsw_is_minimum &&
> > +		(res_counter_read_u64(&memcg->memsw, RES_LIMIT) > 0);
> > +}
> > +
> > +static s64 mem_cgroup_get_local_page_stat(struct mem_cgroup *memcg,
> > +				enum mem_cgroup_page_stat_item item)
> > +{
> > +	s64 ret;
> > +
> > +	switch (item) {
> > +	case MEMCG_NR_DIRTYABLE_PAGES:
> > +		ret = res_counter_read_u64(&memcg->res, RES_LIMIT) -
> > +			res_counter_read_u64(&memcg->res, RES_USAGE);
> > +		/* Translate free memory in pages */
> > +		ret >>= PAGE_SHIFT;
> > +		ret += mem_cgroup_read_stat(memcg, LRU_ACTIVE_FILE) +
> > +			mem_cgroup_read_stat(memcg, LRU_INACTIVE_FILE);
> > +		if (mem_cgroup_can_swap(memcg))
> > +			ret += mem_cgroup_read_stat(memcg, LRU_ACTIVE_ANON) +
> > +				mem_cgroup_read_stat(memcg, LRU_INACTIVE_ANON);
> > +		break;
> > +	case MEMCG_NR_RECLAIM_PAGES:
> > +		ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_FILE_DIRTY) +
> > +			mem_cgroup_read_stat(memcg,
> > +					MEM_CGROUP_STAT_UNSTABLE_NFS);
> > +		break;
> > +	case MEMCG_NR_WRITEBACK:
> > +		ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
> > +		break;
> > +	case MEMCG_NR_DIRTY_WRITEBACK_PAGES:
> > +		ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_WRITEBACK) +
> > +			mem_cgroup_read_stat(memcg,
> > +				MEM_CGROUP_STAT_UNSTABLE_NFS);
> > +		break;
> > +	default:
> > +		BUG_ON(1);
> > +	}
> > +	return ret;
> > +}
> > +
> > +static int mem_cgroup_page_stat_cb(struct mem_cgroup *mem, void *data)
> > +{
> > +	struct mem_cgroup_page_stat *stat = (struct mem_cgroup_page_stat *)data;
> > +
> > +	stat->value += mem_cgroup_get_local_page_stat(mem, stat->item);
> > +	return 0;
> > +}
> > +
> > +/*
> > + * mem_cgroup_has_dirty_limit() - check if current memcg has local dirty limits
> > + *
> > + * Return true if the current memory cgroup has local dirty memory settings,
> > + * false otherwise.
> > + */
> > +bool mem_cgroup_has_dirty_limit(void)
> > +{
> > +	if (mem_cgroup_disabled())
> > +		return false;
> > +	return mem_cgroup_from_task(current) != NULL;
> > +}
> > +
> > +/*
> > + * mem_cgroup_page_stat() - get memory cgroup file cache statistics
> > + * @item:	memory statistic item exported to the kernel
> > + *
> > + * Return the accounted statistic value, or a negative value in case of error.
> > + */
> > +s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item)
> > +{
> > +	struct mem_cgroup_page_stat stat = {};
> > +	struct mem_cgroup *memcg;
> > +
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(current);
> > +	if (memcg) {
> > +		/*
> > +		 * Recursively evaulate page statistics against all cgroup
> > +		 * under hierarchy tree
> > +		 */
> > +		stat.item = item;
> > +		mem_cgroup_walk_tree(memcg, &stat, mem_cgroup_page_stat_cb);
> > +	} else
> > +		stat.value = -EINVAL;
> > +	rcu_read_unlock();
> > +
> > +	return stat.value;
> > +}
> > +
> >  static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
> >  {
> >  	int *val = data;
> > @@ -1275,34 +1423,70 @@ static void record_last_oom(struct mem_cgroup *mem)
> >  }
> >  
> >  /*
> > - * Currently used to update mapped file statistics, but the routine can be
> > - * generalized to update other statistics as well.
> > + * Generalized routine to update file cache's status for memcg.
> > + *
> > + * Before calling this, mapping->tree_lock should be held and preemption is
> > + * disabled.  Then, it's guarnteed that the page is not uncharged while we
> > + * access page_cgroup. We can make use of that.
> >   */
> IIUC, mapping->tree_lock is held with irq disabled, so I think "mapping->tree_lock
> should be held with irq disabled" would be enouth.
> And, as far as I can see, callers of this function have not ensured this yet in [4/4].
> 
> how about:
> 
> 	void mem_cgroup_update_stat_locked(...)
> 	{
> 		...
> 	}
> 
> 	void mem_cgroup_update_stat_unlocked(mapping, ...)
> 	{
> 		spin_lock_irqsave(mapping->tree_lock, ...);
> 		mem_cgroup_update_stat_locked();
> 		spin_unlock_irqrestore(...);
> 	}

So, basically, lock_page_cgroup_migrate() should disable irqs and
unlock_page_cgroup_migrate() should re-enable them, except for updating
MEM_CGROUP_STAT_FILE_MAPPED, where just a lock/unlock_page_cgroup() is
needed. Right?

> 
> > -void mem_cgroup_update_file_mapped(struct page *page, int val)
> > +void mem_cgroup_update_stat(struct page *page,
> > +			enum mem_cgroup_stat_index idx, int val)
> >  {
> I preffer "void mem_cgroup_update_page_stat(struct page *, enum mem_cgroup_page_stat_item, ..)"
> as I said above.
> 
> >  	struct mem_cgroup *mem;
> >  	struct page_cgroup *pc;
> >  
> > +	if (mem_cgroup_disabled())
> > +		return;
> >  	pc = lookup_page_cgroup(page);
> > -	if (unlikely(!pc))
> > +	if (unlikely(!pc) || !PageCgroupUsed(pc))
> >  		return;
> >  
> > -	lock_page_cgroup(pc);
> > -	mem = pc->mem_cgroup;
> > -	if (!mem)
> > -		goto done;
> > -
> > -	if (!PageCgroupUsed(pc))
> > -		goto done;
> > -
> > +	lock_page_cgroup_migrate(pc);
> >  	/*
> > -	 * Preemption is already disabled. We can use __this_cpu_xxx
> > -	 */
> > -	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
> > -
> > -done:
> > -	unlock_page_cgroup(pc);
> > +	* It's guarnteed that this page is never uncharged.
> > +	* The only racy problem is moving account among memcgs.
> > +	*/
> > +	switch (idx) {
> > +	case MEM_CGROUP_STAT_FILE_MAPPED:
> > +		if (val > 0)
> > +			SetPageCgroupFileMapped(pc);
> > +		else
> > +			ClearPageCgroupFileMapped(pc);
> > +		break;
> > +	case MEM_CGROUP_STAT_FILE_DIRTY:
> > +		if (val > 0)
> > +			SetPageCgroupDirty(pc);
> > +		else
> > +			ClearPageCgroupDirty(pc);
> > +		break;
> > +	case MEM_CGROUP_STAT_WRITEBACK:
> > +		if (val > 0)
> > +			SetPageCgroupWriteback(pc);
> > +		else
> > +			ClearPageCgroupWriteback(pc);
> > +		break;
> > +	case MEM_CGROUP_STAT_WRITEBACK_TEMP:
> > +		if (val > 0)
> > +			SetPageCgroupWritebackTemp(pc);
> > +		else
> > +			ClearPageCgroupWritebackTemp(pc);
> > +		break;
> > +	case MEM_CGROUP_STAT_UNSTABLE_NFS:
> > +		if (val > 0)
> > +			SetPageCgroupUnstableNFS(pc);
> > +		else
> > +			ClearPageCgroupUnstableNFS(pc);
> > +		break;
> > +	default:
> > +		BUG();
> > +		break;
> > +	}
> > +	mem = pc->mem_cgroup;
> > +	if (likely(mem))
> > +		__this_cpu_add(mem->stat->count[idx], val);
> > +	unlock_page_cgroup_migrate(pc);
> >  }
> > +EXPORT_SYMBOL_GPL(mem_cgroup_update_stat);
> >  
> >  /*
> >   * size of first charge trial. "32" comes from vmscan.c's magic value.
> > @@ -1701,6 +1885,45 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
> >  	memcg_check_events(mem, pc->page);
> >  }
> >  
> > +/*
> > + * Update file cache accounted statistics on task migration.
> > + *
> > + * TODO: We don't move charges of file (including shmem/tmpfs) pages for now.
> > + * So, at the moment this function simply returns without updating accounted
> > + * statistics, because we deal only with anonymous pages here.
> > + */
> This function is not unique to task migration. It's called from rmdir() too.
> So this comment isn't needed.

Agreed.

> 
> > +static void __mem_cgroup_update_file_stat(struct page_cgroup *pc,
> > +	struct mem_cgroup *from, struct mem_cgroup *to)
> > +{
> > +	struct page *page = pc->page;
> > +
> > +	if (!page_mapped(page) || PageAnon(page))
> > +		return;
> > +
> > +	if (PageCgroupFileMapped(pc)) {
> > +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > +	}
> > +	if (PageCgroupDirty(pc)) {
> > +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_DIRTY]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_DIRTY]);
> > +	}
> > +	if (PageCgroupWriteback(pc)) {
> > +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_WRITEBACK]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_WRITEBACK]);
> > +	}
> > +	if (PageCgroupWritebackTemp(pc)) {
> > +		__this_cpu_dec(
> > +			from->stat->count[MEM_CGROUP_STAT_WRITEBACK_TEMP]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_WRITEBACK_TEMP]);
> > +	}
> > +	if (PageCgroupUnstableNFS(pc)) {
> > +		__this_cpu_dec(
> > +			from->stat->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
> > +	}
> > +}
> > +
> >  /**
> >   * __mem_cgroup_move_account - move account of the page
> >   * @pc:	page_cgroup of the page.
> > @@ -1721,22 +1944,16 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
> >  static void __mem_cgroup_move_account(struct page_cgroup *pc,
> >  	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
> >  {
> > -	struct page *page;
> > -
> >  	VM_BUG_ON(from == to);
> >  	VM_BUG_ON(PageLRU(pc->page));
> >  	VM_BUG_ON(!PageCgroupLocked(pc));
> >  	VM_BUG_ON(!PageCgroupUsed(pc));
> >  	VM_BUG_ON(pc->mem_cgroup != from);
> >  
> > -	page = pc->page;
> > -	if (page_mapped(page) && !PageAnon(page)) {
> > -		/* Update mapped_file data for mem_cgroup */
> > -		preempt_disable();
> > -		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > -		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > -		preempt_enable();
> > -	}
> > +	preempt_disable();
> > +	lock_page_cgroup_migrate(pc);
> > +	__mem_cgroup_update_file_stat(pc, from, to);
> > +
> >  	mem_cgroup_charge_statistics(from, pc, false);
> >  	if (uncharge)
> >  		/* This is not "cancel", but cancel_charge does all we need. */
> > @@ -1745,6 +1962,8 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
> >  	/* caller should have done css_get */
> >  	pc->mem_cgroup = to;
> >  	mem_cgroup_charge_statistics(to, pc, true);
> > +	unlock_page_cgroup_migrate(pc);
> > +	preempt_enable();
> Glad to see this cleanup :)
> But, hmm, I don't think preempt_disable/enable() is enough(and bit_spin_lock/unlock()
> does it anyway). lock/unlock_page_cgroup_migrate() can be called under irq context
> (e.g. end_page_writeback()), so I think we must local_irq_disable()/enable() here.

You're right. So, also for this case irqs must be disabled/enabled by
lock/unlock_page_cgroup_migrate(). And again, FILE_MAPPED just needs
lock/unlock_page_cgroup().

Thanks,
-Andrea
