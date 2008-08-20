From: <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: patch sysfs-support-for-preventing-unmounts.patch added to gregkh-2.6
	tree
Date: Tue, 19 Aug 2008 19:16:28 -0700
Message-ID: <12191985882234@kroah.org>
References: <m1prpuihjb.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1prpuihjb.fsf_-_-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org, htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


This is a note to let you know that I've just added the patch titled

    Subject: sysfs: Support for preventing unmounts.

to my gregkh-2.6 tree.  Its filename is

    sysfs-support-for-preventing-unmounts.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


From ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org Thu Jul  3 18:11:50 2008
From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Date: Thu, 03 Jul 2008 18:07:04 -0700
Subject: sysfs: Support for preventing unmounts.
To: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Message-ID: <m1prpuihjb.fsf_-_-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

To support mounting multiple instances of sysfs occassionally I
need to walk through all of the currently present sysfs super blocks.

To allow this iteration this patch adds sysfs_grab_supers
and sysfs_release_supers.  While a piece of code is in
a section surrounded by these no more sysfs super blocks
will be either created or destroyed.

So the fundamentals.
- The data in sysfs fundamentally changes behind the back of the
  VFS and we need to keep the VFS in sync.  Essentially this is the
  distributed filesystem problem.

- In particular for sysfs_rename and sysfs_move_dir we need to support finding
  the dcache entries and calling d_move.  So that the dcache does not
  get into an inconsistent state.  Timeouts and invalidates like NFS
  uses are to be  avoided if at all possible.

- Coming through the vfs we are guaranteed that the filesystem will
  not be unmounted while we have a reference on a dentry, and with
  multiple mounts we do not get that guarantee.  Therefore to get that
  guarantee for all of the superblocks we need the blunt instrument.

- Since mount/unmount are rare blocking them is no big deal.

I believe any distributed filesystem that is together enough to tell
us about renames (so we can update the dcache) instead of doing the
NFS timeout will need the ability to block mount/unmount while it is
executing d_move.

Currently sysfs does not need to block mounts only because we perform
an internal mount and then never unmount sysfs.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Acked-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

---
 fs/sysfs/mount.c |   79 +++++++++++++++++++++++++++++++++++++++++++++++++------
 fs/sysfs/sysfs.h |   10 ++++++
 2 files changed, 81 insertions(+), 8 deletions(-)

--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -42,47 +42,110 @@ struct sysfs_dirent sysfs_root = {
 
 static int sysfs_fill_super(struct super_block *sb, void *data, int silent)
 {
-	struct inode *inode;
-	struct dentry *root;
+	struct sysfs_super_info *info = NULL;
+	struct inode *inode = NULL;
+	struct dentry *root = NULL;
+	int error;
 
 	sb->s_blocksize = PAGE_CACHE_SIZE;
 	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
 	sb->s_magic = SYSFS_MAGIC;
 	sb->s_op = &sysfs_ops;
 	sb->s_time_gran = 1;
-	sysfs_sb = sb;
+	if (!sysfs_sb)
+		sysfs_sb = sb;
+
+	error = -ENOMEM;
+	info = kzalloc(sizeof(*info), GFP_KERNEL);
+	if (!info)
+		goto out_err;
 
 	/* get root inode, initialize and unlock it */
+	error = -ENOMEM;
 	inode = sysfs_get_inode(&sysfs_root);
 	if (!inode) {
 		pr_debug("sysfs: could not get root inode\n");
-		return -ENOMEM;
+		goto out_err;
 	}
 
 	/* instantiate and link root dentry */
+	error = -ENOMEM;
 	root = d_alloc_root(inode);
 	if (!root) {
 		pr_debug("%s: could not get root dentry!\n",__func__);
-		iput(inode);
-		return -ENOMEM;
+		goto out_err;
 	}
 	root->d_fsdata = &sysfs_root;
 	sb->s_root = root;
+	sb->s_fs_info = info;
 	return 0;
+
+out_err:
+	dput(root);
+	iput(inode);
+	kfree(info);
+	if (sysfs_sb == sb)
+		sysfs_sb = NULL;
+	return error;
 }
 
 static int sysfs_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
 {
-	return get_sb_single(fs_type, flags, data, sysfs_fill_super, mnt);
+	int rc;
+	mutex_lock(&sysfs_rename_mutex);
+	rc = get_sb_single(fs_type, flags, data, sysfs_fill_super, mnt);
+	mutex_unlock(&sysfs_rename_mutex);
+	return rc;
 }
 
-static struct file_system_type sysfs_fs_type = {
+struct file_system_type sysfs_fs_type = {
 	.name		= "sysfs",
 	.get_sb		= sysfs_get_sb,
 	.kill_sb	= kill_anon_super,
 };
 
+void sysfs_grab_supers(void)
+{
+	/* must hold sysfs_rename_mutex */
+	struct super_block *sb;
+	/* Loop until I have taken s_umount on all sysfs superblocks */
+restart:
+	spin_lock(&sb_lock);
+	list_for_each_entry(sb, &sysfs_fs_type.fs_supers, s_instances) {
+		if (sysfs_info(sb)->grabbed)
+			continue;
+		/* Wait for unmount activity to complete. */
+		if (sb->s_count < S_BIAS) {
+			sb->s_count += 1;
+			spin_unlock(&sb_lock);
+			down_read(&sb->s_umount);
+			drop_super(sb);
+			goto restart;
+		}
+		atomic_inc(&sb->s_active);
+		sysfs_info(sb)->grabbed = 1;
+	}
+	spin_unlock(&sb_lock);
+}
+
+void sysfs_release_supers(void)
+{
+	/* must hold sysfs_rename_mutex */
+	struct super_block *sb;
+restart:
+	spin_lock(&sb_lock);
+	list_for_each_entry(sb, &sysfs_fs_type.fs_supers, s_instances) {
+		if (!sysfs_info(sb)->grabbed)
+			continue;
+		sysfs_info(sb)->grabbed = 0;
+		spin_unlock(&sb_lock);
+		deactivate_super(sb);
+		goto restart;
+	}
+	spin_unlock(&sb_lock);
+}
+
 int __init sysfs_init(void)
 {
 	int err = -ENOMEM;
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -85,12 +85,22 @@ struct sysfs_addrm_cxt {
 	int			cnt;
 };
 
+struct sysfs_super_info {
+	int	grabbed;
+};
+
+#define sysfs_info(SB) ((struct sysfs_super_info *)(SB)->s_fs_info)
+
 /*
  * mount.c
  */
 extern struct sysfs_dirent sysfs_root;
 extern struct super_block *sysfs_sb;
 extern struct kmem_cache *sysfs_dir_cachep;
+extern struct file_system_type sysfs_fs_type;
+
+void sysfs_grab_supers(void);
+void sysfs_release_supers(void);
 
 /*
  * dir.c


Patches currently in gregkh-2.6 which might be from ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org are

driver-core/kobject-fix-kobject_rename-and-config_sysfs.patch
driver-core/kobject-cleanup-kobject_rename-and-config_sysfs.patch
driver-core/sysfs-implement-__sysfs_get_dentry.patch
driver-core/sysfs-introduce-sysfs_sd_setattr-and-fix-sysfs_chmod.patch
driver-core/sysfs-sysfs_get_dentry-add-a-sb-parameter.patch
driver-core/sysfs-rename-support-multiple-superblocks.patch
driver-core/sysfs-support-for-preventing-unmounts.patch
driver-core/sysfs-sysfs_chmod_file-handle-multiple-superblocks.patch
