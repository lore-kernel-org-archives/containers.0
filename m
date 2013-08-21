From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 04/11] cpuset: update cs->real_{cpus, mems}_allowed when config
	changes
Date: Wed, 21 Aug 2013 17:59:32 +0800
Message-ID: <52148F84.9050309__46164.7713942968$1377079203$gmane$org@huawei.com>
References: <52148F52.0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <52148F52.0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

We're going to have separate user-configured masks and effective ones.

At last configured masks can only be changed by writing cpuset.cpus
and cpuset.mems, and they won't be restricted by parent cpuset. While
effective masks reflect cpu/memory hotplug and hierachical restriction.

This is a preparation to make real_{cpus,mems}_allowed to be effective
masks of the cpuset:

- change the effective masks at hotplug: done
- change the effective masks at config change: done
- take on ancestor's mask when the effective mask is empty: todo

This won't introduce behavior change.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 115 ++++++++++++++++++++++++++++++++------------------------
 1 file changed, 66 insertions(+), 49 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index ab89c1e..72afef4 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -880,39 +880,49 @@ static void update_tasks_cpumask(struct cpuset *cs, struct ptr_heap *heap)
 	css_scan_tasks(&cs->css, NULL, cpuset_change_cpumask, cs, heap);
 }
 
-/*
- * update_tasks_cpumask_hier - Update the cpumasks of tasks in the hierarchy.
- * @root_cs: the root cpuset of the hierarchy
- * @update_root: update root cpuset or not?
+/**
+ * update_cpumasks_hier - Update effective cpumasks and tasks in the subtree
+ * @cs: the cpuset to consider
+ * @trialcs: the trial cpuset
  * @heap: the heap used by css_scan_tasks()
  *
- * This will update cpumasks of tasks in @root_cs and all other empty cpusets
- * which take on cpumask of @root_cs.
- *
- * Called with cpuset_mutex held
+ * When configured cpumask is changed, the effective cpumasks of this cpuset
+ * and all its descendants need to be updated.
  */
