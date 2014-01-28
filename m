From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 11/13] cgroup: misc preps for kernfs conversion
Date: Tue, 28 Jan 2014 18:54:43 -0500
Message-ID: <1390953285-16360-12-git-send-email-tj__41438.202330801$1390953381$gmane$org@kernel.org>
References: <1390953285-16360-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390953285-16360-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

* Un-inline seq_css().  After kernfs conversion, the function will
  need to dereference internal data structures.

* Add cgroup_get/put_root() and replace direct super_block->s_active
  manipulatinos with them.  These will be converted to kernfs_root
  refcnting.

* Add cgroup_get/put() and replace dget/put() on cgrp->dentry with
  them.  These will be converted to kernfs refcnting.

* Update current_css_set_cg_links_read() to use cgroup_name() instead
  of reaching into the dentry name.  The end result is the same.

These changes don't make functional differences but will make
transition to kernfs easier.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  8 ++---
 kernel/cgroup.c        | 85 +++++++++++++++++++++++++++++++-------------------
 2 files changed, 55 insertions(+), 38 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 15b7839..4740cba 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -514,18 +514,14 @@ static inline ino_t cgroup_ino(struct cgroup *cgrp)
 		return 0;
 }
 
-static inline struct cgroup_subsys_state *seq_css(struct seq_file *seq)
-{
-	struct cgroup_open_file *of = seq->private;
-	return of->cfe->css;
-}
-
 static inline struct cftype *seq_cft(struct seq_file *seq)
 {
 	struct cgroup_open_file *of = seq->private;
 	return of->cfe->type;
 }
 
+struct cgroup_subsys_state *seq_css(struct seq_file *seq);
+
 int cgroup_add_cftypes(struct cgroup_subsys *ss, struct cftype *cfts);
 int cgroup_rm_cftypes(struct cftype *cfts);
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a8a1adc..0c5d1d1 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -169,6 +169,7 @@ static int need_forkexit_callback __read_mostly;
 
 static struct cftype cgroup_base_files[];
 
+static void cgroup_put(struct cgroup *cgrp);
 static void cgroup_destroy_css_killed(struct cgroup *cgrp);
 static int cgroup_destroy_locked(struct cgroup *cgrp);
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
@@ -204,6 +205,13 @@ static inline bool cgroup_is_dead(const struct cgroup *cgrp)
 	return test_bit(CGRP_DEAD, &cgrp->flags);
 }
 
+struct cgroup_subsys_state *seq_css(struct seq_file *seq)
+{
+	struct cgroup_open_file *of = seq->private;
+	return of->cfe->css;
+}
+EXPORT_SYMBOL_GPL(seq_css);
+
 /**
  * cgroup_is_descendant - test ancestry
  * @cgrp: the cgroup to be tested
@@ -682,6 +690,16 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 	return cset;
 }
 
+static void cgroup_get_root(struct cgroupfs_root *root)
+{
+	atomic_inc(&root->sb->s_active);
+}
+
+static void cgroup_put_root(struct cgroupfs_root *root)
+{
+	deactivate_super(root->sb);
+}
+
 /*
  * Return the cgroup for "task" from the given hierarchy. Must be
  * called with cgroup_mutex held.
@@ -837,18 +855,14 @@ static void cgroup_free_fn(struct work_struct *work)
 	mutex_unlock(&cgroup_mutex);
 
 	/*
-	 * We get a ref to the parent's dentry, and put the ref when
-	 * this cgroup is being freed, so it's guaranteed that the
-	 * parent won't be destroyed before its children.
+	 * We get a ref to the parent, and put the ref when this cgroup is
+	 * being freed, so it's guaranteed that the parent won't be
+	 * destroyed before its children.
 	 */
-	dput(cgrp->parent->dentry);
+	cgroup_put(cgrp->parent);
 
-	/*
-	 * Drop the active superblock reference that we took when we
-	 * created the cgroup. This will free cgrp->root, if we are
-	 * holding the last reference to @sb.
-	 */
-	deactivate_super(cgrp->root->sb);
+	/* put the root reference that we took when we created the cgroup */
+	cgroup_put_root(cgrp->root);
 
 	cgroup_pidlist_destroy_all(cgrp);
 
@@ -866,6 +880,11 @@ static void cgroup_free_rcu(struct rcu_head *head)
 	queue_work(cgroup_destroy_wq, &cgrp->destroy_work);
 }
 
+static void cgroup_get(struct cgroup *cgrp)
+{
+	dget(cgrp->dentry);
+}
+
 static void cgroup_diput(struct dentry *dentry, struct inode *inode)
 {
 	/* is dentry a directory ? if so, kfree() associated cgroup */
@@ -897,6 +916,11 @@ static void cgroup_diput(struct dentry *dentry, struct inode *inode)
 	iput(inode);
 }
 
