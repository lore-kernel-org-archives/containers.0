From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 6/6] cgroup: remove cgroup_root_mutex
Date: Fri, 17 Jan 2014 13:11:57 -0500
Message-ID: <1389982317-22225-7-git-send-email-tj__4826.51980496502$1389982389$gmane$org@kernel.org>
References: <1389982317-22225-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1389982317-22225-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_root_mutex was added to avoid deadlock involving namespace_sem
via cgroup_show_options().  It added a lot of overhead for the small
purpose of it and, because it's nested under cgroup_mutex, it has very
limited usefulness.  The previous patch made cgroup_show_options() not
use cgroup_root_mutex, so nobody needs it anymore.  Remove it.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 42 +-----------------------------------------
 1 file changed, 1 insertion(+), 41 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2736689..f5dcac5 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -70,18 +70,6 @@
 /*
  * cgroup_mutex is the master lock.  Any modification to cgroup or its
  * hierarchy must be performed while holding it.
- *
- * cgroup_root_mutex nests inside cgroup_mutex and should be held to modify
- * cgroupfs_root of any cgroup hierarchy - subsys list, flags,
- * release_agent_path and so on.  Modifying requires both cgroup_mutex and
- * cgroup_root_mutex.  Readers can acquire either of the two.  This is to
- * break the following locking order cycle.
- *
- *  A. cgroup_mutex -> cred_guard_mutex -> s_type->i_mutex_key -> namespace_sem
- *  B. namespace_sem -> cgroup_mutex
- *
- * B happens only through cgroup_show_options() and using cgroup_root_mutex
- * breaks it.
  */
 #ifdef CONFIG_PROVE_RCU
 DEFINE_MUTEX(cgroup_mutex);
@@ -90,8 +78,6 @@ EXPORT_SYMBOL_GPL(cgroup_mutex);	/* only for lockdep */
 static DEFINE_MUTEX(cgroup_mutex);
 #endif
 
-static DEFINE_MUTEX(cgroup_root_mutex);
-
 /*
  * Protects cgroup_subsys->release_agent_path.  Modifying it also requires
  * cgroup_mutex.  Reading requires either cgroup_mutex or this spinlock.
@@ -103,14 +89,6 @@ static DEFINE_SPINLOCK(release_agent_path_lock);
 			   lockdep_is_held(&cgroup_mutex),		\
 			   "cgroup_mutex or RCU read lock required");
 
-#ifdef CONFIG_LOCKDEP
-#define cgroup_assert_mutex_or_root_locked()				\
-	WARN_ON_ONCE(debug_locks && (!lockdep_is_held(&cgroup_mutex) &&	\
-				     !lockdep_is_held(&cgroup_root_mutex)))
-#else
-#define cgroup_assert_mutex_or_root_locked()	do { } while (0)
-#endif
-
 /*
  * cgroup destruction makes heavy use of work items and there can be a lot
  * of concurrent destructions.  Use a separate workqueue so that cgroup
@@ -154,11 +132,7 @@ static struct cgroup * const cgroup_dummy_top = &cgroup_dummy_root.top_cgroup;
 static LIST_HEAD(cgroup_roots);
 static int cgroup_root_count;
 
-/*
- * Hierarchy ID allocation and mapping.  It follows the same exclusion
- * rules as other root ops - both cgroup_mutex and cgroup_root_mutex for
- * writes, either for reads.
- */
+/* hierarchy ID allocation and mapping, protected by cgroup_mutex */
 static DEFINE_IDR(cgroup_hierarchy_idr);
 
 static struct cgroup_name root_cgroup_name = { .name = "/" };
@@ -963,7 +937,6 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	int i, ret;
 
 	BUG_ON(!mutex_is_locked(&cgroup_mutex));
-	BUG_ON(!mutex_is_locked(&cgroup_root_mutex));
 
 	/* Check that any added subsystems are currently free */
 	for_each_subsys(ss, i)
