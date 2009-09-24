From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 03/28] io-controller: Keep a cache of recently expired queues
Date: Thu, 24 Sep 2009 15:25:07 -0400
Message-ID: <1253820332-10246-4-git-send-email-vgoyal__1327.57323231107$1253823758$gmane$org@redhat.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253820332-10246-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

o Currently once a queue uses its slice and it is empty, we remove it from the
  service tree and when a new request comes in it is queued at the end of tree.
  It works as long as there are only queue or only groups at same level but if
  there is a mix of queue and group, there can be fairness issue. For example,
  consider following case.

			root
			/ \
		       T1  G1
			    |
			    T2

 T1 and T2 are two tasks with prio 0 and 7 respectively and G1 is the group
 with weight 900.

 Task T1 prio 0 is mapped to weight 900 and it will get slice length of 180ms
 and then queue will expire and will be put after G1. (Note, in case of reader
 most liekly next request will come after queue expiry hence queue will be
 deleted and once the request comes in again, it will added to tree fresh. A
 fresh queue is added at the end of the tree. So it will be put after G1.).

 Now G1 will get to run (effectivly T2 will run), T2 has prio 7, which will
 map to weight 200 and get slice length of 40ms and will expire after that. Now
 G1 will a new vtime which is effectively charge of 40ms.

 Now to get fairness G1 should run more but instead T1 will be running as we
 gave it a vtime, same as G1.

 The core issue here is that for readers, when slice expires, queue is empty
 and not backlogged hence it gets deleted from the tree. Because CFQ only
 operates in flat mode, it did a smart thing and did not keep a track of
 history. Instead it provides slice lenghts according to prio and if in one
 round of dispatch one gets fairness it is fine, otherwise upon queue expiry
 you will be placed at the end of service tree.

 This does not work in hierarchical setups where group's slice lenght is
 determined not by group' weight but by the weight of the queue which will
 run under the group.

 Hence we need to keep track of histroy and assign a new vtime based on disk
 time used by the current queue at the time of expiry.

 But here io scheduler is little different from CFS that at the time of expiry
 most of the time reader's queue is empty. So one will end up deleting it from
 the service tree and next request comes with-in 1 ms and it gets into the tree
 again like a new process.

 So we need to keep track of process io queue's vdisktime, even it after got
 deleted from io scheduler's service tree and use that same vdisktime if that
 queue gets backlogged again. But trusting a ioq's vdisktime is bad because
 it can lead to issues if a service tree min_vtime wrap around takes place
 between two requests of the queue. (Agreed that it can be not that easy to
 hit but it is possible).

 Hence, keep a cache of io queues serviced recently and when a queue gets
 backlogged, if it is found in cache, use that vdisktime otherwise assign
 a new vdisktime. This cache of io queues (idle tree), is basically the idea
 implemented by BFQ guys. I had gotten rid of idle trees in V9 and now I am
 bringing it back. (Now I understand it better. :-)).

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/elevator-fq.c |  188 ++++++++++++++++++++++++++++++++++++++++++++++-----
 block/elevator-fq.h |    7 ++
 2 files changed, 179 insertions(+), 16 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index d98fa42..8343397 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -21,6 +21,8 @@
 #define ELV_SLICE_SCALE		(500)
 #define ELV_SERVICE_SHIFT	20
 
+static void check_idle_tree_release(struct io_service_tree *st);
+
 static inline struct io_queue *ioq_of(struct io_entity *entity)
 {
 	if (entity->my_sd == NULL)
@@ -78,6 +80,11 @@ elv_prio_to_slice(struct elv_fq_data *efqd, struct io_queue *ioq)
 	return elv_weight_slice(efqd, elv_ioq_sync(ioq), ioq->entity.weight);
 }
 
+static inline int vdisktime_gt(u64 a, u64 b)
+{
+	return (s64)(a - b) > 0;
+}
+
 static inline u64 max_vdisktime(u64 min_vdisktime, u64 vdisktime)
 {
 	s64 delta = (s64)(vdisktime - min_vdisktime);
@@ -114,6 +121,7 @@ static void update_min_vdisktime(struct io_service_tree *st)
 	}
 
 	st->min_vdisktime = max_vdisktime(st->min_vdisktime, vdisktime);
