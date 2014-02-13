From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/7] cgroup: use css_set->mg_tasks to track target tasks
	during migration
Date: Thu, 13 Feb 2014 15:28:48 -0500
Message-ID: <1392323333-18907-3-git-send-email-tj@kernel.org>
References: <1392323333-18907-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1392323333-18907-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, while migrating tasks from one cgroup to another,
cgroup_attach_task() builds a flex array of all target tasks;
unfortunately, this has a couple issues.

* Flex array has size limit.  On 64bit, struct task_and_cgroup is
  24bytes making the flex element limit around 87k.  It is a high
  number but not impossible to hit.  This means that the current
  cgroup implementation can't migrate a process with more than 87k
  threads.

* Process migration involves memory allocation whose size is dependent
  on the number of threads the process has.  This means that cgroup
  core can't guarantee success or failure of multi-process migrations
  as memory allocation failure can happen in the middle.  This is in
  part because cgroup can't grab threadgroup locks of multiple
  processes at the same time, so when there are multiple processes to
  migrate, it is imposible to tell how many tasks are to be migrated
  beforehand.

  Note that this already affects cgroup_transfer_tasks().  cgroup
  currently cannot guarantee atomic success or failure of the
  operation.  It may fail in the middle and after such failure cgroup
  doesn't have enough information to roll back properly.  It just
  aborts with some tasks migrated and others not.

To resolve the situation, this patch updates the migration path to use
task->cg_list to track target tasks.  The previous patch already added
css_set->mg_tasks and updated iterations in non-migration paths to
include them during task migration.  This patch updates migration path
to actually make use of it.

Instead of putting onto a flex_array, each target task is moved from
its css_set->tasks list to css_set->mg_tasks and the migration path
keeps trace of all the source css_sets and the associated cgroups.
Once all source css_sets are determined, the destination css_set for
each is determined, linked to the matching source css_set and put on a
separate list.

To iterate the target tasks, migration path just needs to iterat
through either the source or target css_sets, depending on whether
migration has been committed or not, and the tasks on their ->mg_tasks
lists.  cgroup_taskset is updated to contain the list_heads for source
and target css_sets and the iteration cursor.  cgroup_taskset_*() are
accordingly updated to walk through css_sets and their ->mg_tasks.

This resolves the above listed issues with moderate additional
complexity.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  16 ++++
 kernel/cgroup.c        | 223 +++++++++++++++++++++++++------------------------
 2 files changed, 131 insertions(+), 108 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 3238abd..42a0b56 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -346,6 +346,22 @@ struct css_set {
 	 */
 	struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT];
 
+	/*
+	 * List of csets participating in the on-going migration either as
+	 * source or destination.  Protected by cgroup_mutex.
+	 */
+	struct list_head mg_node;
+
+	/*
+	 * If this cset is acting as the source of migration the following
+	 * two fields are set.  mg_src_cgrp is the source cgroup of the
+	 * on-going migration and mg_dst_cset is the destination cset the
+	 * target tasks on this cset should be migrated to.  Protected by
+	 * cgroup_mutex.
+	 */
+	struct cgroup *mg_src_cgrp;
+	struct css_set *mg_dst_cset;
+
 	/* For RCU-protected deletion */
 	struct rcu_head rcu_head;
 };
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index c423bac..539758c 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -52,7 +52,6 @@
 #include <linux/pid_namespace.h>
 #include <linux/idr.h>
 #include <linux/vmalloc.h> /* TODO: replace with more sophisticated array */
-#include <linux/flex_array.h> /* used in cgroup_attach_task */
 #include <linux/kthread.h>
 #include <linux/delay.h>
 
@@ -645,6 +644,7 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 	INIT_LIST_HEAD(&cset->cgrp_links);
 	INIT_LIST_HEAD(&cset->tasks);
 	INIT_LIST_HEAD(&cset->mg_tasks);
