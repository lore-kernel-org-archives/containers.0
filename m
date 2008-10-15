From: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Subject: [PATCH 6/9] Define mknod_ptmx()
Date: Tue, 14 Oct 2008 22:36:22 -0700
Message-ID: <20081015053621.GF2215@us.ibm.com>
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


From ff0c06fb1878a3c20a6a91d9666d44f56eb94ff7 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 6/9] Define mknod_ptmx()

/dev/ptmx is closely tied to the devpts filesystem. An open of /dev/ptmx,
allocates the next pty index and the associated device shows up in the
devpts fs as /dev/pts/n.

Wih multiple instancs of devpts filesystem, during an open of /dev/ptmx
we would be unable to determine which instance of the devpts is being
accessed.

So we move the 'ptmx' node into /dev/pts and use the inode of the 'ptmx'
node to identify the superblock and hence the devpts instance.  This patch
adds ability for the kernel to internally create the [ptmx, c, 5:2] device
when mounting devpts filesystem.  Since the ptmx node in devpts is new and
may surprise some userspace scripts, the default permissions for the new
node is 0000.  These permissions can be changed either using chmod or by
remounting with the new '-o ptmxmode=0666' mount option.

Changelog[v5]:
	- [Serge Hallyn bugfix]: Letting new_inode() assign inode number to
	  ptmx can collide with hand-assigning inode numbers to ptys. So,
	  hand-assign specific inode number to ptmx node also.
	- [Serge Hallyn]: Maybe safer to grab root dentry mutex while creating
	  ptmx node
	- [Bugfix with Serge Hallyn] Replace lookup_one_len() in mknod_ptmx()
	  wih d_alloc_name() (lookup during ->get_sb() locks up system). To
	  simplify patchset, fold the ptmx_dentry patch into this.

Changelog[v4]:
	- Change default permissions of pts/ptmx node to 0000.
	- Move code for ptmxmode under #ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES.

Changelog[v3]:
	- Rename ptmx_mode to ptmxmode (for consistency with 'newinstance')

Changelog[v2]:
	- [H. Peter Anvin] Remove mknod() system call support and create the
	  ptmx node internally.

Changelog[v1]:
	- Earlier version of this patch enabled creating /dev/pts/tty as
	  well. As pointed out by Al Viro and H. Peter Anvin, that is not
	  really necessary.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/devpts/inode.c |  113 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 109 insertions(+), 4 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 7ae60aa..bbdd7df 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -27,6 +27,13 @@
 #define DEVPTS_SUPER_MAGIC 0x1cd1
 
 #define DEVPTS_DEFAULT_MODE 0600
+/*
+ * ptmx is a new node in /dev/pts and will be unused in legacy (single-
+ * instance) mode. To prevent surprises in user space, set permissions of
+ * ptmx to 0. Use 'chmod' or remount with '-o ptmxmode' to set meaningful
+ * permissions.
+ */
+#define DEVPTS_DEFAULT_PTMX_MODE 0000
 #define PTMX_MINOR	2
 
 extern int pty_limit;			/* Config limit on Unix98 ptys */
