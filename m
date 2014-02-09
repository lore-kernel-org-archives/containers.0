From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 12/16] cgroup: drop @skip_css from cgroup_taskset_for_each()
Date: Sun,  9 Feb 2014 08:52:40 -0500
Message-ID: <1391953964-22088-13-git-send-email-tj@kernel.org>
References: <1391953964-22088-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391953964-22088-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

If !NULL, @skip_css makes cgroup_taskset_for_each() skip the matching
css.  The intention of the interface is to make it easy to skip css's
(cgroup_subsys_states) which already match the migration target;
however, this is entirely unnecessary as migration taskset doesn't
include tasks which are already in the target cgroup.  Drop @skip_css
from cgroup_taskset_for_each().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
Cc: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c           | 2 +-
 include/linux/cgroup.h       | 8 ++------
 kernel/cgroup_freezer.c      | 2 +-
 kernel/cpuset.c              | 4 ++--
 kernel/events/core.c         | 2 +-
 kernel/sched/core.c          | 4 ++--
 net/core/netclassid_cgroup.c | 2 +-
 net/core/netprio_cgroup.c    | 2 +-
 8 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 1cef07c..4aefd46 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -894,7 +894,7 @@ static int blkcg_can_attach(struct cgroup_subsys_state *css,
 	int ret = 0;
 
 	/* task_lock() is needed to avoid races with exit_io_context() */
-	cgroup_taskset_for_each(task, css, tset) {
+	cgroup_taskset_for_each(task, tset) {
 		task_lock(task);
 		ioc = task->io_context;
 		if (ioc && atomic_read(&ioc->nr_tasks) > 1)
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index db5ccf4..3c67883 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -533,15 +533,11 @@ int cgroup_taskset_size(struct cgroup_taskset *tset);
 /**
  * cgroup_taskset_for_each - iterate cgroup_taskset
  * @task: the loop cursor
- * @skip_css: skip if task's css matches this, %NULL to iterate through all
  * @tset: taskset to iterate
  */
-#define cgroup_taskset_for_each(task, skip_css, tset)			\
+#define cgroup_taskset_for_each(task, tset)				\
 	for ((task) = cgroup_taskset_first((tset)); (task);		\
-	     (task) = cgroup_taskset_next((tset)))			\
-		if (!(skip_css) ||					\
-		    cgroup_taskset_cur_css((tset),			\
-			(skip_css)->ss->id) != (skip_css))
+	     (task) = cgroup_taskset_next((tset)))
 
 /*
  * Control Group subsystem type.
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 98ea26a9..7201a63 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -187,7 +187,7 @@ static void freezer_attach(struct cgroup_subsys_state *new_css,
 	 * current state before executing the following - !frozen tasks may
 	 * be visible in a FROZEN cgroup and frozen tasks in a THAWED one.
 	 */
-	cgroup_taskset_for_each(task, new_css, tset) {
+	cgroup_taskset_for_each(task, tset) {
 		if (!(freezer->state & CGROUP_FREEZING)) {
 			__thaw_task(task);
 		} else {
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 65ae0bd..bf20e4a 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1398,7 +1398,7 @@ static int cpuset_can_attach(struct cgroup_subsys_state *css,
 	    (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed)))
 		goto out_unlock;
 
-	cgroup_taskset_for_each(task, css, tset) {
+	cgroup_taskset_for_each(task, tset) {
 		/*
 		 * Kthreads which disallow setaffinity shouldn't be moved
 		 * to a new cpuset; we don't want to change their cpu
@@ -1467,7 +1467,7 @@ static void cpuset_attach(struct cgroup_subsys_state *css,
 
 	guarantee_online_mems(mems_cs, &cpuset_attach_nodemask_to);
 
-	cgroup_taskset_for_each(task, css, tset) {
+	cgroup_taskset_for_each(task, tset) {
 		/*
 		 * can_attach beforehand should guarantee that this doesn't
 		 * fail.  TODO: have a better way to handle failure here
diff --git a/kernel/events/core.c b/kernel/events/core.c
index a3c3ab5..6dd7149 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8021,7 +8021,7 @@ static void perf_cgroup_attach(struct cgroup_subsys_state *css,
 {
 	struct task_struct *task;
 
-	cgroup_taskset_for_each(task, css, tset)
+	cgroup_taskset_for_each(task, tset)
 		task_function_call(task, __perf_cgroup_move, task);
 }
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index d4cfc55..ba386a0 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7600,7 +7600,7 @@ static int cpu_cgroup_can_attach(struct cgroup_subsys_state *css,
 {
 	struct task_struct *task;
 
-	cgroup_taskset_for_each(task, css, tset) {
+	cgroup_taskset_for_each(task, tset) {
 #ifdef CONFIG_RT_GROUP_SCHED
 		if (!sched_rt_can_attach(css_tg(css), task))
 			return -EINVAL;
@@ -7618,7 +7618,7 @@ static void cpu_cgroup_attach(struct cgroup_subsys_state *css,
 {
 	struct task_struct *task;
 
-	cgroup_taskset_for_each(task, css, tset)
+	cgroup_taskset_for_each(task, tset)
 		sched_move_task(task);
 }
 
diff --git a/net/core/netclassid_cgroup.c b/net/core/netclassid_cgroup.c
index b865662..22931e1 100644
--- a/net/core/netclassid_cgroup.c
+++ b/net/core/netclassid_cgroup.c
@@ -73,7 +73,7 @@ static void cgrp_attach(struct cgroup_subsys_state *css,
 	void *v = (void *)(unsigned long)cs->classid;
 	struct task_struct *p;
 
-	cgroup_taskset_for_each(p, css, tset) {
+	cgroup_taskset_for_each(p, tset) {
 		task_lock(p);
 		iterate_fd(p->files, 0, update_classid, v);
 		task_unlock(p);
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index d7d23e2..f9f3a40 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -224,7 +224,7 @@ static void net_prio_attach(struct cgroup_subsys_state *css,
 	struct task_struct *p;
 	void *v = (void *)(unsigned long)css->cgroup->id;
 
-	cgroup_taskset_for_each(p, css, tset) {
+	cgroup_taskset_for_each(p, tset) {
 		task_lock(p);
 		iterate_fd(p->files, 0, update_netprio, v);
 		task_unlock(p);
-- 
1.8.5.3
