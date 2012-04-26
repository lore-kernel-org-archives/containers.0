From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/11] block: refactor get_request[_wait]()
Date: Thu, 26 Apr 2012 14:59:16 -0700
Message-ID: <1335477561-11131-7-git-send-email-tj@kernel.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, there are two request allocation functions - get_request()
and get_request_wait().  The former tries to allocate a request once
and the latter keeps retrying until it succeeds.  The latter wraps the
former and keeps retrying until allocation succeeds.

The combination of two functions deliver fallible non-wait allocation,
fallible wait allocation and unfailing wait allocation.  However,
given that forward progress is guaranteed, fallible wait allocation
isn't all that useful and in fact nobody uses it.

This patch simplifies the interface as follows.

* get_request() is renamed to __get_request() and is only used by the
  wrapper function.

* get_request_wait() is renamed to get_request().  It now takes
  @gfp_mask and retries iff it contains %__GFP_WAIT.

This patch doesn't introduce any functional change and is to prepare
for further updates to request allocation path.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-core.c |   74 +++++++++++++++++++++++++----------------------------
 1 files changed, 35 insertions(+), 39 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 6a04dcd..02b6cf8 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -824,7 +824,7 @@ static struct io_context *rq_ioc(struct bio *bio)
 }
 
 /**
- * get_request - get a free request
+ * __get_request - get a free request
  * @q: request_queue to allocate request from
  * @rw_flags: RW and SYNC flags
  * @bio: bio to allocate request for (can be %NULL)
@@ -837,8 +837,8 @@ static struct io_context *rq_ioc(struct bio *bio)
  * Returns %NULL on failure, with @q->queue_lock held.
  * Returns !%NULL on success, with @q->queue_lock *not held*.
  */
-static struct request *get_request(struct request_queue *q, int rw_flags,
-				   struct bio *bio, gfp_t gfp_mask)
+static struct request *__get_request(struct request_queue *q, int rw_flags,
+				     struct bio *bio, gfp_t gfp_mask)
 {
 	struct request *rq;
 	struct request_list *rl = &q->rq;
@@ -1016,56 +1016,55 @@ rq_starved:
 }
 
 /**
- * get_request_wait - get a free request with retry
+ * get_request - get a free request
  * @q: request_queue to allocate request from
  * @rw_flags: RW and SYNC flags
  * @bio: bio to allocate request for (can be %NULL)
+ * @gfp_mask: allocation mask
  *
- * Get a free request from @q.  This function keeps retrying under memory
- * pressure and fails iff @q is dead.
+ * Get a free request from @q.  If %__GFP_WAIT is set in @gfp_mask, this
+ * function keeps retrying under memory pressure and fails iff @q is dead.
  *
  * Must be callled with @q->queue_lock held and,
  * Returns %NULL on failure, with @q->queue_lock held.
  * Returns !%NULL on success, with @q->queue_lock *not held*.
  */
-static struct request *get_request_wait(struct request_queue *q, int rw_flags,
-					struct bio *bio)
+static struct request *get_request(struct request_queue *q, int rw_flags,
+				   struct bio *bio, gfp_t gfp_mask)
 {
 	const bool is_sync = rw_is_sync(rw_flags) != 0;
+	DEFINE_WAIT(wait);
+	struct request_list *rl = &q->rq;
 	struct request *rq;
+retry:
+	rq = __get_request(q, rw_flags, bio, gfp_mask);
+	if (rq)
+		return rq;
 
-	rq = get_request(q, rw_flags, bio, GFP_NOIO);
-	while (!rq) {
-		DEFINE_WAIT(wait);
-		struct request_list *rl = &q->rq;
-
-		if (unlikely(blk_queue_dead(q)))
-			return NULL;
-
-		prepare_to_wait_exclusive(&rl->wait[is_sync], &wait,
-				TASK_UNINTERRUPTIBLE);
+	if (!(gfp_mask & __GFP_WAIT) || unlikely(blk_queue_dead(q)))
+		return NULL;
 
-		trace_block_sleeprq(q, bio, rw_flags & 1);
+	/* wait on @rl and retry */
+	prepare_to_wait_exclusive(&rl->wait[is_sync], &wait,
+				  TASK_UNINTERRUPTIBLE);
 
-		spin_unlock_irq(q->queue_lock);
-		io_schedule();
+	trace_block_sleeprq(q, bio, rw_flags & 1);
 
-		/*
-		 * After sleeping, we become a "batching" process and
-		 * will be able to allocate at least one request, and
-		 * up to a big batch of them for a small period time.
-		 * See ioc_batching, ioc_set_batching
-		 */
-		create_io_context(GFP_NOIO, q->node);
-		ioc_set_batching(q, current->io_context);
+	spin_unlock_irq(q->queue_lock);
+	io_schedule();
 
-		spin_lock_irq(q->queue_lock);
-		finish_wait(&rl->wait[is_sync], &wait);
+	/*
+	 * After sleeping, we become a "batching" process and will be able
+	 * to allocate at least one request, and up to a big batch of them
+	 * for a small period time.  See ioc_batching, ioc_set_batching
+	 */
+	create_io_context(GFP_NOIO, q->node);
+	ioc_set_batching(q, current->io_context);
 
-		rq = get_request(q, rw_flags, bio, GFP_NOIO);
-	};
+	spin_lock_irq(q->queue_lock);
+	finish_wait(&rl->wait[is_sync], &wait);
 
-	return rq;
+	goto retry;
 }
 
 struct request *blk_get_request(struct request_queue *q, int rw, gfp_t gfp_mask)
@@ -1075,10 +1074,7 @@ struct request *blk_get_request(struct request_queue *q, int rw, gfp_t gfp_mask)
 	BUG_ON(rw != READ && rw != WRITE);
 
 	spin_lock_irq(q->queue_lock);
-	if (gfp_mask & __GFP_WAIT)
-		rq = get_request_wait(q, rw, NULL);
-	else
-		rq = get_request(q, rw, NULL, gfp_mask);
+	rq = get_request(q, rw, NULL, gfp_mask);
 	if (!rq)
 		spin_unlock_irq(q->queue_lock);
 	/* q->queue_lock is unlocked at this point */
@@ -1467,7 +1463,7 @@ get_rq:
 	 * Grab a free request. This is might sleep but can not fail.
 	 * Returns with the queue unlocked.
 	 */
-	req = get_request_wait(q, rw_flags, bio);
+	req = get_request(q, rw_flags, bio, GFP_NOIO);
 	if (unlikely(!req)) {
 		bio_endio(bio, -ENODEV);	/* @q is dead */
 		goto out_unlock;
-- 
1.7.7.3
