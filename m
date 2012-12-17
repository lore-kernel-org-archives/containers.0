From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC PATCH 5/9] cgroup: add container support for cgroup
Date: Mon, 17 Dec 2012 14:43:31 +0800
Message-ID: <1355726615-15224-6-git-send-email-gaofeng__18517.3191166998$1355726680$gmane$org@cn.fujitsu.com>
References: <1355726615-15224-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1355726615-15224-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

with this patch, the cgroup mounted in the container will
have it's own cgroupfs_root.

The css of this hierarchy's top cgroup are same with
container's init task's css.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |  216 +++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 162 insertions(+), 54 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0195db1..ac61027 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1024,21 +1024,13 @@ static void cgroup_d_remove_dir(struct dentry *dentry)
 	remove_dir(dentry);
 }
 
-/*
- * Call with cgroup_mutex held. Drops reference counts on modules, including
- * any duplicate ones that parse_cgroupfs_options took. If this function
- * returns an error, no reference counts are touched.
- */
-static int rebind_subsystems(struct cgroupfs_root *root,
-			      unsigned long final_subsys_mask)
+static int __rebind_subsystems(struct cgroupfs_root *root,
+			       unsigned long final_subsys_mask)
 {
 	unsigned long added_mask, removed_mask;
 	struct cgroup *cgrp = &root->top_cgroup;
 	int i;
 
-	BUG_ON(!mutex_is_locked(&cgroup_mutex));
-	BUG_ON(!mutex_is_locked(&cgroup_root_mutex));
-
 	removed_mask = root->actual_subsys_mask & ~final_subsys_mask;
 	added_mask = final_subsys_mask & ~root->actual_subsys_mask;
 	/* Check that any added subsystems are currently free */
@@ -1059,13 +1051,6 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 		}
 	}
 
-	/* Currently we don't handle adding/removing subsystems when
-	 * any child cgroups exist. This is theoretically supportable
-	 * but involves complex error handling, so it's being left until
-	 * later */
-	if (root->number_of_cgroups > 1)
-		return -EBUSY;
-
 	/* Process each subsystem */
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
@@ -1113,6 +1098,117 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			BUG_ON(cgrp->subsys[i]);
 		}
 	}
+
+	return 0;
+}
+
+static int __rebind_subsystems_ns(struct cgroupfs_root *root,
+				  unsigned long final_subsys_mask)
+{
+	unsigned long added_mask, removed_mask;
+	struct cgroup *cgrp = &root->top_cgroup;
+	struct cgroup *parent = NULL;
+	struct cgroupfs_root *top_root = NULL;
+	unsigned long bit;
+	int i;
+
+	removed_mask = root->actual_subsys_mask & ~final_subsys_mask;
+	added_mask = final_subsys_mask & ~root->actual_subsys_mask;
+
+	/* Get new top root and new parent */
+	if (final_subsys_mask) {
+		top_root = find_top_root(final_subsys_mask);
+		if (top_root == NULL)
+			return -EINVAL;
+
+		parent = task_cgroup_from_root(root->pid_ns->child_reaper,
+					       top_root);
+		BUG_ON(parent == NULL);
+	}
+
+	/* Process each subsystem */
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+		struct cgroup_subsys *ss = subsys[i];
+		struct cgroup_subsys_state *css;
+		bit = 1UL << i;
+		if (bit & added_mask) {
+			BUG_ON(cgrp->subsys[i]);
+			BUG_ON(parent->subsys[ss->subsys_id] == NULL);
+
+			css = parent->subsys[ss->subsys_id];
+			if (!css_tryget(css))
+				goto out;
+			cgrp->subsys[ss->subsys_id] = css;
+
+			/* refcount was already taken, and we're keeping it */
+		} else if (bit & removed_mask) {
+			BUG_ON(cgrp->subsys[i] != cgrp->parent->subsys[i]);
+
+			css_put(cgrp->subsys[i]);
+			cgrp->subsys[i] = NULL;
+
+			/* subsystem is now free - drop reference on module */
+			module_put(ss->module);
+		} else if (bit & final_subsys_mask) {
+			/*
+			 * a refcount was taken, but we already had one, so
+			 * drop the extra reference.
+			 */
+			module_put(ss->module);
+		}
+	}
+
+	root->top_root = top_root;
+	cgrp->parent = parent;
+
+	/* Link to new top_root or unlink when umounting */
+	if (top_root)
+		list_move_tail(&cgrp->allcg_node, &top_root->allcg_list);
+	else
+		list_del_init(&cgrp->allcg_node);
+
+	return 0;
+out:
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+		bit = 1UL << i;
+		if ((bit & added_mask) && cgrp->subsys[i]) {
+			css_put(cgrp->subsys[i]);
+			cgrp->subsys[i] = NULL;
+		}
+	}
+	return -EINVAL;
+}
+
+
+/*
+ * Call with cgroup_mutex held. Drops reference counts on modules, including
+ * any duplicate ones that parse_cgroupfs_options took. If this function
+ * returns an error, no reference counts are touched.
+ */
+static int rebind_subsystems(struct cgroupfs_root *root,
+			      unsigned long final_subsys_mask)
+{
+	int err = 0;
+
+	BUG_ON(!mutex_is_locked(&cgroup_mutex));
+	BUG_ON(!mutex_is_locked(&cgroup_root_mutex));
+
+	/* Currently we don't handle adding/removing subsystems when
+	 * any child cgroups exist. This is theoretically supportable
+	 * but involves complex error handling, so it's being left until
+	 * later */
+	if (root->number_of_cgroups > 1)
+		return -EBUSY;
+
+	if (test_bit(ROOT_NAMESPACE, &root->flags))
+		err = __rebind_subsystems_ns(root, final_subsys_mask);
+	else
+		err = __rebind_subsystems(root, final_subsys_mask);
+
+	if (err)
+		return err;
+
+
 	root->subsys_mask = root->actual_subsys_mask = final_subsys_mask;
 	synchronize_rcu();
 
@@ -1490,6 +1586,10 @@ static int cgroup_test_super(struct super_block *sb, void *data)
 	    && (opts->subsys_mask != root->subsys_mask))
 		return 0;
 
