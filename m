From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 26/31] blk-throttle: make blk_throtl_drain() ready for
	hierarchy
Date: Wed,  1 May 2013 17:39:44 -0700
Message-ID: <1367455189-6957-27-git-send-email-tj__28959.0278910056$1367455599$gmane$org@kernel.org>
References: <1367455189-6957-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1367455189-6957-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

The current blk_throtl_drain() assumes that all active throtl_grps are
queued on throtl_data->service_queue, which won't be true once
hierarchy support is implemented.

This patch makes blk_throtl_drain() perform post-order walk of the
blkg hierarchy draining each associated throtl_grp, which guarantees
that all bios will eventually be pushed to the top-level service_queue
in throtl_data.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 51 ++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 40 insertions(+), 11 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 8f435a7..1080563 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -1299,6 +1299,28 @@ out:
 	return throttled;
 }
 
+/*
+ * Dispatch all bios from all children tg's queued on @parent_sq.  On
+ * return, @parent_sq is guaranteed to not have any active children tg's
+ * and all bios from previously active tg's are on @parent_sq->bio_lists[].
+ */
+static void tg_drain_bios(struct throtl_service_queue *parent_sq)
+{
+	struct throtl_grp *tg;
+
+	while ((tg = throtl_rb_first(parent_sq))) {
+		struct throtl_service_queue *sq = &tg->service_queue;
+		struct bio *bio;
+
+		throtl_dequeue_tg(tg);
+
+		while ((bio = bio_list_peek(&sq->bio_lists[READ])))
+			tg_dispatch_one_bio(tg, bio_data_dir(bio));
+		while ((bio = bio_list_peek(&sq->bio_lists[WRITE])))
+			tg_dispatch_one_bio(tg, bio_data_dir(bio));
+	}
+}
+
 /**
  * blk_throtl_drain - drain throttled bios
  * @q: request_queue to drain throttled bios for
@@ -1309,27 +1331,34 @@ void blk_throtl_drain(struct request_queue *q)
 	__releases(q->queue_lock) __acquires(q->queue_lock)
 {
 	struct throtl_data *td = q->td;
-	struct throtl_service_queue *parent_sq = &td->service_queue;
-	struct throtl_grp *tg;
+	struct blkcg_gq *blkg;
+	struct cgroup *pos_cgrp;
 	struct bio *bio;
 	int rw;
 
 	queue_lockdep_assert_held(q);
+	rcu_read_lock();
 
-	while ((tg = throtl_rb_first(parent_sq))) {
-		struct throtl_service_queue *sq = &tg->service_queue;
+	/*
+	 * Drain each tg while doing post-order walk on the blkg tree, so
+	 * that all bios are propagated to td->service_queue.  It'd be
+	 * better to walk service_queue tree directly but blkg walk is
+	 * easier.
+	 */
+	blkg_for_each_descendant_post(blkg, pos_cgrp, td->queue->root_blkg)
+		tg_drain_bios(&blkg_to_tg(blkg)->service_queue);
 
-		throtl_dequeue_tg(tg);
+	tg_drain_bios(&td_root_tg(td)->service_queue);
 
-		while ((bio = bio_list_peek(&sq->bio_lists[READ])))
-			tg_dispatch_one_bio(tg, bio_data_dir(bio));
-		while ((bio = bio_list_peek(&sq->bio_lists[WRITE])))
-			tg_dispatch_one_bio(tg, bio_data_dir(bio));
-	}
+	/* finally, transfer bios from top-level tg's into the td */
+	tg_drain_bios(&td->service_queue);
+
+	rcu_read_unlock();
 	spin_unlock_irq(q->queue_lock);
 
+	/* all bios now should be in td->service_queue, issue them */
 	for (rw = READ; rw <= WRITE; rw++)
-		while ((bio = bio_list_pop(&parent_sq->bio_lists[rw])))
+		while ((bio = bio_list_pop(&td->service_queue.bio_lists[rw])))
 			generic_make_request(bio);
 
 	spin_lock_irq(q->queue_lock);
-- 
1.8.1.4
