From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 3/3] blkio-throttle: async write io instrumentation
Date: Mon, 28 Feb 2011 11:15:05 +0100
Message-ID: <1298888105-3778-4-git-send-email-arighi__859.91562014005$1298888775$gmane$org@develer.com>
References: <1298888105-3778-1-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1298888105-3778-1-git-send-email-arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Enforce IO throttling policy to asynchronous IO writes at the time tasks
write pages in the page cache.

Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
---
 mm/page-writeback.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 2cb01f6..e3f5f4f 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -607,6 +607,19 @@ void set_page_dirty_balance(struct page *page, int page_mkwrite)
 	}
 }
 
+/*
+ * Get a request_queue of the underlying superblock device from an
+ * address_space.
+ */
+static struct request_queue *as_to_rq(struct address_space *mapping)
+{
+	struct block_device *bdev;
+
+	bdev = (mapping->host && mapping->host->i_sb->s_bdev) ?
+				mapping->host->i_sb->s_bdev : NULL;
+	return bdev ? bdev_get_queue(bdev) : NULL;
+}
+
 static DEFINE_PER_CPU(unsigned long, bdp_ratelimits) = 0;
 
 /**
@@ -628,6 +641,7 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 {
 	unsigned long ratelimit;
 	unsigned long *p;
+	struct request_queue *q;
 
 	ratelimit = ratelimit_pages;
 	if (mapping->backing_dev_info->dirty_exceeded)
@@ -644,6 +658,9 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 		ratelimit = sync_writeback_pages(*p);
 		*p = 0;
 		preempt_enable();
+		q = as_to_rq(mapping);
+		if (q)
+			blk_throtl_async(q, ratelimit << PAGE_SHIFT);
 		balance_dirty_pages(mapping, ratelimit);
 		return;
 	}
-- 
1.7.1
