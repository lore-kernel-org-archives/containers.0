From: Jeff Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cgroup: don't show pid list on tasks/procs in ascending order
Date: Tue, 15 Jan 2013 13:28:34 +0800
Message-ID: <50F4E902.20202__47186.8193395951$1358227751$gmane$org@oracle.com>
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
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

Currently, the pid list shown on cgroup->procs & tasks is in ascending order.  However, this list is not
guaranteed to be sorted according to the following records mentioned at Documentation/cgroups/cgroups.txt.

 - tasks: list of tasks (by PID) attached to that cgroup.  This list
   is not guaranteed to be sorted. 
 - cgroup.procs: list of thread group IDs in the cgroup.  This list is
   not guaranteed to be sorted or free of duplicate TGIDs, and userspace
   should sort/uniquify the list if this property is required.

This patch remove the sorting function to make the default behavior of pid list be consistent with
the document.

Without patch:
# echo 2942 >> /cgroup/test/tasks 
# echo 2803 >> /cgroup/test/tasks 
# echo 2911 >> /cgroup/test/tasks
# echo 2761 >> /cgroup/test/tasks 
# cat /cgroup/test/tasks 
2761
2803
2911
2942
# cat /cgroup/test/cgroup.procs
2761
2803
2911
2942

Patch applied:
# echo 3042 >> /cgroup/testfixed/tasks
# echo 2916 >> /cgroup/testfixed/tasks
# echo 2781 >> /cgroup/testfixed/tasks
# echo 2527 >> /cgroup/testfixed/tasks
# cat /cgroup/testfixed/tasks 
2916
3042
2527
2781
# cat /cgroup/testfixed/cgroup.procs 
2916
3042
2527
2781


Signed-off-by: Jie Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

---
 kernel/cgroup.c |    9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f24f724..2b5b477 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -47,7 +47,6 @@
 #include <linux/magic.h>
 #include <linux/spinlock.h>
 #include <linux/string.h>
-#include <linux/sort.h>
 #include <linux/kmod.h>
 #include <linux/module.h>
 #include <linux/delayacct.h>
@@ -3374,11 +3373,6 @@ after:
 	return dest;
 }
 
-static int cmppid(const void *a, const void *b)
-{
-	return *(pid_t *)a - *(pid_t *)b;
-}
-
 /*
  * find the appropriate pidlist for our purpose (given procs vs tasks)
  * returns with the lock on that pidlist already held, and takes care
@@ -3463,8 +3457,7 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
 	}
 	cgroup_iter_end(cgrp, &it);
 	length = n;
-	/* now sort & (if procs) strip out duplicates */
-	sort(array, length, sizeof(pid_t), cmppid, NULL);
+	/* if procs, strip out duplicates */
 	if (type == CGROUP_FILE_PROCS)
 		length = pidlist_uniq(&array, length);
 	l = cgroup_pidlist_find(cgrp, type);
-- 
1.7.9.5
