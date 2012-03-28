From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 11/21] blkcg: move conf/stat file handling code to policies
Date: Wed, 28 Mar 2012 15:51:21 -0700
Message-ID: <1332975091-10950-12-git-send-email-tj@kernel.org>
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

blkcg conf/stat handling is convoluted in that details which belong to
specific policy implementations are all out in blkcg core and then
policies hook into core layer to access and manipulate confs and
stats.  This sadly achieves both inflexibility (confs/stats can't be
modified without messing with blkcg core) and complexity (all the
call-ins and call-backs).

The previous patches restructured conf and stat handling code such
that they can be separated out.  This patch relocates the file
handling part.  All conf/stat file handling code which belongs to
BLKIO_POLICY_PROP is moved to cfq-iosched.c and all
BKLIO_POLICY_THROTL code to blk-throtl.c.

The move is verbatim except for blkio_update_group_{weight|bps|iops}()
callbacks which relays conf changes to policies.  The configuration
settings are handled in policies themselves so the relaying isn't
necessary.  Conf setting functions are modified to directly call
per-policy update functions and the relaying mechanism is dropped.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c   |  373 --------------------------------------------------
 block/blk-cgroup.h   |   15 --
 block/blk-throttle.c |  163 ++++++++++++++++++----
 block/cfq-iosched.c  |  202 +++++++++++++++++++++++++++-
 4 files changed, 333 insertions(+), 420 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 2f05056..96b6b5a 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -63,63 +63,6 @@ struct blkio_cgroup *bio_blkio_cgroup(struct bio *bio)
 }
 EXPORT_SYMBOL_GPL(bio_blkio_cgroup);
 
-static inline void blkio_update_group_weight(struct blkio_group *blkg,
-					     int plid, unsigned int weight)
-{
-	struct blkio_policy_type *blkiop;
-
-	list_for_each_entry(blkiop, &blkio_list, list) {
-		/* If this policy does not own the blkg, do not send updates */
-		if (blkiop->plid != plid)
-			continue;
-		if (blkiop->ops.blkio_update_group_weight_fn)
-			blkiop->ops.blkio_update_group_weight_fn(blkg->q,
-							blkg, weight);
-	}
-}
-
-static inline void blkio_update_group_bps(struct blkio_group *blkg, int plid,
-					  u64 bps, int rw)
-{
-	struct blkio_policy_type *blkiop;
-
-	list_for_each_entry(blkiop, &blkio_list, list) {
-
-		/* If this policy does not own the blkg, do not send updates */
-		if (blkiop->plid != plid)
-			continue;
-
-		if (rw == READ && blkiop->ops.blkio_update_group_read_bps_fn)
-			blkiop->ops.blkio_update_group_read_bps_fn(blkg->q,
-								blkg, bps);
-
-		if (rw == WRITE && blkiop->ops.blkio_update_group_write_bps_fn)
-			blkiop->ops.blkio_update_group_write_bps_fn(blkg->q,
-								blkg, bps);
-	}
-}
-
-static inline void blkio_update_group_iops(struct blkio_group *blkg, int plid,
-					   u64 iops, int rw)
-{
-	struct blkio_policy_type *blkiop;
-
-	list_for_each_entry(blkiop, &blkio_list, list) {
-
-		/* If this policy does not own the blkg, do not send updates */
-		if (blkiop->plid != plid)
-			continue;
-
-		if (rw == READ && blkiop->ops.blkio_update_group_read_iops_fn)
-			blkiop->ops.blkio_update_group_read_iops_fn(blkg->q,
-								blkg, iops);
-
-		if (rw == WRITE && blkiop->ops.blkio_update_group_write_iops_fn)
-			blkiop->ops.blkio_update_group_write_iops_fn(blkg->q,
-								blkg,iops);
-	}
-}
-
 #ifdef CONFIG_DEBUG_BLK_CGROUP
 /* This should be called with the queue_lock held. */
 static void blkio_set_start_group_wait_time(struct blkio_group *blkg,
@@ -939,33 +882,6 @@ int blkcg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
 }
 EXPORT_SYMBOL_GPL(blkcg_print_cpu_rwstat);
 
