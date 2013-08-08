From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 07/14] cgroup: reorganize css init / exit paths
Date: Thu,  8 Aug 2013 16:13:44 -0400
Message-ID: <1375992831-4650-8-git-send-email-tj@kernel.org>
References: <1375992831-4650-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375992831-4650-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

css (cgroup_subsys_state) lifetime management is about to be
restructured.  In prepartion, make the following mostly trivial
changes.

* init_cgroup_css() is renamed to init_css() so that it's consistent
  with other css handling functions.

* alloc_css_id(), online_css() and offline_css() updated to take @css
  instead of cgroups and subsys IDs.

* Merge two separate loops - one around percpu_ref_get() and the other
  around online_css() - into one.  This changes the order of
  operations a bit without any consequences.

The first two changes don't make any functional differences and while
the last one does change behavior, it is of no consequence.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 60 +++++++++++++++++++++++++--------------------------------
 1 file changed, 26 insertions(+), 34 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index c271016..2a93bae 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -838,8 +838,7 @@ static struct backing_dev_info cgroup_backing_dev_info = {
 	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
 };
 
-static int alloc_css_id(struct cgroup_subsys *ss,
-			struct cgroup *parent, struct cgroup *child);
+static int alloc_css_id(struct cgroup_subsys_state *child_css);
 
 static struct inode *cgroup_new_inode(umode_t mode, struct super_block *sb)
 {
@@ -4308,9 +4307,8 @@ static void css_release(struct percpu_ref *ref)
 	schedule_work(&css->destroy_work);
 }
 
-static void init_cgroup_css(struct cgroup_subsys_state *css,
-			       struct cgroup_subsys *ss,
-			       struct cgroup *cgrp)
+static void init_css(struct cgroup_subsys_state *css, struct cgroup_subsys *ss,
+		     struct cgroup *cgrp)
 {
 	css->cgroup = cgrp;
 	css->ss = ss;
@@ -4327,9 +4325,9 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 }
 
 /* invoke ->css_online() on a new CSS and mark it online if successful */
-static int online_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
+static int online_css(struct cgroup_subsys_state *css)
 {
-	struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
+	struct cgroup_subsys *ss = css->ss;
 	int ret = 0;
 
 	lockdep_assert_held(&cgroup_mutex);
@@ -4342,9 +4340,9 @@ static int online_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
 }
 
 /* if the CSS is online, invoke ->css_offline() on it and mark it offline */
-static void offline_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
+static void offline_css(struct cgroup_subsys_state *css)
 {
-	struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
+	struct cgroup_subsys *ss = css->ss;
 
 	lockdep_assert_held(&cgroup_mutex);
 
@@ -4442,10 +4440,10 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 			goto err_free_all;
 		}
 
-		init_cgroup_css(css, ss, cgrp);
+		init_css(css, ss, cgrp);
 
 		if (ss->use_id) {
-			err = alloc_css_id(ss, parent, cgrp);
+			err = alloc_css_id(css);
 			if (err)
 				goto err_free_all;
 		}
@@ -4467,20 +4465,18 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	list_add_tail_rcu(&cgrp->sibling, &cgrp->parent->children);
 	root->number_of_cgroups++;
 
-	/* each css holds a ref to the cgroup's dentry and the parent css */
+	/* hold a ref to the parent's dentry */
+	dget(parent->dentry);
+
 	for_each_root_subsys(root, ss) {
 		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
 
+		/* each css holds a ref to the cgroup and the parent css */
 		dget(dentry);
 		percpu_ref_get(&css->parent->refcnt);
-	}
 
-	/* hold a ref to the parent's dentry */
-	dget(parent->dentry);
-
-	/* creation succeeded, notify subsystems */
-	for_each_root_subsys(root, ss) {
-		err = online_css(ss, cgrp);
+		/* creation succeeded, notify subsystems */
+		err = online_css(css);
 		if (err)
 			goto err_destroy;
 
@@ -4700,7 +4696,7 @@ static void cgroup_offline_fn(struct work_struct *work)
 	 * initate destruction.
 	 */
 	for_each_root_subsys(cgrp->root, ss)
-		offline_css(ss, cgrp);
+		offline_css(cgroup_css(cgrp, ss->subsys_id));
 
 	/*
 	 * Put the css refs from cgroup_destroy_locked().  Each css holds
@@ -4778,7 +4774,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	css = ss->css_alloc(cgroup_css(cgroup_dummy_top, ss->subsys_id));
 	/* We don't handle early failures gracefully */
 	BUG_ON(IS_ERR(css));
-	init_cgroup_css(css, ss, cgroup_dummy_top);
+	init_css(css, ss, cgroup_dummy_top);
 
 	/* Update the init_css_set to contain a subsys
 	 * pointer to this state - since the subsystem is
@@ -4793,7 +4789,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	 * need to invoke fork callbacks here. */
 	BUG_ON(!list_empty(&init_task.tasks));
 
-	BUG_ON(online_css(ss, cgroup_dummy_top));
+	BUG_ON(online_css(cgroup_css(cgroup_dummy_top, ss->subsys_id)));
 
 	mutex_unlock(&cgroup_mutex);
 
@@ -4866,8 +4862,8 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	ss->root = &cgroup_dummy_root;
 
 	/* our new subsystem will be attached to the dummy hierarchy. */
-	init_cgroup_css(css, ss, cgroup_dummy_top);
-	/* init_idr must be after init_cgroup_css because it sets css->id. */
+	init_css(css, ss, cgroup_dummy_top);
+	/* init_idr must be after init_css() because it sets css->id. */
 	if (ss->use_id) {
 		ret = cgroup_init_idr(ss, css);
 		if (ret)
@@ -4897,7 +4893,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	}
 	write_unlock(&css_set_lock);
 
-	ret = online_css(ss, cgroup_dummy_top);
+	ret = online_css(cgroup_css(cgroup_dummy_top, ss->subsys_id));
 	if (ret)
 		goto err_unload;
 
@@ -4936,7 +4932,7 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 
 	mutex_lock(&cgroup_mutex);
 
-	offline_css(ss, cgroup_dummy_top);
+	offline_css(cgroup_css(cgroup_dummy_top, ss->subsys_id));
 
 	if (ss->use_id)
 		idr_destroy(&ss->idr);
@@ -5588,20 +5584,16 @@ static int __init_or_module cgroup_init_idr(struct cgroup_subsys *ss,
 	return 0;
 }
 
-static int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *parent,
-			struct cgroup *child)
+static int alloc_css_id(struct cgroup_subsys_state *child_css)
 {
-	int subsys_id, i, depth = 0;
-	struct cgroup_subsys_state *parent_css, *child_css;
+	struct cgroup_subsys_state *parent_css = css_parent(child_css);
 	struct css_id *child_id, *parent_id;
+	int i, depth;
 
-	subsys_id = ss->subsys_id;
-	parent_css = cgroup_css(parent, subsys_id);
-	child_css = cgroup_css(child, subsys_id);
 	parent_id = rcu_dereference_protected(parent_css->id, true);
 	depth = parent_id->depth + 1;
 
-	child_id = get_new_cssid(ss, depth);
+	child_id = get_new_cssid(child_css->ss, depth);
 	if (IS_ERR(child_id))
 		return PTR_ERR(child_id);
 
-- 
1.8.3.1
