From: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/4] cgroup: convert from per-cgroup id to per-subsys id
Date: Tue, 22 Apr 2014 14:31:13 +0800
Message-ID: <4ea07e9e6e32cdf4c3038cc2ea5513f37f9c2ab1.1398147734.git.nasa4836@gmail.com>
References: <cover.1398147734.git.nasa4836@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1398147734.git.nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, cgrp->id is only used to look up css's.  As cgroup and
css's lifetimes is now decoupled, it should be made per-subsystem
and moved to css->css_id so that lookups are successful until the
target css is released.

Signed-off-by: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/cgroup.h | 26 +++++++--------
 kernel/cgroup.c        | 87 ++++++++++++++++++++++++--------------------------
 2 files changed, 55 insertions(+), 58 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index de31b2a..66085bd 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -62,6 +62,16 @@ struct cgroup_subsys_state {
 	/* the parent css */
 	struct cgroup_subsys_state *parent;
 
+	/*
+	 * per css id
+	 *
+	 * The css id of cgrp_dfl_root for each subsys is always 0, and
+	 * a new css will be assigned with a smallest available ID.
+	 *
+	 * Allocating/Removing ID must be protected by cgroup_mutex.
+	 */
+	int css_id;
+
 	unsigned long flags;
 
 	/* percpu_ref killing and RCU release */
@@ -141,16 +151,6 @@ enum {
 struct cgroup {
 	unsigned long flags;		/* "unsigned long" so bitops work */
 
-	/*
-	 * idr allocated in-hierarchy ID.
-	 *
-	 * The ID of the root cgroup is always 0, and a new cgroup
-	 * will be assigned with a smallest available ID.
-	 *
-	 * Allocating/Removing ID must be protected by cgroup_mutex.
-	 */
-	int id;
-
 	/* the number of attached css's */
 	int nr_css;
 
@@ -329,9 +329,6 @@ struct cgroup_root {
 	/* Hierarchy-specific flags */
 	unsigned long flags;
 
-	/* IDs for cgroups in this hierarchy */
-	struct idr cgroup_idr;
-
 	/* The path to use for release notifications. */
 	char release_agent_path[PATH_MAX];
 
@@ -655,6 +652,9 @@ struct cgroup_subsys {
 	/* link to parent, protected by cgroup_lock() */
 	struct cgroup_root *root;
 
+	/* IDs for css'es of this subsys */
+	struct idr css_idr;
+
 	/*
 	 * List of cftypes.  Each entry is the first entry of an array
 	 * terminated by zero length name.
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 80c1cf3..f41cf8b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -838,7 +838,6 @@ static void cgroup_free_root(struct cgroup_root *root)
 		/* hierarhcy ID shoulid already have been released */
 		WARN_ON_ONCE(root->hierarchy_id);
 
-		idr_destroy(&root->cgroup_idr);
 		kfree(root);
 	}
 }
@@ -1050,17 +1049,6 @@ static void cgroup_put(struct cgroup *cgrp)
 	if (WARN_ON_ONCE(cgrp->parent && !cgroup_is_dead(cgrp)))
 		return;
 
-	/*
-	 * XXX: cgrp->id is only used to look up css's.  As cgroup and
-	 * css's lifetimes will be decoupled, it should be made
-	 * per-subsystem and moved to css->id so that lookups are
-	 * successful until the target css is released.
-	 */
-	mutex_lock(&cgroup_mutex);
-	idr_remove(&cgrp->root->cgroup_idr, cgrp->id);
-	mutex_unlock(&cgroup_mutex);
-	cgrp->id = -1;
-
 	call_rcu(&cgrp->rcu_head, cgroup_free_rcu);
 }
 
@@ -1512,7 +1500,6 @@ static void init_cgroup_root(struct cgroup_root *root,
 	atomic_set(&root->nr_cgrps, 1);
 	cgrp->root = root;
 	init_cgroup_housekeeping(cgrp);
-	idr_init(&root->cgroup_idr);
 
 	root->flags = opts->flags;
 	if (opts->release_agent)
@@ -1533,11 +1520,6 @@ static int cgroup_setup_root(struct cgroup_root *root, unsigned long ss_mask)
 	lockdep_assert_held(&cgroup_tree_mutex);
 	lockdep_assert_held(&cgroup_mutex);
 
-	ret = idr_alloc(&root->cgroup_idr, root_cgrp, 0, 1, GFP_KERNEL);
-	if (ret < 0)
-		goto out;
-	root_cgrp->id = ret;
-
 	/*
 	 * We're accessing css_set_count without locking css_set_rwsem here,
 	 * but that's OK - it can only be increased by someone holding
@@ -4056,6 +4038,11 @@ static void css_free_work_fn(struct work_struct *work)
 
 	css->ss->css_free(css);
 	cgroup_put(cgrp);
+
+	mutex_lock(&cgroup_mutex);
+	idr_remove(&css->ss->css_idr, css->css_id);
+	mutex_unlock(&cgroup_mutex);
+	css->css_id = -1;
 }
 
 static void css_free_rcu_fn(struct rcu_head *rcu_head)
@@ -4152,9 +4139,17 @@ static int create_css(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	if (IS_ERR(css))
 		return PTR_ERR(css);
 
+	/*
+	 * Temporarily set the pointer to NULL, so idr_find() won't return
+	 * a half-baked css.
+	 */
+	css->css_id = idr_alloc(&ss->css_idr, NULL, 1, 0, GFP_KERNEL);
+	if (css->css_id < 0)
+		goto err_free_css;
+
 	err = percpu_ref_init(&css->refcnt, css_release);
 	if (err)
-		goto err_free_css;
+		goto err_free_id;
 
 	init_css(css, ss, cgrp);
 
@@ -4166,6 +4161,12 @@ static int create_css(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	if (err)
 		goto err_clear_dir;
 
+	/*
+	 * @css is now fully operational.
+	 * Nothing can fail from this point on.
+	 */
+	idr_replace(&ss->css_idr, css, css->css_id);
+
 	cgroup_get(cgrp);
 	css_get(css->parent);
 
@@ -4184,6 +4185,8 @@ err_clear_dir:
 	cgroup_clear_dir(css->cgroup, 1 << css->ss->id);
 err_free_percpu_ref:
 	percpu_ref_cancel_init(&css->refcnt);
+err_free_id:
+	idr_remove(&ss->css_idr, css->css_id);
 err_free_css:
 	ss->css_free(css);
 	return err;
@@ -4223,16 +4226,6 @@ static long cgroup_create(struct cgroup *parent, const char *name,
 		goto err_unlock_tree;
 	}
 
-	/*
-	 * Temporarily set the pointer to NULL, so idr_find() won't return
-	 * a half-baked cgroup.
-	 */
-	cgrp->id = idr_alloc(&root->cgroup_idr, NULL, 1, 0, GFP_KERNEL);
-	if (cgrp->id < 0) {
-		err = -ENOMEM;
-		goto err_unlock;
-	}
-
 	init_cgroup_housekeeping(cgrp);
 
 	cgrp->parent = parent;
@@ -4249,7 +4242,7 @@ static long cgroup_create(struct cgroup *parent, const char *name,
 	kn = kernfs_create_dir(parent->kn, name, mode, cgrp);
 	if (IS_ERR(kn)) {
 		err = PTR_ERR(kn);
-		goto err_free_id;
+		goto err_unlock;
 	}
 	cgrp->kn = kn;
 
@@ -4266,12 +4259,6 @@ static long cgroup_create(struct cgroup *parent, const char *name,
 	atomic_inc(&root->nr_cgrps);
 	cgroup_get(parent);
 
-	/*
-	 * @cgrp is now fully operational.  If something fails after this
-	 * point, it'll be released via the normal destruction path.
-	 */
-	idr_replace(&root->cgroup_idr, cgrp, cgrp->id);
-
 	err = cgroup_kn_set_ugid(kn);
 	if (err)
 		goto err_destroy;
@@ -4303,8 +4290,6 @@ static long cgroup_create(struct cgroup *parent, const char *name,
 
 	return 0;
 
-err_free_id:
-	idr_remove(&root->cgroup_idr, cgrp->id);
 err_unlock:
 	mutex_unlock(&cgroup_mutex);
 err_unlock_tree:
@@ -4617,6 +4602,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 
+	idr_init(&ss->css_idr);
 	INIT_LIST_HEAD(&ss->cfts);
 
 	/* Create the root cgroup state for this subsystem */
@@ -4707,9 +4693,25 @@ int __init cgroup_init(void)
 	mutex_unlock(&cgroup_tree_mutex);
 
 	for_each_subsys(ss, ssid) {
+		struct cgroup_subsys_state *css;
+		int id;
+
 		if (!ss->early_init)
 			cgroup_init_subsys(ss);
 
+		/*
+		 * mm_init() runs lately after cgroup_init_early(), thus
+		 * the world isn't set up yet for idr_alloc() to run, so
+		 * we have to defer the id allocation to this point.
+		 *
+		 * And we don't gracefully handle early failure.
+		 */
+		css = init_css_set.subsys[ss->id];
+		id = idr_alloc(&ss->css_idr, css, 0, 1, GFP_KERNEL);
+		if (id < 0)
+			BUG();
+		css->css_id = id;
+
 		list_add_tail(&init_css_set.e_cset_node[ssid],
 			      &cgrp_dfl_root.cgrp.e_csets[ssid]);
 
@@ -5160,7 +5162,7 @@ struct cgroup_subsys_state *css_tryget_from_dir(struct dentry *dentry,
  */
 int css_to_id(struct cgroup_subsys_state *css)
 {
-	return css->cgroup->id;
+	return css->css_id;
 }
 
 /**
@@ -5173,14 +5175,9 @@ int css_to_id(struct cgroup_subsys_state *css)
  */
 struct cgroup_subsys_state *css_from_id(int id, struct cgroup_subsys *ss)
 {
-	struct cgroup *cgrp;
-
 	cgroup_assert_mutexes_or_rcu_locked();
 
-	cgrp = idr_find(&ss->root->cgroup_idr, id);
-	if (cgrp)
-		return cgroup_css(cgrp, ss);
-	return NULL;
+	return idr_find(&ss->css_idr, id);
 }
 
 #ifdef CONFIG_CGROUP_DEBUG
-- 
2.0.0-rc0
