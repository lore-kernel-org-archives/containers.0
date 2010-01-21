From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: [RFC][PATCH] sched: Fix fork vs hotplug vs cpuset namespaces
Date: Thu, 21 Jan 2010 21:36:30 +0100
Message-ID: <1264106190.4283.1314.camel__34485.7868193232$1264106325$gmane$org@laptop>
References: <1263852243.4745.363.camel@Mercier.safe.ca>
	<20100119150931.GA7708@us.ibm.com>
	<1263916851.4745.386.camel@Mercier.safe.ca>
	<20100121171338.GA16904@us.ibm.com> <1264095325.4283.1198.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1264095325.4283.1198.camel@laptop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2010-01-21 at 18:35 +0100, Peter Zijlstra wrote:
> On Thu, 2010-01-21 at 11:13 -0600, Serge E. Hallyn wrote:
> > The culprit is e2912009fb7b715728311b0d8fe327a1432b3f79
> >     sched: Ensure set_task_cpu() is never called on blocked tasks
> > 
> > If you mount both the ns and cpuset cgroups with this patch applied,
> > then doing clone with CLONE_NEWPID, CLONE_NEWNET, etc, you get the
> > hang.  The hang is actually hard enough that alt-sysrq isn't helpful :)
> > Still trying to figure out what is going on - Peter, any ideas offhand?

> Hmm, I have an idea.. does it really need the ns cgroup stuff?

It appears so, what is happening is that:

copy_process()

  sched_fork()
    child->state = TASK_WAKING; /* waiting for wake_up_new_task() */

  if (current->nsproxy != p->nsproxy)
     ns_cgroup_clone()
       cgroup_clone()
         mutex_lock(inode->i_mutex)
         mutex_lock(cgroup_mutex)
         cgroup_attach_task()
	   ss->can_attach()
           ss->attach() [ -> cpuset_attach() ]
             cpuset_attach_task()
               set_cpus_allowed_ptr();
                 while (child->state == TASK_WAKING)
                   cpu_relax();


which will pretty much mess up your system. However sysrq not working
shouldn't be amongst that and s390 working is also unexplained.

While that spin on TASK_WAKING is new, the behaviour was dubious because
when we stick the new child into the tasklist we copy the
parent->cpus_allowed back into the child:


  	/* Need tasklist lock for parent etc handling! */
	write_lock_irq(&tasklist_lock);

	/*
	 * The task hasn't been attached yet, so its cpus_allowed mask will
	 * not be changed, nor will its assigned CPU.
	 *
	 * The cpus_allowed mask of the parent may have changed after it was
	 * copied first time - so re-copy it here, then check the child's CPU
	 * to ensure it is on a valid CPU (and if not, just force it back to
	 * parent's CPU). This avoids alot of nasty races.
	 */
	p->cpus_allowed = current->cpus_allowed;
	p->rt.nr_cpus_allowed = current->rt.nr_cpus_allowed;
	if (unlikely(!cpu_isset(task_cpu(p), p->cpus_allowed) ||
			!cpu_online(task_cpu(p))))
		set_task_cpu(p, smp_processor_id());


which mostly stems from 2005.

Now, I'm not quite sure how to fix this to be honest.. calling
->can_attach and ->attach on half finished tasks seems somewhat ill
defined.

So while pondering this I think I might have found another bug which
needs to get closed, hotplug vs fork might end up removing the target
cpu between this second ->cpus_allowed copy in copy_process() and
wake_up_new_task(), so we need to move the fork migration step anyway.

So I think the below ought to cure at least the immediate problem,
leaving the question if cgroups really want to call ->attach that early.

Utterly untested.... never even seen a compiler but here goes:

---
Subject: sched: Fix fork vs hotplug vs cpuset namespaces
From: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Date: Thu Jan 21 21:04:57 CET 2010

There are a number of issues:

1) TASK_WAKING vs cgroup_clone (cpusets)

copy_process():

  sched_fork()
    child->state = TASK_WAKING; /* waiting for wake_up_new_task() */

  if (current->nsproxy != p->nsproxy)
     ns_cgroup_clone()
       cgroup_clone()
         mutex_lock(inode->i_mutex)
         mutex_lock(cgroup_mutex)
         cgroup_attach_task()
	   ss->can_attach()
           ss->attach() [ -> cpuset_attach() ]
             cpuset_attach_task()
               set_cpus_allowed_ptr();
                 while (child->state == TASK_WAKING)
                   cpu_relax();

will deadlock the system.


2) cgroup_clone (cpusets) vs copy_process

So even if the above would work we still have:

copy_process():

  if (current->nsproxy != p->nsproxy)
     ns_cgroup_clone()
       cgroup_clone()
         mutex_lock(inode->i_mutex)
         mutex_lock(cgroup_mutex)
         cgroup_attach_task()
	   ss->can_attach()
           ss->attach() [ -> cpuset_attach() ]
             cpuset_attach_task()
               set_cpus_allowed_ptr();
  
  ...

  p->cpus_allowed = current->cpus_allowed

over-writing the modified cpus_allowed.


