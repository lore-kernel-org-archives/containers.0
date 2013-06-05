From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 09/10] cpuset: allow to move tasks to empty cpusets
Date: Wed, 5 Jun 2013 17:17:13 +0800
Message-ID: <51AF0219.6070808@huawei.com>
References: <51AF0183.8070602@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51AF0183.8070602-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

Currently some cpuset behaviors are not friendly when cpuset is co-mounted
with other cgroup controllers.

Now with this patchset if cpuset is mounted with sane_behavior option,
it behaves differently:

- Tasks will be kept in empty cpusets when hotplug happens and take
  masks of ancestors with non-empty cpus/mems, instead of being moved to
  an ancestor.

- A task can be moved into an empty cpuset, and again it takes masks of
  ancestors, so the user can drop a task into a newly created cgroup without
  having to do anything for it.

As tasks can reside in empy cpusets, here're some rules:

- They can be moved to another cpuset, regardless it's empty or not.

- Though it takes masks from ancestors, it takes other configs from the
  empty cpuset.

- If the ancestors' masks are changed, those tasks will also be updated
  to take new masks.

v2: add documentation in include/linux/cgroup.h

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/linux/cgroup.h |  3 +++
 kernel/cpuset.c        | 12 +++++++++---
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 53e81a6..74e8b8e 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -281,6 +281,9 @@ enum {
 	 *   and take masks of ancestors with non-empty cpus/mems, instead of
 	 *   being moved to an ancestor.
 	 *
+	 * - cpuset: a task can be moved into an empty cpuset, and again it
+	 *   takes masks of ancestors.
+	 *
 	 * - memcg: use_hierarchy is on by default and the cgroup file for
 	 *   the flag is not created.
 	 *
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 3b93098..9bb6a47 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -483,7 +483,7 @@ static int validate_change(const struct cpuset *cur, const struct cpuset *trial)
 	 */
 	ret = -ENOSPC;
 	if ((cgroup_task_count(cur->css.cgroup) || cur->attach_in_progress) &&
-	    (cpumask_empty(trial->cpus_allowed) ||
+	    (cpumask_empty(trial->cpus_allowed) &&
 	     nodes_empty(trial->mems_allowed)))
 		goto out;
 
@@ -1478,8 +1478,13 @@ static int cpuset_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 
 	mutex_lock(&cpuset_mutex);
 
+	/*
+	 * We allow to move tasks into an empty cpuset if sane_behavior
+	 * flag is set.
+	 */
 	ret = -ENOSPC;
-	if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
+	if (!cgroup_sane_behavior(cgrp) &&
+	    (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed)))
 		goto out_unlock;
 
 	cgroup_taskset_for_each(task, cgrp, tset) {
@@ -1584,7 +1589,8 @@ static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 	 * propagation if @cs doesn't have any CPU or memory.  It will move
 	 * the newly added tasks to the nearest parent which can execute.
 	 */
-	if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
+	if (!cgroup_sane_behavior(cgrp) &&
+	    (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed)))
 		schedule_cpuset_propagate_hotplug(cs);
 
 	mutex_unlock(&cpuset_mutex);
-- 
1.8.0.2
