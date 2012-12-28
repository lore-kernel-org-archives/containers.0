From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/24] cfq-iosched: More renaming to better represent wl_class
	and wl_type
Date: Fri, 28 Dec 2012 12:35:24 -0800
Message-ID: <1356726946-26037-3-git-send-email-tj@kernel.org>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1356726946-26037-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Some more renaming. Again making the code uniform w.r.t use of
wl_class/class to represent IO class (RT, BE, IDLE) and using
wl_type/type to represent subclass (SYNC, SYNC-IDLE, ASYNC).

At places this patch shortens the string "workload" to "wl".
Renamed "saved_workload" to "saved_wl_type". Renamed
"saved_serving_class" to "saved_wl_class".

For uniformity with "saved_wl_*" variables, renamed "serving_class"
to "serving_wl_class" and renamed "serving_type" to "serving_wl_type".

Again, just trying to improve upon code uniformity and improve
readability. No functional change.

v2:
- Restored the usage of keyword "service" based on Jeff Moyer's feedback.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/cfq-iosched.c | 64 +++++++++++++++++++++++++++--------------------------
 1 file changed, 33 insertions(+), 31 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 7646dfd..8f890bf 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -248,9 +248,9 @@ struct cfq_group {
 	struct cfq_rb_root service_trees[2][3];
 	struct cfq_rb_root service_tree_idle;
 
-	unsigned long saved_workload_slice;
-	enum wl_type_t saved_workload;
-	enum wl_class_t saved_serving_class;
+	unsigned long saved_wl_slice;
+	enum wl_type_t saved_wl_type;
+	enum wl_class_t saved_wl_class;
 
 	/* number of requests that are on the dispatch list or inside driver */
 	int dispatched;
@@ -280,8 +280,8 @@ struct cfq_data {
 	/*
 	 * The priority currently being served
 	 */
-	enum wl_class_t serving_class;
-	enum wl_type_t serving_type;
+	enum wl_class_t serving_wl_class;
+	enum wl_type_t serving_wl_type;
 	unsigned long workload_expires;
 	struct cfq_group *serving_group;
 
@@ -1241,7 +1241,7 @@ cfq_group_notify_queue_del(struct cfq_data *cfqd, struct cfq_group *cfqg)
 
 	cfq_log_cfqg(cfqd, cfqg, "del_from_rr group");
 	cfq_group_service_tree_del(st, cfqg);
-	cfqg->saved_workload_slice = 0;
+	cfqg->saved_wl_slice = 0;
 	cfqg_stats_update_dequeue(cfqg);
 }
 
@@ -1301,12 +1301,12 @@ static void cfq_group_served(struct cfq_data *cfqd, struct cfq_group *cfqg,
 
 	/* This group is being expired. Save the context */
 	if (time_after(cfqd->workload_expires, jiffies)) {
-		cfqg->saved_workload_slice = cfqd->workload_expires
+		cfqg->saved_wl_slice = cfqd->workload_expires
 						- jiffies;
-		cfqg->saved_workload = cfqd->serving_type;
-		cfqg->saved_serving_class = cfqd->serving_class;
+		cfqg->saved_wl_type = cfqd->serving_wl_type;
+		cfqg->saved_wl_class = cfqd->serving_wl_class;
 	} else
-		cfqg->saved_workload_slice = 0;
+		cfqg->saved_wl_slice = 0;
 
 	cfq_log_cfqg(cfqd, cfqg, "served: vt=%llu min_vt=%llu", cfqg->vdisktime,
 					st->min_vdisktime);
@@ -2031,7 +2031,7 @@ static void __cfq_set_active_queue(struct cfq_data *cfqd,
 {
 	if (cfqq) {
 		cfq_log_cfqq(cfqd, cfqq, "set_active wl_class:%d wl_type:%d",
-				cfqd->serving_class, cfqd->serving_type);
+				cfqd->serving_wl_class, cfqd->serving_wl_type);
 		cfqg_stats_update_avg_queue_size(cfqq->cfqg);
 		cfqq->slice_start = 0;
 		cfqq->dispatch_start = jiffies;
@@ -2118,8 +2118,8 @@ static inline void cfq_slice_expired(struct cfq_data *cfqd, bool timed_out)
 static struct cfq_queue *cfq_get_next_queue(struct cfq_data *cfqd)
 {
 	struct cfq_rb_root *service_tree =
-		service_tree_for(cfqd->serving_group, cfqd->serving_class,
-					cfqd->serving_type);
+		service_tree_for(cfqd->serving_group, cfqd->serving_wl_class,
+						cfqd->serving_wl_type);
 
 	if (!cfqd->rq_queued)
 		return NULL;
@@ -2523,20 +2523,20 @@ static void choose_service_tree(struct cfq_data *cfqd, struct cfq_group *cfqg)
 	unsigned count;
 	struct cfq_rb_root *st;
 	unsigned group_slice;
-	enum wl_class_t original_class = cfqd->serving_class;
+	enum wl_class_t original_class = cfqd->serving_wl_class;
 
 	/* Choose next priority. RT > BE > IDLE */
 	if (cfq_group_busy_queues_wl(RT_WORKLOAD, cfqd, cfqg))
-		cfqd->serving_class = RT_WORKLOAD;
+		cfqd->serving_wl_class = RT_WORKLOAD;
 	else if (cfq_group_busy_queues_wl(BE_WORKLOAD, cfqd, cfqg))
-		cfqd->serving_class = BE_WORKLOAD;
+		cfqd->serving_wl_class = BE_WORKLOAD;
 	else {
-		cfqd->serving_class = IDLE_WORKLOAD;
+		cfqd->serving_wl_class = IDLE_WORKLOAD;
 		cfqd->workload_expires = jiffies + 1;
 		return;
 	}
 
-	if (original_class != cfqd->serving_class)
+	if (original_class != cfqd->serving_wl_class)
 		goto new_workload;
 
 	/*
@@ -2544,7 +2544,8 @@ static void choose_service_tree(struct cfq_data *cfqd, struct cfq_group *cfqg)
 	 * (SYNC, SYNC_NOIDLE, ASYNC), and to compute a workload
 	 * expiration time
 	 */
-	st = service_tree_for(cfqg, cfqd->serving_class, cfqd->serving_type);
+	st = service_tree_for(cfqg, cfqd->serving_wl_class,
+					cfqd->serving_wl_type);
 	count = st->count;
 
 	/*
@@ -2555,9 +2556,10 @@ static void choose_service_tree(struct cfq_data *cfqd, struct cfq_group *cfqg)
 
 new_workload:
 	/* otherwise select new workload type */
-	cfqd->serving_type =
-		cfq_choose_wl(cfqd, cfqg, cfqd->serving_class);
-	st = service_tree_for(cfqg, cfqd->serving_class, cfqd->serving_type);
+	cfqd->serving_wl_type = cfq_choose_wl(cfqd, cfqg,
+					cfqd->serving_wl_class);
+	st = service_tree_for(cfqg, cfqd->serving_wl_class,
+					cfqd->serving_wl_type);
 	count = st->count;
 
 	/*
@@ -2568,11 +2570,11 @@ new_workload:
 	group_slice = cfq_group_slice(cfqd, cfqg);
 
 	slice = group_slice * count /
-		max_t(unsigned, cfqg->busy_queues_avg[cfqd->serving_class],
-		      cfq_group_busy_queues_wl(cfqd->serving_class, cfqd,
+		max_t(unsigned, cfqg->busy_queues_avg[cfqd->serving_wl_class],
+		      cfq_group_busy_queues_wl(cfqd->serving_wl_class, cfqd,
 					cfqg));
 
-	if (cfqd->serving_type == ASYNC_WORKLOAD) {
+	if (cfqd->serving_wl_type == ASYNC_WORKLOAD) {
 		unsigned int tmp;
 
 		/*
@@ -2618,10 +2620,10 @@ static void cfq_choose_cfqg(struct cfq_data *cfqd)
 	cfqd->serving_group = cfqg;
 
 	/* Restore the workload type data */
-	if (cfqg->saved_workload_slice) {
-		cfqd->workload_expires = jiffies + cfqg->saved_workload_slice;
-		cfqd->serving_type = cfqg->saved_workload;
-		cfqd->serving_class = cfqg->saved_serving_class;
+	if (cfqg->saved_wl_slice) {
+		cfqd->workload_expires = jiffies + cfqg->saved_wl_slice;
+		cfqd->serving_wl_type = cfqg->saved_wl_type;
+		cfqd->serving_wl_class = cfqg->saved_wl_class;
 	} else
 		cfqd->workload_expires = jiffies - 1;
 
@@ -3404,7 +3406,7 @@ cfq_should_preempt(struct cfq_data *cfqd, struct cfq_queue *new_cfqq,
 		return true;
 
 	/* Allow preemption only if we are idling on sync-noidle tree */
-	if (cfqd->serving_type == SYNC_NOIDLE_WORKLOAD &&
+	if (cfqd->serving_wl_type == SYNC_NOIDLE_WORKLOAD &&
 	    cfqq_type(new_cfqq) == SYNC_NOIDLE_WORKLOAD &&
 	    new_cfqq->service_tree->count == 2 &&
 	    RB_EMPTY_ROOT(&cfqq->sort_list))
@@ -3456,7 +3458,7 @@ static void cfq_preempt_queue(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 	 * doesn't happen
 	 */
 	if (old_type != cfqq_type(cfqq))
-		cfqq->cfqg->saved_workload_slice = 0;
+		cfqq->cfqg->saved_wl_slice = 0;
 
 	/*
 	 * Put the new queue at the front of the of the current list,
-- 
1.8.0.2