-#ifdef CONFIG_DEBUG_BLK_CGROUP
-static u64 blkg_prfill_avg_queue_size(struct seq_file *sf,
-				      struct blkg_policy_data *pd, int off)
-{
-	u64 samples = blkg_stat_read(&pd->stats.avg_queue_size_samples);
-	u64 v = 0;
-
-	if (samples) {
-		v = blkg_stat_read(&pd->stats.avg_queue_size_sum);
-		do_div(v, samples);
-	}
-	__blkg_prfill_u64(sf, pd, v);
-	return 0;
-}
-
-/* print avg_queue_size */
-static int blkcg_print_avg_queue_size(struct cgroup *cgrp, struct cftype *cft,
-				      struct seq_file *sf)
-{
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
-
-	blkcg_print_blkgs(sf, blkcg, blkg_prfill_avg_queue_size,
-			  BLKIO_POLICY_PROP, 0, false);
-	return 0;
-}
-#endif	/* CONFIG_DEBUG_BLK_CGROUP */
-
 /**
  * blkg_conf_prep - parse and prepare for per-blkg config update
  * @blkcg: target block cgroup
@@ -1039,300 +955,11 @@ void blkg_conf_finish(struct blkg_conf_ctx *ctx)
 }
 EXPORT_SYMBOL_GPL(blkg_conf_finish);
 
-/* for propio conf */
-static u64 blkg_prfill_weight_device(struct seq_file *sf,
-				     struct blkg_policy_data *pd, int off)
-{
-	if (!pd->conf.weight)
-		return 0;
-	return __blkg_prfill_u64(sf, pd, pd->conf.weight);
-}
-
-static int blkcg_print_weight_device(struct cgroup *cgrp, struct cftype *cft,
-				     struct seq_file *sf)
-{
-	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp),
-			  blkg_prfill_weight_device, BLKIO_POLICY_PROP, 0,
-			  false);
-	return 0;
-}
-
-static int blkcg_print_weight(struct cgroup *cgrp, struct cftype *cft,
-			      struct seq_file *sf)
-{
-	seq_printf(sf, "%u\n", cgroup_to_blkio_cgroup(cgrp)->weight);
-	return 0;
-}
-
-static int blkcg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
-				   const char *buf)
-{
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
-	struct blkg_policy_data *pd;
-	struct blkg_conf_ctx ctx;
-	int ret;
-
-	ret = blkg_conf_prep(blkcg, buf, &ctx);
-	if (ret)
-		return ret;
-
-	ret = -EINVAL;
-	pd = ctx.blkg->pd[BLKIO_POLICY_PROP];
-	if (pd && (!ctx.v || (ctx.v >= BLKIO_WEIGHT_MIN &&
-			      ctx.v <= BLKIO_WEIGHT_MAX))) {
-		pd->conf.weight = ctx.v;
-		blkio_update_group_weight(ctx.blkg, BLKIO_POLICY_PROP,
-					  ctx.v ?: blkcg->weight);
-		ret = 0;
-	}
-
-	blkg_conf_finish(&ctx);
-	return ret;
-}
-
-static int blkcg_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
-{
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
-	struct blkio_group *blkg;
-	struct hlist_node *n;
-
-	if (val < BLKIO_WEIGHT_MIN || val > BLKIO_WEIGHT_MAX)
-		return -EINVAL;
-
-	spin_lock(&blkio_list_lock);
-	spin_lock_irq(&blkcg->lock);
-	blkcg->weight = (unsigned int)val;
-
-	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node) {
-		struct blkg_policy_data *pd = blkg->pd[BLKIO_POLICY_PROP];
-
-		if (pd && !pd->conf.weight)
-			blkio_update_group_weight(blkg, BLKIO_POLICY_PROP,
-						  blkcg->weight);
-	}
-
-	spin_unlock_irq(&blkcg->lock);
-	spin_unlock(&blkio_list_lock);
-	return 0;
-}
-
-/* for blk-throttle conf */
-#ifdef CONFIG_BLK_DEV_THROTTLING
-static u64 blkg_prfill_conf_u64(struct seq_file *sf,
-				struct blkg_policy_data *pd, int off)
-{
-	u64 v = *(u64 *)((void *)&pd->conf + off);
-
-	if (!v)
-		return 0;
-	return __blkg_prfill_u64(sf, pd, v);
-}
-
-static int blkcg_print_conf_u64(struct cgroup *cgrp, struct cftype *cft,
-				struct seq_file *sf)
-{
-	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp),
-			  blkg_prfill_conf_u64, BLKIO_POLICY_THROTL,
-			  cft->private, false);
-	return 0;
-}
-
-static int blkcg_set_conf_u64(struct cgroup *cgrp, struct cftype *cft,
-			      const char *buf, int rw,
-			      void (*update)(struct blkio_group *, int, u64, int))
-{
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
-	struct blkg_policy_data *pd;
-	struct blkg_conf_ctx ctx;
-	int ret;
-
-	ret = blkg_conf_prep(blkcg, buf, &ctx);
-	if (ret)
-		return ret;
-
-	ret = -EINVAL;
-	pd = ctx.blkg->pd[BLKIO_POLICY_THROTL];
-	if (pd) {
-		*(u64 *)((void *)&pd->conf + cft->private) = ctx.v;
-		update(ctx.blkg, BLKIO_POLICY_THROTL, ctx.v ?: -1, rw);
-		ret = 0;
-	}
-
-	blkg_conf_finish(&ctx);
-	return ret;
-}
-
-static int blkcg_set_conf_bps_r(struct cgroup *cgrp, struct cftype *cft,
-				const char *buf)
-{
-	return blkcg_set_conf_u64(cgrp, cft, buf, READ, blkio_update_group_bps);
-}
-
-static int blkcg_set_conf_bps_w(struct cgroup *cgrp, struct cftype *cft,
-				const char *buf)
-{
-	return blkcg_set_conf_u64(cgrp, cft, buf, WRITE, blkio_update_group_bps);
-}
-
-static int blkcg_set_conf_iops_r(struct cgroup *cgrp, struct cftype *cft,
-				 const char *buf)
-{
-	return blkcg_set_conf_u64(cgrp, cft, buf, READ, blkio_update_group_iops);
-}
-
-static int blkcg_set_conf_iops_w(struct cgroup *cgrp, struct cftype *cft,
-				 const char *buf)
-{
-	return blkcg_set_conf_u64(cgrp, cft, buf, WRITE, blkio_update_group_iops);
-}
-#endif
-
 struct cftype blkio_files[] = {
 	{
-		.name = "weight_device",
-		.read_seq_string = blkcg_print_weight_device,
-		.write_string = blkcg_set_weight_device,
-		.max_write_len = 256,
-	},
-	{
-		.name = "weight",
-		.read_seq_string = blkcg_print_weight,
-		.write_u64 = blkcg_set_weight,
-	},
-	{
-		.name = "time",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, time)),
-		.read_seq_string = blkcg_print_stat,
-	},
-	{
-		.name = "sectors",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats_cpu, sectors)),
-		.read_seq_string = blkcg_print_cpu_stat,
-	},
-	{
-		.name = "io_service_bytes",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats_cpu, service_bytes)),
-		.read_seq_string = blkcg_print_cpu_rwstat,
-	},
-	{
-		.name = "io_serviced",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats_cpu, serviced)),
-		.read_seq_string = blkcg_print_cpu_rwstat,
-	},
-	{
-		.name = "io_service_time",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, service_time)),
-		.read_seq_string = blkcg_print_rwstat,
-	},
-	{
-		.name = "io_wait_time",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, wait_time)),
-		.read_seq_string = blkcg_print_rwstat,
-	},
-	{
-		.name = "io_merged",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, merged)),
-		.read_seq_string = blkcg_print_rwstat,
-	},
-	{
-		.name = "io_queued",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, queued)),
-		.read_seq_string = blkcg_print_rwstat,
-	},
-	{
 		.name = "reset_stats",
 		.write_u64 = blkiocg_reset_stats,
 	},
