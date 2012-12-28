From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 23/24] cfq-iosched: collect stats from dead cfqgs
Date: Fri, 28 Dec 2012 12:35:45 -0800
Message-ID: <1356726946-26037-24-git-send-email-tj__23624.5900778615$1356727132$gmane$org@kernel.org>
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

To support hierarchical stats, it's necessary to remember stats from
dead children.  Add cfqg->dead_stats and make a dying cfqg transfer
its stats to the parent's dead-stats.

The transfer happens form ->pd_offline_fn() and it is possible that
there are some residual IOs completing afterwards.  Currently, we lose
these stats.  Given that cgroup removal isn't a very high frequency
operation and the amount of residual IOs on offline are likely to be
nil or small, this shouldn't be a big deal and the complexity needed
to handle residual IOs - another callback and rather elaborate
synchronization to reach and lock the matching q - doesn't seem
justified.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/cfq-iosched.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 56 insertions(+), 1 deletion(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index f8b34bb..4d75b79 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -289,7 +289,8 @@ struct cfq_group {
 	/* number of requests that are on the dispatch list or inside driver */
 	int dispatched;
 	struct cfq_ttime ttime;
-	struct cfqg_stats stats;
+	struct cfqg_stats stats;	/* stats for this cfqg */
+	struct cfqg_stats dead_stats;	/* stats pushed from dead children */
 };
 
 struct cfq_io_cq {
@@ -709,6 +710,47 @@ static void cfqg_stats_reset(struct cfqg_stats *stats)
 #endif
 }
 
+/* @to += @from */
+static void cfqg_stats_merge(struct cfqg_stats *to, struct cfqg_stats *from)
+{
+	/* queued stats shouldn't be cleared */
+	blkg_rwstat_merge(&to->service_bytes, &from->service_bytes);
+	blkg_rwstat_merge(&to->serviced, &from->serviced);
+	blkg_rwstat_merge(&to->merged, &from->merged);
+	blkg_rwstat_merge(&to->service_time, &from->service_time);
+	blkg_rwstat_merge(&to->wait_time, &from->wait_time);
+	blkg_stat_merge(&from->time, &from->time);
+#ifdef CONFIG_DEBUG_BLK_CGROUP
+	blkg_stat_merge(&to->unaccounted_time, &from->unaccounted_time);
+	blkg_stat_merge(&to->avg_queue_size_sum, &from->avg_queue_size_sum);
+	blkg_stat_merge(&to->avg_queue_size_samples, &from->avg_queue_size_samples);
+	blkg_stat_merge(&to->dequeue, &from->dequeue);
+	blkg_stat_merge(&to->group_wait_time, &from->group_wait_time);
+	blkg_stat_merge(&to->idle_time, &from->idle_time);
+	blkg_stat_merge(&to->empty_time, &from->empty_time);
+#endif
+}
+
+/*
+ * Transfer @cfqg's stats to its parent's dead_stats so that the ancestors'
+ * recursive stats can still account for the amount used by this cfqg after
+ * it's gone.
+ */
+static void cfqg_stats_xfer_dead(struct cfq_group *cfqg)
+{
+	struct cfq_group *parent = cfqg_parent(cfqg);
+
+	lockdep_assert_held(cfqg_to_blkg(cfqg)->q->queue_lock);
+
+	if (unlikely(!parent))
+		return;
+
+	cfqg_stats_merge(&parent->dead_stats, &cfqg->stats);
+	cfqg_stats_merge(&parent->dead_stats, &cfqg->dead_stats);
+	cfqg_stats_reset(&cfqg->stats);
+	cfqg_stats_reset(&cfqg->dead_stats);
+}
+
 #else	/* CONFIG_CFQ_GROUP_IOSCHED */
 
 static inline struct cfq_group *cfqg_parent(struct cfq_group *cfqg) { return NULL; }
@@ -1475,11 +1517,23 @@ static void cfq_pd_init(struct blkcg_gq *blkg)
 	cfqg->leaf_weight = blkg->blkcg->cfq_leaf_weight;
 }
 
+static void cfq_pd_offline(struct blkcg_gq *blkg)
+{
+	/*
+	 * @blkg is going offline and will be ignored by
+	 * blkg_[rw]stat_recursive_sum().  Transfer stats to the parent so
+	 * that they don't get lost.  If IOs complete after this point, the
+	 * stats for them will be lost.  Oh well...
+	 */
+	cfqg_stats_xfer_dead(blkg_to_cfqg(blkg));
+}
+
 static void cfq_pd_reset_stats(struct blkcg_gq *blkg)
 {
 	struct cfq_group *cfqg = blkg_to_cfqg(blkg);
 
 	cfqg_stats_reset(&cfqg->stats);
+	cfqg_stats_reset(&cfqg->dead_stats);
 }
 
 /*
@@ -4408,6 +4462,7 @@ static struct blkcg_policy blkcg_policy_cfq = {
 	.cftypes		= cfq_blkcg_files,
 
 	.pd_init_fn		= cfq_pd_init,
+	.pd_offline_fn		= cfq_pd_offline,
 	.pd_reset_stats_fn	= cfq_pd_reset_stats,
 };
 #endif
-- 
1.8.0.2
