From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 08/10] cpuset: allow to keep tasks in empty cpusets
Date: Wed, 5 Jun 2013 17:16:59 +0800
Message-ID: <51AF020B.3030701@huawei.com>
References: <51AF0183.8070602@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51AF0183.8070602-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

To achieve this:

- We call update_tasks_cpumask/nodemask() for empty cpusets when
hotplug happens, instead of moving tasks out of them.

- When a cpuset's masks are changed by writing cpuset.cpus/mems,
we also update tasks in child cpusets which are empty.

v2:

- drop rcu_read_lock before calling update_task_nodemask() and
  update_task_cpumask(), instead of using workqueue.

- add documentation in include/linux/cgroup.h

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/linux/cgroup.h |   4 ++
 kernel/cpuset.c        | 137 +++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 120 insertions(+), 21 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index d0ad379..53e81a6 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -277,6 +277,10 @@ enum {
 	 *
 	 * - Remount is disallowed.
 	 *
+	 * - cpuset: tasks will be kept in empty cpusets when hotplug happens
+	 *   and take masks of ancestors with non-empty cpus/mems, instead of
+	 *   being moved to an ancestor.
+	 *
 	 * - memcg: use_hierarchy is on by default and the cgroup file for
 	 *   the flag is not created.
 	 *
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 5252f94..3b93098 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -878,6 +878,49 @@ static void update_tasks_cpumask(struct cpuset *cs, struct ptr_heap *heap)
 	cgroup_scan_tasks(&scan);
 }
 
+/*
+ * update_tasks_cpumask_hier - Update the cpumasks of tasks in the hierarchy.
+ * @root_cs: the root cpuset of the hierarchy
+ * @update_root: update root cpuset or not?
+ * @heap: the heap used by cgroup_scan_tasks()
+ *
+ * This will update cpumasks of tasks in @root_cs and all other empty cpusets
+ * which take on cpumask of @root_cs.
+ *
+ * Called with cpuset_mutex held
+ */
+static void update_tasks_cpumask_hier(struct cpuset *root_cs,
+				      bool update_root, struct ptr_heap *heap)
+{
+	struct cpuset *cp;
+	struct cgroup *pos_cgrp;
+
+	if (update_root)
+		update_tasks_cpumask(root_cs, heap);
+
+	rcu_read_lock();
+	cpuset_for_each_descendant_pre(cp, pos_cgrp, root_cs) {
+		/* skip the whole subtree if @cp have some CPU */
+		if (!cpumask_empty(cp->cpus_allowed)) {
+			pos_cgrp = cgroup_rightmost_descendant(pos_cgrp);
+			continue;
+		}
+		if (!css_tryget(&cp->css))
+			continue;
+		rcu_read_unlock();
+
+		update_tasks_cpumask(cp, heap);
+
+		rcu_read_lock();
+		/*
+		 * We should acquire rcu_read_lock first, so it's still
+		 * valid to access @cp after dropping the css refcnt.
+		 */
+		css_put(&cp->css);
+	}
+	rcu_read_unlock();
+}
+
 /**
  * update_cpumask - update the cpus_allowed mask of a cpuset and all tasks in it
  * @cs: the cpuset to consider
@@ -929,11 +972,7 @@ static int update_cpumask(struct cpuset *cs, struct cpuset *trialcs,
 	cpumask_copy(cs->cpus_allowed, trialcs->cpus_allowed);
 	mutex_unlock(&callback_mutex);
 
-	/*
-	 * Scan tasks in the cpuset, and update the cpumasks of any
-	 * that need an update.
-	 */
-	update_tasks_cpumask(cs, &heap);
+	update_tasks_cpumask_hier(cs, true, &heap);
 
 	heap_free(&heap);
 
