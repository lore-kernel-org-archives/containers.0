From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/4] cgroup: introduce sane_behavior mount option
Date: Fri, 12 Apr 2013 16:10:58 -0700
Message-ID: <1365808259-31073-4-git-send-email-tj@kernel.org>
References: <1365808259-31073-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1365808259-31073-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

It's a sad fact that at this point various cgroup controllers are
carrying so many idiosyncrasies and pure insanities that it simply
isn't possible to reach any sort of sane consistent behavior while
maintaining staying fully compatible with what already has been
exposed to userland.

As we can't break exposed userland interface, transitioning to sane
behaviors can only be done in steps while maintaining backwards
compatibility.  This patch introduces a new mount option -
__DEVEL__sane_behavior - which disables crazy features and enforces
consistent behaviors in cgroup core proper and various controllers.
As exactly which behaviors it changes are still being determined, the
mount option, at this point, is useful only for development of the new
behaviors.  As such, the mount option is prefixed with __DEVEL__ and
generates a warning message when used.

Eventually, once we get to the point where all controller's behaviors
are consistent enough to implement unified hierarchy, the __DEVEL__
prefix will be dropped, and more importantly, unified-hierarchy will
enforce sane_behavior by default.  Maybe we'll able to completely drop
the crazy stuff after a while, maybe not, but we at least have a
strategy to move on to saner behaviors.

This patch introduces the mount option and changes the following
behaviors in cgroup core.

* Mount options "noprefix" and "clone_children" are disallowed.  Also,
  cgroupfs file cgroup.clone_children is not created.

* When mounting an existing superblock, mount options should match.
  This is currently pretty crazy.  If one mounts a cgroup, creates a
  subdirectory, unmounts it and then mount it again with different
  option, it looks like the new options are applied but they aren't.

* Remount is disallowed.

