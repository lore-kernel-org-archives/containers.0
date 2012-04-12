From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/8] blkcg: use @pol instead of @plid in update_root_blkg_pd()
	and blkcg_print_blkgs()
Date: Thu, 12 Apr 2012 16:29:34 -0700
Message-ID: <1334273380-30233-3-git-send-email-tj@kernel.org>
References: <1334273380-30233-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1334273380-30233-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

The two functions were taking "enum blkio_policy_id plid".  Make them
take "const struct blkio_policy_type *pol" instead.

This is to prepare for per-queue policy activation and doesn't cause
any functional difference.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c   |   21 +++++++++++----------
 block/blk-cgroup.h   |    7 ++++---
 block/blk-throttle.c |    6 +++---
 block/cfq-iosched.c  |   10 +++++-----
 4 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index af665fe..b123152 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -226,17 +226,17 @@ static void blkg_destroy(struct blkio_group *blkg)
  * aren't shot down.  This broken and racy implementation is temporary.
  * Eventually, blkg shoot down will be replaced by proper in-place update.
  */
-void update_root_blkg_pd(struct request_queue *q, enum blkio_policy_id plid)
+void update_root_blkg_pd(struct request_queue *q,
+			 const struct blkio_policy_type *pol)
 {
-	struct blkio_policy_type *pol = blkio_policy[plid];
 	struct blkio_group *blkg = blkg_lookup(&blkio_root_cgroup, q);
 	struct blkg_policy_data *pd;
 
 	if (!blkg)
 		return;
 
-	kfree(blkg->pd[plid]);
-	blkg->pd[plid] = NULL;
+	kfree(blkg->pd[pol->plid]);
+	blkg->pd[pol->plid] = NULL;
 
 	if (!pol)
 		return;
@@ -244,7 +244,7 @@ void update_root_blkg_pd(struct request_queue *q, enum blkio_policy_id plid)
 	pd = kzalloc(sizeof(*pd) + pol->pdata_size, GFP_KERNEL);
 	WARN_ON_ONCE(!pd);
 
-	blkg->pd[plid] = pd;
+	blkg->pd[pol->plid] = pd;
 	pd->blkg = blkg;
 	pol->ops.blkio_init_group_fn(blkg);
 }
@@ -360,7 +360,8 @@ static const char *blkg_dev_name(struct blkio_group *blkg)
  */
 void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
 		       u64 (*prfill)(struct seq_file *, void *, int),
-		       int pol, int data, bool show_total)
+		       const struct blkio_policy_type *pol, int data,
+		       bool show_total)
 {
 	struct blkio_group *blkg;
 	struct hlist_node *n;
@@ -368,8 +369,8 @@ void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
 
 	spin_lock_irq(&blkcg->lock);
 	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node)
-		if (blkg->pd[pol])
-			total += prfill(sf, blkg->pd[pol]->pdata, data);
+		if (blkg->pd[pol->plid])
+			total += prfill(sf, blkg->pd[pol->plid]->pdata, data);
 	spin_unlock_irq(&blkcg->lock);
 
 	if (show_total)
@@ -739,7 +740,7 @@ void blkio_policy_register(struct blkio_policy_type *blkiop)
 	BUG_ON(blkio_policy[blkiop->plid]);
 	blkio_policy[blkiop->plid] = blkiop;
 	list_for_each_entry(q, &all_q_list, all_q_node)
-		update_root_blkg_pd(q, blkiop->plid);
+		update_root_blkg_pd(q, blkiop);
 
 	blkcg_bypass_end();
 
@@ -765,7 +766,7 @@ void blkio_policy_unregister(struct blkio_policy_type *blkiop)
 	blkio_policy[blkiop->plid] = NULL;
 
 	list_for_each_entry(q, &all_q_list, all_q_node)
-		update_root_blkg_pd(q, blkiop->plid);
+		update_root_blkg_pd(q, blkiop);
 	blkcg_bypass_end();
 
 	mutex_unlock(&blkcg_pol_mutex);
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index f2ede76..49116d3 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -117,11 +117,12 @@ extern void blkio_policy_register(struct blkio_policy_type *);
 extern void blkio_policy_unregister(struct blkio_policy_type *);
 extern void blkg_destroy_all(struct request_queue *q, bool destroy_root);
 extern void update_root_blkg_pd(struct request_queue *q,
-				enum blkio_policy_id plid);
+				const struct blkio_policy_type *pol);
 
 void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
 		       u64 (*prfill)(struct seq_file *, void *, int),
