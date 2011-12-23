From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 1/3] cgroup: remove tasklist_lock from cgroup_attach_proc
Date: Thu, 22 Dec 2011 16:57:51 -0800
Message-ID: <1324601873-20773-1-git-send-email-msb@chromium.org>
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
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Since cgroup_attach_proc is protected by a threadgroup_lock, we
no longer need a tasklist_lock to protect while_each_thread.
To keep the complexity of the double-check locking in one place,
I also moved the thread_group_leader check up into
attach_task_by_pid.

While at it, also converted a couple of returns to gotos.

The suggestion was made here:

https://lkml.org/lkml/2011/12/22/86

Suggested-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
---
 kernel/cgroup.c |   52 +++++++++++++++++++++-------------------------------
 1 files changed, 21 insertions(+), 31 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 1042b3c..032139d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2102,21 +2102,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	if (retval)
 		goto out_free_group_list;
 
-	/* prevent changes to the threadgroup list while we take a snapshot. */
-	read_lock(&tasklist_lock);
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
@@ -2145,7 +2130,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	group_size = i;
 	tset.tc_array = group;
 	tset.tc_array_len = group_size;
-	read_unlock(&tasklist_lock);
 
 	/* methods shouldn't be called if no task is actually migrating */
 	retval = 0;
@@ -2247,18 +2231,12 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 		tsk = find_task_by_vpid(pid);
 		if (!tsk) {
 			rcu_read_unlock();
-			cgroup_unlock();
-			return -ESRCH;
+			ret= -ESRCH;
+			goto out_unlock_cgroup;
 		}
-		if (threadgroup) {
-			/*
-			 * RCU protects this access, since tsk was found in the
-			 * tid map. a race with de_thread may cause group_leader
-			 * to stop being the leader, but cgroup_attach_proc will
-			 * detect it later.
-			 */
+		/* we check later for a group_leader race with de_thread */
+		if (threadgroup)
 			tsk = tsk->group_leader;
-		}
 		/*
 		 * even if we're attaching all tasks in the thread group, we
 		 * only need to check permissions on one of them.
@@ -2268,8 +2246,8 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 		    cred->euid != tcred->uid &&
 		    cred->euid != tcred->suid) {
 			rcu_read_unlock();
-			cgroup_unlock();
-			return -EACCES;
+			ret = -EACCES;
+			goto out_unlock_cgroup;
 		}
 		get_task_struct(tsk);
 		rcu_read_unlock();
@@ -2283,14 +2261,26 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 
 	threadgroup_lock(tsk);
 
-	if (threadgroup)
+	if (threadgroup) {
+		if (!thread_group_leader(tsk)) {
+			/*
+			 * a race with de_thread from another thread's exec()
+			 * may strip us of our leadership, if this happens,
+			 * there is no choice but to throw this task away and
+			 * try again (from cgroup_procs_write); this is
+			 * "double-double-toil-and-trouble-check locking".
+			 */
+			ret = -EAGAIN;
+			goto out_unlock_threadgroup;
+		}
 		ret = cgroup_attach_proc(cgrp, tsk);
-	else
+	} else
 		ret = cgroup_attach_task(cgrp, tsk);
 
+out_unlock_threadgroup:
 	threadgroup_unlock(tsk);
-
 	put_task_struct(tsk);
+out_unlock_cgroup:
 	cgroup_unlock();
 	return ret;
 }
-- 
1.7.3.1
