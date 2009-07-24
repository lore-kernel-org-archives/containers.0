From: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 6/6] Lets ss->can_attach and ss->attach do whole threadgroups
	at a time
Date: Thu, 23 Jul 2009 20:22:06 -0700
Message-ID: <20090724032205.2463.36312.stgit@hastromil.mtv.corp.google.com>
References: <20090724032033.2463.79256.stgit@hastromil.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090724032033.2463.79256.stgit-/yCBOHwbXCxd3OlUiQof+WCaruZE5nAUZeezCHUQhQ4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Lets ss->can_attach and ss->attach do whole threadgroups at a time

This patch alters the ss->can_attach and ss->attach functions to be able to
deal with a whole threadgroup at a time, for use in cgroup_attach_proc. (This
is a post-patch to cgroup-procs-writable.patch.)

Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 include/linux/cgroup.h   |    7 +++--
 kernel/cgroup.c          |    8 +++---
 kernel/cgroup_freezer.c  |   15 +++++++++--
 kernel/cpuset.c          |   65 ++++++++++++++++++++++++++++++++++++----------
 kernel/ns_cgroup.c       |   16 ++++++++++-
 kernel/sched.c           |   37 ++++++++++++++++++++++++--
 mm/memcontrol.c          |    3 +-
 security/device_cgroup.c |    3 +-
 8 files changed, 124 insertions(+), 30 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index cae7d3e..5a4383c 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -409,10 +409,11 @@ struct cgroup_subsys {
 						  struct cgroup *cgrp);
 	int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
