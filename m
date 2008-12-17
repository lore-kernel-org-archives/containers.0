From: Gowrishankar M <gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH] cgroups: add task along with its threads in one shot inside
	cgroup
Date: Thu, 18 Dec 2008 02:00:26 +0530
Message-ID: <1229545826-16978-1-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
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
To: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Gowrishankar M <gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Dave <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Eric <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sukadev <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Balbir <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Gowrishankar M <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

In current model, task by task we populate cgroup.
Incase of multi-threaded task, it becomes difficult
as we should first know about list of threads created
and add them one by one in cgroup.

In below patch, when a thread group leader is scanned,
belonging threads are also moved along with it, while
populating cgroup tasks.

Below steps can help to verify the patch:
(1) mount -t cgroup -o cpuset cgroup /cgroup
(2) /bin/mkdir /cgroup/testgroup and cd /cgroup/testgroup
(3) /bin/echo 0 > cpuset.mems
(4) /bin/echo 0 > cpuset.cpus
(5) /bin/echo "<PID of thread group leader>" > tasks (tip: ps -aeL)
(6) cat tasks and check for thread ids.

Signed-off-by: Gowrishankar M <gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 kernel/cgroup.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 35eebd5..de7f0cc 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1279,6 +1279,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 static int attach_task_by_pid(struct cgroup *cgrp, u64 pid)
 {
 	struct task_struct *tsk;
+	struct task_struct *p;
 	int ret;
 
 	if (pid) {
@@ -1288,21 +1289,23 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid)
 			rcu_read_unlock();
 			return -ESRCH;
 		}
-		get_task_struct(tsk);
 		rcu_read_unlock();
 
 		if ((current->euid) && (current->euid != tsk->uid)
 		    && (current->euid != tsk->suid)) {
-			put_task_struct(tsk);
 			return -EACCES;
 		}
-	} else {
+	} else
 		tsk = current;
-		get_task_struct(tsk);
-	}
 
-	ret = cgroup_attach_task(cgrp, tsk);
-	put_task_struct(tsk);
+	p = tsk;
+	do {
+		get_task_struct(p);
+		ret = cgroup_attach_task(cgrp, p);
+		put_task_struct(p);
+		if (thread_group_empty(p) && !(has_group_leader_pid(p)))
+			break;
+	} while_each_thread(tsk, p);
 	return ret;
 }
 
-- 
1.5.5.1
