From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/6] cgroup: improve old cgroup handling in
	cgroup_attach_proc()
Date: Fri, 26 Aug 2011 00:43:08 +0200
Message-ID: <1314312192-26885-3-git-send-email-tj__14922.9716662832$1314312635$gmane$org@kernel.org>
References: <1314312192-26885-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1314312192-26885-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_attach_proc() behaves differently from cgroup_attach_task() in
the following aspects.

* All hooks are invoked even if no task is actually being moved.

* ->can_attach_task() is called for all tasks in the group whether the
  new cgrp is different from the current cgrp or not; however,
  ->attach_task() is skipped if new equals new.  This makes the calls
  asymmetric.

This patch improves old cgroup handling in cgroup_attach_proc() by
looking up the current cgroup at the head, recording it in the flex
array along with the task itself, and using it to remove the above two
differences.  This will also ease further changes.

-v2: nr_todo renamed to nr_migrating_tasks as per Paul Menage's
     suggestion.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   70 ++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 44 insertions(+), 26 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a606fa2..8a47380 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1739,6 +1739,11 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 }
 EXPORT_SYMBOL_GPL(cgroup_path);
 
+struct task_and_cgroup {
+	struct task_struct	*task;
+	struct cgroup		*cgrp;
+};
+
 /*
  * cgroup_task_migrate - move a task from one cgroup to another.
  *
@@ -1990,15 +1995,15 @@ static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
  */
 int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 {
-	int retval, i, group_size;
+	int retval, i, group_size, nr_migrating_tasks;
 	struct cgroup_subsys *ss, *failed_ss = NULL;
 	bool cancel_failed_ss = false;
 	/* guaranteed to be initialized later, but the compiler needs this */
-	struct cgroup *oldcgrp = NULL;
 	struct css_set *oldcg;
 	struct cgroupfs_root *root = cgrp->root;
 	/* threadgroup list cursor and array */
 	struct task_struct *tsk;
+	struct task_and_cgroup *tc;
 	struct flex_array *group;
 	/*
 	 * we need to make sure we have css_sets for all the tasks we're
@@ -2017,8 +2022,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 */
 	group_size = get_nr_threads(leader);
 	/* flex_array supports very large thread-groups better than kmalloc. */
-	group = flex_array_alloc(sizeof(struct task_struct *), group_size,
-				 GFP_KERNEL);
+	group = flex_array_alloc(sizeof(*tc), group_size, GFP_KERNEL);
 	if (!group)
 		return -ENOMEM;
 	/* pre-allocate to guarantee space while iterating in rcu read-side. */
@@ -2042,8 +2046,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	}
 	/* take a reference on each task in the group to go in the array. */
 	tsk = leader;
-	i = 0;
+	i = nr_migrating_tasks = 0;
 	do {
+		struct task_and_cgroup ent;
+
 		/* as per above, nr_threads may decrease, but not increase. */
 		BUG_ON(i >= group_size);
 		get_task_struct(tsk);
@@ -2051,14 +2057,23 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 		 * saying GFP_ATOMIC has no effect here because we did prealloc
 		 * earlier, but it's good form to communicate our expectations.
 		 */
-		retval = flex_array_put_ptr(group, i, tsk, GFP_ATOMIC);
+		ent.task = tsk;
+		ent.cgrp = task_cgroup_from_root(tsk, root);
+		retval = flex_array_put(group, i, &ent, GFP_ATOMIC);
 		BUG_ON(retval != 0);
 		i++;
+		if (ent.cgrp != cgrp)
+			nr_migrating_tasks++;
 	} while_each_thread(leader, tsk);
 	/* remember the number of threads in the array for later. */
 	group_size = i;
 	rcu_read_unlock();
 
+	/* methods shouldn't be called if no task is actually migrating */
+	retval = 0;
+	if (!nr_migrating_tasks)
+		goto out_put_tasks;
+
 	/*
 	 * step 1: check that we can legitimately attach to the cgroup.
 	 */
