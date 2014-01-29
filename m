From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 13/13] cgroup: convert to kernfs
Date: Wed, 29 Jan 2014 11:09:55 -0500
Message-ID: <20140129160955.GH30842__39379.7172386714$1391011812$gmane$org@htj.dyndns.org>
References: <1390953285-16360-1-git-send-email-tj@kernel.org>
	<1390953285-16360-14-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1390953285-16360-14-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Hello,

Patch updated according to the review points and reports from the
bots.  Also, a different "name=" option handling bug is fixed.  Due to
the updates to patches earlier in the series, some of the previous
patches also need to be refreshed but as the refreshes don't involve
any meaningful changes, I'm not posting the updated versions here.
I'll post them together for the next revision.  However, all the git
branches have been updated with the latest versions of the patches.

Thanks!

-------- 8< --------
From 92f4a9d3d4d33b971fce9d2dd7f3148a4048fb8b Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Wed, 29 Jan 2014 11:02:13 -0500

cgroup filesystem code was derived from the original sysfs
implementation which was heavily intertwined with vfs objects and
locking with the goal of re-using the existing vfs infrastructure.
That experiment turned out rather disastrous and sysfs switched, a
long time ago, to distributed filesystem model where a separate
representation is maintained which is queried by vfs.  Unfortunately,
cgroup stuck with the failed experiment all these years and
accumulated even more problems over time.

Locking and object lifetime management being entangled with vfs is
probably the most egregious.  vfs is never designed to be misused like
this and cgroup ends up jumping through various convoluted dancing to
make things work.  Even then, operations across multiple cgroups can't
be done safely as it'll deadlock with rename locking.

Recently, kernfs is separated out from sysfs so that it can be used by
users other than sysfs.  This patch converts cgroup to use kernfs,
which will bring the following benefits.

* Separation from vfs internals.  Locking and object lifetime
  management is contained in cgroup proper making things a lot
  simpler.  This removes significant amount of locking convolutions,
  hairy object lifetime rules and the restriction on multi-cgroup
  operations.

* Can drop a lot of code to implement filesystem interface as most are
  provided by kernfs.

* Proper "severing" semantics, which allows controllers to not worry
  about lingering file accesses after offline.

While the preceding patches did as much as possible to make the
transition less painful, large part of the conversion has to be one
discrete step making this patch rather large.  The rest of the commit
message lists notable changes in different areas.

Overall
-------

* vfs constructs replaced with kernfs ones.  cgroup->dentry w/ ->kn,
  cgroupfs_root->sb w/ ->kf_root.

* All dentry accessors are removed.  Helpers to map from kernfs
  constructs are added.

* All vfs plumbing around dentry, inode and bdi removed.

* cgroup_mount() now directly looks for matching root and then
  proceeds to create a new one if not found.

Synchronization and object lifetime
-----------------------------------

* vfs inode locking removed.  Among other things, this removes the
  need for the convolution in cgroup_cfts_commit().  Future patches
  will further simplify it.

* vfs refcnting replaced with cgroup internal ones.  cgroup->refcnt,
  cgroupfs_root->refcnt added.  cgroup_put_root() now directly puts
  root->refcnt and when it reaches zero proceeds to destroy it thus
  merging cgroup_put_root() and the former cgroup_kill_sb().
  Simliarly, cgroup_put() now directly schedules cgroup_free_rcu()
  when refcnt reaches zero.

* Unlike before, kernfs objects don't hold onto cgroup objects.  When
  cgroup destroys a kernfs node, all existing operations are drained
  and the association is broken immediately.  The same for
  cgroupfs_roots and mounts.

* All operations which come through kernfs guarantee that the
  associated cgroup is and stays valid for the duration of operation;
  however, there are two paths which need to find out the associated
  cgroup from dentry without going through kernfs -
  css_tryget_from_dir() and cgroupstats_build().  For these two,
  kernfs_node->priv is RCU managed so that they can dereference it
  under RCU read lock.

File and directory handling
---------------------------

* File and directory operations converted to kernfs_ops and
  kernfs_syscall_ops.

* xattrs is implicitly supported by kernfs.  No need to worry about it
  from cgroup.  This means that "xattr" mount option is no longer
  necessary.  A future patch will add a deprecated warning message
  when sane_behavior.

* When cftype->max_write_len > PAGE_SIZE, it's necessary to make a
  private copy of one of the kernfs_ops to set its atomic_write_len.
  cftype->kf_ops is added and cgroup_init/exit_cftypes() are updated
  to handle it.

* cftype->lockdep_key added so that kernfs lockdep annotation can be
  per cftype.

* Inidividual file entries and open states are now managed by kernfs.
  No need to worry about them from cgroup.  cfent, cgroup_open_file
  and their friends are removed.

* kernfs_nodes are created deactivated and kernfs_activate()
  invocations added to places where creation of new nodes are
  committed.

* cgroup_rmdir() uses kernfs_[un]break_active_protection() for
  self-removal.

v2: - Li pointed out in an earlier patch that specifying "name="
      during mount without subsystem specification should succeed if
      there's an existing hierarchy with a matching name although it
      should fail with -EINVAL if a new hierarchy should be created.
      Prior to the conversion, this used by handled by deferring
      failure from NULL return from cgroup_root_from_opts(), which was
      necessary because root was being created before checking for
      existing ones.  Note that cgroup_root_from_opts() returned an
      ERR_PTR() value for error conditions which require immediate
      mount failure.

      As we now have separate search and creation steps, deferring
      failure from cgroup_root_from_opts() is no longer necessary.
      cgroup_root_from_opts() is updated to always return ERR_PTR()
      value on failure.

    - The logic to match existing roots is updated so that a mount
      attempt with a matching name but different subsys_mask are
      rejected.  This was handled by a separate matching loop under
      the comment "Check for name clashes with existing mounts" but
      got lost during conversion.  Merge the check into the main
      search loop.

    - Add __rcu __force casting in RCU_INIT_POINTER() in
      cgroup_destroy_locked() to avoid the sparse address space
      warning reported by kbuild test bot.  Maybe we want an explicit
      interface to use kn->priv as RCU protected pointer?

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: kbuild test robot fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/linux/cgroup.h |   52 +--
 kernel/cgroup.c        | 1111 ++++++++++++++++--------------------------------
 2 files changed, 380 insertions(+), 783 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 4740cba..b6c2652 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -18,10 +18,10 @@
 #include <linux/rwsem.h>
 #include <linux/idr.h>
 #include <linux/workqueue.h>
-#include <linux/xattr.h>
 #include <linux/fs.h>
 #include <linux/percpu-refcount.h>
 #include <linux/seq_file.h>
+#include <linux/kernfs.h>
 
 #ifdef CONFIG_CGROUPS
 
@@ -157,16 +157,17 @@ struct cgroup {
 	/* the number of attached css's */
 	int nr_css;
 
+	atomic_t refcnt;
+
 	/*
 	 * We link our 'sibling' struct into our parent's 'children'.
 	 * Our children link their 'sibling' into our 'children'.
 	 */
 	struct list_head sibling;	/* my parent's children */
 	struct list_head children;	/* my children */
-	struct list_head files;		/* my files */
 
 	struct cgroup *parent;		/* my parent */
-	struct dentry *dentry;		/* cgroup fs entry, RCU protected */
+	struct kernfs_node *kn;		/* cgroup kernfs entry */
 
 	/*
 	 * Monotonically increasing unique serial number which defines a
@@ -220,9 +221,6 @@ struct cgroup {
 	/* For css percpu_ref killing and RCU-protected deletion */
 	struct rcu_head rcu_head;
 	struct work_struct destroy_work;
-
-	/* directory xattrs */
-	struct simple_xattrs xattrs;
 };
 
 #define MAX_CGROUP_ROOT_NAMELEN 64
