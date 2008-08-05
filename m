From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 4/6]: Allow mknod of ptmx in devpts
Date: Mon, 4 Aug 2008 18:23:53 -0700
Message-ID: <20080805012353.GD15360@us.ibm.com>
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
Subject: [RFC][PATCH 4/6]: Allow mknod of ptmx in devpts

/dev/ptmx is closely tied to the devpts filesystem. An open of /dev/ptmx,
allocates the next pty index and the associated device shows up in the
devpts fs as /dev/pts/n.

Wih multiple mounts of devpts filesystem, an open of /dev/ptmx would be
unable to determine which instance of the devpts is being accessed.

One solution for this would be to create make /dev/ptmx a symlink to
/dev/pts/ptmx and create the device node, ptmx, in each instance of
devpts.  When /dev/ptmx is opened, we can use the inode of /dev/pts/ptmx
to identify the specific devpts instance.

(This solution has an impact on the 'startup scripts', and that is 
being discussed separately).

This patch merely enables creating the [c, 5:2] (ptmx) device in devpts
filesystem.

TODO:
	- Ability to unlink the /dev/pts/ptmx
	- Remove traces of '/dev/pts/tty' node

Changelog:
	- Earlier version of this patch enabled creating /dev/pts/tty
	  as well. As pointed out by Al Viro and H. Peter Anvin, that
	  is not really necessary.

---
 fs/devpts/inode.c |   56 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 53 insertions(+), 3 deletions(-)

Index: linux-2.6.26-rc8-mm1/fs/devpts/inode.c
===================================================================
--- linux-2.6.26-rc8-mm1.orig/fs/devpts/inode.c	2008-08-04 02:08:50.000000000 -0700
+++ linux-2.6.26-rc8-mm1/fs/devpts/inode.c	2008-08-04 17:26:26.000000000 -0700
@@ -141,6 +141,56 @@ static void *new_pts_fs_info(void)
 }
 
 
+
+static int devpts_mknod(struct inode *dir, struct dentry *dentry,
+			int mode, dev_t rdev)
+{
+	int inum;
+	struct inode *inode;
+	struct super_block *sb = dir->i_sb;
+
+	if (dentry->d_inode)
+		return -EEXIST;
+
+	if (!S_ISCHR(mode))
+		return -EPERM;
+
+	if (rdev == MKDEV(TTYAUX_MAJOR, 2))
+		inum = 2;
+#if 0
+	else if (rdev == MKDEV(TTYAUX_MAJOR, 0))
+		inum = 3;
+#endif
+	else
+		return -EPERM;
+
+	inode = new_inode(sb);
+	if (!inode)
+		return -ENOMEM;
+
+	inode->i_ino = inum;
+	inode->i_uid = inode->i_gid = 0;
+	inode->i_blocks = 0;
+	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+
+	init_special_inode(inode, mode, rdev);
+
+	d_instantiate(dentry, inode);
+	/*
+	 * Get a reference to the dentry so the device-nodes persist
+	 * even when there are no active references to them. We use
+	 * kill_litter_super() to remove this entry when unmounting
+	 * devpts.
+	 */
+	dget(dentry);
+	return 0;
+}
+
+const struct inode_operations devpts_dir_inode_operations = {
+	.lookup         = simple_lookup,
+	.mknod		= devpts_mknod,
+};
+
 static int
 devpts_fill_super(struct super_block *s, void *data, int silent)
 {
@@ -164,7 +214,7 @@ devpts_fill_super(struct super_block *s,
 	inode->i_blocks = 0;
 	inode->i_uid = inode->i_gid = 0;
 	inode->i_mode = S_IFDIR | S_IRUGO | S_IXUGO | S_IWUSR;
-	inode->i_op = &simple_dir_inode_operations;
+	inode->i_op = &devpts_dir_inode_operations;
 	inode->i_fop = &simple_dir_operations;
 	inode->i_nlink = 2;
 
@@ -195,7 +245,7 @@ static void devpts_kill_sb(struct super_
 	//idr_destroy(&fsi->allocated_ptys);
 	kfree(fsi);
 
-	kill_anon_super(sb);
+	kill_litter_super(sb);
 }
 
 static struct file_system_type devpts_fs_type = {
@@ -274,7 +324,7 @@ int devpts_pty_new(struct inode *ptmx_in
 	if (!inode)
 		return -ENOMEM;
 
-	inode->i_ino = number+2;
+	inode->i_ino = number+4;
 	inode->i_uid = config.setuid ? config.uid : current->fsuid;
 	inode->i_gid = config.setgid ? config.gid : current->fsgid;
 	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
