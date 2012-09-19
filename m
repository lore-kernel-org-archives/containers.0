From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/3] cgroup, sched: let cpu serve the same files as cpuacct
Date: Wed, 19 Sep 2012 15:43:44 -0700
Message-ID: <1348094625-4471-3-git-send-email-tj@kernel.org>
References: <1348094625-4471-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348094625-4471-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, kay.sievers-tD+1rO4QERM@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, mzxreary-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org
List-Id: containers.vger.kernel.org

cpuacct being on a separate hierarchy is one of the main cgroup
related complaints from scheduler side and the consensus seems to be

* Allowing cpuacct to be a separate controller was a mistake.  In
  general multiple controllers on the same type of resource should be
  avoided, especially accounting-only ones.

* Statistics provided by cpuacct are useful and should instead be
  served by cpu.

This patch makes cpu maintain and serve all cpuacct.* files and make
cgroup core ignore cpuacct if it's co-mounted with cpu.  This is a
step in deprecating cpuacct.  The next patch will allow disabling or
dropping cpuacct without affecting userland too much.

Note that this creates some discrepancies in /proc/cgroups and
/proc/PID/cgroup.  The co-mounted cpuacct won't be reflected correctly
there.  cpuacct will eventually be removed completely probably except
for the statistics filenames and I'd like to keep the amount of
compatbility hackery to minimum as much as possible.

The cpu statistics implementation isn't optimized in any way.  It's
mostly verbatim copy from cpuacct.  The goal is allowing quick
disabling and removal of CONFIG_CGROUP_CPUACCT and creating a base on
top of which cpu can implement proper optimization.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
Cc: Lennart Poettering <mzxreary-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
Cc: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Cc: Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c          |   13 +++
 kernel/sched/core.c      |  194 +++++++++++++++++++++++++++++++++++++++++++++-
 kernel/sched/fair.c      |    1 +
 kernel/sched/rt.c        |    1 +
 kernel/sched/sched.h     |    7 ++
 kernel/sched/stop_task.c |    1 +
 6 files changed, 215 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 08edb52..01c11e3 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1265,6 +1265,19 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 	/* Consistency checks */
 
 	/*
+	 * cpuacct is deprecated and cpu will serve the same stat files.
+	 * If co-mount with cpu is requested, ignore cpuacct.  Note that
+	 * this creates some discrepancies in /proc/cgroups and
+	 * /proc/PID/cgroup.
+	 *
+	 * https://lkml.org/lkml/2012/9/13/542
+	 */
+#if IS_ENABLED(CONFIG_CGROUP_SCHED) && IS_ENABLED(CONFIG_CGROUP_CPUACCT)
+	if ((opts->subsys_bits & (1 << cpu_cgroup_subsys_id)) &&
+	    (opts->subsys_bits & (1 << cpuacct_subsys_id)))
+		opts->subsys_bits &= ~(1 << cpuacct_subsys_id);
+#endif
+	/*
 	 * Option noprefix was introduced just for backward compatibility
 	 * with the old cpuset, so we allow noprefix only if mounting just
 	 * the cpuset subsystem.
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index fbf1fd0..9648671 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -2817,8 +2817,10 @@ struct cpuacct root_cpuacct;
 static inline void task_group_account_field(struct task_struct *p, int index,
 					    u64 tmp)
 {
+#ifdef CONFIG_CGROUP_SCHED
+	struct task_group *tg;
+#endif
 #ifdef CONFIG_CGROUP_CPUACCT
-	struct kernel_cpustat *kcpustat;
 	struct cpuacct *ca;
 #endif
 	/*
@@ -2829,6 +2831,20 @@ static inline void task_group_account_field(struct task_struct *p, int index,
 	 */
 	__get_cpu_var(kernel_cpustat).cpustat[index] += tmp;
 
