From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/9] cgroup: separate out cgroup_base_files[] handling out of
	cgroup_populate/clear_dir()
Date: Fri, 28 Jun 2013 16:45:40 -0700
Message-ID: <1372463145-4245-5-git-send-email-tj__8224.26729505441$1372463192$gmane$org@kernel.org>
References: <1372463145-4245-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1372463145-4245-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_populate/clear_dir() currently take @base_files and adds and
removes, respectively, cgroup_base_files[] to the directory.  File
additions and removals are being reorganized for proper error handling
and more dynamic handling for the unified hierarchy, and mixing base
and subsys file handling into the same functions gets a bit confusing.

This patch moves base file handling out of cgroup_populate/clear_dir()
into their users - cgroup_mount(), cgroup_create() and
cgroup_destroy_locked().

Note that this changes the behavior of base file removal.  If
@base_files is %true, cgroup_clear_dir() used to delete files
regardless of cftype until there's no files left.  Now, only files
with matching cfts are removed.  As files can only be created by the
base or registered cftypes, this shouldn't result in any behavior
difference.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 46 +++++++++++++++++++---------------------------
 1 file changed, 19 insertions(+), 27 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 4682d81..254d54e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -215,6 +215,8 @@ static u64 cgroup_serial_nr_next = 1;
  */
 static int need_forkexit_callback __read_mostly;
 
+static struct cftype cgroup_base_files[];
+
 static void cgroup_offline_fn(struct work_struct *work);
 static int cgroup_destroy_locked(struct cgroup *cgrp);
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
@@ -804,8 +806,7 @@ static struct cgroup *task_cgroup_from_root(struct task_struct *task,
 static int cgroup_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode);
 static struct dentry *cgroup_lookup(struct inode *, struct dentry *, unsigned int);
 static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry);
-static int cgroup_populate_dir(struct cgroup *cgrp, bool base_files,
-			       unsigned long subsys_mask);
+static int cgroup_populate_dir(struct cgroup *cgrp, unsigned long subsys_mask);
 static const struct inode_operations cgroup_dir_inode_operations;
 static const struct file_operations proc_cgroupstats_operations;
 
@@ -957,13 +958,11 @@ static void cgroup_rm_file(struct cgroup *cgrp, const struct cftype *cft)
 }
 
 /**
- * cgroup_clear_dir - selective removal of base and subsystem files
+ * cgroup_clear_dir - remove subsys files in a cgroup directory
  * @cgrp: target cgroup
- * @base_files: true if the base files should be removed
  * @subsys_mask: mask of the subsystem ids whose files should be removed
  */
-static void cgroup_clear_dir(struct cgroup *cgrp, bool base_files,
-			     unsigned long subsys_mask)
+static void cgroup_clear_dir(struct cgroup *cgrp, unsigned long subsys_mask)
 {
 	struct cgroup_subsys *ss;
 
@@ -974,10 +973,6 @@ static void cgroup_clear_dir(struct cgroup *cgrp, bool base_files,
 		list_for_each_entry(set, &ss->cftsets, node)
 			cgroup_addrm_files(cgrp, NULL, set->cfts, false);
 	}
-	if (base_files) {
-		while (!list_empty(&cgrp->files))
-			cgroup_rm_file(cgrp, NULL);
-	}
 }
 
 /*
@@ -1372,17 +1367,17 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	 * this before rebind_subsystems, since rebind_subsystems may
 	 * change this hierarchy's subsys_list.
 	 */
-	cgroup_clear_dir(cgrp, false, removed_mask);
+	cgroup_clear_dir(cgrp, removed_mask);
 
 	ret = rebind_subsystems(root, added_mask, removed_mask);
 	if (ret) {
 		/* rebind_subsystems failed, re-populate the removed files */
-		cgroup_populate_dir(cgrp, false, removed_mask);
+		cgroup_populate_dir(cgrp, removed_mask);
 		goto out_unlock;
 	}
 
 	/* re-populate subsystem files */
-	cgroup_populate_dir(cgrp, false, added_mask);
+	cgroup_populate_dir(cgrp, added_mask);
 
 	if (opts.release_agent)
 		strcpy(root->release_agent_path, opts.release_agent);
@@ -1687,7 +1682,8 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		BUG_ON(root->number_of_cgroups != 1);
 
 		cred = override_creds(&init_cred);
-		cgroup_populate_dir(root_cgrp, true, root->subsys_mask);
+		cgroup_addrm_files(root_cgrp, NULL, cgroup_base_files, true);
+		cgroup_populate_dir(root_cgrp, root->subsys_mask);
 		revert_creds(cred);
 		mutex_unlock(&cgroup_root_mutex);
 		mutex_unlock(&cgroup_mutex);
@@ -4172,23 +4168,14 @@ static struct cftype cgroup_base_files[] = {
 };
 
 /**
- * cgroup_populate_dir - selectively creation of files in a directory
+ * cgroup_populate_dir - create subsys files in a cgroup directory
  * @cgrp: target cgroup
- * @base_files: true if the base files should be added
  * @subsys_mask: mask of the subsystem ids whose files should be added
  */
-static int cgroup_populate_dir(struct cgroup *cgrp, bool base_files,
-			       unsigned long subsys_mask)
+static int cgroup_populate_dir(struct cgroup *cgrp, unsigned long subsys_mask)
 {
-	int err;
 	struct cgroup_subsys *ss;
 
-	if (base_files) {
-		err = cgroup_addrm_files(cgrp, NULL, cgroup_base_files, true);
-		if (err < 0)
-			return err;
-	}
-
 	/* process cftsets of each subsystem */
 	for_each_root_subsys(cgrp->root, ss) {
 		struct cftype_set *set;
@@ -4410,7 +4397,11 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		}
 	}
 
-	err = cgroup_populate_dir(cgrp, true, root->subsys_mask);
+	err = cgroup_addrm_files(cgrp, NULL, cgroup_base_files, true);
+	if (err)
+		goto err_destroy;
+
+	err = cgroup_populate_dir(cgrp, root->subsys_mask);
 	if (err)
 		goto err_destroy;
 
@@ -4566,7 +4557,8 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	 * Clear and remove @cgrp directory.  The removal puts the base ref
 	 * but we aren't quite done with @cgrp yet, so hold onto it.
 	 */
-	cgroup_clear_dir(cgrp, true, cgrp->root->subsys_mask);
+	cgroup_clear_dir(cgrp, cgrp->root->subsys_mask);
+	cgroup_addrm_files(cgrp, NULL, cgroup_base_files, false);
 	dget(d);
 	cgroup_d_remove_dir(d);
 
-- 
1.8.3.1