+	INIT_LIST_HEAD(&cset->mg_node);
 	INIT_HLIST_NODE(&cset->hlist);
 
 	/* Copy the set of subsystem state objects generated in
@@ -1637,20 +1637,26 @@ char *task_cgroup_path(struct task_struct *task, char *buf, size_t buflen)
 }
 EXPORT_SYMBOL_GPL(task_cgroup_path);
 
-/*
- * Control Group taskset
- */
-struct task_and_cgroup {
-	struct task_struct	*task;
-	struct cgroup		*cgrp;
-	struct css_set		*cset;
-};
-
+/* used to track tasks and other necessary states during migration */
 struct cgroup_taskset {
-	struct task_and_cgroup	single;
-	struct flex_array	*tc_array;
-	int			tc_array_len;
-	int			idx;
+	/* the src and dst cset list running through cset->mg_node */
+	struct list_head	src_csets;
+	struct list_head	dst_csets;
+
+	/*
+	 * Fields for cgroup_taskset_*() iteration.
+	 *
+	 * Before migration is committed, the target migration tasks are on
+	 * ->mg_tasks of the csets on ->src_csets.  After, on ->mg_tasks of
+	 * the csets on ->dst_csets.  ->csets point to either ->src_csets
+	 * or ->dst_csets depending on whether migration is committed.
+	 *
+	 * ->cur_csets and ->cur_task point to the current task position
+	 * during iteration.
+	 */
+	struct list_head	*csets;
+	struct css_set		*cur_cset;
+	struct task_struct	*cur_task;
 };
 
 /**
@@ -1661,12 +1667,10 @@ struct cgroup_taskset {
  */
 struct task_struct *cgroup_taskset_first(struct cgroup_taskset *tset)
 {
-	if (tset->tc_array) {
-		tset->idx = 0;
-		return cgroup_taskset_next(tset);
-	} else {
-		return tset->single.task;
-	}
+	tset->cur_cset = list_first_entry(tset->csets, struct css_set, mg_node);
+	tset->cur_task = NULL;
+
+	return cgroup_taskset_next(tset);
 }
 
 /**
@@ -1678,13 +1682,27 @@ struct task_struct *cgroup_taskset_first(struct cgroup_taskset *tset)
  */
 struct task_struct *cgroup_taskset_next(struct cgroup_taskset *tset)
 {
-	struct task_and_cgroup *tc;
+	struct css_set *cset = tset->cur_cset;
+	struct task_struct *task = tset->cur_task;
 
-	if (!tset->tc_array || tset->idx >= tset->tc_array_len)
-		return NULL;
+	while (&cset->mg_node != tset->csets) {
+		if (!task)
+			task = list_first_entry(&cset->mg_tasks,
+						struct task_struct, cg_list);
+		else
+			task = list_next_entry(task, cg_list);
 
-	tc = flex_array_get(tset->tc_array, tset->idx++);
-	return tc->task;
+		if (&task->cg_list != &cset->mg_tasks) {
+			tset->cur_cset = cset;
+			tset->cur_task = task;
+			return task;
+		}
+
+		cset = list_next_entry(cset, mg_node);
+		task = NULL;
+	}
+
+	return NULL;
 }
 
 /**
@@ -1712,11 +1730,13 @@ static void cgroup_task_migrate(struct cgroup *old_cgrp,
 	WARN_ON_ONCE(tsk->flags & PF_EXITING);
 	old_cset = task_css_set(tsk);
 
+	get_css_set(new_cset);
+
 	task_lock(tsk);
 	rcu_assign_pointer(tsk->cgroups, new_cset);
 	task_unlock(tsk);
 
-	list_move(&tsk->cg_list, &new_cset->tasks);
+	list_move(&tsk->cg_list, &new_cset->mg_tasks);
 
 	/*
 	 * We just gained a reference on old_cset by taking it from the
@@ -1739,80 +1759,58 @@ static void cgroup_task_migrate(struct cgroup *old_cgrp,
 static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *leader,
 			      bool threadgroup)
 {
-	int ret, i, group_size;
-	struct cgroupfs_root *root = cgrp->root;
+	struct cgroup_taskset tset = {
+		.src_csets	= LIST_HEAD_INIT(tset.src_csets),
+		.dst_csets	= LIST_HEAD_INIT(tset.dst_csets),
+		.csets		= &tset.src_csets,
+	};
 	struct cgroup_subsys_state *css, *failed_css = NULL;
-	/* threadgroup list cursor and array */
-	struct task_struct *task;
-	struct task_and_cgroup *tc;
-	struct flex_array *group;
-	struct cgroup_taskset tset = { };
-
-	/*
-	 * step 0: in order to do expensive, possibly blocking operations for
-	 * every thread, we cannot iterate the thread group list, since it needs
-	 * rcu or tasklist locked. instead, build an array of all threads in the
-	 * group - group_rwsem prevents new threads from appearing, and if
-	 * threads exit, this will just be an over-estimate.
-	 */
-	if (threadgroup)
-		group_size = get_nr_threads(leader);
-	else
-		group_size = 1;
-	/* flex_array supports very large thread-groups better than kmalloc. */
-	group = flex_array_alloc(sizeof(*tc), group_size, GFP_KERNEL);
-	if (!group)
-		return -ENOMEM;
-	/* pre-allocate to guarantee space while iterating in rcu read-side. */
-	ret = flex_array_prealloc(group, 0, group_size, GFP_KERNEL);
-	if (ret)
-		goto out_free_group_list;
+	struct css_set *cset, *tmp_cset;
+	struct task_struct *task, *tmp_task;
+	int i, ret;
 
