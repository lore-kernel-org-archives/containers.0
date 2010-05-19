From: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
Subject: [PATCH 1/2] scheduler: Extract cgroups_cpuaccount code from sched.c
	into own file V2
Date: Wed, 19 May 2010 20:58:58 +0200
Message-ID: <1274295539-7798-2-git-send-email-trenn__31158.2888396972$1274295655$gmane$org@suse.de>
References: <1274264877.5605.10541.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1274264877.5605.10541.camel@twins>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: trenn-l3A5Bk7waGM@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mike-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

This is a cleanup against current linux-2.6 Linus tree.

Having CONFIG_CGROUP_CPUACCT code in kernel/sched.c looks wrong.
Move this out to kernel/cgroup_cpuaccount.c

Test compiled on several archs (IA64, ppc, x86(_64), s390)
with differnt configs.

Signed-off-by: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
CC: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: mike-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org
CC: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
CC: lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
CC: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
CC: mingo-X9Un+BFzKDI@public.gmane.org
CC: peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
---
 include/linux/cgroup.h     |   29 ++++
 kernel/Makefile            |    1 +
 kernel/cgroup_cpuaccount.c |  287 ++++++++++++++++++++++++++++++++++++++++
 kernel/sched.c             |  309 ++------------------------------------------
 kernel/sched.h             |    7 +
 5 files changed, 336 insertions(+), 297 deletions(-)
 create mode 100644 kernel/cgroup_cpuaccount.c
 create mode 100644 kernel/sched.h

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8f78073..1c8f09d 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -609,8 +609,37 @@ bool css_is_ancestor(struct cgroup_subsys_state *cg,
 unsigned short css_id(struct cgroup_subsys_state *css);
 unsigned short css_depth(struct cgroup_subsys_state *css);
 
+/* Time spent by the tasks of the cpu accounting group executing in ... */
+enum cpuacct_stat_index {
+	CPUACCT_STAT_USER,	/* ... user mode */
+	CPUACCT_STAT_SYSTEM,	/* ... kernel mode */
+
+	CPUACCT_STAT_NSTATS,
+};
+
+#ifdef CONFIG_CGROUP_CPUACCT
+void cpuacct_charge(struct task_struct *tsk, u64 cputime);
+void cpuacct_update_stats(struct task_struct *tsk,
+		enum cpuacct_stat_index idx, cputime_t val);
+#else
+static inline void cpuacct_charge(struct task_struct *tsk, u64 cputime) {}
+static inline void cpuacct_update_stats(struct task_struct *tsk,
+			enum cpuacct_stat_index idx, cputime_t val) {}
+#endif
+
 #else /* !CONFIG_CGROUPS */
 
+/* TBD: Make these double declarations (see above) disappear */
+enum cpuacct_stat_index {
+	CPUACCT_STAT_USER,	/* ... user mode */
+	CPUACCT_STAT_SYSTEM,	/* ... kernel mode */
+
+	CPUACCT_STAT_NSTATS,
+};
+static inline void cpuacct_charge(struct task_struct *tsk, u64 cputime) {}
+static inline void cpuacct_update_stats(struct task_struct *tsk,
+			enum cpuacct_stat_index idx, cputime_t val) {}
+
 static inline int cgroup_init_early(void) { return 0; }
 static inline int cgroup_init(void) { return 0; }
 static inline void cgroup_fork(struct task_struct *p) {}
diff --git a/kernel/Makefile b/kernel/Makefile
index 149e18e..1df6e53 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -60,6 +60,7 @@ obj-$(CONFIG_KEXEC) += kexec.o
 obj-$(CONFIG_BACKTRACE_SELF_TEST) += backtracetest.o
 obj-$(CONFIG_COMPAT) += compat.o
 obj-$(CONFIG_CGROUPS) += cgroup.o
+obj-$(CONFIG_CGROUP_CPUACCT) += cgroup_cpuaccount.o
 obj-$(CONFIG_CGROUP_FREEZER) += cgroup_freezer.o
 obj-$(CONFIG_CPUSETS) += cpuset.o
 obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
diff --git a/kernel/cgroup_cpuaccount.c b/kernel/cgroup_cpuaccount.c
new file mode 100644
index 0000000..0ad356a
--- /dev/null
+++ b/kernel/cgroup_cpuaccount.c
@@ -0,0 +1,287 @@
+#include <linux/kernel.h>
+#include <linux/percpu.h>
+#include <linux/spinlock.h>
+#include <linux/sched.h>
+#include <linux/cgroup.h>
+#include <linux/srcu.h>
+#include <linux/slab.h>
+#include <linux/seq_file.h>
+#include <linux/err.h>
+
+#include <asm/cputime.h>
+
+#include "sched.h"
+
+/*
+ * CPU accounting code for task groups.
+ *
+ * Based on the work by Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org) and Balbir Singh
+ * (balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org).
+ */
+
+/* track cpu usage of a group of tasks and its child groups */
+struct cpuacct {
+	struct cgroup_subsys_state css;
+	/* cpuusage holds pointer to a u64-type object on every cpu */
+	u64 __percpu *cpuusage;
+	struct percpu_counter cpustat[CPUACCT_STAT_NSTATS];
+	struct cpuacct *parent;
+};
+
+struct cgroup_subsys cpuacct_subsys;
+
+/* return cpu accounting group corresponding to this container */
+static inline struct cpuacct *cgroup_ca(struct cgroup *cgrp)
+{
+	return container_of(cgroup_subsys_state(cgrp, cpuacct_subsys_id),
+			    struct cpuacct, css);
+}
+
+/* return cpu accounting group to which this task belongs */
+static inline struct cpuacct *task_ca(struct task_struct *tsk)
+{
+	return container_of(task_subsys_state(tsk, cpuacct_subsys_id),
+			    struct cpuacct, css);
+}
+
+/* create a new cpu accounting group */
+static struct cgroup_subsys_state *cpuacct_create(
+	struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct cpuacct *ca = kzalloc(sizeof(*ca), GFP_KERNEL);
+	int i;
+
+	if (!ca)
+		goto out;
+
+	ca->cpuusage = alloc_percpu(u64);
+	if (!ca->cpuusage)
+		goto out_free_ca;
+
+	for (i = 0; i < CPUACCT_STAT_NSTATS; i++)
+		if (percpu_counter_init(&ca->cpustat[i], 0))
+			goto out_free_counters;
+
+	if (cgrp->parent)
+		ca->parent = cgroup_ca(cgrp->parent);
+
+	return &ca->css;
+
+out_free_counters:
+	while (--i >= 0)
+		percpu_counter_destroy(&ca->cpustat[i]);
+	free_percpu(ca->cpuusage);
+out_free_ca:
+	kfree(ca);
+out:
+	return ERR_PTR(-ENOMEM);
+}
+
+/* destroy an existing cpu accounting group */
+static void
+cpuacct_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct cpuacct *ca = cgroup_ca(cgrp);
+	int i;
+
+	for (i = 0; i < CPUACCT_STAT_NSTATS; i++)
+		percpu_counter_destroy(&ca->cpustat[i]);
+	free_percpu(ca->cpuusage);
+	kfree(ca);
+}
+
+static u64 cpuacct_cpuusage_read(struct cpuacct *ca, int cpu)
+{
+	u64 *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
+	u64 data;
+
+#ifndef CONFIG_64BIT
+	/*
+	 * Take rq->lock to make 64-bit read safe on 32-bit platforms.
+	 */
+	lock_runqueue(cpu);
+	data = *cpuusage;
+	unlock_runqueue(cpu);
+#else
+	data = *cpuusage;
+#endif
+
+	return data;
+}
+
+static void cpuacct_cpuusage_write(struct cpuacct *ca, int cpu, u64 val)
+{
+	u64 *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
+
+#ifndef CONFIG_64BIT
+	/*
+	 * Take rq->lock to make 64-bit write safe on 32-bit platforms.
+	 */
+	lock_runqueue(cpu);
+	*cpuusage = val;
+	unlock_runqueue(cpu);
+#else
+	*cpuusage = val;
+#endif
+}
+
+/* return total cpu usage (in nanoseconds) of a group */
+static u64 cpuusage_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct cpuacct *ca = cgroup_ca(cgrp);
+	u64 totalcpuusage = 0;
+	int i;
+
+	for_each_present_cpu(i)
+		totalcpuusage += cpuacct_cpuusage_read(ca, i);
+
+	return totalcpuusage;
+}
+
+static int cpuusage_write(struct cgroup *cgrp, struct cftype *cftype,
+								u64 reset)
+{
+	struct cpuacct *ca = cgroup_ca(cgrp);
+	int err = 0;
+	int i;
+
+	if (reset) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	for_each_present_cpu(i)
+		cpuacct_cpuusage_write(ca, i, 0);
+
+out:
+	return err;
+}
+
+static int cpuacct_percpu_seq_read(struct cgroup *cgroup, struct cftype *cft,
+				   struct seq_file *m)
+{
+	struct cpuacct *ca = cgroup_ca(cgroup);
+	u64 percpu;
+	int i;
+
+	for_each_present_cpu(i) {
+		percpu = cpuacct_cpuusage_read(ca, i);
+		seq_printf(m, "%llu ", (unsigned long long) percpu);
+	}
+	seq_printf(m, "\n");
+	return 0;
+}
+
+static const char *cpuacct_stat_desc[] = {
+	[CPUACCT_STAT_USER] = "user",
+	[CPUACCT_STAT_SYSTEM] = "system",
+};
+
+static int cpuacct_stats_show(struct cgroup *cgrp, struct cftype *cft,
+		struct cgroup_map_cb *cb)
+{
+	struct cpuacct *ca = cgroup_ca(cgrp);
+	int i;
+
+	for (i = 0; i < CPUACCT_STAT_NSTATS; i++) {
+		s64 val = percpu_counter_read(&ca->cpustat[i]);
+		val = cputime64_to_clock_t(val);
+		cb->fill(cb, cpuacct_stat_desc[i], val);
+	}
+	return 0;
+}
+
+static struct cftype files[] = {
+	{
+		.name = "usage",
+		.read_u64 = cpuusage_read,
+		.write_u64 = cpuusage_write,
+	},
+	{
+		.name = "usage_percpu",
+		.read_seq_string = cpuacct_percpu_seq_read,
+	},
+	{
+		.name = "stat",
+		.read_map = cpuacct_stats_show,
+	},
+};
+
+static int cpuacct_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	return cgroup_add_files(cgrp, ss, files, ARRAY_SIZE(files));
+}
+
+/*
+ * charge this task's execution time to its accounting group.
+ *
+ * called with rq->lock held.
+ */
+void cpuacct_charge(struct task_struct *tsk, u64 cputime)
+{
+	struct cpuacct *ca;
+	int cpu;
+
+	if (unlikely(!cpuacct_subsys.active))
+		return;
+
+	cpu = task_cpu(tsk);
+
+	rcu_read_lock();
+
+	ca = task_ca(tsk);
+
+	for (; ca; ca = ca->parent) {
+		u64 *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
+		*cpuusage += cputime;
+	}
+
+	rcu_read_unlock();
+}
+
+/*
+ * When CONFIG_VIRT_CPU_ACCOUNTING is enabled one jiffy can be very large
+ * in cputime_t units. As a result, cpuacct_update_stats calls
+ * percpu_counter_add with values large enough to always overflow the
+ * per cpu batch limit causing bad SMP scalability.
+ *
+ * To fix this we scale percpu_counter_batch by cputime_one_jiffy so we
+ * batch the same amount of time with CONFIG_VIRT_CPU_ACCOUNTING disabled
+ * and enabled. We cap it at INT_MAX which is the largest allowed batch value.
+ */
+#ifdef CONFIG_SMP
+#define CPUACCT_BATCH	\
+	min_t(long, percpu_counter_batch * cputime_one_jiffy, INT_MAX)
+#else
+#define CPUACCT_BATCH	0
+#endif
+
+/*
+ * Charge the system/user time to the task's accounting group.
+ */
+void cpuacct_update_stats(struct task_struct *tsk,
+			  enum cpuacct_stat_index idx, cputime_t val)
+{
+	struct cpuacct *ca;
+	int batch = CPUACCT_BATCH;
+
+	if (unlikely(!cpuacct_subsys.active))
+		return;
+
+	rcu_read_lock();
+	ca = task_ca(tsk);
+
+	do {
+		__percpu_counter_add(&ca->cpustat[idx], val, batch);
+		ca = ca->parent;
+	} while (ca);
+	rcu_read_unlock();
+}
+
+struct cgroup_subsys cpuacct_subsys = {
+	.name = "cpuacct",
+	.create = cpuacct_create,
+	.destroy = cpuacct_destroy,
+	.populate = cpuacct_populate,
+	.subsys_id = cpuacct_subsys_id,
+};
diff --git a/kernel/sched.c b/kernel/sched.c
index 1d93cd0..fc93cbd 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -72,11 +72,13 @@
 #include <linux/ctype.h>
 #include <linux/ftrace.h>
 #include <linux/slab.h>
