From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/10] cgroup: don't use subsys->can_attach_task() or
	->attach_task()
Date: Tue,  1 Nov 2011 16:46:31 -0700
Message-ID: <1320191193-8110-9-git-send-email-tj__12317.3339678489$1320191274$gmane$org@kernel.org>
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
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Now that subsys->can_attach() and attach() take @tset instead of
@task, they can handle per-task operations.  Convert
->can_attach_task() and ->attach_task() users to use ->can_attach()
and attach() instead.  Most converions are straight-forward.
Noteworthy changes are,

* In cgroup_freezer, remove unnecessary NULL assignments to unused
  methods.  It's useless and very prone to get out of sync, which
  already happened.

* In cpuset, PF_THREAD_BOUND test is checked for each task.  This
  doesn't make any practical difference but is conceptually cleaner.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
---
 block/blk-cgroup.c      |   45 +++++++++++++++++++-----------
 kernel/cgroup_freezer.c |   25 ++++++-----------
 kernel/cpuset.c         |   70 +++++++++++++++++++++-------------------------
 kernel/events/core.c    |   13 +++++---
 kernel/sched.c          |   31 +++++++++++++--------
 5 files changed, 96 insertions(+), 88 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index b596e54..b5e3fef 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -30,8 +30,10 @@ EXPORT_SYMBOL_GPL(blkio_root_cgroup);
 
 static struct cgroup_subsys_state *blkiocg_create(struct cgroup_subsys *,
 						  struct cgroup *);
-static int blkiocg_can_attach_task(struct cgroup *, struct task_struct *);
-static void blkiocg_attach_task(struct cgroup *, struct task_struct *);
+static int blkiocg_can_attach(struct cgroup_subsys *, struct cgroup *,
+			      struct cgroup_taskset *);
+static void blkiocg_attach(struct cgroup_subsys *, struct cgroup *,
+			   struct cgroup_taskset *);
 static void blkiocg_destroy(struct cgroup_subsys *, struct cgroup *);
 static int blkiocg_populate(struct cgroup_subsys *, struct cgroup *);
 
@@ -44,8 +46,8 @@ static int blkiocg_populate(struct cgroup_subsys *, struct cgroup *);
 struct cgroup_subsys blkio_subsys = {
 	.name = "blkio",
 	.create = blkiocg_create,
-	.can_attach_task = blkiocg_can_attach_task,
-	.attach_task = blkiocg_attach_task,
+	.can_attach = blkiocg_can_attach,
+	.attach = blkiocg_attach,
 	.destroy = blkiocg_destroy,
 	.populate = blkiocg_populate,
 #ifdef CONFIG_BLK_CGROUP
@@ -1609,30 +1611,39 @@ done:
  * of the main cic data structures.  For now we allow a task to change
  * its cgroup only if it's the only owner of its ioc.
  */
-static int blkiocg_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+static int blkiocg_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			      struct cgroup_taskset *tset)
 {
+	struct task_struct *task;
 	struct io_context *ioc;
 	int ret = 0;
 
 	/* task_lock() is needed to avoid races with exit_io_context() */
-	task_lock(tsk);
-	ioc = tsk->io_context;
-	if (ioc && atomic_read(&ioc->nr_tasks) > 1)
-		ret = -EINVAL;
-	task_unlock(tsk);
-
+	cgroup_taskset_for_each(task, cgrp, tset) {
+		task_lock(task);
+		ioc = task->io_context;
+		if (ioc && atomic_read(&ioc->nr_tasks) > 1)
+			ret = -EINVAL;
+		task_unlock(task);
+		if (ret)
+			break;
+	}
 	return ret;
 }
 
-static void blkiocg_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+static void blkiocg_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			   struct cgroup_taskset *tset)
 {
+	struct task_struct *task;
 	struct io_context *ioc;
 
-	task_lock(tsk);
-	ioc = tsk->io_context;
-	if (ioc)
-		ioc->cgroup_changed = 1;
-	task_unlock(tsk);
+	cgroup_taskset_for_each(task, cgrp, tset) {
+		task_lock(task);
+		ioc = task->io_context;
+		if (ioc)
+			ioc->cgroup_changed = 1;
+		task_unlock(task);
+	}
 }
 
 void blkio_policy_register(struct blkio_policy_type *blkiop)
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index a72d5fa..68ef861 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -163,10 +163,19 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 			      struct cgroup_taskset *tset)
 {
 	struct freezer *freezer;
+	struct task_struct *task;
 
 	/*
 	 * Anything frozen can't move or be moved to/from.
 	 */
+	rcu_read_lock();
+	cgroup_taskset_for_each(task, new_cgroup, tset) {
+		if (__cgroup_freezing_or_frozen(task)) {
+			rcu_read_unlock();
+			return -EBUSY;
+		}
+	}
+	rcu_read_unlock();
 
 	freezer = cgroup_freezer(new_cgroup);
 	if (freezer->state != CGROUP_THAWED)
@@ -175,17 +184,6 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 	return 0;
 }
 
