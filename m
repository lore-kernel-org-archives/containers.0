From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Fri, 23 Jan 2009 20:26:15 +0530
Message-ID: <200901232026.16778.knikanth__15751.6612824567$1232723097$gmane$org@suse.de>
References: <200901211638.23101.knikanth@suse.de>
	<200901231515.37442.knikanth@suse.de>
	<alpine.DEB.2.00.0901230223500.15719@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.0901230223500.15719-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve =?iso-8859-1?q?Hj=F8nnev=E5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

On Friday 23 January 2009 16:03:49 David Rientjes wrote:
> On Fri, 23 Jan 2009, Nikanth Karthikesan wrote:
> > > Of course, because the oom killer must be aware that tasks in disjoint
> > > cpusets are more likely than not to result in no memory freeing for
> > > current's subsequent allocations.
> >
> > Yes, the problem is cpuset does not track the tasks which has allocated
> > from this node - who has either moved or changed it set of allowable
> > nodes. And because of that it does not limit oom killing to the tasks
> > with in those tasks and could kill some innocent tasks at times.
>
> Right, the logic to prefer tasks that share the same set of allowable
> nodes as the oom-triggering task is implemented in badness() and being in
> a completely disjoint cpuset does not specifically exclude a task from
> being chosen as the oom killer's victim.  That's because, as you said, it
> could have allocated memory elsewhere before changing cpusets or its set
> of allowable mems.
>
> > As it is unable to take deterministic decision as memcg does, it plays
> > with badness value and only suggests but does not restricts within those
> > tasks that has to be killed.
> >
> > This bug is present even without this patch.
>
> It's not a bug, it can actually help in a couple instances:
>
>  - a much larger memory hogging task is identified in a disjoint cpuset
>    and the liklihood it has allocated memory elsewhere either previously
>    or atomically, or
>
>  - an administrator tunes the oom_adj value for such a task to describe
>    the above behavior even for smaller tasks and their liklihood to
>    allocate outside of their exclusive cpuset.
>

In other instances, It can actually also kill some innocent tasks unless the 
administrator tunes oom_adj, say something like kvm which would have a huge 
memory accounted, but might be from a different node altogether. Killing a 
single vm is killing all of the processes in that OS ;)  Don't you think this 
has to be fixed^Wimproved?

> > This patch adds one more easier way for the administrator to over-ride.
>
> Yeah, I know.  But the problem with the approach is that it specifies an
> oom priority for both global unconstrained ooms and cpuset-constrained
> ooms.
>
> It's quite possible with your patch to identify an aggregate of tasks that
> should be killed first whenever the system is completely out of memory.
> That's great, and solves your problem.  But that same system cannot
> correctly use cpusets that have the potential to ever oom because your
> patch completely overrides the victim priority and could needlessly kill
> tasks that will not lead to future memory freeing.
>
> That's my objection to the proposal: it doesn't behave appropriately for
> both global unconstrained ooms and cpuset-constrained ooms at the same
> time.
>

So you are against specifying order when it is a cpuset-constrained oom. Here 
is a revised version of the patch which adds oom.cpuset_constraint, when set 
to 1 would disable the ordering imposed by this controller for cpuset 
constrained ooms! Will this work for you?

Thanks
Nikanth

From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>

Cgroup based OOM killer controller

Signed-off-by: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>

---

This is a container group based approach to override the oom killer selection 
without losing all the benefits of the current oom killer heuristics and 
oom_adj interface.

It adds a tunable oom.victim to the oom cgroup. The oom killer will kill the 
process using the usual badness value but only within the cgroup with the 
maximum value for oom.victim before killing any process from a cgroup with a 
lesser oom.victim number. Oom killing could be disabled by setting 
oom.victim=0.

Difference from oom_adj:
This controller allows users to specify "strict order" for oom kills. While 
oom_adj just works as a hint for the kernel, OOM Killer Controller gives users 
full control to decide the order in which processes should be killed. It is 
very hard to specify oom-kill order for several applications using just 
oom_adj because one needs to adjust oom_adj of various task based on oom_score 
of several tasks which keeps changing.