@@ -40,10 +47,11 @@ struct pts_mount_opts {
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
 
@@ -51,12 +59,16 @@ static match_table_t tokens = {
 	{Opt_uid, "uid=%u"},
 	{Opt_gid, "gid=%u"},
 	{Opt_mode, "mode=%o"},
+#ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
+	{Opt_ptmxmode, "ptmxmode=%o"},
+#endif
 	{Opt_err, NULL}
 };
 
 struct pts_fs_info {
 	struct ida allocated_ptys;
 	struct pts_mount_opts mount_opts;
+	struct dentry *ptmx_dentry;
 };
 
 static inline struct pts_fs_info *DEVPTS_SB(struct super_block *sb)
@@ -81,6 +93,7 @@ static int parse_mount_options(char *data, struct pts_mount_opts *opts)
 	opts->uid     = 0;
 	opts->gid     = 0;
 	opts->mode    = DEVPTS_DEFAULT_MODE;
+	opts->ptmxmode = DEVPTS_DEFAULT_PTMX_MODE;
 
 	while ((p = strsep(&data, ",")) != NULL) {
 		substring_t args[MAX_OPT_ARGS];
@@ -109,6 +122,13 @@ static int parse_mount_options(char *data, struct pts_mount_opts *opts)
 				return -EINVAL;
 			opts->mode = option & S_IALLUGO;
 			break;
+#ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
+		case Opt_ptmxmode:
+			if (match_octal(&args[0], &option))
+				return -EINVAL;
+			opts->ptmxmode = option & S_IALLUGO;
+			break;
+#endif
 		default:
 			printk(KERN_ERR "devpts: called with bogus options\n");
 			return -EINVAL;
@@ -118,12 +138,93 @@ static int parse_mount_options(char *data, struct pts_mount_opts *opts)
 	return 0;
 }
 
+#ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
+static int mknod_ptmx(struct super_block *sb)
+{
+	int mode;
+	int rc = -ENOMEM;
+	struct dentry *dentry;
+	struct inode *inode;
+	struct dentry *root = sb->s_root;
+	struct pts_fs_info *fsi = DEVPTS_SB(sb);
+	struct pts_mount_opts *opts = &fsi->mount_opts;
+
+	mutex_lock(&root->d_inode->i_mutex);
+
+	/* If we have already created ptmx node, return */
+	if (fsi->ptmx_dentry) {
+		rc = 0;
+		goto out;
+	}
+
+	dentry = d_alloc_name(root, "ptmx");
+	if (!dentry) {
+		printk(KERN_NOTICE "Unable to alloc dentry for ptmx node\n");
+		goto out;
+	}
+
+	/*
+	 * Create a new 'ptmx' node in this mount of devpts.
+	 */
+	inode = new_inode(sb);
+	if (!inode) {
+		printk(KERN_ERR "Unable to alloc inode for ptmx node\n");
+		dput(dentry);
+		goto out;
+	}
+
+	inode->i_ino = 2;
+	inode->i_uid = inode->i_gid = 0;
+	inode->i_blocks = 0;
+	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+
+	mode = S_IFCHR|opts->ptmxmode;
+	init_special_inode(inode, mode, MKDEV(TTYAUX_MAJOR, 2));
+
+	d_add(dentry, inode);
+	
+	fsi->ptmx_dentry = dentry;
+	rc = 0;
+
+	printk(KERN_DEBUG "Created ptmx node in devpts ino %lu\n",
+			inode->i_ino);
+out:
+	mutex_unlock(&root->d_inode->i_mutex);
+	return rc;
+}
+
+static void update_ptmx_mode(struct pts_fs_info *fsi)
+{
+       struct inode *inode;
+       if (fsi->ptmx_dentry) {
+               inode = fsi->ptmx_dentry->d_inode;
+               inode->i_mode = S_IFCHR|fsi->mount_opts.ptmxmode;
+       }
+}
+#else
+static inline void update_ptmx_mode(struct pts_fs_info *fsi)
+{
+       return;
+}
+#endif
+
 static int devpts_remount(struct super_block *sb, int *flags, char *data)
 {
+	int err;
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
 	struct pts_mount_opts *opts = &fsi->mount_opts;
 
-	return parse_mount_options(data, opts);
+	err = parse_mount_options(data, opts);
+
+	/*
+	 * parse_mount_options() restores options to default values
+	 * before parsing and may have changed ptmxmode. So, update the
+	 * mode in the inode too. Bogus options don't fail the remount,
+	 * so do this even on error return.
+	 */
+	update_ptmx_mode(fsi);
+
+	return err;
 }
 
 static int devpts_show_options(struct seq_file *seq, struct vfsmount *vfs)
@@ -136,6 +237,9 @@ static int devpts_show_options(struct seq_file *seq, struct vfsmount *vfs)
 	if (opts->setgid)
 		seq_printf(seq, ",gid=%u", opts->gid);
 	seq_printf(seq, ",mode=%03o", opts->mode);
+#ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
+	seq_printf(seq, ",ptmxmode=%03o", opts->ptmxmode);
+#endif
 
 	return 0;
 }
@@ -156,6 +260,7 @@ static void *new_pts_fs_info(void)
 
 	ida_init(&fsi->allocated_ptys);
 	fsi->mount_opts.mode = DEVPTS_DEFAULT_MODE;
+	fsi->mount_opts.ptmxmode = DEVPTS_DEFAULT_PTMX_MODE;
 
 	return fsi;
 }
@@ -211,7 +316,7 @@ static void devpts_kill_sb(struct super_block *sb)
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
 
 	kfree(fsi);
-	kill_anon_super(sb);
+	kill_litter_super(sb);
 }
 
 static struct file_system_type devpts_fs_type = {
@@ -286,7 +391,7 @@ int devpts_pty_new(struct inode *ptmx_inode, struct tty_struct *tty)
 	if (!inode)
 		return -ENOMEM;
 
-	inode->i_ino = number+2;
+	inode->i_ino = number+3;
 	inode->i_uid = opts->setuid ? opts->uid : current->fsuid;
 	inode->i_gid = opts->setgid ? opts->gid : current->fsgid;
 	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
-- 
1.5.2.5
