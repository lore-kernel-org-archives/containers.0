From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 03/10] cpuset: remove unnecessary variable in cpuset_attach()
Date: Fri, 19 Apr 2013 20:26:04 +0800
Message-ID: <517137DC.8060401__22789.4528456547$1366374381$gmane$org@huawei.com>
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

We can just use oldcs->mems_allowed.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 6f9d5e0..66302a9 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1406,8 +1406,7 @@ static cpumask_var_t cpus_attach;
 
 static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 {
-	/* static bufs protected by cpuset_mutex */
-	static nodemask_t cpuset_attach_nodemask_from;
+	/* static buf protected by cpuset_mutex */
 	static nodemask_t cpuset_attach_nodemask_to;
 	struct mm_struct *mm;
 	struct task_struct *task;
@@ -1441,13 +1440,12 @@ static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 	 * Change mm, possibly for multiple threads in a threadgroup. This is
 	 * expensive and may sleep.
 	 */
-	cpuset_attach_nodemask_from = oldcs->mems_allowed;
 	cpuset_attach_nodemask_to = cs->mems_allowed;
 	mm = get_task_mm(leader);
 	if (mm) {
 		mpol_rebind_mm(mm, &cpuset_attach_nodemask_to);
 		if (is_memory_migrate(cs))
-			cpuset_migrate_mm(mm, &cpuset_attach_nodemask_from,
+			cpuset_migrate_mm(mm, &oldcs->mems_allowed,
 					  &cpuset_attach_nodemask_to);
 		mmput(mm);
 	}
-- 
1.8.0.2
