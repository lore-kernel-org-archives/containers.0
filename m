From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH UPDATED v4 10/10] blkcg: implement per-blkg request allocation
Date: Tue, 26 Jun 2012 15:34:37 -0700
Message-ID: <20120626223437.GD15811@google.com>
References: <1338867660-4689-1-git-send-email-tj@kernel.org>
	<1338867660-4689-11-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1338867660-4689-11-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

From 866f8c15fafc3ae461463d5937f448eee2631ac5 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Tue, 26 Jun 2012 15:05:44 -0700

Currently, request_queue has one request_list to allocate requests
from regardless of blkcg of the IO being issued.  When the unified
request pool is used up, cfq proportional IO limits become meaningless
- whoever grabs the next request being freed wins the race regardless
of the configured weights.

This can be easily demonstrated by creating a blkio cgroup w/ very low
weight, put a program which can issue a lot of random direct IOs there
and running a sequential IO from a different cgroup.  As soon as the
request pool is used up, the sequential IO bandwidth crashes.

This patch implements per-blkg request_list.  Each blkg has its own
request_list and any IO allocates its request from the matching blkg
making blkcgs completely isolated in terms of request allocation.

* Root blkcg uses the request_list embedded in each request_queue,
  which was renamed to @q->root_rl from @q->rq.  While making blkcg rl
  handling a bit harier, this enables avoiding most overhead for root
  blkcg.

* Queue fullness is properly per request_list but bdi isn't blkcg
  aware yet, so congestion state currently just follows the root
  blkcg.  As writeback isn't aware of blkcg yet, this works okay for
  async congestion but readahead may get the wrong signals.  It's
  better than blkcg completely collapsing with shared request_list but
  needs to be improved with future changes.

* After this change, each block cgroup gets a full request pool making
  resource consumption of each cgroup higher.  This makes allowing
  non-root users to create cgroups less desirable; however, note that
  allowing non-root users to directly manage cgroups is already
  severely broken regardless of this patch - each block cgroup
  consumes kernel memory and skews IO weight (IO weights are not
  hierarchical).

v2: queue-sysfs.txt updated and patch description udpated as suggested
    by Vivek.

v3: blk_get_rl() wasn't checking error return from
    blkg_lookup_create() and may cause oops on lookup failure.  Fix it
    by falling back to root_rl on blkg lookup failures.  This problem
    was spotted by Rakesh Iyer <rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>.

v4: Updated to accomodate 458f27a982 "block: Avoid missed wakeup in
    request waitqueue".  blk_drain_queue() now wakes up waiters on all
    blkg->rl on the target queue.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
v4 to fix build failure on top of block/for-3.6/core.  git branch has
been udpated too.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git blkcg-rl

Only the top commit has changed.

Thanks.

 Documentation/block/queue-sysfs.txt |    7 +++
 block/blk-cgroup.c                  |   51 ++++++++++++++++--
 block/blk-cgroup.h                  |  102 +++++++++++++++++++++++++++++++++++
 block/blk-core.c                    |   42 +++++++++++----
 block/blk-sysfs.c                   |   32 +++++++-----
 include/linux/blkdev.h              |   12 +++-
 6 files changed, 216 insertions(+), 30 deletions(-)

diff --git a/Documentation/block/queue-sysfs.txt b/Documentation/block/queue-sysfs.txt
index d8147b3..6518a55 100644
--- a/Documentation/block/queue-sysfs.txt
+++ b/Documentation/block/queue-sysfs.txt
@@ -38,6 +38,13 @@ read or write requests. Note that the total allocated number may be twice
 this amount, since it applies only to reads or writes (not the accumulated
 sum).
 
+To avoid priority inversion through request starvation, a request
+queue maintains a separate request pool per each cgroup when
+CONFIG_BLK_CGROUP is enabled, and this parameter applies to each such
+per-block-cgroup request pool.  IOW, if there are N block cgroups,
+each request queue may have upto N request pools, each independently
+regulated by nr_requests.
+
 read_ahead_kb (RW)
 ------------------
 Maximum number of kilobytes to read-ahead for filesystems on this block
diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 63b31eb..f3b44a6 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -63,6 +63,7 @@ static void blkg_free(struct blkcg_gq *blkg)
 		kfree(pd);
 	}
 
+	blk_exit_rl(&blkg->rl);
 	kfree(blkg);
 }
 
