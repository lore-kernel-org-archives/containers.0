From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 5/7] [RFC] Remove cgroup_subsys.root pointer
Date: Thu, 12 Mar 2009 03:51:42 -0700
Message-ID: <20090312105142.24154.95590.stgit@menage.corp.google.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090312104507.24154.71691.stgit-B63HFAS8fGlSzHKm+aFRNNkmqwFzkYv6@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
List-Id: containers.vger.kernel.org

[RFC] Remove cgroup_subsys.root pointer

In preparation for supporting cgroup subsystems that can be bound to
multiple hierarchies, remove the "root" pointer and associated list
structures.  Subsystem hierarchy membership is now determined entirely
through the subsystem bitmasks in struct cgroupfs_root.

Minor changes include:
  - root_list now includes the inactive root
  - for_each_active_root() -> for_each_root()
  - for_each_subsys() is now guaranteed to be in subsys_id order


Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 include/linux/cgroup.h |   16 ++----
 kernel/cgroup.c        |  128 +++++++++++++++++++++++++++---------------------
 2 files changed, 77 insertions(+), 67 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 665fa70..adf6739 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -227,7 +227,9 @@ struct css_set {
 	/*
 	 * Set of subsystem states, one for each subsystem. This array
 	 * is immutable after creation apart from the init_css_set
-	 * during subsystem registration (at boot time).
+	 * during subsystem registration (at boot
+	 * time). Multi-subsystems don't have an entry in here since
+	 * there's no unique state for a given task.
 	 */
 	struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT];
 };
