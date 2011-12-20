From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 4/5] cgroup: remove extra calls to find_existing_css_set
Date: Tue, 20 Dec 2011 15:14:32 -0800
Message-ID: <1324422873-31001-5-git-send-email-msb@chromium.org>
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

In cgroup_attach_proc, we indirectly call find_existing_css_set 3
times. It is an expensive call so we want to call it a minimum
of times. This patch only calls it once and stores the result so
that it can be used later on when we call cgroup_task_migrate.

This required modifying cgroup_task_migrate to take the new css_set
(which we obtained from find_css_set) as a parameter. The nice side
effect of this is that cgroup_task_migrate is now identical for
cgroup_attach_task and cgroup_attach_proc. It also now returns a
void since it can never fail.

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
 kernel/cgroup.c |  138 ++++++++++--------------------------------------------
 1 files changed, 26 insertions(+), 112 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 4668a3f..2ac9eee 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1763,6 +1763,7 @@ EXPORT_SYMBOL_GPL(cgroup_path);
 struct task_and_cgroup {
 	struct task_struct	*task;
 	struct cgroup		*cgrp;
+	struct css_set		*cg;
 };
 
 struct cgroup_taskset {
@@ -1843,40 +1844,14 @@ EXPORT_SYMBOL_GPL(cgroup_taskset_size);
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
-
-	/*
-	 * get old css_set. we need to take task_lock and refcount it, because
-	 * an exiting task can change its css_set to init_css_set and drop its
-	 * old one without taking cgroup_mutex.
-	 */
-	task_lock(tsk);
-	oldcg = tsk->cgroups;
-	task_unlock(tsk);
-
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
 
 	/* @tsk can't exit as its threadgroup is locked */
 	task_lock(tsk);
+	oldcg = tsk->cgroups;
 	WARN_ON_ONCE(tsk->flags & PF_EXITING);
 	rcu_assign_pointer(tsk->cgroups, newcg);
 	task_unlock(tsk);
@@ -1895,7 +1870,6 @@ static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
 	put_css_set(oldcg);
 
 	set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
-	return 0;
 }
 
 /**
@@ -1913,6 +1887,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	struct cgroup *oldcgrp;
 	struct cgroupfs_root *root = cgrp->root;
 	struct cgroup_taskset tset = { };
+	struct css_set *newcg, *oldcg;
 
 	/* @tsk either already exited or can't exit until the end */
 	if (tsk->flags & PF_EXITING)
@@ -1942,9 +1917,17 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 		}
 	}
 
-	retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, false);
-	if (retval)
+	task_lock(tsk);
+	oldcg = tsk->cgroups;
+	task_unlock(tsk);
+
+	newcg = find_css_set(oldcg, cgrp);
+	if (!newcg) {
+		retval = -ENOMEM;
 		goto out;
+	}
+
+	cgroup_task_migrate(cgrp, oldcgrp, tsk, newcg);
 
 	for_each_subsys(root, ss) {
 		if (ss->attach)
@@ -2000,65 +1983,6 @@ int cgroup_attach_task_all(struct task_struct *from, struct task_struct *tsk)
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
-static bool css_set_fetched(struct cgroup *cgrp, struct task_struct *tsk,
-			    struct css_set *cg, struct list_head *newcg_list)
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
@@ -2069,7 +1993,7 @@ static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
  */
 int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 {
-	int retval, i, group_size;
+	int retval, i, group_size, css_set_refs = 0;
 	struct cgroup_subsys *ss, *failed_ss = NULL;
 	/* guaranteed to be initialized later, but the compiler needs this */
 	struct css_set *oldcg;
@@ -2079,13 +2003,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
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
@@ -2171,17 +2088,18 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 * step 2: make sure css_sets exist for all threads to be migrated.
 	 * we use find_css_set, which allocates a new one if necessary.
 	 */
-	INIT_LIST_HEAD(&newcg_list);
 	for (i = 0; i < group_size; i++) {
 		tc = flex_array_get(group, i);
 		/* get old css_set pointer */
 		task_lock(tc->task);
 		oldcg = tc->task->cgroups;
 		task_unlock(tc->task);
-		/* if we don't already have it in the list get a new one */
-		if (!css_set_fetched(cgrp, tc->task, oldcg, &newcg_list))
-			if (retval = css_set_prefetch(cgrp, oldcg, &newcg_list))
-				goto out_list_teardown;
+		tc->cg = find_css_set(oldcg, cgrp);
+		if (!tc->cg) {
+			retval = -ENOMEM;
+			css_set_refs = i + 1;
+			goto out_list_teardown;
+		}
 	}
 
 	/*
@@ -2191,8 +2109,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 */
 	for (i = 0; i < group_size; i++) {
 		tc = flex_array_get(group, i);
-		retval = cgroup_task_migrate(cgrp, tc->cgrp, tc->task, true);
-		BUG_ON(retval);
+		cgroup_task_migrate(cgrp, tc->cgrp, tc->task, tc->cg);
 	}
 	/* nothing is sensitive to fork() after this point. */
 
@@ -2211,14 +2128,11 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	cgroup_wakeup_rmdir_waiter(cgrp);
 	retval = 0;
 out_list_teardown:
-	/* clean up the list of prefetched css_sets. */
-	list_for_each_entry_safe(cg_entry, temp_nobe, &newcg_list, links) {
-		list_del(&cg_entry->links);
-		put_css_set(cg_entry->cg);
-		kfree(cg_entry);
+	for (i = 0; i < css_set_refs; i++) {
+		tc = flex_array_get(group, i);
+		put_css_set(tc->cg);
 	}
 out_cancel_attach:
-	/* same deal as in cgroup_attach_task */
 	if (retval) {
 		for_each_subsys(root, ss) {
 			if (ss == failed_ss)
-- 
1.7.3.1