+#include <linux/cgroup.h>
 
 #include <asm/tlb.h>
 #include <asm/irq_regs.h>
 
 #include "sched_cpupri.h"
+#include "sched.h"
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/sched.h>
@@ -236,8 +238,6 @@ static DEFINE_MUTEX(sched_domains_mutex);
 
 #ifdef CONFIG_CGROUP_SCHED
 
-#include <linux/cgroup.h>
-
 struct cfs_rq;
 
 static LIST_HEAD(task_groups);
@@ -642,6 +642,16 @@ static inline int cpu_of(struct rq *rq)
 #define cpu_curr(cpu)		(cpu_rq(cpu)->curr)
 #define raw_rq()		(&__raw_get_cpu_var(runqueues))
 
+void lock_runqueue(unsigned int cpu)
+{
+	raw_spin_lock_irq(&cpu_rq(cpu)->lock);
+}
+
+void unlock_runqueue(unsigned int cpu)
+{
+	raw_spin_unlock_irq(&cpu_rq(cpu)->lock);
+}
+
 inline void update_rq_clock(struct rq *rq)
 {
 	if (!rq->skip_clock_update)
@@ -1394,24 +1404,6 @@ static const u32 prio_to_wmult[40] = {
  /*  15 */ 119304647, 148102320, 186737708, 238609294, 286331153,
 };
 
-/* Time spent by the tasks of the cpu accounting group executing in ... */
-enum cpuacct_stat_index {
-	CPUACCT_STAT_USER,	/* ... user mode */
-	CPUACCT_STAT_SYSTEM,	/* ... kernel mode */
-
-	CPUACCT_STAT_NSTATS,
-};
-
-#ifdef CONFIG_CGROUP_CPUACCT
-static void cpuacct_charge(struct task_struct *tsk, u64 cputime);
-static void cpuacct_update_stats(struct task_struct *tsk,
-		enum cpuacct_stat_index idx, cputime_t val);
-#else
-static inline void cpuacct_charge(struct task_struct *tsk, u64 cputime) {}
-static inline void cpuacct_update_stats(struct task_struct *tsk,
-		enum cpuacct_stat_index idx, cputime_t val) {}
-#endif
-
 static inline void inc_cpu_load(struct rq *rq, unsigned long load)
 {
 	update_load_add(&rq->load, load);
@@ -8617,283 +8609,6 @@ struct cgroup_subsys cpu_cgroup_subsys = {
 
 #endif	/* CONFIG_CGROUP_SCHED */
 
-#ifdef CONFIG_CGROUP_CPUACCT
-
-/*
- * CPU accounting code for task groups.
- *
- * Based on the work by Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org) and Balbir Singh
- * (balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org).
- */
-
-/* track cpu usage of a group of tasks and its child groups */
-struct cpuacct {
-	struct cgroup_subsys_state css;
-	/* cpuusage holds pointer to a u64-type object on every cpu */
-	u64 __percpu *cpuusage;
-	struct percpu_counter cpustat[CPUACCT_STAT_NSTATS];
-	struct cpuacct *parent;
-};
-
-struct cgroup_subsys cpuacct_subsys;
-
-/* return cpu accounting group corresponding to this container */
-static inline struct cpuacct *cgroup_ca(struct cgroup *cgrp)
-{
-	return container_of(cgroup_subsys_state(cgrp, cpuacct_subsys_id),
-			    struct cpuacct, css);
-}
-
-/* return cpu accounting group to which this task belongs */
-static inline struct cpuacct *task_ca(struct task_struct *tsk)
-{
-	return container_of(task_subsys_state(tsk, cpuacct_subsys_id),
-			    struct cpuacct, css);
-}
-
-/* create a new cpu accounting group */
-static struct cgroup_subsys_state *cpuacct_create(
-	struct cgroup_subsys *ss, struct cgroup *cgrp)
-{
-	struct cpuacct *ca = kzalloc(sizeof(*ca), GFP_KERNEL);
-	int i;
-
-	if (!ca)
-		goto out;
-
-	ca->cpuusage = alloc_percpu(u64);
-	if (!ca->cpuusage)
-		goto out_free_ca;
-
-	for (i = 0; i < CPUACCT_STAT_NSTATS; i++)
-		if (percpu_counter_init(&ca->cpustat[i], 0))
-			goto out_free_counters;
-
-	if (cgrp->parent)
-		ca->parent = cgroup_ca(cgrp->parent);
-
-	return &ca->css;
-
-out_free_counters:
-	while (--i >= 0)
-		percpu_counter_destroy(&ca->cpustat[i]);
-	free_percpu(ca->cpuusage);
-out_free_ca:
-	kfree(ca);
-out:
-	return ERR_PTR(-ENOMEM);
-}
-
-/* destroy an existing cpu accounting group */
-static void
-cpuacct_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
-{
-	struct cpuacct *ca = cgroup_ca(cgrp);
-	int i;
-
-	for (i = 0; i < CPUACCT_STAT_NSTATS; i++)
-		percpu_counter_destroy(&ca->cpustat[i]);
-	free_percpu(ca->cpuusage);
-	kfree(ca);
-}
-
-static u64 cpuacct_cpuusage_read(struct cpuacct *ca, int cpu)
-{
-	u64 *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
-	u64 data;
-
-#ifndef CONFIG_64BIT
-	/*
-	 * Take rq->lock to make 64-bit read safe on 32-bit platforms.
-	 */
-	raw_spin_lock_irq(&cpu_rq(cpu)->lock);
-	data = *cpuusage;
-	raw_spin_unlock_irq(&cpu_rq(cpu)->lock);
-#else
-	data = *cpuusage;
-#endif
-
-	return data;
-}
-
-static void cpuacct_cpuusage_write(struct cpuacct *ca, int cpu, u64 val)
-{
-	u64 *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
-
-#ifndef CONFIG_64BIT
-	/*
-	 * Take rq->lock to make 64-bit write safe on 32-bit platforms.
-	 */
-	raw_spin_lock_irq(&cpu_rq(cpu)->lock);
-	*cpuusage = val;
-	raw_spin_unlock_irq(&cpu_rq(cpu)->lock);
-#else
-	*cpuusage = val;
-#endif
-}
-
-/* return total cpu usage (in nanoseconds) of a group */
-static u64 cpuusage_read(struct cgroup *cgrp, struct cftype *cft)
-{
-	struct cpuacct *ca = cgroup_ca(cgrp);
-	u64 totalcpuusage = 0;
-	int i;
-
-	for_each_present_cpu(i)
-		totalcpuusage += cpuacct_cpuusage_read(ca, i);
-
-	return totalcpuusage;
-}
-
-static int cpuusage_write(struct cgroup *cgrp, struct cftype *cftype,
-								u64 reset)
-{
-	struct cpuacct *ca = cgroup_ca(cgrp);
-	int err = 0;
-	int i;
-
-	if (reset) {
-		err = -EINVAL;
-		goto out;
-	}
-
-	for_each_present_cpu(i)
-		cpuacct_cpuusage_write(ca, i, 0);
-
-out:
-	return err;
-}
-
-static int cpuacct_percpu_seq_read(struct cgroup *cgroup, struct cftype *cft,
-				   struct seq_file *m)
-{
-	struct cpuacct *ca = cgroup_ca(cgroup);
-	u64 percpu;
-	int i;
-
-	for_each_present_cpu(i) {
-		percpu = cpuacct_cpuusage_read(ca, i);
-		seq_printf(m, "%llu ", (unsigned long long) percpu);
-	}
-	seq_printf(m, "\n");
-	return 0;
-}
-
-static const char *cpuacct_stat_desc[] = {
-	[CPUACCT_STAT_USER] = "user",
-	[CPUACCT_STAT_SYSTEM] = "system",
-};
-
-static int cpuacct_stats_show(struct cgroup *cgrp, struct cftype *cft,
-		struct cgroup_map_cb *cb)
-{
-	struct cpuacct *ca = cgroup_ca(cgrp);
-	int i;
-
-	for (i = 0; i < CPUACCT_STAT_NSTATS; i++) {
-		s64 val = percpu_counter_read(&ca->cpustat[i]);
-		val = cputime64_to_clock_t(val);
-		cb->fill(cb, cpuacct_stat_desc[i], val);
-	}
-	return 0;
-}
-
-static struct cftype files[] = {
-	{
-		.name = "usage",
-		.read_u64 = cpuusage_read,
-		.write_u64 = cpuusage_write,
-	},
-	{
-		.name = "usage_percpu",
-		.read_seq_string = cpuacct_percpu_seq_read,
-	},
-	{
-		.name = "stat",
-		.read_map = cpuacct_stats_show,
-	},
-};
-
-static int cpuacct_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
-{
-	return cgroup_add_files(cgrp, ss, files, ARRAY_SIZE(files));
-}
-
-/*
- * charge this task's execution time to its accounting group.
- *
- * called with rq->lock held.
- */
-static void cpuacct_charge(struct task_struct *tsk, u64 cputime)
-{
-	struct cpuacct *ca;
-	int cpu;
-
-	if (unlikely(!cpuacct_subsys.active))
-		return;
-
-	cpu = task_cpu(tsk);
-
-	rcu_read_lock();
-
-	ca = task_ca(tsk);
-
-	for (; ca; ca = ca->parent) {
-		u64 *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
-		*cpuusage += cputime;
-	}
-
-	rcu_read_unlock();
-}
-
-/*
- * When CONFIG_VIRT_CPU_ACCOUNTING is enabled one jiffy can be very large
- * in cputime_t units. As a result, cpuacct_update_stats calls
- * percpu_counter_add with values large enough to always overflow the
- * per cpu batch limit causing bad SMP scalability.
- *
- * To fix this we scale percpu_counter_batch by cputime_one_jiffy so we
- * batch the same amount of time with CONFIG_VIRT_CPU_ACCOUNTING disabled
- * and enabled. We cap it at INT_MAX which is the largest allowed batch value.
- */
-#ifdef CONFIG_SMP
-#define CPUACCT_BATCH	\
-	min_t(long, percpu_counter_batch * cputime_one_jiffy, INT_MAX)
-#else
-#define CPUACCT_BATCH	0
-#endif
-
-/*
- * Charge the system/user time to the task's accounting group.
- */
-static void cpuacct_update_stats(struct task_struct *tsk,
-		enum cpuacct_stat_index idx, cputime_t val)
-{
-	struct cpuacct *ca;
-	int batch = CPUACCT_BATCH;
-
-	if (unlikely(!cpuacct_subsys.active))
-		return;
-
-	rcu_read_lock();
-	ca = task_ca(tsk);
-
-	do {
-		__percpu_counter_add(&ca->cpustat[idx], val, batch);
-		ca = ca->parent;
-	} while (ca);
-	rcu_read_unlock();
-}
-
-struct cgroup_subsys cpuacct_subsys = {
-	.name = "cpuacct",
-	.create = cpuacct_create,
-	.destroy = cpuacct_destroy,
-	.populate = cpuacct_populate,
-	.subsys_id = cpuacct_subsys_id,
-};
-#endif	/* CONFIG_CGROUP_CPUACCT */
-
 #ifndef CONFIG_SMP
 
 void synchronize_sched_expedited(void)
diff --git a/kernel/sched.h b/kernel/sched.h
new file mode 100644
index 0000000..2fc20e0
--- /dev/null
+++ b/kernel/sched.h
@@ -0,0 +1,7 @@
+#ifndef _LINUX_SCHED_LOCAL_H
+#define _LINUX_SCHED_LOCAL_H
+
+void lock_runqueue(unsigned int cpu);
+void unlock_runqueue(unsigned int cpu);
+
+#endif
-- 
1.6.3
