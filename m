From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/13] cpuset: make CPU / memory hotplug propagation
	asynchronous
Date: Thu,  3 Jan 2013 13:36:04 -0800
Message-ID: <1357248967-24959-11-git-send-email-tj__12047.1541108147$1357249062$gmane$org@kernel.org>
References: <1357248967-24959-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1357248967-24959-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cpuset_hotplug_workfn() has been invoking cpuset_propagate_hotplug()
directly to propagate hotplug updates to !root cpusets; however, this
has the following problems.

* cpuset locking is scheduled to be decoupled from cgroup_mutex,
  cgroup_mutex will be unexported, and cgroup_attach_task() will do
  cgroup locking internally, so propagation can't synchronously move
  tasks to a parent cgroup while walking the hierarchy.

* We can't use cgroup generic tree iterator because propagation to
  each cpuset may sleep.  With propagation done asynchronously, we can
  lose the rather ugly cpuset specific iteration.

Convert cpuset_propagate_hotplug() to
cpuset_propagate_hotplug_workfn() and execute it from newly added
cpuset->hotplug_work.  The work items are run on an ordered workqueue,
so the propagation order is preserved.  cpuset_hotplug_workfn()
schedules all propagations while holding cgroup_mutex and waits for
completion without cgroup_mutex.  Each in-flight propagation holds a
reference to the cpuset->css.

This patch doesn't cause any functional difference.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cpuset.c | 54 ++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 48 insertions(+), 6 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 74e412f..2d0b9bc 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -99,6 +99,8 @@ struct cpuset {
 
 	/* used for walking a cpuset hierarchy */
 	struct list_head stack_list;
+
+	struct work_struct hotplug_work;
 };
 
 /* Retrieve the cpuset for a cgroup */
@@ -254,7 +256,10 @@ static DEFINE_SPINLOCK(cpuset_buffer_lock);
 /*
  * CPU / memory hotplug is handled asynchronously.
  */
+static struct workqueue_struct *cpuset_propagate_hotplug_wq;
+
 static void cpuset_hotplug_workfn(struct work_struct *work);
+static void cpuset_propagate_hotplug_workfn(struct work_struct *work);
 
 static DECLARE_WORK(cpuset_hotplug_work, cpuset_hotplug_workfn);
 
@@ -1808,6 +1813,7 @@ static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cont)
 	cpumask_clear(cs->cpus_allowed);
 	nodes_clear(cs->mems_allowed);
 	fmeter_init(&cs->fmeter);
+	INIT_WORK(&cs->hotplug_work, cpuset_propagate_hotplug_workfn);
 	cs->relax_domain_level = -1;
 	cs->parent = cgroup_cs(cont->parent);
 
@@ -2033,21 +2039,20 @@ static struct cpuset *cpuset_next(struct list_head *queue)
 }
 
 /**
- * cpuset_propagate_hotplug - propagate CPU/memory hotplug to a cpuset
+ * cpuset_propagate_hotplug_workfn - propagate CPU/memory hotplug to a cpuset
  * @cs: cpuset in interest
  *
  * Compare @cs's cpu and mem masks against top_cpuset and if some have gone
  * offline, update @cs accordingly.  If @cs ends up with no CPU or memory,
  * all its tasks are moved to the nearest ancestor with both resources.
- *
- * Should be called with cgroup_mutex held.
  */
-static void cpuset_propagate_hotplug(struct cpuset *cs)
+static void cpuset_propagate_hotplug_workfn(struct work_struct *work)
 {
 	static cpumask_t off_cpus;
 	static nodemask_t off_mems, tmp_mems;
+	struct cpuset *cs = container_of(work, struct cpuset, hotplug_work);
 
-	WARN_ON_ONCE(!cgroup_lock_is_held());
+	cgroup_lock();
 
 	cpumask_andnot(&off_cpus, cs->cpus_allowed, top_cpuset.cpus_allowed);
 	nodes_andnot(off_mems, cs->mems_allowed, top_cpuset.mems_allowed);
@@ -2071,6 +2076,36 @@ static void cpuset_propagate_hotplug(struct cpuset *cs)
 
 	if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
 		remove_tasks_in_empty_cpuset(cs);
+
+	cgroup_unlock();
+
+	/* the following may free @cs, should be the last operation */
+	css_put(&cs->css);
+}
+
+/**
+ * schedule_cpuset_propagate_hotplug - schedule hotplug propagation to a cpuset
+ * @cs: cpuset of interest
+ *
+ * Schedule cpuset_propagate_hotplug_workfn() which will update CPU and
+ * memory masks according to top_cpuset.
+ */
+static void schedule_cpuset_propagate_hotplug(struct cpuset *cs)
+{
+	/*
+	 * Pin @cs.  The refcnt will be released when the work item
+	 * finishes executing.
+	 */
+	if (!css_tryget(&cs->css))
+		return;
+
+	/*
+	 * Queue @cs->empty_cpuset_work.  If already pending, lose the css
+	 * ref.  cpuset_propagate_hotplug_wq is ordered and propagation
+	 * will happen in the order this function is called.
+	 */
+	if (!queue_work(cpuset_propagate_hotplug_wq, &cs->hotplug_work))
+		css_put(&cs->css);
 }
 
 /**
@@ -2135,11 +2170,14 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 		list_add_tail(&top_cpuset.stack_list, &queue);
 		while ((cs = cpuset_next(&queue)))
 			if (cs != &top_cpuset)
-				cpuset_propagate_hotplug(cs);
+				schedule_cpuset_propagate_hotplug(cs);
 	}
 
 	cgroup_unlock();
 
+	/* wait for propagations to finish */
+	flush_workqueue(cpuset_propagate_hotplug_wq);
+
 	/* rebuild sched domains if cpus_allowed has changed */
 	if (cpus_updated) {
 		struct sched_domain_attr *attr;
@@ -2196,6 +2234,10 @@ void __init cpuset_init_smp(void)
 	top_cpuset.mems_allowed = node_states[N_MEMORY];
 
 	hotplug_memory_notifier(cpuset_track_online_nodes, 10);
+
+	cpuset_propagate_hotplug_wq =
+		alloc_ordered_workqueue("cpuset_hotplug", 0);
+	BUG_ON(!cpuset_propagate_hotplug_wq);
 }
 
 /**
-- 
1.8.0.2
