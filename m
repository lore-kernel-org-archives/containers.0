From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 05/11] block: drop custom queue draining used by
	scsi_transport_{iscsi|fc}
Date: Thu, 26 Apr 2012 14:59:15 -0700
Message-ID: <1335477561-11131-6-git-send-email-tj@kernel.org>
References: <1335477561-11131-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1335477561-11131-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, James Smart <james.smart-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

iscsi_remove_host() uses bsg_remove_queue() which implements custom
queue draining.  fc_bsg_remove() open-codes mostly identical logic.

The draining logic isn't correct in that blk_stop_queue() doesn't
prevent new requests from being queued - it just stops processing, so
nothing prevents new requests to be queued after the logic determines
that the queue is drained.

blk_cleanup_queue() now implements proper queue draining and these
custom draining logics aren't necessary.  Drop them and use
bsg_unregister_queue() + blk_cleanup_queue() instead.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Cc: James Smart <james.smart-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org>
---
 block/bsg-lib.c                     |   53 -----------------------------------
 drivers/scsi/scsi_transport_fc.c    |   38 -------------------------
 drivers/scsi/scsi_transport_iscsi.c |    2 +-
 include/linux/bsg-lib.h             |    1 -
 4 files changed, 1 insertions(+), 93 deletions(-)

diff --git a/block/bsg-lib.c b/block/bsg-lib.c
index 7ad49c8..deee61f 100644
--- a/block/bsg-lib.c
+++ b/block/bsg-lib.c
@@ -243,56 +243,3 @@ int bsg_setup_queue(struct device *dev, struct request_queue *q,
 	return 0;
 }
 EXPORT_SYMBOL_GPL(bsg_setup_queue);
-
-/**
- * bsg_remove_queue - Deletes the bsg dev from the q
- * @q:	the request_queue that is to be torn down.
- *
- * Notes:
- *   Before unregistering the queue empty any requests that are blocked
- */
-void bsg_remove_queue(struct request_queue *q)
-{
-	struct request *req; /* block request */
-	int counts; /* totals for request_list count and starved */
-
-	if (!q)
-		return;
-
-	/* Stop taking in new requests */
-	spin_lock_irq(q->queue_lock);
-	blk_stop_queue(q);
-
-	/* drain all requests in the queue */
-	while (1) {
-		/* need the lock to fetch a request
-		 * this may fetch the same reqeust as the previous pass
-		 */
-		req = blk_fetch_request(q);
-		/* save requests in use and starved */
-		counts = q->rq.count[0] + q->rq.count[1] +
-			 q->rq.starved[0] + q->rq.starved[1];
-		spin_unlock_irq(q->queue_lock);
-		/* any requests still outstanding? */
-		if (counts == 0)
-			break;
-
-		/* This may be the same req as the previous iteration,
-		 * always send the blk_end_request_all after a prefetch.
-		 * It is not okay to not end the request because the
-		 * prefetch started the request.
-		 */
-		if (req) {
-			/* return -ENXIO to indicate that this queue is
-			 * going away
-			 */
-			req->errors = -ENXIO;
-			blk_end_request_all(req, -ENXIO);
-		}
-
-		msleep(200); /* allow bsg to possibly finish */
-		spin_lock_irq(q->queue_lock);
-	}
-	bsg_unregister_queue(q);
-}
-EXPORT_SYMBOL_GPL(bsg_remove_queue);
diff --git a/drivers/scsi/scsi_transport_fc.c b/drivers/scsi/scsi_transport_fc.c
index 80fbe2a..3aff3db 100644
--- a/drivers/scsi/scsi_transport_fc.c
+++ b/drivers/scsi/scsi_transport_fc.c
@@ -4126,45 +4126,7 @@ fc_bsg_rportadd(struct Scsi_Host *shost, struct fc_rport *rport)
 static void
 fc_bsg_remove(struct request_queue *q)
 {
-	struct request *req; /* block request */
-	int counts; /* totals for request_list count and starved */
-
 	if (q) {
-		/* Stop taking in new requests */
-		spin_lock_irq(q->queue_lock);
-		blk_stop_queue(q);
-
-		/* drain all requests in the queue */
-		while (1) {
-			/* need the lock to fetch a request
-			 * this may fetch the same reqeust as the previous pass
-			 */
-			req = blk_fetch_request(q);
-			/* save requests in use and starved */
-			counts = q->rq.count[0] + q->rq.count[1] +
-				q->rq.starved[0] + q->rq.starved[1];
-			spin_unlock_irq(q->queue_lock);
-			/* any requests still outstanding? */
-			if (counts == 0)
-				break;
-
-			/* This may be the same req as the previous iteration,
-			 * always send the blk_end_request_all after a prefetch.
-			 * It is not okay to not end the request because the
-			 * prefetch started the request.
-			 */
-			if (req) {
-				/* return -ENXIO to indicate that this queue is
-				 * going away
-				 */
-				req->errors = -ENXIO;
-				blk_end_request_all(req, -ENXIO);
-			}
-
-			msleep(200); /* allow bsg to possibly finish */
-			spin_lock_irq(q->queue_lock);
-		}
-
 		bsg_unregister_queue(q);
 		blk_cleanup_queue(q);
 	}
diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index 1cf640e..c737a16 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -575,7 +575,7 @@ static int iscsi_remove_host(struct transport_container *tc,
 	struct iscsi_cls_host *ihost = shost->shost_data;
 
 	if (ihost->bsg_q) {
-		bsg_remove_queue(ihost->bsg_q);
+		bsg_unregister_queue(ihost->bsg_q);
 		blk_cleanup_queue(ihost->bsg_q);
 	}
 	return 0;
diff --git a/include/linux/bsg-lib.h b/include/linux/bsg-lib.h
index f55ab8c..4d0fb3d 100644
--- a/include/linux/bsg-lib.h
+++ b/include/linux/bsg-lib.h
@@ -67,7 +67,6 @@ void bsg_job_done(struct bsg_job *job, int result,
 int bsg_setup_queue(struct device *dev, struct request_queue *q, char *name,
 		    bsg_job_fn *job_fn, int dd_job_size);
 void bsg_request_fn(struct request_queue *q);
-void bsg_remove_queue(struct request_queue *q);
 void bsg_goose_queue(struct request_queue *q);
 
 #endif
-- 
1.7.7.3
