From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3 2/7] cpuset: remove async hotplug propagation work
Date: Sun, 9 Jun 2013 17:14:47 +0800
Message-ID: <51B44787.2030601@huawei.com>
References: <51B4475A.8030509@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51B4475A.8030509-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

As we can drop rcu read lock while iterating cgroup hierarchy,
we don't have to do propagation asynchronously via workqueue.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 69 +++++++++++++--------------------------------------------
 1 file changed, 16 insertions(+), 53 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 5ffcc3b..2d68d5c 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -101,8 +101,6 @@ struct cpuset {
 
 	/* for custom sched domain */
 	int relax_domain_level;
-
-	struct work_struct hotplug_work;
 };
 
 /* Retrieve the cpuset for a cgroup */
@@ -268,12 +266,7 @@ static DEFINE_MUTEX(callback_mutex);
 /*
  * CPU / memory hotplug is handled asynchronously.
  */
-static struct workqueue_struct *cpuset_propagate_hotplug_wq;
-
 static void cpuset_hotplug_workfn(struct work_struct *work);
-static void cpuset_propagate_hotplug_workfn(struct work_struct *work);
-static void schedule_cpuset_propagate_hotplug(struct cpuset *cs);
-
 static DECLARE_WORK(cpuset_hotplug_work, cpuset_hotplug_workfn);
 
 static DECLARE_WAIT_QUEUE_HEAD(cpuset_attach_wq);
@@ -1554,7 +1547,6 @@ static int cpuset_write_resmask(struct cgroup *cgrp, struct cftype *cft,
 	 * after execution capability is restored.
 	 */
 	flush_work(&cpuset_hotplug_work);
-	flush_workqueue(cpuset_propagate_hotplug_wq);
 
 	mutex_lock(&cpuset_mutex);
 	if (!is_cpuset_online(cs))
@@ -1821,7 +1813,6 @@ static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cont)
 	cpumask_clear(cs->cpus_allowed);
 	nodes_clear(cs->mems_allowed);
 	fmeter_init(&cs->fmeter);
-	INIT_WORK(&cs->hotplug_work, cpuset_propagate_hotplug_workfn);
 	cs->relax_domain_level = -1;
 
 	return &cs->css;
@@ -1984,18 +1975,17 @@ static void remove_tasks_in_empty_cpuset(struct cpuset *cs)
 }
 
 /**
- * cpuset_propagate_hotplug_workfn - propagate CPU/memory hotplug to a cpuset
+ * cpuset_hotplug_update_tasks - update tasks in a cpuset for hotunplug
  * @cs: cpuset in interest
  *
  * Compare @cs's cpu and mem masks against top_cpuset and if some have gone
  * offline, update @cs accordingly.  If @cs ends up with no CPU or memory,
  * all its tasks are moved to the nearest ancestor with both resources.
  */
-static void cpuset_propagate_hotplug_workfn(struct work_struct *work)
+static void cpuset_hotplug_update_tasks(struct cpuset *cs)
 {
 	static cpumask_t off_cpus;
 	static nodemask_t off_mems, tmp_mems;
-	struct cpuset *cs = container_of(work, struct cpuset, hotplug_work);
 	bool is_empty;
 
 retry:
@@ -2044,34 +2034,6 @@ retry:
 	 */
 	if (is_empty)
 		remove_tasks_in_empty_cpuset(cs);
-
-	/* the following may free @cs, should be the last operation */
-	css_put(&cs->css);
-}
-
-/**
- * schedule_cpuset_propagate_hotplug - schedule hotplug propagation to a cpuset
- * @cs: cpuset of interest
- *
- * Schedule cpuset_propagate_hotplug_workfn() which will update CPU and
- * memory masks according to top_cpuset.
- */
-static void schedule_cpuset_propagate_hotplug(struct cpuset *cs)
-{
-	/*
-	 * Pin @cs.  The refcnt will be released when the work item
-	 * finishes executing.
-	 */
-	if (!css_tryget(&cs->css))
-		return;
-
-	/*
-	 * Queue @cs->hotplug_work.  If already pending, lose the css ref.
-	 * cpuset_propagate_hotplug_wq is ordered and propagation will
-	 * happen in the order this function is called.
-	 */
-	if (!queue_work(cpuset_propagate_hotplug_wq, &cs->hotplug_work))
-		css_put(&cs->css);
 }
 
 /**
@@ -2084,8 +2046,8 @@ static void schedule_cpuset_propagate_hotplug(struct cpuset *cs)
  * actively using CPU hotplug but making no active use of cpusets.
  *
  * Non-root cpusets are only affected by offlining.  If any CPUs or memory
- * nodes have been taken down, cpuset_propagate_hotplug() is invoked on all
- * descendants.
+ * nodes have been taken down, cpuset_hotplug_update_tasks() is invoked on
+ * all descendants.
  *
  * Note that CPU offlining during suspend is ignored.  We don't modify
  * cpusets across suspend/resume cycles at all.
@@ -2128,21 +2090,26 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 		update_tasks_nodemask(&top_cpuset, &tmp_mems, NULL);
 	}
 
+	mutex_unlock(&cpuset_mutex);
+
 	/* if cpus or mems went down, we need to propagate to descendants */
 	if (cpus_offlined || mems_offlined) {
 		struct cpuset *cs;
 		struct cgroup *pos_cgrp;
 
 		rcu_read_lock();
-		cpuset_for_each_descendant_pre(cs, pos_cgrp, &top_cpuset)
-			schedule_cpuset_propagate_hotplug(cs);
-		rcu_read_unlock();
-	}
+		cpuset_for_each_descendant_pre(cs, pos_cgrp, &top_cpuset) {
+			if (!css_tryget(&cs->css))
+				continue;
+			rcu_read_unlock();
 
-	mutex_unlock(&cpuset_mutex);
+			cpuset_hotplug_update_tasks(cs);
 
-	/* wait for propagations to finish */
-	flush_workqueue(cpuset_propagate_hotplug_wq);
+			rcu_read_lock();
+			css_put(&cs->css);
+		}
+		rcu_read_unlock();
+	}
 
 	/* rebuild sched domains if cpus_allowed has changed */
 	if (cpus_updated)
@@ -2193,10 +2160,6 @@ void __init cpuset_init_smp(void)
 	top_cpuset.mems_allowed = node_states[N_MEMORY];
 
 	register_hotmemory_notifier(&cpuset_track_online_nodes_nb);
-
-	cpuset_propagate_hotplug_wq =
-		alloc_ordered_workqueue("cpuset_hotplug", 0);
-	BUG_ON(!cpuset_propagate_hotplug_wq);
 }
 
 /**
-- 
1.8.0.2
