From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/4] Allow cgroup hierarchies to be created with no bound
	subsystems
Date: Wed, 22 Jul 2009 12:50:45 -0700
Message-ID: <20090722195045.7481.62013.stgit@menage.mtv.corp.google.com>
References: <20090722194644.7481.47805.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090722194644.7481.47805.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Allow cgroup hierarchies to be created with no bound subsystems

This patch removes the restriction that a cgroup hierarchy must have
at least one bound subsystem.  The mount option "none" is treated as
an explicit request for no bound subsystems.

A hierarchy with no subsystems can be useful for plain task tracking,
and is also a step towards the support for multiply-bindable
subsystems.

As part of this change, the hierarchy id is no longer calculated from
the bitmask of subsystems in the hierarchy (since this is not
guaranteed to be unique) but is allocated via an ida.  Reference
counts on cgroups from css_set objects are now taken explicitly one
per hierarchy, rather than one per subsystem.

Example usage:

mount -t cgroup -o none,name=foo cgroup /mnt/cgroup

Based on the "no-op"/"none" subsystem concept proposed by
kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 kernel/cgroup.c |  158 ++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 99 insertions(+), 59 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3a970e0..3648331 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -49,6 +49,7 @@
 #include <linux/namei.h>
 #include <linux/smp_lock.h>
 #include <linux/pid_namespace.h>
+#include <linux/idr.h>
 
 #include <asm/atomic.h>
 
@@ -77,6 +78,9 @@ struct cgroupfs_root {
 	 */
 	unsigned long subsys_bits;
 
+	/* Unique id for this hierarchy. */
+	int hierarchy_id;
+
 	/* The bitmask of subsystems currently attached to this hierarchy */
 	unsigned long actual_subsys_bits;
 
@@ -147,6 +151,10 @@ struct css_id {
 static LIST_HEAD(roots);
 static int root_count;
 
+static DEFINE_IDA(hierarchy_ida);
+static int next_hierarchy_id;
+static DEFINE_SPINLOCK(hierarchy_id_lock);
+
 /* dummytop is a shorthand for the dummy hierarchy's top cgroup */
 #define dummytop (&rootnode.top_cgroup)
 
@@ -264,42 +272,10 @@ static struct hlist_head *css_set_hash(struct cgroup_subsys_state *css[])
  * compiled into their kernel but not actually in use */
 static int use_task_css_set_links __read_mostly;
 
-/* When we create or destroy a css_set, the operation simply
- * takes/releases a reference count on all the cgroups referenced
- * by subsystems in this css_set. This can end up multiple-counting
- * some cgroups, but that's OK - the ref-count is just a
- * busy/not-busy indicator; ensuring that we only count each cgroup
- * once would require taking a global lock to ensure that no
- * subsystems moved between hierarchies while we were doing so.
- *
- * Possible TODO: decide at boot time based on the number of
- * registered subsystems and the number of CPUs or NUMA nodes whether
- * it's better for performance to ref-count every subsystem, or to
- * take a global lock and only add one ref count to each hierarchy.
- */
-
-/*
- * unlink a css_set from the list and free it
- */
-static void unlink_css_set(struct css_set *cg)
+static void __put_css_set(struct css_set *cg, int taskexit)
 {
 	struct cg_cgroup_link *link;
 	struct cg_cgroup_link *saved_link;
-
-	hlist_del(&cg->hlist);
-	css_set_count--;
-
-	list_for_each_entry_safe(link, saved_link, &cg->cg_links,
-				 cg_link_list) {
-		list_del(&link->cg_link_list);
-		list_del(&link->cgrp_link_list);
-		kfree(link);
-	}
-}
-
-static void __put_css_set(struct css_set *cg, int taskexit)
-{
-	int i;
 	/*
 	 * Ensure that the refcount doesn't hit zero while any readers
 	 * can see it. Similar to atomic_dec_and_lock(), but for an
@@ -312,20 +288,27 @@ static void __put_css_set(struct css_set *cg, int taskexit)
 		write_unlock(&css_set_lock);
 		return;
 	}
-	unlink_css_set(cg);
-	write_unlock(&css_set_lock);
 
-	rcu_read_lock();
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		struct cgroup *cgrp = rcu_dereference(cg->subsys[i]->cgroup);
+	/* This css_set is dead. unlink it and release cgroup refcounts */
+	hlist_del(&cg->hlist);
+	css_set_count--;
+
+	list_for_each_entry_safe(link, saved_link, &cg->cg_links,
+				 cg_link_list) {
+		struct cgroup *cgrp = link->cgrp;
+		list_del(&link->cg_link_list);
+		list_del(&link->cgrp_link_list);
 		if (atomic_dec_and_test(&cgrp->count) &&
 		    notify_on_release(cgrp)) {
 			if (taskexit)
 				set_bit(CGRP_RELEASABLE, &cgrp->flags);
 			check_for_release(cgrp);
 		}
+
+		kfree(link);
 	}
-	rcu_read_unlock();
+
+	write_unlock(&css_set_lock);
 	kfree(cg);
 }
 
@@ -519,6 +502,7 @@ static void link_css_set(struct list_head *tmp_cg_links,
 				cgrp_link_list);
 	link->cg = cg;
 	link->cgrp = cgrp;
+	atomic_inc(&cgrp->count);
 	list_move(&link->cgrp_link_list, &cgrp->css_sets);
 	/*
 	 * Always add links to the tail of the list so that the list
@@ -539,7 +523,6 @@ static struct css_set *find_css_set(
 {
 	struct css_set *res;
 	struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
-	int i;
 
 	struct list_head tmp_cg_links;
 
@@ -578,10 +561,6 @@ static struct css_set *find_css_set(
 
 	write_lock(&css_set_lock);
 	/* Add reference counts and links from the new css_set. */
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		struct cgroup *cgrp = res->subsys[i]->cgroup;
-		atomic_inc(&cgrp->count);
-	}
 	list_for_each_entry(link, &oldcg->cg_links, cg_link_list) {
 		struct cgroup *c = link->cgrp;
 		if (c->root == cgrp->root)
@@ -960,8 +939,11 @@ struct cgroup_sb_opts {
 	unsigned long flags;
 	char *release_agent;
 	char *name;
+	/* User explicitly requested empty subsystem */
+	bool none;
 
 	struct cgroupfs_root *new_root;
+
 };
 
 /* Convert a hierarchy specifier into a bitmask of subsystems and
@@ -990,6 +972,9 @@ static int parse_cgroupfs_options(char *data,
 				if (!ss->disabled)
 					opts->subsys_bits |= 1ul << i;
 			}
+		} else if (!strcmp(token, "none")) {
+			/* Explicitly have no subsystems */
+			opts->none = true;
 		} else if (!strcmp(token, "noprefix")) {
 			set_bit(ROOT_NOPREFIX, &opts->flags);
 		} else if (!strncmp(token, "release_agent=", 14)) {
@@ -1039,6 +1024,8 @@ static int parse_cgroupfs_options(char *data,
 		}
 	}
 
+	/* Consistency checks */
+
 	/*
 	 * Option noprefix was introduced just for backward compatibility
 	 * with the old cpuset, so we allow noprefix only if mounting just
@@ -1048,7 +1035,15 @@ static int parse_cgroupfs_options(char *data,
 	    (opts->subsys_bits & mask))
 		return -EINVAL;
 
-	/* We can't have an empty hierarchy */
+
+	/* Can't specify "none" and some subsystems */
+	if (opts->subsys_bits && opts->none)
+		return -EINVAL;
+
+	/*
+	 * We either have to specify by name or by subsystems. (So all
+	 * empty hierarchies must have a name).
+	 */
 	if (!opts->subsys_bits && !opts->name)
 		return -EINVAL;
 
@@ -1129,6 +1124,31 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 	init_cgroup_housekeeping(cgrp);
 }
 
