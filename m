From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 07/21] blkcg: restructure blkio_group configruation setting
Date: Wed, 28 Mar 2012 15:51:17 -0700
Message-ID: <1332975091-10950-8-git-send-email-tj@kernel.org>
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

As part of userland interface restructuring, this patch updates
per-blkio_group configuration setting.  Instead of funneling
everything through a master function which has hard-coded cases for
each config file it may handle, the common part is factored into
blkg_conf_prep() and blkg_conf_finish() and different configuration
setters are implemented using the helpers.

While this doesn't result in immediate LOC reduction, this enables
further cleanups and more modular implementation.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c |  274 ++++++++++++++++++++++++++++------------------------
 block/blk-cgroup.h |   13 ---
 2 files changed, 147 insertions(+), 140 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 5e8a818..0d4f21e 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -43,12 +43,6 @@ EXPORT_SYMBOL_GPL(blkio_root_cgroup);
 
 static struct blkio_policy_type *blkio_policy[BLKIO_NR_POLICIES];
 
-/* for encoding cft->private value on file */
-#define BLKIOFILE_PRIVATE(x, val)	(((x) << 16) | (val))
-/* What policy owns the file, proportional or throttle */
-#define BLKIOFILE_POLICY(val)		(((val) >> 16) & 0xffff)
-#define BLKIOFILE_ATTR(val)		((val) & 0xffff)
-
 struct blkio_cgroup *cgroup_to_blkio_cgroup(struct cgroup *cgroup)
 {
 	return container_of(cgroup_subsys_state(cgroup, blkio_subsys_id),
@@ -86,7 +80,7 @@ static inline void blkio_update_group_weight(struct blkio_group *blkg,
 }
 
 static inline void blkio_update_group_bps(struct blkio_group *blkg, int plid,
-					  u64 bps, int fileid)
+					  u64 bps, int rw)
 {
 	struct blkio_policy_type *blkiop;
 
@@ -96,21 +90,18 @@ static inline void blkio_update_group_bps(struct blkio_group *blkg, int plid,
 		if (blkiop->plid != plid)
 			continue;
 
-		if (fileid == BLKIO_THROTL_read_bps_device
-		    && blkiop->ops.blkio_update_group_read_bps_fn)
+		if (rw == READ && blkiop->ops.blkio_update_group_read_bps_fn)
 			blkiop->ops.blkio_update_group_read_bps_fn(blkg->q,
 								blkg, bps);
 
-		if (fileid == BLKIO_THROTL_write_bps_device
-		    && blkiop->ops.blkio_update_group_write_bps_fn)
+		if (rw == WRITE && blkiop->ops.blkio_update_group_write_bps_fn)
 			blkiop->ops.blkio_update_group_write_bps_fn(blkg->q,
 								blkg, bps);
 	}
 }
 
-static inline void blkio_update_group_iops(struct blkio_group *blkg,
-					   int plid, unsigned int iops,
-					   int fileid)
+static inline void blkio_update_group_iops(struct blkio_group *blkg, int plid,
+					   u64 iops, int rw)
 {
 	struct blkio_policy_type *blkiop;
 
@@ -120,13 +111,11 @@ static inline void blkio_update_group_iops(struct blkio_group *blkg,
 		if (blkiop->plid != plid)
 			continue;
 
-		if (fileid == BLKIO_THROTL_read_iops_device
-		    && blkiop->ops.blkio_update_group_read_iops_fn)
+		if (rw == READ && blkiop->ops.blkio_update_group_read_iops_fn)
 			blkiop->ops.blkio_update_group_read_iops_fn(blkg->q,
 								blkg, iops);
 
-		if (fileid == BLKIO_THROTL_write_iops_device
-		    && blkiop->ops.blkio_update_group_write_iops_fn)
+		if (rw == WRITE && blkiop->ops.blkio_update_group_write_iops_fn)
 			blkiop->ops.blkio_update_group_write_iops_fn(blkg->q,
 								blkg,iops);
 	}
@@ -975,19 +964,40 @@ static int blkcg_print_avg_queue_size(struct cgroup *cgrp, struct cftype *cft,
 }
 #endif	/* CONFIG_DEBUG_BLK_CGROUP */
 
-static int blkio_policy_parse_and_set(char *buf, enum blkio_policy_id plid,
-				      int fileid, struct blkio_cgroup *blkcg)
+struct blkg_conf_ctx {
+	struct gendisk		*disk;
+	struct blkio_group	*blkg;
+	u64			v;
+};
+
+/**
+ * blkg_conf_prep - parse and prepare for per-blkg config update
+ * @blkcg: target block cgroup
+ * @input: input string
+ * @ctx: blkg_conf_ctx to be filled
+ *
+ * Parse per-blkg config update from @input and initialize @ctx with the
+ * result.  @ctx->blkg points to the blkg to be updated and @ctx->v the new
+ * value.  This function returns with RCU read locked and must be paired
+ * with blkg_conf_finish().
+ */
+static int blkg_conf_prep(struct blkio_cgroup *blkcg, const char *input,
+			  struct blkg_conf_ctx *ctx)
+	__acquires(rcu)
 {
-	struct gendisk *disk = NULL;
-	struct blkio_group *blkg = NULL;
-	struct blkg_policy_data *pd;
-	char *s[4], *p, *major_s = NULL, *minor_s = NULL;
+	struct gendisk *disk;
+	struct blkio_group *blkg;
+	char *buf, *s[4], *p, *major_s, *minor_s;
 	unsigned long major, minor;
 	int i = 0, ret = -EINVAL;
 	int part;
 	dev_t dev;
 	u64 temp;
 
+	buf = kstrdup(input, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
 	memset(s, 0, sizeof(s));
 
 	while ((p = strsep(&buf, " ")) != NULL) {
@@ -1037,82 +1047,42 @@ static int blkio_policy_parse_and_set(char *buf, enum blkio_policy_id plid,
 
 	if (IS_ERR(blkg)) {
 		ret = PTR_ERR(blkg);
-		goto out_unlock;
-	}
-
-	pd = blkg->pd[plid];
-
-	switch (plid) {
-	case BLKIO_POLICY_PROP:
-		if ((temp < BLKIO_WEIGHT_MIN && temp > 0) ||
-		     temp > BLKIO_WEIGHT_MAX)
-			goto out_unlock;
-
-		pd->conf.weight = temp;
-		blkio_update_group_weight(blkg, plid, temp ?: blkcg->weight);
-		break;
-	case BLKIO_POLICY_THROTL:
-		switch(fileid) {
-		case BLKIO_THROTL_read_bps_device:
-			pd->conf.bps[READ] = temp;
-			blkio_update_group_bps(blkg, plid, temp ?: -1, fileid);
-			break;
-		case BLKIO_THROTL_write_bps_device:
-			pd->conf.bps[WRITE] = temp;
-			blkio_update_group_bps(blkg, plid, temp ?: -1, fileid);
-			break;
-		case BLKIO_THROTL_read_iops_device:
-			if (temp > THROTL_IOPS_MAX)
-				goto out_unlock;
-			pd->conf.iops[READ] = temp;
-			blkio_update_group_iops(blkg, plid, temp ?: -1, fileid);
-			break;
-		case BLKIO_THROTL_write_iops_device:
-			if (temp > THROTL_IOPS_MAX)
-				goto out_unlock;
-			pd->conf.iops[WRITE] = temp;
-			blkio_update_group_iops(blkg, plid, temp ?: -1, fileid);
-			break;
+		rcu_read_unlock();
+		put_disk(disk);
+		/*
+		 * If queue was bypassing, we should retry.  Do so after a
+		 * short msleep().  It isn't strictly necessary but queue
+		 * can be bypassing for some time and it's always nice to
+		 * avoid busy looping.
+		 */
+		if (ret == -EBUSY) {
+			msleep(10);
+			ret = restart_syscall();
 		}
-		break;
-	default:
-		BUG();
+		goto out;
 	}
+
+	ctx->disk = disk;
+	ctx->blkg = blkg;
+	ctx->v = temp;
 	ret = 0;
-out_unlock:
-	rcu_read_unlock();
 out:
-	put_disk(disk);
-
-	/*
-	 * If queue was bypassing, we should retry.  Do so after a short
-	 * msleep().  It isn't strictly necessary but queue can be
-	 * bypassing for some time and it's always nice to avoid busy
-	 * looping.
-	 */
-	if (ret == -EBUSY) {
-		msleep(10);
-		return restart_syscall();
-	}
+	kfree(buf);
 	return ret;
 }
 
-static int blkiocg_file_write(struct cgroup *cgrp, struct cftype *cft,
- 				       const char *buffer)
+/**
+ * blkg_conf_finish - finish up per-blkg config update
+ * @ctx: blkg_conf_ctx intiailized by blkg_conf_prep()
+ *
+ * Finish up after per-blkg config update.  This function must be paired
+ * with blkg_conf_prep().
+ */
+static void blkg_conf_finish(struct blkg_conf_ctx *ctx)
+	__releases(rcu)
 {
-	int ret = 0;
-	char *buf;
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
-	enum blkio_policy_id plid = BLKIOFILE_POLICY(cft->private);
-	int fileid = BLKIOFILE_ATTR(cft->private);
-
-	buf = kstrdup(buffer, GFP_KERNEL);
-	if (!buf)
-		return -ENOMEM;
-
-	ret = blkio_policy_parse_and_set(buf, plid, fileid, blkcg);
-	kfree(buf);
-	return ret;
+	rcu_read_unlock();
+	put_disk(ctx->disk);
 }
 
 /* for propio conf */
@@ -1140,6 +1110,32 @@ static int blkcg_print_weight(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
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
+		blkio_update_group_weight(ctx.blkg, BLKIO_POLICY_PROP,
+					  ctx.v ?: blkcg->weight);
+		ret = 0;
+	}
+
+	blkg_conf_finish(&ctx);
+	return ret;
+}
+
 static int blkcg_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
@@ -1181,39 +1177,67 @@ static u64 blkg_prfill_conf_u64(struct seq_file *sf,
 static int blkcg_print_conf_u64(struct cgroup *cgrp, struct cftype *cft,
 				struct seq_file *sf)
 {
-	int off;
-
-	switch (BLKIOFILE_ATTR(cft->private)) {
-	case BLKIO_THROTL_read_bps_device:
-		off = offsetof(struct blkio_group_conf, bps[READ]);
-		break;
-	case BLKIO_THROTL_write_bps_device:
-		off = offsetof(struct blkio_group_conf, bps[WRITE]);
-		break;
-	case BLKIO_THROTL_read_iops_device:
-		off = offsetof(struct blkio_group_conf, iops[READ]);
-		break;
-	case BLKIO_THROTL_write_iops_device:
-		off = offsetof(struct blkio_group_conf, iops[WRITE]);
-		break;
-	default:
-		return -EINVAL;
-	}
-
 	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp),
 			  blkg_prfill_conf_u64, BLKIO_POLICY_THROTL,
-			  off, false);
+			  cft->private, false);
 	return 0;
 }
+
+static int blkcg_set_conf_u64(struct cgroup *cgrp, struct cftype *cft,
+			      const char *buf, int rw,
+			      void (*update)(struct blkio_group *, int, u64, int))
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
+		update(ctx.blkg, BLKIO_POLICY_THROTL, ctx.v ?: -1, rw);
+		ret = 0;
+	}
+
+	blkg_conf_finish(&ctx);
+	return ret;
+}
+
+static int blkcg_set_conf_bps_r(struct cgroup *cgrp, struct cftype *cft,
+				const char *buf)
+{
+	return blkcg_set_conf_u64(cgrp, cft, buf, READ, blkio_update_group_bps);
+}
+
+static int blkcg_set_conf_bps_w(struct cgroup *cgrp, struct cftype *cft,
+				const char *buf)
+{
+	return blkcg_set_conf_u64(cgrp, cft, buf, WRITE, blkio_update_group_bps);
+}
+
+static int blkcg_set_conf_iops_r(struct cgroup *cgrp, struct cftype *cft,
+				 const char *buf)
+{
+	return blkcg_set_conf_u64(cgrp, cft, buf, READ, blkio_update_group_iops);
+}
+
+static int blkcg_set_conf_iops_w(struct cgroup *cgrp, struct cftype *cft,
+				 const char *buf)
+{
+	return blkcg_set_conf_u64(cgrp, cft, buf, WRITE, blkio_update_group_iops);
+}
 #endif
 
 struct cftype blkio_files[] = {
 	{
 		.name = "weight_device",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_weight_device),
 		.read_seq_string = blkcg_print_weight_device,
-		.write_string = blkiocg_file_write,
+		.write_string = blkcg_set_weight_device,
 		.max_write_len = 256,
 	},
 	{
@@ -1276,37 +1300,33 @@ struct cftype blkio_files[] = {
 #ifdef CONFIG_BLK_DEV_THROTTLING
 	{
 		.name = "throttle.read_bps_device",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_THROTL,
-				BLKIO_THROTL_read_bps_device),
+		.private = offsetof(struct blkio_group_conf, bps[READ]),
 		.read_seq_string = blkcg_print_conf_u64,
-		.write_string = blkiocg_file_write,
+		.write_string = blkcg_set_conf_bps_r,
 		.max_write_len = 256,
 	},
 
 	{
 		.name = "throttle.write_bps_device",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_THROTL,
-				BLKIO_THROTL_write_bps_device),
+		.private = offsetof(struct blkio_group_conf, bps[WRITE]),
 		.read_seq_string = blkcg_print_conf_u64,
-		.write_string = blkiocg_file_write,
+		.write_string = blkcg_set_conf_bps_w,
 		.max_write_len = 256,
 	},
 
 	{
 		.name = "throttle.read_iops_device",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_THROTL,
-				BLKIO_THROTL_read_iops_device),
+		.private = offsetof(struct blkio_group_conf, iops[READ]),
 		.read_seq_string = blkcg_print_conf_u64,
-		.write_string = blkiocg_file_write,
+		.write_string = blkcg_set_conf_iops_r,
 		.max_write_len = 256,
 	},
 
 	{
 		.name = "throttle.write_iops_device",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_THROTL,
-				BLKIO_THROTL_write_iops_device),
+		.private = offsetof(struct blkio_group_conf, iops[WRITE]),
 		.read_seq_string = blkcg_print_conf_u64,
-		.write_string = blkiocg_file_write,
+		.write_string = blkcg_set_conf_iops_w,
 		.max_write_len = 256,
 	},
 	{
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index b67eefa..108ffbf 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -50,19 +50,6 @@ enum blkg_state_flags {
 	BLKG_empty,
 };
 
-/* cgroup files owned by proportional weight policy */
-enum blkcg_file_name_prop {
-	BLKIO_PROP_weight_device,
-};
-
-/* cgroup files owned by throttle policy */
-enum blkcg_file_name_throtl {
-	BLKIO_THROTL_read_bps_device,
-	BLKIO_THROTL_write_bps_device,
-	BLKIO_THROTL_read_iops_device,
-	BLKIO_THROTL_write_iops_device,
-};
-
 struct blkio_cgroup {
 	struct cgroup_subsys_state css;
 	unsigned int weight;
-- 
1.7.7.3
