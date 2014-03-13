From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 07/11] cgroup: move ->subsys_mask from cgroupfs_root to cgroup
Date: Thu, 13 Mar 2014 15:50:09 -0400
Message-ID: <1394740213-17626-8-git-send-email-tj@kernel.org>
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

cgroupfs_root->subsys_mask represents the controllers attached to the
hierarchy.  This patch moves the field to cgroup.  Subsystem
initialization and rebinding updates the top cgroup's subsys_mask.
For !root cgroups, the subsys_mask bits are set from create_css() and
cleared from kill_css(), which effectively means that all cgroups will
have the same subsys_mask as the top cgroup.

While this doesn't make any difference now, this will help
implementation of the default unified hierarchy where !root cgroups
may have subsets of the top_cgroup's subsys_mask.

While at it, __kill_css() is split out of kill_css().  The former
doesn't care about the subsys_mask while the latter becomes noop if
the controller is already killed and clears the matching bit if not
before proceeding to killing the css.  This will be used later by the
default unified hierarchy implementation.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  6 ++---
 kernel/cgroup.c        | 61 ++++++++++++++++++++++++++++++++------------------
 2 files changed, 42 insertions(+), 25 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 9f4f253..3752a01 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -173,6 +173,9 @@ struct cgroup {
 	 */
 	u64 serial_nr;
 
+	/* The bitmask of subsystems attached to this cgroup */
+	unsigned long subsys_mask;
+
 	/* Private pointers for each registered subsystem */
 	struct cgroup_subsys_state __rcu *subsys[CGROUP_SUBSYS_COUNT];
 
@@ -276,9 +279,6 @@ enum {
 struct cgroupfs_root {
 	struct kernfs_root *kf_root;
 
-	/* The bitmask of subsystems attached to this hierarchy */
-	unsigned long subsys_mask;
-
 	/* Unique id for this hierarchy. */
 	int hierarchy_id;
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 9b9a294..7505f8b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -526,7 +526,7 @@ static struct css_set *find_existing_css_set(struct css_set *old_cset,
 	 * won't change, so no need for locking.
 	 */
 	for_each_subsys(ss, i) {
-		if (root->subsys_mask & (1UL << i)) {
+		if (root->top_cgroup.subsys_mask & (1UL << i)) {
 			/* Subsystem is in this hierarchy. So we want
 			 * the subsystem state from the new
 			 * cgroup */
@@ -739,7 +739,7 @@ static void cgroup_destroy_root(struct cgroupfs_root *root)
 	BUG_ON(!list_empty(&cgrp->children));
 
 	/* Rebind all subsystems back to the default hierarchy */
-	rebind_subsystems(&cgroup_dummy_root, root->subsys_mask);
+	rebind_subsystems(&cgroup_dummy_root, cgrp->subsys_mask);
 
 	/*
 	 * Release all the links from cset_links to this hierarchy's
@@ -1038,8 +1038,8 @@ static int rebind_subsystems(struct cgroupfs_root *dst_root,
 		ss->root = dst_root;
 		css->cgroup = dst_top;
 
-		src_root->subsys_mask &= ~(1 << ssid);
-		dst_root->subsys_mask |= 1 << ssid;
+		src_top->subsys_mask &= ~(1 << ssid);
+		dst_top->subsys_mask |= 1 << ssid;
 
 		if (ss->bind)
 			ss->bind(css);
@@ -1058,7 +1058,7 @@ static int cgroup_show_options(struct seq_file *seq,
 	int ssid;
 
 	for_each_subsys(ss, ssid)
-		if (root->subsys_mask & (1 << ssid))
+		if (root->top_cgroup.subsys_mask & (1 << ssid))
 			seq_printf(seq, ",%s", ss->name);
 	if (root->flags & CGRP_ROOT_SANE_BEHAVIOR)
 		seq_puts(seq, ",sane_behavior");
@@ -1262,12 +1262,12 @@ static int cgroup_remount(struct kernfs_root *kf_root, int *flags, char *data)
 	if (ret)
 		goto out_unlock;
 
-	if (opts.subsys_mask != root->subsys_mask || opts.release_agent)
+	if (opts.subsys_mask != root->top_cgroup.subsys_mask || opts.release_agent)
 		pr_warning("cgroup: option changes via remount are deprecated (pid=%d comm=%s)\n",
 			   task_tgid_nr(current), current->comm);
 
-	added_mask = opts.subsys_mask & ~root->subsys_mask;
-	removed_mask = root->subsys_mask & ~opts.subsys_mask;
+	added_mask = opts.subsys_mask & ~root->top_cgroup.subsys_mask;
+	removed_mask = root->top_cgroup.subsys_mask & ~opts.subsys_mask;
 
 	/* Don't allow flags or name to change at remount */
 	if (((opts.flags ^ root->flags) & CGRP_ROOT_OPTION_MASK) ||
@@ -1515,7 +1515,7 @@ retry:
 		 * subsystems) then they must match.
 		 */
 		if ((opts.subsys_mask || opts.none) &&
-		    (opts.subsys_mask != root->subsys_mask)) {
+		    (opts.subsys_mask != root->top_cgroup.subsys_mask)) {
 			if (!name_match)
 				continue;
 			ret = -EBUSY;
@@ -3594,6 +3594,8 @@ static int create_css(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	cgroup_get(cgrp);
 	css_get(css->parent);
 
+	cgrp->subsys_mask |= 1 << ss->id;
+
 	if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
 	    parent->parent) {
 		pr_warning("cgroup: %s (%d) created nested cgroup for controller \"%s\" which has incomplete hierarchy support. Nested cgroups may change behavior in the future.\n",
@@ -3700,7 +3702,7 @@ static long cgroup_create(struct cgroup *parent, const char *name,
 
 	/* let's create and online css's */
 	for_each_subsys(ss, ssid) {
-		if (root->subsys_mask & (1 << ssid)) {
+		if (root->top_cgroup.subsys_mask & (1 << ssid)) {
 			err = create_css(cgrp, ss);
 			if (err)
 				goto err_destroy;
@@ -3788,17 +3790,10 @@ static void css_killed_ref_fn(struct percpu_ref *ref)
 	queue_work(cgroup_destroy_wq, &css->destroy_work);
 }
 
-/**
- * kill_css - destroy a css
- * @css: css to destroy
- *
- * This function initiates destruction of @css by removing cgroup interface
- * files and putting its base reference.  ->css_offline() will be invoked
- * asynchronously once css_tryget() is guaranteed to fail and when the
- * reference count reaches zero, @css will be released.
- */
-static void kill_css(struct cgroup_subsys_state *css)
+static void __kill_css(struct cgroup_subsys_state *css)
 {
+	lockdep_assert_held(&cgroup_tree_mutex);
+
 	/*
 	 * This must happen before css is disassociated with its cgroup.
 	 * See seq_css() for details.
@@ -3825,6 +3820,28 @@ static void kill_css(struct cgroup_subsys_state *css)
 }
 
 /**
+ * kill_css - destroy a css
+ * @css: css to destroy
+ *
+ * This function initiates destruction of @css by removing cgroup interface
+ * files and putting its base reference.  ->css_offline() will be invoked
+ * asynchronously once css_tryget() is guaranteed to fail and when the
+ * reference count reaches zero, @css will be released.
+ */
+static void kill_css(struct cgroup_subsys_state *css)
+{
+	struct cgroup *cgrp = css->cgroup;
+
+	lockdep_assert_held(&cgroup_tree_mutex);
+
+	/* if already killed, noop */
+	if (cgrp->subsys_mask & (1 << css->ss->id)) {
+		cgrp->subsys_mask &= ~(1 << css->ss->id);
+		__kill_css(css);
+	}
+}
+
+/**
  * cgroup_destroy_locked - the first stage of cgroup destruction
  * @cgrp: cgroup to be destroyed
  *
@@ -4036,7 +4053,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 
 	BUG_ON(online_css(css));
 
-	cgroup_dummy_root.subsys_mask |= 1 << ss->id;
+	cgroup_dummy_root.top_cgroup.subsys_mask |= 1 << ss->id;
 
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgroup_tree_mutex);
@@ -4192,7 +4209,7 @@ int proc_cgroup_show(struct seq_file *m, void *v)
 
 		seq_printf(m, "%d:", root->hierarchy_id);
 		for_each_subsys(ss, ssid)
-			if (root->subsys_mask & (1 << ssid))
+			if (root->top_cgroup.subsys_mask & (1 << ssid))
 				seq_printf(m, "%s%s", count++ ? "," : "", ss->name);
 		if (strlen(root->name))
 			seq_printf(m, "%sname=%s", count ? "," : "",
-- 
1.8.5.3