@@ -90,6 +91,13 @@ static struct blkcg_gq *blkg_alloc(struct blkcg *blkcg, struct request_queue *q,
 	blkg->blkcg = blkcg;
 	blkg->refcnt = 1;
 
+	/* root blkg uses @q->root_rl, init rl only for !root blkgs */
+	if (blkcg != &blkcg_root) {
+		if (blk_init_rl(&blkg->rl, q, gfp_mask))
+			goto err_free;
+		blkg->rl.blkg = blkg;
+	}
+
 	for (i = 0; i < BLKCG_MAX_POLS; i++) {
 		struct blkcg_policy *pol = blkcg_policy[i];
 		struct blkg_policy_data *pd;
@@ -99,10 +107,8 @@ static struct blkcg_gq *blkg_alloc(struct blkcg *blkcg, struct request_queue *q,
 
 		/* alloc per-policy data and attach it to blkg */
 		pd = kzalloc_node(pol->pd_size, gfp_mask, q->node);
-		if (!pd) {
-			blkg_free(blkg);
-			return NULL;
-		}
+		if (!pd)
+			goto err_free;
 
 		blkg->pd[i] = pd;
 		pd->blkg = blkg;
@@ -113,6 +119,10 @@ static struct blkcg_gq *blkg_alloc(struct blkcg *blkcg, struct request_queue *q,
 	}
 
 	return blkg;
+
+err_free:
+	blkg_free(blkg);
+	return NULL;
 }
 
 static struct blkcg_gq *__blkg_lookup(struct blkcg *blkcg,
@@ -300,6 +310,38 @@ void __blkg_release(struct blkcg_gq *blkg)
 }
 EXPORT_SYMBOL_GPL(__blkg_release);
 
+/*
+ * The next function used by blk_queue_for_each_rl().  It's a bit tricky
+ * because the root blkg uses @q->root_rl instead of its own rl.
+ */
+struct request_list *__blk_queue_next_rl(struct request_list *rl,
+					 struct request_queue *q)
+{
+	struct list_head *ent;
+	struct blkcg_gq *blkg;
+
+	/*
+	 * Determine the current blkg list_head.  The first entry is
+	 * root_rl which is off @q->blkg_list and mapped to the head.
+	 */
+	if (rl == &q->root_rl) {
+		ent = &q->blkg_list;
+	} else {
+		blkg = container_of(rl, struct blkcg_gq, rl);
+		ent = &blkg->q_node;
+	}
+
+	/* walk to the next list_head, skip root blkcg */
+	ent = ent->next;
+	if (ent == &q->root_blkg->q_node)
+		ent = ent->next;
+	if (ent == &q->blkg_list)
+		return NULL;
+
+	blkg = container_of(ent, struct blkcg_gq, q_node);
+	return &blkg->rl;
+}
+
 static int blkcg_reset_stats(struct cgroup *cgroup, struct cftype *cftype,
 			     u64 val)
 {
@@ -750,6 +792,7 @@ int blkcg_activate_policy(struct request_queue *q,
 		goto out_unlock;
 	}
 	q->root_blkg = blkg;
+	q->root_rl.blkg = blkg;
 
 	list_for_each_entry(blkg, &q->blkg_list, q_node)
 		cnt++;
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index e74cce1..2459730 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -17,6 +17,7 @@
 #include <linux/u64_stats_sync.h>
 #include <linux/seq_file.h>
 #include <linux/radix-tree.h>
+#include <linux/blkdev.h>
 
 /* Max limits for throttle policy */
 #define THROTL_IOPS_MAX		UINT_MAX
@@ -93,6 +94,8 @@ struct blkcg_gq {
 	struct list_head		q_node;
 	struct hlist_node		blkcg_node;
 	struct blkcg			*blkcg;
+	/* request allocation list for this blkcg-q pair */
+	struct request_list		rl;
 	/* reference count */
 	int				refcnt;
 
@@ -251,6 +254,95 @@ static inline void blkg_put(struct blkcg_gq *blkg)
 }
 
 /**
+ * blk_get_rl - get request_list to use
+ * @q: request_queue of interest
+ * @bio: bio which will be attached to the allocated request (may be %NULL)
+ *
+ * The caller wants to allocate a request from @q to use for @bio.  Find
+ * the request_list to use and obtain a reference on it.  Should be called
+ * under queue_lock.  This function is guaranteed to return non-%NULL
+ * request_list.
+ */
+static inline struct request_list *blk_get_rl(struct request_queue *q,
+					      struct bio *bio)
+{
+	struct blkcg *blkcg;
+	struct blkcg_gq *blkg;
+
+	rcu_read_lock();
+
+	blkcg = bio_blkcg(bio);
+
+	/* bypass blkg lookup and use @q->root_rl directly for root */
+	if (blkcg == &blkcg_root)
+		goto root_rl;
+
+	/*
+	 * Try to use blkg->rl.  blkg lookup may fail under memory pressure
+	 * or if either the blkcg or queue is going away.  Fall back to
+	 * root_rl in such cases.
+	 */
+	blkg = blkg_lookup_create(blkcg, q);
+	if (unlikely(IS_ERR(blkg)))
+		goto root_rl;
+
+	blkg_get(blkg);
+	rcu_read_unlock();
+	return &blkg->rl;
+root_rl:
+	rcu_read_unlock();
+	return &q->root_rl;
+}
+
+/**
+ * blk_put_rl - put request_list
+ * @rl: request_list to put
+ *
+ * Put the reference acquired by blk_get_rl().  Should be called under
+ * queue_lock.
+ */
+static inline void blk_put_rl(struct request_list *rl)
+{
+	/* root_rl may not have blkg set */
+	if (rl->blkg && rl->blkg->blkcg != &blkcg_root)
+		blkg_put(rl->blkg);
+}
+
+/**
+ * blk_rq_set_rl - associate a request with a request_list
+ * @rq: request of interest
+ * @rl: target request_list
+ *
+ * Associate @rq with @rl so that accounting and freeing can know the
+ * request_list @rq came from.
+ */
+static inline void blk_rq_set_rl(struct request *rq, struct request_list *rl)
+{
+	rq->rl = rl;
+}
+
+/**
+ * blk_rq_rl - return the request_list a request came from
+ * @rq: request of interest
+ *
+ * Return the request_list @rq is allocated from.
+ */
+static inline struct request_list *blk_rq_rl(struct request *rq)
+{
+	return rq->rl;
+}
+
+struct request_list *__blk_queue_next_rl(struct request_list *rl,
+					 struct request_queue *q);
+/**
+ * blk_queue_for_each_rl - iterate through all request_lists of a request_queue
+ *
+ * Should be used under queue_lock.
+ */
+#define blk_queue_for_each_rl(rl, q)	\
+	for ((rl) = &(q)->root_rl; (rl); (rl) = __blk_queue_next_rl((rl), (q)))
+
+/**
  * blkg_stat_add - add a value to a blkg_stat
  * @stat: target blkg_stat
  * @val: value to add
@@ -392,6 +484,7 @@ static inline void blkcg_deactivate_policy(struct request_queue *q,
 
 static inline struct blkcg *cgroup_to_blkcg(struct cgroup *cgroup) { return NULL; }
 static inline struct blkcg *bio_blkcg(struct bio *bio) { return NULL; }
+
 static inline struct blkg_policy_data *blkg_to_pd(struct blkcg_gq *blkg,
 						  struct blkcg_policy *pol) { return NULL; }
 static inline struct blkcg_gq *pd_to_blkg(struct blkg_policy_data *pd) { return NULL; }
@@ -399,5 +492,14 @@ static inline char *blkg_path(struct blkcg_gq *blkg) { return NULL; }
 static inline void blkg_get(struct blkcg_gq *blkg) { }
 static inline void blkg_put(struct blkcg_gq *blkg) { }
 
+static inline struct request_list *blk_get_rl(struct request_queue *q,
+					      struct bio *bio) { return &q->root_rl; }
+static inline void blk_put_rl(struct request_list *rl) { }
+static inline void blk_rq_set_rl(struct request *rq, struct request_list *rl) { }
+static inline struct request_list *blk_rq_rl(struct request *rq) { return &rq->q->root_rl; }
+
+#define blk_queue_for_each_rl(rl, q)	\
+	for ((rl) = &(q)->root_rl; (rl); (rl) = NULL)
+
 #endif	/* CONFIG_BLK_CGROUP */
 #endif	/* _BLK_CGROUP_H */
diff --git a/block/blk-core.c b/block/blk-core.c
index f392a2e..dd134d8 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -416,9 +416,14 @@ void blk_drain_queue(struct request_queue *q, bool drain_all)
 	 * left with hung waiters. We need to wake up those waiters.
 	 */
 	if (q->request_fn) {
+		struct request_list *rl;
+
 		spin_lock_irq(q->queue_lock);
-		for (i = 0; i < ARRAY_SIZE(q->rq.wait); i++)
-			wake_up_all(&q->rq.wait[i]);
+
+		blk_queue_for_each_rl(rl, q)
+			for (i = 0; i < ARRAY_SIZE(rl->wait); i++)
+				wake_up_all(&rl->wait[i]);
+
 		spin_unlock_irq(q->queue_lock);
 	}
 }
@@ -685,7 +690,7 @@ blk_init_allocated_queue(struct request_queue *q, request_fn_proc *rfn,
 	if (!q)
 		return NULL;
 
-	if (blk_init_rl(&q->rq, q, GFP_KERNEL))
+	if (blk_init_rl(&q->root_rl, q, GFP_KERNEL))
 		return NULL;
 
 	q->request_fn		= rfn;
@@ -776,7 +781,12 @@ static void __freed_request(struct request_list *rl, int sync)
 {
 	struct request_queue *q = rl->q;
 
-	if (rl->count[sync] < queue_congestion_off_threshold(q))
+	/*
+	 * bdi isn't aware of blkcg yet.  As all async IOs end up root
+	 * blkcg anyway, just use root blkcg state.
+	 */
+	if (rl == &q->root_rl &&
+	    rl->count[sync] < queue_congestion_off_threshold(q))
 		blk_clear_queue_congested(q, sync);
 
 	if (rl->count[sync] + 1 <= q->nr_requests) {
@@ -897,7 +907,12 @@ static struct request *__get_request(struct request_list *rl, int rw_flags,
 				}
 			}
 		}
-		blk_set_queue_congested(q, is_sync);
+		/*
+		 * bdi isn't aware of blkcg yet.  As all async IOs end up
+		 * root blkcg anyway, just use root blkcg state.
+		 */
+		if (rl == &q->root_rl)
+			blk_set_queue_congested(q, is_sync);
 	}
 
 	/*
@@ -939,6 +954,7 @@ static struct request *__get_request(struct request_list *rl, int rw_flags,
 		goto fail_alloc;
 
 	blk_rq_init(q, rq);
+	blk_rq_set_rl(rq, rl);
 	rq->cmd_flags = rw_flags | REQ_ALLOCED;
 
 	/* init elvpriv */
@@ -1032,15 +1048,19 @@ static struct request *get_request(struct request_queue *q, int rw_flags,
 {
 	const bool is_sync = rw_is_sync(rw_flags) != 0;
 	DEFINE_WAIT(wait);
-	struct request_list *rl = &q->rq;
+	struct request_list *rl;
 	struct request *rq;
+
+	rl = blk_get_rl(q, bio);	/* transferred to @rq on success */
 retry:
-	rq = __get_request(&q->rq, rw_flags, bio, gfp_mask);
+	rq = __get_request(rl, rw_flags, bio, gfp_mask);
 	if (rq)
 		return rq;
 
-	if (!(gfp_mask & __GFP_WAIT) || unlikely(blk_queue_dead(q)))
+	if (!(gfp_mask & __GFP_WAIT) || unlikely(blk_queue_dead(q))) {
+		blk_put_rl(rl);
 		return NULL;
+	}
 
 	/* wait on @rl and retry */
 	prepare_to_wait_exclusive(&rl->wait[is_sync], &wait,
@@ -1231,12 +1251,14 @@ void __blk_put_request(struct request_queue *q, struct request *req)
 	 */
 	if (req->cmd_flags & REQ_ALLOCED) {
 		unsigned int flags = req->cmd_flags;
+		struct request_list *rl = blk_rq_rl(req);
 
 		BUG_ON(!list_empty(&req->queuelist));
 		BUG_ON(!hlist_unhashed(&req->hash));
 
-		blk_free_request(&q->rq, req);
-		freed_request(&q->rq, flags);
+		blk_free_request(rl, req);
+		freed_request(rl, flags);
+		blk_put_rl(rl);
 	}
 }
 EXPORT_SYMBOL_GPL(__blk_put_request);
diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index 234ce7c..9628b29 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -40,7 +40,7 @@ static ssize_t queue_requests_show(struct request_queue *q, char *page)
 static ssize_t
 queue_requests_store(struct request_queue *q, const char *page, size_t count)
 {
-	struct request_list *rl = &q->rq;
+	struct request_list *rl;
 	unsigned long nr;
 	int ret;
 
@@ -55,6 +55,9 @@ queue_requests_store(struct request_queue *q, const char *page, size_t count)
 	q->nr_requests = nr;
 	blk_queue_congestion_threshold(q);
 
+	/* congestion isn't cgroup aware and follows root blkcg for now */
+	rl = &q->root_rl;
+
 	if (rl->count[BLK_RW_SYNC] >= queue_congestion_on_threshold(q))
 		blk_set_queue_congested(q, BLK_RW_SYNC);
 	else if (rl->count[BLK_RW_SYNC] < queue_congestion_off_threshold(q))
@@ -65,19 +68,22 @@ queue_requests_store(struct request_queue *q, const char *page, size_t count)
 	else if (rl->count[BLK_RW_ASYNC] < queue_congestion_off_threshold(q))
 		blk_clear_queue_congested(q, BLK_RW_ASYNC);
 
-	if (rl->count[BLK_RW_SYNC] >= q->nr_requests) {
-		blk_set_rl_full(rl, BLK_RW_SYNC);
-	} else {
-		blk_clear_rl_full(rl, BLK_RW_SYNC);
-		wake_up(&rl->wait[BLK_RW_SYNC]);
+	blk_queue_for_each_rl(rl, q) {
+		if (rl->count[BLK_RW_SYNC] >= q->nr_requests) {
+			blk_set_rl_full(rl, BLK_RW_SYNC);
+		} else {
+			blk_clear_rl_full(rl, BLK_RW_SYNC);
+			wake_up(&rl->wait[BLK_RW_SYNC]);
+		}
+
+		if (rl->count[BLK_RW_ASYNC] >= q->nr_requests) {
+			blk_set_rl_full(rl, BLK_RW_ASYNC);
+		} else {
+			blk_clear_rl_full(rl, BLK_RW_ASYNC);
+			wake_up(&rl->wait[BLK_RW_ASYNC]);
+		}
 	}
 
-	if (rl->count[BLK_RW_ASYNC] >= q->nr_requests) {
-		blk_set_rl_full(rl, BLK_RW_ASYNC);
-	} else {
-		blk_clear_rl_full(rl, BLK_RW_ASYNC);
-		wake_up(&rl->wait[BLK_RW_ASYNC]);
-	}
 	spin_unlock_irq(q->queue_lock);
 	return ret;
 }
@@ -488,7 +494,7 @@ static void blk_release_queue(struct kobject *kobj)
 		elevator_exit(q->elevator);
 	}
 
-	blk_exit_rl(&q->rq);
+	blk_exit_rl(&q->root_rl);
 
 	if (q->queue_tags)
 		__blk_queue_free_tags(q);
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index f2385ee..3816ce8 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -51,7 +51,9 @@ typedef void (rq_end_io_fn)(struct request *, int);
 
 struct request_list {
 	struct request_queue	*q;	/* the queue this rl belongs to */
-
+#ifdef CONFIG_BLK_CGROUP
+	struct blkcg_gq		*blkg;	/* blkg this request pool belongs to */
+#endif
 	/*
 	 * count[], starved[], and wait[] are indexed by
 	 * BLK_RW_SYNC/BLK_RW_ASYNC
@@ -143,6 +145,7 @@ struct request {
 	struct hd_struct *part;
 	unsigned long start_time;
 #ifdef CONFIG_BLK_CGROUP
+	struct request_list *rl;		/* rl this rq is alloced from */
 	unsigned long long start_time_ns;
 	unsigned long long io_start_time_ns;    /* when passed to hardware */
 #endif
@@ -291,9 +294,12 @@ struct request_queue {
 	int			nr_rqs_elvpriv;	/* # allocated rqs w/ elvpriv */
 
 	/*
-	 * the queue request freelist, one for reads and one for writes
+	 * If blkcg is not used, @q->root_rl serves all requests.  If blkcg
+	 * is used, root blkg allocates from @q->root_rl and all other
+	 * blkgs from their own blkg->rl.  Which one to use should be
+	 * determined using bio_request_list().
 	 */
-	struct request_list	rq;
+	struct request_list	root_rl;
 
 	request_fn_proc		*request_fn;
 	make_request_fn		*make_request_fn;
-- 
1.7.7.3
