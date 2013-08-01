From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/23] cgroup: pass around cgroup_subsys_state instead of
	cgroup in subsystem methods
Date: Thu,  1 Aug 2013 17:49:46 -0400
Message-ID: <1375393801-4817-9-git-send-email-tj__17540.5964175754$1375393893$gmane$org@kernel.org>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375393801-4817-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

cgroup is currently in the process of transitioning to using struct
cgroup_subsys_state * as the primary handle instead of struct cgroup *
in subsystem implementations for the following reasons.

* With unified hierarchy, subsystems will be dynamically bound and
  unbound from cgroups and thus css's (cgroup_subsys_state) may be
  created and destroyed dynamically over the lifetime of a cgroup,
  which is different from the current state where all css's are
  allocated and destroyed together with the associated cgroup.  This
  in turn means that cgroup_css() should be synchronized and may
  return NULL, making it more cumbersome to use.

* Differing levels of per-subsystem granularity in the unified
  hierarchy means that the task and descendant iterators should behave
  differently depending on the specific subsystem the iteration is
  being performed for.

* In majority of the cases, subsystems only care about its part in the
  cgroup hierarchy - ie. the hierarchy of css's.  Subsystem methods
  often obtain the matching css pointer from the cgroup and don't
  bother with the cgroup pointer itself.  Passing around css fits
  much better.

This patch converts all cgroup_subsys methods to take @css instead of
@cgroup.  The conversions are mostly straight-forward.  A few
noteworthy changes are

* ->css_alloc() now takes css of the parent cgroup rather than the
  pointer to the new cgroup as the css for the new cgroup doesn't
  exist yet.  Knowing the parent css is enough for all the existing
  subsystems.

* In kernel/cgroup.c::offline_css(), unnecessary open coded css
  dereference is replaced with local variable access.

