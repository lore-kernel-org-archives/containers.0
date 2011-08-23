From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 6/6] cgroup: kill subsys->can_attach_task(),
	pre_attach() and attach_task()
Date: Wed, 24 Aug 2011 00:20:00 +0200
Message-ID: <1314138000-2049-7-git-send-email-tj__49801.2119591751$1314138563$gmane$org@kernel.org>
References: <1314138000-2049-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1314138000-2049-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: rjw-KKrjLPT3xs0@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

These three methods are no longer used.  Kill them.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/cgroup.h |    3 --
 kernel/cgroup.c        |   53 ++++-------------------------------------------
 2 files changed, 5 insertions(+), 51 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 2470c8e..5659d37 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -490,11 +490,8 @@ struct cgroup_subsys {
 	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	int (*can_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			  struct cgroup_taskset *tset);
-	int (*can_attach_task)(struct cgroup *cgrp, struct task_struct *tsk);
 	void (*cancel_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			      struct cgroup_taskset *tset);
-	void (*pre_attach)(struct cgroup *cgrp);
-	void (*attach_task)(struct cgroup *cgrp, struct task_struct *tsk);
 	void (*attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 		       struct cgroup_taskset *tset);
 	void (*fork)(struct cgroup_subsys *ss, struct task_struct *task);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 474674b..374a4cb 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1926,13 +1926,6 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 				goto out;
 			}
 		}
-		if (ss->can_attach_task) {
-			retval = ss->can_attach_task(cgrp, tsk);
-			if (retval) {
-				failed_ss = ss;
-				goto out;
-			}
-		}
 	}
 
 	retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, false);
@@ -1940,10 +1933,6 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 		goto out;
 
 	for_each_subsys(root, ss) {
-		if (ss->pre_attach)
-			ss->pre_attach(cgrp);
-		if (ss->attach_task)
-			ss->attach_task(cgrp, tsk);
 		if (ss->attach)
 			ss->attach(ss, cgrp, &tset);
 	}
@@ -2075,7 +2064,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 {
 	int retval, i, group_size, nr_todo;
 	struct cgroup_subsys *ss, *failed_ss = NULL;
-	bool cancel_failed_ss = false;
 	/* guaranteed to be initialized later, but the compiler needs this */
 	struct css_set *oldcg;
 	struct cgroupfs_root *root = cgrp->root;
@@ -2166,21 +2154,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 				goto out_cancel_attach;
 			}
 		}
-		/* a callback to be run on every thread in the threadgroup. */
-		if (ss->can_attach_task) {
-			/* run on each task in the threadgroup. */
-			for (i = 0; i < group_size; i++) {
-				tc = flex_array_get(group, i);
-				if (tc->cgrp == cgrp)
-					continue;
-				retval = ss->can_attach_task(cgrp, tc->task);
-				if (retval) {
-					failed_ss = ss;
-					cancel_failed_ss = true;
-					goto out_cancel_attach;
-				}
-			}
-		}
 	}
 
 	/*
@@ -2217,15 +2190,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	}
 
 	/*
-	 * step 3: now that we're guaranteed success wrt the css_sets, proceed
-	 * to move all tasks to the new cgroup, calling ss->attach_task for each
-	 * one along the way. there are no failure cases after here, so this is
-	 * the commit point.
+	 * step 3: now that we're guaranteed success wrt the css_sets,
+	 * proceed to move all tasks to the new cgroup.  There are no
+	 * failure cases after here, so this is the commit point.
 	 */
-	for_each_subsys(root, ss) {
-		if (ss->pre_attach)
-			ss->pre_attach(cgrp);
-	}
 	for (i = 0; i < group_size; i++) {
 		tc = flex_array_get(group, i);
 		/* leave current thread as it is if it's already there */
@@ -2235,19 +2203,11 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 		/* if the thread is PF_EXITING, it can just get skipped. */
 		retval = cgroup_task_migrate(cgrp, tc->cgrp, tc->task, true);
 		BUG_ON(retval != 0 && retval != -ESRCH);
-
-		/* attach each task to each subsystem */
-		for_each_subsys(root, ss) {
-			if (ss->attach_task)
-				ss->attach_task(cgrp, tc->task);
-		}
 	}
 	/* nothing is sensitive to fork() after this point. */
 
 	/*
-	 * step 4: do expensive, non-thread-specific subsystem callbacks.
-	 * TODO: if ever a subsystem needs to know the oldcgrp for each task
-	 * being moved, this call will need to be reworked to communicate that.
+	 * step 4: do subsystem attach callbacks.
 	 */
 	for_each_subsys(root, ss) {
 		if (ss->attach)
@@ -2271,11 +2231,8 @@ out_cancel_attach:
 	/* same deal as in cgroup_attach_task */
 	if (retval) {
 		for_each_subsys(root, ss) {
-			if (ss == failed_ss) {
-				if (cancel_failed_ss && ss->cancel_attach)
-					ss->cancel_attach(ss, cgrp, &tset);
+			if (ss == failed_ss)
 				break;
-			}
 			if (ss->cancel_attach)
 				ss->cancel_attach(ss, cgrp, &tset);
 		}
-- 
1.7.6
