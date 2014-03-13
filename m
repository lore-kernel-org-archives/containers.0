From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/11] cgroup: make cgrp_dfl_root mountable
Date: Thu, 13 Mar 2014 15:50:12 -0400
Message-ID: <1394740213-17626-11-git-send-email-tj__39396.8564960689$1394740333$gmane$org@kernel.org>
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

cgrp_dfl_root will be used as the default unified hierarchy.  This
patch makes cgrp_dfl_root mountable by making the following changes.

* cgroup_init_early() now initializes cgrp_dfl_root w/
  CGRP_ROOT_SANE_BEHAVIOR.  The default hierarchy is always sane.

* parse_cgroupfs_options() and cgroup_mount() are updated such that
  cgrp_dfl_root is mounted if sane_behavior is specified w/o any
  subsystems.

* rebind_subsystems() now populates the root directory of
  cgrp_dfl_root.  Note that the function still guarantees success of
  rebinding subsystems to cgrp_dfl_root.  If populating fails while
  rebinding to cgrp_dfl_root, it whines but ignores the error.

* For backward compatibility, the default hierarchy shows up in
  /proc/$PID/cgroup only after it's explicitly mounted so that
  userland which doesn't make use of it doesn't see any change.

* "current_css_set_cg_links" file of debug cgroup now treats the
  default hierarchy the same as other hierarchies.  This is visible to
  userland.  Given that it's for debug controller, this should be
  fine.

* While at it, implement cgroup_on_dfl() which tests whether a give
  cgroup is on the default hierarchy or not.

The above changes make cgrp_dfl_root mostly equivalent to other
controllers but the actual unified hierarchy behaviors are not
implemented yet.  Let's plug child cgroup creation in cgrp_dfl_root
from create_cgroup() for now.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 10 ++++++
 kernel/cgroup.c        | 94 ++++++++++++++++++++++++++++++++------------------
 2 files changed, 71 insertions(+), 33 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 79993ac..7e9fa50 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -250,6 +250,9 @@ enum {
 	 *
 	 * - "cgroup.clone_children" is removed.
 	 *
+	 * - If mount is requested with sane_behavior but without any
+	 *   subsystem, the default unified hierarchy is mounted.
+	 *
 	 * - cpuset: tasks will be kept in empty cpusets when hotplug happens
 	 *   and take masks of ancestors with non-empty cpus/mems, instead of
 	 *   being moved to an ancestor.
@@ -468,6 +471,13 @@ struct cftype {
 #endif
 };
 
+extern struct cgroup_root cgrp_dfl_root;
+
+static inline bool cgroup_on_dfl(const struct cgroup *cgrp)
+{
+	return cgrp->root == &cgrp_dfl_root;
+}
+
 /*
  * See the comment above CGRP_ROOT_SANE_BEHAVIOR for details.  This
  * function can be called as long as @cgrp is accessible.
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 36d1a53..c42230c 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -142,7 +142,13 @@ static const char *cgroup_subsys_name[] = {
  * unattached - it never has more than a single cgroup, and all tasks are
  * part of that cgroup.
  */
-static struct cgroup_root cgrp_dfl_root;
+struct cgroup_root cgrp_dfl_root;
+
+/*
+ * The default hierarchy always exists but is hidden until mounted for the
+ * first time.  This is for backward compatibility.
+ */
+static bool cgrp_dfl_root_visible;
 
 /* The list of hierarchy roots */
 
@@ -999,10 +1005,22 @@ static int rebind_subsystems(struct cgroup_root *dst_root,
 			return -EBUSY;
 	}
 
-	if (dst_root != &cgrp_dfl_root) {
-		ret = cgroup_populate_dir(&dst_root->cgrp, ss_mask);
-		if (ret)
+	ret = cgroup_populate_dir(&dst_root->cgrp, ss_mask);
+	if (ret) {
+		if (dst_root != &cgrp_dfl_root)
 			return ret;
+
+		/*
+		 * Rebinding back to the default root is not allowed to
+		 * fail.  Using both default and non-default roots should
+		 * be rare.  Moving subsystems back and forth even more so.
+		 * Just warn about it and continue.
+		 */
+		if (cgrp_dfl_root_visible) {
+			pr_warning("cgroup: failed to create files (%d) while rebinding 0x%lx to default root\n",
+				   ret, ss_mask);
+			pr_warning("cgroup: you may retry by moving them to a different hierarchy and unbinding\n");
+		}
 	}
 
 	/*
@@ -1011,7 +1029,7 @@ static int rebind_subsystems(struct cgroup_root *dst_root,
 	 */
 	mutex_unlock(&cgroup_mutex);
 	for_each_subsys(ss, ssid)
-		if ((ss_mask & (1 << ssid)) && ss->root != &cgrp_dfl_root)
+		if (ss_mask & (1 << ssid))
 			cgroup_clear_dir(&ss->root->cgrp, 1 << ssid);
 	mutex_lock(&cgroup_mutex);
 
@@ -1039,8 +1057,7 @@ static int rebind_subsystems(struct cgroup_root *dst_root,
 			ss->bind(css);
 	}
 
-	if (dst_root != &cgrp_dfl_root)
-		kernfs_activate(dst_root->cgrp.kn);
+	kernfs_activate(dst_root->cgrp.kn);
 	return 0;
 }
 
@@ -1190,16 +1207,6 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 			return -ENOENT;
 	}
 
