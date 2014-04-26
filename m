From: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] kernfs: move the last knowledge of sysfs out from kernfs
Date: Sat, 26 Apr 2014 15:40:28 +0800
Message-ID: <1398498028-19127-1-git-send-email-nasa4836@gmail.com>
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

Hi, Greg,

>This doesn't apply to my tree, can you please redo it against
>the driver-core-next branch and resend?

I've reworked it on top of driver-core-next.

Thanks!

------<8------

There is still one residue of sysfs remaining: the sb_magic
SYSFS_MAGIC. However this should be kernfs user specific,
so this patch moves it out. Kerrnfs user should specify their
magic number while mouting.

Signed-off-by: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 fs/kernfs/mount.c      | 11 ++++++-----
 fs/sysfs/mount.c       |  4 +++-
 include/linux/kernfs.h | 13 ++++++++-----
 kernel/cgroup.c        |  4 +++-
 4 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/fs/kernfs/mount.c b/fs/kernfs/mount.c
index f25a7c0..d171b98 100644
--- a/fs/kernfs/mount.c
+++ b/fs/kernfs/mount.c
@@ -62,7 +62,7 @@ struct kernfs_root *kernfs_root_from_sb(struct super_block *sb)
 	return NULL;
 }
 
-static int kernfs_fill_super(struct super_block *sb)
+static int kernfs_fill_super(struct super_block *sb, unsigned long magic)
 {
 	struct kernfs_super_info *info = kernfs_info(sb);
 	struct inode *inode;
@@ -71,7 +71,7 @@ static int kernfs_fill_super(struct super_block *sb)
 	info->sb = sb;
 	sb->s_blocksize = PAGE_CACHE_SIZE;
 	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
-	sb->s_magic = SYSFS_MAGIC;
+	sb->s_magic = magic;
 	sb->s_op = &kernfs_sops;
 	sb->s_time_gran = 1;
 
@@ -132,6 +132,7 @@ const void *kernfs_super_ns(struct super_block *sb)
  * @fs_type: file_system_type of the fs being mounted
  * @flags: mount flags specified for the mount
  * @root: kernfs_root of the hierarchy being mounted
+ * @magic: file system specific magic number
  * @new_sb_created: tell the caller if we allocated a new superblock
  * @ns: optional namespace tag of the mount
  *
@@ -143,8 +144,8 @@ const void *kernfs_super_ns(struct super_block *sb)
  * The return value can be passed to the vfs layer verbatim.
  */
 struct dentry *kernfs_mount_ns(struct file_system_type *fs_type, int flags,
-			       struct kernfs_root *root, bool *new_sb_created,
-			       const void *ns)
+				struct kernfs_root *root, unsigned long magic,
+				bool *new_sb_created, const void *ns)
 {
 	struct super_block *sb;
 	struct kernfs_super_info *info;
@@ -169,7 +170,7 @@ struct dentry *kernfs_mount_ns(struct file_system_type *fs_type, int flags,
 	if (!sb->s_root) {
 		struct kernfs_super_info *info = kernfs_info(sb);
 
-		error = kernfs_fill_super(sb);
+		error = kernfs_fill_super(sb, magic);
 		if (error) {
 			deactivate_locked_super(sb);
 			return ERR_PTR(error);
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index a66ad61..024134e 100644
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
+				SYSFS_MAGIC, &new_sb, ns);
 	if (IS_ERR(root) || !new_sb)
 		kobj_ns_drop(KOBJ_NS_TYPE_NET, ns);
 	return root;
diff --git a/include/linux/kernfs.h b/include/linux/kernfs.h
index 589318b..5f4ebeb 100644
--- a/include/linux/kernfs.h
+++ b/include/linux/kernfs.h
@@ -284,8 +284,8 @@ void kernfs_notify(struct kernfs_node *kn);
 
 const void *kernfs_super_ns(struct super_block *sb);
 struct dentry *kernfs_mount_ns(struct file_system_type *fs_type, int flags,
-			       struct kernfs_root *root, bool *new_sb_created,
-			       const void *ns);
+			       struct kernfs_root *root, unsigned long magic,
+			       bool *new_sb_created, const void *ns);
 void kernfs_kill_sb(struct super_block *sb);
 
 void kernfs_init(void);
@@ -378,7 +378,8 @@ static inline const void *kernfs_super_ns(struct super_block *sb)
 
 static inline struct dentry *
 kernfs_mount_ns(struct file_system_type *fs_type, int flags,
-		struct kernfs_root *root, bool *new_sb_created, const void *ns)
+		struct kernfs_root *root, unsigned long magic,
+		bool *new_sb_created, const void *ns)
 { return ERR_PTR(-ENOSYS); }
 
 static inline void kernfs_kill_sb(struct super_block *sb) { }
@@ -436,9 +437,11 @@ static inline int kernfs_rename(struct kernfs_node *kn,
 
 static inline struct dentry *
 kernfs_mount(struct file_system_type *fs_type, int flags,
-	     struct kernfs_root *root, bool *new_sb_created)
+		struct kernfs_root *root, unsigned long magic,
+		bool *new_sb_created)
 {
-	return kernfs_mount_ns(fs_type, flags, root, new_sb_created, NULL);
+	return kernfs_mount_ns(fs_type, flags, root,
+				magic, new_sb_created, NULL);
 }
 
 #endif	/* __LINUX_KERNFS_H */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 9fcdaa7..ab5a995 100644
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
+				CGROUP_SUPER_MAGIC, &new_sb);
 	if (IS_ERR(dentry) || !new_sb)
 		cgroup_put(&root->cgrp);
 	return dentry;
-- 
2.0.0-rc0
