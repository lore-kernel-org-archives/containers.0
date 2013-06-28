From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/9] cgroup: minor updates around cgroup_clear_directory()
Date: Fri, 28 Jun 2013 16:45:37 -0700
Message-ID: <1372463145-4245-2-git-send-email-tj__34794.293906498$1372463169$gmane$org@kernel.org>
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

* Rename it to cgroup_clear_dir() and make it take the pointer to the
  target cgroup instead of the the dentry.  This makes the function
  consistent with its counterpart - cgroup_populate_dir().

* Move cgroup_clear_directory() invocation from cgroup_d_remove_dir()
  to cgroup_remount() so that the function doesn't have to determine
  the cgroup pointer back from the dentry.  cgroup_d_remove_dir() now
  only deals with vfs, which is slightly cleaner.

This patch doesn't introduce any functional differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5a2fcf5..64877de 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -957,15 +957,14 @@ static void cgroup_rm_file(struct cgroup *cgrp, const struct cftype *cft)
 }
 
 /**
- * cgroup_clear_directory - selective removal of base and subsystem files
- * @dir: directory containing the files
+ * cgroup_clear_dir - selective removal of base and subsystem files
+ * @cgrp: target cgroup
  * @base_files: true if the base files should be removed
  * @subsys_mask: mask of the subsystem ids whose files should be removed
  */
-static void cgroup_clear_directory(struct dentry *dir, bool base_files,
-				   unsigned long subsys_mask)
+static void cgroup_clear_dir(struct cgroup *cgrp, bool base_files,
+			     unsigned long subsys_mask)
 {
-	struct cgroup *cgrp = __d_cgrp(dir);
 	struct cgroup_subsys *ss;
 
 	for_each_root_subsys(cgrp->root, ss) {
@@ -987,9 +986,6 @@ static void cgroup_clear_directory(struct dentry *dir, bool base_files,
 static void cgroup_d_remove_dir(struct dentry *dentry)
 {
 	struct dentry *parent;
-	struct cgroupfs_root *root = dentry->d_sb->s_fs_info;
-
-	cgroup_clear_directory(dentry, true, root->subsys_mask);
 
 	parent = dentry->d_parent;
 	spin_lock(&parent->d_lock);
@@ -1376,7 +1372,7 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	 * this before rebind_subsystems, since rebind_subsystems may
 	 * change this hierarchy's subsys_list.
 	 */
-	cgroup_clear_directory(cgrp->dentry, false, removed_mask);
+	cgroup_clear_dir(cgrp, false, removed_mask);
 
 	ret = rebind_subsystems(root, added_mask, removed_mask);
 	if (ret) {
@@ -4541,9 +4537,10 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	raw_spin_unlock(&release_list_lock);
 
 	/*
-	 * Remove @cgrp directory.  The removal puts the base ref but we
-	 * aren't quite done with @cgrp yet, so hold onto it.
+	 * Clear and remove @cgrp directory.  The removal puts the base ref
+	 * but we aren't quite done with @cgrp yet, so hold onto it.
 	 */
+	cgroup_clear_dir(cgrp, true, cgrp->root->subsys_mask);
 	dget(d);
 	cgroup_d_remove_dir(d);
 
-- 
1.8.3.1
