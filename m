From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 8/11][v3]: Per-mount 'config' object
Date: Wed, 3 Sep 2008 22:34:17 -0700
Message-ID: <20080904053417.GI3680@us.ibm.com>
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
Subject: [PATCH 8/11]: Per-mount 'config' object

With support for multiple mounts of devpts, the 'config' structure really
represents per-mount options rather than config parameters. Rename 'config'
structure to 'pts_mount_opts' and store it in the super-block.

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

---
 fs/devpts/inode.c |   57 ++++++++++++++++++++++++++++++++----------------------
 1 file changed, 34 insertions(+), 23 deletions(-)

Index: linux-2.6.27-rc3-tty/fs/devpts/inode.c
===================================================================
--- linux-2.6.27-rc3-tty.orig/fs/devpts/inode.c	2008-09-03 21:32:10.000000000 -0700
+++ linux-2.6.27-rc3-tty/fs/devpts/inode.c	2008-09-03 21:33:36.000000000 -0700
@@ -34,13 +34,13 @@ static DEFINE_MUTEX(allocated_ptys_lock)
 
 static struct vfsmount *devpts_mnt;
 
-static struct {
+struct pts_mount_opts {
 	int setuid;
 	int setgid;
 	uid_t   uid;
 	gid_t   gid;
 	umode_t mode;
-} config = {.mode = DEVPTS_DEFAULT_MODE};
+};
 
 enum {
 	Opt_uid, Opt_gid, Opt_mode,
@@ -56,6 +56,7 @@ static match_table_t tokens = {
 
 struct pts_fs_info {
 	struct ida allocated_ptys;
+	struct pts_mount_opts mount_opts;
 };
 
 static inline struct pts_fs_info * DEVPTS_SB(struct super_block *sb)
@@ -74,12 +75,14 @@ static inline struct super_block *pts_sb
 static int devpts_remount(struct super_block *sb, int *flags, char *data)
 {
 	char *p;
+	struct pts_fs_info *fsi = DEVPTS_SB(sb);
+	struct pts_mount_opts *opts = &fsi->mount_opts;
 
-	config.setuid  = 0;
-	config.setgid  = 0;
-	config.uid     = 0;
-	config.gid     = 0;
-	config.mode    = DEVPTS_DEFAULT_MODE;
+	opts->setuid  = 0;
+	opts->setgid  = 0;
+	opts->uid     = 0;
+	opts->gid     = 0;
+	opts->mode    = DEVPTS_DEFAULT_MODE;
 
 	while ((p = strsep(&data, ",")) != NULL) {
 		substring_t args[MAX_OPT_ARGS];
@@ -94,19 +97,19 @@ static int devpts_remount(struct super_b
 		case Opt_uid:
 			if (match_int(&args[0], &option))
 				return -EINVAL;
-			config.uid = option;
-			config.setuid = 1;
+			opts->uid = option;
+			opts->setuid = 1;
 			break;
 		case Opt_gid:
 			if (match_int(&args[0], &option))
 				return -EINVAL;
-			config.gid = option;
-			config.setgid = 1;
+			opts->gid = option;
+			opts->setgid = 1;
 			break;
 		case Opt_mode:
 			if (match_octal(&args[0], &option))
 				return -EINVAL;
-			config.mode = option & S_IALLUGO;
+			opts->mode = option & S_IALLUGO;
 			break;
 		default:
 			printk(KERN_ERR "devpts: called with bogus options\n");
@@ -119,11 +122,14 @@ static int devpts_remount(struct super_b
 
 static int devpts_show_options(struct seq_file *seq, struct vfsmount *vfs)
 {
-	if (config.setuid)
-		seq_printf(seq, ",uid=%u", config.uid);
-	if (config.setgid)
-		seq_printf(seq, ",gid=%u", config.gid);
-	seq_printf(seq, ",mode=%03o", config.mode);
+	struct pts_fs_info *fsi = DEVPTS_SB(vfs->mnt_sb);
+	struct pts_mount_opts *opts = &fsi->mount_opts;
+
+	if (opts->setuid)
+		seq_printf(seq, ",uid=%u", opts->uid);
+	if (opts->setgid)
+		seq_printf(seq, ",gid=%u", opts->gid);
+	seq_printf(seq, ",mode=%03o", opts->mode);
 
 	return 0;
 }
@@ -138,9 +144,12 @@ static void *new_pts_fs_info(void)
 {
 	struct pts_fs_info *fsi;
 
-	fsi = kmalloc(sizeof(struct pts_fs_info), GFP_KERNEL);
-	if (fsi)
-		ida_init(&fsi->allocated_ptys);
+	fsi = kzalloc(sizeof(struct pts_fs_info), GFP_KERNEL);
+	if (!fsi)
+		return NULL;
+
+	ida_init(&fsi->allocated_ptys);
+	fsi->mount_opts.mode = DEVPTS_DEFAULT_MODE;
 
 	return fsi;
 }
@@ -262,6 +271,8 @@ int devpts_pty_new(struct inode *ptmx_in
 	struct super_block *sb = pts_sb_from_inode(ptmx_inode);
 	struct inode *inode = new_inode(sb);
 	struct dentry *root = sb->s_root;
+	struct pts_fs_info *fsi = DEVPTS_SB(sb);
+	struct pts_mount_opts *opts = &fsi->mount_opts;
 	char s[12];
 
 	/* We're supposed to be given the slave end of a pty */
@@ -272,10 +283,10 @@ int devpts_pty_new(struct inode *ptmx_in
 		return -ENOMEM;
 
 	inode->i_ino = number+2;
-	inode->i_uid = config.setuid ? config.uid : current->fsuid;
-	inode->i_gid = config.setgid ? config.gid : current->fsgid;
+	inode->i_uid = opts->setuid ? opts->uid : current->fsuid;
+	inode->i_gid = opts->setgid ? opts->gid : current->fsgid;
 	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
-	init_special_inode(inode, S_IFCHR|config.mode, device);
+	init_special_inode(inode, S_IFCHR|opts->mode, device);
 	inode->i_private = tty;
 	tty->driver_data = inode;
