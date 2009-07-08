From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 21/25] io-controller: Per cgroup request descriptor support
Date: Wed, 08 Jul 2009 11:27:25 +0800
Message-ID: <4A54121D.5090008__37479.6712225818$1247023738$gmane$org@cn.fujitsu.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<1246564917-19603-22-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246564917-19603-22-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
...
>  }
> +#ifdef CONFIG_GROUP_IOSCHED
> +static ssize_t queue_group_requests_show(struct request_queue *q, char *page)
> +{
> +	return queue_var_show(q->nr_group_requests, (page));
> +}
> +
> +static ssize_t
> +queue_group_requests_store(struct request_queue *q, const char *page,
> +					size_t count)
> +{
> +	unsigned long nr;
> +	int ret = queue_var_store(&nr, page, count);
> +	if (nr < BLKDEV_MIN_RQ)
> +		nr = BLKDEV_MIN_RQ;
> +
> +	spin_lock_irq(q->queue_lock);
> +	q->nr_group_requests = nr;
> +	spin_unlock_irq(q->queue_lock);
> +	return ret;
> +}
> +#endif

Hi Vivek,

Do we need to update the congestion thresholds for allocated io groups?

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/blk-sysfs.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index 577ed42..92b9f25 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -83,17 +83,32 @@ static ssize_t queue_group_requests_show(struct request_queue *q, char *page)
 	return queue_var_show(q->nr_group_requests, (page));
 }
 
+extern void elv_io_group_congestion_threshold(struct request_queue *q,
+					      struct io_group *iog);
+
 static ssize_t
 queue_group_requests_store(struct request_queue *q, const char *page,
 					size_t count)
 {
+	struct hlist_node *n;
+	struct io_group *iog;
+	struct elv_fq_data *efqd;
 	unsigned long nr;
 	int ret = queue_var_store(&nr, page, count);
+
 	if (nr < BLKDEV_MIN_RQ)
 		nr = BLKDEV_MIN_RQ;
 
 	spin_lock_irq(q->queue_lock);
+
 	q->nr_group_requests = nr;
+
+	efqd = &q->elevator->efqd;
+
+	hlist_for_each_entry(iog, n, &efqd->group_list, elv_data_node) {
+		elv_io_group_congestion_threshold(q, iog);
+	}
+
 	spin_unlock_irq(q->queue_lock);
 	return ret;
 }
-- 
1.5.4.rc3 
