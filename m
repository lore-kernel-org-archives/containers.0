From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 02/13] cgroup: introduce cgroup_tree_mutex
Date: Tue, 11 Feb 2014 11:55:29 -0500
Message-ID: <20140211165529.GD24490@htj.dyndns.org>
References: <1390953285-16360-1-git-send-email-tj@kernel.org>
	<1390953285-16360-3-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1390953285-16360-3-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From ace2bee8135a3dc725958b8d08c55ee9df813d39 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Tue, 11 Feb 2014 11:52:47 -0500

Currently cgroup uses combination of inode->i_mutex'es and
cgroup_mutex for synchronization.  With the scheduled kernfs
conversion, i_mutex'es will be removed.  Unfortunately, just using
cgroup_mutex isn't possible.  All kernfs file and syscall operations,
most of which require grabbing cgroup_mutex, will be called with
kernfs active ref held and, if we try to perform kernfs removals under
cgroup_mutex, it can deadlock as kernfs_remove() tries to drain the
target node.

Let's introduce a new outer mutex, cgroup_tree_mutex, which protects
stuff used during hierarchy changing operations - cftypes and all the
operations which may affect the cgroupfs.  It also covers css
association and iteration.  This allows cgroup_css(), for_each_css()
and other css iterators to be called under cgroup_tree_mutex.  The new
mutex will nest above both kernfs's active ref protection and
cgroup_mutex.  By protecting tree modifications with a separate outer
mutex, we can get rid of the forementioned deadlock condition.

Actual file additions and removals now require cgroup_tree_mutex
instead of cgroup_mutex.  Currently, cgroup_tree_mutex is never used
without cgroup_mutex; however, we'll soon add hierarchy modification
sections which are only protected by cgroup_tree_mutex.  In the
future, we might want to make the locking more granular by better
splitting the coverages of the two mutexes.  For now, this should do.

v2: Rebased on top of 0ab02ca8f887 ("cgroup: protect modifications to
    cgroup_idr with cgroup_mutex").

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c | 66 +++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 53 insertions(+), 13 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index fc2db07..cb20d12 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -68,6 +68,15 @@
 #define CGROUP_PIDLIST_DESTROY_DELAY	HZ
 
 /*
+ * cgroup_tree_mutex nests above cgroup_mutex and protects cftypes, file
+ * creation/removal and hierarchy changing operations including cgroup
+ * creation, removal, css association and controller rebinding.  This outer
+ * lock is needed mainly to resolve the circular dependency between kernfs
+ * active ref and cgroup_mutex.  cgroup_tree_mutex nests above both.
+ */
+static DEFINE_MUTEX(cgroup_tree_mutex);
+
+/*
  * cgroup_mutex is the master lock.  Any modification to cgroup or its
  * hierarchy must be performed while holding it.
  */
@@ -84,10 +93,11 @@ static DEFINE_MUTEX(cgroup_mutex);
  */
 static DEFINE_SPINLOCK(release_agent_path_lock);
 
-#define cgroup_assert_mutex_or_rcu_locked()				\
+#define cgroup_assert_mutexes_or_rcu_locked()				\
 	rcu_lockdep_assert(rcu_read_lock_held() ||			\
+			   lockdep_is_held(&cgroup_tree_mutex) ||	\
 			   lockdep_is_held(&cgroup_mutex),		\
-			   "cgroup_mutex or RCU read lock required");
+			   "cgroup_[tree_]mutex or RCU read lock required");
 
 /*
  * cgroup destruction makes heavy use of work items and there can be a lot
@@ -179,7 +189,8 @@ static struct cgroup_subsys_state *cgroup_css(struct cgroup *cgrp,
 {
 	if (ss)
 		return rcu_dereference_check(cgrp->subsys[ss->id],
-					     lockdep_is_held(&cgroup_mutex));
+					lockdep_is_held(&cgroup_tree_mutex) ||
+					lockdep_is_held(&cgroup_mutex));
 	else
 		return &cgrp->dummy_css;
 }
@@ -235,6 +246,7 @@ static int notify_on_release(const struct cgroup *cgrp)
 	for ((ssid) = 0; (ssid) < CGROUP_SUBSYS_COUNT; (ssid)++)	\
 		if (!((css) = rcu_dereference_check(			\
 				(cgrp)->subsys[(ssid)],			\
+				lockdep_is_held(&cgroup_tree_mutex) ||	\
 				lockdep_is_held(&cgroup_mutex)))) { }	\
 		else
 
@@ -883,7 +895,7 @@ static void cgroup_rm_file(struct cgroup *cgrp, const struct cftype *cft)
 	struct cfent *cfe;
 
 	lockdep_assert_held(&cgrp->dentry->d_inode->i_mutex);
-	lockdep_assert_held(&cgroup_mutex);
+	lockdep_assert_held(&cgroup_tree_mutex);
 
 	/*
 	 * If we're doing cleanup due to failure of cgroup_create(),
@@ -948,7 +960,8 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	struct cgroup_subsys *ss;
 	int i, ret;
 
-	BUG_ON(!mutex_is_locked(&cgroup_mutex));
+	lockdep_assert_held(&cgroup_tree_mutex);
+	lockdep_assert_held(&cgroup_mutex);
 
 	/* Check that any added subsystems are currently free */
 	for_each_subsys(ss, i)