+	check_idle_tree_release(st);
 }
 
 static inline struct io_entity *parent_entity(struct io_entity *entity)
@@ -167,27 +175,46 @@ static void place_entity(struct io_service_tree *st, struct io_entity *entity,
 	struct rb_node *parent;
 	struct io_entity *entry;
 	int nr_active = st->nr_active - 1;
+	struct io_queue *ioq = ioq_of(entity);
+	int sync = 1;
+
+	if (ioq)
+		sync = elv_ioq_sync(ioq);
+
+	if (add_front || !nr_active) {
+		vdisktime = st->min_vdisktime;
+		goto done;
+	}
+
+	if (sync && entity->vdisktime
+	    && vdisktime_gt(entity->vdisktime, st->min_vdisktime)) {
+		/* vdisktime still in future. Use old vdisktime */
+		vdisktime = entity->vdisktime;
+		goto done;
+	}
 
 	/*
-	 * Currently put entity at the end of last entity. This probably will
-	 * require adjustments as we move along
+	 * Effectively a new queue. Assign sync queue a lower vdisktime so
+	 * we can achieve better latencies for small file readers. For async
+	 * queues, put them at the end of the existing queue.
+	 * Group entities are always considered sync.
 	 */
-	if (io_entity_class_idle(entity)) {
-		vdisktime = elv_delta_fair(ELV_IDLE_DELAY, entity);
-		parent = rb_last(&st->active);
-		if (parent) {
-			entry = rb_entry(parent, struct io_entity, rb_node);
-			vdisktime += entry->vdisktime;
-		}
-	} else if (!add_front && nr_active) {
-		parent = rb_last(&st->active);
-		if (parent) {
-			entry = rb_entry(parent, struct io_entity, rb_node);
-			vdisktime = entry->vdisktime;
-		}
-	} else
+	if (sync) {
 		vdisktime = st->min_vdisktime;
+		goto done;
+	}
 
+	/*
+	 * Put entity at the end of the tree. Effectively async queues use
+	 * this path.
+	 */
+	parent = rb_last(&st->active);
+	if (parent) {
+		entry = rb_entry(parent, struct io_entity, rb_node);
+		vdisktime = entry->vdisktime;
+	} else
+		vdisktime = st->min_vdisktime;
+done:
 	entity->vdisktime = max_vdisktime(st->min_vdisktime, vdisktime);
 }
 
@@ -200,6 +227,122 @@ static inline void io_entity_update_prio(struct io_entity *entity)
 		 */
 		init_io_entity_service_tree(entity, parent_entity(entity));
 		entity->ioprio_changed = 0;