-static int freezer_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
-{
-	rcu_read_lock();
-	if (__cgroup_freezing_or_frozen(tsk)) {
-		rcu_read_unlock();
-		return -EBUSY;
-	}
-	rcu_read_unlock();
-	return 0;
-}
-
 static void freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
 {
 	struct freezer *freezer;
@@ -381,10 +379,5 @@ struct cgroup_subsys freezer_subsys = {
 	.populate	= freezer_populate,
 	.subsys_id	= freezer_subsys_id,
 	.can_attach	= freezer_can_attach,
-	.can_attach_task = freezer_can_attach_task,
-	.pre_attach	= NULL,
-	.attach_task	= NULL,
-	.attach		= NULL,
 	.fork		= freezer_fork,
-	.exit		= NULL,
 };
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 2e5825b..472ddd6 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1372,33 +1372,34 @@ static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			     struct cgroup_taskset *tset)
 {
 	struct cpuset *cs = cgroup_cs(cgrp);
+	struct task_struct *task;
+	int ret;
 
 	if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
 		return -ENOSPC;
 
-	/*
-	 * Kthreads bound to specific cpus cannot be moved to a new cpuset; we
-	 * cannot change their cpu affinity and isolating such threads by their
-	 * set of allowed nodes is unnecessary.  Thus, cpusets are not
-	 * applicable for such threads.  This prevents checking for success of
-	 * set_cpus_allowed_ptr() on all attached tasks before cpus_allowed may
-	 * be changed.
-	 */
-	if (cgroup_taskset_first(tset)->flags & PF_THREAD_BOUND)
-		return -EINVAL;
-
+	cgroup_taskset_for_each(task, cgrp, tset) {
+		/*
+		 * Kthreads bound to specific cpus cannot be moved to a new
+		 * cpuset; we cannot change their cpu affinity and
+		 * isolating such threads by their set of allowed nodes is
+		 * unnecessary.  Thus, cpusets are not applicable for such
+		 * threads.  This prevents checking for success of
+		 * set_cpus_allowed_ptr() on all attached tasks before
+		 * cpus_allowed may be changed.
+		 */
+		if (task->flags & PF_THREAD_BOUND)
+			return -EINVAL;
+		if ((ret = security_task_setscheduler(task)))
+			return ret;
+	}
 	return 0;
 }
 
-static int cpuset_can_attach_task(struct cgroup *cgrp, struct task_struct *task)
-{
-	return security_task_setscheduler(task);
-}
-
 /*
  * Protected by cgroup_lock. The nodemasks must be stored globally because
  * dynamically allocating them is not allowed in pre_attach, and they must
- * persist among pre_attach, attach_task, and attach.
+ * persist among pre_attach, and attach.
  */
 static cpumask_var_t cpus_attach;
 static nodemask_t cpuset_attach_nodemask_from;
@@ -1417,39 +1418,34 @@ static void cpuset_pre_attach(struct cgroup *cont)
 	guarantee_online_mems(cs, &cpuset_attach_nodemask_to);
 }
 
