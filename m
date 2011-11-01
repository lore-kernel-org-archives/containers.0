From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 07/10] cgroup: introduce cgroup_taskset and use it in
	subsys->can_attach(), cancel_attach() and attach()
Date: Tue,  1 Nov 2011 16:46:30 -0700
Message-ID: <1320191193-8110-8-git-send-email-tj@kernel.org>
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
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, there's no way to pass multiple tasks to cgroup_subsys
methods necessitating the need for separate per-process and per-task
methods.  This patch introduces cgroup_taskset which can be used to
pass multiple tasks and their associated cgroups to cgroup_subsys
methods.

Three methods - can_attach(), cancel_attach() and attach() - are
converted to use cgroup_taskset.  This unifies passed parameters so
that all methods have access to all information.  Conversions in this
patchset are identical and don't introduce any behavior change.

-v2: documentation updated as per Paul Menage's suggestion.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |   31 ++++++++----
 include/linux/cgroup.h            |   28 +++++++++-
 kernel/cgroup.c                   |   99 +++++++++++++++++++++++++++++++++----
 kernel/cgroup_freezer.c           |    2 +-
 kernel/cpuset.c                   |   18 ++++---
 mm/memcontrol.c                   |   16 +++---
 security/device_cgroup.c          |    7 ++-
 7 files changed, 158 insertions(+), 43 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index cd67e90..bf5d6c9 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -594,15 +594,25 @@ rmdir() will fail with it. From this behavior, pre_destroy() can be
 called multiple times against a cgroup.
 
 int can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-	       struct task_struct *task)
+	       struct cgroup_taskset *tset)
 (cgroup_mutex held by caller)
 
-Called prior to moving a task into a cgroup; if the subsystem
-returns an error, this will abort the attach operation.  If a NULL
-task is passed, then a successful result indicates that *any*
-unspecified task can be moved into the cgroup. Note that this isn't
-called on a fork. If this method returns 0 (success) then this should
-remain valid while the caller holds cgroup_mutex and it is ensured that either
+Called prior to moving one or more tasks into a cgroup; if the
+subsystem returns an error, this will abort the attach operation.
+@tset contains the tasks to be attached and is guaranteed to have at
+least one task in it.
+
+If there are multiple tasks in the taskset, then:
+  - it's guaranteed that all are from the same thread group
+  - @tset contains all tasks from the thread group whether or not
+    they're switching cgroups
+  - the first task is the leader
+
+Each @tset entry also contains the task's old cgroup and tasks which
+aren't switching cgroup can be skipped easily using the
+cgroup_taskset_for_each() iterator. Note that this isn't called on a
+fork. If this method returns 0 (success) then this should remain valid
+while the caller holds cgroup_mutex and it is ensured that either
 attach() or cancel_attach() will be called in future.
 
 int can_attach_task(struct cgroup *cgrp, struct task_struct *tsk);
@@ -613,14 +623,14 @@ attached (possibly many when using cgroup_attach_proc). Called after
 can_attach.
 
 void cancel_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-	       struct task_struct *task, bool threadgroup)
+		   struct cgroup_taskset *tset)
 (cgroup_mutex held by caller)
 
 Called when a task attach operation has failed after can_attach() has succeeded.
 A subsystem whose can_attach() has some side-effects should provide this
 function, so that the subsystem can implement a rollback. If not, not necessary.
 This will be called only about subsystems whose can_attach() operation have
-succeeded.
+succeeded. The parameters are identical to can_attach().
 
 void pre_attach(struct cgroup *cgrp);
 (cgroup_mutex held by caller)
@@ -629,11 +639,12 @@ For any non-per-thread attachment work that needs to happen before
 attach_task. Needed by cpuset.
 
 void attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-	    struct cgroup *old_cgrp, struct task_struct *task)
+	    struct cgroup_taskset *tset)
 (cgroup_mutex held by caller)
 
 Called after the task has been attached to the cgroup, to allow any
 post-attachment activity that requires memory allocations or blocking.
