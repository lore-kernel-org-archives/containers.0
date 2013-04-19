From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 09/10] cpuset: allow to keep tasks in empty cpusets
Date: Fri, 19 Apr 2013 20:29:24 +0800
Message-ID: <517138A4.3070209__41159.8325394609$1366374638$gmane$org@huawei.com>
References: <517137A7.4020605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <517137A7.4020605-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 171 +++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 146 insertions(+), 25 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 741e652..95e9394 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -99,6 +99,9 @@ struct cpuset {
 	 */
 	nodemask_t old_mems_allowed;
 
+	/* used in cpuset_update_nodemask_workfn() */
+	struct ptr_heap *heap;
+
 	struct fmeter fmeter;		/* memory_pressure filter */
 
 	/*
@@ -114,6 +117,7 @@ struct cpuset {
 	int relax_domain_level;
 
 	struct work_struct hotplug_work;
+	struct work_struct update_nodemask_work;
 };
 
 /* Retrieve the cpuset for a cgroup */
@@ -276,6 +280,8 @@ static struct cpuset top_cpuset = {
 static DEFINE_MUTEX(cpuset_mutex);
 static DEFINE_MUTEX(callback_mutex);
 
+static struct workqueue_struct *cpuset_update_nodemask_wq;
+
 /*
  * CPU / memory hotplug is handled asynchronously.
  */
@@ -877,6 +883,39 @@ static void update_tasks_cpumask(struct cpuset *cs, struct ptr_heap *heap)
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
+
+		update_tasks_cpumask(cp, heap);
+	}
+	rcu_read_unlock();
+}
+
 /**
  * update_cpumask - update the cpus_allowed mask of a cpuset and all tasks in it
  * @cs: the cpuset to consider
@@ -928,11 +967,7 @@ static int update_cpumask(struct cpuset *cs, struct cpuset *trialcs,
 	cpumask_copy(cs->cpus_allowed, trialcs->cpus_allowed);
 	mutex_unlock(&callback_mutex);
 
-	/*
-	 * Scan tasks in the cpuset, and update the cpumasks of any
-	 * that need an update.
-	 */
-	update_tasks_cpumask(cs, &heap);
+	update_tasks_cpumask_hier(cs, true, &heap);
 
 	heap_free(&heap);
 
@@ -1099,6 +1134,78 @@ static void update_tasks_nodemask(struct cpuset *cs, struct ptr_heap *heap)
 	cpuset_being_rebound = NULL;
 }
 
+static void cpuset_update_nodemask_workfn(struct work_struct *work)
+{
+	struct cpuset *cs = container_of(work, struct cpuset,
+					update_nodemask_work);
+
+	update_tasks_nodemask(cs, cs->heap);
+	css_put(&cs->css);
+}
+
+static void schedule_update_tasks_nodemask(struct cpuset *cs,
+					   struct ptr_heap *heap)
+{
+	bool queued;
+
+	/* Will be released when the work item finishes executing. */
+	if (!css_tryget(&cs->css))
+		return;
+
+	/*
+	 * The caller will flush the workqueue with cpuset_mutex held,
+	 * so it's not possible a work item was already queued, and
+	 * we're sure cs->heap is valid.
+	 */
+	cs->heap = heap;
+	queued = queue_work(cpuset_update_nodemask_wq,
+			    &cs->update_nodemask_work);
+	if (queued) {
+		WARN_ON(1);
+		css_put(&cs->css);
+	}
+}
+
+/*
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
+
+		schedule_update_tasks_nodemask(cp, heap);
+	}
+	rcu_read_unlock();
+
+	/*
+	 * The only reason we use workqueue is update_tasks_nodemask() can't
+	 * be called in rcu_read_lock(). Flush the workqueue to make sure
+	 * all the updates are done before we return.
+	 */
+	flush_workqueue(cpuset_update_nodemask_wq);
+}
+
 /*
  * Handle user request to change the 'mems' memory placement
  * of a cpuset.  Needs to validate the request, update the
@@ -1163,7 +1270,7 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 	cs->mems_allowed = trialcs->mems_allowed;
 	mutex_unlock(&callback_mutex);
 
-	update_tasks_nodemask(cs, &heap);
+	update_tasks_nodemask_hier(cs, true, &heap);
 
 	heap_free(&heap);
 done:
@@ -1888,6 +1995,7 @@ static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cont)
 	nodes_clear(cs->mems_allowed);
 	fmeter_init(&cs->fmeter);
 	INIT_WORK(&cs->hotplug_work, cpuset_propagate_hotplug_workfn);
+	INIT_WORK(&cs->update_nodemask_work, cpuset_update_nodemask_workfn);
 	cs->relax_domain_level = -1;
 
 	return &cs->css;
@@ -2063,31 +2171,36 @@ static void cpuset_propagate_hotplug_workfn(struct work_struct *work)
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
 
-		if (!cpumask_empty(cs->cpus_allowed))
-			update_tasks_cpumask(cs, NULL);
-	}
+	/*
+	 * If sane_behavior flag is set, we need to update tasks' cpumask
+	 * for empy cpuset to take on ancestor's cpumask
+	 */
+	if ((sane && cpumask_empty(cs->cpus_allowed)) ||
+	    (!cpumask_empty(&off_cpus) && !cpumask_empty(cs->cpus_allowed)))
+		update_tasks_cpumask(cs, NULL);
 