@@ -289,15 +287,17 @@ enum {
 
 /*
  * A cgroupfs_root represents the root of a cgroup hierarchy, and may be
- * associated with a superblock to form an active hierarchy.  This is
+ * associated with a kernfs_root to form an active hierarchy.  This is
  * internal to cgroup core.  Don't access directly from controllers.
  */
 struct cgroupfs_root {
-	struct super_block *sb;
+	struct kernfs_root *kf_root;
 
 	/* The bitmask of subsystems attached to this hierarchy */
 	unsigned long subsys_mask;
 
+	atomic_t refcnt;
+
 	/* Unique id for this hierarchy. */
 	int hierarchy_id;
 
@@ -413,6 +413,9 @@ struct cftype {
 	 */
 	struct cgroup_subsys *ss;
 
+	/* kernfs_ops to use, initialized automatically during registration */
+	struct kernfs_ops *kf_ops;
+
 	/*
 	 * read_u64() is a shortcut for the common case of returning a
 	 * single integer. Use it in place of read()
@@ -458,6 +461,10 @@ struct cftype {
 	 * kick type for multiplexing.
 	 */
 	int (*trigger)(struct cgroup_subsys_state *css, unsigned int event);
+
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	struct lock_class_key	lockdep_key;
+#endif
 };
 
 /*
@@ -471,26 +478,6 @@ struct cftype_set {
 };
 
 /*
- * cgroupfs file entry, pointed to from leaf dentry->d_fsdata.  Don't
- * access directly.
- */
-struct cfent {
-	struct list_head		node;
-	struct dentry			*dentry;
-	struct cftype			*type;
-	struct cgroup_subsys_state	*css;
-
-	/* file xattrs */
-	struct simple_xattrs		xattrs;
-};
-
-/* seq_file->private points to the following, only ->priv is public */
-struct cgroup_open_file {
-	struct cfent			*cfe;
-	void				*priv;
-};
-
-/*
  * See the comment above CGRP_ROOT_SANE_BEHAVIOR for details.  This
  * function can be called as long as @cgrp is accessible.
  */
@@ -508,16 +495,17 @@ static inline const char *cgroup_name(const struct cgroup *cgrp)
 /* returns ino associated with a cgroup, 0 indicates unmounted root */
 static inline ino_t cgroup_ino(struct cgroup *cgrp)
 {
-	if (cgrp->dentry)
-		return cgrp->dentry->d_inode->i_ino;
+	if (cgrp->kn)
+		return cgrp->kn->ino;
 	else
 		return 0;
 }
 
 static inline struct cftype *seq_cft(struct seq_file *seq)
 {
-	struct cgroup_open_file *of = seq->private;
-	return of->cfe->type;
+	struct kernfs_open_file *of = seq->private;
+
+	return of->kn->priv;
 }
 
 struct cgroup_subsys_state *seq_css(struct seq_file *seq);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e09db61..f1ec561 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -40,9 +40,7 @@
 #include <linux/proc_fs.h>
 #include <linux/rcupdate.h>
 #include <linux/sched.h>
-#include <linux/backing-dev.h>
 #include <linux/slab.h>
-#include <linux/magic.h>
 #include <linux/spinlock.h>
 #include <linux/string.h>
 #include <linux/sort.h>
@@ -50,7 +48,6 @@
 #include <linux/delayacct.h>
 #include <linux/cgroupstats.h>
 #include <linux/hashtable.h>
-#include <linux/namei.h>
 #include <linux/pid_namespace.h>
 #include <linux/idr.h>
 #include <linux/vmalloc.h> /* TODO: replace with more sophisticated array */
@@ -176,7 +173,6 @@ static void cgroup_destroy_css_killed(struct cgroup *cgrp);
 static int cgroup_destroy_locked(struct cgroup *cgrp);
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
 			      bool is_add);
-static int cgroup_file_release(struct inode *inode, struct file *file);
 static void cgroup_pidlist_destroy_all(struct cgroup *cgrp);
 
 /**
@@ -209,8 +205,22 @@ static inline bool cgroup_is_dead(const struct cgroup *cgrp)
 
 struct cgroup_subsys_state *seq_css(struct seq_file *seq)
 {
-	struct cgroup_open_file *of = seq->private;
-	return of->cfe->css;
+	struct kernfs_open_file *of = seq->private;
+	struct cgroup *cgrp = of->kn->parent->priv;
+	struct cftype *cft = seq_cft(seq);
+
+	/*
+	 * This is open and unprotected implementation of cgroup_css().
+	 * seq_css() is only called from a kernfs file operation which has
+	 * an active reference on the file.  Because all the subsystem
+	 * files are drained before a css is disassociated with a cgroup,
+	 * the matching css from the cgroup's subsys table is guaranteed to
+	 * be and stay valid until the enclosing operation is complete.
+	 */
+	if (cft->ss)
+		return rcu_dereference_raw(cgrp->subsys[cft->ss->id]);
+	else
+		return &cgrp->dummy_css;
 }
 EXPORT_SYMBOL_GPL(seq_css);
 
@@ -276,21 +286,6 @@ static int notify_on_release(const struct cgroup *cgrp)
 #define for_each_active_root(root)					\
 	list_for_each_entry((root), &cgroup_roots, root_list)
 
-static inline struct cgroup *__d_cgrp(struct dentry *dentry)
-{
-	return dentry->d_fsdata;
-}
-
-static inline struct cfent *__d_cfe(struct dentry *dentry)
-{
-	return dentry->d_fsdata;
-}
-
-static inline struct cftype *__d_cft(struct dentry *dentry)
-{
-	return __d_cfe(dentry)->type;
-}
-
 /**
  * cgroup_lock_live_group - take cgroup_mutex and check that cgrp is alive.
  * @cgrp: the cgroup to be checked for liveness
@@ -692,6 +687,13 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 	return cset;
 }
 
+static struct cgroupfs_root *cgroup_root_from_kf(struct kernfs_root *kf_root)
+{
+	struct cgroup *top_cgrp = kf_root->kn->priv;
+
+	return top_cgrp->root;
+}
+
 static int cgroup_init_root_id(struct cgroupfs_root *root, int start, int end)
 {
 	int id;
@@ -730,30 +732,37 @@ static void cgroup_free_root(struct cgroupfs_root *root)
 
 static void cgroup_get_root(struct cgroupfs_root *root)
 {
-	atomic_inc(&root->sb->s_active);
+	/*
+	 * The caller must ensure that @root is alive, which can be
+	 * achieved by holding a ref on one of the member cgroups or
+	 * following a registered reference to @root while holding
+	 * cgroup_tree_mutex.
+	 */
+	WARN_ON_ONCE(atomic_read(&root->refcnt) <= 0);
+	atomic_inc(&root->refcnt);
 }
 
 static void cgroup_put_root(struct cgroupfs_root *root)
 {
-	deactivate_super(root->sb);
-}
-
-static void cgroup_kill_sb(struct super_block *sb)
-{
-	struct cgroupfs_root *root = sb->s_fs_info;
 	struct cgroup *cgrp = &root->top_cgroup;
 	struct cgrp_cset_link *link, *tmp_link;
 	int ret;
 
-	BUG_ON(!root);
+	/*
+	 * @root's refcnt reaching zero and its deregistration should be
+	 * atomic w.r.t. cgroup_tree_mutex.  This ensures that
+	 * cgroup_get_root() is safe to invoke if @root is registered.
+	 */
+	mutex_lock(&cgroup_tree_mutex);
+	if (!atomic_dec_and_test(&root->refcnt)) {
+		mutex_unlock(&cgroup_tree_mutex);
+		return;
+	}
+	mutex_lock(&cgroup_mutex);
 
 	BUG_ON(root->number_of_cgroups != 1);
 	BUG_ON(!list_empty(&cgrp->children));
 
-	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
-	mutex_lock(&cgroup_tree_mutex);
-	mutex_lock(&cgroup_mutex);
-
 	/* Rebind all subsystems back to the default hierarchy */
 	if (root->flags & CGRP_ROOT_SUBSYS_BOUND) {
 		ret = rebind_subsystems(root, 0, root->subsys_mask);
@@ -783,11 +792,8 @@ static void cgroup_kill_sb(struct super_block *sb)
 
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgroup_tree_mutex);
-	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
-
-	simple_xattrs_free(&cgrp->xattrs);
 
-	kill_litter_super(sb);
+	kernfs_destroy_root(root->kf_root);
 	cgroup_free_root(root);
 }
 
@@ -878,42 +884,10 @@ static struct cgroup *task_cgroup_from_root(struct task_struct *task,
  * update of a tasks cgroup pointer by cgroup_attach_task()
  */
 
-/*
- * A couple of forward declarations required, due to cyclic reference loop:
- * cgroup_mkdir -> cgroup_create -> cgroup_populate_dir ->
- * cgroup_add_file -> cgroup_create_file -> cgroup_dir_inode_operations
- * -> cgroup_mkdir.
- */
-
-static int cgroup_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode);
-static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry);
 static int cgroup_populate_dir(struct cgroup *cgrp, unsigned long subsys_mask);
-static const struct inode_operations cgroup_dir_inode_operations;
+static struct kernfs_syscall_ops cgroup_kf_syscall_ops;
 static const struct file_operations proc_cgroupstats_operations;
 
-static struct backing_dev_info cgroup_backing_dev_info = {
-	.name		= "cgroup",
-	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
-};
-
-static struct inode *cgroup_new_inode(umode_t mode, struct super_block *sb)
-{
-	struct inode *inode = new_inode(sb);
-
-	if (inode) {
-		do {
-			/* ino 0 is reserved for dummy_root */
-			inode->i_ino = get_next_ino();
-		} while (!inode->i_ino);
-		inode->i_mode = mode;
-		inode->i_uid = current_fsuid();
-		inode->i_gid = current_fsgid();
-		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
-		inode->i_mapping->backing_dev_info = &cgroup_backing_dev_info;
-	}
-	return inode;
-}
-
 static struct cgroup_name *cgroup_alloc_name(const char *name_str)
 {
 	struct cgroup_name *name;
@@ -983,8 +957,6 @@ static void cgroup_free_fn(struct work_struct *work)
 
 	cgroup_pidlist_destroy_all(cgrp);
 
-	simple_xattrs_free(&cgrp->xattrs);
-
 	kfree(rcu_dereference_raw(cgrp->name));
 	kfree(cgrp);
 }
