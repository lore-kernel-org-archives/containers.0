From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/21] blkcg: restructure configuration printing
Date: Wed, 28 Mar 2012 15:51:16 -0700
Message-ID: <1332975091-10950-7-git-send-email-tj@kernel.org>
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

Similarly to the previous stat restructuring, this patch restructures
conf printing code such that,

* Conf printing uses the same helpers as stat.

* Printing function doesn't require hardcoded switching on the config
  being printed.  Note that this isn't complete yet for throttle
  confs.  The next patch will convert setting for these confs and will
  complete the transition.

* Printing uses read_seq_string callback (other methods will be phased
  out).

Note that blkio_group_conf.iops[2] is changed to u64 so that they can
be manipulated with the same functions.  This is transitional and will
go away later.

After this patch, per-device configurations - weight, bps and iops -
use __blkg_prfill_u64() for printing which uses white space as
delimiter instead of tab.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c |  156 ++++++++++++++++++----------------------------------
 block/blk-cgroup.h |    3 +-
 2 files changed, 55 insertions(+), 104 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index ae539d3..5e8a818 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -1115,95 +1115,28 @@ static int blkiocg_file_write(struct cgroup *cgrp, struct cftype *cft,
 	return ret;
 }
 
-static void blkio_print_group_conf(struct cftype *cft, struct blkio_group *blkg,
-				   struct seq_file *m)
+/* for propio conf */
+static u64 blkg_prfill_weight_device(struct seq_file *sf,
+				     struct blkg_policy_data *pd, int off)
 {
-	int plid = BLKIOFILE_POLICY(cft->private);
-	int fileid = BLKIOFILE_ATTR(cft->private);
-	struct blkg_policy_data *pd = blkg->pd[plid];
-	const char *dname = blkg_dev_name(blkg);
-	int rw = WRITE;
-
-	if (!dname)
-		return;
-
-	switch (plid) {
-		case BLKIO_POLICY_PROP:
-			if (pd->conf.weight)
-				seq_printf(m, "%s\t%u\n",
-					   dname, pd->conf.weight);
-			break;
-		case BLKIO_POLICY_THROTL:
-			switch (fileid) {
-			case BLKIO_THROTL_read_bps_device:
-				rw = READ;
-			case BLKIO_THROTL_write_bps_device:
-				if (pd->conf.bps[rw])
-					seq_printf(m, "%s\t%llu\n",
-						   dname, pd->conf.bps[rw]);
-				break;
-			case BLKIO_THROTL_read_iops_device:
-				rw = READ;
-			case BLKIO_THROTL_write_iops_device:
-				if (pd->conf.iops[rw])
-					seq_printf(m, "%s\t%u\n",
-						   dname, pd->conf.iops[rw]);
-				break;
-			}
-			break;
-		default:
-			BUG();
-	}
+	if (!pd->conf.weight)
+		return 0;
+	return __blkg_prfill_u64(sf, pd, pd->conf.weight);
 }
 
-/* cgroup files which read their data from policy nodes end up here */
-static void blkio_read_conf(struct cftype *cft, struct blkio_cgroup *blkcg,
-			    struct seq_file *m)
+static int blkcg_print_weight_device(struct cgroup *cgrp, struct cftype *cft,
+				     struct seq_file *sf)
 {
-	struct blkio_group *blkg;
-	struct hlist_node *n;
-
-	spin_lock_irq(&blkcg->lock);
-	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node)
-		blkio_print_group_conf(cft, blkg, m);
-	spin_unlock_irq(&blkcg->lock);
+	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp),
+			  blkg_prfill_weight_device, BLKIO_POLICY_PROP, 0,
+			  false);
+	return 0;
 }
 
-static int blkiocg_file_read(struct cgroup *cgrp, struct cftype *cft,
-				struct seq_file *m)
+static int blkcg_print_weight(struct cgroup *cgrp, struct cftype *cft,
+			      struct seq_file *sf)
 {
-	struct blkio_cgroup *blkcg;
-	enum blkio_policy_id plid = BLKIOFILE_POLICY(cft->private);
-	int name = BLKIOFILE_ATTR(cft->private);
-
-	blkcg = cgroup_to_blkio_cgroup(cgrp);
-
-	switch(plid) {
-	case BLKIO_POLICY_PROP:
-		switch(name) {
-		case BLKIO_PROP_weight_device:
-			blkio_read_conf(cft, blkcg, m);
-			return 0;
-		default:
-			BUG();
-		}
-		break;
-	case BLKIO_POLICY_THROTL:
-		switch(name){
-		case BLKIO_THROTL_read_bps_device:
-		case BLKIO_THROTL_write_bps_device:
-		case BLKIO_THROTL_read_iops_device:
-		case BLKIO_THROTL_write_iops_device:
-			blkio_read_conf(cft, blkcg, m);
-			return 0;
-		default:
-			BUG();
-		}
-		break;
-	default:
-		BUG();
-	}
-
+	seq_printf(sf, "%u\n", cgroup_to_blkio_cgroup(cgrp)->weight);
 	return 0;
 }
 
