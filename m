From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 6/6] cgroup: implement for_each_[builtin_]subsys()
Date: Mon, 24 Jun 2013 17:22:36 -0700
Message-ID: <20130625002236.GU1918@mtj.dyndns.org>
References: <1371864854-28364-1-git-send-email-tj@kernel.org>
	<1371864854-28364-7-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1371864854-28364-7-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

There are quite a few places where all loaded [builtin] subsys are
iterated.  Implement for_each_[builtin_]subsys() and replace manual
iterations with those to simplify those places a bit.  The new
iterators automatically skip NULL subsystems.  This shouldn't cause
any functional difference.

Iteration loops which scan all subsystems and then skipping modular
ones explicitly are converted to use for_each_builtin_subsys().

While at it, reorder variable declarations and adjust whitespaces a
bit in the affected functions.

v2: Add lockdep_assert_held() in for_each_subsys() and add comments
    about synchronization as suggested by Li.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c |  147 +++++++++++++++++++++++++++-----------------------------
 1 file changed, 71 insertions(+), 76 deletions(-)

--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -259,6 +259,31 @@ static int notify_on_release(const struc
 	return test_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
 }
 
+/**
+ * for_each_subsys - iterate all loaded cgroup subsystems
+ * @ss: the iteration cursor
+ * @i: the index of @ss, CGROUP_SUBSYS_COUNT after reaching the end
+ *
+ * Should be called under cgroup_mutex.
+ */
+#define for_each_subsys(ss, i)						\
+	for ((i) = 0; (i) < CGROUP_SUBSYS_COUNT; (i)++)			\
+		if (({ lockdep_assert_held(&cgroup_mutex);		\
+		       !((ss) = cgroup_subsys[i]); })) { }		\
+		else
+
+/**
+ * for_each_builtin_subsys - iterate all built-in cgroup subsystems
+ * @ss: the iteration cursor
+ * @i: the index of @ss, CGROUP_BUILTIN_SUBSYS_COUNT after reaching the end
+ *
+ * Bulit-in subsystems are always present and iteration itself doesn't
+ * require any synchronization.
+ */
+#define for_each_builtin_subsys(ss, i)					\
+	for ((i) = 0; (i) < CGROUP_BUILTIN_SUBSYS_COUNT &&		\
+	     (((ss) = cgroup_subsys[i]) || true); (i)++)
+
 /* iterate each subsystem attached to a hierarchy */
 #define for_each_root_subsys(root, ss)					\
 	list_for_each_entry((ss), &(root)->subsys_list, sibling)
