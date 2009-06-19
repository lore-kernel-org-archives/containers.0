From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 17/20] io-controller: Per io group bdi congestion interface
Date: Fri, 19 Jun 2009 16:37:35 -0400
Message-ID: <1245443858-8487-18-git-send-email-vgoyal__9066.43029670722$1245445188$gmane$org@redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1245443858-8487-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

o So far there used to be only one pair or queue  of request descriptors
  (one for sync and one for async) per device and number of requests allocated
  used to decide whether associated bdi is congested or not.

  Now with per io group request descriptor infrastructure, there is a pair
  of request descriptor queue per io group per device. So it might happen
  that overall request queue is not congested but a particular io group
  bio belongs to is congested.

  Or, it could be otherwise that group is not congested but overall queue
  is congested. This can happen if user has not properly set the request
  descriptors limits for queue and groups.
  (q->nr_requests < nr_groups * q->nr_group_requests)

  Hence there is a need for new interface which can query deivce congestion
  status per group. This group is determined by the "struct page" IO will be
  done for. If page is null, then group is determined from the current task
  context.

o This patch introduces new set of function bdi_*_congested_group(), which
  take "struct page" as addition argument. These functions will call the
  block layer and in trun elevator to find out if the io group the page will
  go into is congested or not.

o Currently I have introduced the core functions and migrated most of the users.
  But there might be still some left. This is an ongoing TODO item.

o There are some io_get_io_group() related changes which should be pushed into
  higher patches. Still testing this patch. Will push these changes up in next
  posting.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-core.c            |   21 +++++
 block/cfq-iosched.c         |    6 +-
 block/elevator-fq.c         |  179 ++++++++++++++++++++++++++++++++++---------
 block/elevator-fq.h         |   10 ++-
 drivers/md/dm-table.c       |   11 ++-
 drivers/md/dm.c             |    5 +-
 drivers/md/dm.h             |    3 +-
 drivers/md/linear.c         |    7 +-
 drivers/md/multipath.c      |    7 +-
 drivers/md/raid0.c          |    6 +-
 drivers/md/raid1.c          |    9 ++-
 drivers/md/raid10.c         |    6 +-
 drivers/md/raid5.c          |    2 +-
 fs/afs/write.c              |    8 ++-
 fs/btrfs/disk-io.c          |    6 +-
 fs/btrfs/extent_io.c        |   12 +++
 fs/btrfs/volumes.c          |    8 ++-
 fs/cifs/file.c              |   11 +++
 fs/ext2/ialloc.c            |    2 +-
 fs/gfs2/ops_address.c       |   12 +++
 fs/nilfs2/segbuf.c          |    3 +-
 fs/xfs/linux-2.6/xfs_aops.c |    2 +-
 fs/xfs/linux-2.6/xfs_buf.c  |    2 +-
 include/linux/backing-dev.h |   61 ++++++++++++++-
 include/linux/biotrack.h    |    6 ++
 include/linux/blkdev.h      |    5 +
 mm/backing-dev.c            |   62 +++++++++++++++
 mm/biotrack.c               |   21 +++++
 mm/page-writeback.c         |   11 +++
 mm/readahead.c              |    4 +-
 30 files changed, 435 insertions(+), 73 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 35e3725..5f16f4a 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -99,6 +99,27 @@ void blk_queue_congestion_threshold(struct request_queue *q)
 	q->nr_congestion_off = nr;
 }
 
+#ifdef CONFIG_GROUP_IOSCHED
+int blk_queue_io_group_congested(struct backing_dev_info *bdi, int bdi_bits,
+					struct page *page)
+{
+	int ret = 0;
+	struct request_queue *q = bdi->unplug_io_data;
+
+	if (!q && !q->elevator)
+		return bdi_congested(bdi, bdi_bits);
+
+	/* Do we need to hold queue lock? */
+	if (bdi_bits & (1 << BDI_sync_congested))
+		ret |= elv_io_group_congested(q, page, 1);
+
+	if (bdi_bits & (1 << BDI_async_congested))
+		ret |= elv_io_group_congested(q, page, 0);
+
+	return ret;
+}
+#endif
+
 /**
  * blk_get_backing_dev_info - get the address of a queue's backing_dev_info
  * @bdev:	device
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 77bbe6c..b02acf2 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -195,7 +195,7 @@ static struct cfq_queue *cic_bio_to_cfqq(struct cfq_data *cfqd,
 		 * async bio tracking is enabled and we are not caching
 		 * async queue pointer in cic.
 		 */
