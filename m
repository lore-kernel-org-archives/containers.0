From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 22/23] cgroup: make cgroup_taskset deal with
	cgroup_subsys_state instead of cgroup
Date: Thu,  1 Aug 2013 17:50:00 -0400
Message-ID: <1375393801-4817-23-git-send-email-tj__44499.5535807267$1375393988$gmane$org@kernel.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup is in the process of converting to css (cgroup_subsys_state)
from cgroup as the principal subsystem interface handle.  This is
mostly to prepare for the unified hierarchy support where css's will
be created and destroyed dynamically but also helps cleaning up
subsystem implementations as css is usually what they are interested
in anyway.

cgroup_taskset which is used by the subsystem attach methods is the
last cgroup subsystem API which isn't using css as the handle.  Update
cgroup_taskset_cur_cgroup() to cgroup_taskset_cur_css() and
cgroup_taskset_for_each() to take @skip_css instead of @skip_cgrp.

The conversions are pretty mechanical.  One exception is
cpuset::cgroup_cs(), which lost its last user and got removed.

This patch shouldn't introduce any functional changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
---
 block/blk-cgroup.c        |  2 +-
 include/linux/cgroup.h    | 12 +++++++-----
 kernel/cgroup.c           | 16 +++++++++-------
 kernel/cgroup_freezer.c   |  2 +-
 kernel/cpuset.c           | 15 +++++----------
 kernel/events/core.c      |  2 +-
 kernel/sched/core.c       |  4 ++--
 net/core/netprio_cgroup.c |  2 +-
 net/sched/cls_cgroup.c    |  2 +-
 9 files changed, 28 insertions(+), 29 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 4b40640..54ad002 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -891,7 +891,7 @@ static int blkcg_can_attach(struct cgroup_subsys_state *css,
 	int ret = 0;
 
 	/* task_lock() is needed to avoid races with exit_io_context() */
-	cgroup_taskset_for_each(task, css->cgroup, tset) {
+	cgroup_taskset_for_each(task, css, tset) {
 		task_lock(task);
 		ioc = task->io_context;
 		if (ioc && atomic_read(&ioc->nr_tasks) > 1)
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8f44411..28e21f9 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -563,20 +563,22 @@ int cgroup_task_count(const struct cgroup *cgrp);
 struct cgroup_taskset;
 struct task_struct *cgroup_taskset_first(struct cgroup_taskset *tset);
 struct task_struct *cgroup_taskset_next(struct cgroup_taskset *tset);
-struct cgroup *cgroup_taskset_cur_cgroup(struct cgroup_taskset *tset);
+struct cgroup_subsys_state *cgroup_taskset_cur_css(struct cgroup_taskset *tset,
+						   int subsys_id);
 int cgroup_taskset_size(struct cgroup_taskset *tset);
 
 /**
  * cgroup_taskset_for_each - iterate cgroup_taskset
  * @task: the loop cursor
- * @skip_cgrp: skip if task's cgroup matches this, %NULL to iterate through all
+ * @skip_css: skip if task's css matches this, %NULL to iterate through all
  * @tset: taskset to iterate
  */
-#define cgroup_taskset_for_each(task, skip_cgrp, tset)			\
+#define cgroup_taskset_for_each(task, skip_css, tset)			\
 	for ((task) = cgroup_taskset_first((tset)); (task);		\
 	     (task) = cgroup_taskset_next((tset)))			\
-		if (!(skip_cgrp) ||					\
-		    cgroup_taskset_cur_cgroup((tset)) != (skip_cgrp))
+		if (!(skip_css) ||					\
+		    cgroup_taskset_cur_css((tset),			\
+			(skip_css)->ss->subsys_id) != (skip_css))
 
 /*
  * Control Group subsystem type.
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e0ef58e..ead0088 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1900,18 +1900,20 @@ struct task_struct *cgroup_taskset_next(struct cgroup_taskset *tset)
 EXPORT_SYMBOL_GPL(cgroup_taskset_next);
 
 /**
- * cgroup_taskset_cur_cgroup - return the matching cgroup for the current task
+ * cgroup_taskset_cur_css - return the matching css for the current task
  * @tset: taskset of interest
+ * @subsys_id: the ID of the target subsystem
  *
- * Return the cgroup for the current (last returned) task of @tset.  This
- * function must be preceded by either cgroup_taskset_first() or
- * cgroup_taskset_next().
+ * Return the css for the current (last returned) task of @tset for
+ * subsystem specified by @subsys_id.  This function must be preceded by
+ * either cgroup_taskset_first() or cgroup_taskset_next().
  */
-struct cgroup *cgroup_taskset_cur_cgroup(struct cgroup_taskset *tset)
+struct cgroup_subsys_state *cgroup_taskset_cur_css(struct cgroup_taskset *tset,
+						   int subsys_id)
 {
-	return tset->cur_cgrp;
+	return cgroup_css(tset->cur_cgrp, subsys_id);
 }
-EXPORT_SYMBOL_GPL(cgroup_taskset_cur_cgroup);
+EXPORT_SYMBOL_GPL(cgroup_taskset_cur_css);
 
 /**
  * cgroup_taskset_size - return the number of tasks in taskset
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 5cd2b6d..224da9a 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -189,7 +189,7 @@ static void freezer_attach(struct cgroup_subsys_state *new_css,
 	 * current state before executing the following - !frozen tasks may
 	 * be visible in a FROZEN cgroup and frozen tasks in a THAWED one.
 	 */
-	cgroup_taskset_for_each(task, new_css->cgroup, tset) {
+	cgroup_taskset_for_each(task, new_css, tset) {
 		if (!(freezer->state & CGROUP_FREEZING)) {
 			__thaw_task(task);
 		} else {
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 39e5217..bf69717 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -119,12 +119,6 @@ static inline struct cpuset *css_cs(struct cgroup_subsys_state *css)
 	return css ? container_of(css, struct cpuset, css) : NULL;
 }
 
-/* Retrieve the cpuset for a cgroup */
-static inline struct cpuset *cgroup_cs(struct cgroup *cgrp)
-{
-	return css_cs(cgroup_css(cgrp, cpuset_subsys_id));
-}
-
 /* Retrieve the cpuset for a task */
 static inline struct cpuset *task_cs(struct task_struct *task)
 {
@@ -1459,7 +1453,7 @@ static int cpuset_can_attach(struct cgroup_subsys_state *css,
 	    (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed)))
 		goto out_unlock;
 
-	cgroup_taskset_for_each(task, css->cgroup, tset) {
+	cgroup_taskset_for_each(task, css, tset) {
 		/*
 		 * Kthreads which disallow setaffinity shouldn't be moved
 		 * to a new cpuset; we don't want to change their cpu
@@ -1511,9 +1505,10 @@ static void cpuset_attach(struct cgroup_subsys_state *css,
 	struct mm_struct *mm;
 	struct task_struct *task;
 	struct task_struct *leader = cgroup_taskset_first(tset);
-	struct cgroup *oldcgrp = cgroup_taskset_cur_cgroup(tset);
+	struct cgroup_subsys_state *oldcss = cgroup_taskset_cur_css(tset,
+							cpuset_subsys_id);
 	struct cpuset *cs = css_cs(css);
-	struct cpuset *oldcs = cgroup_cs(oldcgrp);
+	struct cpuset *oldcs = css_cs(oldcss);
 	struct cpuset *cpus_cs = effective_cpumask_cpuset(cs);
 	struct cpuset *mems_cs = effective_nodemask_cpuset(cs);
 
@@ -1527,7 +1522,7 @@ static void cpuset_attach(struct cgroup_subsys_state *css,
 
 	guarantee_online_mems(mems_cs, &cpuset_attach_nodemask_to);
 
-	cgroup_taskset_for_each(task, css->cgroup, tset) {
+	cgroup_taskset_for_each(task, css, tset) {
 		/*
 		 * can_attach beforehand should guarantee that this doesn't
 		 * fail.  TODO: have a better way to handle failure here
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 9705a0e..c199c4f 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -7816,7 +7816,7 @@ static void perf_cgroup_attach(struct cgroup_subsys_state *css,
 {
 	struct task_struct *task;
 
-	cgroup_taskset_for_each(task, css->cgroup, tset)
+	cgroup_taskset_for_each(task, css, tset)
 		task_function_call(task, __perf_cgroup_move, task);
 }
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index cc9a492..a7122d5 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7135,7 +7135,7 @@ static int cpu_cgroup_can_attach(struct cgroup_subsys_state *css,
 {
 	struct task_struct *task;
 
-	cgroup_taskset_for_each(task, css->cgroup, tset) {
+	cgroup_taskset_for_each(task, css, tset) {
 #ifdef CONFIG_RT_GROUP_SCHED
 		if (!sched_rt_can_attach(css_tg(css), task))
 			return -EINVAL;
@@ -7153,7 +7153,7 @@ static void cpu_cgroup_attach(struct cgroup_subsys_state *css,
 {
 	struct task_struct *task;
 
-	cgroup_taskset_for_each(task, css->cgroup, tset)
+	cgroup_taskset_for_each(task, css, tset)
 		sched_move_task(task);
 }
 
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index e00f60e..d9cd627 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -224,7 +224,7 @@ static void net_prio_attach(struct cgroup_subsys_state *css,
 	struct task_struct *p;
 	void *v;
 
-	cgroup_taskset_for_each(p, css->cgroup, tset) {
+	cgroup_taskset_for_each(p, css, tset) {
 		task_lock(p);
 		v = (void *)(unsigned long)task_netprioidx(p);
 		iterate_fd(p->files, 0, update_netprio, v);
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 8ea1184..867b4a3 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -74,7 +74,7 @@ static void cgrp_attach(struct cgroup_subsys_state *css,
 	struct task_struct *p;
 	void *v;
 
-	cgroup_taskset_for_each(p, css->cgroup, tset) {
+	cgroup_taskset_for_each(p, css, tset) {
 		task_lock(p);
 		v = (void *)(unsigned long)task_cls_classid(p);
 		iterate_fd(p->files, 0, update_classid, v);
-- 
1.8.3.1
