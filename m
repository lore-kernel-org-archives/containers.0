From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v4 7/7] cpuset: fix to migrate mm correctly in a corner case
Date: Thu, 13 Jun 2013 15:11:44 +0800
Message-ID: <51B970B0.2040907__30262.1077782989$1371107584$gmane$org@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

Before moving tasks out of empty cpusets, update_tasks_nodemask()
is called, which calls do_migrate_pages(xx, from, to). Then those
tasks are moved to an ancestor, and do_migrate_pages() is called
again.

The first time: from = node_to_be_offlined, to = empty.
The second time: from = empty, to = ancestor's nodemask.

so looks like no pages will be migrated.

Fix this by:

- Don't call update_tasks_nodemask() on empty cpusets.
- Pass cs->old_mems_allowed to do_migrate_pages().

v4: added comment in cpuset_hotplug_update_tasks() and rephased comment
    in cpuset_attach().

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 25 +++++++++++++++++++------
 1 file changed, 19 insertions(+), 6 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index d1d6782..3be9597 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1563,9 +1563,18 @@ static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 		struct cpuset *mems_oldcs = effective_nodemask_cpuset(oldcs);
 
 		mpol_rebind_mm(mm, &cpuset_attach_nodemask_to);
-		if (is_memory_migrate(cs))
-			cpuset_migrate_mm(mm, &mems_oldcs->mems_allowed,
+
+		/*
+		 * old_mems_allowed is the same with mems_allowed here, except
+		 * if this task is being moved automatically due to hotplug.
+		 * In that case @mems_allowed has been updated and is empty,
+		 * so @old_mems_allowed is the right nodesets that we migrate
+		 * mm from.
+		 */
+		if (is_memory_migrate(cs)) {
+			cpuset_migrate_mm(mm, &mems_oldcs->old_mems_allowed,
 					  &cpuset_attach_nodemask_to);
+		}
 		mmput(mm);
 	}
 
@@ -2152,10 +2161,12 @@ retry:
 
 	/*
 	 * If sane_behavior flag is set, we need to update tasks' cpumask
-	 * for empty cpuset to take on ancestor's cpumask.
+	 * for empty cpuset to take on ancestor's cpumask. Otherwise, don't
+	 * call update_tasks_cpumask() if the cpuset becomes empty, as
+	 * the tasks in it will be migrated to an ancestor.
 	 */
 	if ((sane && cpumask_empty(cs->cpus_allowed)) ||
-	    !cpumask_empty(&off_cpus))
+	    (!cpumask_empty(&off_cpus) && !cpumask_empty(cs->cpus_allowed)))
 		update_tasks_cpumask(cs, NULL);
 
 	mutex_lock(&callback_mutex);
@@ -2164,10 +2175,12 @@ retry:
 
 	/*
 	 * If sane_behavior flag is set, we need to update tasks' nodemask
-	 * for empty cpuset to take on ancestor's nodemask.
+	 * for empty cpuset to take on ancestor's nodemask. Otherwise, don't
+	 * call update_tasks_nodemask() if the cpuset becomes empty, as
+	 * the tasks in it will be migratd to an ancestor.
 	 */
 	if ((sane && nodes_empty(cs->mems_allowed)) ||
-	    !nodes_empty(off_mems))
+	    (!nodes_empty(off_mems) && !nodes_empty(cs->mems_allowed)))
 		update_tasks_nodemask(cs, NULL);
 
 	is_empty = cpumask_empty(cs->cpus_allowed) ||
-- 
1.8.0.2
