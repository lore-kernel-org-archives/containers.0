From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: [PATCH 03/11] cgroups: Add previous cgroup in can_attach_task/attach_task callbacks
Date: Tue, 13 Sep 2011 01:11:23 +0200
Message-ID: <1315869091-18933-4-git-send-email-fweisbec@gmail.com>
References: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Containers <containers@lists.osdl.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>
List-Id: containers.vger.kernel.org

This is to prepare the integration of a new max number of proc
cgroup subsystem. We'll need to release some resources from the
previous cgroup.

Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
Acked-by: Paul Menage <paul@paulmenage.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Aditya Kali <adityakali@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kay Sievers <kay.sievers@vrfy.org>
Cc: Tim Hockin <thockin@hockin.org>
Cc: Tejun Heo <tj@kernel.org>
---
 Documentation/cgroups/cgroups.txt |    6 ++++--
 block/blk-cgroup.c                |   12 ++++++++----
 include/linux/cgroup.h            |    6 ++++--
 kernel/cgroup.c                   |   11 +++++++----
 kernel/cgroup_freezer.c           |    3 ++-
 kernel/cpuset.c                   |    6 ++++--
 kernel/events/core.c              |    5 +++--
 kernel/sched.c                    |    6 ++++--
 8 files changed, 36 insertions(+), 19 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index cd67e90..0621e93 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -605,7 +605,8 @@ called on a fork. If this method returns 0 (success) then this should
 remain valid while the caller holds cgroup_mutex and it is ensured that either
 attach() or cancel_attach() will be called in future.
 
-int can_attach_task(struct cgroup *cgrp, struct task_struct *tsk);
+int can_attach_task(struct cgroup *cgrp, struct cgroup *old_cgrp,
+		    struct task_struct *tsk);
 (cgroup_mutex held by caller)
 
 As can_attach, but for operations that must be run once per task to be
@@ -635,7 +636,8 @@ void attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 Called after the task has been attached to the cgroup, to allow any
 post-attachment activity that requires memory allocations or blocking.
 
-void attach_task(struct cgroup *cgrp, struct task_struct *tsk);
+void attach_task(struct cgroup *cgrp, struct cgroup *old_cgrp,
+		 struct task_struct *tsk);
 (cgroup_mutex held by caller)
 
 As attach, but for operations that must be run once per task to be attached,
diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index bcaf16e..6eddc5f 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -30,8 +30,10 @@ EXPORT_SYMBOL_GPL(blkio_root_cgroup);
 
 static struct cgroup_subsys_state *blkiocg_create(struct cgroup_subsys *,
 						  struct cgroup *);
-static int blkiocg_can_attach_task(struct cgroup *, struct task_struct *);
-static void blkiocg_attach_task(struct cgroup *, struct task_struct *);
+static int blkiocg_can_attach_task(struct cgroup *, struct cgroup *,
+				   struct task_struct *);
+static void blkiocg_attach_task(struct cgroup *, struct cgroup *,
+				struct task_struct *);
 static void blkiocg_destroy(struct cgroup_subsys *, struct cgroup *);
 static int blkiocg_populate(struct cgroup_subsys *, struct cgroup *);
 
@@ -1614,7 +1616,8 @@ done:
  * of the main cic data structures.  For now we allow a task to change
  * its cgroup only if it's the only owner of its ioc.
  */
-static int blkiocg_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+static int blkiocg_can_attach_task(struct cgroup *cgrp, struct cgroup *old_cgrp,
+				   struct task_struct *tsk)
 {
 	struct io_context *ioc;
 	int ret = 0;
@@ -1629,7 +1632,8 @@ static int blkiocg_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	return ret;
 }
 
