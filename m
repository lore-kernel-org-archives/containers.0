From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/7] cgroup: split process / task migration into four steps
Date: Thu, 13 Feb 2014 15:28:50 -0500
Message-ID: <1392323333-18907-5-git-send-email-tj@kernel.org>
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

Currently, process / task migration is a single operation which may
fail depending on memory pressure or the involved controllers'
->can_attach() callbacks.  One problem with this approach is migration
of multiple targets.  It's impossible to tell whether a given target
will be successfully migrated beforehand and cgroup core can't keep
track of enough states to roll back after intermediate failure.

This is already an issue with cgroup_transfer_tasks().  Also, we're
gonna need multiple target migration for unified hierarchy.

This patch splits migration into four stages -
cgroup_migrate_add_src(), cgroup_migrate_prepare_dst(),
cgroup_migrate() and cgroup_migrate_finish(), where
cgroup_migrate_prepare_dst() performs all the operations which may
fail due to allocation failure without actually migrating the target.

The four separate stages mean that, disregarding ->can_attach()
failures, the success or failure of multi target migration can be
determined before performing any actual migration.  If preparations of
all targets succeed, the whole thing will succeed.  If not, the whole
operation can fail without any side-effect.

Since the previous patch to use css_set->mg_tasks to keep track of
migration targets, the only thing which may need memory allocation
during migration is the target css_sets.  cgroup_migrate_prepare()
pins all source and target css_sets and link them up.  Note that this
can be performed without holding threadgroup_lock even if the target
is a process.  As long as cgroup_mutex is held, no new css_set can be
put into play.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |   1 +
 kernel/cgroup.c        | 240 +++++++++++++++++++++++++++++++++++++------------
 2 files changed, 182 insertions(+), 59 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 42a0b56..366a2cc 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -350,6 +350,7 @@ struct css_set {
 	 * List of csets participating in the on-going migration either as
 	 * source or destination.  Protected by cgroup_mutex.
 	 */
+	struct list_head mg_preload_node;
 	struct list_head mg_node;
 
 	/*
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index cc35a20..aca3661 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -644,6 +644,7 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 	INIT_LIST_HEAD(&cset->cgrp_links);
 	INIT_LIST_HEAD(&cset->tasks);
 	INIT_LIST_HEAD(&cset->mg_tasks);
+	INIT_LIST_HEAD(&cset->mg_preload_node);
 	INIT_LIST_HEAD(&cset->mg_node);
 	INIT_HLIST_NODE(&cset->hlist);
 
@@ -1753,16 +1754,137 @@ static void cgroup_task_migrate(struct cgroup *old_cgrp,
 }
 
 /**
- * cgroup_attach_task - attach a task or a whole threadgroup to a cgroup
- * @cgrp: the cgroup to attach to
- * @leader: the task or the leader of the threadgroup to be attached
- * @threadgroup: attach the whole threadgroup?
+ * cgroup_migrate_finish - cleanup after attach
+ * @preloaded_csets: list of preloaded css_sets
  *
- * Call holding cgroup_mutex and the group_rwsem of the leader. Will take
- * task_lock of @tsk or each thread in the threadgroup individually in turn.
+ * Undo cgroup_migrate_add_src() and cgroup_migrate_prepare_dst().  See
+ * those functions for details.
  */
-static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *leader,
-			      bool threadgroup)
+static void cgroup_migrate_finish(struct list_head *preloaded_csets)
+{
+	struct css_set *cset, *tmp_cset;
+
+	lockdep_assert_held(&cgroup_mutex);
+
+	down_write(&css_set_rwsem);
+	list_for_each_entry_safe(cset, tmp_cset, preloaded_csets, mg_preload_node) {
+		cset->mg_src_cgrp = NULL;
+		cset->mg_dst_cset = NULL;
+		list_del_init(&cset->mg_preload_node);
+		put_css_set_locked(cset, false);
+	}
+	up_write(&css_set_rwsem);
+}
+
+/**
+ * cgroup_migrate_add_src - add a migration source css_set
+ * @src_cset: the source css_set to add
+ * @dst_cgrp: the destination cgroup
+ * @preloaded_csets: list of preloaded css_sets
+ *
+ * Tasks belonging to @src_cset are about to be migrated to @dst_cgrp.  Pin
+ * @src_cset and add it to @preloaded_csets, which should later be cleaned
+ * up by cgroup_migrate_finish().
+ *
+ * This function may be called without holding threadgroup_lock even if the
+ * target is a process.  Threads may be created and destroyed but as long
+ * as cgroup_mutex is not dropped, no new css_set can be put into play and
+ * the preloaded css_sets are guaranteed to cover all migrations.
+ */
+static void cgroup_migrate_add_src(struct css_set *src_cset,
+				   struct cgroup *dst_cgrp,
+				   struct list_head *preloaded_csets)
+{
+	struct cgroup *src_cgrp;
+
+	lockdep_assert_held(&cgroup_mutex);
+	lockdep_assert_held(&css_set_rwsem);
+
+	src_cgrp = cset_cgroup_from_root(src_cset, dst_cgrp->root);
+
+	/* nothing to do if this cset already belongs to the cgroup */
+	if (src_cgrp == dst_cgrp)
+		return;
+
+	if (!list_empty(&src_cset->mg_preload_node))
+		return;
+
+	WARN_ON(src_cset->mg_src_cgrp);
+	WARN_ON(!list_empty(&src_cset->mg_tasks));
+	WARN_ON(!list_empty(&src_cset->mg_node));
+
+	src_cset->mg_src_cgrp = src_cgrp;
+	get_css_set(src_cset);
+	list_add(&src_cset->mg_preload_node, preloaded_csets);
+}
+
+/**
+ * cgroup_migrate_prepare_dst - prepare destination css_sets for migration
+ * @dst_cgrp: the destination cgroup
+ * @preloaded_csets: list of preloaded source css_sets
+ *
+ * Tasks are about to be moved to @dst_cgrp and all the source css_sets
+ * have been preloaded to @preloaded_csets.  This function looks up and
+ * pins all destination css_sets, links each to its source, and put them on
+ * @preloaded_csets.
+ *
+ * This function must be called after cgroup_migrate_add_src() has been
+ * called on each migration source css_set.  After migration is performed
+ * using cgroup_migrate(), cgroup_migrate_finish() must be called on
+ * @preloaded_csets.
+ */
+static int cgroup_migrate_prepare_dst(struct cgroup *dst_cgrp,
+				      struct list_head *preloaded_csets)
+{
+	LIST_HEAD(csets);
+	struct css_set *src_cset;
+
+	lockdep_assert_held(&cgroup_mutex);
+
+	/* look up the dst cset for each src cset and link it to src */
+	list_for_each_entry(src_cset, preloaded_csets, mg_preload_node) {
+		struct css_set *dst_cset;
+
+		dst_cset = find_css_set(src_cset, dst_cgrp);
+		if (!dst_cset)
+			goto err;
+
+		WARN_ON_ONCE(src_cset->mg_dst_cset || dst_cset->mg_dst_cset);
+		src_cset->mg_dst_cset = dst_cset;
+
+		if (list_empty(&dst_cset->mg_preload_node))
+			list_add(&dst_cset->mg_preload_node, &csets);
+		else
+			put_css_set(dst_cset, false);
+	}
+
+	list_splice(&csets, preloaded_csets);
+	return 0;
+err:
+	cgroup_migrate_finish(&csets);
+	return -ENOMEM;
+}
+
+/**
+ * cgroup_migrate - migrate a process or task to a cgroup
+ * @cgrp: the destination cgroup
+ * @leader: the leader of the process or the task to migrate
+ * @threadgroup: whether @leader points to the whole process or a single task
+ *
+ * Migrate a process or task denoted by @leader to @cgrp.  If migrating a
+ * process, the caller must be holding threadgroup_lock of @leader.  The
+ * caller is also responsible for invoking cgroup_migrate_add_src() and
+ * cgroup_migrate_prepare_dst() on the targets before invoking this
+ * function and following up with cgroup_migrate_finish().
+ *
+ * As long as a controller's ->can_attach() doesn't fail, this function is
+ * guaranteed to succeed.  This means that, excluding ->can_attach()
+ * failure, when migrating multiple targets, the success or failure can be
+ * decided for all targets by invoking group_migrate_prepare_dst() before
+ * actually starting migrating.
+ */
+static int cgroup_migrate(struct cgroup *cgrp, struct task_struct *leader,
+			  bool threadgroup)
 {
 	struct cgroup_taskset tset = {
 		.src_csets	= LIST_HEAD_INIT(tset.src_csets),
@@ -1783,29 +1905,17 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *leader,
 	rcu_read_lock();
 	task = leader;
 	do {
-		struct cgroup *src_cgrp;
-
 		/* @task either already exited or can't exit until the end */
 		if (task->flags & PF_EXITING)
 			goto next;
 
 		cset = task_css_set(task);
-		src_cgrp = task_cgroup_from_root(task, cgrp->root);
-
-		/* nothing to do if this task is already in the cgroup */
-		if (src_cgrp == cgrp)
+		if (!cset->mg_src_cgrp)
 			goto next;
 
-		if (!cset->mg_src_cgrp) {
-			WARN_ON(!list_empty(&cset->mg_tasks));
-			WARN_ON(!list_empty(&cset->mg_node));
-
-			cset->mg_src_cgrp = src_cgrp;
-			list_add(&cset->mg_node, &tset.src_csets);
-			get_css_set(cset);
-		}
-
 		list_move(&task->cg_list, &cset->mg_tasks);
+		list_move(&cset->mg_node, &tset.src_csets);
+		list_move(&cset->mg_dst_cset->mg_node, &tset.dst_csets);
 	next:
 		if (!threadgroup)
 			break;
@@ -1817,9 +1927,7 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *leader,
 	if (list_empty(&tset.src_csets))
 		return 0;
 
-	/*
-	 * step 1: check that we can legitimately attach to the cgroup.
-	 */
+	/* check that we can legitimately attach to the cgroup */
 	for_each_css(css, i, cgrp) {
 		if (css->ss->can_attach) {
 			ret = css->ss->can_attach(css, &tset);
@@ -1831,30 +1939,9 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *leader,
 	}
 
 	/*
-	 * step 2: make sure css_sets exist for all threads to be migrated.
-	 * we use find_css_set, which allocates a new one if necessary.
-	 */
-	list_for_each_entry(cset, &tset.src_csets, mg_node) {
-		struct css_set *dst_cset;
-
-		dst_cset = find_css_set(cset, cgrp);
-		if (!dst_cset) {
-			ret = -ENOMEM;
-			goto out_release_tset;
-		}
-
-		if (list_empty(&dst_cset->mg_node))
-			list_add(&dst_cset->mg_node, &tset.dst_csets);
-		else
-			put_css_set(dst_cset, false);
-
-		cset->mg_dst_cset = dst_cset;
-	}
-
-	/*
-	 * step 3: now that we're guaranteed success wrt the css_sets,
-	 * proceed to move all tasks to the new cgroup.  There are no
-	 * failure cases after here, so this is the commit point.
+	 * Now that we're guaranteed success, proceed to move all tasks to
+	 * the new cgroup.  There are no failure cases after here, so this
+	 * is the commit point.
 	 */
 	down_write(&css_set_rwsem);
 	list_for_each_entry(cset, &tset.src_csets, mg_node) {
@@ -1864,14 +1951,13 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *leader,
 	}
 	up_write(&css_set_rwsem);
 
-	/* migration is committed, all target tasks are now on dst_csets */
-	tset.csets = &tset.dst_csets;
-
-	/* nothing is sensitive to fork() after this point */
-
 	/*
-	 * step 4: do subsystem attach callbacks.
+	 * Migration is committed, all target tasks are now on dst_csets.
+	 * Nothing is sensitive to fork() after this point.  Notify
+	 * controllers that migration is complete.
 	 */
+	tset.csets = &tset.dst_csets;
+
 	for_each_css(css, i, cgrp)
 		if (css->ss->attach)
 			css->ss->attach(css, &tset);
@@ -1891,15 +1977,50 @@ out_release_tset:
 	list_splice_init(&tset.dst_csets, &tset.src_csets);
 	list_for_each_entry_safe(cset, tmp_cset, &tset.src_csets, mg_node) {
 		list_splice_init(&cset->mg_tasks, &cset->tasks);
-		cset->mg_dst_cset = NULL;
-		cset->mg_src_cgrp = NULL;
 		list_del_init(&cset->mg_node);
-		put_css_set_locked(cset, false);
 	}
 	up_write(&css_set_rwsem);
 	return ret;
 }
 
+/**
+ * cgroup_attach_task - attach a task or a whole threadgroup to a cgroup
+ * @dst_cgrp: the cgroup to attach to
+ * @leader: the task or the leader of the threadgroup to be attached
+ * @threadgroup: attach the whole threadgroup?
+ *
+ * Call holding cgroup_mutex and the group_rwsem of the leader. Will take
+ * task_lock of @tsk or each thread in the threadgroup individually in turn.
+ */
+static int cgroup_attach_task(struct cgroup *dst_cgrp,
+			      struct task_struct *leader, bool threadgroup)
+{
+	LIST_HEAD(preloaded_csets);
+	struct task_struct *task;
+	int ret;
+
+	/* look up all src csets */
+	down_read(&css_set_rwsem);
+	rcu_read_lock();
+	task = leader;
+	do {
+		cgroup_migrate_add_src(task_css_set(task), dst_cgrp,
+				       &preloaded_csets);
+		if (!threadgroup)
+			break;
+	} while_each_thread(leader, task);
+	rcu_read_unlock();
+	up_read(&css_set_rwsem);
+
+	/* prepare dst csets and commit */
+	ret = cgroup_migrate_prepare_dst(dst_cgrp, &preloaded_csets);
+	if (!ret)
+		ret = cgroup_migrate(dst_cgrp, leader, threadgroup);
+
+	cgroup_migrate_finish(&preloaded_csets);
+	return ret;
+}
+
 /*
  * Find the task_struct of the task to attach by vpid and pass it along to the
  * function to attach either it or all tasks in its threadgroup. Will lock
@@ -3899,6 +4020,7 @@ int __init cgroup_init_early(void)
 	INIT_LIST_HEAD(&init_css_set.cgrp_links);
 	INIT_LIST_HEAD(&init_css_set.tasks);
 	INIT_LIST_HEAD(&init_css_set.mg_tasks);
+	INIT_LIST_HEAD(&init_css_set.mg_preload_node);
 	INIT_LIST_HEAD(&init_css_set.mg_node);
 	INIT_HLIST_NODE(&init_css_set.hlist);
 	css_set_count = 1;
-- 
1.8.5.3