@@ -1101,6 +1140,49 @@ static void update_tasks_nodemask(struct cpuset *cs, struct ptr_heap *heap)
 }
 
 /*
+ * update_tasks_nodemask_hier - Update the nodemasks of tasks in the hierarchy.
+ * @cs: the root cpuset of the hierarchy
+ * @update_root: update the root cpuset or not?
+ * @heap: the heap used by cgroup_scan_tasks()
+ *
+ * This will update nodemasks of tasks in @root_cs and all other empty cpusets
+ * which take on nodemask of @root_cs.
+ *
+ * Called with cpuset_mutex held
+ */
+static void update_tasks_nodemask_hier(struct cpuset *root_cs,
+				       bool update_root, struct ptr_heap *heap)
+{
+	struct cpuset *cp;
+	struct cgroup *pos_cgrp;
+
+	if (update_root)
+		update_tasks_nodemask(root_cs, heap);
+
+	rcu_read_lock();
+	cpuset_for_each_descendant_pre(cp, pos_cgrp, root_cs) {
+		/* skip the whole subtree if @cp have some CPU */
+		if (!nodes_empty(cp->mems_allowed)) {
+			pos_cgrp = cgroup_rightmost_descendant(pos_cgrp);
+			continue;
+		}
+		if (!css_tryget(&cp->css))
+			continue;
+		rcu_read_unlock();
+
+		update_tasks_nodemask(cp, heap);
+
+		rcu_read_lock();
+		/*
+		 * We should acquire rcu_read_lock first, so it's still
+		 * valid to access @cp after dropping the css refcnt.
+		 */
+		css_put(&cp->css);
+	}
+	rcu_read_unlock();
+}
+
+/*
  * Handle user request to change the 'mems' memory placement
  * of a cpuset.  Needs to validate the request, update the
  * cpusets mems_allowed, and for each task in the cpuset,
@@ -1164,7 +1246,7 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 	cs->mems_allowed = trialcs->mems_allowed;
 	mutex_unlock(&callback_mutex);
 
-	update_tasks_nodemask(cs, &heap);
+	update_tasks_nodemask_hier(cs, true, &heap);
 
 	heap_free(&heap);
 done:
@@ -2064,27 +2146,36 @@ static void cpuset_propagate_hotplug_workfn(struct work_struct *work)
 	static nodemask_t off_mems;
 	struct cpuset *cs = container_of(work, struct cpuset, hotplug_work);
 	bool is_empty;
+	bool sane = cgroup_sane_behavior(cs->css.cgroup);
 
 	mutex_lock(&cpuset_mutex);
 
 	cpumask_andnot(&off_cpus, cs->cpus_allowed, top_cpuset.cpus_allowed);
 	nodes_andnot(off_mems, cs->mems_allowed, top_cpuset.mems_allowed);
 
-	/* remove offline cpus from @cs */
-	if (!cpumask_empty(&off_cpus)) {
-		mutex_lock(&callback_mutex);
-		cpumask_andnot(cs->cpus_allowed, cs->cpus_allowed, &off_cpus);
-		mutex_unlock(&callback_mutex);
+	mutex_lock(&callback_mutex);
+	cpumask_andnot(cs->cpus_allowed, cs->cpus_allowed, &off_cpus);
+	mutex_unlock(&callback_mutex);
+
+	/*
+	 * If sane_behavior flag is set, we need to update tasks' cpumask
+	 * for empty cpuset to take on ancestor's cpumask
+	 */
+	if ((sane && cpumask_empty(cs->cpus_allowed)) ||
+	    !cpumask_empty(&off_cpus))
 		update_tasks_cpumask(cs, NULL);
-	}
 
-	/* remove offline mems from @cs */
-	if (!nodes_empty(off_mems)) {
-		mutex_lock(&callback_mutex);
-		nodes_andnot(cs->mems_allowed, cs->mems_allowed, off_mems);
-		mutex_unlock(&callback_mutex);
+	mutex_lock(&callback_mutex);
+	nodes_andnot(cs->mems_allowed, cs->mems_allowed, off_mems);
+	mutex_unlock(&callback_mutex);
+
+	/*
+	 * If sane_behavior flag is set, we need to update tasks' nodemask
+	 * for empty cpuset to take on ancestor's nodemask
+	 */
+	if ((sane && nodes_empty(cs->mems_allowed)) ||
+	    !nodes_empty(off_mems))
 		update_tasks_nodemask(cs, NULL);
-	}
 
 	is_empty = cpumask_empty(cs->cpus_allowed) ||
 		nodes_empty(cs->mems_allowed);
@@ -2092,11 +2183,13 @@ static void cpuset_propagate_hotplug_workfn(struct work_struct *work)
 	mutex_unlock(&cpuset_mutex);
 
 	/*
-	 * If @cs became empty, move tasks to the nearest ancestor with
-	 * execution resources.  This is full cgroup operation which will
+	 * If sane_behavior flag is set, we'll keep tasks in empty cpusets.
+	 *
+	 * Otherwise move tasks to the nearest ancestor with execution
+	 *  resources.  This is full cgroup operation which will
 	 * also call back into cpuset.  Should be done outside any lock.
 	 */
-	if (is_empty)
+	if (!sane && is_empty)
 		remove_tasks_in_empty_cpuset(cs);
 
 	/* the following may free @cs, should be the last operation */
@@ -2171,6 +2264,7 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 		cpumask_copy(top_cpuset.cpus_allowed, &new_cpus);
 		mutex_unlock(&callback_mutex);
 		/* we don't mess with cpumasks of tasks in top_cpuset */
+		update_tasks_cpumask_hier(&top_cpuset, false, NULL);
 	}
 
 	/* synchronize mems_allowed to N_MEMORY */
@@ -2179,6 +2273,7 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 		top_cpuset.mems_allowed = new_mems;
 		mutex_unlock(&callback_mutex);
 		update_tasks_nodemask(&top_cpuset, NULL);
+		update_tasks_nodemask_hier(&top_cpuset, false, NULL);
 	}
 
 	/* if cpus or mems went down, we need to propagate to descendants */
-- 
1.8.0.2
