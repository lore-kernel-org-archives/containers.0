From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/31] blk-throttle: remove pointless throtl_nr_queued()
	optimizations
Date: Wed,  1 May 2013 17:39:28 -0700
Message-ID: <1367455189-6957-11-git-send-email-tj@kernel.org>
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

throtl_nr_queued() is used in several places to avoid performing
certain operations when the throtl_data is empty.  This usually is
useless as those paths usually aren't traveled if there's no bio
queued.

* throtl_schedule_delayed_work() skips scheduling dispatch work item
  if @td doesn't have any bios queued; however, the only case it can
  be called when @td is empty is from tg_set_conf() which isn't
  something we should be optimizing for.

* throtl_schedule_next_dispatch() takes a quick exit if @td is empty;
  however, right after that it triggers BUG if the service tree is
  empty.  The two conditions are equivalent and it can just test
  @st->count for the quick exit.

* blk_throtl_dispatch_work_fn() skips dispatch if @td is empty.  This
  work function isn't usually invoked when @td is empty.  The only
  possibility is from tg_set_conf() and when it happens the normal
  dispatching path can handle empty @td fine.  No need to add special
  skip path.

This patch removes the above three unnecessary optimizations, which
leave throtl_log() call in blk_throtl_dispatch_work_fn() the only user
of throtl_nr_queued().  Remove throtl_nr_queued() and open code it in
throtl_log().  I don't think we need td->nr_queued[] at all.  Maybe we
can remove it later.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 29 +++++++----------------------
 1 file changed, 7 insertions(+), 22 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 00e72f4..6fd08a4 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -166,11 +166,6 @@ THROTL_TG_FNS(on_rr);
 #define throtl_log(td, fmt, args...)	\
 	blk_add_trace_msg((td)->queue, "throtl " fmt, ##args)
 
-static inline unsigned int total_nr_queued(struct throtl_data *td)
-{
-	return td->nr_queued[0] + td->nr_queued[1];
-}
-
 /*
  * Worker for allocating per cpu stat for tgs. This is scheduled on the
  * system_wq once there are some groups on the alloc_list waiting for
@@ -402,25 +397,18 @@ static void throtl_schedule_delayed_work(struct throtl_data *td,
 {
 	struct delayed_work *dwork = &td->dispatch_work;
 
-	if (total_nr_queued(td)) {
-		mod_delayed_work(kthrotld_workqueue, dwork, delay);
-		throtl_log(td, "schedule work. delay=%lu jiffies=%lu",
-			   delay, jiffies);
-	}
+	mod_delayed_work(kthrotld_workqueue, dwork, delay);
+	throtl_log(td, "schedule work. delay=%lu jiffies=%lu", delay, jiffies);
 }
 
 static void throtl_schedule_next_dispatch(struct throtl_data *td)
 {
 	struct throtl_rb_root *st = &td->tg_service_tree;
 
-	/*
-	 * If there are more bios pending, schedule more work.
-	 */
-	if (!total_nr_queued(td))
+	/* any pending children left? */
+	if (!st->count)
 		return;
 
-	BUG_ON(!st->count);
-
 	update_min_dispatch_time(st);
 
 	if (time_before_eq(st->min_disptime, jiffies))
@@ -844,14 +832,11 @@ void blk_throtl_dispatch_work_fn(struct work_struct *work)
 
 	spin_lock_irq(q->queue_lock);
 
-	if (!total_nr_queued(td))
-		goto out;
-
 	bio_list_init(&bio_list_on_stack);
 
 	throtl_log(td, "dispatch nr_queued=%u read=%u write=%u",
-			total_nr_queued(td), td->nr_queued[READ],
-			td->nr_queued[WRITE]);
+		   td->nr_queued[READ] + td->nr_queued[WRITE],
+		   td->nr_queued[READ], td->nr_queued[WRITE]);
 
 	nr_disp = throtl_select_dispatch(td, &bio_list_on_stack);
 
@@ -859,7 +844,7 @@ void blk_throtl_dispatch_work_fn(struct work_struct *work)
 		throtl_log(td, "bios disp=%u", nr_disp);
 
 	throtl_schedule_next_dispatch(td);
-out:
+
 	spin_unlock_irq(q->queue_lock);
 
 	/*
-- 
1.8.1.4