@@ -401,9 +403,9 @@ struct cgroup_subsys {
 	/*
 	 * Protects sibling/children links of cgroups in this
 	 * hierarchy, plus protects which hierarchy (or none) the
-	 * subsystem is a part of (i.e. root/sibling).  To avoid
-	 * potential deadlocks, the following operations should not be
-	 * undertaken while holding any hierarchy_mutex:
+	 * subsystem is a part of.  To avoid potential deadlocks, the
+	 * following operations should not be undertaken while holding
+	 * any hierarchy_mutex:
 	 *
 	 * - allocating memory
 	 * - initiating hotplug events
@@ -411,12 +413,6 @@ struct cgroup_subsys {
 	struct mutex hierarchy_mutex;
 	struct lock_class_key subsys_key;
 
-	/*
-	 * Link to parent, and list entry in parent's children.
-	 * Protected by this->hierarchy_mutex and cgroup_lock()
-	 */
-	struct cgroupfs_root *root;
-	struct list_head sibling;
 	/* used when use_id == true */
 	struct idr idr;
 	spinlock_t id_lock;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 4a7ef2c..fcb8181 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -66,28 +66,19 @@ static struct cgroup_subsys *subsys[] = {
 struct cgroupfs_root {
 	struct super_block *sb;
 
-	/*
-	 * The bitmask of subsystems intended to be attached to this
-	 * hierarchy
-	 */
+	/* The bitmask of subsystems attached to this hierarchy */
 	unsigned long subsys_bits;
 
 	/* Unique id for this hierarchy. */
 	int hierarchy_id;
 
-	/* The bitmask of subsystems currently attached to this hierarchy */
-	unsigned long actual_subsys_bits;
-
-	/* A list running through the attached subsystems */
-	struct list_head subsys_list;
-
 	/* The root cgroup for this hierarchy */
 	struct cgroup top_cgroup;
 
 	/* Tracks how many cgroups are currently defined in hierarchy.*/
 	int number_of_cgroups;
 
-	/* A list running through the active hierarchies */
+	/* A list running through all hierarchies */
 	struct list_head root_list;
 
 	/* Hierarchy-specific flags */
@@ -187,13 +178,36 @@ static int notify_on_release(const struct cgroup *cgrp)
  * for_each_subsys() allows you to iterate on each subsystem attached to
  * an active hierarchy
  */
+static inline struct cgroup_subsys *nth_ss(int n)
+{
+	return (n >= CGROUP_SUBSYS_COUNT) ? NULL : subsys[n];
+}
 #define for_each_subsys(_root, _ss) \
-list_for_each_entry(_ss, &_root->subsys_list, sibling)
+for (_ss = nth_ss(find_first_bit(&(_root)->subsys_bits, CGROUP_SUBSYS_COUNT));\
+	    _ss != NULL;						      \
+    _ss = nth_ss(find_next_bit(&(_root)->subsys_bits, CGROUP_SUBSYS_COUNT,    \
+			       _ss->subsys_id + 1)))
 
-/* for_each_active_root() allows you to iterate across the active hierarchies */
-#define for_each_active_root(_root) \
+
+/* for_each_root() allows you to iterate across all hierarchies */
+#define for_each_root(_root) \
 list_for_each_entry(_root, &roots, root_list)
 
+/* Find the root for a given subsystem */
+static struct cgroupfs_root *find_root(struct cgroup_subsys *ss)
+{
+	int id = ss->subsys_id;
+	struct cgroupfs_root *root, *res = NULL;
+	for_each_root(root) {
+		if (root->subsys_bits && (1UL << id)) {
+			BUG_ON(res);
+			res = root;
+		}
+	}
+	BUG_ON(!res);
+	return res;
+}
+
 /* the list of cgroups eligible for automatic release. Protected by
  * release_list_lock */
 static LIST_HEAD(release_list);
@@ -419,7 +433,7 @@ static struct css_set *find_existing_css_set(
 	struct hlist_node *node;
 	struct css_set *cg;
 
-	/* Built the set of subsystem state objects that we want to
+	/* Build the set of subsystem state objects that we want to
 	 * see in the new css_set */
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		if (root->subsys_bits & (1UL << i)) {
@@ -840,21 +854,20 @@ static void cgroup_wakeup_rmdir_waiters(const struct cgroup *cgrp)
 }
 
 static int rebind_subsystems(struct cgroupfs_root *root,
-			      unsigned long final_bits)
+			     unsigned long final_bits)
 {
 	unsigned long added_bits, removed_bits;
 	struct cgroup *cgrp = &root->top_cgroup;
 	int i;
 
-	removed_bits = root->actual_subsys_bits & ~final_bits;
-	added_bits = final_bits & ~root->actual_subsys_bits;
+	removed_bits = root->subsys_bits & ~final_bits;
+	added_bits = final_bits & ~root->subsys_bits;
 	/* Check that any added subsystems are currently free */
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		unsigned long bit = 1UL << i;
-		struct cgroup_subsys *ss = subsys[i];
 		if (!(bit & added_bits))
 			continue;
-		if (ss->root != &rootnode) {
+		if (!(rootnode.subsys_bits & bit)) {
 			/* Subsystem isn't free */
 			return -EBUSY;
 		}
@@ -876,25 +889,27 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			BUG_ON(cgrp->subsys[i]);
 			BUG_ON(!dummytop->subsys[i]);
 			BUG_ON(dummytop->subsys[i]->cgroup != dummytop);
+			BUG_ON(!(rootnode.subsys_bits & bit));
 			mutex_lock(&ss->hierarchy_mutex);
 			cgrp->subsys[i] = dummytop->subsys[i];
 			cgrp->subsys[i]->cgroup = cgrp;
-			list_move(&ss->sibling, &root->subsys_list);
-			ss->root = root;
 			if (ss->bind)
 				ss->bind(ss, cgrp);
+			rootnode.subsys_bits &= ~bit;
+			root->subsys_bits |= bit;
 			mutex_unlock(&ss->hierarchy_mutex);
 		} else if (bit & removed_bits) {
 			/* We're removing this subsystem */
 			BUG_ON(cgrp->subsys[i] != dummytop->subsys[i]);
 			BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
+			BUG_ON(rootnode.subsys_bits & bit);
 			mutex_lock(&ss->hierarchy_mutex);
 			if (ss->bind)
 				ss->bind(ss, dummytop);
 			dummytop->subsys[i]->cgroup = dummytop;
 			cgrp->subsys[i] = NULL;
-			subsys[i]->root = &rootnode;
-			list_move(&ss->sibling, &rootnode.subsys_list);
+			root->subsys_bits &= ~bit;
+			rootnode.subsys_bits |= bit;
 			mutex_unlock(&ss->hierarchy_mutex);
 		} else if (bit & final_bits) {
 			/* Subsystem state should already exist */
@@ -904,7 +919,6 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			BUG_ON(cgrp->subsys[i]);
 		}
 	}
-	root->subsys_bits = root->actual_subsys_bits = final_bits;
 	synchronize_rcu();
 
 	return 0;
@@ -1083,7 +1097,6 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 static void init_cgroup_root(struct cgroupfs_root *root)
 {
 	struct cgroup *cgrp = &root->top_cgroup;
-	INIT_LIST_HEAD(&root->subsys_list);
 	INIT_LIST_HEAD(&root->root_list);
 	root->number_of_cgroups = 1;
 	cgrp->root = root;
@@ -1133,7 +1146,6 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
 	init_cgroup_root(root);
 	init_root_id(root);
 
-	root->subsys_bits = opts->subsys_bits;
 	root->flags = opts->flags;
 	if (opts->release_agent)
 		strcpy(root->release_agent_path, opts->release_agent);
@@ -1252,7 +1264,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 			goto drop_new_super;
 		}
 
-		ret = rebind_subsystems(root, root->subsys_bits);
+		ret = rebind_subsystems(root, opts.subsys_bits);
 		if (ret == -EBUSY) {
 			mutex_unlock(&cgroup_mutex);
 			mutex_unlock(&inode->i_mutex);
@@ -2596,24 +2608,16 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 static void cgroup_lock_hierarchy(struct cgroupfs_root *root)
 {
 	/* We need to take each hierarchy_mutex in a consistent order */
-	int i;
-
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		struct cgroup_subsys *ss = subsys[i];
-		if (ss->root == root)
-			mutex_lock(&ss->hierarchy_mutex);
-	}
+	struct cgroup_subsys *ss;
+	for_each_subsys(root, ss)
+		mutex_lock(&ss->hierarchy_mutex);
 }
 
 static void cgroup_unlock_hierarchy(struct cgroupfs_root *root)
 {
-	int i;
-
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		struct cgroup_subsys *ss = subsys[i];
-		if (ss->root == root)
-			mutex_unlock(&ss->hierarchy_mutex);
-	}
+	struct cgroup_subsys *ss;
+	for_each_subsys(root, ss)
+		mutex_unlock(&ss->hierarchy_mutex);
 }
 
 /*
@@ -2730,13 +2734,9 @@ static int cgroup_has_css_refs(struct cgroup *cgrp)
 	 * we can be called via check_for_release() with no
 	 * synchronization other than RCU, and the subsystem linked
 	 * list isn't RCU-safe */
-	int i;
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		struct cgroup_subsys *ss = subsys[i];
+	struct cgroup_subsys *ss;
+	for_each_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css;
-		/* Skip subsystems not in this hierarchy */
-		if (ss->root != cgrp->root)
-			continue;
 		css = cgrp->subsys[ss->subsys_id];
 		/* When called from check_for_release() it's possible
 		 * that by this point the cgroup has been removed
@@ -2894,8 +2894,6 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	printk(KERN_INFO "Initializing cgroup subsys %s\n", ss->name);
 
 	/* Create the top cgroup state for this subsystem */
-	list_add(&ss->sibling, &rootnode.subsys_list);
-	ss->root = &rootnode;
 	css = ss->create(ss, dummytop);
 	/* We don't handle early failures gracefully */
 	BUG_ON(IS_ERR(css));
@@ -2917,6 +2915,8 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	mutex_init(&ss->hierarchy_mutex);
 	lockdep_set_class(&ss->hierarchy_mutex, &ss->subsys_key);
 	ss->active = 1;
+
+	rootnode.subsys_bits |= 1ULL << ss->subsys_id;
 }
 
 /**
@@ -2934,6 +2934,7 @@ int __init cgroup_init_early(void)
 	INIT_HLIST_NODE(&init_css_set.hlist);
 	css_set_count = 1;
 	init_cgroup_root(&rootnode);
+	list_add(&rootnode.root_list, &roots);
 	root_count = 1;
 	init_task.cgroups = &init_css_set;
 
@@ -3043,11 +3044,14 @@ static int proc_cgroup_show(struct seq_file *m, void *v)
 
 	mutex_lock(&cgroup_mutex);
 
-	for_each_active_root(root) {
+	for_each_root(root) {
 		struct cgroup_subsys *ss;
 		struct cgroup *cgrp;
 		int count = 0;
 
+		if (root == &rootnode)
+			continue;
+
 		seq_printf(m, "%d:", root->hierarchy_id);
 		for_each_subsys(root, ss)
 			seq_printf(m, "%s%s", count++ ? "," : "", ss->name);
@@ -3086,17 +3090,27 @@ struct file_operations proc_cgroup_operations = {
 };
 
 /* Display information about each subsystem and each hierarchy */
+static void proc_show_subsys(struct seq_file *m, struct cgroupfs_root *root,
+			     struct cgroup_subsys *ss)
+{
+	seq_printf(m, "%s\t%d\t%d\t%d\n",
+		   ss->name, root->hierarchy_id,
+		   root->number_of_cgroups, !ss->disabled);
+}
+
 static int proc_cgroupstats_show(struct seq_file *m, void *v)
 {
 	int i;
-
 	seq_puts(m, "#subsys_name\thierarchy\tnum_cgroups\tenabled\n");
 	mutex_lock(&cgroup_mutex);
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
-		seq_printf(m, "%s\t%d\t%d\t%d\n",
-			   ss->name, ss->root->hierarchy_id,
-			   ss->root->number_of_cgroups, !ss->disabled);
+		unsigned long bit = 1ULL << ss->subsys_id;
+		struct cgroupfs_root *root;
+		for_each_root(root) {
+			if (root->subsys_bits & bit)
+				proc_show_subsys(m, root, ss);
+		}
 	}
 	mutex_unlock(&cgroup_mutex);
 	return 0;
@@ -3276,7 +3290,7 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
 	 * with, and pin them so we can drop cgroup_mutex */
 	mutex_lock(&cgroup_mutex);
  again:
-	root = subsys->root;
+	root = find_root(subsys);
 	if (root == &rootnode) {
 		mutex_unlock(&cgroup_mutex);
 		return 0;
@@ -3328,7 +3342,7 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
 	 * that we're still in the same state that we thought we
 	 * were. */
 	mutex_lock(&cgroup_mutex);
-	if ((root != subsys->root) ||
+	if ((root != find_root(subsys)) ||
 	    (parent != task_cgroup(tsk, subsys->subsys_id))) {
 		/* Aargh, we raced ... */
 		mutex_unlock(&inode->i_mutex);