-#ifdef CONFIG_BLK_DEV_THROTTLING
-	{
-		.name = "throttle.read_bps_device",
-		.private = offsetof(struct blkio_group_conf, bps[READ]),
-		.read_seq_string = blkcg_print_conf_u64,
-		.write_string = blkcg_set_conf_bps_r,
-		.max_write_len = 256,
-	},
-
-	{
-		.name = "throttle.write_bps_device",
-		.private = offsetof(struct blkio_group_conf, bps[WRITE]),
-		.read_seq_string = blkcg_print_conf_u64,
-		.write_string = blkcg_set_conf_bps_w,
-		.max_write_len = 256,
-	},
-
-	{
-		.name = "throttle.read_iops_device",
-		.private = offsetof(struct blkio_group_conf, iops[READ]),
-		.read_seq_string = blkcg_print_conf_u64,
-		.write_string = blkcg_set_conf_iops_r,
-		.max_write_len = 256,
-	},
-
-	{
-		.name = "throttle.write_iops_device",
-		.private = offsetof(struct blkio_group_conf, iops[WRITE]),
-		.read_seq_string = blkcg_print_conf_u64,
-		.write_string = blkcg_set_conf_iops_w,
-		.max_write_len = 256,
-	},
-	{
-		.name = "throttle.io_service_bytes",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_THROTL,
-				offsetof(struct blkio_group_stats_cpu, service_bytes)),
-		.read_seq_string = blkcg_print_cpu_rwstat,
-	},
-	{
-		.name = "throttle.io_serviced",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_THROTL,
-				offsetof(struct blkio_group_stats_cpu, serviced)),
-		.read_seq_string = blkcg_print_cpu_rwstat,
-	},
-#endif /* CONFIG_BLK_DEV_THROTTLING */
-
-#ifdef CONFIG_DEBUG_BLK_CGROUP
-	{
-		.name = "avg_queue_size",
-		.read_seq_string = blkcg_print_avg_queue_size,
-	},
-	{
-		.name = "group_wait_time",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, group_wait_time)),
-		.read_seq_string = blkcg_print_stat,
-	},
-	{
-		.name = "idle_time",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, idle_time)),
-		.read_seq_string = blkcg_print_stat,
-	},
-	{
-		.name = "empty_time",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, empty_time)),
-		.read_seq_string = blkcg_print_stat,
-	},
-	{
-		.name = "dequeue",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, dequeue)),
-		.read_seq_string = blkcg_print_stat,
-	},
-	{
-		.name = "unaccounted_time",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, unaccounted_time)),
-		.read_seq_string = blkcg_print_stat,
-	},
-#endif
 	{ }	/* terminate */
 };
 
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index fa744d5..ba64b28 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -156,24 +156,9 @@ struct blkio_group {
 };
 
 typedef void (blkio_init_group_fn)(struct blkio_group *blkg);
