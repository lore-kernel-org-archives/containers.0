From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/13] cgroup: introduce cgroup_tree_mutex
Date: Sat,  8 Feb 2014 11:15:16 -0500
Message-ID: <1391876127-7134-3-git-send-email-tj@kernel.org>
References: <1391876127-7134-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391876127-7134-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 66 +++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 53 insertions(+), 13 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 57eb942..e41987d 100644
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
 
@@ -881,7 +893,7 @@ static void cgroup_rm_file(struct cgroup *cgrp, const struct cftype *cft)
 	struct cfent *cfe;
 
 	lockdep_assert_held(&cgrp->dentry->d_inode->i_mutex);
-	lockdep_assert_held(&cgroup_mutex);
+	lockdep_assert_held(&cgroup_tree_mutex);
 
 	/*
 	 * If we're doing cleanup due to failure of cgroup_create(),
@@ -946,7 +958,8 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	struct cgroup_subsys *ss;
 	int i, ret;
 
-	BUG_ON(!mutex_is_locked(&cgroup_mutex));
+	lockdep_assert_held(&cgroup_tree_mutex);
+	lockdep_assert_held(&cgroup_mutex);
 
 	/* Check that any added subsystems are currently free */
 	for_each_subsys(ss, i)
@@ -1218,6 +1231,7 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	}
 
 	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
+	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 
 	/* See what subsystems are wanted */
@@ -1261,6 +1275,7 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	kfree(opts.release_agent);
 	kfree(opts.name);
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 	return ret;
 }
@@ -1492,6 +1507,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		inode = sb->s_root->d_inode;
 
 		mutex_lock(&inode->i_mutex);
+		mutex_lock(&cgroup_tree_mutex);
 		mutex_lock(&cgroup_mutex);
 
 		ret = idr_alloc(&root->cgroup_idr, root_cgrp, 0, 1, GFP_KERNEL);
@@ -1566,6 +1582,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		BUG_ON(root->number_of_cgroups != 1);
 
 		mutex_unlock(&cgroup_mutex);
+		mutex_unlock(&cgroup_tree_mutex);
 		mutex_unlock(&inode->i_mutex);
 	} else {
 		/*
@@ -1596,6 +1613,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
  unlock_drop:
 	cgroup_exit_root_id(root);
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 	mutex_unlock(&inode->i_mutex);
  drop_new_super:
 	deactivate_locked_super(sb);
@@ -1618,6 +1636,7 @@ static void cgroup_kill_sb(struct super_block *sb)
 	BUG_ON(!list_empty(&cgrp->children));
 
 	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
+	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 
 	/* Rebind all subsystems back to the default hierarchy */
@@ -1648,6 +1667,7 @@ static void cgroup_kill_sb(struct super_block *sb)
 	cgroup_exit_root_id(root);
 
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 
 	simple_xattrs_free(&cgrp->xattrs);
@@ -2623,7 +2643,7 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
 	int ret;
 
 	lockdep_assert_held(&cgrp->dentry->d_inode->i_mutex);
-	lockdep_assert_held(&cgroup_mutex);
+	lockdep_assert_held(&cgroup_tree_mutex);
 
 	for (cft = cfts; cft->name[0] != '\0'; cft++) {
 		/* does cft->flags tell us to skip this file on @cgrp? */
@@ -2657,6 +2677,7 @@ static void cgroup_cfts_prepare(void)
 	 * Instead, we use css_for_each_descendant_pre() and drop RCU read
 	 * lock before calling cgroup_addrm_files().
 	 */
+	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 }
 
@@ -2677,6 +2698,7 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 	if (!cfts || ss->root == &cgroup_dummy_root ||
 	    !atomic_inc_not_zero(&sb->s_active)) {
 		mutex_unlock(&cgroup_mutex);
+		mutex_unlock(&cgroup_tree_mutex);
 		return 0;
 	}
 
@@ -2700,7 +2722,9 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 		prev = cgrp->dentry;
 
 		mutex_unlock(&cgroup_mutex);
+		mutex_unlock(&cgroup_tree_mutex);
 		mutex_lock(&inode->i_mutex);
+		mutex_lock(&cgroup_tree_mutex);
 		mutex_lock(&cgroup_mutex);
 		if (cgrp->serial_nr < update_before && !cgroup_is_dead(cgrp))
 			ret = cgroup_addrm_files(cgrp, cfts, is_add);
@@ -2709,6 +2733,7 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 			break;
 	}
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 	dput(prev);
 	deactivate_super(sb);
 	return ret;
