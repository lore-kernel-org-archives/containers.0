From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 08/11] cpuset: separate configured masks and efffective masks
Date: Wed, 21 Aug 2013 18:00:42 +0800
Message-ID: <52148FCA.8010704__36972.4371158101$1377079274$gmane$org@huawei.com>
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

Now we've used effective cpumasks to enforce hierarchical manner,
we can use cs->{cpus,mems}_allowed as configured masks.

Configured masks can be changed by writing cpuset.cpus and cpuset.mems
only. The new behaviors are:

- They won't be changed by hotplug anymore.
- They won't be limited by its parent's masks.

This behavior change won't take effect unless mount with sane_behavior.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index e7ad4a7..c3a02a9 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -457,9 +457,13 @@ static int validate_change(struct cpuset *cur, struct cpuset *trial)
 
 	par = parent_cs(cur);
 
-	/* We must be a subset of our parent cpuset */
+	/*
+	 * We must be a subset of our parent cpuset, unless sane_behavior
+	 * flag is set.
+	 */
 	ret = -EACCES;
-	if (!is_cpuset_subset(trial, par))
+	if (!cgroup_sane_behavior(cur->css.cgroup) &&
+	    !is_cpuset_subset(trial, par))
 		goto out;
 
 	/*
@@ -780,7 +784,7 @@ static void rebuild_sched_domains_locked(void)
 	 * passing doms with offlined cpu to partition_sched_domains().
 	 * Anyways, hotplug work item will rebuild sched domains.
 	 */
-	if (!cpumask_equal(top_cpuset.cpus_allowed, cpu_active_mask))
+	if (!cpumask_equal(top_cpuset.real_cpus_allowed, cpu_active_mask))
 		goto out;
 
 	/* Generate domain masks and attrs */
@@ -2159,11 +2163,14 @@ retry:
 		goto retry;
 	}
 
-	cpumask_andnot(&off_cpus, cs->cpus_allowed, top_cpuset.cpus_allowed);
-	nodes_andnot(off_mems, cs->mems_allowed, top_cpuset.mems_allowed);
+	cpumask_andnot(&off_cpus, cs->real_cpus_allowed,
+		       top_cpuset.real_cpus_allowed);
+	nodes_andnot(off_mems, cs->real_mems_allowed,
+		     top_cpuset.real_mems_allowed);
 
 	mutex_lock(&callback_mutex);
-	cpumask_andnot(cs->cpus_allowed, cs->cpus_allowed, &off_cpus);
+	if (!sane)
+		cpumask_andnot(cs->cpus_allowed, cs->cpus_allowed, &off_cpus);
 
 	cpumask_andnot(cs->real_cpus_allowed, cs->real_cpus_allowed,
 		       &off_cpus);
@@ -2184,7 +2191,8 @@ retry:
 		update_tasks_cpumask(cs, NULL);
 
 	mutex_lock(&callback_mutex);
-	nodes_andnot(cs->mems_allowed, cs->mems_allowed, off_mems);
+	if (!sane)
+		nodes_andnot(cs->mems_allowed, cs->mems_allowed, off_mems);
 
 	nodes_andnot(cs->real_mems_allowed, cs->real_mems_allowed, off_mems);
 	/* Inherite the effective mask of the parent, if it becomes empty */
@@ -2239,6 +2247,7 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 	static cpumask_t new_cpus;
 	static nodemask_t new_mems;
 	bool cpus_updated, mems_updated;
+	bool sane = cgroup_sane_behavior(top_cpuset.css.cgroup);
 
 	mutex_lock(&cpuset_mutex);
 
@@ -2246,13 +2255,14 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 	cpumask_copy(&new_cpus, cpu_active_mask);
 	new_mems = node_states[N_MEMORY];
 
-	cpus_updated = !cpumask_equal(top_cpuset.cpus_allowed, &new_cpus);
-	mems_updated = !nodes_equal(top_cpuset.mems_allowed, new_mems);
+	cpus_updated = !cpumask_equal(top_cpuset.real_cpus_allowed, &new_cpus);
+	mems_updated = !nodes_equal(top_cpuset.real_mems_allowed, new_mems);
 
 	/* synchronize cpus_allowed to cpu_active_mask */
 	if (cpus_updated) {
 		mutex_lock(&callback_mutex);
-		cpumask_copy(top_cpuset.cpus_allowed, &new_cpus);
+		if (!sane)
+			cpumask_copy(top_cpuset.cpus_allowed, &new_cpus);
 		cpumask_copy(top_cpuset.real_cpus_allowed, &new_cpus);
 		mutex_unlock(&callback_mutex);
 		/* we don't mess with cpumasks of tasks in top_cpuset */
@@ -2261,7 +2271,8 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 	/* synchronize mems_allowed to N_MEMORY */
 	if (mems_updated) {
 		mutex_lock(&callback_mutex);
-		top_cpuset.mems_allowed = new_mems;
+		if (!sane)
+			top_cpuset.mems_allowed = new_mems;
 		top_cpuset.real_mems_allowed = new_mems;
 		mutex_unlock(&callback_mutex);
 		update_tasks_nodemask(&top_cpuset, NULL);
-- 
1.8.0.2
