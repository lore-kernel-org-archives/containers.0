From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 5/6] cgroup: s/for_each_subsys()/for_each_root_subsys()/
Date: Fri, 21 Jun 2013 18:34:13 -0700
Message-ID: <1371864854-28364-6-git-send-email-tj__5427.88587413288$1371864907$gmane$org@kernel.org>
References: <1371864854-28364-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371864854-28364-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

for_each_subsys() walks over subsystems attached to a hierarchy and
we're gonna add iterators which walk over all available subsystems.
Rename for_each_subsys() to for_each_root_subsys() so that it's more
appropriately named and for_each_subsys() can be used to iterate all
subsystems.

While at it, remove unnecessary underbar prefix from macro arguments,
put them inside parentheses, and adjust indentation for the two
for_each_*() macros.

This patch is purely cosmetic.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 47 ++++++++++++++++++++++-------------------------
 1 file changed, 22 insertions(+), 25 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5f85f3a..c4bbafb 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -259,16 +259,13 @@ static int notify_on_release(const struct cgroup *cgrp)
 	return test_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
 }
 
-/*
- * for_each_subsys() allows you to iterate on each subsystem attached to
- * an active hierarchy
- */
-#define for_each_subsys(_root, _ss) \
-list_for_each_entry(_ss, &_root->subsys_list, sibling)
+/* iterate each subsystem attached to a hierarchy */
+#define for_each_root_subsys(root, ss)					\
+	list_for_each_entry((ss), &(root)->subsys_list, sibling)
 
-/* for_each_active_root() allows you to iterate across the active hierarchies */
-#define for_each_active_root(_root) \
-list_for_each_entry(_root, &cgroup_roots, root_list)
+/* iterate across the active hierarchies */
+#define for_each_active_root(root)					\
+	list_for_each_entry((root), &cgroup_roots, root_list)
 
 static inline struct cgroup *__d_cgrp(struct dentry *dentry)
 {
@@ -828,7 +825,7 @@ static void cgroup_free_fn(struct work_struct *work)
 	/*
 	 * Release the subsystem state objects.
 	 */
-	for_each_subsys(cgrp->root, ss)
+	for_each_root_subsys(cgrp->root, ss)
 		ss->css_free(cgrp);
 
 	cgrp->root->number_of_cgroups--;
@@ -944,7 +941,7 @@ static void cgroup_clear_directory(struct dentry *dir, bool base_files,
 	struct cgroup *cgrp = __d_cgrp(dir);
 	struct cgroup_subsys *ss;
 
-	for_each_subsys(cgrp->root, ss) {
+	for_each_root_subsys(cgrp->root, ss) {
 		struct cftype_set *set;
 		if (!test_bit(ss->subsys_id, &subsys_mask))
 			continue;
@@ -1078,7 +1075,7 @@ static int cgroup_show_options(struct seq_file *seq, struct dentry *dentry)
 	struct cgroup_subsys *ss;
 
 	mutex_lock(&cgroup_root_mutex);
-	for_each_subsys(root, ss)
+	for_each_root_subsys(root, ss)
 		seq_printf(seq, ",%s", ss->name);
 	if (root->flags & CGRP_ROOT_SANE_BEHAVIOR)
 		seq_puts(seq, ",sane_behavior");
@@ -2054,7 +2051,7 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
 	/*
 	 * step 1: check that we can legitimately attach to the cgroup.
 	 */
-	for_each_subsys(root, ss) {
+	for_each_root_subsys(root, ss) {
 		if (ss->can_attach) {
 			retval = ss->can_attach(cgrp, &tset);
 			if (retval) {
@@ -2094,7 +2091,7 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
 	/*
 	 * step 4: do subsystem attach callbacks.
 	 */
-	for_each_subsys(root, ss) {
+	for_each_root_subsys(root, ss) {
 		if (ss->attach)
 			ss->attach(cgrp, &tset);
 	}
@@ -2114,7 +2111,7 @@ out_put_css_set_refs:
 	}
 out_cancel_attach:
 	if (retval) {
-		for_each_subsys(root, ss) {
+		for_each_root_subsys(root, ss) {
 			if (ss == failed_ss)
 				break;
 			if (ss->cancel_attach)
@@ -4140,7 +4137,7 @@ static int cgroup_populate_dir(struct cgroup *cgrp, bool base_files,
 	}
 
 	/* process cftsets of each subsystem */
-	for_each_subsys(cgrp->root, ss) {
+	for_each_root_subsys(cgrp->root, ss) {
 		struct cftype_set *set;
 		if (!test_bit(ss->subsys_id, &subsys_mask))
 			continue;
@@ -4150,7 +4147,7 @@ static int cgroup_populate_dir(struct cgroup *cgrp, bool base_files,
 	}
 
 	/* This cgroup is ready now */
-	for_each_subsys(cgrp->root, ss) {
+	for_each_root_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
 		struct css_id *id = rcu_dereference_protected(css->id, true);
 
@@ -4299,7 +4296,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	if (test_bit(CGRP_CPUSET_CLONE_CHILDREN, &parent->flags))
 		set_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags);
 
-	for_each_subsys(root, ss) {
+	for_each_root_subsys(root, ss) {
 		struct cgroup_subsys_state *css;
 
 		css = ss->css_alloc(cgrp);
@@ -4338,14 +4335,14 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	root->number_of_cgroups++;
 
 	/* each css holds a ref to the cgroup's dentry */
-	for_each_subsys(root, ss)
+	for_each_root_subsys(root, ss)
 		dget(dentry);
 
 	/* hold a ref to the parent's dentry */
 	dget(parent->dentry);
 
 	/* creation succeeded, notify subsystems */
-	for_each_subsys(root, ss) {
+	for_each_root_subsys(root, ss) {
 		err = online_css(ss, cgrp);
 		if (err)
 			goto err_destroy;
@@ -4370,7 +4367,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	return 0;
 
 err_free_all:
-	for_each_subsys(root, ss) {
+	for_each_root_subsys(root, ss) {
 		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
 
 		if (css) {
@@ -4483,7 +4480,7 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	 * be killed.
 	 */
 	atomic_set(&cgrp->css_kill_cnt, 1);
-	for_each_subsys(cgrp->root, ss) {
+	for_each_root_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
 
 		/*
@@ -4557,7 +4554,7 @@ static void cgroup_offline_fn(struct work_struct *work)
 	 * css_tryget() is guaranteed to fail now.  Tell subsystems to
 	 * initate destruction.
 	 */
-	for_each_subsys(cgrp->root, ss)
+	for_each_root_subsys(cgrp->root, ss)
 		offline_css(ss, cgrp);
 
 	/*
@@ -4567,7 +4564,7 @@ static void cgroup_offline_fn(struct work_struct *work)
 	 * whenever that may be, the extra dentry ref is put so that dentry
 	 * destruction happens only after all css's are released.
 	 */
-	for_each_subsys(cgrp->root, ss)
+	for_each_root_subsys(cgrp->root, ss)
 		css_put(cgrp->subsys[ss->subsys_id]);
 
 	/* delete this cgroup from parent->children */
@@ -4972,7 +4969,7 @@ int proc_cgroup_show(struct seq_file *m, void *v)
 		int count = 0;
 
 		seq_printf(m, "%d:", root->hierarchy_id);
-		for_each_subsys(root, ss)
+		for_each_root_subsys(root, ss)
 			seq_printf(m, "%s%s", count++ ? "," : "", ss->name);
 		if (strlen(root->name))
 			seq_printf(m, "%sname=%s", count ? "," : "",
-- 
1.8.2.1