@@ -2854,7 +2879,7 @@ css_next_child(struct cgroup_subsys_state *pos_css,
 	struct cgroup *cgrp = parent_css->cgroup;
 	struct cgroup *next;
 
-	cgroup_assert_mutex_or_rcu_locked();
+	cgroup_assert_mutexes_or_rcu_locked();
 
 	/*
 	 * @pos could already have been removed.  Once a cgroup is removed,
@@ -2912,7 +2937,7 @@ css_next_descendant_pre(struct cgroup_subsys_state *pos,
 {
 	struct cgroup_subsys_state *next;
 
-	cgroup_assert_mutex_or_rcu_locked();
+	cgroup_assert_mutexes_or_rcu_locked();
 
 	/* if first iteration, visit @root */
 	if (!pos)
@@ -2953,7 +2978,7 @@ css_rightmost_descendant(struct cgroup_subsys_state *pos)
 {
 	struct cgroup_subsys_state *last, *tmp;
 
-	cgroup_assert_mutex_or_rcu_locked();
+	cgroup_assert_mutexes_or_rcu_locked();
 
 	do {
 		last = pos;
@@ -3001,7 +3026,7 @@ css_next_descendant_post(struct cgroup_subsys_state *pos,
 {
 	struct cgroup_subsys_state *next;
 
-	cgroup_assert_mutex_or_rcu_locked();
+	cgroup_assert_mutexes_or_rcu_locked();
 
 	/* if first iteration, visit leftmost descendant which may be @root */
 	if (!pos)
@@ -3975,6 +4000,7 @@ static int online_css(struct cgroup_subsys_state *css)
 	struct cgroup_subsys *ss = css->ss;
 	int ret = 0;
 
+	lockdep_assert_held(&cgroup_tree_mutex);
 	lockdep_assert_held(&cgroup_mutex);
 
 	if (ss->css_online)
@@ -3992,6 +4018,7 @@ static void offline_css(struct cgroup_subsys_state *css)
 {
 	struct cgroup_subsys *ss = css->ss;
 
+	lockdep_assert_held(&cgroup_tree_mutex);
 	lockdep_assert_held(&cgroup_mutex);
 
 	if (!(css->flags & CSS_ONLINE))
@@ -4101,6 +4128,8 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		goto err_free_name;
 	}
 
+	mutex_lock(&cgroup_tree_mutex);
+
 	/*
 	 * Only live parents can have children.  Note that the liveliness
 	 * check isn't strictly necessary because cgroup_mkdir() and
@@ -4110,7 +4139,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	 */
 	if (!cgroup_lock_live_group(parent)) {
 		err = -ENODEV;
-		goto err_free_id;
+		goto err_unlock_tree;
 	}
 
 	/* Grab a reference on the superblock so the hierarchy doesn't
@@ -4174,6 +4203,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	}
 
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 
 	return 0;
@@ -4182,7 +4212,8 @@ err_unlock:
 	mutex_unlock(&cgroup_mutex);
 	/* Release the reference count that we took on the superblock */
 	deactivate_super(sb);
-err_free_id:
+err_unlock_tree:
+	mutex_unlock(&cgroup_tree_mutex);
 	idr_remove(&root->cgroup_idr, cgrp->id);
 err_free_name:
 	kfree(rcu_dereference_raw(cgrp->name));
@@ -4193,6 +4224,7 @@ err_free_cgrp:
 err_destroy:
 	cgroup_destroy_locked(cgrp);
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 	mutex_unlock(&dentry->d_inode->i_mutex);
 	return err;
 }
@@ -4215,6 +4247,7 @@ static void css_killed_work_fn(struct work_struct *work)
 		container_of(work, struct cgroup_subsys_state, destroy_work);
 	struct cgroup *cgrp = css->cgroup;
 
+	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 
 	/*
@@ -4232,6 +4265,7 @@ static void css_killed_work_fn(struct work_struct *work)
 		cgroup_destroy_css_killed(cgrp);
 
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 
 	/*
 	 * Put the css refs from kill_css().  Each css holds an extra
@@ -4319,6 +4353,7 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	int ssid;
 
 	lockdep_assert_held(&d->d_inode->i_mutex);
+	lockdep_assert_held(&cgroup_tree_mutex);
 	lockdep_assert_held(&cgroup_mutex);
 
 	/*
@@ -4405,6 +4440,7 @@ static void cgroup_destroy_css_killed(struct cgroup *cgrp)
 	struct cgroup *parent = cgrp->parent;
 	struct dentry *d = cgrp->dentry;
 
+	lockdep_assert_held(&cgroup_tree_mutex);
 	lockdep_assert_held(&cgroup_mutex);
 
 	/* delete this cgroup from parent->children */
@@ -4420,9 +4456,11 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 {
 	int ret;
 
+	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 	ret = cgroup_destroy_locked(dentry->d_fsdata);
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 
 	return ret;
 }
@@ -4452,6 +4490,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 
 	printk(KERN_INFO "Initializing cgroup subsys %s\n", ss->name);
 
+	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 
 	/* init base cftset */
@@ -4480,6 +4519,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	BUG_ON(online_css(css));
 
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 }
 
 /**
@@ -5019,7 +5059,7 @@ struct cgroup_subsys_state *css_from_id(int id, struct cgroup_subsys *ss)
 {
 	struct cgroup *cgrp;
 
-	cgroup_assert_mutex_or_rcu_locked();
+	cgroup_assert_mutexes_or_rcu_locked();
 
 	cgrp = idr_find(&ss->root->cgroup_idr, id);
 	if (cgrp)
-- 
1.8.5.3