+#ifdef CONFIG_CGROUP_SCHED
+	rcu_read_lock();
+	tg = container_of(task_subsys_state(p, cpu_cgroup_subsys_id),
+			  struct task_group, css);
+
+	while (tg && (tg != &root_task_group)) {
+		struct kernel_cpustat *kcpustat = this_cpu_ptr(tg->cpustat);
+
+		kcpustat->cpustat[index] += tmp;
+		tg = tg->parent;
+	}
+	rcu_read_unlock();
+#endif
+
 #ifdef CONFIG_CGROUP_CPUACCT
 	if (unlikely(!cpuacct_subsys.active))
 		return;
@@ -2836,7 +2852,8 @@ static inline void task_group_account_field(struct task_struct *p, int index,
 	rcu_read_lock();
 	ca = task_ca(p);
 	while (ca && (ca != &root_cpuacct)) {
-		kcpustat = this_cpu_ptr(ca->cpustat);
+		struct kernel_cpustat *kcpustat = this_cpu_ptr(ca->cpustat);
+
 		kcpustat->cpustat[index] += tmp;
 		ca = parent_ca(ca);
 	}
@@ -7253,6 +7270,7 @@ int in_sched_functions(unsigned long addr)
 #ifdef CONFIG_CGROUP_SCHED
 struct task_group root_task_group;
 LIST_HEAD(task_groups);
+static DEFINE_PER_CPU(u64, root_tg_cpuusage);
 #endif
 
 DECLARE_PER_CPU(cpumask_var_t, load_balance_tmpmask);
@@ -7311,6 +7329,8 @@ void __init sched_init(void)
 #endif /* CONFIG_RT_GROUP_SCHED */
 
 #ifdef CONFIG_CGROUP_SCHED
+	root_task_group.cpustat = &kernel_cpustat;
+	root_task_group.cpuusage = &root_tg_cpuusage;
 	list_add(&root_task_group.list, &task_groups);
 	INIT_LIST_HEAD(&root_task_group.children);
 	INIT_LIST_HEAD(&root_task_group.siblings);
@@ -7594,6 +7614,8 @@ static void free_sched_group(struct task_group *tg)
 	free_fair_sched_group(tg);
 	free_rt_sched_group(tg);
 	autogroup_free(tg);
+	free_percpu(tg->cpuusage);
+	free_percpu(tg->cpustat);
 	kfree(tg);
 }
 
@@ -7607,6 +7629,11 @@ struct task_group *sched_create_group(struct task_group *parent)
 	if (!tg)
 		return ERR_PTR(-ENOMEM);
 
+	tg->cpuusage = alloc_percpu(u64);
+	tg->cpustat = alloc_percpu(struct kernel_cpustat);
+	if (!tg->cpuusage || !tg->cpustat)
+		goto err;
+
 	if (!alloc_fair_sched_group(tg, parent))
 		goto err;
 
@@ -7698,6 +7725,24 @@ void sched_move_task(struct task_struct *tsk)
 
 	task_rq_unlock(rq, tsk, &flags);
 }
+
+void task_group_charge(struct task_struct *tsk, u64 cputime)
+{
+	struct task_group *tg;
+	int cpu = task_cpu(tsk);
+
+	rcu_read_lock();
+
+	tg = container_of(task_subsys_state(tsk, cpu_cgroup_subsys_id),
+			  struct task_group, css);
+
+	for (; tg; tg = tg->parent) {
+		u64 *cpuusage = per_cpu_ptr(tg->cpuusage, cpu);
+		*cpuusage += cputime;
+	}
+
+	rcu_read_unlock();
+}
 #endif /* CONFIG_CGROUP_SCHED */
 
 #if defined(CONFIG_RT_GROUP_SCHED) || defined(CONFIG_CFS_BANDWIDTH)
@@ -8054,6 +8099,134 @@ cpu_cgroup_exit(struct cgroup *cgrp, struct cgroup *old_cgrp,
 	sched_move_task(task);
 }
 