CPUSET constrained OOM:
Also the tunable oom.cpuset_constrained when enabled, would disable the 
ordering imposed by this controller for cpuset constrained OOMs.

diff --git a/Documentation/cgroups/oom.txt b/Documentation/cgroups/oom.txt
new file mode 100644
index 0000000..772fb41
--- /dev/null
+++ b/Documentation/cgroups/oom.txt
@@ -0,0 +1,34 @@
+OOM Killer controller
+--- ------ ----------
+
+The OOM killer kills the process based on a set of heuristics such that only
+minimum amount of work done will be lost, a large amount of memory would be
+recovered and minimum no of processes are killed.
+
+The user can adjust the score used to select the processes to be killed using
+/proc/<pid>/oom_adj. Giving it a high score will increase the likelihood of 
+this process being killed by the oom-killer.  Valid values are in the range 
+-16 to +15, plus the special value -17, which disables oom-killing altogether
+for that process.
+
+But it is very difficult to suggest an order among tasks to be killed during
+Out Of Memory situation. The OOM Killer controller aids in doing that.
+
+USAGE
+-----
+
+Mount the oom controller by passing 'oom' when mounting cgroups. Echo
+a value in oom.victim file to change the order. The oom killer would kill
+all the processes in a cgroup with a higher oom.victim value before killing a
+process in a cgroup with lower oom.victim value. Among those tasks with same
+oom.victim value, the usual badness heuristics would be applied. The 
+/proc/<pid>/oom_adj still helps adjusting the oom killer score. Also having
+oom.victim = 0 would disable oom killing for the tasks in that cgroup.
+
+Note: If this is used without proper consideration, innocent processes may
+get killed unnecesarily.
+
+CPUSET constrained OOM:
+Setting oom.cpuset_constraint=1 would disable the ordering during a cpuset
+constrained oom. Setting oom.cpuset_constraint=0 would not distinguish
+between a cpuset constrained oom and system wide oom.
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 9c8d31b..6944f99 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -59,4 +59,8 @@ SUBSYS(freezer)
 SUBSYS(net_cls)
 #endif
 
+#ifdef CONFIG_CGROUP_OOM
+SUBSYS(oom)
+#endif
+
 /* */
diff --git a/include/linux/oomcontrol.h b/include/linux/oomcontrol.h
new file mode 100644
index 0000000..d4c4c72
--- /dev/null
+++ b/include/linux/oomcontrol.h
@@ -0,0 +1,19 @@
+#ifndef _LINUX_OOMCONTROL_H
+#define _LINUX_OOMCONTROL_H
+
+#ifdef CONFIG_CGROUP_OOM
+struct oom_cgroup { 
+	struct cgroup_subsys_state css;
+	/*
+	 * the order to be victimized for this group
+	 */  
+	u64 victim;
+
+	/*
+	 * disable during cpuset constrained oom
+	 */
+	bool *cpuset_constraint;
+};
+
+#endif
+#endif
diff --git a/init/Kconfig b/init/Kconfig
index 2af8382..99ed0de 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -354,6 +354,15 @@ config CGROUP_DEBUG
 
 	  Say N if unsure.
 
+config CGROUP_OOM
+	bool "Oom cgroup subsystem"
+	depends on CGROUPS
+	help
+	  This provides a cgroup subsystem which aids controlling
+	  the order in which tasks whould be killed during
+	  out of memory situations.
+	
+
 config CGROUP_NS
 	bool "Namespace cgroup subsystem"
 	depends on CGROUPS
diff --git a/mm/Makefile b/mm/Makefile
index 72255be..a5d7222 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -33,3 +33,4 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_CGROUP_OOM) += oomcontrol.o 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 40ba050..555ecb6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -26,6 +26,7 @@
 #include <linux/module.h>
 #include <linux/notifier.h>
 #include <linux/memcontrol.h>
+#include <linux/oomcontrol.h>
 #include <linux/security.h>
 
 int sysctl_panic_on_oom;
