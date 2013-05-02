From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 28/31] blk-throttle: make tg_dispatch_one_bio() ready for
	hierarchy
Date: Wed,  1 May 2013 17:39:46 -0700
Message-ID: <1367455189-6957-29-git-send-email-tj__38231.4582741403$1367455625$gmane$org@kernel.org>
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

tg_dispatch_one_bio() currently assumes that the parent_sq is the top
level one and the bio being dispatched is ready to be issued; however,
this assumption will be wrong with proper hierarchy support.  This
patch makes the following changes to make tg_dispatch_on_bio() ready
for hiearchy.

* throtl_data->nr_queued[] is incremented in blk_throtl_bio() instead
  of throtl_add_bio_tg() so that throtl_add_bio_tg() can be used to
  transfer a bio from a child tg to its parent.

* tg_dispatch_one_bio() is updated to distinguish whether its parent
  is another throtl_grp or the throtl_data.  If former, the bio is
  transferred to the parent throtl_grp using throtl_add_bio_tg().  If
  latter, the bio is ready to be issued and put on the top-level
  service_queue's bio_lists[] and throtl_data->nr_queued is
  decremented.

As all throtl_grps currently have the top level service_queue as their
->parent_sq, this patch in itself doesn't make any behavior
difference.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 28 +++++++++++++++++++++-------
 1 file changed, 21 insertions(+), 7 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 99e1e78..367c269 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -821,7 +821,6 @@ static void throtl_add_bio_tg(struct bio *bio, struct throtl_grp *tg)
 	/* Take a bio reference on tg */
 	blkg_get(tg_to_blkg(tg));
 	sq->nr_queued[rw]++;
-	tg->td->nr_queued[rw]++;
 	throtl_enqueue_tg(tg);
 }
 
@@ -852,20 +851,34 @@ static void tg_update_disptime(struct throtl_grp *tg)
 static void tg_dispatch_one_bio(struct throtl_grp *tg, bool rw)
 {
 	struct throtl_service_queue *sq = &tg->service_queue;
+	struct throtl_service_queue *parent_sq = sq->parent_sq;
+	struct throtl_grp *parent_tg = sq_to_tg(parent_sq);
 	struct bio *bio;
 
 	bio = bio_list_pop(&sq->bio_lists[rw]);
 	sq->nr_queued[rw]--;
-	/* Drop bio reference on blkg */
-	blkg_put(tg_to_blkg(tg));
-
-	BUG_ON(tg->td->nr_queued[rw] <= 0);
-	tg->td->nr_queued[rw]--;
 
 	throtl_charge_bio(tg, bio);
-	bio_list_add(&sq->parent_sq->bio_lists[rw], bio);
+
+	/*
+	 * If our parent is another tg, we just need to transfer @bio to
+	 * the parent using throtl_add_bio_tg().  If our parent is
+	 * @td->service_queue, @bio is ready to be issued.  Put it on its
+	 * bio_lists[] and decrease total number queued.  The caller is
+	 * responsible for issuing these bios.
+	 */
+	if (parent_tg) {
+		throtl_add_bio_tg(bio, parent_tg);
+	} else {
+		bio_list_add(&parent_sq->bio_lists[rw], bio);
+		BUG_ON(tg->td->nr_queued[rw] <= 0);
+		tg->td->nr_queued[rw]--;
+	}
 
 	throtl_trim_slice(tg, rw);
+
+	/* @bio is transferred to parent, drop its blkg reference */
+	blkg_put(tg_to_blkg(tg));
 }
 
 static int throtl_dispatch_tg(struct throtl_grp *tg)
@@ -1283,6 +1296,7 @@ bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 		   sq->nr_queued[READ], sq->nr_queued[WRITE]);
 
 	bio_associate_current(bio);
+	tg->td->nr_queued[rw]++;
 	throtl_add_bio_tg(bio, tg);
 	throttled = true;
 
-- 
1.8.1.4
