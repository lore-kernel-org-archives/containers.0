From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 03/24] io-controller: bfq support of in-class preemption
Date: Fri, 24 Jul 2009 16:27:33 -0400
Message-ID: <1248467274-32073-4-git-send-email-vgoyal__22395.0560823598$1248467495$gmane$org@redhat.com>
References: <1248467274-32073-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248467274-32073-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

o Generally preemption is associated with cross class where if an request
  from RT class is pending it will preempt the ongoing BE or IDLE class
  request.

o CFQ also does in-class preemtions like a sync request queue preempting the
  async request queue. In that case it looks like preempting queue gains
  share and it is not fair.

o Implement the similar functionality in bfq so that we can retain the
  existing CFQ behavior.

o This patch creates a bypass path so that a queue can be put at the
  front of the service tree (add_front, similar to CFQ), so that it will
  be selected next to run. That's a different thing that in the process
  this queue gains share.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/elevator-fq.c |   46 +++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 41 insertions(+), 5 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index e5f39cf..f1ab0dc 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -267,7 +267,8 @@ static void bfq_get_entity(struct io_entity *entity)
 		elv_get_ioq(ioq);
 }
 
-static void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
+static inline void
+bfq_init_entity(struct io_entity *entity, struct io_group *iog)
 {
 	entity->sched_data = &iog->sched_data;
 }
@@ -580,7 +581,7 @@ static struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
  * service received if @entity is active) of the queue to calculate its
  * timestamps.
  */
-static void __bfq_activate_entity(struct io_entity *entity)
+static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 {
 	struct io_sched_data *sd = entity->sched_data;
 	struct io_service_tree *st = io_entity_service_tree(entity);
@@ -625,7 +626,42 @@ static void __bfq_activate_entity(struct io_entity *entity)
 	}
 
 	st = __bfq_entity_update_prio(st, entity);
-	bfq_calc_finish(entity, entity->budget);
+	/*
+	 * This is to emulate cfq like functionality where preemption can
+	 * happen with-in same class, like sync queue preempting async queue
+	 * May be this is not a very good idea from fairness point of view
+	 * as preempting queue gains share. Keeping it for now.
+	 */
+	if (add_front) {
+		struct io_entity *next_entity;
+
+		/*
+		 * Determine the entity which will be dispatched next
+		 * Use sd->next_active once hierarchical patch is applied
+		 */
+		next_entity = bfq_lookup_next_entity(sd, 0);
+
+		if (next_entity && next_entity != entity) {
+			struct io_service_tree *new_st;
+			u64 delta;
+
+			new_st = io_entity_service_tree(next_entity);
+
+			/*
+			 * At this point, both entities should belong to
+			 * same service tree as cross service tree preemption
+			 * is automatically taken care by algorithm
+			 */
+			BUG_ON(new_st != st);
+			entity->finish = next_entity->finish - 1;
+			delta = bfq_delta(entity->budget, entity->weight);
+			entity->start = entity->finish - delta;
+			if (bfq_gt(entity->start, st->vtime))
+				entity->start = st->vtime;
+		}
+	} else {
+		bfq_calc_finish(entity, entity->budget);
+	}
 	bfq_active_insert(st, entity);
 }
 
@@ -633,9 +669,9 @@ static void __bfq_activate_entity(struct io_entity *entity)
  * bfq_activate_entity - activate an entity.
  * @entity: the entity to activate.
  */
-static void bfq_activate_entity(struct io_entity *entity)
+static void bfq_activate_entity(struct io_entity *entity, int add_front)
 {
-	__bfq_activate_entity(entity);
+	__bfq_activate_entity(entity, add_front);
 }
 
 /**
-- 
1.6.0.6
