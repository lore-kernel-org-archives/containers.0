From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/4] block: collapse blk_alloc_request() into get_request()
Date: Thu, 19 Apr 2012 16:29:21 -0700
Message-ID: <1334878164-24788-2-git-send-email-tj__26326.2748173021$1334878190$gmane$org@kernel.org>
References: <1334878164-24788-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1334878164-24788-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Allocation failure handling in get_request() is about to be updated.
To ease the update, collapse blk_alloc_request() into get_request().

This patch doesn't introduce any functional change.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-core.c |   46 +++++++++++++++++-----------------------------
 1 files changed, 17 insertions(+), 29 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 3b02ba3..f6f68b0 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -719,33 +719,6 @@ static inline void blk_free_request(struct request_queue *q, struct request *rq)
 	mempool_free(rq, q->rq.rq_pool);
 }
 
-static struct request *
-blk_alloc_request(struct request_queue *q, struct bio *bio, struct io_cq *icq,
-		  unsigned int flags, gfp_t gfp_mask)
-{
-	struct request *rq = mempool_alloc(q->rq.rq_pool, gfp_mask);
-
-	if (!rq)
-		return NULL;
-
-	blk_rq_init(q, rq);
-
-	rq->cmd_flags = flags | REQ_ALLOCED;
-
-	if (flags & REQ_ELVPRIV) {
-		rq->elv.icq = icq;
-		if (unlikely(elv_set_request(q, rq, bio, gfp_mask))) {
-			mempool_free(rq, q->rq.rq_pool);
-			return NULL;
-		}
-		/* @rq->elv.icq holds on to io_context until @rq is freed */
-		if (icq)
-			get_io_context(icq->ioc);
-	}
-
-	return rq;
-}
-
 /*
  * ioc_batching returns true if the ioc is a valid batching request and
  * should be given priority access to a request.
@@ -968,10 +941,25 @@ retry:
 			goto fail_alloc;
 	}
 
-	rq = blk_alloc_request(q, bio, icq, rw_flags, gfp_mask);
-	if (unlikely(!rq))
+	/* allocate and init request */
+	rq = mempool_alloc(q->rq.rq_pool, gfp_mask);
+	if (!rq)
 		goto fail_alloc;
 
+	blk_rq_init(q, rq);
+	rq->cmd_flags = rw_flags | REQ_ALLOCED;
+
+	if (rw_flags & REQ_ELVPRIV) {
+		rq->elv.icq = icq;
+		if (unlikely(elv_set_request(q, rq, bio, gfp_mask))) {
+			mempool_free(rq, q->rq.rq_pool);
+			goto fail_alloc;
+		}
+		/* @rq->elv.icq holds on to io_context until @rq is freed */
+		if (icq)
+			get_io_context(icq->ioc);
+	}
+
 	/*
 	 * ioc may be NULL here, and ioc_batching will be false. That's
 	 * OK, if the queue is under the request limit then requests need
-- 
1.7.7.3
