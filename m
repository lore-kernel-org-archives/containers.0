From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 01/12] cgroup: update cgroup->subsys_mask to
	->child_subsys_mask and restore cgroup_root->subsys_mask
Date: Thu, 27 Mar 2014 22:40:50 -0400
Message-ID: <1395974461-12735-2-git-send-email-tj@kernel.org>
References: <1395974461-12735-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1395974461-12735-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

944196278d3d ("cgroup: move ->subsys_mask from cgroupfs_root to
cgroup") moved ->subsys_mask from cgroup_root to cgroup to prepare for
the unified hierarhcy; however, it turns out that carrying the
subsys_mask of the children in the parent, instead of itself, is a lot
more natural.  This patch restores cgroup_root->subsys_mask and morphs
cgroup->subsys_mask into cgroup->child_subsys_mask.

* Uses of root->cgrp.subsys_mask are restored to root->subsys_mask.

* Remove automatic setting and clearing of cgrp->subsys_mask and
  instead just inherit ->child_subsys_mask from the parent during
  cgroup creation.  Note that this doesn't affect any current
  behaviors.

* Undo __kill_css() separation.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  7 ++++--
 kernel/cgroup.c        | 64 +++++++++++++++++++++-----------------------------
 2 files changed, 32 insertions(+), 39 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 43d1ed3..e351a18 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -173,8 +173,8 @@ struct cgroup {
 	 */
 	u64 serial_nr;
 
-	/* The bitmask of subsystems attached to this cgroup */
-	unsigned long subsys_mask;
+	/* the bitmask of subsystems enabled on the child cgroups */
+	unsigned long child_subsys_mask;
 
 	/* Private pointers for each registered subsystem */
 	struct cgroup_subsys_state __rcu *subsys[CGROUP_SUBSYS_COUNT];
@@ -282,6 +282,9 @@ enum {
 struct cgroup_root {
 	struct kernfs_root *kf_root;
 
+	/* The bitmask of subsystems attached to this hierarchy */
+	unsigned long subsys_mask;
+
 	/* Unique id for this hierarchy. */
 	int hierarchy_id;
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e378cb2..3c9c623 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -529,7 +529,7 @@ static struct css_set *find_existing_css_set(struct css_set *old_cset,
 	 * won't change, so no need for locking.
 	 */
 	for_each_subsys(ss, i) {
-		if (root->cgrp.subsys_mask & (1UL << i)) {
+		if (root->subsys_mask & (1UL << i)) {
 			/* Subsystem is in this hierarchy. So we want
 			 * the subsystem state from the new
 			 * cgroup */
@@ -742,7 +742,7 @@ static void cgroup_destroy_root(struct cgroup_root *root)
 	BUG_ON(!list_empty(&cgrp->children));
 
 	/* Rebind all subsystems back to the default hierarchy */
-	rebind_subsystems(&cgrp_dfl_root, cgrp->subsys_mask);
+	rebind_subsystems(&cgrp_dfl_root, root->subsys_mask);
 
 	/*
 	 * Release all the links from cset_links to this hierarchy's
@@ -1050,8 +1050,11 @@ static int rebind_subsystems(struct cgroup_root *dst_root,
 		ss->root = dst_root;
 		css->cgroup = &dst_root->cgrp;
 
-		src_root->cgrp.subsys_mask &= ~(1 << ssid);
-		dst_root->cgrp.subsys_mask |= 1 << ssid;
+		src_root->subsys_mask &= ~(1 << ssid);
+		src_root->cgrp.child_subsys_mask &= ~(1 << ssid);
+
+		dst_root->subsys_mask |= 1 << ssid;
+		dst_root->cgrp.child_subsys_mask |= 1 << ssid;
 
 		if (ss->bind)
 			ss->bind(css);
@@ -1069,7 +1072,7 @@ static int cgroup_show_options(struct seq_file *seq,
 	int ssid;
 
 	for_each_subsys(ss, ssid)
-		if (root->cgrp.subsys_mask & (1 << ssid))
+		if (root->subsys_mask & (1 << ssid))
 			seq_printf(seq, ",%s", ss->name);
 	if (root->flags & CGRP_ROOT_SANE_BEHAVIOR)
 		seq_puts(seq, ",sane_behavior");
@@ -1273,12 +1276,12 @@ static int cgroup_remount(struct kernfs_root *kf_root, int *flags, char *data)
 	if (ret)
 		goto out_unlock;
 
-	if (opts.subsys_mask != root->cgrp.subsys_mask || opts.release_agent)
+	if (opts.subsys_mask != root->subsys_mask || opts.release_agent)
 		pr_warning("cgroup: option changes via remount are deprecated (pid=%d comm=%s)\n",
 			   task_tgid_nr(current), current->comm);
 
-	added_mask = opts.subsys_mask & ~root->cgrp.subsys_mask;
-	removed_mask = root->cgrp.subsys_mask & ~opts.subsys_mask;
+	added_mask = opts.subsys_mask & ~root->subsys_mask;
+	removed_mask = root->subsys_mask & ~opts.subsys_mask;
 
 	/* Don't allow flags or name to change at remount */
 	if (((opts.flags ^ root->flags) & CGRP_ROOT_OPTION_MASK) ||
@@ -1534,7 +1537,7 @@ retry:
 		 * subsystems) then they must match.
 		 */
 		if ((opts.subsys_mask || opts.none) &&
-		    (opts.subsys_mask != root->cgrp.subsys_mask)) {
+		    (opts.subsys_mask != root->subsys_mask)) {
 			if (!name_match)
 				continue;
 			ret = -EBUSY;
@@ -3640,8 +3643,6 @@ static int create_css(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	cgroup_get(cgrp);
 	css_get(css->parent);
 
-	cgrp->subsys_mask |= 1 << ss->id;
-
 	if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
 	    parent->parent) {
 		pr_warning("cgroup: %s (%d) created nested cgroup for controller \"%s\" which has incomplete hierarchy support. Nested cgroups may change behavior in the future.\n",
@@ -3755,13 +3756,15 @@ static long cgroup_create(struct cgroup *parent, const char *name,
 
 	/* let's create and online css's */
 	for_each_subsys(ss, ssid) {
-		if (root->cgrp.subsys_mask & (1 << ssid)) {
+		if (parent->child_subsys_mask & (1 << ssid)) {
 			err = create_css(cgrp, ss);
 			if (err)
 				goto err_destroy;
 		}
 	}
 
+	cgrp->child_subsys_mask = parent->child_subsys_mask;
+
 	kernfs_activate(kn);
 
 	mutex_unlock(&cgroup_mutex);
@@ -3857,7 +3860,16 @@ static void css_killed_ref_fn(struct percpu_ref *ref)
 	queue_work(cgroup_destroy_wq, &css->destroy_work);
 }
 
-static void __kill_css(struct cgroup_subsys_state *css)
+/**
+ * kill_css - destroy a css
+ * @css: css to destroy
+ *
+ * This function initiates destruction of @css by removing cgroup interface
+ * files and putting its base reference.  ->css_offline() will be invoked
+ * asynchronously once css_tryget() is guaranteed to fail and when the
+ * reference count reaches zero, @css will be released.
+ */
+static void kill_css(struct cgroup_subsys_state *css)
 {
 	lockdep_assert_held(&cgroup_tree_mutex);
 
@@ -3887,28 +3899,6 @@ static void __kill_css(struct cgroup_subsys_state *css)
 }
 
 /**
- * kill_css - destroy a css
- * @css: css to destroy
- *
- * This function initiates destruction of @css by removing cgroup interface
- * files and putting its base reference.  ->css_offline() will be invoked
- * asynchronously once css_tryget() is guaranteed to fail and when the
- * reference count reaches zero, @css will be released.
- */
-static void kill_css(struct cgroup_subsys_state *css)
-{
-	struct cgroup *cgrp = css->cgroup;
-
-	lockdep_assert_held(&cgroup_tree_mutex);
-
-	/* if already killed, noop */
-	if (cgrp->subsys_mask & (1 << css->ss->id)) {
-		cgrp->subsys_mask &= ~(1 << css->ss->id);
-		__kill_css(css);
-	}
-}
-
-/**
  * cgroup_destroy_locked - the first stage of cgroup destruction
  * @cgrp: cgroup to be destroyed
  *
@@ -4120,7 +4110,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 
 	BUG_ON(online_css(css));
 
-	cgrp_dfl_root.cgrp.subsys_mask |= 1 << ss->id;
+	cgrp_dfl_root.subsys_mask |= 1 << ss->id;
 
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgroup_tree_mutex);
@@ -4277,7 +4267,7 @@ int proc_cgroup_show(struct seq_file *m, void *v)
 
 		seq_printf(m, "%d:", root->hierarchy_id);
 		for_each_subsys(ss, ssid)
-			if (root->cgrp.subsys_mask & (1 << ssid))
+			if (root->subsys_mask & (1 << ssid))
 				seq_printf(m, "%s%s", count++ ? "," : "", ss->name);
 		if (strlen(root->name))
 			seq_printf(m, "%sname=%s", count ? "," : "",
-- 
1.8.5.3
