From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 2/4] cgroup: remove redundant get/put of task struct
Date: Wed, 21 Dec 2011 20:18:36 -0800
Message-ID: <1324527518-24461-2-git-send-email-msb@chromium.org>
References: <1324527518-24461-1-git-send-email-msb@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1324527518-24461-1-git-send-email-msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
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

threadgroup_lock() guarantees that the target threadgroup will
remain stable - no new task will be added, no new PF_EXITING
will be set and exec won't happen.

Changes in V2:
* https://lkml.org/lkml/2011/12/20/369 (Tejun Heo)
  * Undo incorrect removal of get/put from attach_task_by_pid()
* Author
  * Remove a comment which is made stale by this change

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
 kernel/cgroup.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 8228808..a85a700 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2116,7 +2116,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 		retval = -EAGAIN;
 		goto out_free_group_list;
 	}
-	/* take a reference on each task in the group to go in the array. */
+
 	tsk = leader;
 	i = nr_migrating_tasks = 0;
 	do {
@@ -2128,7 +2128,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 
 		/* as per above, nr_threads may decrease, but not increase. */
 		BUG_ON(i >= group_size);
-		get_task_struct(tsk);
 		/*
 		 * saying GFP_ATOMIC has no effect here because we did prealloc
 		 * earlier, but it's good form to communicate our expectations.
@@ -2150,7 +2149,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	/* methods shouldn't be called if no task is actually migrating */
 	retval = 0;
 	if (!nr_migrating_tasks)
-		goto out_put_tasks;
+		goto out_free_group_list;
 
 	/*
 	 * step 1: check that we can legitimately attach to the cgroup.
@@ -2234,12 +2233,6 @@ out_cancel_attach:
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
-- 
1.7.3.1
