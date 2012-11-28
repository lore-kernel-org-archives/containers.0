From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/3] cpuset: replace cpuset->stack_list with
	cpuset_for_each_descendant_pre()
Date: Wed, 28 Nov 2012 14:27:00 -0800
Message-ID: <1354141621-11906-3-git-send-email-tj@kernel.org>
References: <1354141621-11906-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1354141621-11906-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Implement cpuset_for_each_descendant_pre() and replace the
cpuset-specific tree walking using cpuset->stack_list with it.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cpuset.c | 123 ++++++++++++++++++++++----------------------------------
 1 file changed, 48 insertions(+), 75 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 2ee0e03..3a01730 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -103,9 +103,6 @@ struct cpuset {
 	/* for custom sched domain */
 	int relax_domain_level;
 
-	/* used for walking a cpuset hierarchy */
-	struct list_head stack_list;
-
 	struct work_struct hotplug_work;
 };
 
@@ -207,6 +204,20 @@ static struct cpuset top_cpuset = {
 	cgroup_for_each_child((pos_cgrp), (parent_cs)->css.cgroup)	\
 		if (is_cpuset_online(((child_cs) = cgroup_cs((pos_cgrp)))))
 
+/**
+ * cpuset_for_each_descendant_pre - pre-order walk of a cpuset's descendants
+ * @des_cs: loop cursor pointing to the current descendant
+ * @pos_cgrp: used for iteration
+ * @root_cs: target cpuset to walk ancestor of
+ *
+ * Walk @des_cs through the online descendants of @root_cs.  Must be used
+ * with RCU read locked.  The caller may modify @pos_cgrp by calling
+ * cgroup_rightmost_descendant() to skip subtree.
+ */
+#define cpuset_for_each_descendant_pre(des_cs, pos_cgrp, root_cs)	\
+	cgroup_for_each_descendant_pre((pos_cgrp), (root_cs)->css.cgroup) \
+		if (is_cpuset_online(((des_cs) = cgroup_cs((pos_cgrp)))))
+
 /*
  * There are two global mutexes guarding cpuset structures - cpuset_mutex
  * and callback_mutex.  The latter may nest inside the former.  We also
@@ -507,31 +518,24 @@ update_domain_attr(struct sched_domain_attr *dattr, struct cpuset *c)
 	return;
 }
 
-static void
-update_domain_attr_tree(struct sched_domain_attr *dattr, struct cpuset *c)
+static void update_domain_attr_tree(struct sched_domain_attr *dattr,
+				    struct cpuset *root_cs)
 {
-	LIST_HEAD(q);
-
-	list_add(&c->stack_list, &q);
-	while (!list_empty(&q)) {
-		struct cpuset *cp;
-		struct cgroup *cont;
-		struct cpuset *child;
-
-		cp = list_first_entry(&q, struct cpuset, stack_list);
-		list_del(q.next);
+	struct cpuset *cp;
+	struct cgroup *pos_cgrp;
 
-		if (cpumask_empty(cp->cpus_allowed))
+	rcu_read_lock();
+	cpuset_for_each_descendant_pre(cp, pos_cgrp, root_cs) {
+		/* skip the whole subtree if @cp doesn't have any CPU */
+		if (cpumask_empty(cp->cpus_allowed)) {
+			pos_cgrp = cgroup_rightmost_descendant(pos_cgrp);
 			continue;
+		}
 
 		if (is_sched_load_balance(cp))
 			update_domain_attr(dattr, cp);
-
-		rcu_read_lock();
-		cpuset_for_each_child(child, cont, cp)
-			list_add_tail(&child->stack_list, &q);
-		rcu_read_unlock();
 	}
+	rcu_read_unlock();
 }
 
 /*
@@ -591,7 +595,6 @@ update_domain_attr_tree(struct sched_domain_attr *dattr, struct cpuset *c)
 static int generate_sched_domains(cpumask_var_t **domains,
 			struct sched_domain_attr **attributes)
 {
-	LIST_HEAD(q);		/* queue of cpusets to be scanned */
 	struct cpuset *cp;	/* scans q */
 	struct cpuset **csa;	/* array of all cpuset ptrs */
 	int csn;		/* how many cpuset ptrs in csa so far */