@@ -999,79 +971,36 @@ static void cgroup_free_rcu(struct rcu_head *head)
 
 static void cgroup_get(struct cgroup *cgrp)
 {
-	dget(cgrp->dentry);
-}
-
-static void cgroup_diput(struct dentry *dentry, struct inode *inode)
-{
-	/* is dentry a directory ? if so, kfree() associated cgroup */
-	if (S_ISDIR(inode->i_mode)) {
-		struct cgroup *cgrp = dentry->d_fsdata;
-
-		BUG_ON(!(cgroup_is_dead(cgrp)));
-
-		/*
-		 * XXX: cgrp->id is only used to look up css's.  As cgroup
-		 * and css's lifetimes will be decoupled, it should be made
-		 * per-subsystem and moved to css->id so that lookups are
-		 * successful until the target css is released.
-		 */
-		idr_remove(&cgrp->root->cgroup_idr, cgrp->id);
-		cgrp->id = -1;
-
-		call_rcu(&cgrp->rcu_head, cgroup_free_rcu);
-	} else {
-		struct cfent *cfe = __d_cfe(dentry);
-		struct cgroup *cgrp = dentry->d_parent->d_fsdata;
-
-		WARN_ONCE(!list_empty(&cfe->node) &&
-			  cgrp != &cgrp->root->top_cgroup,
-			  "cfe still linked for %s\n", cfe->type->name);
-		simple_xattrs_free(&cfe->xattrs);
-		kfree(cfe);
-	}
-	iput(inode);
+	WARN_ON_ONCE(cgroup_is_dead(cgrp));
+	WARN_ON_ONCE(atomic_read(&cgrp->refcnt) <= 0);
+	atomic_inc(&cgrp->refcnt);
 }
 
 static void cgroup_put(struct cgroup *cgrp)
 {
-	dput(cgrp->dentry);
-}
+	if (!atomic_dec_and_test(&cgrp->refcnt))
+		return;
+	if (WARN_ON_ONCE(!cgroup_is_dead(cgrp)))
+		return;
 
-static void remove_dir(struct dentry *d)
-{
-	struct dentry *parent = dget(d->d_parent);
+	/*
+	 * XXX: cgrp->id is only used to look up css's.  As cgroup and
+	 * css's lifetimes will be decoupled, it should be made
+	 * per-subsystem and moved to css->id so that lookups are
+	 * successful until the target css is released.
+	 */
+	idr_remove(&cgrp->root->cgroup_idr, cgrp->id);
+	cgrp->id = -1;
 
-	d_delete(d);
-	simple_rmdir(parent->d_inode, d);
-	dput(parent);
+	call_rcu(&cgrp->rcu_head, cgroup_free_rcu);
 }
 
 static void cgroup_rm_file(struct cgroup *cgrp, const struct cftype *cft)
 {
-	struct cfent *cfe;
+	char name[CGROUP_FILE_NAME_MAX];
 
-	lockdep_assert_held(&cgrp->dentry->d_inode->i_mutex);
 	lockdep_assert_held(&cgroup_tree_mutex);
-
-	/*
-	 * If we're doing cleanup due to failure of cgroup_create(),
-	 * the corresponding @cfe may not exist.
-	 */
-	list_for_each_entry(cfe, &cgrp->files, node) {
-		struct dentry *d = cfe->dentry;
-
-		if (cft && cfe->type != cft)
-			continue;
-
-		dget(d);
-		d_delete(d);
-		simple_unlink(cgrp->dentry->d_inode, d);
-		list_del_init(&cfe->node);
-		dput(d);
-
-		break;
-	}
+	kernfs_remove_by_name(cgrp->kn, cgroup_file_name(cgrp, cft, name));
 }
 
 /**
@@ -1094,22 +1023,6 @@ static void cgroup_clear_dir(struct cgroup *cgrp, unsigned long subsys_mask)
 	}
 }
 
-/*
- * NOTE : the dentry must have been dget()'ed
- */
-static void cgroup_d_remove_dir(struct dentry *dentry)
-{
-	struct dentry *parent;
-
-	parent = dentry->d_parent;
-	spin_lock(&parent->d_lock);
-	spin_lock_nested(&dentry->d_lock, DENTRY_D_LOCK_NESTED);
-	list_del_init(&dentry->d_u.d_child);
-	spin_unlock(&dentry->d_lock);
-	spin_unlock(&parent->d_lock);
-	remove_dir(dentry);
-}
-
 static int rebind_subsystems(struct cgroupfs_root *root,
 			     unsigned long added_mask, unsigned removed_mask)
 {
@@ -1177,13 +1090,15 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	 * now matches the bound subsystems.
 	 */
 	root->flags |= CGRP_ROOT_SUBSYS_BOUND;
+	kernfs_activate(cgrp->kn);
 
 	return 0;
 }
 
-static int cgroup_show_options(struct seq_file *seq, struct dentry *dentry)
+static int cgroup_show_options(struct seq_file *seq,
+			       struct kernfs_root *kf_root)
 {
-	struct cgroupfs_root *root = dentry->d_sb->s_fs_info;
+	struct cgroupfs_root *root = cgroup_root_from_kf(kf_root);
 	struct cgroup_subsys *ss;
 	int ssid;
 
@@ -1217,9 +1132,6 @@ struct cgroup_sb_opts {
 	char *name;
 	/* User explicitly requested empty subsystem */
 	bool none;
-
-	struct cgroupfs_root *new_root;
-
 };
 
 /*
@@ -1378,11 +1290,10 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 	return 0;
 }
 
-static int cgroup_remount(struct super_block *sb, int *flags, char *data)
+static int cgroup_remount(struct kernfs_root *kf_root, int *flags, char *data)
 {
 	int ret = 0;
-	struct cgroupfs_root *root = sb->s_fs_info;
-	struct cgroup *cgrp = &root->top_cgroup;
+	struct cgroupfs_root *root = cgroup_root_from_kf(kf_root);
 	struct cgroup_sb_opts opts;
 	unsigned long added_mask, removed_mask;
 
@@ -1391,7 +1302,6 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 		return -EINVAL;
 	}
 
-	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
 	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 
@@ -1437,34 +1347,26 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	kfree(opts.name);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgroup_tree_mutex);
-	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 	return ret;
 }
 
-static const struct super_operations cgroup_ops = {
-	.statfs = simple_statfs,
-	.drop_inode = generic_delete_inode,
-	.show_options = cgroup_show_options,
-	.remount_fs = cgroup_remount,
-};
-
 static void init_cgroup_housekeeping(struct cgroup *cgrp)
 {
+	atomic_set(&cgrp->refcnt, 1);
 	INIT_LIST_HEAD(&cgrp->sibling);
 	INIT_LIST_HEAD(&cgrp->children);
-	INIT_LIST_HEAD(&cgrp->files);
 	INIT_LIST_HEAD(&cgrp->cset_links);
 	INIT_LIST_HEAD(&cgrp->release_list);
 	INIT_LIST_HEAD(&cgrp->pidlists);
 	mutex_init(&cgrp->pidlist_mutex);
 	cgrp->dummy_css.cgroup = cgrp;
-	simple_xattrs_init(&cgrp->xattrs);
 }
 
 static void init_cgroup_root(struct cgroupfs_root *root)
 {
 	struct cgroup *cgrp = &root->top_cgroup;
 
+	atomic_set(&root->refcnt, 1);
 	INIT_LIST_HEAD(&root->root_list);
 	root->number_of_cgroups = 1;
 	cgrp->root = root;
@@ -1473,32 +1375,12 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 	idr_init(&root->cgroup_idr);
 }
 
-static int cgroup_test_super(struct super_block *sb, void *data)
-{
-	struct cgroup_sb_opts *opts = data;
-	struct cgroupfs_root *root = sb->s_fs_info;
-
-	/* If we asked for a name then it must match */
-	if (opts->name && strcmp(opts->name, root->name))
-		return 0;
-
-	/*
-	 * If we asked for subsystems (or explicitly for no
-	 * subsystems) then they must match
-	 */
-	if ((opts->subsys_mask || opts->none)
-	    && (opts->subsys_mask != root->subsys_mask))
-		return 0;
-
-	return 1;
-}
-
 static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
 {
 	struct cgroupfs_root *root;
 
 	if (!opts->subsys_mask && !opts->none)
-		return NULL;
+		return ERR_PTR(-EINVAL);
 
 	root = kzalloc(sizeof(*root), GFP_KERNEL);
 	if (!root)
@@ -1525,99 +1407,21 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
 	return root;
 }
 
