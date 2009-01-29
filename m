From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Thu, 29 Jan 2009 21:18:15 +0530
Message-ID: <200901292118.18237.knikanth__1577.79425285316$1233244537$gmane$org@suse.de>
References: <200901211638.23101.knikanth@suse.de>
	<200901232026.16778.knikanth@suse.de>
	<6599ad830901271700u43e472dk742992334e456a13@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830901271700u43e472dk742992334e456a13-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve =?iso-8859-1?q?Hj=F8nnev=E5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wednesday 28 January 2009 06:30:42 Paul Menage wrote:
> Hi Nikanth,
>
> On Fri, Jan 23, 2009 at 6:56 AM, Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org> 
wrote:
> > From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
> >
> > Cgroup based OOM killer controller
> >
> > Signed-off-by: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
> >
> > ---
> >
> > This is a container group based approach to override the oom killer
> > selection without losing all the benefits of the current oom killer
> > heuristics and oom_adj interface.
>
> The basic functionality looks useful.
>

Thanks.

> But before we add an OOM subsystem and commit to an API that has to be
> supported forever, I think it would be good to have an overall design
> for what kinds of things we want to be able to do regarding cgroups
> and OOM killing.
>
> Specifying a per-cgroup priority is part of the solution, and is
> useful for simple cases. Some kind of userspace notification is also
> useful.
>

Yes, very much.

> The notification system that David/Ying posted has worked pretty well
> for us at Google - it's allowed us to use cpusets and fake numa to
> provide hard memory controls and guarantees for jobs, while avoiding
> having jobs getting killed when they expand faster than we expect. But
> we also acknowledge that it's a bit of a hack, and it would be nice to
> come up with something more generally acceptable for a real
> submission.
>
> > It adds a tunable oom.victim to the oom cgroup. The oom killer will kill
> > the process using the usual badness value but only within the cgroup with
> > the maximum value for oom.victim before killing any process from a cgroup
> > with a lesser oom.victim number. Oom killing could be disabled by setting
> > oom.victim=0.
>
> "priority" might be a better term than "victim".
>

Agreed.

