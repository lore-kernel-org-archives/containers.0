From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 1/3] cgroup: simplify double-check locking in
	cgroup_attach_proc
Date: Tue,  3 Jan 2012 21:18:30 -0800
Message-ID: <1325654312-32477-1-git-send-email-msb__45947.1514951021$1325654342$gmane$org@chromium.org>
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
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

To keep the complexity of the double-check locking in one place,
I moved the thread_group_leader check up into attach_task_by_pid.
This allows us to use a goto instead of returning -EAGAIN.

While at it, converted a couple of returns to gotos and used
rcu for the !pid case also in order to simplify the logic.

Changes in V2:
* https://lkml.org/lkml/2011/12/22/86 (Tejun Heo)
  * Use a goto instead of returning -EAGAIN

Signed-off-by: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
---
 kernel/cgroup.c |   79 ++++++++++++++++++++----------------------------------
 1 files changed, 29 insertions(+), 50 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 1042b3c..09867eb 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2104,19 +2104,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 
 	/* prevent changes to the threadgroup list while we take a snapshot. */
 	read_lock(&tasklist_lock);
-	if (!thread_group_leader(leader)) {
-		/*
-		 * a race with de_thread from another thread's exec() may strip
-		 * us of our leadership, making while_each_thread unsafe to use
-		 * on this task. if this happens, there is no choice but to
-		 * throw this task away and try again (from cgroup_procs_write);
-		 * this is "double-double-toil-and-trouble-check locking".
-		 */
-		read_unlock(&tasklist_lock);
-		retval = -EAGAIN;
-		goto out_free_group_list;
-	}
-
 	tsk = leader;
 	i = 0;
 	do {
@@ -2242,22 +2229,14 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 	if (!cgroup_lock_live_group(cgrp))
 		return -ENODEV;
 
+retry_find_task:
+	rcu_read_lock();
 	if (pid) {
-		rcu_read_lock();
 		tsk = find_task_by_vpid(pid);
 		if (!tsk) {
 			rcu_read_unlock();
-			cgroup_unlock();
-			return -ESRCH;
-		}
-		if (threadgroup) {
-			/*
-			 * RCU protects this access, since tsk was found in the
-			 * tid map. a race with de_thread may cause group_leader
-			 * to stop being the leader, but cgroup_attach_proc will
-			 * detect it later.
-			 */
-			tsk = tsk->group_leader;
+			ret= -ESRCH;
+			goto out_unlock_cgroup;
 		}
 		/*
 		 * even if we're attaching all tasks in the thread group, we
@@ -2268,29 +2247,38 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 		    cred->euid != tcred->uid &&
 		    cred->euid != tcred->suid) {
 			rcu_read_unlock();
-			cgroup_unlock();
-			return -EACCES;
+			ret = -EACCES;
+			goto out_unlock_cgroup;
 		}
-		get_task_struct(tsk);
-		rcu_read_unlock();
-	} else {
-		if (threadgroup)
-			tsk = current->group_leader;
-		else
-			tsk = current;
-		get_task_struct(tsk);
-	}
-
-	threadgroup_lock(tsk);
+	} else
+		tsk = current;
 
 	if (threadgroup)
+		tsk = tsk->group_leader;
+	get_task_struct(tsk);
+	rcu_read_unlock();
+
+	threadgroup_lock(tsk);
+	if (threadgroup) {
+		if (!thread_group_leader(tsk)) {
+			/*
+			 * a race with de_thread from another thread's exec()
+			 * may strip us of our leadership, if this happens,
+			 * there is no choice but to throw this task away and
+			 * try again; this is
+			 * "double-double-toil-and-trouble-check locking".
+			 */
+			threadgroup_unlock(tsk);
+			put_task_struct(tsk);
+			goto retry_find_task;
+		}
 		ret = cgroup_attach_proc(cgrp, tsk);
-	else
+	} else
 		ret = cgroup_attach_task(cgrp, tsk);
-
 	threadgroup_unlock(tsk);
 
 	put_task_struct(tsk);
+out_unlock_cgroup:
 	cgroup_unlock();
 	return ret;
 }
@@ -2302,16 +2290,7 @@ static int cgroup_tasks_write(struct cgroup *cgrp, struct cftype *cft, u64 pid)
 
 static int cgroup_procs_write(struct cgroup *cgrp, struct cftype *cft, u64 tgid)
 {
-	int ret;
-	do {
-		/*
-		 * attach_proc fails with -EAGAIN if threadgroup leadership
-		 * changes in the middle of the operation, in which case we need
-		 * to find the task_struct for the new leader and start over.
-		 */
-		ret = attach_task_by_pid(cgrp, tgid, true);
-	} while (ret == -EAGAIN);
-	return ret;
+	return attach_task_by_pid(cgrp, tgid, true);
 }
 
 /**
-- 
1.7.3.1
