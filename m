From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 07/10] cpuset: record old_mems_allowed in struct cpuset
Date: Fri, 19 Apr 2013 20:28:20 +0800
Message-ID: <51713864.2030204__14674.4228354239$1366374529$gmane$org@huawei.com>
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

When we update a cpuset's mems_allowed and thus update tasks'
mems_allowed, it's required to pass the old mems_allowed and new
mems_allowed to cpuset_migrate_mm().

Currently we save old mems_allowed in a temp local variable before
changing cpuset->mems_allowed. This patch changes it by saving
old mems_allowed in cpuset->old_mems_allowed.

This currently won't change any behavior, but it will later allow
us to keep tasks in empty cpusets.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 62 +++++++++++++++++++++++++++++++++------------------------
 1 file changed, 36 insertions(+), 26 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 63a5343..c4f9ebd 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -87,6 +87,18 @@ struct cpuset {
 	cpumask_var_t cpus_allowed;	/* CPUs allowed to tasks in cpuset */
 	nodemask_t mems_allowed;	/* Memory Nodes allowed to tasks */
 
+	/*
+	 * This is old Memory Nodes tasks took on.
+	 *
+	 * - top_cpuset.old_mems_allowed is initialized to mems_allowed.
+	 * - A new cpuset's old_mems_allowed is initialized when some
+	 *   task is moved into it.
+	 * - old_mems_allowed is used in cpuset_migrate_mm() when we change
+	 *   cpuset.mems_allowed and have tasks' nodemask updated, and
+	 *   then old_mems_allowed is updated to mems_allowed.
+	 */
+	nodemask_t old_mems_allowed;
+
 	struct fmeter fmeter;		/* memory_pressure filter */
 
 	/*
@@ -975,16 +987,12 @@ static void cpuset_change_task_nodemask(struct task_struct *tsk,
 static void cpuset_change_nodemask(struct task_struct *p,
 				   struct cgroup_scanner *scan)
 {
+	struct cpuset *cs = cgroup_cs(scan->cg);
 	struct mm_struct *mm;
-	struct cpuset *cs;
 	int migrate;
-	const nodemask_t *oldmem = scan->data;
-	static nodemask_t newmems;	/* protected by cpuset_mutex */
-
-	cs = cgroup_cs(scan->cg);
-	guarantee_online_mems(cs, &newmems);
+	nodemask_t *newmems = scan->data;
 
-	cpuset_change_task_nodemask(p, &newmems);
+	cpuset_change_task_nodemask(p, newmems);
 
 	mm = get_task_mm(p);
 	if (!mm)
@@ -994,7 +1002,7 @@ static void cpuset_change_nodemask(struct task_struct *p,
 
 	mpol_rebind_mm(mm, &cs->mems_allowed);
 	if (migrate)
-		cpuset_migrate_mm(mm, oldmem, &cs->mems_allowed);
+		cpuset_migrate_mm(mm, &cs->old_mems_allowed, newmems);
 	mmput(mm);
 }
 
@@ -1003,25 +1011,26 @@ static void *cpuset_being_rebound;
 /**
  * update_tasks_nodemask - Update the nodemasks of tasks in the cpuset.
  * @cs: the cpuset in which each task's mems_allowed mask needs to be changed
- * @oldmem: old mems_allowed of cpuset cs
  * @heap: if NULL, defer allocating heap memory to cgroup_scan_tasks()
  *
  * Called with cpuset_mutex held
  * No return value. It's guaranteed that cgroup_scan_tasks() always returns 0
  * if @heap != NULL.
  */
-static void update_tasks_nodemask(struct cpuset *cs, const nodemask_t *oldmem,
-				 struct ptr_heap *heap)
+static void update_tasks_nodemask(struct cpuset *cs, struct ptr_heap *heap)
 {
+	static nodemask_t newmems;	/* protected by cpuset_mutex */
 	struct cgroup_scanner scan;
 
 	cpuset_being_rebound = cs;		/* causes mpol_dup() rebind */
 
+	guarantee_online_mems(cs, &newmems);
+
 	scan.cg = cs->css.cgroup;
 	scan.test_task = NULL;
 	scan.process_task = cpuset_change_nodemask;
 	scan.heap = heap;
-	scan.data = (nodemask_t *)oldmem;
+	scan.data = &newmems;
 
 	/*
 	 * The mpol_rebind_mm() call takes mmap_sem, which we couldn't
@@ -1035,6 +1044,12 @@ static void update_tasks_nodemask(struct cpuset *cs, const nodemask_t *oldmem,
 	 */
 	cgroup_scan_tasks(&scan);
 
+	/*
+	 * All the tasks' nodemasks have been updated, update
+	 * cs->old_mems_allowed.
+	 */
+	cs->old_mems_allowed = newmems;
+
 	/* We're done rebinding vmas to this cpuset's new mems_allowed. */
 	cpuset_being_rebound = NULL;
 }
@@ -1055,13 +1070,9 @@ static void update_tasks_nodemask(struct cpuset *cs, const nodemask_t *oldmem,
 static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 			   const char *buf)
 {
-	NODEMASK_ALLOC(nodemask_t, oldmem, GFP_KERNEL);
 	int retval;
 	struct ptr_heap heap;
 
-	if (!oldmem)
-		return -ENOMEM;
-
 	/*
 	 * top_cpuset.mems_allowed tracks node_stats[N_MEMORY];
 	 * it's read-only
@@ -1090,8 +1101,8 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 			goto done;
 		}
 	}
-	*oldmem = cs->mems_allowed;
-	if (nodes_equal(*oldmem, trialcs->mems_allowed)) {
+
+	if (nodes_equal(cs->mems_allowed, trialcs->mems_allowed)) {
 		retval = 0;		/* Too easy - nothing to do */
 		goto done;
 	}
@@ -1107,11 +1118,10 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 	cs->mems_allowed = trialcs->mems_allowed;
 	mutex_unlock(&callback_mutex);
 
-	update_tasks_nodemask(cs, oldmem, &heap);
+	update_tasks_nodemask(cs, &heap);
 
 	heap_free(&heap);
 done:
-	NODEMASK_FREE(oldmem);
 	return retval;
 }
 
