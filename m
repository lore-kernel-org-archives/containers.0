From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 11/12] blkcg: implement blkg_prfill_[rw]stat_recursive()
Date: Fri, 14 Dec 2012 14:41:24 -0800
Message-ID: <1355524885-22719-12-git-send-email-tj__7059.05749132416$1355524995$gmane$org@kernel.org>
References: <1355524885-22719-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1355524885-22719-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

blkg_prfill_[rw]stat_recursive() collect the specified [rw]stats from
the target policy_data and its descendants and print it.  They can be
used to make stat printing hierarchical.

blkg_for_each_descendant_pre() and blkg_[rw]stat_collect() are added
to implement the new prfill functions.  While at it, function comment
is added to __blkg_lookup() which is now also used by the for_each
macro.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c | 129 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 block/blk-cgroup.h |   4 ++
 2 files changed, 133 insertions(+)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index fbf96ce..8e9caf0 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -32,6 +32,26 @@ EXPORT_SYMBOL_GPL(blkcg_root);
 
 static struct blkcg_policy *blkcg_policy[BLKCG_MAX_POLS];
 
+static struct blkcg_gq *__blkg_lookup(struct blkcg *blkcg,
+				      struct request_queue *q, bool update_hint);
+
+/**
+ * blkg_for_each_descendant_pre - pre-order walk of a blkg's descendants
+ * @d_blkg: loop cursor pointing to the current descendant
+ * @pos_cgrp: used for iteration
+ * @p_blkg: target blkg to walk descendants of
+ *
+ * Walk @c_blkg through the descendants of @p_blkg.  Must be used with RCU
+ * read locked.  If called under either blkcg or queue lock, the iteration
+ * is guaranteed to include all and only online blkgs.  The caller may
+ * update @pos_cgrp by calling cgroup_rightmost_descendant() to skip
+ * subtree.
+ */
+#define blkg_for_each_descendant_pre(d_blkg, pos_cgrp, p_blkg)		\
+	cgroup_for_each_descendant_pre((pos_cgrp), (p_blkg)->blkcg->css.cgroup) \
+		if (((d_blkg) = __blkg_lookup(cgroup_to_blkcg(pos_cgrp), \
+					      (p_blkg)->q, false)))
+
 static bool blkcg_policy_enabled(struct request_queue *q,
 				 const struct blkcg_policy *pol)
 {
@@ -127,6 +147,17 @@ err_free:
 	return NULL;
 }
 
