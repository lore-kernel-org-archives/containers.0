From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 09/11] cpuset: enable onlined cpu/node in effective masks
Date: Wed, 21 Aug 2013 18:01:05 +0800
Message-ID: <52148FE1.3080806@huawei.com>
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

Firstly offline cpu1:

  # echo 0-1 > cpuset.cpus
  # echo 0 > /sys/devices/system/cpu/cpu1/online
  # cat cpuset.cpus
  0-1
  # cat cpuset.effective_cpus
  0

Then online it:

  # echo 1 > /sys/devices/system/cpu/cpu1/online
  # cat cpuset.cpus
  0-1
  # cat cpuset.effective_cpus
  0-1

And cpuset will bring it back to the effective mask.

This is a behavior change for sane_behavior.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 140 +++++++++++++++++++++++++++++++-------------------------
 1 file changed, 77 insertions(+), 63 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index c3a02a9..20fc109 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2134,6 +2134,77 @@ static void remove_tasks_in_empty_cpuset(struct cpuset *cs)
 	}
 }
 
+static void hotplug_update_tasks_insane(struct cpuset *cs,
+					struct cpumask *off_cpus,
+					nodemask_t *off_mems)
+{
+	bool is_empty;
+
+	cpumask_andnot(off_cpus, cs->real_cpus_allowed,
+		       top_cpuset.real_cpus_allowed);
+	nodes_andnot(*off_mems, cs->real_mems_allowed,
+		     top_cpuset.real_mems_allowed);
+
+	mutex_lock(&callback_mutex);
+	cpumask_andnot(cs->cpus_allowed, cs->cpus_allowed, off_cpus);
+	cpumask_andnot(cs->real_cpus_allowed, cs->real_cpus_allowed, off_cpus);
+	nodes_andnot(cs->mems_allowed, cs->mems_allowed, *off_mems);
+	nodes_andnot(cs->real_mems_allowed, cs->real_mems_allowed, *off_mems);
+	mutex_unlock(&callback_mutex);
+
+	/*
+	 * Don't call update_tasks_cpumask() if the cpuset becomes empty,
+	 * as the tasks will be migrated to an ancestor.
+	 */
+	if (!cpumask_empty(off_cpus) && !cpumask_empty(cs->cpus_allowed))
+		update_tasks_cpumask(cs, NULL);
+
+	if (!nodes_empty(*off_mems) && !cpumask_empty(cs->cpus_allowed))
+		update_tasks_nodemask(cs, NULL);
+
+	is_empty = cpumask_empty(cs->cpus_allowed) ||
+		   nodes_empty(cs->mems_allowed);
+
+	mutex_unlock(&cpuset_mutex);
+	/*
+	 * Move tasks to the nearest ancestor with execution resources,
+	 * This is full cgroup operation which will also call back into
+	 * cpuset. Should be don outside any lock.
+	 */
+	if (is_empty)
+		remove_tasks_in_empty_cpuset(cs);
+	mutex_lock(&cpuset_mutex);
+}
+
+static void hotplug_update_tasks_sane(struct cpuset *cs,
+				      struct cpumask *new_cpus,
+				      nodemask_t *new_mems)
+{
+	struct cpuset *parent = parent_cs(cs);
+	bool update_cpus, update_mems;
+
+	cpumask_and(new_cpus, cs->cpus_allowed, parent->real_cpus_allowed);
+	if (cpumask_empty(new_cpus))
+		cpumask_copy(new_cpus, parent->real_cpus_allowed);
+
+	nodes_and(*new_mems, cs->mems_allowed, parent->real_mems_allowed);
+	if (nodes_empty(*new_mems))
+		*new_mems = parent->real_mems_allowed;
+
+	update_cpus = !cpumask_equal(cs->real_cpus_allowed, new_cpus);
+	update_mems = !nodes_equal(cs->real_mems_allowed, new_mems);
+
+	mutex_lock(&callback_mutex);
+	cpumask_copy(cs->real_cpus_allowed, new_cpus);
+	cs->real_mems_allowed = *new_mems;
+	mutex_unlock(&callback_mutex);
+
+	if (update_cpus)
+		update_tasks_cpumask(cs, NULL);
+	if (update_mems)
+		update_tasks_nodemask(cs, NULL);
+}
+
 /**
  * cpuset_hotplug_update_tasks - update tasks in a cpuset for hotunplug
  * @cs: cpuset in interest
@@ -2144,9 +2215,8 @@ static void remove_tasks_in_empty_cpuset(struct cpuset *cs)
  */
 static void cpuset_hotplug_update_tasks(struct cpuset *cs)
 {
-	static cpumask_t off_cpus;
-	static nodemask_t off_mems;
-	bool is_empty;
+	static cpumask_t tmp_cpus;
+	static nodemask_t tmp_mems;
 	bool sane = cgroup_sane_behavior(cs->css.cgroup);
 
 retry:
@@ -2163,67 +2233,11 @@ retry:
 		goto retry;
 	}
 
