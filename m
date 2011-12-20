From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 2/5] cgroup: remove redundant get/put of task struct
Date: Tue, 20 Dec 2011 15:14:30 -0800
Message-ID: <1324422873-31001-3-git-send-email-msb@chromium.org>
References: <1324422873-31001-1-git-send-email-msb@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1324422873-31001-1-git-send-email-msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

threadgroup_lock() guarantees that the target threadgroup will
remain stable - no new task will be added, no new PF_EXITING
will be set and exec won't happen.

Signed-off-by: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
---
 kernel/cgroup.c |   12 +-----------
 1 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 4166066..6649529 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2130,7 +2130,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 
 		/* as per above, nr_threads may decrease, but not increase. */
 		BUG_ON(i >= group_size);
-		get_task_struct(tsk);
 		/*
 		 * saying GFP_ATOMIC has no effect here because we did prealloc
 		 * earlier, but it's good form to communicate our expectations.
@@ -2152,7 +2151,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	/* methods shouldn't be called if no task is actually migrating */
 	retval = 0;
 	if (!nr_migrating_tasks)
-		goto out_put_tasks;
+		goto out_free_group_list;
 
 	/*
 	 * step 1: check that we can legitimately attach to the cgroup.
@@ -2233,12 +2232,6 @@ out_cancel_attach:
 				ss->cancel_attach(ss, cgrp, &tset);
 		}
 	}
-out_put_tasks:
-	/* clean up the array of referenced threads in the group. */
-	for (i = 0; i < group_size; i++) {
-		tc = flex_array_get(group, i);
-		put_task_struct(tc->task);
-	}
 out_free_group_list:
 	flex_array_free(group);
 	return retval;
@@ -2287,14 +2280,12 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 			cgroup_unlock();
 			return -EACCES;
 		}
-		get_task_struct(tsk);
 		rcu_read_unlock();
 	} else {
 		if (threadgroup)
 			tsk = current->group_leader;
 		else
 			tsk = current;
-		get_task_struct(tsk);
 	}
 
 	threadgroup_lock(tsk);
@@ -2306,7 +2297,6 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 
 	threadgroup_unlock(tsk);
 
-	put_task_struct(tsk);
 	cgroup_unlock();
 	return ret;
 }
-- 
1.7.3.1