-	/*
-	 * If the 'all' option was specified select all the subsystems,
-	 * otherwise if 'none', 'name=' and a subsystem name options
-	 * were not specified, let's default to 'all'
-	 */
-	if (all_ss || (!one_ss && !opts->none && !opts->name))
-		for_each_subsys(ss, i)
-			if (!ss->disabled)
-				set_bit(i, &opts->subsys_mask);
-
 	/* Consistency checks */
 
 	if (opts->flags & CGRP_ROOT_SANE_BEHAVIOR) {
@@ -1211,6 +1218,23 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 			pr_err("cgroup: sane_behavior: noprefix, xattr, clone_children, release_agent and name are not allowed\n");
 			return -EINVAL;
 		}
+	} else {
+		/*
+		 * If the 'all' option was specified select all the
+		 * subsystems, otherwise if 'none', 'name=' and a subsystem
+		 * name options were not specified, let's default to 'all'
+		 */
+		if (all_ss || (!one_ss && !opts->none && !opts->name))
+			for_each_subsys(ss, i)
+				if (!ss->disabled)
+					set_bit(i, &opts->subsys_mask);
+
+		/*
+		 * We either have to specify by name or by subsystems. (So
+		 * all empty hierarchies must have a name).
+		 */
+		if (!opts->subsys_mask && !opts->name)
+			return -EINVAL;
 	}
 
 	/*
@@ -1226,13 +1250,6 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 	if (opts->subsys_mask && opts->none)
 		return -EINVAL;
 
-	/*
-	 * We either have to specify by name or by subsystems. (So all
-	 * empty hierarchies must have a name).
-	 */
-	if (!opts->subsys_mask && !opts->name)
-		return -EINVAL;
-
 	return 0;
 }
 
@@ -1487,6 +1504,14 @@ retry:
 		goto out_unlock;
 
 	/* look for a matching existing root */
+	if (!opts.subsys_mask && !opts.none && !opts.name) {
+		cgrp_dfl_root_visible = true;
+		root = &cgrp_dfl_root;
+		cgroup_get(&root->cgrp);
+		ret = 0;
+		goto out_unlock;
+	}
+
 	for_each_root(root) {
 		bool name_match = false;
 
@@ -3622,6 +3647,13 @@ static long cgroup_create(struct cgroup *parent, const char *name,
 	struct cgroup_subsys *ss;
 	struct kernfs_node *kn;
 
+	/*
+	 * XXX: The default hierarchy isn't fully implemented yet.  Block
+	 * !root cgroup creation on it for now.
+	 */
+	if (root == &cgrp_dfl_root)
+		return -EINVAL;
+
 	/* allocate the cgroup and its ID, 0 is reserved for the root */
 	cgrp = kzalloc(sizeof(*cgrp), GFP_KERNEL);
 	if (!cgrp)
@@ -4061,7 +4093,8 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
  */
 int __init cgroup_init_early(void)
 {
-	static struct cgroup_sb_opts __initdata opts = { };
+	static struct cgroup_sb_opts __initdata opts =
+		{ .flags = CGRP_ROOT_SANE_BEHAVIOR };
 	struct cgroup_subsys *ss;
 	int i;
 
@@ -4198,7 +4231,7 @@ int proc_cgroup_show(struct seq_file *m, void *v)
 		struct cgroup *cgrp;
 		int ssid, count = 0;
 
-		if (root == &cgrp_dfl_root)
+		if (root == &cgrp_dfl_root && !cgrp_dfl_root_visible)
 			continue;
 
 		seq_printf(m, "%d:", root->hierarchy_id);
@@ -4631,15 +4664,10 @@ static int current_css_set_cg_links_read(struct seq_file *seq, void *v)
 	cset = rcu_dereference(current->cgroups);
 	list_for_each_entry(link, &cset->cgrp_links, cgrp_link) {
 		struct cgroup *c = link->cgrp;
-		const char *name = "?";
-
-		if (c != &cgrp_dfl_root.cgrp) {
-			cgroup_name(c, name_buf, NAME_MAX + 1);
-			name = name_buf;
-		}
 
+		cgroup_name(c, name_buf, NAME_MAX + 1);
 		seq_printf(seq, "Root %d group %s\n",
-			   c->root->hierarchy_id, name);
+			   c->root->hierarchy_id, name_buf);
 	}
 	rcu_read_unlock();
 	up_read(&css_set_rwsem);
-- 
1.8.5.3