> > CPUSET constrained OOM:
> > Also the tunable oom.cpuset_constrained when enabled, would disable the
> > ordering imposed by this controller for cpuset constrained OOMs.
> >
> > diff --git a/Documentation/cgroups/oom.txt
> > b/Documentation/cgroups/oom.txt new file mode 100644
> > index 0000000..772fb41
> > --- /dev/null
> > +++ b/Documentation/cgroups/oom.txt
> > @@ -0,0 +1,34 @@
> > +OOM Killer controller
> > +--- ------ ----------
> > +
> > +The OOM killer kills the process based on a set of heuristics such that
> > only
>
> Might be worth adding "theoretically" in this sentence :-)
>
> >        do_posix_clock_monotonic_gettime(&uptime);
> > @@ -257,10 +262,30 @@ static struct task_struct
> > *select_bad_process(unsigned long *ppoints,
> >                        continue;
> >
> >                points = badness(p, uptime.tv_sec);
> > +#ifdef CONFIG_CGROUP_OOM
> > +               taskvictim =
> > (container_of(p->cgroups->subsys[oom_subsys_id], +                       
> >                        struct oom_cgroup, css))->victim;
>
> Firstly, this ought to be using the task_subsys_state() function to
> ensure the appropriate rcu_dereference() calls.
>

Ok.

> Secondly, is it safe? I'm not sure if we're in an RCU section in this
> case, and we certainly haven't called task_lock(p) or cgroup_lock().
> You should surround this with rcu_read_lock()/rcu_read_unlock().
>

Ok.

> And thirdly, it would be better to move the #ifdef to the header file,
> and provide dummy functions that return 0 for the kill priority if
> CONFIG_CGROUP_OOM isn't defined.
>

Ok. As this patch uses 0 to disable oom_killing completely, the dummy function 
should return 1 instead of zero. It should be documented more clearly.

> > +               honour_cpuset_constraint = *(container_of(p->cgroups-
> >
> >>subsys[oom_subsys_id],
> >
> > +                                                struct oom_cgroup,
> > css))-
> >
> >>cpuset_constraint;
>
> I think that putting this kind of inter-subsystem dependency in is a
> bad idea. If you want to control whether the OOM killer treats cpusets
> specially, perhaps that flag should be put in cpusets?
>

But then won't it add a special variable in cpusets for oom-controller?

> > +
> > +               if (taskvictim > chosenvictim ||
> > +                       (((taskvictim == chosenvictim) ||
> > +                               (cpuset_constrained &&
> > honour_cpuset_constraint)) +                                && points >
> > *ppoints) ||
> > +                       (taskvictim && !chosen)) {
>
> This could do with more comments or maybe breaking up into simpler
> conditions.
>

Ok.

> > +       if (cont->parent == NULL) {
> > +               oom_css->victim = 1;
>
> Any reason to default to 1 rather than 0?
>

0 disables oom killing completely.

> > +               oom_css->cpuset_constraint =
> > +                       kzalloc(sizeof(*oom_css->cpuset_constraint),
> > GFP_KERNEL); +               *oom_css->cpuset_constraint = false;
> > +       } else {
> > +               parent = oom_css_from_cgroup(cont->parent);
> > +               oom_css->victim = parent->victim;
> > +               oom_css->cpuset_constraint = parent->cpuset_constraint;
> > +       }
>
> So there's a single cpuset_constraint shared by all cgroups? Isn't
> that just a global variable then?
>

Yes, it should be a global variable.

> > +
> > +static int oom_victim_write(struct cgroup *cgrp, struct cftype *cft,
> > +                                       u64 val)
> > +{
> > +
> > +        cgroup_lock();
>
> This isn't really doing much, since you don't synchronize on the read
> side (either the file handler or in the OOM killer itself). It might
> be better to just make the value an atomic_t and avoid taking
> cgroup_lock() here.
>

Yes.

> Should we enforce any constraint that a cgroup can never have a lower
> kill priority than its parent? Or a separate "min child priority"
> value, or just make the cgroup's priority be the max of any in its
> path to the root? That would allow you to safely delegate OOM priority
> control to sub cgroups while still controlling relative priorities for
> each subtree.
>

Setting priority to be the maximum of any in its path seems better to me. It 
should make it easier to handle a group of cgroups.

> > +static int oom_cpuset_write(struct cgroup *cont, struct cftype *cft,
> > +                            const char *buffer)
> > +{
> > +       if (buffer[0] == '1' && buffer[1] == 0)
> > +               *(oom_css_from_cgroup(cont))->cpuset_constraint = true;
> > +       else if (buffer[0] == '0' && buffer[1] == 0)
> > +               *(oom_css_from_cgroup(cont))->cpuset_constraint = false;
> > +       else
> > +               return -EINVAL;
> > +       return 0;
> > +}
>
> This can be a u64 write handler that just complains if its input isn't 0 or
> 1.
>

Yes, that would be cleaner.

> > +static struct cftype oom_cgroup_files[] = {
> > +       {
> > +               .name = "victim",
> > +               .read_u64 = oom_victim_read,
> > +               .write_u64 = oom_victim_write,
> > +       },
> > +};
> > +
> > +static struct cftype oom_cgroup_root_files[] = {
> > +       {
> > +               .name = "victim",
> > +               .read_u64 = oom_victim_read,
> > +               .write_u64 = oom_victim_write,
> > +       },
>
> Don't duplicate here - just have disjoint sets of files, and call
> cgroup_add_files(oom_cgroup_root_files) in addition to the regular
> files if it's the root. (Although as I mentioned above, I don't really
> think this is the right place for the cpuset_constraint file)
>

Ok.

Thanks for the detailed review. I have attached the patch with your comments 
incorporated. There is a read-only oom.effective_priority added which is 
computed as the maximum oom.priority along its path.

Thanks
Nikanth

From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>

Cgroup based OOM killer controller

Signed-off-by: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>

---

This is a container group based approach to override the oom killer selection 
without losing all the benefits of the current oom killer heuristics and 
oom_adj interface. This controller helps in specifying a strict order between 
tasks that can be killed during a oom.

It adds a tunable oom.priority to the oom cgroup. The oom killer will kill the 
process using the usual badness value but only within the cgroup with the 
maximum value for oom.effective_priority before killing any process from a 
cgroup with a lesser oom.effective_priority number. The oom.effective_priority 
is calculated as the maximum oom.priority along its path. Oom killing could be 
disabled for a cgroup by setting oom.effective_priority=0.

diff --git a/Documentation/cgroups/oom.txt b/Documentation/cgroups/oom.txt
new file mode 100644
index 0000000..5ef34db
--- /dev/null
+++ b/Documentation/cgroups/oom.txt
@@ -0,0 +1,36 @@
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
+a value in oom.priority file to change the order. The oom.effective_priority
+is calculated as the highest oom.priority along its path. The oom killer 
would
+kill all the processes in a cgroup with a higher oom.effective_priority 
before
+killing a process in a cgroup with lower oom.effective_priority value. Among
+those tasks with same oom.effective_priority value, the usual badness
+heuristics would be applied. The /proc/<pid>/oom_adj still helps adjusting 
the
+oom killer score. Also having oom.effective_priority = 0 would disable oom
+killing for the tasks in that cgroup.
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
index 0000000..8072d7a
--- /dev/null
+++ b/include/linux/oomcontrol.h
@@ -0,0 +1,35 @@
+#ifndef _LINUX_OOMCONTROL_H
+#define _LINUX_OOMCONTROL_H
+
+#ifdef CONFIG_CGROUP_OOM
+
+struct oom_cgroup { 
+	struct cgroup_subsys_state css;
+
+	/*
+	 * the order to be victimized for this group
+	 */  
+	atomic_t priority;
+
+	/*
+	 * the maximum priority along the path from root
+	 */  
+	atomic_t effective_priority;
+
+};
+
+/*
+ * disable during cpuset constrained oom
+ */
+extern atomic_t honour_cpuset_constraint;
+
+u64 task_oom_priority(struct task_struct *p);
+
+#else
+
+#define task_oom_priority(p) (1)
+
+static atomic_t honour_cpuset_constraint; /* unused */
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
index 40ba050..6851da3 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -26,6 +26,7 @@
 #include <linux/module.h>
 #include <linux/notifier.h>
 #include <linux/memcontrol.h>
+#include <linux/oomcontrol.h>
 #include <linux/security.h>
 
 int sysctl_panic_on_oom;
@@ -200,11 +201,13 @@ static inline enum oom_constraint 
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
+	u64 chosenpriority = 1, taskpriority;
+
 	*ppoints = 0;
 
 	do_posix_clock_monotonic_gettime(&uptime);
@@ -257,10 +260,35 @@ static struct task_struct *select_bad_process(unsigned 
long *ppoints,
 			continue;
 
 		points = badness(p, uptime.tv_sec);
-		if (points > *ppoints || !chosen) {
+
+		taskpriority = task_oom_priority(p);
+
+		/*
+		 * select this task if
+		 * 1. It has higher oom.priority than the previously selected
+		 * task, or
+		 * 2. It has the same priority as previously selected task but
+		 * higher badness score, or
+		 * 3. If this is the first task to be considered and it is not
+		 * protected from oom killer by setting priority as zero, or
+		 * 4. If this is a cpuset constrained oom and
+		 * honour_cpuset_constraint is set
+		 */
+		if (taskpriority > chosenpriority ||
+
+			(((taskpriority == chosenpriority) ||
+			  (cpuset_constrained &&
+				atomic_read(&honour_cpuset_constraint)))
+			 && points > *ppoints) ||
+
+			(taskpriority && !chosen)) {
+
 			chosen = p;
 			*ppoints = points;
+			chosenpriority = taskpriority;
+
 		}
+		
 	} while_each_thread(g, p);
 
 	return chosen;
@@ -431,7 +459,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, 
gfp_t gfp_mask)
 
 	read_lock(&tasklist_lock);
 retry:
-	p = select_bad_process(&points, mem);
+	p = select_bad_process(&points, mem, 0); /* not cpuset constrained */
 	if (PTR_ERR(p) == -1UL)
 		goto out;
 
@@ -513,7 +541,7 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t 
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
@@ -528,7 +556,7 @@ retry:
 		 * Rambo mode: Shoot down a process and hope it solves whatever
 		 * issues we may have.
 		 */
-		p = select_bad_process(&points, NULL);
+		p = select_bad_process(&points, NULL, cpuset_constrained);
 
 		if (PTR_ERR(p) == -1UL)
 			return;
@@ -569,7 +597,8 @@ void pagefault_out_of_memory(void)
 		panic("out of memory from page fault. panic_on_oom is selected.\n");
 
 	read_lock(&tasklist_lock);
-	__out_of_memory(0, 0); /* unknown gfp_mask and order */
+	/* unknown gfp_mask and order and not cpuset constrained */
+	__out_of_memory(0, 0, 0); 
 	read_unlock(&tasklist_lock);
 
 	/*
@@ -623,7 +652,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t 
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
index 0000000..d572b1f
--- /dev/null
+++ b/mm/oomcontrol.c
@@ -0,0 +1,294 @@
+/*
+ * kernel/cgroup_oom.c - oom handler cgroup.
+ */
+
+#include <linux/cgroup.h>
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <linux/oomcontrol.h>
+#include <asm/atomic.h>
+
+atomic_t honour_cpuset_constraint;
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
+u64 task_oom_priority(struct task_struct *p)
+{
+	rcu_read_lock();
+	return atomic_read(&(container_of(task_subsys_state(p,oom_subsys_id),
+				struct oom_cgroup, css))->effective_priority);
+	rcu_read_unlock();
+}
+
+static struct cgroup_subsys_state *oom_create(struct cgroup_subsys *ss,
+						   struct cgroup *cont)
+{
+	struct oom_cgroup *oom_css = kzalloc(sizeof(*oom_css), GFP_KERNEL);
+	struct oom_cgroup *parent;
+	u64 parent_priority, parent_effective_priority;
+
+	if (!oom_css)
+		return ERR_PTR(-ENOMEM);
+
+	/*
+	 * if root last/only group to be victimized
+	 * else inherit parents value
+	 */
+	if (cont->parent == NULL) {
+		atomic_set(&oom_css->priority, 1);
+		atomic_set(&oom_css->effective_priority, 1);
+		atomic_set(&honour_cpuset_constraint, 0);
+	} else {
+		parent = oom_css_from_cgroup(cont->parent);
+		parent_priority = atomic_read(&parent->priority);
+		parent_effective_priority = 
+			atomic_read(&parent->effective_priority);
+		atomic_set(&oom_css->priority, parent_priority);
+		atomic_set(&oom_css->effective_priority,
+					parent_effective_priority);
+	}
+
+	return &oom_css->css;
+}
+
+static void oom_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	kfree(cont->subsys[oom_subsys_id]);
+}
+
+static void increase_effective_priority(struct cgroup *cgrp, u64 val)
+{
+	struct cgroup *curr;
+	struct oom_cgroup *oom_css;
+
+	atomic_set( &(oom_css_from_cgroup(cgrp))->effective_priority, val);
+
+	mutex_lock(&oom_subsys.hierarchy_mutex);
+
+	/*
+	 * DFS
+	 */
+	if (!list_empty(&cgrp->children))
+		curr = list_first_entry(&cgrp->children,
+					struct cgroup, sibling);
+	else
+		goto out;
+
+visit_children:
+	oom_css = oom_css_from_cgroup(curr);
+	if (atomic_read(&oom_css->effective_priority) < val)
+		atomic_set(&oom_css->effective_priority, val);
+
+	if (!list_empty(&curr->children)) {
+		curr = list_first_entry(&curr->children,
+					struct cgroup, sibling);
+		goto visit_children;
+	} else {
+visit_siblings:
+		if (curr == 0 || cgrp == curr) goto out;
+
+		if (curr->sibling.next != &curr->parent->children) {
+			curr = list_entry(curr->sibling.next,
+						struct cgroup, sibling);
+			goto visit_children;
+		} else {
+			curr = curr->parent;
+			goto visit_siblings;
+		}
+	}
+out:
+	mutex_unlock(&oom_subsys.hierarchy_mutex);
+
+}
+
+static void decrease_effective_priority(struct cgroup *cgrp, u64 val)
+{
+	struct cgroup *curr;
+	u64 priority, effective_priority;
+
+
+	effective_priority = val;
+
+	atomic_set(&oom_css_from_cgroup(cgrp)->effective_priority,
+							effective_priority);
+
+	mutex_lock(&oom_subsys.hierarchy_mutex);
+
+	/*
+	 * DFS
+	 */
+	if (!list_empty(&cgrp->children))
+		curr = list_first_entry(&cgrp->children,
+					struct cgroup, sibling);
+	else
+		goto out;
+
+visit_children:
+	priority = atomic_read(&oom_css_from_cgroup(curr)->priority);
+
+	if (priority > effective_priority) {
+		atomic_set(&oom_css_from_cgroup(curr)->
+					effective_priority, priority);
+		effective_priority = priority;
+	} else 
+		atomic_set(&oom_css_from_cgroup(curr)->
+				effective_priority,effective_priority);
+
+	if (!list_empty(&curr->children)) {
+		curr = list_first_entry(&curr->children,
+						struct cgroup, sibling);
+		goto visit_children;
+	} else {
+visit_siblings:
+		if (curr == 0 || cgrp == curr)
+			goto out;
+
+		if (curr->parent)
+       	        	effective_priority =
+			  atomic_read(&oom_css_from_cgroup(
+			   curr->parent)->effective_priority);
+		else
+        		effective_priority = val;
+
+		if (curr->sibling.next != &curr->parent->children) {
+			curr = list_entry(curr->sibling.next,
+						struct cgroup, sibling);
+			goto visit_children;
+		} else {
+			curr = curr->parent;
+			goto visit_siblings;
+		}
+	}
+out:
+				
+		mutex_unlock(&oom_subsys.hierarchy_mutex);
+
+}
+
+static int oom_priority_write(struct cgroup *cgrp, struct cftype *cft,
+                                       u64 val)
+{
+	u64 effective_priority;
+	u64 old_priority;
+	u64 parent_effective_priority = 0;
+
+	old_priority = atomic_read(&(oom_css_from_cgroup(cgrp))->priority);
+	atomic_set(&(oom_css_from_cgroup(cgrp))->priority, val);
+
+	effective_priority = atomic_read(
+			&(oom_css_from_cgroup(cgrp))->effective_priority);
+
+	/*
+	 * propagate new effective_priority to sub cgroups
+	 */
+	if (val > effective_priority)
+		increase_effective_priority(cgrp, val);
+	else if (effective_priority == old_priority &&
+						val < effective_priority) {
+		struct oom_cgroup *oom_css = NULL;
+		if (cgrp->parent)
+			oom_css = oom_css_from_cgroup(cgrp->parent);
+		else
+			oom_css = oom_css_from_cgroup(cgrp);
+
+		if (cgrp->parent)
+			parent_effective_priority =
+				atomic_read(&oom_css->effective_priority);
+			
+		if (cgrp->parent == NULL || 
+				parent_effective_priority < effective_priority) {
+			/*
+			 * set effective_priority to max of parents effective and
+			 * new priority
+			 */
+			if (cgrp->parent == NULL || effective_priority < val
+				 	|| parent_effective_priority < val)
+				effective_priority = val;
+			else
+				effective_priority = parent_effective_priority;
+
+			decrease_effective_priority(cgrp, effective_priority);
+
+		} 
+	}
+        return 0;
+}
+
+static u64 oom_effective_priority_read(struct cgroup *cgrp, struct cftype 
*cft)
+{
+        u64 priority = atomic_read(&(oom_css_from_cgroup(cgrp))-
>effective_priority);
+
+        return priority;
+}
+
+static u64 oom_priority_read(struct cgroup *cgrp, struct cftype *cft)
+{
+        u64 priority = atomic_read(&(oom_css_from_cgroup(cgrp))->priority);
+
+        return priority;
+}
+
+static int oom_cpuset_write(struct cgroup *cgrp, struct cftype *cft,
+					u64 val)
+{
+	if (val > 1)
+		return -EINVAL;
+	atomic_set(&honour_cpuset_constraint, val);
+	return 0;
+}
+
+static u64 oom_cpuset_read(struct cgroup *cgrp, struct cftype *cft)
+{
+        return atomic_read(&honour_cpuset_constraint);
+}
+
+static struct cftype oom_cgroup_files[] = {
+	{
+		.name = "priority",
+		.read_u64 = oom_priority_read,
+		.write_u64 = oom_priority_write,
+	},
+	{
+		.name = "effective_priority",
+		.read_u64 = oom_effective_priority_read,
+	},
+};
+
+static struct cftype oom_cgroup_root_only_files[] = {
+	{
+		.name = "cpuset_constraint",
+		.read_u64 = oom_cpuset_read,
+		.write_u64 = oom_cpuset_write,
+	},
+};
+
+static int oom_populate(struct cgroup_subsys *ss,
+                                struct cgroup *cont)
+{
+	int ret;
+
+	ret = cgroup_add_files(cont, ss, oom_cgroup_files,
+				ARRAY_SIZE(oom_cgroup_files));
+	if (!ret && cont->parent == NULL) {
+		ret = cgroup_add_files(cont, ss, oom_cgroup_root_only_files,
+				ARRAY_SIZE(oom_cgroup_root_only_files));
+	}
+
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
