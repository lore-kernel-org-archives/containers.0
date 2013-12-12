From: Dwight Engen <dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 8/9] cgroups: Add task and fork limits to cpuacct subsystem
Date: Thu, 12 Dec 2013 16:35:17 -0500
Message-ID: <1386884118-14972-9-git-send-email-dwight.engen@oracle.com>
References: <1386884118-14972-1-git-send-email-dwight.engen@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1386884118-14972-1-git-send-email-dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

A task limit can be set that is checked every time a task forks or
is moved into the cgroup. For performance reasons the accounting is
not performed unless a limit is set.

The primary goal is to protect against forkbombs that explode
inside a container. The traditional NR_PROC rlimit is not
efficient in that case because if we run containers in parallel
under the same user, one of these could starve all the others
by spawning a high number of tasks close to the user wide limit.

A secondary goal is to limit the total number of forks a container
can do, for example for use in a temporary cgroup created to
process a CGI request. This is implemented with a separate fork
count limit.

Original Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Dwight Engen <dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 Documentation/cgroups/cpuacct.txt |  35 ++++-
 include/linux/cgroup.h            |   8 +-
 kernel/cgroup.c                   |  37 ++++-
 kernel/exit.c                     |   2 +-
 kernel/fork.c                     |   7 +-
 kernel/sched/cpuacct.c            | 279 +++++++++++++++++++++++++++++++++++++-
 6 files changed, 347 insertions(+), 21 deletions(-)

diff --git a/Documentation/cgroups/cpuacct.txt b/Documentation/cgroups/cpuacct.txt
index 9d73cc0..4d5a568 100644
--- a/Documentation/cgroups/cpuacct.txt
+++ b/Documentation/cgroups/cpuacct.txt
@@ -2,11 +2,13 @@ CPU Accounting Controller
 -------------------------
 
 The CPU accounting controller is used to group tasks using cgroups and
-account the CPU usage of these groups of tasks.
+account the CPU usage of these groups of tasks. It can also limit the
+number of tasks running inside the cgroup, and limit the total number of
+forks done by processes in the cgroup.
 
 The CPU accounting controller supports multi-hierarchy groups. An accounting
-group accumulates the CPU usage of all of its child groups and the tasks
-directly present in its group.
+group accumulates the CPU and task usage of all of its child groups and the
+tasks directly present in its group.
 
 Accounting groups can be created by first mounting the cgroup filesystem.
 
@@ -47,3 +49,30 @@ system times. This has two side effects:
   against concurrent writes.
 - It is possible to see slightly outdated values for user and system times
   due to the batch processing nature of percpu_counter.
+
+cpuacct.fork_usage maintains a counter which is incremented each time a new
+process/thread is created. For performance reasons, this accounting is not
+done unless cpuacct.fork_limit is set.
+
+cpuacct.fork_limit limits the number of times a new child process or thread
+can be created. If cpuacct.fork_limit is set, when cpuacct.fork_usage
+reaches the limit, no process in the cgroup is allowed to create new child
+processes/threads, even if existing ones quit. A limit other than 0 cannot
+be set if the cgroup has children or tasks already assigned. Setting the
+limit to 0 is useful for stopping an in progress fork bomb. The limit in the
+root of the cgroup heirarchy cannot be set.
+
+This has been proven useful in a shared hosting environment.  A new
+temporary cgroup is created for each CGI process, and the maximum fork
+count is configured to a sensible value.  Since CGIs are expected to
+run for only a short time with predictable resource usage, this may be
+an appropriate tool to limit the damage that a freaked CGI can do.
+
+cpuacct.task_usage maintains a counter of the number of tasks in the cgroup.
+For performance reasons, this accounting is not done unless
+cpuacct.task_limit is set.
+
+cpuacct.task_limit limits the number of tasks running inside a given cgroup.
+It behaves like the NR_PROC rlimit but in the scope of a cgroup instead of a
+user. This limit is checked when a task forks or when it is migrated to the
+cgroup. The limit in the root of the cgroup heirarchy cannot be set.
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 9b20ba9..519c80e 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -33,9 +33,9 @@ struct eventfd_ctx;
 
 extern int cgroup_init_early(void);
 extern int cgroup_init(void);
-extern void cgroup_fork(struct task_struct *p);
+extern int cgroup_fork(struct task_struct *p);
 extern void cgroup_post_fork(struct task_struct *p);