-typedef void (blkio_update_group_weight_fn)(struct request_queue *q,
-			struct blkio_group *blkg, unsigned int weight);
-typedef void (blkio_update_group_read_bps_fn)(struct request_queue *q,
-			struct blkio_group *blkg, u64 read_bps);
-typedef void (blkio_update_group_write_bps_fn)(struct request_queue *q,
-			struct blkio_group *blkg, u64 write_bps);
-typedef void (blkio_update_group_read_iops_fn)(struct request_queue *q,
-			struct blkio_group *blkg, unsigned int read_iops);
-typedef void (blkio_update_group_write_iops_fn)(struct request_queue *q,
-			struct blkio_group *blkg, unsigned int write_iops);
 
 struct blkio_policy_ops {
 	blkio_init_group_fn *blkio_init_group_fn;
-	blkio_update_group_weight_fn *blkio_update_group_weight_fn;
-	blkio_update_group_read_bps_fn *blkio_update_group_read_bps_fn;
-	blkio_update_group_write_bps_fn *blkio_update_group_write_bps_fn;
-	blkio_update_group_read_iops_fn *blkio_update_group_read_iops_fn;
-	blkio_update_group_write_iops_fn *blkio_update_group_write_iops_fn;
 };
 
 struct blkio_policy_type {
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 1cc6c23d..fb6f257 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -804,6 +804,11 @@ throtl_schedule_delayed_work(struct throtl_data *td, unsigned long delay)
 	}
 }
 
