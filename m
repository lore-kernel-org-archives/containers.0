From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 27/33] blk-throttle: make blk_throtl_bio() ready for hierarchy
Date: Mon,  6 May 2013 15:46:06 -0700
Message-ID: <1367880372-28312-28-git-send-email-tj__44797.3681301393$1367880725$gmane$org@kernel.org>
References: <1367880372-28312-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1367880372-28312-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, blk_throtl_bio() issues the passed in bio directly if it's
within limits of its associated tg (throtl_grp).  This behavior
becomes incorrect with hierarchy support as the bio should be
accounted to and throttled by the ancestor throtl_grps too.

This patch makes the direct issue path of blk_throtl_bio() to loop
until it reaches the top-level service_queue or gets throttled.  If
the former, the bio can be issued directly; otherwise, it gets queued
at the first layer it was above limits.

As tg->parent_sq is always the top-level service queue currently, this
patch in itself doesn't make any behavior differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 27 ++++++++++++++++++++-------
 1 file changed, 20 insertions(+), 7 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 8c6e133..52321a4 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -1239,12 +1239,16 @@ bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 
 	sq = &tg->service_queue;
 
-	/* throtl is FIFO - if other bios are already queued, should queue */
-	if (sq->nr_queued[rw])
-		goto queue_bio;
+	while (true) {
+		/* throtl is FIFO - if bios are already queued, should queue */
+		if (sq->nr_queued[rw])
+			break;
 
-	/* Bio is with-in rate limit of group */
-	if (tg_may_dispatch(tg, bio, NULL)) {
+		/* if above limits, break to queue */
+		if (!tg_may_dispatch(tg, bio, NULL))
+			break;
+
+		/* within limits, let's charge and dispatch directly */
 		throtl_charge_bio(tg, bio);
 
 		/*
@@ -1259,10 +1263,19 @@ bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 		 * So keep on trimming slice even if bio is not queued.
 		 */
 		throtl_trim_slice(tg, rw);
-		goto out_unlock;
+
+		/*
+		 * @bio passed through this layer without being throttled.
+		 * Climb up the ladder.  If we''re already at the top, it
+		 * can be executed directly.
+		 */
+		sq = sq->parent_sq;
+		tg = sq_to_tg(sq);
+		if (!tg)
+			goto out_unlock;
 	}
 
-queue_bio:
+	/* out-of-limit, queue to @tg */
 	throtl_log(sq, "[%c] bio. bdisp=%llu sz=%u bps=%llu iodisp=%u iops=%u queued=%d/%d",
 		   rw == READ ? 'R' : 'W',
 		   tg->bytes_disp[rw], bio->bi_size, tg->bps[rw],
-- 
1.8.1.4
