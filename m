From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/2] memcg: dirty pages instrumentation
Date: Mon, 22 Feb 2010 09:32:21 +0900
Message-ID: <20100222093221.eaaff1b4.kamezawa.hiroyu__9042.37246509201$1266821981$gmane$org@jp.fujitsu.com>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-3-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1266765525-30890-3-git-send-email-arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, 21 Feb 2010 16:18:45 +0100
Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:

> Apply the cgroup dirty pages accounting and limiting infrastructure to
> the opportune kernel functions.
> 
> Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>

I think there are design confusion with 1st patch.


> ---
>  fs/fuse/file.c      |    3 ++
>  fs/nfs/write.c      |    3 ++
>  fs/nilfs2/segment.c |    8 ++++-
>  mm/filemap.c        |    1 +
>  mm/page-writeback.c |   69 ++++++++++++++++++++++++++++++++++++--------------
>  mm/truncate.c       |    1 +
>  6 files changed, 63 insertions(+), 22 deletions(-)
> 
> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> index a9f5e13..357632a 100644
> --- a/fs/fuse/file.c
> +++ b/fs/fuse/file.c
> @@ -11,6 +11,7 @@
>  #include <linux/pagemap.h>
>  #include <linux/slab.h>
>  #include <linux/kernel.h>
> +#include <linux/memcontrol.h>
>  #include <linux/sched.h>
>  #include <linux/module.h>
>  
> @@ -1129,6 +1130,7 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
>  
>  	list_del(&req->writepages_entry);
>  	dec_bdi_stat(bdi, BDI_WRITEBACK);
> +	mem_cgroup_charge_dirty(req->pages[0], NR_WRITEBACK_TEMP, -1);

Here, you account dirty pages to the memcg which page_cgroup belongs to.
Not to the root cgroup of hierarchical accouning.


>  	dec_zone_page_state(req->pages[0], NR_WRITEBACK_TEMP);
>  	bdi_writeout_inc(bdi);
>  	wake_up(&fi->page_waitq);
> @@ -1240,6 +1242,7 @@ static int fuse_writepage_locked(struct page *page)
>  	req->inode = inode;
>  
>  	inc_bdi_stat(mapping->backing_dev_info, BDI_WRITEBACK);
> +	mem_cgroup_charge_dirty(tmp_page, NR_WRITEBACK_TEMP, 1);

here too....