@@ -200,11 +201,15 @@ static inline enum oom_constraint 
constrained_alloc(struct zonelist *zonelist,
  * (not docbooked, we don't want this one cluttering up the manual)
  */
 static struct task_struct *select_bad_process(unsigned long *ppoints,
-						struct mem_cgroup *mem)
+			struct mem_cgroup *mem, int cpuset_constrained)
 {
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
 	struct timespec uptime;
+#ifdef CONFIG_CGROUP_OOM
+	u64 chosenvictim = 1, taskvictim;
+	bool honour_cpuset_constraint;
+#endif
 	*ppoints = 0;
 
 	do_posix_clock_monotonic_gettime(&uptime);
@@ -257,10 +262,30 @@ static struct task_struct *select_bad_process(unsigned 
long *ppoints,
 			continue;
 
 		points = badness(p, uptime.tv_sec);
+#ifdef CONFIG_CGROUP_OOM
+		taskvictim = (container_of(p->cgroups->subsys[oom_subsys_id],
+						struct oom_cgroup, css))->victim;
+		honour_cpuset_constraint = *(container_of(p->cgroups-
>subsys[oom_subsys_id],
+                                                struct oom_cgroup, css))-
>cpuset_constraint;
+
+		if (taskvictim > chosenvictim ||
+			(((taskvictim == chosenvictim) ||
+				(cpuset_constrained && honour_cpuset_constraint))
+				 && points > *ppoints) ||
+			(taskvictim && !chosen)) {
+
+			chosen = p;
+			*ppoints = points;
+			chosenvictim = taskvictim;
+
+		}
+		
+#else
 		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;
 		}
+#endif
 	} while_each_thread(g, p);
 
 	return chosen;
@@ -431,7 +456,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, 
gfp_t gfp_mask)
 
 	read_lock(&tasklist_lock);
 retry:
-	p = select_bad_process(&points, mem);
+	p = select_bad_process(&points, mem, 0); /* not cpuset constrained */
 	if (PTR_ERR(p) == -1UL)
 		goto out;
 
@@ -513,7 +538,7 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t 
gfp_mask)
 /*
  * Must be called with tasklist_lock held for read.
  */
