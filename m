From: Tejun Heo <theo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH cgroup/for-3.11 1/3] cgroup: fix RCU accesses to task->cgroups
Date: Fri, 21 Jun 2013 15:51:17 -0700
Message-ID: <20130621225116.GC3949__18269.9278266684$1371855097$gmane$org@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

task->cgroups is a RCU pointer pointing to struct css_set.  A task
switches to a different css_set on cgroup migration but a css_set
doesn't change once created and its pointers to cgroup_subsys_states
aren't RCU protected.

task_subsys_state[_check]() is the macro to acquire css given a task
and subsys_id pair.  It RCU-dereferences task->cgroups->subsys[] not
task->cgroups, so the RCU pointer task->cgroups ends up being
dereferenced without read_barrier_depends() after it.  It's broken.

Fix it by introducing task_css_set[_check]() which does
RCU-dereference on task->cgroups.  task_subsys_state[_check]() is
reimplemented to directly dereference ->subsys[] of the css_set
returned from task_css_set[_check]().

This removes some of sparse RCU warnings in cgroup.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Reported-by: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
Hello,

Three RCU fixe patches.  The first one fixes an actual bug.  The other
two add missing annoations so that sparse doesn't generate spurious
RCU address space warnings.

Thanks!

 include/linux/cgroup.h |   58 ++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 48 insertions(+), 10 deletions(-)

--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -638,22 +638,60 @@ static inline struct cgroup_subsys_state
 	return cgrp->subsys[subsys_id];
 }
 
-/*
- * function to get the cgroup_subsys_state which allows for extra
- * rcu_dereference_check() conditions, such as locks used during the
- * cgroup_subsys::attach() methods.
+/**
+ * task_css_set_check - obtain a task's css_set with extra access conditions
+ * @task: the task to obtain css_set for
+ * @__c: extra condition expression to be passed to rcu_dereference_check()
+ *
+ * A task's css_set is RCU protected, initialized and exited while holding
+ * task_lock(), and can only be modified while holding both cgroup_mutex
+ * and task_lock() while the task is alive.  This macro verifies that the
+ * caller is inside proper critical section and returns @task's css_set.
+ *
+ * The caller can also specify additional allowed conditions via @__c, such
+ * as locks used during the cgroup_subsys::attach() methods.
  */
 #ifdef CONFIG_PROVE_RCU
 extern struct mutex cgroup_mutex;
-#define task_subsys_state_check(task, subsys_id, __c)			\
-	rcu_dereference_check((task)->cgroups->subsys[(subsys_id)],	\
-			      lockdep_is_held(&(task)->alloc_lock) ||	\
-			      lockdep_is_held(&cgroup_mutex) || (__c))
+#define task_css_set_check(task, __c)					\
+	rcu_dereference_check((task)->cgroups,				\
+		lockdep_is_held(&(task)->alloc_lock) ||			\
+		lockdep_is_held(&cgroup_mutex) || (__c))
 #else
-#define task_subsys_state_check(task, subsys_id, __c)			\
-	rcu_dereference((task)->cgroups->subsys[(subsys_id)])
+#define task_css_set_check(task, __c)					\
+	rcu_dereference_raw((task)->cgroups
 #endif
 
+/**
+ * task_subsys_state_check - obtain css for (task, subsys) w/ extra access conds
+ * @task: the target task
+ * @subsys_id: the target subsystem ID
+ * @__c: extra condition expression to be passed to rcu_dereference_check()
+ *
+ * Return the cgroup_subsys_state for the (@task, @subsys_id) pair.  The
+ * synchronization rules are the same as task_css_set_check().
+ */
+#define task_subsys_state_check(task, subsys_id, __c)			\
+	task_css_set_check((task), (__c))->subsys[(subsys_id)]
+
+/**
+ * task_css_set - obtain a task's css_set
+ * @task: the task to obtain css_set for
+ *
+ * See task_css_set_check().
+ */
+static inline struct css_set *task_css_set(struct task_struct *task)
+{
+	return task_css_set_check(task, false);
+}
+
+/**
+ * task_subsys_state - obtain css for (task, subsys)
+ * @task: the target task
+ * @subsys_id: the target subsystem ID
+ *
+ * See task_subsys_state_check().
+ */
 static inline struct cgroup_subsys_state *
 task_subsys_state(struct task_struct *task, int subsys_id)
 {