-	cpumask_andnot(&off_cpus, cs->real_cpus_allowed,
-		       top_cpuset.real_cpus_allowed);
-	nodes_andnot(off_mems, cs->real_mems_allowed,
-		     top_cpuset.real_mems_allowed);
-
-	mutex_lock(&callback_mutex);
-	if (!sane)
-		cpumask_andnot(cs->cpus_allowed, cs->cpus_allowed, &off_cpus);
-
-	cpumask_andnot(cs->real_cpus_allowed, cs->real_cpus_allowed,
-		       &off_cpus);
-	/* Inherite the effective mask of the parent, if it becomes empty */
-	if (cpumask_empty(cs->real_cpus_allowed))
-		cpumask_copy(cs->real_cpus_allowed,
-			     parent_cs(cs)->real_cpus_allowed);
-	mutex_unlock(&callback_mutex);
-
-	/*
-	 * If sane_behavior flag is set, we need to update tasks' cpumask
-	 * for empty cpuset to take on ancestor's cpumask. Otherwise, don't
-	 * call update_tasks_cpumask() if the cpuset becomes empty, as
-	 * the tasks in it will be migrated to an ancestor.
-	 */
-	if ((sane && cpumask_empty(cs->cpus_allowed)) ||
-	    (!cpumask_empty(&off_cpus) && !cpumask_empty(cs->cpus_allowed)))
-		update_tasks_cpumask(cs, NULL);
-
-	mutex_lock(&callback_mutex);
-	if (!sane)
-		nodes_andnot(cs->mems_allowed, cs->mems_allowed, off_mems);
-
-	nodes_andnot(cs->real_mems_allowed, cs->real_mems_allowed, off_mems);
-	/* Inherite the effective mask of the parent, if it becomes empty */
-	if (nodes_empty(cs->real_mems_allowed))
-		cs->real_mems_allowed = parent_cs(cs)->real_mems_allowed;
-	mutex_unlock(&callback_mutex);
-
-	/*
-	 * If sane_behavior flag is set, we need to update tasks' nodemask
-	 * for empty cpuset to take on ancestor's nodemask. Otherwise, don't
-	 * call update_tasks_nodemask() if the cpuset becomes empty, as
-	 * the tasks in it will be migratd to an ancestor.
-	 */
-	if ((sane && nodes_empty(cs->mems_allowed)) ||
-	    (!nodes_empty(off_mems) && !nodes_empty(cs->mems_allowed)))
-		update_tasks_nodemask(cs, NULL);
-
-	is_empty = cpumask_empty(cs->cpus_allowed) ||
-		nodes_empty(cs->mems_allowed);
-
+	if (sane)
+		hotplug_update_tasks_sane(cs, &tmp_cpus, &tmp_mems);
+	else
+		hotplug_update_tasks_insane(cs, &tmp_cpus, &tmp_mems);
 	mutex_unlock(&cpuset_mutex);
-
-	/*
-	 * If sane_behavior flag is set, we'll keep tasks in empty cpusets.
-	 *
-	 * Otherwise move tasks to the nearest ancestor with execution
-	 * resources.  This is full cgroup operation which will
-	 * also call back into cpuset.  Should be done outside any lock.
-	 */
-	if (!sane && is_empty)
-		remove_tasks_in_empty_cpuset(cs);
 }
 
 /**
-- 
1.8.0.2