+
+		/*
+		 * Assign this entity a fresh vdisktime instead of using
+		 * previous one as prio class will lead to service tree
+		 * change and this vdisktime will not be valid on new
+		 * service tree.
+		 *
+		 * TODO: Handle the case of only prio change.
+		 */
+		entity->vdisktime = 0;
+	}
+}
+
+static void
+__dequeue_io_entity_idle(struct io_service_tree *st, struct io_entity *entity)
+{
+	if (st->rb_leftmost_idle == &entity->rb_node) {
+		struct rb_node *next_node;
+
+		next_node = rb_next(&entity->rb_node);
+		st->rb_leftmost_idle = next_node;
+	}
+
+	rb_erase(&entity->rb_node, &st->idle);
+	RB_CLEAR_NODE(&entity->rb_node);
+}
+
+static void dequeue_io_entity_idle(struct io_entity *entity)
+{
+	struct io_queue *ioq = ioq_of(entity);
+
+	__dequeue_io_entity_idle(entity->st, entity);
+	entity->on_idle_st = 0;
+	if (ioq)
+		elv_put_ioq(ioq);
+}
+
+static void
+__enqueue_io_entity_idle(struct io_service_tree *st, struct io_entity *entity)
+{
+	struct rb_node **node = &st->idle.rb_node;
+	struct rb_node *parent = NULL;
+	struct io_entity *entry;
+	int leftmost = 1;
+
+	while (*node != NULL) {
+		parent = *node;
+		entry = rb_entry(parent, struct io_entity, rb_node);
+
+		if (vdisktime_gt(entry->vdisktime, entity->vdisktime))
+			node = &parent->rb_left;
+		else {
+			node = &parent->rb_right;
+			leftmost = 0;
+		}
+	}
+
+	/*
+	 * Maintain a cache of leftmost tree entries (it is frequently
+	 * used)
+	 */
+	if (leftmost)
+		st->rb_leftmost_idle = &entity->rb_node;
+
+	rb_link_node(&entity->rb_node, parent, node);
+	rb_insert_color(&entity->rb_node, &st->idle);
+}
+
+static void enqueue_io_entity_idle(struct io_entity *entity)
+{
+	struct io_queue *ioq = ioq_of(entity);
+	struct io_group *parent_iog;
+
+	/*
+	 * Don't put an entity on idle tree if it has been marked for deletion.
+	 * We are not expecting more io from this entity. No need to cache it
+	 */
+
+	if (entity->exiting)
+		return;
+
+	/*
+	 * If parent group is exiting, don't put on idle tree. May be task got
+	 * moved to a different cgroup and original cgroup got deleted
+	 */
+	parent_iog = iog_of(parent_entity(entity));
+	if (parent_iog->entity.exiting)
+		return;
+
+	if (ioq)
+		elv_get_ioq(ioq);
+	__enqueue_io_entity_idle(entity->st, entity);
+	entity->on_idle_st = 1;
+}
+
+static void check_idle_tree_release(struct io_service_tree *st)
+{
+	struct io_entity *leftmost;
+
+	if (!st->rb_leftmost_idle)
+		return;
+
+	leftmost = rb_entry(st->rb_leftmost_idle, struct io_entity, rb_node);
+
+	if (vdisktime_gt(st->min_vdisktime, leftmost->vdisktime))
+		dequeue_io_entity_idle(leftmost);
+}
+
+static void flush_idle_tree(struct io_service_tree *st)
+{
+	struct io_entity *entity;
+
+	while (st->rb_leftmost_idle) {
+		entity = rb_entry(st->rb_leftmost_idle, struct io_entity,
+					rb_node);
+		dequeue_io_entity_idle(entity);
 	}
 }
 
@@ -235,6 +378,9 @@ static void dequeue_io_entity(struct io_entity *entity)
 	entity->on_st = 0;
 	st->nr_active--;
 	sd->nr_active--;
+
+	if (vdisktime_gt(entity->vdisktime, st->min_vdisktime))
+		enqueue_io_entity_idle(entity);
 }
 
 static void
@@ -276,6 +422,16 @@ static void enqueue_io_entity(struct io_entity *entity)
 	struct io_service_tree *st;
 	struct io_sched_data *sd = io_entity_sched_data(entity);
 
+	if (entity->on_idle_st)
+		dequeue_io_entity_idle(entity);
+	else
+		/*
+		 * This entity was not in idle tree cache. Zero out vdisktime
+		 * so that we don't rely on old vdisktime instead assign a
+		 * fresh one.
+		 */
+		entity->vdisktime = 0;
+
 	io_entity_update_prio(entity);
 	st = entity->st;
 	st->nr_active++;
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 868e035..ee46a47 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -28,6 +28,10 @@ struct io_service_tree {
 	u64 min_vdisktime;
 	struct rb_node *rb_leftmost;
 	unsigned int nr_active;
+
+	/* A cache of io entities which were served and expired */
+	struct rb_root idle;
+	struct rb_node *rb_leftmost_idle;
 };
 
 struct io_sched_data {
@@ -39,9 +43,12 @@ struct io_sched_data {
 struct io_entity {
 	struct rb_node rb_node;
 	int on_st;
+	int on_idle_st;
 	u64 vdisktime;
 	unsigned int weight;
 	struct io_entity *parent;
+	/* This io entity (queue or group) has been marked for deletion */
+	unsigned int exiting;
 
 	struct io_sched_data *my_sd;
 	struct io_service_tree *st;
-- 
1.6.0.6
