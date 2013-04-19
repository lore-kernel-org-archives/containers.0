From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 04/10] cpuset: remove cpuset_test_cpumask()
Date: Fri, 19 Apr 2013 20:26:15 +0800
Message-ID: <517137E7.20505@huawei.com>
References: <517137A7.4020605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <517137A7.4020605-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

The test is done in set_cpus_allowed_ptr(), so it's redundant.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 66302a9..8b0e433 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -783,23 +783,6 @@ void rebuild_sched_domains(void)
 }
 
 /**
- * cpuset_test_cpumask - test a task's cpus_allowed versus its cpuset's
- * @tsk: task to test
- * @scan: struct cgroup_scanner contained in its struct cpuset_hotplug_scanner
- *
- * Call with cpuset_mutex held.  May take callback_mutex during call.
- * Called for each task in a cgroup by cgroup_scan_tasks().
- * Return nonzero if this tasks's cpus_allowed mask should be changed (in other
- * words, if its mask is not equal to its cpuset's mask).
- */
-static int cpuset_test_cpumask(struct task_struct *tsk,
-			       struct cgroup_scanner *scan)
-{
-	return !cpumask_equal(&tsk->cpus_allowed,
-			(cgroup_cs(scan->cg))->cpus_allowed);
-}
-
-/**
  * cpuset_change_cpumask - make a task's cpus_allowed the same as its cpuset's
  * @tsk: task to test
  * @scan: struct cgroup_scanner containing the cgroup of the task
@@ -834,7 +817,7 @@ static void update_tasks_cpumask(struct cpuset *cs, struct ptr_heap *heap)
 	struct cgroup_scanner scan;
 
 	scan.cg = cs->css.cgroup;
-	scan.test_task = cpuset_test_cpumask;
+	scan.test_task = NULL;
 	scan.process_task = cpuset_change_cpumask;
 	scan.heap = heap;
 	cgroup_scan_tasks(&scan);
-- 
1.8.0.2
