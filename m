From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/10] cgroup: kill subsys->can_attach_task(),
	pre_attach() and attach_task()
Date: Tue,  1 Nov 2011 16:46:33 -0700
Message-ID: <1320191193-8110-11-git-send-email-tj@kernel.org>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1320191193-8110-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

These three methods are no longer used.  Kill them.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |   20 --------------
 include/linux/cgroup.h            |    3 --
 kernel/cgroup.c                   |   53 +++---------------------------------
 3 files changed, 5 insertions(+), 71 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index bf5d6c9..eb1b609 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -615,13 +615,6 @@ fork. If this method returns 0 (success) then this should remain valid
 while the caller holds cgroup_mutex and it is ensured that either
 attach() or cancel_attach() will be called in future.
 
-int can_attach_task(struct cgroup *cgrp, struct task_struct *tsk);
-(cgroup_mutex held by caller)
-
-As can_attach, but for operations that must be run once per task to be
-attached (possibly many when using cgroup_attach_proc). Called after
-can_attach.
-
 void cancel_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 		   struct cgroup_taskset *tset)
 (cgroup_mutex held by caller)
@@ -632,12 +625,6 @@ function, so that the subsystem can implement a rollback. If not, not necessary.
 This will be called only about subsystems whose can_attach() operation have
 succeeded. The parameters are identical to can_attach().
 
-void pre_attach(struct cgroup *cgrp);
-(cgroup_mutex held by caller)
-
-For any non-per-thread attachment work that needs to happen before
-attach_task. Needed by cpuset.
-
 void attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	    struct cgroup_taskset *tset)
 (cgroup_mutex held by caller)
@@ -646,13 +633,6 @@ Called after the task has been attached to the cgroup, to allow any
 post-attachment activity that requires memory allocations or blocking.
 The parameters are identical to can_attach().
 
-void attach_task(struct cgroup *cgrp, struct task_struct *tsk);
-(cgroup_mutex held by caller)
-
-As attach, but for operations that must be run once per task to be attached,
-like can_attach_task. Called before attach. Currently does not support any
-subsystem that might need the old_cgrp for every thread in the group.
-
 void fork(struct cgroup_subsy *ss, struct task_struct *task)
 
 Called when a task is forked into a cgroup.
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
index 0bb7927..d2b3697 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1944,13 +1944,6 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
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
@@ -1958,10 +1951,6 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 		goto out;
 
 	for_each_subsys(root, ss) {
-		if (ss->pre_attach)
-			ss->pre_attach(cgrp);
-		if (ss->attach_task)
-			ss->attach_task(cgrp, tsk);
 		if (ss->attach)
 			ss->attach(ss, cgrp, &tset);
 	}
@@ -2093,7 +2082,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 {
 	int retval, i, group_size, nr_migrating_tasks;
 	struct cgroup_subsys *ss, *failed_ss = NULL;
-	bool cancel_failed_ss = false;
 	/* guaranteed to be initialized later, but the compiler needs this */
 	struct css_set *oldcg;
 	struct cgroupfs_root *root = cgrp->root;
@@ -2188,21 +2176,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
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
@@ -2234,15 +2207,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
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
@@ -2251,19 +2219,11 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 
 		retval = cgroup_task_migrate(cgrp, tc->cgrp, tc->task, true);
 		BUG_ON(retval != 0);
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
@@ -2287,11 +2247,8 @@ out_cancel_attach:
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
1.7.3.1