+/*
+ * Can not take queue lock in update functions as queue lock under
+ * blkcg_lock is not allowed. Under other paths we take blkcg_lock under
+ * queue_lock.
+ */
 static void throtl_update_blkio_group_common(struct throtl_data *td,
 				struct throtl_grp *tg)
 {
@@ -813,51 +818,158 @@ static void throtl_update_blkio_group_common(struct throtl_data *td,
 	throtl_schedule_delayed_work(td, 0);
 }
 
-/*
- * For all update functions, @q should be a valid pointer because these
- * update functions are called under blkcg_lock, that means, blkg is
- * valid and in turn @q is valid. queue exit path can not race because
- * of blkcg_lock
- *
- * Can not take queue lock in update functions as queue lock under blkcg_lock
- * is not allowed. Under other paths we take blkcg_lock under queue_lock.
- */
-static void throtl_update_blkio_group_read_bps(struct request_queue *q,
-				struct blkio_group *blkg, u64 read_bps)
+static u64 blkg_prfill_conf_u64(struct seq_file *sf,
+				struct blkg_policy_data *pd, int off)
+{
+	u64 v = *(u64 *)((void *)&pd->conf + off);
+
+	if (!v)
+		return 0;
+	return __blkg_prfill_u64(sf, pd, v);
+}
+
+static int blkcg_print_conf_u64(struct cgroup *cgrp, struct cftype *cft,
+				struct seq_file *sf)
+{
+	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp),
+			  blkg_prfill_conf_u64, BLKIO_POLICY_THROTL,
+			  cft->private, false);
+	return 0;
+}
+
+static void throtl_update_blkio_group_read_bps(struct blkio_group *blkg,
+					       u64 read_bps)
 {
 	struct throtl_grp *tg = blkg_to_tg(blkg);
 
 	tg->bps[READ] = read_bps;
-	throtl_update_blkio_group_common(q->td, tg);
+	throtl_update_blkio_group_common(blkg->q->td, tg);
 }
 
-static void throtl_update_blkio_group_write_bps(struct request_queue *q,
-				struct blkio_group *blkg, u64 write_bps)
+static void throtl_update_blkio_group_write_bps(struct blkio_group *blkg,
+						u64 write_bps)
 {
 	struct throtl_grp *tg = blkg_to_tg(blkg);
 
 	tg->bps[WRITE] = write_bps;
-	throtl_update_blkio_group_common(q->td, tg);
+	throtl_update_blkio_group_common(blkg->q->td, tg);
 }
 
-static void throtl_update_blkio_group_read_iops(struct request_queue *q,
-			struct blkio_group *blkg, unsigned int read_iops)
+static void throtl_update_blkio_group_read_iops(struct blkio_group *blkg,
+						u64 read_iops)
 {
 	struct throtl_grp *tg = blkg_to_tg(blkg);
 
 	tg->iops[READ] = read_iops;
-	throtl_update_blkio_group_common(q->td, tg);
+	throtl_update_blkio_group_common(blkg->q->td, tg);
 }
 
