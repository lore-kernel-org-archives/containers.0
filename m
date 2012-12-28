From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 17/24] blkcg: implement blkcg_policy->on/offline_pd_fn() and
	blkcg_gq->online
Date: Fri, 28 Dec 2012 12:35:39 -0800
Message-ID: <1356726946-26037-18-git-send-email-tj@kernel.org>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1356726946-26037-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Add two blkcg_policy methods, ->online_pd_fn() and ->offline_pd_fn(),
which are invoked as the policy_data gets activated and deactivated
while holding both blkcg and q locks.

Also, add blkcg_gq->online bool, which is set and cleared as the
blkcg_gq gets activated and deactivated.  This flag also is toggled
while holding both blkcg and q locks.

These will be used to implement hierarchical stats.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c | 21 ++++++++++++++++++++-
 block/blk-cgroup.h |  7 +++++++
 2 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 3a8de32..4d625d2 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -182,7 +182,7 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 				    struct blkcg_gq *new_blkg)
 {
 	struct blkcg_gq *blkg;
-	int ret;
+	int i, ret;
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
 	lockdep_assert_held(q->queue_lock);
@@ -218,7 +218,15 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 	if (likely(!ret)) {
 		hlist_add_head_rcu(&blkg->blkcg_node, &blkcg->blkg_list);
 		list_add(&blkg->q_node, &q->blkg_list);
+
+		for (i = 0; i < BLKCG_MAX_POLS; i++) {
+			struct blkcg_policy *pol = blkcg_policy[i];
+
+			if (blkg->pd[i] && pol->pd_online_fn)
+				pol->pd_online_fn(blkg);
+		}
 	}
+	blkg->online = true;
 	spin_unlock(&blkcg->lock);
 
 	if (!ret)
@@ -291,6 +299,7 @@ EXPORT_SYMBOL_GPL(blkg_lookup_create);
 static void blkg_destroy(struct blkcg_gq *blkg)
 {
 	struct blkcg *blkcg = blkg->blkcg;
+	int i;
 
 	lockdep_assert_held(blkg->q->queue_lock);
 	lockdep_assert_held(&blkcg->lock);
@@ -299,6 +308,14 @@ static void blkg_destroy(struct blkcg_gq *blkg)
 	WARN_ON_ONCE(list_empty(&blkg->q_node));
 	WARN_ON_ONCE(hlist_unhashed(&blkg->blkcg_node));
 
+	for (i = 0; i < BLKCG_MAX_POLS; i++) {
+		struct blkcg_policy *pol = blkcg_policy[i];
+
+		if (blkg->pd[i] && pol->pd_offline_fn)
+			pol->pd_offline_fn(blkg);
+	}
+	blkg->online = false;
+
 	radix_tree_delete(&blkcg->blkg_tree, blkg->q->id);
 	list_del_init(&blkg->q_node);
 	hlist_del_init_rcu(&blkg->blkcg_node);
@@ -956,6 +973,8 @@ void blkcg_deactivate_policy(struct request_queue *q,
 		/* grab blkcg lock too while removing @pd from @blkg */
 		spin_lock(&blkg->blkcg->lock);
 
+		if (pol->pd_offline_fn)
+			pol->pd_offline_fn(blkg);
 		if (pol->pd_exit_fn)
 			pol->pd_exit_fn(blkg);
 
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 40f5b97..678e89e 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -106,12 +106,17 @@ struct blkcg_gq {
 	/* reference count */
 	int				refcnt;
 
+	/* is this blkg online? protected by both blkcg and q locks */
+	bool				online;
+
 	struct blkg_policy_data		*pd[BLKCG_MAX_POLS];
 
 	struct rcu_head			rcu_head;
 };
 
 typedef void (blkcg_pol_init_pd_fn)(struct blkcg_gq *blkg);
+typedef void (blkcg_pol_online_pd_fn)(struct blkcg_gq *blkg);
+typedef void (blkcg_pol_offline_pd_fn)(struct blkcg_gq *blkg);
 typedef void (blkcg_pol_exit_pd_fn)(struct blkcg_gq *blkg);
 typedef void (blkcg_pol_reset_pd_stats_fn)(struct blkcg_gq *blkg);
 
@@ -124,6 +129,8 @@ struct blkcg_policy {
 
 	/* operations */
 	blkcg_pol_init_pd_fn		*pd_init_fn;
+	blkcg_pol_online_pd_fn		*pd_online_fn;
+	blkcg_pol_offline_pd_fn		*pd_offline_fn;
 	blkcg_pol_exit_pd_fn		*pd_exit_fn;
 	blkcg_pol_reset_pd_stats_fn	*pd_reset_stats_fn;
 };
-- 
1.8.0.2
