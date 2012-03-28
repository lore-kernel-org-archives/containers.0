From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 19/21] blkcg: move blkio_group_conf->iops and ->bps to
	blk-throttle
Date: Wed, 28 Mar 2012 15:51:29 -0700
Message-ID: <1332975091-10950-20-git-send-email-tj@kernel.org>
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

blkio_cgroup_conf->iops and ->bps are owned by blk-throttle and has no
reason to be defined in blkcg core.  Drop them and let conf setting
functions directly manipulate throtl_grp->bps[] and ->iops[].

This makes blkio_group_conf empty.  Drop it.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.h   |    8 ---
 block/blk-throttle.c |  153 +++++++++++++++++++-------------------------------
 2 files changed, 58 insertions(+), 103 deletions(-)

diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 386db29..a77ab1a 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -71,19 +71,11 @@ struct blkg_rwstat {
 	uint64_t			cnt[BLKG_RWSTAT_NR];
 };
 
-struct blkio_group_conf {
-	u64 iops[2];
-	u64 bps[2];
-};
-
 /* per-blkg per-policy data */
 struct blkg_policy_data {
 	/* the blkg this per-policy data belongs to */
 	struct blkio_group *blkg;
 
-	/* Configuration */
-	struct blkio_group_conf conf;
-
 	/* pol->pdata_size bytes of private data used by policy impl */
 	char pdata[] __aligned(__alignof__(unsigned long long));
 };
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 27f7960..004964b 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -924,20 +924,6 @@ throtl_schedule_delayed_work(struct throtl_data *td, unsigned long delay)
 	}
 }
 
-/*
- * Can not take queue lock in update functions as queue lock under
- * blkcg_lock is not allowed. Under other paths we take blkcg_lock under
- * queue_lock.
- */
-static void throtl_update_blkio_group_common(struct throtl_data *td,
-				struct throtl_grp *tg)
-{
-	xchg(&tg->limits_changed, true);
-	xchg(&td->limits_changed, true);
-	/* Schedule a work now to process the limit change */
-	throtl_schedule_delayed_work(td, 0);
-}
-
 static u64 tg_prfill_cpu_rwstat(struct seq_file *sf,
 				struct blkg_policy_data *pd, int off)
 {
@@ -968,68 +954,48 @@ static int tg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
-static u64 blkg_prfill_conf_u64(struct seq_file *sf,
-				struct blkg_policy_data *pd, int off)
+static u64 tg_prfill_conf_u64(struct seq_file *sf, struct blkg_policy_data *pd,
+			      int off)
 {
-	u64 v = *(u64 *)((void *)&pd->conf + off);
+	u64 v = *(u64 *)((void *)pd->pdata + off);
 
-	if (!v)
+	if (v == -1)
 		return 0;
 	return __blkg_prfill_u64(sf, pd, v);
 }
 
-static int blkcg_print_conf_u64(struct cgroup *cgrp, struct cftype *cft,
-				struct seq_file *sf)
+static u64 tg_prfill_conf_uint(struct seq_file *sf, struct blkg_policy_data *pd,
+			       int off)
 {
-	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp),
-			  blkg_prfill_conf_u64, BLKIO_POLICY_THROTL,
-			  cft->private, false);
-	return 0;
-}
+	unsigned int v = *(unsigned int *)((void *)pd->pdata + off);
 
-static void throtl_update_blkio_group_read_bps(struct blkio_group *blkg,
-					       u64 read_bps)
-{
-	struct throtl_grp *tg = blkg_to_tg(blkg);
-
-	tg->bps[READ] = read_bps;
-	throtl_update_blkio_group_common(blkg->q->td, tg);
-}
-
-static void throtl_update_blkio_group_write_bps(struct blkio_group *blkg,
-						u64 write_bps)
-{
-	struct throtl_grp *tg = blkg_to_tg(blkg);
-
-	tg->bps[WRITE] = write_bps;
-	throtl_update_blkio_group_common(blkg->q->td, tg);
+	if (v == -1)
+		return 0;
+	return __blkg_prfill_u64(sf, pd, v);
 }
 
-static void throtl_update_blkio_group_read_iops(struct blkio_group *blkg,
-						u64 read_iops)
+static int tg_print_conf_u64(struct cgroup *cgrp, struct cftype *cft,
+			     struct seq_file *sf)
 {
-	struct throtl_grp *tg = blkg_to_tg(blkg);
-
-	tg->iops[READ] = read_iops;
-	throtl_update_blkio_group_common(blkg->q->td, tg);
+	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp), tg_prfill_conf_u64,
+			  BLKIO_POLICY_THROTL, cft->private, false);
+	return 0;
 }
 
-static void throtl_update_blkio_group_write_iops(struct blkio_group *blkg,
-						 u64 write_iops)
+static int tg_print_conf_uint(struct cgroup *cgrp, struct cftype *cft,
+			      struct seq_file *sf)
 {
-	struct throtl_grp *tg = blkg_to_tg(blkg);
-
-	tg->iops[WRITE] = write_iops;
-	throtl_update_blkio_group_common(blkg->q->td, tg);
+	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp), tg_prfill_conf_uint,
+			  BLKIO_POLICY_THROTL, cft->private, false);
+	return 0;
 }
 
