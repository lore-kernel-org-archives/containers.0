From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 25/31] blk-throttle: dispatch from throtl_pending_timer_fn()
Date: Wed,  1 May 2013 17:39:43 -0700
Message-ID: <1367455189-6957-26-git-send-email-tj__23450.692339293$1367455587$gmane$org@kernel.org>
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

Currently, blk_throtl_dispatch_work_fn() is responsible for both
dispatching bio's from throtl_grp's according to their limits and then
issuing the dispatched bios.

This patch moves the dispatch part to throtl_pending_timer_fn() so
that the work item is kicked iff there are bio's to issue.  This is to
avoid work item execution at each step when hierarchy support is
enabled.  bio's will be dispatched towards the top-level service_queue
from the timers at each layer and the work item will only be used to
issue the bio's which reached the top-level service_queue.

While fetching bio's to issue from bio_lists[],
blk_throtl_dispatch_work_fn() fetches all READs before WRITEs.  While
the original code also dispatched READs first, if multiple throtl_grps
are dispatched on the same run, WRITEs from throtl_grp which is
dispatched first would precede READs from throtl_grps which are
dispatched later.  While this is a behavior change, given that the
previous code already prioritized READs and block layer generally
prioritizes and segregates READs from WRITEs, this isn't likely to
make any noticeable differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 69 +++++++++++++++++++++++++++++++++-------------------
 1 file changed, 44 insertions(+), 25 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index d573cdf..8f435a7 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -929,31 +929,26 @@ static int throtl_select_dispatch(struct throtl_service_queue *parent_sq)
 	return nr_disp;
 }
 
+/**
+ * throtl_pending_timer_fn - timer function for service_queue->pending_timer
+ * @arg: the throtl_service_queue being serviced
+ *
+ * This timer is armed when a child throtl_grp with active bio's become
+ * pending and queued on the service_queue's pending_tree and expires when
+ * the first child throtl_grp should be dispatched.  This function
+ * dispatches bio's from the children throtl_grps and kicks
+ * throtl_data->dispatch_work if there are bio's ready to be issued.
+ */
 static void throtl_pending_timer_fn(unsigned long arg)
 {
 	struct throtl_service_queue *sq = (void *)arg;
 	struct throtl_data *td = sq_to_td(sq);
-
-	queue_work(kthrotld_workqueue, &td->dispatch_work);
-}
-
-/* work function to dispatch throttled bios */
-void blk_throtl_dispatch_work_fn(struct work_struct *work)
-{
-	struct throtl_data *td = container_of(work, struct throtl_data,
-					      dispatch_work);
-	struct throtl_service_queue *sq = &td->service_queue;
 	struct request_queue *q = td->queue;
-	struct bio_list bio_list_on_stack;
-	struct bio *bio;
-	struct blk_plug plug;
 	bool dispatched = false;
-	int rw, ret;
+	int ret;
 
 	spin_lock_irq(q->queue_lock);
 
-	bio_list_init(&bio_list_on_stack);
-
 	while (true) {
 		throtl_log(sq, "dispatch nr_queued=%u read=%u write=%u",
 			   td->nr_queued[READ] + td->nr_queued[WRITE],
@@ -961,10 +956,6 @@ void blk_throtl_dispatch_work_fn(struct work_struct *work)
 
 		ret = throtl_select_dispatch(sq);
 		if (ret) {
-			for (rw = READ; rw <= WRITE; rw++) {
-				bio_list_merge(&bio_list_on_stack, &sq->bio_lists[rw]);
-				bio_list_init(&sq->bio_lists[rw]);
-			}
 			throtl_log(sq, "bios disp=%u", ret);
 			dispatched = true;
 		}
@@ -978,13 +969,41 @@ void blk_throtl_dispatch_work_fn(struct work_struct *work)
 		spin_lock_irq(q->queue_lock);
 	}
 
+	if (dispatched)
+		queue_work(kthrotld_workqueue, &td->dispatch_work);
+
 	spin_unlock_irq(q->queue_lock);
+}
 
-	/*
-	 * If we dispatched some requests, unplug the queue to make sure
-	 * immediate dispatch
-	 */
-	if (dispatched) {
+/**
+ * blk_throtl_dispatch_work_fn - work function for throtl_data->dispatch_work
+ * @work: work item being executed
+ *
+ * This function is queued for execution when bio's reach the bio_lists[]
+ * of throtl_data->service_queue.  Those bio's are ready and issued by this
+ * function.
+ */
+void blk_throtl_dispatch_work_fn(struct work_struct *work)
+{
+	struct throtl_data *td = container_of(work, struct throtl_data,
+					      dispatch_work);
+	struct throtl_service_queue *td_sq = &td->service_queue;
+	struct request_queue *q = td->queue;
+	struct bio_list bio_list_on_stack;
+	struct bio *bio;
+	struct blk_plug plug;
+	int rw;
+
+	bio_list_init(&bio_list_on_stack);
+
+	spin_lock_irq(q->queue_lock);
+	for (rw = READ; rw <= WRITE; rw++) {
+		bio_list_merge(&bio_list_on_stack, &td_sq->bio_lists[rw]);
+		bio_list_init(&td_sq->bio_lists[rw]);
+	}
+	spin_unlock_irq(q->queue_lock);
+
+	if (!bio_list_empty(&bio_list_on_stack)) {
 		blk_start_plug(&plug);
 		while((bio = bio_list_pop(&bio_list_on_stack)))
 			generic_make_request(bio);
-- 
1.8.1.4
