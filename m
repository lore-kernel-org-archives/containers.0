From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: [PATCH RFC - TAKE TWO - 11/12] block,
	bfq: boost the throughput on NCQ-capable flash-based devices
Date: Thu, 29 May 2014 11:05:42 +0200
Message-ID: <1401354343-5527-12-git-send-email-paolo.valente__43575.8874555633$1401355827$gmane$org@unimore.it>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1401354343-5527-1-git-send-email-paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch boosts the throughput on NCQ-capable flash-based devices,
while still preserving latency guarantees for interactive and soft
real-time applications. The throughput is boosted by just not idling
the device when the in-service queue remains empty, even if the queue
is sync and has a non-null idle window. This helps to keep the drive's
internal queue full, which is necessary to achieve maximum
performance. This solution to boost the throughput is a port of
commits a68bbdd and f7d7b7a for CFQ.

As already highlighted in patch 10, allowing the device to prefetch
and internally reorder requests trivially causes loss of control on
the request service order, and hence on service guarantees.
Fortunately, as discussed in detail in the comments to the function
bfq_bfqq_must_not_expire(), if every process has to receive the same
fraction of the throughput, then the service order enforced by the
internal scheduler of a flash-based device is relatively close to that
enforced by BFQ. In particular, it is close enough to let service
guarantees be substantially preserved.

Things change in an asymmetric scenario, i.e., if not every process
has to receive the same fraction of the throughput. In this case, to
guarantee the desired throughput distribution, the device must be
prevented from prefetching requests. This is exactly what this patch
does in asymmetric scenarios.

Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/bfq-cgroup.c  |   1 +
 block/bfq-iosched.c | 205 +++++++++++++++++++++++++++++++++++++++++++++++++---
 block/bfq-sched.c   |  98 ++++++++++++++++++++++++-
 block/bfq.h         |  46 ++++++++++++
 4 files changed, 338 insertions(+), 12 deletions(-)

diff --git a/block/bfq-cgroup.c b/block/bfq-cgroup.c
index 1cb25aa..d338a54 100644
--- a/block/bfq-cgroup.c
+++ b/block/bfq-cgroup.c
@@ -85,6 +85,7 @@ static inline void bfq_group_init_entity(struct bfqio_cgroup *bgrp,
 	entity->ioprio = entity->new_ioprio;
 	entity->ioprio_class = entity->new_ioprio_class = bgrp->ioprio_class;
 	entity->my_sched_data = &bfqg->sched_data;
+	bfqg->active_entities = 0;
 }
 
 static inline void bfq_group_set_parent(struct bfq_group *bfqg,
diff --git a/block/bfq-iosched.c b/block/bfq-iosched.c
index 22d4caa..49856e1 100644
--- a/block/bfq-iosched.c
+++ b/block/bfq-iosched.c
@@ -364,6 +364,120 @@ static struct request *bfq_choose_req(struct bfq_data *bfqd,
 	}
 }
 
