From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 11/12] cgroup: introduce struct cfent
Date: Wed, 21 Mar 2012 15:17:44 -0700
Message-ID: <1332368265-21586-12-git-send-email-tj@kernel.org>
References: <1332368265-21586-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1332368265-21586-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch adds cfent (cgroup file entry) which is the association
between a cgroup and a file.  This is in-cgroup representation of
files under a cgroup directory.  This simplifies walking walking
cgroup files and thus cgroup_clear_directory(), which is now
implemented in two parts - cgroup_rm_file() and a loop around it.

cgroup_rm_file() will be used to implement cftype removal and cfent is
scheduled to serve cgroup specific per-file data (e.g. for sysfs-like
"sever" semantics).

v2: - cfe was freed from cgroup_rm_file() which led to use-after-free
      if the file had openers at the time of removal.  Moved to
      cgroup_diput().

    - cgroup_clear_directory() triggered WARN_ON_ONCE() if d_subdirs
      wasn't empty after removing all files.  This triggered
      spuriously if some files were open during directory clearing.
      Removed.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
---
 include/linux/cgroup.h |    1 +
 kernel/cgroup.c        |  111 ++++++++++++++++++++++++++++++++---------------
 2 files changed, 76 insertions(+), 36 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 45869d7..bfe5470 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -175,6 +175,7 @@ struct cgroup {
 	 */
 	struct list_head sibling;	/* my parent's children */
 	struct list_head children;	/* my children */
+	struct list_head files;		/* my files */
 
 	struct cgroup *parent;		/* my parent */
 	struct dentry __rcu *dentry;	/* cgroup fs entry, RCU protected */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index d64f16d..67daea9 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -148,6 +148,15 @@ struct cgroupfs_root {
 static struct cgroupfs_root rootnode;
 
 /*
+ * cgroupfs file entry, pointed to from leaf dentry->d_fsdata.
+ */
+struct cfent {
+	struct list_head		node;
+	struct dentry			*dentry;
+	struct cftype			*type;
+};
+
+/*
  * CSS ID -- ID per subsys's Cgroup Subsys State(CSS). used only when
  * cgroup_subsys->use_id != 0.
  */
@@ -287,11 +296,16 @@ static inline struct cgroup *__d_cgrp(struct dentry *dentry)
 	return dentry->d_fsdata;
 }
 
-static inline struct cftype *__d_cft(struct dentry *dentry)
+static inline struct cfent *__d_cfe(struct dentry *dentry)
 {
 	return dentry->d_fsdata;
 }
 
+static inline struct cftype *__d_cft(struct dentry *dentry)
+{
+	return __d_cfe(dentry)->type;
+}
+
 /* the list of cgroups eligible for automatic release. Protected by
  * release_list_lock */
 static LIST_HEAD(release_list);
@@ -877,6 +891,12 @@ static void cgroup_diput(struct dentry *dentry, struct inode *inode)
 		BUG_ON(!list_empty(&cgrp->pidlists));
 
 		kfree_rcu(cgrp, rcu_head);
+	} else {
+		struct cfent *cfe = __d_cfe(dentry);
+
+		WARN_ONCE(!list_empty(&cfe->node),
+			  "cfe still linked for %s\n", cfe->type->name);
+		kfree(cfe);
 	}
 	iput(inode);
 }
@@ -895,34 +915,36 @@ static void remove_dir(struct dentry *d)
 	dput(parent);
 }
 
