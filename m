From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 5/6] cgroup, cpuset: don't use ss->pre_attach()
Date: Wed, 24 Aug 2011 00:19:59 +0200
Message-ID: <1314138000-2049-6-git-send-email-tj__14831.1025965542$1314138155$gmane$org@kernel.org>
References: <1314138000-2049-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1314138000-2049-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: rjw-KKrjLPT3xs0@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

->pre_attach() is supposed to be called before migration, which is
observed during process migration but task migration does it the other
way around.  The only ->pre_attach() user is cpuset which can do the
same operaitons in ->can_attach().  Collapse cpuset_pre_attach() into
cpuset_can_attach().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |   20 --------------------
 kernel/cpuset.c                   |   29 ++++++++++++-----------------
 2 files changed, 12 insertions(+), 37 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 2eee7cf..afb7cde 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -610,13 +610,6 @@ called on a fork. If this method returns 0 (success) then this should
 remain valid while the caller holds cgroup_mutex and it is ensured
 that either attach() or cancel_attach() will be called in future.
 
-int can_attach_task(struct cgroup *cgrp, struct task_struct *tsk);
-(cgroup_mutex held by caller)
-
-As can_attach, but for operations that must be run once per task to be
-attached (possibly many when using cgroup_attach_proc). Called after
-can_attach.
-
 void cancel_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 		   struct cgroup_taskset *tset)
 (cgroup_mutex held by caller)
@@ -627,12 +620,6 @@ function, so that the subsystem can implement a rollback. If not, not necessary.
 This will be called only about subsystems whose can_attach() operation have
 succeeded. The parameters are identical to can_attach().
 
-void pre_attach(struct cgroup *cgrp);
-(cgroup_mutex held by caller)
-
-For any non-per-thread attachment work that needs to happen before
-attach_task. Needed by cpuset.
-
 void attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	    struct cgroup_taskset *tset)
 (cgroup_mutex held by caller)
@@ -641,13 +628,6 @@ Called after the task has been attached to the cgroup, to allow any
 post-attachment activity that requires memory allocations or blocking.
 The parameters are identical to can_attach().
 
-void attach_task(struct cgroup *cgrp, struct task_struct *tsk);
-(cgroup_mutex held by caller)
-
-As attach, but for operations that must be run once per task to be attached,
-like can_attach_task. Called before attach. Currently does not support any
-subsystem that might need the old_cgrp for every thread in the group.
-
 void fork(struct cgroup_subsy *ss, struct task_struct *task)
 
 Called when a task is forked into a cgroup.
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 472ddd6..f0b8df3 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1367,6 +1367,15 @@ static int fmeter_getrate(struct fmeter *fmp)
 	return val;
 }
 
+/*
+ * Protected by cgroup_lock. The nodemasks must be stored globally because
+ * dynamically allocating them is not allowed in can_attach, and they must
+ * persist until attach.
+ */
+static cpumask_var_t cpus_attach;
+static nodemask_t cpuset_attach_nodemask_from;
+static nodemask_t cpuset_attach_nodemask_to;
+
 /* Called by cgroups to determine if a cpuset is usable; cgroup_mutex held */
 static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			     struct cgroup_taskset *tset)
@@ -1393,29 +1402,16 @@ static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 		if ((ret = security_task_setscheduler(task)))
 			return ret;
 	}
-	return 0;
-}
-
-/*
- * Protected by cgroup_lock. The nodemasks must be stored globally because
- * dynamically allocating them is not allowed in pre_attach, and they must
- * persist among pre_attach, and attach.
- */
-static cpumask_var_t cpus_attach;
-static nodemask_t cpuset_attach_nodemask_from;
-static nodemask_t cpuset_attach_nodemask_to;
-
-/* Set-up work for before attaching each task. */
-static void cpuset_pre_attach(struct cgroup *cont)
-{
-	struct cpuset *cs = cgroup_cs(cont);
 
+	/* prepare for attach */
 	if (cs == &top_cpuset)
 		cpumask_copy(cpus_attach, cpu_possible_mask);
 	else
 		guarantee_online_cpus(cs, cpus_attach);
 
 	guarantee_online_mems(cs, &cpuset_attach_nodemask_to);
+
+	return 0;
 }
 
 static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
@@ -1901,7 +1897,6 @@ struct cgroup_subsys cpuset_subsys = {
 	.create = cpuset_create,
 	.destroy = cpuset_destroy,
 	.can_attach = cpuset_can_attach,
-	.pre_attach = cpuset_pre_attach,
 	.attach = cpuset_attach,
 	.populate = cpuset_populate,
 	.post_clone = cpuset_post_clone,
-- 
1.7.6
