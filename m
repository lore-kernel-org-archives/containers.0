From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 03/13] cpuset: introduce ->css_on/offline()
Date: Wed, 28 Nov 2012 13:34:10 -0800
Message-ID: <1354138460-19286-4-git-send-email-tj__45042.7399286584$1354138514$gmane$org@kernel.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1354138460-19286-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Add cpuset_css_on/offline() and rearrange css init/exit such that,

* Allocation and clearing to the default values happen in css_alloc().
  Allocation now uses kzalloc().

* Config inheritance and registration happen in css_online().

* css_offline() undoes what css_online() did.

* css_free() frees.

This doesn't introduce any visible behavior changes.  This will help
cleaning up locking.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cpuset.c | 66 ++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 44 insertions(+), 22 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 54b2b73..70197ba 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1790,15 +1790,12 @@ static struct cftype files[] = {
 
 static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cont)
 {
-	struct cgroup *parent_cg = cont->parent;
-	struct cgroup *tmp_cg;
-	struct cpuset *parent, *cs;
+	struct cpuset *cs;
 
-	if (!parent_cg)
+	if (!cont->parent)
 		return &top_cpuset.css;
-	parent = cgroup_cs(parent_cg);
 
-	cs = kmalloc(sizeof(*cs), GFP_KERNEL);
+	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
 	if (!cs)
 		return ERR_PTR(-ENOMEM);
 	if (!alloc_cpumask_var(&cs->cpus_allowed, GFP_KERNEL)) {
@@ -1806,22 +1803,34 @@ static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cont)
 		return ERR_PTR(-ENOMEM);
 	}
 
-	cs->flags = 0;
-	if (is_spread_page(parent))
-		set_bit(CS_SPREAD_PAGE, &cs->flags);
-	if (is_spread_slab(parent))
-		set_bit(CS_SPREAD_SLAB, &cs->flags);
 	set_bit(CS_SCHED_LOAD_BALANCE, &cs->flags);
 	cpumask_clear(cs->cpus_allowed);
 	nodes_clear(cs->mems_allowed);
 	fmeter_init(&cs->fmeter);
 	cs->relax_domain_level = -1;
+	cs->parent = cgroup_cs(cont->parent);
+
+	return &cs->css;
+}
+
+static int cpuset_css_online(struct cgroup *cgrp)
+{
+	struct cpuset *cs = cgroup_cs(cgrp);
+	struct cpuset *parent = cs->parent;
+	struct cgroup *tmp_cg;
+
+	if (!parent)
+		return 0;
+
+	if (is_spread_page(parent))
+		set_bit(CS_SPREAD_PAGE, &cs->flags);
+	if (is_spread_slab(parent))
+		set_bit(CS_SPREAD_SLAB, &cs->flags);
 
-	cs->parent = parent;
 	number_of_cpusets++;
 
-	if (!test_bit(CGRP_CPUSET_CLONE_CHILDREN, &cont->flags))
-		goto skip_clone;
+	if (!test_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags))
+		return 0;
 
 	/*
 	 * Clone @parent's configuration if CGRP_CPUSET_CLONE_CHILDREN is
@@ -1836,19 +1845,34 @@ static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cont)
 	 * changed to grant parent->cpus_allowed-sibling_cpus_exclusive
 	 * (and likewise for mems) to the new cgroup.
 	 */
-	list_for_each_entry(tmp_cg, &parent_cg->children, sibling) {
+	list_for_each_entry(tmp_cg, &cgrp->parent->children, sibling) {
 		struct cpuset *tmp_cs = cgroup_cs(tmp_cg);
 
 		if (is_mem_exclusive(tmp_cs) || is_cpu_exclusive(tmp_cs))
-			goto skip_clone;
+			return 0;
 	}
 
 	mutex_lock(&callback_mutex);
 	cs->mems_allowed = parent->mems_allowed;
 	cpumask_copy(cs->cpus_allowed, parent->cpus_allowed);
 	mutex_unlock(&callback_mutex);
-skip_clone:
-	return &cs->css;
+
+	return 0;
+}
+
+static void cpuset_css_offline(struct cgroup *cgrp)
+{
+	struct cpuset *cs = cgroup_cs(cgrp);
+
+	/* css_offline is called w/o cgroup_mutex, grab it */
+	cgroup_lock();
+
+	if (is_sched_load_balance(cs))
+		update_flag(CS_SCHED_LOAD_BALANCE, cs, 0);
+
+	number_of_cpusets--;
+
+	cgroup_unlock();
 }
 
 /*
@@ -1861,10 +1885,6 @@ static void cpuset_css_free(struct cgroup *cont)
 {
 	struct cpuset *cs = cgroup_cs(cont);
 
-	if (is_sched_load_balance(cs))
-		update_flag(CS_SCHED_LOAD_BALANCE, cs, 0);
-
-	number_of_cpusets--;
 	free_cpumask_var(cs->cpus_allowed);
 	kfree(cs);
 }
@@ -1872,6 +1892,8 @@ static void cpuset_css_free(struct cgroup *cont)
 struct cgroup_subsys cpuset_subsys = {
 	.name = "cpuset",
 	.css_alloc = cpuset_css_alloc,
+	.css_online = cpuset_css_online,
+	.css_offline = cpuset_css_offline,
 	.css_free = cpuset_css_free,
 	.can_attach = cpuset_can_attach,
 	.attach = cpuset_attach,
-- 
1.7.11.7
