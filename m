From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 09/33] blk-throttle: relocate throtl_schedule_delayed_work()
Date: Mon,  6 May 2013 15:45:48 -0700
Message-ID: <1367880372-28312-10-git-send-email-tj@kernel.org>
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

Move throtl_schedule_delayed_work() above its first user so that the
forward declaration can be removed.

This patch is pure relocaiton.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 29 +++++++++++++----------------
 1 file changed, 13 insertions(+), 16 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 0a0bc00..507b1c6 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -25,8 +25,6 @@ static struct blkcg_policy blkcg_policy_throtl;
 
 /* A workqueue to queue throttle related work */
 static struct workqueue_struct *kthrotld_workqueue;
-static void throtl_schedule_delayed_work(struct throtl_data *td,
-				unsigned long delay);
 
 struct throtl_rb_root {
 	struct rb_root rb;
@@ -398,6 +396,19 @@ static void throtl_dequeue_tg(struct throtl_data *td, struct throtl_grp *tg)
 		__throtl_dequeue_tg(td, tg);
 }
 
+/* Call with queue lock held */
+static void throtl_schedule_delayed_work(struct throtl_data *td,
+					 unsigned long delay)
+{
+	struct delayed_work *dwork = &td->dispatch_work;
+
+	if (total_nr_queued(td)) {
+		mod_delayed_work(kthrotld_workqueue, dwork, delay);
+		throtl_log(td, "schedule work. delay=%lu jiffies=%lu",
+			   delay, jiffies);
+	}
+}
+
 static void throtl_schedule_next_dispatch(struct throtl_data *td)
 {
 	struct throtl_rb_root *st = &td->tg_service_tree;
@@ -863,20 +874,6 @@ out:
 	}
 }
 
-/* Call with queue lock held */
-static void
-throtl_schedule_delayed_work(struct throtl_data *td, unsigned long delay)
-{
-
-	struct delayed_work *dwork = &td->dispatch_work;
-
-	if (total_nr_queued(td)) {
-		mod_delayed_work(kthrotld_workqueue, dwork, delay);
-		throtl_log(td, "schedule work. delay=%lu jiffies=%lu",
-				delay, jiffies);
-	}
-}
-
 static u64 tg_prfill_cpu_rwstat(struct seq_file *sf,
 				struct blkg_policy_data *pd, int off)
 {
-- 
1.8.1.4