+/**
+ * __blkg_lookup - internal version of blkg_lookup()
+ * @blkcg: blkcg of interest
+ * @q: request_queue of interest
+ * @update_hint: whether to update lookup hint with the result or not
+ *
+ * This is internal version and shouldn't be used by policy
+ * implementations.  Looks up blkgs for the @blkcg - @q pair regardless of
+ * @q's bypass state.  If @update_hint is %true, the caller should be
+ * holding @q->queue_lock and lookup hint is updated on success.
+ */
 static struct blkcg_gq *__blkg_lookup(struct blkcg *blkcg,
 				      struct request_queue *q, bool update_hint)
 {
@@ -568,6 +599,104 @@ u64 blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
 EXPORT_SYMBOL_GPL(blkg_prfill_rwstat);
 
 /**
+ * blkg_stat_collect - collect hierarchical blkg_stat
+ * @pd: policy private data of interest
+ * @off: offset to the blkg_stat in @pd
+ *
+ * Collect the blkg_stat specified by @off from @pd and all its descendants
+ * and return the sum.
+ */
+static u64 blkg_stat_collect(struct blkg_policy_data *pd, int off)
+{
+	struct blkcg_policy *pol = blkcg_policy[pd->plid];
+	struct blkcg_gq *pos_blkg;
+	struct cgroup *pos_cgrp;
+	u64 sum;
+
+	sum = blkg_stat_read((void *)pd + off);
+
+	rcu_read_lock();
+	blkg_for_each_descendant_pre(pos_blkg, pos_cgrp, pd_to_blkg(pd)) {
+		struct blkg_policy_data *pos_pd = blkg_to_pd(pos_blkg, pol);
+		struct blkg_stat *stat = (void *)pos_pd + off;
+
+		sum += blkg_stat_read(stat);
+	}
+	rcu_read_unlock();
+
+	return sum;
+}
+
+/**
+ * blkg_rwstat_collect - collect hierarchical blkg_rwstat
+ * @pd: policy private data of interest
+ * @off: offset to the blkg_stat in @pd
+ *
+ * Collect the blkg_rwstat specified by @off from @pd and all its
+ * descendants and return the sum.
+ */
+static struct blkg_rwstat blkg_rwstat_collect(struct blkg_policy_data *pd,
+					      int off)
+{
+	struct blkcg_policy *pol = blkcg_policy[pd->plid];
+	struct blkcg_gq *pos_blkg;
+	struct cgroup *pos_cgrp;
+	struct blkg_rwstat sum;
+	int i;
+
+	sum = blkg_rwstat_read((void *)pd + off);
+
+	rcu_read_lock();
+	blkg_for_each_descendant_pre(pos_blkg, pos_cgrp, pd_to_blkg(pd)) {
+		struct blkg_policy_data *pos_pd = blkg_to_pd(pos_blkg, pol);
+		struct blkg_rwstat *rwstat = (void *)pos_pd + off;
+		struct blkg_rwstat tmp;
+
+		tmp = blkg_rwstat_read(rwstat);
+
+		for (i = 0; i < BLKG_RWSTAT_NR; i++)
+			sum.cnt[i] += tmp.cnt[i];
+	}
+	rcu_read_unlock();
+
+	return sum;
+}
+
+/**
+ * blkg_prfill_stat_recursive - recursive prfill callback for blkg_stat
+ * @sf: seq_file to print to
+ * @pd: policy private data of interest
+ * @off: offset to the blkg_stat in @pd
+ *
+ * Recursive prfill callback for printing a blkg_stat.  Sums the blkg_stat
+ * specified by @off of @pd and its descendants and prints it.
+ */
+u64 blkg_prfill_stat_recursive(struct seq_file *sf,
+			       struct blkg_policy_data *pd, int off)
+{
+	return __blkg_prfill_u64(sf, pd, blkg_stat_collect(pd, off));
+}
+EXPORT_SYMBOL_GPL(blkg_prfill_stat_recursive);
+
+/**
+ * blkg_prfill_rwstat_recursive - recursive prfill callback for blkg_rwstat
+ * @sf: seq_file to print to
+ * @pd: policy private data of interest
+ * @off: offset to the blkg_rwstat in @pd
+ *
+ * Recursive prfill callback for printing a blkg_rwstat.  Sums the
+ * blkg_rwstat specified by @off of @pd and its descendants and prints it.
+ */
+u64 blkg_prfill_rwstat_recursive(struct seq_file *sf,
+				 struct blkg_policy_data *pd, int off)
+{
+	struct blkg_rwstat sum = blkg_rwstat_collect(pd, off);
+
+	return __blkg_prfill_rwstat(sf, pd, &sum);
+}
+EXPORT_SYMBOL_GPL(blkg_prfill_rwstat_recursive);
+
+/**
  * blkg_conf_prep - parse and prepare for per-blkg config update
  * @blkcg: target block cgroup
  * @pol: target policy
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 40f5b97..747bcc5 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -156,6 +156,10 @@ u64 __blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
 u64 blkg_prfill_stat(struct seq_file *sf, struct blkg_policy_data *pd, int off);
 u64 blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
 		       int off);
+u64 blkg_prfill_stat_recursive(struct seq_file *sf,
+			       struct blkg_policy_data *pd, int off);
+u64 blkg_prfill_rwstat_recursive(struct seq_file *sf,
+				 struct blkg_policy_data *pd, int off);
 
 struct blkg_conf_ctx {
 	struct gendisk			*disk;
-- 
1.7.11.7