+/*
+ * Tell whether there are active queues or groups with differentiated weights.
+ */
+static inline bool bfq_differentiated_weights(struct bfq_data *bfqd)
+{
+	/*
+	 * For weights to differ, at least one of the trees must contain
+	 * at least two nodes.
+	 */
+	return (!RB_EMPTY_ROOT(&bfqd->queue_weights_tree) &&
+		(bfqd->queue_weights_tree.rb_node->rb_left ||
+		 bfqd->queue_weights_tree.rb_node->rb_right)
+#ifdef CONFIG_CGROUP_BFQIO
+	       ) ||
+	       (!RB_EMPTY_ROOT(&bfqd->group_weights_tree) &&
+		(bfqd->group_weights_tree.rb_node->rb_left ||
+		 bfqd->group_weights_tree.rb_node->rb_right)
+#endif
+	       );
+}
+
+/*
+ * If the weight-counter tree passed as input contains no counter for
+ * the weight of the input entity, then add that counter; otherwise just
+ * increment the existing counter.
+ *
+ * Note that weight-counter trees contain few nodes in mostly symmetric
+ * scenarios. For example, if all queues have the same weight, then the
+ * weight-counter tree for the queues may contain at most one node.
+ * This holds even if low_latency is on, because weight-raised queues
+ * are not inserted in the tree.
+ * In most scenarios, the rate at which nodes are created/destroyed
+ * should be low too.
+ */
+static void bfq_weights_tree_add(struct bfq_data *bfqd,
+				 struct bfq_entity *entity,
+				 struct rb_root *root)
+{
+	struct rb_node **new = &(root->rb_node), *parent = NULL;
+
+	/*
+	 * Do not insert if:
+	 * - the device does not support queueing;
+	 * - the entity is already associated with a counter, which happens if:
+	 *   1) the entity is associated with a queue, 2) a request arrival
+	 *   has caused the queue to become both non-weight-raised, and hence
+	 *   change its weight, and backlogged; in this respect, each
+	 *   of the two events causes an invocation of this function,
+	 *   3) this is the invocation of this function caused by the second
+	 *   event. This second invocation is actually useless, and we handle
+	 *   this fact by exiting immediately. More efficient or clearer
+	 *   solutions might possibly be adopted.
+	 */
+	if (!bfqd->hw_tag || entity->weight_counter)
+		return;
+
+	while (*new) {
+		struct bfq_weight_counter *__counter = container_of(*new,
+						struct bfq_weight_counter,
+						weights_node);
+		parent = *new;
+
+		if (entity->weight == __counter->weight) {
+			entity->weight_counter = __counter;
+			goto inc_counter;
+		}
+		if (entity->weight < __counter->weight)
+			new = &((*new)->rb_left);
+		else
+			new = &((*new)->rb_right);
+	}
+
+	entity->weight_counter = kzalloc(sizeof(struct bfq_weight_counter),
+					 GFP_ATOMIC);
+	entity->weight_counter->weight = entity->weight;
+	rb_link_node(&entity->weight_counter->weights_node, parent, new);
+	rb_insert_color(&entity->weight_counter->weights_node, root);
+
+inc_counter:
+	entity->weight_counter->num_active++;
+}
+
+/*
+ * Decrement the weight counter associated with the entity, and, if the
+ * counter reaches 0, remove the counter from the tree.
+ * See the comments to the function bfq_weights_tree_add() for considerations
+ * about overhead.
+ */
+static void bfq_weights_tree_remove(struct bfq_data *bfqd,
+				    struct bfq_entity *entity,
+				    struct rb_root *root)
+{
+	/*
+	 * Check whether the entity is actually associated with a counter.
+	 * In fact, the device may not be considered NCQ-capable for a while,
+	 * which implies that no insertion in the weight trees is performed,
+	 * after which the device may start to be deemed NCQ-capable, and hence
+	 * this function may start to be invoked. This may cause the function
+	 * to be invoked for entities that are not associated with any counter.
+	 */
+	if (!entity->weight_counter)
+		return;
+
+	entity->weight_counter->num_active--;
+	if (entity->weight_counter->num_active > 0)
+		goto reset_entity_pointer;
+
+	rb_erase(&entity->weight_counter->weights_node, root);
+	kfree(entity->weight_counter);
+
+reset_entity_pointer:
+	entity->weight_counter = NULL;
+}
+
 static struct request *bfq_find_next_rq(struct bfq_data *bfqd,
 					struct bfq_queue *bfqq,
 					struct request *last)
@@ -1906,16 +2020,17 @@ static inline int bfq_may_expire_for_budg_timeout(struct bfq_queue *bfqq)
  * two conditions holds. The first condition is that the device is not
  * performing NCQ, because idling the device most certainly boosts the
  * throughput if this condition holds and bfqq has been granted a non-null
- * idle window.
+ * idle window. The second compound condition is made of the logical AND of
+ * two components.
  *
