From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 03/24] cfq-iosched: Rename "service_tree" to "st" at some
	places
Date: Fri, 28 Dec 2012 12:35:25 -0800
Message-ID: <1356726946-26037-4-git-send-email-tj@kernel.org>
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

At quite a few places we use the keyword "service_tree". At some places,
especially local variables, I have abbreviated it to "st".

Also at couple of places moved binary operator "+" from beginning of line
to end of previous line, as per Tejun's feedback.

v2:
 Reverted most of the service tree name change based on Jeff Moyer's feedback.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/cfq-iosched.c | 77 +++++++++++++++++++++++++----------------------------
 1 file changed, 36 insertions(+), 41 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 8f890bf..db4a1a5 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -353,7 +353,7 @@ struct cfq_data {
 
 static struct cfq_group *cfq_get_next_cfqg(struct cfq_data *cfqd);
 
-static struct cfq_rb_root *service_tree_for(struct cfq_group *cfqg,
+static struct cfq_rb_root *st_for(struct cfq_group *cfqg,
 					    enum wl_class_t class,
 					    enum wl_type_t type)
 {
@@ -758,16 +758,16 @@ static inline int cfq_group_busy_queues_wl(enum wl_class_t wl_class,
 	if (wl_class == IDLE_WORKLOAD)
 		return cfqg->service_tree_idle.count;
 
-	return cfqg->service_trees[wl_class][ASYNC_WORKLOAD].count
-		+ cfqg->service_trees[wl_class][SYNC_NOIDLE_WORKLOAD].count
-		+ cfqg->service_trees[wl_class][SYNC_WORKLOAD].count;
+	return cfqg->service_trees[wl_class][ASYNC_WORKLOAD].count +
+		cfqg->service_trees[wl_class][SYNC_NOIDLE_WORKLOAD].count +
+		cfqg->service_trees[wl_class][SYNC_WORKLOAD].count;
 }
 
 static inline int cfqg_busy_async_queues(struct cfq_data *cfqd,
 					struct cfq_group *cfqg)
 {
-	return cfqg->service_trees[RT_WORKLOAD][ASYNC_WORKLOAD].count
-		+ cfqg->service_trees[BE_WORKLOAD][ASYNC_WORKLOAD].count;
+	return cfqg->service_trees[RT_WORKLOAD][ASYNC_WORKLOAD].count +
+		cfqg->service_trees[BE_WORKLOAD][ASYNC_WORKLOAD].count;
 }
 
 static void cfq_dispatch_insert(struct request_queue *, struct request *);
@@ -1612,15 +1612,14 @@ static void cfq_service_tree_add(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 	struct rb_node **p, *parent;
 	struct cfq_queue *__cfqq;
 	unsigned long rb_key;
-	struct cfq_rb_root *service_tree;
+	struct cfq_rb_root *st;
 	int left;
 	int new_cfqq = 1;
 
-	service_tree = service_tree_for(cfqq->cfqg, cfqq_class(cfqq),
-						cfqq_type(cfqq));
+	st = st_for(cfqq->cfqg, cfqq_class(cfqq), cfqq_type(cfqq));
 	if (cfq_class_idle(cfqq)) {
 		rb_key = CFQ_IDLE_DELAY;
-		parent = rb_last(&service_tree->rb);
+		parent = rb_last(&st->rb);
 		if (parent && parent != &cfqq->rb_node) {
 			__cfqq = rb_entry(parent, struct cfq_queue, rb_node);
 			rb_key += __cfqq->rb_key;
@@ -1638,7 +1637,7 @@ static void cfq_service_tree_add(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 		cfqq->slice_resid = 0;
 	} else {
 		rb_key = -HZ;
-		__cfqq = cfq_rb_first(service_tree);
+		__cfqq = cfq_rb_first(st);
 		rb_key += __cfqq ? __cfqq->rb_key : jiffies;
 	}
 
@@ -1647,8 +1646,7 @@ static void cfq_service_tree_add(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 		/*
 		 * same position, nothing more to do
 		 */
-		if (rb_key == cfqq->rb_key &&
-		    cfqq->service_tree == service_tree)
+		if (rb_key == cfqq->rb_key && cfqq->service_tree == st)
 			return;
 
 		cfq_rb_erase(&cfqq->rb_node, cfqq->service_tree);
@@ -1657,8 +1655,8 @@ static void cfq_service_tree_add(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 
 	left = 1;
 	parent = NULL;
-	cfqq->service_tree = service_tree;
-	p = &service_tree->rb.rb_node;
+	cfqq->service_tree = st;
+	p = &st->rb.rb_node;
 	while (*p) {
 		struct rb_node **n;
 
@@ -1679,12 +1677,12 @@ static void cfq_service_tree_add(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 	}
 
 	if (left)
-		service_tree->left = &cfqq->rb_node;
+		st->left = &cfqq->rb_node;
 
 	cfqq->rb_key = rb_key;
 	rb_link_node(&cfqq->rb_node, parent, p);
-	rb_insert_color(&cfqq->rb_node, &service_tree->rb);
-	service_tree->count++;
+	rb_insert_color(&cfqq->rb_node, &st->rb);
+	st->count++;
 	if (add_front || !new_cfqq)
 		return;
 	cfq_group_notify_queue_add(cfqd, cfqq->cfqg);
@@ -2117,19 +2115,18 @@ static inline void cfq_slice_expired(struct cfq_data *cfqd, bool timed_out)
  */
 static struct cfq_queue *cfq_get_next_queue(struct cfq_data *cfqd)
 {
-	struct cfq_rb_root *service_tree =
-		service_tree_for(cfqd->serving_group, cfqd->serving_wl_class,
-						cfqd->serving_wl_type);
+	struct cfq_rb_root *st = st_for(cfqd->serving_group,
+			cfqd->serving_wl_class, cfqd->serving_wl_type);
 
 	if (!cfqd->rq_queued)
 		return NULL;
 
 	/* There is nothing to dispatch */
-	if (!service_tree)
+	if (!st)
 		return NULL;
-	if (RB_EMPTY_ROOT(&service_tree->rb))
+	if (RB_EMPTY_ROOT(&st->rb))
 		return NULL;
-	return cfq_rb_first(service_tree);
+	return cfq_rb_first(st);
 }
 
 static struct cfq_queue *cfq_get_next_queue_forced(struct cfq_data *cfqd)
@@ -2286,10 +2283,10 @@ static struct cfq_queue *cfq_close_cooperator(struct cfq_data *cfqd,
 static bool cfq_should_idle(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 {
 	enum wl_class_t wl_class = cfqq_class(cfqq);
-	struct cfq_rb_root *service_tree = cfqq->service_tree;
+	struct cfq_rb_root *st = cfqq->service_tree;
 
-	BUG_ON(!service_tree);
-	BUG_ON(!service_tree->count);
+	BUG_ON(!st);
+	BUG_ON(!st->count);
 
 	if (!cfqd->cfq_slice_idle)
 		return false;
@@ -2307,11 +2304,10 @@ static bool cfq_should_idle(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 	 * Otherwise, we do only if they are the last ones
 	 * in their service tree.
 	 */
-	if (service_tree->count == 1 && cfq_cfqq_sync(cfqq) &&
-	   !cfq_io_thinktime_big(cfqd, &service_tree->ttime, false))
+	if (st->count == 1 && cfq_cfqq_sync(cfqq) &&
+	   !cfq_io_thinktime_big(cfqd, &st->ttime, false))
 		return true;
-	cfq_log_cfqq(cfqd, cfqq, "Not idling. st->count:%d",
-			service_tree->count);
+	cfq_log_cfqq(cfqd, cfqq, "Not idling. st->count:%d", st->count);
 	return false;
 }
 
@@ -2505,7 +2501,7 @@ static enum wl_type_t cfq_choose_wl(struct cfq_data *cfqd,
 
 	for (i = 0; i <= SYNC_WORKLOAD; ++i) {
 		/* select the one with lowest rb_key */
-		queue = cfq_rb_first(service_tree_for(cfqg, wl_class, i));
+		queue = cfq_rb_first(st_for(cfqg, wl_class, i));
 		if (queue &&
 		    (!key_valid || time_before(queue->rb_key, lowest_key))) {
 			lowest_key = queue->rb_key;
@@ -2544,8 +2540,7 @@ static void choose_service_tree(struct cfq_data *cfqd, struct cfq_group *cfqg)
 	 * (SYNC, SYNC_NOIDLE, ASYNC), and to compute a workload
 	 * expiration time
 	 */
-	st = service_tree_for(cfqg, cfqd->serving_wl_class,
-					cfqd->serving_wl_type);
+	st = st_for(cfqg, cfqd->serving_wl_class, cfqd->serving_wl_type);
 	count = st->count;
 
 	/*
@@ -2558,8 +2553,7 @@ new_workload:
 	/* otherwise select new workload type */
 	cfqd->serving_wl_type = cfq_choose_wl(cfqd, cfqg,
 					cfqd->serving_wl_class);
-	st = service_tree_for(cfqg, cfqd->serving_wl_class,
-					cfqd->serving_wl_type);
+	st = st_for(cfqg, cfqd->serving_wl_class, cfqd->serving_wl_type);
 	count = st->count;
 
 	/*
@@ -3640,16 +3634,17 @@ static void cfq_completed_request(struct request_queue *q, struct request *rq)
 	cfqd->rq_in_flight[cfq_cfqq_sync(cfqq)]--;
 
 	if (sync) {
-		struct cfq_rb_root *service_tree;
+		struct cfq_rb_root *st;
 
 		RQ_CIC(rq)->ttime.last_end_request = now;
 
 		if (cfq_cfqq_on_rr(cfqq))
-			service_tree = cfqq->service_tree;
+			st = cfqq->service_tree;
 		else
-			service_tree = service_tree_for(cfqq->cfqg,
-				cfqq_class(cfqq), cfqq_type(cfqq));
-		service_tree->ttime.last_end_request = now;
+			st = st_for(cfqq->cfqg, cfqq_class(cfqq),
+					cfqq_type(cfqq));
+
+		st->ttime.last_end_request = now;
 		if (!time_after(rq->start_time + cfqd->cfq_fifo_expire[1], now))
 			cfqd->last_delayed_sync = now;
 	}
-- 
1.8.0.2