+static u64 task_group_cpuusage_read(struct task_group *tg, int cpu)
+{
+	u64 *cpuusage = per_cpu_ptr(tg->cpuusage, cpu);
+	u64 data;
+
+#ifndef CONFIG_64BIT
+	/*
+	 * Take rq->lock to make 64-bit read safe on 32-bit platforms.
+	 */
+	raw_spin_lock_irq(&cpu_rq(cpu)->lock);
+	data = *cpuusage;
+	raw_spin_unlock_irq(&cpu_rq(cpu)->lock);
+#else
+	data = *cpuusage;
+#endif
+
+	return data;
+}
+
+static void task_group_cpuusage_write(struct task_group *tg, int cpu, u64 val)
+{
+	u64 *cpuusage = per_cpu_ptr(tg->cpuusage, cpu);
+
+#ifndef CONFIG_64BIT
+	/*
+	 * Take rq->lock to make 64-bit write safe on 32-bit platforms.
+	 */
+	raw_spin_lock_irq(&cpu_rq(cpu)->lock);
+	*cpuusage = val;
+	raw_spin_unlock_irq(&cpu_rq(cpu)->lock);
+#else
+	*cpuusage = val;
+#endif
+}
+
+/* return total cpu usage (in nanoseconds) of a group */
+static u64 cpucg_cpuusage_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct task_group *tg;
+	u64 totalcpuusage = 0;
+	int i;
+
+	tg = container_of(cgroup_subsys_state(cgrp, cpu_cgroup_subsys_id),
+			  struct task_group, css);
+
+	for_each_present_cpu(i)
+		totalcpuusage += task_group_cpuusage_read(tg, i);
+
+	return totalcpuusage;
+}
+
+static int cpucg_cpuusage_write(struct cgroup *cgrp, struct cftype *cftype,
+				u64 reset)
+{
+	struct task_group *tg;
+	int err = 0;
+	int i;
+
+	tg = container_of(cgroup_subsys_state(cgrp, cpu_cgroup_subsys_id),
+			  struct task_group, css);
+
+	if (reset) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	for_each_present_cpu(i)
+		task_group_cpuusage_write(tg, i, 0);
+
+out:
+	return err;
+}
+
+static int cpucg_percpu_seq_read(struct cgroup *cgrp, struct cftype *cft,
+				 struct seq_file *m)
+{
+	struct task_group *tg;
+	u64 percpu;
+	int i;
+
+	tg = container_of(cgroup_subsys_state(cgrp, cpu_cgroup_subsys_id),
+			  struct task_group, css);
+
+	for_each_present_cpu(i) {
+		percpu = task_group_cpuusage_read(tg, i);
+		seq_printf(m, "%llu ", (unsigned long long) percpu);
+	}
+	seq_printf(m, "\n");
+	return 0;
+}
+
+static const char *cpucg_stat_desc[] = {
+	[CPUACCT_STAT_USER] = "user",
+	[CPUACCT_STAT_SYSTEM] = "system",
+};
+
+static int cpucg_stats_show(struct cgroup *cgrp, struct cftype *cft,
+			    struct cgroup_map_cb *cb)
+{
+	struct task_group *tg;
+	int cpu;
+	s64 val = 0;
+
+	tg = container_of(cgroup_subsys_state(cgrp, cpu_cgroup_subsys_id),
+			  struct task_group, css);
+
+	for_each_online_cpu(cpu) {
+		struct kernel_cpustat *kcpustat = per_cpu_ptr(tg->cpustat, cpu);
+		val += kcpustat->cpustat[CPUTIME_USER];
+		val += kcpustat->cpustat[CPUTIME_NICE];
+	}
+	val = cputime64_to_clock_t(val);
+	cb->fill(cb, cpucg_stat_desc[CPUACCT_STAT_USER], val);
+
+	val = 0;
+	for_each_online_cpu(cpu) {
+		struct kernel_cpustat *kcpustat = per_cpu_ptr(tg->cpustat, cpu);
+		val += kcpustat->cpustat[CPUTIME_SYSTEM];
+		val += kcpustat->cpustat[CPUTIME_IRQ];
+		val += kcpustat->cpustat[CPUTIME_SOFTIRQ];
+	}
+
+	val = cputime64_to_clock_t(val);
+	cb->fill(cb, cpucg_stat_desc[CPUACCT_STAT_SYSTEM], val);
+
+	return 0;
+}
+
 #ifdef CONFIG_FAIR_GROUP_SCHED
 static int cpu_shares_write_u64(struct cgroup *cgrp, struct cftype *cftype,
 				u64 shareval)
