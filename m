From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 7/8]: Auto-create ptmx node when mounting devpts
Date: Wed, 20 Aug 2008 19:29:08 -0700
Message-ID: <20080821022908.GG29658@us.ibm.com>
References: <20080821022126.GA29449@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080821022126.GA29449-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 7/8]: Auto-create ptmx node when mounting devpts

/dev/ptmx is closely tied to the devpts filesystem. An open of /dev/ptmx,
allocates the next pty index and the associated device shows up in the
devpts fs as /dev/pts/n.

Wih multiple mounts of devpts filesystem, an open of /dev/ptmx would be
unable to determine which instance of the devpts is being accessed.

One solution for this would be to create make /dev/ptmx a symlink to
/dev/pts/ptmx and create the device node, ptmx, in each instance of
devpts. When /dev/ptmx is opened, we can use the inode of /dev/pts/ptmx
to identify the specific devpts instance.

This patch has the kernel internally create the [ptmx, c, 5:2] device
when mounting devpts filesystem. The permissions for the device node
can be specified by the '-o ptmx_mode=0666' option. The default mode
is 0666.

USER-SPACE IMPACT:
	
	This patch has an user-space impact in that the permissions for
      	the device node are specified at mount time. Default mode of 0666
      	matches current defaults on Ubuntu, Redhat,
	
	Hopefully, presence of the 'ptmx' node in /dev/pts does not surprise
	user space.

Changelog[v2]:
	- [H. Peter Anvin] Remove mknod() system call support and create the
	  ptmx node internally.

Changelog[v1]:
	- Earlier version of this patch enabled creating /dev/pts/tty as
	  well. As pointed out by Al Viro and H. Peter Anvin, that is not
	  really necessary.

---
 fs/devpts/inode.c |   80 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 77 insertions(+), 3 deletions(-)

Index: linux-2.6.26-rc8-mm1/fs/devpts/inode.c
===================================================================
--- linux-2.6.26-rc8-mm1.orig/fs/devpts/inode.c	2008-08-20 14:28:39.000000000 -0700
+++ linux-2.6.26-rc8-mm1/fs/devpts/inode.c	2008-08-20 17:44:29.000000000 -0700
@@ -27,6 +27,7 @@
 #define DEVPTS_SUPER_MAGIC 0x1cd1
 
 #define DEVPTS_DEFAULT_MODE 0600
+#define DEVPTS_DEFAULT_PTMX_MODE 0666
 
 extern int pty_limit;			/* Config limit on Unix98 ptys */
 static DEFINE_MUTEX(allocated_ptys_lock);
@@ -39,10 +40,11 @@ struct pts_mount_opts {
 	uid_t   uid;
 	gid_t   gid;
 	umode_t mode;
+	umode_t ptmx_mode;
 };
 
 enum {
-	Opt_uid, Opt_gid, Opt_mode,
+	Opt_uid, Opt_gid, Opt_mode, Opt_ptmx_mode,
 	Opt_err
 };
 
@@ -50,6 +52,7 @@ static match_table_t tokens = {
 	{Opt_uid, "uid=%u"},
 	{Opt_gid, "gid=%u"},
 	{Opt_mode, "mode=%o"},
+	{Opt_ptmx_mode, "ptmx_mode=%o"},
 	{Opt_err, NULL}
 };
 
@@ -80,6 +83,7 @@ static int parse_mount_options(char *dat
 	opts->uid     = 0;
 	opts->gid     = 0;
 	opts->mode    = DEVPTS_DEFAULT_MODE;
+	opts->ptmx_mode = DEVPTS_DEFAULT_PTMX_MODE;
 
 	while ((p = strsep(&data, ",")) != NULL) {
 		substring_t args[MAX_OPT_ARGS];
@@ -108,6 +112,11 @@ static int parse_mount_options(char *dat
 				return -EINVAL;
 			opts->mode = option & S_IALLUGO;
 			break;
+		case Opt_ptmx_mode:
+			if (match_octal(&args[0], &option))
+				return -EINVAL;
+			opts->ptmx_mode = option & S_IALLUGO;
+			break;
 		default:
 			printk(KERN_ERR "devpts: called with bogus options\n");
 			return -EINVAL;
@@ -135,6 +144,7 @@ static int devpts_show_options(struct se
 	if (opts->setgid)
 		seq_printf(seq, ",gid=%u", opts->gid);
 	seq_printf(seq, ",mode=%03o", opts->mode);
+	seq_printf(seq, ",ptmx_mode=%03o", opts->ptmx_mode);
 
 	return 0;
 }
@@ -199,10 +209,74 @@ fail:
 	return -ENOMEM;
 }
 
+int mknod_ptmx(struct super_block *sb)
+{
+	struct dentry *root;
+	struct dentry *dentry;
+	struct inode *inode;
+	struct pts_fs_info *fsi = DEVPTS_SB(sb);
+	struct pts_mount_opts *opts = &fsi->mount_opts;
+	int mode;
+
+	root = sb->s_root;
+	dentry = lookup_one_len("ptmx", root, 4);
+	if (IS_ERR(dentry)) {
+		printk(KERN_ERR "Unable to alloc dentry for ptmx node\n");
+		return -ENOMEM;
+	}
+
+	if (dentry->d_inode) {
+		printk(KERN_ERR "'ptmx' (ino %lu) exists in this devpts\n",
+				dentry->d_inode->i_ino);
+		return 0;
+	}
+
+	/*
+	 * Create a new 'ptmx' node in this mount of devpts.
+	 */
+	inode = new_inode(sb);
+	if (!inode) {
+		printk(KERN_ERR "Unable to alloc inode for ptmx node\n");
+		dput(dentry);
+		return -ENOMEM;
+	}
+
+	inode->i_uid = inode->i_gid = 0;
+	inode->i_blocks = 0;
+	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+
+	mode = S_IFCHR|opts->ptmx_mode;
+	init_special_inode(inode, mode, MKDEV(TTYAUX_MAJOR, 2));
+
+	d_add(dentry, inode);	// d_instantiate() should be enough ?
+
+	printk(KERN_DEBUG "Created ptmx node in devpts ino %lu\n",
+			inode->i_ino);
+
+	return 0;
+}
+
 static int devpts_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
 {
-	return get_sb_single(fs_type, flags, data, devpts_fill_super, mnt);
+	int err;
+
+	err = get_sb_single(fs_type, flags, data, devpts_fill_super, mnt);
+	if (err)
+		return err;
+
+	/*
+	 * Create the 'ptmx' device in the root of the new mount.
+	 * Do this even for the 'single-mount' case so users can choose
+	 * to leave /dev/ptmx -> pts/ptmx symlink as they switch between
+	 * old and new kernels.
+	 */
+	err = mknod_ptmx(mnt->mnt_sb);
+	if (err) {
+		dput(mnt->mnt_sb->s_root);
+		deactivate_super(mnt->mnt_sb);
+	}
+	return err;
 }
 
 
@@ -213,7 +287,7 @@ static void devpts_kill_sb(struct super_
 	//idr_destroy(&fsi->allocated_ptys);
 	kfree(fsi);
 
-	kill_anon_super(sb);
+	kill_litter_super(sb);
 }
 
 static struct file_system_type devpts_fs_type = {
