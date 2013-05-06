From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/33] blk-throttle: collapse throtl_dispatch() into the work
	function
Date: Mon,  6 May 2013 15:45:47 -0700
Message-ID: <1367880372-28312-9-git-send-email-tj@kernel.org>
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

blk-throttle is about to go through major restructuring to support
hierarchy.  Do cosmetic updates in preparation.

* s/throtl_data->throtl_work/throtl_data->dispatch_work/

* s/blk_throtl_work()/blk_throtl_dispatch_work_fn()/

* Collapse throtl_dispatch() into blk_throtl_dispatch_work_fn()

This patch is purely cosmetic.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 26 +++++++++-----------------
 1 file changed, 9 insertions(+), 17 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 7dbd0e69..0a0bc00 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -108,7 +108,7 @@ struct throtl_data
 	unsigned int nr_undestroyed_grps;
 
 	/* Work for dispatching throttled bios */
-	struct delayed_work throtl_work;
+	struct delayed_work dispatch_work;
 };
 
 /* list and work item to allocate percpu group stats */
@@ -820,10 +820,12 @@ static int throtl_select_dispatch(struct throtl_data *td, struct bio_list *bl)
 	return nr_disp;
 }
 
-/* Dispatch throttled bios. Should be called without queue lock held. */
-static int throtl_dispatch(struct request_queue *q)
+/* work function to dispatch throttled bios */
+void blk_throtl_dispatch_work_fn(struct work_struct *work)
 {
-	struct throtl_data *td = q->td;
+	struct throtl_data *td = container_of(to_delayed_work(work),
+					      struct throtl_data, dispatch_work);
+	struct request_queue *q = td->queue;
 	unsigned int nr_disp = 0;
 	struct bio_list bio_list_on_stack;
 	struct bio *bio;
@@ -859,16 +861,6 @@ out:
 			generic_make_request(bio);
 		blk_finish_plug(&plug);
 	}
-	return nr_disp;
-}
-
-void blk_throtl_work(struct work_struct *work)
-{
-	struct throtl_data *td = container_of(work, struct throtl_data,
-					throtl_work.work);
-	struct request_queue *q = td->queue;
-
-	throtl_dispatch(q);
 }
 
 /* Call with queue lock held */
@@ -876,7 +868,7 @@ static void
 throtl_schedule_delayed_work(struct throtl_data *td, unsigned long delay)
 {
 
-	struct delayed_work *dwork = &td->throtl_work;
+	struct delayed_work *dwork = &td->dispatch_work;
 
 	if (total_nr_queued(td)) {
 		mod_delayed_work(kthrotld_workqueue, dwork, delay);
@@ -1057,7 +1049,7 @@ static void throtl_shutdown_wq(struct request_queue *q)
 {
 	struct throtl_data *td = q->td;
 
-	cancel_delayed_work_sync(&td->throtl_work);
+	cancel_delayed_work_sync(&td->dispatch_work);
 }
 
 static struct blkcg_policy blkcg_policy_throtl = {
@@ -1206,7 +1198,7 @@ int blk_throtl_init(struct request_queue *q)
 		return -ENOMEM;
 
 	td->tg_service_tree = THROTL_RB_ROOT;
-	INIT_DELAYED_WORK(&td->throtl_work, blk_throtl_work);
+	INIT_DELAYED_WORK(&td->dispatch_work, blk_throtl_dispatch_work_fn);
 
 	q->td = td;
 	td->queue = q;
-- 
1.8.1.4
