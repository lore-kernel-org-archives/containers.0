From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [PATCH v6 2/3] cgroups: add can_attach callback for checking all
	threads in a group
Date: Fri, 24 Dec 2010 03:24:22 -0500
Message-ID: <20101224082422.GC13872@ghc17.ghc.andrew.cmu.edu>
References: <20100730235649.GA22644@ghc17.ghc.andrew.cmu.edu>
	<20100811054604.GA8743@ghc17.ghc.andrew.cmu.edu>
	<20101224082226.GA13872@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: attachment; filename="cgroup-threadgroup-callback.patch"
In-Reply-To: <20101224082226.GA13872-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
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
 block/blk-cgroup.c      |   31 ++++++++++++++++++++++++++-----
 include/linux/cgroup.h  |   14 ++++++++++++++
 kernel/cgroup.c         |   45 +++++++++++++++++++++++++++++++++++++++++++++
 kernel/cgroup_freezer.c |   33 ++++++++++++++-------------------
 kernel/cpuset.c         |   30 ++++++++++--------------------
 kernel/ns_cgroup.c      |   25 +++++++++----------------
 kernel/sched.c          |   24 ++++++------------------
 7 files changed, 124 insertions(+), 78 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index b1febd0..865e208 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -1475,9 +1475,7 @@ done:
  * of the main cic data structures.  For now we allow a task to change
  * its cgroup only if it's the only owner of its ioc.
  */
