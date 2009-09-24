From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 05/28] io-controller: Modify cfq to make use of flat elevator
	fair queuing
Date: Thu, 24 Sep 2009 15:25:09 -0400
Message-ID: <1253820332-10246-6-git-send-email-vgoyal__19039.5757359967$1253821759$gmane$org@redhat.com>
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

This patch changes cfq to use fair queuing code from elevator layer.

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched |    3 +-
 block/cfq-iosched.c   |  981 +++++++++++--------------------------------------
 2 files changed, 218 insertions(+), 766 deletions(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index 3398134..dd5224d 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -3,7 +3,7 @@ if BLOCK
 menu "IO Schedulers"
 
 config ELV_FAIR_QUEUING
-	bool "Elevator Fair Queuing Support"
+	bool
 	default n
 	---help---
 	  Traditionally only cfq had notion of multiple queues and it did
@@ -46,6 +46,7 @@ config IOSCHED_DEADLINE
 
 config IOSCHED_CFQ
 	tristate "CFQ I/O scheduler"
+	select ELV_FAIR_QUEUING
 	default y
 	---help---
 	  The CFQ I/O scheduler tries to distribute bandwidth equally
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 5a67ec0..3e24c03 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -12,6 +12,7 @@
 #include <linux/rbtree.h>
 #include <linux/ioprio.h>
 #include <linux/blktrace_api.h>
+#include "elevator-fq.h"
 
 /*
  * tunables
@@ -23,17 +24,10 @@ static const int cfq_fifo_expire[2] = { HZ / 4, HZ / 8 };
 static const int cfq_back_max = 16 * 1024;
 /* penalty of a backwards seek */
 static const int cfq_back_penalty = 2;
-static const int cfq_slice_sync = HZ / 10;
-static int cfq_slice_async = HZ / 25;
 static const int cfq_slice_async_rq = 2;
 static int cfq_slice_idle = HZ / 125;
 
 /*
- * offset from end of service tree
- */
-#define CFQ_IDLE_DELAY		(HZ / 5)
-
-/*
  * below this threshold, we consider thinktime immediate
  */
 #define CFQ_MIN_TT		(2)
@@ -43,7 +37,7 @@ static int cfq_slice_idle = HZ / 125;
 
 #define RQ_CIC(rq)		\
 	((struct cfq_io_context *) (rq)->elevator_private)
-#define RQ_CFQQ(rq)		(struct cfq_queue *) ((rq)->elevator_private2)
+#define RQ_CFQQ(rq)	(struct cfq_queue *) (elv_ioq_sched_queue((rq)->ioq))
 
 static struct kmem_cache *cfq_pool;
 static struct kmem_cache *cfq_ioc_pool;
@@ -53,8 +47,6 @@ static struct completion *ioc_gone;
 static DEFINE_SPINLOCK(ioc_gone_lock);
 
 #define CFQ_PRIO_LISTS		IOPRIO_BE_NR
-#define cfq_class_idle(cfqq)	((cfqq)->ioprio_class == IOPRIO_CLASS_IDLE)
-#define cfq_class_rt(cfqq)	((cfqq)->ioprio_class == IOPRIO_CLASS_RT)
 
 #define sample_valid(samples)	((samples) > 80)
 
@@ -74,16 +66,11 @@ struct cfq_rb_root {
  * Per process-grouping structure
  */
 struct cfq_queue {
-	/* reference count */
-	atomic_t ref;
+	struct io_queue *ioq;
 	/* various state flags, see below */
 	unsigned int flags;
 	/* parent cfq_data */
 	struct cfq_data *cfqd;
-	/* service_tree member */
-	struct rb_node rb_node;
-	/* service_tree key */
-	unsigned long rb_key;
 	/* prio tree member */
 	struct rb_node p_node;
 	/* prio tree root we belong to, if any */
@@ -99,18 +86,13 @@ struct cfq_queue {
 	/* fifo list of requests in sort_list */
 	struct list_head fifo;
 
-	unsigned long slice_end;
-	long slice_resid;
 	unsigned int slice_dispatch;
 
 	/* pending metadata requests */
 	int meta_pending;
-	/* number of requests that are on the dispatch list or inside driver */
-	int dispatched;
 
 	/* io prio of this group */
-	unsigned short ioprio, org_ioprio;
-	unsigned short ioprio_class, org_ioprio_class;
+	unsigned short org_ioprio, org_ioprio_class;
 
 	pid_t pid;
 };
@@ -120,12 +102,6 @@ struct cfq_queue {
  */
 struct cfq_data {
 	struct request_queue *queue;
-
-	/*
-	 * rr list of queues with requests and the count of them
-	 */
-	struct cfq_rb_root service_tree;
-
 	/*
 	 * Each priority tree is sorted by next_request position.  These
 	 * trees are used when determining if two or more queues are
@@ -133,14 +109,6 @@ struct cfq_data {
 	 */
 	struct rb_root prio_trees[CFQ_PRIO_LISTS];
 
-	unsigned int busy_queues;
-	/*
-	 * Used to track any pending rt requests so we can pre-empt current
-	 * non-RT cfqq in service when this value is non-zero.
-	 */
-	unsigned int busy_rt_queues;
-
-	int rq_in_driver;
 	int sync_flight;
 
 	/*
@@ -151,21 +119,8 @@ struct cfq_data {
 	int hw_tag_samples;
 	int rq_in_driver_peak;
 
-	/*
-	 * idle window management
-	 */
-	struct timer_list idle_slice_timer;
-	struct work_struct unplug_work;
-
-	struct cfq_queue *active_queue;
 	struct cfq_io_context *active_cic;
 
-	/*
-	 * async queue for each priority case
-	 */
-	struct cfq_queue *async_cfqq[2][IOPRIO_BE_NR];
-	struct cfq_queue *async_idle_cfqq;
-
 	sector_t last_position;
 
 	/*
@@ -175,7 +130,6 @@ struct cfq_data {
 	unsigned int cfq_fifo_expire[2];
 	unsigned int cfq_back_penalty;
 	unsigned int cfq_back_max;
-	unsigned int cfq_slice[2];
 	unsigned int cfq_slice_async_rq;
 	unsigned int cfq_slice_idle;
 
@@ -188,16 +142,10 @@ struct cfq_data {
 };
 
 enum cfqq_state_flags {
-	CFQ_CFQQ_FLAG_on_rr = 0,	/* on round-robin busy list */
-	CFQ_CFQQ_FLAG_wait_request,	/* waiting for a request */
-	CFQ_CFQQ_FLAG_must_dispatch,	/* must be allowed a dispatch */
 	CFQ_CFQQ_FLAG_must_alloc,	/* must be allowed rq alloc */
 	CFQ_CFQQ_FLAG_must_alloc_slice,	/* per-slice must_alloc flag */
 	CFQ_CFQQ_FLAG_fifo_expire,	/* FIFO checked in this slice */
-	CFQ_CFQQ_FLAG_idle_window,	/* slice idling enabled */
 	CFQ_CFQQ_FLAG_prio_changed,	/* task priority has changed */
-	CFQ_CFQQ_FLAG_slice_new,	/* no requests dispatched in slice */
-	CFQ_CFQQ_FLAG_sync,		/* synchronous queue */
 	CFQ_CFQQ_FLAG_coop,		/* has done a coop jump of the queue */
 };
 
@@ -215,16 +163,10 @@ static inline int cfq_cfqq_##name(const struct cfq_queue *cfqq)		\
 	return ((cfqq)->flags & (1 << CFQ_CFQQ_FLAG_##name)) != 0;	\
 }
 
-CFQ_CFQQ_FNS(on_rr);
-CFQ_CFQQ_FNS(wait_request);
-CFQ_CFQQ_FNS(must_dispatch);
 CFQ_CFQQ_FNS(must_alloc);
 CFQ_CFQQ_FNS(must_alloc_slice);
 CFQ_CFQQ_FNS(fifo_expire);
-CFQ_CFQQ_FNS(idle_window);
 CFQ_CFQQ_FNS(prio_changed);
-CFQ_CFQQ_FNS(slice_new);
-CFQ_CFQQ_FNS(sync);
 CFQ_CFQQ_FNS(coop);
 #undef CFQ_CFQQ_FNS
 
@@ -263,66 +205,27 @@ static inline int cfq_bio_sync(struct bio *bio)
 	return 0;
 }
 
-/*
- * scheduler run of queue, if there are requests pending and no one in the
- * driver that will restart queueing
- */
-static inline void cfq_schedule_dispatch(struct cfq_data *cfqd)
+static inline struct io_group *cfqq_to_io_group(struct cfq_queue *cfqq)
 {
-	if (cfqd->busy_queues) {
-		cfq_log(cfqd, "schedule dispatch");
-		kblockd_schedule_work(cfqd->queue, &cfqd->unplug_work);
-	}
+	return ioq_to_io_group(cfqq->ioq);
 }
 
-static int cfq_queue_empty(struct request_queue *q)
+static inline int cfq_class_idle(struct cfq_queue *cfqq)
 {
-	struct cfq_data *cfqd = q->elevator->elevator_data;
-
-	return !cfqd->busy_queues;
+	return elv_ioq_class_idle(cfqq->ioq);
 }
 
-/*
- * Scale schedule slice based on io priority. Use the sync time slice only
- * if a queue is marked sync and has sync io queued. A sync queue with async
- * io only, should not get full sync slice length.
- */
-static inline int cfq_prio_slice(struct cfq_data *cfqd, int sync,
-				 unsigned short prio)
+static inline int cfq_cfqq_sync(struct cfq_queue *cfqq)
 {
-	const int base_slice = cfqd->cfq_slice[sync];
-
-	WARN_ON(prio >= IOPRIO_BE_NR);
-
-	return base_slice + (base_slice/CFQ_SLICE_SCALE * (4 - prio));
+	return elv_ioq_sync(cfqq->ioq);
 }
 
-static inline int
-cfq_prio_to_slice(struct cfq_data *cfqd, struct cfq_queue *cfqq)
+static inline int cfqq_is_active_queue(struct cfq_queue *cfqq)
 {
-	return cfq_prio_slice(cfqd, cfq_cfqq_sync(cfqq), cfqq->ioprio);
-}
-
-static inline void
-cfq_set_prio_slice(struct cfq_data *cfqd, struct cfq_queue *cfqq)
-{
-	cfqq->slice_end = cfq_prio_to_slice(cfqd, cfqq) + jiffies;
-	cfq_log_cfqq(cfqd, cfqq, "set_slice=%lu", cfqq->slice_end - jiffies);
-}
-
-/*
- * We need to wrap this check in cfq_cfqq_slice_new(), since ->slice_end
- * isn't valid until the first request from the dispatch is activated
- * and the slice time set.
- */
-static inline int cfq_slice_used(struct cfq_queue *cfqq)
-{
-	if (cfq_cfqq_slice_new(cfqq))
-		return 0;
-	if (time_before(jiffies, cfqq->slice_end))
-		return 0;
+	struct cfq_data *cfqd = cfqq->cfqd;
+	struct elevator_queue *e = cfqd->queue->elevator;
 
-	return 1;
+	return (elv_active_sched_queue(e) == cfqq);
 }
 
 /*
@@ -421,33 +324,6 @@ cfq_choose_req(struct cfq_data *cfqd, struct request *rq1, struct request *rq2)
 }
 
 /*
- * The below is leftmost cache rbtree addon
- */
-static struct cfq_queue *cfq_rb_first(struct cfq_rb_root *root)
-{
-	if (!root->left)
-		root->left = rb_first(&root->rb);
-
-	if (root->left)
-		return rb_entry(root->left, struct cfq_queue, rb_node);
-
-	return NULL;
-}
-
-static void rb_erase_init(struct rb_node *n, struct rb_root *root)
-{
-	rb_erase(n, root);
-	RB_CLEAR_NODE(n);
-}
-
-static void cfq_rb_erase(struct rb_node *n, struct cfq_rb_root *root)
-{
-	if (root->left == n)
-		root->left = NULL;
-	rb_erase_init(n, &root->rb);
-}
-
-/*
  * would be nice to take fifo expire time into account as well
  */
 static struct request *
@@ -474,95 +350,6 @@ cfq_find_next_rq(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 	return cfq_choose_req(cfqd, next, prev);
 }
 
-static unsigned long cfq_slice_offset(struct cfq_data *cfqd,
-				      struct cfq_queue *cfqq)
-{
-	/*
-	 * just an approximation, should be ok.
-	 */
-	return (cfqd->busy_queues - 1) * (cfq_prio_slice(cfqd, 1, 0) -
-		       cfq_prio_slice(cfqd, cfq_cfqq_sync(cfqq), cfqq->ioprio));
-}
-
-/*
- * The cfqd->service_tree holds all pending cfq_queue's that have
- * requests waiting to be processed. It is sorted in the order that
- * we will service the queues.
- */
-static void cfq_service_tree_add(struct cfq_data *cfqd, struct cfq_queue *cfqq,
-				 int add_front)
-{
-	struct rb_node **p, *parent;
-	struct cfq_queue *__cfqq;
-	unsigned long rb_key;
-	int left;
-
-	if (cfq_class_idle(cfqq)) {
-		rb_key = CFQ_IDLE_DELAY;
-		parent = rb_last(&cfqd->service_tree.rb);
-		if (parent && parent != &cfqq->rb_node) {
-			__cfqq = rb_entry(parent, struct cfq_queue, rb_node);
-			rb_key += __cfqq->rb_key;
-		} else
-			rb_key += jiffies;
-	} else if (!add_front) {
-		rb_key = cfq_slice_offset(cfqd, cfqq) + jiffies;
-		rb_key += cfqq->slice_resid;
-		cfqq->slice_resid = 0;
-	} else
-		rb_key = 0;
-
-	if (!RB_EMPTY_NODE(&cfqq->rb_node)) {
-		/*
-		 * same position, nothing more to do
-		 */
-		if (rb_key == cfqq->rb_key)
-			return;
-
-		cfq_rb_erase(&cfqq->rb_node, &cfqd->service_tree);
-	}
-
-	left = 1;
-	parent = NULL;
-	p = &cfqd->service_tree.rb.rb_node;
-	while (*p) {
-		struct rb_node **n;
-
-		parent = *p;
-		__cfqq = rb_entry(parent, struct cfq_queue, rb_node);
-
-		/*
-		 * sort RT queues first, we always want to give
-		 * preference to them. IDLE queues goes to the back.
-		 * after that, sort on the next service time.
-		 */
-		if (cfq_class_rt(cfqq) > cfq_class_rt(__cfqq))
-			n = &(*p)->rb_left;
-		else if (cfq_class_rt(cfqq) < cfq_class_rt(__cfqq))
-			n = &(*p)->rb_right;
-		else if (cfq_class_idle(cfqq) < cfq_class_idle(__cfqq))
-			n = &(*p)->rb_left;
-		else if (cfq_class_idle(cfqq) > cfq_class_idle(__cfqq))
-			n = &(*p)->rb_right;
-		else if (rb_key < __cfqq->rb_key)
-			n = &(*p)->rb_left;
-		else
-			n = &(*p)->rb_right;
-
-		if (n == &(*p)->rb_right)
-			left = 0;
-
-		p = n;
-	}
-
-	if (left)
-		cfqd->service_tree.left = &cfqq->rb_node;
-
-	cfqq->rb_key = rb_key;
-	rb_link_node(&cfqq->rb_node, parent, p);
-	rb_insert_color(&cfqq->rb_node, &cfqd->service_tree.rb);
-}
-
 static struct cfq_queue *
 cfq_prio_tree_lookup(struct cfq_data *cfqd, struct rb_root *root,
 		     sector_t sector, struct rb_node **ret_parent,
@@ -624,57 +411,43 @@ static void cfq_prio_tree_add(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 		cfqq->p_root = NULL;
 }
 
-/*
- * Update cfqq's position in the service tree.
- */
-static void cfq_resort_rr_list(struct cfq_data *cfqd, struct cfq_queue *cfqq)
+/* An active ioq is being reset. A chance to do cic related stuff. */
+static void cfq_active_ioq_reset(struct request_queue *q, void *sched_queue)
 {
-	/*
-	 * Resorting requires the cfqq to be on the RR list already.
-	 */
-	if (cfq_cfqq_on_rr(cfqq)) {
-		cfq_service_tree_add(cfqd, cfqq, 0);
-		cfq_prio_tree_add(cfqd, cfqq);
-	}
-}
+	struct cfq_data *cfqd = q->elevator->elevator_data;
+	struct cfq_queue *cfqq = sched_queue;
 
-/*
- * add to busy list of queues for service, trying to be fair in ordering
- * the pending list according to last request service
- */
-static void cfq_add_cfqq_rr(struct cfq_data *cfqd, struct cfq_queue *cfqq)
-{
-	cfq_log_cfqq(cfqd, cfqq, "add_to_rr");
-	BUG_ON(cfq_cfqq_on_rr(cfqq));
-	cfq_mark_cfqq_on_rr(cfqq);
-	cfqd->busy_queues++;
-	if (cfq_class_rt(cfqq))
-		cfqd->busy_rt_queues++;
+	if (cfqd->active_cic) {
+		put_io_context(cfqd->active_cic->ioc);
+		cfqd->active_cic = NULL;
+	}
 
-	cfq_resort_rr_list(cfqd, cfqq);
+	/* Resort the cfqq in prio tree */
+	if (cfqq)
+		cfq_prio_tree_add(cfqd, cfqq);
 }
 
-/*
- * Called when the cfqq no longer has requests pending, remove it from
- * the service tree.
- */
-static void cfq_del_cfqq_rr(struct cfq_data *cfqd, struct cfq_queue *cfqq)
+/* An ioq has been set as active one. */
+static void cfq_active_ioq_set(struct request_queue *q, void *sched_queue,
+				int coop)
 {
-	cfq_log_cfqq(cfqd, cfqq, "del_from_rr");
-	BUG_ON(!cfq_cfqq_on_rr(cfqq));
-	cfq_clear_cfqq_on_rr(cfqq);
+	struct cfq_queue *cfqq = sched_queue;
 
-	if (!RB_EMPTY_NODE(&cfqq->rb_node))
-		cfq_rb_erase(&cfqq->rb_node, &cfqd->service_tree);
-	if (cfqq->p_root) {
-		rb_erase(&cfqq->p_node, cfqq->p_root);
-		cfqq->p_root = NULL;
-	}
+	cfqq->slice_dispatch = 0;
+
+	cfq_clear_cfqq_must_alloc_slice(cfqq);
+	cfq_clear_cfqq_fifo_expire(cfqq);
 
-	BUG_ON(!cfqd->busy_queues);
-	cfqd->busy_queues--;
-	if (cfq_class_rt(cfqq))
-		cfqd->busy_rt_queues--;
+	/*
+	 * If queue was selected because it was a close cooperator, then
+	 * mark it so that it is not selected again and again. Otherwise
+	 * clear the coop flag so that it becomes eligible to get selected
+	 * again.
+	 */
+	if (coop)
+		cfq_mark_cfqq_coop(cfqq);
+	else
+		cfq_clear_cfqq_coop(cfqq);
 }
 
 /*
@@ -683,7 +456,6 @@ static void cfq_del_cfqq_rr(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 static void cfq_del_rq_rb(struct request *rq)
 {
 	struct cfq_queue *cfqq = RQ_CFQQ(rq);
-	struct cfq_data *cfqd = cfqq->cfqd;
 	const int sync = rq_is_sync(rq);
 
 	BUG_ON(!cfqq->queued[sync]);
@@ -691,8 +463,17 @@ static void cfq_del_rq_rb(struct request *rq)
 
 	elv_rb_del(&cfqq->sort_list, rq);
 
-	if (cfq_cfqq_on_rr(cfqq) && RB_EMPTY_ROOT(&cfqq->sort_list))
-		cfq_del_cfqq_rr(cfqd, cfqq);
+	/*
+	 * If this was last request in the queue, remove this queue from
+	 * prio trees. For last request nr_queued count will still be 1 as
+	 * elevator fair queuing layer is yet to do the accounting.
+	 */
+	if (elv_ioq_nr_queued(cfqq->ioq) == 1) {
+		if (cfqq->p_root) {
+			rb_erase(&cfqq->p_node, cfqq->p_root);
+			cfqq->p_root = NULL;
+		}
+	}
 }
 
 static void cfq_add_rq_rb(struct request *rq)
@@ -710,9 +491,6 @@ static void cfq_add_rq_rb(struct request *rq)
 	while ((__alias = elv_rb_add(&cfqq->sort_list, rq)) != NULL)
 		cfq_dispatch_insert(cfqd->queue, __alias);
 
-	if (!cfq_cfqq_on_rr(cfqq))
-		cfq_add_cfqq_rr(cfqd, cfqq);
-
 	/*
 	 * check if this request is a better next-serve candidate
 	 */
@@ -720,7 +498,9 @@ static void cfq_add_rq_rb(struct request *rq)
 	cfqq->next_rq = cfq_choose_req(cfqd, cfqq->next_rq, rq);
 
 	/*
-	 * adjust priority tree position, if ->next_rq changes
+	 * adjust priority tree position, if ->next_rq changes. This should
+	 * also take care of adding a new queue to prio tree as if this is
+	 * first request then prev would be null and cfqq->next_rq will not.
 	 */
 	if (prev != cfqq->next_rq)
 		cfq_prio_tree_add(cfqd, cfqq);
@@ -760,23 +540,9 @@ static void cfq_activate_request(struct request_queue *q, struct request *rq)
 {
 	struct cfq_data *cfqd = q->elevator->elevator_data;
 
-	cfqd->rq_in_driver++;
-	cfq_log_cfqq(cfqd, RQ_CFQQ(rq), "activate rq, drv=%d",
-						cfqd->rq_in_driver);
-
 	cfqd->last_position = blk_rq_pos(rq) + blk_rq_sectors(rq);
 }
 
-static void cfq_deactivate_request(struct request_queue *q, struct request *rq)
-{
-	struct cfq_data *cfqd = q->elevator->elevator_data;
-
-	WARN_ON(!cfqd->rq_in_driver);
-	cfqd->rq_in_driver--;
-	cfq_log_cfqq(cfqd, RQ_CFQQ(rq), "deactivate rq, drv=%d",
-						cfqd->rq_in_driver);
-}
-
 static void cfq_remove_request(struct request *rq)
 {
 	struct cfq_queue *cfqq = RQ_CFQQ(rq);
@@ -861,93 +627,21 @@ static int cfq_allow_merge(struct request_queue *q, struct request *rq,
 	return 0;
 }
 
-static void __cfq_set_active_queue(struct cfq_data *cfqd,
-				   struct cfq_queue *cfqq)
-{
-	if (cfqq) {
-		cfq_log_cfqq(cfqd, cfqq, "set_active");
-		cfqq->slice_end = 0;
-		cfqq->slice_dispatch = 0;
-
-		cfq_clear_cfqq_wait_request(cfqq);
-		cfq_clear_cfqq_must_dispatch(cfqq);
-		cfq_clear_cfqq_must_alloc_slice(cfqq);
-		cfq_clear_cfqq_fifo_expire(cfqq);
-		cfq_mark_cfqq_slice_new(cfqq);
-
-		del_timer(&cfqd->idle_slice_timer);
-	}
-
-	cfqd->active_queue = cfqq;
-}
-
 /*
  * current cfqq expired its slice (or was too idle), select new one
  */
 static void
-__cfq_slice_expired(struct cfq_data *cfqd, struct cfq_queue *cfqq,
-		    int timed_out)
+__cfq_slice_expired(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 {
-	cfq_log_cfqq(cfqd, cfqq, "slice expired t=%d", timed_out);
-
-	if (cfq_cfqq_wait_request(cfqq))
-		del_timer(&cfqd->idle_slice_timer);
-
-	cfq_clear_cfqq_wait_request(cfqq);
-
-	/*
-	 * store what was left of this slice, if the queue idled/timed out
-	 */
-	if (timed_out && !cfq_cfqq_slice_new(cfqq)) {
-		cfqq->slice_resid = cfqq->slice_end - jiffies;
-		cfq_log_cfqq(cfqd, cfqq, "resid=%ld", cfqq->slice_resid);
-	}
-
-	cfq_resort_rr_list(cfqd, cfqq);
-
-	if (cfqq == cfqd->active_queue)
-		cfqd->active_queue = NULL;
-
-	if (cfqd->active_cic) {
-		put_io_context(cfqd->active_cic->ioc);
-		cfqd->active_cic = NULL;
-	}
+	elv_ioq_slice_expired(cfqd->queue, cfqq->ioq);
 }
 
-static inline void cfq_slice_expired(struct cfq_data *cfqd, int timed_out)
+static inline void cfq_slice_expired(struct cfq_data *cfqd)
 {
-	struct cfq_queue *cfqq = cfqd->active_queue;
+	struct cfq_queue *cfqq = elv_active_sched_queue(cfqd->queue->elevator);
 
 	if (cfqq)
-		__cfq_slice_expired(cfqd, cfqq, timed_out);
-}
-
-/*
- * Get next queue for service. Unless we have a queue preemption,
- * we'll simply select the first cfqq in the service tree.
- */
-static struct cfq_queue *cfq_get_next_queue(struct cfq_data *cfqd)
-{
-	if (RB_EMPTY_ROOT(&cfqd->service_tree.rb))
-		return NULL;
-
-	return cfq_rb_first(&cfqd->service_tree);
-}
-
-/*
- * Get and set a new active queue for service.
- */
-static struct cfq_queue *cfq_set_active_queue(struct cfq_data *cfqd,
-					      struct cfq_queue *cfqq)
-{
-	if (!cfqq) {
-		cfqq = cfq_get_next_queue(cfqd);
-		if (cfqq)
-			cfq_clear_cfqq_coop(cfqq);
-	}
-
-	__cfq_set_active_queue(cfqd, cfqq);
-	return cfqq;
+		__cfq_slice_expired(cfqd, cfqq);
 }
 
 static inline sector_t cfq_dist_from_last(struct cfq_data *cfqd,
@@ -1024,11 +718,11 @@ static struct cfq_queue *cfqq_close(struct cfq_data *cfqd,
  * associated with the I/O issued by cur_cfqq.  I'm not sure this is a valid
  * assumption.
  */
-static struct cfq_queue *cfq_close_cooperator(struct cfq_data *cfqd,
-					      struct cfq_queue *cur_cfqq,
-					      int probe)
+static struct io_queue *cfq_close_cooperator(struct request_queue *q,
+					      void *cur_sched_queue)
 {
-	struct cfq_queue *cfqq;
+	struct cfq_queue *cur_cfqq = cur_sched_queue, *cfqq;
+	struct cfq_data *cfqd = q->elevator->elevator_data;
 
 	/*
 	 * A valid cfq_io_context is necessary to compare requests against
@@ -1049,14 +743,13 @@ static struct cfq_queue *cfq_close_cooperator(struct cfq_data *cfqd,
 	if (cfq_cfqq_coop(cfqq))
 		return NULL;
 
-	if (!probe)
-		cfq_mark_cfqq_coop(cfqq);
-	return cfqq;
+	return cfqq->ioq;
 }
 
-static void cfq_arm_slice_timer(struct cfq_data *cfqd)
+static void cfq_arm_slice_timer(struct request_queue *q, void *sched_queue)
 {
-	struct cfq_queue *cfqq = cfqd->active_queue;
+	struct cfq_data *cfqd = q->elevator->elevator_data;
+	struct cfq_queue *cfqq = sched_queue;
 	struct cfq_io_context *cic;
 	unsigned long sl;
 
@@ -1069,18 +762,18 @@ static void cfq_arm_slice_timer(struct cfq_data *cfqd)
 		return;
 
 	WARN_ON(!RB_EMPTY_ROOT(&cfqq->sort_list));
-	WARN_ON(cfq_cfqq_slice_new(cfqq));
+	WARN_ON(elv_ioq_slice_new(cfqq->ioq));
 
 	/*
 	 * idle is disabled, either manually or by past process history
 	 */
-	if (!cfqd->cfq_slice_idle || !cfq_cfqq_idle_window(cfqq))
+	if (!cfqd->cfq_slice_idle || !elv_ioq_idle_window(cfqq->ioq))
 		return;
 
 	/*
 	 * still requests with the driver, don't idle
 	 */
-	if (cfqd->rq_in_driver)
+	if (elv_rq_in_driver(q->elevator))
 		return;
 
 	/*
@@ -1090,7 +783,7 @@ static void cfq_arm_slice_timer(struct cfq_data *cfqd)
 	if (!cic || !atomic_read(&cic->ioc->nr_tasks))
 		return;
 
-	cfq_mark_cfqq_wait_request(cfqq);
+	elv_mark_ioq_wait_request(cfqq->ioq);
 
 	/*
 	 * we don't want to idle for seeks, but we do want to allow
@@ -1101,7 +794,7 @@ static void cfq_arm_slice_timer(struct cfq_data *cfqd)
 	if (sample_valid(cic->seek_samples) && CIC_SEEKY(cic))
 		sl = min(sl, msecs_to_jiffies(CFQ_MIN_TT));
 
-	mod_timer(&cfqd->idle_slice_timer, jiffies + sl);
+	elv_mod_idle_slice_timer(q->elevator, jiffies + sl);
 	cfq_log_cfqq(cfqd, cfqq, "arm_idle: %lu", sl);
 }
 
@@ -1113,10 +806,9 @@ static void cfq_dispatch_insert(struct request_queue *q, struct request *rq)
 	struct cfq_data *cfqd = q->elevator->elevator_data;
 	struct cfq_queue *cfqq = RQ_CFQQ(rq);
 
-	cfq_log_cfqq(cfqd, cfqq, "dispatch_insert");
+	cfq_log_cfqq(cfqd, cfqq, "dispatch_insert sect=%d", blk_rq_sectors(rq));
 
 	cfq_remove_request(rq);
-	cfqq->dispatched++;
 	elv_dispatch_sort(q, rq);
 
 	if (cfq_cfqq_sync(cfqq))
@@ -1154,78 +846,11 @@ static inline int
 cfq_prio_to_maxrq(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 {
 	const int base_rq = cfqd->cfq_slice_async_rq;
+	unsigned short ioprio = elv_ioq_ioprio(cfqq->ioq);
 
-	WARN_ON(cfqq->ioprio >= IOPRIO_BE_NR);
+	WARN_ON(ioprio >= IOPRIO_BE_NR);
 
-	return 2 * (base_rq + base_rq * (CFQ_PRIO_LISTS - 1 - cfqq->ioprio));
-}
-
-/*
- * Select a queue for service. If we have a current active queue,
- * check whether to continue servicing it, or retrieve and set a new one.
- */
-static struct cfq_queue *cfq_select_queue(struct cfq_data *cfqd)
-{
-	struct cfq_queue *cfqq, *new_cfqq = NULL;
-
-	cfqq = cfqd->active_queue;
-	if (!cfqq)
-		goto new_queue;
-
-	/*
-	 * The active queue has run out of time, expire it and select new.
-	 */
-	if (cfq_slice_used(cfqq) && !cfq_cfqq_must_dispatch(cfqq))
-		goto expire;
-
-	/*
-	 * If we have a RT cfqq waiting, then we pre-empt the current non-rt
-	 * cfqq.
-	 */
-	if (!cfq_class_rt(cfqq) && cfqd->busy_rt_queues) {
-		/*
-		 * We simulate this as cfqq timed out so that it gets to bank
-		 * the remaining of its time slice.
-		 */
-		cfq_log_cfqq(cfqd, cfqq, "preempt");
-		cfq_slice_expired(cfqd, 1);
-		goto new_queue;
-	}
-
-	/*
-	 * The active queue has requests and isn't expired, allow it to
-	 * dispatch.
-	 */
-	if (!RB_EMPTY_ROOT(&cfqq->sort_list))
-		goto keep_queue;
-
-	/*
-	 * If another queue has a request waiting within our mean seek
-	 * distance, let it run.  The expire code will check for close
-	 * cooperators and put the close queue at the front of the service
-	 * tree.
-	 */
-	new_cfqq = cfq_close_cooperator(cfqd, cfqq, 0);
-	if (new_cfqq)
-		goto expire;
-
-	/*
-	 * No requests pending. If the active queue still has requests in
-	 * flight or is idling for a new request, allow either of these
-	 * conditions to happen (or time out) before selecting a new queue.
-	 */
-	if (timer_pending(&cfqd->idle_slice_timer) ||
-	    (cfqq->dispatched && cfq_cfqq_idle_window(cfqq))) {
-		cfqq = NULL;
-		goto keep_queue;
-	}
-
-expire:
-	cfq_slice_expired(cfqd, 0);
-new_queue:
-	cfqq = cfq_set_active_queue(cfqd, new_cfqq);
-keep_queue:
-	return cfqq;
+	return 2 * (base_rq + base_rq * (CFQ_PRIO_LISTS - 1 - ioprio));
 }
 
 static int __cfq_forced_dispatch_cfqq(struct cfq_queue *cfqq)
@@ -1250,12 +875,14 @@ static int cfq_forced_dispatch(struct cfq_data *cfqd)
 	struct cfq_queue *cfqq;
 	int dispatched = 0;
 
-	while ((cfqq = cfq_rb_first(&cfqd->service_tree)) != NULL)
+	while ((cfqq = elv_select_sched_queue(cfqd->queue, 1)) != NULL)
 		dispatched += __cfq_forced_dispatch_cfqq(cfqq);
 
-	cfq_slice_expired(cfqd, 0);
+	/* This probably is redundant now. above loop will should make sure
+	 * that all the busy queues have expired */
+	cfq_slice_expired(cfqd);
 
-	BUG_ON(cfqd->busy_queues);
+	BUG_ON(elv_nr_busy_ioq(cfqd->queue->elevator));
 
 	cfq_log(cfqd, "forced_dispatch=%d", dispatched);
 	return dispatched;
@@ -1301,13 +928,10 @@ static int cfq_dispatch_requests(struct request_queue *q, int force)
 	struct cfq_queue *cfqq;
 	unsigned int max_dispatch;
 
-	if (!cfqd->busy_queues)
-		return 0;
-
 	if (unlikely(force))
 		return cfq_forced_dispatch(cfqd);
 
-	cfqq = cfq_select_queue(cfqd);
+	cfqq = elv_select_sched_queue(q, 0);
 	if (!cfqq)
 		return 0;
 
@@ -1324,7 +948,7 @@ static int cfq_dispatch_requests(struct request_queue *q, int force)
 	/*
 	 * Does this cfqq already have too much IO in flight?
 	 */
-	if (cfqq->dispatched >= max_dispatch) {
+	if (elv_ioq_nr_dispatched(cfqq->ioq) >= max_dispatch) {
 		/*
 		 * idle queue must always only have a single IO in flight
 		 */
@@ -1334,13 +958,13 @@ static int cfq_dispatch_requests(struct request_queue *q, int force)
 		/*
 		 * We have other queues, don't allow more IO from this one
 		 */
-		if (cfqd->busy_queues > 1)
+		if (elv_nr_busy_ioq(q->elevator) > 1)
 			return 0;
 
 		/*
 		 * we are the only queue, allow up to 4 times of 'quantum'
 		 */
-		if (cfqq->dispatched >= 4 * max_dispatch)
+		if (elv_ioq_nr_dispatched(cfqq->ioq) >= 4 * max_dispatch)
 			return 0;
 	}
 
@@ -1349,51 +973,45 @@ static int cfq_dispatch_requests(struct request_queue *q, int force)
 	 */
 	cfq_dispatch_request(cfqd, cfqq);
 	cfqq->slice_dispatch++;
-	cfq_clear_cfqq_must_dispatch(cfqq);
 
 	/*
 	 * expire an async queue immediately if it has used up its slice. idle
 	 * queue always expire after 1 dispatch round.
 	 */
-	if (cfqd->busy_queues > 1 && ((!cfq_cfqq_sync(cfqq) &&
+	if (elv_nr_busy_ioq(q->elevator) > 1 && ((!cfq_cfqq_sync(cfqq) &&
 	    cfqq->slice_dispatch >= cfq_prio_to_maxrq(cfqd, cfqq)) ||
 	    cfq_class_idle(cfqq))) {
-		cfqq->slice_end = jiffies + 1;
-		cfq_slice_expired(cfqd, 0);
+		cfq_slice_expired(cfqd);
 	}
 
 	cfq_log(cfqd, "dispatched a request");
 	return 1;
 }
 
-/*
- * task holds one reference to the queue, dropped when task exits. each rq
- * in-flight on this queue also holds a reference, dropped when rq is freed.
- *
- * queue lock must be held here.
- */
-static void cfq_put_queue(struct cfq_queue *cfqq)
+static void cfq_free_cfq_queue(struct elevator_queue *e, void *sched_queue)
 {
+	struct cfq_queue *cfqq = sched_queue;
 	struct cfq_data *cfqd = cfqq->cfqd;
 
-	BUG_ON(atomic_read(&cfqq->ref) <= 0);
-
-	if (!atomic_dec_and_test(&cfqq->ref))
-		return;
+	BUG_ON(!cfqq);
 
-	cfq_log_cfqq(cfqd, cfqq, "put_queue");
+	cfq_log_cfqq(cfqd, cfqq, "free_queue");
 	BUG_ON(rb_first(&cfqq->sort_list));
 	BUG_ON(cfqq->allocated[READ] + cfqq->allocated[WRITE]);
-	BUG_ON(cfq_cfqq_on_rr(cfqq));
 
-	if (unlikely(cfqd->active_queue == cfqq)) {
-		__cfq_slice_expired(cfqd, cfqq, 0);
-		cfq_schedule_dispatch(cfqd);
+	if (unlikely(cfqq_is_active_queue(cfqq))) {
+		__cfq_slice_expired(cfqd, cfqq);
+		elv_schedule_dispatch(cfqd->queue);
 	}
 
 	kmem_cache_free(cfq_pool, cfqq);
 }
 
+static inline void cfq_put_queue(struct cfq_queue *cfqq)
+{
+	elv_put_ioq(cfqq->ioq);
+}
+
 /*
  * Must always be called with the rcu_read_lock() held
  */
@@ -1481,11 +1099,12 @@ static void cfq_free_io_context(struct io_context *ioc)
 
 static void cfq_exit_cfqq(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 {
-	if (unlikely(cfqq == cfqd->active_queue)) {
-		__cfq_slice_expired(cfqd, cfqq, 0);
-		cfq_schedule_dispatch(cfqd);
+	if (unlikely(cfqq == elv_active_sched_queue(cfqd->queue->elevator))) {
+		__cfq_slice_expired(cfqd, cfqq);
+		elv_schedule_dispatch(cfqd->queue);
 	}
 
+	elv_exit_ioq(cfqq->ioq);
 	cfq_put_queue(cfqq);
 }
 
@@ -1571,7 +1190,7 @@ cfq_alloc_io_context(struct cfq_data *cfqd, gfp_t gfp_mask)
 static void cfq_init_prio_data(struct cfq_queue *cfqq, struct io_context *ioc)
 {
 	struct task_struct *tsk = current;
-	int ioprio_class;
+	int ioprio_class, ioprio;
 
 	if (!cfq_cfqq_prio_changed(cfqq))
 		return;
@@ -1584,30 +1203,33 @@ static void cfq_init_prio_data(struct cfq_queue *cfqq, struct io_context *ioc)
 		/*
 		 * no prio set, inherit CPU scheduling settings
 		 */
-		cfqq->ioprio = task_nice_ioprio(tsk);
-		cfqq->ioprio_class = task_nice_ioclass(tsk);
+		ioprio = task_nice_ioprio(tsk);
+		ioprio_class = task_nice_ioclass(tsk);
 		break;
 	case IOPRIO_CLASS_RT:
-		cfqq->ioprio = task_ioprio(ioc);
-		cfqq->ioprio_class = IOPRIO_CLASS_RT;
+		ioprio = task_ioprio(ioc);
+		ioprio_class = IOPRIO_CLASS_RT;
 		break;
 	case IOPRIO_CLASS_BE:
-		cfqq->ioprio = task_ioprio(ioc);
-		cfqq->ioprio_class = IOPRIO_CLASS_BE;
+		ioprio = task_ioprio(ioc);
+		ioprio_class = IOPRIO_CLASS_BE;
 		break;
 	case IOPRIO_CLASS_IDLE:
-		cfqq->ioprio_class = IOPRIO_CLASS_IDLE;
-		cfqq->ioprio = 7;
-		cfq_clear_cfqq_idle_window(cfqq);
+		ioprio_class = IOPRIO_CLASS_IDLE;
+		ioprio = 7;
+		elv_clear_ioq_idle_window(cfqq->ioq);
 		break;
 	}
 
+	elv_ioq_set_ioprio_class(cfqq->ioq, ioprio_class);
+	elv_ioq_set_ioprio(cfqq->ioq, ioprio);
+
 	/*
 	 * keep track of original prio settings in case we have to temporarily
 	 * elevate the priority of this queue
 	 */
-	cfqq->org_ioprio = cfqq->ioprio;
-	cfqq->org_ioprio_class = cfqq->ioprio_class;
+	cfqq->org_ioprio = ioprio;
+	cfqq->org_ioprio_class = ioprio_class;
 	cfq_clear_cfqq_prio_changed(cfqq);
 }
 
@@ -1649,19 +1271,17 @@ static void cfq_ioc_set_ioprio(struct io_context *ioc)
 static void cfq_init_cfqq(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 			  pid_t pid, int is_sync)
 {
-	RB_CLEAR_NODE(&cfqq->rb_node);
 	RB_CLEAR_NODE(&cfqq->p_node);
 	INIT_LIST_HEAD(&cfqq->fifo);
 
-	atomic_set(&cfqq->ref, 0);
 	cfqq->cfqd = cfqd;
 
 	cfq_mark_cfqq_prio_changed(cfqq);
 
 	if (is_sync) {
 		if (!cfq_class_idle(cfqq))
-			cfq_mark_cfqq_idle_window(cfqq);
-		cfq_mark_cfqq_sync(cfqq);
+			elv_mark_ioq_idle_window(cfqq->ioq);
+		elv_mark_ioq_sync(cfqq->ioq);
 	}
 	cfqq->pid = pid;
 }
@@ -1672,8 +1292,13 @@ cfq_find_alloc_queue(struct cfq_data *cfqd, int is_sync,
 {
 	struct cfq_queue *cfqq, *new_cfqq = NULL;
 	struct cfq_io_context *cic;
+	struct request_queue *q = cfqd->queue;
+	struct io_queue *ioq = NULL, *new_ioq = NULL;
+	struct io_group *iog = NULL;
 
 retry:
+	iog = elv_io_get_io_group(q, 0);
+
 	cic = cfq_cic_lookup(cfqd, ioc);
 	/* cic always exists here */
 	cfqq = cic_to_cfqq(cic, is_sync);
@@ -1683,8 +1308,29 @@ retry:
 	 * originally, since it should just be a temporary situation.
 	 */
 	if (!cfqq || cfqq == &cfqd->oom_cfqq) {
+		/* Allocate ioq object first and then cfqq */
+		if (new_ioq) {
+			goto alloc_cfqq;
+		} else if (gfp_mask & __GFP_WAIT) {
+			spin_unlock_irq(cfqd->queue->queue_lock);
+			new_ioq = elv_alloc_ioq(q, gfp_mask | __GFP_ZERO);
+			spin_lock_irq(cfqd->queue->queue_lock);
+			if (new_ioq)
+				goto retry;
+		} else
+			ioq = elv_alloc_ioq(q, gfp_mask | __GFP_ZERO);
+
+alloc_cfqq:
+		if (!ioq && !new_ioq) {
+			/* ioq allocation failed. Deafult to oom_cfqq */
+			cfqq = &cfqd->oom_cfqq;
+			goto out;
+		}
+
 		cfqq = NULL;
 		if (new_cfqq) {
+			ioq = new_ioq;
+			new_ioq = NULL;
 			cfqq = new_cfqq;
 			new_cfqq = NULL;
 		} else if (gfp_mask & __GFP_WAIT) {
@@ -1702,60 +1348,59 @@ retry:
 		}
 
 		if (cfqq) {
+			elv_init_ioq(q->elevator, ioq, current->pid, is_sync);
+			elv_init_ioq_sched_queue(q->elevator, ioq, cfqq);
+
+			cfqq->ioq = ioq;
 			cfq_init_cfqq(cfqd, cfqq, current->pid, is_sync);
 			cfq_init_prio_data(cfqq, ioc);
+
+			/* call it after cfq has initialized queue prio */
+			elv_init_ioq_io_group(ioq, iog);
 			cfq_log_cfqq(cfqd, cfqq, "alloced");
-		} else
+		} else {
 			cfqq = &cfqd->oom_cfqq;
+			/* If ioq allocation was successful, free it up */
+			if (ioq)
+				elv_free_ioq(ioq);
+		}
 	}
 
+	if (new_ioq)
+		elv_free_ioq(new_ioq);
+
 	if (new_cfqq)
 		kmem_cache_free(cfq_pool, new_cfqq);
 
+out:
 	return cfqq;
 }
 
-static struct cfq_queue **
-cfq_async_queue_prio(struct cfq_data *cfqd, int ioprio_class, int ioprio)
-{
-	switch (ioprio_class) {
-	case IOPRIO_CLASS_RT:
-		return &cfqd->async_cfqq[0][ioprio];
-	case IOPRIO_CLASS_BE:
-		return &cfqd->async_cfqq[1][ioprio];
-	case IOPRIO_CLASS_IDLE:
-		return &cfqd->async_idle_cfqq;
-	default:
-		BUG();
-	}
-}
-
 static struct cfq_queue *
 cfq_get_queue(struct cfq_data *cfqd, int is_sync, struct io_context *ioc,
 	      gfp_t gfp_mask)
 {
 	const int ioprio = task_ioprio(ioc);
 	const int ioprio_class = task_ioprio_class(ioc);
-	struct cfq_queue **async_cfqq = NULL;
+	struct cfq_queue *async_cfqq = NULL;
 	struct cfq_queue *cfqq = NULL;
+	struct io_group *iog = elv_io_get_io_group(cfqd->queue, 0);
 
 	if (!is_sync) {
-		async_cfqq = cfq_async_queue_prio(cfqd, ioprio_class, ioprio);
-		cfqq = *async_cfqq;
+		async_cfqq = elv_io_group_async_queue_prio(iog, ioprio_class,
+								ioprio);
+		cfqq = async_cfqq;
 	}
 
 	if (!cfqq)
 		cfqq = cfq_find_alloc_queue(cfqd, is_sync, ioc, gfp_mask);
 
-	/*
-	 * pin the queue now that it's allocated, scheduler exit will prune it
-	 */
-	if (!is_sync && !(*async_cfqq)) {
-		atomic_inc(&cfqq->ref);
-		*async_cfqq = cfqq;
-	}
+	if (!is_sync && !async_cfqq)
+		elv_io_group_set_async_queue(iog, ioprio_class, ioprio,
+							cfqq->ioq);
 
-	atomic_inc(&cfqq->ref);
+	/* ioc reference */
+	elv_get_ioq(cfqq->ioq);
 	return cfqq;
 }
 
@@ -1960,7 +1605,7 @@ cfq_update_idle_window(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 	if (!cfq_cfqq_sync(cfqq) || cfq_class_idle(cfqq))
 		return;
 
-	enable_idle = old_idle = cfq_cfqq_idle_window(cfqq);
+	enable_idle = old_idle = elv_ioq_idle_window(cfqq->ioq);
 
 	if (!atomic_read(&cic->ioc->nr_tasks) || !cfqd->cfq_slice_idle ||
 	    (cfqd->hw_tag && CIC_SEEKY(cic)))
@@ -1975,9 +1620,9 @@ cfq_update_idle_window(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 	if (old_idle != enable_idle) {
 		cfq_log_cfqq(cfqd, cfqq, "idle=%d", enable_idle);
 		if (enable_idle)
-			cfq_mark_cfqq_idle_window(cfqq);
+			elv_mark_ioq_idle_window(cfqq->ioq);
 		else
-			cfq_clear_cfqq_idle_window(cfqq);
+			elv_clear_ioq_idle_window(cfqq->ioq);
 	}
 }
 
@@ -1986,16 +1631,15 @@ cfq_update_idle_window(struct cfq_data *cfqd, struct cfq_queue *cfqq,
  * no or if we aren't sure, a 1 will cause a preempt.
  */
 static int
-cfq_should_preempt(struct cfq_data *cfqd, struct cfq_queue *new_cfqq,
-		   struct request *rq)
+cfq_should_preempt(struct request_queue *q, void *new_cfqq, struct request *rq)
 {
-	struct cfq_queue *cfqq;
+	struct cfq_data *cfqd = q->elevator->elevator_data;
+	struct cfq_queue *cfqq = elv_active_sched_queue(q->elevator);
 
-	cfqq = cfqd->active_queue;
 	if (!cfqq)
 		return 0;
 
-	if (cfq_slice_used(cfqq))
+	if (elv_ioq_slice_used(cfqq->ioq))
 		return 1;
 
 	if (cfq_class_idle(new_cfqq))
@@ -2018,13 +1662,7 @@ cfq_should_preempt(struct cfq_data *cfqd, struct cfq_queue *new_cfqq,
 	if (rq_is_meta(rq) && !cfqq->meta_pending)
 		return 1;
 
-	/*
-	 * Allow an RT request to pre-empt an ongoing non-RT cfqq timeslice.
-	 */
-	if (cfq_class_rt(new_cfqq) && !cfq_class_rt(cfqq))
-		return 1;
-
-	if (!cfqd->active_cic || !cfq_cfqq_wait_request(cfqq))
+	if (!cfqd->active_cic || !elv_ioq_wait_request(cfqq->ioq))
 		return 0;
 
 	/*
@@ -2038,27 +1676,6 @@ cfq_should_preempt(struct cfq_data *cfqd, struct cfq_queue *new_cfqq,
 }
 
 /*
- * cfqq preempts the active queue. if we allowed preempt with no slice left,
- * let it have half of its nominal slice.
- */
-static void cfq_preempt_queue(struct cfq_data *cfqd, struct cfq_queue *cfqq)
-{
-	cfq_log_cfqq(cfqd, cfqq, "preempt");
-	cfq_slice_expired(cfqd, 1);
-
-	/*
-	 * Put the new queue at the front of the of the current list,
-	 * so we know that it will be selected next.
-	 */
-	BUG_ON(!cfq_cfqq_on_rr(cfqq));
-
-	cfq_service_tree_add(cfqd, cfqq, 1);
-
-	cfqq->slice_end = 0;
-	cfq_mark_cfqq_slice_new(cfqq);
-}
-
-/*
  * Called when a new fs request (rq) is added (to cfqq). Check if there's
  * something we should do about it
  */
@@ -2077,36 +1694,6 @@ cfq_rq_enqueued(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 	cfq_update_idle_window(cfqd, cfqq, cic);
 
 	cic->last_request_pos = blk_rq_pos(rq) + blk_rq_sectors(rq);
-
-	if (cfqq == cfqd->active_queue) {
-		/*
-		 * Remember that we saw a request from this process, but
-		 * don't start queuing just yet. Otherwise we risk seeing lots
-		 * of tiny requests, because we disrupt the normal plugging
-		 * and merging. If the request is already larger than a single
-		 * page, let it rip immediately. For that case we assume that
-		 * merging is already done. Ditto for a busy system that
-		 * has other work pending, don't risk delaying until the
-		 * idle timer unplug to continue working.
-		 */
-		if (cfq_cfqq_wait_request(cfqq)) {
-			if (blk_rq_bytes(rq) > PAGE_CACHE_SIZE ||
-			    cfqd->busy_queues > 1) {
-				del_timer(&cfqd->idle_slice_timer);
-			__blk_run_queue(cfqd->queue);
-			}
-			cfq_mark_cfqq_must_dispatch(cfqq);
-		}
-	} else if (cfq_should_preempt(cfqd, cfqq, rq)) {
-		/*
-		 * not the active queue - expire current slice if it is
-		 * idle and has expired it's mean thinktime or this new queue
-		 * has some old slice time left and is of higher priority or
-		 * this new queue is RT and the current one is BE
-		 */
-		cfq_preempt_queue(cfqd, cfqq);
-		__blk_run_queue(cfqd->queue);
-	}
 }
 
 static void cfq_insert_request(struct request_queue *q, struct request *rq)
@@ -2130,11 +1717,13 @@ static void cfq_insert_request(struct request_queue *q, struct request *rq)
  */
 static void cfq_update_hw_tag(struct cfq_data *cfqd)
 {
-	if (cfqd->rq_in_driver > cfqd->rq_in_driver_peak)
-		cfqd->rq_in_driver_peak = cfqd->rq_in_driver;
+	struct elevator_queue *eq = cfqd->queue->elevator;
+
+	if (elv_rq_in_driver(eq) > cfqd->rq_in_driver_peak)
+		cfqd->rq_in_driver_peak = elv_rq_in_driver(eq);
 
 	if (cfqd->rq_queued <= CFQ_HW_QUEUE_MIN &&
-	    cfqd->rq_in_driver <= CFQ_HW_QUEUE_MIN)
+	    elv_rq_in_driver(eq) <= CFQ_HW_QUEUE_MIN)
 		return;
 
 	if (cfqd->hw_tag_samples++ < 50)
@@ -2161,44 +1750,10 @@ static void cfq_completed_request(struct request_queue *q, struct request *rq)
 
 	cfq_update_hw_tag(cfqd);
 
-	WARN_ON(!cfqd->rq_in_driver);
-	WARN_ON(!cfqq->dispatched);
-	cfqd->rq_in_driver--;
-	cfqq->dispatched--;
-
 	if (cfq_cfqq_sync(cfqq))
 		cfqd->sync_flight--;
-
 	if (sync)
 		RQ_CIC(rq)->last_end_request = now;
-
-	/*
-	 * If this is the active queue, check if it needs to be expired,
-	 * or if we want to idle in case it has no pending requests.
-	 */
-	if (cfqd->active_queue == cfqq) {
-		const bool cfqq_empty = RB_EMPTY_ROOT(&cfqq->sort_list);
-
-		if (cfq_cfqq_slice_new(cfqq)) {
-			cfq_set_prio_slice(cfqd, cfqq);
-			cfq_clear_cfqq_slice_new(cfqq);
-		}
-		/*
-		 * If there are no requests waiting in this queue, and
-		 * there are other queues ready to issue requests, AND
-		 * those other queues are issuing requests within our
-		 * mean seek distance, give them a chance to run instead
-		 * of idling.
-		 */
-		if (cfq_slice_used(cfqq) || cfq_class_idle(cfqq))
-			cfq_slice_expired(cfqd, 1);
-		else if (cfqq_empty && !cfq_close_cooperator(cfqd, cfqq, 1) &&
-			 sync && !rq_noidle(rq))
-			cfq_arm_slice_timer(cfqd);
-	}
-
-	if (!cfqd->rq_in_driver)
-		cfq_schedule_dispatch(cfqd);
 }
 
 /*
@@ -2207,29 +1762,32 @@ static void cfq_completed_request(struct request_queue *q, struct request *rq)
  */
 static void cfq_prio_boost(struct cfq_queue *cfqq)
 {
+	struct io_queue *ioq = cfqq->ioq;
+
 	if (has_fs_excl()) {
 		/*
 		 * boost idle prio on transactions that would lock out other
 		 * users of the filesystem
 		 */
 		if (cfq_class_idle(cfqq))
-			cfqq->ioprio_class = IOPRIO_CLASS_BE;
-		if (cfqq->ioprio > IOPRIO_NORM)
-			cfqq->ioprio = IOPRIO_NORM;
+			elv_ioq_set_ioprio_class(ioq, IOPRIO_CLASS_BE);
+		if (elv_ioq_ioprio(ioq) > IOPRIO_NORM)
+			elv_ioq_set_ioprio(ioq, IOPRIO_NORM);
+
 	} else {
 		/*
 		 * check if we need to unboost the queue
 		 */
-		if (cfqq->ioprio_class != cfqq->org_ioprio_class)
-			cfqq->ioprio_class = cfqq->org_ioprio_class;
-		if (cfqq->ioprio != cfqq->org_ioprio)
-			cfqq->ioprio = cfqq->org_ioprio;
+		if (elv_ioq_ioprio_class(ioq) != cfqq->org_ioprio_class)
+			elv_ioq_set_ioprio_class(ioq, cfqq->org_ioprio_class);
+		if (elv_ioq_ioprio(ioq) != cfqq->org_ioprio)
+			elv_ioq_set_ioprio(ioq, cfqq->org_ioprio);
 	}
 }
 
 static inline int __cfq_may_queue(struct cfq_queue *cfqq)
 {
-	if ((cfq_cfqq_wait_request(cfqq) || cfq_cfqq_must_alloc(cfqq)) &&
+	if ((elv_ioq_wait_request(cfqq->ioq) || cfq_cfqq_must_alloc(cfqq)) &&
 	    !cfq_cfqq_must_alloc_slice(cfqq)) {
 		cfq_mark_cfqq_must_alloc_slice(cfqq);
 		return ELV_MQUEUE_MUST;
@@ -2282,7 +1840,7 @@ static void cfq_put_request(struct request *rq)
 		put_io_context(RQ_CIC(rq)->ioc);
 
 		rq->elevator_private = NULL;
-		rq->elevator_private2 = NULL;
+		rq->ioq = NULL;
 
 		cfq_put_queue(cfqq);
 	}
@@ -2318,119 +1876,31 @@ cfq_set_request(struct request_queue *q, struct request *rq, gfp_t gfp_mask)
 
 	cfqq->allocated[rw]++;
 	cfq_clear_cfqq_must_alloc(cfqq);
-	atomic_inc(&cfqq->ref);
+	elv_get_ioq(cfqq->ioq);
 
 	spin_unlock_irqrestore(q->queue_lock, flags);
 
 	rq->elevator_private = cic;
-	rq->elevator_private2 = cfqq;
+	rq->ioq = cfqq->ioq;
 	return 0;
 
 queue_fail:
 	if (cic)
 		put_io_context(cic->ioc);
 
-	cfq_schedule_dispatch(cfqd);
+	elv_schedule_dispatch(cfqd->queue);
 	spin_unlock_irqrestore(q->queue_lock, flags);
 	cfq_log(cfqd, "set_request fail");
 	return 1;
 }
 
-static void cfq_kick_queue(struct work_struct *work)
-{
-	struct cfq_data *cfqd =
-		container_of(work, struct cfq_data, unplug_work);
-	struct request_queue *q = cfqd->queue;
-
-	spin_lock_irq(q->queue_lock);
-	__blk_run_queue(cfqd->queue);
-	spin_unlock_irq(q->queue_lock);
-}
-
-/*
- * Timer running if the active_queue is currently idling inside its time slice
- */
-static void cfq_idle_slice_timer(unsigned long data)
-{
-	struct cfq_data *cfqd = (struct cfq_data *) data;
-	struct cfq_queue *cfqq;
-	unsigned long flags;
-	int timed_out = 1;
-
-	cfq_log(cfqd, "idle timer fired");
-
-	spin_lock_irqsave(cfqd->queue->queue_lock, flags);
-
-	cfqq = cfqd->active_queue;
-	if (cfqq) {
-		timed_out = 0;
-
-		/*
-		 * We saw a request before the queue expired, let it through
-		 */
-		if (cfq_cfqq_must_dispatch(cfqq))
-			goto out_kick;
-
-		/*
-		 * expired
-		 */
-		if (cfq_slice_used(cfqq))
-			goto expire;
-
-		/*
-		 * only expire and reinvoke request handler, if there are
-		 * other queues with pending requests
-		 */
-		if (!cfqd->busy_queues)
-			goto out_cont;
-
-		/*
-		 * not expired and it has a request pending, let it dispatch
-		 */
-		if (!RB_EMPTY_ROOT(&cfqq->sort_list))
-			goto out_kick;
-	}
-expire:
-	cfq_slice_expired(cfqd, timed_out);
-out_kick:
-	cfq_schedule_dispatch(cfqd);
-out_cont:
-	spin_unlock_irqrestore(cfqd->queue->queue_lock, flags);
-}
-
-static void cfq_shutdown_timer_wq(struct cfq_data *cfqd)
-{
-	del_timer_sync(&cfqd->idle_slice_timer);
-	cancel_work_sync(&cfqd->unplug_work);
-}
-
-static void cfq_put_async_queues(struct cfq_data *cfqd)
-{
-	int i;
-
-	for (i = 0; i < IOPRIO_BE_NR; i++) {
-		if (cfqd->async_cfqq[0][i])
-			cfq_put_queue(cfqd->async_cfqq[0][i]);
-		if (cfqd->async_cfqq[1][i])
-			cfq_put_queue(cfqd->async_cfqq[1][i]);
-	}
-
-	if (cfqd->async_idle_cfqq)
-		cfq_put_queue(cfqd->async_idle_cfqq);
-}
-
 static void cfq_exit_queue(struct elevator_queue *e)
 {
 	struct cfq_data *cfqd = e->elevator_data;
 	struct request_queue *q = cfqd->queue;
 
-	cfq_shutdown_timer_wq(cfqd);
-
 	spin_lock_irq(q->queue_lock);
 
-	if (cfqd->active_queue)
-		__cfq_slice_expired(cfqd, cfqd->active_queue, 0);
-
 	while (!list_empty(&cfqd->cic_list)) {
 		struct cfq_io_context *cic = list_entry(cfqd->cic_list.next,
 							struct cfq_io_context,
@@ -2439,12 +1909,7 @@ static void cfq_exit_queue(struct elevator_queue *e)
 		__cfq_exit_single_io_context(cfqd, cic);
 	}
 
-	cfq_put_async_queues(cfqd);
-
 	spin_unlock_irq(q->queue_lock);
-
-	cfq_shutdown_timer_wq(cfqd);
-
 	kfree(cfqd);
 }
 
@@ -2457,8 +1922,6 @@ static void *cfq_init_queue(struct request_queue *q, struct elevator_queue *eq)
 	if (!cfqd)
 		return NULL;
 
-	cfqd->service_tree = CFQ_RB_ROOT;
-
 	/*
 	 * Not strictly needed (since RB_ROOT just clears the node and we
 	 * zeroed cfqd on alloc), but better be safe in case someone decides
@@ -2473,25 +1936,20 @@ static void *cfq_init_queue(struct request_queue *q, struct elevator_queue *eq)
 	 * will not attempt to free it.
 	 */
 	cfq_init_cfqq(cfqd, &cfqd->oom_cfqq, 1, 0);
-	atomic_inc(&cfqd->oom_cfqq.ref);
+
+	/* Link up oom_ioq and oom_cfqq */
+	cfqd->oom_cfqq.ioq = elv_get_oom_ioq(eq);
+	elv_init_ioq_sched_queue(eq, elv_get_oom_ioq(eq), &cfqd->oom_cfqq);
 
 	INIT_LIST_HEAD(&cfqd->cic_list);
 
 	cfqd->queue = q;
 
-	init_timer(&cfqd->idle_slice_timer);
-	cfqd->idle_slice_timer.function = cfq_idle_slice_timer;
-	cfqd->idle_slice_timer.data = (unsigned long) cfqd;
-
-	INIT_WORK(&cfqd->unplug_work, cfq_kick_queue);
-
 	cfqd->cfq_quantum = cfq_quantum;
 	cfqd->cfq_fifo_expire[0] = cfq_fifo_expire[0];
 	cfqd->cfq_fifo_expire[1] = cfq_fifo_expire[1];
 	cfqd->cfq_back_max = cfq_back_max;
 	cfqd->cfq_back_penalty = cfq_back_penalty;
-	cfqd->cfq_slice[0] = cfq_slice_async;
-	cfqd->cfq_slice[1] = cfq_slice_sync;
 	cfqd->cfq_slice_async_rq = cfq_slice_async_rq;
 	cfqd->cfq_slice_idle = cfq_slice_idle;
 	cfqd->hw_tag = 1;
@@ -2560,8 +2018,6 @@ SHOW_FUNCTION(cfq_fifo_expire_async_show, cfqd->cfq_fifo_expire[0], 1);
 SHOW_FUNCTION(cfq_back_seek_max_show, cfqd->cfq_back_max, 0);
 SHOW_FUNCTION(cfq_back_seek_penalty_show, cfqd->cfq_back_penalty, 0);
 SHOW_FUNCTION(cfq_slice_idle_show, cfqd->cfq_slice_idle, 1);
-SHOW_FUNCTION(cfq_slice_sync_show, cfqd->cfq_slice[1], 1);
-SHOW_FUNCTION(cfq_slice_async_show, cfqd->cfq_slice[0], 1);
 SHOW_FUNCTION(cfq_slice_async_rq_show, cfqd->cfq_slice_async_rq, 0);
 #undef SHOW_FUNCTION
 
@@ -2590,8 +2046,6 @@ STORE_FUNCTION(cfq_back_seek_max_store, &cfqd->cfq_back_max, 0, UINT_MAX, 0);
 STORE_FUNCTION(cfq_back_seek_penalty_store, &cfqd->cfq_back_penalty, 1,
 		UINT_MAX, 0);
 STORE_FUNCTION(cfq_slice_idle_store, &cfqd->cfq_slice_idle, 0, UINT_MAX, 1);
-STORE_FUNCTION(cfq_slice_sync_store, &cfqd->cfq_slice[1], 1, UINT_MAX, 1);
-STORE_FUNCTION(cfq_slice_async_store, &cfqd->cfq_slice[0], 1, UINT_MAX, 1);
 STORE_FUNCTION(cfq_slice_async_rq_store, &cfqd->cfq_slice_async_rq, 1,
 		UINT_MAX, 0);
 #undef STORE_FUNCTION
@@ -2605,10 +2059,10 @@ static struct elv_fs_entry cfq_attrs[] = {
 	CFQ_ATTR(fifo_expire_async),
 	CFQ_ATTR(back_seek_max),
 	CFQ_ATTR(back_seek_penalty),
-	CFQ_ATTR(slice_sync),
-	CFQ_ATTR(slice_async),
 	CFQ_ATTR(slice_async_rq),
 	CFQ_ATTR(slice_idle),
+	ELV_ATTR(slice_sync),
+	ELV_ATTR(slice_async),
 	__ATTR_NULL
 };
 
@@ -2621,8 +2075,6 @@ static struct elevator_type iosched_cfq = {
 		.elevator_dispatch_fn =		cfq_dispatch_requests,
 		.elevator_add_req_fn =		cfq_insert_request,
 		.elevator_activate_req_fn =	cfq_activate_request,
-		.elevator_deactivate_req_fn =	cfq_deactivate_request,
-		.elevator_queue_empty_fn =	cfq_queue_empty,
 		.elevator_completed_req_fn =	cfq_completed_request,
 		.elevator_former_req_fn =	elv_rb_former_request,
 		.elevator_latter_req_fn =	elv_rb_latter_request,
@@ -2632,7 +2084,14 @@ static struct elevator_type iosched_cfq = {
 		.elevator_init_fn =		cfq_init_queue,
 		.elevator_exit_fn =		cfq_exit_queue,
 		.trim =				cfq_free_io_context,
+		.elevator_free_sched_queue_fn =	cfq_free_cfq_queue,
+		.elevator_active_ioq_set_fn = 	cfq_active_ioq_set,
+		.elevator_active_ioq_reset_fn =	cfq_active_ioq_reset,
+		.elevator_arm_slice_timer_fn = 	cfq_arm_slice_timer,
+		.elevator_should_preempt_fn = 	cfq_should_preempt,
+		.elevator_close_cooperator_fn = cfq_close_cooperator,
 	},
+	.elevator_features =    ELV_IOSCHED_NEED_FQ,
 	.elevator_attrs =	cfq_attrs,
 	.elevator_name =	"cfq",
 	.elevator_owner =	THIS_MODULE,
@@ -2640,14 +2099,6 @@ static struct elevator_type iosched_cfq = {
 
 static int __init cfq_init(void)
 {
-	/*
-	 * could be 0 on HZ < 1000 setups
-	 */
-	if (!cfq_slice_async)
-		cfq_slice_async = 1;
-	if (!cfq_slice_idle)
-		cfq_slice_idle = 1;
-
 	if (cfq_slab_setup())
 		return -ENOMEM;
 
-- 
1.6.0.6
