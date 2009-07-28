From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/4] Support named cgroups hierarchies
Date: Tue, 28 Jul 2009 16:26:21 -0700
Message-ID: <20090728232621.20156.45418.stgit__22816.126413136$1248823854$gmane$org@menage.mtv.corp.google.com>
References: <20090728232508.20156.17943.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090728232508.20156.17943.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Support named cgroups hierarchies

To simplify referring to cgroup hierarchies in mount statements, and
to allow disambiguation in the presence of empty hierarchies and
multiply-bindable subsystems this patch adds support for naming a new
cgroup hierarchy via the "name=" mount option

A pre-existing hierarchy may be specified by either name or by
subsystems; a hierarchy's name cannot be changed by a remount
operation.

Example usage:

# To create a hierarchy called "foo" containing the "cpu" subsystem
mount -t cgroup -oname=foo,cpu cgroup /mnt/cgroup1

# To mount the "foo" hierarchy on a second location
mount -t cgroup -oname=foo cgroup /mnt/cgroup2


Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

---

 Documentation/cgroups/cgroups.txt |   20 ++++
 kernel/cgroup.c                   |  185 +++++++++++++++++++++++++++----------
 2 files changed, 157 insertions(+), 48 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 6eb1a97..4bccfc1 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -408,6 +408,26 @@ You can attach the current shell task by echoing 0:
 
 # echo 0 > tasks
 
+2.3 Mounting hierarchies by name
+--------------------------------
+
+Passing the name=<x> option when mounting a cgroups hierarchy
+associates the given name with the hierarchy.  This can be used when
+mounting a pre-existing hierarchy, in order to refer to it by name
+rather than by its set of active subsystems.  Each hierarchy is either
+nameless, or has a unique name.
+
+The name should match [\w.-]+
+
+When passing a name=<x> option for a new hierarchy, you need to
+specify subsystems manually; the legacy behaviour of mounting all
+subsystems when none are explicitly specified is not supported when
+you give a subsystem a name.
+
+The name of the subsystem appears as part of the hierarchy description
+in /proc/mounts and /proc/<pid>/cgroups.
+
+
 3. Kernel API
 =============
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 18acba7..85573e8 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -23,6 +23,7 @@
  */
 
 #include <linux/cgroup.h>
+#include <linux/ctype.h>
 #include <linux/errno.h>
 #include <linux/fs.h>
 #include <linux/kernel.h>
@@ -60,6 +61,8 @@ static struct cgroup_subsys *subsys[] = {
 #include <linux/cgroup_subsys.h>
 };
 
+#define MAX_CGROUP_ROOT_NAMELEN 64
+
 /*
  * A cgroupfs_root represents the root of a cgroup hierarchy,
  * and may be associated with a superblock to form an active
@@ -94,6 +97,9 @@ struct cgroupfs_root {
 
 	/* The path to use for release notifications. */
 	char release_agent_path[PATH_MAX];
+
+	/* The name for this hierarchy - may be empty */
+	char name[MAX_CGROUP_ROOT_NAMELEN];
 };
 
 /*
@@ -829,6 +835,8 @@ static int cgroup_show_options(struct seq_file *seq, struct vfsmount *vfs)
 		seq_puts(seq, ",noprefix");
 	if (strlen(root->release_agent_path))
 		seq_printf(seq, ",release_agent=%s", root->release_agent_path);
+	if (strlen(root->name))
+		seq_printf(seq, ",name=%s", root->name);
 	mutex_unlock(&cgroup_mutex);
 	return 0;
 }
@@ -837,6 +845,9 @@ struct cgroup_sb_opts {
 	unsigned long subsys_bits;
 	unsigned long flags;
 	char *release_agent;
+	char *name;
+
+	struct cgroupfs_root *new_root;
 };
 
 /* Convert a hierarchy specifier into a bitmask of subsystems and
@@ -851,9 +862,7 @@ static int parse_cgroupfs_options(char *data,
 	mask = ~(1UL << cpuset_subsys_id);
 #endif
 
-	opts->subsys_bits = 0;
-	opts->flags = 0;
-	opts->release_agent = NULL;
+	memset(opts, 0, sizeof(*opts));
 
 	while ((token = strsep(&o, ",")) != NULL) {
 		if (!*token)
@@ -873,11 +882,33 @@ static int parse_cgroupfs_options(char *data,
 			/* Specifying two release agents is forbidden */
 			if (opts->release_agent)
 				return -EINVAL;
-			opts->release_agent = kzalloc(PATH_MAX, GFP_KERNEL);
+			opts->release_agent =
+				kstrndup(token + 14, PATH_MAX, GFP_KERNEL);
 			if (!opts->release_agent)
 				return -ENOMEM;
