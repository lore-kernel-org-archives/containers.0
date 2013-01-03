From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/13] cpuset: don't nest cgroup_mutex inside get_online_cpus()
Date: Thu,  3 Jan 2013 13:36:02 -0800
Message-ID: <1357248967-24959-9-git-send-email-tj__25936.2797755331$1357249054$gmane$org@kernel.org>
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

CPU / memory hotplug path currently grabs cgroup_mutex from hotplug
event notifications.  We want to separate cpuset locking from cgroup
core and make cgroup_mutex outer to hotplug synchronization so that,
among other things, mechanisms which depend on get_online_cpus() can
be used from cgroup callbacks.  In general, we want to keep
cgroup_mutex the outermost lock to minimize locking interactions among
different controllers.

Convert cpuset_handle_hotplug() to cpuset_hotplug_workfn() and
schedule it from the hotplug notifications.  As the function can
already handle multiple mixed events without any input, converting it
to a work function is mostly trivial; however, one complication is
that cpuset_update_active_cpus() needs to update sched domains
synchronously to reflect an offlined cpu to avoid confusing the
scheduler.  This is worked around by falling back to the the default
single sched domain synchronously before scheduling the actual hotplug
work.  This makes sched domain rebuilt twice per CPU hotplug event but
the operation isn't that heavy and a lot of the second operation would
be noop for systems w/ single sched domain, which is the common case.

This decouples cpuset hotplug handling from the notification callbacks
and there can be an arbitrary delay between the actual event and
updates to cpusets.  Scheduler and mm can handle it fine but moving
tasks out of an empty cpuset may race against writes to the cpuset
restoring execution resources which can lead to confusing behavior.
Flush hotplug work item from cpuset_write_resmask() to avoid such
confusions.

v2: Synchronous sched domain rebuilding using the fallback sched
    domain added.  This fixes various issues caused by confused
    scheduler putting tasks on a dead CPU, including the one reported
    by Li Zefan.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 39 +++++++++++++++++++++++++++++++++++----
 1 file changed, 35 insertions(+), 4 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 3d448e6..658eb1a 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -260,6 +260,13 @@ static char cpuset_nodelist[CPUSET_NODELIST_LEN];
 static DEFINE_SPINLOCK(cpuset_buffer_lock);
 
 /*
+ * CPU / memory hotplug is handled asynchronously.
+ */
+static void cpuset_hotplug_workfn(struct work_struct *work);
+
+static DECLARE_WORK(cpuset_hotplug_work, cpuset_hotplug_workfn);
+
+/*
  * This is ugly, but preserves the userspace API for existing cpuset
  * users. If someone tries to mount the "cpuset" filesystem, we
  * silently switch it to mount "cgroup" instead
@@ -1565,6 +1572,19 @@ static int cpuset_write_resmask(struct cgroup *cgrp, struct cftype *cft,
 	struct cpuset *cs = cgroup_cs(cgrp);
 	struct cpuset *trialcs;
 
+	/*
+	 * CPU or memory hotunplug may leave @cs w/o any execution
+	 * resources, in which case the hotplug code asynchronously updates
+	 * configuration and transfers all tasks to the nearest ancestor
+	 * which can execute.
+	 *
+	 * As writes to "cpus" or "mems" may restore @cs's execution
+	 * resources, wait for the previously scheduled operations before
+	 * proceeding, so that we don't end up keep removing tasks added
+	 * after execution capability is restored.
+	 */
+	flush_work(&cpuset_hotplug_work);
+
 	if (!cgroup_lock_live_group(cgrp))
 		return -ENODEV;
 
@@ -2095,7 +2115,7 @@ static void cpuset_propagate_hotplug(struct cpuset *cs)
 }
 
 /**
- * cpuset_handle_hotplug - handle CPU/memory hot[un]plug
+ * cpuset_hotplug_workfn - handle CPU/memory hotunplug for a cpuset
  *
  * This function is called after either CPU or memory configuration has
  * changed and updates cpuset accordingly.  The top_cpuset is always
@@ -2110,7 +2130,7 @@ static void cpuset_propagate_hotplug(struct cpuset *cs)
  * Note that CPU offlining during suspend is ignored.  We don't modify
  * cpusets across suspend/resume cycles at all.
  */
-static void cpuset_handle_hotplug(void)
+static void cpuset_hotplug_workfn(struct work_struct *work)
 {
 	static cpumask_t new_cpus, tmp_cpus;
 	static nodemask_t new_mems, tmp_mems;
@@ -2177,7 +2197,18 @@ static void cpuset_handle_hotplug(void)
 
 void cpuset_update_active_cpus(bool cpu_online)
 {
-	cpuset_handle_hotplug();
+	/*
+	 * We're inside cpu hotplug critical region which usually nests
+	 * inside cgroup synchronization.  Bounce actual hotplug processing
+	 * to a work item to avoid reverse locking order.
+	 *
+	 * We still need to do partition_sched_domains() synchronously;
+	 * otherwise, the scheduler will get confused and put tasks to the
+	 * dead CPU.  Fall back to the default single domain.
+	 * cpuset_hotplug_workfn() will rebuild it as necessary.
+	 */
+	partition_sched_domains(1, NULL, NULL);
+	schedule_work(&cpuset_hotplug_work);
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
@@ -2189,7 +2220,7 @@ void cpuset_update_active_cpus(bool cpu_online)
 static int cpuset_track_online_nodes(struct notifier_block *self,
 				unsigned long action, void *arg)
 {
-	cpuset_handle_hotplug();
+	schedule_work(&cpuset_hotplug_work);
 	return NOTIFY_OK;
 }
 #endif
-- 
1.8.0.2
