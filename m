From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 07/23] cgroup: add css_parent()
Date: Thu,  1 Aug 2013 17:49:45 -0400
Message-ID: <1375393801-4817-8-git-send-email-tj@kernel.org>
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

Currently, controllers have to explicitly follow the cgroup hierarchy
to find the parent of a given css.  cgroup is moving towards using
cgroup_subsys_state as the main controller interface construct, so
let's provide a way to climb the hierarchy using just csses.

This patch implements css_parent() which, given a css, returns its
parent.  The function is guarnateed to valid non-NULL parent css as
long as the target css is not at the top of the hierarchy.

freezer, cpuset, cpu, cpuacct, hugetlb, memory, net_cls and devices
are converted to use css_parent() instead of accessing cgroup->parent
directly.

* __parent_ca() is dropped from cpuacct and its usage is replaced with
  parent_ca().  The only difference between the two was NULL test on
  cgroup->parent which is now embedded in css_parent() making the
  distinction moot.  Note that eventually a css->parent field will be
  added to css and the NULL check in css_parent() will go away.

This patch shouldn't cause any behavior differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.h       |  4 +---
 include/linux/cgroup.h   | 15 +++++++++++++++
 kernel/cgroup_freezer.c  |  8 ++------
 kernel/cpuset.c          |  6 +-----
 kernel/sched/core.c      |  9 +++------
 kernel/sched/cpuacct.c   | 11 ++---------
 mm/hugetlb_cgroup.c      |  6 +-----
 mm/memcontrol.c          | 39 +++++++++++----------------------------
 net/sched/cls_cgroup.c   |  8 +++++---
 security/device_cgroup.c | 18 +++++-------------
 10 files changed, 46 insertions(+), 78 deletions(-)

diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 8e5863e..b6802c4 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -209,9 +209,7 @@ static inline struct blkcg *bio_blkcg(struct bio *bio)
  */
 static inline struct blkcg *blkcg_parent(struct blkcg *blkcg)
 {
-	struct cgroup *pcg = blkcg->css.cgroup->parent;
-
-	return pcg ? cgroup_to_blkcg(pcg) : NULL;
+	return css_to_blkcg(css_parent(&blkcg->css));
 }
 
 /**
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 9c2f9d7..b65f6b5 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -648,6 +648,21 @@ struct cgroup_subsys {
 #undef SUBSYS
 
 /**
+ * css_parent - find the parent css
+ * @css: the target cgroup_subsys_state
+ *
+ * Return the parent css of @css.  This function is guaranteed to return
+ * non-NULL parent as long as @css isn't the root.
+ */
+static inline
+struct cgroup_subsys_state *css_parent(struct cgroup_subsys_state *css)
+{
+	struct cgroup *parent_cgrp = css->cgroup->parent;
+
+	return parent_cgrp ? parent_cgrp->subsys[css->ss->subsys_id] : NULL;
+}
+
+/**
  * cgroup_css - obtain a cgroup's css for the specified subsystem
  * @cgrp: the cgroup of interest
  * @subsys_id: the subsystem of interest
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 1db686e..657a73c 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -62,11 +62,7 @@ static inline struct freezer *task_freezer(struct task_struct *task)
 
 static struct freezer *parent_freezer(struct freezer *freezer)
 {
-	struct cgroup *pcg = freezer->css.cgroup->parent;
-
-	if (pcg)
-		return cgroup_freezer(pcg);
-	return NULL;
+	return css_freezer(css_parent(&freezer->css));
 }
 
 bool cgroup_freezing(struct task_struct *task)
@@ -234,7 +230,7 @@ static void freezer_fork(struct task_struct *task)
 	 * The root cgroup is non-freezable, so we can skip the
 	 * following check.
 	 */
-	if (!freezer->css.cgroup->parent)
+	if (!parent_freezer(freezer))
 		goto out;
 
 	spin_lock_irq(&freezer->lock);
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 6e9cbdd..259a4af 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -133,11 +133,7 @@ static inline struct cpuset *task_cs(struct task_struct *task)
 
 static inline struct cpuset *parent_cs(struct cpuset *cs)
 {
-	struct cgroup *pcgrp = cs->css.cgroup->parent;
-
-	if (pcgrp)
-		return cgroup_cs(pcgrp);
-	return NULL;
+	return css_cs(css_parent(&cs->css));
 }
 
 #ifdef CONFIG_NUMA
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 5bccb02..7a10742 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7114,13 +7114,10 @@ static struct cgroup_subsys_state *cpu_cgroup_css_alloc(struct cgroup *cgrp)
 static int cpu_cgroup_css_online(struct cgroup *cgrp)
 {
 	struct task_group *tg = cgroup_tg(cgrp);
-	struct task_group *parent;
+	struct task_group *parent = css_tg(css_parent(&tg->css));
 
-	if (!cgrp->parent)
-		return 0;
-
-	parent = cgroup_tg(cgrp->parent);
-	sched_online_group(tg, parent);
+	if (parent)
+		sched_online_group(tg, parent);
 	return 0;
 }
 
