From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/2] cgroup, cpuset: remove cgroup_subsys->post_clone()
Date: Tue, 13 Nov 2012 12:27:45 -0800
Message-ID: <20121113202745.GB21185@mtj.dyndns.org>
References: <20121113202714.GA21185@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121113202714.GA21185-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From bbf2566f9f4fc79ff3320e83cafb69533efc9ea0 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Tue, 13 Nov 2012 12:21:50 -0800

Currently CGRP_CPUSET_CLONE_CHILDREN triggers ->post_clone().  Now
that clone_children is cpuset specific, there's no reason to have this
rather odd option activation mechanism in cgroup core.  cpuset can
check the flag from its ->css_allocate() and take the necessary
action.

Move cpuset_post_clone() logic to the end of cpuset_css_alloc() and
remove cgroup_subsys->post_clone().

Loosely based on Glauber's "generalize post_clone into post_create"
patch.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Original-patch-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Original-patch: <1351686554-22592-2-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |  8 ----
 include/linux/cgroup.h            |  1 -
 kernel/cgroup.c                   |  4 --
 kernel/cpuset.c                   | 80 ++++++++++++++++++---------------------
 4 files changed, 36 insertions(+), 57 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 24cdf76..bcf1a00 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -642,14 +642,6 @@ void exit(struct task_struct *task)
 
 Called during task exit.
 
-void post_clone(struct cgroup *cgrp)
-(cgroup_mutex held by caller)
-
-Called during cgroup_create() to do any parameter
-initialization which might be required before a task could attach.  For
-example, in cpusets, no task may attach before 'cpus' and 'mems' are set
-up.
-
 void bind(struct cgroup *root)
 (cgroup_mutex held by caller)
 
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 926d8d1..d5fc8a7 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -449,7 +449,6 @@ struct cgroup_subsys {
 	void (*fork)(struct task_struct *task);
 	void (*exit)(struct cgroup *cgrp, struct cgroup *old_cgrp,
 		     struct task_struct *task);
-	void (*post_clone)(struct cgroup *cgrp);
 	void (*bind)(struct cgroup *root);
 
 	int subsys_id;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a49572e..35aa18b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4142,10 +4142,6 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 			if (err)
 				goto err_free_all;
 		}
-		/* At error, ->css_free() callback has to free assigned ID. */
-		if (test_bit(CGRP_CPUSET_CLONE_CHILDREN, &parent->flags) &&
-		    ss->post_clone)
-			ss->post_clone(cgrp);
 
 		if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
 		    parent->parent) {
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 0693133..b017887 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1784,56 +1784,20 @@ static struct cftype files[] = {
 };
 
 /*
- * post_clone() is called during cgroup_create() when the
- * clone_children mount argument was specified.  The cgroup
- * can not yet have any tasks.
- *
- * Currently we refuse to set up the cgroup - thereby
- * refusing the task to be entered, and as a result refusing
- * the sys_unshare() or clone() which initiated it - if any
- * sibling cpusets have exclusive cpus or mem.
- *
- * If this becomes a problem for some users who wish to
- * allow that scenario, then cpuset_post_clone() could be
- * changed to grant parent->cpus_allowed-sibling_cpus_exclusive
- * (and likewise for mems) to the new cgroup. Called with cgroup_mutex
- * held.
- */
-static void cpuset_post_clone(struct cgroup *cgroup)
-{
-	struct cgroup *parent, *child;
-	struct cpuset *cs, *parent_cs;
-
-	parent = cgroup->parent;
-	list_for_each_entry(child, &parent->children, sibling) {
-		cs = cgroup_cs(child);
-		if (is_mem_exclusive(cs) || is_cpu_exclusive(cs))
-			return;
-	}
-	cs = cgroup_cs(cgroup);
-	parent_cs = cgroup_cs(parent);
-
-	mutex_lock(&callback_mutex);
-	cs->mems_allowed = parent_cs->mems_allowed;
-	cpumask_copy(cs->cpus_allowed, parent_cs->cpus_allowed);
-	mutex_unlock(&callback_mutex);
-	return;
-}
-
-/*
  *	cpuset_css_alloc - allocate a cpuset css
  *	cont:	control group that the new cpuset will be part of
  */
 
 static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cont)
 {
-	struct cpuset *cs;
-	struct cpuset *parent;
+	struct cgroup *parent_cg = cont->parent;
+	struct cgroup *tmp_cg;
+	struct cpuset *parent, *cs;
 
-	if (!cont->parent) {
+	if (!parent_cg)
 		return &top_cpuset.css;
-	}
-	parent = cgroup_cs(cont->parent);
+	parent = cgroup_cs(parent_cg);
+
 	cs = kmalloc(sizeof(*cs), GFP_KERNEL);
 	if (!cs)
 		return ERR_PTR(-ENOMEM);
@@ -1855,7 +1819,36 @@ static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cont)
 
 	cs->parent = parent;
 	number_of_cpusets++;
-	return &cs->css ;
+
+	if (!test_bit(CGRP_CPUSET_CLONE_CHILDREN, &cont->flags))
+		goto skip_clone;
+
+	/*
+	 * Clone @parent's configuration if CGRP_CPUSET_CLONE_CHILDREN is
+	 * set.  This flag handling is implemented in cgroup core for
+	 * histrical reasons - the flag may be specified during mount.
+	 *
+	 * Currently, if any sibling cpusets have exclusive cpus or mem, we
+	 * refuse to clone the configuration - thereby refusing the task to
+	 * be entered, and as a result refusing the sys_unshare() or
+	 * clone() which initiated it.  If this becomes a problem for some
+	 * users who wish to allow that scenario, then this could be
+	 * changed to grant parent->cpus_allowed-sibling_cpus_exclusive
+	 * (and likewise for mems) to the new cgroup.
+	 */
+	list_for_each_entry(tmp_cg, &parent_cg->children, sibling) {
+		struct cpuset *tmp_cs = cgroup_cs(tmp_cg);
+
+		if (is_mem_exclusive(tmp_cs) || is_cpu_exclusive(tmp_cs))
+			goto skip_clone;
+	}
+
+	mutex_lock(&callback_mutex);
+	cs->mems_allowed = parent->mems_allowed;
+	cpumask_copy(cs->cpus_allowed, parent->cpus_allowed);
+	mutex_unlock(&callback_mutex);
+skip_clone:
+	return &cs->css;
 }
 
 /*
@@ -1882,7 +1875,6 @@ struct cgroup_subsys cpuset_subsys = {
 	.css_free = cpuset_css_free,
 	.can_attach = cpuset_can_attach,
 	.attach = cpuset_attach,
-	.post_clone = cpuset_post_clone,
 	.subsys_id = cpuset_subsys_id,
 	.base_cftypes = files,
 	.early_init = 1,
-- 
1.7.11.7
