From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 16/33] blk-throttle: add throtl_grp->service_queue
Date: Mon,  6 May 2013 15:45:55 -0700
Message-ID: <1367880372-28312-17-git-send-email-tj__23835.7533155524$1367880574$gmane$org@kernel.org>
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

Currently, there's single service_queue per queue -
throtl_data->service_queue.  All active throtl_grp's are queued on the
queue and dispatched according to their limits.  To support hierarchy,
this will be expanded such that active throtl_grp's form a tree
anchored at throtl_data->service_queue and chained through each
intermediate throtl_grp's service_queue.

This patch adds throtl_grp->service_queue to prepare for hierarchy
support.  The initialization function - throtl_service_queue_init() -
is added and replaces the macro initializer.  The newly added
tg->service_queue isn't used yet.  Following patches will do.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index ebaaaa9..7340440 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -33,9 +33,6 @@ struct throtl_service_queue {
 	unsigned long		first_pending_disptime;	/* disptime of the first tg */
 };
 
-#define THROTL_SERVICE_QUEUE_INITIALIZER				\
-	(struct throtl_service_queue){ .pending_tree = RB_ROOT }
-
 enum tg_state_flags {
 	THROTL_TG_PENDING	= 1 << 0,	/* on parent's pending tree */
 };
@@ -60,6 +57,9 @@ struct throtl_grp {
 	/* throtl_data this group belongs to */
 	struct throtl_data *td;
 
+	/* this group's service queue */
+	struct throtl_service_queue service_queue;
+
 	/*
 	 * Dispatch time in jiffies. This is the estimated time when group
 	 * will unthrottle and is ready to dispatch more bio. It is used as
@@ -190,11 +190,18 @@ alloc_stats:
 		goto alloc_stats;
 }
 
+/* init a service_queue, assumes the caller zeroed it */
+static void throtl_service_queue_init(struct throtl_service_queue *sq)
+{
+	sq->pending_tree = RB_ROOT;
+}
+
 static void throtl_pd_init(struct blkcg_gq *blkg)
 {
 	struct throtl_grp *tg = blkg_to_tg(blkg);
 	unsigned long flags;
 
+	throtl_service_queue_init(&tg->service_queue);
 	RB_CLEAR_NODE(&tg->rb_node);
 	tg->td = blkg->q->td;
 	bio_list_init(&tg->bio_lists[0]);
@@ -1168,8 +1175,8 @@ int blk_throtl_init(struct request_queue *q)
 	if (!td)
 		return -ENOMEM;
 
-	td->service_queue = THROTL_SERVICE_QUEUE_INITIALIZER;
 	INIT_DELAYED_WORK(&td->dispatch_work, blk_throtl_dispatch_work_fn);
+	throtl_service_queue_init(&td->service_queue);
 
 	q->td = td;
 	td->queue = q;
-- 
1.8.1.4
