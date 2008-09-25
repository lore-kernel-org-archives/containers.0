From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 4/8] bio-cgroup: Split the cgroup memory subsystem into
	two parts
Date: Thu, 25 Sep 2008 16:14:00 +0900
Message-ID: <20080925161400.602ddfdb.kamezawa.hiroyu__46401.0065691129$1222328005$gmane$org@jp.fujitsu.com>
References: <20080924.191135.226787109.ryov@valinux.co.jp>
	<20080924.191204.71103350.ryov@valinux.co.jp>
	<20080924.191234.104048747.ryov@valinux.co.jp>
	<20080924.191309.189710495.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080924.191309.189710495.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 24 Sep 2008 19:13:09 +0900 (JST)
Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:

> This patch splits the cgroup memory subsystem into two parts.
> One is for tracking pages to find out the owners. The other is
> for controlling how much amount of memory should be assigned to
> each cgroup.
> 
> With this patch, you can use the page tracking mechanism even if
> the memory subsystem is off.
> 
I posted new ones.
 - http://lkml.org/lkml/2008/9/25/33 
 (changes in page_cgroup) http://lkml.org/lkml/2008/9/25/56
(I'm not sure this gets Ack or Nack. but direction will not change.)

Then, please tell me if you have new troubles with new ones.
Or if you have requests.
Major changes are

  - page_cgroup.h is added.
  - lookup_page_cgroup(struct page*), lock_page_cgroup() etc.. is exported.
  - All page_cgroup are allocated at boot.
  - you can use atomic operation to modify page_cgroup->flags.

One concern from me to this bio_cgroup is that this increases size of
+#ifdef CONFIG_CGROUP_BIO
+	struct list_head blist;		/* for bio_cgroup page list */
+	struct bio_cgroup *bio_cgroup;
+#endif
struct page_cgroup...more 24bytes per 4096bytes.

Could you reduce this ? I think 8bytes per memcg is reasonable.
Can you move lru to bio itself ?

This makes page_cgroup to be 64bytes from 40bytes and makes it larger
than mem_map....
After bio_cgroup, page_cgroup, allocated at boot, size on my 48GB box 
will jump up.
480MB -> 760MB.

Thanks,
-Kame


> Based on 2.6.27-rc5-mm1
> Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> 
> diff -Ndupr linux-2.6.27-rc5-mm1.ioband/include/linux/memcontrol.h linux-2.6.27-rc5-mm1.cg0/include/linux/memcontrol.h
> --- linux-2.6.27-rc5-mm1.ioband/include/linux/memcontrol.h	2008-09-24 16:23:03.000000000 +0900
> +++ linux-2.6.27-rc5-mm1.cg0/include/linux/memcontrol.h	2008-09-24 16:34:34.000000000 +0900
> @@ -20,12 +20,62 @@
>  #ifndef _LINUX_MEMCONTROL_H
>  #define _LINUX_MEMCONTROL_H
>  
> +#include <linux/rcupdate.h>
> +#include <linux/mm.h>
> +#include <linux/smp.h>
> +#include <linux/bit_spinlock.h>
> +
>  struct mem_cgroup;
>  struct page_cgroup;
>  struct page;
>  struct mm_struct;
>  
> +#ifdef CONFIG_CGROUP_PAGE
> +/*
> + * We use the lower bit of the page->page_cgroup pointer as a bit spin
> + * lock.  We need to ensure that page->page_cgroup is at least two
> + * byte aligned (based on comments from Nick Piggin).  But since
> + * bit_spin_lock doesn't actually set that lock bit in a non-debug
> + * uniprocessor kernel, we should avoid setting it here too.
> + */
> +#define PAGE_CGROUP_LOCK_BIT    0x0
> +#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
> +#define PAGE_CGROUP_LOCK        (1 << PAGE_CGROUP_LOCK_BIT)
> +#else
> +#define PAGE_CGROUP_LOCK        0x0
> +#endif
> +
> +/*
> + * A page_cgroup page is associated with every page descriptor. The
> + * page_cgroup helps us identify information about the cgroup
> + */
> +struct page_cgroup {
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	struct list_head lru;		/* per cgroup LRU list */
> +	struct mem_cgroup *mem_cgroup;
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +	struct page *page;
> +	int flags;
> +};
> +#define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
> +#define PAGE_CGROUP_FLAG_ACTIVE	(0x2)	/* page is active in this cgroup */
> +#define PAGE_CGROUP_FLAG_FILE	(0x4)	/* page is file system backed */
> +#define PAGE_CGROUP_FLAG_UNEVICTABLE (0x8)	/* page is unevictableable */
> +
> +static inline void lock_page_cgroup(struct page *page)
> +{
> +	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
> +}
> +
> +static inline int try_lock_page_cgroup(struct page *page)
> +{
> +	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
> +}
> +
> +static inline void unlock_page_cgroup(struct page *page)
> +{
> +	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
> +}
>  
>  #define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
>  
> @@ -34,45 +84,15 @@ extern int mem_cgroup_charge(struct page
>  				gfp_t gfp_mask);
>  extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  					gfp_t gfp_mask);
> -extern void mem_cgroup_move_lists(struct page *page, enum lru_list lru);
>  extern void mem_cgroup_uncharge_page(struct page *page);
>  extern void mem_cgroup_uncharge_cache_page(struct page *page);
> -extern int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask);
> -
> -extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> -					struct list_head *dst,
> -					unsigned long *scanned, int order,
> -					int mode, struct zone *z,
> -					struct mem_cgroup *mem_cont,
> -					int active, int file);
> -extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
> -int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
> -
> -extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> -
> -#define mm_match_cgroup(mm, cgroup)	\
> -	((cgroup) == mem_cgroup_from_task((mm)->owner))
>  
>  extern int
>  mem_cgroup_prepare_migration(struct page *page, struct page *newpage);
>  extern void mem_cgroup_end_migration(struct page *page);
> +extern void page_cgroup_init(void);
>  
> -/*
> - * For memory reclaim.
> - */
> -extern int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem);
> -extern long mem_cgroup_reclaim_imbalance(struct mem_cgroup *mem);
> -
> -extern int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem);
> -extern void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem,
> -							int priority);
> -extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
> -							int priority);
> -
> -extern long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
> -					int priority, enum lru_list lru);
> -
> -#else /* CONFIG_CGROUP_MEM_RES_CTLR */
> +#else /* CONFIG_CGROUP_PAGE */
>  static inline void page_reset_bad_cgroup(struct page *page)
>  {
>  }
> @@ -102,6 +122,53 @@ static inline void mem_cgroup_uncharge_c
>  {
>  }
>  
> +static inline int
> +mem_cgroup_prepare_migration(struct page *page, struct page *newpage)
> +{
> +	return 0;
> +}
> +
> +static inline void mem_cgroup_end_migration(struct page *page)
> +{
> +}
> +#endif /* CONFIG_CGROUP_PAGE */
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +
> +extern void mem_cgroup_move_lists(struct page *page, enum lru_list lru);
> +extern int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask);
> +
> +extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> +					struct list_head *dst,
> +					unsigned long *scanned, int order,
> +					int mode, struct zone *z,
> +					struct mem_cgroup *mem_cont,
> +					int active, int file);
> +extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
> +int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
> +
> +extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> +
> +#define mm_match_cgroup(mm, cgroup)	\
> +	((cgroup) == mem_cgroup_from_task((mm)->owner))
> +
> +/*
> + * For memory reclaim.
> + */
> +extern int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem);
> +extern long mem_cgroup_reclaim_imbalance(struct mem_cgroup *mem);
> +
> +extern int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem);
> +extern void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem,
> +							int priority);
> +extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
> +							int priority);
> +
> +extern long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
> +					int priority, enum lru_list lru);
> +
> +#else /* CONFIG_CGROUP_MEM_RES_CTLR */
> +
>  static inline int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask)
>  {
>  	return 0;
> @@ -122,16 +189,6 @@ static inline int task_in_mem_cgroup(str
>  	return 1;
>  }
>  
> -static inline int
> -mem_cgroup_prepare_migration(struct page *page, struct page *newpage)
> -{
> -	return 0;
> -}
> -
> -static inline void mem_cgroup_end_migration(struct page *page)
> -{
> -}
> -
>  static inline int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
>  {
>  	return 0;
> @@ -163,7 +220,8 @@ static inline long mem_cgroup_calc_recla
>  {
>  	return 0;
>  }
> -#endif /* CONFIG_CGROUP_MEM_CONT */
> +
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
>  
>  #endif /* _LINUX_MEMCONTROL_H */
>  
> diff -Ndupr linux-2.6.27-rc5-mm1.ioband/include/linux/mm_types.h linux-2.6.27-rc5-mm1.cg0/include/linux/mm_types.h
> --- linux-2.6.27-rc5-mm1.ioband/include/linux/mm_types.h	2008-09-24 16:23:03.000000000 +0900
> +++ linux-2.6.27-rc5-mm1.cg0/include/linux/mm_types.h	2008-09-24 16:34:34.000000000 +0900
> @@ -92,7 +92,7 @@ struct page {
>  	void *virtual;			/* Kernel virtual address (NULL if
>  					   not kmapped, ie. highmem) */
>  #endif /* WANT_PAGE_VIRTUAL */
> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +#ifdef CONFIG_CGROUP_PAGE
>  	unsigned long page_cgroup;
>  #endif
>  
> diff -Ndupr linux-2.6.27-rc5-mm1.ioband/init/Kconfig linux-2.6.27-rc5-mm1.cg0/init/Kconfig
> --- linux-2.6.27-rc5-mm1.ioband/init/Kconfig	2008-09-24 16:23:03.000000000 +0900
> +++ linux-2.6.27-rc5-mm1.cg0/init/Kconfig	2008-09-24 16:34:35.000000000 +0900
> @@ -425,6 +425,10 @@ config CGROUP_MEMRLIMIT_CTLR
>  	  memory RSS and Page Cache control. Virtual address space control
>  	  is provided by this controller.
>  
> +config CGROUP_PAGE
> +	def_bool y
> +	depends on CGROUP_MEM_RES_CTLR
> +
>  config SYSFS_DEPRECATED
>  	bool
>  
> diff -Ndupr linux-2.6.27-rc5-mm1.ioband/mm/Makefile linux-2.6.27-rc5-mm1.cg0/mm/Makefile
> --- linux-2.6.27-rc5-mm1.ioband/mm/Makefile	2008-09-24 16:23:03.000000000 +0900
> +++ linux-2.6.27-rc5-mm1.cg0/mm/Makefile	2008-09-24 16:34:35.000000000 +0900
> @@ -34,6 +34,6 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
>  obj-$(CONFIG_MIGRATION) += migrate.o
>  obj-$(CONFIG_SMP) += allocpercpu.o
>  obj-$(CONFIG_QUICKLIST) += quicklist.o
> -obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
> +obj-$(CONFIG_CGROUP_PAGE) += memcontrol.o
>  obj-$(CONFIG_CGROUP_MEMRLIMIT_CTLR) += memrlimitcgroup.o
>  obj-$(CONFIG_KMEMTRACE) += kmemtrace.o
> diff -Ndupr linux-2.6.27-rc5-mm1.ioband/mm/memcontrol.c linux-2.6.27-rc5-mm1.cg0/mm/memcontrol.c
> --- linux-2.6.27-rc5-mm1.ioband/mm/memcontrol.c	2008-09-24 16:23:03.000000000 +0900
> +++ linux-2.6.27-rc5-mm1.cg0/mm/memcontrol.c	2008-09-24 16:34:35.000000000 +0900
> @@ -36,10 +36,25 @@
>  
>  #include <asm/uaccess.h>
>  
> -struct cgroup_subsys mem_cgroup_subsys __read_mostly;
> +enum charge_type {
> +	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
> +	MEM_CGROUP_CHARGE_TYPE_MAPPED,
> +	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
> +};
> +
> +static void __mem_cgroup_uncharge_common(struct page *, enum charge_type);
> +
>  static struct kmem_cache *page_cgroup_cache __read_mostly;
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +struct cgroup_subsys mem_cgroup_subsys __read_mostly;
>  #define MEM_CGROUP_RECLAIM_RETRIES	5
>  
> +static inline int mem_cgroup_disabled(void)
> +{
> +	return mem_cgroup_subsys.disabled;
> +}
> +
>  /*
>   * Statistics for memory cgroup.
>   */
> @@ -136,35 +151,6 @@ struct mem_cgroup {
>  };
>  static struct mem_cgroup init_mem_cgroup;
>  
> -/*
> - * We use the lower bit of the page->page_cgroup pointer as a bit spin
> - * lock.  We need to ensure that page->page_cgroup is at least two
> - * byte aligned (based on comments from Nick Piggin).  But since
> - * bit_spin_lock doesn't actually set that lock bit in a non-debug
> - * uniprocessor kernel, we should avoid setting it here too.
> - */
> -#define PAGE_CGROUP_LOCK_BIT 	0x0
> -#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
> -#define PAGE_CGROUP_LOCK 	(1 << PAGE_CGROUP_LOCK_BIT)
> -#else
> -#define PAGE_CGROUP_LOCK	0x0
> -#endif
> -
> -/*
> - * A page_cgroup page is associated with every page descriptor. The
> - * page_cgroup helps us identify information about the cgroup
> - */
> -struct page_cgroup {
> -	struct list_head lru;		/* per cgroup LRU list */
> -	struct page *page;
> -	struct mem_cgroup *mem_cgroup;
> -	int flags;
> -};
> -#define PAGE_CGROUP_FLAG_CACHE	   (0x1)	/* charged as cache */
> -#define PAGE_CGROUP_FLAG_ACTIVE    (0x2)	/* page is active in this cgroup */
> -#define PAGE_CGROUP_FLAG_FILE	   (0x4)	/* page is file system backed */
> -#define PAGE_CGROUP_FLAG_UNEVICTABLE (0x8)	/* page is unevictableable */
> -
>  static int page_cgroup_nid(struct page_cgroup *pc)
>  {
>  	return page_to_nid(pc->page);
> @@ -175,12 +161,6 @@ static enum zone_type page_cgroup_zid(st
>  	return page_zonenum(pc->page);
>  }
>  
> -enum charge_type {
> -	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
> -	MEM_CGROUP_CHARGE_TYPE_MAPPED,
> -	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
> -};
> -
>  /*
>   * Always modified under lru lock. Then, not necessary to preempt_disable()
>   */
> @@ -248,37 +228,6 @@ struct mem_cgroup *mem_cgroup_from_task(
>  				struct mem_cgroup, css);
>  }
>  
> -static inline int page_cgroup_locked(struct page *page)
> -{
> -	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
> -}
> -
> -static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
> -{
> -	VM_BUG_ON(!page_cgroup_locked(page));
> -	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
> -}
> -
> -struct page_cgroup *page_get_page_cgroup(struct page *page)
> -{
> -	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
> -}
> -
> -static void lock_page_cgroup(struct page *page)
> -{
> -	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
> -}
> -
> -static int try_lock_page_cgroup(struct page *page)
> -{
> -	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
> -}
> -
> -static void unlock_page_cgroup(struct page *page)
> -{
> -	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
> -}
> -
>  static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
>  			struct page_cgroup *pc)
>  {
> @@ -367,7 +316,7 @@ void mem_cgroup_move_lists(struct page *
>  	struct mem_cgroup_per_zone *mz;
>  	unsigned long flags;
>  
> -	if (mem_cgroup_subsys.disabled)
> +	if (mem_cgroup_disabled())
>  		return;
>  
>  	/*
> @@ -506,273 +455,6 @@ unsigned long mem_cgroup_isolate_pages(u
>  }
>  
>  /*
> - * Charge the memory controller for page usage.
> - * Return
> - * 0 if the charge was successful
> - * < 0 if the cgroup is over its limit
> - */
> -static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
> -				gfp_t gfp_mask, enum charge_type ctype,
> -				struct mem_cgroup *memcg)
> -{
> -	struct mem_cgroup *mem;
> -	struct page_cgroup *pc;
> -	unsigned long flags;
> -	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> -	struct mem_cgroup_per_zone *mz;
> -
> -	pc = kmem_cache_alloc(page_cgroup_cache, gfp_mask);
> -	if (unlikely(pc == NULL))
> -		goto err;
> -
> -	/*
> -	 * We always charge the cgroup the mm_struct belongs to.
> -	 * The mm_struct's mem_cgroup changes on task migration if the
> -	 * thread group leader migrates. It's possible that mm is not
> -	 * set, if so charge the init_mm (happens for pagecache usage).
> -	 */
> -	if (likely(!memcg)) {
> -		rcu_read_lock();
> -		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> -		/*
> -		 * For every charge from the cgroup, increment reference count
> -		 */
> -		css_get(&mem->css);
> -		rcu_read_unlock();
> -	} else {
> -		mem = memcg;
> -		css_get(&memcg->css);
> -	}
> -
> -	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
> -		if (!(gfp_mask & __GFP_WAIT))
> -			goto out;
> -
> -		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
> -			continue;
> -
> -		/*
> -		 * try_to_free_mem_cgroup_pages() might not give us a full
> -		 * picture of reclaim. Some pages are reclaimed and might be
> -		 * moved to swap cache or just unmapped from the cgroup.
> -		 * Check the limit again to see if the reclaim reduced the
> -		 * current usage of the cgroup before giving up
> -		 */
> -		if (res_counter_check_under_limit(&mem->res))
> -			continue;
> -
> -		if (!nr_retries--) {
> -			mem_cgroup_out_of_memory(mem, gfp_mask);
> -			goto out;
> -		}
> -	}
> -
> -	pc->mem_cgroup = mem;
> -	pc->page = page;
> -	/*
> -	 * If a page is accounted as a page cache, insert to inactive list.
> -	 * If anon, insert to active list.
> -	 */
> -	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE) {
> -		pc->flags = PAGE_CGROUP_FLAG_CACHE;
> -		if (page_is_file_cache(page))
> -			pc->flags |= PAGE_CGROUP_FLAG_FILE;
> -		else
> -			pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
> -	} else
> -		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
> -
> -	lock_page_cgroup(page);
> -	if (unlikely(page_get_page_cgroup(page))) {
> -		unlock_page_cgroup(page);
> -		res_counter_uncharge(&mem->res, PAGE_SIZE);
> -		css_put(&mem->css);
> -		kmem_cache_free(page_cgroup_cache, pc);
> -		goto done;
> -	}
> -	page_assign_page_cgroup(page, pc);
> -
> -	mz = page_cgroup_zoneinfo(pc);
> -	spin_lock_irqsave(&mz->lru_lock, flags);
> -	__mem_cgroup_add_list(mz, pc);
> -	spin_unlock_irqrestore(&mz->lru_lock, flags);
> -
> -	unlock_page_cgroup(page);
> -done:
> -	return 0;
> -out:
> -	css_put(&mem->css);
> -	kmem_cache_free(page_cgroup_cache, pc);
> -err:
> -	return -ENOMEM;
> -}
> -
> -int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
> -{
> -	if (mem_cgroup_subsys.disabled)
> -		return 0;
> -
> -	/*
> -	 * If already mapped, we don't have to account.
> -	 * If page cache, page->mapping has address_space.
> -	 * But page->mapping may have out-of-use anon_vma pointer,
> -	 * detecit it by PageAnon() check. newly-mapped-anon's page->mapping
> -	 * is NULL.
> -  	 */
> -	if (page_mapped(page) || (page->mapping && !PageAnon(page)))
> -		return 0;
> -	if (unlikely(!mm))
> -		mm = &init_mm;
> -	return mem_cgroup_charge_common(page, mm, gfp_mask,
> -				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
> -}
> -
> -int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> -				gfp_t gfp_mask)
> -{
> -	if (mem_cgroup_subsys.disabled)
> -		return 0;
> -
> -	/*
> -	 * Corner case handling. This is called from add_to_page_cache()
> -	 * in usual. But some FS (shmem) precharges this page before calling it
> -	 * and call add_to_page_cache() with GFP_NOWAIT.
> -	 *
> -	 * For GFP_NOWAIT case, the page may be pre-charged before calling
> -	 * add_to_page_cache(). (See shmem.c) check it here and avoid to call
> -	 * charge twice. (It works but has to pay a bit larger cost.)
> -	 */
> -	if (!(gfp_mask & __GFP_WAIT)) {
> -		struct page_cgroup *pc;
> -
> -		lock_page_cgroup(page);
> -		pc = page_get_page_cgroup(page);
> -		if (pc) {
> -			VM_BUG_ON(pc->page != page);
> -			VM_BUG_ON(!pc->mem_cgroup);
> -			unlock_page_cgroup(page);
> -			return 0;
> -		}
> -		unlock_page_cgroup(page);
> -	}
> -
> -	if (unlikely(!mm))
> -		mm = &init_mm;
> -
> -	return mem_cgroup_charge_common(page, mm, gfp_mask,
> -				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
> -}
> -
> -/*
> - * uncharge if !page_mapped(page)
> - */
> -static void
> -__mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
> -{
> -	struct page_cgroup *pc;
> -	struct mem_cgroup *mem;
> -	struct mem_cgroup_per_zone *mz;
> -	unsigned long flags;
> -
> -	if (mem_cgroup_subsys.disabled)
> -		return;
> -
> -	/*
> -	 * Check if our page_cgroup is valid
> -	 */
> -	lock_page_cgroup(page);
> -	pc = page_get_page_cgroup(page);
> -	if (unlikely(!pc))
> -		goto unlock;
> -
> -	VM_BUG_ON(pc->page != page);
> -
> -	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> -	    && ((pc->flags & PAGE_CGROUP_FLAG_CACHE)
> -		|| page_mapped(page)))
> -		goto unlock;
> -
> -	mz = page_cgroup_zoneinfo(pc);
> -	spin_lock_irqsave(&mz->lru_lock, flags);
> -	__mem_cgroup_remove_list(mz, pc);
> -	spin_unlock_irqrestore(&mz->lru_lock, flags);
> -
> -	page_assign_page_cgroup(page, NULL);
> -	unlock_page_cgroup(page);
> -
> -	mem = pc->mem_cgroup;
> -	res_counter_uncharge(&mem->res, PAGE_SIZE);
> -	css_put(&mem->css);
> -
> -	kmem_cache_free(page_cgroup_cache, pc);
> -	return;
> -unlock:
> -	unlock_page_cgroup(page);
> -}
> -
> -void mem_cgroup_uncharge_page(struct page *page)
> -{
> -	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_MAPPED);
> -}
> -
> -void mem_cgroup_uncharge_cache_page(struct page *page)
> -{
> -	VM_BUG_ON(page_mapped(page));
> -	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
> -}
> -
> -/*
> - * Before starting migration, account against new page.
> - */
> -int mem_cgroup_prepare_migration(struct page *page, struct page *newpage)
> -{
> -	struct page_cgroup *pc;
> -	struct mem_cgroup *mem = NULL;
> -	enum charge_type ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
> -	int ret = 0;
> -
> -	if (mem_cgroup_subsys.disabled)
> -		return 0;
> -
> -	lock_page_cgroup(page);
> -	pc = page_get_page_cgroup(page);
> -	if (pc) {
> -		mem = pc->mem_cgroup;
> -		css_get(&mem->css);
> -		if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
> -			ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> -	}
> -	unlock_page_cgroup(page);
> -	if (mem) {
> -		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
> -			ctype, mem);
> -		css_put(&mem->css);
> -	}
> -	return ret;
> -}
> -
> -/* remove redundant charge if migration failed*/
> -void mem_cgroup_end_migration(struct page *newpage)
> -{
> -	/*
> -	 * At success, page->mapping is not NULL.
> -	 * special rollback care is necessary when
> -	 * 1. at migration failure. (newpage->mapping is cleared in this case)
> -	 * 2. the newpage was moved but not remapped again because the task
> -	 *    exits and the newpage is obsolete. In this case, the new page
> -	 *    may be a swapcache. So, we just call mem_cgroup_uncharge_page()
> -	 *    always for avoiding mess. The  page_cgroup will be removed if
> -	 *    unnecessary. File cache pages is still on radix-tree. Don't
> -	 *    care it.
> -	 */
> -	if (!newpage->mapping)
> -		__mem_cgroup_uncharge_common(newpage,
> -					 MEM_CGROUP_CHARGE_TYPE_FORCE);
> -	else if (PageAnon(newpage))
> -		mem_cgroup_uncharge_page(newpage);
> -}
> -
> -/*
>   * A call to try to shrink memory usage under specified resource controller.
>   * This is typically used for page reclaiming for shmem for reducing side
>   * effect of page allocation from shmem, which is used by some mem_cgroup.
> @@ -783,7 +465,7 @@ int mem_cgroup_shrink_usage(struct mm_st
>  	int progress = 0;
>  	int retry = MEM_CGROUP_RECLAIM_RETRIES;
>  
> -	if (mem_cgroup_subsys.disabled)
> +	if (mem_cgroup_disabled())
>  		return 0;
>  	if (!mm)
>  		return 0;
> @@ -1106,7 +788,7 @@ mem_cgroup_create(struct cgroup_subsys *
>  
>  	if (unlikely((cont->parent) == NULL)) {
>  		mem = &init_mem_cgroup;
> -		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
> +		page_cgroup_init();
>  	} else {
>  		mem = mem_cgroup_alloc();
>  		if (!mem)
> @@ -1190,3 +872,324 @@ struct cgroup_subsys mem_cgroup_subsys =
>  	.attach = mem_cgroup_move_task,
>  	.early_init = 0,
>  };
> +
> +#else /* CONFIG_CGROUP_MEM_RES_CTLR */
> +
> +static inline int mem_cgroup_disabled(void)
> +{
> +	return 1;
> +}
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +
> +static inline int page_cgroup_locked(struct page *page)
> +{
> +	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
> +}
> +
> +static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
> +{
> +	VM_BUG_ON(!page_cgroup_locked(page));
> +	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
> +}
> +
> +struct page_cgroup *page_get_page_cgroup(struct page *page)
> +{
> +	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
> +}
> +
> +/*
> + * Charge the memory controller for page usage.
> + * Return
> + * 0 if the charge was successful
> + * < 0 if the cgroup is over its limit
> + */
> +static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
> +				gfp_t gfp_mask, enum charge_type ctype,
> +				struct mem_cgroup *memcg)
> +{
> +	struct page_cgroup *pc;
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	struct mem_cgroup *mem;
> +	unsigned long flags;
> +	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> +	struct mem_cgroup_per_zone *mz;
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +
> +	pc = kmem_cache_alloc(page_cgroup_cache, gfp_mask);
> +	if (unlikely(pc == NULL))
> +		goto err;
> +
> +	/*
> +	 * We always charge the cgroup the mm_struct belongs to.
> +	 * The mm_struct's mem_cgroup changes on task migration if the
> +	 * thread group leader migrates. It's possible that mm is not
> +	 * set, if so charge the init_mm (happens for pagecache usage).
> +	 */
> +	if (likely(!memcg)) {
> +		rcu_read_lock();
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> +		/*
> +		 * For every charge from the cgroup, increment reference count
> +		 */
> +		css_get(&mem->css);
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +		rcu_read_unlock();
> +	} else {
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +		mem = memcg;
> +		css_get(&memcg->css);
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +	}
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
> +		if (!(gfp_mask & __GFP_WAIT))
> +			goto out;
> +
> +		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
> +			continue;
> +
> +		/*
> +		 * try_to_free_mem_cgroup_pages() might not give us a full
> +		 * picture of reclaim. Some pages are reclaimed and might be
> +		 * moved to swap cache or just unmapped from the cgroup.
> +		 * Check the limit again to see if the reclaim reduced the
> +		 * current usage of the cgroup before giving up
> +		 */
> +		if (res_counter_check_under_limit(&mem->res))
> +			continue;
> +
> +		if (!nr_retries--) {
> +			mem_cgroup_out_of_memory(mem, gfp_mask);
> +			goto out;
> +		}
> +	}
> +	pc->mem_cgroup = mem;
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +
> +	pc->page = page;
> +	/*
> +	 * If a page is accounted as a page cache, insert to inactive list.
> +	 * If anon, insert to active list.
> +	 */
> +	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE) {
> +		pc->flags = PAGE_CGROUP_FLAG_CACHE;
> +		if (page_is_file_cache(page))
> +			pc->flags |= PAGE_CGROUP_FLAG_FILE;
> +		else
> +			pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
> +	} else
> +		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
> +
> +	lock_page_cgroup(page);
> +	if (unlikely(page_get_page_cgroup(page))) {
> +		unlock_page_cgroup(page);
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +		res_counter_uncharge(&mem->res, PAGE_SIZE);
> +		css_put(&mem->css);
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +		kmem_cache_free(page_cgroup_cache, pc);
> +		goto done;
> +	}
> +	page_assign_page_cgroup(page, pc);
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	mz = page_cgroup_zoneinfo(pc);
> +	spin_lock_irqsave(&mz->lru_lock, flags);
> +	__mem_cgroup_add_list(mz, pc);
> +	spin_unlock_irqrestore(&mz->lru_lock, flags);
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +
> +	unlock_page_cgroup(page);
> +done:
> +	return 0;
> +out:
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	css_put(&mem->css);
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +	kmem_cache_free(page_cgroup_cache, pc);
> +err:
> +	return -ENOMEM;
> +}
> +
> +int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
> +{
> +	if (mem_cgroup_disabled())
> +		return 0;
> +
> +	/*
> +	 * If already mapped, we don't have to account.
> +	 * If page cache, page->mapping has address_space.
> +	 * But page->mapping may have out-of-use anon_vma pointer,
> +	 * detecit it by PageAnon() check. newly-mapped-anon's page->mapping
> +	 * is NULL.
> +	 */
> +	if (page_mapped(page) || (page->mapping && !PageAnon(page)))
> +		return 0;
> +	if (unlikely(!mm))
> +		mm = &init_mm;
> +	return mem_cgroup_charge_common(page, mm, gfp_mask,
> +				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
> +}
> +
> +int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> +				gfp_t gfp_mask)
> +{
> +	if (mem_cgroup_disabled())
> +		return 0;
> +
> +	/*
> +	 * Corner case handling. This is called from add_to_page_cache()
> +	 * in usual. But some FS (shmem) precharges this page before calling it
> +	 * and call add_to_page_cache() with GFP_NOWAIT.
> +	 *
> +	 * For GFP_NOWAIT case, the page may be pre-charged before calling
> +	 * add_to_page_cache(). (See shmem.c) check it here and avoid to call
> +	 * charge twice. (It works but has to pay a bit larger cost.)
> +	 */
> +	if (!(gfp_mask & __GFP_WAIT)) {
> +		struct page_cgroup *pc;
> +
> +		lock_page_cgroup(page);
> +		pc = page_get_page_cgroup(page);
> +		if (pc) {
> +			VM_BUG_ON(pc->page != page);
> +			VM_BUG_ON(!pc->mem_cgroup);
> +			unlock_page_cgroup(page);
> +			return 0;
> +		}
> +		unlock_page_cgroup(page);
> +	}
> +
> +	if (unlikely(!mm))
> +		mm = &init_mm;
> +
> +	return mem_cgroup_charge_common(page, mm, gfp_mask,
> +				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
> +}
> +
> +/*
> + * uncharge if !page_mapped(page)
> + */
> +static void
> +__mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
> +{
> +	struct page_cgroup *pc;
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	struct mem_cgroup *mem;
> +	struct mem_cgroup_per_zone *mz;
> +	unsigned long flags;
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +
> +	if (mem_cgroup_disabled())
> +		return;
> +
> +	/*
> +	 * Check if our page_cgroup is valid
> +	 */
> +	lock_page_cgroup(page);
> +	pc = page_get_page_cgroup(page);
> +	if (unlikely(!pc))
> +		goto unlock;
> +
> +	VM_BUG_ON(pc->page != page);
> +
> +	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> +	    && ((pc->flags & PAGE_CGROUP_FLAG_CACHE)
> +		|| page_mapped(page)))
> +		goto unlock;
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	mz = page_cgroup_zoneinfo(pc);
> +	spin_lock_irqsave(&mz->lru_lock, flags);
> +	__mem_cgroup_remove_list(mz, pc);
> +	spin_unlock_irqrestore(&mz->lru_lock, flags);
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +
> +	page_assign_page_cgroup(page, NULL);
> +	unlock_page_cgroup(page);
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	mem = pc->mem_cgroup;
> +	res_counter_uncharge(&mem->res, PAGE_SIZE);
> +	css_put(&mem->css);
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +
> +	kmem_cache_free(page_cgroup_cache, pc);
> +	return;
> +unlock:
> +	unlock_page_cgroup(page);
> +}
> +
> +void mem_cgroup_uncharge_page(struct page *page)
> +{
> +	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_MAPPED);
> +}
> +
> +void mem_cgroup_uncharge_cache_page(struct page *page)
> +{
> +	VM_BUG_ON(page_mapped(page));
> +	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
> +}
> +
> +/*
> + * Before starting migration, account against new page.
> + */
> +int mem_cgroup_prepare_migration(struct page *page, struct page *newpage)
> +{
> +	struct page_cgroup *pc;
> +	struct mem_cgroup *mem = NULL;
> +	enum charge_type ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
> +	int ret = 0;
> +
> +	if (mem_cgroup_disabled())
> +		return 0;
> +
> +	lock_page_cgroup(page);
> +	pc = page_get_page_cgroup(page);
> +	if (pc) {
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +		mem = pc->mem_cgroup;
> +		css_get(&mem->css);
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +		if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
> +			ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> +	}
> +	unlock_page_cgroup(page);
> +	if (mem) {
> +		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
> +			ctype, mem);
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +		css_put(&mem->css);
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +	}
> +	return ret;
> +}
> +
> +/* remove redundant charge if migration failed*/
> +void mem_cgroup_end_migration(struct page *newpage)
> +{
> +	/*
> +	 * At success, page->mapping is not NULL.
> +	 * special rollback care is necessary when
> +	 * 1. at migration failure. (newpage->mapping is cleared in this case)
> +	 * 2. the newpage was moved but not remapped again because the task
> +	 *    exits and the newpage is obsolete. In this case, the new page
> +	 *    may be a swapcache. So, we just call mem_cgroup_uncharge_page()
> +	 *    always for avoiding mess. The  page_cgroup will be removed if
> +	 *    unnecessary. File cache pages is still on radix-tree. Don't
> +	 *    care it.
> +	 */
> +	if (!newpage->mapping)
> +		__mem_cgroup_uncharge_common(newpage,
> +					 MEM_CGROUP_CHARGE_TYPE_FORCE);
> +	else if (PageAnon(newpage))
> +		mem_cgroup_uncharge_page(newpage);
> +}
> +
> +void page_cgroup_init()
> +{
> +	if (!page_cgroup_cache)
> +		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
> +}
> 