-			strncpy(opts->release_agent, token + 14, PATH_MAX - 1);
-			opts->release_agent[PATH_MAX - 1] = 0;
+		} else if (!strncmp(token, "name=", 5)) {
+			int i;
+			const char *name = token + 5;
+			/* Can't specify an empty name */
+			if (!strlen(name))
+				return -EINVAL;
+			/* Must match [\w.-]+ */
+			for (i = 0; i < strlen(name); i++) {
+				char c = name[i];
+				if (isalnum(c))
+					continue;
+				if ((c == '.') || (c == '-') || (c == '_'))
+					continue;
+				return -EINVAL;
+			}
+			/* Specifying two names is forbidden */
+			if (opts->name)
+				return -EINVAL;
+			opts->name = kstrndup(name,
+					      MAX_CGROUP_ROOT_NAMELEN,
+					      GFP_KERNEL);
+			if (!opts->name)
+				return -ENOMEM;
 		} else {
 			struct cgroup_subsys *ss;
 			int i;
@@ -904,7 +935,7 @@ static int parse_cgroupfs_options(char *data,
 		return -EINVAL;
 
 	/* We can't have an empty hierarchy */
-	if (!opts->subsys_bits)
+	if (!opts->subsys_bits && !opts->name)
 		return -EINVAL;
 
 	return 0;
@@ -932,6 +963,12 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 		goto out_unlock;
 	}
 
+	/* Don't allow name to change at remount */
+	if (opts.name && strcmp(opts.name, root->name)) {
+		ret = -EINVAL;
+		goto out_unlock;
+	}
+
 	ret = rebind_subsystems(root, opts.subsys_bits);
 	if (ret)
 		goto out_unlock;
@@ -943,6 +980,7 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 		strcpy(root->release_agent_path, opts.release_agent);
  out_unlock:
 	kfree(opts.release_agent);
+	kfree(opts.name);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 	unlock_kernel();
@@ -965,6 +1003,7 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	INIT_LIST_HEAD(&cgrp->pids_list);
 	init_rwsem(&cgrp->pids_mutex);
 }