+The parameters are identical to can_attach().
 
 void attach_task(struct cgroup *cgrp, struct task_struct *tsk);
 (cgroup_mutex held by caller)
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index da7e4bc..2470c8e 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -457,6 +457,28 @@ void cgroup_exclude_rmdir(struct cgroup_subsys_state *css);
 void cgroup_release_and_wakeup_rmdir(struct cgroup_subsys_state *css);
 
 /*
+ * Control Group taskset, used to pass around set of tasks to cgroup_subsys
+ * methods.
+ */
+struct cgroup_taskset;
+struct task_struct *cgroup_taskset_first(struct cgroup_taskset *tset);
+struct task_struct *cgroup_taskset_next(struct cgroup_taskset *tset);
+struct cgroup *cgroup_taskset_cur_cgroup(struct cgroup_taskset *tset);
+int cgroup_taskset_size(struct cgroup_taskset *tset);
+
+/**
+ * cgroup_taskset_for_each - iterate cgroup_taskset
+ * @task: the loop cursor
+ * @skip_cgrp: skip if task's cgroup matches this, %NULL to iterate through all
+ * @tset: taskset to iterate
+ */
+#define cgroup_taskset_for_each(task, skip_cgrp, tset)			\
+	for ((task) = cgroup_taskset_first((tset)); (task);		\
+	     (task) = cgroup_taskset_next((tset)))			\
+		if (!(skip_cgrp) ||					\
+		    cgroup_taskset_cur_cgroup((tset)) != (skip_cgrp))
+
+/*
  * Control Group subsystem type.
  * See Documentation/cgroups/cgroups.txt for details
  */
@@ -467,14 +489,14 @@ struct cgroup_subsys {
 	int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	int (*can_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
-			  struct task_struct *tsk);
+			  struct cgroup_taskset *tset);
 	int (*can_attach_task)(struct cgroup *cgrp, struct task_struct *tsk);
 	void (*cancel_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
-			      struct task_struct *tsk);
+			      struct cgroup_taskset *tset);
 	void (*pre_attach)(struct cgroup *cgrp);
 	void (*attach_task)(struct cgroup *cgrp, struct task_struct *tsk);
 	void (*attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
-		       struct cgroup *old_cgrp, struct task_struct *tsk);
+		       struct cgroup_taskset *tset);
 	void (*fork)(struct cgroup_subsys *ss, struct task_struct *task);
 	void (*exit)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			struct cgroup *old_cgrp, struct task_struct *task);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 19396d6..0bb7927 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1757,11 +1757,85 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 }
 EXPORT_SYMBOL_GPL(cgroup_path);
 
+/*
+ * Control Group taskset
+ */
 struct task_and_cgroup {
 	struct task_struct	*task;
 	struct cgroup		*cgrp;
 };
 
+struct cgroup_taskset {
+	struct task_and_cgroup	single;
+	struct flex_array	*tc_array;
+	int			tc_array_len;
+	int			idx;
+	struct cgroup		*cur_cgrp;
+};
+
+/**
+ * cgroup_taskset_first - reset taskset and return the first task
+ * @tset: taskset of interest
+ *
+ * @tset iteration is initialized and the first task is returned.
+ */
+struct task_struct *cgroup_taskset_first(struct cgroup_taskset *tset)
+{
+	if (tset->tc_array) {
+		tset->idx = 0;
+		return cgroup_taskset_next(tset);
+	} else {
+		tset->cur_cgrp = tset->single.cgrp;
+		return tset->single.task;
+	}
+}
+EXPORT_SYMBOL_GPL(cgroup_taskset_first);
+
+/**
+ * cgroup_taskset_next - iterate to the next task in taskset
+ * @tset: taskset of interest
+ *
+ * Return the next task in @tset.  Iteration must have been initialized
+ * with cgroup_taskset_first().
+ */
+struct task_struct *cgroup_taskset_next(struct cgroup_taskset *tset)
+{
+	struct task_and_cgroup *tc;
+
+	if (!tset->tc_array || tset->idx >= tset->tc_array_len)
+		return NULL;
+
+	tc = flex_array_get(tset->tc_array, tset->idx++);
+	tset->cur_cgrp = tc->cgrp;
+	return tc->task;
+}
+EXPORT_SYMBOL_GPL(cgroup_taskset_next);
+
+/**
+ * cgroup_taskset_cur_cgroup - return the matching cgroup for the current task
+ * @tset: taskset of interest
+ *
+ * Return the cgroup for the current (last returned) task of @tset.  This
+ * function must be preceded by either cgroup_taskset_first() or
+ * cgroup_taskset_next().
+ */
+struct cgroup *cgroup_taskset_cur_cgroup(struct cgroup_taskset *tset)
+{
+	return tset->cur_cgrp;
+}
+EXPORT_SYMBOL_GPL(cgroup_taskset_cur_cgroup);
+
+/**
+ * cgroup_taskset_size - return the number of tasks in taskset
+ * @tset: taskset of interest
+ */
+int cgroup_taskset_size(struct cgroup_taskset *tset)
+{
+	return tset->tc_array ? tset->tc_array_len : 1;
+}
+EXPORT_SYMBOL_GPL(cgroup_taskset_size);
+
+
 /*
  * cgroup_task_migrate - move a task from one cgroup to another.
  *
@@ -1842,6 +1916,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	struct cgroup_subsys *ss, *failed_ss = NULL;
 	struct cgroup *oldcgrp;
 	struct cgroupfs_root *root = cgrp->root;
+	struct cgroup_taskset tset = { };
 
 	/* @tsk either already exited or can't exit until the end */
 	if (tsk->flags & PF_EXITING)