-	i = 0;
 	/*
 	 * Prevent freeing of tasks while we take a snapshot. Tasks that are
 	 * already PF_EXITING could be freed from underneath us unless we
 	 * take an rcu_read_lock.
 	 */
-	down_read(&css_set_rwsem);
+	down_write(&css_set_rwsem);
 	rcu_read_lock();
 	task = leader;
 	do {
-		struct task_and_cgroup ent;
+		struct cgroup *src_cgrp;
 
 		/* @task either already exited or can't exit until the end */
 		if (task->flags & PF_EXITING)
 			goto next;
 
-		/* as per above, nr_threads may decrease, but not increase. */
-		BUG_ON(i >= group_size);
-		ent.task = task;
-		ent.cgrp = task_cgroup_from_root(task, root);
+		cset = task_css_set(task);
+		src_cgrp = task_cgroup_from_root(task, cgrp->root);
+
 		/* nothing to do if this task is already in the cgroup */
-		if (ent.cgrp == cgrp)
+		if (src_cgrp == cgrp)
 			goto next;
-		/*
-		 * saying GFP_ATOMIC has no effect here because we did prealloc
-		 * earlier, but it's good form to communicate our expectations.
-		 */
-		ret = flex_array_put(group, i, &ent, GFP_ATOMIC);
-		BUG_ON(ret != 0);
-		i++;
+
+		if (!cset->mg_src_cgrp) {
+			WARN_ON(!list_empty(&cset->mg_tasks));
+			WARN_ON(!list_empty(&cset->mg_node));
+
+			cset->mg_src_cgrp = src_cgrp;
+			list_add(&cset->mg_node, &tset.src_csets);
+			get_css_set(cset);
+		}
+
+		list_move(&task->cg_list, &cset->mg_tasks);
 	next:
 		if (!threadgroup)
 			break;
 	} while_each_thread(leader, task);
 	rcu_read_unlock();
-	up_read(&css_set_rwsem);
-	/* remember the number of threads in the array for later. */
-	group_size = i;
-	tset.tc_array = group;
-	tset.tc_array_len = group_size;
+	up_write(&css_set_rwsem);
 
 	/* methods shouldn't be called if no task is actually migrating */
-	ret = 0;
-	if (!group_size)
-		goto out_free_group_list;
+	if (list_empty(&tset.src_csets))
+		return 0;
 
 	/*
 	 * step 1: check that we can legitimately attach to the cgroup.
@@ -1831,16 +1829,21 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *leader,
 	 * step 2: make sure css_sets exist for all threads to be migrated.
 	 * we use find_css_set, which allocates a new one if necessary.
 	 */
