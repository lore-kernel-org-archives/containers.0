From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 01/23] cgroup: s/cgroup_subsys_state/cgroup_css/
	s/task_subsys_state/task_css/
Date: Thu,  1 Aug 2013 17:49:39 -0400
Message-ID: <1375393801-4817-2-git-send-email-tj@kernel.org>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375393801-4817-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

The names of the two struct cgroup_subsys_state accessors -
cgroup_subsys_state() and task_subsys_state() - are somewhat awkward.
The former clashes with the type name and the latter doesn't even
indicate it's somehow related to cgroup.

We're about to revamp large portion of cgroup API, so, let's rename
them so that they're less awkward.  Most per-controller usages of the
accessors are localized in accessor wrappers and given the amount of
scheduled changes, this isn't gonna add any noticeable headache.

Rename cgroup_subsys_state() to cgroup_css() and task_subsys_state()
to task_css().  This patch is pure rename.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.h           |  5 ++---
 fs/bio.c                     |  2 +-
 include/linux/cgroup.h       | 31 +++++++++++++++++++------------
 include/net/cls_cgroup.h     |  4 ++--
 include/net/netprio_cgroup.h |  4 ++--
 kernel/cgroup.c              |  2 +-
 kernel/cgroup_freezer.c      |  4 ++--
 kernel/cpuset.c              |  6 +++---
 kernel/events/core.c         |  6 +++---
 kernel/sched/core.c          |  4 ++--
 kernel/sched/cpuacct.c       |  4 ++--
 kernel/sched/sched.h         |  6 +++---
 mm/hugetlb_cgroup.c          |  6 ++----
 mm/memcontrol.c              |  5 ++---
 mm/vmpressure.c              |  2 +-
 net/core/netprio_cgroup.c    |  2 +-
 net/sched/cls_cgroup.c       |  4 ++--
 security/device_cgroup.c     |  4 ++--
 18 files changed, 52 insertions(+), 49 deletions(-)

diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 8056c03..628e50f 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -181,14 +181,13 @@ void blkg_conf_finish(struct blkg_conf_ctx *ctx);
 
 static inline struct blkcg *cgroup_to_blkcg(struct cgroup *cgroup)
 {
-	return container_of(cgroup_subsys_state(cgroup, blkio_subsys_id),
+	return container_of(cgroup_css(cgroup, blkio_subsys_id),
 			    struct blkcg, css);
 }
 
 static inline struct blkcg *task_blkcg(struct task_struct *tsk)
 {
-	return container_of(task_subsys_state(tsk, blkio_subsys_id),
-			    struct blkcg, css);
+	return container_of(task_css(tsk, blkio_subsys_id), struct blkcg, css);
 }
 
 static inline struct blkcg *bio_blkcg(struct bio *bio)
diff --git a/fs/bio.c b/fs/bio.c
index 94bbc04..8e0348f 100644
--- a/fs/bio.c
+++ b/fs/bio.c
@@ -1946,7 +1946,7 @@ int bio_associate_current(struct bio *bio)
 
 	/* associate blkcg if exists */
 	rcu_read_lock();
-	css = task_subsys_state(current, blkio_subsys_id);
+	css = task_css(current, blkio_subsys_id);
 	if (css && css_tryget(css))
 		bio->bi_css = css;
 	rcu_read_unlock();
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index bbf4d89..1938292 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -648,8 +648,15 @@ struct cgroup_subsys {
 #undef IS_SUBSYS_ENABLED
 #undef SUBSYS
 
-static inline struct cgroup_subsys_state *cgroup_subsys_state(
-	struct cgroup *cgrp, int subsys_id)
+/**
+ * cgroup_css - obtain a cgroup's css for the specified subsystem
+ * @cgrp: the cgroup of interest
+ * @subsys_id: the subsystem of interest
+ *
+ * Return @cgrp's css (cgroup_subsys_state) associated with @subsys_id.
+ */
+static inline struct cgroup_subsys_state *cgroup_css(struct cgroup *cgrp,
+						     int subsys_id)
 {
 	return cgrp->subsys[subsys_id];
 }
@@ -679,7 +686,7 @@ extern struct mutex cgroup_mutex;
 #endif
 
 /**
- * task_subsys_state_check - obtain css for (task, subsys) w/ extra access conds
+ * task_css_check - obtain css for (task, subsys) w/ extra access conds
  * @task: the target task
  * @subsys_id: the target subsystem ID
  * @__c: extra condition expression to be passed to rcu_dereference_check()
@@ -687,7 +694,7 @@ extern struct mutex cgroup_mutex;
  * Return the cgroup_subsys_state for the (@task, @subsys_id) pair.  The
  * synchronization rules are the same as task_css_set_check().
  */
-#define task_subsys_state_check(task, subsys_id, __c)			\
+#define task_css_check(task, subsys_id, __c)				\
 	task_css_set_check((task), (__c))->subsys[(subsys_id)]
 
 /**
@@ -702,22 +709,22 @@ static inline struct css_set *task_css_set(struct task_struct *task)
 }
 
 /**
- * task_subsys_state - obtain css for (task, subsys)
+ * task_css - obtain css for (task, subsys)
  * @task: the target task
  * @subsys_id: the target subsystem ID
  *
- * See task_subsys_state_check().
+ * See task_css_check().
  */
-static inline struct cgroup_subsys_state *
-task_subsys_state(struct task_struct *task, int subsys_id)
+static inline struct cgroup_subsys_state *task_css(struct task_struct *task,
+						   int subsys_id)
 {
-	return task_subsys_state_check(task, subsys_id, false);
+	return task_css_check(task, subsys_id, false);
 }
 
-static inline struct cgroup* task_cgroup(struct task_struct *task,
-					       int subsys_id)
+static inline struct cgroup *task_cgroup(struct task_struct *task,
+					 int subsys_id)
 {
-	return task_subsys_state(task, subsys_id)->cgroup;
+	return task_css(task, subsys_id)->cgroup;
 }
 
 /**
diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 0fee061..52adaa7 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -35,7 +35,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
 		return 0;
 
 	rcu_read_lock();
-	classid = container_of(task_subsys_state(p, net_cls_subsys_id),
+	classid = container_of(task_css(p, net_cls_subsys_id),
 			       struct cgroup_cls_state, css)->classid;
 	rcu_read_unlock();
 
@@ -51,7 +51,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
 		return 0;
 
 	rcu_read_lock();
-	css = task_subsys_state(p, net_cls_subsys_id);
+	css = task_css(p, net_cls_subsys_id);
 	if (css)
 		classid = container_of(css,
 				       struct cgroup_cls_state, css)->classid;
diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index 50ab8c2..8110fa7 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -39,7 +39,7 @@ static inline u32 task_netprioidx(struct task_struct *p)
 	u32 idx;
 
 	rcu_read_lock();
-	css = task_subsys_state(p, net_prio_subsys_id);
+	css = task_css(p, net_prio_subsys_id);
 	idx = css->cgroup->id;
 	rcu_read_unlock();
 	return idx;
@@ -53,7 +53,7 @@ static inline u32 task_netprioidx(struct task_struct *p)
 	u32 idx = 0;
 
 	rcu_read_lock();
-	css = task_subsys_state(p, net_prio_subsys_id);
+	css = task_css(p, net_prio_subsys_id);
 	if (css)
 		idx = css->cgroup->id;
 	rcu_read_unlock();
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 9420662..9d5af91 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -81,7 +81,7 @@
  */
 #ifdef CONFIG_PROVE_RCU
 DEFINE_MUTEX(cgroup_mutex);
-EXPORT_SYMBOL_GPL(cgroup_mutex);	/* only for task_subsys_state_check() */
+EXPORT_SYMBOL_GPL(cgroup_mutex);	/* only for lockdep */
 #else
 static DEFINE_MUTEX(cgroup_mutex);
 #endif
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 75dda1e..9d3f615 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -47,13 +47,13 @@ struct freezer {
 
 static inline struct freezer *cgroup_freezer(struct cgroup *cgroup)
 {
-	return container_of(cgroup_subsys_state(cgroup, freezer_subsys_id),
+	return container_of(cgroup_css(cgroup, freezer_subsys_id),
 			    struct freezer, css);
 }
 
 static inline struct freezer *task_freezer(struct task_struct *task)
 {
-	return container_of(task_subsys_state(task, freezer_subsys_id),
+	return container_of(task_css(task, freezer_subsys_id),
 			    struct freezer, css);
 }
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 1b9c315..be4512b 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -117,14 +117,14 @@ struct cpuset {
 /* Retrieve the cpuset for a cgroup */
 static inline struct cpuset *cgroup_cs(struct cgroup *cgrp)
 {
-	return container_of(cgroup_subsys_state(cgrp, cpuset_subsys_id),
+	return container_of(cgroup_css(cgrp, cpuset_subsys_id),
 			    struct cpuset, css);
 }
 
 /* Retrieve the cpuset for a task */
 static inline struct cpuset *task_cs(struct task_struct *task)
 {
-	return container_of(task_subsys_state(task, cpuset_subsys_id),
+	return container_of(task_css(task, cpuset_subsys_id),
 			    struct cpuset, css);
 }
 
@@ -2724,7 +2724,7 @@ int proc_cpuset_show(struct seq_file *m, void *unused_v)
 		goto out_free;
 
 	rcu_read_lock();
-	css = task_subsys_state(tsk, cpuset_subsys_id);
+	css = task_css(tsk, cpuset_subsys_id);
 	retval = cgroup_path(css->cgroup, buf, PAGE_SIZE);
 	rcu_read_unlock();
 	if (retval < 0)
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 1833bc5..414c61f 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -340,8 +340,8 @@ struct perf_cgroup {
 static inline struct perf_cgroup *
 perf_cgroup_from_task(struct task_struct *task)
 {
-	return container_of(task_subsys_state(task, perf_subsys_id),
-			struct perf_cgroup, css);
+	return container_of(task_css(task, perf_subsys_id),
+			    struct perf_cgroup, css);
 }
 
 static inline bool
@@ -7798,7 +7798,7 @@ static struct cgroup_subsys_state *perf_cgroup_css_alloc(struct cgroup *cont)
 static void perf_cgroup_css_free(struct cgroup *cont)
 {
 	struct perf_cgroup *jc;
-	jc = container_of(cgroup_subsys_state(cont, perf_subsys_id),
+	jc = container_of(cgroup_css(cont, perf_subsys_id),
 			  struct perf_cgroup, css);
 	free_percpu(jc->info);
 	kfree(jc);
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 9b1f2e5..323d907 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -6761,7 +6761,7 @@ void sched_move_task(struct task_struct *tsk)
 	if (unlikely(running))
 		tsk->sched_class->put_prev_task(rq, tsk);
 
-	tg = container_of(task_subsys_state_check(tsk, cpu_cgroup_subsys_id,
+	tg = container_of(task_css_check(tsk, cpu_cgroup_subsys_id,
 				lockdep_is_held(&tsk->sighand->siglock)),
 			  struct task_group, css);
 	tg = autogroup_task_group(tsk, tg);
@@ -7086,7 +7086,7 @@ int sched_rt_handler(struct ctl_table *table, int write,
 /* return corresponding task_group object of a cgroup */
 static inline struct task_group *cgroup_tg(struct cgroup *cgrp)
 {
-	return container_of(cgroup_subsys_state(cgrp, cpu_cgroup_subsys_id),
+	return container_of(cgroup_css(cgrp, cpu_cgroup_subsys_id),
 			    struct task_group, css);
 }
 
diff --git a/kernel/sched/cpuacct.c b/kernel/sched/cpuacct.c
index dbb7e2c..4a210fa 100644
--- a/kernel/sched/cpuacct.c
+++ b/kernel/sched/cpuacct.c
@@ -36,14 +36,14 @@ struct cpuacct {
 /* return cpu accounting group corresponding to this container */
 static inline struct cpuacct *cgroup_ca(struct cgroup *cgrp)
 {
-	return container_of(cgroup_subsys_state(cgrp, cpuacct_subsys_id),
+	return container_of(cgroup_css(cgrp, cpuacct_subsys_id),
 			    struct cpuacct, css);
 }
 
 /* return cpu accounting group to which this task belongs */
 static inline struct cpuacct *task_ca(struct task_struct *tsk)
 {
-	return container_of(task_subsys_state(tsk, cpuacct_subsys_id),
+	return container_of(task_css(tsk, cpuacct_subsys_id),
 			    struct cpuacct, css);
 }
 
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index ef0a7b2..471a56d 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -665,9 +665,9 @@ extern int group_balance_cpu(struct sched_group *sg);
 /*
  * Return the group to which this tasks belongs.
  *
- * We cannot use task_subsys_state() and friends because the cgroup
- * subsystem changes that value before the cgroup_subsys::attach() method
- * is called, therefore we cannot pin it and might observe the wrong value.
+ * We cannot use task_css() and friends because the cgroup subsystem
+ * changes that value before the cgroup_subsys::attach() method is called,
+ * therefore we cannot pin it and might observe the wrong value.
  *
  * The same is true for autogroup's p->signal->autogroup->tg, the autogroup
  * core changes this before calling sched_move_task().
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 9cea7de..50f213f 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -42,15 +42,13 @@ struct hugetlb_cgroup *hugetlb_cgroup_from_css(struct cgroup_subsys_state *s)
 static inline
 struct hugetlb_cgroup *hugetlb_cgroup_from_cgroup(struct cgroup *cgroup)
 {
-	return hugetlb_cgroup_from_css(cgroup_subsys_state(cgroup,
-							   hugetlb_subsys_id));
+	return hugetlb_cgroup_from_css(cgroup_css(cgroup, hugetlb_subsys_id));
 }
 
 static inline
 struct hugetlb_cgroup *hugetlb_cgroup_from_task(struct task_struct *task)
 {
-	return hugetlb_cgroup_from_css(task_subsys_state(task,
-							 hugetlb_subsys_id));
+	return hugetlb_cgroup_from_css(task_css(task, hugetlb_subsys_id));
 }
 
 static inline bool hugetlb_cgroup_is_root(struct hugetlb_cgroup *h_cg)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d12ca6f..b47bd3a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1037,8 +1037,7 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 
 struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
 {
-	return mem_cgroup_from_css(
-		cgroup_subsys_state(cont, mem_cgroup_subsys_id));
+	return mem_cgroup_from_css(cgroup_css(cont, mem_cgroup_subsys_id));
 }
 
 struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
@@ -1051,7 +1050,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 	if (unlikely(!p))
 		return NULL;
 
-	return mem_cgroup_from_css(task_subsys_state(p, mem_cgroup_subsys_id));
+	return mem_cgroup_from_css(task_css(p, mem_cgroup_subsys_id));
 }
 
 struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 736a601..7f1654d 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -76,7 +76,7 @@ static struct vmpressure *work_to_vmpressure(struct work_struct *work)
 
 static struct vmpressure *cg_to_vmpressure(struct cgroup *cg)
 {
-	return css_to_vmpressure(cgroup_subsys_state(cg, mem_cgroup_subsys_id));
+	return css_to_vmpressure(cgroup_css(cg, mem_cgroup_subsys_id));
 }
 
 static struct vmpressure *vmpressure_parent(struct vmpressure *vmpr)
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index e533259..ccf8523 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -31,7 +31,7 @@
 
 static inline struct cgroup_netprio_state *cgrp_netprio_state(struct cgroup *cgrp)
 {
-	return container_of(cgroup_subsys_state(cgrp, net_prio_subsys_id),
+	return container_of(cgroup_css(cgrp, net_prio_subsys_id),
 			    struct cgroup_netprio_state, css);
 }
 
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 3a294eb..5ee72a0 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -25,13 +25,13 @@
 
 static inline struct cgroup_cls_state *cgrp_cls_state(struct cgroup *cgrp)
 {
-	return container_of(cgroup_subsys_state(cgrp, net_cls_subsys_id),
+	return container_of(cgroup_css(cgrp, net_cls_subsys_id),
 			    struct cgroup_cls_state, css);
 }
 
 static inline struct cgroup_cls_state *task_cls_state(struct task_struct *p)
 {
-	return container_of(task_subsys_state(p, net_cls_subsys_id),
+	return container_of(task_css(p, net_cls_subsys_id),
 			    struct cgroup_cls_state, css);
 }
 
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index e8aad69..87a0a03 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -58,12 +58,12 @@ static inline struct dev_cgroup *css_to_devcgroup(struct cgroup_subsys_state *s)
 
 static inline struct dev_cgroup *cgroup_to_devcgroup(struct cgroup *cgroup)
 {
-	return css_to_devcgroup(cgroup_subsys_state(cgroup, devices_subsys_id));
+	return css_to_devcgroup(cgroup_css(cgroup, devices_subsys_id));
 }
 
 static inline struct dev_cgroup *task_devcgroup(struct task_struct *task)
 {
-	return css_to_devcgroup(task_subsys_state(task, devices_subsys_id));
+	return css_to_devcgroup(task_css(task, devices_subsys_id));
 }
 
 struct cgroup_subsys devices_subsys;
-- 
1.8.3.1