-static void throtl_update_blkio_group_write_iops(struct request_queue *q,
-			struct blkio_group *blkg, unsigned int write_iops)
+static void throtl_update_blkio_group_write_iops(struct blkio_group *blkg,
+						 u64 write_iops)
 {
 	struct throtl_grp *tg = blkg_to_tg(blkg);
 
 	tg->iops[WRITE] = write_iops;
-	throtl_update_blkio_group_common(q->td, tg);
+	throtl_update_blkio_group_common(blkg->q->td, tg);
+}
+
+static int blkcg_set_conf_u64(struct cgroup *cgrp, struct cftype *cft,
+			      const char *buf,
+			      void (*update)(struct blkio_group *, u64))
+{
+	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+	struct blkg_policy_data *pd;
+	struct blkg_conf_ctx ctx;
+	int ret;
+
+	ret = blkg_conf_prep(blkcg, buf, &ctx);
+	if (ret)
+		return ret;
+
+	ret = -EINVAL;
+	pd = ctx.blkg->pd[BLKIO_POLICY_THROTL];
+	if (pd) {
+		*(u64 *)((void *)&pd->conf + cft->private) = ctx.v;
+		update(ctx.blkg, ctx.v ?: -1);
+		ret = 0;
+	}
+
+	blkg_conf_finish(&ctx);
+	return ret;
 }
 
+static int blkcg_set_conf_bps_r(struct cgroup *cgrp, struct cftype *cft,
+				const char *buf)
+{
+	return blkcg_set_conf_u64(cgrp, cft, buf,
+				  throtl_update_blkio_group_read_bps);
+}
+
+static int blkcg_set_conf_bps_w(struct cgroup *cgrp, struct cftype *cft,
+				const char *buf)
+{
+	return blkcg_set_conf_u64(cgrp, cft, buf,
+				  throtl_update_blkio_group_write_bps);
+}
+
+static int blkcg_set_conf_iops_r(struct cgroup *cgrp, struct cftype *cft,
+				 const char *buf)
+{
+	return blkcg_set_conf_u64(cgrp, cft, buf,
+				  throtl_update_blkio_group_read_iops);
+}
+
+static int blkcg_set_conf_iops_w(struct cgroup *cgrp, struct cftype *cft,
+				 const char *buf)
+{
+	return blkcg_set_conf_u64(cgrp, cft, buf,
+				  throtl_update_blkio_group_write_iops);
+}
+
+static struct cftype throtl_files[] = {
+	{
+		.name = "throttle.read_bps_device",
+		.private = offsetof(struct blkio_group_conf, bps[READ]),
+		.read_seq_string = blkcg_print_conf_u64,
+		.write_string = blkcg_set_conf_bps_r,
+		.max_write_len = 256,
+	},
+	{
+		.name = "throttle.write_bps_device",
+		.private = offsetof(struct blkio_group_conf, bps[WRITE]),
+		.read_seq_string = blkcg_print_conf_u64,
+		.write_string = blkcg_set_conf_bps_w,
+		.max_write_len = 256,
+	},
+	{
+		.name = "throttle.read_iops_device",
+		.private = offsetof(struct blkio_group_conf, iops[READ]),
+		.read_seq_string = blkcg_print_conf_u64,
+		.write_string = blkcg_set_conf_iops_r,
+		.max_write_len = 256,
+	},
+	{
+		.name = "throttle.write_iops_device",
+		.private = offsetof(struct blkio_group_conf, iops[WRITE]),
+		.read_seq_string = blkcg_print_conf_u64,
+		.write_string = blkcg_set_conf_iops_w,
+		.max_write_len = 256,
+	},
+	{
+		.name = "throttle.io_service_bytes",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_THROTL,
+				offsetof(struct blkio_group_stats_cpu, service_bytes)),
+		.read_seq_string = blkcg_print_cpu_rwstat,
+	},
+	{
+		.name = "throttle.io_serviced",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_THROTL,
+				offsetof(struct blkio_group_stats_cpu, serviced)),
+		.read_seq_string = blkcg_print_cpu_rwstat,
+	},
+	{ }	/* terminate */
+};
+
 static void throtl_shutdown_wq(struct request_queue *q)
 {
 	struct throtl_data *td = q->td;
@@ -868,17 +980,10 @@ static void throtl_shutdown_wq(struct request_queue *q)
 static struct blkio_policy_type blkio_policy_throtl = {
 	.ops = {
 		.blkio_init_group_fn = throtl_init_blkio_group,
-		.blkio_update_group_read_bps_fn =
-					throtl_update_blkio_group_read_bps,
-		.blkio_update_group_write_bps_fn =
-					throtl_update_blkio_group_write_bps,
-		.blkio_update_group_read_iops_fn =
-					throtl_update_blkio_group_read_iops,
-		.blkio_update_group_write_iops_fn =
-					throtl_update_blkio_group_write_iops,
 	},
 	.plid = BLKIO_POLICY_THROTL,
 	.pdata_size = sizeof(struct throtl_grp),
+	.cftypes = throtl_files,
 };
 
 bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 8cca6161..119e061 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1058,8 +1058,7 @@ static void cfq_init_cfqg_base(struct cfq_group *cfqg)
 }
 
 #ifdef CONFIG_CFQ_GROUP_IOSCHED
