From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 19/33] blk-throttle: generalize update_disptime optimization
	in blk_throtl_bio()
Date: Mon,  6 May 2013 15:45:58 -0700
Message-ID: <1367880372-28312-20-git-send-email-tj@kernel.org>
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

When blk_throtl_bio() wants to queue a bio to a tg (throtl_grp), it
avoids invoking tg_update_disptime() and
throtl_schedule_next_dispatch() if the tg already has bios queued in
that direction.  As a new bio is appeneded after the existing ones, it
can't change the tg's next dispatch time or the parent's dispatch
schedule.

This optimization is currently open coded in blk_throtl_bio().
Whether the target biolist was occupied was recorded in a local
variable and later used to skip disptime update.  This patch moves
generalizes it so that throtl_add_bio_tg() sets a new flag
THROTL_TG_WAS_EMPTY if the biolist was empty before the new bio was
added.  tg_update_disptime() clears the flag automatically.
blk_throtl_bio() is updated to simply test the flag before updating
disptime.

This patch doesn't make any functional differences now but will enable
using the same optimization for recursive dispatch.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 154bd63..ec9397f 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -46,6 +46,7 @@ struct throtl_service_queue {
 
 enum tg_state_flags {
 	THROTL_TG_PENDING	= 1 << 0,	/* on parent's pending tree */
+	THROTL_TG_WAS_EMPTY	= 1 << 1,	/* bio_lists[] became non-empty */
 };
 
 #define rb_entry_tg(node)	rb_entry((node), struct throtl_grp, rb_node)
@@ -712,6 +713,15 @@ static void throtl_add_bio_tg(struct bio *bio, struct throtl_grp *tg,
 	struct throtl_service_queue *sq = &tg->service_queue;
 	bool rw = bio_data_dir(bio);
 
+	/*
+	 * If @tg doesn't currently have any bios queued in the same
+	 * direction, queueing @bio can change when @tg should be
+	 * dispatched.  Mark that @tg was empty.  This is automatically
+	 * cleaered on the next tg_update_disptime().
+	 */
+	if (!sq->nr_queued[rw])
+		tg->flags |= THROTL_TG_WAS_EMPTY;
+
 	bio_list_add(&sq->bio_lists[rw], bio);
 	/* Take a bio reference on tg */
 	blkg_get(tg_to_blkg(tg));
@@ -740,6 +750,9 @@ static void tg_update_disptime(struct throtl_grp *tg,
 	throtl_dequeue_tg(tg, parent_sq);
 	tg->disptime = disptime;
 	throtl_enqueue_tg(tg, parent_sq);
+
+	/* see throtl_add_bio_tg() */
+	tg->flags &= ~THROTL_TG_WAS_EMPTY;
 }
 
 static void tg_dispatch_one_bio(struct throtl_grp *tg, bool rw,
@@ -1061,7 +1074,7 @@ bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 	struct throtl_data *td = q->td;
 	struct throtl_grp *tg;
 	struct throtl_service_queue *sq;
-	bool rw = bio_data_dir(bio), update_disptime = true;
+	bool rw = bio_data_dir(bio);
 	struct blkcg *blkcg;
 	bool throttled = false;
 
@@ -1097,16 +1110,10 @@ bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 
 	sq = &tg->service_queue;
 
-	if (sq->nr_queued[rw]) {
-		/*
-		 * There is already another bio queued in same dir. No
-		 * need to update dispatch time.
-		 */
-		update_disptime = false;
+	/* throtl is FIFO - if other bios are already queued, should queue */
+	if (sq->nr_queued[rw])
 		goto queue_bio;
 
-	}
-
 	/* Bio is with-in rate limit of group */
 	if (tg_may_dispatch(tg, bio, NULL)) {
 		throtl_charge_bio(tg, bio);
@@ -1138,7 +1145,8 @@ queue_bio:
 	throtl_add_bio_tg(bio, tg, &q->td->service_queue);
 	throttled = true;
 
-	if (update_disptime) {
+	/* update @tg's dispatch time if @tg was empty before @bio */
+	if (tg->flags & THROTL_TG_WAS_EMPTY) {
 		tg_update_disptime(tg, &td->service_queue);
 		throtl_schedule_next_dispatch(td);
 	}
-- 
1.8.1.4
