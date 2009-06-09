From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 15/19] io-controller: map async requests to appropriate cgroup
Date: Mon,  8 Jun 2009 22:08:58 -0400
Message-ID: <1244513342-11758-16-git-send-email-vgoyal__47979.2003673085$1244515637$gmane$org@redhat.com>
References: <1244513342-11758-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1244513342-11758-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

o So far we were assuming that a bio/rq belongs to the task who is submitting
  it. It did not hold good in case of async writes. This patch makes use of
  blkio_cgroup pataches to attribute the aysnc writes to right group instead
  of task submitting the bio.

o For sync requests, we continue to assume that io belongs to the task
  submitting it. Only in case of async requests, we make use of io tracking
  patches to track the owner cgroup.

o So far cfq always caches the async queue pointer. With async requests now
  not necessarily being tied to submitting task io context, caching the
  pointer will not help for async queues. This patch introduces a new config
  option CONFIG_TRACK_ASYNC_CONTEXT. If this option is not set, cfq retains
  old behavior where async queue pointer is cached in task context. If it
  is not set, async queue pointer is not cached and we take help of bio
  tracking patches to determine group bio belongs to and then map it to
  async queue of that group.

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched    |   16 +++++
 block/as-iosched.c       |    2 +-
 block/blk-core.c         |    7 +-
 block/cfq-iosched.c      |  152 ++++++++++++++++++++++++++++++++++++----------
 block/deadline-iosched.c |    2 +-
 block/elevator-fq.c      |  101 ++++++++++++++++++++++++++-----
 block/elevator-fq.h      |   23 ++++++-
 block/elevator.c         |   15 +++--
 include/linux/elevator.h |   21 ++++++-
 9 files changed, 272 insertions(+), 67 deletions(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index 77fc786..0677099 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -124,6 +124,22 @@ config DEFAULT_IOSCHED
 	default "cfq" if DEFAULT_CFQ
 	default "noop" if DEFAULT_NOOP
 
+config TRACK_ASYNC_CONTEXT
+	bool "Determine async request context from bio"
+	depends on GROUP_IOSCHED
+	select CGROUP_BLKIO
+	default n
+	---help---
+	  Normally async request is attributed to the task submitting the
+	  request. With group ioscheduling, for accurate accounting of
+	  async writes, one needs to map the request to original task/cgroup
+	  which originated the request and not the submitter of the request.
+
+	  Currently there are generic io tracking patches to provide facility
+	  to map bio to original owner. If this option is set, for async
+	  request, original owner of the bio is decided by using io tracking
+	  patches otherwise we continue to attribute the request to the
+	  submitting thread.
 endmenu
 
 endif
diff --git a/block/as-iosched.c b/block/as-iosched.c
index d115697..b0c66e4 100644
--- a/block/as-iosched.c
+++ b/block/as-iosched.c
@@ -1499,7 +1499,7 @@ as_merge(struct request_queue *q, struct request **req, struct bio *bio)
 {
 	sector_t rb_key = bio->bi_sector + bio_sectors(bio);
 	struct request *__rq;
-	struct as_queue *asq = elv_get_sched_queue_current(q);
+	struct as_queue *asq = elv_get_sched_queue_bio(q, bio);
 
 	if (!asq)
 		return ELEVATOR_NO_MERGE;
diff --git a/block/blk-core.c b/block/blk-core.c
index c89883b..c77b5b2 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -643,7 +643,8 @@ static inline void blk_free_request(struct request_queue *q, struct request *rq)
 }
 
 static struct request *
-blk_alloc_request(struct request_queue *q, int flags, int priv, gfp_t gfp_mask)
+blk_alloc_request(struct request_queue *q, struct bio *bio, int flags, int priv,
+					gfp_t gfp_mask)
 {
 	struct request *rq = mempool_alloc(q->rq.rq_pool, gfp_mask);
 
@@ -655,7 +656,7 @@ blk_alloc_request(struct request_queue *q, int flags, int priv, gfp_t gfp_mask)
 	rq->cmd_flags = flags | REQ_ALLOCED;
 
 	if (priv) {
-		if (unlikely(elv_set_request(q, rq, gfp_mask))) {
+		if (unlikely(elv_set_request(q, rq, bio, gfp_mask))) {
 			mempool_free(rq, q->rq.rq_pool);
 			return NULL;
 		}
@@ -796,7 +797,7 @@ static struct request *get_request(struct request_queue *q, int rw_flags,
 		rw_flags |= REQ_IO_STAT;
 	spin_unlock_irq(q->queue_lock);
 
-	rq = blk_alloc_request(q, rw_flags, priv, gfp_mask);
+	rq = blk_alloc_request(q, bio, rw_flags, priv, gfp_mask);
 	if (unlikely(!rq)) {
 		/*
 		 * Allocation failed presumably due to memory. Undo anything
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 7a431b8..9b3c263 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -161,8 +161,8 @@ CFQ_CFQQ_FNS(coop);
 	blk_add_trace_msg((cfqd)->queue, "cfq " fmt, ##args)
 
 static void cfq_dispatch_insert(struct request_queue *, struct request *);
-static struct cfq_queue *cfq_get_queue(struct cfq_data *, int,
-				       struct io_context *, gfp_t);
+static struct cfq_queue *cfq_get_queue(struct cfq_data *, struct bio *bio,
+					int, struct io_context *, gfp_t);
 static struct cfq_io_context *cfq_cic_lookup(struct cfq_data *,
 						struct io_context *);
 
@@ -172,22 +172,56 @@ static inline struct cfq_queue *cic_to_cfqq(struct cfq_io_context *cic,
 	return cic->cfqq[!!is_sync];
 }
 
-static inline void cic_set_cfqq(struct cfq_io_context *cic,
-				struct cfq_queue *cfqq, int is_sync)
-{
-	cic->cfqq[!!is_sync] = cfqq;
-}
-
 /*
- * We regard a request as SYNC, if it's either a read or has the SYNC bit
- * set (in which case it could also be direct WRITE).
+ * Determine the cfq queue bio should go in. This is primarily used by
+ * front merge and allow merge functions.
+ *
+ * Currently this function takes the ioprio and iprio_class from task
+ * submitting async bio. Later save the task information in the page_cgroup
+ * and retrieve task's ioprio and class from there.
  */
-static inline int cfq_bio_sync(struct bio *bio)
+static struct cfq_queue *cic_bio_to_cfqq(struct cfq_data *cfqd,
+		struct cfq_io_context *cic, struct bio *bio, int is_sync)
 {
-	if (bio_data_dir(bio) == READ || bio_sync(bio))
-		return 1;
+	struct cfq_queue *cfqq = NULL;
 
-	return 0;
+	cfqq = cic_to_cfqq(cic, is_sync);
+
+#ifdef CONFIG_TRACK_ASYNC_CONTEXT
+	if (!cfqq && !is_sync) {
+		const int ioprio = task_ioprio(cic->ioc);
+		const int ioprio_class = task_ioprio_class(cic->ioc);
+		struct io_group *iog;
+		/*
+		 * async bio tracking is enabled and we are not caching
+		 * async queue pointer in cic.
+		 */
+		iog = io_get_io_group(cfqd->queue, bio, 0);
+		if (!iog) {
+			/*
+			 * May be this is first rq/bio and io group has not
+			 * been setup yet.
+			 */
+			return NULL;
+		}
+		return io_group_async_queue_prio(iog, ioprio_class, ioprio);
+	}
+#endif
+	return cfqq;
+}
+
+static inline void cic_set_cfqq(struct cfq_io_context *cic,
+				struct cfq_queue *cfqq, int is_sync)
+{
+#ifdef CONFIG_TRACK_ASYNC_CONTEXT
+	/*
+	 * Don't cache async queue pointer as now one io context might
+	 * be submitting async io for various different async queues
+	 */
+	if (!is_sync)
+		return;
+#endif
+	cic->cfqq[!!is_sync] = cfqq;
 }
 
 static inline struct io_group *cfqq_to_io_group(struct cfq_queue *cfqq)
@@ -505,7 +539,7 @@ cfq_find_rq_fmerge(struct cfq_data *cfqd, struct bio *bio)
 	if (!cic)
 		return NULL;
 
-	cfqq = cic_to_cfqq(cic, cfq_bio_sync(bio));
+	cfqq = cic_bio_to_cfqq(cfqd, cic, bio, elv_bio_sync(bio));
 	if (cfqq) {
 		sector_t sector = bio->bi_sector + bio_sectors(bio);
 
@@ -587,7 +621,7 @@ static int cfq_allow_merge(struct request_queue *q, struct request *rq,
 	/*
 	 * Disallow merge of a sync bio into an async request.
 	 */
-	if (cfq_bio_sync(bio) && !rq_is_sync(rq))
+	if (elv_bio_sync(bio) && !rq_is_sync(rq))
 		return 0;
 
 	/*
@@ -598,7 +632,7 @@ static int cfq_allow_merge(struct request_queue *q, struct request *rq,
 	if (!cic)
 		return 0;
 
-	cfqq = cic_to_cfqq(cic, cfq_bio_sync(bio));
+	cfqq = cic_bio_to_cfqq(cfqd, cic, bio, elv_bio_sync(bio));
 	if (cfqq == RQ_CFQQ(rq))
 		return 1;
 
@@ -1206,14 +1240,28 @@ static void changed_ioprio(struct io_context *ioc, struct cfq_io_context *cic)
 	spin_lock_irqsave(q->queue_lock, flags);
 
 	cfqq = cic->cfqq[BLK_RW_ASYNC];
+
 	if (cfqq) {
 		struct cfq_queue *new_cfqq;
-		new_cfqq = cfq_get_queue(cfqd, BLK_RW_ASYNC, cic->ioc,
+
+		/*
+		 * Drop the reference to old queue unconditionally. Don't
+		 * worry whether new async prio queue has been allocated
+		 * or not.
+		 */
+		cic_set_cfqq(cic, NULL, BLK_RW_ASYNC);
+		cfq_put_queue(cfqq);
+
+		/*
+		 * Why to allocate new queue now? Will it not be automatically
+		 * allocated whenever another async request from same context
+		 * comes? Keeping it for the time being because existing cfq
+		 * code allocates the new queue immediately upon prio change
+		 */
+		new_cfqq = cfq_get_queue(cfqd, NULL, BLK_RW_ASYNC, cic->ioc,
 						GFP_ATOMIC);
-		if (new_cfqq) {
-			cic->cfqq[BLK_RW_ASYNC] = new_cfqq;
-			cfq_put_queue(cfqq);
-		}
+		if (new_cfqq)
+			cic_set_cfqq(cic, new_cfqq, BLK_RW_ASYNC);
 	}
 
 	cfqq = cic->cfqq[BLK_RW_SYNC];
@@ -1246,7 +1294,7 @@ static void changed_cgroup(struct io_context *ioc, struct cfq_io_context *cic)
 
 	spin_lock_irqsave(q->queue_lock, flags);
 
-	iog = io_get_io_group(q, 0);
+	iog = io_get_io_group(q, NULL, 0);
 
 	if (async_cfqq != NULL) {
 		__iog = cfqq_to_io_group(async_cfqq);
@@ -1284,7 +1332,7 @@ static void cfq_ioc_set_cgroup(struct io_context *ioc)
 #endif  /* CONFIG_IOSCHED_CFQ_HIER */
 
 static struct cfq_queue *
-cfq_find_alloc_queue(struct cfq_data *cfqd, int is_sync,
+cfq_find_alloc_queue(struct cfq_data *cfqd, struct bio *bio, int is_sync,
 				struct io_context *ioc, gfp_t gfp_mask)
 {
 	struct cfq_queue *cfqq, *new_cfqq = NULL;
@@ -1293,12 +1341,28 @@ cfq_find_alloc_queue(struct cfq_data *cfqd, int is_sync,
 	struct io_queue *ioq = NULL, *new_ioq = NULL;
 	struct io_group *iog = NULL;
 retry:
-	iog = io_get_io_group(q, 1);
+	iog = io_get_io_group(q, bio, 1);
 
 	cic = cfq_cic_lookup(cfqd, ioc);
 	/* cic always exists here */
 	cfqq = cic_to_cfqq(cic, is_sync);
 
+#ifdef CONFIG_TRACK_ASYNC_CONTEXT
+	if (!cfqq && !is_sync) {
+		const int ioprio = task_ioprio(cic->ioc);
+		const int ioprio_class = task_ioprio_class(cic->ioc);
+
+		/*
+		 * We have not cached async queue pointer as bio tracking
+		 * is enabled. Look into group async queue array using ioc
+		 * class and prio to see if somebody already allocated the
+		 * queue.
+		 */
+
+		cfqq = io_group_async_queue_prio(iog, ioprio_class, ioprio);
+	}
+#endif
+
 	if (!cfqq) {
 		if (new_cfqq) {
 			goto alloc_ioq;
@@ -1388,14 +1452,14 @@ out:
 }
 
 static struct cfq_queue *
-cfq_get_queue(struct cfq_data *cfqd, int is_sync, struct io_context *ioc,
-					gfp_t gfp_mask)
+cfq_get_queue(struct cfq_data *cfqd, struct bio *bio, int is_sync,
+		struct io_context *ioc, gfp_t gfp_mask)
 {
 	const int ioprio = task_ioprio(ioc);
 	const int ioprio_class = task_ioprio_class(ioc);
 	struct cfq_queue *async_cfqq = NULL;
 	struct cfq_queue *cfqq = NULL;
-	struct io_group *iog = io_get_io_group(cfqd->queue, 1);
+	struct io_group *iog = io_get_io_group(cfqd->queue, bio, 1);
 
 	if (!is_sync) {
 		async_cfqq = io_group_async_queue_prio(iog, ioprio_class,
@@ -1404,7 +1468,7 @@ cfq_get_queue(struct cfq_data *cfqd, int is_sync, struct io_context *ioc,
 	}
 
 	if (!cfqq) {
-		cfqq = cfq_find_alloc_queue(cfqd, is_sync, ioc, gfp_mask);
+		cfqq = cfq_find_alloc_queue(cfqd, bio, is_sync, ioc, gfp_mask);
 		if (!cfqq)
 			return NULL;
 	}
@@ -1412,8 +1476,30 @@ cfq_get_queue(struct cfq_data *cfqd, int is_sync, struct io_context *ioc,
 	if (!is_sync && !async_cfqq)
 		io_group_set_async_queue(iog, ioprio_class, ioprio, cfqq->ioq);
 
-	/* ioc reference */
+#ifdef CONFIG_TRACK_ASYNC_CONTEXT
+	/*
+	 * ioc reference. If async request queue/group is determined from the
+	 * original task/cgroup and not from submitter task, io context can
+	 * not cache the pointer to async queue and everytime a request comes,
+	 * it will be determined by going through the async queue array.
+	 *
+	 * This comes from the fact that we might be getting async requests
+	 * which belong to a different cgroup altogether than the cgroup
+	 * iocontext belongs to. And this thread might be submitting bios
+	 * from various cgroups. So every time async queue will be different
+	 * based on the cgroup of the bio/rq. Can't cache the async cfqq
+	 * pointer in cic.
+	 */
+	if (is_sync)
+		elv_get_ioq(cfqq->ioq);
+#else
+	/*
+	 * async requests are being attributed to task submitting
+	 * it, hence cic can cache async cfqq pointer. Take the
+	 * queue reference even for async queue.
+	 */
 	elv_get_ioq(cfqq->ioq);
+#endif
 	return cfqq;
 }
 
@@ -1807,7 +1893,8 @@ static void cfq_put_request(struct request *rq)
  * Allocate cfq data structures associated with this request.
  */
 static int
-cfq_set_request(struct request_queue *q, struct request *rq, gfp_t gfp_mask)
+cfq_set_request(struct request_queue *q, struct request *rq, struct bio *bio,
+				gfp_t gfp_mask)
 {
 	struct cfq_data *cfqd = q->elevator->elevator_data;
 	struct cfq_io_context *cic;
@@ -1827,7 +1914,8 @@ cfq_set_request(struct request_queue *q, struct request *rq, gfp_t gfp_mask)
 
 	cfqq = cic_to_cfqq(cic, is_sync);
 	if (!cfqq) {
-		cfqq = cfq_get_queue(cfqd, is_sync, cic->ioc, gfp_mask);
+		cfqq = cfq_get_queue(cfqd, bio, is_sync, cic->ioc,
+						gfp_mask);
 
 		if (!cfqq)
 			goto queue_fail;
diff --git a/block/deadline-iosched.c b/block/deadline-iosched.c
index 4cda105..0082a05 100644
--- a/block/deadline-iosched.c
+++ b/block/deadline-iosched.c
@@ -133,7 +133,7 @@ deadline_merge(struct request_queue *q, struct request **req, struct bio *bio)
 	int ret;
 	struct deadline_queue *dq;
 
-	dq = elv_get_sched_queue_current(q);
+	dq = elv_get_sched_queue_bio(q, bio);
 	if (!dq)
 		return ELEVATOR_NO_MERGE;
 
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 3df74ac..27e46bb 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -14,6 +14,7 @@
 #include "elevator-fq.h"
 #include <linux/blktrace_api.h>
 #include <linux/seq_file.h>
+#include <linux/biotrack.h>
 
 /* Values taken from cfq */
 const int elv_slice_sync = HZ / 10;
@@ -1004,6 +1005,9 @@ void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
 
 struct io_cgroup *cgroup_to_io_cgroup(struct cgroup *cgroup)
 {
+	if (!cgroup)
+		return &io_root_cgroup;
+
 	return container_of(cgroup_subsys_state(cgroup, io_subsys_id),
 			    struct io_cgroup, css);
 }
@@ -1363,9 +1367,47 @@ end:
 	return iog;
 }
 
+/* Map a bio to respective cgroup. Null return means, map it to root cgroup */
+static inline struct cgroup *get_cgroup_from_bio(struct bio *bio)
+{
+	unsigned long bio_cgroup_id;
+	struct cgroup *cgroup;
+
+	/* blk_get_request can reach here without passing a bio */
+	if (!bio)
+		return NULL;
+
+	if (bio_barrier(bio)) {
+		/*
+		 * Map barrier requests to root group. May be more special
+		 * bio cases should come here
+		 */
+		return NULL;
+	}
+
+#ifdef CONFIG_TRACK_ASYNC_CONTEXT
+	if (elv_bio_sync(bio)) {
+		/* sync io. Determine cgroup from submitting task context. */
+		cgroup = task_cgroup(current, io_subsys_id);
+		return cgroup;
+	}
+
+	/* Async io. Determine cgroup from with cgroup id stored in page */
+	bio_cgroup_id = get_blkio_cgroup_id(bio);
+
+	if (!bio_cgroup_id)
+		return NULL;
+
+	cgroup = blkio_cgroup_lookup(bio_cgroup_id);
+#else
+	cgroup = task_cgroup(current, io_subsys_id);
+#endif
+	return cgroup;
+}
+
 /*
- * Search for the io group current task belongs to. If create=1, then also
- * create the io group if it is not already there.
+ * Find the io group bio belongs to.
+ * If "create" is set, io group is created if it is not already present.
  *
  * Note: This function should be called with queue lock held. It returns
  * a pointer to io group without taking any reference. That group will
@@ -1374,7 +1416,8 @@ end:
  * pointer even after dropping queue lock, take a reference to the group
  * before dropping queue lock.
  */
-struct io_group *io_get_io_group(struct request_queue *q, int create)
+struct io_group *io_get_io_group(struct request_queue *q, struct bio *bio,
+					int create)
 {
 	struct cgroup *cgroup;
 	struct io_group *iog;
@@ -1383,18 +1426,33 @@ struct io_group *io_get_io_group(struct request_queue *q, int create)
 	assert_spin_locked(q->queue_lock);
 
 	rcu_read_lock();
-	cgroup = task_cgroup(current, io_subsys_id);
-	iog = io_find_alloc_group(q, cgroup, efqd, create, NULL);
-	if (!iog) {
+
+	if (!bio)
+		cgroup = task_cgroup(current, io_subsys_id);
+	else
+		cgroup = get_cgroup_from_bio(bio);
+
+	if (!cgroup) {
 		if (create)
 			iog = efqd->root_group;
-		else
+		else {
 			/*
 			 * bio merge functions doing lookup don't want to
 			 * map bio to root group by default
 			 */
 			iog = NULL;
+		}
+		goto out;
 	}
+
+	iog = io_find_alloc_group(q, cgroup, efqd, create, bio);
+	if (!iog) {
+		if (create)
+			iog = efqd->root_group;
+		else
+			iog = NULL;
+	}
+out:
 	rcu_read_unlock();
 	return iog;
 }
@@ -1800,7 +1858,7 @@ int io_group_allow_merge(struct request *rq, struct bio *bio)
 		return 1;
 
 	/* Determine the io group of the bio submitting task */
-	iog = io_get_io_group(q, 0);
+	iog = io_get_io_group(q, bio, 0);
 	if (!iog) {
 		/* May be task belongs to a differet cgroup for which io
 		 * group has not been setup yet. */
@@ -1824,7 +1882,7 @@ int io_group_allow_merge(struct request *rq, struct bio *bio)
  * function is not invoked.
  */
 int elv_fq_set_request_ioq(struct request_queue *q, struct request *rq,
-					gfp_t gfp_mask)
+				struct bio *bio, gfp_t gfp_mask)
 {
 	struct elevator_queue *e = q->elevator;
 	unsigned long flags;
@@ -1840,7 +1898,7 @@ int elv_fq_set_request_ioq(struct request_queue *q, struct request *rq,
 
 retry:
 	/* Determine the io group request belongs to */
-	iog = io_get_io_group(q, 1);
+	iog = io_get_io_group(q, bio, 1);
 	BUG_ON(!iog);
 
 	/* Get the iosched queue */
@@ -1925,17 +1983,17 @@ queue_fail:
 }
 
 /*
- * Find out the io queue of current task. Optimization for single ioq
+ * Find out the io queue of bio belongs to. Optimization for single ioq
  * per io group io schedulers.
  */
-struct io_queue *elv_lookup_ioq_current(struct request_queue *q)
+struct io_queue *elv_lookup_ioq_bio(struct request_queue *q, struct bio *bio)
 {
 	struct io_group *iog;
 
 	/* Determine the io group and io queue of the bio submitting task */
-	iog = io_get_io_group(q, 0);
+	iog = io_get_io_group(q, bio, 0);
 	if (!iog) {
-		/* May be task belongs to a cgroup for which io group has
+		/* May be bio belongs to a cgroup for which io group has
 		 * not been setup yet. */
 		return NULL;
 	}
@@ -2000,7 +2058,13 @@ void io_free_root_group(struct elevator_queue *e)
 	kfree(iog);
 }
 
-struct io_group *io_get_io_group(struct request_queue *q, int create)
+struct io_group *io_get_io_group(struct request_queue *q, struct bio *bio,
+						int create)
+{
+	return q->elevator->efqd.root_group;
+}
+
+struct io_group *rq_iog(struct request_queue *q, struct request *rq)
 {
 	return q->elevator->efqd.root_group;
 }
@@ -3188,6 +3252,10 @@ expire:
 new_queue:
 	ioq = elv_set_active_ioq(q, new_ioq);
 keep_queue:
+	if (ioq)
+		elv_log_ioq(efqd, ioq, "select busy=%d qued=%d disp=%d",
+				elv_nr_busy_ioq(q->elevator), ioq->nr_queued,
+				elv_ioq_nr_dispatched(ioq));
 	return ioq;
 }
 
@@ -3323,7 +3391,8 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 	ioq = rq->ioq;
 	iog = ioq_to_io_group(ioq);
 
-	elv_log_ioq(efqd, ioq, "complete");
+	elv_log_ioq(efqd, ioq, "complete drv=%d disp=%d", efqd->rq_in_driver,
+						elv_ioq_nr_dispatched(ioq));
 
 	elv_update_hw_tag(efqd);
 
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 97aa2da..bee4783 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -520,10 +520,12 @@ static inline int update_requeue(struct io_queue *ioq, int requeue)
 }
 
 extern int elv_fq_set_request_ioq(struct request_queue *q, struct request *rq,
-					gfp_t gfp_mask);
+					struct bio *bio, gfp_t gfp_mask);
 extern void elv_fq_unset_request_ioq(struct request_queue *q,
 					struct request *rq);
 extern struct io_queue *elv_lookup_ioq_current(struct request_queue *q);
+extern struct io_queue *elv_lookup_ioq_bio(struct request_queue *q,
+						struct bio *bio);
 
 /* Returns single ioq associated with the io group. */
 static inline struct io_queue *io_group_ioq(struct io_group *iog)
@@ -581,7 +583,7 @@ static inline void io_group_set_ioq(struct io_group *iog, struct io_queue *ioq)
 }
 
 static inline int elv_fq_set_request_ioq(struct request_queue *q,
-					struct request *rq, gfp_t gfp_mask)
+			struct request *rq, struct bio *bio, gfp_t gfp_mask)
 {
 	return 0;
 }
@@ -596,6 +598,12 @@ static inline struct io_queue *elv_lookup_ioq_current(struct request_queue *q)
 	return NULL;
 }
 
+static inline struct io_queue *elv_lookup_ioq_bio(struct request_queue *q,
+						struct bio *bio)
+{
+	return NULL;
+}
+
 #endif /* GROUP_IOSCHED */
 
 /* Functions used by blksysfs.c */
@@ -650,7 +658,8 @@ extern void *io_group_async_queue_prio(struct io_group *iog, int ioprio_class,
 					int ioprio);
 extern void io_group_set_async_queue(struct io_group *iog, int ioprio_class,
 					int ioprio, struct io_queue *ioq);
-extern struct io_group *io_get_io_group(struct request_queue *q, int create);
+extern struct io_group *io_get_io_group(struct request_queue *q,
+					struct bio *bio, int create);
 extern int elv_nr_busy_ioq(struct elevator_queue *e);
 extern int elv_nr_busy_rt_ioq(struct elevator_queue *e);
 extern struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp_mask);
@@ -710,7 +719,7 @@ static inline int io_group_allow_merge(struct request *rq, struct bio *bio)
 	return 1;
 }
 static inline int elv_fq_set_request_ioq(struct request_queue *q,
-					struct request *rq, gfp_t gfp_mask)
+			struct request *rq, struct bio *bio, gfp_t gfp_mask)
 {
 	return 0;
 }
@@ -725,5 +734,11 @@ static inline struct io_queue *elv_lookup_ioq_current(struct request_queue *q)
 	return NULL;
 }
 
+static inline struct io_queue *elv_lookup_ioq_bio(struct request_queue *q,
+						struct bio *bio)
+{
+	return NULL;
+}
+
 #endif /* CONFIG_ELV_FAIR_QUEUING */
 #endif /* _BFQ_SCHED_H */
diff --git a/block/elevator.c b/block/elevator.c
index de42fd6..b49efd6 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -967,7 +967,8 @@ struct request *elv_former_request(struct request_queue *q, struct request *rq)
 	return NULL;
 }
 
-int elv_set_request(struct request_queue *q, struct request *rq, gfp_t gfp_mask)
+int elv_set_request(struct request_queue *q, struct request *rq,
+			struct bio *bio, gfp_t gfp_mask)
 {
 	struct elevator_queue *e = q->elevator;
 
@@ -976,10 +977,10 @@ int elv_set_request(struct request_queue *q, struct request *rq, gfp_t gfp_mask)
 	 * ioq per io group
 	 */
 	if (elv_iosched_single_ioq(e))
-		return elv_fq_set_request_ioq(q, rq, gfp_mask);
+		return elv_fq_set_request_ioq(q, rq, bio, gfp_mask);
 
 	if (e->ops->elevator_set_req_fn)
-		return e->ops->elevator_set_req_fn(q, rq, gfp_mask);
+		return e->ops->elevator_set_req_fn(q, rq, bio, gfp_mask);
 
 	rq->elevator_private = NULL;
 	return 0;
@@ -1368,19 +1369,19 @@ void *elv_select_sched_queue(struct request_queue *q, int force)
 EXPORT_SYMBOL(elv_select_sched_queue);
 
 /*
- * Get the io scheduler queue pointer for current task.
+ * Get the io scheduler queue pointer for the group bio belongs to.
  *
  * If fair queuing is enabled, determine the io group of task and retrieve
  * the ioq pointer from that. This is used by only single queue ioschedulers
  * for retrieving the queue associated with the group to decide whether the
  * new bio can do a front merge or not.
  */
-void *elv_get_sched_queue_current(struct request_queue *q)
+void *elv_get_sched_queue_bio(struct request_queue *q, struct bio *bio)
 {
 	/* Fair queuing is not enabled. There is only one queue. */
 	if (!elv_iosched_fair_queuing_enabled(q->elevator))
 		return q->elevator->sched_queue;
 
-	return ioq_sched_queue(elv_lookup_ioq_current(q));
+	return ioq_sched_queue(elv_lookup_ioq_bio(q, bio));
 }
-EXPORT_SYMBOL(elv_get_sched_queue_current);
+EXPORT_SYMBOL(elv_get_sched_queue_bio);
diff --git a/include/linux/elevator.h b/include/linux/elevator.h
index b47ecb3..1177bfe 100644
--- a/include/linux/elevator.h
+++ b/include/linux/elevator.h
@@ -23,7 +23,7 @@ typedef struct request *(elevator_request_list_fn) (struct request_queue *, stru
 typedef void (elevator_completed_req_fn) (struct request_queue *, struct request *);
 typedef int (elevator_may_queue_fn) (struct request_queue *, int);
 
-typedef int (elevator_set_req_fn) (struct request_queue *, struct request *, gfp_t);
+typedef int (elevator_set_req_fn) (struct request_queue *, struct request *, struct bio *bio, gfp_t);
 typedef void (elevator_put_req_fn) (struct request *);
 typedef void (elevator_activate_req_fn) (struct request_queue *, struct request *);
 typedef void (elevator_deactivate_req_fn) (struct request_queue *, struct request *);
@@ -150,7 +150,8 @@ extern void elv_unregister_queue(struct request_queue *q);
 extern int elv_may_queue(struct request_queue *, int);
 extern void elv_abort_queue(struct request_queue *);
 extern void elv_completed_request(struct request_queue *, struct request *);
-extern int elv_set_request(struct request_queue *, struct request *, gfp_t);
+extern int elv_set_request(struct request_queue *, struct request *,
+					struct bio *bio, gfp_t);
 extern void elv_put_request(struct request_queue *, struct request *);
 extern void elv_drain_elevator(struct request_queue *);
 
@@ -279,6 +280,20 @@ static inline int elv_iosched_single_ioq(struct elevator_queue *e)
 #endif /* ELV_IOSCHED_FAIR_QUEUING */
 extern void *elv_get_sched_queue(struct request_queue *q, struct request *rq);
 extern void *elv_select_sched_queue(struct request_queue *q, int force);
-extern void *elv_get_sched_queue_current(struct request_queue *q);
+extern void *elv_get_sched_queue_bio(struct request_queue *q, struct bio *bio);
+
+/*
+ * This is equivalent of rq_is_sync()/cfq_bio_sync() function where we
+ * determine whether an rq/bio is sync or not. There are cases like during
+ * merging and during * request allocation, where we don't have rq but bio
+ * and needs to find out * if this bio will be considered as sync or async by
+ * elevator/iosched. This function is useful in such cases.
+ */
+static inline int elv_bio_sync(struct bio *bio)
+{
+	if ((bio_data_dir(bio) == READ) || bio_sync(bio))
+		return 1;
+	return 0;
+}
 #endif /* CONFIG_BLOCK */
 #endif
-- 
1.6.0.6