+	/* Pid namespace must match too */
+	if (root->pid_ns != task_active_pid_ns(current))
+		return 0;
+
 	return 1;
 }
 
@@ -1656,52 +1756,60 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 				if (!strcmp(existing_root->name, root->name))
 					goto unlock_drop;
 
-		/*
-		 * We're accessing css_set_count without locking
-		 * css_set_lock here, but that's OK - it can only be
-		 * increased by someone holding cgroup_lock, and
-		 * that's us. The worst that can happen is that we
-		 * have some link structures left over
-		 */
-		ret = allocate_cg_links(css_set_count, &tmp_cg_links);
-		if (ret)
-			goto unlock_drop;
+		if (!test_bit(ROOT_NAMESPACE, &root->flags)) {
+			/*
+			 * We're accessing css_set_count without locking
+			 * css_set_lock here, but that's OK - it can only be
+			 * increased by someone holding cgroup_lock, and
+			 * that's us. The worst that can happen is that we
+			 * have some link structures left over
+			 */
+			ret = allocate_cg_links(css_set_count, &tmp_cg_links);
+			if (ret)
+				goto unlock_drop;
+
+			ret = rebind_subsystems(root, root->subsys_mask);
+			if (ret == -EBUSY) {
+				free_cg_links(&tmp_cg_links);
+				goto unlock_drop;
+			}
+			/*
+			 * There must be no failure case after here, since
+			 * rebinding takes care of subsystems' refcounts,
+			 * which are explicitly dropped in the failure exit
+			 * path.
+			 */
+
+			/* EBUSY should be the only error here */
+			BUG_ON(ret);
+			top_root_count++;
+
+			/* Link the top cgroup in this hierarchy into all
+			 * the css_set objects */
+			write_lock(&css_set_lock);
+			for (i = 0; i < CSS_SET_TABLE_SIZE; i++) {
+				struct hlist_head *hhead = &css_set_table[i];
+				struct hlist_node *node;
+				struct css_set *cg;
+
+				hlist_for_each_entry(cg, node, hhead, hlist)
+					link_css_set(&tmp_cg_links, cg,
+						     root_cgrp);
+			}
+			write_unlock(&css_set_lock);
 
-		ret = rebind_subsystems(root, root->subsys_mask);
-		if (ret == -EBUSY) {
 			free_cg_links(&tmp_cg_links);
-			goto unlock_drop;
+		} else {
+			ret = rebind_subsystems(root, root->subsys_mask);
+			if (ret)
+				goto unlock_drop;
 		}
-		/*
-		 * There must be no failure case after here, since rebinding
-		 * takes care of subsystems' refcounts, which are explicitly
-		 * dropped in the failure exit path.
-		 */
-
-		/* EBUSY should be the only error here */
-		BUG_ON(ret);
 
 		list_add(&root->root_list, &roots);
-		top_root_count++;
 
 		sb->s_root->d_fsdata = root_cgrp;
 		root->top_cgroup.dentry = sb->s_root;
 
-		/* Link the top cgroup in this hierarchy into all
-		 * the css_set objects */
-		write_lock(&css_set_lock);
-		for (i = 0; i < CSS_SET_TABLE_SIZE; i++) {
-			struct hlist_head *hhead = &css_set_table[i];
-			struct hlist_node *node;
-			struct css_set *cg;
-
-			hlist_for_each_entry(cg, node, hhead, hlist)
-				link_css_set(&tmp_cg_links, cg, root_cgrp);
-		}
-		write_unlock(&css_set_lock);
-
-		free_cg_links(&tmp_cg_links);
-
 		BUG_ON(!list_empty(&root_cgrp->children));
 		BUG_ON(root->number_of_cgroups != 1);
 
-- 
1.7.7.6
