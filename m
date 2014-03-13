From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/11] cgroup: treat cgroup_dummy_root as an equivalent
	hierarchy during rebinding
Date: Thu, 13 Mar 2014 15:50:08 -0400
Message-ID: <1394740213-17626-7-git-send-email-tj@kernel.org>
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

Currently, while rebinding, cgroup_dummy_root serves as the anchor
point.  In addition to the target root, rebind_subsystems() takes
@added_mask and @removed_mask.  The subsystems specified in the former
are expected to be on the dummy root and then moved to the target
root.  The ones in the latter are moved from non-dummy root to dummy.
Now that the dummy root is a fully functional one and we're planning
to use it for the default unified hierarchy, this level of distinction
between dummy and non-dummy roots is quite awkward.

This patch updates rebind_subsystems() to take the target root and one
subsystem mask and move the specified subsystmes to the target root
which may or may not be the dummy root.  IOW, unbinding now becomes
moving the subsystems to the dummy root and binding to non-dummy root.
This makes the dummy root mostly equivalent to other hierarchies in
terms of the mechanism of moving subsystems around; however, we still
retain all the semantical restrictions so that this patch doesn't
introduce any visible behavior differences.  Another noteworthy detail
is that rebind_subsystems() guarantees that moving a subsystem to the
dummy root never fails so that valid unmounting attempts always
succeed.

This unifies binding and unbinding of subsystems.  The invocation
points of ->bind() were inconsistent between the two and now moved
after whole rebinding is complete.  This doesn't break the current
users and generally makes more sense.

All rebind_subsystems() users are converted accordingly.  Note that
cgroup_remount() now makes two calls to rebind_subsystems() to bind
and then unbind the requested subsystems.

This will allow repurposing of the dummy hierarchy as the default
unified hierarchy and shouldn't make any userland visible behavior
difference.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 100 +++++++++++++++++++++++++++++++-------------------------
 1 file changed, 56 insertions(+), 44 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2483f4e..9b9a294 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -175,8 +175,8 @@ static int need_forkexit_callback __read_mostly;
 static struct cftype cgroup_base_files[];
 
 static void cgroup_put(struct cgroup *cgrp);
-static int rebind_subsystems(struct cgroupfs_root *root,
-			     unsigned long added_mask, unsigned removed_mask);
+static int rebind_subsystems(struct cgroupfs_root *dst_root,
+			     unsigned long ss_mask);
 static void cgroup_destroy_css_killed(struct cgroup *cgrp);
 static int cgroup_destroy_locked(struct cgroup *cgrp);
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
@@ -739,7 +739,7 @@ static void cgroup_destroy_root(struct cgroupfs_root *root)
 	BUG_ON(!list_empty(&cgrp->children));
 
 	/* Rebind all subsystems back to the default hierarchy */
-	WARN_ON(rebind_subsystems(root, 0, root->subsys_mask));
+	rebind_subsystems(&cgroup_dummy_root, root->subsys_mask);
 
 	/*
 	 * Release all the links from cset_links to this hierarchy's
@@ -976,69 +976,77 @@ static void cgroup_clear_dir(struct cgroup *cgrp, unsigned long subsys_mask)
 	}
 }
 
-static int rebind_subsystems(struct cgroupfs_root *root,
-			     unsigned long added_mask, unsigned removed_mask)
+static int rebind_subsystems(struct cgroupfs_root *dst_root,
+			     unsigned long ss_mask)
 {
-	struct cgroup *cgrp = &root->top_cgroup;
+	struct cgroup *dst_top = &dst_root->top_cgroup;
 	struct cgroup_subsys *ss;
-	int i, ret;
+	int ssid, ret;
 
 	lockdep_assert_held(&cgroup_tree_mutex);
 	lockdep_assert_held(&cgroup_mutex);
 
-	/* Check that any added subsystems are currently free */
-	for_each_subsys(ss, i)
-		if ((added_mask & (1 << i)) && ss->root != &cgroup_dummy_root)
+	for_each_subsys(ss, ssid) {
+		if (!(ss_mask & (1 << ssid)))
+			continue;
+
+		/* if @ss is on the dummy_root, we can always move it */
+		if (ss->root == &cgroup_dummy_root)
+			continue;
+
+		/* if @ss has non-root cgroups attached to it, can't move */
+		if (!list_empty(&ss->root->top_cgroup.children))
 			return -EBUSY;
 
-	ret = cgroup_populate_dir(cgrp, added_mask);
-	if (ret)
-		return ret;
+		/* can't move between two non-dummy roots either */
+		if (dst_root != &cgroup_dummy_root)
+			return -EBUSY;
+	}
+
+	if (dst_root != &cgroup_dummy_root) {
+		ret = cgroup_populate_dir(dst_top, ss_mask);
+		if (ret)
+			return ret;
+	}
 
 	/*
 	 * Nothing can fail from this point on.  Remove files for the
 	 * removed subsystems and rebind each subsystem.
 	 */
 	mutex_unlock(&cgroup_mutex);
