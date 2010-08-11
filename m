From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [PATCH v5 2/3] cgroups: add can_attach callback for checking all
	threads in a group
Date: Wed, 11 Aug 2010 01:48:14 -0400
Message-ID: <20100811054814.GC8743@ghc17.ghc.andrew.cmu.edu>
References: <20100730235649.GA22644@ghc17.ghc.andrew.cmu.edu>
	<20100811054604.GA8743@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: attachment; filename="cgroup-threadgroup-callback.patch"
In-Reply-To: <20100811054604.GA8743-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Add cgroup wrapper for safely calling can_attach on all threads in a threadgroup

From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

This patch adds a function cgroup_can_attach_per_thread which handles iterating
over each thread in a threadgroup safely with respect to the invariants that
will be used in cgroup_attach_proc. Also, subsystems whose can_attach calls
require per-thread validation are modified to use the per_thread wrapper to
avoid duplicating cgroup-internal code.

This is a pre-patch for cgroup-procs-writable.patch.

Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
---
 include/linux/cgroup.h  |   12 ++++++++++++
 kernel/cgroup.c         |   35 +++++++++++++++++++++++++++++++++++
 kernel/cgroup_freezer.c |   27 ++++++++++++---------------
 kernel/cpuset.c         |   20 +++++++-------------
 kernel/ns_cgroup.c      |   27 +++++++++++++--------------
 kernel/sched.c          |   21 ++++++---------------
 6 files changed, 85 insertions(+), 57 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index e3d00fd..f040d66 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -580,6 +580,18 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan);
 int cgroup_attach_task(struct cgroup *, struct task_struct *);
 
 /*
+ * For use in subsystems whose can_attach functions need to run an operation
+ * on every task in the threadgroup. Calls the given callback once if the
+ * 'threadgroup' flag is false, or once per thread in the group if true.
+ * The callback should return 0/-ERR; this will return 0/-ERR.
+ * The callback will run within an rcu_read section, so must not sleep.
+ */
+int cgroup_can_attach_per_thread(struct cgroup *cgrp, struct task_struct *task,
+				 int (*cb)(struct cgroup *cgrp,
+					   struct task_struct *task),
+				 bool threadgroup);
+
+/*
  * CSS ID is ID for cgroup_subsys_state structs under subsys. This only works
  * if cgroup_subsys.use_id == true. It can be used for looking up and scanning.
  * CSS ID is assigned at cgroup allocation (create) automatically
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f91d7dd..e8b8f71 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1688,6 +1688,41 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 }
 EXPORT_SYMBOL_GPL(cgroup_path);
 
+int cgroup_can_attach_per_thread(struct cgroup *cgrp, struct task_struct *task,
+				 int (*cb)(struct cgroup *cgrp,
+					   struct task_struct *task),
+				 bool threadgroup)
+{
+	/* Start by running on the leader, in all cases. */
+	int ret = cb(cgrp, task);
+	if (ret < 0)
+		return ret;
+
+	if (threadgroup) {
+		/* Run on each task in the threadgroup. */
+		struct task_struct *c;
+		rcu_read_lock();
+		/*
+		 * It is necessary for the given task to still be the leader
+		 * to safely traverse thread_group. See cgroup_attach_proc.
+		 */
+		if (!thread_group_leader(task)) {
+			rcu_read_unlock();
+			return -EAGAIN;
+		}
+		list_for_each_entry_rcu(c, &task->thread_group, thread_group) {
+			ret = cb(cgrp, c);
+			if (ret < 0) {
+				rcu_read_unlock();
+				return ret;
+			}
+		}
+		rcu_read_unlock();
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(cgroup_can_attach_per_thread);
+
 /**
  * cgroup_attach_task - attach task 'tsk' to cgroup 'cgrp'
  * @cgrp: the cgroup the task is attaching to
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index ce71ed5..677b24e 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -161,6 +161,13 @@ static bool is_task_frozen_enough(struct task_struct *task)
 		(task_is_stopped_or_traced(task) && freezing(task));
 }
 
+static int freezer_can_attach_cb(struct cgroup *cgrp, struct task_struct *task)
+{
+	if (is_task_frozen_enough(task))
+		return -EBUSY;
+	return 0;
+}
+
 /*
  * The call to cgroup_lock() in the freezer.state write method prevents
  * a write to that file racing against an attach, and hence the
@@ -171,6 +178,7 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 			      struct task_struct *task, bool threadgroup)
 {
 	struct freezer *freezer;
+	int ret;
 
 	/*
 	 * Anything frozen can't move or be moved to/from.
@@ -179,26 +187,15 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 	 * frozen, so it's sufficient to check the latter condition.
 	 */
 
-	if (is_task_frozen_enough(task))
-		return -EBUSY;
+	ret = cgroup_can_attach_per_thread(new_cgroup, task,
+					   freezer_can_attach_cb, threadgroup);
+	if (ret < 0)
+		return ret;
 
 	freezer = cgroup_freezer(new_cgroup);
 	if (freezer->state == CGROUP_FROZEN)
 		return -EBUSY;
 
-	if (threadgroup) {
-		struct task_struct *c;
-
-		rcu_read_lock();
-		list_for_each_entry_rcu(c, &task->thread_group, thread_group) {
-			if (is_task_frozen_enough(c)) {
-				rcu_read_unlock();
-				return -EBUSY;
-			}
-		}
-		rcu_read_unlock();
-	}
-
 	return 0;
 }
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index b23c097..cc4b1f7 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1376,6 +1376,11 @@ static int fmeter_getrate(struct fmeter *fmp)
 /* Protected by cgroup_lock */
 static cpumask_var_t cpus_attach;
 