+
 static void init_cgroup_root(struct cgroupfs_root *root)
 {
 	struct cgroup *cgrp = &root->top_cgroup;
@@ -978,31 +1017,59 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 
 static int cgroup_test_super(struct super_block *sb, void *data)
 {
-	struct cgroupfs_root *new = data;
+	struct cgroup_sb_opts *opts = data;
 	struct cgroupfs_root *root = sb->s_fs_info;
 
-	/* First check subsystems */
-	if (new->subsys_bits != root->subsys_bits)
-	    return 0;
+	/* If we asked for a name then it must match */
+	if (opts->name && strcmp(opts->name, root->name))
+		return 0;
 
-	/* Next check flags */
-	if (new->flags != root->flags)
+	/* If we asked for subsystems then they must match */
+	if (opts->subsys_bits && (opts->subsys_bits != root->subsys_bits))
 		return 0;
 
 	return 1;
 }
 
+static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
+{
+	struct cgroupfs_root *root;
+
+	/* Empty hierarchies aren't supported */
+	if (!opts->subsys_bits)
+		return NULL;
+
+	root = kzalloc(sizeof(*root), GFP_KERNEL);
+	if (!root)
+		return ERR_PTR(-ENOMEM);
+
+	init_cgroup_root(root);
+	root->subsys_bits = opts->subsys_bits;
+	root->flags = opts->flags;
+	if (opts->release_agent)
+		strcpy(root->release_agent_path, opts->release_agent);
+	if (opts->name)
+		strcpy(root->name, opts->name);
+	return root;
+}
+
 static int cgroup_set_super(struct super_block *sb, void *data)
 {
 	int ret;
-	struct cgroupfs_root *root = data;
+	struct cgroup_sb_opts *opts = data;
+
+	/* If we don't have a new root, we can't set up a new sb */
+	if (!opts->new_root)
+		return -EINVAL;
+
+	BUG_ON(!opts->subsys_bits);
 
 	ret = set_anon_super(sb, NULL);
 	if (ret)
 		return ret;
 
-	sb->s_fs_info = root;
-	root->sb = sb;
+	sb->s_fs_info = opts->new_root;
+	opts->new_root->sb = sb;
 
 	sb->s_blocksize = PAGE_CACHE_SIZE;
 	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
@@ -1039,48 +1106,43 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 			 void *data, struct vfsmount *mnt)
 {
 	struct cgroup_sb_opts opts;
+	struct cgroupfs_root *root;
 	int ret = 0;
 	struct super_block *sb;
-	struct cgroupfs_root *root;
-	struct list_head tmp_cg_links;
+	struct cgroupfs_root *new_root;
 
 	/* First find the desired set of subsystems */
 	ret = parse_cgroupfs_options(data, &opts);
-	if (ret) {
-		kfree(opts.release_agent);
-		return ret;
-	}
-
-	root = kzalloc(sizeof(*root), GFP_KERNEL);
-	if (!root) {
-		kfree(opts.release_agent);
-		return -ENOMEM;
-	}
+	if (ret)
+		goto out_err;
 
-	init_cgroup_root(root);
-	root->subsys_bits = opts.subsys_bits;
-	root->flags = opts.flags;
-	if (opts.release_agent) {
-		strcpy(root->release_agent_path, opts.release_agent);
-		kfree(opts.release_agent);
+	/*
+	 * Allocate a new cgroup root. We may not need it if we're
+	 * reusing an existing hierarchy.
+	 */
+	new_root = cgroup_root_from_opts(&opts);
+	if (IS_ERR(new_root)) {
+		ret = PTR_ERR(new_root);
+		goto out_err;
 	}
+	opts.new_root = new_root;
 
-	sb = sget(fs_type, cgroup_test_super, cgroup_set_super, root);
-
+	/* Locate an existing or new sb for this hierarchy */
+	sb = sget(fs_type, cgroup_test_super, cgroup_set_super, &opts);
 	if (IS_ERR(sb)) {
-		kfree(root);
-		return PTR_ERR(sb);
+		ret = PTR_ERR(sb);
+		kfree(opts.new_root);
+		goto out_err;
 	}
 
-	if (sb->s_fs_info != root) {
-		/* Reusing an existing superblock */
-		BUG_ON(sb->s_root == NULL);
-		kfree(root);
-		root = NULL;
-	} else {
-		/* New superblock */
+	root = sb->s_fs_info;
+	BUG_ON(!root);
+	if (root == opts.new_root) {
+		/* We used the new root structure, so this is a new hierarchy */
+		struct list_head tmp_cg_links;
 		struct cgroup *root_cgrp = &root->top_cgroup;
 		struct inode *inode;
+		struct cgroupfs_root *existing_root;
 		int i;
 
 		BUG_ON(sb->s_root != NULL);
@@ -1093,6 +1155,18 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 		mutex_lock(&inode->i_mutex);
 		mutex_lock(&cgroup_mutex);
 
+		if (strlen(root->name)) {
+			/* Check for name clashes with existing mounts */
+			for_each_active_root(existing_root) {
+				if (!strcmp(existing_root->name, root->name)) {
+					ret = -EBUSY;
+					mutex_unlock(&cgroup_mutex);
+					mutex_unlock(&inode->i_mutex);
+					goto drop_new_super;
+				}
+			}
+		}
+
 		/*
 		 * We're accessing css_set_count without locking
 		 * css_set_lock here, but that's OK - it can only be
@@ -1111,7 +1185,8 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 		if (ret == -EBUSY) {
 			mutex_unlock(&cgroup_mutex);
 			mutex_unlock(&inode->i_mutex);
-			goto free_cg_links;
+			free_cg_links(&tmp_cg_links);
+			goto drop_new_super;
 		}
 
 		/* EBUSY should be the only error here */
@@ -1145,15 +1220,26 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 		cgroup_populate_dir(root_cgrp);
 		mutex_unlock(&inode->i_mutex);
 		mutex_unlock(&cgroup_mutex);
+	} else {
+		/*
+		 * We re-used an existing hierarchy - the new root (if
+		 * any) is not needed
+		 */
+		kfree(opts.new_root);
 	}
 
 	simple_set_mnt(mnt, sb);
+	kfree(opts.release_agent);
+	kfree(opts.name);
 	return 0;
 
- free_cg_links:
-	free_cg_links(&tmp_cg_links);
  drop_new_super:
 	deactivate_locked_super(sb);
+
+ out_err:
+	kfree(opts.release_agent);
+	kfree(opts.name);
+
 	return ret;
 }
 
@@ -2971,6 +3057,9 @@ static int proc_cgroup_show(struct seq_file *m, void *v)
 		seq_printf(m, "%lu:", root->subsys_bits);
 		for_each_subsys(root, ss)
 			seq_printf(m, "%s%s", count++ ? "," : "", ss->name);
+		if (strlen(root->name))
+			seq_printf(m, "%sname=%s", count ? "," : "",
+				   root->name);
 		seq_putc(m, ':');
 		get_first_subsys(&root->top_cgroup, NULL, &subsys_id);
 		cgrp = task_cgroup(tsk, subsys_id);