- * The second condition is that there is no weight-raised busy queue,
- * which guarantees that the device is not idled for a sync non-weight-
- * raised queue when there are busy weight-raised queues. The former is
- * then expired immediately if empty. Combined with the timestamping rules
- * of BFQ (see [1] for details), this causes sync non-weight-raised queues
- * to get a lower number of requests served, and hence to ask for a lower
- * number of requests from the request pool, before the busy weight-raised
- * queues get served again.
+ * The first component is true only if there is no weight-raised busy
+ * queue. This guarantees that the device is not idled for a sync non-
+ * weight-raised queue when there are busy weight-raised queues. The former
+ * is then expired immediately if empty. Combined with the timestamping
+ * rules of BFQ (see [1] for details), this causes sync non-weight-raised
+ * queues to get a lower number of requests served, and hence to ask for a
+ * lower number of requests from the request pool, before the busy weight-
+ * raised queues get served again.
  *
  * This is beneficial for the processes associated with weight-raised
  * queues, when the request pool is saturated (e.g., in the presence of
@@ -1932,16 +2047,76 @@ static inline int bfq_may_expire_for_budg_timeout(struct bfq_queue *bfqq)
  * weight-raised queues seems to mitigate starvation problems in the
  * presence of heavy write workloads and NCQ, and hence to guarantee a
  * higher application and system responsiveness in these hostile scenarios.
+ *
+ * If the first component of the compound condition is instead true, i.e.,
+ * there is no weight-raised busy queue, then the second component of the
+ * compound condition takes into account service-guarantee and throughput
+ * issues related to NCQ (recall that the compound condition is evaluated
+ * only if the device is detected as supporting NCQ).
+ *
+ * As for service guarantees, allowing the drive to enqueue more than one
+ * request at a time, and hence delegating de facto final scheduling
+ * decisions to the drive's internal scheduler, causes loss of control on
+ * the actual request service order. In this respect, when the drive is
+ * allowed to enqueue more than one request at a time, the service
+ * distribution enforced by the drive's internal scheduler is likely to
+ * coincide with the desired device-throughput distribution only in the
+ * following, perfectly symmetric, scenario:
+ * 1) all active queues have the same weight,
+ * 2) all active groups at the same level in the groups tree have the same
+ *    weight,
+ * 3) all active groups at the same level in the groups tree have the same
+ *    number of children.
+ *
+ * Even in such a scenario, sequential I/O may still receive a preferential
+ * treatment, but this is not likely to be a big issue with flash-based
+ * devices, because of their non-dramatic loss of throughput with random
+ * I/O.
+ *
+ * Unfortunately, keeping the necessary state for evaluating exactly the
+ * above symmetry conditions would be quite complex and time-consuming.
+ * Therefore BFQ evaluates instead the following stronger sub-conditions,
+ * for which it is much easier to maintain the needed state:
+ * 1) all active queues have the same weight,
+ * 2) all active groups have the same weight,
+ * 3) all active groups have at most one active child each.
+ * In particular, the last two conditions are always true if hierarchical
+ * support and the cgroups interface are not enabled, hence no state needs
+ * to be maintained in this case.
+ *
+ * According to the above considerations, the second component of the
+ * compound condition evaluates to true if any of the above symmetry
+ * sub-condition does not hold, or the device is not flash-based. Therefore,
+ * if also the first component is true, then idling is allowed for a sync
+ * queue. In contrast, if all the required symmetry sub-conditions hold and
+ * the device is flash-based, then the second component, and hence the
+ * whole compound condition, evaluates to false, and no idling is performed.
+ * This helps to keep the drives' internal queues full on NCQ-capable
+ * devices, and hence to boost the throughput, without causing 'almost' any
+ * loss of service guarantees. The 'almost' follows from the fact that, if
+ * the internal queue of one such device is filled while all the
+ * sub-conditions hold, but at some point in time some sub-condition stops
+ * to hold, then it may become impossible to let requests be served in the
+ * new desired order until all the requests already queued in the device
+ * have been served.
  */
 static inline bool bfq_bfqq_must_not_expire(struct bfq_queue *bfqq)
 {
 	struct bfq_data *bfqd = bfqq->bfqd;
+#ifdef CONFIG_CGROUP_BFQIO
+#define symmetric_scenario	  (!bfqd->active_numerous_groups && \
+				   !bfq_differentiated_weights(bfqd))
+#else
+#define symmetric_scenario	  (!bfq_differentiated_weights(bfqd))
+#endif
 /*
  * Condition for expiring a non-weight-raised queue (and hence not idling
  * the device).
  */
 #define cond_for_expiring_non_wr  (bfqd->hw_tag && \
