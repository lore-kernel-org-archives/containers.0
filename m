From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/11] blkcg: kill blkio_list and replace blkio_list_lock with
	a mutex
Date: Fri, 13 Apr 2012 13:11:26 -0700
Message-ID: <1334347895-6268-3-git-send-email-tj@kernel.org>
References: <1334347895-6268-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1334347895-6268-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

With blkio_policy[], blkio_list is redundant and hinders with
per-queue policy activation.  Remove it.  Also, replace
blkio_list_lock with a mutex blkcg_pol_mutex and let it protect the
whole [un]registration.

This is to prepare for per-queue policy activation and doesn't cause
any functional difference.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c |   32 +++++++++++++++++---------------
 block/blk-cgroup.h |    1 -
 2 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 9449c38..af665fe 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -24,9 +24,7 @@
 
 #define MAX_KEY_LEN 100
 
-static DEFINE_SPINLOCK(blkio_list_lock);
-static LIST_HEAD(blkio_list);
-
+static DEFINE_MUTEX(blkcg_pol_mutex);
 static DEFINE_MUTEX(all_q_mutex);
 static LIST_HEAD(all_q_list);
 
@@ -311,8 +309,9 @@ blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgroup);
 	struct blkio_group *blkg;
 	struct hlist_node *n;
+	int i;
 
-	spin_lock(&blkio_list_lock);
+	mutex_lock(&blkcg_pol_mutex);
 	spin_lock_irq(&blkcg->lock);
 
 	/*
@@ -321,15 +320,16 @@ blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 	 * anyway.  If you get hit by a race, retry.
 	 */
 	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node) {
-		struct blkio_policy_type *pol;
+		for (i = 0; i < BLKIO_NR_POLICIES; i++) {
+			struct blkio_policy_type *pol = blkio_policy[i];
 
-		list_for_each_entry(pol, &blkio_list, list)
-			if (pol->ops.blkio_reset_group_stats_fn)
+			if (pol && pol->ops.blkio_reset_group_stats_fn)
 				pol->ops.blkio_reset_group_stats_fn(blkg);
+		}
 	}
 
 	spin_unlock_irq(&blkcg->lock);
-	spin_unlock(&blkio_list_lock);
+	mutex_unlock(&blkcg_pol_mutex);
 	return 0;
 }
 
@@ -732,20 +732,21 @@ void blkio_policy_register(struct blkio_policy_type *blkiop)
 {
 	struct request_queue *q;
 
+	mutex_lock(&blkcg_pol_mutex);
+
 	blkcg_bypass_start();
-	spin_lock(&blkio_list_lock);
 
 	BUG_ON(blkio_policy[blkiop->plid]);
 	blkio_policy[blkiop->plid] = blkiop;
-	list_add_tail(&blkiop->list, &blkio_list);
-
-	spin_unlock(&blkio_list_lock);
 	list_for_each_entry(q, &all_q_list, all_q_node)
 		update_root_blkg_pd(q, blkiop->plid);
+
 	blkcg_bypass_end();
 
 	if (blkiop->cftypes)
 		WARN_ON(cgroup_add_cftypes(&blkio_subsys, blkiop->cftypes));
+
+	mutex_unlock(&blkcg_pol_mutex);
 }
 EXPORT_SYMBOL_GPL(blkio_policy_register);
 
@@ -753,19 +754,20 @@ void blkio_policy_unregister(struct blkio_policy_type *blkiop)
 {
 	struct request_queue *q;
 
+	mutex_lock(&blkcg_pol_mutex);
+
 	if (blkiop->cftypes)
 		cgroup_rm_cftypes(&blkio_subsys, blkiop->cftypes);
 
 	blkcg_bypass_start();
-	spin_lock(&blkio_list_lock);
 
 	BUG_ON(blkio_policy[blkiop->plid] != blkiop);
 	blkio_policy[blkiop->plid] = NULL;
-	list_del_init(&blkiop->list);
 
-	spin_unlock(&blkio_list_lock);
 	list_for_each_entry(q, &all_q_list, all_q_node)
 		update_root_blkg_pd(q, blkiop->plid);
 	blkcg_bypass_end();
+
+	mutex_unlock(&blkcg_pol_mutex);
 }
 EXPORT_SYMBOL_GPL(blkio_policy_unregister);
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 64392ac..c772581 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -102,7 +102,6 @@ struct blkio_policy_ops {
 };
 
 struct blkio_policy_type {
-	struct list_head list;
 	struct blkio_policy_ops ops;
 	enum blkio_policy_id plid;
 	size_t pdata_size;		/* policy specific private data size */
-- 
1.7.7.3