-static int cgroup_set_super(struct super_block *sb, void *data)
-{
-	int ret;
-	struct cgroup_sb_opts *opts = data;
-
-	/* If we don't have a new root, we can't set up a new sb */
-	if (!opts->new_root)
-		return -EINVAL;
-
-	BUG_ON(!opts->subsys_mask && !opts->none);
-
-	ret = set_anon_super(sb, NULL);
-	if (ret)
-		return ret;
-
-	sb->s_fs_info = opts->new_root;
-	opts->new_root->sb = sb;
-
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
-	sb->s_magic = CGROUP_SUPER_MAGIC;
-	sb->s_op = &cgroup_ops;
-
-	return 0;
-}
-
-static int cgroup_get_rootdir(struct super_block *sb)
-{
-	static const struct dentry_operations cgroup_dops = {
-		.d_iput = cgroup_diput,
-		.d_delete = always_delete_dentry,
-	};
-
-	struct inode *inode =
-		cgroup_new_inode(S_IFDIR | S_IRUGO | S_IXUGO | S_IWUSR, sb);
-
-	if (!inode)
-		return -ENOMEM;
-
-	inode->i_fop = &simple_dir_operations;
-	inode->i_op = &cgroup_dir_inode_operations;
-	/* directories start off with i_nlink == 2 (for "." entry) */
-	inc_nlink(inode);
-	sb->s_root = d_make_root(inode);
-	if (!sb->s_root)
-		return -ENOMEM;
-	/* for everything else we want ->d_op set */
-	sb->s_d_op = &cgroup_dops;
-	return 0;
-}
-
 static int cgroup_setup_root(struct cgroupfs_root *root)
 {
 	LIST_HEAD(tmp_links);
-	struct super_block *sb = root->sb;
 	struct cgroup *root_cgrp = &root->top_cgroup;
-	struct cgroupfs_root *existing_root;
 	struct css_set *cset;
-	struct inode *inode;
-	const struct cred *cred;
 	int i, ret;
 
 	lockdep_assert_held(&cgroup_tree_mutex);
 	lockdep_assert_held(&cgroup_mutex);
-	BUG_ON(sb->s_root != NULL);
-
-	mutex_unlock(&cgroup_mutex);
-	mutex_unlock(&cgroup_tree_mutex);
-
-	ret = cgroup_get_rootdir(sb);
-	if (ret) {
-		mutex_lock(&cgroup_tree_mutex);
-		mutex_lock(&cgroup_mutex);
-		return ret;
-	}
-	inode = sb->s_root->d_inode;
-
-	mutex_lock(&inode->i_mutex);
-	mutex_lock(&cgroup_tree_mutex);
-	mutex_lock(&cgroup_mutex);
 
 	ret = idr_alloc(&root->cgroup_idr, root_cgrp, 0, 1, GFP_KERNEL);
 	if (ret < 0)
-		goto out_unlock;
+		goto out;
 	root_cgrp->id = ret;
 
-	/* check for name clashes with existing mounts */
-	ret = -EBUSY;
-	if (strlen(root->name))
-		for_each_active_root(existing_root)
-			if (!strcmp(existing_root->name, root->name))
-				goto out_unlock;
-
 	/*
 	 * We're accessing css_set_count without locking css_set_lock here,
 	 * but that's OK - it can only be increased by someone holding
@@ -1626,34 +1430,29 @@ static int cgroup_setup_root(struct cgroupfs_root *root)
 	 */
 	ret = allocate_cgrp_cset_links(css_set_count, &tmp_links);
 	if (ret)
-		goto out_unlock;
+		goto out;
 
 	/* ID 0 is reserved for dummy root, 1 for unified hierarchy */
 	ret = cgroup_init_root_id(root, 2, 0);
 	if (ret)
-		goto out_unlock;
-
-	sb->s_root->d_fsdata = root_cgrp;
-	root_cgrp->dentry = sb->s_root;
+		goto out;
 
-	/*
-	 * We're inside get_sb() and will call lookup_one_len() to create
-	 * the root files, which doesn't work if SELinux is in use.  The
-	 * following cred dancing somehow works around it.  See 2ce9738ba
-	 * ("cgroupfs: use init_cred when populating new cgroupfs mount")
-	 * for more details.
-	 */
-	cred = override_creds(&init_cred);
+	root->kf_root = kernfs_create_root(&cgroup_kf_syscall_ops,
+					   KERNFS_ROOT_CREATE_DEACTIVATED,
+					   root_cgrp);
+	if (IS_ERR(root->kf_root)) {
+		ret = PTR_ERR(root->kf_root);
+		goto exit_root_id;
+	}
+	root_cgrp->kn = root->kf_root->kn;
 
 	ret = cgroup_addrm_files(root_cgrp, cgroup_base_files, true);
 	if (ret)
-		goto rm_base_files;
+		goto destroy_root;
 
 	ret = rebind_subsystems(root, root->subsys_mask, 0);
 	if (ret)
-		goto rm_base_files;
-
-	revert_creds(cred);
+		goto destroy_root;
 
 	/*
 	 * There must be no failure case after here, since rebinding takes
@@ -1675,15 +1474,16 @@ static int cgroup_setup_root(struct cgroupfs_root *root)
 	BUG_ON(!list_empty(&root_cgrp->children));
 	BUG_ON(root->number_of_cgroups != 1);
 
+	kernfs_activate(root_cgrp->kn);
 	ret = 0;
-	goto out_unlock;
+	goto out;
 
-rm_base_files:
-	cgroup_addrm_files(&root->top_cgroup, cgroup_base_files, false);
-	revert_creds(cred);
+destroy_root:
+	kernfs_destroy_root(root->kf_root);
+	root->kf_root = NULL;
+exit_root_id:
 	cgroup_exit_root_id(root);
-out_unlock:
-	mutex_unlock(&inode->i_mutex);
+out:
 	free_cgrp_cset_links(&tmp_links);
 	return ret;
 }
@@ -1692,10 +1492,9 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 			 int flags, const char *unused_dev_name,
 			 void *data)
 {
-	struct super_block *sb = NULL;
-	struct cgroupfs_root *root = NULL;
+	struct cgroupfs_root *root;
 	struct cgroup_sb_opts opts;
-	struct cgroupfs_root *new_root;
+	struct dentry *dentry;
 	int ret;
 
 	mutex_lock(&cgroup_tree_mutex);
@@ -1706,41 +1505,32 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	if (ret)
 		goto out_unlock;
 
-	/*
-	 * Allocate a new cgroup root. We may not need it if we're
-	 * reusing an existing hierarchy.
-	 */
-	new_root = cgroup_root_from_opts(&opts);
-	if (IS_ERR(new_root)) {
-		ret = PTR_ERR(new_root);
-		goto out_unlock;
-	}
-	opts.new_root = new_root;
+	/* look for a matching existing root */
+	for_each_active_root(root) {
+		bool name_match = false;
 
-	/* Locate an existing or new sb for this hierarchy */
-	mutex_unlock(&cgroup_mutex);
-	mutex_unlock(&cgroup_tree_mutex);
-	sb = sget(fs_type, cgroup_test_super, cgroup_set_super, 0, &opts);
-	mutex_lock(&cgroup_tree_mutex);
-	mutex_lock(&cgroup_mutex);
-	if (IS_ERR(sb)) {
-		ret = PTR_ERR(sb);
-		cgroup_free_root(opts.new_root);
-		goto out_unlock;
-	}
+		/*
+		 * If we asked for a name then it must match.  Also, if
+		 * name matches but sybsys_mask doesn't, we should fail.
+		 * Remember whether name matched.
+		 */
+		if (opts.name) {
+			if (strcmp(opts.name, root->name))
+				continue;
+			name_match = true;
+		}
 
-	root = sb->s_fs_info;
-	BUG_ON(!root);
-	if (root == opts.new_root) {
-		ret = cgroup_setup_root(root);
-		if (ret)
-			goto out_unlock;
-	} else {
 		/*
-		 * We re-used an existing hierarchy - the new root (if
-		 * any) is not needed
+		 * If we asked for subsystems (or explicitly for no
+		 * subsystems) then they must match.
 		 */
-		cgroup_free_root(opts.new_root);
+		if ((opts.subsys_mask || opts.none) &&
+		    (opts.subsys_mask != root->subsys_mask)) {
+			if (!name_match)
+				continue;
+			ret = -EBUSY;
+			goto out_unlock;
+		}
 
 		if ((root->flags ^ opts.flags) & CGRP_ROOT_OPTION_MASK) {
 			if ((root->flags | opts.flags) & CGRP_ROOT_SANE_BEHAVIOR) {
@@ -1751,23 +1541,45 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 				pr_warning("cgroup: new mount options do not match the existing superblock, will be ignored\n");
 			}
 		}
+
+		cgroup_get_root(root);
+		goto out_unlock;
 	}
 
-	ret = 0;
+	/* no such thing, create a new one */
+	root = cgroup_root_from_opts(&opts);
+	if (IS_ERR(root)) {
+		ret = PTR_ERR(root);
+		goto out_unlock;
+	}
+
+	ret = cgroup_setup_root(root);
+	if (ret)
+		cgroup_free_root(root);
+
 out_unlock:
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgroup_tree_mutex);
 
-	if (ret && !IS_ERR_OR_NULL(sb))
-		deactivate_locked_super(sb);
-
 	kfree(opts.release_agent);
 	kfree(opts.name);
 
-	if (!ret)
-		return dget(sb->s_root);
-	else
+	if (ret)
 		return ERR_PTR(ret);
+
+	dentry = kernfs_mount(fs_type, flags, root->kf_root);
+	if (IS_ERR(dentry))
+		cgroup_put_root(root);
+	return dentry;
+}
+
+static void cgroup_kill_sb(struct super_block *sb)
+{
+	struct kernfs_root *kf_root = kernfs_root_from_sb(sb);
+	struct cgroupfs_root *root = cgroup_root_from_kf(kf_root);
+
+	cgroup_put_root(root);
+	kernfs_kill_sb(sb);
 }
 
 static struct file_system_type cgroup_fs_type = {
@@ -2299,29 +2111,23 @@ static int cgroup_sane_behavior_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-static ssize_t cgroup_file_write(struct file *file, const char __user *userbuf,
-				 size_t nbytes, loff_t *ppos)
+static ssize_t cgroup_file_write(struct kernfs_open_file *of, char *buf,
+				 size_t nbytes, loff_t off)
 {
-	struct cfent *cfe = __d_cfe(file->f_dentry);
-	struct cftype *cft = __d_cft(file->f_dentry);
-	struct cgroup_subsys_state *css = cfe->css;
-	size_t max_bytes = max(cft->max_write_len, PAGE_SIZE);
-	char *buf;
+	struct cgroup *cgrp = of->kn->parent->priv;
+	struct cftype *cft = of->kn->priv;
+	struct cgroup_subsys_state *css;
 	int ret;
 
-	if (nbytes > max_bytes)
-		return -E2BIG;
-
-	buf = kmalloc(nbytes + 1, GFP_KERNEL);
-	if (!buf)
-		return -ENOMEM;
-
-	if (copy_from_user(buf, userbuf, nbytes)) {
-		ret = -EFAULT;
-		goto out_free;
-	}
-
-	buf[nbytes] = '\0';
+	/*
+	 * kernfs guarantees that a file isn't deleted with operations in
+	 * flight, which means that the matching css is and stays alive and
+	 * doesn't need to be pinned.  The RCU locking is not necessary
+	 * either.  It's just for the convenience of using cgroup_css().
+	 */
+	rcu_read_lock();
+	css = cgroup_css(cgrp, cft->ss);
+	rcu_read_unlock();
 
 	if (cft->write_string) {
 		ret = cft->write_string(css, cft, strstrip(buf));
@@ -2340,53 +2146,23 @@ static ssize_t cgroup_file_write(struct file *file, const char __user *userbuf,
 	} else {
 		ret = -EINVAL;
 	}
-out_free:
-	kfree(buf);
+
 	return ret ?: nbytes;
 }
 
-/*
- * seqfile ops/methods for returning structured data. Currently just
- * supports string->u64 maps, but can be extended in future.
- */
-
 static void *cgroup_seqfile_start(struct seq_file *seq, loff_t *ppos)
 {
-	struct cftype *cft = seq_cft(seq);
-
-	if (cft->seq_start) {
-		return cft->seq_start(seq, ppos);
-	} else {
-		/*
-		 * The same behavior and code as single_open().  Returns
-		 * !NULL if pos is at the beginning; otherwise, NULL.
-		 */
-		return NULL + !*ppos;
-	}
+	return seq_cft(seq)->seq_start(seq, ppos);
 }
 
 static void *cgroup_seqfile_next(struct seq_file *seq, void *v, loff_t *ppos)
 {
-	struct cftype *cft = seq_cft(seq);
-
-	if (cft->seq_next) {
-		return cft->seq_next(seq, v, ppos);
-	} else {
-		/*
-		 * The same behavior and code as single_open(), always
-		 * terminate after the initial read.
-		 */
-		++*ppos;
-		return NULL;
-	}
+	return seq_cft(seq)->seq_next(seq, v, ppos);
 }
 
 static void cgroup_seqfile_stop(struct seq_file *seq, void *v)
 {
-	struct cftype *cft = seq_cft(seq);
-
-	if (cft->seq_stop)
-		cft->seq_stop(seq, v);
+	seq_cft(seq)->seq_stop(seq, v);
 }
 
 static int cgroup_seqfile_show(struct seq_file *m, void *arg)
@@ -2406,96 +2182,36 @@ static int cgroup_seqfile_show(struct seq_file *m, void *arg)
 	return 0;
 }
 
-static struct seq_operations cgroup_seq_operations = {
-	.start		= cgroup_seqfile_start,
-	.next		= cgroup_seqfile_next,
-	.stop		= cgroup_seqfile_stop,
-	.show		= cgroup_seqfile_show,
+static struct kernfs_ops cgroup_kf_single_ops = {
+	.atomic_write_len	= PAGE_SIZE,
+	.write			= cgroup_file_write,
+	.seq_show		= cgroup_seqfile_show,
 };
 
-static int cgroup_file_open(struct inode *inode, struct file *file)
-{
-	struct cfent *cfe = __d_cfe(file->f_dentry);
-	struct cftype *cft = __d_cft(file->f_dentry);
-	struct cgroup *cgrp = __d_cgrp(cfe->dentry->d_parent);
-	struct cgroup_subsys_state *css;
-	struct cgroup_open_file *of;
-	int err;
-
-	err = generic_file_open(inode, file);
-	if (err)
-		return err;
-
-	/*
-	 * If the file belongs to a subsystem, pin the css.  Will be
-	 * unpinned either on open failure or release.  This ensures that
-	 * @css stays alive for all file operations.
-	 */
-	rcu_read_lock();
-	css = cgroup_css(cgrp, cft->ss);
-	if (cft->ss && !css_tryget(css))
-		css = NULL;
-	rcu_read_unlock();
-
-	if (!css)
-		return -ENODEV;
-
-	/*
-	 * @cfe->css is used by read/write/close to determine the
-	 * associated css.  @file->private_data would be a better place but
-	 * that's already used by seqfile.  Multiple accessors may use it
-	 * simultaneously which is okay as the association never changes.
-	 */
-	WARN_ON_ONCE(cfe->css && cfe->css != css);
-	cfe->css = css;
-
-	of = __seq_open_private(file, &cgroup_seq_operations,
-				sizeof(struct cgroup_open_file));
-	if (of) {
-		of->cfe = cfe;
-		return 0;
-	}
-
-	if (css->ss)
-		css_put(css);
-	return -ENOMEM;
-}
-
-static int cgroup_file_release(struct inode *inode, struct file *file)
-{
-	struct cfent *cfe = __d_cfe(file->f_dentry);
-	struct cgroup_subsys_state *css = cfe->css;
-
-	if (css->ss)
-		css_put(css);
-	return seq_release_private(inode, file);
-}
+static struct kernfs_ops cgroup_kf_ops = {
+	.atomic_write_len	= PAGE_SIZE,
+	.write			= cgroup_file_write,
+	.seq_start		= cgroup_seqfile_start,
+	.seq_next		= cgroup_seqfile_next,
+	.seq_stop		= cgroup_seqfile_stop,
+	.seq_show		= cgroup_seqfile_show,
+};
 
 /*
  * cgroup_rename - Only allow simple rename of directories in place.
  */
-static int cgroup_rename(struct inode *old_dir, struct dentry *old_dentry,
-			    struct inode *new_dir, struct dentry *new_dentry)
+static int cgroup_rename(struct kernfs_node *kn, struct kernfs_node *new_parent,
+			 const char *new_name_str)
 {
-	int ret;
+	struct cgroup *cgrp = kn->priv;
 	struct cgroup_name *name, *old_name;
-	struct cgroup *cgrp;
-
-	/*
-	 * It's convinient to use parent dir's i_mutex to protected
-	 * cgrp->name.
-	 */
-	lockdep_assert_held(&old_dir->i_mutex);
+	int ret;
 
-	if (!S_ISDIR(old_dentry->d_inode->i_mode))
+	if (kernfs_type(kn) != KERNFS_DIR)
 		return -ENOTDIR;
-	if (new_dentry->d_inode)
-		return -EEXIST;
-	if (old_dir != new_dir)
+	if (kn->parent != new_parent)
 		return -EIO;
 
-	cgrp = __d_cgrp(old_dentry);
-
 	/*
 	 * This isn't a proper migration and its usefulness is very
 	 * limited.  Disallow if sane_behavior.
@@ -2503,186 +2219,43 @@ static int cgroup_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (cgroup_sane_behavior(cgrp))
 		return -EPERM;
 
-	name = cgroup_alloc_name(new_dentry->d_name.name);
+	name = cgroup_alloc_name(new_name_str);
 	if (!name)
 		return -ENOMEM;
 
-	ret = simple_rename(old_dir, old_dentry, new_dir, new_dentry);
-	if (ret) {
-		kfree(name);
-		return ret;
+	mutex_lock(&cgroup_tree_mutex);
+	mutex_lock(&cgroup_mutex);
+
+	ret = kernfs_rename(kn, new_parent, new_name_str);
+	if (!ret) {
+		old_name = rcu_dereference_protected(cgrp->name, true);
+		rcu_assign_pointer(cgrp->name, name);
+	} else {
+		old_name = name;
 	}
 
-	old_name = rcu_dereference_protected(cgrp->name, true);
-	rcu_assign_pointer(cgrp->name, name);
+	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 
 	kfree_rcu(old_name, rcu_head);
-	return 0;
-}
-
-static struct simple_xattrs *__d_xattrs(struct dentry *dentry)
-{
-	if (S_ISDIR(dentry->d_inode->i_mode))
-		return &__d_cgrp(dentry)->xattrs;
-	else
-		return &__d_cfe(dentry)->xattrs;
-}
-
-static inline int xattr_enabled(struct dentry *dentry)
-{
-	struct cgroupfs_root *root = dentry->d_sb->s_fs_info;
-	return root->flags & CGRP_ROOT_XATTR;
-}
-
-static bool is_valid_xattr(const char *name)
-{
-	if (!strncmp(name, XATTR_TRUSTED_PREFIX, XATTR_TRUSTED_PREFIX_LEN) ||
-	    !strncmp(name, XATTR_SECURITY_PREFIX, XATTR_SECURITY_PREFIX_LEN))
-		return true;
-	return false;
-}
-
-static int cgroup_setxattr(struct dentry *dentry, const char *name,
-			   const void *val, size_t size, int flags)
-{
-	if (!xattr_enabled(dentry))
-		return -EOPNOTSUPP;
-	if (!is_valid_xattr(name))
-		return -EINVAL;
-	return simple_xattr_set(__d_xattrs(dentry), name, val, size, flags);
-}
-
-static int cgroup_removexattr(struct dentry *dentry, const char *name)
-{
-	if (!xattr_enabled(dentry))
-		return -EOPNOTSUPP;
-	if (!is_valid_xattr(name))
-		return -EINVAL;
-	return simple_xattr_remove(__d_xattrs(dentry), name);
-}
-
-static ssize_t cgroup_getxattr(struct dentry *dentry, const char *name,
-			       void *buf, size_t size)
-{
-	if (!xattr_enabled(dentry))
-		return -EOPNOTSUPP;
-	if (!is_valid_xattr(name))
-		return -EINVAL;
-	return simple_xattr_get(__d_xattrs(dentry), name, buf, size);
-}
-
-static ssize_t cgroup_listxattr(struct dentry *dentry, char *buf, size_t size)
-{
-	if (!xattr_enabled(dentry))
-		return -EOPNOTSUPP;
-	return simple_xattr_list(__d_xattrs(dentry), buf, size);
-}
-
-static const struct file_operations cgroup_file_operations = {
-	.read = seq_read,
-	.write = cgroup_file_write,
-	.llseek = generic_file_llseek,
-	.open = cgroup_file_open,
-	.release = cgroup_file_release,
-};
-
-static const struct inode_operations cgroup_file_inode_operations = {
-	.setxattr = cgroup_setxattr,
-	.getxattr = cgroup_getxattr,
-	.listxattr = cgroup_listxattr,
-	.removexattr = cgroup_removexattr,
-};
-
-static const struct inode_operations cgroup_dir_inode_operations = {
-	.lookup = simple_lookup,
-	.mkdir = cgroup_mkdir,
-	.rmdir = cgroup_rmdir,
-	.rename = cgroup_rename,
-	.setxattr = cgroup_setxattr,
-	.getxattr = cgroup_getxattr,
-	.listxattr = cgroup_listxattr,
-	.removexattr = cgroup_removexattr,
-};
-
-static int cgroup_create_file(struct dentry *dentry, umode_t mode,
-				struct super_block *sb)
-{
-	struct inode *inode;
-
-	if (!dentry)
-		return -ENOENT;
-	if (dentry->d_inode)
-		return -EEXIST;
-
-	inode = cgroup_new_inode(mode, sb);
-	if (!inode)
-		return -ENOMEM;
-
-	if (S_ISDIR(mode)) {
-		inode->i_op = &cgroup_dir_inode_operations;
-		inode->i_fop = &simple_dir_operations;
-
-		/* start off with i_nlink == 2 (for "." entry) */
-		inc_nlink(inode);
-		inc_nlink(dentry->d_parent->d_inode);
-
-		/*
-		 * Control reaches here with cgroup_mutex held.
-		 * @inode->i_mutex should nest outside cgroup_mutex but we
-		 * want to populate it immediately without releasing
-		 * cgroup_mutex.  As @inode isn't visible to anyone else
-		 * yet, trylock will always succeed without affecting
-		 * lockdep checks.
-		 */
-		WARN_ON_ONCE(!mutex_trylock(&inode->i_mutex));
-	} else if (S_ISREG(mode)) {
-		inode->i_size = 0;
-		inode->i_fop = &cgroup_file_operations;
-		inode->i_op = &cgroup_file_inode_operations;
-	}
-	d_instantiate(dentry, inode);
-	dget(dentry);	/* Extra count - pin the dentry in core */
-	return 0;
+	return ret;
 }
 
 static int cgroup_add_file(struct cgroup *cgrp, struct cftype *cft)
 {
-	struct dentry *dir = cgrp->dentry;
-	struct cgroup *parent = __d_cgrp(dir);
-	struct dentry *dentry;
-	struct cfent *cfe;
-	int error;
-	umode_t mode;
 	char name[CGROUP_FILE_NAME_MAX];
+	struct kernfs_node *kn;
+	struct lock_class_key *key = NULL;
 
-	BUG_ON(!mutex_is_locked(&dir->d_inode->i_mutex));
-
-	cfe = kzalloc(sizeof(*cfe), GFP_KERNEL);
-	if (!cfe)
-		return -ENOMEM;
-
-	cgroup_file_name(cgrp, cft, name);
-	dentry = lookup_one_len(name, dir, strlen(name));
-	if (IS_ERR(dentry)) {
-		error = PTR_ERR(dentry);
-		goto out;
-	}
-
-	cfe->type = (void *)cft;
-	cfe->dentry = dentry;
-	dentry->d_fsdata = cfe;
-	simple_xattrs_init(&cfe->xattrs);
-
-	mode = cgroup_file_mode(cft);
-	error = cgroup_create_file(dentry, mode | S_IFREG, cgrp->root->sb);
-	if (!error) {
-		list_add_tail(&cfe->node, &parent->files);
-		cfe = NULL;
-	}
-	dput(dentry);
-out:
-	kfree(cfe);
-	return error;
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	key = &cft->lockdep_key;
+#endif
+	kn = __kernfs_create_file(cgrp->kn, cgroup_file_name(cgrp, cft, name),
+				  cgroup_file_mode(cft), 0, cft->kf_ops, cft,
+				  NULL, false, key);
+	if (IS_ERR(kn))
+		return PTR_ERR(kn);
+	return 0;
 }
 
 /**
@@ -2702,7 +2275,6 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
 	struct cftype *cft;
 	int ret;
 
-	lockdep_assert_held(&cgrp->dentry->d_inode->i_mutex);
 	lockdep_assert_held(&cgroup_tree_mutex);
 
 	for (cft = cfts; cft->name[0] != '\0'; cft++) {
@@ -2747,9 +2319,7 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 	LIST_HEAD(pending);
 	struct cgroup_subsys *ss = cfts[0].ss;
 	struct cgroup *root = &ss->root->top_cgroup;
-	struct super_block *sb = ss->root->sb;
 	struct cgroup *prev = NULL;
-	struct inode *inode;
 	struct cgroup_subsys_state *css;
 	u64 update_before;
 	int ret = 0;
@@ -2757,12 +2327,13 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 	mutex_unlock(&cgroup_mutex);
 
 	/* %NULL @cfts indicates abort and don't bother if @ss isn't attached */
-	if (!cfts || ss->root == &cgroup_dummy_root ||
-	    !atomic_inc_not_zero(&sb->s_active)) {
+	if (!cfts || ss->root == &cgroup_dummy_root) {
 		mutex_unlock(&cgroup_tree_mutex);
 		return 0;
 	}
 
+	cgroup_get_root(ss->root);
+
 	/*
 	 * All cgroups which are created after we drop cgroup_mutex will
 	 * have the updated set of files, so we only need to update the
@@ -2777,18 +2348,16 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 		if (cgroup_is_dead(cgrp))
 			continue;
 
-		inode = cgrp->dentry->d_inode;
 		cgroup_get(cgrp);
 		if (prev)
 			cgroup_put(prev);
 		prev = cgrp;
 
-		mutex_unlock(&cgroup_tree_mutex);
-		mutex_lock(&inode->i_mutex);
-		mutex_lock(&cgroup_tree_mutex);
-		if (cgrp->serial_nr < update_before && !cgroup_is_dead(cgrp))
+		if (cgrp->serial_nr < update_before && !cgroup_is_dead(cgrp)) {
 			ret = cgroup_addrm_files(cgrp, cfts, is_add);
-		mutex_unlock(&inode->i_mutex);
+			if (is_add)
+				kernfs_activate(cgrp->kn);
+		}
 		if (ret)
 			break;
 	}
@@ -2802,16 +2371,45 @@ static void cgroup_exit_cftypes(struct cftype *cfts)
 {
 	struct cftype *cft;
 
-	for (cft = cfts; cft->name[0] != '\0'; cft++)
+	for (cft = cfts; cft->name[0] != '\0'; cft++) {
+		/* free copy for custom atomic_write_len, see init_cftypes() */
+		if (cft->max_write_len && cft->max_write_len != PAGE_SIZE)
+			kfree(cft->kf_ops);
+		cft->kf_ops = NULL;
 		cft->ss = NULL;
+	}
 }
 
