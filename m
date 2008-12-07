From: gowrishankar <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH] cgroups: skip processes from other namespaces when listing
	a cgroup
Date: Sun, 07 Dec 2008 20:16:01 +0530
Message-ID: <493BE1A9.8030503@linux.vnet.ibm.com>
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
To: akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Balbir <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Once tasks are populated from system namespace inside cgroup,
container replaces other namespace task with 0 while listing tasks,
inside container.

Though this is expected behaviour from container end, there is
no use of showing unwanted 0s.

In below patch, we check if a process is in same namespace before
loading into pid array.

Signed-off-by: Gowrishankar M <gowrishankar.m-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

changes for vpid and pid_t
---
 kernel/cgroup.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 35eebd5..588d305 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2012,13 +2012,15 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
 static int pid_array_load(pid_t *pidarray, int npids, struct cgroup *cgrp)
 {
     int n = 0;
+    pid_t vpid;
     struct cgroup_iter it;
     struct task_struct *tsk;
     cgroup_iter_start(cgrp, &it);
     while ((tsk = cgroup_iter_next(cgrp, &it))) {
         if (unlikely(n == npids))
             break;
-        pidarray[n++] = task_pid_vnr(tsk);
+        if ((vpid = task_pid_vnr(tsk)) > 0)
+            pidarray[n++] = vpid;
     }
     cgroup_iter_end(cgrp, &it);
     return n;
-- 
1.5.5.1
