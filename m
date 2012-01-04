From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 3/3] cgroup: remove extra calls to find_existing_css_set
Date: Tue,  3 Jan 2012 21:18:32 -0800
Message-ID: <1325654312-32477-3-git-send-email-msb@chromium.org>
References: <1325654312-32477-1-git-send-email-msb@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1325654312-32477-1-git-send-email-msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
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

Changes in V4:
* https://lkml.org/lkml/2011/12/22/421 (Li Zefan)
  * Avoid GFP_KERNEL (sleep) in rcu_read_lock by getting css_set in
    a separate loop not under an rcu_read_lock
Changes in V3:
* https://lkml.org/lkml/2011/12/22/13 (Li Zefan)
  * Fixed earlier bug by creating a seperate patch to remove tasklist_lock
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
 kernel/cgroup.c |  142 +++++++++++-------------------------------------------
 1 files changed, 29 insertions(+), 113 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 354c539..16e8e70 100644
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
@@ -2067,23 +1994,15 @@ static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
  */
 int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 {
-	int retval, i, group_size;
+	int retval, i, group_size, css_set_refs = 0;
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
@@ -2119,15 +2038,15 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 
 		/* as per above, nr_threads may decrease, but not increase. */
 		BUG_ON(i >= group_size);
-		/*
-		 * saying GFP_ATOMIC has no effect here because we did prealloc
-		 * earlier, but it's good form to communicate our expectations.
-		 */
 		ent.task = tsk;
 		ent.cgrp = task_cgroup_from_root(tsk, root);
 		/* nothing to do if this task is already in the cgroup */
 		if (ent.cgrp == cgrp)
 			continue;
+		/*
+		 * saying GFP_ATOMIC has no effect here because we did prealloc
+		 * earlier, but it's good form to communicate our expectations.
+		 */
 		retval = flex_array_put(group, i, &ent, GFP_ATOMIC);
 		BUG_ON(retval != 0);
 		i++;
@@ -2156,19 +2075,18 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 		}
 	}
 
-	/*
+        /*
 	 * step 2: make sure css_sets exist for all threads to be migrated.
 	 * we use find_css_set, which allocates a new one if necessary.
 	 */
-	INIT_LIST_HEAD(&newcg_list);
 	for (i = 0; i < group_size; i++) {
 		tc = flex_array_get(group, i);
-		oldcg = tc->task->cgroups;
-
-		/* if we don't already have it in the list get a new one */
-		if (!css_set_check_fetched(cgrp, tc->task, oldcg, &newcg_list))
-			if (retval = css_set_prefetch(cgrp, oldcg, &newcg_list))
-				goto out_list_teardown;
+		tc->cg = find_css_set(tc->task->cgroups, cgrp);
+		if (!tc->cg) {
+			retval = -ENOMEM;
+			css_set_refs = i;
+			goto out_put_css_set_refs;
+		}
 	}
 
 	/*
@@ -2178,8 +2096,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 */
 	for (i = 0; i < group_size; i++) {
 		tc = flex_array_get(group, i);
-		retval = cgroup_task_migrate(cgrp, tc->cgrp, tc->task, true);
-		BUG_ON(retval);
+		cgroup_task_migrate(cgrp, tc->cgrp, tc->task, tc->cg);
 	}
 	/* nothing is sensitive to fork() after this point. */
 
@@ -2197,15 +2114,14 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	synchronize_rcu();
 	cgroup_wakeup_rmdir_waiter(cgrp);
 	retval = 0;
-out_list_teardown:
-	/* clean up the list of prefetched css_sets. */
-	list_for_each_entry_safe(cg_entry, temp_nobe, &newcg_list, links) {
-		list_del(&cg_entry->links);
-		put_css_set(cg_entry->cg);
-		kfree(cg_entry);
+out_put_css_set_refs:
+	if (retval) {
+		for (i = 0; i < css_set_refs; i++) {
+			tc = flex_array_get(group, i);
+			put_css_set(tc->cg);
+		}
 	}
 out_cancel_attach:
-	/* same deal as in cgroup_attach_task */
 	if (retval) {
 		for_each_subsys(root, ss) {
 			if (ss == failed_ss)
-- 
1.7.3.1
