From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 10/11][v3]: Ability to internally create ptmx
Date: Wed, 3 Sep 2008 22:35:22 -0700
Message-ID: <20080904053522.GK3680@us.ibm.com>
References: <20080904052718.GA3680@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080904052718.GA3680-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 10/11]: Ability to internally create ptmx 

/dev/ptmx is closely tied to the devpts filesystem. An open of /dev/ptmx,
allocates the next pty index and the associated device shows up in the
devpts fs as /dev/pts/n.

Wih multiple instancs of devpts filesystem, during an open of /dev/ptmx
we would be unable to determine which instance of the devpts is being
accessed.

So we move the 'ptmx' node into /dev/pts and use the inode of the 'ptmx'
node to identify the superblock and hence the devpts instance.  This patch
adds ability for the kernel to internally create the [ptmx, c, 5:2] device
when mounting devpts filesystem. The permissions for the device node can
be specified by the '-o ptmxmode=0666' option.  The default 'ptmxmode' is
0666.

See next patch ("PATCH [11/11] Enable multiple instances of devpts") for
usage of this interface, user-space impact and backward compatibility issues


Changelog[v3]:
	- Rename ptmx_mode to ptmxmode (for consistency with 'newinstance')

Changelog[v2]:
	- [H. Peter Anvin] Remove mknod() system call support and create the
	  ptmx node internally.

Changelog[v1]:
	- Earlier version of this patch enabled creating /dev/pts/tty as
	  well. As pointed out by Al Viro and H. Peter Anvin, that is not
	  really necessary.

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

---
 fs/devpts/inode.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 60 insertions(+), 2 deletions(-)

Index: linux-2.6.27-rc3-tty/fs/devpts/inode.c
===================================================================
--- linux-2.6.27-rc3-tty.orig/fs/devpts/inode.c	2008-09-03 21:33:46.000000000 -0700
+++ linux-2.6.27-rc3-tty/fs/devpts/inode.c	2008-09-03 21:34:36.000000000 -0700
@@ -27,6 +27,7 @@
 #define DEVPTS_SUPER_MAGIC 0x1cd1
 
 #define DEVPTS_DEFAULT_MODE 0600
+#define DEVPTS_DEFAULT_PTMX_MODE	0666
 #define PTMX_MINOR	2
 
 extern int pty_limit;			/* Config limit on Unix98 ptys */
@@ -40,10 +41,11 @@ struct pts_mount_opts {
 	uid_t   uid;
 	gid_t   gid;
 	umode_t mode;
+	umode_t ptmxmode;
 };
 
 enum {
-	Opt_uid, Opt_gid, Opt_mode,
+	Opt_uid, Opt_gid, Opt_mode, Opt_ptmxmode,
 	Opt_err
 };
 
@@ -51,6 +53,7 @@ static match_table_t tokens = {
 	{Opt_uid, "uid=%u"},
 	{Opt_gid, "gid=%u"},
 	{Opt_mode, "mode=%o"},
+	{Opt_ptmxmode, "ptmxmode=%o"},
 	{Opt_err, NULL}
 };
 
@@ -81,6 +84,7 @@ static int parse_mount_options(char *dat
 	opts->uid     = 0;
 	opts->gid     = 0;
 	opts->mode    = DEVPTS_DEFAULT_MODE;
+	opts->ptmxmode = DEVPTS_DEFAULT_PTMX_MODE;
 
 	while ((p = strsep(&data, ",")) != NULL) {
 		substring_t args[MAX_OPT_ARGS];
@@ -109,6 +113,11 @@ static int parse_mount_options(char *dat
 				return -EINVAL;
 			opts->mode = option & S_IALLUGO;
 			break;
+		case Opt_ptmxmode:
+			if (match_octal(&args[0], &option))
+				return -EINVAL;
+			opts->ptmxmode = option & S_IALLUGO;
+			break;
 		default:
 			printk(KERN_ERR "devpts: called with bogus options\n");
 			return -EINVAL;
@@ -136,6 +145,7 @@ static int devpts_show_options(struct se
 	if (opts->setgid)
 		seq_printf(seq, ",gid=%u", opts->gid);
 	seq_printf(seq, ",mode=%03o", opts->mode);
+	seq_printf(seq, ",ptmxmode=%03o", opts->ptmxmode);
 
 	return 0;
 }
@@ -156,6 +166,7 @@ static void *new_pts_fs_info(void)
 
 	ida_init(&fsi->allocated_ptys);
 	fsi->mount_opts.mode = DEVPTS_DEFAULT_MODE;
+	fsi->mount_opts.ptmxmode = DEVPTS_DEFAULT_PTMX_MODE;
 
 	return fsi;
 }
@@ -201,6 +212,53 @@ fail:
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
+	mode = S_IFCHR|opts->ptmxmode;
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
@@ -213,7 +271,7 @@ static void devpts_kill_sb(struct super_
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
 
 	kfree(fsi);
-	kill_anon_super(sb);
+	kill_litter_super(sb);
 }
 
 static struct file_system_type devpts_fs_type = {