+static void cgroup_put(struct cgroup *cgrp)
+{
+	dput(cgrp->dentry);
+}
+
 static void remove_dir(struct dentry *d)
 {
 	struct dentry *parent = dget(d->d_parent);
@@ -2715,7 +2739,7 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 	struct cgroup_subsys *ss = cfts[0].ss;
 	struct cgroup *root = &ss->root->top_cgroup;
 	struct super_block *sb = ss->root->sb;
-	struct dentry *prev = NULL;
+	struct cgroup *prev = NULL;
 	struct inode *inode;
 	struct cgroup_subsys_state *css;
 	u64 update_before;
@@ -2745,9 +2769,10 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 			continue;
 
 		inode = cgrp->dentry->d_inode;
-		dget(cgrp->dentry);
-		dput(prev);
-		prev = cgrp->dentry;
+		cgroup_get(cgrp);
+		if (prev)
+			cgroup_put(prev);
+		prev = cgrp;
 
 		mutex_unlock(&cgroup_tree_mutex);
 		mutex_lock(&inode->i_mutex);
@@ -2759,8 +2784,8 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 			break;
 	}
 	mutex_unlock(&cgroup_tree_mutex);
-	dput(prev);
-	deactivate_super(sb);
+	cgroup_put(prev);
+	cgroup_put_root(ss->root);
 	return ret;
 }
 
@@ -3854,11 +3879,9 @@ static int cgroup_write_notify_on_release(struct cgroup_subsys_state *css,
  */
 static void cgroup_dput(struct cgroup *cgrp)
 {
-	struct super_block *sb = cgrp->root->sb;
-
-	atomic_inc(&sb->s_active);
-	dput(cgrp->dentry);
-	deactivate_super(sb);
+	cgroup_get_root(cgrp->root);
+	cgroup_put(cgrp);
+	cgroup_put_root(cgrp->root);
 }
 
 static u64 cgroup_clone_children_read(struct cgroup_subsys_state *css,
@@ -4109,7 +4132,7 @@ static int create_css(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	if (err)
 		goto err_free;
 
-	dget(cgrp->dentry);
+	cgroup_get(cgrp);
 	css_get(css->parent);
 
 	if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
@@ -4188,7 +4211,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	 * can be done outside cgroup_mutex, since the sb can't
 	 * disappear while someone has an open control file on the
 	 * fs */
-	atomic_inc(&sb->s_active);
+	cgroup_get_root(root);
 
 	init_cgroup_housekeeping(cgrp);
 
@@ -4222,7 +4245,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	root->number_of_cgroups++;
 
 	/* hold a ref to the parent's dentry */
-	dget(parent->dentry);
+	cgroup_get(parent);
 
 	/*
 	 * @cgrp is now fully operational.  If something fails after this
@@ -4252,7 +4275,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 err_unlock:
 	mutex_unlock(&cgroup_mutex);
 	/* Release the reference count that we took on the superblock */
-	deactivate_super(sb);
+	cgroup_put_root(root);
 err_unlock_tree:
 	mutex_unlock(&cgroup_tree_mutex);
 	idr_remove(&root->cgroup_idr, cgrp->id);
@@ -4484,7 +4507,6 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 static void cgroup_destroy_css_killed(struct cgroup *cgrp)
 {
 	struct cgroup *parent = cgrp->parent;
-	struct dentry *d = cgrp->dentry;
 
 	lockdep_assert_held(&cgroup_tree_mutex);
 	lockdep_assert_held(&cgroup_mutex);
@@ -4492,7 +4514,7 @@ static void cgroup_destroy_css_killed(struct cgroup *cgrp)
 	/* delete this cgroup from parent->children */
 	list_del_rcu(&cgrp->sibling);
 
-	dput(d);
+	cgroup_put(cgrp);
 
 	set_bit(CGRP_RELEASABLE, &parent->flags);
 	check_for_release(parent);
@@ -5147,12 +5169,11 @@ static int current_css_set_cg_links_read(struct seq_file *seq, void *v)
 	cset = rcu_dereference(current->cgroups);
 	list_for_each_entry(link, &cset->cgrp_links, cgrp_link) {
 		struct cgroup *c = link->cgrp;
-		const char *name;
+		const char *name = "?";
+
+		if (c != cgroup_dummy_top)
+			name = cgroup_name(c);
 
-		if (c->dentry)
-			name = c->dentry->d_name.name;
-		else
-			name = "?";
 		seq_printf(seq, "Root %d group %s\n",
 			   c->root->hierarchy_id, name);
 	}
-- 
1.8.5.3
