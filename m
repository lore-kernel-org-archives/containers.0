From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 23/31] blk-throttle: separate out
	throtl_service_queue->pending_timer from throtl_data->dispatch_work
Date: Wed,  1 May 2013 17:39:41 -0700
Message-ID: <1367455189-6957-24-git-send-email-tj__39437.0693633848$1367455561$gmane$org@kernel.org>
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

Currently, throtl_data->dispatch_work is a delayed_work item which
handles both delayed dispatch and issuing bios.  The two tasks will be
separated to support proper hierarchy.  To prepare for that, this
patch separates out the timer into throtl_service_queue->pending_timer
from throtl_data->dispatch_work and make the latter a work_struct.

* As the timer is now per-service_queue, it's initialized and
  del_sync'd as its corresponding service_queue is created and
  destroyed.  The timer, when triggered, simply schedules
  throtl_data->dispathc_work for execution.

* throtl_schedule_delayed_work() is renamed to
  throtl_schedule_pending_timer() and takes @sq and @expires now.

* Simiarly, throtl_schedule_next_dispatch() now takes @sq, which
  should be the parent_sq of the service_queue which just got a new
  bio or updated.  As the parent_sq is always the top-level
  service_queue now, this doesn't change anything at this point.

This patch doesn't introduce any behavior differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 70 ++++++++++++++++++++++++++++++++++------------------
 1 file changed, 46 insertions(+), 24 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 7f8ca43..9270663 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -44,6 +44,7 @@ struct throtl_service_queue {
 	struct rb_node		*first_pending;	/* first node in the tree */
 	unsigned int		nr_pending;	/* # queued in the tree */
 	unsigned long		first_pending_disptime;	/* disptime of the first tg */
+	struct timer_list	pending_timer;	/* fires on first_pending_disptime */
 };
 
 enum tg_state_flags {
@@ -121,7 +122,7 @@ struct throtl_data
 	unsigned int nr_undestroyed_grps;
 
 	/* Work for dispatching throttled bios */
-	struct delayed_work dispatch_work;
+	struct work_struct dispatch_work;
 };
 
 /* list and work item to allocate percpu group stats */
@@ -131,6 +132,8 @@ static LIST_HEAD(tg_stats_alloc_list);
 static void tg_stats_alloc_fn(struct work_struct *);
 static DECLARE_DELAYED_WORK(tg_stats_alloc_work, tg_stats_alloc_fn);
 
+static void throtl_pending_timer_fn(unsigned long arg);
+
 static inline struct throtl_grp *pd_to_tg(struct blkg_policy_data *pd)
 {
 	return pd ? container_of(pd, struct throtl_grp, pd) : NULL;
@@ -252,6 +255,13 @@ static void throtl_service_queue_init(struct throtl_service_queue *sq,
 	bio_list_init(&sq->bio_lists[1]);
 	sq->pending_tree = RB_ROOT;
 	sq->parent_sq = parent_sq;
+	setup_timer(&sq->pending_timer, throtl_pending_timer_fn,
+		    (unsigned long)sq);
+}
+
+static void throtl_service_queue_exit(struct throtl_service_queue *sq)
+{
+	del_timer_sync(&sq->pending_timer);
 }
 
 static void throtl_pd_init(struct blkcg_gq *blkg)
@@ -290,6 +300,8 @@ static void throtl_pd_exit(struct blkcg_gq *blkg)
 	spin_unlock_irqrestore(&tg_stats_alloc_lock, flags);
 
 	free_percpu(tg->stats_cpu);
+
+	throtl_service_queue_exit(&tg->service_queue);
 }
 
 static void throtl_pd_reset_stats(struct blkcg_gq *blkg)
@@ -444,19 +456,17 @@ static void throtl_dequeue_tg(struct throtl_grp *tg)
 }
 
 /* Call with queue lock held */
-static void throtl_schedule_delayed_work(struct throtl_data *td,
-					 unsigned long delay)
+static void throtl_schedule_pending_timer(struct throtl_service_queue *sq,
+					  unsigned long expires)
 {
-	struct delayed_work *dwork = &td->dispatch_work;
-	struct throtl_service_queue *sq = &td->service_queue;
-
-	mod_delayed_work(kthrotld_workqueue, dwork, delay);
-	throtl_log(sq, "schedule work. delay=%lu jiffies=%lu", delay, jiffies);
+	mod_timer(&sq->pending_timer, expires);
+	throtl_log(sq, "schedule timer. delay=%lu jiffies=%lu",
+		   expires - jiffies, jiffies);
 }
 
