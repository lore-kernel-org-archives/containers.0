From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 19/23] cgroup: remove struct cgroup_scanner
Date: Thu,  1 Aug 2013 17:49:57 -0400
Message-ID: <1375393801-4817-20-git-send-email-tj__37998.1164624498$1375393962$gmane$org@kernel.org>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375393801-4817-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

cgroup_scan_tasks() takes a pointer to struct cgroup_scanner as its
sole argument and the only function of that struct is packing the
arguments of the function call which are consisted of five fields.
It's not too unusual to pack parameters into a struct when the number
of arguments gets excessive or the whole set needs to be passed around
a lot, but neither holds here making it just weird.

Drop struct cgroup_scanner and pass the params directly to
cgroup_scan_tasks().  Note that struct cpuset_change_nodemask_arg was
added to cpuset.c to pass both ->cs and ->newmems pointer to
cpuset_change_nodemask() using single data pointer.

This doesn't make any functional differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 16 ++++-----
 kernel/cgroup.c        | 93 +++++++++++++++++++++++---------------------------
 kernel/cpuset.c        | 63 ++++++++++++++--------------------
 3 files changed, 75 insertions(+), 97 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 2b10152..2e9a799 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -528,15 +528,6 @@ struct cftype_set {
 	struct cftype			*cfts;
 };
 
-struct cgroup_scanner {
-	struct cgroup *cgrp;
-	int (*test_task)(struct task_struct *p, struct cgroup_scanner *scan);
-	void (*process_task)(struct task_struct *p,
-			struct cgroup_scanner *scan);
-	struct ptr_heap *heap;
-	void *data;
-};
-
 /*
  * See the comment above CGRP_ROOT_SANE_BEHAVIOR for details.  This
  * function can be called as long as @cgrp is accessible.
@@ -900,7 +891,12 @@ struct cgroup_task_iter {
 void cgroup_task_iter_start(struct cgroup *cgrp, struct cgroup_task_iter *it);
 struct task_struct *cgroup_task_iter_next(struct cgroup_task_iter *it);
 void cgroup_task_iter_end(struct cgroup_task_iter *it);
-int cgroup_scan_tasks(struct cgroup_scanner *scan);
+
+int cgroup_scan_tasks(struct cgroup *cgrp,
+		      bool (*test)(struct task_struct *, void *),
+		      void (*process)(struct task_struct *, void *),
+		      void *data, struct ptr_heap *heap);
+
 int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7adaaa6..4e354b59 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3336,32 +3336,37 @@ static inline int started_after(void *p1, void *p2)
 
 /**
  * cgroup_scan_tasks - iterate though all the tasks in a cgroup
- * @scan: struct cgroup_scanner containing arguments for the scan
+ * @cgrp: the cgroup to iterate tasks of
+ * @test: optional test callback
+ * @process: process callback
+ * @data: data passed to @test and @process
+ * @heap: optional pre-allocated heap used for task iteration
  *
- * Arguments include pointers to callback functions test_task() and
- * process_task().
- * Iterate through all the tasks in a cgroup, calling test_task() for each,
- * and if it returns true, call process_task() for it also.
- * The test_task pointer may be NULL, meaning always true (select all tasks).
- * Effectively duplicates cgroup_task_iter_{start,next,end}()
- * but does not lock css_set_lock for the call to process_task().
- * The struct cgroup_scanner may be embedded in any structure of the caller's
- * creation.
- * It is guaranteed that process_task() will act on every task that
- * is a member of the cgroup for the duration of this call. This
- * function may or may not call process_task() for tasks that exit
- * or move to a different cgroup during the call, or are forked or
- * move into the cgroup during the call.
+ * Iterate through all the tasks in a cgroup, calling @test for each, and
+ * if it returns %true, call @process for it also.
  *
- * Note that test_task() may be called with locks held, and may in some
- * situations be called multiple times for the same task, so it should
- * be cheap.
- * If the heap pointer in the struct cgroup_scanner is non-NULL, a heap has been
- * pre-allocated and will be used for heap operations (and its "gt" member will
- * be overwritten), else a temporary heap will be used (allocation of which
- * may cause this function to fail).
+ * @test may be NULL, meaning always true (select all tasks), which
+ * effectively duplicates cgroup_task_iter_{start,next,end}() but does not
+ * lock css_set_lock for the call to @process.
+ *
+ * It is guaranteed that @process will act on every task that is a member
+ * of @cgrp for the duration of this call.  This function may or may not
+ * call @process for tasks that exit or move to a different cgroup during
+ * the call, or are forked or move into the cgroup during the call.
+ *
+ * Note that @test may be called with locks held, and may in some
+ * situations be called multiple times for the same task, so it should be
+ * cheap.
+ *
+ * If @heap is non-NULL, a heap has been pre-allocated and will be used for
+ * heap operations (and its "gt" member will be overwritten), else a
+ * temporary heap will be used (allocation of which may cause this function
+ * to fail).
  */