The behaviors changes are documented in the comment above
CGRP_ROOT_SANE_BEHAVIOR enum and will be expanded as different
controllers are converted and planned improvements progress.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/linux/cgroup.h | 43 +++++++++++++++++++++++++++++++++++++++++++
 kernel/cgroup.c        | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 92 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index b21881e..9c300ad 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -156,6 +156,8 @@ enum {
 	 * specified at mount time and thus is implemented here.
 	 */
 	CGRP_CPUSET_CLONE_CHILDREN,
+	/* see the comment above CGRP_ROOT_SANE_BEHAVIOR for details */
+	CGRP_SANE_BEHAVIOR,
 };
 
 struct cgroup_name {
@@ -243,6 +245,37 @@ struct cgroup {
 
 /* cgroupfs_root->flags */
 enum {
+	/*
+	 * Unfortunately, cgroup core and various controllers are riddled
+	 * with idiosyncrasies and pointless options.  The following flag,
+	 * when set, will force sane behavior - some options are forced on,
+	 * others are disallowed, and some controllers will change their
+	 * hierarchical or other behaviors.
+	 *
+	 * The set of behaviors affected by this flag are still being
+	 * determined and developed and the mount option for this flag is
+	 * prefixed with __DEVEL__.  The prefix will be dropped once we
+	 * reach the point where all behaviors are compatible with the
+	 * planned unified hierarchy, which will automatically turn on this
+	 * flag.
+	 *
+	 * The followings are the behaviors currently affected this flag.
+	 *
+	 * - Mount options "noprefix" and "clone_children" are disallowed.
+	 *   Also, cgroupfs file cgroup.clone_children is not created.
+	 *
+	 * - When mounting an existing superblock, mount options should
+	 *   match.
+	 *
+	 * - Remount is disallowed.
+	 *
+	 * The followings are planned changes.
+	 *
+	 * - release_agent will be disallowed once replacement notification
+	 *   mechanism is implemented.
+	 */
+	CGRP_ROOT_SANE_BEHAVIOR	= (1 << 0),
+
 	CGRP_ROOT_NOPREFIX	= (1 << 1), /* mounted subsystems have no named prefix */
 	CGRP_ROOT_XATTR		= (1 << 2), /* supports extended attributes */
 };
@@ -360,6 +393,7 @@ struct cgroup_map_cb {
 /* cftype->flags */
 #define CFTYPE_ONLY_ON_ROOT	(1U << 0)	/* only create on root cg */
 #define CFTYPE_NOT_ON_ROOT	(1U << 1)	/* don't create on root cg */
+#define CFTYPE_INSANE		(1U << 2)	/* don't create if sane_behavior */
 
 #define MAX_CFTYPE_NAME		64
 
@@ -486,6 +520,15 @@ struct cgroup_scanner {
 	void *data;
 };
 
+/*
+ * See the comment above CGRP_ROOT_SANE_BEHAVIOR for details.  This
+ * function can be called as long as @cgrp is accessible.
+ */
+static inline bool cgroup_sane_behavior(const struct cgroup *cgrp)
+{
+	return cgrp->root->flags & CGRP_ROOT_SANE_BEHAVIOR;
+}
+
 /* Caller should hold rcu_read_lock() */
 static inline const char *cgroup_name(const struct cgroup *cgrp)
 {
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 8848070..e229800 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1080,6 +1080,8 @@ static int cgroup_show_options(struct seq_file *seq, struct dentry *dentry)
 	mutex_lock(&cgroup_root_mutex);
 	for_each_subsys(root, ss)
 		seq_printf(seq, ",%s", ss->name);
+	if (root->flags & CGRP_ROOT_SANE_BEHAVIOR)
+		seq_puts(seq, ",sane_behavior");
 	if (root->flags & CGRP_ROOT_NOPREFIX)
 		seq_puts(seq, ",noprefix");
 	if (root->flags & CGRP_ROOT_XATTR)
@@ -1144,6 +1146,10 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 			all_ss = true;
 			continue;
 		}
+		if (!strcmp(token, "__DEVEL__sane_behavior")) {
+			opts->flags |= CGRP_ROOT_SANE_BEHAVIOR;
+			continue;
+		}
 		if (!strcmp(token, "noprefix")) {
 			opts->flags |= CGRP_ROOT_NOPREFIX;
 			continue;
@@ -1231,6 +1237,20 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 
 	/* Consistency checks */
 
+	if (opts->flags & CGRP_ROOT_SANE_BEHAVIOR) {
+		pr_warning("cgroup: sane_behavior: this is still under development and its behaviors will change, proceed at your own risk\n");
+
+		if (opts->flags & CGRP_ROOT_NOPREFIX) {
+			pr_err("cgroup: sane_behavior: noprefix is not allowed\n");
+			return -EINVAL;
+		}
+
+		if (opts->cpuset_clone_children) {
+			pr_err("cgroup: sane_behavior: clone_children is not allowed\n");
+			return -EINVAL;
+		}
+	}
+
 	/*
 	 * Option noprefix was introduced just for backward compatibility
 	 * with the old cpuset, so we allow noprefix only if mounting just
@@ -1307,6 +1327,11 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	struct cgroup_sb_opts opts;
 	unsigned long added_mask, removed_mask;
 
+	if (root->flags & CGRP_ROOT_SANE_BEHAVIOR) {
+		pr_err("cgroup: sane_behavior: remount is not allowed\n");
+		return -EINVAL;
+	}
+
 	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
 	mutex_lock(&cgroup_mutex);
 	mutex_lock(&cgroup_root_mutex);
@@ -1657,6 +1682,14 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		 * any) is not needed
 		 */
 		cgroup_drop_root(opts.new_root);
+
+		if (((root->flags | opts.flags) & CGRP_ROOT_SANE_BEHAVIOR) &&
+		    root->flags != opts.flags) {
+			pr_err("cgroup: sane_behavior: new mount options should match the existing superblock\n");
+			ret = -EINVAL;
+			goto drop_new_super;
+		}
+
 		/* no subsys rebinding, so refcounts don't change */
 		drop_parsed_module_refcounts(opts.subsys_mask);
 	}
@@ -2197,6 +2230,13 @@ static int cgroup_release_agent_show(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
+static int cgroup_sane_behavior_show(struct cgroup *cgrp, struct cftype *cft,
+				     struct seq_file *seq)
+{
+	seq_printf(seq, "%d\n", cgroup_sane_behavior(cgrp));
+	return 0;
+}
+
 /* A buffer size big enough for numbers or short strings */
 #define CGROUP_LOCAL_BUFFER_SIZE 64
 
@@ -2678,6 +2718,8 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 
 	for (cft = cfts; cft->name[0] != '\0'; cft++) {
 		/* does cft->flags tell us to skip this file on @cgrp? */
+		if ((cft->flags & CFTYPE_INSANE) && cgroup_sane_behavior(cgrp))
+			continue;
 		if ((cft->flags & CFTYPE_NOT_ON_ROOT) && !cgrp->parent)
 			continue;
 		if ((cft->flags & CFTYPE_ONLY_ON_ROOT) && cgrp->parent)
@@ -3915,10 +3957,17 @@ static struct cftype files[] = {
 	},
 	{
 		.name = "cgroup.clone_children",
+		.flags = CFTYPE_INSANE,
 		.read_u64 = cgroup_clone_children_read,
 		.write_u64 = cgroup_clone_children_write,
 	},
 	{
+		.name = "cgroup.sane_behavior",
+		.flags = CFTYPE_ONLY_ON_ROOT,
+		.read_seq_string = cgroup_sane_behavior_show,
+		.mode = S_IRUGO,
+	},
+	{
 		.name = "release_agent",
 		.flags = CFTYPE_ONLY_ON_ROOT,
 		.read_seq_string = cgroup_release_agent_show,
-- 
1.8.1.4
