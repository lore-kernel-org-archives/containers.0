From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [RFC] [PATCH 1/5] cgroups: revamp subsys array
Date: Fri, 4 Dec 2009 03:55:08 -0500
Message-ID: <20091204085508.GA18912__36150.1714367934$1259917013$gmane$org@andrew.cmu.edu>
References: <20091204085349.GA18867@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: attachment; filename="cgroups-revamp-subsys-array.patch"
In-Reply-To: <20091204085349.GA18867-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org
List-Id: containers.vger.kernel.org

Make subsys[] able to be dynamically populated to support modular subsystems

From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

This patch reworks the way the subsys[] array is used so that subsystems can
register themselves after boot time, and enables the internals of cgroups to
be able to handle when subsystems are not present or may appear/disappear.

Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
---

 include/linux/cgroup.h |    8 +++-
 kernel/cgroup.c        |   92 ++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 82 insertions(+), 18 deletions(-)


diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 642a47f..d7f1545 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -41,13 +41,17 @@ extern int cgroupstats_build(struct cgroupstats *stats,
 
 extern struct file_operations proc_cgroup_operations;
 
-/* Define the enumeration of all cgroup subsystems */
+/* Define the enumeration of all builtin cgroup subsystems */
 #define SUBSYS(_x) _x ## _subsys_id,
 enum cgroup_subsys_id {
 #include <linux/cgroup_subsys.h>
-	CGROUP_SUBSYS_COUNT
+	CGROUP_BUILTIN_SUBSYS_COUNT
 };
 #undef SUBSYS
+/* This define indicates the maximum number of subsystems that can be loaded
+ * at once. We limit to this many since cgroupfs_root has subsys_bits to keep
+ * track of all of them. */
+#define CGROUP_SUBSYS_COUNT (BITS_PER_BYTE*sizeof(unsigned long))
 
 /* Per-subsystem/per-cgroup state maintained by the system. */
 struct cgroup_subsys_state {
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7af6168..84448d0 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -58,10 +58,15 @@ static DEFINE_MUTEX(cgroup_mutex);
 
 /* Generate an array of cgroup subsystem pointers */
 #define SUBSYS(_x) &_x ## _subsys,
-
-static struct cgroup_subsys *subsys[] = {
+static struct cgroup_subsys *subsys[CGROUP_SUBSYS_COUNT] = {
 #include <linux/cgroup_subsys.h>
 };
+/*
+ * this lock protects the dynamic section of the array, in which modular
+ * subsystems are loaded. nests outside of cgroup_mutex, because of both
+ * cgroup_get_sb and cgroup_load_subsys.
+ */
+static DECLARE_RWSEM(subsys_mutex);
 
 #define MAX_CGROUP_ROOT_NAMELEN 64
 
@@ -433,8 +438,9 @@ static struct css_set *find_existing_css_set(
 	struct hlist_node *node;
 	struct css_set *cg;
 
-	/* Built the set of subsystem state objects that we want to
-	 * see in the new css_set */
+	/* Built the set of subsystem state objects that we want to see in the
+	 * new css_set. while subsystems can change globally, the entries here
+	 * won't change, so no need for subsys_mutex. */
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		if (root->subsys_bits & (1UL << i)) {
 			/* Subsystem is in this hierarchy. So we want
@@ -869,7 +875,9 @@ void cgroup_release_and_wakeup_rmdir(struct cgroup_subsys_state *css)
 	css_put(css);
 }
 
-
+/*
+ * Call with subsys_mutex held - see parse_cgroupfs_options.
+ */
 static int rebind_subsystems(struct cgroupfs_root *root,
 			      unsigned long final_bits)
 {
@@ -877,6 +885,8 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	struct cgroup *cgrp = &root->top_cgroup;
 	int i;
 
+	BUG_ON(!rwsem_is_locked(&subsys_mutex));
+
 	removed_bits = root->actual_subsys_bits & ~final_bits;
 	added_bits = final_bits & ~root->actual_subsys_bits;
 	/* Check that any added subsystems are currently free */
@@ -885,6 +895,12 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 		struct cgroup_subsys *ss = subsys[i];
 		if (!(bit & added_bits))
 			continue;
+		/* nobody should tell us to do a subsys that doesn't exist:
+		 * parse_cgroupfs_options should catch that case (subsys_mutex
+		 * prevents state from changing in between), and the only time
+		 * we're called without that beforehand is when the bitmask is
+		 * 0 in cgroup_kill_sb. */
+		BUG_ON(ss == NULL);
 		if (ss->root != &rootnode) {
 			/* Subsystem isn't free */
 			return -EBUSY;
@@ -904,6 +920,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 		unsigned long bit = 1UL << i;
 		if (bit & added_bits) {
 			/* We're binding this subsystem to this hierarchy */
+			BUG_ON(ss == NULL);
 			BUG_ON(cgrp->subsys[i]);
 			BUG_ON(!dummytop->subsys[i]);
 			BUG_ON(dummytop->subsys[i]->cgroup != dummytop);
@@ -915,8 +932,11 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			if (ss->bind)
 				ss->bind(ss, cgrp);
 			mutex_unlock(&ss->hierarchy_mutex);
+			/* TODO: If subsystem unloading support, need to take
+			 * a reference on the subsystem here. */
 		} else if (bit & removed_bits) {
 			/* We're removing this subsystem */
+			BUG_ON(ss == NULL);
 			BUG_ON(cgrp->subsys[i] != dummytop->subsys[i]);
 			BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
 			mutex_lock(&ss->hierarchy_mutex);
@@ -927,8 +947,11 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			subsys[i]->root = &rootnode;
 			list_move(&ss->sibling, &rootnode.subsys_list);
 			mutex_unlock(&ss->hierarchy_mutex);
+			/* TODO: If subsystem unloading support, drop refcount
+			 * here. */
 		} else if (bit & final_bits) {
 			/* Subsystem state should already exist */
+			BUG_ON(ss == NULL);
 			BUG_ON(!cgrp->subsys[i]);
 		} else {
 			/* Subsystem state shouldn't exist */
@@ -971,14 +994,18 @@ struct cgroup_sb_opts {
 
 };
 
-/* Convert a hierarchy specifier into a bitmask of subsystems and
- * flags. */
+/*
+ * Convert a hierarchy specifier into a bitmask of subsystems and flags. Call
+ * with subsys_mutex held to guard subsys[] between us and rebind_subsystems.
+ */
 static int parse_cgroupfs_options(char *data,
 				     struct cgroup_sb_opts *opts)
 {
 	char *token, *o = data ?: "all";
 	unsigned long mask = (unsigned long)-1;
 
+	BUG_ON(!rwsem_is_locked(&subsys_mutex));
+
 #ifdef CONFIG_CPUSETS
 	mask = ~(1UL << cpuset_subsys_id);
 #endif
@@ -994,6 +1021,8 @@ static int parse_cgroupfs_options(char *data,
 			opts->subsys_bits = 0;
 			for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 				struct cgroup_subsys *ss = subsys[i];
+				if (ss == NULL)
+					continue;
 				if (!ss->disabled)
 					opts->subsys_bits |= 1ul << i;
 			}
@@ -1038,6 +1067,8 @@ static int parse_cgroupfs_options(char *data,
 			int i;
 			for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 				ss = subsys[i];
+				if (ss == NULL)
+					continue;
 				if (!strcmp(token, ss->name)) {
 					if (!ss->disabled)
 						set_bit(i, &opts->subsys_bits);
@@ -1084,6 +1115,7 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 
 	lock_kernel();
 	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
+	down_read(&subsys_mutex);
 	mutex_lock(&cgroup_mutex);
 
 	/* See what subsystems are wanted */
@@ -1116,6 +1148,7 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	kfree(opts.release_agent);
 	kfree(opts.name);
 	mutex_unlock(&cgroup_mutex);
+	up_read(&subsys_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 	unlock_kernel();
 	return ret;
@@ -1291,6 +1324,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 	struct cgroupfs_root *new_root;
 
 	/* First find the desired set of subsystems */
+	down_read(&subsys_mutex);
 	ret = parse_cgroupfs_options(data, &opts);
 	if (ret)
 		goto out_err;
@@ -1367,6 +1401,8 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 			free_cg_links(&tmp_cg_links);
 			goto drop_new_super;
 		}
+		/* done with subsys stuff and no other failure case */
+		up_read(&subsys_mutex);
 
 		/* EBUSY should be the only error here */
 		BUG_ON(ret);
@@ -1415,6 +1451,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
  drop_new_super:
 	deactivate_locked_super(sb);
  out_err:
+	up_read(&subsys_mutex);
 	kfree(opts.release_agent);
 	kfree(opts.name);
 
@@ -1434,10 +1471,12 @@ static void cgroup_kill_sb(struct super_block *sb) {
 	BUG_ON(!list_empty(&cgrp->children));
 	BUG_ON(!list_empty(&cgrp->sibling));
 
+	down_read(&subsys_mutex);
 	mutex_lock(&cgroup_mutex);
 
 	/* Rebind all subsystems back to the default hierarchy */
 	ret = rebind_subsystems(root, 0);
+	up_read(&subsys_mutex);
 	/* Shouldn't be able to fail ... */
 	BUG_ON(ret);
 
@@ -3276,9 +3315,12 @@ static void cgroup_lock_hierarchy(struct cgroupfs_root *root)
 {
 	/* We need to take each hierarchy_mutex in a consistent order */
 	int i;
-
+	/* no worry about a race with rebind_subsystems that might mess up the
+	 * locking order, since both parties are under cgroup_mutex. */
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
+		if (ss == NULL)
+			continue;
 		if (ss->root == root)
 			mutex_lock(&ss->hierarchy_mutex);
 	}
@@ -3287,9 +3329,10 @@ static void cgroup_lock_hierarchy(struct cgroupfs_root *root)
 static void cgroup_unlock_hierarchy(struct cgroupfs_root *root)
 {
 	int i;
-
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
+		if (ss == NULL)
+			continue;
 		if (ss->root == root)
 			mutex_unlock(&ss->hierarchy_mutex);
 	}
@@ -3410,11 +3453,14 @@ static int cgroup_has_css_refs(struct cgroup *cgrp)
 	 * synchronization other than RCU, and the subsystem linked
 	 * list isn't RCU-safe */
 	int i;
+	/* we won't need to lock the subsys array, because the subsystems
+	 * we're concerned about aren't going anywhere since our cgroup root
+	 * has a reference on them. */
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
 		struct cgroup_subsys_state *css;
-		/* Skip subsystems not in this hierarchy */
-		if (ss->root != cgrp->root)
+		/* Skip subsystems not present or not in this hierarchy */
+		if (ss == NULL || ss->root != cgrp->root)
 			continue;
 		css = cgrp->subsys[ss->subsys_id];
 		/* When called from check_for_release() it's possible
@@ -3635,7 +3681,8 @@ int __init cgroup_init_early(void)
 	for (i = 0; i < CSS_SET_TABLE_SIZE; i++)
 		INIT_HLIST_HEAD(&css_set_table[i]);
 
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+	/* at bootup time, we don't worry about modular subsystems */
+	for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
 
 		BUG_ON(!ss->name);
@@ -3670,7 +3717,8 @@ int __init cgroup_init(void)
 	if (err)
 		return err;
 
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+	/* at bootup time, we don't worry about modular subsystems */
+	for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
 		if (!ss->early_init)
 			cgroup_init_subsys(ss);
@@ -3779,14 +3827,19 @@ static int proc_cgroupstats_show(struct seq_file *m, void *v)
 	int i;
 
 	seq_puts(m, "#subsys_name\thierarchy\tnum_cgroups\tenabled\n");
+	/* ideally we don't want subsystems moving around while we do this */
+	down_read(&subsys_mutex);
 	mutex_lock(&cgroup_mutex);
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
+		if (ss == NULL)
+			continue;
 		seq_printf(m, "%s\t%d\t%d\t%d\n",
 			   ss->name, ss->root->hierarchy_id,
 			   ss->root->number_of_cgroups, !ss->disabled);
 	}
 	mutex_unlock(&cgroup_mutex);
+	up_read(&subsys_mutex);
 	return 0;
 }
 
@@ -3841,7 +3894,10 @@ void cgroup_fork_callbacks(struct task_struct *child)
 {
 	if (need_forkexit_callback) {
 		int i;
-		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+		/* forkexit callbacks are only supported for builtin modules,
+		 * and the builtin section of the subsys array is immutable,
+		 * so we don't need the subsys_lock here. */
+		for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss = subsys[i];
 			if (ss->fork)
 				ss->fork(ss, child);
@@ -3912,7 +3968,9 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 	struct css_set *cg;
 
 	if (run_callbacks && need_forkexit_callback) {
-		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+		/* modular subsystems can't use callbacks, so no need to take
+		 * subsys_lock */
+		for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss = subsys[i];
 			if (ss->exit)
 				ss->exit(ss, tsk);
@@ -4221,7 +4279,9 @@ static int __init cgroup_disable(char *str)
 		if (!*token)
 			continue;
 
-		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+		/* cgroup_disable, being at boot time, can't know about module
+		 * subsystems, so we don't worry about them. */
+		for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss = subsys[i];
 
 			if (!strcmp(token, ss->name)) {
