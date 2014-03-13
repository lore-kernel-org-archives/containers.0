From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 03/11] cgroup: reorganize cgroup bootstrapping
Date: Thu, 13 Mar 2014 15:50:05 -0400
Message-ID: <1394740213-17626-4-git-send-email-tj__22943.5798632496$1394740261$gmane$org@kernel.org>
References: <1394740213-17626-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1394740213-17626-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

* Fields of init_css_set and css_set_count are now set using
  initializer instead of programmatically from cgroup_init_early().

* init_cgroup_root() now also takes @opts and performs the optional
  part of initialization too.  The leftover part of
  cgroup_root_from_opts() is collapsed into its only caller -
  cgroup_mount().

* Initialization of cgroup_root_count and linking of init_css_set are
  moved from cgroup_init_early() to to cgroup_init().  None of the
  early_init users depends on init_css_set being linked.

* Subsystem initializations are moved after dummy hierarchy init and
  init_css_set linking.

These changes reorganize the bootstrap logic so that the dummy
hierarchy can share the usual hierarchy init path and be made more
normal.  These changes don't make noticeable behavior changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 100 +++++++++++++++++++++++++++-----------------------------
 1 file changed, 49 insertions(+), 51 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7bf1459..12a0bda 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -338,16 +338,24 @@ struct cgrp_cset_link {
 	struct list_head	cgrp_link;
 };
 
-/* The default css_set - used by init and its children prior to any
+/*
+ * The default css_set - used by init and its children prior to any
  * hierarchies being mounted. It contains a pointer to the root state
  * for each subsystem. Also used to anchor the list of css_sets. Not
  * reference-counted, to improve performance when child cgroups
  * haven't been created.
  */
+static struct css_set init_css_set = {
+	.refcount		= ATOMIC_INIT(1),
+	.cgrp_links		= LIST_HEAD_INIT(init_css_set.cgrp_links),
+	.tasks			= LIST_HEAD_INIT(init_css_set.tasks),
+	.mg_tasks		= LIST_HEAD_INIT(init_css_set.mg_tasks),
+	.mg_preload_node	= LIST_HEAD_INIT(init_css_set.mg_preload_node),
+	.mg_node		= LIST_HEAD_INIT(init_css_set.mg_node),
+};
 
-static struct css_set init_css_set;
 static struct cgrp_cset_link init_cgrp_cset_link;
