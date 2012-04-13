From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 07/11] blkcg: make request_queue bypassing on allocation
Date: Fri, 13 Apr 2012 13:11:31 -0700
Message-ID: <1334347895-6268-8-git-send-email-tj@kernel.org>
References: <1334347895-6268-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1334347895-6268-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

With the previous change to guarantee bypass visiblity for RCU read
lock regions, entering bypass mode involves non-trivial overhead and
future changes are scheduled to make use of bypass mode during init
path.  Combined it may end up adding noticeable delay during boot.

This patch makes request_queue start its life in bypass mode, which is
ended on queue init completion at the end of
blk_init_allocated_queue(), and updates blk_queue_bypass_start() such
that draining and RCU synchronization are performed only when the
queue actually enters bypass mode.

This avoids unnecessarily switching in and out of bypass mode during
init avoiding the overhead and any nasty surprises which may step from
leaving bypass mode on half-initialized queues.

The boot time overhead was pointed out by Vivek.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-core.c |   37 +++++++++++++++++++++++++------------
 1 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index a4b3eaf..86027cd 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -421,14 +421,18 @@ void blk_drain_queue(struct request_queue *q, bool drain_all)
  */
 void blk_queue_bypass_start(struct request_queue *q)
 {
+	bool drain;
+
 	spin_lock_irq(q->queue_lock);
-	q->bypass_depth++;
+	drain = !q->bypass_depth++;
 	queue_flag_set(QUEUE_FLAG_BYPASS, q);
 	spin_unlock_irq(q->queue_lock);
 
-	blk_drain_queue(q, false);
-	/* ensure blk_queue_bypass() is %true inside RCU read lock */
-	synchronize_rcu();
+	if (drain) {
+		blk_drain_queue(q, false);
+		/* ensure blk_queue_bypass() is %true inside RCU read lock */
+		synchronize_rcu();
+	}
 }
 EXPORT_SYMBOL_GPL(blk_queue_bypass_start);
 
@@ -569,6 +573,15 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 	 */
 	q->queue_lock = &q->__queue_lock;
 
+	/*
+	 * A queue starts its life with bypass turned on to avoid
+	 * unnecessary bypass on/off overhead and nasty surprises during
+	 * init.  The initial bypass will be finished at the end of
+	 * blk_init_allocated_queue().
+	 */
+	q->bypass_depth = 1;
+	__set_bit(QUEUE_FLAG_BYPASS, &q->queue_flags);
+
 	if (blkcg_init_queue(q))
 		goto fail_id;
 
@@ -664,15 +677,15 @@ blk_init_allocated_queue(struct request_queue *q, request_fn_proc *rfn,
 
 	q->sg_reserved_size = INT_MAX;
 
-	/*
-	 * all done
-	 */
-	if (!elevator_init(q, NULL)) {
-		blk_queue_congestion_threshold(q);
-		return q;
-	}
+	/* init elevator */
+	if (elevator_init(q, NULL))
+		return NULL;
 
-	return NULL;
+	blk_queue_congestion_threshold(q);
+
+	/* all done, end the initial bypass */
+	blk_queue_bypass_end(q);
+	return q;
 }
 EXPORT_SYMBOL(blk_init_allocated_queue);
 
-- 
1.7.7.3
