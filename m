From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 3/4] devpts: Make the newinstance option historical
Date: Sat, 22 Sep 2012 20:50:44 -0700
Message-ID: <87d31d75yj.fsf_-_@xmission.com>
References: <20120124000517.GA28878@sergelap>
	<CA+55aFz9ofF+Ey8VCDS8UEf2XSw36kj2RhkHfFScuzLXMeNrkA@mail.gmail.com>
	<20120124002555.GA29534@sergelap>
	<CA+55aFzwOU137V6wtyBjessx05NJo2G4KV0rvTKWvC79A+o9iQ@mail.gmail.com>
	<20120124010758.GJ23916@ZenIV.linux.org.uk>
	<m1k44gj1cu.fsf@fess.ebiederm.org> <20120124220247.GA26353@hallyn.com>
	<CAPXgP13_gczQmG_USAp0p2AuTfxkzAvzHvjbZY_rbbLH-4rDyg@mail.gmail.com>
	<20120124231601.GA4470@sergelap>
	<CAPXgP12REAwmDORzdGJhsxZKU8nhiauCxoVdKa8Eifw4MWWtgA@mail.gmail.com>
	<20120128195103.GA11299@sergelap> <87txup763i.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87txup763i.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Sat, 22 Sep 2012 20:47:45 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andy Whitcroft <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org


- Modify opening /dev/ptmx so that it opens /dev/pts/ptmx
  As it appares nearly impossible to get udev to create a symlink
  do this with a little sprinkle of in kernel magic.
- Cleanup the devpts mount code and only leave the code for
  new instance.

Tested on debian and ubuntu without any problems.

Acked-by: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 drivers/tty/pty.c         |    4 +
 fs/devpts/inode.c         |  180 +++++++++++++++++----------------------------
 include/linux/devpts_fs.h |    5 +
 3 files changed, 77 insertions(+), 112 deletions(-)

diff --git a/drivers/tty/pty.c b/drivers/tty/pty.c
index 6beb7e1..a605074 100644
--- a/drivers/tty/pty.c
+++ b/drivers/tty/pty.c
@@ -615,6 +615,10 @@ static int ptmx_open(struct inode *inode, struct file *filp)
 	int retval;
 	int index;
 
+	inode = devpts_redirect(filp);
+	if (IS_ERR(inode))
+		return PTR_ERR(inode);
+
 	nonseekable_open(inode, filp);
 
 	retval = tty_alloc_file(filp);
diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 61b54aa..38136ae 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -25,6 +25,7 @@
 #include <linux/parser.h>
 #include <linux/fsnotify.h>
 #include <linux/seq_file.h>
+#include <linux/file.h>
 
 #define DEVPTS_DEFAULT_MODE 0600
 
@@ -94,7 +95,6 @@ struct pts_mount_opts {
 	kgid_t   gid;
 	umode_t mode;
 	umode_t ptmxmode;
-	int newinstance;
 	int max;
 };
 
