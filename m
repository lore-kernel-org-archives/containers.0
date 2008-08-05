From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 2/6] Remove 'devpts_root' global
Date: Mon, 4 Aug 2008 18:22:53 -0700
Message-ID: <20080805012253.GB15360@us.ibm.com>
References: <20080805011844.GA14940@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080805011844.GA14940-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org
Cc: "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 2/6] Remove 'devpts_root' global

Remove the 'devpts_root' global variable and find the root dentry using
the super_block. The super-block itself is found from the device inode,
using a new wrapper, pts_sb_from_inode().

---
 fs/devpts/inode.c |   36 ++++++++++++++++++++++++------------
 1 file changed, 24 insertions(+), 12 deletions(-)

Index: linux-2.6.26-rc8-mm1/fs/devpts/inode.c
===================================================================
--- linux-2.6.26-rc8-mm1.orig/fs/devpts/inode.c	2008-08-04 02:08:15.000000000 -0700
+++ linux-2.6.26-rc8-mm1/fs/devpts/inode.c	2008-08-04 02:08:43.000000000 -0700
@@ -33,7 +33,14 @@ static DEFINE_IDR(allocated_ptys);
 static DEFINE_MUTEX(allocated_ptys_lock);
 
 static struct vfsmount *devpts_mnt;
-static struct dentry *devpts_root;
+
+static inline struct super_block *pts_sb_from_inode(struct inode *inode)
+{
+	if (inode->i_sb->s_magic == DEVPTS_SUPER_MAGIC)
+		return inode->i_sb;
+
+	return devpts_mnt->mnt_sb;
+}
 
 static struct {
 	int setuid;
@@ -141,7 +148,7 @@ devpts_fill_super(struct super_block *s,
 	inode->i_fop = &simple_dir_operations;
 	inode->i_nlink = 2;
 
-	devpts_root = s->s_root = d_alloc_root(inode);
+	s->s_root = d_alloc_root(inode);
 	if (s->s_root)
 		return 0;
 	
@@ -169,10 +176,9 @@ static struct file_system_type devpts_fs
  * to the System V naming convention
  */
 
-static struct dentry *get_node(int num)
+static struct dentry *get_node(struct dentry *root, int num)
 {
 	char s[12];
-	struct dentry *root = devpts_root;
 	mutex_lock(&root->d_inode->i_mutex);
 	return lookup_one_len(s, root, sprintf(s, "%d", num));
 }
@@ -218,7 +224,9 @@ int devpts_pty_new(struct inode *ptmx_in
 	struct tty_driver *driver = tty->driver;
 	dev_t device = MKDEV(driver->major, driver->minor_start+number);
 	struct dentry *dentry;
-	struct inode *inode = new_inode(devpts_mnt->mnt_sb);
+	struct super_block *sb = pts_sb_from_inode(ptmx_inode);
+	struct inode *inode = new_inode(sb);
+	struct dentry *root = sb->s_root;
 
 	/* We're supposed to be given the slave end of a pty */
 	BUG_ON(driver->type != TTY_DRIVER_TYPE_PTY);
@@ -234,20 +242,22 @@ int devpts_pty_new(struct inode *ptmx_in
 	init_special_inode(inode, S_IFCHR|config.mode, device);
 	inode->i_private = tty;
 
-	dentry = get_node(number);
+	dentry = get_node(root, number);
 	if (!IS_ERR(dentry) && !dentry->d_inode) {
 		d_instantiate(dentry, inode);
-		fsnotify_create(devpts_root->d_inode, dentry);
+		fsnotify_create(root->d_inode, dentry);
 	}
 
-	mutex_unlock(&devpts_root->d_inode->i_mutex);
+	mutex_unlock(&root->d_inode->i_mutex);
 
 	return 0;
 }
 
 struct tty_struct *devpts_get_tty(struct inode *inode, int number)
 {
-	struct dentry *dentry = get_node(number);
+	struct super_block *sb = pts_sb_from_inode(inode);
+	struct dentry *root = sb->s_root;
+	struct dentry *dentry = get_node(root, number);
 	struct tty_struct *tty;
 
 	tty = NULL;
@@ -257,14 +267,16 @@ struct tty_struct *devpts_get_tty(struct
 		dput(dentry);
 	}
 
-	mutex_unlock(&devpts_root->d_inode->i_mutex);
+	mutex_unlock(&root->d_inode->i_mutex);
 
 	return tty;
 }
 
 void devpts_pty_kill(struct inode *inode, int number)
 {
-	struct dentry *dentry = get_node(number);
+	struct super_block *sb = pts_sb_from_inode(inode);
+	struct dentry *root = sb->s_root;
+	struct dentry *dentry = get_node(root, number);
 
 	if (!IS_ERR(dentry)) {
 		struct inode *inode = dentry->d_inode;
@@ -275,7 +287,7 @@ void devpts_pty_kill(struct inode *inode
 		}
 		dput(dentry);
 	}
-	mutex_unlock(&devpts_root->d_inode->i_mutex);
+	mutex_unlock(&root->d_inode->i_mutex);
 }
 
 static int __init init_devpts_fs(void)