-		       int pol, int data, bool show_total);
+		       const struct blkio_policy_type *pol, int data,
+		       bool show_total);
 u64 __blkg_prfill_u64(struct seq_file *sf, void *pdata, u64 v);
 u64 __blkg_prfill_rwstat(struct seq_file *sf, void *pdata,
 			 const struct blkg_rwstat *rwstat);
@@ -333,7 +334,7 @@ static inline void blkio_policy_unregister(struct blkio_policy_type *blkiop) { }
 static inline void blkg_destroy_all(struct request_queue *q,
 				    bool destory_root) { }
 static inline void update_root_blkg_pd(struct request_queue *q,
-				       enum blkio_policy_id plid) { }
+				       const struct blkio_policy_type *pol) { }
 
 static inline void *blkg_to_pdata(struct blkio_group *blkg,
 				struct blkio_policy_type *pol) { return NULL; }
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 6024014..07c17c2 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -946,7 +946,7 @@ static int tg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 
-	blkcg_print_blkgs(sf, blkcg, tg_prfill_cpu_rwstat, BLKIO_POLICY_THROTL,
+	blkcg_print_blkgs(sf, blkcg, tg_prfill_cpu_rwstat, &blkio_policy_throtl,
 			  cft->private, true);
 	return 0;
 }
@@ -973,7 +973,7 @@ static int tg_print_conf_u64(struct cgroup *cgrp, struct cftype *cft,
 			     struct seq_file *sf)
 {
 	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp), tg_prfill_conf_u64,
-			  BLKIO_POLICY_THROTL, cft->private, false);
+			  &blkio_policy_throtl, cft->private, false);
 	return 0;
 }
 
@@ -981,7 +981,7 @@ static int tg_print_conf_uint(struct cgroup *cgrp, struct cftype *cft,
 			      struct seq_file *sf)
 {
 	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp), tg_prfill_conf_uint,
-			  BLKIO_POLICY_THROTL, cft->private, false);
+			  &blkio_policy_throtl, cft->private, false);
 	return 0;
 }
 
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index cff8b5b..7980173 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1381,7 +1381,7 @@ static int cfqg_print_weight_device(struct cgroup *cgrp, struct cftype *cft,
 				    struct seq_file *sf)
 {
 	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp),
-			  cfqg_prfill_weight_device, BLKIO_POLICY_PROP, 0,
+			  cfqg_prfill_weight_device, &blkio_policy_cfq, 0,
 			  false);
 	return 0;
 }
@@ -1446,7 +1446,7 @@ static int cfqg_print_stat(struct cgroup *cgrp, struct cftype *cft,
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 
-	blkcg_print_blkgs(sf, blkcg, blkg_prfill_stat, BLKIO_POLICY_PROP,
+	blkcg_print_blkgs(sf, blkcg, blkg_prfill_stat, &blkio_policy_cfq,
 			  cft->private, false);
 	return 0;
 }
@@ -1456,7 +1456,7 @@ static int cfqg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 
-	blkcg_print_blkgs(sf, blkcg, blkg_prfill_rwstat, BLKIO_POLICY_PROP,
+	blkcg_print_blkgs(sf, blkcg, blkg_prfill_rwstat, &blkio_policy_cfq,
 			  cft->private, true);
 	return 0;
 }
@@ -1483,7 +1483,7 @@ static int cfqg_print_avg_queue_size(struct cgroup *cgrp, struct cftype *cft,
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 
 	blkcg_print_blkgs(sf, blkcg, cfqg_prfill_avg_queue_size,
-			  BLKIO_POLICY_PROP, 0, false);
+			  &blkio_policy_cfq, 0, false);
 	return 0;
 }
 #endif	/* CONFIG_DEBUG_BLK_CGROUP */
@@ -3939,7 +3939,7 @@ static void cfq_exit_queue(struct elevator_queue *e)
 #ifndef CONFIG_CFQ_GROUP_IOSCHED
 	kfree(cfqd->root_group);
 #endif
-	update_root_blkg_pd(q, BLKIO_POLICY_PROP);
+	update_root_blkg_pd(q, &blkio_policy_cfq);
 	kfree(cfqd);
 }
 
-- 
1.7.7.3