@@ -600,6 +603,7 @@ static int generate_sched_domains(cpumask_var_t **domains,
 	struct sched_domain_attr *dattr;  /* attributes for custom domains */
 	int ndoms = 0;		/* number of sched domains in result */
 	int nslot;		/* next empty doms[] struct cpumask slot */
+	struct cgroup *pos_cgrp;
 
 	doms = NULL;
 	dattr = NULL;
@@ -627,33 +631,27 @@ static int generate_sched_domains(cpumask_var_t **domains,
 		goto done;
 	csn = 0;
 
-	list_add(&top_cpuset.stack_list, &q);
-	while (!list_empty(&q)) {
-		struct cgroup *cont;
-		struct cpuset *child;   /* scans child cpusets of cp */
-
-		cp = list_first_entry(&q, struct cpuset, stack_list);
-		list_del(q.next);
-
-		if (cpumask_empty(cp->cpus_allowed))
-			continue;
-
+	rcu_read_lock();
+	cpuset_for_each_descendant_pre(cp, pos_cgrp, &top_cpuset) {
 		/*
-		 * All child cpusets contain a subset of the parent's cpus, so
-		 * just skip them, and then we call update_domain_attr_tree()
-		 * to calc relax_domain_level of the corresponding sched
-		 * domain.
+		 * Continue traversing beyond @cp iff @cp has some CPUs and
+		 * isn't load balancing.  The former is obvious.  The
+		 * latter: All child cpusets contain a subset of the
+		 * parent's cpus, so just skip them, and then we call
+		 * update_domain_attr_tree() to calc relax_domain_level of
+		 * the corresponding sched domain.
 		 */
-		if (is_sched_load_balance(cp)) {
-			csa[csn++] = cp;
+		if (!cpumask_empty(cp->cpus_allowed) &&
+		    !is_sched_load_balance(cp))
 			continue;
-		}
 
-		rcu_read_lock();
-		cpuset_for_each_child(child, cont, cp)
-			list_add_tail(&child->stack_list, &q);
-		rcu_read_unlock();
-  	}
+		if (is_sched_load_balance(cp))
+			csa[csn++] = cp;
+
+		/* skip @cp's subtree */
+		pos_cgrp = cgroup_rightmost_descendant(pos_cgrp);
+	}
+	rcu_read_unlock();
 
 	for (i = 0; i < csn; i++)
 		csa[i]->pn = i;
@@ -2059,31 +2057,6 @@ static void remove_tasks_in_empty_cpuset(struct cpuset *cs)
 	move_member_tasks_to_cpuset(cs, parent);
 }
 
-/*
- * Helper function to traverse cpusets.
- * It can be used to walk the cpuset tree from top to bottom, completing
- * one layer before dropping down to the next (thus always processing a
- * node before any of its children).
- */
-static struct cpuset *cpuset_next(struct list_head *queue)
-{
-	struct cpuset *cp;
-	struct cpuset *child;	/* scans child cpusets of cp */
-	struct cgroup *cont;
-
-	if (list_empty(queue))
-		return NULL;
-
-	cp = list_first_entry(queue, struct cpuset, stack_list);
-	list_del(queue->next);
-	rcu_read_lock();
-	cpuset_for_each_child(child, cont, cp)
-		list_add_tail(&child->stack_list, queue);
-	rcu_read_unlock();
-
-	return cp;
-}
-
 /**
  * cpuset_propagate_hotplug_workfn - propagate CPU/memory hotplug to a cpuset
  * @cs: cpuset in interest
@@ -2220,12 +2193,12 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 	/* if cpus or mems went down, we need to propagate to descendants */
 	if (cpus_offlined || mems_offlined) {
 		struct cpuset *cs;
-		LIST_HEAD(queue);
+		struct cgroup *pos_cgrp;
 
-		list_add_tail(&top_cpuset.stack_list, &queue);
-		while ((cs = cpuset_next(&queue)))
-			if (cs != &top_cpuset)
-				schedule_cpuset_propagate_hotplug(cs);
+		rcu_read_lock();
+		cpuset_for_each_descendant_pre(cs, pos_cgrp, &top_cpuset)
+			schedule_cpuset_propagate_hotplug(cs);
+		rcu_read_unlock();
 	}
 
 	mutex_unlock(&cpuset_mutex);
-- 
1.7.11.7