-static int blkcg_set_conf_u64(struct cgroup *cgrp, struct cftype *cft,
-			      const char *buf,
-			      void (*update)(struct blkio_group *, u64))
+static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
+		       bool is_u64)
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
-	struct blkg_policy_data *pd;
 	struct blkg_conf_ctx ctx;
+	struct throtl_grp *tg;
 	int ret;
 
 	ret = blkg_conf_prep(blkcg, buf, &ctx);
@@ -1037,10 +1003,23 @@ static int blkcg_set_conf_u64(struct cgroup *cgrp, struct cftype *cft,
 		return ret;
 
 	ret = -EINVAL;
-	pd = ctx.blkg->pd[BLKIO_POLICY_THROTL];
-	if (pd) {
-		*(u64 *)((void *)&pd->conf + cft->private) = ctx.v;
-		update(ctx.blkg, ctx.v ?: -1);
+	tg = blkg_to_tg(ctx.blkg);
+	if (tg) {
+		struct throtl_data *td = ctx.blkg->q->td;
+
+		if (!ctx.v)
+			ctx.v = -1;
+
+		if (is_u64)
+			*(u64 *)((void *)tg + cft->private) = ctx.v;
+		else
+			*(unsigned int *)((void *)tg + cft->private) = ctx.v;
+
+		/* XXX: we don't need the following deferred processing */
+		xchg(&tg->limits_changed, true);
+		xchg(&td->limits_changed, true);
+		throtl_schedule_delayed_work(td, 0);
+
 		ret = 0;
 	}
 
@@ -1048,61 +1027,45 @@ static int blkcg_set_conf_u64(struct cgroup *cgrp, struct cftype *cft,
 	return ret;
 }
 
-static int blkcg_set_conf_bps_r(struct cgroup *cgrp, struct cftype *cft,
-				const char *buf)
-{
-	return blkcg_set_conf_u64(cgrp, cft, buf,
-				  throtl_update_blkio_group_read_bps);
-}
-
-static int blkcg_set_conf_bps_w(struct cgroup *cgrp, struct cftype *cft,
-				const char *buf)
-{
-	return blkcg_set_conf_u64(cgrp, cft, buf,
-				  throtl_update_blkio_group_write_bps);
-}
-
-static int blkcg_set_conf_iops_r(struct cgroup *cgrp, struct cftype *cft,
-				 const char *buf)
+static int tg_set_conf_u64(struct cgroup *cgrp, struct cftype *cft,
+			   const char *buf)
 {
-	return blkcg_set_conf_u64(cgrp, cft, buf,
-				  throtl_update_blkio_group_read_iops);
+	return tg_set_conf(cgrp, cft, buf, true);
 }
 
-static int blkcg_set_conf_iops_w(struct cgroup *cgrp, struct cftype *cft,
-				 const char *buf)
+static int tg_set_conf_uint(struct cgroup *cgrp, struct cftype *cft,
+			    const char *buf)
 {
-	return blkcg_set_conf_u64(cgrp, cft, buf,
-				  throtl_update_blkio_group_write_iops);
+	return tg_set_conf(cgrp, cft, buf, false);
 }
 
 static struct cftype throtl_files[] = {
 	{
 		.name = "throttle.read_bps_device",
-		.private = offsetof(struct blkio_group_conf, bps[READ]),
-		.read_seq_string = blkcg_print_conf_u64,
-		.write_string = blkcg_set_conf_bps_r,
+		.private = offsetof(struct throtl_grp, bps[READ]),
+		.read_seq_string = tg_print_conf_u64,
+		.write_string = tg_set_conf_u64,
 		.max_write_len = 256,
 	},
 	{
 		.name = "throttle.write_bps_device",
-		.private = offsetof(struct blkio_group_conf, bps[WRITE]),
-		.read_seq_string = blkcg_print_conf_u64,
-		.write_string = blkcg_set_conf_bps_w,
+		.private = offsetof(struct throtl_grp, bps[WRITE]),
+		.read_seq_string = tg_print_conf_u64,
+		.write_string = tg_set_conf_u64,
 		.max_write_len = 256,
 	},
 	{
 		.name = "throttle.read_iops_device",
-		.private = offsetof(struct blkio_group_conf, iops[READ]),
-		.read_seq_string = blkcg_print_conf_u64,
-		.write_string = blkcg_set_conf_iops_r,
+		.private = offsetof(struct throtl_grp, iops[READ]),
+		.read_seq_string = tg_print_conf_uint,
+		.write_string = tg_set_conf_uint,
 		.max_write_len = 256,
 	},
 	{
 		.name = "throttle.write_iops_device",
-		.private = offsetof(struct blkio_group_conf, iops[WRITE]),
-		.read_seq_string = blkcg_print_conf_u64,
-		.write_string = blkcg_set_conf_iops_w,
+		.private = offsetof(struct throtl_grp, iops[WRITE]),
+		.read_seq_string = tg_print_conf_uint,
+		.write_string = tg_set_conf_uint,
 		.max_write_len = 256,
 	},
 	{
-- 
1.7.7.3
