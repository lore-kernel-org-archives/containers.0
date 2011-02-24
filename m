From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 10/10] rename is_owner_or_cap to inode_owner_or_capable
Date: Thu, 24 Feb 2011 15:03:37 +0000
Message-ID: <20110224150337.GJ8262__16434.0300522328$1298560539$gmane$org@mail.hallyn.com>
References: <20110224150150.GA8262@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110224150150.GA8262-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dlezcano-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, oleg-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

And give it a kernel-doc comment.

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 fs/9p/acl.c              |    2 +-
 fs/attr.c                |    4 ++--
 fs/btrfs/acl.c           |    2 +-
 fs/btrfs/ioctl.c         |    2 +-
 fs/ext2/acl.c            |    2 +-
 fs/ext2/ioctl.c          |    6 +++---
 fs/ext3/acl.c            |    2 +-
 fs/ext3/ioctl.c          |    6 +++---
 fs/ext4/acl.c            |    2 +-
 fs/ext4/ioctl.c          |    8 ++++----
 fs/fcntl.c               |    2 +-
 fs/generic_acl.c         |    2 +-
 fs/gfs2/file.c           |    2 +-
 fs/hfsplus/ioctl.c       |    2 +-
 fs/inode.c               |   13 ++++++++-----
 fs/jffs2/acl.c           |    2 +-
 fs/jfs/ioctl.c           |    2 +-
 fs/jfs/xattr.c           |    2 +-
 fs/logfs/file.c          |    2 +-
 fs/namei.c               |    2 +-
 fs/ocfs2/acl.c           |    2 +-
 fs/ocfs2/ioctl.c         |    2 +-
 fs/reiserfs/ioctl.c      |    4 ++--
 fs/reiserfs/xattr_acl.c  |    2 +-
 fs/ubifs/ioctl.c         |    2 +-
 fs/utimes.c              |    2 +-
 fs/xattr.c               |    2 +-
 include/linux/fs.h       |    2 +-
 security/selinux/hooks.c |    2 +-
 29 files changed, 45 insertions(+), 42 deletions(-)