-static int css_set_count;
+static int css_set_count	= 1;	/* 1 for init_css_set */
 
 /*
  * hash table for cgroup groups. This improves the performance to find
@@ -1352,7 +1360,8 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	cgrp->dummy_css.cgroup = cgrp;
 }
 
-static void init_cgroup_root(struct cgroupfs_root *root)
+static void init_cgroup_root(struct cgroupfs_root *root,
+			     struct cgroup_sb_opts *opts)
 {
 	struct cgroup *cgrp = &root->top_cgroup;
 
@@ -1361,20 +1370,6 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 	cgrp->root = root;
 	init_cgroup_housekeeping(cgrp);
 	idr_init(&root->cgroup_idr);
-}
-
-static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
-{
-	struct cgroupfs_root *root;
-
-	if (!opts->subsys_mask && !opts->none)
-		return ERR_PTR(-EINVAL);
-
-	root = kzalloc(sizeof(*root), GFP_KERNEL);
-	if (!root)
-		return ERR_PTR(-ENOMEM);
-
-	init_cgroup_root(root);
 
 	root->flags = opts->flags;
 	if (opts->release_agent)
@@ -1383,7 +1378,6 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
 		strcpy(root->name, opts->name);
 	if (opts->cpuset_clone_children)
 		set_bit(CGRP_CPUSET_CLONE_CHILDREN, &root->top_cgroup.flags);
-	return root;
 }
 
 static int cgroup_setup_root(struct cgroupfs_root *root, unsigned long ss_mask)
@@ -1548,13 +1542,24 @@ retry:
 		goto out_unlock;
 	}
 
-	/* no such thing, create a new one */
-	root = cgroup_root_from_opts(&opts);
-	if (IS_ERR(root)) {
-		ret = PTR_ERR(root);
+	/*
+	 * No such thing, create a new one.  name= matching without subsys
+	 * specification is allowed for already existing hierarchies but we
+	 * can't create new one without subsys specification.
+	 */
+	if (!opts.subsys_mask && !opts.none) {
+		ret = -EINVAL;
+		goto out_unlock;
+	}
+
+	root = kzalloc(sizeof(*root), GFP_KERNEL);
+	if (!root) {
+		ret = -ENOMEM;
 		goto out_unlock;
 	}
 
+	init_cgroup_root(root, &opts);
+
 	ret = cgroup_setup_root(root, opts.subsys_mask);
 	if (ret)
 		cgroup_free_root(root);
@@ -4030,26 +4035,13 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
  */
 int __init cgroup_init_early(void)
 {
+	static struct cgroup_sb_opts __initdata opts = { };
 	struct cgroup_subsys *ss;
 	int i;
 
-	atomic_set(&init_css_set.refcount, 1);
-	INIT_LIST_HEAD(&init_css_set.cgrp_links);
-	INIT_LIST_HEAD(&init_css_set.tasks);
-	INIT_LIST_HEAD(&init_css_set.mg_tasks);
-	INIT_LIST_HEAD(&init_css_set.mg_preload_node);
-	INIT_LIST_HEAD(&init_css_set.mg_node);
-	INIT_HLIST_NODE(&init_css_set.hlist);
-	css_set_count = 1;
-	init_cgroup_root(&cgroup_dummy_root);
-	cgroup_root_count = 1;
+	init_cgroup_root(&cgroup_dummy_root, &opts);
 	RCU_INIT_POINTER(init_task.cgroups, &init_css_set);
 
-	init_cgrp_cset_link.cset = &init_css_set;
-	init_cgrp_cset_link.cgrp = cgroup_dummy_top;
-	list_add(&init_cgrp_cset_link.cset_link, &cgroup_dummy_top->cset_links);
-	list_add(&init_cgrp_cset_link.cgrp_link, &init_css_set.cgrp_links);
-
 	for_each_subsys(ss, i) {
 		WARN(!ss->css_alloc || !ss->css_free || ss->name || ss->id,
 		     "invalid cgroup_subsys %d:%s css_alloc=%p css_free=%p name:id=%d:%s\n",
@@ -4077,22 +4069,10 @@ int __init cgroup_init(void)
 {
 	struct cgroup_subsys *ss;
 	unsigned long key;
-	int i, err;
+	int ssid, err;
 
 	BUG_ON(cgroup_init_cftypes(NULL, cgroup_base_files));
 
-	for_each_subsys(ss, i) {
-		if (!ss->early_init)
-			cgroup_init_subsys(ss);
-
-		/*
-		 * cftype registration needs kmalloc and can't be done
-		 * during early_init.  Register base cftypes separately.
-		 */
-		if (ss->base_cftypes)
-			WARN_ON(cgroup_add_cftypes(ss, ss->base_cftypes));
-	}
-
 	/* allocate id for the dummy hierarchy */
 	mutex_lock(&cgroup_mutex);
 
@@ -4106,8 +4086,26 @@ int __init cgroup_init(void)
 			0, 1, GFP_KERNEL);
 	BUG_ON(err < 0);
 
+	cgroup_root_count = 1;
+	init_cgrp_cset_link.cset = &init_css_set;
+	init_cgrp_cset_link.cgrp = cgroup_dummy_top;
+	list_add(&init_cgrp_cset_link.cset_link, &cgroup_dummy_top->cset_links);
+	list_add(&init_cgrp_cset_link.cgrp_link, &init_css_set.cgrp_links);
+
 	mutex_unlock(&cgroup_mutex);
 
+	for_each_subsys(ss, ssid) {
+		if (!ss->early_init)
+			cgroup_init_subsys(ss);
+
+		/*
+		 * cftype registration needs kmalloc and can't be done
+		 * during early_init.  Register base cftypes separately.
+		 */
+		if (ss->base_cftypes)
+			WARN_ON(cgroup_add_cftypes(ss, ss->base_cftypes));
+	}
+
 	cgroup_kobj = kobject_create_and_add("cgroup", fs_kobj);
 	if (!cgroup_kobj)
 		return -ENOMEM;
-- 
1.8.5.3
