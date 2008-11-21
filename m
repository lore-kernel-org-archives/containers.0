From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cpuset: rcu_read_lock() to protect task_cs()
Date: Fri, 21 Nov 2008 16:49:37 +0800
Message-ID: <49267621.2070706__1919.84404013983$1227264726$gmane$org@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers@lists.l>
List-Id: containers.vger.kernel.org


task_cs() calls cgroup_subsys_state().

we must use rcu_read_lock() to protect cgroup_subsys_state().

it's correct that top_cpuset is never freed, but cgroup_subsys_state()
accesses css_set, this css_set maybe freed when task_cs() called.

we use use rcu_read_lock() to protect it.

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 3e00526..e0e087e 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -363,14 +363,9 @@ void cpuset_update_task_memory_state(void)
 	struct task_struct *tsk = current;
 	struct cpuset *cs;
 
-	if (task_cs(tsk) == &top_cpuset) {
-		/* Don't need rcu for top_cpuset.  It's never freed. */
-		my_cpusets_mem_gen = top_cpuset.mems_generation;
-	} else {
-		rcu_read_lock();
-		my_cpusets_mem_gen = task_cs(tsk)->mems_generation;
-		rcu_read_unlock();
-	}
+	rcu_read_lock();
+	my_cpusets_mem_gen = task_cs(tsk)->mems_generation;
+	rcu_read_unlock();
 
 	if (my_cpusets_mem_gen != tsk->cpuset_mems_generation) {
 		mutex_lock(&callback_mutex);
