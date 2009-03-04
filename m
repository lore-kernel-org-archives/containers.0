From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: show correct file mode, fix
Date: Wed, 04 Mar 2009 09:52:57 +0800
Message-ID: <49ADDEF9.7020308__14726.3407045559$1236131650$gmane$org@cn.fujitsu.com>
References: <49ACC037.2090507@cn.fujitsu.com>
	<20090303122733.af5ceea9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090303122733.af5ceea9.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

- 'mode' should have type mode_t
- use S_IRUGO/S_IWUSR instead of 0444/0200

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---

against cgroups-show-correct-file-mode.patch

---
 include/linux/cgroup.h |    2 +-
 kernel/cgroup.c        |   24 ++++++++++++------------
 kernel/cpuset.c        |    2 +-
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 31cc1a9..665fa70 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -262,7 +262,7 @@ struct cftype {
 	 * If not 0, file mode is set to this value, otherwise it will
 	 * be figured out automatically
 	 */
-	int mode;
+	mode_t mode;
 
 	/*
 	 * If non-zero, defines the maximum length of string that can
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 043b24e..ad10c5d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1686,7 +1686,7 @@ static struct inode_operations cgroup_dir_inode_operations = {
 	.rename = cgroup_rename,
 };
 
-static int cgroup_create_file(struct dentry *dentry, int mode,
+static int cgroup_create_file(struct dentry *dentry, mode_t mode,
 				struct super_block *sb)
 {
 	static struct dentry_operations cgroup_dops = {
@@ -1732,7 +1732,7 @@ static int cgroup_create_file(struct dentry *dentry, int mode,
  * @mode: mode to set on new directory.
  */
 static int cgroup_create_dir(struct cgroup *cgrp, struct dentry *dentry,
-				int mode)
+				mode_t mode)
 {
 	struct dentry *parent;
 	int error = 0;
@@ -1755,24 +1755,24 @@ static int cgroup_create_dir(struct cgroup *cgrp, struct dentry *dentry,
  * @cft: the control file in question
  *
  * returns cft->mode if ->mode is not 0
- * returns 0644 if it has both a read and a write handler
- * returns 0444 if it has only a read handler
- * returns 0200 if it has only a write hander
+ * returns S_IRUGO|S_IWUSR if it has both a read and a write handler
+ * returns S_IRUGO if it has only a read handler
+ * returns S_IWUSR if it has only a write hander
  */
-static int cgroup_file_mode(const struct cftype *cft)
+static mode_t cgroup_file_mode(const struct cftype *cft)
 {
-	int mode = 0;
+	mode_t mode = 0;
 
 	if (cft->mode)
 		return cft->mode;
 
 	if (cft->read || cft->read_u64 || cft->read_s64 ||
 	    cft->read_map || cft->read_seq_string)
-		mode |= 0444;
+		mode |= S_IRUGO;
 
 	if (cft->write || cft->write_u64 || cft->write_s64 ||
 	    cft->write_string || cft->trigger)
-		mode |= 0200;
+		mode |= S_IWUSR;
 
 	return mode;
 }
@@ -1784,7 +1784,7 @@ int cgroup_add_file(struct cgroup *cgrp,
 	struct dentry *dir = cgrp->dentry;
 	struct dentry *dentry;
 	int error;
-	int mode;
+	mode_t mode;
 
 	char name[MAX_CGROUP_TYPE_NAMELEN + MAX_CFTYPE_NAME + 2] = { 0 };
 	if (subsys && !test_bit(ROOT_NOPREFIX, &cgrp->root->flags)) {
@@ -2378,7 +2378,7 @@ static struct cftype files[] = {
 		.write_u64 = cgroup_tasks_write,
 		.release = cgroup_tasks_release,
 		.private = FILE_TASKLIST,
-		.mode = 0644,
+		.mode = S_IRUGO | S_IWUSR,
 	},
 
 	{
@@ -2479,7 +2479,7 @@ static void cgroup_unlock_hierarchy(struct cgroupfs_root *root)
  * Must be called with the mutex on the parent inode held
  */
 static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
-			     int mode)
+			     mode_t mode)
 {
 	struct cgroup *cgrp;
 	struct cgroupfs_root *root = parent->root;
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 31e28b3..0619f10 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1678,7 +1678,7 @@ static struct cftype files[] = {
 		.read_u64 = cpuset_read_u64,
 		.write_u64 = cpuset_write_u64,
 		.private = FILE_MEMORY_PRESSURE,
-		.mode = 0444,
+		.mode = S_IRUGO,
 	},
 
 	{
-- 
1.5.4.rc3