-				   bfqd->wr_busy_queues > 0)
+				   (bfqd->wr_busy_queues > 0 || \
+				    (symmetric_scenario && \
+				     blk_queue_nonrot(bfqd->queue))))
 
 	return bfq_bfqq_sync(bfqq) && (
 		bfqq->wr_coeff > 1 ||
@@ -2821,6 +2996,10 @@ static void bfq_completed_request(struct request_queue *q, struct request *rq)
 	bfqd->rq_in_driver--;
 	bfqq->dispatched--;
 
+	if (!bfqq->dispatched && !bfq_bfqq_busy(bfqq))
+		bfq_weights_tree_remove(bfqd, &bfqq->entity,
+					&bfqd->queue_weights_tree);
+
 	if (sync) {
 		bfqd->sync_flight--;
 		RQ_BIC(rq)->ttime.last_end_request = jiffies;
@@ -3195,11 +3374,17 @@ static int bfq_init_queue(struct request_queue *q, struct elevator_type *e)
 
 	bfqd->root_group = bfqg;
 
+#ifdef CONFIG_CGROUP_BFQIO
+	bfqd->active_numerous_groups = 0;
+#endif
+
 	init_timer(&bfqd->idle_slice_timer);
 	bfqd->idle_slice_timer.function = bfq_idle_slice_timer;
 	bfqd->idle_slice_timer.data = (unsigned long)bfqd;
 
 	bfqd->rq_pos_tree = RB_ROOT;
+	bfqd->queue_weights_tree = RB_ROOT;
+	bfqd->group_weights_tree = RB_ROOT;
 
 	INIT_WORK(&bfqd->unplug_work, bfq_kick_queue);
 
diff --git a/block/bfq-sched.c b/block/bfq-sched.c
index 73f453b..473b36a 100644
--- a/block/bfq-sched.c
+++ b/block/bfq-sched.c
@@ -308,6 +308,15 @@ up:
 	goto up;
 }
 
+static void bfq_weights_tree_add(struct bfq_data *bfqd,
+				 struct bfq_entity *entity,
+				 struct rb_root *root);
+
+static void bfq_weights_tree_remove(struct bfq_data *bfqd,
+				    struct bfq_entity *entity,
+				    struct rb_root *root);
+
+
 /**
  * bfq_active_insert - insert an entity in the active tree of its
  *                     group/device.
@@ -324,6 +333,11 @@ static void bfq_active_insert(struct bfq_service_tree *st,
 {
 	struct bfq_queue *bfqq = bfq_entity_to_bfqq(entity);
 	struct rb_node *node = &entity->rb_node;
+#ifdef CONFIG_CGROUP_BFQIO
+	struct bfq_sched_data *sd = NULL;
+	struct bfq_group *bfqg = NULL;
+	struct bfq_data *bfqd = NULL;
+#endif
 
 	bfq_insert(&st->active, entity);
 
@@ -334,8 +348,22 @@ static void bfq_active_insert(struct bfq_service_tree *st,
 
 	bfq_update_active_tree(node);
 
+#ifdef CONFIG_CGROUP_BFQIO
+	sd = entity->sched_data;
+	bfqg = container_of(sd, struct bfq_group, sched_data);
+	bfqd = (struct bfq_data *)bfqg->bfqd;
+#endif
 	if (bfqq != NULL)
 		list_add(&bfqq->bfqq_list, &bfqq->bfqd->active_list);
+#ifdef CONFIG_CGROUP_BFQIO
+	else /* bfq_group */
+		bfq_weights_tree_add(bfqd, entity, &bfqd->group_weights_tree);
+	if (bfqg != bfqd->root_group) {
+		bfqg->active_entities++;
+		if (bfqg->active_entities == 2)
+			bfqd->active_numerous_groups++;
+	}
+#endif
 }
 
 /**
@@ -411,6 +439,11 @@ static void bfq_active_extract(struct bfq_service_tree *st,
 {
 	struct bfq_queue *bfqq = bfq_entity_to_bfqq(entity);
 	struct rb_node *node;
+#ifdef CONFIG_CGROUP_BFQIO
+	struct bfq_sched_data *sd = NULL;
+	struct bfq_group *bfqg = NULL;
+	struct bfq_data *bfqd = NULL;
+#endif
 
 	node = bfq_find_deepest(&entity->rb_node);
 	bfq_extract(&st->active, entity);
@@ -418,8 +451,23 @@ static void bfq_active_extract(struct bfq_service_tree *st,
 	if (node != NULL)
 		bfq_update_active_tree(node);
 
+#ifdef CONFIG_CGROUP_BFQIO
+	sd = entity->sched_data;
+	bfqg = container_of(sd, struct bfq_group, sched_data);
+	bfqd = (struct bfq_data *)bfqg->bfqd;
+#endif
 	if (bfqq != NULL)
 		list_del(&bfqq->bfqq_list);
+#ifdef CONFIG_CGROUP_BFQIO
+	else /* bfq_group */
+		bfq_weights_tree_remove(bfqd, entity,
+					&bfqd->group_weights_tree);
+	if (bfqg != bfqd->root_group) {
+		bfqg->active_entities--;
+		if (bfqg->active_entities == 1)
+			bfqd->active_numerous_groups--;
+	}
+#endif
 }
 
 /**
@@ -515,6 +563,23 @@ __bfq_entity_update_weight_prio(struct bfq_service_tree *old_st,
 
 	if (entity->ioprio_changed) {
 		struct bfq_queue *bfqq = bfq_entity_to_bfqq(entity);
+		unsigned short prev_weight, new_weight;
+		struct bfq_data *bfqd = NULL;
+		struct rb_root *root;
+#ifdef CONFIG_CGROUP_BFQIO
+		struct bfq_sched_data *sd;
+		struct bfq_group *bfqg;
+#endif
+
+		if (bfqq != NULL)
+			bfqd = bfqq->bfqd;
+#ifdef CONFIG_CGROUP_BFQIO
+		else {
+			sd = entity->my_sched_data;
+			bfqg = container_of(sd, struct bfq_group, sched_data);
+			bfqd = (struct bfq_data *)bfqg->bfqd;
+		}
+#endif
 
 		old_st->wsum -= entity->weight;
 
@@ -541,8 +606,31 @@ __bfq_entity_update_weight_prio(struct bfq_service_tree *old_st,
 		 * when entity->finish <= old_st->vtime).
 		 */
 		new_st = bfq_entity_service_tree(entity);