@@ -8360,6 +8533,23 @@ static struct cftype cpu_files[] = {
 		.write_u64 = cpu_rt_period_write_uint,
 	},
 #endif
+	/* cpuacct.* which used to be served by a separate cpuacct controller */
+	{
+		.name = "cpuacct.usage",
+		.flags = CFTYPE_NO_PREFIX,
+		.read_u64 = cpucg_cpuusage_read,
+		.write_u64 = cpucg_cpuusage_write,
+	},
+	{
+		.name = "cpuacct.usage_percpu",
+		.flags = CFTYPE_NO_PREFIX,
+		.read_seq_string = cpucg_percpu_seq_read,
+	},
+	{
+		.name = "cpuacct.stat",
+		.flags = CFTYPE_NO_PREFIX,
+		.read_map = cpucg_stats_show,
+	},
 	{ }	/* terminate */
 };
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index c219bf8..8935c3a 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -706,6 +706,7 @@ static void update_curr(struct cfs_rq *cfs_rq)
 		struct task_struct *curtask = task_of(curr);
 
 		trace_sched_stat_runtime(curtask, delta_exec, curr->vruntime);
+		task_group_charge(curtask, delta_exec);
 		cpuacct_charge(curtask, delta_exec);
 		account_group_exec_runtime(curtask, delta_exec);
 	}
diff --git a/kernel/sched/rt.c b/kernel/sched/rt.c
index 944cb68..53f7d3d 100644
--- a/kernel/sched/rt.c
+++ b/kernel/sched/rt.c
@@ -934,6 +934,7 @@ static void update_curr_rt(struct rq *rq)
 	account_group_exec_runtime(curr, delta_exec);
 
 	curr->se.exec_start = rq->clock_task;
+	task_group_charge(curr, delta_exec);
 	cpuacct_charge(curr, delta_exec);
 
 	sched_rt_avg_update(rq, delta_exec);
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index f6714d0..bfa115e 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -104,6 +104,10 @@ struct cfs_bandwidth {
 struct task_group {
 	struct cgroup_subsys_state css;
 
+	/* statistics */
+	u64 __percpu *cpuusage;
+	struct kernel_cpustat __percpu *cpustat;
+
 #ifdef CONFIG_FAIR_GROUP_SCHED
 	/* schedulable entities of this group on each cpu */
 	struct sched_entity **se;
@@ -575,6 +579,8 @@ static inline void set_task_rq(struct task_struct *p, unsigned int cpu)
 #endif
 }
 
+extern void task_group_charge(struct task_struct *tsk, u64 cputime);
+
 #else /* CONFIG_CGROUP_SCHED */
 
 static inline void set_task_rq(struct task_struct *p, unsigned int cpu) { }
@@ -582,6 +588,7 @@ static inline struct task_group *task_group(struct task_struct *p)
 {
 	return NULL;
 }
+static inline void task_group_charge(struct task_struct *tsk, u64 cputime) { }
 
 #endif /* CONFIG_CGROUP_SCHED */
 
diff --git a/kernel/sched/stop_task.c b/kernel/sched/stop_task.c
index da5eb5b..e323790 100644
--- a/kernel/sched/stop_task.c
+++ b/kernel/sched/stop_task.c
@@ -68,6 +68,7 @@ static void put_prev_task_stop(struct rq *rq, struct task_struct *prev)
 	account_group_exec_runtime(curr, delta_exec);
 
 	curr->se.exec_start = rq->clock_task;
+	task_group_charge(curr, delta_exec);
 	cpuacct_charge(curr, delta_exec);
 }
 
-- 
1.7.7.3
