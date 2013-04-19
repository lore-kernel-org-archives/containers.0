From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 05/10] cpuset: don't update tasks' cpumask and nodemask in
	an empty cpuset
Date: Fri, 19 Apr 2013 20:27:05 +0800
Message-ID: <51713819.8050708__31674.4247953922$1366374446$gmane$org@huawei.com>
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

I think this was introduced unintentionally when cpuset hotplug was
made asynchronous. Fortunately it does no harm, as updating tasks'
cpumask will just return failure and there's a guarantee_online_mems()
when updating nodemask, and then the tasks will be moved to an ancestor
cpuset.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 8b0e433..2e4c5af 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2013,7 +2013,9 @@ static void cpuset_propagate_hotplug_workfn(struct work_struct *work)
 		mutex_lock(&callback_mutex);
 		cpumask_andnot(cs->cpus_allowed, cs->cpus_allowed, &off_cpus);
 		mutex_unlock(&callback_mutex);
-		update_tasks_cpumask(cs, NULL);
+
+		if (!cpumask_empty(cs->cpus_allowed))
+			update_tasks_cpumask(cs, NULL);
 	}
 
 	/* remove offline mems from @cs */
@@ -2022,7 +2024,9 @@ static void cpuset_propagate_hotplug_workfn(struct work_struct *work)
 		mutex_lock(&callback_mutex);
 		nodes_andnot(cs->mems_allowed, cs->mems_allowed, off_mems);
 		mutex_unlock(&callback_mutex);
-		update_tasks_nodemask(cs, &tmp_mems, NULL);
+
+		if (!nodes_empty(cs->mems_allowed))
+			update_tasks_nodemask(cs, &tmp_mems, NULL);
 	}
 
 	is_empty = cpumask_empty(cs->cpus_allowed) ||
-- 
1.8.0.2
