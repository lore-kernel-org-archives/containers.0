From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3 1/7] cpuset: let hotplug propagation work wait for task
	attaching
Date: Sun, 9 Jun 2013 17:14:22 +0800
Message-ID: <51B4476E.90202__25297.5331306972$1370769312$gmane$org@huawei.com>
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

Instead of triggering porpagation work in cpuset_attach(), we make
hotplug propagation work wait until there's no task attaching in
progress.

IMO this is more robust. We won't see empty masks in cpuset_attach().

Also it's a preparation for removing propagation work. Without asynchronous
propagation we can't call move_tasks_in_empty_cpuset() in cpuset_attach(),
because otherwise we'll deadlock on cgroup_mutex.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 535dce6..5ffcc3b 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -59,6 +59,7 @@
 #include <linux/mutex.h>
 #include <linux/workqueue.h>
 #include <linux/cgroup.h>
+#include <linux/wait.h>
 
 /*
  * Tracks how many cpusets are currently defined in system.
@@ -275,6 +276,8 @@ static void schedule_cpuset_propagate_hotplug(struct cpuset *cs);
 
 static DECLARE_WORK(cpuset_hotplug_work, cpuset_hotplug_workfn);
 
+static DECLARE_WAIT_QUEUE_HEAD(cpuset_attach_wq);
+
 /*
  * This is ugly, but preserves the userspace API for existing cpuset
  * users. If someone tries to mount the "cpuset" filesystem, we
@@ -1436,14 +1439,8 @@ static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 	}
 
 	cs->attach_in_progress--;
-
-	/*
-	 * We may have raced with CPU/memory hotunplug.  Trigger hotplug
-	 * propagation if @cs doesn't have any CPU or memory.  It will move
-	 * the newly added tasks to the nearest parent which can execute.
-	 */
-	if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
-		schedule_cpuset_propagate_hotplug(cs);
+	if (!cs->attach_in_progress)
+		wake_up(&cpuset_attach_wq);
 
 	mutex_unlock(&cpuset_mutex);
 }
@@ -1555,10 +1552,6 @@ static int cpuset_write_resmask(struct cgroup *cgrp, struct cftype *cft,
 	 * resources, wait for the previously scheduled operations before
 	 * proceeding, so that we don't end up keep removing tasks added
 	 * after execution capability is restored.
-	 *
-	 * Flushing cpuset_hotplug_work is enough to synchronize against
-	 * hotplug hanlding; however, cpuset_attach() may schedule
-	 * propagation work directly.  Flush the workqueue too.
 	 */
 	flush_work(&cpuset_hotplug_work);
 	flush_workqueue(cpuset_propagate_hotplug_wq);
@@ -2005,8 +1998,20 @@ static void cpuset_propagate_hotplug_workfn(struct work_struct *work)
 	struct cpuset *cs = container_of(work, struct cpuset, hotplug_work);
 	bool is_empty;
 
+retry:
+	wait_event(cpuset_attach_wq, cs->attach_in_progress == 0);
+
 	mutex_lock(&cpuset_mutex);
 
+	/*
+	 * We have raced with task attaching. We wait util attaching
+	 * is finished, so we won't attach a task to an empty cpuset.
+	 */
+	if (cs->attach_in_progress) {
+		mutex_unlock(&cpuset_mutex);
+		goto retry;
+	}
+
 	cpumask_andnot(&off_cpus, cs->cpus_allowed, top_cpuset.cpus_allowed);
 	nodes_andnot(off_mems, cs->mems_allowed, top_cpuset.mems_allowed);
 
-- 
1.8.0.2
