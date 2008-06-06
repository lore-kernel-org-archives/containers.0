From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 02/11] sysfs: sysfs_get_dentry add a sb parameter
Date: Fri, 06 Jun 2008 17:47:14 +0200
Message-ID: <20080606154654.667494697@theryb.frec.bull.fr>
References: <20080606154654.356185262@theryb.frec.bull.fr>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759768AbYFFPsa@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Biederman <ebiederm@xmission.com>, Serge Hallyn <serue@us.ibm.com>, linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>, Benjamin Thery <benjamin.thery@bull.net>
List-Id: containers.vger.kernel.org

sysfs: sysfs_get_dentry add a sb parameter

In preparation for multiple mounts of sysfs add a superblock parameter to
sysfs_get_dentry.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 fs/sysfs/dir.c   |   12 +++++++-----
 fs/sysfs/file.c  |    2 +-
 fs/sysfs/sysfs.h |    3 ++-
 3 files changed, 10 insertions(+), 7 deletions(-)

Index: linux-mm/fs/sysfs/dir.c
===================================================================
--- linux-mm.orig/fs/sysfs/dir.c
+++ linux-mm/fs/sysfs/dir.c
@@ -87,6 +87,7 @@ static void sysfs_unlink_sibling(struct 
 
 /**
  *	sysfs_get_dentry - get dentry for the given sysfs_dirent
+ *	@sb: superblock of the dentry to return
  *	@sd: sysfs_dirent of interest
  *
  *	Get dentry for @sd.  Dentry is looked up if currently not
@@ -99,9 +100,10 @@ static void sysfs_unlink_sibling(struct 
  *	RETURNS:
  *	Pointer to found dentry on success, ERR_PTR() value on error.
  */
-struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
+struct dentry *sysfs_get_dentry(struct super_block *sb,
+				struct sysfs_dirent *sd)
 {
-	struct dentry *dentry = dget(sysfs_sb->s_root);
+	struct dentry *dentry = dget(sb->s_root);
 
 	while (dentry->d_fsdata != sd) {
 		struct sysfs_dirent *cur;
@@ -790,7 +792,7 @@ int sysfs_rename_dir(struct kobject * ko
 		goto out;	/* nothing to rename */
 
 	/* get the original dentry */
-	old_dentry = sysfs_get_dentry(sd);
+	old_dentry = sysfs_get_dentry(sysfs_sb, sd);
 	if (IS_ERR(old_dentry)) {
 		error = PTR_ERR(old_dentry);
 		old_dentry = NULL;
@@ -858,7 +860,7 @@ int sysfs_move_dir(struct kobject *kobj,
 		goto out;	/* nothing to move */
 
 	/* get dentries */
-	old_dentry = sysfs_get_dentry(sd);
+	old_dentry = sysfs_get_dentry(sysfs_sb, sd);
 	if (IS_ERR(old_dentry)) {
 		error = PTR_ERR(old_dentry);
 		old_dentry = NULL;
@@ -866,7 +868,7 @@ int sysfs_move_dir(struct kobject *kobj,
 	}
 	old_parent = old_dentry->d_parent;
 
-	new_parent = sysfs_get_dentry(new_parent_sd);
+	new_parent = sysfs_get_dentry(sysfs_sb, new_parent_sd);
 	if (IS_ERR(new_parent)) {
 		error = PTR_ERR(new_parent);
 		new_parent = NULL;
Index: linux-mm/fs/sysfs/file.c
===================================================================
--- linux-mm.orig/fs/sysfs/file.c
+++ linux-mm/fs/sysfs/file.c
@@ -584,7 +584,7 @@ int sysfs_chmod_file(struct kobject *kob
 		goto out;
 
 	mutex_lock(&sysfs_rename_mutex);
-	victim = sysfs_get_dentry(victim_sd);
+	victim = sysfs_get_dentry(sysfs_sb, victim_sd);
 	mutex_unlock(&sysfs_rename_mutex);
 	if (IS_ERR(victim)) {
 		rc = PTR_ERR(victim);
Index: linux-mm/fs/sysfs/sysfs.h
===================================================================
--- linux-mm.orig/fs/sysfs/sysfs.h
+++ linux-mm/fs/sysfs/sysfs.h
@@ -113,7 +113,8 @@ extern spinlock_t sysfs_assoc_lock;
 extern const struct file_operations sysfs_dir_operations;
 extern const struct inode_operations sysfs_dir_inode_operations;
 
-struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd);
+struct dentry *sysfs_get_dentry(struct super_block *sb,
+				struct sysfs_dirent *sd);
 struct sysfs_dirent *sysfs_get_active_two(struct sysfs_dirent *sd);
 void sysfs_put_active_two(struct sysfs_dirent *sd);
 void sysfs_addrm_start(struct sysfs_addrm_cxt *acxt,

-- 
