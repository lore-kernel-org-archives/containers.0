From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 17/21] blkcg: move blkio_group_stats_cpu and friends to
	blk-throttle.c
Date: Wed, 28 Mar 2012 15:51:27 -0700
Message-ID: <1332975091-10950-18-git-send-email-tj@kernel.org>
References: <1332975091-10950-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1332975091-10950-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

blkio_group_stats_cpu is used only by blk-throtl and has no reason to
be defined in blkcg core.

* Move blkio_group_stats_cpu to blk-throttle.c and rename it to
  tg_stats_cpu.

* blkg_policy_data->stats_cpu is replaced with throtl_grp->stats_cpu.
  prfill functions updated accordingly.

* All related macros / functions are renamed so that they have tg_
  prefix and the unnecessary @pol arguments are dropped.

* Per-cpu stats allocation code is also moved from blk-cgroup.c to
  blk-throttle.c and gets simplified to only deal with
  BLKIO_POLICY_THROTL.  percpu stat free is performed by the exit
  method throtl_exit_blkio_group().

* throtl_reset_group_stats() implemented for
  blkio_reset_group_stats_fn method so that tg->stats_cpu can be
  reset.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c   |   98 +--------------------------------------
 block/blk-cgroup.h   |   13 -----
 block/blk-throttle.c |  128 ++++++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 114 insertions(+), 125 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index d7c7f17..0b4b765 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -30,13 +30,6 @@ static LIST_HEAD(blkio_list);
 static DEFINE_MUTEX(all_q_mutex);
 static LIST_HEAD(all_q_list);
 
-/* List of groups pending per cpu stats allocation */
-static DEFINE_SPINLOCK(alloc_list_lock);
-static LIST_HEAD(alloc_list);
-
-static void blkio_stat_alloc_fn(struct work_struct *);
-static DECLARE_DELAYED_WORK(blkio_stat_alloc_work, blkio_stat_alloc_fn);
-
 struct blkio_cgroup blkio_root_cgroup = { .weight = 2*BLKIO_WEIGHT_DEFAULT };
 EXPORT_SYMBOL_GPL(blkio_root_cgroup);
 
@@ -63,60 +56,6 @@ struct blkio_cgroup *bio_blkio_cgroup(struct bio *bio)
 }
 EXPORT_SYMBOL_GPL(bio_blkio_cgroup);
 
-/*
- * Worker for allocating per cpu stat for blk groups. This is scheduled on
- * the system_nrt_wq once there are some groups on the alloc_list waiting
- * for allocation.
- */
-static void blkio_stat_alloc_fn(struct work_struct *work)
-{
-	static void *pcpu_stats[BLKIO_NR_POLICIES];
-	struct delayed_work *dwork = to_delayed_work(work);
-	struct blkio_group *blkg;
-	int i;
-	bool empty = false;
-
-alloc_stats:
-	for (i = 0; i < BLKIO_NR_POLICIES; i++) {
-		if (pcpu_stats[i] != NULL)
-			continue;
-
-		pcpu_stats[i] = alloc_percpu(struct blkio_group_stats_cpu);
-
-		/* Allocation failed. Try again after some time. */
-		if (pcpu_stats[i] == NULL) {
-			queue_delayed_work(system_nrt_wq, dwork,
-						msecs_to_jiffies(10));
-			return;
-		}
-	}
-
-	spin_lock_irq(&blkio_list_lock);
-	spin_lock(&alloc_list_lock);
-
-	/* cgroup got deleted or queue exited. */
-	if (!list_empty(&alloc_list)) {
-		blkg = list_first_entry(&alloc_list, struct blkio_group,
-						alloc_node);
-		for (i = 0; i < BLKIO_NR_POLICIES; i++) {
-			struct blkg_policy_data *pd = blkg->pd[i];
-
-			if (blkio_policy[i] && pd && !pd->stats_cpu)
-				swap(pd->stats_cpu, pcpu_stats[i]);
-		}
-
-		list_del_init(&blkg->alloc_node);
-	}
-
-	empty = list_empty(&alloc_list);
-
-	spin_unlock(&alloc_list_lock);
-	spin_unlock_irq(&blkio_list_lock);
-
-	if (!empty)
-		goto alloc_stats;
-}
-
 /**
  * blkg_free - free a blkg
  * @blkg: blkg to free
@@ -140,7 +79,6 @@ static void blkg_free(struct blkio_group *blkg)
 		if (pol && pol->ops.blkio_exit_group_fn)
 			pol->ops.blkio_exit_group_fn(blkg);
 
-		free_percpu(pd->stats_cpu);
 		kfree(pd);
 	}
 
@@ -167,7 +105,6 @@ static struct blkio_group *blkg_alloc(struct blkio_cgroup *blkcg,
 
 	blkg->q = q;
 	INIT_LIST_HEAD(&blkg->q_node);
-	INIT_LIST_HEAD(&blkg->alloc_node);
 	blkg->blkcg = blkcg;
 	blkg->refcnt = 1;
 	cgroup_path(blkcg->css.cgroup, blkg->path, sizeof(blkg->path));
@@ -245,12 +182,6 @@ struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
 	hlist_add_head_rcu(&blkg->blkcg_node, &blkcg->blkg_list);
 	list_add(&blkg->q_node, &q->blkg_list);
 	spin_unlock(&blkcg->lock);
-
-	spin_lock(&alloc_list_lock);
-	list_add(&blkg->alloc_node, &alloc_list);
-	/* Queue per cpu stat allocation from worker thread. */
-	queue_delayed_work(system_nrt_wq, &blkio_stat_alloc_work, 0);
-	spin_unlock(&alloc_list_lock);
 out:
 	return blkg;
 }
