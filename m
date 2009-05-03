From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 6/7] io-throttle instrumentation
Date: Sun,  3 May 2009 13:36:22 +0200
Message-ID: <1241350583-9871-7-git-send-email-righi.andrea__3703.18636200881$1241351792$gmane$org@gmail.com>
References: <1241350583-9871-1-git-send-email-righi.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1241350583-9871-1-git-send-email-righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, tytso-3s7WtUTddSA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Apply the io-throttle control and page tracking to the opportune kernel
functions.

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/blk-core.c      |    8 ++++++++
 fs/aio.c              |   12 ++++++++++++
 fs/block_dev.c        |    3 +++
 fs/buffer.c           |    2 ++
 fs/direct-io.c        |    3 +++
 include/linux/fs.h    |    4 ++++
 include/linux/sched.h |    8 ++++++++
 kernel/fork.c         |    8 ++++++++
 mm/bounce.c           |    2 ++
 mm/filemap.c          |    2 ++
 mm/page-writeback.c   |   13 +++++++++++++
 mm/readahead.c        |    3 +++
 12 files changed, 68 insertions(+), 0 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 2998fe3..a9689df 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -26,6 +26,7 @@
 #include <linux/swap.h>
 #include <linux/writeback.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/blktrace_api.h>
 #include <linux/fault-inject.h>
 #include <trace/block.h>
@@ -1549,11 +1550,16 @@ void submit_bio(int rw, struct bio *bio)
 	 * go through the normal accounting stuff before submission.
 	 */
 	if (bio_has_data(bio)) {
+		unsigned long sleep = 0;
+
 		if (rw & WRITE) {
 			count_vm_events(PGPGOUT, count);
+			sleep = cgroup_io_throttle(bio,
+					bio->bi_bdev, bio->bi_size);
 		} else {
 			task_io_account_read(bio->bi_size);
 			count_vm_events(PGPGIN, count);
+			cgroup_io_throttle(NULL, bio->bi_bdev, bio->bi_size);
 		}
 
 		if (unlikely(block_dump)) {
@@ -1564,6 +1570,8 @@ void submit_bio(int rw, struct bio *bio)
 				(unsigned long long)bio->bi_sector,
 				bdevname(bio->bi_bdev, b));
 		}
+		if (sleep && !iothrottle_make_request(bio, jiffies + sleep))
+			return;
 	}
 
 	generic_make_request(bio);
diff --git a/fs/aio.c b/fs/aio.c
index 76da125..ab6c457 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -22,6 +22,7 @@
 #include <linux/sched.h>
 #include <linux/fs.h>
 #include <linux/file.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
 #include <linux/slab.h>
