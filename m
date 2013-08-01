From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 09/23] cgroup: add subsys backlink pointer to cftype
Date: Thu,  1 Aug 2013 17:49:47 -0400
Message-ID: <1375393801-4817-10-git-send-email-tj__9902.97701578147$1375393882$gmane$org@kernel.org>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375393801-4817-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

cgroup is transitioning to using css (cgroup_subsys_state) instead of
cgroup as the primary subsystem handle.  The cgroupfs file interface
will be converted to use css's which requires finding out the
subsystem from cftype so that the matching css can be determined from
the cgroup.

This patch adds cftype->ss which points to the subsystem the file
belongs to.  The field is initialized while a cftype is being
registered.  This makes it unnecessary to explicitly specify the
subsystem for other cftype handling functions.  @ss argument dropped
from various cftype handling functions.

This patch shouldn't introduce any behavior differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
---
 block/blk-cgroup.c     |  2 +-
 include/linux/cgroup.h |  8 +++++-
 kernel/cgroup.c        | 78 ++++++++++++++++++++++++++++----------------------
 3 files changed, 51 insertions(+), 37 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 79fd9f4..3406373 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -1128,7 +1128,7 @@ void blkcg_policy_unregister(struct blkcg_policy *pol)
 
 	/* kill the intf files first */
 	if (pol->cftypes)
-		cgroup_rm_cftypes(&blkio_subsys, pol->cftypes);
+		cgroup_rm_cftypes(pol->cftypes);
 
 	/* unregister and update blkgs */
 	blkcg_policy[pol->plid] = NULL;
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 69b33f9..2e0e9e2 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -429,6 +429,12 @@ struct cftype {
 	/* CFTYPE_* flags */
 	unsigned int flags;
 
+	/*
+	 * The subsys this file belongs to.  Initialized automatically
+	 * during registration.  NULL for cgroup core files.
+	 */
+	struct cgroup_subsys *ss;
+
 	int (*open)(struct inode *inode, struct file *file);
 	ssize_t (*read)(struct cgroup *cgrp, struct cftype *cft,
 			struct file *file,
@@ -542,7 +548,7 @@ static inline const char *cgroup_name(const struct cgroup *cgrp)
 }
 
 int cgroup_add_cftypes(struct cgroup_subsys *ss, struct cftype *cfts);
-int cgroup_rm_cftypes(struct cgroup_subsys *ss, struct cftype *cfts);
+int cgroup_rm_cftypes(struct cftype *cfts);
 
 bool cgroup_is_descendant(struct cgroup *cgrp, struct cgroup *ancestor);
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index fae11e3..f1fc4d8 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -219,8 +219,8 @@ static struct cftype cgroup_base_files[];
 
 static void cgroup_offline_fn(struct work_struct *work);
 static int cgroup_destroy_locked(struct cgroup *cgrp);
-static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
-			      struct cftype cfts[], bool is_add);
+static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
+			      bool is_add);
 
 /* convenient tests for these bits */
 static inline bool cgroup_is_dead(const struct cgroup *cgrp)
@@ -974,7 +974,7 @@ static void cgroup_clear_dir(struct cgroup *cgrp, unsigned long subsys_mask)
 		if (!test_bit(i, &subsys_mask))
 			continue;
 		list_for_each_entry(set, &ss->cftsets, node)
-			cgroup_addrm_files(cgrp, NULL, set->cfts, false);
+			cgroup_addrm_files(cgrp, set->cfts, false);
 	}
 }
 
@@ -1623,7 +1623,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		 */
 		cred = override_creds(&init_cred);
 
-		ret = cgroup_addrm_files(root_cgrp, NULL, cgroup_base_files, true);
+		ret = cgroup_addrm_files(root_cgrp, cgroup_base_files, true);
 		if (ret)
 			goto rm_base_files;
 
@@ -1681,7 +1681,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 
  rm_base_files:
 	free_cgrp_cset_links(&tmp_links);
-	cgroup_addrm_files(&root->top_cgroup, NULL, cgroup_base_files, false);
+	cgroup_addrm_files(&root->top_cgroup, cgroup_base_files, false);
 	revert_creds(cred);
  unlock_drop:
 	cgroup_exit_root_id(root);