diff --git a/kernel/sched/cpuacct.c b/kernel/sched/cpuacct.c
index 8ccfa10..f6926a1 100644
--- a/kernel/sched/cpuacct.c
+++ b/kernel/sched/cpuacct.c
@@ -50,16 +50,9 @@ static inline struct cpuacct *task_ca(struct task_struct *tsk)
 	return css_ca(task_css(tsk, cpuacct_subsys_id));
 }
 
-static inline struct cpuacct *__parent_ca(struct cpuacct *ca)
-{
-	return cgroup_ca(ca->css.cgroup->parent);
-}
-
 static inline struct cpuacct *parent_ca(struct cpuacct *ca)
 {
-	if (!ca->css.cgroup->parent)
-		return NULL;
-	return cgroup_ca(ca->css.cgroup->parent);
+	return css_ca(css_parent(&ca->css));
 }
 
 static DEFINE_PER_CPU(u64, root_cpuacct_cpuusage);
@@ -284,7 +277,7 @@ void cpuacct_account_field(struct task_struct *p, int index, u64 val)
 	while (ca != &root_cpuacct) {
 		kcpustat = this_cpu_ptr(ca->cpustat);
 		kcpustat->cpustat[index] += val;
-		ca = __parent_ca(ca);
+		ca = parent_ca(ca);
 	}
 	rcu_read_unlock();
 }
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 95585a0..57ecb5d 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -59,11 +59,7 @@ static inline bool hugetlb_cgroup_is_root(struct hugetlb_cgroup *h_cg)
 static inline struct hugetlb_cgroup *
 parent_hugetlb_cgroup(struct hugetlb_cgroup *h_cg)
 {
-	struct cgroup *parent = h_cg->css.cgroup->parent;
-
-	if (!parent)
-		return NULL;
-	return hugetlb_cgroup_from_cgroup(parent);
+	return hugetlb_cgroup_from_css(css_parent(&h_cg->css));
 }
 
 static inline bool hugetlb_cgroup_have_usage(struct hugetlb_cgroup *h_cg)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 11d659e..69b3e52 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1524,10 +1524,8 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
 
 int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 {
-	struct cgroup *cgrp = memcg->css.cgroup;
-
 	/* root ? */
-	if (cgrp->parent == NULL)
+	if (!css_parent(&memcg->css))
 		return vm_swappiness;
 
 	return memcg->swappiness;
@@ -5026,11 +5024,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 {
 	int retval = 0;
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
-	struct cgroup *parent = cont->parent;
-	struct mem_cgroup *parent_memcg = NULL;
-
-	if (parent)
-		parent_memcg = mem_cgroup_from_cont(parent);
+	struct mem_cgroup *parent_memcg = mem_cgroup_from_css(css_parent(&memcg->css));
 
 	mutex_lock(&memcg_create_mutex);
 
@@ -5282,18 +5276,15 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
 		unsigned long long *mem_limit, unsigned long long *memsw_limit)
 {
-	struct cgroup *cgroup;
 	unsigned long long min_limit, min_memsw_limit, tmp;
 
 	min_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
 	min_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
-	cgroup = memcg->css.cgroup;
 	if (!memcg->use_hierarchy)
 		goto out;
 
-	while (cgroup->parent) {
-		cgroup = cgroup->parent;
-		memcg = mem_cgroup_from_cont(cgroup);
+	while (css_parent(&memcg->css)) {
+		memcg = mem_cgroup_from_css(css_parent(&memcg->css));
 		if (!memcg->use_hierarchy)
 			break;
 		tmp = res_counter_read_u64(&memcg->res, RES_LIMIT);
@@ -5523,16 +5514,11 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 				       u64 val)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
-	struct mem_cgroup *parent;
-
-	if (val > 100)
-		return -EINVAL;
+	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(&memcg->css));
 
-	if (cgrp->parent == NULL)
+	if (val > 100 || !parent)
 		return -EINVAL;
 
-	parent = mem_cgroup_from_cont(cgrp->parent);
-
 	mutex_lock(&memcg_create_mutex);
 
 	/* If under hierarchy, only empty-root can set this value */
@@ -5861,14 +5847,12 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 	struct cftype *cft, u64 val)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
-	struct mem_cgroup *parent;
+	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(&memcg->css));
 
 	/* cannot set to root cgroup and only 0 and 1 are allowed */