-int cgroup_scan_tasks(struct cgroup_scanner *scan)
+int cgroup_scan_tasks(struct cgroup *cgrp,
+		      bool (*test)(struct task_struct *, void *),
+		      void (*process)(struct task_struct *, void *),
+		      void *data, struct ptr_heap *heap)
 {
 	int retval, i;
 	struct cgroup_task_iter it;
@@ -3369,12 +3374,10 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
 	/* Never dereference latest_task, since it's not refcounted */
 	struct task_struct *latest_task = NULL;
 	struct ptr_heap tmp_heap;
-	struct ptr_heap *heap;
 	struct timespec latest_time = { 0, 0 };
 
-	if (scan->heap) {
+	if (heap) {
 		/* The caller supplied our heap and pre-allocated its memory */
-		heap = scan->heap;
 		heap->gt = &started_after;
 	} else {
 		/* We need to allocate our own heap memory */
@@ -3387,25 +3390,24 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
 
  again:
 	/*
-	 * Scan tasks in the cgroup, using the scanner's "test_task" callback
-	 * to determine which are of interest, and using the scanner's
-	 * "process_task" callback to process any of them that need an update.
-	 * Since we don't want to hold any locks during the task updates,
-	 * gather tasks to be processed in a heap structure.
-	 * The heap is sorted by descending task start time.
-	 * If the statically-sized heap fills up, we overflow tasks that
-	 * started later, and in future iterations only consider tasks that
-	 * started after the latest task in the previous pass. This
+	 * Scan tasks in the cgroup, using the @test callback to determine
+	 * which are of interest, and invoking @process callback on the
+	 * ones which need an update.  Since we don't want to hold any
+	 * locks during the task updates, gather tasks to be processed in a
+	 * heap structure.  The heap is sorted by descending task start
+	 * time.  If the statically-sized heap fills up, we overflow tasks
+	 * that started later, and in future iterations only consider tasks
+	 * that started after the latest task in the previous pass. This
 	 * guarantees forward progress and that we don't miss any tasks.
 	 */
 	heap->size = 0;
-	cgroup_task_iter_start(scan->cgrp, &it);
+	cgroup_task_iter_start(cgrp, &it);
 	while ((p = cgroup_task_iter_next(&it))) {
 		/*
 		 * Only affect tasks that qualify per the caller's callback,
 		 * if he provided one
 		 */
-		if (scan->test_task && !scan->test_task(p, scan))
+		if (test && !test(p, data))
 			continue;
 		/*
 		 * Only process tasks that started after the last task
@@ -3443,7 +3445,7 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
 				latest_task = q;
 			}
 			/* Process the task per the caller's callback */
-			scan->process_task(q, scan);
+			process(q, data);
 			put_task_struct(q);
 		}
 		/*
@@ -3460,10 +3462,9 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
 	return 0;
 }
 
-static void cgroup_transfer_one_task(struct task_struct *task,
-				     struct cgroup_scanner *scan)
+static void cgroup_transfer_one_task(struct task_struct *task, void *data)
 {
-	struct cgroup *new_cgroup = scan->data;
+	struct cgroup *new_cgroup = data;
 
 	mutex_lock(&cgroup_mutex);
 	cgroup_attach_task(new_cgroup, task, false);
@@ -3477,15 +3478,7 @@ static void cgroup_transfer_one_task(struct task_struct *task,
  */
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from)
 {
-	struct cgroup_scanner scan;
-
-	scan.cgrp = from;
-	scan.test_task = NULL; /* select all tasks in cgroup */
-	scan.process_task = cgroup_transfer_one_task;
-	scan.heap = NULL;
-	scan.data = to;
-
-	return cgroup_scan_tasks(&scan);
+	return cgroup_scan_tasks(from, NULL, cgroup_transfer_one_task, to, NULL);
 }
 
 /*
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index be4f503..6fe23f2 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -830,7 +830,7 @@ static struct cpuset *effective_nodemask_cpuset(struct cpuset *cs)
 /**
  * cpuset_change_cpumask - make a task's cpus_allowed the same as its cpuset's
  * @tsk: task to test
- * @scan: struct cgroup_scanner containing the cgroup of the task
+ * @data: cpuset to @tsk belongs to
  *
  * Called by cgroup_scan_tasks() for each task in a cgroup whose
  * cpus_allowed mask needs to be changed.
@@ -838,12 +838,11 @@ static struct cpuset *effective_nodemask_cpuset(struct cpuset *cs)
  * We don't need to re-check for the cgroup/cpuset membership, since we're
  * holding cpuset_mutex at this point.
  */
-static void cpuset_change_cpumask(struct task_struct *tsk,
-				  struct cgroup_scanner *scan)
+static void cpuset_change_cpumask(struct task_struct *tsk, void *data)
 {
-	struct cpuset *cpus_cs;
+	struct cpuset *cs = data;
+	struct cpuset *cpus_cs = effective_cpumask_cpuset(cs);
 
-	cpus_cs = effective_cpumask_cpuset(cgroup_cs(scan->cgrp));
 	set_cpus_allowed_ptr(tsk, cpus_cs->cpus_allowed);
 }
 
@@ -862,13 +861,8 @@ static void cpuset_change_cpumask(struct task_struct *tsk,
  */
 static void update_tasks_cpumask(struct cpuset *cs, struct ptr_heap *heap)
 {
-	struct cgroup_scanner scan;
-
-	scan.cgrp = cs->css.cgroup;
-	scan.test_task = NULL;
-	scan.process_task = cpuset_change_cpumask;
-	scan.heap = heap;
-	cgroup_scan_tasks(&scan);
+	cgroup_scan_tasks(cs->css.cgroup, NULL, cpuset_change_cpumask, cs,
+			  heap);
 }
 
 /*
@@ -1052,20 +1046,24 @@ static void cpuset_change_task_nodemask(struct task_struct *tsk,
 	task_unlock(tsk);
 }
 
+struct cpuset_change_nodemask_arg {
+	struct cpuset		*cs;
+	nodemask_t		*newmems;
+};
+
 /*
  * Update task's mems_allowed and rebind its mempolicy and vmas' mempolicy
  * of it to cpuset's new mems_allowed, and migrate pages to new nodes if
  * memory_migrate flag is set. Called with cpuset_mutex held.
  */
-static void cpuset_change_nodemask(struct task_struct *p,
-				   struct cgroup_scanner *scan)
+static void cpuset_change_nodemask(struct task_struct *p, void *data)
 {
-	struct cpuset *cs = cgroup_cs(scan->cgrp);
+	struct cpuset_change_nodemask_arg *arg = data;
+	struct cpuset *cs = arg->cs;
 	struct mm_struct *mm;
 	int migrate;
-	nodemask_t *newmems = scan->data;
 
-	cpuset_change_task_nodemask(p, newmems);
+	cpuset_change_task_nodemask(p, arg->newmems);
 
 	mm = get_task_mm(p);
 	if (!mm)
@@ -1075,7 +1073,7 @@ static void cpuset_change_nodemask(struct task_struct *p,
 
 	mpol_rebind_mm(mm, &cs->mems_allowed);
 	if (migrate)
-		cpuset_migrate_mm(mm, &cs->old_mems_allowed, newmems);
+		cpuset_migrate_mm(mm, &cs->old_mems_allowed, arg->newmems);
 	mmput(mm);
 }
 
@@ -1093,19 +1091,14 @@ static void *cpuset_being_rebound;
 static void update_tasks_nodemask(struct cpuset *cs, struct ptr_heap *heap)
 {
 	static nodemask_t newmems;	/* protected by cpuset_mutex */
-	struct cgroup_scanner scan;
 	struct cpuset *mems_cs = effective_nodemask_cpuset(cs);
+	struct cpuset_change_nodemask_arg arg = { .cs = cs,
+						  .newmems = &newmems };
 
 	cpuset_being_rebound = cs;		/* causes mpol_dup() rebind */
 
 	guarantee_online_mems(mems_cs, &newmems);
 
-	scan.cgrp = cs->css.cgroup;
-	scan.test_task = NULL;
-	scan.process_task = cpuset_change_nodemask;
-	scan.heap = heap;
-	scan.data = &newmems;
-
 	/*
 	 * The mpol_rebind_mm() call takes mmap_sem, which we couldn't
 	 * take while holding tasklist_lock.  Forks can happen - the
@@ -1116,7 +1109,8 @@ static void update_tasks_nodemask(struct cpuset *cs, struct ptr_heap *heap)
 	 * It's ok if we rebind the same mm twice; mpol_rebind_mm()
 	 * is idempotent.  Also migrate pages in each mm to new nodes.
 	 */
-	cgroup_scan_tasks(&scan);
+	cgroup_scan_tasks(cs->css.cgroup, NULL, cpuset_change_nodemask, &arg,
+			  heap);
 
 	/*
 	 * All the tasks' nodemasks have been updated, update
@@ -1263,17 +1257,18 @@ static int update_relax_domain_level(struct cpuset *cs, s64 val)
 /*
  * cpuset_change_flag - make a task's spread flags the same as its cpuset's
  * @tsk: task to be updated
- * @scan: struct cgroup_scanner containing the cgroup of the task
+ * @data: cpuset to @tsk belongs to
  *
  * Called by cgroup_scan_tasks() for each task in a cgroup.
  *
  * We don't need to re-check for the cgroup/cpuset membership, since we're
  * holding cpuset_mutex at this point.
  */
-static void cpuset_change_flag(struct task_struct *tsk,
-				struct cgroup_scanner *scan)
+static void cpuset_change_flag(struct task_struct *tsk, void *data)
 {
-	cpuset_update_task_spread_flag(cgroup_cs(scan->cgrp), tsk);
+	struct cpuset *cs = data;
+
+	cpuset_update_task_spread_flag(cs, tsk);
 }
 
 /*
@@ -1291,13 +1286,7 @@ static void cpuset_change_flag(struct task_struct *tsk,
  */
 static void update_tasks_flags(struct cpuset *cs, struct ptr_heap *heap)
 {
-	struct cgroup_scanner scan;
-
-	scan.cgrp = cs->css.cgroup;
-	scan.test_task = NULL;
-	scan.process_task = cpuset_change_flag;
-	scan.heap = heap;
-	cgroup_scan_tasks(&scan);
+	cgroup_scan_tasks(cs->css.cgroup, NULL, cpuset_change_flag, cs, heap);
 }
 
 /*
-- 
1.8.3.1