-static void cgroup_init_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
+static int cgroup_init_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
 {
 	struct cftype *cft;
 
-	for (cft = cfts; cft->name[0] != '\0'; cft++)
+	for (cft = cfts; cft->name[0] != '\0'; cft++) {
+		struct kernfs_ops *kf_ops;
+
+		if (cft->seq_start)
+			kf_ops = &cgroup_kf_ops;
+		else
+			kf_ops = &cgroup_kf_single_ops;
+
+		/*
+		 * Ugh... if @cft wants a custom max_write_len, we need to
+		 * make a copy of kf_ops to set its atomic_write_len.
+		 */
+		if (cft->max_write_len && cft->max_write_len != PAGE_SIZE) {
+			kf_ops = kmemdup(kf_ops, sizeof(*kf_ops), GFP_KERNEL);
+			if (!kf_ops) {
+				cgroup_exit_cftypes(cfts);
+				return -ENOMEM;
+			}
+			kf_ops->atomic_write_len = cft->max_write_len;
+		}
+
+		cft->kf_ops = kf_ops;
 		cft->ss = ss;
+	}
+
+	return 0;
 }
 
 /**
@@ -2837,7 +2435,9 @@ int cgroup_add_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
 	if (!set)
 		return -ENOMEM;
 
-	cgroup_init_cftypes(ss, cfts);
+	ret = cgroup_init_cftypes(ss, cfts);
+	if (ret)
+		return ret;
 
 	cgroup_cfts_prepare();
 	set->cfts = cfts;
@@ -3704,21 +3304,27 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
  */
 int cgroupstats_build(struct cgroupstats *stats, struct dentry *dentry)
 {
-	int ret = -EINVAL;
+	struct kernfs_node *kn = kernfs_node_from_dentry(dentry);
 	struct cgroup *cgrp;
 	struct css_task_iter it;
 	struct task_struct *tsk;
 
+	/* it should be kernfs_node belonging to cgroupfs and is a directory */
+	if (dentry->d_sb->s_type != &cgroup_fs_type || !kn ||
+	    kernfs_type(kn) != KERNFS_DIR)
+		return -EINVAL;
+
 	/*
-	 * Validate dentry by checking the superblock operations,
-	 * and make sure it's a directory.
+	 * We aren't being called from kernfs and there's no guarantee on
+	 * @kn->priv's validity.  For this and css_tryget_from_dir(),
+	 * @kn->priv is RCU safe.  Let's do the RCU dancing.
 	 */
-	if (dentry->d_sb->s_op != &cgroup_ops ||
-	    !S_ISDIR(dentry->d_inode->i_mode))
-		 goto err;
-
-	ret = 0;
-	cgrp = dentry->d_fsdata;
+	rcu_read_lock();
+	cgrp = rcu_dereference(kn->priv);
+	if (!cgrp) {
+		rcu_read_unlock();
+		return -ENOENT;
+	}
 
 	css_task_iter_start(&cgrp->dummy_css, &it);
 	while ((tsk = css_task_iter_next(&it))) {
@@ -3743,8 +3349,8 @@ int cgroupstats_build(struct cgroupstats *stats, struct dentry *dentry)
 	}
 	css_task_iter_end(&it);
 
-err:
-	return ret;
+	rcu_read_unlock();
+	return 0;
 }
 
 