-static void blkiocg_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+static void blkiocg_attach_task(struct cgroup *cgrp, struct cgroup *old_cgrp,
+				struct task_struct *tsk)
 {
 	struct io_context *ioc;
 
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index da7e4bc..ed34eb8 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -468,11 +468,13 @@ struct cgroup_subsys {
 	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	int (*can_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			  struct task_struct *tsk);
-	int (*can_attach_task)(struct cgroup *cgrp, struct task_struct *tsk);
+	int (*can_attach_task)(struct cgroup *cgrp, struct cgroup *old_cgrp,
+			       struct task_struct *tsk);
 	void (*cancel_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			      struct task_struct *tsk);
 	void (*pre_attach)(struct cgroup *cgrp);
-	void (*attach_task)(struct cgroup *cgrp, struct task_struct *tsk);
+	void (*attach_task)(struct cgroup *cgrp, struct cgroup *old_cgrp,
+			    struct task_struct *tsk);
 	void (*attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 		       struct cgroup *old_cgrp, struct task_struct *tsk);
 	void (*fork)(struct cgroup_subsys *ss, struct task_struct *task);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 84bdace..fafebdb 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1844,7 +1844,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 			}
 		}
 		if (ss->can_attach_task) {
-			retval = ss->can_attach_task(cgrp, tsk);
+			retval = ss->can_attach_task(cgrp, oldcgrp, tsk);
 			if (retval) {
 				failed_ss = ss;
 				goto out;
@@ -1860,7 +1860,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 		if (ss->pre_attach)
 			ss->pre_attach(cgrp);
 		if (ss->attach_task)
-			ss->attach_task(cgrp, tsk);
+			ss->attach_task(cgrp, oldcgrp, tsk);
 		if (ss->attach)
 			ss->attach(ss, cgrp, oldcgrp, tsk);
 	}
@@ -2075,7 +2075,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 			/* run on each task in the threadgroup. */
 			for (i = 0; i < group_size; i++) {
 				tsk = flex_array_get_ptr(group, i);
-				retval = ss->can_attach_task(cgrp, tsk);
+				oldcgrp = task_cgroup_from_root(tsk, root);
+
+				retval = ss->can_attach_task(cgrp,
+							     oldcgrp, tsk);
 				if (retval) {
 					failed_ss = ss;
 					cancel_failed_ss = true;
@@ -2141,7 +2144,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 			/* attach each task to each subsystem */
 			for_each_subsys(root, ss) {
 				if (ss->attach_task)
-					ss->attach_task(cgrp, tsk);
+					ss->attach_task(cgrp, oldcgrp, tsk);
 			}
 		} else {
 			BUG_ON(retval != -ESRCH);
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index e691818..c1421a1 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -175,7 +175,8 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 	return 0;
 }
 
-static int freezer_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+static int freezer_can_attach_task(struct cgroup *cgrp, struct cgroup *old_cgrp,
+				   struct task_struct *tsk)
 {
 	rcu_read_lock();
 	if (__cgroup_freezing_or_frozen(tsk)) {
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 10131fd..427be38 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1390,7 +1390,8 @@ static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 	return 0;
 }
 
-static int cpuset_can_attach_task(struct cgroup *cgrp, struct task_struct *task)
+static int cpuset_can_attach_task(struct cgroup *cgrp, struct cgroup *old_cgrp,
+				  struct task_struct *task)
 {
 	return security_task_setscheduler(task);
 }
@@ -1418,7 +1419,8 @@ static void cpuset_pre_attach(struct cgroup *cont)
 }
 
 /* Per-thread attachment work. */
-static void cpuset_attach_task(struct cgroup *cont, struct task_struct *tsk)
+static void cpuset_attach_task(struct cgroup *cont, struct cgroup *old,
+			       struct task_struct *tsk)
 {
 	int err;
 	struct cpuset *cs = cgroup_cs(cont);
diff --git a/kernel/events/core.c b/kernel/events/core.c
index b8785e2..509464e 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -7001,7 +7001,8 @@ static int __perf_cgroup_move(void *info)
 }
 
 static void
-perf_cgroup_attach_task(struct cgroup *cgrp, struct task_struct *task)
+perf_cgroup_attach_task(struct cgroup *cgrp, struct cgroup *old_cgrp,
+			struct task_struct *task)
 {
 	task_function_call(task, __perf_cgroup_move, task);
 }
@@ -7017,7 +7018,7 @@ static void perf_cgroup_exit(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	if (!(task->flags & PF_EXITING))
 		return;
 
-	perf_cgroup_attach_task(cgrp, task);
+	perf_cgroup_attach_task(cgrp, old_cgrp, task);
 }
 
 struct cgroup_subsys perf_subsys = {
diff --git a/kernel/sched.c b/kernel/sched.c
index ccacdbd..72ce1b1 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -8967,7 +8967,8 @@ cpu_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
 }
 
 static int
-cpu_cgroup_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+cpu_cgroup_can_attach_task(struct cgroup *cgrp, struct cgroup *old_cgrp,
+			   struct task_struct *tsk)
 {
 #ifdef CONFIG_RT_GROUP_SCHED
 	if (!sched_rt_can_attach(cgroup_tg(cgrp), tsk))
@@ -8981,7 +8982,8 @@ cpu_cgroup_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 }
 
 static void
-cpu_cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+cpu_cgroup_attach_task(struct cgroup *cgrp, struct cgroup *old_cgrp,
+		       struct task_struct *tsk)
 {
 	sched_move_task(tsk);
 }
-- 
1.7.5.4