-	cgroup_clear_dir(cgrp, removed_mask);
+	for_each_subsys(ss, ssid)
+		if ((ss_mask & (1 << ssid)) && ss->root != &cgroup_dummy_root)
+			cgroup_clear_dir(&ss->root->top_cgroup, 1 << ssid);
 	mutex_lock(&cgroup_mutex);
 
-	for_each_subsys(ss, i) {
-		unsigned long bit = 1UL << i;
-
-		if (bit & added_mask) {
-			/* We're binding this subsystem to this hierarchy */
-			BUG_ON(cgroup_css(cgrp, ss));
-			BUG_ON(!cgroup_css(cgroup_dummy_top, ss));
-			BUG_ON(cgroup_css(cgroup_dummy_top, ss)->cgroup != cgroup_dummy_top);
+	for_each_subsys(ss, ssid) {
+		struct cgroupfs_root *src_root;
+		struct cgroup *src_top;
+		struct cgroup_subsys_state *css;
 
-			rcu_assign_pointer(cgrp->subsys[i],
-					   cgroup_css(cgroup_dummy_top, ss));
-			cgroup_css(cgrp, ss)->cgroup = cgrp;
+		if (!(ss_mask & (1 << ssid)))
+			continue;
 
-			ss->root = root;
-			if (ss->bind)
-				ss->bind(cgroup_css(cgrp, ss));
+		src_root = ss->root;
+		src_top = &src_root->top_cgroup;
+		css = cgroup_css(src_top, ss);
 
-			/* refcount was already taken, and we're keeping it */
-			root->subsys_mask |= bit;
-		} else if (bit & removed_mask) {
-			/* We're removing this subsystem */
-			BUG_ON(cgroup_css(cgrp, ss) != cgroup_css(cgroup_dummy_top, ss));
-			BUG_ON(cgroup_css(cgrp, ss)->cgroup != cgrp);
+		WARN_ON(!css || cgroup_css(dst_top, ss));
 
-			if (ss->bind)
-				ss->bind(cgroup_css(cgroup_dummy_top, ss));
+		RCU_INIT_POINTER(src_top->subsys[ssid], NULL);
+		rcu_assign_pointer(dst_top->subsys[ssid], css);
+		ss->root = dst_root;
+		css->cgroup = dst_top;
 
-			cgroup_css(cgroup_dummy_top, ss)->cgroup = cgroup_dummy_top;
-			RCU_INIT_POINTER(cgrp->subsys[i], NULL);
+		src_root->subsys_mask &= ~(1 << ssid);
+		dst_root->subsys_mask |= 1 << ssid;
 
-			cgroup_subsys[i]->root = &cgroup_dummy_root;
-			root->subsys_mask &= ~bit;
-		}
+		if (ss->bind)
+			ss->bind(css);
 	}
 
-	kernfs_activate(cgrp->kn);
+	if (dst_root != &cgroup_dummy_root)
+		kernfs_activate(dst_top->kn);
 	return 0;
 }
 
@@ -1277,10 +1285,12 @@ static int cgroup_remount(struct kernfs_root *kf_root, int *flags, char *data)
 		goto out_unlock;
 	}
 
-	ret = rebind_subsystems(root, added_mask, removed_mask);
+	ret = rebind_subsystems(root, added_mask);
 	if (ret)
 		goto out_unlock;
 
+	rebind_subsystems(&cgroup_dummy_root, removed_mask);
+
 	if (opts.release_agent) {
 		spin_lock(&release_agent_path_lock);
 		strcpy(root->release_agent_path, opts.release_agent);
@@ -1420,7 +1430,7 @@ static int cgroup_setup_root(struct cgroupfs_root *root, unsigned long ss_mask)
 	if (ret)
 		goto destroy_root;
 
-	ret = rebind_subsystems(root, ss_mask, 0);
+	ret = rebind_subsystems(root, ss_mask);
 	if (ret)
 		goto destroy_root;
 
@@ -4026,6 +4036,8 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 
 	BUG_ON(online_css(css));
 
+	cgroup_dummy_root.subsys_mask |= 1 << ss->id;
+
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgroup_tree_mutex);
 }
-- 
1.8.5.3