@@ -356,10 +381,11 @@ static DEFINE_HASHTABLE(css_set_table, C
 
 static unsigned long css_set_hash(struct cgroup_subsys_state *css[])
 {
-	int i;
 	unsigned long key = 0UL;
+	struct cgroup_subsys *ss;
+	int i;
 
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++)
+	for_each_subsys(ss, i)
 		key += (unsigned long)css[i];
 	key = (key >> 16) ^ key;
 
@@ -514,6 +540,7 @@ static struct css_set *find_existing_css
 					struct cgroup_subsys_state *template[])
 {
 	struct cgroupfs_root *root = cgrp->root;
+	struct cgroup_subsys *ss;
 	struct css_set *cset;
 	unsigned long key;
 	int i;
@@ -523,7 +550,7 @@ static struct css_set *find_existing_css
 	 * new css_set. while subsystems can change globally, the entries here
 	 * won't change, so no need for locking.
 	 */
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+	for_each_subsys(ss, i) {
 		if (root->subsys_mask & (1UL << i)) {
 			/* Subsystem is in this hierarchy. So we want
 			 * the subsystem state from the new
@@ -982,23 +1009,19 @@ static int rebind_subsystems(struct cgro
 			     unsigned long added_mask, unsigned removed_mask)
 {
 	struct cgroup *cgrp = &root->top_cgroup;
+	struct cgroup_subsys *ss;
 	int i;
 
 	BUG_ON(!mutex_is_locked(&cgroup_mutex));
 	BUG_ON(!mutex_is_locked(&cgroup_root_mutex));
 
 	/* Check that any added subsystems are currently free */
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+	for_each_subsys(ss, i) {
 		unsigned long bit = 1UL << i;
-		struct cgroup_subsys *ss = cgroup_subsys[i];
+
 		if (!(bit & added_mask))
 			continue;
-		/*
-		 * Nobody should tell us to do a subsys that doesn't exist:
-		 * parse_cgroupfs_options should catch that case and refcounts
-		 * ensure that subsystems won't disappear once selected.
-		 */
-		BUG_ON(ss == NULL);
+
 		if (ss->root != &cgroup_dummy_root) {
 			/* Subsystem isn't free */
 			return -EBUSY;
@@ -1013,12 +1036,11 @@ static int rebind_subsystems(struct cgro
 		return -EBUSY;
 
 	/* Process each subsystem */
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		struct cgroup_subsys *ss = cgroup_subsys[i];
+	for_each_subsys(ss, i) {
 		unsigned long bit = 1UL << i;
+
 		if (bit & added_mask) {
 			/* We're binding this subsystem to this hierarchy */
-			BUG_ON(ss == NULL);
 			BUG_ON(cgrp->subsys[i]);
 			BUG_ON(!cgroup_dummy_top->subsys[i]);
 			BUG_ON(cgroup_dummy_top->subsys[i]->cgroup != cgroup_dummy_top);
@@ -1034,7 +1056,6 @@ static int rebind_subsystems(struct cgro
 			root->subsys_mask |= bit;
 		} else if (bit & removed_mask) {
 			/* We're removing this subsystem */
-			BUG_ON(ss == NULL);
 			BUG_ON(cgrp->subsys[i] != cgroup_dummy_top->subsys[i]);
 			BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
 
@@ -1050,7 +1071,6 @@ static int rebind_subsystems(struct cgro
 			root->subsys_mask &= ~bit;
 		} else if (bit & root->subsys_mask) {
 			/* Subsystem state should already exist */
-			BUG_ON(ss == NULL);
 			BUG_ON(!cgrp->subsys[i]);
 			/*
 			 * a refcount was taken, but we already had one, so
@@ -1117,8 +1137,9 @@ static int parse_cgroupfs_options(char *
 	char *token, *o = data;
 	bool all_ss = false, one_ss = false;
 	unsigned long mask = (unsigned long)-1;
-	int i;
 	bool module_pin_failed = false;
+	struct cgroup_subsys *ss;
+	int i;
 
 	BUG_ON(!mutex_is_locked(&cgroup_mutex));
 
@@ -1195,10 +1216,7 @@ static int parse_cgroupfs_options(char *
 			continue;
 		}
 
-		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-			struct cgroup_subsys *ss = cgroup_subsys[i];
-			if (ss == NULL)
-				continue;
+		for_each_subsys(ss, i) {
 			if (strcmp(token, ss->name))
 				continue;
 			if (ss->disabled)
@@ -1221,16 +1239,10 @@ static int parse_cgroupfs_options(char *
 	 * otherwise if 'none', 'name=' and a subsystem name options
 	 * were not specified, let's default to 'all'
 	 */
-	if (all_ss || (!one_ss && !opts->none && !opts->name)) {
-		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-			struct cgroup_subsys *ss = cgroup_subsys[i];
-			if (ss == NULL)
-				continue;
-			if (ss->disabled)
-				continue;
-			set_bit(i, &opts->subsys_mask);
-		}
-	}
+	if (all_ss || (!one_ss && !opts->none && !opts->name))
+		for_each_subsys(ss, i)
+			if (!ss->disabled)
+				set_bit(i, &opts->subsys_mask);
 
 	/* Consistency checks */
 
@@ -1274,10 +1286,8 @@ static int parse_cgroupfs_options(char *
 	 * take duplicate reference counts on a subsystem that's already used,
 	 * but rebind_subsystems handles this case.
 	 */
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		unsigned long bit = 1UL << i;
-
-		if (!(bit & opts->subsys_mask))
+	for_each_subsys(ss, i) {
+		if (!(opts->subsys_mask & (1UL << i)))
 			continue;
 		if (!try_module_get(cgroup_subsys[i]->module)) {
 			module_pin_failed = true;
@@ -1306,11 +1316,11 @@ static int parse_cgroupfs_options(char *
 
 static void drop_parsed_module_refcounts(unsigned long subsys_mask)
 {
+	struct cgroup_subsys *ss;
 	int i;
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		unsigned long bit = 1UL << i;
 
-		if (!(bit & subsys_mask))
+	for_each_subsys(ss, i) {
+		if (!(subsys_mask & (1UL << i)))
 			continue;
 		module_put(cgroup_subsys[i]->module);
 	}
@@ -4822,7 +4832,9 @@ EXPORT_SYMBOL_GPL(cgroup_unload_subsys);
  */
 int __init cgroup_init_early(void)
 {
+	struct cgroup_subsys *ss;
 	int i;
+
 	atomic_set(&init_css_set.refcount, 1);
 	INIT_LIST_HEAD(&init_css_set.cgrp_links);
 	INIT_LIST_HEAD(&init_css_set.tasks);
@@ -4837,13 +4849,8 @@ int __init cgroup_init_early(void)
 	list_add(&init_cgrp_cset_link.cset_link, &cgroup_dummy_top->cset_links);
 	list_add(&init_cgrp_cset_link.cgrp_link, &init_css_set.cgrp_links);
 
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		struct cgroup_subsys *ss = cgroup_subsys[i];
-
-		/* at bootup time, we don't worry about modular subsystems */
-		if (!ss || ss->module)
-			continue;
-
+	/* at bootup time, we don't worry about modular subsystems */
+	for_each_builtin_subsys(ss, i) {
 		BUG_ON(!ss->name);
 		BUG_ON(strlen(ss->name) > MAX_CGROUP_TYPE_NAMELEN);
 		BUG_ON(!ss->css_alloc);
@@ -4868,20 +4875,15 @@ int __init cgroup_init_early(void)
  */
 int __init cgroup_init(void)
 {
-	int err;
-	int i;
+	struct cgroup_subsys *ss;
 	unsigned long key;
+	int i, err;
 
 	err = bdi_init(&cgroup_backing_dev_info);
 	if (err)
 		return err;
 
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		struct cgroup_subsys *ss = cgroup_subsys[i];
-
-		/* at bootup time, we don't worry about modular subsystems */
-		if (!ss || ss->module)
-			continue;
+	for_each_builtin_subsys(ss, i) {
 		if (!ss->early_init)
 			cgroup_init_subsys(ss);
 		if (ss->use_id)
@@ -4990,6 +4992,7 @@ out:
 /* Display information about each subsystem and each hierarchy */
 static int proc_cgroupstats_show(struct seq_file *m, void *v)
 {
+	struct cgroup_subsys *ss;
 	int i;
 
 	seq_puts(m, "#subsys_name\thierarchy\tnum_cgroups\tenabled\n");
@@ -4999,14 +5002,12 @@ static int proc_cgroupstats_show(struct
 	 * subsys/hierarchy state.
 	 */
 	mutex_lock(&cgroup_mutex);
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		struct cgroup_subsys *ss = cgroup_subsys[i];
-		if (ss == NULL)
-			continue;
+
+	for_each_subsys(ss, i)
 		seq_printf(m, "%s\t%d\t%d\t%d\n",
 			   ss->name, ss->root->hierarchy_id,
 			   ss->root->number_of_cgroups, !ss->disabled);
-	}
+
 	mutex_unlock(&cgroup_mutex);
 	return 0;
 }
@@ -5060,6 +5061,7 @@ void cgroup_fork(struct task_struct *chi
  */
 void cgroup_post_fork(struct task_struct *child)
 {
+	struct cgroup_subsys *ss;
 	int i;
 
 	/*
@@ -5096,12 +5098,9 @@ void cgroup_post_fork(struct task_struct
 		 * of the array can be freed at module unload, so we
 		 * can't touch that.
 		 */
-		for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
-			struct cgroup_subsys *ss = cgroup_subsys[i];
-
+		for_each_builtin_subsys(ss, i)
 			if (ss->fork)
 				ss->fork(child);
-		}
 	}
 }
 
@@ -5142,6 +5141,7 @@ void cgroup_post_fork(struct task_struct
  */
 void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 {
+	struct cgroup_subsys *ss;
 	struct css_set *cset;
 	int i;
 
@@ -5167,13 +5167,12 @@ void cgroup_exit(struct task_struct *tsk
 		 * fork/exit callbacks are supported only for builtin
 		 * subsystems, see cgroup_post_fork() for details.
 		 */
-		for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
-			struct cgroup_subsys *ss = cgroup_subsys[i];
-
+		for_each_builtin_subsys(ss, i) {
 			if (ss->exit) {
 				struct cgroup *old_cgrp =
 					rcu_dereference_raw(cset->subsys[i])->cgroup;
 				struct cgroup *cgrp = task_cgroup(tsk, i);
+
 				ss->exit(cgrp, old_cgrp, tsk);
 			}
 		}
@@ -5280,23 +5279,19 @@ static void cgroup_release_agent(struct
 
 static int __init cgroup_disable(char *str)
 {
-	int i;
+	struct cgroup_subsys *ss;
 	char *token;
+	int i;
 
 	while ((token = strsep(&str, ",")) != NULL) {
 		if (!*token)
 			continue;
-		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-			struct cgroup_subsys *ss = cgroup_subsys[i];
-
-			/*
-			 * cgroup_disable, being at boot time, can't
-			 * know about module subsystems, so we don't
-			 * worry about them.
-			 */
-			if (!ss || ss->module)
-				continue;
 
+		/*
+		 * cgroup_disable, being at boot time, can't know about
+		 * module subsystems, so we don't worry about them.
+		 */
+		for_each_builtin_subsys(ss, i) {
 			if (!strcmp(token, ss->name)) {
 				ss->disabled = 1;
 				printk(KERN_INFO "Disabling %s control group"
