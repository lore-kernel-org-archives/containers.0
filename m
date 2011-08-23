From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/6] cgroup: don't use subsys->can_attach_task() or
	->attach_task()
Date: Wed, 24 Aug 2011 00:19:58 +0200
Message-ID: <1314138000-2049-5-git-send-email-tj__1361.79062906212$1314138154$gmane$org@kernel.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
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
 kernel/cgroup_freezer.c |   14 +++-------
 kernel/cpuset.c         |   70 +++++++++++++++++++++-------------------------
 kernel/events/core.c    |   13 +++++---
 kernel/sched.c          |   31 +++++++++++++--------
 5 files changed, 91 insertions(+), 82 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index bcaf16e..99e0bd4 100644
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
@@ -1614,30 +1616,39 @@ done:
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
index a2b0082..2cb5e72 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -162,10 +162,14 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 			      struct cgroup_taskset *tset)
 {
 	struct freezer *freezer;
+	struct task_struct *task;
 
 	/*
 	 * Anything frozen can't move or be moved to/from.
 	 */
+	cgroup_taskset_for_each(task, new_cgroup, tset)
+		if (cgroup_freezing(task))
+			return -EBUSY;
 
 	freezer = cgroup_freezer(new_cgroup);
 	if (freezer->state != CGROUP_THAWED)
@@ -174,11 +178,6 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 	return 0;
 }
 
-static int freezer_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
-{
-	return cgroup_freezing(tsk) ? -EBUSY : 0;
-}
-
 static void freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
 {
 	struct freezer *freezer;
@@ -374,10 +373,5 @@ struct cgroup_subsys freezer_subsys = {
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
index b8785e2..95e189d 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -7000,10 +7000,13 @@ static int __perf_cgroup_move(void *info)
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
@@ -7017,7 +7020,7 @@ static void perf_cgroup_exit(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	if (!(task->flags & PF_EXITING))
 		return;
 
-	perf_cgroup_attach_task(cgrp, task);
+	task_function_call(task, __perf_cgroup_move, task);
 }
 
 struct cgroup_subsys perf_subsys = {
@@ -7026,6 +7029,6 @@ struct cgroup_subsys perf_subsys = {
 	.create		= perf_cgroup_create,
 	.destroy	= perf_cgroup_destroy,
 	.exit		= perf_cgroup_exit,
-	.attach_task	= perf_cgroup_attach_task,
+	.attach		= perf_cgroup_attach,
 };
 #endif /* CONFIG_CGROUP_PERF */
diff --git a/kernel/sched.c b/kernel/sched.c
index ccacdbd..dd7e460 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -8966,24 +8966,31 @@ cpu_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
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
@@ -9071,8 +9078,8 @@ struct cgroup_subsys cpu_cgroup_subsys = {
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
1.7.6
