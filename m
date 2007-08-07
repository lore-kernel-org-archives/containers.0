From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 16/25] sysfs: Support for preventing unmounts.
Date: Tue, 07 Aug 2007 15:26:28 -0600
Message-ID: <m18x8nhw8r.fsf_-_@ebiederm.dsl.xmission.com>
References: <11860582832964-git-send-email-htejun@gmail.com>
	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>
	<m11wefkq88.fsf_-_@ebiederm.dsl.xmission.com>
	<m1wsw7jbml.fsf_-_@ebiederm.dsl.xmission.com>
	<m1sl6vjbjw.fsf_-_@ebiederm.dsl.xmission.com>
	<m1odhjjbij.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5s7jbh9.fsf_-_@ebiederm.dsl.xmission.com>
	<m1fy2vjbf9.fsf_-_@ebiederm.dsl.xmission.com>
	<m1bqdjjbcf.fsf_-_@ebiederm.dsl.xmission.com>
	<m17io7jba4.fsf_-_@ebiederm.dsl.xmission.com>
	<m13ayvjb82.fsf_-_@ebiederm.dsl.xmission.com>
	<m1y7gnhwm4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com>
	<m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com>
	<m1d4xzhwb2.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1d4xzhwb2.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Tue, 07 Aug 2007 15:25:05 -0600")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, gregkh-l3A5Bk7waGM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


To support mounting multiple instances of sysfs occassionally I
need to walk through all of the currently present sysfs super blocks.

To allow this iteration this patch adds sysfs_grab_supers
and sysfs_release_supers.  While a piece of code is in
a section surrounded by these no more sysfs super blocks
will be either created or destroyed.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysfs/mount.c |   79 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 fs/sysfs/sysfs.h |   10 +++++++
 2 files changed, 81 insertions(+), 8 deletions(-)

diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index 4968d31..b2bfa45 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -33,47 +33,110 @@ struct sysfs_dirent sysfs_root = {
 
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
 		pr_debug("%s: could not get root dentry!\n",__FUNCTION__);
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
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index 791b3ed..8156ccb 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -50,8 +50,18 @@ struct sysfs_addrm_cxt {
 	int			cnt;
 };
 
+struct sysfs_super_info {
+	int	grabbed;
+};
+
+#define sysfs_info(SB) ((struct sysfs_super_info *)(SB)->s_fs_info)
+
 extern struct sysfs_dirent sysfs_root;
 extern struct kmem_cache *sysfs_dir_cachep;
+extern struct file_system_type sysfs_fs_type;
+
+void sysfs_grab_supers(void);
+void sysfs_release_supers(void);
 
 extern struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd);
 extern struct sysfs_dirent *sysfs_get_active(struct sysfs_dirent *sd);
-- 
1.5.1.1.181.g2de0