-		entity->weight = entity->orig_weight *
-				 (bfqq != NULL ? bfqq->wr_coeff : 1);
+
+		prev_weight = entity->weight;
+		new_weight = entity->orig_weight *
+			     (bfqq != NULL ? bfqq->wr_coeff : 1);
+		/*
+		 * If the weight of the entity changes, remove the entity
+		 * from its old weight counter (if there is a counter
+		 * associated with the entity), and add it to the counter
+		 * associated with its new weight.
+		 */
+		if (prev_weight != new_weight) {
+			root = bfqq ? &bfqd->queue_weights_tree :
+				      &bfqd->group_weights_tree;
+			bfq_weights_tree_remove(bfqd, entity, root);
+		}
+		entity->weight = new_weight;
+		/*
+		 * Add the entity to its weights tree only if it is
+		 * not associated with a weight-raised queue.
+		 */
+		if (prev_weight != new_weight &&
+		    (bfqq ? bfqq->wr_coeff == 1 : 1))
+			/* If we get here, root has been initialized. */
+			bfq_weights_tree_add(bfqd, entity, root);
+
 		new_st->wsum += entity->weight;
 
 		if (new_st != old_st)
@@ -976,6 +1064,9 @@ static void bfq_del_bfqq_busy(struct bfq_data *bfqd, struct bfq_queue *bfqq,
 
 	bfq_deactivate_bfqq(bfqd, bfqq, requeue);
 
+	if (!bfqq->dispatched)
+		bfq_weights_tree_remove(bfqd, &bfqq->entity,
+					&bfqd->queue_weights_tree);
 	if (bfqq->wr_coeff > 1)
 		bfqd->wr_busy_queues--;
 }
@@ -992,6 +1083,9 @@ static void bfq_add_bfqq_busy(struct bfq_data *bfqd, struct bfq_queue *bfqq)
 	bfq_mark_bfqq_busy(bfqq);
 	bfqd->busy_queues++;
 