@@ -116,7 +116,6 @@ static const match_table_t tokens = {
 struct pts_fs_info {
 	struct ida allocated_ptys;
 	struct pts_mount_opts mount_opts;
-	struct dentry *ptmx_dentry;
 };
 
 static inline struct pts_fs_info *DEVPTS_SB(struct super_block *sb)
@@ -157,10 +156,6 @@ static int parse_mount_options(char *data, int op, struct pts_mount_opts *opts)
 	opts->ptmxmode = DEVPTS_DEFAULT_PTMX_MODE;
 	opts->max     = NR_UNIX98_PTY_MAX;
 
-	/* newinstance makes sense only on initial mount */
-	if (op == PARSE_MOUNT)
-		opts->newinstance = 0;
-
 	while ((p = strsep(&data, ",")) != NULL) {
 		substring_t args[MAX_OPT_ARGS];
 		int token;
@@ -200,9 +195,7 @@ static int parse_mount_options(char *data, int op, struct pts_mount_opts *opts)
 			opts->ptmxmode = option & S_IALLUGO;
 			break;
 		case Opt_newinstance:
-			/* newinstance makes sense only on initial mount */
-			if (op == PARSE_MOUNT)
-				opts->newinstance = 1;
+			/* Historical */
 			break;
 		case Opt_max:
 			if (match_int(&args[0], &option) ||
@@ -229,14 +222,6 @@ static int mknod_ptmx(struct super_block *sb)
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
 	struct pts_mount_opts *opts = &fsi->mount_opts;
 
-	mutex_lock(&root->d_inode->i_mutex);
-
-	/* If we have already created ptmx node, return */
-	if (fsi->ptmx_dentry) {
-		rc = 0;
-		goto out;
-	}
-
 	dentry = d_alloc_name(root, "ptmx");
 	if (!dentry) {
 		printk(KERN_NOTICE "Unable to alloc dentry for ptmx node\n");
@@ -261,39 +246,17 @@ static int mknod_ptmx(struct super_block *sb)
 
 	d_add(dentry, inode);
 
-	fsi->ptmx_dentry = dentry;
 	rc = 0;
 out:
-	mutex_unlock(&root->d_inode->i_mutex);
 	return rc;
 }
 
-static void update_ptmx_mode(struct pts_fs_info *fsi)
-{
-	struct inode *inode;
-	if (fsi->ptmx_dentry) {
-		inode = fsi->ptmx_dentry->d_inode;
-		inode->i_mode = S_IFCHR|fsi->mount_opts.ptmxmode;
-	}
-}
-
 static int devpts_remount(struct super_block *sb, int *flags, char *data)
 {
-	int err;
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
 	struct pts_mount_opts *opts = &fsi->mount_opts;
 
-	err = parse_mount_options(data, PARSE_REMOUNT, opts);
-
-	/*
-	 * parse_mount_options() restores options to default values
-	 * before parsing and may have changed ptmxmode. So, update the
-	 * mode in the inode too. Bogus options don't fail the remount,
-	 * so do this even on error return.
-	 */
-	update_ptmx_mode(fsi);
-
-	return err;
+	return  parse_mount_options(data, PARSE_REMOUNT, opts);
 }
 
 static int devpts_show_options(struct seq_file *seq, struct dentry *root)
@@ -319,7 +282,7 @@ static const struct super_operations devpts_sops = {
 	.show_options	= devpts_show_options,
 };
 
-static void *new_pts_fs_info(void)
+static struct pts_fs_info *new_pts_fs_info(void)
 {
 	struct pts_fs_info *fsi;
 
@@ -338,6 +301,8 @@ static int
 devpts_fill_super(struct super_block *s, void *data, int silent)
 {
 	struct inode *inode;
+	struct pts_fs_info *fsi;
+	int error = -ENOMEM;
 
 	s->s_blocksize = 1024;
 	s->s_blocksize_bits = 10;
@@ -345,13 +310,18 @@ devpts_fill_super(struct super_block *s, void *data, int silent)
 	s->s_op = &devpts_sops;
 	s->s_time_gran = 1;
 
-	s->s_fs_info = new_pts_fs_info();
-	if (!s->s_fs_info)
+	fsi = new_pts_fs_info();
+	s->s_fs_info = fsi;
+	if (!fsi)
 		goto fail;
 
+	error = parse_mount_options(data, PARSE_MOUNT, &fsi->mount_opts);
+	if (error)
+		goto fail_kfree;
+
 	inode = new_inode(s);
 	if (!inode)
-		goto fail;
+		goto fail_kfree;
 	inode->i_ino = 1;
 	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
 	inode->i_mode = S_IFDIR | S_IRUGO | S_IXUGO | S_IWUSR;
@@ -360,87 +330,40 @@ devpts_fill_super(struct super_block *s, void *data, int silent)
 	set_nlink(inode, 2);
 
 	s->s_root = d_make_root(inode);
-	if (s->s_root)
-		return 0;
+	if (!s->s_root) {
+		printk(KERN_ERR "devpts: get root dentry failed\n");
+		goto fail_iput;
+	}
 
-	printk(KERN_ERR "devpts: get root dentry failed\n");
+	error = mknod_ptmx(s);
+	if (error)
+		goto fail_put_root;
+
+	return 0;
 
+fail_put_root:
+	dput(s->s_root);
+	s->s_root = NULL;
+fail_iput:
+	iput(inode);
+fail_kfree:
+	kfree(fsi);
 fail:
 	return -ENOMEM;
 }
 
-static int compare_init_pts_sb(struct super_block *s, void *p)
-{
-	if (devpts_mnt)
-		return devpts_mnt->mnt_sb == s;
-	return 0;
-}
 
 /*
  * devpts_mount()
  *
- *     If the '-o newinstance' mount option was specified, mount a new
- *     (private) instance of devpts.  PTYs created in this instance are
- *     independent of the PTYs in other devpts instances.
- *
- *     If the '-o newinstance' option was not specified, mount/remount the
- *     initial kernel mount of devpts.  This type of mount gives the
- *     legacy, single-instance semantics.
- *
- *     The 'newinstance' option is needed to support multiple namespace
- *     semantics in devpts while preserving backward compatibility of the
- *     current 'single-namespace' semantics. i.e all mounts of devpts
- *     without the 'newinstance' mount option should bind to the initial
- *     kernel mount, like mount_single().
- *
- *     Mounts with 'newinstance' option create a new, private namespace.
+ *     Mount a new (private) instance of devpts.  PTYs created in this
+ *     instance are independent of the PTYs in other devpts instances.
  *
- *     NOTE:
- *
- *     For single-mount semantics, devpts cannot use mount_single(),
- *     because mount_single()/sget() find and use the super-block from
- *     the most recent mount of devpts. But that recent mount may be a
- *     'newinstance' mount and mount_single() would pick the newinstance
- *     super-block instead of the initial super-block.
  */
 static struct dentry *devpts_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data)
 {
-	int error;
-	struct pts_mount_opts opts;
-	struct super_block *s;
-
-	error = parse_mount_options(data, PARSE_MOUNT, &opts);
-	if (error)
-		return ERR_PTR(error);
-
-	if (opts.newinstance)
-		s = sget(fs_type, NULL, set_anon_super, flags, NULL);
-	else
-		s = sget(fs_type, compare_init_pts_sb, set_anon_super, flags,
-			 NULL);
-
-	if (IS_ERR(s))
-		return ERR_CAST(s);
-
-	if (!s->s_root) {
-		error = devpts_fill_super(s, data, flags & MS_SILENT ? 1 : 0);
-		if (error)
-			goto out_undo_sget;
-		s->s_flags |= MS_ACTIVE;
-	}
-
-	memcpy(&(DEVPTS_SB(s))->mount_opts, &opts, sizeof(opts));
-
-	error = mknod_ptmx(s);
-	if (error)
-		goto out_undo_sget;
-
-	return dget(s->s_root);
-
-out_undo_sget:
-	deactivate_locked_super(s);
-	return ERR_PTR(error);
+	return mount_nodev(fs_type, flags, data, devpts_fill_super);
 }
 
 static void devpts_kill_sb(struct super_block *sb)
@@ -457,6 +380,40 @@ static struct file_system_type devpts_fs_type = {
 	.kill_sb	= devpts_kill_sb,
 };
 
+struct inode *devpts_redirect(struct file *filp)
+{
+	struct inode *inode;
+	struct file *filp2;
+
+	/* Is the inode already a devpts inode? */
+	inode = filp->f_dentry->d_inode;
+	if (filp->f_dentry->d_sb->s_magic == DEVPTS_SUPER_MAGIC)
+		goto out;
+
+	/* Is f_dentry->d_parent usable? */
+	inode = ERR_PTR(-ENODEV);
+	if (filp->f_vfsmnt->mnt_root == filp->f_dentry)
+		goto out;
+
+	/* Is there a devpts inode we can use instead? */
+	
+	filp2 = file_open_root(filp->f_dentry->d_parent, filp->f_vfsmnt,
+			       "pts/ptmx", O_PATH);
+	if (!IS_ERR(filp2)) {
+		if (filp2->f_dentry->d_sb->s_magic == DEVPTS_SUPER_MAGIC) {
+			struct path old;
+			old = filp->f_path;
+			filp->f_path = filp2->f_path;
+			inode = filp->f_dentry->d_inode;
+			path_get(&filp->f_path);
+			path_put(&old);
+		}
+		fput(filp2);
+	}
+out:
+	return inode;
+}
+
 /*
  * The normal naming convention is simply /dev/pts/<number>; this conforms
  * to the System V naming convention
@@ -474,8 +431,7 @@ retry:
 		return -ENOMEM;
 
 	mutex_lock(&allocated_ptys_lock);
-	if (pty_count >= pty_limit -
-			(fsi->mount_opts.newinstance ? pty_reserve : 0)) {
+	if (pty_count >= pty_limit - pty_reserve) {
 		mutex_unlock(&allocated_ptys_lock);
 		return -ENOSPC;
 	}
diff --git a/include/linux/devpts_fs.h b/include/linux/devpts_fs.h
index 2d539ae..fe2b41f 100644
--- a/include/linux/devpts_fs.h
+++ b/include/linux/devpts_fs.h
@@ -20,6 +20,7 @@
 
 #ifdef CONFIG_UNIX98_PTYS
 
+struct inode *devpts_redirect(struct file *filp);
 int devpts_new_index(struct inode *ptmx_inode);
 void devpts_kill_index(struct inode *ptmx_inode, int idx);
 /* mknod in devpts */
@@ -32,6 +33,10 @@ void devpts_pty_kill(struct tty_struct *tty);
 #else
 
 /* Dummy stubs in the no-pty case */
+static inline struct inode *devpts_redirect(struct file *filp)
+{
+	return ERR_PTR(-ENODEV);
+}
 static inline int devpts_new_index(struct inode *ptmx_inode) { return -EINVAL; }
 static inline void devpts_kill_index(struct inode *ptmx_inode, int idx) { }
 static inline int devpts_pty_new(struct inode *ptmx_inode,
-- 
1.7.5.4