-static void throtl_schedule_next_dispatch(struct throtl_data *td)
+static void throtl_schedule_next_dispatch(struct throtl_service_queue *sq)
 {
-	struct throtl_service_queue *sq = &td->service_queue;
+	struct throtl_data *td = sq_to_td(sq);
 
 	/* any pending children left? */
 	if (!sq->nr_pending)
@@ -464,10 +474,14 @@ static void throtl_schedule_next_dispatch(struct throtl_data *td)
 
 	update_min_dispatch_time(sq);
 
-	if (time_before_eq(sq->first_pending_disptime, jiffies))
-		throtl_schedule_delayed_work(td, 0);
-	else
-		throtl_schedule_delayed_work(td, sq->first_pending_disptime - jiffies);
+	/* is the next dispatch time in the future? */
+	if (time_after(sq->first_pending_disptime, jiffies)) {
+		throtl_schedule_pending_timer(sq, sq->first_pending_disptime);
+		return;
+	}
+
+	/* kick immediate execution */
+	queue_work(kthrotld_workqueue, &td->dispatch_work);
 }
 
 static inline void throtl_start_new_slice(struct throtl_grp *tg, bool rw)
@@ -898,11 +912,19 @@ static int throtl_select_dispatch(struct throtl_service_queue *parent_sq)
 	return nr_disp;
 }
 
+static void throtl_pending_timer_fn(unsigned long arg)
+{
+	struct throtl_service_queue *sq = (void *)arg;
+	struct throtl_data *td = sq_to_td(sq);
+
+	queue_work(kthrotld_workqueue, &td->dispatch_work);
+}
+
 /* work function to dispatch throttled bios */
 void blk_throtl_dispatch_work_fn(struct work_struct *work)
 {
-	struct throtl_data *td = container_of(to_delayed_work(work),
-					      struct throtl_data, dispatch_work);
+	struct throtl_data *td = container_of(work, struct throtl_data,
+					      dispatch_work);
 	struct throtl_service_queue *sq = &td->service_queue;
 	struct request_queue *q = td->queue;
 	unsigned int nr_disp = 0;
@@ -929,7 +951,7 @@ void blk_throtl_dispatch_work_fn(struct work_struct *work)
 		throtl_log(sq, "bios disp=%u", nr_disp);
 	}
 
-	throtl_schedule_next_dispatch(td);
+	throtl_schedule_next_dispatch(sq);
 
 	spin_unlock_irq(q->queue_lock);
 
@@ -1017,7 +1039,7 @@ static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
 	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
 	struct blkg_conf_ctx ctx;
 	struct throtl_grp *tg;
-	struct throtl_data *td;
+	struct throtl_service_queue *sq;
 	int ret;
 
 	ret = blkg_conf_prep(blkcg, &blkcg_policy_throtl, buf, &ctx);
@@ -1025,7 +1047,7 @@ static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
 		return ret;
 
 	tg = blkg_to_tg(ctx.blkg);
-	td = ctx.blkg->q->td;
+	sq = &tg->service_queue;
 
 	if (!ctx.v)
 		ctx.v = -1;
@@ -1053,11 +1075,11 @@ static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
 
 	if (tg->flags & THROTL_TG_PENDING) {
 		tg_update_disptime(tg);
-		throtl_schedule_next_dispatch(td);
+		throtl_schedule_next_dispatch(sq->parent_sq);
 	}
 
 	/* kick dispatch in case disptime got shortened */
-	throtl_schedule_delayed_work(td, 0);
+	throtl_schedule_pending_timer(sq->parent_sq, jiffies);
 
 	blkg_conf_finish(&ctx);
 	return 0;
@@ -1121,7 +1143,7 @@ static void throtl_shutdown_wq(struct request_queue *q)
 {
 	struct throtl_data *td = q->td;
 
-	cancel_delayed_work_sync(&td->dispatch_work);
+	cancel_work_sync(&td->dispatch_work);
 }
 
 static struct blkcg_policy blkcg_policy_throtl = {
@@ -1210,7 +1232,7 @@ queue_bio:
 	/* update @tg's dispatch time if @tg was empty before @bio */
 	if (tg->flags & THROTL_TG_WAS_EMPTY) {
 		tg_update_disptime(tg);
-		throtl_schedule_next_dispatch(td);
+		throtl_schedule_next_dispatch(tg->service_queue.parent_sq);
 	}
 
 out_unlock:
@@ -1273,7 +1295,7 @@ int blk_throtl_init(struct request_queue *q)
 	if (!td)
 		return -ENOMEM;
 
-	INIT_DELAYED_WORK(&td->dispatch_work, blk_throtl_dispatch_work_fn);
+	INIT_WORK(&td->dispatch_work, blk_throtl_dispatch_work_fn);
 	throtl_service_queue_init(&td->service_queue, NULL);
 
 	q->td = td;
-- 
1.8.1.4