3) fork() vs hotplug

  if we unplug the child's cpu after the sanity check when the child
  gets attached to the task_list but before wake_up_new_task() shit
  will meet with fan.

Solve all these issues by moving fork cpu selection into
wake_up_new_task().

Reported-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Almost-Signed-off-by: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
---
 kernel/fork.c  |   15 ---------------
 kernel/sched.c |   39 +++++++++++++++++++++++++++------------
 2 files changed, 27 insertions(+), 27 deletions(-)

Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -1241,21 +1241,6 @@ static struct task_struct *copy_process(
 	/* Need tasklist lock for parent etc handling! */
 	write_lock_irq(&tasklist_lock);
 
-	/*
-	 * The task hasn't been attached yet, so its cpus_allowed mask will
-	 * not be changed, nor will its assigned CPU.
-	 *
-	 * The cpus_allowed mask of the parent may have changed after it was
-	 * copied first time - so re-copy it here, then check the child's CPU
-	 * to ensure it is on a valid CPU (and if not, just force it back to
-	 * parent's CPU). This avoids alot of nasty races.
-	 */
-	p->cpus_allowed = current->cpus_allowed;
-	p->rt.nr_cpus_allowed = current->rt.nr_cpus_allowed;
-	if (unlikely(!cpu_isset(task_cpu(p), p->cpus_allowed) ||
-			!cpu_online(task_cpu(p))))
-		set_task_cpu(p, smp_processor_id());
-
 	/* CLONE_PARENT re-uses the old parent */
 	if (clone_flags & (CLONE_PARENT|CLONE_THREAD)) {
 		p->real_parent = current->real_parent;
Index: linux-2.6/kernel/sched.c
===================================================================
--- linux-2.6.orig/kernel/sched.c
+++ linux-2.6/kernel/sched.c
@@ -2300,14 +2300,12 @@ static int select_fallback_rq(int cpu, s
 }
 
 /*
- * Called from:
+ * Gets called from 3 sites (exec, fork, wakeup), since it is called without
+ * holding rq->lock we need to ensure ->cpus_allowed is stable, this is done
+ * by:
  *
- *  - fork, @p is stable because it isn't on the tasklist yet
- *
- *  - exec, @p is unstable, retry loop
- *
- *  - wake-up, we serialize ->cpus_allowed against TASK_WAKING so
- *             we should be good.
+ *  exec:           is unstable, retry loop
+ *  fork & wake-up: serialize ->cpus_allowed against TASK_WAKING
  */
 static inline
 int select_task_rq(struct task_struct *p, int sd_flags, int wake_flags)
@@ -2600,9 +2598,6 @@ void sched_fork(struct task_struct *p, i
 	if (p->sched_class->task_fork)
 		p->sched_class->task_fork(p);
 
-#ifdef CONFIG_SMP
-	cpu = select_task_rq(p, SD_BALANCE_FORK, 0);
-#endif
 	set_task_cpu(p, cpu);
 
 #if defined(CONFIG_SCHEDSTATS) || defined(CONFIG_TASK_DELAY_ACCT)
@@ -2632,6 +2627,21 @@ void wake_up_new_task(struct task_struct
 {
 	unsigned long flags;
 	struct rq *rq;
+	int cpu = get_cpu;
+
+#ifdef CONFIG_SMP
+	/*
+	 * Fork balancing, do it here and not earlier because:
+	 *  - cpus_allowed can change in the fork path
+	 *  - any previously selected cpu might disappear through hotplug
+	 *
+	 * We still have TASK_WAKING but PF_STARTING is gone now, meaning
+	 * ->cpus_allowed is stable, we have preemption disabled, meaning
+	 * cpu_online_mask is stable.
+	 */
+	cpu = select_task_rq(p, SD_BALANCE_FORK, 0);
+	set_task_cpu(p, cpu);
+#endif
 
 	rq = task_rq_lock(p, &flags);
 	BUG_ON(p->state != TASK_WAKING);
@@ -2645,6 +2655,7 @@ void wake_up_new_task(struct task_struct
 		p->sched_class->task_woken(rq, p);
 #endif
 	task_rq_unlock(rq, &flags);
+	put_cpu();
 }
 
 #ifdef CONFIG_PREEMPT_NOTIFIERS
@@ -5316,14 +5327,18 @@ int set_cpus_allowed_ptr(struct task_str
 	 * the ->cpus_allowed mask from under waking tasks, which would be
 	 * possible when we change rq->lock in ttwu(), so synchronize against
 	 * TASK_WAKING to avoid that.
+	 *
+	 * Make an exception for freshly cloned tasks, since cpuset namespaces
+	 * might move the task about, we have to validate the target in
+	 * wake_up_new_task() anyway since the cpu might have gone away.
 	 */
 again:
-	while (p->state == TASK_WAKING)
+	while (p->state == TASK_WAKING && !(p->flags & PF_STARTING))
 		cpu_relax();
 
 	rq = task_rq_lock(p, &flags);
 
-	if (p->state == TASK_WAKING) {
+	if (p->state == TASK_WAKING && !(p->flags & PF_STARTING)) {
 		task_rq_unlock(rq, &flags);
 		goto again;
 	}
