From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 06/11] cpuset: apply cs->real_{cpus,mems}_allowed
Date: Wed, 21 Aug 2013 17:59:56 +0800
Message-ID: <52148F9C.2080600__10032.5671759949$1377079242$gmane$org@huawei.com>
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

Now we can use cs->real{cpus,mems}_allowed as effective masks. It's
used whenever:

- we update tasks' cpus_allowed/mems_allowed,
- we want to retrieve tasks_cs(tsk)'s cpus_allowed/mems_allowed.

They actually replace effective_{cpu,node}mask_cpuset().

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 83 ++++++++++-----------------------------------------------
 1 file changed, 14 insertions(+), 69 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index b7b63dd..0de15eb 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -318,9 +318,9 @@ static struct file_system_type cpuset_fs_type = {
  */
 static void guarantee_online_cpus(struct cpuset *cs, struct cpumask *pmask)
 {
-	while (!cpumask_intersects(cs->cpus_allowed, cpu_online_mask))
+	while (!cpumask_intersects(cs->real_cpus_allowed, cpu_online_mask))
 		cs = parent_cs(cs);
-	cpumask_and(pmask, cs->cpus_allowed, cpu_online_mask);
+	cpumask_and(pmask, cs->real_cpus_allowed, cpu_online_mask);
 }
 
 /*
@@ -336,9 +336,9 @@ static void guarantee_online_cpus(struct cpuset *cs, struct cpumask *pmask)
  */
 static void guarantee_online_mems(struct cpuset *cs, nodemask_t *pmask)
 {
-	while (!nodes_intersects(cs->mems_allowed, node_states[N_MEMORY]))
+	while (!nodes_intersects(cs->real_mems_allowed, node_states[N_MEMORY]))
 		cs = parent_cs(cs);
-	nodes_and(*pmask, cs->mems_allowed, node_states[N_MEMORY]);
+	nodes_and(*pmask, cs->real_mems_allowed, node_states[N_MEMORY]);
 }
 
 /*
@@ -804,45 +804,6 @@ void rebuild_sched_domains(void)
 	mutex_unlock(&cpuset_mutex);
 }
 
-/*
- * effective_cpumask_cpuset - return nearest ancestor with non-empty cpus
- * @cs: the cpuset in interest
- *
- * A cpuset's effective cpumask is the cpumask of the nearest ancestor
- * with non-empty cpus. We use effective cpumask whenever:
- * - we update tasks' cpus_allowed. (they take on the ancestor's cpumask
- *   if the cpuset they reside in has no cpus)
- * - we want to retrieve task_cs(tsk)'s cpus_allowed.
- *
- * Called with cpuset_mutex held. cpuset_cpus_allowed_fallback() is an
- * exception. See comments there.
- */
-static struct cpuset *effective_cpumask_cpuset(struct cpuset *cs)
-{
-	while (cpumask_empty(cs->cpus_allowed))
-		cs = parent_cs(cs);
-	return cs;
-}
-
-/*
- * effective_nodemask_cpuset - return nearest ancestor with non-empty mems
- * @cs: the cpuset in interest
- *
- * A cpuset's effective nodemask is the nodemask of the nearest ancestor
- * with non-empty memss. We use effective nodemask whenever:
- * - we update tasks' mems_allowed. (they take on the ancestor's nodemask
- *   if the cpuset they reside in has no mems)
- * - we want to retrieve task_cs(tsk)'s mems_allowed.
- *
- * Called with cpuset_mutex held.
- */
-static struct cpuset *effective_nodemask_cpuset(struct cpuset *cs)
-{
-	while (nodes_empty(cs->mems_allowed))
-		cs = parent_cs(cs);
-	return cs;
-}
-
 /**
  * cpuset_change_cpumask - make a task's cpus_allowed the same as its cpuset's
  * @tsk: task to test
@@ -857,9 +818,8 @@ static struct cpuset *effective_nodemask_cpuset(struct cpuset *cs)
 static void cpuset_change_cpumask(struct task_struct *tsk, void *data)
 {
 	struct cpuset *cs = data;
-	struct cpuset *cpus_cs = effective_cpumask_cpuset(cs);
 
-	set_cpus_allowed_ptr(tsk, cpus_cs->cpus_allowed);
+	set_cpus_allowed_ptr(tsk, cs->real_cpus_allowed);
 }
 
 /**
@@ -1014,14 +974,12 @@ static void cpuset_migrate_mm(struct mm_struct *mm, const nodemask_t *from,
 							const nodemask_t *to)
 {
 	struct task_struct *tsk = current;
-	struct cpuset *mems_cs;
 
 	tsk->mems_allowed = *to;
 
 	do_migrate_pages(mm, from, to, MPOL_MF_MOVE_ALL);
 
-	mems_cs = effective_nodemask_cpuset(task_cs(tsk));
-	guarantee_online_mems(mems_cs, &tsk->mems_allowed);
+	guarantee_online_mems(task_cs(tsk), &tsk->mems_allowed);
 }
 
 /*
@@ -1116,13 +1074,12 @@ static void *cpuset_being_rebound;
 static void update_tasks_nodemask(struct cpuset *cs, struct ptr_heap *heap)
 {
 	static nodemask_t newmems;	/* protected by cpuset_mutex */
-	struct cpuset *mems_cs = effective_nodemask_cpuset(cs);
 	struct cpuset_change_nodemask_arg arg = { .cs = cs,
 						  .newmems = &newmems };
 
 	cpuset_being_rebound = cs;		/* causes mpol_dup() rebind */
 
-	guarantee_online_mems(mems_cs, &newmems);
+	guarantee_online_mems(cs, &newmems);
 
 	/*
 	 * The mpol_rebind_mm() call takes mmap_sem, which we couldn't
@@ -1556,8 +1513,6 @@ static void cpuset_attach(struct cgroup_subsys_state *css,
 							cpuset_subsys_id);
 	struct cpuset *cs = css_cs(css);
 	struct cpuset *oldcs = css_cs(oldcss);
-	struct cpuset *cpus_cs = effective_cpumask_cpuset(cs);
-	struct cpuset *mems_cs = effective_nodemask_cpuset(cs);
 
 	mutex_lock(&cpuset_mutex);
 
@@ -1565,9 +1520,9 @@ static void cpuset_attach(struct cgroup_subsys_state *css,
 	if (cs == &top_cpuset)
 		cpumask_copy(cpus_attach, cpu_possible_mask);
 	else
-		guarantee_online_cpus(cpus_cs, cpus_attach);
+		guarantee_online_cpus(cs, cpus_attach);
 
-	guarantee_online_mems(mems_cs, &cpuset_attach_nodemask_to);
+	guarantee_online_mems(cs, &cpuset_attach_nodemask_to);
 
 	cgroup_taskset_for_each(task, css, tset) {
 		/*
@@ -1584,11 +1539,9 @@ static void cpuset_attach(struct cgroup_subsys_state *css,
 	 * Change mm, possibly for multiple threads in a threadgroup. This is
 	 * expensive and may sleep.
 	 */
-	cpuset_attach_nodemask_to = cs->mems_allowed;
+	cpuset_attach_nodemask_to = cs->real_mems_allowed;
 	mm = get_task_mm(leader);
 	if (mm) {
-		struct cpuset *mems_oldcs = effective_nodemask_cpuset(oldcs);
-
 		mpol_rebind_mm(mm, &cpuset_attach_nodemask_to);
 
 		/*
@@ -1599,7 +1552,7 @@ static void cpuset_attach(struct cgroup_subsys_state *css,
 		 * mm from.
 		 */
 		if (is_memory_migrate(cs)) {
-			cpuset_migrate_mm(mm, &mems_oldcs->old_mems_allowed,
+			cpuset_migrate_mm(mm, &oldcs->old_mems_allowed,
 					  &cpuset_attach_nodemask_to);
 		}
 		mmput(mm);
@@ -2398,23 +2351,17 @@ void __init cpuset_init_smp(void)
 
 void cpuset_cpus_allowed(struct task_struct *tsk, struct cpumask *pmask)
 {
-	struct cpuset *cpus_cs;
-
 	mutex_lock(&callback_mutex);
 	task_lock(tsk);
-	cpus_cs = effective_cpumask_cpuset(task_cs(tsk));
-	guarantee_online_cpus(cpus_cs, pmask);
+	guarantee_online_cpus(task_cs(tsk), pmask);
 	task_unlock(tsk);
 	mutex_unlock(&callback_mutex);
 }
 
 void cpuset_cpus_allowed_fallback(struct task_struct *tsk)
 {
-	struct cpuset *cpus_cs;
-
 	rcu_read_lock();
-	cpus_cs = effective_cpumask_cpuset(task_cs(tsk));
-	do_set_cpus_allowed(tsk, cpus_cs->cpus_allowed);
+	do_set_cpus_allowed(tsk, task_cs(tsk)->real_cpus_allowed);
 	rcu_read_unlock();
 
 	/*
@@ -2453,13 +2400,11 @@ void cpuset_init_current_mems_allowed(void)
 
 nodemask_t cpuset_mems_allowed(struct task_struct *tsk)
 {
-	struct cpuset *mems_cs;
 	nodemask_t mask;
 
 	mutex_lock(&callback_mutex);
 	task_lock(tsk);
-	mems_cs = effective_nodemask_cpuset(task_cs(tsk));
-	guarantee_online_mems(mems_cs, &mask);
+	guarantee_online_mems(task_cs(tsk), &mask);
 	task_unlock(tsk);
 	mutex_unlock(&callback_mutex);
 
-- 
1.8.0.2
