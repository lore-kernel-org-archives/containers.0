From: Takuya Yoshikawa <yoshikawa.takuya-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 3/9] bio-cgroup controller
Date: Fri, 17 Apr 2009 10:49:43 +0900
Message-ID: <49E7E037.9080004__37508.5672633306$1239932966$gmane$org@oss.ntt.co.jp>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-4-git-send-email-righi.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239740480-28125-4-git-send-email-righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

I have a few question.
   - I have not yet fully understood how your controller are using
     bio_cgroup. If my view is wrong please tell me.

o In my view, bio_cgroup's implementation strongly depends on
   page_cgoup's. Could you explain for what purpose does this
   functionality itself should be implemented as cgroup subsystem?
   Using page_cgoup and implementing tracking APIs is not enough?


 > +config CGROUP_BIO
 > +	bool "Block I/O cgroup subsystem"
 > +	depends on CGROUPS && BLOCK
 > +	select MM_OWNER
 > +	help
 > +	  Provides a Resource Controller which enables to track the onwner
 > +	  of every Block I/O requests.
 > +	  The information this subsystem provides can be used from any
 > +	  kind of module such as dm-ioband device mapper modules or
 > +	  the cfq-scheduler.

o I can understand this kind of information will be effective for io
   controllers but how about cfq-scheduler? Don't we need some changes to
   make cfq use this kind of information?


Thanks,
   Takuya Yoshikawa






