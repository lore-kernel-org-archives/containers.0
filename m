From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH -mm 5/6] i/o controller instrumentation: accounting and
	throttling
Date: Tue,  7 Oct 2008 12:03:37 +0200
Message-ID: <1223373818-13687-6-git-send-email-righi.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <>
References: <>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Apply the cgroup-io-throttle controller to the opportune kernel functions.
Both accounting and throttling functionalities are performed by
cgroup_io_throttle().

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/blk-core.c      |    4 ++++
 fs/aio.c              |   12 ++++++++++++
 fs/direct-io.c        |    3 +++
 include/linux/sched.h |    7 +++++++
 kernel/fork.c         |    8 +++++++-
 mm/page-writeback.c   |    4 ++++
 mm/readahead.c        |    3 +++
 7 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 6cb3c6d..cc8a493 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -26,6 +26,7 @@
 #include <linux/swap.h>
 #include <linux/writeback.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/blktrace_api.h>
 #include <linux/fault-inject.h>
 
@@ -1504,9 +1505,12 @@ void submit_bio(int rw, struct bio *bio)
 	if (bio_has_data(bio)) {
 		if (rw & WRITE) {
 			count_vm_events(PGPGOUT, count);
+			cgroup_io_throttle(bio_iovec_idx(bio, 0)->bv_page,
+					bio->bi_bdev, bio->bi_size, 0);
 		} else {
 			task_io_account_read(bio->bi_size);
 			count_vm_events(PGPGIN, count);
+			cgroup_io_throttle(NULL, bio->bi_bdev, bio->bi_size, 1);
 		}
 
 		if (unlikely(block_dump)) {
diff --git a/fs/aio.c b/fs/aio.c
index f658441..ee8d452 100644
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
@@ -1558,6 +1559,7 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 {
 	struct kiocb *req;
 	struct file *file;
+	struct block_device *bdev;
 	ssize_t ret;
 
 	/* enforce forwards compatibility on users */
@@ -1580,6 +1582,14 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 	if (unlikely(!file))
 		return -EBADF;
 
+	/* check if we're exceeding the IO throttling limits */
+	bdev = as_to_bdev(file->f_mapping);
+	ret = cgroup_io_throttle(NULL, bdev, 0, 0);
+	if (unlikely(ret)) {
+		fput(file);
+		return -EAGAIN;
+	}
+
 	req = aio_get_req(ctx);		/* returns with 2 references to req */
 	if (unlikely(!req)) {
 		fput(file);
@@ -1622,12 +1632,14 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
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
diff --git a/fs/direct-io.c b/fs/direct-io.c
index 9606ee8..66f011a 100644
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
@@ -657,10 +658,12 @@ submit_page_section(struct dio *dio, struct page *page,
 	int ret = 0;
 
 	if (dio->rw & WRITE) {
+		struct block_device *bdev = dio->inode->i_sb->s_bdev;
 		/*
 		 * Read accounting is performed in submit_bio()
 		 */
 		task_io_account_write(len);
+		cgroup_io_throttle(NULL, bdev, 0, 1);
 	}
 
 	/*
diff --git a/include/linux/sched.h b/include/linux/sched.h
index cd67fac..685c449 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1210,6 +1210,13 @@ struct task_struct {
 	unsigned long ptrace_message;
 	siginfo_t *last_siginfo; /* For ptrace use.  */
 	struct task_io_accounting ioac;
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+	atomic_t in_aio;
+	unsigned long long io_throttle_bw_cnt;
+	unsigned long long io_throttle_bw_sleep;
+	unsigned long long io_throttle_iops_cnt;
+	unsigned long long io_throttle_iops_sleep;
+#endif
 #if defined(CONFIG_TASK_XACCT)
 	u64 acct_rss_mem1;	/* accumulated rss usage */
 	u64 acct_vm_mem1;	/* accumulated virtual memory usage */
diff --git a/kernel/fork.c b/kernel/fork.c
index 7b34bc5..99cef1a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1004,7 +1004,13 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 
 	task_io_accounting_init(&p->ioac);
 	acct_clear_integrals(p);
-
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+	atomic_set(&p->in_aio, 0);
+	p->io_throttle_bw_cnt = 0;
+	p->io_throttle_bw_sleep = 0;
+	p->io_throttle_iops_cnt = 0;
+	p->io_throttle_iops_sleep = 0;
+#endif
 	p->it_virt_expires = cputime_zero;
 	p->it_prof_expires = cputime_zero;
 	p->it_sched_expires = 0;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c6d6088..7096b26 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -23,6 +23,7 @@
 #include <linux/init.h>
 #include <linux/backing-dev.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/blkdev.h>
 #include <linux/mpage.h>
 #include <linux/rmap.h>
@@ -556,6 +557,9 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 	static DEFINE_PER_CPU(unsigned long, ratelimits) = 0;
 	unsigned long ratelimit;
 	unsigned long *p;
+	struct block_device *bdev = as_to_bdev(mapping);
+
+	cgroup_io_throttle(NULL, bdev, 0, 1);
 
 	ratelimit = ratelimit_pages;
 	if (mapping->backing_dev_info->dirty_exceeded)
diff --git a/mm/readahead.c b/mm/readahead.c
index 137bc56..176ad00 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -14,6 +14,7 @@
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 
@@ -58,6 +59,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 			int (*filler)(void *, struct page *), void *data)
 {
 	struct page *page;
+	struct block_device *bdev = as_to_bdev(mapping);
 	int ret = 0;
 
 	while (!list_empty(pages)) {
@@ -76,6 +78,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 			break;
 		}
 		task_io_account_read(PAGE_CACHE_SIZE);
+		cgroup_io_throttle(NULL, bdev, PAGE_CACHE_SIZE, 1);
 	}
 	return ret;
 }
-- 
1.5.4.3