-	for (i = 0; i < group_size; i++) {
-		struct css_set *old_cset;
+	list_for_each_entry(cset, &tset.src_csets, mg_node) {
+		struct css_set *dst_cset;
 
-		tc = flex_array_get(group, i);
-		old_cset = task_css_set(tc->task);
-		tc->cset = find_css_set(old_cset, cgrp);
-		if (!tc->cset) {
+		dst_cset = find_css_set(cset, cgrp);
+		if (!dst_cset) {
 			ret = -ENOMEM;
-			goto out_put_css_set_refs;
+			goto out_release_tset;
 		}
+
+		if (list_empty(&dst_cset->mg_node))
+			list_add(&dst_cset->mg_node, &tset.dst_csets);
+		else
+			put_css_set(dst_cset, false);
+
+		cset->mg_dst_cset = dst_cset;
 	}
 
 	/*
@@ -1849,12 +1852,17 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *leader,
 	 * failure cases after here, so this is the commit point.
 	 */
 	down_write(&css_set_rwsem);
-	for (i = 0; i < group_size; i++) {
-		tc = flex_array_get(group, i);
-		cgroup_task_migrate(tc->cgrp, tc->task, tc->cset);
+	list_for_each_entry(cset, &tset.src_csets, mg_node) {
+		list_for_each_entry_safe(task, tmp_task, &cset->mg_tasks, cg_list)
+			cgroup_task_migrate(cset->mg_src_cgrp, task,
+					    cset->mg_dst_cset);
 	}
 	up_write(&css_set_rwsem);
-	/* nothing is sensitive to fork() after this point. */
+
+	/* migration is committed, all target tasks are now on dst_csets */
+	tset.csets = &tset.dst_csets;
+
+	/* nothing is sensitive to fork() after this point */
 
 	/*
 	 * step 4: do subsystem attach callbacks.
@@ -1863,30 +1871,27 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *leader,
 		if (css->ss->attach)
 			css->ss->attach(css, &tset);
 
-	/*
-	 * step 5: success! and cleanup
-	 */
 	ret = 0;
-out_put_css_set_refs:
-	if (ret) {
-		for (i = 0; i < group_size; i++) {
-			tc = flex_array_get(group, i);
-			if (!tc->cset)
-				break;
-			put_css_set(tc->cset, false);
-		}
-	}
+	goto out_release_tset;
+
 out_cancel_attach:
-	if (ret) {
-		for_each_css(css, i, cgrp) {
-			if (css == failed_css)
-				break;
-			if (css->ss->cancel_attach)
-				css->ss->cancel_attach(css, &tset);
-		}
+	for_each_css(css, i, cgrp) {
+		if (css == failed_css)
+			break;
+		if (css->ss->cancel_attach)
+			css->ss->cancel_attach(css, &tset);
 	}
-out_free_group_list:
-	flex_array_free(group);
+out_release_tset:
+	down_write(&css_set_rwsem);
+	list_splice_init(&tset.dst_csets, &tset.src_csets);
+	list_for_each_entry_safe(cset, tmp_cset, &tset.src_csets, mg_node) {
+		list_splice_init(&cset->mg_tasks, &cset->tasks);
+		cset->mg_dst_cset = NULL;
+		cset->mg_src_cgrp = NULL;
+		list_del_init(&cset->mg_node);
+		put_css_set_locked(cset, false);
+	}
+	up_write(&css_set_rwsem);
 	return ret;
 }
 
@@ -3888,6 +3893,8 @@ int __init cgroup_init_early(void)
 	atomic_set(&init_css_set.refcount, 1);
 	INIT_LIST_HEAD(&init_css_set.cgrp_links);
 	INIT_LIST_HEAD(&init_css_set.tasks);
+	INIT_LIST_HEAD(&init_css_set.mg_tasks);
+	INIT_LIST_HEAD(&init_css_set.mg_node);
 	INIT_HLIST_NODE(&init_css_set.hlist);
 	css_set_count = 1;
 	init_cgroup_root(&cgroup_dummy_root);
-- 
1.8.5.3