-extern void cgroup_exit(struct task_struct *p, int run_callbacks);
+extern void cgroup_exit(struct task_struct *p);
 extern int cgroupstats_build(struct cgroupstats *stats,
 				struct dentry *dentry);
 extern int cgroup_load_subsys(struct cgroup_subsys *ss);
@@ -603,6 +603,8 @@ struct cgroup_subsys {
 			      struct cgroup_taskset *tset);
 	void (*attach)(struct cgroup_subsys_state *css,
 		       struct cgroup_taskset *tset);
+	int (*can_fork)(void);
+	void (*cancel_can_fork)(void);
 	void (*fork)(struct task_struct *task);
 	void (*exit)(struct cgroup_subsys_state *css,
 		     struct cgroup_subsys_state *old_css,
@@ -913,7 +915,7 @@ static inline int cgroup_init_early(void) { return 0; }
 static inline int cgroup_init(void) { return 0; }
 static inline void cgroup_fork(struct task_struct *p) {}
 static inline void cgroup_post_fork(struct task_struct *p) {}
-static inline void cgroup_exit(struct task_struct *p, int callbacks) {}
+static inline void cgroup_exit(struct task_struct *p) {}
 
 static inline int cgroupstats_build(struct cgroupstats *stats,
 					struct dentry *dentry)
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5c9127d..8abacad 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4855,7 +4855,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	 * init_css_set is in the subsystem's top cgroup. */
 	init_css_set.subsys[ss->subsys_id] = css;
 
-	need_forkexit_callback |= ss->fork || ss->exit;
+	need_forkexit_callback |= ss->fork || ss->can_fork || ss->exit;
 
 	/* At system boot, before all subsystems have been
 	 * registered, no tasks have been forked, so we don't
@@ -5282,13 +5282,40 @@ static const struct file_operations proc_cgroupstats_operations = {
  * At the point that cgroup_fork() is called, 'current' is the parent
  * task, and the passed argument 'child' points to the child task.
  */
-void cgroup_fork(struct task_struct *child)
+int cgroup_fork(struct task_struct *child)
 {
+	struct cgroup_subsys *ss;
+	struct cgroup_subsys *failed_ss;
+	int i;
+	int err = 0;
+
 	task_lock(current);
+	if (need_forkexit_callback) {
+		for_each_builtin_subsys(ss, i) {
+			if (ss->can_fork) {
+				err = ss->can_fork();
+				if (err) {
+					failed_ss = ss;
+					goto out_cancel_fork;
+				}
+			}
+		}
+	}
 	get_css_set(task_css_set(current));
 	child->cgroups = current->cgroups;
-	task_unlock(current);
 	INIT_LIST_HEAD(&child->cg_list);
+
+out_cancel_fork:
+	if (err) {
+		for_each_builtin_subsys(ss, i) {
+			if (ss == failed_ss)
+				break;
+			if (ss->cancel_can_fork)
+				ss->cancel_can_fork();
+		}
+	}
+	task_unlock(current);
+	return err;
 }
 
 /**
@@ -5381,7 +5408,7 @@ void cgroup_post_fork(struct task_struct *child)
  *    which wards off any cgroup_attach_task() attempts, or task is a failed
  *    fork, never visible to cgroup_attach_task.
  */
-void cgroup_exit(struct task_struct *tsk, int run_callbacks)
+void cgroup_exit(struct task_struct *tsk)
 {
 	struct cgroup_subsys *ss;
 	struct css_set *cset;
@@ -5404,7 +5431,7 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 	cset = task_css_set(tsk);
 	RCU_INIT_POINTER(tsk->cgroups, &init_css_set);
 
-	if (run_callbacks && need_forkexit_callback) {
+	if (need_forkexit_callback) {
 		/*
 		 * fork/exit callbacks are supported only for builtin
 		 * subsystems, see cgroup_post_fork() for details.
diff --git a/kernel/exit.c b/kernel/exit.c
index a949819..74c4964 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -796,7 +796,7 @@ void do_exit(long code)
 	 */
 	perf_event_exit_task(tsk);
 
-	cgroup_exit(tsk, 1);
+	cgroup_exit(tsk);
 
 	if (group_dead)
 		disassociate_ctty(1);
diff --git a/kernel/fork.c b/kernel/fork.c
index 086fe73..cff2f73 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1264,7 +1264,9 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->audit_context = NULL;
 	if (clone_flags & CLONE_THREAD)
 		threadgroup_change_begin(current);
-	cgroup_fork(p);
+	retval = cgroup_fork(p);
+	if (retval)
+		goto bad_fork_cleanup_threadgroup;
 #ifdef CONFIG_NUMA
 	p->mempolicy = mpol_dup(p->mempolicy);
 	if (IS_ERR(p->mempolicy)) {
@@ -1523,9 +1525,10 @@ bad_fork_cleanup_policy:
 	mpol_put(p->mempolicy);
 bad_fork_cleanup_cgroup:
 #endif
+	cgroup_exit(p);
+bad_fork_cleanup_threadgroup:
 	if (clone_flags & CLONE_THREAD)
 		threadgroup_change_end(current);
-	cgroup_exit(p, 0);
 	delayacct_tsk_free(p);
 	module_put(task_thread_info(p)->exec_domain->module);
 bad_fork_cleanup_count:
diff --git a/kernel/sched/cpuacct.c b/kernel/sched/cpuacct.c
index f64722f..e23e543 100644
--- a/kernel/sched/cpuacct.c
+++ b/kernel/sched/cpuacct.c
@@ -5,6 +5,7 @@
 #include <linux/cpumask.h>
 #include <linux/seq_file.h>
 #include <linux/rcupdate.h>
+#include <linux/res_counter.h>
 #include <linux/kernel_stat.h>
 #include <linux/err.h>
 
@@ -31,6 +32,11 @@ struct cpuacct {
 	/* cpuusage holds pointer to a u64-type object on every cpu */
 	u64 __percpu *cpuusage;
 	struct kernel_cpustat __percpu *cpustat;
+
+	/* counter for allowed tasks */
+	struct res_counter task_limit;
+	/* counter for allowed forks */
+	struct res_counter fork_limit;
 };
 
 static inline struct cpuacct *css_ca(struct cgroup_subsys_state *css)
@@ -49,6 +55,11 @@ static inline struct cpuacct *parent_ca(struct cpuacct *ca)
 	return css_ca(css_parent(&ca->css));
 }
 
+static inline bool res_limit_enabled(struct res_counter *res)
+{
+	return res_counter_read_u64(res, RES_LIMIT) != RES_COUNTER_MAX;
+}
+
 static DEFINE_PER_CPU(u64, root_cpuacct_cpuusage);
 static struct cpuacct root_cpuacct = {
 	.cpustat	= &kernel_cpustat,
@@ -61,8 +72,11 @@ cpuacct_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct cpuacct *ca;
 
-	if (!parent_css)
+	if (!parent_css) {
+		res_counter_init(&root_cpuacct.task_limit, NULL);
+		res_counter_init(&root_cpuacct.fork_limit, NULL);
 		return &root_cpuacct.css;
+	}
 
 	ca = kzalloc(sizeof(*ca), GFP_KERNEL);
 	if (!ca)
@@ -76,6 +90,12 @@ cpuacct_css_alloc(struct cgroup_subsys_state *parent_css)
 	if (!ca->cpustat)
 		goto out_free_cpuusage;
 
+	res_counter_init(&ca->task_limit, &css_ca(parent_css)->task_limit);
+	res_counter_inherit(&ca->task_limit, RES_LIMIT);
+
+	res_counter_init(&ca->fork_limit, &css_ca(parent_css)->fork_limit);
+	res_counter_inherit(&ca->fork_limit, RES_LIMIT);
+
 	return &ca->css;
 
 out_free_cpuusage:
@@ -212,6 +232,223 @@ static int cpuacct_stats_show(struct cgroup_subsys_state *css,
 	return 0;
 }
 
+static u64 cpuacct_task_limit_read_u64(struct cgroup_subsys_state *css,
+				       struct cftype *cft)
+{
+	struct cpuacct *ca = css_ca(css);
+	int type = cft->private;
+
+	return res_counter_read_u64(&ca->task_limit, type);
+}
+
+static int cpuacct_task_limit_write_u64(struct cgroup_subsys_state *css,
+					struct cftype *cft, u64 val)
+{
+	struct cpuacct *ca = css_ca(css);
+	struct cgroup *cgrp = ca->css.cgroup;
+	int type = cft->private;
+
+	if (ca == &root_cpuacct)
+		return -EINVAL;
+
+	if (val != RES_COUNTER_MAX) {
+		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
+			return -EBUSY;
+		res_counter_write_u64(&ca->task_limit, type, val);
+	}
+
+	return 0;
+}
+
+static u64 cpuacct_fork_limit_read_u64(struct cgroup_subsys_state *css,
+				       struct cftype *cft)
+{
+	struct cpuacct *ca = css_ca(css);
+	int type = cft->private;
+
+	return res_counter_read_u64(&ca->fork_limit, type);
+}
+
+static int cpuacct_fork_limit_write_u64(struct cgroup_subsys_state *css,
+					struct cftype *cft, u64 val)
+{
+	struct cpuacct *ca = css_ca(css);
+	struct cgroup *cgrp = ca->css.cgroup;
+	int type = cft->private;
+
+	if (ca == &root_cpuacct)
+		return -EINVAL;
+
+	if (val != RES_COUNTER_MAX) {
+		/* always allow 0 to stop an ongoing fork bomb */
+		if (val != 0 &&
+		    (cgroup_task_count(cgrp) || !list_empty(&cgrp->children)))
+			return -EBUSY;
+		res_counter_write_u64(&ca->fork_limit, type, val);
+	}
+
+	return 0;
+}
+
+static int cpuacct_can_fork(void)
+{
+	int err = 0;
+	bool fork_charged = 0;
+	struct cpuacct *ca = task_ca(current);
+
+	if (ca == &root_cpuacct)
+		return 0;
+
+	if (res_limit_enabled(&ca->fork_limit)) {
+		if (res_counter_charge(&ca->fork_limit, 1, NULL))
+			return -EPERM;
+		fork_charged = 1;
+	}
+
+	if (res_limit_enabled(&ca->task_limit)) {
+		if (res_counter_charge(&ca->task_limit, 1, NULL)) {
+			err = -EAGAIN;
+			goto err_task_limit;
+		}
+	}
+
+	return 0;
+
+err_task_limit:
+	if (fork_charged)
+		res_counter_uncharge(&ca->fork_limit, 1);
+	return err;
+}
+
+static void cpuacct_cancel_can_fork(void)
+{
+	struct cpuacct *ca = task_ca(current);
+
+	if (ca == &root_cpuacct)
+		return;
+
+	if (res_limit_enabled(&ca->fork_limit))
+		res_counter_uncharge(&ca->fork_limit, 1);
+
+	if (res_limit_enabled(&ca->task_limit))
+		res_counter_uncharge(&ca->task_limit, 1);
+}
+
+
+static void cpuacct_exit(struct cgroup_subsys_state *css,
+			 struct cgroup_subsys_state *old_css,
+			 struct task_struct *task)
+{
+	struct cpuacct *ca = css_ca(old_css);
+
+	if (ca == &root_cpuacct)
+		return;
+
+	if (res_limit_enabled(&ca->task_limit))
+		res_counter_uncharge(&ca->task_limit, 1);
+}
+
+/*
+ * Complete the attach by uncharging the old cgroups. We can do that now that
+ * we are sure the attachment can't be cancelled anymore, because this uncharge
+ * operation couldn't be reverted later: a task in the old cgroup could fork
+ * after we uncharge and reach the task counter limit, making our return there
+ * not possible.
+ */
+static void cpuacct_attach(struct cgroup_subsys_state *css,
+			   struct cgroup_taskset *tset)
+{
+	struct task_struct *task;
+	struct cpuacct *new = css_ca(css);
+	struct cpuacct *old;
+	struct res_counter *until;
+
+	cgroup_taskset_for_each(task, NULL, tset) {
+		old = css_ca(cgroup_taskset_cur_css(tset, cpuacct_subsys_id));
+		until = res_counter_common_ancestor(&new->task_limit,
+						    &old->task_limit);
+		if (until == &root_cpuacct.task_limit)
+			until = NULL;
+		if (res_limit_enabled(&old->task_limit))
+			res_counter_uncharge_until(&old->task_limit, until, 1);
+	}
+}
+
+static void cpuacct_cancel_attach_until(struct cgroup_subsys_state *css,
+					struct cgroup_taskset *tset,
+					struct task_struct *until_task)
+{
+	struct task_struct *task;
+	struct cpuacct *new = css_ca(css);
+	struct cpuacct *old;
+	struct res_counter *until;
+
+	cgroup_taskset_for_each(task, NULL, tset) {
+		if (task == until_task)
+			break;
+		old = css_ca(cgroup_taskset_cur_css(tset, cpuacct_subsys_id));
+		until = res_counter_common_ancestor(&new->task_limit,
+						    &old->task_limit);
+		if (until == &root_cpuacct.task_limit)
+			until = NULL;
+		if (res_limit_enabled(&new->task_limit))
+			res_counter_uncharge_until(&new->task_limit, until, 1);
+	}
+}
+
+/*
+ * This does more than just probing the ability to attach to the dest cgroup.
+ * We can not just _check_ if we can attach to the destination and do the real
+ * attachment later in cpuacct_attach() because a task in the dest cgroup can
+ * fork before we get there and steal the last remaining count, thus we must
+ * charge the dest cgroup right now.
+ */
+static int cpuacct_can_attach(struct cgroup_subsys_state *css,
+			      struct cgroup_taskset *tset)
+{
+	struct task_struct *task;
+	struct cpuacct *new = css_ca(css);
+	struct cpuacct *old;
+	struct res_counter *until;
+	int err;
+
+	cgroup_taskset_for_each(task, NULL, tset) {
+		old = css_ca(cgroup_taskset_cur_css(tset, cpuacct_subsys_id));
+
+		/*
+		 * When moving a task from a cgroup to another, we don't want
+		 * to charge the common ancestors, even though they would be
+		 * uncharged later in cpuacct_attach(), because during that
+		 * short window between charge and uncharge, a task could fork
+		 * in the ancestor and spuriously fail due to the temporary
+		 * charge. The exception is root_cpuacct since it is unlimited.
+		 */
+		until = res_counter_common_ancestor(&new->task_limit,
+						    &old->task_limit);
+		if (until == &root_cpuacct.task_limit)
+			until = NULL;
+
+		if (!res_limit_enabled(&new->task_limit))
+			continue;
+
+		err = res_counter_charge_until(&new->task_limit, until, 1, NULL);
+		if (err) {
+			cpuacct_cancel_attach_until(css, tset, task);
+			return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
+/* Uncharge the cgroup that we charged in cpuacct_can_attach() */
+static void cpuacct_cancel_attach(struct cgroup_subsys_state *css,
+				  struct cgroup_taskset *tset)
+{
+	cpuacct_cancel_attach_until(css, tset, NULL);
+}
+
+
 static struct cftype files[] = {
 	{
 		.name = "usage",
@@ -226,6 +463,28 @@ static struct cftype files[] = {
 		.name = "stat",
 		.read_map = cpuacct_stats_show,
 	},
+	{
+		.name = "task_limit",
+		.read_u64 = cpuacct_task_limit_read_u64,
+		.write_u64 = cpuacct_task_limit_write_u64,
+		.private = RES_LIMIT,
+	},
+	{
+		.name = "task_usage",
+		.read_u64 = cpuacct_task_limit_read_u64,
+		.private = RES_USAGE,
+	},
+	{
+		.name = "fork_limit",
+		.read_u64 = cpuacct_fork_limit_read_u64,
+		.write_u64 = cpuacct_fork_limit_write_u64,
+		.private = RES_LIMIT,
+	},
+	{
+		.name = "fork_usage",
+		.read_u64 = cpuacct_fork_limit_read_u64,
+		.private = RES_USAGE,
+	},
 	{ }	/* terminate */
 };
 
@@ -278,10 +537,16 @@ void cpuacct_account_field(struct task_struct *p, int index, u64 val)
 }
 
 struct cgroup_subsys cpuacct_subsys = {
-	.name		= "cpuacct",
-	.css_alloc	= cpuacct_css_alloc,
-	.css_free	= cpuacct_css_free,
-	.subsys_id	= cpuacct_subsys_id,
-	.base_cftypes	= files,
-	.early_init	= 1,
+	.name			= "cpuacct",
+	.css_alloc		= cpuacct_css_alloc,
+	.css_free		= cpuacct_css_free,
+	.subsys_id		= cpuacct_subsys_id,
+	.base_cftypes		= files,
+	.early_init		= 1,
+	.can_fork		= cpuacct_can_fork,
+	.cancel_can_fork	= cpuacct_cancel_can_fork,
+	.exit			= cpuacct_exit,
+	.attach			= cpuacct_attach,
+	.can_attach		= cpuacct_can_attach,
+	.cancel_attach		= cpuacct_cancel_attach,
 };
-- 
1.8.3.1