-/* Per-thread attachment work. */
-static void cpuset_attach_task(struct cgroup *cont, struct task_struct *tsk)
-{
-	int err;
-	struct cpuset *cs = cgroup_cs(cont);
-
-	/*
-	 * can_attach beforehand should guarantee that this doesn't fail.
-	 * TODO: have a better way to handle failure here
-	 */
-	err = set_cpus_allowed_ptr(tsk, cpus_attach);
-	WARN_ON_ONCE(err);
-
-	cpuset_change_task_nodemask(tsk, &cpuset_attach_nodemask_to);
-	cpuset_update_task_spread_flag(cs, tsk);
-}
-
 static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			  struct cgroup_taskset *tset)
 {
 	struct mm_struct *mm;
-	struct task_struct *tsk = cgroup_taskset_first(tset);
+	struct task_struct *task;
+	struct task_struct *leader = cgroup_taskset_first(tset);
 	struct cgroup *oldcgrp = cgroup_taskset_cur_cgroup(tset);
 	struct cpuset *cs = cgroup_cs(cgrp);
 	struct cpuset *oldcs = cgroup_cs(oldcgrp);
 
+	cgroup_taskset_for_each(task, cgrp, tset) {
+		/*
+		 * can_attach beforehand should guarantee that this doesn't
+		 * fail.  TODO: have a better way to handle failure here
+		 */
+		WARN_ON_ONCE(set_cpus_allowed_ptr(task, cpus_attach));
+
+		cpuset_change_task_nodemask(task, &cpuset_attach_nodemask_to);
+		cpuset_update_task_spread_flag(cs, task);
+	}
+
 	/*
 	 * Change mm, possibly for multiple threads in a threadgroup. This is
 	 * expensive and may sleep.
 	 */
 	cpuset_attach_nodemask_from = oldcs->mems_allowed;
 	cpuset_attach_nodemask_to = cs->mems_allowed;
-	mm = get_task_mm(tsk);
+	mm = get_task_mm(leader);
 	if (mm) {
 		mpol_rebind_mm(mm, &cpuset_attach_nodemask_to);
 		if (is_memory_migrate(cs))
@@ -1905,9 +1901,7 @@ struct cgroup_subsys cpuset_subsys = {
 	.create = cpuset_create,
 	.destroy = cpuset_destroy,
 	.can_attach = cpuset_can_attach,
-	.can_attach_task = cpuset_can_attach_task,
 	.pre_attach = cpuset_pre_attach,
-	.attach_task = cpuset_attach_task,
 	.attach = cpuset_attach,
 	.populate = cpuset_populate,
 	.post_clone = cpuset_post_clone,
diff --git a/kernel/events/core.c b/kernel/events/core.c
index d1a1bee..ed35211 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -7136,10 +7136,13 @@ static int __perf_cgroup_move(void *info)
 	return 0;
 }
 
-static void
-perf_cgroup_attach_task(struct cgroup *cgrp, struct task_struct *task)
+static void perf_cgroup_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			       struct cgroup_taskset *tset)
 {
-	task_function_call(task, __perf_cgroup_move, task);
+	struct task_struct *task;
+
+	cgroup_taskset_for_each(task, cgrp, tset)
+		task_function_call(task, __perf_cgroup_move, task);
 }
 
 static void perf_cgroup_exit(struct cgroup_subsys *ss, struct cgroup *cgrp,
@@ -7153,7 +7156,7 @@ static void perf_cgroup_exit(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	if (!(task->flags & PF_EXITING))
 		return;
 
-	perf_cgroup_attach_task(cgrp, task);
+	task_function_call(task, __perf_cgroup_move, task);
 }
 
 struct cgroup_subsys perf_subsys = {
@@ -7162,6 +7165,6 @@ struct cgroup_subsys perf_subsys = {
 	.create		= perf_cgroup_create,
 	.destroy	= perf_cgroup_destroy,
 	.exit		= perf_cgroup_exit,
-	.attach_task	= perf_cgroup_attach_task,
+	.attach		= perf_cgroup_attach,
 };
 #endif /* CONFIG_CGROUP_PERF */
diff --git a/kernel/sched.c b/kernel/sched.c
index d87c6e5..49e3605 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -9129,24 +9129,31 @@ cpu_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
 	sched_destroy_group(tg);
 }
 
-static int
-cpu_cgroup_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+static int cpu_cgroup_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+				 struct cgroup_taskset *tset)
 {
+	struct task_struct *task;
+
+	cgroup_taskset_for_each(task, cgrp, tset) {
 #ifdef CONFIG_RT_GROUP_SCHED
-	if (!sched_rt_can_attach(cgroup_tg(cgrp), tsk))
-		return -EINVAL;
+		if (!sched_rt_can_attach(cgroup_tg(cgrp), task))
+			return -EINVAL;
 #else
-	/* We don't support RT-tasks being in separate groups */
-	if (tsk->sched_class != &fair_sched_class)
-		return -EINVAL;
+		/* We don't support RT-tasks being in separate groups */
+		if (task->sched_class != &fair_sched_class)
+			return -EINVAL;
 #endif
+	}
 	return 0;
 }
 
-static void
-cpu_cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+static void cpu_cgroup_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			      struct cgroup_taskset *tset)
 {
-	sched_move_task(tsk);
+	struct task_struct *task;
+
+	cgroup_taskset_for_each(task, cgrp, tset)
+		sched_move_task(task);
 }
 
 static void
@@ -9482,8 +9489,8 @@ struct cgroup_subsys cpu_cgroup_subsys = {
 	.name		= "cpu",
 	.create		= cpu_cgroup_create,
 	.destroy	= cpu_cgroup_destroy,
-	.can_attach_task = cpu_cgroup_can_attach_task,
-	.attach_task	= cpu_cgroup_attach_task,
+	.can_attach	= cpu_cgroup_can_attach,
+	.attach		= cpu_cgroup_attach,
 	.exit		= cpu_cgroup_exit,
 	.populate	= cpu_cgroup_populate,
 	.subsys_id	= cpu_cgroup_subsys_id,
-- 
1.7.3.1