This patch shouldn't cause any behavior differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
---
 block/blk-cgroup.c        | 25 +++++++++++-----------
 include/linux/cgroup.h    | 24 ++++++++++++---------
 kernel/cgroup.c           | 53 ++++++++++++++++++++++++++++-------------------
 kernel/cgroup_freezer.c   | 40 ++++++++++++++++++-----------------
 kernel/cpuset.c           | 39 ++++++++++++++++++----------------
 kernel/events/core.c      | 18 +++++++++-------
 kernel/sched/core.c       | 39 +++++++++++++++++-----------------
 kernel/sched/cpuacct.c    |  9 ++++----
 mm/hugetlb_cgroup.c       | 19 ++++++++---------
 mm/memcontrol.c           | 38 ++++++++++++++++-----------------
 net/core/netprio_cgroup.c | 20 +++++++++---------
 net/sched/cls_cgroup.c    | 18 +++++++++-------
 security/device_cgroup.c  | 22 ++++++++++----------
 13 files changed, 195 insertions(+), 169 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 290792a..79fd9f4 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -765,18 +765,18 @@ struct cftype blkcg_files[] = {
 
 /**
  * blkcg_css_offline - cgroup css_offline callback
- * @cgroup: cgroup of interest
+ * @css: css of interest
  *
- * This function is called when @cgroup is about to go away and responsible
- * for shooting down all blkgs associated with @cgroup.  blkgs should be
+ * This function is called when @css is about to go away and responsible
+ * for shooting down all blkgs associated with @css.  blkgs should be
  * removed while holding both q and blkcg locks.  As blkcg lock is nested
  * inside q lock, this function performs reverse double lock dancing.
  *
  * This is the blkcg counterpart of ioc_release_fn().
  */
-static void blkcg_css_offline(struct cgroup *cgroup)
+static void blkcg_css_offline(struct cgroup_subsys_state *css)
 {
-	struct blkcg *blkcg = cgroup_to_blkcg(cgroup);
+	struct blkcg *blkcg = css_to_blkcg(css);
 
 	spin_lock_irq(&blkcg->lock);
 
@@ -798,21 +798,21 @@ static void blkcg_css_offline(struct cgroup *cgroup)
 	spin_unlock_irq(&blkcg->lock);
 }
 
-static void blkcg_css_free(struct cgroup *cgroup)
+static void blkcg_css_free(struct cgroup_subsys_state *css)
 {
-	struct blkcg *blkcg = cgroup_to_blkcg(cgroup);
+	struct blkcg *blkcg = css_to_blkcg(css);
 
 	if (blkcg != &blkcg_root)
 		kfree(blkcg);
 }
 
-static struct cgroup_subsys_state *blkcg_css_alloc(struct cgroup *cgroup)
+static struct cgroup_subsys_state *
+blkcg_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	static atomic64_t id_seq = ATOMIC64_INIT(0);
 	struct blkcg *blkcg;
-	struct cgroup *parent = cgroup->parent;
 
-	if (!parent) {
+	if (!parent_css) {
 		blkcg = &blkcg_root;
 		goto done;
 	}
@@ -883,14 +883,15 @@ void blkcg_exit_queue(struct request_queue *q)
  * of the main cic data structures.  For now we allow a task to change
  * its cgroup only if it's the only owner of its ioc.
  */
-static int blkcg_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
+static int blkcg_can_attach(struct cgroup_subsys_state *css,
+			    struct cgroup_taskset *tset)
 {
 	struct task_struct *task;
 	struct io_context *ioc;
 	int ret = 0;
 
 	/* task_lock() is needed to avoid races with exit_io_context() */
-	cgroup_taskset_for_each(task, cgrp, tset) {
+	cgroup_taskset_for_each(task, css->cgroup, tset) {
 		task_lock(task);
 		ioc = task->io_context;
 		if (ioc && atomic_read(&ioc->nr_tasks) > 1)
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index b65f6b5..69b33f9 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -580,18 +580,22 @@ int cgroup_taskset_size(struct cgroup_taskset *tset);
  */
 
 struct cgroup_subsys {
-	struct cgroup_subsys_state *(*css_alloc)(struct cgroup *cgrp);
-	int (*css_online)(struct cgroup *cgrp);
-	void (*css_offline)(struct cgroup *cgrp);
-	void (*css_free)(struct cgroup *cgrp);
-
-	int (*can_attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
-	void (*cancel_attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
-	void (*attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
+	struct cgroup_subsys_state *(*css_alloc)(struct cgroup_subsys_state *parent_css);
+	int (*css_online)(struct cgroup_subsys_state *css);
+	void (*css_offline)(struct cgroup_subsys_state *css);
+	void (*css_free)(struct cgroup_subsys_state *css);
+
+	int (*can_attach)(struct cgroup_subsys_state *css,
+			  struct cgroup_taskset *tset);
+	void (*cancel_attach)(struct cgroup_subsys_state *css,
+			      struct cgroup_taskset *tset);
+	void (*attach)(struct cgroup_subsys_state *css,
+		       struct cgroup_taskset *tset);
 	void (*fork)(struct task_struct *task);
-	void (*exit)(struct cgroup *cgrp, struct cgroup *old_cgrp,
+	void (*exit)(struct cgroup_subsys_state *css,
+		     struct cgroup_subsys_state *old_css,
 		     struct task_struct *task);
-	void (*bind)(struct cgroup *root);
+	void (*bind)(struct cgroup_subsys_state *root_css);
 
 	int subsys_id;
 	int disabled;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index fad5498..fae11e3 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -853,8 +853,11 @@ static void cgroup_free_fn(struct work_struct *work)
 	/*
 	 * Release the subsystem state objects.
 	 */
-	for_each_root_subsys(cgrp->root, ss)
-		ss->css_free(cgrp);
+	for_each_root_subsys(cgrp->root, ss) {
+		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+
+		ss->css_free(css);
+	}
 
 	cgrp->root->number_of_cgroups--;
 	mutex_unlock(&cgroup_mutex);
@@ -1056,7 +1059,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			list_move(&ss->sibling, &root->subsys_list);
 			ss->root = root;
 			if (ss->bind)
-				ss->bind(cgrp);
+				ss->bind(cgrp->subsys[i]);
 
 			/* refcount was already taken, and we're keeping it */
 			root->subsys_mask |= bit;
@@ -1066,7 +1069,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
 
 			if (ss->bind)
-				ss->bind(cgroup_dummy_top);
+				ss->bind(cgroup_dummy_top->subsys[i]);
 			cgroup_dummy_top->subsys[i]->cgroup = cgroup_dummy_top;
 			cgrp->subsys[i] = NULL;
 			cgroup_subsys[i]->root = &cgroup_dummy_root;
@@ -2042,8 +2045,10 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
 	 * step 1: check that we can legitimately attach to the cgroup.
 	 */
 	for_each_root_subsys(root, ss) {
+		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+
 		if (ss->can_attach) {
-			retval = ss->can_attach(cgrp, &tset);
+			retval = ss->can_attach(css, &tset);
 			if (retval) {
 				failed_ss = ss;
 				goto out_cancel_attach;
@@ -2082,8 +2087,10 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
 	 * step 4: do subsystem attach callbacks.
 	 */
 	for_each_root_subsys(root, ss) {
+		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+
 		if (ss->attach)
-			ss->attach(cgrp, &tset);
+			ss->attach(css, &tset);
 	}
 
 	/*
@@ -2102,10 +2109,12 @@ out_put_css_set_refs:
 out_cancel_attach:
 	if (retval) {
 		for_each_root_subsys(root, ss) {
+			struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+
 			if (ss == failed_ss)
 				break;
 			if (ss->cancel_attach)
-				ss->cancel_attach(cgrp, &tset);
+				ss->cancel_attach(css, &tset);
 		}
 	}
 out_free_group_list:
@@ -4199,12 +4208,13 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 /* invoke ->css_online() on a new CSS and mark it online if successful */
 static int online_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
 {
+	struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
 	int ret = 0;
 
 	lockdep_assert_held(&cgroup_mutex);
 
 	if (ss->css_online)
-		ret = ss->css_online(cgrp);
+		ret = ss->css_online(css);
 	if (!ret)
 		cgrp->subsys[ss->subsys_id]->flags |= CSS_ONLINE;
 	return ret;
@@ -4221,9 +4231,9 @@ static void offline_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
 		return;
 
 	if (ss->css_offline)
-		ss->css_offline(cgrp);
+		ss->css_offline(css);
 
-	cgrp->subsys[ss->subsys_id]->flags &= ~CSS_ONLINE;
+	css->flags &= ~CSS_ONLINE;
 }
 
 /*
@@ -4298,7 +4308,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	for_each_root_subsys(root, ss) {
 		struct cgroup_subsys_state *css;
 
-		css = ss->css_alloc(cgrp);
+		css = ss->css_alloc(parent->subsys[ss->subsys_id]);
 		if (IS_ERR(css)) {
 			err = PTR_ERR(css);
 			goto err_free_all;
@@ -4377,7 +4387,7 @@ err_free_all:
 
 		if (css) {
 			percpu_ref_cancel_init(&css->refcnt);
-			ss->css_free(cgrp);
+			ss->css_free(css);
 		}
 	}
 	mutex_unlock(&cgroup_mutex);
@@ -4632,7 +4642,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	/* Create the top cgroup state for this subsystem */
 	list_add(&ss->sibling, &cgroup_dummy_root.subsys_list);
 	ss->root = &cgroup_dummy_root;
-	css = ss->css_alloc(cgroup_dummy_top);
+	css = ss->css_alloc(cgroup_dummy_top->subsys[ss->subsys_id]);
 	/* We don't handle early failures gracefully */
 	BUG_ON(IS_ERR(css));
 	init_cgroup_css(css, ss, cgroup_dummy_top);
@@ -4711,7 +4721,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	 * struct, so this can happen first (i.e. before the dummy root
 	 * attachment).
 	 */
-	css = ss->css_alloc(cgroup_dummy_top);
+	css = ss->css_alloc(cgroup_dummy_top->subsys[ss->subsys_id]);
 	if (IS_ERR(css)) {
 		/* failure case - need to deassign the cgroup_subsys[] slot. */
 		cgroup_subsys[ss->subsys_id] = NULL;
@@ -4827,7 +4837,7 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	 * the cgrp->subsys pointer to find their state. note that this
 	 * also takes care of freeing the css_id.
 	 */
-	ss->css_free(cgroup_dummy_top);
+	ss->css_free(cgroup_dummy_top->subsys[ss->subsys_id]);
 	cgroup_dummy_top->subsys[ss->subsys_id] = NULL;
 
 	mutex_unlock(&cgroup_mutex);
@@ -5183,10 +5193,10 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 		 */
 		for_each_builtin_subsys(ss, i) {
 			if (ss->exit) {
-				struct cgroup *old_cgrp = cset->subsys[i]->cgroup;
-				struct cgroup *cgrp = task_cgroup(tsk, i);
+				struct cgroup_subsys_state *old_css = cset->subsys[i];
+				struct cgroup_subsys_state *css = task_css(tsk, i);
 
-				ss->exit(cgrp, old_cgrp, tsk);
+				ss->exit(css, old_css, tsk);
 			}
 		}
 	}
@@ -5520,7 +5530,8 @@ struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id)
 }
 
 #ifdef CONFIG_CGROUP_DEBUG
-static struct cgroup_subsys_state *debug_css_alloc(struct cgroup *cgrp)
+static struct cgroup_subsys_state *
+debug_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct cgroup_subsys_state *css = kzalloc(sizeof(*css), GFP_KERNEL);
 
@@ -5530,9 +5541,9 @@ static struct cgroup_subsys_state *debug_css_alloc(struct cgroup *cgrp)
 	return css;
 }
 
-static void debug_css_free(struct cgroup *cgrp)
+static void debug_css_free(struct cgroup_subsys_state *css)
 {
-	kfree(cgrp->subsys[debug_subsys_id]);
+	kfree(css);
 }
 
 static u64 debug_taskcount_read(struct cgroup *cgrp, struct cftype *cft)
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 657a73c..f03a857 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -91,7 +91,8 @@ static const char *freezer_state_strs(unsigned int state)
 
 struct cgroup_subsys freezer_subsys;
 
-static struct cgroup_subsys_state *freezer_css_alloc(struct cgroup *cgroup)
+static struct cgroup_subsys_state *
+freezer_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct freezer *freezer;
 
@@ -104,16 +105,16 @@ static struct cgroup_subsys_state *freezer_css_alloc(struct cgroup *cgroup)
 }
 
 /**
- * freezer_css_online - commit creation of a freezer cgroup
- * @cgroup: cgroup being created
+ * freezer_css_online - commit creation of a freezer css
+ * @css: css being created
  *
- * We're committing to creation of @cgroup.  Mark it online and inherit
+ * We're committing to creation of @css.  Mark it online and inherit
  * parent's freezing state while holding both parent's and our
  * freezer->lock.
  */
-static int freezer_css_online(struct cgroup *cgroup)
+static int freezer_css_online(struct cgroup_subsys_state *css)
 {
-	struct freezer *freezer = cgroup_freezer(cgroup);
+	struct freezer *freezer = css_freezer(css);
 	struct freezer *parent = parent_freezer(freezer);
 
 	/*
@@ -140,15 +141,15 @@ static int freezer_css_online(struct cgroup *cgroup)
 }
 
 /**
- * freezer_css_offline - initiate destruction of @cgroup
- * @cgroup: cgroup being destroyed
+ * freezer_css_offline - initiate destruction of a freezer css
+ * @css: css being destroyed
  *
- * @cgroup is going away.  Mark it dead and decrement system_freezing_count
- * if it was holding one.
+ * @css is going away.  Mark it dead and decrement system_freezing_count if
+ * it was holding one.
  */
-static void freezer_css_offline(struct cgroup *cgroup)
+static void freezer_css_offline(struct cgroup_subsys_state *css)
 {
-	struct freezer *freezer = cgroup_freezer(cgroup);
+	struct freezer *freezer = css_freezer(css);
 
 	spin_lock_irq(&freezer->lock);
 
@@ -160,9 +161,9 @@ static void freezer_css_offline(struct cgroup *cgroup)
 	spin_unlock_irq(&freezer->lock);
 }
 
-static void freezer_css_free(struct cgroup *cgroup)
+static void freezer_css_free(struct cgroup_subsys_state *css)
 {
-	kfree(cgroup_freezer(cgroup));
+	kfree(css_freezer(css));
 }
 
 /*
@@ -174,25 +175,26 @@ static void freezer_css_free(struct cgroup *cgroup)
  * @freezer->lock.  freezer_attach() makes the new tasks conform to the
  * current state and all following state changes can see the new tasks.
  */
-static void freezer_attach(struct cgroup *new_cgrp, struct cgroup_taskset *tset)
+static void freezer_attach(struct cgroup_subsys_state *new_css,
+			   struct cgroup_taskset *tset)
 {
-	struct freezer *freezer = cgroup_freezer(new_cgrp);
+	struct freezer *freezer = css_freezer(new_css);
 	struct task_struct *task;
 	bool clear_frozen = false;
 
 	spin_lock_irq(&freezer->lock);
 
 	/*
-	 * Make the new tasks conform to the current state of @new_cgrp.
+	 * Make the new tasks conform to the current state of @new_css.
 	 * For simplicity, when migrating any task to a FROZEN cgroup, we
 	 * revert it to FREEZING and let update_if_frozen() determine the
 	 * correct state later.
 	 *
-	 * Tasks in @tset are on @new_cgrp but may not conform to its
+	 * Tasks in @tset are on @new_css but may not conform to its
 	 * current state before executing the following - !frozen tasks may
 	 * be visible in a FROZEN cgroup and frozen tasks in a THAWED one.
 	 */
-	cgroup_taskset_for_each(task, new_cgrp, tset) {
+	cgroup_taskset_for_each(task, new_css->cgroup, tset) {
 		if (!(freezer->state & CGROUP_FREEZING)) {
 			__thaw_task(task);
 		} else {
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 259a4af..8ce3fdc 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1455,9 +1455,10 @@ static int fmeter_getrate(struct fmeter *fmp)
 }
 
 /* Called by cgroups to determine if a cpuset is usable; cpuset_mutex held */
-static int cpuset_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
+static int cpuset_can_attach(struct cgroup_subsys_state *css,
+			     struct cgroup_taskset *tset)
 {
-	struct cpuset *cs = cgroup_cs(cgrp);
+	struct cpuset *cs = css_cs(css);
 	struct task_struct *task;
 	int ret;
 
@@ -1468,11 +1469,11 @@ static int cpuset_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 	 * flag is set.
 	 */
 	ret = -ENOSPC;
-	if (!cgroup_sane_behavior(cgrp) &&
+	if (!cgroup_sane_behavior(css->cgroup) &&
 	    (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed)))
 		goto out_unlock;
 
-	cgroup_taskset_for_each(task, cgrp, tset) {
+	cgroup_taskset_for_each(task, css->cgroup, tset) {
 		/*
 		 * Kthreads which disallow setaffinity shouldn't be moved
 		 * to a new cpuset; we don't want to change their cpu
@@ -1501,11 +1502,11 @@ out_unlock:
 	return ret;
 }
 
-static void cpuset_cancel_attach(struct cgroup *cgrp,
+static void cpuset_cancel_attach(struct cgroup_subsys_state *css,
 				 struct cgroup_taskset *tset)
 {
 	mutex_lock(&cpuset_mutex);
-	cgroup_cs(cgrp)->attach_in_progress--;
+	css_cs(css)->attach_in_progress--;
 	mutex_unlock(&cpuset_mutex);
 }
 
@@ -1516,7 +1517,8 @@ static void cpuset_cancel_attach(struct cgroup *cgrp,
  */
 static cpumask_var_t cpus_attach;
 
-static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
+static void cpuset_attach(struct cgroup_subsys_state *css,
+			  struct cgroup_taskset *tset)
 {
 	/* static buf protected by cpuset_mutex */
 	static nodemask_t cpuset_attach_nodemask_to;
@@ -1524,7 +1526,7 @@ static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 	struct task_struct *task;
 	struct task_struct *leader = cgroup_taskset_first(tset);
 	struct cgroup *oldcgrp = cgroup_taskset_cur_cgroup(tset);
-	struct cpuset *cs = cgroup_cs(cgrp);
+	struct cpuset *cs = css_cs(css);
 	struct cpuset *oldcs = cgroup_cs(oldcgrp);
 	struct cpuset *cpus_cs = effective_cpumask_cpuset(cs);
 	struct cpuset *mems_cs = effective_nodemask_cpuset(cs);
@@ -1539,7 +1541,7 @@ static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 
 	guarantee_online_mems(mems_cs, &cpuset_attach_nodemask_to);
 
-	cgroup_taskset_for_each(task, cgrp, tset) {
+	cgroup_taskset_for_each(task, css->cgroup, tset) {
 		/*
 		 * can_attach beforehand should guarantee that this doesn't
 		 * fail.  TODO: have a better way to handle failure here
@@ -1940,11 +1942,12 @@ static struct cftype files[] = {
  *	cgrp:	control group that the new cpuset will be part of
  */
 
-static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cgrp)
+static struct cgroup_subsys_state *
+cpuset_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct cpuset *cs;
 
-	if (!cgrp->parent)
+	if (!parent_css)
 		return &top_cpuset.css;
 
 	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
@@ -1964,9 +1967,9 @@ static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cgrp)
 	return &cs->css;
 }
 
-static int cpuset_css_online(struct cgroup *cgrp)
+static int cpuset_css_online(struct cgroup_subsys_state *css)
 {
-	struct cpuset *cs = cgroup_cs(cgrp);
+	struct cpuset *cs = css_cs(css);
 	struct cpuset *parent = parent_cs(cs);
 	struct cpuset *tmp_cs;
 	struct cgroup *pos_cgrp;
@@ -1984,7 +1987,7 @@ static int cpuset_css_online(struct cgroup *cgrp)
 
 	number_of_cpusets++;
 
-	if (!test_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags))
+	if (!test_bit(CGRP_CPUSET_CLONE_CHILDREN, &css->cgroup->flags))
 		goto out_unlock;
 
 	/*
@@ -2024,9 +2027,9 @@ out_unlock:
  * will call rebuild_sched_domains_locked().
  */
 
-static void cpuset_css_offline(struct cgroup *cgrp)
+static void cpuset_css_offline(struct cgroup_subsys_state *css)
 {
-	struct cpuset *cs = cgroup_cs(cgrp);
+	struct cpuset *cs = css_cs(css);
 
 	mutex_lock(&cpuset_mutex);
 
@@ -2039,9 +2042,9 @@ static void cpuset_css_offline(struct cgroup *cgrp)
 	mutex_unlock(&cpuset_mutex);
 }
 
-static void cpuset_css_free(struct cgroup *cgrp)
+static void cpuset_css_free(struct cgroup_subsys_state *css)
 {
-	struct cpuset *cs = cgroup_cs(cgrp);
+	struct cpuset *cs = css_cs(css);
 
 	free_cpumask_var(cs->cpus_allowed);
 	kfree(cs);
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 414c61f..9705a0e 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -7778,7 +7778,8 @@ unlock:
 device_initcall(perf_event_sysfs_init);
 
 #ifdef CONFIG_CGROUP_PERF
-static struct cgroup_subsys_state *perf_cgroup_css_alloc(struct cgroup *cont)
+static struct cgroup_subsys_state *
+perf_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct perf_cgroup *jc;
 
@@ -7795,11 +7796,10 @@ static struct cgroup_subsys_state *perf_cgroup_css_alloc(struct cgroup *cont)
 	return &jc->css;
 }
 
-static void perf_cgroup_css_free(struct cgroup *cont)
+static void perf_cgroup_css_free(struct cgroup_subsys_state *css)
 {
-	struct perf_cgroup *jc;
-	jc = container_of(cgroup_css(cont, perf_subsys_id),
-			  struct perf_cgroup, css);
+	struct perf_cgroup *jc = container_of(css, struct perf_cgroup, css);
+
 	free_percpu(jc->info);
 	kfree(jc);
 }
@@ -7811,15 +7811,17 @@ static int __perf_cgroup_move(void *info)
 	return 0;
 }
 
-static void perf_cgroup_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
+static void perf_cgroup_attach(struct cgroup_subsys_state *css,
+			       struct cgroup_taskset *tset)
 {
 	struct task_struct *task;
 
-	cgroup_taskset_for_each(task, cgrp, tset)
+	cgroup_taskset_for_each(task, css->cgroup, tset)
 		task_function_call(task, __perf_cgroup_move, task);
 }
 
-static void perf_cgroup_exit(struct cgroup *cgrp, struct cgroup *old_cgrp,
+static void perf_cgroup_exit(struct cgroup_subsys_state *css,
+			     struct cgroup_subsys_state *old_css,
 			     struct task_struct *task)
 {
 	/*
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 7a10742..622b7ef 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7094,16 +7094,17 @@ static inline struct task_group *cgroup_tg(struct cgroup *cgrp)
 	return css_tg(cgroup_css(cgrp, cpu_cgroup_subsys_id));
 }
 
-static struct cgroup_subsys_state *cpu_cgroup_css_alloc(struct cgroup *cgrp)
+static struct cgroup_subsys_state *
+cpu_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
-	struct task_group *tg, *parent;
+	struct task_group *parent = css_tg(parent_css);
+	struct task_group *tg;
 
-	if (!cgrp->parent) {
+	if (!parent) {
 		/* This is early initialization for the top cgroup */
 		return &root_task_group.css;
 	}
 
-	parent = cgroup_tg(cgrp->parent);
 	tg = sched_create_group(parent);
 	if (IS_ERR(tg))
 		return ERR_PTR(-ENOMEM);
@@ -7111,38 +7112,38 @@ static struct cgroup_subsys_state *cpu_cgroup_css_alloc(struct cgroup *cgrp)
 	return &tg->css;
 }
 
-static int cpu_cgroup_css_online(struct cgroup *cgrp)
+static int cpu_cgroup_css_online(struct cgroup_subsys_state *css)
 {
-	struct task_group *tg = cgroup_tg(cgrp);
-	struct task_group *parent = css_tg(css_parent(&tg->css));
+	struct task_group *tg = css_tg(css);
+	struct task_group *parent = css_tg(css_parent(css));
 
 	if (parent)
 		sched_online_group(tg, parent);
 	return 0;
 }
 
-static void cpu_cgroup_css_free(struct cgroup *cgrp)
+static void cpu_cgroup_css_free(struct cgroup_subsys_state *css)
 {
-	struct task_group *tg = cgroup_tg(cgrp);
+	struct task_group *tg = css_tg(css);
 
 	sched_destroy_group(tg);
 }
 
-static void cpu_cgroup_css_offline(struct cgroup *cgrp)
+static void cpu_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
-	struct task_group *tg = cgroup_tg(cgrp);
+	struct task_group *tg = css_tg(css);
 
 	sched_offline_group(tg);
 }
 
-static int cpu_cgroup_can_attach(struct cgroup *cgrp,
+static int cpu_cgroup_can_attach(struct cgroup_subsys_state *css,
 				 struct cgroup_taskset *tset)
 {
 	struct task_struct *task;
 
-	cgroup_taskset_for_each(task, cgrp, tset) {
+	cgroup_taskset_for_each(task, css->cgroup, tset) {
 #ifdef CONFIG_RT_GROUP_SCHED
-		if (!sched_rt_can_attach(cgroup_tg(cgrp), task))
+		if (!sched_rt_can_attach(css_tg(css), task))
 			return -EINVAL;
 #else
 		/* We don't support RT-tasks being in separate groups */
@@ -7153,18 +7154,18 @@ static int cpu_cgroup_can_attach(struct cgroup *cgrp,
 	return 0;
 }
 
-static void cpu_cgroup_attach(struct cgroup *cgrp,
+static void cpu_cgroup_attach(struct cgroup_subsys_state *css,
 			      struct cgroup_taskset *tset)
 {
 	struct task_struct *task;
 
-	cgroup_taskset_for_each(task, cgrp, tset)
+	cgroup_taskset_for_each(task, css->cgroup, tset)
 		sched_move_task(task);
 }
 
-static void
-cpu_cgroup_exit(struct cgroup *cgrp, struct cgroup *old_cgrp,
-		struct task_struct *task)
+static void cpu_cgroup_exit(struct cgroup_subsys_state *css,
+			    struct cgroup_subsys_state *old_css,
+			    struct task_struct *task)
 {
 	/*
 	 * cgroup_exit() is called in the copy_process() failure path.
diff --git a/kernel/sched/cpuacct.c b/kernel/sched/cpuacct.c
index f6926a1..1b784d9 100644
--- a/kernel/sched/cpuacct.c
+++ b/kernel/sched/cpuacct.c
@@ -62,11 +62,12 @@ static struct cpuacct root_cpuacct = {
 };
 
 /* create a new cpu accounting group */
-static struct cgroup_subsys_state *cpuacct_css_alloc(struct cgroup *cgrp)
+static struct cgroup_subsys_state *
+cpuacct_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct cpuacct *ca;
 
-	if (!cgrp->parent)
+	if (!parent_css)
 		return &root_cpuacct.css;
 
 	ca = kzalloc(sizeof(*ca), GFP_KERNEL);
@@ -92,9 +93,9 @@ out:
 }
 
 /* destroy an existing cpu accounting group */
-static void cpuacct_css_free(struct cgroup *cgrp)
+static void cpuacct_css_free(struct cgroup_subsys_state *css)
 {
-	struct cpuacct *ca = cgroup_ca(cgrp);
+	struct cpuacct *ca = css_ca(css);
 
 	free_percpu(ca->cpustat);
 	free_percpu(ca->cpuusage);
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 57ecb5d..e213243 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -73,19 +73,18 @@ static inline bool hugetlb_cgroup_have_usage(struct hugetlb_cgroup *h_cg)
 	return false;
 }
 
-static struct cgroup_subsys_state *hugetlb_cgroup_css_alloc(struct cgroup *cgroup)
+static struct cgroup_subsys_state *
+hugetlb_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
+	struct hugetlb_cgroup *parent_h_cgroup = hugetlb_cgroup_from_css(parent_css);
+	struct hugetlb_cgroup *h_cgroup;
 	int idx;
-	struct cgroup *parent_cgroup;
-	struct hugetlb_cgroup *h_cgroup, *parent_h_cgroup;
 
 	h_cgroup = kzalloc(sizeof(*h_cgroup), GFP_KERNEL);
 	if (!h_cgroup)
 		return ERR_PTR(-ENOMEM);
 
-	parent_cgroup = cgroup->parent;
-	if (parent_cgroup) {
-		parent_h_cgroup = hugetlb_cgroup_from_cgroup(parent_cgroup);
+	if (parent_h_cgroup) {
 		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
 			res_counter_init(&h_cgroup->hugepage[idx],
 					 &parent_h_cgroup->hugepage[idx]);
@@ -97,11 +96,11 @@ static struct cgroup_subsys_state *hugetlb_cgroup_css_alloc(struct cgroup *cgrou
 	return &h_cgroup->css;
 }
 
-static void hugetlb_cgroup_css_free(struct cgroup *cgroup)
+static void hugetlb_cgroup_css_free(struct cgroup_subsys_state *css)
 {
 	struct hugetlb_cgroup *h_cgroup;
 
-	h_cgroup = hugetlb_cgroup_from_cgroup(cgroup);
+	h_cgroup = hugetlb_cgroup_from_css(css);
 	kfree(h_cgroup);
 }
 
@@ -150,9 +149,9 @@ out:
  * Force the hugetlb cgroup to empty the hugetlb resources by moving them to
  * the parent cgroup.
  */
-static void hugetlb_cgroup_css_offline(struct cgroup *cgroup)
+static void hugetlb_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
-	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cgroup);
+	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(css);
 	struct hstate *h;
 	struct page *page;
 	int idx = 0;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 69b3e52..32cca0f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6211,7 +6211,7 @@ static void __init mem_cgroup_soft_limit_tree_init(void)
 }
 
 static struct cgroup_subsys_state * __ref
-mem_cgroup_css_alloc(struct cgroup *cont)
+mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct mem_cgroup *memcg;
 	long error = -ENOMEM;
@@ -6226,7 +6226,7 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 			goto free_out;
 
 	/* root ? */
-	if (cont->parent == NULL) {
+	if (parent_css == NULL) {
 		root_mem_cgroup = memcg;
 		res_counter_init(&memcg->res, NULL);
 		res_counter_init(&memcg->memsw, NULL);
@@ -6248,10 +6248,10 @@ free_out:
 }
 
 static int
-mem_cgroup_css_online(struct cgroup *cont)
+mem_cgroup_css_online(struct cgroup_subsys_state *css)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
-	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(&memcg->css));
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(css));
 	int error = 0;
 
 	if (!parent)
@@ -6308,9 +6308,9 @@ static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)
 		mem_cgroup_iter_invalidate(root_mem_cgroup);
 }
 
-static void mem_cgroup_css_offline(struct cgroup *cont)
+static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
 	kmem_cgroup_css_offline(memcg);
 
@@ -6319,9 +6319,9 @@ static void mem_cgroup_css_offline(struct cgroup *cont)
 	mem_cgroup_destroy_all_caches(memcg);
 }
 
-static void mem_cgroup_css_free(struct cgroup *cont)
+static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
 	memcg_destroy_kmem(memcg);
 	__mem_cgroup_free(memcg);
@@ -6691,12 +6691,12 @@ static void mem_cgroup_clear_mc(void)
 	mem_cgroup_end_move(from);
 }
 
-static int mem_cgroup_can_attach(struct cgroup *cgroup,
+static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 				 struct cgroup_taskset *tset)
 {
 	struct task_struct *p = cgroup_taskset_first(tset);
 	int ret = 0;
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	unsigned long move_charge_at_immigrate;
 
 	/*
@@ -6738,7 +6738,7 @@ static int mem_cgroup_can_attach(struct cgroup *cgroup,
 	return ret;
 }
 
-static void mem_cgroup_cancel_attach(struct cgroup *cgroup,
+static void mem_cgroup_cancel_attach(struct cgroup_subsys_state *css,
 				     struct cgroup_taskset *tset)
 {
 	mem_cgroup_clear_mc();
@@ -6886,7 +6886,7 @@ retry:
 	up_read(&mm->mmap_sem);
 }
 
-static void mem_cgroup_move_task(struct cgroup *cont,
+static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
 				 struct cgroup_taskset *tset)
 {
 	struct task_struct *p = cgroup_taskset_first(tset);
@@ -6901,16 +6901,16 @@ static void mem_cgroup_move_task(struct cgroup *cont,
 		mem_cgroup_clear_mc();
 }
 #else	/* !CONFIG_MMU */
-static int mem_cgroup_can_attach(struct cgroup *cgroup,
+static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 				 struct cgroup_taskset *tset)
 {
 	return 0;
 }
-static void mem_cgroup_cancel_attach(struct cgroup *cgroup,
+static void mem_cgroup_cancel_attach(struct cgroup_subsys_state *css,
 				     struct cgroup_taskset *tset)
 {
 }
-static void mem_cgroup_move_task(struct cgroup *cont,
+static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
 				 struct cgroup_taskset *tset)
 {
 }
@@ -6920,15 +6920,15 @@ static void mem_cgroup_move_task(struct cgroup *cont,
  * Cgroup retains root cgroups across [un]mount cycles making it necessary
  * to verify sane_behavior flag on each mount attempt.
  */
-static void mem_cgroup_bind(struct cgroup *root)
+static void mem_cgroup_bind(struct cgroup_subsys_state *root_css)
 {
 	/*
 	 * use_hierarchy is forced with sane_behavior.  cgroup core
 	 * guarantees that @root doesn't have any children, so turning it
 	 * on for the root memcg is enough.
 	 */
-	if (cgroup_sane_behavior(root))
-		mem_cgroup_from_cont(root)->use_hierarchy = true;
+	if (cgroup_sane_behavior(root_css->cgroup))
+		mem_cgroup_from_css(root_css)->use_hierarchy = true;
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 5dfac88..8d095b4 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -126,7 +126,8 @@ static int netprio_set_prio(struct cgroup_subsys_state *css,
 	return 0;
 }
 
-static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
+static struct cgroup_subsys_state *
+cgrp_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct cgroup_subsys_state *css;
 
@@ -137,16 +138,14 @@ static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
 	return css;
 }
 
-static int cgrp_css_online(struct cgroup *cgrp)
+static int cgrp_css_online(struct cgroup_subsys_state *css)
 {
-	struct cgroup_subsys_state *css = cgroup_css(cgrp, net_prio_subsys_id);
-	struct cgroup_subsys_state *parent_css;
+	struct cgroup_subsys_state *parent_css = css_parent(css);
 	struct net_device *dev;
 	int ret = 0;
 
-	if (!cgrp->parent)
+	if (!parent_css)
 		return 0;
-	parent_css = cgroup_css(cgrp->parent, net_prio_subsys_id);
 
 	rtnl_lock();
 	/*
@@ -164,9 +163,9 @@ static int cgrp_css_online(struct cgroup *cgrp)
 	return ret;
 }
 
-static void cgrp_css_free(struct cgroup *cgrp)
+static void cgrp_css_free(struct cgroup_subsys_state *css)
 {
-	kfree(cgroup_css(cgrp, net_prio_subsys_id));
+	kfree(css);
 }
 
 static u64 read_prioidx(struct cgroup *cgrp, struct cftype *cft)
@@ -221,12 +220,13 @@ static int update_netprio(const void *v, struct file *file, unsigned n)
 	return 0;
 }
 
-static void net_prio_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
+static void net_prio_attach(struct cgroup_subsys_state *css,
+			    struct cgroup_taskset *tset)
 {
 	struct task_struct *p;
 	void *v;
 
-	cgroup_taskset_for_each(p, cgrp, tset) {
+	cgroup_taskset_for_each(p, css->cgroup, tset) {
 		task_lock(p);
 		v = (void *)(unsigned long)task_netprioidx(p);
 		iterate_fd(p->files, 0, update_netprio, v);
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 9e6b75e..dc39838 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -38,7 +38,8 @@ static inline struct cgroup_cls_state *task_cls_state(struct task_struct *p)
 	return css_cls_state(task_css(p, net_cls_subsys_id));
 }
 
-static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
+static struct cgroup_subsys_state *
+cgrp_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct cgroup_cls_state *cs;
 
@@ -48,19 +49,19 @@ static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
 	return &cs->css;
 }
 
-static int cgrp_css_online(struct cgroup *cgrp)
+static int cgrp_css_online(struct cgroup_subsys_state *css)
 {
-	struct cgroup_cls_state *cs = cgrp_cls_state(cgrp);
-	struct cgroup_cls_state *parent = css_cls_state(css_parent(&cs->css));
+	struct cgroup_cls_state *cs = css_cls_state(css);
+	struct cgroup_cls_state *parent = css_cls_state(css_parent(css));
 
 	if (parent)
 		cs->classid = parent->classid;
 	return 0;
 }
 
-static void cgrp_css_free(struct cgroup *cgrp)
+static void cgrp_css_free(struct cgroup_subsys_state *css)
 {
-	kfree(cgrp_cls_state(cgrp));
+	kfree(css_cls_state(css));
 }
 
 static int update_classid(const void *v, struct file *file, unsigned n)
@@ -72,12 +73,13 @@ static int update_classid(const void *v, struct file *file, unsigned n)
 	return 0;
 }
 
-static void cgrp_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
+static void cgrp_attach(struct cgroup_subsys_state *css,
+			struct cgroup_taskset *tset)
 {
 	struct task_struct *p;
 	void *v;
 
-	cgroup_taskset_for_each(p, cgrp, tset) {
+	cgroup_taskset_for_each(p, css->cgroup, tset) {
 		task_lock(p);
 		v = (void *)(unsigned long)task_cls_classid(p);
 		iterate_fd(p->files, 0, update_classid, v);
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 635a49d..7293ac4 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -68,7 +68,7 @@ static inline struct dev_cgroup *task_devcgroup(struct task_struct *task)
 
 struct cgroup_subsys devices_subsys;
 
-static int devcgroup_can_attach(struct cgroup *new_cgrp,
+static int devcgroup_can_attach(struct cgroup_subsys_state *new_css,
 				struct cgroup_taskset *set)
 {
 	struct task_struct *task = cgroup_taskset_first(set);
@@ -193,13 +193,13 @@ static inline bool is_devcg_online(const struct dev_cgroup *devcg)
 /**
  * devcgroup_online - initializes devcgroup's behavior and exceptions based on
  * 		      parent's
- * @cgroup: cgroup getting online
+ * @css: css getting online
  * returns 0 in case of success, error code otherwise
  */
-static int devcgroup_online(struct cgroup *cgroup)
+static int devcgroup_online(struct cgroup_subsys_state *css)
 {
-	struct dev_cgroup *dev_cgroup = cgroup_to_devcgroup(cgroup);
-	struct dev_cgroup *parent_dev_cgroup = css_to_devcgroup(css_parent(&dev_cgroup->css));
+	struct dev_cgroup *dev_cgroup = css_to_devcgroup(css);
+	struct dev_cgroup *parent_dev_cgroup = css_to_devcgroup(css_parent(css));
 	int ret = 0;
 
 	mutex_lock(&devcgroup_mutex);
@@ -217,9 +217,9 @@ static int devcgroup_online(struct cgroup *cgroup)
 	return ret;
 }
 
-static void devcgroup_offline(struct cgroup *cgroup)
+static void devcgroup_offline(struct cgroup_subsys_state *css)
 {
-	struct dev_cgroup *dev_cgroup = cgroup_to_devcgroup(cgroup);
+	struct dev_cgroup *dev_cgroup = css_to_devcgroup(css);
 
 	mutex_lock(&devcgroup_mutex);
 	dev_cgroup->behavior = DEVCG_DEFAULT_NONE;
@@ -229,7 +229,8 @@ static void devcgroup_offline(struct cgroup *cgroup)
 /*
  * called from kernel/cgroup.c with cgroup_lock() held.
  */
-static struct cgroup_subsys_state *devcgroup_css_alloc(struct cgroup *cgroup)
+static struct cgroup_subsys_state *
+devcgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct dev_cgroup *dev_cgroup;
 
@@ -242,11 +243,10 @@ static struct cgroup_subsys_state *devcgroup_css_alloc(struct cgroup *cgroup)
 	return &dev_cgroup->css;
 }
 
-static void devcgroup_css_free(struct cgroup *cgroup)
+static void devcgroup_css_free(struct cgroup_subsys_state *css)
 {
-	struct dev_cgroup *dev_cgroup;
+	struct dev_cgroup *dev_cgroup = css_to_devcgroup(css);
 
-	dev_cgroup = cgroup_to_devcgroup(cgroup);
 	__dev_exception_clean(dev_cgroup);
 	kfree(dev_cgroup);
 }
-- 
1.8.3.1