@@ -1220,6 +1233,7 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	}
 
 	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
+	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 
 	/* See what subsystems are wanted */
@@ -1263,6 +1277,7 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	kfree(opts.release_agent);
 	kfree(opts.name);
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 	return ret;
 }
@@ -1494,6 +1509,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		inode = sb->s_root->d_inode;
 
 		mutex_lock(&inode->i_mutex);
+		mutex_lock(&cgroup_tree_mutex);
 		mutex_lock(&cgroup_mutex);
 
 		ret = idr_alloc(&root->cgroup_idr, root_cgrp, 0, 1, GFP_KERNEL);
@@ -1568,6 +1584,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		BUG_ON(root->number_of_cgroups != 1);
 
 		mutex_unlock(&cgroup_mutex);
+		mutex_unlock(&cgroup_tree_mutex);
 		mutex_unlock(&inode->i_mutex);
 	} else {
 		/*
@@ -1598,6 +1615,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
  unlock_drop:
 	cgroup_exit_root_id(root);
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 	mutex_unlock(&inode->i_mutex);
  drop_new_super:
 	deactivate_locked_super(sb);
@@ -1620,6 +1638,7 @@ static void cgroup_kill_sb(struct super_block *sb)
 	BUG_ON(!list_empty(&cgrp->children));
 
 	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
+	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 
 	/* Rebind all subsystems back to the default hierarchy */
@@ -1650,6 +1669,7 @@ static void cgroup_kill_sb(struct super_block *sb)
 	cgroup_exit_root_id(root);
 
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 
 	simple_xattrs_free(&cgrp->xattrs);
@@ -2625,7 +2645,7 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
 	int ret;
 
 	lockdep_assert_held(&cgrp->dentry->d_inode->i_mutex);
-	lockdep_assert_held(&cgroup_mutex);
+	lockdep_assert_held(&cgroup_tree_mutex);
 
 	for (cft = cfts; cft->name[0] != '\0'; cft++) {
 		/* does cft->flags tell us to skip this file on @cgrp? */
@@ -2659,6 +2679,7 @@ static void cgroup_cfts_prepare(void)
 	 * Instead, we use css_for_each_descendant_pre() and drop RCU read
 	 * lock before calling cgroup_addrm_files().
 	 */
+	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 }
 
@@ -2679,6 +2700,7 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 	if (!cfts || ss->root == &cgroup_dummy_root ||
 	    !atomic_inc_not_zero(&sb->s_active)) {
 		mutex_unlock(&cgroup_mutex);
+		mutex_unlock(&cgroup_tree_mutex);
 		return 0;
 	}
 
@@ -2702,7 +2724,9 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 		prev = cgrp->dentry;
 
 		mutex_unlock(&cgroup_mutex);
+		mutex_unlock(&cgroup_tree_mutex);
 		mutex_lock(&inode->i_mutex);
+		mutex_lock(&cgroup_tree_mutex);
 		mutex_lock(&cgroup_mutex);
 		if (cgrp->serial_nr < update_before && !cgroup_is_dead(cgrp))
 			ret = cgroup_addrm_files(cgrp, cfts, is_add);
@@ -2711,6 +2735,7 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 			break;
 	}
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 	dput(prev);
 	deactivate_super(sb);
 	return ret;