-	/* remove offline mems from @cs */
-	if (!nodes_empty(off_mems)) {
-		mutex_lock(&callback_mutex);
-		nodes_andnot(cs->mems_allowed, cs->mems_allowed, off_mems);
-		mutex_unlock(&callback_mutex);
+	mutex_lock(&callback_mutex);
+	nodes_andnot(cs->mems_allowed, cs->mems_allowed, off_mems);
+	mutex_unlock(&callback_mutex);
 
-		if (!nodes_empty(cs->mems_allowed))
-			update_tasks_nodemask(cs, NULL);
-	}
+	/*
+	 * If sane_behavior flag is set, we need to update tasks' nodemask
+	 * for empy cpuset to take on ancestor's nodemask
+	 */
+	if ((sane && nodes_empty(cs->mems_allowed)) ||
+	    (!nodes_empty(off_mems) && !nodes_empty(cs->mems_allowed)))
+		update_tasks_nodemask(cs, NULL);
 
 	is_empty = cpumask_empty(cs->cpus_allowed) ||
 		nodes_empty(cs->mems_allowed);
@@ -2095,11 +2208,13 @@ static void cpuset_propagate_hotplug_workfn(struct work_struct *work)
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
@@ -2174,6 +2289,7 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 		cpumask_copy(top_cpuset.cpus_allowed, &new_cpus);
 		mutex_unlock(&callback_mutex);
 		/* we don't mess with cpumasks of tasks in top_cpuset */
+		update_tasks_cpumask_hier(&top_cpuset, false, NULL);
 	}
 
 	/* synchronize mems_allowed to N_MEMORY */
@@ -2182,6 +2298,7 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 		top_cpuset.mems_allowed = new_mems;
 		mutex_unlock(&callback_mutex);
 		update_tasks_nodemask(&top_cpuset, NULL);
+		update_tasks_nodemask_hier(&top_cpuset, false, NULL);
 	}
 
 	/* if cpus or mems went down, we need to propagate to descendants */
@@ -2261,6 +2378,10 @@ void __init cpuset_init_smp(void)
 	cpuset_propagate_hotplug_wq =
 		alloc_ordered_workqueue("cpuset_hotplug", 0);
 	BUG_ON(!cpuset_propagate_hotplug_wq);
+
+	cpuset_update_nodemask_wq =
+		create_workqueue("cpuset_update_nodemask");
+	BUG_ON(!cpuset_update_nodemask_wq);
 }
 
 /**
-- 
1.8.0.2
