From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 22/24] io-controller: Per io group bdi congestion interface
Date: Sat, 08 Aug 2009 16:14:51 +0800
Message-ID: <4A7D33FB.6090207__48924.3161901415$1249719455$gmane$org@cn.fujitsu.com>
References: <1248467274-32073-1-git-send-email-vgoyal@redhat.com>
	<1248467274-32073-23-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248467274-32073-23-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
...
> +/* Set io group congestion on and off thresholds */
> +void elv_io_group_congestion_threshold(struct request_queue *q,
> +						struct io_group *iog)
> +{
> +	int nr;
> +
> +	nr = q->nr_group_requests - (q->nr_group_requests / 8) + 1;
> +	if (nr > q->nr_group_requests)
> +		nr = q->nr_group_requests;
> +	iog->nr_congestion_on = nr;
> +
> +	nr = q->nr_group_requests - (q->nr_group_requests / 8)
> +			- (q->nr_group_requests / 16) - 1;
> +	if (nr < 1)
> +		nr = 1;
> +	iog->nr_congestion_off = nr;

Vivek,

Since we determine whether io group is congenssed or not just by checking 
iog->nr_congestion_on, we can get rid of iog->nr_congestion_off here.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/elevator-fq.c |    6 ------
 block/elevator-fq.h |    3 +--
 2 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 66b10eb..e73da31 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -1267,12 +1267,6 @@ void elv_io_group_congestion_threshold(struct request_queue *q,
 	if (nr > q->nr_group_requests)
 		nr = q->nr_group_requests;
 	iog->nr_congestion_on = nr;
-
-	nr = q->nr_group_requests - (q->nr_group_requests / 8)
-			- (q->nr_group_requests / 16) - 1;
-	if (nr < 1)
-		nr = 1;
-	iog->nr_congestion_off = nr;
 }
 
 static inline int elv_is_iog_congested(struct request_queue *q,
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 0581e55..2815279 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -266,9 +266,8 @@ struct io_group {
 	/* Single ioq per group, used for noop, deadline, anticipatory */
 	struct io_queue *ioq;
 
-	/* io group congestion on and off threshold for request descriptors */
+	/* io group congestion on threshold for request descriptors */
 	unsigned int nr_congestion_on;
-	unsigned int nr_congestion_off;
 
 	/* request list associated with the group */
 	struct request_list rl;
-- 
1.5.4.rc3
