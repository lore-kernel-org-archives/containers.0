From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 2/7] cgroups: Allow to bind a subsystem to a cgroup hierarchy
Date: Fri, 22 Oct 2010 16:09:56 +0800
Message-ID: <4CC146D4.7030009@cn.fujitsu.com>
References: <4CC146A4.9090505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CC146A4.9090505-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Stephane posted a patchset to add perf_cgroup subsystem, so perf can
be used to monitor all threads belonging to a cgroup.

But if you already mounted a cgroup hierarchy but without perf_cgroup
and the hierarchy has sub-cgroups, you can't bind perf_cgroup to it,
and thus you're not able to use per-cgroup perf feature.

This patchset alleviates the pain, and then a subsytem can be bind/unbind
to/from a hierarchy which has sub-cgroups in it.

For a cgroup subsystem to become bindable, the can_bind flag of
struct cgroup_subsys should be set, and provide ->bind() callback
if necessary.

But for some constraints, not all subsystems can take advantage of
this patch. For example, we can't decide a cgroup's cpuset.mems and
cpuset.cpus automatically, so cpuset is not bindable.

Usage:

# mount -t cgroup -o cpuset xxx /mnt
# mkdir /mnt/tmp
# echo $$ > /mnt/tmp/tasks

(assume cpuacct is bindable, and we add cpuacct to the hierarchy)
# mount -o remount,cpuset,cpuacct xxx /mnt

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/cgroup.h |    5 +
 kernel/cgroup.c        |  225 ++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 187 insertions(+), 43 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index e23ded6..49369ff 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -490,6 +490,11 @@ struct cgroup_subsys {
 	 * (not available in early_init time.)
 	 */
 	unsigned int use_id:1;
+	/*
+	 * Indicate if this subsystem can be bound/unbound to/from a cgroup
+	 * hierarchy which has child cgroups.
+	 */
+	unsigned int can_bind:1;
 
 #define MAX_CGROUP_TYPE_NAMELEN 32
 	const char *name;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 6c36750..46df5f8 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -57,6 +57,7 @@
 #include <linux/vmalloc.h> /* TODO: replace with more sophisticated array */
 #include <linux/eventfd.h>
 #include <linux/poll.h>
+#include <linux/bitops.h>
 
 #include <asm/atomic.h>
 
@@ -870,18 +871,13 @@ static void remove_dir(struct dentry *d)
 
 static void cgroup_clear_directory(struct dentry *dentry)
 {
-	struct list_head *node;
+	struct dentry *d, *tmp;
 
 	BUG_ON(!mutex_is_locked(&dentry->d_inode->i_mutex));
 	spin_lock(&dcache_lock);
-	node = dentry->d_subdirs.next;
-	while (node != &dentry->d_subdirs) {
-		struct dentry *d = list_entry(node, struct dentry, d_u.d_child);
-		list_del_init(node);
-		if (d->d_inode) {
-			/* This should never be called on a cgroup
-			 * directory with child cgroups */
-			BUG_ON(d->d_inode->i_mode & S_IFDIR);
+	list_for_each_entry_safe(d, tmp, &dentry->d_subdirs, d_u.d_child) {
+		if (d->d_inode && !(d->d_inode->i_mode & S_IFDIR)) {
+			list_del_init(&d->d_u.d_child);
 			d = dget_locked(d);
 			spin_unlock(&dcache_lock);
 			d_delete(d);
@@ -889,7 +885,6 @@ static void cgroup_clear_directory(struct dentry *dentry)
 			dput(d);
 			spin_lock(&dcache_lock);
 		}
-		node = dentry->d_subdirs.next;
 	}
 	spin_unlock(&dcache_lock);
 }
@@ -934,6 +929,145 @@ void cgroup_release_and_wakeup_rmdir(struct cgroup_subsys_state *css)
 	css_put(css);
 }
 
+static void init_cgroup_css(struct cgroup_subsys_state *css,
+			       struct cgroup_subsys *ss,
+			       struct cgroup *cgrp)
+{
+	css->cgroup = cgrp;
+	atomic_set(&css->refcnt, 1);
+	css->flags = 0;
+	css->id = NULL;
+	if (cgrp == dummytop)
+		set_bit(CSS_ROOT, &css->flags);
+	BUG_ON(cgrp->subsys[ss->subsys_id]);
+	cgrp->subsys[ss->subsys_id] = css;
+}
+
+/*
+ * cgroup_walk_herarchy - iterate through a cgroup hierarchy
+ * @process_cgroup: callback called on each cgroup in the hierarchy
+ * @data: will be passed to @process_cgroup
+ * @top_cgrp: the root cgroup of the hierarchy
+ *
+ * For such a hierarchy:
+ *        a1        c1
+ *      /         /
+ * Root - a2 - b1 - c2
+ *      \
+ *        a3
+ *
+ * The iterating order is: a1, a2, b1, c1, c2, a3. So a parent will be
+ * processed before its children.
+ */
+static int cgroup_walk_hierarchy(int (*process_cgroup)(struct cgroup *, void *),
+				 void *data, struct cgroup *top_cgrp)
+{
+	struct cgroup *parent = top_cgrp;
+	struct cgroup *child;
+	struct list_head *node;
+	int ret;
+
+	node = parent->children.next;
+repeat:
+	while (node != &parent->children) {
+		child = list_entry(node, struct cgroup, sibling);
+
+		ret = process_cgroup(child, data);
+		if (ret)
+			return ret;
+
+		if (!list_empty(&child->children)) {
+			parent = child;
+			node = parent->children.next;
+			goto repeat;
+		} else
+			node = node->next;
+	}
+
+	if (parent != top_cgrp) {
+		child = parent;
+		parent = child->parent;
+		node = child->sibling.next;
+		goto repeat;
+	}
+
+	return 0;
+}
+
+static int hierarchy_attach_css_failed(struct cgroup *cgrp, void *data)
+{
+	unsigned long added_bits = (unsigned long)data;
+	int i;
+
+	for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT);
+		if (cgrp->subsys[i])
+			subsys[i]->destroy(subsys[i], cgrp);
+
+	return 0;
+}
+
+static int hierarchy_attach_css(struct cgroup *cgrp, void *data)
+{
+	unsigned long added_bits = (unsigned long)data;
+	int i;
+	int ret = 0;
+
+	for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT) {
+		struct cgroup_subsys_state *css;
+		struct cgroup_subsys *ss = subsys[i];
+
+		css = ss->create(ss, cgrp);
+		if (IS_ERR(css)) {
+			ret = PTR_ERR(css);
+			break;
+		}
+		init_cgroup_css(css, ss, cgrp);
+
+		if (ss->use_id) {
+			ret = alloc_css_id(ss, cgrp->parent, cgrp);
+			if (ret)
+				break;
+		}
+	}
+
+	if (ret)
+		cgroup_walk_hierarchy(hierarchy_attach_css_failed, data,
+				      cgrp->top_cgroup);
+	return ret;
+}
+
+static int hierarchy_update_css_sets(struct cgroup *cgrp, void *data)
+{
+	unsigned long added_bits = (unsigned long)data;
+	int i;
+	struct cg_cgroup_link *link;
+
+	write_lock(&css_set_lock);
+	list_for_each_entry(link, &cgrp->css_sets, cgrp_link_list) {
+		struct css_set *cg = link->cg;
+		struct hlist_head *hhead;
+
+		for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT)
+			cg->subsys[i] = cgrp->subsys[i];
+
+		/* rehash */
+		hlist_del(&cg->hlist);
+		hhead = css_set_hash(cg->subsys);
+		hlist_add_head(&cg->hlist, hhead);
+	}
+	write_unlock(&css_set_lock);
+
+	return 0;
+}
+
+static int hierarchy_populate_dir(struct cgroup *cgrp, void *data)
+{
+	mutex_lock_nested(&cgrp->dentry->d_inode->i_mutex, I_MUTEX_CHILD);
+	cgroup_populate_dir(cgrp);
+	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
+	return 0;
+}
+
 /*
  * Call with cgroup_mutex held. Drops reference counts on modules, including
  * any duplicate ones that parse_cgroupfs_options took. If this function
@@ -945,36 +1079,53 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	unsigned long added_bits, removed_bits;
 	struct cgroup *cgrp = &root->top_cgroup;
 	int i;
+	int err;
 
 	BUG_ON(!mutex_is_locked(&cgroup_mutex));
 
 	removed_bits = root->actual_subsys_bits & ~final_bits;
 	added_bits = final_bits & ~root->actual_subsys_bits;
+
 	/* Check that any added subsystems are currently free */
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		unsigned long bit = 1UL << i;
-		struct cgroup_subsys *ss = subsys[i];
-		if (!(bit & added_bits))
-			continue;
+	for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT) {
 		/*
 		 * Nobody should tell us to do a subsys that doesn't exist:
 		 * parse_cgroupfs_options should catch that case and refcounts
 		 * ensure that subsystems won't disappear once selected.
 		 */
-		BUG_ON(ss == NULL);
-		if (ss->root != &rootnode) {
+		BUG_ON(subsys[i] == NULL);
+		if (subsys[i]->root != &rootnode) {
 			/* Subsystem isn't free */
 			return -EBUSY;
 		}
 	}
 
-	/* Currently we don't handle adding/removing subsystems when
-	 * any child cgroups exist. This is theoretically supportable
-	 * but involves complex error handling, so it's being left until
-	 * later */
-	if (root->number_of_cgroups > 1)
+	/* removing will be supported later */
+	if (root->number_of_cgroups > 1 && removed_bits)
 		return -EBUSY;
 
+	if (root->number_of_cgroups > 1) {
+		for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT)
+			if (!subsys[i]->can_bind)
+				return -EBUSY;
+
+	for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT) {
+		BUG_ON(cgrp->subsys[i]);
+		BUG_ON(!dummytop->subsys[i]);
+		BUG_ON(dummytop->subsys[i]->cgroup != dummytop);
+
+		cgrp->subsys[i] = dummytop->subsys[i];
+		cgrp->subsys[i]->cgroup = cgrp;
+	}
+
+	err = cgroup_walk_hierarchy(hierarchy_attach_css,
+				    (void *)added_bits, cgrp);
+	if (err)
+		goto failed;
+
+	cgroup_walk_hierarchy(hierarchy_update_css_sets,
+			      (void *)added_bits, cgrp);
+
 	/* Process each subsystem */
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
@@ -982,12 +1133,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 		if (bit & added_bits) {
 			/* We're binding this subsystem to this hierarchy */
 			BUG_ON(ss == NULL);
-			BUG_ON(cgrp->subsys[i]);
-			BUG_ON(!dummytop->subsys[i]);
-			BUG_ON(dummytop->subsys[i]->cgroup != dummytop);
 			mutex_lock(&ss->hierarchy_mutex);
-			cgrp->subsys[i] = dummytop->subsys[i];
-			cgrp->subsys[i]->cgroup = cgrp;
 			list_move(&ss->sibling, &root->subsys_list);
 			ss->root = root;
 			if (ss->bind)
@@ -1000,10 +1146,10 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			BUG_ON(cgrp->subsys[i] != dummytop->subsys[i]);
 			BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
 			mutex_lock(&ss->hierarchy_mutex);
-			if (ss->bind)
-				ss->bind(ss, dummytop);
 			dummytop->subsys[i]->cgroup = dummytop;
 			cgrp->subsys[i] = NULL;
+			if (ss->bind)
+				ss->bind(ss, dummytop);
 			subsys[i]->root = &rootnode;
 			list_move(&ss->sibling, &rootnode.subsys_list);
 			mutex_unlock(&ss->hierarchy_mutex);
@@ -1030,6 +1176,12 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	synchronize_rcu();
 
 	return 0;
+
+failed:
+	for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT)
+		cgrp->subsys[i] = NULL;
+
+	return err;
 }
 
 static int cgroup_show_options(struct seq_file *seq, struct vfsmount *vfs)
@@ -1285,6 +1437,7 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 
 	/* (re)populate subsystem files */
 	cgroup_populate_dir(cgrp);
+	cgroup_walk_hierarchy(hierarchy_populate_dir, NULL, cgrp);
 
 	if (opts.release_agent)
 		strcpy(root->release_agent_path, opts.release_agent);
@@ -3313,20 +3466,6 @@ static int cgroup_populate_dir(struct cgroup *cgrp)
 	return 0;
 }
 
-static void init_cgroup_css(struct cgroup_subsys_state *css,
-			       struct cgroup_subsys *ss,
-			       struct cgroup *cgrp)
-{
-	css->cgroup = cgrp;
-	atomic_set(&css->refcnt, 1);
-	css->flags = 0;
-	css->id = NULL;
-	if (cgrp == dummytop)
-		set_bit(CSS_ROOT, &css->flags);
-	BUG_ON(cgrp->subsys[ss->subsys_id]);
-	cgrp->subsys[ss->subsys_id] = css;
-}
-
 static void cgroup_lock_hierarchy(struct cgroupfs_root *root)
 {
 	/* We need to take each hierarchy_mutex in a consistent order */
-- 
1.7.0.1
