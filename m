From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 29/33] blk-throttle: make throtl_pending_timer_fn() ready for
	hierarchy
Date: Mon,  6 May 2013 15:46:08 -0700
Message-ID: <1367880372-28312-30-git-send-email-tj__24386.7145306014$1367880741$gmane$org@kernel.org>
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

throtl_pending_timer_fn() currently assumes that the parent_sq is the
top level one and the bio's dispatched are ready to be issued;
however, this assumption will be wrong with proper hierarchy support.
This patch makes the following changes to make
throtl_pending_timer_fn() ready for hiearchy.

* If the parent_sq isn't the top-level one, update the parent
  throtl_grp's dispatch time and schedule the next dispatch as
  necessary.  If the parent's dispatch time is now, repeat the
  function for the parent throtl_grp.

* If the parent_sq is the top-level one, kick issue work_item as
  before.

* The debug message printed by throtl_log() now prints out the
  service_queue's nr_queued[] instead of the total nr_queued as the
  latter becomes uninteresting and misleading with hierarchical
  dispatch.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 40 +++++++++++++++++++++++++++++++++-------
 1 file changed, 33 insertions(+), 7 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 0420261..bc65077 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -952,23 +952,33 @@ static int throtl_select_dispatch(struct throtl_service_queue *parent_sq)
  * This timer is armed when a child throtl_grp with active bio's become
  * pending and queued on the service_queue's pending_tree and expires when
  * the first child throtl_grp should be dispatched.  This function
- * dispatches bio's from the children throtl_grps and kicks
- * throtl_data->dispatch_work if there are bio's ready to be issued.
+ * dispatches bio's from the children throtl_grps to the parent
+ * service_queue.
+ *
+ * If the parent's parent is another throtl_grp, dispatching is propagated
+ * by either arming its pending_timer or repeating dispatch directly.  If
+ * the top-level service_tree is reached, throtl_data->dispatch_work is
+ * kicked so that the ready bio's are issued.
  */
 static void throtl_pending_timer_fn(unsigned long arg)
 {
 	struct throtl_service_queue *sq = (void *)arg;
+	struct throtl_grp *tg = sq_to_tg(sq);
 	struct throtl_data *td = sq_to_td(sq);
 	struct request_queue *q = td->queue;
-	bool dispatched = false;
+	struct throtl_service_queue *parent_sq;
+	bool dispatched;
 	int ret;
 
 	spin_lock_irq(q->queue_lock);
+again:
+	parent_sq = sq->parent_sq;
+	dispatched = false;
 
 	while (true) {
 		throtl_log(sq, "dispatch nr_queued=%u read=%u write=%u",
-			   td->nr_queued[READ] + td->nr_queued[WRITE],
-			   td->nr_queued[READ], td->nr_queued[WRITE]);
+			   sq->nr_queued[READ] + sq->nr_queued[WRITE],
+			   sq->nr_queued[READ], sq->nr_queued[WRITE]);
 
 		ret = throtl_select_dispatch(sq);
 		if (ret) {
@@ -985,9 +995,25 @@ static void throtl_pending_timer_fn(unsigned long arg)
 		spin_lock_irq(q->queue_lock);
 	}
 
-	if (dispatched)
-		queue_work(kthrotld_workqueue, &td->dispatch_work);
+	if (!dispatched)
+		goto out_unlock;
 
+	if (parent_sq) {
+		/* @parent_sq is another throl_grp, propagate dispatch */
+		if (tg->flags & THROTL_TG_WAS_EMPTY) {
+			tg_update_disptime(tg);
+			if (!throtl_schedule_next_dispatch(parent_sq, false)) {
+				/* window is already open, repeat dispatching */
+				sq = parent_sq;
+				tg = sq_to_tg(sq);
+				goto again;
+			}
+		}
+	} else {
+		/* reached the top-level, queue issueing */
+		queue_work(kthrotld_workqueue, &td->dispatch_work);
+	}
+out_unlock:
 	spin_unlock_irq(q->queue_lock);
 }
 
-- 
1.8.1.4
