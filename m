From: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] kernfs: move the last knowledge of sysfs out from kernfs
Date: Thu, 17 Apr 2014 00:40:01 +0800
Message-ID: <1397666401-10427-1-git-send-email-nasa4836__32398.9808596254$1397666467$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

There is still one residue of sysfs remaining: the sb_magic
SYSFS_MAGIC. However this should be kernfs user specific,
so this patch moves it out. Kerrnfs user should specify their
magic number while mouting.

Signed-off-by: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/kernfs/mount.c      |  9 +++++----
 fs/sysfs/mount.c       |  4 +++-
 include/linux/kernfs.h | 10 ++++++----
 kernel/cgroup.c        |  4 +++-
 4 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/fs/kernfs/mount.c b/fs/kernfs/mount.c
index 6a5f04a..514d946 100644
--- a/fs/kernfs/mount.c
+++ b/fs/kernfs/mount.c
@@ -62,7 +62,7 @@ struct kernfs_root *kernfs_root_from_sb(struct super_block *sb)
 	return NULL;
 }
 
-static int kernfs_fill_super(struct super_block *sb)
+static int kernfs_fill_super(struct super_block *sb, void *data)
 {
 	struct kernfs_super_info *info = kernfs_info(sb);
 	struct inode *inode;
@@ -70,7 +70,7 @@ static int kernfs_fill_super(struct super_block *sb)
 
 	sb->s_blocksize = PAGE_CACHE_SIZE;
 	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
-	sb->s_magic = SYSFS_MAGIC;
+	sb->s_magic = (unsigned long)data;
 	sb->s_op = &kernfs_sops;
 	sb->s_time_gran = 1;
 
@@ -132,6 +132,7 @@ const void *kernfs_super_ns(struct super_block *sb)
  * @flags: mount flags specified for the mount
  * @root: kernfs_root of the hierarchy being mounted
  * @new_sb_created: tell the caller if we allocated a new superblock
+ * @private: any file system specifc private data
  * @ns: optional namespace tag of the mount
  *
  * This is to be called from each kernfs user's file_system_type->mount()
@@ -143,7 +144,7 @@ const void *kernfs_super_ns(struct super_block *sb)
  */
 struct dentry *kernfs_mount_ns(struct file_system_type *fs_type, int flags,
 			       struct kernfs_root *root, bool *new_sb_created,
-			       const void *ns)
+			       void *private, const void *ns)
 {
 	struct super_block *sb;
 	struct kernfs_super_info *info;
@@ -166,7 +167,7 @@ struct dentry *kernfs_mount_ns(struct file_system_type *fs_type, int flags,
 		*new_sb_created = !sb->s_root;
 
 	if (!sb->s_root) {
-		error = kernfs_fill_super(sb);
+		error = kernfs_fill_super(sb, private);
 		if (error) {
 			deactivate_locked_super(sb);
 			return ERR_PTR(error);
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index a66ad61..cdcbde2 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -13,6 +13,7 @@
 #define DEBUG
 
 #include <linux/fs.h>
+#include <linux/magic.h>
 #include <linux/mount.h>
 #include <linux/init.h>
 #include <linux/user_namespace.h>
@@ -38,7 +39,8 @@ static struct dentry *sysfs_mount(struct file_system_type *fs_type,
 	}
 
 	ns = kobj_ns_grab_current(KOBJ_NS_TYPE_NET);
-	root = kernfs_mount_ns(fs_type, flags, sysfs_root, &new_sb, ns);
+	root = kernfs_mount_ns(fs_type, flags, sysfs_root,
+				&new_sb, (void *)SYSFS_MAGIC, ns);
 	if (IS_ERR(root) || !new_sb)
 		kobj_ns_drop(KOBJ_NS_TYPE_NET, ns);
 	return root;
diff --git a/include/linux/kernfs.h b/include/linux/kernfs.h
index b0122dc..6bb5dd7 100644
--- a/include/linux/kernfs.h
+++ b/include/linux/kernfs.h
@@ -281,7 +281,7 @@ void kernfs_notify(struct kernfs_node *kn);
 const void *kernfs_super_ns(struct super_block *sb);
 struct dentry *kernfs_mount_ns(struct file_system_type *fs_type, int flags,
 			       struct kernfs_root *root, bool *new_sb_created,
-			       const void *ns);
+			       void *private, const void *ns);
 void kernfs_kill_sb(struct super_block *sb);
 
 void kernfs_init(void);
@@ -374,7 +374,8 @@ static inline const void *kernfs_super_ns(struct super_block *sb)
 
 static inline struct dentry *
 kernfs_mount_ns(struct file_system_type *fs_type, int flags,
-		struct kernfs_root *root, bool *new_sb_created, const void *ns)
+		struct kernfs_root *root, bool *new_sb_created,
+		void *private, const void *ns)
 { return ERR_PTR(-ENOSYS); }
 
 static inline void kernfs_kill_sb(struct super_block *sb) { }
@@ -432,9 +433,10 @@ static inline int kernfs_rename(struct kernfs_node *kn,
 
 static inline struct dentry *
 kernfs_mount(struct file_system_type *fs_type, int flags,
-	     struct kernfs_root *root, bool *new_sb_created)
+	     struct kernfs_root *root, bool *new_sb_created, void *private)
 {
-	return kernfs_mount_ns(fs_type, flags, root, new_sb_created, NULL);
+	return kernfs_mount_ns(fs_type, flags, root,
+				new_sb_created, private, NULL);
 }
 
 #endif	/* __LINUX_KERNFS_H */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 9fcdaa7..438ad2b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -33,6 +33,7 @@
 #include <linux/init_task.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
+#include <linux/magic.h>
 #include <linux/mm.h>
 #include <linux/mutex.h>
 #include <linux/mount.h>
@@ -1604,7 +1605,8 @@ out_unlock:
 	if (ret)
 		return ERR_PTR(ret);
 
-	dentry = kernfs_mount(fs_type, flags, root->kf_root, &new_sb);
+	dentry = kernfs_mount(fs_type, flags, root->kf_root,
+				(void *)CGROUP_SUPER_MAGIC, &new_sb);
 	if (IS_ERR(dentry) || !new_sb)
 		cgroup_put(&root->cgrp);
 	return dentry;
-- 
1.9.0.GIT