+	if (!bfqq->dispatched && bfqq->wr_coeff == 1)
+		bfq_weights_tree_add(bfqd, &bfqq->entity,
+				     &bfqd->queue_weights_tree);
 	if (bfqq->wr_coeff > 1)
 		bfqd->wr_busy_queues++;
 }
diff --git a/block/bfq.h b/block/bfq.h
index bda1ecb3..83c828d 100644
--- a/block/bfq.h
+++ b/block/bfq.h
@@ -81,8 +81,23 @@ struct bfq_sched_data {
 };
 
 /**
+ * struct bfq_weight_counter - counter of the number of all active entities
+ *                             with a given weight.
+ * @weight: weight of the entities that this counter refers to.
+ * @num_active: number of active entities with this weight.
+ * @weights_node: weights tree member (see bfq_data's @queue_weights_tree
+ *                and @group_weights_tree).
+ */
+struct bfq_weight_counter {
+	short int weight;
+	unsigned int num_active;
+	struct rb_node weights_node;
+};
+
+/**
  * struct bfq_entity - schedulable entity.
  * @rb_node: service_tree member.
+ * @weight_counter: pointer to the weight counter associated with this entity.
  * @on_st: flag, true if the entity is on a tree (either the active or
  *         the idle one of its service_tree).
  * @finish: B-WF2Q+ finish timestamp (aka F_i).
@@ -133,6 +148,7 @@ struct bfq_sched_data {
  */
 struct bfq_entity {
 	struct rb_node rb_node;
+	struct bfq_weight_counter *weight_counter;
 
 	int on_st;
 
@@ -306,6 +322,22 @@ enum bfq_device_speed {
  * @rq_pos_tree: rbtree sorted by next_request position, used when
  *               determining if two or more queues have interleaving
  *               requests (see bfq_close_cooperator()).
+ * @active_numerous_groups: number of bfq_groups containing more than one
+ *                          active @bfq_entity.
+ * @queue_weights_tree: rbtree of weight counters of @bfq_queues, sorted by
+ *                      weight. Used to keep track of whether all @bfq_queues
+ *                     have the same weight. The tree contains one counter
+ *                     for each distinct weight associated to some active
+ *                     and not weight-raised @bfq_queue (see the comments to
+ *                      the functions bfq_weights_tree_[add|remove] for
+ *                     further details).
+ * @group_weights_tree: rbtree of non-queue @bfq_entity weight counters, sorted
+ *                      by weight. Used to keep track of whether all
+ *                     @bfq_groups have the same weight. The tree contains
+ *                     one counter for each distinct weight associated to
+ *                     some active @bfq_group (see the comments to the
+ *                     functions bfq_weights_tree_[add|remove] for further
+ *                     details).
  * @busy_queues: number of bfq_queues containing requests (including the
  *		 queue in service, even if it is idling).
  * @wr_busy_queues: number of weight-raised busy @bfq_queues.
@@ -374,6 +406,13 @@ struct bfq_data {
 	struct bfq_group *root_group;
 	struct rb_root rq_pos_tree;
 
+#ifdef CONFIG_CGROUP_BFQIO
+	int active_numerous_groups;
+#endif
+
+	struct rb_root queue_weights_tree;
+	struct rb_root group_weights_tree;
+
 	int busy_queues;
 	int wr_busy_queues;
 	int queued;
@@ -517,6 +556,11 @@ enum bfqq_expiration {
  * @my_entity: pointer to @entity, %NULL for the toplevel group; used
  *             to avoid too many special cases during group creation/
  *             migration.
+ * @active_entities: number of active entities belonging to the group;
+ *                   unused for the root group. Used to know whether there
+ *                   are groups with more than one active @bfq_entity
+ *                   (see the comments to the function
+ *                   bfq_bfqq_must_not_expire()).
  *
  * Each (device, cgroup) pair has its own bfq_group, i.e., for each cgroup
  * there is a set of bfq_groups, each one collecting the lower-level
@@ -542,6 +586,8 @@ struct bfq_group {
 	struct bfq_queue *async_idle_bfqq;
 
 	struct bfq_entity *my_entity;
+
+	int active_entities;
 };
 
 /**
-- 
1.9.2