@@ -1587,6 +1588,7 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 {
 	struct kiocb *req;
 	struct file *file;
+	struct block_device *bdev;
 	ssize_t ret;
 
 	/* enforce forwards compatibility on users */
@@ -1609,6 +1611,14 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 	if (unlikely(!file))
 		return -EBADF;
 
+	/* check if we're exceeding the IO throttling limits */
+	bdev = as_to_bdev(file->f_mapping);
+	ret = cgroup_io_throttle(NULL, bdev, 0);
+	if (unlikely(ret)) {
+		fput(file);
+		return -EAGAIN;
+	}
+
 	req = aio_get_req(ctx);		/* returns with 2 references to req */
 	if (unlikely(!req)) {
 		fput(file);
@@ -1652,12 +1662,14 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 		goto out_put_req;
 
 	spin_lock_irq(&ctx->ctx_lock);
+	set_in_aio();
 	aio_run_iocb(req);
 	if (!list_empty(&ctx->run_list)) {
 		/* drain the run list */
 		while (__aio_run_iocbs(ctx))
 			;
 	}
+	unset_in_aio();
 	spin_unlock_irq(&ctx->ctx_lock);
 	aio_put_req(req);	/* drop extra ref to req */
 	return 0;
diff --git a/fs/block_dev.c b/fs/block_dev.c
index f45dbc1..21d1adf 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -431,6 +431,9 @@ static void init_once(void *foo)
 #ifdef CONFIG_SYSFS
 	INIT_LIST_HEAD(&bdev->bd_holder_list);
 #endif
+#ifdef CGROUP_IO_THROTTLE
+	bdev->last_access = jiffies;
+#endif
 	inode_init_once(&ei->vfs_inode);
 	/* Initialize mutex for freeze. */
 	mutex_init(&bdev->bd_fsfreeze_mutex);
diff --git a/fs/buffer.c b/fs/buffer.c
index aed2977..ecdcff5 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -36,6 +36,7 @@
 #include <linux/buffer_head.h>
 #include <linux/task_io_accounting_ops.h>
 #include <linux/bio.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/notifier.h>
 #include <linux/cpu.h>
 #include <linux/bitops.h>
@@ -668,6 +669,7 @@ static void __set_page_dirty(struct page *page,
 	if (page->mapping) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
 		account_page_dirtied(page, mapping);
+		iothrottle_set_pagedirty_owner(page, current->mm);
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 	}
diff --git a/fs/direct-io.c b/fs/direct-io.c
index 05763bb..1b304b6 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -28,6 +28,7 @@
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/bio.h>
 #include <linux/wait.h>
 #include <linux/err.h>
@@ -340,7 +341,9 @@ static void dio_bio_submit(struct dio *dio)
 	if (dio->is_async && dio->rw == READ)
 		bio_set_pages_dirty(bio);
 
+	set_in_dio();
 	submit_bio(dio->rw, bio);
+	unset_in_dio();
 
 	dio->bio = NULL;
 	dio->boundary = 0;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 5bed436..701fc72 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -656,6 +656,10 @@ struct block_device {
 	struct gendisk *	bd_disk;
 	struct list_head	bd_list;
 	struct backing_dev_info *bd_inode_backing_dev_info;
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+	unsigned int last_access;
+	unsigned int last_io_ticks;
+#endif
 	/*
 	 * Private data.  You must have bd_claim'ed the block_device
 	 * to use this.  NOTE:  bd_claim allows an owner to claim
diff --git a/include/linux/sched.h b/include/linux/sched.h
index b4c38bc..3294430 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1356,6 +1356,14 @@ struct task_struct {
 	unsigned long ptrace_message;
 	siginfo_t *last_siginfo; /* For ptrace use.  */
 	struct task_io_accounting ioac;
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+	atomic_t in_aio;
+	atomic_t in_dio;
+	unsigned long long io_throttle_bw_cnt;
+	unsigned long long io_throttle_bw_sleep;
+	unsigned long long io_throttle_iops_cnt;
+	unsigned long long io_throttle_iops_sleep;
+#endif
 #if defined(CONFIG_TASK_XACCT)
 	u64 acct_rss_mem1;	/* accumulated rss usage */
 	u64 acct_vm_mem1;	/* accumulated virtual memory usage */
diff --git a/kernel/fork.c b/kernel/fork.c
index b9e2edd..7b4d991 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1043,6 +1043,14 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	task_io_accounting_init(&p->ioac);
 	acct_clear_integrals(p);
 
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+	atomic_set(&p->in_aio, 0);
+	atomic_set(&p->in_dio, 0);
+	p->io_throttle_bw_cnt = 0;
+	p->io_throttle_bw_sleep = 0;
+	p->io_throttle_iops_cnt = 0;
+	p->io_throttle_iops_sleep = 0;
+#endif
 	posix_cpu_timers_init(p);
 
 	p->lock_depth = -1;		/* -1 = no lock */
diff --git a/mm/bounce.c b/mm/bounce.c
index e590272..80bf52c 100644
--- a/mm/bounce.c
+++ b/mm/bounce.c
@@ -10,6 +10,7 @@
 #include <linux/pagemap.h>
 #include <linux/mempool.h>
 #include <linux/blkdev.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/init.h>
 #include <linux/hash.h>
 #include <linux/highmem.h>
@@ -212,6 +213,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 		to->bv_len = from->bv_len;
 		to->bv_offset = from->bv_offset;
 		inc_zone_page_state(to->bv_page, NR_BOUNCE);
+		iothrottle_copy_page_owner(to->bv_page, page);
 
 		if (rw == WRITE) {
 			char *vto, *vfrom;
diff --git a/mm/filemap.c b/mm/filemap.c
index 379ff0b..5498d1d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -28,6 +28,7 @@
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 #include <linux/blkdev.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/cpuset.h>
@@ -464,6 +465,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 					gfp_mask & GFP_RECLAIM_MASK);
 	if (error)
 		goto out;
+	iothrottle_set_page_owner(page, current->mm);
 
 	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error == 0) {
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 30351f0..90cd65a 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -24,6 +24,7 @@
 #include <linux/backing-dev.h>
 #include <linux/task_io_accounting_ops.h>
 #include <linux/blkdev.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/mpage.h>
 #include <linux/rmap.h>
 #include <linux/percpu.h>
@@ -626,12 +627,23 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 	static DEFINE_PER_CPU(unsigned long, ratelimits) = 0;
 	unsigned long ratelimit;
 	unsigned long *p;
+	struct block_device *bdev = as_to_bdev(mapping);
 
 	ratelimit = ratelimit_pages;
 	if (mapping->backing_dev_info->dirty_exceeded)
 		ratelimit = 8;
 
 	/*
+	 * Just check if we've exceeded cgroup IO limits, but do not account
+	 * anything here because we're not actually doing IO at this stage.
+	 *
+	 * We just want to stop to dirty additional pages in the system,
+	 * because we're not dispatching the IO requests generated by this
+	 * cgroup.
+	 */
+	cgroup_io_throttle(NULL, bdev, 0);
+
+	/*
 	 * Check the rate limiting. Also, we do not want to throttle real-time
 	 * tasks in balance_dirty_pages(). Period.
 	 */
@@ -1243,6 +1255,7 @@ int __set_page_dirty_nobuffers(struct page *page)
 			BUG_ON(mapping2 != mapping);
 			WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
 			account_page_dirtied(page, mapping);
+			iothrottle_set_pagedirty_owner(page, current->mm);
 			radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 		}
diff --git a/mm/readahead.c b/mm/readahead.c
index 133b6d5..25cae4c 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -14,6 +14,7 @@
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 
@@ -81,6 +82,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 			int (*filler)(void *, struct page *), void *data)
 {
 	struct page *page;
+	struct block_device *bdev = as_to_bdev(mapping);
 	int ret = 0;
 
 	while (!list_empty(pages)) {
@@ -99,6 +101,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 			break;
 		}
 		task_io_account_read(PAGE_CACHE_SIZE);
+		cgroup_io_throttle(NULL, bdev, PAGE_CACHE_SIZE);
 	}
 	return ret;
 }
-- 
1.6.0.4