-static int blkiocg_can_attach(struct cgroup_subsys *subsys,
-				struct cgroup *cgroup, struct task_struct *tsk,
-				bool threadgroup)
+static int blkiocg_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 {
 	struct io_context *ioc;
 	int ret = 0;
@@ -1492,10 +1490,17 @@ static int blkiocg_can_attach(struct cgroup_subsys *subsys,
 	return ret;
 }
 
-static void blkiocg_attach(struct cgroup_subsys *subsys, struct cgroup *cgroup,
-				struct cgroup *prev, struct task_struct *tsk,
+static int blkiocg_can_attach(struct cgroup_subsys *subsys,
+				struct cgroup *cgroup, struct task_struct *tsk,
 				bool threadgroup)
 {
+	return cgroup_can_attach_per_thread(cgroup, tsk,
+					    blkiocg_can_attach_task,
+					    threadgroup, false);
+}
+
+static void blkiocg_attach_task(struct task_struct *tsk)
+{
 	struct io_context *ioc;
 
 	task_lock(tsk);
@@ -1505,6 +1510,22 @@ static void blkiocg_attach(struct cgroup_subsys *subsys, struct cgroup *cgroup,
 	task_unlock(tsk);
 }
 
+static void blkiocg_attach(struct cgroup_subsys *subsys, struct cgroup *cgroup,
+				struct cgroup *prev, struct task_struct *tsk,
+				bool threadgroup)
+{
+	blkiocg_attach_task(tsk);
+	if (threadgroup) {
+		struct task_struct *c;
+
+		/* tasklist_lock will be held. */
+		BUG_ON(!thread_group_leader(tsk));
+		list_for_each_entry_rcu(c, &tsk->thread_group, thread_group) {
+			blkiocg_attach_task(c);
+		}
+	}
+}
+
 void blkio_policy_register(struct blkio_policy_type *blkiop)
 {
 	spin_lock(&blkio_list_lock);
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index ce104e3..96898e6 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -590,6 +590,20 @@ static inline int cgroup_attach_task_current_cg(struct task_struct *tsk)
 }
 
 /*
+ * For use in subsystems whose can_attach functions need to run an operation
+ * on every task in the threadgroup. Calls the given callback once if the
+ * 'threadgroup' flag is false, or once per thread in the group if true.
+ * The callback should return 0/-ERR; this will return 0/-ERR.
+ * The callback will run within an rcu_read section, so must not sleep.
+ * 'need_rcu' should specify whether the callback needs to run in an rcu_read
+ * section even in the single-task case.
+ */
+int cgroup_can_attach_per_thread(struct cgroup *cgrp, struct task_struct *task,
+				 int (*cb)(struct cgroup *cgrp,
+					   struct task_struct *task),
+				 bool threadgroup, bool need_rcu);
+
+/*
  * CSS ID is ID for cgroup_subsys_state structs under subsys. This only works
  * if cgroup_subsys.use_id == true. It can be used for looking up and scanning.
  * CSS ID is assigned at cgroup allocation (create) automatically
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 66a416b..f86dd9c 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1726,6 +1726,51 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 }
 EXPORT_SYMBOL_GPL(cgroup_path);
 
+int cgroup_can_attach_per_thread(struct cgroup *cgrp, struct task_struct *task,
+				 int (*cb)(struct cgroup *cgrp,
+					   struct task_struct *task),
+				 bool threadgroup, bool need_rcu)
+{
+	int ret;
+
+	/* Run callback on the leader first, taking rcu_read_lock if needed. */
+	if (need_rcu)
+		rcu_read_lock();
+
+	ret = cb(cgrp, task);
+
+	if (need_rcu)
+		rcu_read_unlock();
+
+	if (ret < 0)
+		return ret;
+
+	/* Run on each task in the threadgroup. */
+	if (threadgroup) {
+		struct task_struct *c;
+
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
index e7bebb7..1f5ac8f 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -153,6 +153,13 @@ static void freezer_destroy(struct cgroup_subsys *ss,
 	kfree(cgroup_freezer(cgroup));
 }
 
+static int freezer_can_attach_cb(struct cgroup *cgrp, struct task_struct *task)
+{
+	if (__cgroup_freezing_or_frozen(task))
+		return -EBUSY;
+	return 0;
+}
+
 /*
  * The call to cgroup_lock() in the freezer.state write method prevents
  * a write to that file racing against an attach, and hence the
@@ -163,6 +170,7 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 			      struct task_struct *task, bool threadgroup)
 {
 	struct freezer *freezer;
+	int ret;
 
 	/*
 	 * Anything frozen can't move or be moved to/from.
@@ -172,25 +180,12 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 	if (freezer->state != CGROUP_THAWED)
 		return -EBUSY;
 
-	rcu_read_lock();
-	if (__cgroup_freezing_or_frozen(task)) {
-		rcu_read_unlock();
-		return -EBUSY;
-	}
-	rcu_read_unlock();
-
-	if (threadgroup) {
-		struct task_struct *c;
-
-		rcu_read_lock();
-		list_for_each_entry_rcu(c, &task->thread_group, thread_group) {
-			if (__cgroup_freezing_or_frozen(c)) {
-				rcu_read_unlock();
-				return -EBUSY;
-			}
-		}
-		rcu_read_unlock();
-	}
+	/* Need to take rcu_read_lock even around the call on the leader. */
+	ret = cgroup_can_attach_per_thread(new_cgroup, task,
+					   freezer_can_attach_cb, threadgroup,
+					   true);
+	if (ret < 0)
+		return ret;
 
 	return 0;
 }
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 4349935..8fbe1e3 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1375,11 +1375,15 @@ static int fmeter_getrate(struct fmeter *fmp)
 /* Protected by cgroup_lock */
 static cpumask_var_t cpus_attach;
 
+static int cpuset_can_attach_cb(struct cgroup *cgrp, struct task_struct *task)
+{
+	return security_task_setscheduler(task);
+}
+
 /* Called by cgroups to determine if a cpuset is usable; cgroup_mutex held */
 static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 			     struct task_struct *tsk, bool threadgroup)
 {
-	int ret;
 	struct cpuset *cs = cgroup_cs(cont);
 
 	if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
@@ -1396,23 +1400,8 @@ static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 	if (tsk->flags & PF_THREAD_BOUND)
 		return -EINVAL;
 
-	ret = security_task_setscheduler(tsk);
-	if (ret)
-		return ret;
-	if (threadgroup) {
-		struct task_struct *c;
-
-		rcu_read_lock();
-		list_for_each_entry_rcu(c, &tsk->thread_group, thread_group) {
-			ret = security_task_setscheduler(c);
-			if (ret) {
-				rcu_read_unlock();
-				return ret;
-			}
-		}
-		rcu_read_unlock();
-	}
-	return 0;
+	return cgroup_can_attach_per_thread(cont, tsk, cpuset_can_attach_cb,
+					    threadgroup, false);
 }
 
 static void cpuset_attach_task(struct task_struct *tsk, nodemask_t *to,
@@ -1455,11 +1444,12 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 	cpuset_attach_task(tsk, to, cs);
 	if (threadgroup) {
 		struct task_struct *c;
-		rcu_read_lock();
+
+		/* tasklist_lock will be held. */
+		BUG_ON(!thread_group_leader(tsk));
 		list_for_each_entry_rcu(c, &tsk->thread_group, thread_group) {
 			cpuset_attach_task(c, to, cs);
 		}
-		rcu_read_unlock();
 	}
 
 	/* change mm; only needs to be done once even if threadgroup */
diff --git a/kernel/ns_cgroup.c b/kernel/ns_cgroup.c
index 2c98ad9..66ba860 100644
--- a/kernel/ns_cgroup.c
+++ b/kernel/ns_cgroup.c
@@ -42,6 +42,13 @@ int ns_cgroup_clone(struct task_struct *task, struct pid *pid)
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
@@ -53,22 +60,8 @@ static int ns_can_attach(struct cgroup_subsys *ss, struct cgroup *new_cgroup,
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
-
-	return 0;
+	return cgroup_can_attach_per_thread(new_cgroup, task, ns_can_attach_cb,
+					    threadgroup, false);
 }
 
 /*
diff --git a/kernel/sched.c b/kernel/sched.c
index 218ef20..8e89bf9 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -8659,22 +8659,9 @@ static int
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
-	return 0;
+	return cgroup_can_attach_per_thread(cgrp, tsk,
+					    cpu_cgroup_can_attach_task,
+					    threadgroup, false);
 }
 
 static void
@@ -8685,11 +8672,12 @@ cpu_cgroup_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	sched_move_task(tsk);
 	if (threadgroup) {
 		struct task_struct *c;
-		rcu_read_lock();
+
+		/* tasklist_lock will be held. */
+		BUG_ON(!thread_group_leader(tsk));
 		list_for_each_entry_rcu(c, &tsk->thread_group, thread_group) {
 			sched_move_task(c);
 		}
-		rcu_read_unlock();
 	}
 }
