From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/16] cpuset: use css_task_iter_start/next/end() instead of
	css_scan_tasks()
Date: Sun,  9 Feb 2014 08:52:36 -0500
Message-ID: <1391953964-22088-9-git-send-email-tj@kernel.org>
References: <1391953964-22088-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391953964-22088-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Now that css_task_iter_start/next_end() supports blocking while
iterating, there's no reason to use css_scan_tasks() which is more
cumbersome to use and scheduled to be removed.

Convert all css_scan_tasks() usages in cpuset to
css_task_iter_start/next/end().  This simplifies the code by removing
heap allocation and callbacks.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 186 ++++++++++++++++++--------------------------------------
 1 file changed, 58 insertions(+), 128 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index ae190b0..65ae0bd 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -829,55 +829,36 @@ static struct cpuset *effective_nodemask_cpuset(struct cpuset *cs)
 }
 
 /**
- * cpuset_change_cpumask - make a task's cpus_allowed the same as its cpuset's
- * @tsk: task to test
- * @data: cpuset to @tsk belongs to
- *
- * Called by css_scan_tasks() for each task in a cgroup whose cpus_allowed
- * mask needs to be changed.
- *
- * We don't need to re-check for the cgroup/cpuset membership, since we're
- * holding cpuset_mutex at this point.
- */
-static void cpuset_change_cpumask(struct task_struct *tsk, void *data)
-{
-	struct cpuset *cs = data;
-	struct cpuset *cpus_cs = effective_cpumask_cpuset(cs);
-
-	set_cpus_allowed_ptr(tsk, cpus_cs->cpus_allowed);
-}
-
-/**
  * update_tasks_cpumask - Update the cpumasks of tasks in the cpuset.
  * @cs: the cpuset in which each task's cpus_allowed mask needs to be changed
- * @heap: if NULL, defer allocating heap memory to css_scan_tasks()
- *
- * Called with cpuset_mutex held
- *
- * The css_scan_tasks() function will scan all the tasks in a cgroup,
- * calling callback functions for each.
  *
- * No return value. It's guaranteed that css_scan_tasks() always returns 0
- * if @heap != NULL.
+ * Iterate through each task of @cs updating its cpus_allowed to the
+ * effective cpuset's.  As this function is called with cpuset_mutex held,
+ * cpuset membership stays stable.
  */
-static void update_tasks_cpumask(struct cpuset *cs, struct ptr_heap *heap)
+static void update_tasks_cpumask(struct cpuset *cs)
 {
-	css_scan_tasks(&cs->css, NULL, cpuset_change_cpumask, cs, heap);
+	struct cpuset *cpus_cs = effective_cpumask_cpuset(cs);
+	struct css_task_iter it;
+	struct task_struct *task;
+
+	css_task_iter_start(&cs->css, &it);
+	while ((task = css_task_iter_next(&it)))
+		set_cpus_allowed_ptr(task, cpus_cs->cpus_allowed);
+	css_task_iter_end(&it);
 }
 
 /*
  * update_tasks_cpumask_hier - Update the cpumasks of tasks in the hierarchy.
  * @root_cs: the root cpuset of the hierarchy
  * @update_root: update root cpuset or not?
- * @heap: the heap used by css_scan_tasks()
  *
  * This will update cpumasks of tasks in @root_cs and all other empty cpusets
  * which take on cpumask of @root_cs.
  *
  * Called with cpuset_mutex held
  */
