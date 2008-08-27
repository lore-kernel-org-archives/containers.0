From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC][PATCH -mm 4/5] i/o controller instrumentation: accounting and
	throttling
Date: Wed, 27 Aug 2008 18:07:36 +0200
Message-ID: <1219853257-11052-5-git-send-email-righi.andrea@gmail.com>
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

Apply the io-throttle controller to the opportune kernel functions. Both
accounting and throttling functionalities are performed by
cgroup_io_throttle().

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/blk-core.c      |    2 ++
 fs/aio.c              |   14 ++++++++++++++
 include/linux/sched.h |    5 +++++
 kernel/fork.c         |    6 +++++-
 mm/page-writeback.c   |   19 +++++++++++++++++++
 mm/readahead.c        |    5 +++++
 6 files changed, 50 insertions(+), 1 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index fef79cc..a04f230 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -26,6 +26,7 @@
 #include <linux/swap.h>
 #include <linux/writeback.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/interrupt.h>
 #include <linux/cpu.h>
 #include <linux/blktrace_api.h>
@@ -1490,6 +1491,7 @@ void submit_bio(int rw, struct bio *bio)
 				(unsigned long long)bio->bi_sector,
 				bdevname(bio->bi_bdev, b));
 		}
+		cgroup_io_throttle(bio->bi_bdev, bio->bi_size, 1);
 	}
 
 	generic_make_request(bio);
diff --git a/fs/aio.c b/fs/aio.c
index f658441..6937dfb 100644
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
@@ -1558,6 +1559,8 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 {
 	struct kiocb *req;
 	struct file *file;
+	struct block_device *bdev;
+	struct inode *inode;
 	ssize_t ret;
 
 	/* enforce forwards compatibility on users */
@@ -1580,6 +1583,15 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 	if (unlikely(!file))
 		return -EBADF;
 
+	/* check if we're exceeding the IO throttling limits */
+	inode = file->f_mapping->host;
+	bdev = inode->i_sb->s_bdev;
+	ret = cgroup_io_throttle(bdev, 0, 0);
+	if (unlikely(ret)) {
+		fput(file);
+		return -EAGAIN;
+	}
+
 	req = aio_get_req(ctx);		/* returns with 2 references to req */
 	if (unlikely(!req)) {
 		fput(file);
@@ -1622,12 +1634,14 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
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
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1b26ed2..4b1d69e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1253,6 +1253,11 @@ struct task_struct {
 	unsigned long ptrace_message;
 	siginfo_t *last_siginfo; /* For ptrace use.  */
 	struct task_io_accounting ioac;
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+	atomic_t in_aio;
+	unsigned long long io_throttle_cnt;
+	unsigned long long io_throttle_sleep;
+#endif
 #if defined(CONFIG_TASK_XACCT)
 	u64 acct_rss_mem1;	/* accumulated rss usage */
 	u64 acct_vm_mem1;	/* accumulated virtual memory usage */
diff --git a/kernel/fork.c b/kernel/fork.c
index 63a87ff..9ee7408 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1011,7 +1011,11 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 
 	task_io_accounting_init(&p->ioac);
 	acct_clear_integrals(p);
-
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+	atomic_set(&p->in_aio, 0);
+	p->io_throttle_cnt = 0;
+	p->io_throttle_sleep = 0;
+#endif
 	p->it_virt_expires = cputime_zero;
 	p->it_prof_expires = cputime_zero;
 	p->it_sched_expires = 0;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c6d6088..84b6b9a 100644
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
@@ -556,6 +557,24 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 	static DEFINE_PER_CPU(unsigned long, ratelimits) = 0;
 	unsigned long ratelimit;
 	unsigned long *p;
+	struct block_device *bdev = (mapping->host &&
+				mapping->host->i_sb->s_bdev) ?
+				mapping->host->i_sb->s_bdev : NULL;
+	/*
+	 * If we're dirtying pages on IO limited devices, force the current
+	 * task to actively flush dirty pages back to the device.
+	 *
+	 * The throttling will be performed in submit_bio() in the same IO
+	 * context of the current task.
+	 */
+	if (is_io_throttled(bdev)) {
+		struct backing_dev_info *bdi = mapping->backing_dev_info;
+
+		if (writeback_in_progress(bdi))
+			return;
+		background_writeout(nr_pages_dirtied);
+		return;
+	}
 
 	ratelimit = ratelimit_pages;
 	if (mapping->backing_dev_info->dirty_exceeded)
diff --git a/mm/readahead.c b/mm/readahead.c
index 137bc56..448f065 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -14,6 +14,7 @@
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 
@@ -58,6 +59,9 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 			int (*filler)(void *, struct page *), void *data)
 {
 	struct page *page;
+	struct block_device *bdev =
+		(mapping->host && mapping->host->i_sb->s_bdev) ?
+		mapping->host->i_sb->s_bdev : NULL;
 	int ret = 0;
 
 	while (!list_empty(pages)) {
@@ -76,6 +80,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 			break;
 		}
 		task_io_account_read(PAGE_CACHE_SIZE);
+		cgroup_io_throttle(bdev, PAGE_CACHE_SIZE, 1);
 	}
 	return ret;
 }
-- 
1.5.4.3