@@ -3762,7 +3368,7 @@ static void *cgroup_pidlist_start(struct seq_file *s, loff_t *pos)
 	 * after a seek to the start). Use a binary-search to find the
 	 * next pid to display, if any
 	 */
-	struct cgroup_open_file *of = s->private;
+	struct kernfs_open_file *of = s->private;
 	struct cgroup *cgrp = seq_css(s)->cgroup;
 	struct cgroup_pidlist *l;
 	enum cgroup_filetype type = seq_cft(s)->private;
@@ -3817,7 +3423,7 @@ static void *cgroup_pidlist_start(struct seq_file *s, loff_t *pos)
 
 static void cgroup_pidlist_stop(struct seq_file *s, void *v)
 {
-	struct cgroup_open_file *of = s->private;
+	struct kernfs_open_file *of = s->private;
 	struct cgroup_pidlist *l = of->priv;
 
 	if (l)
@@ -3828,7 +3434,7 @@ static void cgroup_pidlist_stop(struct seq_file *s, void *v)
 
 static void *cgroup_pidlist_next(struct seq_file *s, void *v, loff_t *pos)
 {
-	struct cgroup_open_file *of = s->private;
+	struct kernfs_open_file *of = s->private;
 	struct cgroup_pidlist *l = of->priv;
 	pid_t *p = v;
 	pid_t *end = l->list + l->length;
@@ -3878,21 +3484,6 @@ static int cgroup_write_notify_on_release(struct cgroup_subsys_state *css,
 	return 0;
 }
 
-/*
- * When dput() is called asynchronously, if umount has been done and
- * then deactivate_super() in cgroup_free_fn() kills the superblock,
- * there's a small window that vfs will see the root dentry with non-zero
- * refcnt and trigger BUG().
- *
- * That's why we hold a reference before dput() and drop it right after.
- */
-static void cgroup_dput(struct cgroup *cgrp)
-{
-	cgroup_get_root(cgrp->root);
-	cgroup_put(cgrp);
-	cgroup_put_root(cgrp->root);
-}
-
 static u64 cgroup_clone_children_read(struct cgroup_subsys_state *css,
 				      struct cftype *cft)
 {
@@ -4027,7 +3618,7 @@ static void css_free_work_fn(struct work_struct *work)
 		css_put(css->parent);
 
 	css->ss->css_free(css);
-	cgroup_dput(cgrp);
+	cgroup_put(cgrp);
 }
 
 static void css_free_rcu_fn(struct rcu_head *rcu_head)
@@ -4035,10 +3626,6 @@ static void css_free_rcu_fn(struct rcu_head *rcu_head)
 	struct cgroup_subsys_state *css =
 		container_of(rcu_head, struct cgroup_subsys_state, rcu_head);
 
-	/*
-	 * css holds an extra ref to @cgrp->dentry which is put on the last
-	 * css_put().  dput() requires process context which we don't have.
-	 */
 	INIT_WORK(&css->destroy_work, css_free_work_fn);
 	queue_work(cgroup_destroy_wq, &css->destroy_work);
 }
@@ -4120,7 +3707,6 @@ static int create_css(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	struct cgroup_subsys_state *css;
 	int err;
 
-	lockdep_assert_held(&cgrp->dentry->d_inode->i_mutex);
 	lockdep_assert_held(&cgroup_mutex);
 
 	css = ss->css_alloc(cgroup_css(parent, ss));
@@ -4161,30 +3747,28 @@ err_free:
 	return err;
 }
 
-/*
+/**
  * cgroup_create - create a cgroup
  * @parent: cgroup that will be parent of the new cgroup
- * @dentry: dentry of the new cgroup
- * @mode: mode to set on new inode
- *
- * Must be called with the mutex on the parent inode held
+ * @name_str: name of the new cgroup
+ * @mode: mode to set on new cgroup
  */
-static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
-			     umode_t mode)
+static long cgroup_create(struct cgroup *parent, const char *name_str,
+			  umode_t mode)
 {
 	struct cgroup *cgrp;
 	struct cgroup_name *name;
 	struct cgroupfs_root *root = parent->root;
 	int ssid, err;
 	struct cgroup_subsys *ss;
-	struct super_block *sb = root->sb;
+	struct kernfs_node *kn;
 
 	/* allocate the cgroup and its ID, 0 is reserved for the root */
 	cgrp = kzalloc(sizeof(*cgrp), GFP_KERNEL);
 	if (!cgrp)
 		return -ENOMEM;
 
-	name = cgroup_alloc_name(dentry->d_name.name);
+	name = cgroup_alloc_name(name_str);
 	if (!name) {
 		err = -ENOMEM;
 		goto err_free_cgrp;
@@ -4215,18 +3799,8 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		goto err_unlock_tree;
 	}
 
-	/* Grab a reference on the superblock so the hierarchy doesn't
-	 * get deleted on unmount if there are child cgroups.  This
-	 * can be done outside cgroup_mutex, since the sb can't
-	 * disappear while someone has an open control file on the
-	 * fs */
-	cgroup_get_root(root);
-
 	init_cgroup_housekeeping(cgrp);
 
-	dentry->d_fsdata = cgrp;
-	cgrp->dentry = dentry;
-
 	cgrp->parent = parent;
 	cgrp->dummy_css.parent = &parent->dummy_css;
 	cgrp->root = parent->root;
@@ -4237,15 +3811,13 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	if (test_bit(CGRP_CPUSET_CLONE_CHILDREN, &parent->flags))
 		set_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags);
 