-static void update_tasks_cpumask_hier(struct cpuset *root_cs,
-				      bool update_root, struct ptr_heap *heap)
+static void update_tasks_cpumask_hier(struct cpuset *root_cs, bool update_root)
 {
 	struct cpuset *cp;
 	struct cgroup_subsys_state *pos_css;
@@ -898,7 +879,7 @@ static void update_tasks_cpumask_hier(struct cpuset *root_cs,
 			continue;
 		rcu_read_unlock();
 
-		update_tasks_cpumask(cp, heap);
+		update_tasks_cpumask(cp);
 
 		rcu_read_lock();
 		css_put(&cp->css);
@@ -914,7 +895,6 @@ static void update_tasks_cpumask_hier(struct cpuset *root_cs,
 static int update_cpumask(struct cpuset *cs, struct cpuset *trialcs,
 			  const char *buf)
 {
-	struct ptr_heap heap;
 	int retval;
 	int is_load_balanced;
 
@@ -947,19 +927,13 @@ static int update_cpumask(struct cpuset *cs, struct cpuset *trialcs,
 	if (retval < 0)
 		return retval;
 
-	retval = heap_init(&heap, PAGE_SIZE, GFP_KERNEL, NULL);
-	if (retval)
-		return retval;
-
 	is_load_balanced = is_sched_load_balance(trialcs);
 
 	mutex_lock(&callback_mutex);
 	cpumask_copy(cs->cpus_allowed, trialcs->cpus_allowed);
 	mutex_unlock(&callback_mutex);
 
-	update_tasks_cpumask_hier(cs, true, &heap);
-
-	heap_free(&heap);
+	update_tasks_cpumask_hier(cs, true);
 
 	if (is_load_balanced)
 		rebuild_sched_domains_locked();
@@ -1052,53 +1026,22 @@ static void cpuset_change_task_nodemask(struct task_struct *tsk,
 	task_unlock(tsk);
 }
 
-struct cpuset_change_nodemask_arg {
-	struct cpuset		*cs;
-	nodemask_t		*newmems;
-};
-
-/*
- * Update task's mems_allowed and rebind its mempolicy and vmas' mempolicy
- * of it to cpuset's new mems_allowed, and migrate pages to new nodes if
- * memory_migrate flag is set. Called with cpuset_mutex held.
- */
-static void cpuset_change_nodemask(struct task_struct *p, void *data)
-{
-	struct cpuset_change_nodemask_arg *arg = data;
-	struct cpuset *cs = arg->cs;
-	struct mm_struct *mm;
-	int migrate;
-
-	cpuset_change_task_nodemask(p, arg->newmems);
-
-	mm = get_task_mm(p);
-	if (!mm)
-		return;
-
-	migrate = is_memory_migrate(cs);
-
-	mpol_rebind_mm(mm, &cs->mems_allowed);
-	if (migrate)
-		cpuset_migrate_mm(mm, &cs->old_mems_allowed, arg->newmems);
-	mmput(mm);
-}
-
 static void *cpuset_being_rebound;
 
 /**
  * update_tasks_nodemask - Update the nodemasks of tasks in the cpuset.
  * @cs: the cpuset in which each task's mems_allowed mask needs to be changed
- * @heap: if NULL, defer allocating heap memory to css_scan_tasks()
  *
- * Called with cpuset_mutex held.  No return value. It's guaranteed that
- * css_scan_tasks() always returns 0 if @heap != NULL.
+ * Iterate through each task of @cs updating its mems_allowed to the
+ * effective cpuset's.  As this function is called with cpuset_mutex held,
+ * cpuset membership stays stable.
  */
-static void update_tasks_nodemask(struct cpuset *cs, struct ptr_heap *heap)
+static void update_tasks_nodemask(struct cpuset *cs)
 {
 	static nodemask_t newmems;	/* protected by cpuset_mutex */
 	struct cpuset *mems_cs = effective_nodemask_cpuset(cs);
-	struct cpuset_change_nodemask_arg arg = { .cs = cs,
-						  .newmems = &newmems };
+	struct css_task_iter it;
+	struct task_struct *task;
 
 	cpuset_being_rebound = cs;		/* causes mpol_dup() rebind */
 
@@ -1114,7 +1057,25 @@ static void update_tasks_nodemask(struct cpuset *cs, struct ptr_heap *heap)
 	 * It's ok if we rebind the same mm twice; mpol_rebind_mm()
 	 * is idempotent.  Also migrate pages in each mm to new nodes.
 	 */
-	css_scan_tasks(&cs->css, NULL, cpuset_change_nodemask, &arg, heap);
+	css_task_iter_start(&cs->css, &it);
+	while ((task = css_task_iter_next(&it))) {
+		struct mm_struct *mm;
+		bool migrate;
+
+		cpuset_change_task_nodemask(task, &newmems);
+
+		mm = get_task_mm(task);
+		if (!mm)
+			continue;
+
+		migrate = is_memory_migrate(cs);
+
+		mpol_rebind_mm(mm, &cs->mems_allowed);
+		if (migrate)
+			cpuset_migrate_mm(mm, &cs->old_mems_allowed, &newmems);
+		mmput(mm);
+	}
+	css_task_iter_end(&it);
 
 	/*
 	 * All the tasks' nodemasks have been updated, update
@@ -1130,15 +1091,13 @@ static void update_tasks_nodemask(struct cpuset *cs, struct ptr_heap *heap)
  * update_tasks_nodemask_hier - Update the nodemasks of tasks in the hierarchy.
  * @cs: the root cpuset of the hierarchy
  * @update_root: update the root cpuset or not?
- * @heap: the heap used by css_scan_tasks()
  *
  * This will update nodemasks of tasks in @root_cs and all other empty cpusets
  * which take on nodemask of @root_cs.
  *
  * Called with cpuset_mutex held
  */
-static void update_tasks_nodemask_hier(struct cpuset *root_cs,
-				       bool update_root, struct ptr_heap *heap)
+static void update_tasks_nodemask_hier(struct cpuset *root_cs, bool update_root)
 {
 	struct cpuset *cp;
 	struct cgroup_subsys_state *pos_css;
@@ -1159,7 +1118,7 @@ static void update_tasks_nodemask_hier(struct cpuset *root_cs,
 			continue;
 		rcu_read_unlock();
 
-		update_tasks_nodemask(cp, heap);
+		update_tasks_nodemask(cp);
 
 		rcu_read_lock();
 		css_put(&cp->css);
@@ -1184,7 +1143,6 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 			   const char *buf)
 {
 	int retval;
-	struct ptr_heap heap;
 
 	/*
 	 * top_cpuset.mems_allowed tracks node_stats[N_MEMORY];
@@ -1223,17 +1181,11 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 	if (retval < 0)
 		goto done;
 
-	retval = heap_init(&heap, PAGE_SIZE, GFP_KERNEL, NULL);
-	if (retval < 0)
-		goto done;
-
 	mutex_lock(&callback_mutex);
 	cs->mems_allowed = trialcs->mems_allowed;
 	mutex_unlock(&callback_mutex);
 
-	update_tasks_nodemask_hier(cs, true, &heap);
-
-	heap_free(&heap);
+	update_tasks_nodemask_hier(cs, true);
 done:
 	return retval;
 }
@@ -1261,38 +1213,22 @@ static int update_relax_domain_level(struct cpuset *cs, s64 val)
 }
 
 /**
- * cpuset_change_flag - make a task's spread flags the same as its cpuset's
- * @tsk: task to be updated
- * @data: cpuset to @tsk belongs to
- *
- * Called by css_scan_tasks() for each task in a cgroup.
- *
- * We don't need to re-check for the cgroup/cpuset membership, since we're
- * holding cpuset_mutex at this point.
- */
-static void cpuset_change_flag(struct task_struct *tsk, void *data)
-{
-	struct cpuset *cs = data;
-
-	cpuset_update_task_spread_flag(cs, tsk);
-}
-
-/**
  * update_tasks_flags - update the spread flags of tasks in the cpuset.
  * @cs: the cpuset in which each task's spread flags needs to be changed
- * @heap: if NULL, defer allocating heap memory to css_scan_tasks()
- *
- * Called with cpuset_mutex held
  *
- * The css_scan_tasks() function will scan all the tasks in a cgroup,
- * calling callback functions for each.
- *
- * No return value. It's guaranteed that css_scan_tasks() always returns 0
- * if @heap != NULL.
+ * Iterate through each task of @cs updating its spread flags.  As this
+ * function is called with cpuset_mutex held, cpuset membership stays
+ * stable.
  */
-static void update_tasks_flags(struct cpuset *cs, struct ptr_heap *heap)
+static void update_tasks_flags(struct cpuset *cs)
 {
-	css_scan_tasks(&cs->css, NULL, cpuset_change_flag, cs, heap);
+	struct css_task_iter it;
+	struct task_struct *task;
+
+	css_task_iter_start(&cs->css, &it);
+	while ((task = css_task_iter_next(&it)))
+		cpuset_update_task_spread_flag(cs, task);
+	css_task_iter_end(&it);
 }
 
 /*
@@ -1310,7 +1246,6 @@ static int update_flag(cpuset_flagbits_t bit, struct cpuset *cs,
 	struct cpuset *trialcs;
 	int balance_flag_changed;
 	int spread_flag_changed;
-	struct ptr_heap heap;
 	int err;
 
 	trialcs = alloc_trial_cpuset(cs);
@@ -1326,10 +1261,6 @@ static int update_flag(cpuset_flagbits_t bit, struct cpuset *cs,
 	if (err < 0)
 		goto out;
 
-	err = heap_init(&heap, PAGE_SIZE, GFP_KERNEL, NULL);
-	if (err < 0)
-		goto out;
-
 	balance_flag_changed = (is_sched_load_balance(cs) !=
 				is_sched_load_balance(trialcs));
 
@@ -1344,8 +1275,7 @@ static int update_flag(cpuset_flagbits_t bit, struct cpuset *cs,
 		rebuild_sched_domains_locked();
 
 	if (spread_flag_changed)
-		update_tasks_flags(cs, &heap);
-	heap_free(&heap);
+		update_tasks_flags(cs);
 out:
 	free_trial_cpuset(trialcs);
 	return err;
@@ -2138,7 +2068,7 @@ retry:
 	 */
 	if ((sane && cpumask_empty(cs->cpus_allowed)) ||
 	    (!cpumask_empty(&off_cpus) && !cpumask_empty(cs->cpus_allowed)))
-		update_tasks_cpumask(cs, NULL);
+		update_tasks_cpumask(cs);
 
 	mutex_lock(&callback_mutex);
 	nodes_andnot(cs->mems_allowed, cs->mems_allowed, off_mems);
@@ -2152,7 +2082,7 @@ retry:
 	 */
 	if ((sane && nodes_empty(cs->mems_allowed)) ||
 	    (!nodes_empty(off_mems) && !nodes_empty(cs->mems_allowed)))
-		update_tasks_nodemask(cs, NULL);
+		update_tasks_nodemask(cs);
 
 	is_empty = cpumask_empty(cs->cpus_allowed) ||
 		nodes_empty(cs->mems_allowed);
@@ -2214,7 +2144,7 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 		mutex_lock(&callback_mutex);
 		top_cpuset.mems_allowed = new_mems;
 		mutex_unlock(&callback_mutex);
-		update_tasks_nodemask(&top_cpuset, NULL);
+		update_tasks_nodemask(&top_cpuset);
 	}
 
 	mutex_unlock(&cpuset_mutex);
-- 
1.8.5.3