@@ -2074,8 +2089,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 		if (ss->can_attach_task) {
 			/* run on each task in the threadgroup. */
 			for (i = 0; i < group_size; i++) {
-				tsk = flex_array_get_ptr(group, i);
-				retval = ss->can_attach_task(cgrp, tsk);
+				tc = flex_array_get(group, i);
+				if (tc->cgrp == cgrp)
+					continue;
+				retval = ss->can_attach_task(cgrp, tc->task);
 				if (retval) {
 					failed_ss = ss;
 					cancel_failed_ss = true;
@@ -2091,23 +2108,22 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 */
 	INIT_LIST_HEAD(&newcg_list);
 	for (i = 0; i < group_size; i++) {
-		tsk = flex_array_get_ptr(group, i);
+		tc = flex_array_get(group, i);
 		/* nothing to do if this task is already in the cgroup */
-		oldcgrp = task_cgroup_from_root(tsk, root);
-		if (cgrp == oldcgrp)
+		if (tc->cgrp == cgrp)
 			continue;
 		/* get old css_set pointer */
-		task_lock(tsk);
-		if (tsk->flags & PF_EXITING) {
+		task_lock(tc->task);
+		if (tc->task->flags & PF_EXITING) {
 			/* ignore this task if it's going away */
-			task_unlock(tsk);
+			task_unlock(tc->task);
 			continue;
 		}
-		oldcg = tsk->cgroups;
+		oldcg = tc->task->cgroups;
 		get_css_set(oldcg);
-		task_unlock(tsk);
+		task_unlock(tc->task);
 		/* see if the new one for us is already in the list? */
-		if (css_set_check_fetched(cgrp, tsk, oldcg, &newcg_list)) {
+		if (css_set_check_fetched(cgrp, tc->task, oldcg, &newcg_list)) {
 			/* was already there, nothing to do. */
 			put_css_set(oldcg);
 		} else {
@@ -2130,20 +2146,19 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 			ss->pre_attach(cgrp);
 	}
 	for (i = 0; i < group_size; i++) {
-		tsk = flex_array_get_ptr(group, i);
+		tc = flex_array_get(group, i);
 		/* leave current thread as it is if it's already there */
-		oldcgrp = task_cgroup_from_root(tsk, root);
-		if (cgrp == oldcgrp)
+		if (tc->cgrp == cgrp)
 			continue;
 
 		/* if the thread is PF_EXITING, it can just get skipped. */
-		retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, true);
+		retval = cgroup_task_migrate(cgrp, tc->cgrp, tc->task, true);
 		BUG_ON(retval != 0 && retval != -ESRCH);
 
 		/* attach each task to each subsystem */
 		for_each_subsys(root, ss) {
 			if (ss->attach_task)
-				ss->attach_task(cgrp, tsk);
+				ss->attach_task(cgrp, tc->task);
 		}
 	}
 	/* nothing is sensitive to fork() after this point. */
@@ -2154,8 +2169,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 * being moved, this call will need to be reworked to communicate that.
 	 */
 	for_each_subsys(root, ss) {
-		if (ss->attach)
-			ss->attach(ss, cgrp, oldcgrp, leader);
+		if (ss->attach) {
+			tc = flex_array_get(group, 0);
+			ss->attach(ss, cgrp, tc->cgrp, tc->task);
+		}
 	}
 
 	/*
@@ -2184,10 +2201,11 @@ out_cancel_attach:
 				ss->cancel_attach(ss, cgrp, leader);
 		}
 	}
+out_put_tasks:
 	/* clean up the array of referenced threads in the group. */
 	for (i = 0; i < group_size; i++) {
-		tsk = flex_array_get_ptr(group, i);
-		put_task_struct(tsk);
+		tc = flex_array_get(group, i);
+		put_task_struct(tc->task);
 	}
 out_free_group_list:
 	flex_array_free(group);
-- 
1.7.6