+static int cpuset_can_attach_cb(struct cgroup *cgrp, struct task_struct *task)
+{
+	return security_task_setscheduler(task, 0, NULL);
+}
+
 /* Called by cgroups to determine if a cpuset is usable; cgroup_mutex held */
 static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 			     struct task_struct *tsk, bool threadgroup)
@@ -1397,22 +1402,11 @@ static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 	if (tsk->flags & PF_THREAD_BOUND)
 		return -EINVAL;
 
-	ret = security_task_setscheduler(tsk, 0, NULL);
+	ret = cgroup_can_attach_per_thread(cont, tsk, cpuset_can_attach_cb,
+					   threadgroup);
 	if (ret)
 		return ret;
-	if (threadgroup) {
-		struct task_struct *c;
 
-		rcu_read_lock();
-		list_for_each_entry_rcu(c, &tsk->thread_group, thread_group) {
-			ret = security_task_setscheduler(c, 0, NULL);
-			if (ret) {
-				rcu_read_unlock();
-				return ret;
-			}
-		}
-		rcu_read_unlock();
-	}
 	return 0;
 }
 
diff --git a/kernel/ns_cgroup.c b/kernel/ns_cgroup.c
index 2a5dfec..af0accf 100644
--- a/kernel/ns_cgroup.c
+++ b/kernel/ns_cgroup.c
@@ -42,9 +42,18 @@ int ns_cgroup_clone(struct task_struct *task, struct pid *pid)
  *       (hence either you are in the same cgroup as task, or in an
  *        ancestor cgroup thereof)
  */
+static int ns_can_attach_cb(struct cgroup *new_cgroup, struct task_struct *task)
+{
+	if (!cgroup_is_descendant(new_cgroup, task))
+		return -EPERM;
+	return 0;
+}
+
 static int ns_can_attach(struct cgroup_subsys *ss, struct cgroup *new_cgroup,
 			 struct task_struct *task, bool threadgroup)
 {
+	int ret;
+
 	if (current != task) {
 		if (!capable(CAP_SYS_ADMIN))
 			return -EPERM;
@@ -53,20 +62,10 @@ static int ns_can_attach(struct cgroup_subsys *ss, struct cgroup *new_cgroup,
 			return -EPERM;
 	}
 
-	if (!cgroup_is_descendant(new_cgroup, task))
-		return -EPERM;
-
-	if (threadgroup) {
-		struct task_struct *c;
-		rcu_read_lock();
-		list_for_each_entry_rcu(c, &task->thread_group, thread_group) {
-			if (!cgroup_is_descendant(new_cgroup, c)) {
-				rcu_read_unlock();
-				return -EPERM;
-			}
-		}
-		rcu_read_unlock();
-	}
+	ret = cgroup_can_attach_per_thread(new_cgroup, task, ns_can_attach_cb,
+					   threadgroup);
+	if (ret < 0)
+		return ret;
 
 	return 0;
 }
diff --git a/kernel/sched.c b/kernel/sched.c
index 70fa78d..8330e6f 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -8715,21 +8715,12 @@ static int
 cpu_cgroup_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 		      struct task_struct *tsk, bool threadgroup)
 {
-	int retval = cpu_cgroup_can_attach_task(cgrp, tsk);
-	if (retval)
-		return retval;
-	if (threadgroup) {
-		struct task_struct *c;
-		rcu_read_lock();
-		list_for_each_entry_rcu(c, &tsk->thread_group, thread_group) {
-			retval = cpu_cgroup_can_attach_task(cgrp, c);
-			if (retval) {
-				rcu_read_unlock();
-				return retval;
-			}
-		}
-		rcu_read_unlock();
-	}
+	int ret = cgroup_can_attach_per_thread(cgrp, tsk,
+					       cpu_cgroup_can_attach_task,
+					       threadgroup);
+	if (ret)
+		return ret;
+
 	return 0;
 }