-	int (*can_attach)(struct cgroup_subsys *ss,
-			  struct cgroup *cgrp, struct task_struct *tsk);
+	int (*can_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			  struct task_struct *tsk, bool threadgroup);
 	void (*attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
-			struct cgroup *old_cgrp, struct task_struct *tsk);
+			struct cgroup *old_cgrp, struct task_struct *tsk,
+			bool threadgroup);
 	void (*fork)(struct cgroup_subsys *ss, struct task_struct *task);
 	void (*exit)(struct cgroup_subsys *ss, struct task_struct *task);
 	int (*populate)(struct cgroup_subsys *ss,
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3f8d323..abdfa5a 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1415,7 +1415,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 
 	for_each_subsys(root, ss) {
 		if (ss->can_attach) {
-			retval = ss->can_attach(ss, cgrp, tsk);
+			retval = ss->can_attach(ss, cgrp, tsk, false);
 			if (retval)
 				return retval;
 		}
@@ -1427,7 +1427,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 
 	for_each_subsys(root, ss) {
 		if (ss->attach)
-			ss->attach(ss, cgrp, oldcgrp, tsk);
+			ss->attach(ss, cgrp, oldcgrp, tsk, false);
 	}
 
 	synchronize_rcu();
@@ -1537,7 +1537,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 */
 	for_each_subsys(root, ss) {
 		if (ss->can_attach) {
-			retval = ss->can_attach(ss, cgrp, leader);
+			retval = ss->can_attach(ss, cgrp, leader, true);
 			if (retval)
 				return retval;
 		}
@@ -1649,7 +1649,7 @@ again:
 	 */
 	for_each_subsys(root, ss) {
 		if (ss->attach)
-			ss->attach(ss, cgrp, oldcgrp, leader);
+			ss->attach(ss, cgrp, oldcgrp, leader, true);
 	}
 
 	/*
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index fb249e2..4e352ab 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -159,10 +159,9 @@ static bool is_task_frozen_enough(struct task_struct *task)
  */
 static int freezer_can_attach(struct cgroup_subsys *ss,
 			      struct cgroup *new_cgroup,
-			      struct task_struct *task)
+			      struct task_struct *task, bool threadgroup)
 {
 	struct freezer *freezer;
-
 	/*
 	 * Anything frozen can't move or be moved to/from.
 	 *
@@ -177,6 +176,18 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 	if (freezer->state == CGROUP_FROZEN)
 		return -EBUSY;
 
+	if (threadgroup) {
+		struct task_struct *c;
+		rcu_read_lock();
+		list_for_each_entry_rcu(c, &task->thread_group, thread_group) {
+			if (is_task_frozen_enough(c)) {
+				rcu_read_unlock();
+				return -EBUSY;
+			}
+		}
+		rcu_read_unlock();
+	}
+
 	return 0;
 }
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 7e75a41..86397f4 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1324,9 +1324,10 @@ static int fmeter_getrate(struct fmeter *fmp)
 static cpumask_var_t cpus_attach;
 
 /* Called by cgroups to determine if a cpuset is usable; cgroup_mutex held */
-static int cpuset_can_attach(struct cgroup_subsys *ss,
-			     struct cgroup *cont, struct task_struct *tsk)
+static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cont,
+			     struct task_struct *tsk, bool threadgroup)
 {
+	int ret;
 	struct cpuset *cs = cgroup_cs(cont);
 
 	if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
@@ -1343,18 +1344,50 @@ static int cpuset_can_attach(struct cgroup_subsys *ss,
 	if (tsk->flags & PF_THREAD_BOUND)
 		return -EINVAL;
 
-	return security_task_setscheduler(tsk, 0, NULL);
+	ret = security_task_setscheduler(tsk, 0, NULL);
+	if (ret)
+		return ret;
+	if (threadgroup) {
+		struct task_struct *c;
+		rcu_read_lock();
+		list_for_each_entry_rcu(c, &tsk->thread_group, thread_group) {
+			ret = security_task_setscheduler(c, 0, NULL);
+			if (ret) {
+				rcu_read_unlock();
+				return ret;
+			}
+		}
+		rcu_read_unlock();
+	}
+	return 0;
+}
+
+static void cpuset_attach_task(struct task_struct *tsk, nodemask_t *to,
+			       struct cpuset *cs)
+{
+	int err;
+	/*
+	 * can_attach beforehand should guarantee that this doesn't fail.
+	 * TODO: have a better way to handle failure here
+	 */
+	err = set_cpus_allowed_ptr(tsk, cpus_attach);
+	WARN_ON_ONCE(err);
+
+	task_lock(tsk);
+	cpuset_change_task_nodemask(tsk, to);
+	task_unlock(tsk);
+	cpuset_update_task_spread_flag(cs, tsk);
+
 }
 
-static void cpuset_attach(struct cgroup_subsys *ss,
-			  struct cgroup *cont, struct cgroup *oldcont,
-			  struct task_struct *tsk)
+static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
+			  struct cgroup *oldcont, struct task_struct *tsk,
+			  bool threadgroup)
 {
 	nodemask_t from, to;
 	struct mm_struct *mm;
 	struct cpuset *cs = cgroup_cs(cont);
 	struct cpuset *oldcs = cgroup_cs(oldcont);
-	int err;
 
 	if (cs == &top_cpuset) {
 		cpumask_copy(cpus_attach, cpu_possible_mask);
@@ -1363,15 +1396,19 @@ static void cpuset_attach(struct cgroup_subsys *ss,
 		guarantee_online_cpus(cs, cpus_attach);
 		guarantee_online_mems(cs, &to);
 	}
-	err = set_cpus_allowed_ptr(tsk, cpus_attach);
-	if (err)
-		return;
 
-	task_lock(tsk);
-	cpuset_change_task_nodemask(tsk, &to);
-	task_unlock(tsk);
-	cpuset_update_task_spread_flag(cs, tsk);
+	/* do per-task migration stuff possibly for each in the threadgroup */
+	cpuset_attach_task(tsk, &to, cs);
+	if (threadgroup) {
+		struct task_struct *c;
+		rcu_read_lock();
+		list_for_each_entry_rcu(c, &tsk->thread_group, thread_group) {
+			cpuset_attach_task(c, &to, cs);
+		}
+		rcu_read_unlock();
+	}
 
+	/* change mm; only needs to be done once even if threadgroup */
 	from = oldcs->mems_allowed;
 	to = cs->mems_allowed;
 	mm = get_task_mm(tsk);
diff --git a/kernel/ns_cgroup.c b/kernel/ns_cgroup.c
index 5aa854f..2a5dfec 100644
--- a/kernel/ns_cgroup.c
+++ b/kernel/ns_cgroup.c
@@ -42,8 +42,8 @@ int ns_cgroup_clone(struct task_struct *task, struct pid *pid)
  *       (hence either you are in the same cgroup as task, or in an
  *        ancestor cgroup thereof)
  */
-static int ns_can_attach(struct cgroup_subsys *ss,
-		struct cgroup *new_cgroup, struct task_struct *task)
+static int ns_can_attach(struct cgroup_subsys *ss, struct cgroup *new_cgroup,
+			 struct task_struct *task, bool threadgroup)
 {
 	if (current != task) {
 		if (!capable(CAP_SYS_ADMIN))
@@ -56,6 +56,18 @@ static int ns_can_attach(struct cgroup_subsys *ss,
 	if (!cgroup_is_descendant(new_cgroup, task))
 		return -EPERM;
 
+	if (threadgroup) {
+		struct task_struct *c;
+		rcu_read_lock();
+		list_for_each_entry_rcu(c, &task->thread_group, thread_group) {
+			if (!cgroup_is_descendant(new_cgroup, c)) {
+				rcu_read_unlock();
+				return -EPERM;
+			}
+		}
+		rcu_read_unlock();
+	}
+
 	return 0;
 }
 
diff --git a/kernel/sched.c b/kernel/sched.c
index 3393c18..b5e371b 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -10194,8 +10194,7 @@ cpu_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
 }
 
 static int
-cpu_cgroup_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-		      struct task_struct *tsk)
+cpu_cgroup_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 {
 #ifdef CONFIG_RT_GROUP_SCHED
 	if (!sched_rt_can_attach(cgroup_tg(cgrp), tsk))
@@ -10209,11 +10208,43 @@ cpu_cgroup_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	return 0;
 }
 
+static int
+cpu_cgroup_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+		      struct task_struct *tsk, bool threadgroup)
+{
+	int retval = cpu_cgroup_can_attach_task(cgrp, tsk);
+	if (retval)
+		return retval;
+	if (threadgroup) {
+		struct task_struct *c;
+		rcu_read_lock();
+		list_for_each_entry_rcu(c, &tsk->thread_group, thread_group) {
+			retval = cpu_cgroup_can_attach_task(cgrp, c);
+			if (retval) {
+				rcu_read_unlock();
+				return retval;
+			}
+		}
+		rcu_read_unlock();
+	}
+	return 0;
+
+}
+
 static void
 cpu_cgroup_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-			struct cgroup *old_cont, struct task_struct *tsk)
+		  struct cgroup *old_cont, struct task_struct *tsk
+		  bool threadgroup)
 {
 	sched_move_task(tsk);
+	if (threadgroup) {
+		struct task_struct *c;
+		rcu_read_lock();
+		list_for_each_entry_rcu(c, &tsk->thread_group, thread_group) {
+			sched_move_task(c);
+		}
+		rcu_read_unlock();
+	}
 }
 
 #ifdef CONFIG_FAIR_GROUP_SCHED
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6ceb6f2..d9e9cf4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2584,7 +2584,8 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct cgroup *cont,
 				struct cgroup *old_cont,
-				struct task_struct *p)
+				struct task_struct *p,
+				bool threadgroup)
 {
 	mutex_lock(&memcg_tasklist);
 	/*
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index b8186ba..6cf8fd2 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -61,7 +61,8 @@ static inline struct dev_cgroup *task_devcgroup(struct task_struct *task)
 struct cgroup_subsys devices_subsys;
 
 static int devcgroup_can_attach(struct cgroup_subsys *ss,
-		struct cgroup *new_cgroup, struct task_struct *task)
+		struct cgroup *new_cgroup, struct task_struct *task,
+		bool threadgroup)
 {
 	if (current != task && !capable(CAP_SYS_ADMIN))
 			return -EPERM;