diff --git a/fs/9p/acl.c b/fs/9p/acl.c
index 02a2cf6..35243c0 100644
--- a/fs/9p/acl.c
+++ b/fs/9p/acl.c
@@ -315,7 +315,7 @@ static int v9fs_xattr_set_acl(struct dentry *dentry, const char *name,
 
 	if (S_ISLNK(inode->i_mode))
 		return -EOPNOTSUPP;
-	if (!is_owner_or_cap(inode))
+	if (!inode_owner_or_capable(inode))
 		return -EPERM;
 	if (value) {
 		/* update the cached acl value */
diff --git a/fs/attr.c b/fs/attr.c
index 7ca4181..1007ed6 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -59,7 +59,7 @@ int inode_change_ok(const struct inode *inode, struct iattr *attr)
 
 	/* Make sure a caller can chmod. */
 	if (ia_valid & ATTR_MODE) {
-		if (!is_owner_or_cap(inode))
+		if (!inode_owner_or_capable(inode))
 			return -EPERM;
 		/* Also check the setgid bit! */
 		if (!in_group_p((ia_valid & ATTR_GID) ? attr->ia_gid :
@@ -69,7 +69,7 @@ int inode_change_ok(const struct inode *inode, struct iattr *attr)
 
 	/* Check for setting the inode time. */
 	if (ia_valid & (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)) {
-		if (!is_owner_or_cap(inode))
+		if (!inode_owner_or_capable(inode))
 			return -EPERM;
 	}
 
diff --git a/fs/btrfs/acl.c b/fs/btrfs/acl.c
index 9c94934..de34bfa 100644
--- a/fs/btrfs/acl.c
+++ b/fs/btrfs/acl.c
@@ -170,7 +170,7 @@ static int btrfs_xattr_acl_set(struct dentry *dentry, const char *name,
 	int ret;
 	struct posix_acl *acl = NULL;
 
-	if (!is_owner_or_cap(dentry->d_inode))
+	if (!inode_owner_or_capable(dentry->d_inode))
 		return -EPERM;
 
 	if (!IS_POSIXACL(dentry->d_inode))
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index be2d4f6..bf683ef 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -158,7 +158,7 @@ static int btrfs_ioctl_setflags(struct file *file, void __user *arg)
 		      FS_SYNC_FL | FS_DIRSYNC_FL))
 		return -EOPNOTSUPP;
 
-	if (!is_owner_or_cap(inode))
+	if (!inode_owner_or_capable(inode))
 		return -EACCES;
 
 	mutex_lock(&inode->i_mutex);
diff --git a/fs/ext2/acl.c b/fs/ext2/acl.c
index 7b41805..abea5a1 100644
--- a/fs/ext2/acl.c
+++ b/fs/ext2/acl.c
@@ -406,7 +406,7 @@ ext2_xattr_set_acl(struct dentry *dentry, const char *name, const void *value,
 		return -EINVAL;
 	if (!test_opt(dentry->d_sb, POSIX_ACL))
 		return -EOPNOTSUPP;
-	if (!is_owner_or_cap(dentry->d_inode))
+	if (!inode_owner_or_capable(dentry->d_inode))
 		return -EPERM;
 
 	if (value) {
diff --git a/fs/ext2/ioctl.c b/fs/ext2/ioctl.c
index e743130..f81e250 100644
--- a/fs/ext2/ioctl.c
+++ b/fs/ext2/ioctl.c
@@ -39,7 +39,7 @@ long ext2_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 		if (ret)
 			return ret;
 
-		if (!is_owner_or_cap(inode)) {
+		if (!inode_owner_or_capable(inode)) {
 			ret = -EACCES;
 			goto setflags_out;
 		}
@@ -89,7 +89,7 @@ setflags_out:
 	case EXT2_IOC_GETVERSION:
 		return put_user(inode->i_generation, (int __user *) arg);
 	case EXT2_IOC_SETVERSION:
-		if (!is_owner_or_cap(inode))
+		if (!inode_owner_or_capable(inode))
 			return -EPERM;
 		ret = mnt_want_write(filp->f_path.mnt);
 		if (ret)
@@ -115,7 +115,7 @@ setflags_out:
 		if (!test_opt(inode->i_sb, RESERVATION) ||!S_ISREG(inode->i_mode))
 			return -ENOTTY;
 
-		if (!is_owner_or_cap(inode))
+		if (!inode_owner_or_capable(inode))
 			return -EACCES;
 
 		if (get_user(rsv_window_size, (int __user *)arg))
diff --git a/fs/ext3/acl.c b/fs/ext3/acl.c
index e4fa49e..9d021c0 100644
--- a/fs/ext3/acl.c
+++ b/fs/ext3/acl.c
@@ -435,7 +435,7 @@ ext3_xattr_set_acl(struct dentry *dentry, const char *name, const void *value,
 		return -EINVAL;
 	if (!test_opt(inode->i_sb, POSIX_ACL))
 		return -EOPNOTSUPP;
-	if (!is_owner_or_cap(inode))
+	if (!inode_owner_or_capable(inode))
 		return -EPERM;
 
 	if (value) {
diff --git a/fs/ext3/ioctl.c b/fs/ext3/ioctl.c
index fc080dd..f4090bd 100644
--- a/fs/ext3/ioctl.c
+++ b/fs/ext3/ioctl.c
@@ -38,7 +38,7 @@ long ext3_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 		unsigned int oldflags;
 		unsigned int jflag;
 
-		if (!is_owner_or_cap(inode))
+		if (!inode_owner_or_capable(inode))
 			return -EACCES;
 
 		if (get_user(flags, (int __user *) arg))
@@ -123,7 +123,7 @@ flags_out:
 		__u32 generation;
 		int err;
 
-		if (!is_owner_or_cap(inode))
+		if (!inode_owner_or_capable(inode))
 			return -EPERM;
 
 		err = mnt_want_write(filp->f_path.mnt);
@@ -192,7 +192,7 @@ setversion_out:
 		if (err)
 			return err;
 
-		if (!is_owner_or_cap(inode)) {
+		if (!inode_owner_or_capable(inode)) {
 			err = -EACCES;
 			goto setrsvsz_out;
 		}
diff --git a/fs/ext4/acl.c b/fs/ext4/acl.c
index e0270d1..21eacd7 100644
--- a/fs/ext4/acl.c
+++ b/fs/ext4/acl.c
@@ -433,7 +433,7 @@ ext4_xattr_set_acl(struct dentry *dentry, const char *name, const void *value,
 		return -EINVAL;
 	if (!test_opt(inode->i_sb, POSIX_ACL))
 		return -EOPNOTSUPP;
-	if (!is_owner_or_cap(inode))
+	if (!inode_owner_or_capable(inode))
 		return -EPERM;
 
 	if (value) {
diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index eb3bc2f..a84faa1 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -38,7 +38,7 @@ long ext4_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 		unsigned int oldflags;
 		unsigned int jflag;
 
-		if (!is_owner_or_cap(inode))
+		if (!inode_owner_or_capable(inode))
 			return -EACCES;
 
 		if (get_user(flags, (int __user *) arg))
@@ -146,7 +146,7 @@ flags_out:
 		__u32 generation;
 		int err;
 
-		if (!is_owner_or_cap(inode))
+		if (!inode_owner_or_capable(inode))
 			return -EPERM;
 
 		err = mnt_want_write(filp->f_path.mnt);
@@ -298,7 +298,7 @@ mext_out:
 	case EXT4_IOC_MIGRATE:
 	{
 		int err;
-		if (!is_owner_or_cap(inode))
+		if (!inode_owner_or_capable(inode))
 			return -EACCES;
 
 		err = mnt_want_write(filp->f_path.mnt);
@@ -320,7 +320,7 @@ mext_out:
 	case EXT4_IOC_ALLOC_DA_BLKS:
 	{
 		int err;
-		if (!is_owner_or_cap(inode))
+		if (!inode_owner_or_capable(inode))
 			return -EACCES;
 
 		err = mnt_want_write(filp->f_path.mnt);
diff --git a/fs/fcntl.c b/fs/fcntl.c
index cb10261..8ff9afa 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -159,7 +159,7 @@ static int setfl(int fd, struct file * filp, unsigned long arg)
 
 	/* O_NOATIME can only be set by the owner or superuser */
 	if ((arg & O_NOATIME) && !(filp->f_flags & O_NOATIME))
-		if (!is_owner_or_cap(inode))
+		if (!inode_owner_or_capable(inode))
 			return -EPERM;
 
 	/* required for strict SunOS emulation */
diff --git a/fs/generic_acl.c b/fs/generic_acl.c
index 06c48a8..8f26d1a 100644
--- a/fs/generic_acl.c
+++ b/fs/generic_acl.c
@@ -74,7 +74,7 @@ generic_acl_set(struct dentry *dentry, const char *name, const void *value,
 		return -EINVAL;
 	if (S_ISLNK(inode->i_mode))
 		return -EOPNOTSUPP;
-	if (!is_owner_or_cap(inode))
+	if (!inode_owner_or_capable(inode))
 		return -EPERM;
 	if (value) {
 		acl = posix_acl_from_xattr(value, size);
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index 7cfdcb9..ccbcd1c 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -221,7 +221,7 @@ static int do_gfs2_set_flags(struct file *filp, u32 reqflags, u32 mask)
 		goto out_drop_write;
 
 	error = -EACCES;
-	if (!is_owner_or_cap(inode))
+	if (!inode_owner_or_capable(inode))
 		goto out;
 
 	error = 0;
diff --git a/fs/hfsplus/ioctl.c b/fs/hfsplus/ioctl.c
index 508ce66..fbaa669 100644
--- a/fs/hfsplus/ioctl.c
+++ b/fs/hfsplus/ioctl.c
@@ -47,7 +47,7 @@ static int hfsplus_ioctl_setflags(struct file *file, int __user *user_flags)
 	if (err)
 		goto out;
 
-	if (!is_owner_or_cap(inode)) {
+	if (!inode_owner_or_capable(inode)) {
 		err = -EACCES;
 		goto out_drop_write;
 	}
diff --git a/fs/inode.c b/fs/inode.c
index f5ac235..c200e7a 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1724,11 +1724,14 @@ void inode_init_owner(struct inode *inode, const struct inode *dir,
 }
 EXPORT_SYMBOL(inode_init_owner);
 
-/*
- * return true if current either has CAP_FOWNER to the
- * file, or owns the file.
+/**
+ * inode_owner_or_capable - check current task permissions to inode
+ * @inode: inode being checked
+ *
+ * Return true if current either has CAP_FOWNER to the inode, or
+ * owns the file.
  */
-bool is_owner_or_cap(const struct inode *inode)
+bool inode_owner_or_capable(const struct inode *inode)
 {
 	struct user_namespace *ns = inode_userns(inode);
 
@@ -1738,4 +1741,4 @@ bool is_owner_or_cap(const struct inode *inode)
 		return true;
 	return false;
 }
-EXPORT_SYMBOL(is_owner_or_cap);
+EXPORT_SYMBOL(inode_owner_or_capable);
diff --git a/fs/jffs2/acl.c b/fs/jffs2/acl.c
index 95b7967..828a0e1 100644
--- a/fs/jffs2/acl.c
+++ b/fs/jffs2/acl.c
@@ -402,7 +402,7 @@ static int jffs2_acl_setxattr(struct dentry *dentry, const char *name,
 
 	if (name[0] != '\0')
 		return -EINVAL;
-	if (!is_owner_or_cap(dentry->d_inode))
+	if (!inode_owner_or_capable(dentry->d_inode))
 		return -EPERM;
 
 	if (value) {
diff --git a/fs/jfs/ioctl.c b/fs/jfs/ioctl.c
index afe222b..6f98a18 100644
--- a/fs/jfs/ioctl.c
+++ b/fs/jfs/ioctl.c
@@ -72,7 +72,7 @@ long jfs_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 		if (err)
 			return err;
 
-		if (!is_owner_or_cap(inode)) {
+		if (!inode_owner_or_capable(inode)) {
 			err = -EACCES;
 			goto setflags_out;
 		}
diff --git a/fs/jfs/xattr.c b/fs/jfs/xattr.c
index 2d7f165..6c0d276 100644
--- a/fs/jfs/xattr.c
+++ b/fs/jfs/xattr.c
@@ -678,7 +678,7 @@ static int can_set_system_xattr(struct inode *inode, const char *name,
 	struct posix_acl *acl;
 	int rc;
 
-	if (!is_owner_or_cap(inode))
+	if (!inode_owner_or_capable(inode))
 		return -EPERM;
 
 	/*
diff --git a/fs/logfs/file.c b/fs/logfs/file.c
index e86376b..c2ad702 100644
--- a/fs/logfs/file.c
+++ b/fs/logfs/file.c
@@ -196,7 +196,7 @@ long logfs_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (IS_RDONLY(inode))
 			return -EROFS;
 
-		if (!is_owner_or_cap(inode))
+		if (!inode_owner_or_capable(inode))
 			return -EACCES;
 
 		err = get_user(flags, (int __user *)arg);
diff --git a/fs/namei.c b/fs/namei.c
index cfac5b4..8da5a59 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2129,7 +2129,7 @@ int may_open(struct path *path, int acc_mode, int flag)
 	}
 
 	/* O_NOATIME can only be set by the owner or superuser */
-	if (flag & O_NOATIME && !is_owner_or_cap(inode))
+	if (flag & O_NOATIME && !inode_owner_or_capable(inode))
 		return -EPERM;
 
 	/*
diff --git a/fs/ocfs2/acl.c b/fs/ocfs2/acl.c
index 704f6b1..90f2729 100644
--- a/fs/ocfs2/acl.c
+++ b/fs/ocfs2/acl.c
@@ -497,7 +497,7 @@ static int ocfs2_xattr_set_acl(struct dentry *dentry, const char *name,
 	if (!(osb->s_mount_opt & OCFS2_MOUNT_POSIX_ACL))
 		return -EOPNOTSUPP;
 
-	if (!is_owner_or_cap(inode))
+	if (!inode_owner_or_capable(inode))
 		return -EPERM;
 
 	if (value) {
diff --git a/fs/ocfs2/ioctl.c b/fs/ocfs2/ioctl.c
index 7a48681..09de77c 100644
--- a/fs/ocfs2/ioctl.c
+++ b/fs/ocfs2/ioctl.c
@@ -82,7 +82,7 @@ static int ocfs2_set_inode_attr(struct inode *inode, unsigned flags,
 	}
 
 	status = -EACCES;
-	if (!is_owner_or_cap(inode))
+	if (!inode_owner_or_capable(inode))
 		goto bail_unlock;
 
 	if (!S_ISDIR(inode->i_mode))
diff --git a/fs/reiserfs/ioctl.c b/fs/reiserfs/ioctl.c
index 79265fd..4e15305 100644
--- a/fs/reiserfs/ioctl.c
+++ b/fs/reiserfs/ioctl.c
@@ -59,7 +59,7 @@ long reiserfs_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 			if (err)
 				break;
 
-			if (!is_owner_or_cap(inode)) {
+			if (!inode_owner_or_capable(inode)) {
 				err = -EPERM;
 				goto setflags_out;
 			}
@@ -103,7 +103,7 @@ setflags_out:
 		err = put_user(inode->i_generation, (int __user *)arg);
 		break;
 	case REISERFS_IOC_SETVERSION:
-		if (!is_owner_or_cap(inode)) {
+		if (!inode_owner_or_capable(inode)) {
 			err = -EPERM;
 			break;
 		}
diff --git a/fs/reiserfs/xattr_acl.c b/fs/reiserfs/xattr_acl.c
index 90d2fcb..3dc38f1 100644
--- a/fs/reiserfs/xattr_acl.c
+++ b/fs/reiserfs/xattr_acl.c
@@ -26,7 +26,7 @@ posix_acl_set(struct dentry *dentry, const char *name, const void *value,
 	size_t jcreate_blocks;
 	if (!reiserfs_posixacl(inode->i_sb))
 		return -EOPNOTSUPP;
-	if (!is_owner_or_cap(inode))
+	if (!inode_owner_or_capable(inode))
 		return -EPERM;
 
 	if (value) {
diff --git a/fs/ubifs/ioctl.c b/fs/ubifs/ioctl.c
index 8aacd64..548acf4 100644
--- a/fs/ubifs/ioctl.c
+++ b/fs/ubifs/ioctl.c
@@ -160,7 +160,7 @@ long ubifs_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (IS_RDONLY(inode))
 			return -EROFS;
 
-		if (!is_owner_or_cap(inode))
+		if (!inode_owner_or_capable(inode))
 			return -EACCES;
 
 		if (get_user(flags, (int __user *) arg))
diff --git a/fs/utimes.c b/fs/utimes.c
index 179b586..ba653f3 100644
--- a/fs/utimes.c
+++ b/fs/utimes.c
@@ -95,7 +95,7 @@ static int utimes_common(struct path *path, struct timespec *times)
                 if (IS_IMMUTABLE(inode))
 			goto mnt_drop_write_and_out;
 
-		if (!is_owner_or_cap(inode)) {
+		if (!inode_owner_or_capable(inode)) {
 			error = inode_permission(inode, MAY_WRITE);
 			if (error)
 				goto mnt_drop_write_and_out;
diff --git a/fs/xattr.c b/fs/xattr.c
index 01bb813..a19acdb 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -59,7 +59,7 @@ xattr_permission(struct inode *inode, const char *name, int mask)
 		if (!S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
 			return -EPERM;
 		if (S_ISDIR(inode->i_mode) && (inode->i_mode & S_ISVTX) &&
-		    (mask & MAY_WRITE) && !is_owner_or_cap(inode))
+		    (mask & MAY_WRITE) && !inode_owner_or_capable(inode))
 			return -EPERM;
 	}
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index eb1ddde..40e05c7 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1452,7 +1452,7 @@ enum {
  */
 extern struct user_namespace init_user_ns;
 #define inode_userns(inode) (&init_user_ns)
-extern bool is_owner_or_cap(const struct inode *inode);
+extern bool inode_owner_or_capable(const struct inode *inode);
 
 /* not quite ready to be deprecated, but... */
 extern void lock_super(struct super_block *);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 6dcda48..433236f 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2721,7 +2721,7 @@ static int selinux_inode_setxattr(struct dentry *dentry, const char *name,
 	if (!(sbsec->flags & SE_SBLABELSUPP))
 		return -EOPNOTSUPP;
 
-	if (!is_owner_or_cap(inode))
+	if (!inode_owner_or_capable(inode))
 		return -EPERM;
 
 	COMMON_AUDIT_DATA_INIT(&ad, FS);
-- 
1.7.0.4