-static void cfq_update_blkio_group_weight(struct request_queue *q,
-					  struct blkio_group *blkg,
+static void cfq_update_blkio_group_weight(struct blkio_group *blkg,
 					  unsigned int weight)
 {
 	struct cfq_group *cfqg = blkg_to_cfqg(blkg);
@@ -1111,6 +1110,203 @@ static void cfq_link_cfqq_cfqg(struct cfq_queue *cfqq, struct cfq_group *cfqg)
 	cfqg_get(cfqg);
 }
 
+static u64 blkg_prfill_weight_device(struct seq_file *sf,
+				     struct blkg_policy_data *pd, int off)
+{
+	if (!pd->conf.weight)
+		return 0;
+	return __blkg_prfill_u64(sf, pd, pd->conf.weight);
+}
+
+static int blkcg_print_weight_device(struct cgroup *cgrp, struct cftype *cft,
+				     struct seq_file *sf)
+{
+	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp),
+			  blkg_prfill_weight_device, BLKIO_POLICY_PROP, 0,
+			  false);
+	return 0;
+}
+
+static int blkcg_print_weight(struct cgroup *cgrp, struct cftype *cft,
+			      struct seq_file *sf)
+{
+	seq_printf(sf, "%u\n", cgroup_to_blkio_cgroup(cgrp)->weight);
+	return 0;
+}
+
+static int blkcg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
+				   const char *buf)
+{
+	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+	struct blkg_policy_data *pd;
+	struct blkg_conf_ctx ctx;
+	int ret;
+
+	ret = blkg_conf_prep(blkcg, buf, &ctx);
+	if (ret)
+		return ret;
+
+	ret = -EINVAL;
+	pd = ctx.blkg->pd[BLKIO_POLICY_PROP];
+	if (pd && (!ctx.v || (ctx.v >= BLKIO_WEIGHT_MIN &&
+			      ctx.v <= BLKIO_WEIGHT_MAX))) {
+		pd->conf.weight = ctx.v;
+		cfq_update_blkio_group_weight(ctx.blkg, ctx.v ?: blkcg->weight);
+		ret = 0;
+	}
+
+	blkg_conf_finish(&ctx);
+	return ret;
+}
+
+static int blkcg_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
+{
+	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+	struct blkio_group *blkg;
+	struct hlist_node *n;
+
+	if (val < BLKIO_WEIGHT_MIN || val > BLKIO_WEIGHT_MAX)
+		return -EINVAL;
+
+	spin_lock_irq(&blkcg->lock);
+	blkcg->weight = (unsigned int)val;
+
+	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node) {
+		struct blkg_policy_data *pd = blkg->pd[BLKIO_POLICY_PROP];
+
+		if (pd && !pd->conf.weight)
+			cfq_update_blkio_group_weight(blkg, blkcg->weight);
+	}
+
+	spin_unlock_irq(&blkcg->lock);
+	return 0;
+}
+
+#ifdef CONFIG_DEBUG_BLK_CGROUP
+static u64 blkg_prfill_avg_queue_size(struct seq_file *sf,
+				      struct blkg_policy_data *pd, int off)
+{
+	u64 samples = blkg_stat_read(&pd->stats.avg_queue_size_samples);
+	u64 v = 0;
+
+	if (samples) {
+		v = blkg_stat_read(&pd->stats.avg_queue_size_sum);
+		do_div(v, samples);
+	}
+	__blkg_prfill_u64(sf, pd, v);
+	return 0;
+}
+
+/* print avg_queue_size */
+static int blkcg_print_avg_queue_size(struct cgroup *cgrp, struct cftype *cft,
+				      struct seq_file *sf)
+{
+	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+
+	blkcg_print_blkgs(sf, blkcg, blkg_prfill_avg_queue_size,
+			  BLKIO_POLICY_PROP, 0, false);
+	return 0;
+}
+#endif	/* CONFIG_DEBUG_BLK_CGROUP */
+
+static struct cftype cfq_blkcg_files[] = {
+	{
+		.name = "weight_device",
+		.read_seq_string = blkcg_print_weight_device,
+		.write_string = blkcg_set_weight_device,
+		.max_write_len = 256,
+	},
+	{
+		.name = "weight",
+		.read_seq_string = blkcg_print_weight,
+		.write_u64 = blkcg_set_weight,
+	},
+	{
+		.name = "time",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, time)),
+		.read_seq_string = blkcg_print_stat,
+	},
+	{
+		.name = "sectors",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats_cpu, sectors)),
+		.read_seq_string = blkcg_print_cpu_stat,
+	},
+	{
+		.name = "io_service_bytes",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats_cpu, service_bytes)),
+		.read_seq_string = blkcg_print_cpu_rwstat,
+	},
+	{
+		.name = "io_serviced",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats_cpu, serviced)),
+		.read_seq_string = blkcg_print_cpu_rwstat,
+	},
+	{
+		.name = "io_service_time",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, service_time)),
+		.read_seq_string = blkcg_print_rwstat,
+	},
+	{
+		.name = "io_wait_time",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, wait_time)),
+		.read_seq_string = blkcg_print_rwstat,
+	},
+	{
+		.name = "io_merged",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, merged)),
+		.read_seq_string = blkcg_print_rwstat,
+	},
+	{
+		.name = "io_queued",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, queued)),
+		.read_seq_string = blkcg_print_rwstat,
+	},
+#ifdef CONFIG_DEBUG_BLK_CGROUP
+	{
+		.name = "avg_queue_size",
+		.read_seq_string = blkcg_print_avg_queue_size,
+	},
+	{
+		.name = "group_wait_time",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, group_wait_time)),
+		.read_seq_string = blkcg_print_stat,
+	},
+	{
+		.name = "idle_time",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, idle_time)),
+		.read_seq_string = blkcg_print_stat,
+	},
+	{
+		.name = "empty_time",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, empty_time)),
+		.read_seq_string = blkcg_print_stat,
+	},
+	{
+		.name = "dequeue",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, dequeue)),
+		.read_seq_string = blkcg_print_stat,
+	},
+	{
+		.name = "unaccounted_time",
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, unaccounted_time)),
+		.read_seq_string = blkcg_print_stat,
+	},
+#endif	/* CONFIG_DEBUG_BLK_CGROUP */
+	{ }	/* terminate */
+};
 #else /* GROUP_IOSCHED */
 static struct cfq_group *cfq_lookup_create_cfqg(struct cfq_data *cfqd,
 						struct blkio_cgroup *blkcg)
@@ -3715,10 +3911,10 @@ static struct elevator_type iosched_cfq = {
 static struct blkio_policy_type blkio_policy_cfq = {
 	.ops = {
 		.blkio_init_group_fn =		cfq_init_blkio_group,
-		.blkio_update_group_weight_fn =	cfq_update_blkio_group_weight,
 	},
 	.plid = BLKIO_POLICY_PROP,
 	.pdata_size = sizeof(struct cfq_group),
+	.cftypes = cfq_blkcg_files,
 };
 #endif
 
-- 
1.7.7.3
