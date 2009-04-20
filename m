From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 3/9] bio-cgroup controller
Date: Mon, 20 Apr 2009 20:35:40 +0900 (JST)
Message-ID: <20090420.203540.104031006.ryov__14358.8696759709$1240227602$gmane$org@valinux.co.jp>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-4-git-send-email-righi.andrea@gmail.com>
	<20090417102214.GC3896@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090417102214.GC3896-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Balbir,

> > diff --git a/block/blk-ioc.c b/block/blk-ioc.c
> > index 012f065..ef8cac0 100644
> > --- a/block/blk-ioc.c
> > +++ b/block/blk-ioc.c
> > @@ -84,24 +84,28 @@ void exit_io_context(void)
> >  	}
> >  }
> > 
> > +void init_io_context(struct io_context *ioc)
> > +{
> > +	atomic_set(&ioc->refcount, 1);
> > +	atomic_set(&ioc->nr_tasks, 1);
> > +	spin_lock_init(&ioc->lock);
> > +  ioc->ioprio_changed = 0;
> > +	ioc->ioprio = 0;
> > +	ioc->last_waited = jiffies; /* doesn't matter... */
> > +	ioc->nr_batch_requests = 0; /* because this is 0 */
> > +	ioc->aic = NULL;
> > +	INIT_RADIX_TREE(&ioc->radix_root, GFP_ATOMIC | __GFP_HIGH);
> > +	INIT_HLIST_HEAD(&ioc->cic_list);
> > +	ioc->ioc_data = NULL;
> > +}
> > +
> >  struct io_context *alloc_io_context(gfp_t gfp_flags, int node)
> >  {
> >  	struct io_context *ret;
> > 
> >  	ret = kmem_cache_alloc_node(iocontext_cachep, gfp_flags, node);
> > -	if (ret) {
> > -		atomic_set(&ret->refcount, 1);
> > -		atomic_set(&ret->nr_tasks, 1);
> > -		spin_lock_init(&ret->lock);
> > -		ret->ioprio_changed = 0;
> > -		ret->ioprio = 0;
> > -		ret->last_waited = jiffies; /* doesn't matter... */
> > -		ret->nr_batch_requests = 0; /* because this is 0 */
> > -		ret->aic = NULL;
> > -		INIT_RADIX_TREE(&ret->radix_root, GFP_ATOMIC | __GFP_HIGH);
> > -		INIT_HLIST_HEAD(&ret->cic_list);
> > -		ret->ioc_data = NULL;
> > -	}
> > +	if (ret)
> > +		init_io_context(ret);
> >
> 
> Can you split this part of the patch out as a refactoring patch?

Yes, I'll do it.

> >  	return ret;
> >  }
> > diff --git a/fs/buffer.c b/fs/buffer.c
> > index 13edf7a..bc72150 100644
> > --- a/fs/buffer.c
> > +++ b/fs/buffer.c
> > @@ -36,6 +36,7 @@
> >  #include <linux/buffer_head.h>
> >  #include <linux/task_io_accounting_ops.h>
> >  #include <linux/bio.h>
> > +#include <linux/biotrack.h>
> >  #include <linux/notifier.h>
> >  #include <linux/cpu.h>
> >  #include <linux/bitops.h>
> > @@ -655,6 +656,7 @@ static void __set_page_dirty(struct page *page,
> >  	if (page->mapping) {	/* Race with truncate? */
> >  		WARN_ON_ONCE(warn && !PageUptodate(page));
> >  		account_page_dirtied(page, mapping);
> > +		bio_cgroup_reset_owner_pagedirty(page, current->mm);
> >  		radix_tree_tag_set(&mapping->page_tree,
> >  				page_index(page), PAGECACHE_TAG_DIRTY);
> >  	}
> > diff --git a/fs/direct-io.c b/fs/direct-io.c
> > index da258e7..ec42362 100644
> > --- a/fs/direct-io.c
> > +++ b/fs/direct-io.c
> > @@ -33,6 +33,7 @@
> >  #include <linux/err.h>
> >  #include <linux/blkdev.h>
> >  #include <linux/buffer_head.h>
> > +#include <linux/biotrack.h>
> >  #include <linux/rwsem.h>
> >  #include <linux/uio.h>
> >  #include <asm/atomic.h>
> > @@ -799,6 +800,7 @@ static int do_direct_IO(struct dio *dio)
> >  			ret = PTR_ERR(page);
> >  			goto out;
> >  		}
> > +		bio_cgroup_reset_owner(page, current->mm);
> > 
> >  		while (block_in_page < blocks_per_page) {
> >  			unsigned offset_in_page = block_in_page << blkbits;
> > diff --git a/include/linux/biotrack.h b/include/linux/biotrack.h
> > new file mode 100644
> > index 0000000..25b8810
> > --- /dev/null
> > +++ b/include/linux/biotrack.h
> > @@ -0,0 +1,95 @@
> > +#include <linux/cgroup.h>
> > +#include <linux/mm.h>
> > +#include <linux/page_cgroup.h>
> > +
> > +#ifndef _LINUX_BIOTRACK_H
> > +#define _LINUX_BIOTRACK_H
> > +
> > +#ifdef	CONFIG_CGROUP_BIO
> > +
> > +struct tsk_move_msg {
> > +	int old_id;
> > +	int new_id;
> > +	struct task_struct *tsk;
> > +};
> > +
> > +extern int register_biocgroup_notifier(struct notifier_block *nb);
> > +extern int unregister_biocgroup_notifier(struct notifier_block *nb);
> > +
> > +struct io_context;
> > +struct block_device;
> > +
> > +struct bio_cgroup {
> > +	struct cgroup_subsys_state css;
> > +	int id;
> 
> Can't css_id be used here?

The latest patch has already done it.

> > +	struct io_context *io_context;	/* default io_context */
> > +/*	struct radix_tree_root io_context_root; per device io_context */
> 
> Commented out code? Do you want to remove this.

No. This is a sample code to set io_contexts per cgroup.

> Comments? Docbook style would be nice for the functions below.

O.K. I'll do it.

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
> 
> Do we need the #if defined clause? Anyone using page_cgroup, but not
> list_head LRU needs to be explicitly covered when they come up.

How about to add a option like "CONFIG_CGROUP_PAGE_USE_LRU" ?

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
> 
> 
> Is this routine called with lock_page_cgroup() taken?  Otherwise
> what protects pc->bio_cgroup_id?

pc->bio_cgroup_id can be updated without any locks because an integer
type variable can be set a new value at once on modern CPUs.

> > +	/*
> > +	 * css_get(&bio->css) isn't called to increment the reference
> > +	 * count of this bio_cgroup "biog" so pc->bio_cgroup_id might turn
> > +	 * invalid even if this page is still active.
> > +	 * This approach is chosen to minimize the overhead.
> > +	 */
> > +	pc->bio_cgroup_id = biog->id;
> 
> What happens without ref count increase we delete the cgroup or css?

I know that the same ID could be reused, but it is not a big
problem because it is recovered slowly.
I think that a mechanism which makes it difficult to reuse the same
ID should be implemented.

> > +/*
> > + * Change the owner of a given page. This function is only effective for
> > + * pages in the pagecache.
> 
> Could you clarify pagecache? mapped/unmapped or both?

This function is effective for both mapped and unmapped pages. I'll
write it in the comment.

> > + */
> > +void bio_cgroup_reset_owner_pagedirty(struct page *page, struct mm_struct *mm)
> > +{
> > +	if (PageSwapCache(page) || PageAnon(page))
> > +		return;
> 
> Look at page_is_file_cache() depending on the answer above

Thank you for this information. I'll use it.

> > +/*
> > + * Assign "page" the same owner as "opage."
> > + */
> > +void bio_cgroup_copy_owner(struct page *npage, struct page *opage)
> > +{
> > +	struct page_cgroup *npc, *opc;
> > +
> > +	if (bio_cgroup_disabled())
> > +		return;
> > +	npc = lookup_page_cgroup(npage);
> > +	if (unlikely(!npc))
> > +		return;
> > +	opc = lookup_page_cgroup(opage);
> > +	if (unlikely(!opc))
> > +		return;
> > +
> > +	/*
> > +	 * Do this without any locks. The reason is the same as
> > +	 * bio_cgroup_reset_owner().
> > +	 */
> > +	npc->bio_cgroup_id = opc->bio_cgroup_id;
> 
> What protects npc and opc?

As the same reason mentioned above, bio_cgroup_id can be updated
without any locks, and npc and opc always point to page_cgroups.
An integer variable can be set a new value at once on a system which
can use RCU lock.

Thanks,
Ryo Tsuruta