@@ -1424,7 +1434,6 @@ static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 	 * Change mm, possibly for multiple threads in a threadgroup. This is
 	 * expensive and may sleep.
 	 */
-	cpuset_attach_nodemask_to = cs->mems_allowed;
 	mm = get_task_mm(leader);
 	if (mm) {
 		mpol_rebind_mm(mm, &cpuset_attach_nodemask_to);
@@ -1434,6 +1443,8 @@ static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 		mmput(mm);
 	}
 
+	cs->old_mems_allowed = cpuset_attach_nodemask_to;
+
 	cs->attach_in_progress--;
 
 	/*
@@ -2000,7 +2011,7 @@ static void remove_tasks_in_empty_cpuset(struct cpuset *cs)
 static void cpuset_propagate_hotplug_workfn(struct work_struct *work)
 {
 	static cpumask_t off_cpus;
-	static nodemask_t off_mems, tmp_mems;
+	static nodemask_t off_mems;
 	struct cpuset *cs = container_of(work, struct cpuset, hotplug_work);
 	bool is_empty;
 
@@ -2021,13 +2032,12 @@ static void cpuset_propagate_hotplug_workfn(struct work_struct *work)
 
 	/* remove offline mems from @cs */
 	if (!nodes_empty(off_mems)) {
-		tmp_mems = cs->mems_allowed;
 		mutex_lock(&callback_mutex);
 		nodes_andnot(cs->mems_allowed, cs->mems_allowed, off_mems);
 		mutex_unlock(&callback_mutex);
 
 		if (!nodes_empty(cs->mems_allowed))
-			update_tasks_nodemask(cs, &tmp_mems, NULL);
+			update_tasks_nodemask(cs, NULL);
 	}
 
 	is_empty = cpumask_empty(cs->cpus_allowed) ||
@@ -2119,11 +2129,10 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 
 	/* synchronize mems_allowed to N_MEMORY */
 	if (mems_updated) {
-		tmp_mems = top_cpuset.mems_allowed;
 		mutex_lock(&callback_mutex);
 		top_cpuset.mems_allowed = new_mems;
 		mutex_unlock(&callback_mutex);
-		update_tasks_nodemask(&top_cpuset, &tmp_mems, NULL);
+		update_tasks_nodemask(&top_cpuset, NULL);
 	}
 
 	/* if cpus or mems went down, we need to propagate to descendants */
@@ -2196,6 +2205,7 @@ void __init cpuset_init_smp(void)
 {
 	cpumask_copy(top_cpuset.cpus_allowed, cpu_active_mask);
 	top_cpuset.mems_allowed = node_states[N_MEMORY];
+	top_cpuset.old_mems_allowed = top_cpuset.mems_allowed;
 
 	hotplug_memory_notifier(cpuset_track_online_nodes, 10);
 
-- 
1.8.0.2
