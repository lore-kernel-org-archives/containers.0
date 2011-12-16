From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH] cgroup: remove redundate get/put of old css_set from migrate
Date: Fri, 16 Dec 2011 08:38:31 -0800
Message-ID: <1324053511-24591-1-git-send-email-msb@chromium.org>
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

We can now assume that the css_set reference held by the task
will not go away for an exiting task. PF_EXITING state can be
trusted throughout migration by checking it after locking
threadgroup.

This patch depends on:

commit cd3d095275374220921fcf0d4e0c16584b26ddbc
Author: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date:   Mon Dec 12 18:12:21 2011 -0800

    cgroup: always lock threadgroup during migration

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
 kernel/cgroup.c |   25 ++++++-------------------
 1 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 1b3b841..eb95e32 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1856,7 +1856,6 @@ static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
 	 */
 	task_lock(tsk);
 	oldcg = tsk->cgroups;
-	get_css_set(oldcg);
 	task_unlock(tsk);
 
 	/* locate or allocate a new css_set for this task. */
@@ -1872,12 +1871,9 @@ static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
 		might_sleep();
 		/* find_css_set will give us newcg already referenced. */
 		newcg = find_css_set(oldcg, cgrp);
-		if (!newcg) {
-			put_css_set(oldcg);
+		if (!newcg)
 			return -ENOMEM;
-		}
 	}
-	put_css_set(oldcg);
 
 	/* @tsk can't exit as its threadgroup is locked */
 	task_lock(tsk);
@@ -2015,9 +2011,8 @@ struct cg_list_entry {
 	struct list_head links;
 };
 
-static bool css_set_check_fetched(struct cgroup *cgrp,
-				  struct task_struct *tsk, struct css_set *cg,
-				  struct list_head *newcg_list)
+static bool css_set_fetched(struct cgroup *cgrp, struct task_struct *tsk,
+			    struct css_set *cg, struct list_head *newcg_list)
 {
 	struct css_set *newcg;
 	struct cg_list_entry *cg_entry;
@@ -2191,19 +2186,11 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 		/* get old css_set pointer */
 		task_lock(tc->task);
 		oldcg = tc->task->cgroups;
-		get_css_set(oldcg);
 		task_unlock(tc->task);
-		/* see if the new one for us is already in the list? */
-		if (css_set_check_fetched(cgrp, tc->task, oldcg, &newcg_list)) {
-			/* was already there, nothing to do. */
-			put_css_set(oldcg);
-		} else {
-			/* we don't already have it. get new one. */
-			retval = css_set_prefetch(cgrp, oldcg, &newcg_list);
-			put_css_set(oldcg);
-			if (retval)
+		/* if we don't already have it in the list get a new one */
+		if (!css_set_fetched(cgrp, tc->task, oldcg, &newcg_list))
+			if (css_set_prefetch(cgrp, oldcg, &newcg_list))
 				goto out_list_teardown;
-		}
 	}
 
 	/*
-- 
1.7.3.1