>  	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
>  	end_page_writeback(page);
>  
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index d63d964..3d9de01 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -439,6 +439,7 @@ nfs_mark_request_commit(struct nfs_page *req)
>  			req->wb_index,
>  			NFS_PAGE_TAG_COMMIT);
>  	spin_unlock(&inode->i_lock);
> +	mem_cgroup_charge_dirty(req->wb_page, NR_UNSTABLE_NFS, 1);
>  	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
>  	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
>  	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> @@ -450,6 +451,7 @@ nfs_clear_request_commit(struct nfs_page *req)
>  	struct page *page = req->wb_page;
>  
>  	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
> +		mem_cgroup_charge_dirty(page, NR_UNSTABLE_NFS, -1);
>  		dec_zone_page_state(page, NR_UNSTABLE_NFS);
>  		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
>  		return 1;
> @@ -1320,6 +1322,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
>  		req = nfs_list_entry(head->next);
>  		nfs_list_remove_request(req);
>  		nfs_mark_request_commit(req);
> +		mem_cgroup_charge_dirty(req->wb_page, NR_UNSTABLE_NFS, -1);
>  		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
>  		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
>  				BDI_RECLAIMABLE);
> diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
> index 105b508..b9ffac5 100644
> --- a/fs/nilfs2/segment.c
> +++ b/fs/nilfs2/segment.c
> @@ -1660,8 +1660,10 @@ nilfs_copy_replace_page_buffers(struct page *page, struct list_head *out)
>  	} while (bh = bh->b_this_page, bh2 = bh2->b_this_page, bh != head);
>  	kunmap_atomic(kaddr, KM_USER0);
>  
> -	if (!TestSetPageWriteback(clone_page))
> +	if (!TestSetPageWriteback(clone_page)) {
> +		mem_cgroup_charge_dirty(clone_page, NR_WRITEBACK, 1);
>  		inc_zone_page_state(clone_page, NR_WRITEBACK);
> +	}
>  	unlock_page(clone_page);
>  
>  	return 0;
> @@ -1788,8 +1790,10 @@ static void __nilfs_end_page_io(struct page *page, int err)
>  	}
>  
>  	if (buffer_nilfs_allocated(page_buffers(page))) {
> -		if (TestClearPageWriteback(page))
> +		if (TestClearPageWriteback(page)) {
> +			mem_cgroup_charge_dirty(clone_page, NR_WRITEBACK, -1);
>  			dec_zone_page_state(page, NR_WRITEBACK);
> +		}
>  	} else
>  		end_page_writeback(page);
>  }
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 698ea80..c19d809 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -135,6 +135,7 @@ void __remove_from_page_cache(struct page *page)
>  	 * having removed the page entirely.
>  	 */
>  	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> +		mem_cgroup_charge_dirty(page, NR_FILE_DIRTY, -1);
>  		dec_zone_page_state(page, NR_FILE_DIRTY);
>  		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
>  	}
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 0b19943..c9ff1cd 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -137,10 +137,11 @@ static struct prop_descriptor vm_dirties;
>   */
>  static int calc_period_shift(void)
>  {
> -	unsigned long dirty_total;
> +	unsigned long dirty_total, dirty_bytes;
>  
> -	if (vm_dirty_bytes)
> -		dirty_total = vm_dirty_bytes / PAGE_SIZE;
> +	dirty_bytes = mem_cgroup_dirty_bytes();

Here, you get dirty pages of a memcg which the task belongs to.
Not from root memcg of the memcg-hierarchy which task belogns to.

> +	if (dirty_bytes)
> +		dirty_total = dirty_bytes / PAGE_SIZE;
>  	else
>  		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
>  				100;
> @@ -406,14 +407,20 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
>   */
>  unsigned long determine_dirtyable_memory(void)
>  {
> -	unsigned long x;
> -
> -	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
> -
> +	unsigned long memcg_memory, memory;
> +
> +	memory = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
> +	memcg_memory = mem_cgroup_page_state(MEMCG_NR_FREE_PAGES);
> +	if (memcg_memory > 0) {
> +		memcg_memory +=
> +			mem_cgroup_page_state(MEMCG_NR_RECLAIMABLE_PAGES);
> +		if (memcg_memory < memory)
> +			return memcg_memory;
> +	}
Here, you get local usage.


>  	if (!vm_highmem_is_dirtyable)
> -		x -= highmem_dirtyable_memory(x);
> +		memory -= highmem_dirtyable_memory(memory);
>  
> -	return x + 1;	/* Ensure that we never return 0 */
> +	return memory + 1;	/* Ensure that we never return 0 */
>  }
>  
>  void
> @@ -421,12 +428,13 @@ get_dirty_limits(unsigned long *pbackground, unsigned long *pdirty,
>  		 unsigned long *pbdi_dirty, struct backing_dev_info *bdi)
>  {
>  	unsigned long background;
> -	unsigned long dirty;
> +	unsigned long dirty, dirty_bytes;
>  	unsigned long available_memory = determine_dirtyable_memory();
>  	struct task_struct *tsk;
>  
> -	if (vm_dirty_bytes)
> -		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> +	dirty_bytes = mem_cgroup_dirty_bytes();
> +	if (dirty_bytes)
> +		dirty = DIV_ROUND_UP(dirty_bytes, PAGE_SIZE);
>  	else {
>  		int dirty_ratio;

you use local value. But, if hierarchila accounting used, memcg->dirty_bytes
should be got from root-of-hierarchy memcg.

I have no objection if you add a pointer as
	memcg->subhierarchy_root
to get root of hierarchical accounting. But please check problem of hierarchy, again.

Thanks,
-Kame

>  
> @@ -505,9 +513,17 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		get_dirty_limits(&background_thresh, &dirty_thresh,
>  				&bdi_thresh, bdi);
>  
> -		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> +		nr_reclaimable = mem_cgroup_page_state(MEMCG_NR_FILE_DIRTY);
> +		if (nr_reclaimable == 0) {
> +			nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
>  					global_page_state(NR_UNSTABLE_NFS);
> -		nr_writeback = global_page_state(NR_WRITEBACK);
> +			nr_writeback = global_page_state(NR_WRITEBACK);
> +		} else {
> +			nr_reclaimable +=
> +				mem_cgroup_page_state(MEMCG_NR_UNSTABLE_NFS);
> +			nr_writeback =
> +				mem_cgroup_page_state(MEMCG_NR_WRITEBACK);
> +		}
>  
>  		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
>  		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
> @@ -660,6 +676,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>  	unsigned long dirty_thresh;
>  
>          for ( ; ; ) {
> +		unsigned long dirty;
> +
>  		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
>  
>                  /*
> @@ -668,10 +686,15 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>                   */
>                  dirty_thresh += dirty_thresh / 10;      /* wheeee... */
>  
> -                if (global_page_state(NR_UNSTABLE_NFS) +
> -			global_page_state(NR_WRITEBACK) <= dirty_thresh)
> -                        	break;
> -                congestion_wait(BLK_RW_ASYNC, HZ/10);
> +		dirty = mem_cgroup_page_state(MEMCG_NR_WRITEBACK);
> +		if (dirty < 0)
> +			dirty = global_page_state(NR_UNSTABLE_NFS) +
> +				global_page_state(NR_WRITEBACK);
> +		else
> +			dirty += mem_cgroup_page_state(MEMCG_NR_UNSTABLE_NFS);
> +		if (dirty <= dirty_thresh)
> +			break;
> +		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		/*
>  		 * The caller might hold locks which can prevent IO completion
> @@ -1078,6 +1101,7 @@ int __set_page_dirty_no_writeback(struct page *page)
>  void account_page_dirtied(struct page *page, struct address_space *mapping)
>  {
>  	if (mapping_cap_account_dirty(mapping)) {
> +		mem_cgroup_charge_dirty(page, NR_FILE_DIRTY, 1);
>  		__inc_zone_page_state(page, NR_FILE_DIRTY);
>  		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
>  		task_dirty_inc(current);
> @@ -1253,6 +1277,7 @@ int clear_page_dirty_for_io(struct page *page)
>  		 * for more comments.
>  		 */
>  		if (TestClearPageDirty(page)) {
> +			mem_cgroup_charge_dirty(page, NR_FILE_DIRTY, -1);
>  			dec_zone_page_state(page, NR_FILE_DIRTY);
>  			dec_bdi_stat(mapping->backing_dev_info,
>  					BDI_RECLAIMABLE);
> @@ -1288,8 +1313,10 @@ int test_clear_page_writeback(struct page *page)
>  	} else {
>  		ret = TestClearPageWriteback(page);
>  	}
> -	if (ret)
> +	if (ret) {
> +		mem_cgroup_charge_dirty(page, NR_WRITEBACK, -1);
>  		dec_zone_page_state(page, NR_WRITEBACK);
> +	}
>  	return ret;
>  }
>  
> @@ -1319,8 +1346,10 @@ int test_set_page_writeback(struct page *page)
>  	} else {
>  		ret = TestSetPageWriteback(page);
>  	}
> -	if (!ret)
> +	if (!ret) {
> +		mem_cgroup_charge_dirty(page, NR_WRITEBACK, 1);
>  		inc_zone_page_state(page, NR_WRITEBACK);
> +	}
>  	return ret;
>  
>  }
> diff --git a/mm/truncate.c b/mm/truncate.c
> index e87e372..f44e370 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -73,6 +73,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
>  	if (TestClearPageDirty(page)) {
>  		struct address_space *mapping = page->mapping;
>  		if (mapping && mapping_cap_account_dirty(mapping)) {
> +			mem_cgroup_charge_dirty(page, NR_FILE_DIRTY, -1);
>  			dec_zone_page_state(page, NR_FILE_DIRTY);
>  			dec_bdi_stat(mapping->backing_dev_info,
>  					BDI_RECLAIMABLE);
> -- 
> 1.6.3.3
> 
> 
