From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 4/4] cgroup: remove extra calls to find_existing_css_set
Date: Wed, 21 Dec 2011 20:18:38 -0800
Message-ID: <1324527518-24461-4-git-send-email-msb__31285.7976802208$1324527546$gmane$org@chromium.org>
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

In cgroup_attach_proc, we indirectly call find_existing_css_set 3
times. It is an expensive call so we want to call it a minimum
of times. This patch only calls it once and stores the result so
that it can be used later on when we call cgroup_task_migrate.

This required modifying cgroup_task_migrate to take the new css_set
(which we obtained from find_css_set) as a parameter. The nice side
effect of this is that cgroup_task_migrate is now identical for
cgroup_attach_task and cgroup_attach_proc. It also now returns a
void since it can never fail.

Changes in V2:
* https://lkml.org/lkml/2011/12/20/372 (Tejun Heo)
  * Move find_css_set call into loop which creates the flex array
* Author
  * Kill css_set_refs and use group_size instead
  * Fix an off-by-one error in counting css_set refs
  * Add a retval check in out_list_teardown

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
 kernel/cgroup.c |  152 ++++++++++++-------------------------------------------
 1 files changed, 32 insertions(+), 120 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 1042b3c..242d89f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1763,6 +1763,7 @@ EXPORT_SYMBOL_GPL(cgroup_path);
 struct task_and_cgroup {
 	struct task_struct	*task;
 	struct cgroup		*cgrp;
+	struct css_set		*cg;
 };
 
 struct cgroup_taskset {
@@ -1843,11 +1844,10 @@ EXPORT_SYMBOL_GPL(cgroup_taskset_size);
  * will already exist. If not set, this function might sleep, and can fail with
  * -ENOMEM. Must be called with cgroup_mutex and threadgroup locked.
  */
-static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
-			       struct task_struct *tsk, bool guarantee)
+static void cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
+				struct task_struct *tsk, struct css_set *newcg)
 {
 	struct css_set *oldcg;
-	struct css_set *newcg;
 
 	/*
 	 * We are synchronized through threadgroup_lock() against PF_EXITING
@@ -1857,23 +1857,6 @@ static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
 	WARN_ON_ONCE(tsk->flags & PF_EXITING);
 	oldcg = tsk->cgroups;
 
-	/* locate or allocate a new css_set for this task. */
-	if (guarantee) {
-		/* we know the css_set we want already exists. */
-		struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
-		read_lock(&css_set_lock);
-		newcg = find_existing_css_set(oldcg, cgrp, template);
-		BUG_ON(!newcg);
-		get_css_set(newcg);
-		read_unlock(&css_set_lock);
-	} else {
-		might_sleep();
-		/* find_css_set will give us newcg already referenced. */
-		newcg = find_css_set(oldcg, cgrp);
-		if (!newcg)
-			return -ENOMEM;
-	}
-
 	task_lock(tsk);
 	rcu_assign_pointer(tsk->cgroups, newcg);
 	task_unlock(tsk);
@@ -1892,7 +1875,6 @@ static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
 	put_css_set(oldcg);
 
 	set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
-	return 0;
 }
 
 /**
@@ -1910,6 +1892,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	struct cgroup *oldcgrp;
 	struct cgroupfs_root *root = cgrp->root;
 	struct cgroup_taskset tset = { };
+	struct css_set *newcg;
 
 	/* @tsk either already exited or can't exit until the end */
 	if (tsk->flags & PF_EXITING)
@@ -1939,9 +1922,13 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 		}
 	}
 
-	retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, false);
-	if (retval)
+	newcg = find_css_set(tsk->cgroups, cgrp);
+	if (!newcg) {
+		retval = -ENOMEM;
 		goto out;
+	}
+
+	cgroup_task_migrate(cgrp, oldcgrp, tsk, newcg);
 
 	for_each_subsys(root, ss) {
 		if (ss->attach)
@@ -1997,66 +1984,6 @@ int cgroup_attach_task_all(struct task_struct *from, struct task_struct *tsk)
 }
 EXPORT_SYMBOL_GPL(cgroup_attach_task_all);
 
-/*
- * cgroup_attach_proc works in two stages, the first of which prefetches all
- * new css_sets needed (to make sure we have enough memory before committing
- * to the move) and stores them in a list of entries of the following type.
- * TODO: possible optimization: use css_set->rcu_head for chaining instead
- */
-struct cg_list_entry {
-	struct css_set *cg;
-	struct list_head links;
-};
-
-static bool css_set_check_fetched(struct cgroup *cgrp,
-				  struct task_struct *tsk, struct css_set *cg,
-				  struct list_head *newcg_list)
-{
-	struct css_set *newcg;
-	struct cg_list_entry *cg_entry;
-	struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
-
-	read_lock(&css_set_lock);
-	newcg = find_existing_css_set(cg, cgrp, template);
-	read_unlock(&css_set_lock);
-
-	/* doesn't exist at all? */
-	if (!newcg)
-		return false;
-	/* see if it's already in the list */
-	list_for_each_entry(cg_entry, newcg_list, links)
-		if (cg_entry->cg == newcg)
-			return true;
-
-	/* not found */
-	return false;
-}
-
-/*
- * Find the new css_set and store it in the list in preparation for moving the
- * given task to the given cgroup. Returns 0 or -ENOMEM.
- */
-static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
-			    struct list_head *newcg_list)
-{
-	struct css_set *newcg;
-	struct cg_list_entry *cg_entry;
-
-	/* ensure a new css_set will exist for this thread */
-	newcg = find_css_set(cg, cgrp);
-	if (!newcg)
-		return -ENOMEM;
-	/* add it to the list */
-	cg_entry = kmalloc(sizeof(struct cg_list_entry), GFP_KERNEL);
-	if (!cg_entry) {
-		put_css_set(newcg);
-		return -ENOMEM;
-	}
-	cg_entry->cg = newcg;
-	list_add(&cg_entry->links, newcg_list);
-	return 0;
-}
-
 /**
  * cgroup_attach_proc - attach all threads in a threadgroup to a cgroup
  * @cgrp: the cgroup to attach to
@@ -2070,20 +1997,12 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	int retval, i, group_size;
 	struct cgroup_subsys *ss, *failed_ss = NULL;
 	/* guaranteed to be initialized later, but the compiler needs this */