-static void __out_of_memory(gfp_t gfp_mask, int order)
+static void __out_of_memory(gfp_t gfp_mask, int order, int 
cpuset_constrained)
 {
 	if (sysctl_oom_kill_allocating_task) {
 		oom_kill_process(current, gfp_mask, order, 0, NULL,
@@ -528,7 +553,7 @@ retry:
 		 * Rambo mode: Shoot down a process and hope it solves whatever
 		 * issues we may have.
 		 */
-		p = select_bad_process(&points, NULL);
+		p = select_bad_process(&points, NULL, cpuset_constrained);
 
 		if (PTR_ERR(p) == -1UL)
 			return;
@@ -569,7 +594,8 @@ void pagefault_out_of_memory(void)
 		panic("out of memory from page fault. panic_on_oom is selected.\n");
 
 	read_lock(&tasklist_lock);
-	__out_of_memory(0, 0); /* unknown gfp_mask and order */
+	/* unknown gfp_mask and order and not cpuset constrained */
+	__out_of_memory(0, 0, 0); 
 	read_unlock(&tasklist_lock);
 
 	/*
@@ -623,7 +649,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t 
gfp_mask, int order)
 			panic("out of memory. panic_on_oom is selected\n");
 		/* Fall-through */
 	case CONSTRAINT_CPUSET:
-		__out_of_memory(gfp_mask, order);
+		__out_of_memory(gfp_mask, order, 1);
 		break;
 	}
 
diff --git a/mm/oomcontrol.c b/mm/oomcontrol.c
new file mode 100644
index 0000000..24ee0da
--- /dev/null
+++ b/mm/oomcontrol.c
@@ -0,0 +1,138 @@
+/*
+ * kernel/cgroup_oom.c - oom handler cgroup.
+ */
+
+#include <linux/cgroup.h>
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <linux/oomcontrol.h>
+
+/*
+ * Helper to retrieve oom controller data from cgroup
+ */
+static struct oom_cgroup *oom_css_from_cgroup(struct cgroup *cgrp)
+{
+        return container_of(cgroup_subsys_state(cgrp,
+                                oom_subsys_id), struct oom_cgroup,
+                                css);
+}
+
+
+static struct cgroup_subsys_state *oom_create(struct cgroup_subsys *ss,
+						   struct cgroup *cont)
+{
+	struct oom_cgroup *oom_css = kzalloc(sizeof(*oom_css), GFP_KERNEL);
+	struct oom_cgroup *parent;
+
+	if (!oom_css)
+		return ERR_PTR(-ENOMEM);
+
+	/*
+	 * if root last/only group to be victimized
+	 * else inherit parents value
+	 */
+	if (cont->parent == NULL) {
+		oom_css->victim = 1;
+		oom_css->cpuset_constraint =
+			kzalloc(sizeof(*oom_css->cpuset_constraint), GFP_KERNEL);
+		*oom_css->cpuset_constraint = false;
+	} else {
+		parent = oom_css_from_cgroup(cont->parent);
+		oom_css->victim = parent->victim;
+		oom_css->cpuset_constraint = parent->cpuset_constraint;
+	}
+
+	return &oom_css->css;
+}
+
+static void oom_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	struct oom_cgroup *oom_css = oom_css_from_cgroup(cont);
+	if (cont->parent == NULL)
+		kfree(oom_css->cpuset_constraint);
+	kfree(cont->subsys[oom_subsys_id]);
+}
+
+static int oom_victim_write(struct cgroup *cgrp, struct cftype *cft,
+                                       u64 val)
+{
+
+        cgroup_lock();
+
+	(oom_css_from_cgroup(cgrp))->victim = val;
+
+        cgroup_unlock();
+
+        return 0;
+}
+
+static u64 oom_victim_read(struct cgroup *cgrp, struct cftype *cft)
+{
+        u64 victim = (oom_css_from_cgroup(cgrp))->victim;
+
+        return victim;
+}
+
+static int oom_cpuset_write(struct cgroup *cont, struct cftype *cft,
+                            const char *buffer)
+{
+	if (buffer[0] == '1' && buffer[1] == 0)
+		*(oom_css_from_cgroup(cont))->cpuset_constraint = true;
+	else if (buffer[0] == '0' && buffer[1] == 0)
+		*(oom_css_from_cgroup(cont))->cpuset_constraint = false;
+	else
+		return -EINVAL;
+	return 0;
+}
+
+static u64 oom_cpuset_read(struct cgroup *cgrp, struct cftype *cft)
+{
+        if (*(oom_css_from_cgroup(cgrp))->cpuset_constraint)
+		return 1;
+	else
+		return 0;
+}
+
+static struct cftype oom_cgroup_files[] = {
+	{
+		.name = "victim",
+		.read_u64 = oom_victim_read,
+		.write_u64 = oom_victim_write,
+	},
+};
+
+static struct cftype oom_cgroup_root_files[] = {
+	{
+		.name = "victim",
+		.read_u64 = oom_victim_read,
+		.write_u64 = oom_victim_write,
+	},
+	{
+		.name = "cpuset_constraint",
+		.read_u64 = oom_cpuset_read,
+		.write_string = oom_cpuset_write,
+	},
+};
+
+static int oom_populate(struct cgroup_subsys *ss,
+                                struct cgroup *cont)
+{
+	int ret;
+
+	if  (cont->parent == NULL) {
+		ret = cgroup_add_files(cont, ss, oom_cgroup_root_files,
+				ARRAY_SIZE(oom_cgroup_root_files));
+	} else {
+		ret = cgroup_add_files(cont, ss, oom_cgroup_files,
+				ARRAY_SIZE(oom_cgroup_files));
+	}
+	return ret;
+}
+
+struct cgroup_subsys oom_subsys = {
+	.name = "oom",
+	.subsys_id = oom_subsys_id,
+	.create = oom_create,
+	.destroy = oom_destroy,
+	.populate = oom_populate,
+};