@@ -1233,40 +1166,59 @@ static int blkcg_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
 	return 0;
 }
 
-static u64 blkiocg_file_read_u64 (struct cgroup *cgrp, struct cftype *cft) {
-	struct blkio_cgroup *blkcg;
-	enum blkio_policy_id plid = BLKIOFILE_POLICY(cft->private);
-	int name = BLKIOFILE_ATTR(cft->private);
+/* for blk-throttle conf */
+#ifdef CONFIG_BLK_DEV_THROTTLING
+static u64 blkg_prfill_conf_u64(struct seq_file *sf,
+				struct blkg_policy_data *pd, int off)
+{
+	u64 v = *(u64 *)((void *)&pd->conf + off);
 
-	blkcg = cgroup_to_blkio_cgroup(cgrp);
+	if (!v)
+		return 0;
+	return __blkg_prfill_u64(sf, pd, v);
+}
 
-	switch(plid) {
-	case BLKIO_POLICY_PROP:
-		switch(name) {
-		case BLKIO_PROP_weight:
-			return (u64)blkcg->weight;
-		}
+static int blkcg_print_conf_u64(struct cgroup *cgrp, struct cftype *cft,
+				struct seq_file *sf)
+{
+	int off;
+
+	switch (BLKIOFILE_ATTR(cft->private)) {
+	case BLKIO_THROTL_read_bps_device:
+		off = offsetof(struct blkio_group_conf, bps[READ]);
+		break;
+	case BLKIO_THROTL_write_bps_device:
+		off = offsetof(struct blkio_group_conf, bps[WRITE]);
+		break;
+	case BLKIO_THROTL_read_iops_device:
+		off = offsetof(struct blkio_group_conf, iops[READ]);
+		break;
+	case BLKIO_THROTL_write_iops_device:
+		off = offsetof(struct blkio_group_conf, iops[WRITE]);
 		break;
 	default:
-		BUG();
+		return -EINVAL;
 	}
+
+	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp),
+			  blkg_prfill_conf_u64, BLKIO_POLICY_THROTL,
+			  off, false);
 	return 0;
 }
+#endif
 
 struct cftype blkio_files[] = {
 	{
 		.name = "weight_device",
 		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
 				BLKIO_PROP_weight_device),
-		.read_seq_string = blkiocg_file_read,
+		.read_seq_string = blkcg_print_weight_device,
 		.write_string = blkiocg_file_write,
 		.max_write_len = 256,
 	},
 	{
 		.name = "weight",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_weight),
-		.read_u64 = blkiocg_file_read_u64,
+		.read_seq_string = blkcg_print_weight,
 		.write_u64 = blkcg_set_weight,
 	},
 	{
@@ -1326,7 +1278,7 @@ struct cftype blkio_files[] = {
 		.name = "throttle.read_bps_device",
 		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_THROTL,
 				BLKIO_THROTL_read_bps_device),
-		.read_seq_string = blkiocg_file_read,
+		.read_seq_string = blkcg_print_conf_u64,
 		.write_string = blkiocg_file_write,
 		.max_write_len = 256,
 	},
@@ -1335,7 +1287,7 @@ struct cftype blkio_files[] = {
 		.name = "throttle.write_bps_device",
 		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_THROTL,
 				BLKIO_THROTL_write_bps_device),
-		.read_seq_string = blkiocg_file_read,
+		.read_seq_string = blkcg_print_conf_u64,
 		.write_string = blkiocg_file_write,
 		.max_write_len = 256,
 	},
@@ -1344,7 +1296,7 @@ struct cftype blkio_files[] = {
 		.name = "throttle.read_iops_device",
 		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_THROTL,
 				BLKIO_THROTL_read_iops_device),
-		.read_seq_string = blkiocg_file_read,
+		.read_seq_string = blkcg_print_conf_u64,
 		.write_string = blkiocg_file_write,
 		.max_write_len = 256,
 	},
@@ -1353,7 +1305,7 @@ struct cftype blkio_files[] = {
 		.name = "throttle.write_iops_device",
 		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_THROTL,
 				BLKIO_THROTL_write_iops_device),
-		.read_seq_string = blkiocg_file_read,
+		.read_seq_string = blkcg_print_conf_u64,
 		.write_string = blkiocg_file_write,
 		.max_write_len = 256,
 	},
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 7331d79..b67eefa 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -52,7 +52,6 @@ enum blkg_state_flags {
 
 /* cgroup files owned by proportional weight policy */
 enum blkcg_file_name_prop {
-	BLKIO_PROP_weight = 1,
 	BLKIO_PROP_weight_device,
 };
 
@@ -130,7 +129,7 @@ struct blkio_group_stats_cpu {
 
 struct blkio_group_conf {
 	unsigned int weight;
-	unsigned int iops[2];
+	u64 iops[2];
 	u64 bps[2];
 };
 
-- 
1.7.7.3