@@ -284,10 +215,6 @@ static void blkg_destroy(struct blkio_group *blkg)
 	list_del_init(&blkg->q_node);
 	hlist_del_init_rcu(&blkg->blkcg_node);
 
-	spin_lock(&alloc_list_lock);
-	list_del_init(&blkg->alloc_node);
-	spin_unlock(&alloc_list_lock);
-
 	/*
 	 * Put the reference taken at the time of creation so that when all
 	 * queues are gone, group can be destroyed.
@@ -319,9 +246,6 @@ void update_root_blkg_pd(struct request_queue *q, enum blkio_policy_id plid)
 	pd = kzalloc(sizeof(*pd) + pol->pdata_size, GFP_KERNEL);
 	WARN_ON_ONCE(!pd);
 
-	pd->stats_cpu = alloc_percpu(struct blkio_group_stats_cpu);
-	WARN_ON_ONCE(!pd->stats_cpu);
-
 	blkg->pd[plid] = pd;
 	pd->blkg = blkg;
 	pol->ops.blkio_init_group_fn(blkg);
@@ -381,23 +305,6 @@ void __blkg_release(struct blkio_group *blkg)
 }
 EXPORT_SYMBOL_GPL(__blkg_release);
 
-static void blkio_reset_stats_cpu(struct blkio_group *blkg, int plid)
-{
-	struct blkg_policy_data *pd = blkg->pd[plid];
-	int cpu;
-
-	if (pd->stats_cpu == NULL)
-		return;
-
-	for_each_possible_cpu(cpu) {
-		struct blkio_group_stats_cpu *sc =
-			per_cpu_ptr(pd->stats_cpu, cpu);
-
-		blkg_rwstat_reset(&sc->service_bytes);
-		blkg_rwstat_reset(&sc->serviced);
-	}
-}
-
 static int
 blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 {
@@ -416,12 +323,9 @@ blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node) {
 		struct blkio_policy_type *pol;
 
-		list_for_each_entry(pol, &blkio_list, list) {
-			blkio_reset_stats_cpu(blkg, pol->plid);
-
+		list_for_each_entry(pol, &blkio_list, list)
 			if (pol->ops.blkio_reset_group_stats_fn)
 				pol->ops.blkio_reset_group_stats_fn(blkg);
-		}
 	}
 
 	spin_unlock_irq(&blkcg->lock);
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 791570394..e368dd00 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -64,14 +64,6 @@ struct blkg_rwstat {
 	uint64_t			cnt[BLKG_RWSTAT_NR];
 };
 
-/* Per cpu blkio group stats */
-struct blkio_group_stats_cpu {
-	/* total bytes transferred */
-	struct blkg_rwstat		service_bytes;
-	/* total IOs serviced, post merge */
-	struct blkg_rwstat		serviced;
-};
-
 struct blkio_group_conf {
 	unsigned int weight;
 	u64 iops[2];
@@ -86,9 +78,6 @@ struct blkg_policy_data {
 	/* Configuration */
 	struct blkio_group_conf conf;
 
-	/* Per cpu stats pointer */
-	struct blkio_group_stats_cpu __percpu *stats_cpu;
-
 	/* pol->pdata_size bytes of private data used by policy impl */
 	char pdata[] __aligned(__alignof__(unsigned long long));
 };
@@ -106,8 +95,6 @@ struct blkio_group {
 
 	struct blkg_policy_data *pd[BLKIO_NR_POLICIES];
 
-	/* List of blkg waiting for per cpu stats memory to be allocated */
-	struct list_head alloc_node;
 	struct rcu_head rcu_head;
 };
 
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index cb259bc..27f7960 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -40,6 +40,14 @@ struct throtl_rb_root {
 
 #define rb_entry_tg(node)	rb_entry((node), struct throtl_grp, rb_node)
 
+/* Per-cpu group stats */
+struct tg_stats_cpu {
+	/* total bytes transferred */
+	struct blkg_rwstat		service_bytes;
+	/* total IOs serviced, post merge */
+	struct blkg_rwstat		serviced;
+};
+
 struct throtl_grp {
 	/* active throtl group service_tree member */
 	struct rb_node rb_node;
@@ -76,6 +84,12 @@ struct throtl_grp {
 
 	/* Some throttle limits got updated for the group */
 	int limits_changed;
+
+	/* Per cpu stats pointer */
+	struct tg_stats_cpu __percpu *stats_cpu;
+
+	/* List of tgs waiting for per cpu stats memory to be allocated */
+	struct list_head stats_alloc_node;
 };
 
 struct throtl_data
@@ -100,6 +114,13 @@ struct throtl_data
 	int limits_changed;
 };
 
+/* list and work item to allocate percpu group stats */
+static DEFINE_SPINLOCK(tg_stats_alloc_lock);
+static LIST_HEAD(tg_stats_alloc_list);
+
+static void tg_stats_alloc_fn(struct work_struct *);
+static DECLARE_DELAYED_WORK(tg_stats_alloc_work, tg_stats_alloc_fn);
+
 static inline struct throtl_grp *blkg_to_tg(struct blkio_group *blkg)
 {
 	return blkg_to_pdata(blkg, &blkio_policy_throtl);
@@ -142,6 +163,44 @@ static inline unsigned int total_nr_queued(struct throtl_data *td)
 	return td->nr_queued[0] + td->nr_queued[1];
 }
 
+/*
+ * Worker for allocating per cpu stat for tgs. This is scheduled on the
+ * system_nrt_wq once there are some groups on the alloc_list waiting for
+ * allocation.
+ */
+static void tg_stats_alloc_fn(struct work_struct *work)
+{
+	static struct tg_stats_cpu *stats_cpu;	/* this fn is non-reentrant */
+	struct delayed_work *dwork = to_delayed_work(work);
+	bool empty = false;
+
+alloc_stats:
+	if (!stats_cpu) {
+		stats_cpu = alloc_percpu(struct tg_stats_cpu);
+		if (!stats_cpu) {
+			/* allocation failed, try again after some time */
+			queue_delayed_work(system_nrt_wq, dwork,
+					   msecs_to_jiffies(10));
+			return;
+		}
+	}
+
+	spin_lock_irq(&tg_stats_alloc_lock);
+
+	if (!list_empty(&tg_stats_alloc_list)) {
+		struct throtl_grp *tg = list_first_entry(&tg_stats_alloc_list,
+							 struct throtl_grp,
+							 stats_alloc_node);
+		swap(tg->stats_cpu, stats_cpu);
+		list_del_init(&tg->stats_alloc_node);
+	}
+
+	empty = list_empty(&tg_stats_alloc_list);
+	spin_unlock_irq(&tg_stats_alloc_lock);
+	if (!empty)
+		goto alloc_stats;
+}
+
 static void throtl_init_blkio_group(struct blkio_group *blkg)
 {
 	struct throtl_grp *tg = blkg_to_tg(blkg);
@@ -155,6 +214,43 @@ static void throtl_init_blkio_group(struct blkio_group *blkg)
 	tg->bps[WRITE] = -1;
 	tg->iops[READ] = -1;
 	tg->iops[WRITE] = -1;
+
+	/*
+	 * Ugh... We need to perform per-cpu allocation for tg->stats_cpu
+	 * but percpu allocator can't be called from IO path.  Queue tg on
+	 * tg_stats_alloc_list and allocate from work item.
+	 */
+	spin_lock(&tg_stats_alloc_lock);
+	list_add(&tg->stats_alloc_node, &tg_stats_alloc_list);
+	queue_delayed_work(system_nrt_wq, &tg_stats_alloc_work, 0);
+	spin_unlock(&tg_stats_alloc_lock);
+}
+
+static void throtl_exit_blkio_group(struct blkio_group *blkg)
+{
+	struct throtl_grp *tg = blkg_to_tg(blkg);
+
+	spin_lock(&tg_stats_alloc_lock);
+	list_del_init(&tg->stats_alloc_node);
+	spin_unlock(&tg_stats_alloc_lock);
+
+	free_percpu(tg->stats_cpu);
+}
+
+static void throtl_reset_group_stats(struct blkio_group *blkg)
+{
+	struct throtl_grp *tg = blkg_to_tg(blkg);
+	int cpu;
+
+	if (tg->stats_cpu == NULL)
+		return;
+
+	for_each_possible_cpu(cpu) {
+		struct tg_stats_cpu *sc = per_cpu_ptr(tg->stats_cpu, cpu);
+
+		blkg_rwstat_reset(&sc->service_bytes);
+		blkg_rwstat_reset(&sc->serviced);
+	}
 }
 
 static struct
@@ -565,12 +661,12 @@ static bool tg_may_dispatch(struct throtl_data *td, struct throtl_grp *tg,
 static void throtl_update_dispatch_stats(struct blkio_group *blkg, u64 bytes,
 					 int rw)
 {
-	struct blkg_policy_data *pd = blkg->pd[BLKIO_POLICY_THROTL];
-	struct blkio_group_stats_cpu *stats_cpu;
+	struct throtl_grp *tg = blkg_to_tg(blkg);
+	struct tg_stats_cpu *stats_cpu;
 	unsigned long flags;
 
 	/* If per cpu stats are not allocated yet, don't do any accounting. */
-	if (pd->stats_cpu == NULL)
+	if (tg->stats_cpu == NULL)
 		return;
 
 	/*
@@ -580,7 +676,7 @@ static void throtl_update_dispatch_stats(struct blkio_group *blkg, u64 bytes,
 	 */
 	local_irq_save(flags);
 
-	stats_cpu = this_cpu_ptr(pd->stats_cpu);
+	stats_cpu = this_cpu_ptr(tg->stats_cpu);
 
 	blkg_rwstat_add(&stats_cpu->serviced, rw, 1);
 	blkg_rwstat_add(&stats_cpu->service_bytes, rw, bytes);
@@ -842,15 +938,15 @@ static void throtl_update_blkio_group_common(struct throtl_data *td,
 	throtl_schedule_delayed_work(td, 0);
 }
 
-static u64 blkg_prfill_cpu_rwstat(struct seq_file *sf,
-				  struct blkg_policy_data *pd, int off)
+static u64 tg_prfill_cpu_rwstat(struct seq_file *sf,
+				struct blkg_policy_data *pd, int off)
 {
+	struct throtl_grp *tg = (void *)pd->pdata;
 	struct blkg_rwstat rwstat = { }, tmp;
 	int i, cpu;
 
 	for_each_possible_cpu(cpu) {
-		struct blkio_group_stats_cpu *sc =
-			per_cpu_ptr(pd->stats_cpu, cpu);
+		struct tg_stats_cpu *sc = per_cpu_ptr(tg->stats_cpu, cpu);
 
 		tmp = blkg_rwstat_read((void *)sc + off);
 		for (i = 0; i < BLKG_RWSTAT_NR; i++)
@@ -861,12 +957,12 @@ static u64 blkg_prfill_cpu_rwstat(struct seq_file *sf,
 }
 
 /* print per-cpu blkg_rwstat specified by BLKCG_STAT_PRIV() */
-static int blkcg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
-				  struct seq_file *sf)
+static int tg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
+			       struct seq_file *sf)
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 
-	blkcg_print_blkgs(sf, blkcg, blkg_prfill_cpu_rwstat,
+	blkcg_print_blkgs(sf, blkcg, tg_prfill_cpu_rwstat,
 			  BLKCG_STAT_POL(cft->private),
 			  BLKCG_STAT_OFF(cft->private), true);
 	return 0;
@@ -1012,14 +1108,14 @@ static struct cftype throtl_files[] = {
 	{
 		.name = "throttle.io_service_bytes",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_THROTL,
-				offsetof(struct blkio_group_stats_cpu, service_bytes)),
-		.read_seq_string = blkcg_print_cpu_rwstat,
+				offsetof(struct tg_stats_cpu, service_bytes)),
+		.read_seq_string = tg_print_cpu_rwstat,
 	},
 	{
 		.name = "throttle.io_serviced",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_THROTL,
-				offsetof(struct blkio_group_stats_cpu, serviced)),
-		.read_seq_string = blkcg_print_cpu_rwstat,
+				offsetof(struct tg_stats_cpu, serviced)),
+		.read_seq_string = tg_print_cpu_rwstat,
 	},
 	{ }	/* terminate */
 };
@@ -1034,6 +1130,8 @@ static void throtl_shutdown_wq(struct request_queue *q)
 static struct blkio_policy_type blkio_policy_throtl = {
 	.ops = {
 		.blkio_init_group_fn = throtl_init_blkio_group,
+		.blkio_exit_group_fn = throtl_exit_blkio_group,
+		.blkio_reset_group_stats_fn = throtl_reset_group_stats,
 	},
 	.plid = BLKIO_POLICY_THROTL,
 	.pdata_size = sizeof(struct throtl_grp),
-- 
1.7.7.3