@@ -1236,7 +1209,6 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 
 	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
 	mutex_lock(&cgroup_mutex);
-	mutex_lock(&cgroup_root_mutex);
 
 	/* See what subsystems are wanted */
 	ret = parse_cgroupfs_options(data, &opts);
@@ -1278,7 +1250,6 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
  out_unlock:
 	kfree(opts.release_agent);
 	kfree(opts.name);
-	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 	return ret;
@@ -1321,7 +1292,6 @@ static int cgroup_init_root_id(struct cgroupfs_root *root, int start, int end)
 	int id;
 
 	lockdep_assert_held(&cgroup_mutex);
-	lockdep_assert_held(&cgroup_root_mutex);
 
 	id = idr_alloc_cyclic(&cgroup_hierarchy_idr, root, start, end,
 			      GFP_KERNEL);
@@ -1335,7 +1305,6 @@ static int cgroup_init_root_id(struct cgroupfs_root *root, int start, int end)
 static void cgroup_exit_root_id(struct cgroupfs_root *root)
 {
 	lockdep_assert_held(&cgroup_mutex);
-	lockdep_assert_held(&cgroup_root_mutex);
 
 	if (root->hierarchy_id) {
 		idr_remove(&cgroup_hierarchy_idr, root->hierarchy_id);
@@ -1514,7 +1483,6 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 
 		mutex_lock(&inode->i_mutex);
 		mutex_lock(&cgroup_mutex);
-		mutex_lock(&cgroup_root_mutex);
 
 		root_cgrp->id = idr_alloc(&root->cgroup_idr, root_cgrp,
 					   0, 1, GFP_KERNEL);
@@ -1587,7 +1555,6 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		BUG_ON(!list_empty(&root_cgrp->children));
 		BUG_ON(root->number_of_cgroups != 1);
 
-		mutex_unlock(&cgroup_root_mutex);
 		mutex_unlock(&cgroup_mutex);
 		mutex_unlock(&inode->i_mutex);
 	} else {
@@ -1618,7 +1585,6 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	revert_creds(cred);
  unlock_drop:
 	cgroup_exit_root_id(root);
-	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&inode->i_mutex);
  drop_new_super:
@@ -1642,7 +1608,6 @@ static void cgroup_kill_sb(struct super_block *sb) {
 
 	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
 	mutex_lock(&cgroup_mutex);
-	mutex_lock(&cgroup_root_mutex);
 
 	/* Rebind all subsystems back to the default hierarchy */
 	if (root->flags & CGRP_ROOT_SUBSYS_BOUND) {
@@ -1671,7 +1636,6 @@ static void cgroup_kill_sb(struct super_block *sb) {
 
 	cgroup_exit_root_id(root);
 
-	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 
@@ -2182,11 +2146,9 @@ static int cgroup_release_agent_write(struct cgroup_subsys_state *css,
 		return -EINVAL;
 	if (!cgroup_lock_live_group(css->cgroup))
 		return -ENODEV;
-	mutex_lock(&cgroup_root_mutex);
 	spin_lock(&release_agent_path_lock);
 	strcpy(css->cgroup->root->release_agent_path, buffer);
 	spin_unlock(&release_agent_path_lock);
-	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 	return 0;
 }
@@ -4584,7 +4546,6 @@ int __init cgroup_init(void)
 
 	/* allocate id for the dummy hierarchy */
 	mutex_lock(&cgroup_mutex);
-	mutex_lock(&cgroup_root_mutex);
 
 	/* Add init_css_set to the hash table */
 	key = css_set_hash(init_css_set.subsys);
@@ -4596,7 +4557,6 @@ int __init cgroup_init(void)
 			0, 1, GFP_KERNEL);
 	BUG_ON(err < 0);
 
-	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 
 	cgroup_kobj = kobject_create_and_add("cgroup", fs_kobj);
-- 
1.8.4.2