+static bool init_root_id(struct cgroupfs_root *root)
+{
+	int ret = 0;
+
+	do {
+		if (!ida_pre_get(&hierarchy_ida, GFP_KERNEL))
+			return false;
+		spin_lock(&hierarchy_id_lock);
+		/* Try to allocate the next unused ID */
+		ret = ida_get_new_above(&hierarchy_ida, next_hierarchy_id,
+					&root->hierarchy_id);
+		if (ret == -ENOSPC)
+			/* Try again starting from 0 */
+			ret = ida_get_new(&hierarchy_ida, &root->hierarchy_id);
+		if (!ret) {
+			next_hierarchy_id = root->hierarchy_id + 1;
+		} else if (ret != -EAGAIN) {
+			/* Can only get here if the 31-bit IDR is full ... */
+			BUG_ON(ret);
+		}
+		spin_unlock(&hierarchy_id_lock);
+	} while (ret);
+	return true;
+}
+
 static int cgroup_test_super(struct super_block *sb, void *data)
 {
 	struct cgroup_sb_opts *opts = data;
@@ -1138,8 +1158,12 @@ static int cgroup_test_super(struct super_block *sb, void *data)
 	if (opts->name && strcmp(opts->name, root->name))
 		return 0;
 
-	/* If we asked for subsystems then they must match */
-	if (opts->subsys_bits && (opts->subsys_bits != root->subsys_bits))
+	/*
+	 * If we asked for subsystems (or explicitly for no
+	 * subsystems) then they must match
+	 */
+	if ((opts->subsys_bits || opts->none)
+	    && (opts->subsys_bits != root->subsys_bits))
 		return 0;
 
 	return 1;
@@ -1149,15 +1173,19 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
 {
 	struct cgroupfs_root *root;
 
-	/* Empty hierarchies aren't supported */
-	if (!opts->subsys_bits)
+	if (!opts->subsys_bits && !opts->none)
 		return NULL;
 
 	root = kzalloc(sizeof(*root), GFP_KERNEL);
 	if (!root)
 		return ERR_PTR(-ENOMEM);
 
+	if (!init_root_id(root)) {
+		kfree(root);
+		return ERR_PTR(-ENOMEM);
+	}
 	init_cgroup_root(root);
+
 	root->subsys_bits = opts->subsys_bits;
 	root->flags = opts->flags;
 	if (opts->release_agent)
@@ -1167,6 +1195,18 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
 	return root;
 }
 
+static void cgroup_drop_root(struct cgroupfs_root *root)
+{
+	if (!root)
+		return;
+
+	BUG_ON(!root->hierarchy_id);
+	spin_lock(&hierarchy_id_lock);
+	ida_remove(&hierarchy_ida, root->hierarchy_id);
+	spin_unlock(&hierarchy_id_lock);
+	kfree(root);
+}
+
 static int cgroup_set_super(struct super_block *sb, void *data)
 {
 	int ret;
@@ -1176,7 +1216,7 @@ static int cgroup_set_super(struct super_block *sb, void *data)
 	if (!opts->new_root)
 		return -EINVAL;
 
-	BUG_ON(!opts->subsys_bits);
+	BUG_ON(!opts->subsys_bits && !opts->none);
 
 	ret = set_anon_super(sb, NULL);
 	if (ret)
@@ -1246,7 +1286,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 	sb = sget(fs_type, cgroup_test_super, cgroup_set_super, &opts);
 	if (IS_ERR(sb)) {
 		ret = PTR_ERR(sb);
-		kfree(opts.new_root);
+		cgroup_drop_root(opts.new_root);
 		goto out_err;
 	}
 
@@ -1340,7 +1380,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 		 * We re-used an existing hierarchy - the new root (if
 		 * any) is not needed
 		 */
-		kfree(opts.new_root);
+		cgroup_drop_root(opts.new_root);
 	}
 
 	simple_set_mnt(mnt, sb);
@@ -1400,7 +1440,7 @@ static void cgroup_kill_sb(struct super_block *sb) {
 	mutex_unlock(&cgroup_mutex);
 
 	kill_litter_super(sb);
-	kfree(root);
+	cgroup_drop_root(root);
 }
 
 static struct file_system_type cgroup_fs_type = {
@@ -3090,7 +3130,7 @@ int __init cgroup_init(void)
 	/* Add init_css_set to the hash table */
 	hhead = css_set_hash(init_css_set.subsys);
 	hlist_add_head(&init_css_set.hlist, hhead);
-
+	BUG_ON(!init_root_id(&rootnode));
 	err = register_filesystem(&cgroup_fs_type);
 	if (err < 0)
 		goto out;
@@ -3145,7 +3185,7 @@ static int proc_cgroup_show(struct seq_file *m, void *v)
 		struct cgroup *cgrp;
 		int count = 0;
 
-		seq_printf(m, "%lu:", root->subsys_bits);
+		seq_printf(m, "%d:", root->hierarchy_id);
 		for_each_subsys(root, ss)
 			seq_printf(m, "%s%s", count++ ? "," : "", ss->name);
 		if (strlen(root->name))
@@ -3191,8 +3231,8 @@ static int proc_cgroupstats_show(struct seq_file *m, void *v)
 	mutex_lock(&cgroup_mutex);
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
-		seq_printf(m, "%s\t%lu\t%d\t%d\n",
-			   ss->name, ss->root->subsys_bits,
+		seq_printf(m, "%s\t%d\t%d\t%d\n",
+			   ss->name, ss->root->hierarchy_id,
 			   ss->root->number_of_cgroups, !ss->disabled);
 	}
 	mutex_unlock(&cgroup_mutex);
@@ -3910,8 +3950,8 @@ static int current_css_set_cg_links_read(struct cgroup *cont,
 			name = c->dentry->d_name.name;
 		else
 			name = "?";
-		seq_printf(seq, "Root %lu group %s\n",
-			   c->root->subsys_bits, name);
+		seq_printf(seq, "Root %d group %s\n",
+			   c->root->hierarchy_id, name);
 	}
 	rcu_read_unlock();
 	read_unlock(&css_set_lock);
