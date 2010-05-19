From: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
Subject: [PATCH 2/2] scheduler: cgroups cpuaccouting: Make cpuusage atomic
Date: Wed, 19 May 2010 20:58:59 +0200
Message-ID: <1274295539-7798-3-git-send-email-trenn__25762.7139021226$1274295666$gmane$org@suse.de>
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

and avoid locking on 32 bit.
This resolves an ugly dependency in cgroups_cpuaccount.c
to per_cpu runqueues lock variable.

Signed-off-by: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
CC: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: mike-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org
CC: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
CC: lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
CC: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
CC: mingo-X9Un+BFzKDI@public.gmane.org
CC: peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
---
 kernel/cgroup_cpuaccount.c |   39 +++++++++------------------------------
 kernel/sched.c             |   11 -----------
 kernel/sched.h             |    7 -------
 3 files changed, 9 insertions(+), 48 deletions(-)
 delete mode 100644 kernel/sched.h

diff --git a/kernel/cgroup_cpuaccount.c b/kernel/cgroup_cpuaccount.c
index 0ad356a..0a53487 100644
--- a/kernel/cgroup_cpuaccount.c
+++ b/kernel/cgroup_cpuaccount.c
@@ -10,8 +10,6 @@
 
 #include <asm/cputime.h>
 
-#include "sched.h"
-
 /*
  * CPU accounting code for task groups.
  *
@@ -23,7 +21,7 @@
 struct cpuacct {
 	struct cgroup_subsys_state css;
 	/* cpuusage holds pointer to a u64-type object on every cpu */
-	u64 __percpu *cpuusage;
+	atomic64_t __percpu *cpuusage;
 	struct percpu_counter cpustat[CPUACCT_STAT_NSTATS];
 	struct cpuacct *parent;
 };
@@ -54,7 +52,7 @@ static struct cgroup_subsys_state *cpuacct_create(
 	if (!ca)
 		goto out;
 
-	ca->cpuusage = alloc_percpu(u64);
+	ca->cpuusage = alloc_percpu(atomic64_t);
 	if (!ca->cpuusage)
 		goto out_free_ca;
 
@@ -92,37 +90,18 @@ cpuacct_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
 
 static u64 cpuacct_cpuusage_read(struct cpuacct *ca, int cpu)
 {
-	u64 *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
+	atomic64_t *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
 	u64 data;
 
-#ifndef CONFIG_64BIT
-	/*
-	 * Take rq->lock to make 64-bit read safe on 32-bit platforms.
-	 */
-	lock_runqueue(cpu);
-	data = *cpuusage;
-	unlock_runqueue(cpu);
-#else
-	data = *cpuusage;
-#endif
-
+	data = atomic64_read(cpuusage);
 	return data;
 }
 
 static void cpuacct_cpuusage_write(struct cpuacct *ca, int cpu, u64 val)
 {
-	u64 *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
-
-#ifndef CONFIG_64BIT
-	/*
-	 * Take rq->lock to make 64-bit write safe on 32-bit platforms.
-	 */
-	lock_runqueue(cpu);
-	*cpuusage = val;
-	unlock_runqueue(cpu);
-#else
-	*cpuusage = val;
-#endif
+	atomic64_t *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
+
+	atomic64_set(cpuusage, val);
 }
 
 /* return total cpu usage (in nanoseconds) of a group */
@@ -232,8 +211,8 @@ void cpuacct_charge(struct task_struct *tsk, u64 cputime)
 	ca = task_ca(tsk);
 
 	for (; ca; ca = ca->parent) {
-		u64 *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
-		*cpuusage += cputime;
+		atomic64_t *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
+		atomic64_add(cputime, cpuusage);
 	}
 
 	rcu_read_unlock();
diff --git a/kernel/sched.c b/kernel/sched.c
index fc93cbd..e1caba2 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -78,7 +78,6 @@
 #include <asm/irq_regs.h>
 
 #include "sched_cpupri.h"
-#include "sched.h"
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/sched.h>
@@ -642,16 +641,6 @@ static inline int cpu_of(struct rq *rq)
 #define cpu_curr(cpu)		(cpu_rq(cpu)->curr)
 #define raw_rq()		(&__raw_get_cpu_var(runqueues))
 
-void lock_runqueue(unsigned int cpu)
-{
-	raw_spin_lock_irq(&cpu_rq(cpu)->lock);
-}
-
-void unlock_runqueue(unsigned int cpu)
-{
-	raw_spin_unlock_irq(&cpu_rq(cpu)->lock);
-}
-
 inline void update_rq_clock(struct rq *rq)
 {
 	if (!rq->skip_clock_update)
diff --git a/kernel/sched.h b/kernel/sched.h
deleted file mode 100644
index 2fc20e0..0000000
--- a/kernel/sched.h
+++ /dev/null
@@ -1,7 +0,0 @@
-#ifndef _LINUX_SCHED_LOCAL_H
-#define _LINUX_SCHED_LOCAL_H
-
-void lock_runqueue(unsigned int cpu);
-void unlock_runqueue(unsigned int cpu);
-
-#endif
-- 
1.6.3
