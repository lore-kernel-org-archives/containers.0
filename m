From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/4] cgroup: refactor hierarchy_id handling
Date: Sun, 14 Apr 2013 11:36:56 -0700
Message-ID: <1365964619-14762-2-git-send-email-tj@kernel.org>
References: <1365964619-14762-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1365964619-14762-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

We're planning to converting hierarchy_ida to an idr and use it to
look up hierarchy from its id.  As we want the mapping to happen
atomically with cgroupfs_root registration, this patch refactors
hierarchy_id init / exit so that ida operations happen inside
cgroup_[root_]mutex.

* s/init_root_id()/cgroup_init_root_id()/ and make it return 0 or
  -errno like a normal function.

* Move hierarchy_id initialization from cgroup_root_from_opts() into
  cgroup_mount() block where the root is confirmed to be used and
  being registered while holding both mutexes.

* Split cgroup_drop_id() into cgroup_exit_root_id() and
  cgroup_free_root(), so that ID release can happen before dropping
  the mutexes in cgroup_kill_sb().  The latter expects hierarchy_id to
  be exited before being invoked.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 56 +++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 35 insertions(+), 21 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a790409..823cb56 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1452,13 +1452,13 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 	list_add_tail(&cgrp->allcg_node, &root->allcg_list);
 }
 
-static bool init_root_id(struct cgroupfs_root *root)
+static int cgroup_init_root_id(struct cgroupfs_root *root)
 {
-	int ret = 0;
+	int ret;
 
 	do {
 		if (!ida_pre_get(&hierarchy_ida, GFP_KERNEL))
-			return false;
+			return -ENOMEM;
 		spin_lock(&hierarchy_id_lock);
 		/* Try to allocate the next unused ID */
 		ret = ida_get_new_above(&hierarchy_ida, next_hierarchy_id,
@@ -1474,7 +1474,18 @@ static bool init_root_id(struct cgroupfs_root *root)
 		}
 		spin_unlock(&hierarchy_id_lock);
 	} while (ret);
-	return true;
+	return 0;
+}
+
+static void cgroup_exit_root_id(struct cgroupfs_root *root)
+{
+	if (root->hierarchy_id) {
+		spin_lock(&hierarchy_id_lock);
+		ida_remove(&hierarchy_ida, root->hierarchy_id);
+		spin_unlock(&hierarchy_id_lock);
+
+		root->hierarchy_id = 0;
+	}
 }
 
 static int cgroup_test_super(struct super_block *sb, void *data)
@@ -1508,10 +1519,6 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
 	if (!root)
 		return ERR_PTR(-ENOMEM);
 
-	if (!init_root_id(root)) {
-		kfree(root);
-		return ERR_PTR(-ENOMEM);
-	}
 	init_cgroup_root(root);
 
 	root->subsys_mask = opts->subsys_mask;
@@ -1526,17 +1533,15 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
 	return root;
 }
 
-static void cgroup_drop_root(struct cgroupfs_root *root)
+static void cgroup_free_root(struct cgroupfs_root *root)
 {
-	if (!root)
-		return;
+	if (root) {
+		/* hierarhcy ID shoulid already have been released */
+		WARN_ON_ONCE(root->hierarchy_id);
 
-	BUG_ON(!root->hierarchy_id);
-	spin_lock(&hierarchy_id_lock);
-	ida_remove(&hierarchy_ida, root->hierarchy_id);
-	spin_unlock(&hierarchy_id_lock);
-	ida_destroy(&root->cgroup_ida);
-	kfree(root);
+		ida_destroy(&root->cgroup_ida);
+		kfree(root);
+	}
 }
 
 static int cgroup_set_super(struct super_block *sb, void *data)
@@ -1623,7 +1628,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	sb = sget(fs_type, cgroup_test_super, cgroup_set_super, 0, &opts);
 	if (IS_ERR(sb)) {
 		ret = PTR_ERR(sb);
-		cgroup_drop_root(opts.new_root);
+		cgroup_free_root(opts.new_root);
 		goto drop_modules;
 	}
 
@@ -1667,6 +1672,10 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		if (ret)
 			goto unlock_drop;
 
+		ret = cgroup_init_root_id(root);
+		if (ret)
+			goto unlock_drop;
+
 		ret = rebind_subsystems(root, root->subsys_mask);
 		if (ret == -EBUSY) {
 			free_cg_links(&tmp_cg_links);
@@ -1710,7 +1719,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		 * We re-used an existing hierarchy - the new root (if
 		 * any) is not needed
 		 */
-		cgroup_drop_root(opts.new_root);
+		cgroup_free_root(opts.new_root);
 		/* no subsys rebinding, so refcounts don't change */
 		drop_parsed_module_refcounts(opts.subsys_mask);
 	}
@@ -1720,6 +1729,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	return dget(sb->s_root);
 
  unlock_drop:
+	cgroup_exit_root_id(root);
 	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&inode->i_mutex);
@@ -1772,13 +1782,15 @@ static void cgroup_kill_sb(struct super_block *sb) {
 		root_count--;
 	}
 
+	cgroup_exit_root_id(root);
+
 	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 
 	simple_xattrs_free(&cgrp->xattrs);
 
 	kill_litter_super(sb);
-	cgroup_drop_root(root);
+	cgroup_free_root(root);
 }
 
 static struct file_system_type cgroup_fs_type = {
@@ -4642,7 +4654,9 @@ int __init cgroup_init(void)
 	/* Add init_css_set to the hash table */
 	key = css_set_hash(init_css_set.subsys);
 	hash_add(css_set_table, &init_css_set.hlist, key);
-	BUG_ON(!init_root_id(&rootnode));
+
+	/* allocate id for the dummy hierarchy */
+	BUG_ON(cgroup_init_root_id(&rootnode));
 
 	cgroup_kobj = kobject_create_and_add("cgroup", fs_kobj);
 	if (!cgroup_kobj) {
-- 
1.8.1.4