-		iog = io_get_io_group(cfqd->queue, bio, 0);
+		iog = io_get_io_group_bio(cfqd->queue, bio, 0);
 		if (!iog) {
 			/*
 			 * May be this is first rq/bio and io group has not
@@ -1334,7 +1334,7 @@ cfq_find_alloc_queue(struct cfq_data *cfqd, struct bio *bio, int is_sync,
 	struct io_queue *ioq = NULL, *new_ioq = NULL;
 	struct io_group *iog = NULL;
 retry:
-	iog = io_get_io_group(q, bio, 1);
+	iog = io_get_io_group_bio(q, bio, 1);
 
 	cic = cfq_cic_lookup(cfqd, ioc);
 	/* cic always exists here */
@@ -1452,7 +1452,7 @@ cfq_get_queue(struct cfq_data *cfqd, struct bio *bio, int is_sync,
 	const int ioprio_class = task_ioprio_class(ioc);
 	struct cfq_queue *async_cfqq = NULL;
 	struct cfq_queue *cfqq = NULL;
-	struct io_group *iog = io_get_io_group(cfqd->queue, bio, 1);
+	struct io_group *iog = io_get_io_group_bio(cfqd->queue, bio, 1);
 
 	if (!is_sync) {
 		async_cfqq = io_group_async_queue_prio(iog, ioprio_class,
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 16f75ad..13c8161 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -42,7 +42,6 @@ struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
 void elv_release_ioq(struct elevator_queue *eq, struct io_queue **ioq_ptr);
 int elv_iosched_expire_ioq(struct request_queue *q, int slice_expired,
 					int force);
-
 static inline int elv_prio_slice(struct elv_fq_data *efqd, int sync,
 					unsigned short prio)
 {
@@ -1087,11 +1086,69 @@ struct request_list *io_group_get_request_list(struct request_queue *q,
 {
 	struct io_group *iog;
 
-	iog = io_get_io_group(q, bio, 1);
+	iog = io_get_io_group_bio(q, bio, 1);
 	BUG_ON(!iog);
 	return &iog->rl;
 }
 
+/* Set io group congestion on and off thresholds */
+void elv_io_group_congestion_threshold(struct request_queue *q,
+						struct io_group *iog)
+{
+	int nr;
+
+	nr = q->nr_group_requests - (q->nr_group_requests / 8) + 1;
+	if (nr > q->nr_group_requests)
+		nr = q->nr_group_requests;
+	iog->nr_congestion_on = nr;
+
+	nr = q->nr_group_requests - (q->nr_group_requests / 8)
+			- (q->nr_group_requests / 16) - 1;
+	if (nr < 1)
+		nr = 1;
+	iog->nr_congestion_off = nr;
+}
+
+static inline int elv_is_iog_congested(struct request_queue *q,
+					struct io_group *iog, int sync)
+{
+	if (iog->rl.count[sync] >= iog->nr_congestion_on)
+		return 1;
+	return 0;
+}
+
+/* Determine if io group page maps to is congested or not */
+int elv_io_group_congested(struct request_queue *q, struct page *page, int sync)
+{
+	struct io_group *iog;
+	int ret = 0;
+
+	rcu_read_lock();
+
+	iog = io_get_io_group(q, page, 0);
+
+	if (!iog) {
+		/*
+		 * Either cgroup got deleted or this is first request in the
+		 * group and associated io group object has not been created
+		 * yet. Map it to root group.
+		 *
+		 * TODO: Fix the case of group not created yet.
+		 */
+		iog = q->elevator->efqd.root_group;
+	}
+
+	ret = elv_is_iog_congested(q, iog, sync);
+	if (ret)
+		elv_log_iog(&q->elevator->efqd, iog, "iog congested=%d sync=%d"
+			" rl.count[sync]=%d nr_group_requests=%d",
+			ret, sync, iog->rl.count[sync], q->nr_group_requests);
+
+	rcu_read_unlock();
+	return ret;
+}
+
+
 /*
  * Search the bfq_group for bfqd into the hash table (by now only a list)
  * of bgrp.  Must be called under rcu_read_lock().
@@ -1265,11 +1322,13 @@ static int io_cgroup_disk_sectors_read(struct cgroup *cgroup,
  * to the root has already an allocated group on @bfqd.
  */
 struct io_group *io_group_chain_alloc(struct request_queue *q, void *key,
-					struct cgroup *cgroup, struct bio *bio)
+					struct cgroup *cgroup)
 {
 	struct io_cgroup *iocg;
 	struct io_group *iog, *leaf = NULL, *prev = NULL;
 	gfp_t flags = GFP_ATOMIC |  __GFP_ZERO;
+	unsigned int major, minor;
+	struct backing_dev_info *bdi = &q->backing_dev_info;
 
 	for (; cgroup != NULL; cgroup = cgroup->parent) {
 		iocg = cgroup_to_io_cgroup(cgroup);
@@ -1308,6 +1367,7 @@ struct io_group *io_group_chain_alloc(struct request_queue *q, void *key,
 		elv_get_iog(iog);
 
 		blk_init_request_list(&iog->rl);
+		elv_io_group_congestion_threshold(q, iog);
 
 		if (leaf == NULL) {
 			leaf = iog;
@@ -1412,7 +1472,7 @@ void io_group_chain_link(struct request_queue *q, void *key,
  */
 struct io_group *io_find_alloc_group(struct request_queue *q,
 			struct cgroup *cgroup, struct elv_fq_data *efqd,
-			int create, struct bio *bio)
+			int create)
 {
 	struct io_cgroup *iocg = cgroup_to_io_cgroup(cgroup);
 	struct io_group *iog = NULL;
@@ -1431,7 +1491,7 @@ struct io_group *io_find_alloc_group(struct request_queue *q,
 	if (iog != NULL || !create)
 		goto end;
 
-	iog = io_group_chain_alloc(q, key, cgroup, bio);
+	iog = io_group_chain_alloc(q, key, cgroup);
 	if (iog != NULL)
 		io_group_chain_link(q, key, cgroup, iog, efqd);
 
@@ -1440,46 +1500,60 @@ end:
 	return iog;
 }
 
-/* Map a bio to respective cgroup. Null return means, map it to root cgroup */
-static inline struct cgroup *get_cgroup_from_bio(struct bio *bio)
+/* Map a page to respective cgroup. Null return means, map it to root cgroup */
+static inline struct cgroup *get_cgroup_from_page(struct page *page)
 {
 	unsigned long bio_cgroup_id;
 	struct cgroup *cgroup;
 
-	/* blk_get_request can reach here without passing a bio */
-	if (!bio)
+	bio_cgroup_id = get_blkio_cgroup_id_page(page);
+
+	if (!bio_cgroup_id)
 		return NULL;
 
+	cgroup = blkio_cgroup_lookup(bio_cgroup_id);
+	return cgroup;
+}
+
+
+struct io_group *io_get_io_group_bio(struct request_queue *q, struct bio *bio,
+					int create)
+{
+	struct page *page = NULL;
+
+	/*
+	 * Determine the group from task context. Even calls from
+	 * blk_get_request() which don't have any bio info will be mapped
+	 * to the task's group
+	 */
+	if (!bio)
+		goto sync;
+
 	if (bio_barrier(bio)) {
 		/*
 		 * Map barrier requests to root group. May be more special
 		 * bio cases should come here
 		 */
-		return NULL;
+		return q->elevator->efqd.root_group;
 	}
 
-#ifdef CONFIG_TRACK_ASYNC_CONTEXT
-	if (elv_bio_sync(bio)) {
-		/* sync io. Determine cgroup from submitting task context. */
-		cgroup = task_cgroup(current, io_subsys_id);
-		return cgroup;
-	}
+	/* Map the sync bio to the right group using task context */
+	if (elv_bio_sync(bio))
+		goto sync;
 
-	/* Async io. Determine cgroup from with cgroup id stored in page */
-	bio_cgroup_id = get_blkio_cgroup_id(bio);
-
-	if (!bio_cgroup_id)
-		return NULL;
-
-	cgroup = blkio_cgroup_lookup(bio_cgroup_id);
-#else
-	cgroup = task_cgroup(current, io_subsys_id);
+#ifndef CONFIG_TRACK_ASYNC_CONTEXT
+	goto sync;
 #endif
-	return cgroup;
+	/* Determine the group from info stored in page */
+	page = bio_iovec_idx(bio, 0)->bv_page;
+	return io_get_io_group(q, page, create);
+sync:
+	return io_get_io_group(q, NULL, create);
 }
+EXPORT_SYMBOL(io_get_io_group_bio);
 
 /*
- * Find the io group bio belongs to.
+ * Find the io group page belongs to.
  * If "create" is set, io group is created if it is not already present.
  *
  * Note: This function should be called with queue lock held. It returns
@@ -1488,22 +1562,27 @@ static inline struct cgroup *get_cgroup_from_bio(struct bio *bio)
  * needs to get hold of queue lock). So if somebody needs to use group
  * pointer even after dropping queue lock, take a reference to the group
  * before dropping queue lock.
+ *
+ * One can call it without queue lock with rcu read lock held for browsing
+ * through the groups.
  */
-struct io_group *io_get_io_group(struct request_queue *q, struct bio *bio,
+struct io_group *io_get_io_group(struct request_queue *q, struct page *page,
 					int create)
 {
 	struct cgroup *cgroup;
 	struct io_group *iog;
 	struct elv_fq_data *efqd = &q->elevator->efqd;
 
-	assert_spin_locked(q->queue_lock);
+
+	if (create)
+		assert_spin_locked(q->queue_lock);
 
 	rcu_read_lock();
 
-	if (!bio)
+	if (!page)
 		cgroup = task_cgroup(current, io_subsys_id);
 	else
-		cgroup = get_cgroup_from_bio(bio);
+		cgroup = get_cgroup_from_page(page);
 
 	if (!cgroup) {
 		if (create)
@@ -1518,7 +1597,7 @@ struct io_group *io_get_io_group(struct request_queue *q, struct bio *bio,
 		goto out;
 	}
 
-	iog = io_find_alloc_group(q, cgroup, efqd, create, bio);
+	iog = io_find_alloc_group(q, cgroup, efqd, create);
 	if (!iog) {
 		if (create)
 			iog = efqd->root_group;
@@ -1570,6 +1649,7 @@ struct io_group *io_alloc_root_group(struct request_queue *q,
 		iog->sched_data.service_tree[i] = IO_SERVICE_TREE_INIT;
 
 	blk_init_request_list(&iog->rl);
+	elv_io_group_congestion_threshold(q, iog);
 
 	iocg = &io_root_cgroup;
 	spin_lock_irq(&iocg->lock);
@@ -1578,6 +1658,10 @@ struct io_group *io_alloc_root_group(struct request_queue *q,
 	iog->iocg_id = css_id(&iocg->css);
 	spin_unlock_irq(&iocg->lock);
 
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+	io_group_path(iog, iog->path, sizeof(iog->path));
+#endif
+
 	return iog;
 }
 
@@ -1670,6 +1754,14 @@ void iocg_attach(struct cgroup_subsys *subsys, struct cgroup *cgroup,
 	task_unlock(tsk);
 }
 
+static void io_group_free_rcu(struct rcu_head *head)
+{
+	struct io_group *iog;
+
+	iog = container_of(head, struct io_group, rcu_head);
+	kfree(iog);
+}
+
 /*
  * This cleanup function does the last bit of things to destroy cgroup.
  * It should only get called after io_destroy_group has been invoked.
@@ -1693,7 +1785,13 @@ void io_group_cleanup(struct io_group *iog)
 	BUG_ON(entity != NULL && entity->tree != NULL);
 
 	iog->iocg_id = 0;
-	kfree(iog);
+
+	/*
+	 * Wait for any rcu readers to exit before freeing up the group.
+	 * Primarily useful when io_get_io_group() is called without queue
+	 * lock to access some group data from bdi_congested_group() path.
+	 */
+	call_rcu(&iog->rcu_head, io_group_free_rcu);
 }
 
 void elv_put_iog(struct io_group *iog)
@@ -1933,7 +2031,7 @@ int io_group_allow_merge(struct request *rq, struct bio *bio)
 		return 1;
 
 	/* Determine the io group of the bio submitting task */
-	iog = io_get_io_group(q, bio, 0);
+	iog = io_get_io_group_bio(q, bio, 0);
 	if (!iog) {
 		/* May be task belongs to a differet cgroup for which io
 		 * group has not been setup yet. */
@@ -1973,7 +2071,7 @@ int elv_fq_set_request_ioq(struct request_queue *q, struct request *rq,
 
 retry:
 	/* Determine the io group request belongs to */
-	iog = io_get_io_group(q, bio, 1);
+	iog = io_get_io_group_bio(q, bio, 1);
 	BUG_ON(!iog);
 
 	/* Get the iosched queue */
@@ -2066,7 +2164,7 @@ struct io_queue *elv_lookup_ioq_bio(struct request_queue *q, struct bio *bio)
 	struct io_group *iog;
 
 	/* Determine the io group and io queue of the bio submitting task */
-	iog = io_get_io_group(q, bio, 0);
+	iog = io_get_io_group_bio(q, bio, 0);
 	if (!iog) {
 		/* May be bio belongs to a cgroup for which io group has
 		 * not been setup yet. */
@@ -2133,7 +2231,14 @@ void io_free_root_group(struct elevator_queue *e)
 	kfree(iog);
 }
 
-struct io_group *io_get_io_group(struct request_queue *q, struct bio *bio,
+struct io_group *io_get_io_group_bio(struct request_queue *q, struct bio *bio,
+					int create)
+{
+	return q->elevator->efqd.root_group;
+}
+EXPORT_SYMBOL(io_get_io_group_bio);
+
+struct io_group *io_get_io_group(struct request_queue *q, struct page *page,
 						int create)
 {
 	return q->elevator->efqd.root_group;
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index c2f71d7..d60105f 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -258,8 +258,13 @@ struct io_group {
 	/* Single ioq per group, used for noop, deadline, anticipatory */
 	struct io_queue *ioq;
 
+	/* io group congestion on and off threshold for request descriptors */
+	unsigned int nr_congestion_on;
+	unsigned int nr_congestion_off;
+
 	/* request list associated with the group */
 	struct request_list rl;
+	struct rcu_head rcu_head;
 };
 
 /**
@@ -540,7 +545,8 @@ extern struct io_queue *elv_lookup_ioq_bio(struct request_queue *q,
 						struct bio *bio);
 extern struct request_list *io_group_get_request_list(struct request_queue *q,
 						struct bio *bio);
-
+extern int elv_io_group_congested(struct request_queue *q, struct page *page,
+					int sync);
 /* Returns single ioq associated with the io group. */
 static inline struct io_queue *io_group_ioq(struct io_group *iog)
 {
@@ -672,6 +678,8 @@ extern void *io_group_async_queue_prio(struct io_group *iog, int ioprio_class,
 extern void io_group_set_async_queue(struct io_group *iog, int ioprio_class,
 					int ioprio, struct io_queue *ioq);
 extern struct io_group *io_get_io_group(struct request_queue *q,
+					struct page *page, int create);
+extern struct io_group *io_get_io_group_bio(struct request_queue *q,
 					struct bio *bio, int create);
 extern int elv_nr_busy_ioq(struct elevator_queue *e);
 extern struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp_mask);
diff --git a/drivers/md/dm-table.c b/drivers/md/dm-table.c
index 429b50b..8fe04f1 100644
--- a/drivers/md/dm-table.c
+++ b/drivers/md/dm-table.c
@@ -1000,7 +1000,8 @@ int dm_table_resume_targets(struct dm_table *t)
 	return 0;
 }
 
-int dm_table_any_congested(struct dm_table *t, int bdi_bits)
+int dm_table_any_congested(struct dm_table *t, int bdi_bits, struct page *page,
+				int group)
 {
 	struct dm_dev_internal *dd;
 	struct list_head *devices = dm_table_get_devices(t);
@@ -1010,9 +1011,11 @@ int dm_table_any_congested(struct dm_table *t, int bdi_bits)
 		struct request_queue *q = bdev_get_queue(dd->dm_dev.bdev);
 		char b[BDEVNAME_SIZE];
 
-		if (likely(q))
-			r |= bdi_congested(&q->backing_dev_info, bdi_bits);
-		else
+		if (likely(q)) {
+			struct backing_dev_info *bdi = &q->backing_dev_info;
+			r |= group ? bdi_congested_group(bdi, bdi_bits, page)
+				: bdi_congested(bdi, bdi_bits);
+		} else
 			DMWARN_LIMIT("%s: any_congested: nonexistent device %s",
 				     dm_device_name(t->md),
 				     bdevname(dd->dm_dev.bdev, b));
diff --git a/drivers/md/dm.c b/drivers/md/dm.c
index 424f7b0..ef12cee 100644
--- a/drivers/md/dm.c
+++ b/drivers/md/dm.c
@@ -994,7 +994,8 @@ static void dm_unplug_all(struct request_queue *q)
 	}
 }
 
-static int dm_any_congested(void *congested_data, int bdi_bits)
+static int dm_any_congested(void *congested_data, int bdi_bits,
+					struct page *page, int group)
 {
 	int r = bdi_bits;
 	struct mapped_device *md = congested_data;
@@ -1003,7 +1004,7 @@ static int dm_any_congested(void *congested_data, int bdi_bits)
 	if (!test_bit(DMF_BLOCK_IO_FOR_SUSPEND, &md->flags)) {
 		map = dm_get_table(md);
 		if (map) {
-			r = dm_table_any_congested(map, bdi_bits);
+			r = dm_table_any_congested(map, bdi_bits, page, group);
 			dm_table_put(map);
 		}
 	}
diff --git a/drivers/md/dm.h b/drivers/md/dm.h
index a31506d..7efe4b4 100644
--- a/drivers/md/dm.h
+++ b/drivers/md/dm.h
@@ -46,7 +46,8 @@ struct list_head *dm_table_get_devices(struct dm_table *t);
 void dm_table_presuspend_targets(struct dm_table *t);
 void dm_table_postsuspend_targets(struct dm_table *t);
 int dm_table_resume_targets(struct dm_table *t);
-int dm_table_any_congested(struct dm_table *t, int bdi_bits);
+int dm_table_any_congested(struct dm_table *t, int bdi_bits, struct page *page,
+				int group);
 
 /*
  * To check the return value from dm_table_find_target().
diff --git a/drivers/md/linear.c b/drivers/md/linear.c
index 7a36e38..ddf43dd 100644
--- a/drivers/md/linear.c
+++ b/drivers/md/linear.c
@@ -88,7 +88,7 @@ static void linear_unplug(struct request_queue *q)
 	}
 }
 
-static int linear_congested(void *data, int bits)
+static int linear_congested(void *data, int bits, struct page *page, int group)
 {
 	mddev_t *mddev = data;
 	linear_conf_t *conf = mddev_to_conf(mddev);
@@ -96,7 +96,10 @@ static int linear_congested(void *data, int bits)
 
 	for (i = 0; i < mddev->raid_disks && !ret ; i++) {
 		struct request_queue *q = bdev_get_queue(conf->disks[i].rdev->bdev);
-		ret |= bdi_congested(&q->backing_dev_info, bits);
+		struct backing_dev_info *bdi = &q->backing_dev_info;
+
+		ret |= group ? bdi_congested_group(bdi, bits, page) :
+			bdi_congested(bdi, bits);
 	}
 	return ret;
 }
diff --git a/drivers/md/multipath.c b/drivers/md/multipath.c
index 41ced0c..9f25b21 100644
--- a/drivers/md/multipath.c
+++ b/drivers/md/multipath.c
@@ -192,7 +192,8 @@ static void multipath_status (struct seq_file *seq, mddev_t *mddev)
 	seq_printf (seq, "]");
 }
 
-static int multipath_congested(void *data, int bits)
+static int multipath_congested(void *data, int bits, struct page *page,
+					int group)
 {
 	mddev_t *mddev = data;
 	multipath_conf_t *conf = mddev_to_conf(mddev);
@@ -203,8 +204,10 @@ static int multipath_congested(void *data, int bits)
 		mdk_rdev_t *rdev = rcu_dereference(conf->multipaths[i].rdev);
 		if (rdev && !test_bit(Faulty, &rdev->flags)) {
 			struct request_queue *q = bdev_get_queue(rdev->bdev);
+			struct backing_dev_info *bdi = &q->backing_dev_info;
 
-			ret |= bdi_congested(&q->backing_dev_info, bits);
+			ret |= group ? bdi_congested_group(bdi, bits, page)
+				: bdi_congested(bdi, bits);
 			/* Just like multipath_map, we just check the
 			 * first available device
 			 */
diff --git a/drivers/md/raid0.c b/drivers/md/raid0.c
index c08d755..eb1d33a 100644
--- a/drivers/md/raid0.c
+++ b/drivers/md/raid0.c
@@ -37,7 +37,7 @@ static void raid0_unplug(struct request_queue *q)
 	}
 }
 
-static int raid0_congested(void *data, int bits)
+static int raid0_congested(void *data, int bits, struct page *page, int group)
 {
 	mddev_t *mddev = data;
 	raid0_conf_t *conf = mddev_to_conf(mddev);
@@ -46,8 +46,10 @@ static int raid0_congested(void *data, int bits)
 
 	for (i = 0; i < mddev->raid_disks && !ret ; i++) {
 		struct request_queue *q = bdev_get_queue(devlist[i]->bdev);
+		struct backing_dev_info *bdi = &q->backing_dev_info;
 
-		ret |= bdi_congested(&q->backing_dev_info, bits);
+		ret |= group ? bdi_congested_group(bdi, bits, page)
+				: bdi_congested(bdi, bits);
 	}
 	return ret;
 }
diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
index 36df910..cdd268e 100644
--- a/drivers/md/raid1.c
+++ b/drivers/md/raid1.c
@@ -570,7 +570,7 @@ static void raid1_unplug(struct request_queue *q)
 	md_wakeup_thread(mddev->thread);
 }
 
-static int raid1_congested(void *data, int bits)
+static int raid1_congested(void *data, int bits, struct page *page, int group)
 {
 	mddev_t *mddev = data;
 	conf_t *conf = mddev_to_conf(mddev);
@@ -581,14 +581,17 @@ static int raid1_congested(void *data, int bits)
 		mdk_rdev_t *rdev = rcu_dereference(conf->mirrors[i].rdev);
 		if (rdev && !test_bit(Faulty, &rdev->flags)) {
 			struct request_queue *q = bdev_get_queue(rdev->bdev);
+			struct backing_dev_info *bdi = &q->backing_dev_info;
 
 			/* Note the '|| 1' - when read_balance prefers
 			 * non-congested targets, it can be removed
 			 */
 			if ((bits & (1<<BDI_async_congested)) || 1)
-				ret |= bdi_congested(&q->backing_dev_info, bits);
+				ret |= group ? bdi_congested_group(bdi, bits,
+					page) : bdi_congested(bdi, bits);
 			else
-				ret &= bdi_congested(&q->backing_dev_info, bits);
+				ret &= group ? bdi_congested_group(bdi, bits,
+					page) : bdi_congested(bdi, bits);
 		}
 	}
 	rcu_read_unlock();
diff --git a/drivers/md/raid10.c b/drivers/md/raid10.c
index 499620a..49f41e3 100644
--- a/drivers/md/raid10.c
+++ b/drivers/md/raid10.c
@@ -625,7 +625,7 @@ static void raid10_unplug(struct request_queue *q)
 	md_wakeup_thread(mddev->thread);
 }
 
-static int raid10_congested(void *data, int bits)
+static int raid10_congested(void *data, int bits, struct page *page, int group)
 {
 	mddev_t *mddev = data;
 	conf_t *conf = mddev_to_conf(mddev);
@@ -636,8 +636,10 @@ static int raid10_congested(void *data, int bits)
 		mdk_rdev_t *rdev = rcu_dereference(conf->mirrors[i].rdev);
 		if (rdev && !test_bit(Faulty, &rdev->flags)) {
 			struct request_queue *q = bdev_get_queue(rdev->bdev);
+			struct backing_dev_info *bdi = &q->backing_dev_info;
 
-			ret |= bdi_congested(&q->backing_dev_info, bits);
+			ret |= group ? bdi_congested_group(bdi, bits, page)
+				: bdi_congested(bdi, bits);
 		}
 	}
 	rcu_read_unlock();
diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index bb37fb1..40f76a4 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -3324,7 +3324,7 @@ static void raid5_unplug_device(struct request_queue *q)
 	unplug_slaves(mddev);
 }
 
-static int raid5_congested(void *data, int bits)
+static int raid5_congested(void *data, int bits, struct page *page, int group)
 {
 	mddev_t *mddev = data;
 	raid5_conf_t *conf = mddev_to_conf(mddev);
diff --git a/fs/afs/write.c b/fs/afs/write.c
index c2e7a7f..aa8b359 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -455,7 +455,7 @@ int afs_writepage(struct page *page, struct writeback_control *wbc)
 	}
 
 	wbc->nr_to_write -= ret;
-	if (wbc->nonblocking && bdi_write_congested(bdi))
+	if (wbc->nonblocking && bdi_or_group_write_congested(bdi, page))
 		wbc->encountered_congestion = 1;
 
 	_leave(" = 0");
@@ -491,6 +491,12 @@ static int afs_writepages_region(struct address_space *mapping,
 			return 0;
 		}
 
+		if (wbc->nonblocking && bdi_write_congested_group(bdi, page)) {
+			wbc->encountered_congestion = 1;
+			page_cache_release(page);
+			break;
+		}
+
 		/* at this point we hold neither mapping->tree_lock nor lock on
 		 * the page itself: the page may be truncated or invalidated
 		 * (changing page->mapping to NULL), or even swizzled back from
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 4b0ea0b..245d8f4 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -1250,7 +1250,8 @@ struct btrfs_root *btrfs_read_fs_root(struct btrfs_fs_info *fs_info,
 	return root;
 }
 
-static int btrfs_congested_fn(void *congested_data, int bdi_bits)
+static int btrfs_congested_fn(void *congested_data, int bdi_bits,
+					struct page *page, int group)
 {
 	struct btrfs_fs_info *info = (struct btrfs_fs_info *)congested_data;
 	int ret = 0;
@@ -1261,7 +1262,8 @@ static int btrfs_congested_fn(void *congested_data, int bdi_bits)
 		if (!device->bdev)
 			continue;
 		bdi = blk_get_backing_dev_info(device->bdev);
-		if (bdi && bdi_congested(bdi, bdi_bits)) {
+		if (bdi && (group ? bdi_congested_group(bdi, bdi_bits, page) :
+		    bdi_congested(bdi, bdi_bits))) {
 			ret = 1;
 			break;
 		}
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index fe9eb99..fac4299 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2358,6 +2358,18 @@ retry:
 		unsigned i;
 
 		scanned = 1;
+
+		/*
+		 * If the io group page will go into is congested, bail out.
+		 */
+		if (wbc->nonblocking
+		    && bdi_write_congested_group(bdi, pvec.pages[0])) {
+			wbc->encountered_congestion = 1;
+			done = 1;
+			pagevec_release(&pvec);
+			break;
+		}
+
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
diff --git a/fs/btrfs/volumes.c b/fs/btrfs/volumes.c
index a6d35b0..5b19141 100644
--- a/fs/btrfs/volumes.c
+++ b/fs/btrfs/volumes.c
@@ -163,6 +163,7 @@ static noinline int run_scheduled_bios(struct btrfs_device *device)
 	unsigned long num_sync_run;
 	unsigned long limit;
 	unsigned long last_waited = 0;
+	struct page *page;
 
 	bdi = blk_get_backing_dev_info(device->bdev);
 	fs_info = device->dev_root->fs_info;
@@ -265,8 +266,11 @@ loop_lock:
 		 * is now congested.  Back off and let other work structs
 		 * run instead
 		 */
-		if (pending && bdi_write_congested(bdi) && num_run > 16 &&
-		    fs_info->fs_devices->open_devices > 1) {
+		if (pending)
+			page = bio_iovec_idx(pending, 0)->bv_page;
+
+		if (pending && bdi_or_group_write_congested(bdi, page) &&
+		    num_run > 16 && fs_info->fs_devices->open_devices > 1) {
 			struct io_context *ioc;
 
 			ioc = current->io_context;
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 302ea15..71d3fb5 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -1466,6 +1466,17 @@ retry:
 		n_iov = 0;
 		bytes_to_write = 0;
 
+		/*
+		 * If the io group page will go into is congested, bail out.
+		 */
+		if (wbc->nonblocking &&
+		    bdi_write_congested_group(bdi, pvec.pages[0])) {
+			wbc->encountered_congestion = 1;
+			done = 1;
+			pagevec_release(&pvec);
+			break;
+		}
+
 		for (i = 0; i < nr_pages; i++) {
 			page = pvec.pages[i];
 			/*
diff --git a/fs/ext2/ialloc.c b/fs/ext2/ialloc.c
index 15387c9..090a961 100644
--- a/fs/ext2/ialloc.c
+++ b/fs/ext2/ialloc.c
@@ -179,7 +179,7 @@ static void ext2_preread_inode(struct inode *inode)
 	struct backing_dev_info *bdi;
 
 	bdi = inode->i_mapping->backing_dev_info;
-	if (bdi_read_congested(bdi))
+	if (bdi_or_group_read_congested(bdi, NULL))
 		return;
 	if (bdi_write_congested(bdi))
 		return;
diff --git a/fs/gfs2/ops_address.c b/fs/gfs2/ops_address.c
index a6dde17..b352f19 100644
--- a/fs/gfs2/ops_address.c
+++ b/fs/gfs2/ops_address.c
@@ -372,6 +372,18 @@ retry:
 					       PAGECACHE_TAG_DIRTY,
 					       min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1))) {
 		scanned = 1;
+
+		/*
+		 * If io group page belongs to is congested. bail out.
+		 */
+		if (wbc->nonblocking
+		    && bdi_write_congested_group(bdi, pvec.pages[0])) {
+			wbc->encountered_congestion = 1;
+			done = 1;
+			pagevec_release(&pvec);
+			break;
+		}
+
 		ret = gfs2_write_jdata_pagevec(mapping, wbc, &pvec, nr_pages, end);
 		if (ret)
 			done = 1;
diff --git a/fs/nilfs2/segbuf.c b/fs/nilfs2/segbuf.c
index 1e68821..abcb161 100644
--- a/fs/nilfs2/segbuf.c
+++ b/fs/nilfs2/segbuf.c
@@ -267,8 +267,9 @@ static int nilfs_submit_seg_bio(struct nilfs_write_info *wi, int mode)
 {
 	struct bio *bio = wi->bio;
 	int err;
+	struct page *page = bio_iovec_idx(bio, 0)->bv_page;
 
-	if (wi->nbio > 0 && bdi_write_congested(wi->bdi)) {
+	if (wi->nbio > 0 && bdi_or_group_write_congested(wi->bdi, page)) {
 		wait_for_completion(&wi->bio_event);
 		wi->nbio--;
 		if (unlikely(atomic_read(&wi->err))) {
diff --git a/fs/xfs/linux-2.6/xfs_aops.c b/fs/xfs/linux-2.6/xfs_aops.c
index 7ec89fc..2a515ab 100644
--- a/fs/xfs/linux-2.6/xfs_aops.c
+++ b/fs/xfs/linux-2.6/xfs_aops.c
@@ -891,7 +891,7 @@ xfs_convert_page(
 
 			bdi = inode->i_mapping->backing_dev_info;
 			wbc->nr_to_write--;
-			if (bdi_write_congested(bdi)) {
+			if (bdi_or_group_write_congested(bdi, page)) {
 				wbc->encountered_congestion = 1;
 				done = 1;
 			} else if (wbc->nr_to_write <= 0) {
diff --git a/fs/xfs/linux-2.6/xfs_buf.c b/fs/xfs/linux-2.6/xfs_buf.c
index e28800a..9e000f4 100644
--- a/fs/xfs/linux-2.6/xfs_buf.c
+++ b/fs/xfs/linux-2.6/xfs_buf.c
@@ -714,7 +714,7 @@ xfs_buf_readahead(
 	struct backing_dev_info *bdi;
 
 	bdi = target->bt_mapping->backing_dev_info;
-	if (bdi_read_congested(bdi))
+	if (bdi_or_group_read_congested(bdi, NULL))
 		return;
 
 	flags |= (XBF_TRYLOCK|XBF_ASYNC|XBF_READ_AHEAD);
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 0ec2c59..f06fdbf 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -29,7 +29,7 @@ enum bdi_state {
 	BDI_unused,		/* Available bits start here */
 };
 
-typedef int (congested_fn)(void *, int);
+typedef int (congested_fn)(void *, int, struct page *, int);
 
 enum bdi_stat_item {
 	BDI_RECLAIMABLE,
@@ -209,7 +209,7 @@ int writeback_in_progress(struct backing_dev_info *bdi);
 static inline int bdi_congested(struct backing_dev_info *bdi, int bdi_bits)
 {
 	if (bdi->congested_fn)
-		return bdi->congested_fn(bdi->congested_data, bdi_bits);
+		return bdi->congested_fn(bdi->congested_data, bdi_bits, NULL, 0);
 	return (bdi->state & bdi_bits);
 }
 
@@ -229,6 +229,63 @@ static inline int bdi_rw_congested(struct backing_dev_info *bdi)
 				  (1 << BDI_async_congested));
 }
 
+#ifdef CONFIG_GROUP_IOSCHED
+extern int bdi_congested_group(struct backing_dev_info *bdi, int bdi_bits,
+				struct page *page);
+
+extern int bdi_read_congested_group(struct backing_dev_info *bdi,
+						struct page *page);
+
+extern int bdi_or_group_read_congested(struct backing_dev_info *bdi,
+					struct page *page);
+
+extern int bdi_write_congested_group(struct backing_dev_info *bdi,
+					struct page *page);
+
+extern int bdi_or_group_write_congested(struct backing_dev_info *bdi,
+					struct page *page);
+
+extern int bdi_rw_congested_group(struct backing_dev_info *bdi,
+					struct page *page);
+#else /* CONFIG_GROUP_IOSCHED */
+static inline int bdi_congested_group(struct backing_dev_info *bdi,
+					int bdi_bits, struct page *page)
+{
+	return bdi_congested(bdi, bdi_bits);
+}
+
+static inline int bdi_read_congested_group(struct backing_dev_info *bdi,
+						struct page *page)
+{
+	return bdi_read_congested(bdi);
+}
+
+static inline int bdi_or_group_read_congested(struct backing_dev_info *bdi,
+						struct page *page)
+{
+	return bdi_read_congested(bdi);
+}
+
+static inline int bdi_write_congested_group(struct backing_dev_info *bdi,
+						struct page *page)
+{
+	return bdi_write_congested(bdi);
+}
+
+static inline int bdi_or_group_write_congested(struct backing_dev_info *bdi,
+						struct page *page)
+{
+	return bdi_write_congested(bdi);
+}
+
+static inline int bdi_rw_congested_group(struct backing_dev_info *bdi,
+						struct page *page)
+{
+	return bdi_rw_congested(bdi);
+}
+
+#endif /* CONFIG_GROUP_IOSCHED */
+
 void clear_bdi_congested(struct backing_dev_info *bdi, int rw);
 void set_bdi_congested(struct backing_dev_info *bdi, int rw);
 long congestion_wait(int rw, long timeout);
diff --git a/include/linux/biotrack.h b/include/linux/biotrack.h
index 741a8b5..0b4491a 100644
--- a/include/linux/biotrack.h
+++ b/include/linux/biotrack.h
@@ -49,6 +49,7 @@ extern void blkio_cgroup_copy_owner(struct page *page, struct page *opage);
 
 extern struct io_context *get_blkio_cgroup_iocontext(struct bio *bio);
 extern unsigned long get_blkio_cgroup_id(struct bio *bio);
+extern unsigned long get_blkio_cgroup_id_page(struct page *page);
 extern struct cgroup *blkio_cgroup_lookup(int id);
 
 #else	/* CONFIG_CGROUP_BIO */
@@ -92,6 +93,11 @@ static inline unsigned long get_blkio_cgroup_id(struct bio *bio)
 	return 0;
 }
 
+static inline unsigned long get_blkio_cgroup_id_page(struct page *page)
+{
+	return 0;
+}
+
 #endif	/* CONFIG_CGROUP_BLKIO */
 
 #endif /* _LINUX_BIOTRACK_H */
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 7fd7d33..45e4cb7 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -880,6 +880,11 @@ static inline void blk_set_queue_congested(struct request_queue *q, int rw)
 	set_bdi_congested(&q->backing_dev_info, rw);
 }
 
+#ifdef CONFIG_GROUP_IOSCHED
+extern int blk_queue_io_group_congested(struct backing_dev_info *bdi,
+					int bdi_bits, struct page *page);
+#endif
+
 extern void blk_start_queue(struct request_queue *q);
 extern void blk_stop_queue(struct request_queue *q);
 extern void blk_sync_queue(struct request_queue *q);
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 493b468..cef038d 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -7,6 +7,7 @@
 #include <linux/module.h>
 #include <linux/writeback.h>
 #include <linux/device.h>
+#include "../block/elevator-fq.h"
 
 void default_unplug_io_fn(struct backing_dev_info *bdi, struct page *page)
 {
@@ -328,3 +329,64 @@ long congestion_wait(int rw, long timeout)
 }
 EXPORT_SYMBOL(congestion_wait);
 
+/*
+ * With group IO scheduling, there are request descriptors per io group per
+ * queue. So generic notion of whether queue is congested or not is not
+ * very accurate. Queue might not be congested but the io group in which
+ * request will go might actually be congested.
+ *
+ * Hence to get the correct idea about congestion level, one should query
+ * the io group congestion status on the queue. Pass in the page information
+ * which can be used to determine the io group of the page and congestion
+ * status can be determined accordingly.
+ *
+ * If page info is not passed, io group is determined from the current task
+ * context.
+ */
+#ifdef CONFIG_GROUP_IOSCHED
+int bdi_congested_group(struct backing_dev_info *bdi, int bdi_bits,
+				struct page *page)
+{
+	if (bdi->congested_fn)
+		return bdi->congested_fn(bdi->congested_data, bdi_bits, page, 1);
+
+	return blk_queue_io_group_congested(bdi, bdi_bits, page);
+}
+EXPORT_SYMBOL(bdi_congested_group);
+
+int bdi_read_congested_group(struct backing_dev_info *bdi, struct page *page)
+{
+	return bdi_congested_group(bdi, 1 << BDI_sync_congested, page);
+}
+EXPORT_SYMBOL(bdi_read_congested_group);
+
+/* Checks if either bdi or associated group is read congested */
+int bdi_or_group_read_congested(struct backing_dev_info *bdi,
+						struct page *page)
+{
+	return bdi_read_congested(bdi) || bdi_read_congested_group(bdi, page);
+}
+EXPORT_SYMBOL(bdi_or_group_read_congested);
+
+int bdi_write_congested_group(struct backing_dev_info *bdi, struct page *page)
+{
+	return bdi_congested_group(bdi, 1 << BDI_async_congested, page);
+}
+EXPORT_SYMBOL(bdi_write_congested_group);
+
+/* Checks if either bdi or associated group is write congested */
+int bdi_or_group_write_congested(struct backing_dev_info *bdi,
+						struct page *page)
+{
+	return bdi_write_congested(bdi) || bdi_write_congested_group(bdi, page);
+}
+EXPORT_SYMBOL(bdi_or_group_write_congested);
+
+int bdi_rw_congested_group(struct backing_dev_info *bdi, struct page *page)
+{
+	return bdi_congested_group(bdi, (1 << BDI_sync_congested) |
+				  (1 << BDI_async_congested), page);
+}
+EXPORT_SYMBOL(bdi_rw_congested_group);
+
+#endif /* CONFIG_GROUP_IOSCHED */
diff --git a/mm/biotrack.c b/mm/biotrack.c
index 2baf1f0..f7d8efb 100644
--- a/mm/biotrack.c
+++ b/mm/biotrack.c
@@ -212,6 +212,27 @@ unsigned long get_blkio_cgroup_id(struct bio *bio)
 }
 
 /**
+ * get_blkio_cgroup_id_page() - determine the blkio-cgroup ID
+ * @page:	the &struct page which describes the I/O
+ *
+ * Returns the blkio-cgroup ID of a given page. A return value zero
+ * means that the page associated with the IO belongs to default_blkio_cgroup.
+ */
+unsigned long get_blkio_cgroup_id_page(struct page *page)
+{
+	struct page_cgroup *pc;
+	unsigned long id = 0;
+
+	pc = lookup_page_cgroup(page);
+	if (pc) {
+		lock_page_cgroup(pc);
+		id = page_cgroup_get_id(pc);
+		unlock_page_cgroup(pc);
+	}
+	return id;
+}
+
+/**
  * get_blkio_cgroup_iocontext() - determine the blkio-cgroup iocontext
  * @bio:	the &struct bio which describe the I/O
  *
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 3604c35..26b9e0a 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -981,6 +981,17 @@ retry:
 		if (nr_pages == 0)
 			break;
 
+		/*
+		 * If the io group page will go into is congested, bail out.
+		 */
+		if (wbc->nonblocking
+		    && bdi_write_congested_group(bdi, pvec.pages[0])) {
+			wbc->encountered_congestion = 1;
+			done = 1;
+			pagevec_release(&pvec);
+			break;
+		}
+
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
diff --git a/mm/readahead.c b/mm/readahead.c
index 133b6d5..acd9c57 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -240,7 +240,7 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 int do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			pgoff_t offset, unsigned long nr_to_read)
 {
-	if (bdi_read_congested(mapping->backing_dev_info))
+	if (bdi_or_group_read_congested(mapping->backing_dev_info, NULL))
 		return -1;
 
 	return __do_page_cache_readahead(mapping, filp, offset, nr_to_read, 0);
@@ -485,7 +485,7 @@ page_cache_async_readahead(struct address_space *mapping,
 	/*
 	 * Defer asynchronous read-ahead on IO congestion.
 	 */
-	if (bdi_read_congested(mapping->backing_dev_info))
+	if (bdi_or_group_read_congested(mapping->backing_dev_info, NULL))
 		return;
 
 	/* do read-ahead */
-- 
1.6.0.6