-	/*
-	 * Create directory.  cgroup_create_file() returns with the new
-	 * directory locked on success so that it can be populated without
-	 * dropping cgroup_mutex.
-	 */
-	err = cgroup_create_file(dentry, S_IFDIR | mode, sb);
-	if (err < 0)
+	/* create the directory */
+	kn = kernfs_create_dir(parent->kn, name->name, mode, cgrp);
+	if (IS_ERR(kn)) {
+		err = PTR_ERR(kn);
 		goto err_unlock;
-	lockdep_assert_held(&dentry->d_inode->i_mutex);
+	}
+	cgrp->kn = kn;
 
 	cgrp->serial_nr = cgroup_serial_nr_next++;
 
@@ -4253,7 +3825,11 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	list_add_tail_rcu(&cgrp->sibling, &cgrp->parent->children);
 	root->number_of_cgroups++;
 
-	/* hold a ref to the parent's dentry */
+	/*
+	 * Grab a reference on the root and parent so that they don't get
+	 * deleted while there are child cgroups.
+	 */
+	cgroup_get_root(root);
 	cgroup_get(parent);
 
 	/*
@@ -4275,16 +3851,15 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		}
 	}
 
+	kernfs_activate(kn);
+
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgroup_tree_mutex);
-	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 
 	return 0;
 
 err_unlock:
 	mutex_unlock(&cgroup_mutex);
-	/* Release the reference count that we took on the superblock */
-	cgroup_put_root(root);
 err_unlock_tree:
 	mutex_unlock(&cgroup_tree_mutex);
 	idr_remove(&root->cgroup_idr, cgrp->id);