@@ -2687,8 +2687,7 @@ static umode_t cgroup_file_mode(const struct cftype *cft)
 	return mode;
 }
 
-static int cgroup_add_file(struct cgroup *cgrp, struct cgroup_subsys *subsys,
-			   struct cftype *cft)
+static int cgroup_add_file(struct cgroup *cgrp, struct cftype *cft)
 {
 	struct dentry *dir = cgrp->dentry;
 	struct cgroup *parent = __d_cgrp(dir);
@@ -2698,8 +2697,8 @@ static int cgroup_add_file(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 	umode_t mode;
 	char name[MAX_CGROUP_TYPE_NAMELEN + MAX_CFTYPE_NAME + 2] = { 0 };
 
-	if (subsys && !(cgrp->root->flags & CGRP_ROOT_NOPREFIX)) {
-		strcpy(name, subsys->name);
+	if (cft->ss && !(cgrp->root->flags & CGRP_ROOT_NOPREFIX)) {
+		strcpy(name, cft->ss->name);
 		strcat(name, ".");
 	}
 	strcat(name, cft->name);
@@ -2736,17 +2735,16 @@ out:
 /**
  * cgroup_addrm_files - add or remove files to a cgroup directory
  * @cgrp: the target cgroup
- * @subsys: the subsystem of files to be added
  * @cfts: array of cftypes to be added
  * @is_add: whether to add or remove
  *
  * Depending on @is_add, add or remove files defined by @cfts on @cgrp.
- * All @cfts should belong to @subsys.  For removals, this function never
- * fails.  If addition fails, this function doesn't remove files already
- * added.  The caller is responsible for cleaning up.
+ * For removals, this function never fails.  If addition fails, this
+ * function doesn't remove files already added.  The caller is responsible
+ * for cleaning up.
  */
-static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
-			      struct cftype cfts[], bool is_add)
+static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
+			      bool is_add)
 {
 	struct cftype *cft;
 	int ret;
@@ -2764,7 +2762,7 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 			continue;
 
 		if (is_add) {
-			ret = cgroup_add_file(cgrp, subsys, cft);
+			ret = cgroup_add_file(cgrp, cft);
 			if (ret) {
 				pr_warn("cgroup_addrm_files: failed to add %s, err=%d\n",
 					cft->name, ret);
@@ -2789,11 +2787,11 @@ static void cgroup_cfts_prepare(void)
 	mutex_lock(&cgroup_mutex);
 }
 
-static int cgroup_cfts_commit(struct cgroup_subsys *ss,
-			      struct cftype *cfts, bool is_add)
+static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 	__releases(&cgroup_mutex)
 {
 	LIST_HEAD(pending);
+	struct cgroup_subsys *ss = cfts[0].ss;
 	struct cgroup *cgrp, *root = &ss->root->top_cgroup;
 	struct super_block *sb = ss->root->sb;
 	struct dentry *prev = NULL;
@@ -2821,7 +2819,7 @@ static int cgroup_cfts_commit(struct cgroup_subsys *ss,
 	inode = root->dentry->d_inode;
 	mutex_lock(&inode->i_mutex);
 	mutex_lock(&cgroup_mutex);
-	ret = cgroup_addrm_files(root, ss, cfts, is_add);
+	ret = cgroup_addrm_files(root, cfts, is_add);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&inode->i_mutex);
 
@@ -2844,7 +2842,7 @@ static int cgroup_cfts_commit(struct cgroup_subsys *ss,
 		mutex_lock(&inode->i_mutex);
 		mutex_lock(&cgroup_mutex);
 		if (cgrp->serial_nr < update_before && !cgroup_is_dead(cgrp))
-			ret = cgroup_addrm_files(cgrp, ss, cfts, is_add);
+			ret = cgroup_addrm_files(cgrp, cfts, is_add);
 		mutex_unlock(&cgroup_mutex);
 		mutex_unlock(&inode->i_mutex);
 
@@ -2876,51 +2874,56 @@ out_deact:
 int cgroup_add_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
 {
 	struct cftype_set *set;
+	struct cftype *cft;
 	int ret;
 
 	set = kzalloc(sizeof(*set), GFP_KERNEL);
 	if (!set)
 		return -ENOMEM;
 
+	for (cft = cfts; cft->name[0] != '\0'; cft++)
+		cft->ss = ss;
+
 	cgroup_cfts_prepare();
 	set->cfts = cfts;
 	list_add_tail(&set->node, &ss->cftsets);
-	ret = cgroup_cfts_commit(ss, cfts, true);
+	ret = cgroup_cfts_commit(cfts, true);
 	if (ret)
-		cgroup_rm_cftypes(ss, cfts);
+		cgroup_rm_cftypes(cfts);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(cgroup_add_cftypes);
 
 /**
  * cgroup_rm_cftypes - remove an array of cftypes from a subsystem
- * @ss: target cgroup subsystem
  * @cfts: zero-length name terminated array of cftypes
  *
- * Unregister @cfts from @ss.  Files described by @cfts are removed from
- * all existing cgroups to which @ss is attached and all future cgroups
- * won't have them either.  This function can be called anytime whether @ss
- * is attached or not.
+ * Unregister @cfts.  Files described by @cfts are removed from all
+ * existing cgroups and all future cgroups won't have them either.  This
+ * function can be called anytime whether @cfts' subsys is attached or not.
  *
  * Returns 0 on successful unregistration, -ENOENT if @cfts is not
- * registered with @ss.
+ * registered.
  */
-int cgroup_rm_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
+int cgroup_rm_cftypes(struct cftype *cfts)
 {
 	struct cftype_set *set;
 
+	if (!cfts || !cfts[0].ss)
+		return -ENOENT;
+
 	cgroup_cfts_prepare();
 
-	list_for_each_entry(set, &ss->cftsets, node) {
+	list_for_each_entry(set, &cfts[0].ss->cftsets, node) {
 		if (set->cfts == cfts) {
 			list_del(&set->node);
 			kfree(set);
-			cgroup_cfts_commit(ss, cfts, false);
+			cgroup_cfts_commit(cfts, false);
 			return 0;
 		}
 	}
 
-	cgroup_cfts_commit(ss, NULL, false);
+	cgroup_cfts_commit(NULL, false);
 	return -ENOENT;
 }
 
@@ -4141,7 +4144,7 @@ static int cgroup_populate_dir(struct cgroup *cgrp, unsigned long subsys_mask)
 			continue;
 
 		list_for_each_entry(set, &ss->cftsets, node) {
-			ret = cgroup_addrm_files(cgrp, ss, set->cfts, true);
+			ret = cgroup_addrm_files(cgrp, set->cfts, true);
 			if (ret < 0)
 				goto err;
 		}
@@ -4368,7 +4371,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 
 	idr_replace(&root->cgroup_idr, cgrp, cgrp->id);
 
-	err = cgroup_addrm_files(cgrp, NULL, cgroup_base_files, true);
+	err = cgroup_addrm_files(cgrp, cgroup_base_files, true);
 	if (err)
 		goto err_destroy;
 
@@ -4529,7 +4532,7 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	 * but we aren't quite done with @cgrp yet, so hold onto it.
 	 */
 	cgroup_clear_dir(cgrp, cgrp->root->subsys_mask);
-	cgroup_addrm_files(cgrp, NULL, cgroup_base_files, false);
+	cgroup_addrm_files(cgrp, cgroup_base_files, false);
 	dget(d);
 	cgroup_d_remove_dir(d);
 
@@ -4623,6 +4626,11 @@ static void __init_or_module cgroup_init_cftsets(struct cgroup_subsys *ss)
 	 * deregistration.
 	 */
 	if (ss->base_cftypes) {
+		struct cftype *cft;
+
+		for (cft = ss->base_cftypes; cft->name[0] != '\0'; cft++)
+			cft->ss = ss;
+
 		ss->base_cftset.cfts = ss->base_cftypes;
 		list_add_tail(&ss->base_cftset.node, &ss->cftsets);
 	}
-- 
1.8.3.1