-	struct css_set *oldcg;
 	struct cgroupfs_root *root = cgrp->root;
 	/* threadgroup list cursor and array */
 	struct task_struct *tsk;
 	struct task_and_cgroup *tc;
 	struct flex_array *group;
 	struct cgroup_taskset tset = { };
-	/*
-	 * we need to make sure we have css_sets for all the tasks we're
-	 * going to move -before- we actually start moving them, so that in
-	 * case we get an ENOMEM we can bail out before making any changes.
-	 */
-	struct list_head newcg_list;
-	struct cg_list_entry *cg_entry, *temp_nobe;
 
 	/*
 	 * step 0: in order to do expensive, possibly blocking operations for
@@ -2091,6 +2010,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 * rcu or tasklist locked. instead, build an array of all threads in the
 	 * group - group_rwsem prevents new threads from appearing, and if
 	 * threads exit, this will just be an over-estimate.
+	 *
+	 * While creating the list, also make sure css_sets exist for all
+	 * threads to be migrated. we use find_css_set, which allocates a new
+	 * one if necessary.
 	 */
 	group_size = get_nr_threads(leader);
 	/* flex_array supports very large thread-groups better than kmalloc. */
@@ -2137,6 +2060,12 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 		/* nothing to do if this task is already in the cgroup */
 		if (ent.cgrp == cgrp)
 			continue;
+		ent.cg = find_css_set(tsk->cgroups, cgrp);
+		if (!ent.cg) {
+			retval = -ENOMEM;
+			group_size = i;
+			goto out_list_teardown;
+		}
 		retval = flex_array_put(group, i, &ent, GFP_ATOMIC);
 		BUG_ON(retval != 0);
 		i++;
@@ -2150,7 +2079,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	/* methods shouldn't be called if no task is actually migrating */
 	retval = 0;
 	if (!group_size)
-		goto out_free_group_list;
+		goto out_list_teardown;
 
 	/*
 	 * step 1: check that we can legitimately attach to the cgroup.
@@ -2166,34 +2095,18 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	}
 
 	/*
-	 * step 2: make sure css_sets exist for all threads to be migrated.
-	 * we use find_css_set, which allocates a new one if necessary.
-	 */
-	INIT_LIST_HEAD(&newcg_list);
-	for (i = 0; i < group_size; i++) {
-		tc = flex_array_get(group, i);
-		oldcg = tc->task->cgroups;
-
-		/* if we don't already have it in the list get a new one */
-		if (!css_set_check_fetched(cgrp, tc->task, oldcg, &newcg_list))
-			if (retval = css_set_prefetch(cgrp, oldcg, &newcg_list))
-				goto out_list_teardown;
-	}
-
-	/*
-	 * step 3: now that we're guaranteed success wrt the css_sets,
+	 * step 2: now that we're guaranteed success wrt the css_sets,
 	 * proceed to move all tasks to the new cgroup.  There are no
 	 * failure cases after here, so this is the commit point.
 	 */
 	for (i = 0; i < group_size; i++) {
 		tc = flex_array_get(group, i);
-		retval = cgroup_task_migrate(cgrp, tc->cgrp, tc->task, true);
-		BUG_ON(retval);
+		cgroup_task_migrate(cgrp, tc->cgrp, tc->task, tc->cg);
 	}
 	/* nothing is sensitive to fork() after this point. */
 
 	/*
-	 * step 4: do subsystem attach callbacks.
+	 * step 3: do subsystem attach callbacks.
 	 */
 	for_each_subsys(root, ss) {
 		if (ss->attach)
@@ -2201,20 +2114,12 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	}
 
 	/*
-	 * step 5: success! and cleanup
+	 * step 4: success! and cleanup
 	 */
 	synchronize_rcu();
 	cgroup_wakeup_rmdir_waiter(cgrp);
 	retval = 0;
-out_list_teardown:
-	/* clean up the list of prefetched css_sets. */
-	list_for_each_entry_safe(cg_entry, temp_nobe, &newcg_list, links) {
-		list_del(&cg_entry->links);
-		put_css_set(cg_entry->cg);
-		kfree(cg_entry);
-	}
 out_cancel_attach:
-	/* same deal as in cgroup_attach_task */
 	if (retval) {
 		for_each_subsys(root, ss) {
 			if (ss == failed_ss)
@@ -2223,6 +2128,13 @@ out_cancel_attach:
 				ss->cancel_attach(ss, cgrp, &tset);
 		}
 	}
+out_list_teardown:
+	if (retval) {
+		for (i = 0; i < group_size; i++) {
+			tc = flex_array_get(group, i);
+			put_css_set(tc->cg);
+		}
+	}
 out_free_group_list:
 	flex_array_free(group);
 	return retval;
-- 
1.7.3.1