-static void cgroup_clear_directory(struct dentry *dentry)
-{
-	struct list_head *node;
-
-	BUG_ON(!mutex_is_locked(&dentry->d_inode->i_mutex));
-	spin_lock(&dentry->d_lock);
-	node = dentry->d_subdirs.next;
-	while (node != &dentry->d_subdirs) {
-		struct dentry *d = list_entry(node, struct dentry, d_u.d_child);
-
-		spin_lock_nested(&d->d_lock, DENTRY_D_LOCK_NESTED);
-		list_del_init(node);
-		if (d->d_inode) {
-			/* This should never be called on a cgroup
-			 * directory with child cgroups */
-			BUG_ON(d->d_inode->i_mode & S_IFDIR);
-			dget_dlock(d);
-			spin_unlock(&d->d_lock);
-			spin_unlock(&dentry->d_lock);
-			d_delete(d);
-			simple_unlink(dentry->d_inode, d);
-			dput(d);
-			spin_lock(&dentry->d_lock);
-		} else
-			spin_unlock(&d->d_lock);
-		node = dentry->d_subdirs.next;
+static int cgroup_rm_file(struct cgroup *cgrp, const struct cftype *cft)
+{
+	struct cfent *cfe;
+
+	lockdep_assert_held(&cgrp->dentry->d_inode->i_mutex);
+	lockdep_assert_held(&cgroup_mutex);
+
+	list_for_each_entry(cfe, &cgrp->files, node) {
+		struct dentry *d = cfe->dentry;
+
+		if (cft && cfe->type != cft)
+			continue;
+
+		dget(d);
+		d_delete(d);
+		simple_unlink(d->d_inode, d);
+		list_del_init(&cfe->node);
+		dput(d);
+
+		return 0;
 	}
-	spin_unlock(&dentry->d_lock);
+	return -ENOENT;
+}
+
+static void cgroup_clear_directory(struct dentry *dir)
+{
+	struct cgroup *cgrp = __d_cgrp(dir);
+
+	while (!list_empty(&cgrp->files))
+		cgroup_rm_file(cgrp, NULL);
 }
 
 /*
@@ -1352,6 +1374,7 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 {
 	INIT_LIST_HEAD(&cgrp->sibling);
 	INIT_LIST_HEAD(&cgrp->children);
+	INIT_LIST_HEAD(&cgrp->files);
 	INIT_LIST_HEAD(&cgrp->css_sets);
 	INIT_LIST_HEAD(&cgrp->release_list);
 	INIT_LIST_HEAD(&cgrp->pidlists);
@@ -2623,7 +2646,9 @@ static int cgroup_add_file(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 			   const struct cftype *cft)
 {
 	struct dentry *dir = cgrp->dentry;
+	struct cgroup *parent = __d_cgrp(dir);
 	struct dentry *dentry;
+	struct cfent *cfe;
 	int error;
 	umode_t mode;
 	char name[MAX_CGROUP_TYPE_NAMELEN + MAX_CFTYPE_NAME + 2] = { 0 };
@@ -2639,17 +2664,31 @@ static int cgroup_add_file(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 		strcat(name, ".");
 	}
 	strcat(name, cft->name);
+
 	BUG_ON(!mutex_is_locked(&dir->d_inode->i_mutex));
+
+	cfe = kzalloc(sizeof(*cfe), GFP_KERNEL);
+	if (!cfe)
+		return -ENOMEM;
+
 	dentry = lookup_one_len(name, dir, strlen(name));
-	if (!IS_ERR(dentry)) {
-		mode = cgroup_file_mode(cft);
-		error = cgroup_create_file(dentry, mode | S_IFREG,
-						cgrp->root->sb);
-		if (!error)
-			dentry->d_fsdata = (void *)cft;
-		dput(dentry);
-	} else
+	if (IS_ERR(dentry)) {
 		error = PTR_ERR(dentry);
+		goto out;
+	}
+
+	mode = cgroup_file_mode(cft);
+	error = cgroup_create_file(dentry, mode | S_IFREG, cgrp->root->sb);
+	if (!error) {
+		cfe->type = (void *)cft;
+		cfe->dentry = dentry;
+		dentry->d_fsdata = cfe;
+		list_add_tail(&cfe->node, &parent->files);
+		cfe = NULL;
+	}
+	dput(dentry);
+out:
+	kfree(cfe);
 	return error;
 }
 
-- 
1.7.7.3