@@ -4298,16 +3873,15 @@ err_destroy:
 	cgroup_destroy_locked(cgrp);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgroup_tree_mutex);
-	mutex_unlock(&dentry->d_inode->i_mutex);
 	return err;
 }
 
-static int cgroup_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
+static int cgroup_mkdir(struct kernfs_node *parent_kn, const char *name,
+			umode_t mode)
 {
-	struct cgroup *c_parent = dentry->d_parent->d_fsdata;
+	struct cgroup *parent = parent_kn->priv;
 
-	/* the vfs holds inode->i_mutex already */
-	return cgroup_create(c_parent, dentry, mode | S_IFDIR);
+	return cgroup_create(parent, name, mode);
 }
 
 /*
@@ -4371,6 +3945,10 @@ static void css_killed_ref_fn(struct percpu_ref *ref)
  */
 static void kill_css(struct cgroup_subsys_state *css)
 {
+	/*
+	 * This must happen before css is disassociated with its cgroup.
+	 * See seq_css() for details.
+	 */
 	cgroup_clear_dir(css->cgroup, 1 << css->ss->id);
 
 	/*
@@ -4419,13 +3997,12 @@ static void kill_css(struct cgroup_subsys_state *css)
 static int cgroup_destroy_locked(struct cgroup *cgrp)
 	__releases(&cgroup_mutex) __acquires(&cgroup_mutex)
 {
-	struct dentry *d = cgrp->dentry;
-	struct cgroup_subsys_state *css;
 	struct cgroup *child;
+	struct cgroup_subsys_state *css;
+	struct kernfs_node *kn;
 	bool empty;
 	int ssid;
 
-	lockdep_assert_held(&d->d_inode->i_mutex);
 	lockdep_assert_held(&cgroup_tree_mutex);
 	lockdep_assert_held(&cgroup_mutex);
 
@@ -4490,15 +4067,24 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	if (!cgrp->nr_css)
 		cgroup_destroy_css_killed(cgrp);
 
+	/* remove @cgrp directory along with the base files */
+	mutex_unlock(&cgroup_mutex);
+
 	/*
-	 * Clear the base files and remove @cgrp directory.  The removal
-	 * puts the base ref but we aren't quite done with @cgrp yet, so
-	 * hold onto it.
+	 * There are two control paths which try to determine cgroup from
+	 * dentry without going through kernfs - cgroupstats_build() and
+	 * css_tryget_from_dir().  Those are supported by RCU protecting
+	 * clearing of cgrp->kn->priv backpointer, which should happen
+	 * after all files under it have been removed.
 	 */
-	mutex_unlock(&cgroup_mutex);
-	cgroup_addrm_files(cgrp, cgroup_base_files, false);
-	dget(d);
-	cgroup_d_remove_dir(d);
+	kn = cgrp->kn;
+	kernfs_get(kn);
+
+	kernfs_remove(cgrp->kn);
+
+	RCU_INIT_POINTER(*(void __rcu __force **)&cgrp->kn->priv, NULL);
+	kernfs_put(kn);
+
 	mutex_lock(&cgroup_mutex);
 
 	return 0;
@@ -4529,19 +4115,46 @@ static void cgroup_destroy_css_killed(struct cgroup *cgrp)
 	check_for_release(parent);
 }
 
-static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
+static int cgroup_rmdir(struct kernfs_node *kn)
 {
-	int ret;
+	struct cgroup *cgrp = kn->priv;
+	int ret = 0;
+
+	/*
+	 * This is self-destruction but @kn can't be removed while this
+	 * callback is in progress.  Let's break active protection.  Once
+	 * the protection is broken, @cgrp can be destroyed at any point.
+	 * Pin it so that it stays accessible.
+	 */
+	cgroup_get(cgrp);
+	kernfs_break_active_protection(kn);
 
 	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
-	ret = cgroup_destroy_locked(dentry->d_fsdata);
+
+	/*
+	 * @cgrp might already have been destroyed while we're trying to
+	 * grab the mutexes.
+	 */
+	if (!cgroup_is_dead(cgrp))
+		ret = cgroup_destroy_locked(cgrp);
+
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgroup_tree_mutex);
 
+	kernfs_unbreak_active_protection(kn);
+	cgroup_put(cgrp);
 	return ret;
 }
 
+static struct kernfs_syscall_ops cgroup_kf_syscall_ops = {
+	.remount_fs		= cgroup_remount,
+	.show_options		= cgroup_show_options,
+	.mkdir			= cgroup_mkdir,
+	.rmdir			= cgroup_rmdir,
+	.rename			= cgroup_rename,
+};
+
 static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 {
 	struct cgroup_subsys_state *css;
@@ -4633,11 +4246,7 @@ int __init cgroup_init(void)
 	unsigned long key;
 	int i, err;
 
-	err = bdi_init(&cgroup_backing_dev_info);
-	if (err)
-		return err;
-
-	cgroup_init_cftypes(NULL, cgroup_base_files);
+	BUG_ON(cgroup_init_cftypes(NULL, cgroup_base_files));
 
 	for_each_subsys(ss, i) {
 		if (!ss->early_init)
@@ -4667,24 +4276,17 @@ int __init cgroup_init(void)
 	mutex_unlock(&cgroup_mutex);
 
 	cgroup_kobj = kobject_create_and_add("cgroup", fs_kobj);
-	if (!cgroup_kobj) {
-		err = -ENOMEM;
-		goto out;
-	}
+	if (!cgroup_kobj)
+		return -ENOMEM;
 
 	err = register_filesystem(&cgroup_fs_type);
 	if (err < 0) {
 		kobject_put(cgroup_kobj);
-		goto out;
+		return err;
 	}
 
 	proc_create("cgroups", 0, NULL, &proc_cgroupstats_operations);
-
-out:
-	if (err)
-		bdi_destroy(&cgroup_backing_dev_info);
-
-	return err;
+	return 0;
 }
 
 static int __init cgroup_wq_init(void)
@@ -5089,18 +4691,25 @@ __setup("cgroup_disable=", cgroup_disable);
 struct cgroup_subsys_state *css_tryget_from_dir(struct dentry *dentry,
 						struct cgroup_subsys *ss)
 {
+	struct kernfs_node *kn = kernfs_node_from_dentry(dentry);
+	struct cgroup_subsys_state *css = NULL;
 	struct cgroup *cgrp;
-	struct cgroup_subsys_state *css;
 
 	/* is @dentry a cgroup dir? */
-	if (!dentry->d_inode ||
-	    dentry->d_inode->i_op != &cgroup_dir_inode_operations)
+	if (dentry->d_sb->s_type != &cgroup_fs_type || !kn ||
+	    kernfs_type(kn) != KERNFS_DIR)
 		return ERR_PTR(-EBADF);
 
 	rcu_read_lock();
 
-	cgrp = __d_cgrp(dentry);
-	css = cgroup_css(cgrp, ss);
+	/*
+	 * This path doesn't originate from kernfs and @kn could already
+	 * have been or be removed at any point.  @kn->priv is RCU
+	 * protected for this access.  See destroy_locked() for details.
+	 */
+	cgrp = rcu_dereference(kn->priv);
+	if (cgrp)
+		css = cgroup_css(cgrp, ss);
 
 	if (!css || !css_tryget(css))
 		css = ERR_PTR(-ENOENT);
-- 
1.8.5.3