@@ -2856,7 +2881,7 @@ css_next_child(struct cgroup_subsys_state *pos_css,
 	struct cgroup *cgrp = parent_css->cgroup;
 	struct cgroup *next;
 
-	cgroup_assert_mutex_or_rcu_locked();
+	cgroup_assert_mutexes_or_rcu_locked();
 
 	/*
 	 * @pos could already have been removed.  Once a cgroup is removed,
@@ -2914,7 +2939,7 @@ css_next_descendant_pre(struct cgroup_subsys_state *pos,
 {
 	struct cgroup_subsys_state *next;
 
-	cgroup_assert_mutex_or_rcu_locked();
+	cgroup_assert_mutexes_or_rcu_locked();
 
 	/* if first iteration, visit @root */
 	if (!pos)
@@ -2955,7 +2980,7 @@ css_rightmost_descendant(struct cgroup_subsys_state *pos)
 {
 	struct cgroup_subsys_state *last, *tmp;
 
-	cgroup_assert_mutex_or_rcu_locked();
+	cgroup_assert_mutexes_or_rcu_locked();
 
 	do {
 		last = pos;
@@ -3003,7 +3028,7 @@ css_next_descendant_post(struct cgroup_subsys_state *pos,
 {
 	struct cgroup_subsys_state *next;
 
-	cgroup_assert_mutex_or_rcu_locked();
+	cgroup_assert_mutexes_or_rcu_locked();
 
 	/* if first iteration, visit leftmost descendant which may be @root */
 	if (!pos)
@@ -3977,6 +4002,7 @@ static int online_css(struct cgroup_subsys_state *css)
 	struct cgroup_subsys *ss = css->ss;
 	int ret = 0;
 
+	lockdep_assert_held(&cgroup_tree_mutex);
 	lockdep_assert_held(&cgroup_mutex);
 
 	if (ss->css_online)
@@ -3994,6 +4020,7 @@ static void offline_css(struct cgroup_subsys_state *css)
 {
 	struct cgroup_subsys *ss = css->ss;
 
+	lockdep_assert_held(&cgroup_tree_mutex);
 	lockdep_assert_held(&cgroup_mutex);
 
 	if (!(css->flags & CSS_ONLINE))
@@ -4093,6 +4120,8 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	}
 	rcu_assign_pointer(cgrp->name, name);
 
+	mutex_lock(&cgroup_tree_mutex);
+
 	/*
 	 * Only live parents can have children.  Note that the liveliness
 	 * check isn't strictly necessary because cgroup_mkdir() and
@@ -4102,7 +4131,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	 */
 	if (!cgroup_lock_live_group(parent)) {
 		err = -ENODEV;
-		goto err_free_name;
+		goto err_unlock_tree;
 	}
 
 	/*
@@ -4176,6 +4205,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	}
 
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 
 	return 0;
@@ -4186,7 +4216,8 @@ err_free_id:
 	deactivate_super(sb);
 err_unlock:
 	mutex_unlock(&cgroup_mutex);
-err_free_name:
+err_unlock_tree:
+	mutex_unlock(&cgroup_tree_mutex);
 	kfree(rcu_dereference_raw(cgrp->name));
 err_free_cgrp:
 	kfree(cgrp);
@@ -4195,6 +4226,7 @@ err_free_cgrp:
 err_destroy:
 	cgroup_destroy_locked(cgrp);
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 	mutex_unlock(&dentry->d_inode->i_mutex);
 	return err;
 }
@@ -4217,6 +4249,7 @@ static void css_killed_work_fn(struct work_struct *work)
 		container_of(work, struct cgroup_subsys_state, destroy_work);
 	struct cgroup *cgrp = css->cgroup;
 
+	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 
 	/*
@@ -4234,6 +4267,7 @@ static void css_killed_work_fn(struct work_struct *work)
 		cgroup_destroy_css_killed(cgrp);
 
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 
 	/*
 	 * Put the css refs from kill_css().  Each css holds an extra
@@ -4321,6 +4355,7 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	int ssid;
 
 	lockdep_assert_held(&d->d_inode->i_mutex);
+	lockdep_assert_held(&cgroup_tree_mutex);
 	lockdep_assert_held(&cgroup_mutex);
 
 	/*
@@ -4407,6 +4442,7 @@ static void cgroup_destroy_css_killed(struct cgroup *cgrp)
 	struct cgroup *parent = cgrp->parent;
 	struct dentry *d = cgrp->dentry;
 
+	lockdep_assert_held(&cgroup_tree_mutex);
 	lockdep_assert_held(&cgroup_mutex);
 
 	/* delete this cgroup from parent->children */
@@ -4422,9 +4458,11 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 {
 	int ret;
 
+	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 	ret = cgroup_destroy_locked(dentry->d_fsdata);
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 
 	return ret;
 }
@@ -4454,6 +4492,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 
 	printk(KERN_INFO "Initializing cgroup subsys %s\n", ss->name);
 
+	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 
 	/* init base cftset */
@@ -4482,6 +4521,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	BUG_ON(online_css(css));
 
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 }
 
 /**
@@ -5021,7 +5061,7 @@ struct cgroup_subsys_state *css_from_id(int id, struct cgroup_subsys *ss)
 {
 	struct cgroup *cgrp;
 
-	cgroup_assert_mutex_or_rcu_locked();
+	cgroup_assert_mutexes_or_rcu_locked();
 
 	cgrp = idr_find(&ss->root->cgroup_idr, id);
 	if (cgrp)
-- 
1.8.5.3