-	if (!cgrp->parent || !((val == 0) || (val == 1)))
+	if (!parent || !((val == 0) || (val == 1)))
 		return -EINVAL;
 
-	parent = mem_cgroup_from_cont(cgrp->parent);
-
 	mutex_lock(&memcg_create_mutex);
 	/* oom-kill-disable is a flag for subhierarchy. */
 	if ((parent->use_hierarchy) || memcg_has_children(memcg)) {
@@ -6266,15 +6250,14 @@ free_out:
 static int
 mem_cgroup_css_online(struct cgroup *cont)
 {
-	struct mem_cgroup *memcg, *parent;
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(&memcg->css));
 	int error = 0;
 
-	if (!cont->parent)
+	if (!parent)
 		return 0;
 
 	mutex_lock(&memcg_create_mutex);
-	memcg = mem_cgroup_from_cont(cont);
-	parent = mem_cgroup_from_cont(cont->parent);
 
 	memcg->use_hierarchy = parent->use_hierarchy;
 	memcg->oom_kill_disable = parent->oom_kill_disable;
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index af412ab..9e6b75e 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -50,9 +50,11 @@ static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
 
 static int cgrp_css_online(struct cgroup *cgrp)
 {
-	if (cgrp->parent)
-		cgrp_cls_state(cgrp)->classid =
-			cgrp_cls_state(cgrp->parent)->classid;
+	struct cgroup_cls_state *cs = cgrp_cls_state(cgrp);
+	struct cgroup_cls_state *parent = css_cls_state(css_parent(&cs->css));
+
+	if (parent)
+		cs->classid = parent->classid;
 	return 0;
 }
 
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 9095364..635a49d 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -198,13 +198,11 @@ static inline bool is_devcg_online(const struct dev_cgroup *devcg)
  */
 static int devcgroup_online(struct cgroup *cgroup)
 {
-	struct dev_cgroup *dev_cgroup, *parent_dev_cgroup = NULL;
+	struct dev_cgroup *dev_cgroup = cgroup_to_devcgroup(cgroup);
+	struct dev_cgroup *parent_dev_cgroup = css_to_devcgroup(css_parent(&dev_cgroup->css));
 	int ret = 0;
 
 	mutex_lock(&devcgroup_mutex);
-	dev_cgroup = cgroup_to_devcgroup(cgroup);
-	if (cgroup->parent)
-		parent_dev_cgroup = cgroup_to_devcgroup(cgroup->parent);
 
 	if (parent_dev_cgroup == NULL)
 		dev_cgroup->behavior = DEVCG_DEFAULT_ALLOW;
@@ -394,12 +392,10 @@ static bool may_access(struct dev_cgroup *dev_cgroup,
 static int parent_has_perm(struct dev_cgroup *childcg,
 				  struct dev_exception_item *ex)
 {
-	struct cgroup *pcg = childcg->css.cgroup->parent;
-	struct dev_cgroup *parent;
+	struct dev_cgroup *parent = css_to_devcgroup(css_parent(&childcg->css));
 
-	if (!pcg)
+	if (!parent)
 		return 1;
-	parent = cgroup_to_devcgroup(pcg);
 	return may_access(parent, ex, childcg->behavior);
 }
 
@@ -524,15 +520,11 @@ static int devcgroup_update_access(struct dev_cgroup *devcgroup,
 	char temp[12];		/* 11 + 1 characters needed for a u32 */
 	int count, rc = 0;
 	struct dev_exception_item ex;
-	struct cgroup *p = devcgroup->css.cgroup;
-	struct dev_cgroup *parent = NULL;
+	struct dev_cgroup *parent = css_to_devcgroup(css_parent(&devcgroup->css));
 
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	if (p->parent)
-		parent = cgroup_to_devcgroup(p->parent);
-
 	memset(&ex, 0, sizeof(ex));
 	b = buffer;
 
-- 
1.8.3.1