@@ -1852,9 +1927,12 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	if (cgrp == oldcgrp)
 		return 0;
 
+	tset.single.task = tsk;
+	tset.single.cgrp = oldcgrp;
+
 	for_each_subsys(root, ss) {
 		if (ss->can_attach) {
-			retval = ss->can_attach(ss, cgrp, tsk);
+			retval = ss->can_attach(ss, cgrp, &tset);
 			if (retval) {
 				/*
 				 * Remember on which subsystem the can_attach()
@@ -1885,7 +1963,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 		if (ss->attach_task)
 			ss->attach_task(cgrp, tsk);
 		if (ss->attach)
-			ss->attach(ss, cgrp, oldcgrp, tsk);
+			ss->attach(ss, cgrp, &tset);
 	}
 
 	synchronize_rcu();
@@ -1907,7 +1985,7 @@ out:
 				 */
 				break;
 			if (ss->cancel_attach)
-				ss->cancel_attach(ss, cgrp, tsk);
+				ss->cancel_attach(ss, cgrp, &tset);
 		}
 	}
 	return retval;
@@ -2023,6 +2101,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	struct task_struct *tsk;
 	struct task_and_cgroup *tc;
 	struct flex_array *group;
+	struct cgroup_taskset tset = { };
 	/*
 	 * we need to make sure we have css_sets for all the tasks we're
 	 * going to move -before- we actually start moving them, so that in
@@ -2089,6 +2168,8 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	} while_each_thread(leader, tsk);
 	/* remember the number of threads in the array for later. */
 	group_size = i;
+	tset.tc_array = group;
+	tset.tc_array_len = group_size;
 	rcu_read_unlock();
 
 	/* methods shouldn't be called if no task is actually migrating */
@@ -2101,7 +2182,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 */
 	for_each_subsys(root, ss) {
 		if (ss->can_attach) {
-			retval = ss->can_attach(ss, cgrp, leader);
+			retval = ss->can_attach(ss, cgrp, &tset);
 			if (retval) {
 				failed_ss = ss;
 				goto out_cancel_attach;
@@ -2185,10 +2266,8 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 * being moved, this call will need to be reworked to communicate that.
 	 */
 	for_each_subsys(root, ss) {
-		if (ss->attach) {
-			tc = flex_array_get(group, 0);
-			ss->attach(ss, cgrp, tc->cgrp, tc->task);
-		}
+		if (ss->attach)
+			ss->attach(ss, cgrp, &tset);
 	}
 
 	/*
@@ -2210,11 +2289,11 @@ out_cancel_attach:
 		for_each_subsys(root, ss) {
 			if (ss == failed_ss) {
 				if (cancel_failed_ss && ss->cancel_attach)
-					ss->cancel_attach(ss, cgrp, leader);
+					ss->cancel_attach(ss, cgrp, &tset);
 				break;
 			}
 			if (ss->cancel_attach)
-				ss->cancel_attach(ss, cgrp, leader);
+				ss->cancel_attach(ss, cgrp, &tset);
 		}
 	}
 out_put_tasks:
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index e691818..a72d5fa 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -160,7 +160,7 @@ static void freezer_destroy(struct cgroup_subsys *ss,
  */
 static int freezer_can_attach(struct cgroup_subsys *ss,
 			      struct cgroup *new_cgroup,
-			      struct task_struct *task)
+			      struct cgroup_taskset *tset)
 {
 	struct freezer *freezer;
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 10131fd..2e5825b 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1368,10 +1368,10 @@ static int fmeter_getrate(struct fmeter *fmp)
 }
 
 /* Called by cgroups to determine if a cpuset is usable; cgroup_mutex held */
-static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cont,
-			     struct task_struct *tsk)
+static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			     struct cgroup_taskset *tset)
 {
-	struct cpuset *cs = cgroup_cs(cont);
+	struct cpuset *cs = cgroup_cs(cgrp);
 
 	if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
 		return -ENOSPC;
@@ -1384,7 +1384,7 @@ static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 	 * set_cpus_allowed_ptr() on all attached tasks before cpus_allowed may
 	 * be changed.
 	 */
-	if (tsk->flags & PF_THREAD_BOUND)
+	if (cgroup_taskset_first(tset)->flags & PF_THREAD_BOUND)
 		return -EINVAL;
 
 	return 0;
@@ -1434,12 +1434,14 @@ static void cpuset_attach_task(struct cgroup *cont, struct task_struct *tsk)
 	cpuset_update_task_spread_flag(cs, tsk);
 }
 
-static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
-			  struct cgroup *oldcont, struct task_struct *tsk)
+static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			  struct cgroup_taskset *tset)
 {
 	struct mm_struct *mm;
-	struct cpuset *cs = cgroup_cs(cont);
-	struct cpuset *oldcs = cgroup_cs(oldcont);
+	struct task_struct *tsk = cgroup_taskset_first(tset);
+	struct cgroup *oldcgrp = cgroup_taskset_cur_cgroup(tset);
+	struct cpuset *cs = cgroup_cs(cgrp);
+	struct cpuset *oldcs = cgroup_cs(oldcgrp);
 
 	/*
 	 * Change mm, possibly for multiple threads in a threadgroup. This is
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3508777..5019787 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5288,8 +5288,9 @@ static void mem_cgroup_clear_mc(void)
 
 static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 				struct cgroup *cgroup,
-				struct task_struct *p)
+				struct cgroup_taskset *tset)
 {
+	struct task_struct *p = cgroup_taskset_first(tset);
 	int ret = 0;
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cgroup);
 
@@ -5327,7 +5328,7 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 
 static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
 				struct cgroup *cgroup,
-				struct task_struct *p)
+				struct cgroup_taskset *tset)
 {
 	mem_cgroup_clear_mc();
 }
@@ -5444,9 +5445,9 @@ retry:
 
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct cgroup *cont,
-				struct cgroup *old_cont,
-				struct task_struct *p)
+				struct cgroup_taskset *tset)
 {
+	struct task_struct *p = cgroup_taskset_first(tset);
 	struct mm_struct *mm = get_task_mm(p);
 
 	if (mm) {
@@ -5461,19 +5462,18 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 #else	/* !CONFIG_MMU */
 static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 				struct cgroup *cgroup,
-				struct task_struct *p)
+				struct cgroup_taskset *tset)
 {
 	return 0;
 }
 static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
 				struct cgroup *cgroup,
-				struct task_struct *p)
+				struct cgroup_taskset *tset)
 {
 }
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct cgroup *cont,
-				struct cgroup *old_cont,
-				struct task_struct *p)
+				struct cgroup_taskset *tset)
 {
 }
 #endif
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 4450fbe..8b5b5d8 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -62,11 +62,12 @@ static inline struct dev_cgroup *task_devcgroup(struct task_struct *task)
 struct cgroup_subsys devices_subsys;
 
 static int devcgroup_can_attach(struct cgroup_subsys *ss,
-		struct cgroup *new_cgroup, struct task_struct *task)
+			struct cgroup *new_cgrp, struct cgroup_taskset *set)
 {
-	if (current != task && !capable(CAP_SYS_ADMIN))
-			return -EPERM;
+	struct task_struct *task = cgroup_taskset_first(set);
 
+	if (current != task && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
 	return 0;
 }
 
-- 
1.7.3.1
