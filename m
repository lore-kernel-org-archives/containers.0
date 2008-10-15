From: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Subject: [PATCH 1/9] Remove devpts_root global
Date: Tue, 14 Oct 2008 22:33:16 -0700
Message-ID: <20081015053316.GA2215@us.ibm.com>
References: <20081015053000.GA2039@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081015053000.GA2039-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


From 1479f9e238d607403abf5af4296bd5c84a1dc18f Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/9] Remove devpts_root global

Remove the 'devpts_root' global variable and find the root dentry using
the super_block. The super-block can be found from the device inode, using
the new wrapper, pts_sb_from_inode().

Changelog: This patch is based on an earlier patchset from Serge Hallyn
	   and Matt Helsley.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/devpts/inode.c |   29 ++++++++++++++++++++---------
 1 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index a70d5d0..ec33833 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -34,7 +34,6 @@ static DEFINE_IDA(allocated_ptys);
 static DEFINE_MUTEX(allocated_ptys_lock);
 
 static struct vfsmount *devpts_mnt;
-static struct dentry *devpts_root;
 
 static struct {
 	int setuid;
@@ -56,6 +55,14 @@ static match_table_t tokens = {
 	{Opt_err, NULL}
 };
 
+static inline struct super_block *pts_sb_from_inode(struct inode *inode)
+{
+	if (inode->i_sb->s_magic == DEVPTS_SUPER_MAGIC)
+		return inode->i_sb;
+
+	return devpts_mnt->mnt_sb;
+}
+
 static int devpts_remount(struct super_block *sb, int *flags, char *data)
 {
 	char *p;
@@ -142,7 +149,7 @@ devpts_fill_super(struct super_block *s, void *data, int silent)
 	inode->i_fop = &simple_dir_operations;
 	inode->i_nlink = 2;
 
-	devpts_root = s->s_root = d_alloc_root(inode);
+	s->s_root = d_alloc_root(inode);
 	if (s->s_root)
 		return 0;
 	
@@ -211,7 +218,9 @@ int devpts_pty_new(struct inode *ptmx_inode, struct tty_struct *tty)
 	struct tty_driver *driver = tty->driver;
 	dev_t device = MKDEV(driver->major, driver->minor_start+number);
 	struct dentry *dentry;
-	struct inode *inode = new_inode(devpts_mnt->mnt_sb);
+	struct super_block *sb = pts_sb_from_inode(ptmx_inode);
+	struct inode *inode = new_inode(sb);
+	struct dentry *root = sb->s_root;
 	char s[12];
 
 	/* We're supposed to be given the slave end of a pty */
@@ -231,15 +240,15 @@ int devpts_pty_new(struct inode *ptmx_inode, struct tty_struct *tty)
 
 	sprintf(s, "%d", number);
 
-	mutex_lock(&devpts_root->d_inode->i_mutex);
+	mutex_lock(&root->d_inode->i_mutex);
 
-	dentry = d_alloc_name(devpts_root, s);
+	dentry = d_alloc_name(root, s);
 	if (!IS_ERR(dentry)) {
 		d_add(dentry, inode);
-		fsnotify_create(devpts_root->d_inode, dentry);
+		fsnotify_create(root->d_inode, dentry);
 	}
 
-	mutex_unlock(&devpts_root->d_inode->i_mutex);
+	mutex_unlock(&root->d_inode->i_mutex);
 
 	return 0;
 }
@@ -256,11 +265,13 @@ struct tty_struct *devpts_get_tty(struct inode *pts_inode, int number)
 void devpts_pty_kill(struct tty_struct *tty)
 {
 	struct inode *inode = tty->driver_data;
+	struct super_block *sb = pts_sb_from_inode(inode);
+	struct dentry *root = sb->s_root;
 	struct dentry *dentry;
 
 	BUG_ON(inode->i_rdev == MKDEV(TTYAUX_MAJOR, PTMX_MINOR));
 
-	mutex_lock(&devpts_root->d_inode->i_mutex);
+	mutex_lock(&root->d_inode->i_mutex);
 
 	dentry = d_find_alias(inode);
 	if (dentry && !IS_ERR(dentry)) {
@@ -269,7 +280,7 @@ void devpts_pty_kill(struct tty_struct *tty)
 		dput(dentry);
 	}
 
-	mutex_unlock(&devpts_root->d_inode->i_mutex);
+	mutex_unlock(&root->d_inode->i_mutex);
 }
 
 static int __init init_devpts_fs(void)
-- 
1.5.2.5