-static void update_tasks_cpumask_hier(struct cpuset *root_cs,
-				      bool update_root, struct ptr_heap *heap)
+static void update_cpumasks_hier(struct cpuset *cs, struct cpuset *trialcs,
+				 struct ptr_heap *heap)
 {
-	struct cpuset *cp;
 	struct cgroup_subsys_state *pos_css;
+	struct cpuset *cp;
 
 	rcu_read_lock();
-	cpuset_for_each_descendant_pre(cp, pos_css, root_cs) {
-		if (cp == root_cs) {
-			if (!update_root)
-				continue;
-		} else {
-			/* skip the whole subtree if @cp have some CPU */
-			if (!cpumask_empty(cp->cpus_allowed)) {
-				pos_css = css_rightmost_descendant(pos_css);
-				continue;
-			}
+	cpuset_for_each_descendant_pre(cp, pos_css, cs) {
+		struct cpuset *parent = parent_cs(cs);
+		struct cpumask *new_cpus = trialcs->real_cpus_allowed;
+
+		cpumask_and(new_cpus, cp->cpus_allowed,
+			    parent->real_cpus_allowed);
+
+		/*
+		 * Skip the whole subtree if the cpumask is not changed, unless
+		 * it's empty, and in this case we need to update tasks to take
+		 * on an ancestor's cpumask.
+		 */
+		if (cpumask_equal(new_cpus, cp->real_cpus_allowed) &&
+		    ((cp == cs) || !cpumask_empty(new_cpus))) {
+			pos_css = css_rightmost_descendant(pos_css);
+			continue;
 		}
+
 		if (!css_tryget(&cp->css))
 			continue;
+
 		rcu_read_unlock();
 
+		mutex_lock(&callback_mutex);
+		cpumask_copy(cp->real_cpus_allowed, new_cpus);
+		mutex_unlock(&callback_mutex);
+
 		update_tasks_cpumask(cp, heap);
 
 		rcu_read_lock();
@@ -931,7 +941,6 @@ static int update_cpumask(struct cpuset *cs, struct cpuset *trialcs,
 {
 	struct ptr_heap heap;
 	int retval;
-	int is_load_balanced;
 
 	/* top_cpuset.cpus_allowed tracks cpu_online_mask; it's read-only */
 	if (cs == &top_cpuset)
@@ -966,17 +975,15 @@ static int update_cpumask(struct cpuset *cs, struct cpuset *trialcs,
 	if (retval)
 		return retval;
 
-	is_load_balanced = is_sched_load_balance(trialcs);
-
 	mutex_lock(&callback_mutex);
 	cpumask_copy(cs->cpus_allowed, trialcs->cpus_allowed);
 	mutex_unlock(&callback_mutex);
 
-	update_tasks_cpumask_hier(cs, true, &heap);
+	update_cpumasks_hier(cs, trialcs, &heap);
 
 	heap_free(&heap);
 
-	if (is_load_balanced)
+	if (is_sched_load_balance(cs))
 		rebuild_sched_domains_locked();
 	return 0;
 }
@@ -1137,40 +1144,50 @@ static void update_tasks_nodemask(struct cpuset *cs, struct ptr_heap *heap)
 	cpuset_being_rebound = NULL;
 }
 
-/*
- * update_tasks_nodemask_hier - Update the nodemasks of tasks in the hierarchy.
- * @cs: the root cpuset of the hierarchy
- * @update_root: update the root cpuset or not?
+/**
+ * update_nodesmasks_hier - Update effective nodemasks and tasks in the subtree
+ * @cs: the cpuset to consider
+ * @trialcs: the trial cpuset
  * @heap: the heap used by css_scan_tasks()
  *
- * This will update nodemasks of tasks in @root_cs and all other empty cpusets
- * which take on nodemask of @root_cs.
- *
- * Called with cpuset_mutex held
+ * When configured nodemask is changed, the effective nodemasks of this cpuset
+ * and all its descendants need to be updated.
  */
-static void update_tasks_nodemask_hier(struct cpuset *root_cs,
-				       bool update_root, struct ptr_heap *heap)
+static void update_nodemasks_hier(struct cpuset *cs, struct cpuset *trialcs,
+				 struct ptr_heap *heap)
 {
-	struct cpuset *cp;
 	struct cgroup_subsys_state *pos_css;
+	struct cpuset *cp;
 
 	rcu_read_lock();
-	cpuset_for_each_descendant_pre(cp, pos_css, root_cs) {
-		if (cp == root_cs) {
-			if (!update_root)
-				continue;
-		} else {
-			/* skip the whole subtree if @cp have some CPU */
-			if (!nodes_empty(cp->mems_allowed)) {
-				pos_css = css_rightmost_descendant(pos_css);
-				continue;
-			}
+	cpuset_for_each_descendant_pre(cp, pos_css, cs) {
+		struct cpuset *parent = parent_cs(cs);
+		nodemask_t *new_mems = &trialcs->real_mems_allowed;
+
+		nodes_and(*new_mems, cp->mems_allowed,
+			  parent->real_mems_allowed);
+
+		/*
+		 * Skip the whole subtree if the nodemask is not changed, unless
+		 * it's empty, and in this case we need to update tasks to take
+		 * on an ancestor's nodemask.
+		 */
+		if (nodes_equal(*new_mems, cp->real_mems_allowed) &&
+		    ((cp == cs) || !nodes_empty(*new_mems))) {
+			pos_css = css_rightmost_descendant(pos_css);
+			continue;
 		}
+
 		if (!css_tryget(&cp->css))
 			continue;
+
 		rcu_read_unlock();
 
-		update_tasks_nodemask(cp, heap);
+		mutex_lock(&callback_mutex);
+		cp->real_mems_allowed = *new_mems;
+		mutex_unlock(&callback_mutex);
+
+		update_tasks_cpumask(cs, heap);
 
 		rcu_read_lock();
 		css_put(&cp->css);
@@ -1242,7 +1259,7 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 	cs->mems_allowed = trialcs->mems_allowed;
 	mutex_unlock(&callback_mutex);
 
-	update_tasks_nodemask_hier(cs, true, &heap);
+	update_nodemasks_hier(cs, trialcs, &heap);
 
 	heap_free(&heap);
 done:
-- 
1.8.0.2