Andrea Righi wrote:
> From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> 
> From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> 
> With writeback IO processed asynchronously by kernel threads (pdflush)
> the real writes to the underlying block devices can occur in a different
> IO context respect to the task that originally generated the dirty
> pages involved in the IO operation.
> 
> The controller bio-cgroup is used by io-throttle to track writeback IO
> and for properly apply throttling.
> 
> Also apply a patch by Gui Jianfeng to announce tasks moving in
> bio-cgroup groups.
> 
> See also: http://people.valinux.co.jp/~ryov/bio-cgroup
> 
> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> ---
>  block/blk-ioc.c               |   30 ++--
>  fs/buffer.c                   |    2 +
>  fs/direct-io.c                |    2 +
>  include/linux/biotrack.h      |   95 +++++++++++
>  include/linux/cgroup_subsys.h |    6 +
>  include/linux/iocontext.h     |    1 +
>  include/linux/memcontrol.h    |    6 +
>  include/linux/mmzone.h        |    4 +-
>  include/linux/page_cgroup.h   |   13 ++-
>  init/Kconfig                  |   15 ++
>  mm/Makefile                   |    4 +-
>  mm/biotrack.c                 |  349 +++++++++++++++++++++++++++++++++++++++++
>  mm/bounce.c                   |    2 +
>  mm/filemap.c                  |    2 +
>  mm/memcontrol.c               |    5 +
>  mm/memory.c                   |    5 +
>  mm/page-writeback.c           |    2 +
>  mm/page_cgroup.c              |   17 ++-
>  mm/swap_state.c               |    2 +
>  19 files changed, 536 insertions(+), 26 deletions(-)
>  create mode 100644 include/linux/biotrack.h
>  create mode 100644 mm/biotrack.c
> 
> diff --git a/block/blk-ioc.c b/block/blk-ioc.c
> index 012f065..ef8cac0 100644
> --- a/block/blk-ioc.c
> +++ b/block/blk-ioc.c
> @@ -84,24 +84,28 @@ void exit_io_context(void)
>  	}
>  }
>  
> +void init_io_context(struct io_context *ioc)
> +{
> +	atomic_set(&ioc->refcount, 1);
> +	atomic_set(&ioc->nr_tasks, 1);
> +	spin_lock_init(&ioc->lock);
> +	ioc->ioprio_changed = 0;
> +	ioc->ioprio = 0;
> +	ioc->last_waited = jiffies; /* doesn't matter... */
> +	ioc->nr_batch_requests = 0; /* because this is 0 */
> +	ioc->aic = NULL;
> +	INIT_RADIX_TREE(&ioc->radix_root, GFP_ATOMIC | __GFP_HIGH);
> +	INIT_HLIST_HEAD(&ioc->cic_list);
> +	ioc->ioc_data = NULL;
> +}
> +
>  struct io_context *alloc_io_context(gfp_t gfp_flags, int node)
>  {
>  	struct io_context *ret;
>  
>  	ret = kmem_cache_alloc_node(iocontext_cachep, gfp_flags, node);
> -	if (ret) {
> -		atomic_set(&ret->refcount, 1);
> -		atomic_set(&ret->nr_tasks, 1);
> -		spin_lock_init(&ret->lock);
> -		ret->ioprio_changed = 0;
> -		ret->ioprio = 0;
> -		ret->last_waited = jiffies; /* doesn't matter... */
> -		ret->nr_batch_requests = 0; /* because this is 0 */
> -		ret->aic = NULL;
> -		INIT_RADIX_TREE(&ret->radix_root, GFP_ATOMIC | __GFP_HIGH);
> -		INIT_HLIST_HEAD(&ret->cic_list);
> -		ret->ioc_data = NULL;
> -	}
> +	if (ret)
> +		init_io_context(ret);
>  
>  	return ret;
>  }
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 13edf7a..bc72150 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -36,6 +36,7 @@
>  #include <linux/buffer_head.h>
>  #include <linux/task_io_accounting_ops.h>
>  #include <linux/bio.h>
> +#include <linux/biotrack.h>
>  #include <linux/notifier.h>
>  #include <linux/cpu.h>
>  #include <linux/bitops.h>
> @@ -655,6 +656,7 @@ static void __set_page_dirty(struct page *page,
>  	if (page->mapping) {	/* Race with truncate? */
>  		WARN_ON_ONCE(warn && !PageUptodate(page));
>  		account_page_dirtied(page, mapping);
> +		bio_cgroup_reset_owner_pagedirty(page, current->mm);
>  		radix_tree_tag_set(&mapping->page_tree,
>  				page_index(page), PAGECACHE_TAG_DIRTY);
>  	}
> diff --git a/fs/direct-io.c b/fs/direct-io.c
> index da258e7..ec42362 100644
> --- a/fs/direct-io.c
> +++ b/fs/direct-io.c
> @@ -33,6 +33,7 @@
>  #include <linux/err.h>
>  #include <linux/blkdev.h>
>  #include <linux/buffer_head.h>
> +#include <linux/biotrack.h>
>  #include <linux/rwsem.h>
>  #include <linux/uio.h>
>  #include <asm/atomic.h>
> @@ -799,6 +800,7 @@ static int do_direct_IO(struct dio *dio)
>  			ret = PTR_ERR(page);
>  			goto out;
>  		}
> +		bio_cgroup_reset_owner(page, current->mm);
>  
>  		while (block_in_page < blocks_per_page) {
>  			unsigned offset_in_page = block_in_page << blkbits;
> diff --git a/include/linux/biotrack.h b/include/linux/biotrack.h
> new file mode 100644
> index 0000000..25b8810
> --- /dev/null
> +++ b/include/linux/biotrack.h
> @@ -0,0 +1,95 @@
> +#include <linux/cgroup.h>
> +#include <linux/mm.h>
> +#include <linux/page_cgroup.h>
> +
> +#ifndef _LINUX_BIOTRACK_H
> +#define _LINUX_BIOTRACK_H
> +
> +#ifdef	CONFIG_CGROUP_BIO
> +
> +struct tsk_move_msg {
> +	int old_id;
> +	int new_id;
> +	struct task_struct *tsk;
> +};
> +
> +extern int register_biocgroup_notifier(struct notifier_block *nb);
> +extern int unregister_biocgroup_notifier(struct notifier_block *nb);
> +
> +struct io_context;
> +struct block_device;
> +
> +struct bio_cgroup {
> +	struct cgroup_subsys_state css;
> +	int id;
> +	struct io_context *io_context;	/* default io_context */
> +/*	struct radix_tree_root io_context_root; per device io_context */
> +};
> +
> +static inline void __init_bio_page_cgroup(struct page_cgroup *pc)
> +{
> +	pc->bio_cgroup_id = 0;
> +}
> +
> +extern struct cgroup *get_cgroup_from_page(struct page *page);
> +extern void put_cgroup_from_page(struct page *page);
> +extern struct cgroup *bio_id_to_cgroup(int id);
> +
> +static inline int bio_cgroup_disabled(void)
> +{
> +	return bio_cgroup_subsys.disabled;
> +}
> +
> +extern void bio_cgroup_set_owner(struct page *page, struct mm_struct *mm);
> +extern void bio_cgroup_reset_owner(struct page *page, struct mm_struct *mm);
> +extern void bio_cgroup_reset_owner_pagedirty(struct page *page,
> +						 struct mm_struct *mm);
> +extern void bio_cgroup_copy_owner(struct page *page, struct page *opage);
> +
> +extern struct io_context *get_bio_cgroup_iocontext(struct bio *bio);
> +extern int get_bio_cgroup_id(struct bio *bio);
> +
> +#else	/* CONFIG_CGROUP_BIO */
> +
> +struct bio_cgroup;
> +
> +static inline void __init_bio_page_cgroup(struct page_cgroup *pc)
> +{
> +}
> +
> +static inline int bio_cgroup_disabled(void)
> +{
> +	return 1;
> +}
> +
> +static inline void bio_cgroup_set_owner(struct page *page, struct mm_struct *mm)
> +{
> +}
> +
> +static inline void bio_cgroup_reset_owner(struct page *page,
> +						struct mm_struct *mm)
> +{
> +}
> +
> +static inline void bio_cgroup_reset_owner_pagedirty(struct page *page,
> +						struct mm_struct *mm)
> +{
> +}
> +
> +static inline void bio_cgroup_copy_owner(struct page *page, struct page *opage)
> +{
> +}
> +
> +static inline struct io_context *get_bio_cgroup_iocontext(struct bio *bio)
> +{
> +	return NULL;
> +}
> +
> +static inline int get_bio_cgroup_id(struct bio *bio)
> +{
> +	return 0;
> +}
> +
> +#endif	/* CONFIG_CGROUP_BIO */
> +
> +#endif /* _LINUX_BIOTRACK_H */
> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
> index 9c8d31b..5df23f8 100644
> --- a/include/linux/cgroup_subsys.h
> +++ b/include/linux/cgroup_subsys.h
> @@ -43,6 +43,12 @@ SUBSYS(mem_cgroup)
>  
>  /* */
>  
> +#ifdef CONFIG_CGROUP_BIO
> +SUBSYS(bio_cgroup)
> +#endif
> +
> +/* */
> +
>  #ifdef CONFIG_CGROUP_DEVICE
>  SUBSYS(devices)
>  #endif
> diff --git a/include/linux/iocontext.h b/include/linux/iocontext.h
> index 08b987b..be37c27 100644
> --- a/include/linux/iocontext.h
> +++ b/include/linux/iocontext.h
> @@ -104,6 +104,7 @@ int put_io_context(struct io_context *ioc);
>  void exit_io_context(void);
>  struct io_context *get_io_context(gfp_t gfp_flags, int node);
>  struct io_context *alloc_io_context(gfp_t gfp_flags, int node);
> +void init_io_context(struct io_context *ioc);
>  void copy_io_context(struct io_context **pdst, struct io_context **psrc);
>  #else
>  static inline void exit_io_context(void)
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 18146c9..f3e0e64 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -37,6 +37,8 @@ struct mm_struct;
>   * (Of course, if memcg does memory allocation in future, GFP_KERNEL is sane.)
>   */
>  
> +extern void __init_mem_page_cgroup(struct page_cgroup *pc);
> +
>  extern int mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
>  				gfp_t gfp_mask);
>  /* for swap handling */
> @@ -120,6 +122,10 @@ extern bool mem_cgroup_oom_called(struct task_struct *task);
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct mem_cgroup;
>  
> +static inline void __init_mem_page_cgroup(struct page_cgroup *pc)
> +{
> +}
> +
>  static inline int mem_cgroup_newpage_charge(struct page *page,
>  					struct mm_struct *mm, gfp_t gfp_mask)
>  {
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 186ec6a..47a6f55 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -607,7 +607,7 @@ typedef struct pglist_data {
>  	int nr_zones;
>  #ifdef CONFIG_FLAT_NODE_MEM_MAP	/* means !SPARSEMEM */
>  	struct page *node_mem_map;
> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +#ifdef CONFIG_CGROUP_PAGE
>  	struct page_cgroup *node_page_cgroup;
>  #endif
>  #endif
> @@ -958,7 +958,7 @@ struct mem_section {
>  
>  	/* See declaration of similar field in struct zone */
>  	unsigned long *pageblock_flags;
> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +#ifdef CONFIG_CGROUP_PAGE
>  	/*
>  	 * If !SPARSEMEM, pgdat doesn't have page_cgroup pointer. We use
>  	 * section. (see memcontrol.h/page_cgroup.h about this.)
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 7339c7b..a7249bb 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -1,7 +1,7 @@
>  #ifndef __LINUX_PAGE_CGROUP_H
>  #define __LINUX_PAGE_CGROUP_H
>  
> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +#ifdef CONFIG_CGROUP_PAGE
>  #include <linux/bit_spinlock.h>
>  /*
>   * Page Cgroup can be considered as an extended mem_map.
> @@ -12,9 +12,16 @@
>   */
>  struct page_cgroup {
>  	unsigned long flags;
> -	struct mem_cgroup *mem_cgroup;
>  	struct page *page;
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	struct mem_cgroup *mem_cgroup;
> +#endif
> +#ifdef CONFIG_CGROUP_BIO
> +	int bio_cgroup_id;
> +#endif
> +#if defined(CONFIG_CGROUP_MEM_RES_CTLR) || defined(CONFIG_CGROUP_BIO)
>  	struct list_head lru;		/* per cgroup LRU list */
> +#endif
>  };
>  
>  void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
> @@ -71,7 +78,7 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
>  	bit_spin_unlock(PCG_LOCK, &pc->flags);
>  }
>  
> -#else /* CONFIG_CGROUP_MEM_RES_CTLR */
> +#else /* CONFIG_CGROUP_PAGE */
>  struct page_cgroup;
>  
>  static inline void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
> diff --git a/init/Kconfig b/init/Kconfig
> index 7be4d38..8f7b23c 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -606,8 +606,23 @@ config CGROUP_MEM_RES_CTLR_SWAP
>  	  Now, memory usage of swap_cgroup is 2 bytes per entry. If swap page
>  	  size is 4096bytes, 512k per 1Gbytes of swap.
>  
> +config CGROUP_BIO
> +	bool "Block I/O cgroup subsystem"
> +	depends on CGROUPS && BLOCK
> +	select MM_OWNER
> +	help
> +	  Provides a Resource Controller which enables to track the onwner
> +	  of every Block I/O requests.
> +	  The information this subsystem provides can be used from any
> +	  kind of module such as dm-ioband device mapper modules or
> +	  the cfq-scheduler.
> +
>  endif # CGROUPS
>  
> +config CGROUP_PAGE
> +	def_bool y
> +	depends on CGROUP_MEM_RES_CTLR || CGROUP_BIO
> +
>  config MM_OWNER
>  	bool
>  
> diff --git a/mm/Makefile b/mm/Makefile
> index ec73c68..a78a437 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -37,4 +37,6 @@ else
>  obj-$(CONFIG_SMP) += allocpercpu.o
>  endif
>  obj-$(CONFIG_QUICKLIST) += quicklist.o
> -obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
> +obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
> +obj-$(CONFIG_CGROUP_PAGE) += page_cgroup.o
> +obj-$(CONFIG_CGROUP_BIO) += biotrack.o
> diff --git a/mm/biotrack.c b/mm/biotrack.c
> new file mode 100644
> index 0000000..d3a35f1
> --- /dev/null
> +++ b/mm/biotrack.c
> @@ -0,0 +1,349 @@
> +/* biotrack.c - Block I/O Tracking
> + *
> + * Copyright (C) VA Linux Systems Japan, 2008
> + * Developed by Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/smp.h>
> +#include <linux/bit_spinlock.h>
> +#include <linux/idr.h>
> +#include <linux/blkdev.h>
> +#include <linux/biotrack.h>
> +
> +#define MOVETASK 0
> +static BLOCKING_NOTIFIER_HEAD(biocgroup_chain);
> +
> +int register_biocgroup_notifier(struct notifier_block *nb)
> +{
> +	return blocking_notifier_chain_register(&biocgroup_chain, nb);
> +}
> +EXPORT_SYMBOL(register_biocgroup_notifier);
> +
> +int unregister_biocgroup_notifier(struct notifier_block *nb)
> +{
> +	return blocking_notifier_chain_unregister(&biocgroup_chain, nb);
> +}
> +EXPORT_SYMBOL(unregister_biocgroup_notifier);
> +
> +/*
> + * The block I/O tracking mechanism is implemented on the cgroup memory
> + * controller framework. It helps to find the the owner of an I/O request
> + * because every I/O request has a target page and the owner of the page
> + * can be easily determined on the framework.
> + */
> +
> +/* Return the bio_cgroup that associates with a cgroup. */
> +static inline struct bio_cgroup *cgroup_bio(struct cgroup *cgrp)
> +{
> +	return container_of(cgroup_subsys_state(cgrp, bio_cgroup_subsys_id),
> +					struct bio_cgroup, css);
> +}
> +
> +/* Return the bio_cgroup that associates with a process. */
> +static inline struct bio_cgroup *bio_cgroup_from_task(struct task_struct *p)
> +{
> +	return container_of(task_subsys_state(p, bio_cgroup_subsys_id),
> +					struct bio_cgroup, css);
> +}
> +
> +static struct idr bio_cgroup_id;
> +static DEFINE_SPINLOCK(bio_cgroup_idr_lock);
> +static struct io_context default_bio_io_context;
> +static struct bio_cgroup default_bio_cgroup = {
> +	.id		= 0,
> +	.io_context	= &default_bio_io_context,
> +};
> +
> +/*
> + * This function is used to make a given page have the bio-cgroup id of
> + * the owner of this page.
> + */
> +void bio_cgroup_set_owner(struct page *page, struct mm_struct *mm)
> +{
> +	struct bio_cgroup *biog;
> +	struct page_cgroup *pc;
> +
> +	if (bio_cgroup_disabled())
> +		return;
> +	pc = lookup_page_cgroup(page);
> +	if (unlikely(!pc))
> +		return;
> +
> +	pc->bio_cgroup_id = 0;	/* 0: default bio_cgroup id */
> +	if (!mm)
> +		return;
> +	/*
> +	 * Locking "pc" isn't necessary here since the current process is
> +	 * the only one that can access the members related to bio_cgroup.
> +	 */
> +	rcu_read_lock();
> +	biog = bio_cgroup_from_task(rcu_dereference(mm->owner));
> +	if (unlikely(!biog))
> +		goto out;
> +	/*
> +	 * css_get(&bio->css) isn't called to increment the reference
> +	 * count of this bio_cgroup "biog" so pc->bio_cgroup_id might turn
> +	 * invalid even if this page is still active.
> +	 * This approach is chosen to minimize the overhead.
> +	 */
> +	pc->bio_cgroup_id = biog->id;
> +out:
> +	rcu_read_unlock();
> +}
> +
> +/*
> + * Change the owner of a given page if necessary.
> + */
> +void bio_cgroup_reset_owner(struct page *page, struct mm_struct *mm)
> +{
> +	/*
> +	 * A little trick:
> +	 * Just call bio_cgroup_set_owner() for pages which are already
> +	 * active since the bio_cgroup_id member of page_cgroup can be
> +	 * updated without any locks. This is because an integer type of
> +	 * variable can be set a new value at once on modern cpus.
> +	 */
> +	bio_cgroup_set_owner(page, mm);
> +}
> +
> +/*
> + * Change the owner of a given page. This function is only effective for
> + * pages in the pagecache.
> + */
> +void bio_cgroup_reset_owner_pagedirty(struct page *page, struct mm_struct *mm)
> +{
> +	if (PageSwapCache(page) || PageAnon(page))
> +		return;
> +	if (current->flags & PF_MEMALLOC)
> +		return;
> +
> +	bio_cgroup_reset_owner(page, mm);
> +}
> +
> +/*
> + * Assign "page" the same owner as "opage."
> + */
> +void bio_cgroup_copy_owner(struct page *npage, struct page *opage)
> +{
> +	struct page_cgroup *npc, *opc;
> +
> +	if (bio_cgroup_disabled())
> +		return;
> +	npc = lookup_page_cgroup(npage);
> +	if (unlikely(!npc))
> +		return;
> +	opc = lookup_page_cgroup(opage);
> +	if (unlikely(!opc))
> +		return;
> +
> +	/*
> +	 * Do this without any locks. The reason is the same as
> +	 * bio_cgroup_reset_owner().
> +	 */
> +	npc->bio_cgroup_id = opc->bio_cgroup_id;
> +}
> +
> +/* Create a new bio-cgroup. */
> +static struct cgroup_subsys_state *
> +bio_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cgrp)
> +{
> +	struct bio_cgroup *biog;
> +	struct io_context *ioc;
> +	int ret;
> +
> +	if (!cgrp->parent) {
> +		biog = &default_bio_cgroup;
> +		init_io_context(biog->io_context);
> +		/* Increment the referrence count not to be released ever. */
> +		atomic_inc(&biog->io_context->refcount);
> +		idr_init(&bio_cgroup_id);
> +		return &biog->css;
> +	}
> +
> +	biog = kzalloc(sizeof(*biog), GFP_KERNEL);
> +	ioc = alloc_io_context(GFP_KERNEL, -1);
> +	if (!ioc || !biog) {
> +		ret = -ENOMEM;
> +		goto out_err;
> +	}
> +	biog->io_context = ioc;
> +retry:
> +	if (!idr_pre_get(&bio_cgroup_id, GFP_KERNEL)) {
> +		ret = -EAGAIN;
> +		goto out_err;
> +	}
> +	spin_lock_irq(&bio_cgroup_idr_lock);
> +	ret = idr_get_new_above(&bio_cgroup_id, (void *)biog, 1, &biog->id);
> +	spin_unlock_irq(&bio_cgroup_idr_lock);
> +	if (ret == -EAGAIN)
> +		goto retry;
> +	else if (ret)
> +		goto out_err;
> +
> +	return &biog->css;
> +out_err:
> +	kfree(biog);
> +	if (ioc)
> +		put_io_context(ioc);
> +	return ERR_PTR(ret);
> +}
> +
> +/* Delete the bio-cgroup. */
> +static void bio_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
> +{
> +	struct bio_cgroup *biog = cgroup_bio(cgrp);
> +
> +	put_io_context(biog->io_context);
> +
> +	spin_lock_irq(&bio_cgroup_idr_lock);
> +	idr_remove(&bio_cgroup_id, biog->id);
> +	spin_unlock_irq(&bio_cgroup_idr_lock);
> +
> +	kfree(biog);
> +}
> +
> +static struct bio_cgroup *find_bio_cgroup(int id)
> +{
> +	struct bio_cgroup *biog;
> +	spin_lock_irq(&bio_cgroup_idr_lock);
> +	/*
> +	 * It might fail to find A bio-group associated with "id" since it
> +	 * is allowed to remove the bio-cgroup even when some of I/O requests
> +	 * this group issued haven't completed yet.
> +	 */
> +	biog = (struct bio_cgroup *)idr_find(&bio_cgroup_id, id);
> +	spin_unlock_irq(&bio_cgroup_idr_lock);
> +	return biog;
> +}
> +
> +struct cgroup *bio_id_to_cgroup(int id)
> +{
> +	struct bio_cgroup *biog;
> +
> +	biog = find_bio_cgroup(id);
> +	if (biog)
> +		return biog->css.cgroup;
> +
> +	return NULL;
> +}
> +
> +struct cgroup *get_cgroup_from_page(struct page *page)
> +{
> +	struct page_cgroup *pc;
> +	struct bio_cgroup *biog;
> +	struct cgroup *cgrp = NULL;
> +
> +	pc = lookup_page_cgroup(page);
> +	if (!pc)
> +		return NULL;
> +	lock_page_cgroup(pc);
> +	biog = find_bio_cgroup(pc->bio_cgroup_id);
> +	if (biog) {
> +		css_get(&biog->css);
> +		cgrp = biog->css.cgroup;
> +	}
> +	unlock_page_cgroup(pc);
> +	return cgrp;
> +}
> +
> +void put_cgroup_from_page(struct page *page)
> +{
> +	struct bio_cgroup *biog;
> +	struct page_cgroup *pc;
> +
> +	pc = lookup_page_cgroup(page);
> +	if (!pc)
> +		return;
> +	lock_page_cgroup(pc);
> +	biog = find_bio_cgroup(pc->bio_cgroup_id);
> +	if (biog)
> +		css_put(&biog->css);
> +	unlock_page_cgroup(pc);
> +}
> +
> +/* Determine the bio-cgroup id of a given bio. */
> +int get_bio_cgroup_id(struct bio *bio)
> +{
> +	struct page_cgroup *pc;
> +	struct page *page = bio_iovec_idx(bio, 0)->bv_page;
> +	int	id = 0;
> +
> +	pc = lookup_page_cgroup(page);
> +	if (pc)
> +		id = pc->bio_cgroup_id;
> +	return id;
> +}
> +EXPORT_SYMBOL(get_bio_cgroup_id);
> +
> +/* Determine the iocontext of the bio-cgroup that issued a given bio. */
> +struct io_context *get_bio_cgroup_iocontext(struct bio *bio)
> +{
> +	struct bio_cgroup *biog = NULL;
> +	struct io_context *ioc;
> +	int	id = 0;
> +
> +	id = get_bio_cgroup_id(bio);
> +	if (id)
> +		biog = find_bio_cgroup(id);
> +	if (!biog)
> +		biog = &default_bio_cgroup;
> +	ioc = biog->io_context;	/* default io_context for this cgroup */
> +	atomic_inc(&ioc->refcount);
> +	return ioc;
> +}
> +EXPORT_SYMBOL(get_bio_cgroup_iocontext);
> +
> +static u64 bio_id_read(struct cgroup *cgrp, struct cftype *cft)
> +{
> +	struct bio_cgroup *biog = cgroup_bio(cgrp);
> +	return (u64) biog->id;
> +}
> +
> +
> +static struct cftype bio_files[] = {
> +	{
> +		.name = "id",
> +		.read_u64 = bio_id_read,
> +	},
> +};
> +
> +static int bio_cgroup_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
> +{
> +	return cgroup_add_files(cgrp, ss, bio_files, ARRAY_SIZE(bio_files));
> +}
> +
> +static void bio_cgroup_attach(struct cgroup_subsys *ss,
> +			      struct cgroup *cont, struct cgroup *oldcont,
> +			      struct task_struct *tsk)
> +{
> +	struct tsk_move_msg tmm;
> +	struct bio_cgroup *old_biog, *new_biog;
> +
> +	old_biog = cgroup_bio(oldcont);
> +	new_biog = cgroup_bio(cont);
> +	tmm.old_id = old_biog->id;
> +	tmm.new_id = new_biog->id;
> +	tmm.tsk = tsk;
> +	blocking_notifier_call_chain(&biocgroup_chain, MOVETASK, &tmm);
> +}
> +
> +struct cgroup_subsys bio_cgroup_subsys = {
> +	.name		= "bio",
> +	.create		= bio_cgroup_create,
> +	.destroy	= bio_cgroup_destroy,
> +	.populate	= bio_cgroup_populate,
> +	.attach         = bio_cgroup_attach,
> +	.subsys_id	= bio_cgroup_subsys_id,
> +};
> +
> diff --git a/mm/bounce.c b/mm/bounce.c
> index e590272..1a01905 100644
> --- a/mm/bounce.c
> +++ b/mm/bounce.c
> @@ -14,6 +14,7 @@
>  #include <linux/hash.h>
>  #include <linux/highmem.h>
>  #include <linux/blktrace_api.h>
> +#include <linux/biotrack.h>
>  #include <trace/block.h>
>  #include <asm/tlbflush.h>
>  
> @@ -212,6 +213,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
>  		to->bv_len = from->bv_len;
>  		to->bv_offset = from->bv_offset;
>  		inc_zone_page_state(to->bv_page, NR_BOUNCE);
> +		bio_cgroup_copy_owner(to->bv_page, page);
>  
>  		if (rw == WRITE) {
>  			char *vto, *vfrom;
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 8bd4980..1ab32a2 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -33,6 +33,7 @@
>  #include <linux/cpuset.h>
>  #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
>  #include <linux/memcontrol.h>
> +#include <linux/biotrack.h>
>  #include <linux/mm_inline.h> /* for page_is_file_cache() */
>  #include "internal.h"
>  
> @@ -463,6 +464,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
>  					gfp_mask & GFP_RECLAIM_MASK);
>  	if (error)
>  		goto out;
> +	bio_cgroup_set_owner(page, current->mm);
>  
>  	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
>  	if (error == 0) {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e44fb0f..c25eb63 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2524,6 +2524,11 @@ struct cgroup_subsys mem_cgroup_subsys = {
>  	.use_id = 1,
>  };
>  
> +void __meminit __init_mem_page_cgroup(struct page_cgroup *pc)
> +{
> +	pc->mem_cgroup = NULL;
> +}
> +
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  
>  static int __init disable_swap_account(char *s)
> diff --git a/mm/memory.c b/mm/memory.c
> index cf6873e..7779e12 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -51,6 +51,7 @@
>  #include <linux/init.h>
>  #include <linux/writeback.h>
>  #include <linux/memcontrol.h>
> +#include <linux/biotrack.h>
>  #include <linux/mmu_notifier.h>
>  #include <linux/kallsyms.h>
>  #include <linux/swapops.h>
> @@ -2052,6 +2053,7 @@ gotten:
>  		 * thread doing COW.
>  		 */
>  		ptep_clear_flush_notify(vma, address, page_table);
> +		bio_cgroup_set_owner(new_page, mm);
>  		page_add_new_anon_rmap(new_page, vma, address);
>  		set_pte_at(mm, address, page_table, entry);
>  		update_mmu_cache(vma, address, entry);
> @@ -2497,6 +2499,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	flush_icache_page(vma, page);
>  	set_pte_at(mm, address, page_table, pte);
>  	page_add_anon_rmap(page, vma, address);
> +	bio_cgroup_reset_owner(page, mm);
>  	/* It's better to call commit-charge after rmap is established */
>  	mem_cgroup_commit_charge_swapin(page, ptr);
>  
> @@ -2559,6 +2562,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (!pte_none(*page_table))
>  		goto release;
>  	inc_mm_counter(mm, anon_rss);
> +	bio_cgroup_set_owner(page, mm);
>  	page_add_new_anon_rmap(page, vma, address);
>  	set_pte_at(mm, address, page_table, entry);
>  
> @@ -2711,6 +2715,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
>  		if (anon) {
>  			inc_mm_counter(mm, anon_rss);
> +			bio_cgroup_set_owner(page, mm);
>  			page_add_new_anon_rmap(page, vma, address);
>  		} else {
>  			inc_mm_counter(mm, file_rss);
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 30351f0..1379eb0 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -26,6 +26,7 @@
>  #include <linux/blkdev.h>
>  #include <linux/mpage.h>
>  #include <linux/rmap.h>
> +#include <linux/biotrack.h>
>  #include <linux/percpu.h>
>  #include <linux/notifier.h>
>  #include <linux/smp.h>
> @@ -1243,6 +1244,7 @@ int __set_page_dirty_nobuffers(struct page *page)
>  			BUG_ON(mapping2 != mapping);
>  			WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
>  			account_page_dirtied(page, mapping);
> +			bio_cgroup_reset_owner_pagedirty(page, current->mm);
>  			radix_tree_tag_set(&mapping->page_tree,
>  				page_index(page), PAGECACHE_TAG_DIRTY);
>  		}
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 791905c..f692ee2 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -9,13 +9,16 @@
>  #include <linux/vmalloc.h>
>  #include <linux/cgroup.h>
>  #include <linux/swapops.h>
> +#include <linux/memcontrol.h>
> +#include <linux/biotrack.h>
>  
>  static void __meminit
>  __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
>  {
>  	pc->flags = 0;
> -	pc->mem_cgroup = NULL;
>  	pc->page = pfn_to_page(pfn);
> +	__init_mem_page_cgroup(pc);
> +	__init_bio_page_cgroup(pc);
>  	INIT_LIST_HEAD(&pc->lru);
>  }
>  static unsigned long total_usage;
> @@ -74,7 +77,7 @@ void __init page_cgroup_init(void)
>  
>  	int nid, fail;
>  
> -	if (mem_cgroup_disabled())
> +	if (mem_cgroup_disabled() && bio_cgroup_disabled())
>  		return;
>  
>  	for_each_online_node(nid)  {
> @@ -83,12 +86,12 @@ void __init page_cgroup_init(void)
>  			goto fail;
>  	}
>  	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
> -	printk(KERN_INFO "please try cgroup_disable=memory option if you"
> +	printk(KERN_INFO "please try cgroup_disable=memory,bio option if you"
>  	" don't want\n");
>  	return;
>  fail:
>  	printk(KERN_CRIT "allocation of page_cgroup was failed.\n");
> -	printk(KERN_CRIT "please try cgroup_disable=memory boot option\n");
> +	printk(KERN_CRIT "please try cgroup_disable=memory,bio boot options\n");
>  	panic("Out of memory");
>  }
>  
> @@ -248,7 +251,7 @@ void __init page_cgroup_init(void)
>  	unsigned long pfn;
>  	int fail = 0;
>  
> -	if (mem_cgroup_disabled())
> +	if (mem_cgroup_disabled() && bio_cgroup_disabled())
>  		return;
>  
>  	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
> @@ -263,8 +266,8 @@ void __init page_cgroup_init(void)
>  		hotplug_memory_notifier(page_cgroup_callback, 0);
>  	}
>  	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
> -	printk(KERN_INFO "please try cgroup_disable=memory option if you don't"
> -	" want\n");
> +	printk(KERN_INFO
> +		"try cgroup_disable=memory,bio option if you don't want\n");
>  }
>  
>  void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 3ecea98..c7ad256 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -17,6 +17,7 @@
>  #include <linux/backing-dev.h>
>  #include <linux/pagevec.h>
>  #include <linux/migrate.h>
> +#include <linux/biotrack.h>
>  #include <linux/page_cgroup.h>
>  
>  #include <asm/pgtable.h>
> @@ -308,6 +309,7 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  		 */
>  		__set_page_locked(new_page);
>  		SetPageSwapBacked(new_page);
> +		bio_cgroup_set_owner(new_page, current->mm);
>  		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
>  		if (likely(!err)) {
>  			/*
