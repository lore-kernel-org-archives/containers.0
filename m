From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 09/10] Enable multiple instances of devpts
Date: Fri, 12 Sep 2008 10:53:22 -0700
Message-ID: <20080912175322.GJ17350@us.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080912174845.GA17350-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


From 4567a37856205a04cc0617e3fcc8ede36b25bcf5 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 9 Sep 2008 18:52:56 -0700
Subject: [PATCH 09/10] Enable multiple instances of devpts

To support containers, allow multiple instances of devpts filesystem, such
that indices of ptys allocated in one instance are independent of ptys
allocated in other instances of devpts.

But to preserve backward compatibility, enable this support for multiple
instances only if:

	- CONFIG_DEVPTS_MULTIPLE_INSTANCES is set to Y, and
	- '-o newinstance' mount option is specified while mounting devpts

See Documentation/fs/devpts.txt (next patch in series) for details.

To use multi-instance mount, a container startup script could:

	$ ns_exec -cm /bin/bash
	$ umount /dev/pts
	$ mount -t devpts -o newinstance lxcpts /dev/pts
	$ mount -o bind /dev/pts/ptmx /dev/ptmx
	$ sshd -p 1234

where 'ns_exec -cm /bin/bash' is calls clone() with CLONE_NEWNS flag and execs
/bin/bash in the child process. A pty created by the sshd is not visible in
the original mount of /dev/pts.

USER-SPACE-IMPACT:

	See Documentation/fs/devpts.txt (included in next patch) for user-space
	impact in multi-instance and mixed-mode operation.
TODO:
	- Update mount(8), pts(4) man pages. Highlight impact of not
	  redirecting /dev/ptmx to /dev/pts/ptmx after a multi-instance mount.

Implementation note:

	See comments in new get_sb_ref() function in fs/super.c on why
	get_sb_single() cannot be directly used.

Changelog[v5]:
	- Move get_sb_ref() definition to earlier patch

	- Move usage info to Documentation/filesystems/devpts.txt (next patch)

	- Make ptmx node even in init_pts_ns, now that default mode is 0000
	  (defined in earlier patch, enabled here).

	- Cache ptmx dentry and use to update mode during remount
	  (defined in earlier patch, enabled here).

	- Bugfix: explicitly ignore newinstance on remount (if newinstance was
	  specified on remount of initial mount, it would be ignored but
	  /proc/mounts would imply that the option was set)

Changelog[v4]:

	- Update patch description to address H. Peter Anvin's comments

	- Consolidate multi-instance mode code under new config token,
	  CONFIG_DEVPTS_MULTIPLE_INSTANCE.

	- Move usage-details from patch description to
	  Documentation/fs/devpts.txt

Changelog[v3]:
	- Rename new mount option to 'newinstance'

	- Create ptmx nodes only in 'newinstance' mounts

	- Bugfix: parse_mount_options() modifies @data but since we need to
	  parse the @data twice (once in devpts_get_sb() and once during
	  do_remount_sb()), parse a local copy of @data in devpts_get_sb().
	  (restructured code in devpts_get_sb() to fix this)

Changelog[v2]:
	- Support both single-mount and multiple-mount semantics and
	  provide '-onewmnt' option to select the semantics.

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/devpts/inode.c |  168 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 163 insertions(+), 5 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 6b56255..c54b010 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -48,10 +48,11 @@ struct pts_mount_opts {
 	gid_t   gid;
 	umode_t mode;
 	umode_t ptmxmode;
+	int newinstance;
 };
 
 enum {
-	Opt_uid, Opt_gid, Opt_mode, Opt_ptmxmode,
+	Opt_uid, Opt_gid, Opt_mode, Opt_ptmxmode, Opt_newinstance,
 	Opt_err
 };
 
@@ -61,6 +62,7 @@ static match_table_t tokens = {
 	{Opt_mode, "mode=%o"},
 #ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
 	{Opt_ptmxmode, "ptmxmode=%o"},
+	{Opt_newinstance, "newinstance"},
 #endif
 	{Opt_err, NULL}
 };
@@ -78,13 +80,15 @@ static inline struct pts_fs_info *DEVPTS_SB(struct super_block *sb)
 
 static inline struct super_block *pts_sb_from_inode(struct inode *inode)
 {
+#ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
 	if (inode->i_sb->s_magic == DEVPTS_SUPER_MAGIC)
 		return inode->i_sb;
-
+#endif
 	return devpts_mnt->mnt_sb;
 }
 
-static int parse_mount_options(char *data, struct pts_mount_opts *opts)
+static int parse_mount_options(char *data, int remount,
+		struct pts_mount_opts *opts)
 {
 	char *p;
 
@@ -95,6 +99,10 @@ static int parse_mount_options(char *data, struct pts_mount_opts *opts)
 	opts->mode    = DEVPTS_DEFAULT_MODE;
 	opts->ptmxmode = DEVPTS_DEFAULT_PTMX_MODE;
 
+	/* ignore newinstance on remount to avoid confusing show_options */
+	if (!remount)
+		opts->newinstance = 0;
+
 	while ((p = strsep(&data, ",")) != NULL) {
 		substring_t args[MAX_OPT_ARGS];
 		int token;
@@ -128,6 +136,10 @@ static int parse_mount_options(char *data, struct pts_mount_opts *opts)
 				return -EINVAL;
 			opts->ptmxmode = option & S_IALLUGO;
 			break;
+		case Opt_newinstance:
+			if (!remount)
+				opts->newinstance = 1;
+			break;
 #endif
 		default:
 			printk(KERN_ERR "devpts: called with bogus options\n");
@@ -180,6 +192,8 @@ static int mknod_ptmx(struct super_block *sb)
 
 	d_add(dentry, inode);
 
+	fsi->ptmx_dentry = dentry;
+
 	printk(KERN_DEBUG "Created ptmx node in devpts ino %lu\n",
 			inode->i_ino);
 
@@ -207,7 +221,7 @@ static int devpts_remount(struct super_block *sb, int *flags, char *data)
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
 	struct pts_mount_opts *opts = &fsi->mount_opts;
 
-	err = parse_mount_options(data, opts);
+	err = parse_mount_options(data, 1, opts);
 
 	/*
 	 * parse_mount_options() restores options to default values
@@ -232,6 +246,8 @@ static int devpts_show_options(struct seq_file *seq, struct vfsmount *vfs)
 	seq_printf(seq, ",mode=%03o", opts->mode);
 #ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
 	seq_printf(seq, ",ptmxmode=%03o", opts->ptmxmode);
+	if (opts->newinstance)
+		seq_printf(seq, ",newinstance");
 #endif
 
 	return 0;
@@ -298,12 +314,153 @@ fail:
 	return -ENOMEM;
 }
 
+#ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
+/*
+ * Safely parse the mount options in @data and update @opts.
+ *
+ * devpts ends up parsing options two times during mount, due to the
+ * two modes of operation it supports. The first parse occurs in
+ * devpts_get_sb() when determining the mode (single-instance or
+ * multi-instance mode). The second parse happens in devpts_remount()
+ * or new_pts_mount() depending on the mode.
+ *
+ * Parsing of options modifies the @data making subsequent parsing
+ * incorrect. So make a local copy of @data and parse it.
+ *
+ * Return: 0 On success, -errno on error
+ */
+static int safe_parse_mount_options(void *data, struct pts_mount_opts *opts)
+{
+	int rc;
+	void *datacp;
+
+	if (!data)
+		return 0;
+
+	/* Use kstrdup() ?  */
+	datacp = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!datacp)
+		return -ENOMEM;
+
+	memcpy(datacp, data, PAGE_SIZE);
+	rc = parse_mount_options((char *)datacp, 0, opts);
+	kfree(datacp);
+
+	return rc;
+}
+
+/*
+ * Mount a new (private) instance of devpts.  PTYs created in this
+ * instance are independent of the PTYs in other devpts instances.
+ */
+static int new_pts_mount(struct file_system_type *fs_type, int flags,
+		void *data, struct vfsmount *mnt)
+{
+	int err;
+	struct pts_fs_info *fsi;
+	struct pts_mount_opts *opts;
+
+	printk(KERN_NOTICE "devpts: newinstance mount\n");
+
+	err = get_sb_nodev(fs_type, flags, data, devpts_fill_super, mnt);
+	if (err)
+		return err;
+
+	fsi = DEVPTS_SB(mnt->mnt_sb);
+	opts = &fsi->mount_opts;
+
+	err = parse_mount_options(data, 0, opts);
+	if (err)
+		goto fail;
+
+	err = mknod_ptmx(mnt->mnt_sb);
+	if (err)
+		goto fail;
+
+	return 0;
+
+fail:
+	dput(mnt->mnt_sb->s_root);
+	deactivate_super(mnt->mnt_sb);
+	return err;
+}
+
+/*
+ * Check if 'newinstance' mount option was specified in @data.
+ *
+ * Return: -errno  	on error (eg: invalid mount options specified)
+ * 	 : 1 		if 'newinstance' mount option was specified
+ * 	 : 0 		if 'newinstance' mount option was NOT specified
+ */
+static int is_new_instance_mount(void *data)
+{
+	int rc;
+	struct pts_mount_opts opts;
+
+	if (!data)
+		return 0;
+
+	rc = safe_parse_mount_options(data, &opts);
+	if (!rc)
+		rc = opts.newinstance;
+
+	return rc;
+}
+
+/*
+ * Mount or remount the initial kernel mount of devpts. This type of
+ * mount maintains the legacy, single-instance semantics, while the
+ * kernel still allows multiple-instances.
+ */
+static int init_pts_mount(struct file_system_type *fs_type, int flags,
+		void *data, struct vfsmount *mnt)
+{
+	int err;
+
+	if (!devpts_mnt) {
+		err = get_sb_single(fs_type, flags, data, devpts_fill_super,
+				mnt);
+
+		err = mknod_ptmx(mnt->mnt_sb);
+		if (err) {
+			dput(mnt->mnt_sb->s_root);
+			deactivate_super(mnt->mnt_sb);
+		} else
+			devpts_mnt = mnt;
+
+		return err;
+	}
+
+	return get_sb_ref(devpts_mnt->mnt_sb, flags, data, mnt);
+}
+
 static int devpts_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
 {
+	int new;
+
+	new = is_new_instance_mount(data);
+	if (new < 0)
+		return new;
+
+	if (new)
+		return new_pts_mount(fs_type, flags, data, mnt);
+
+	return init_pts_mount(fs_type, flags, data, mnt);
+}
+#else
+/*
+ * This supports only the legacy single-instance semantics (no
+ * multiple-instance semantics)
+ */
+static int devpts_get_sb(struct file_system_type *fs_type, int flags,
+		const char *dev_name, void *data, struct vfsmount *mnt)
+{
 	return get_sb_single(fs_type, flags, data, devpts_fill_super, mnt);
 }
 
+#endif
+
 static void devpts_kill_sb(struct super_block *sb)
 {
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
@@ -431,8 +588,9 @@ void devpts_pty_kill(struct tty_struct *tty)
 	if (dentry && !IS_ERR(dentry)) {
 		inode->i_nlink--;
 		d_delete(dentry);
-		dput(dentry);
+		dput(dentry);		// d_lookup in devpts_pty_new
 	}
+	dput(dentry);			// d_find_alias above
 
 	mutex_unlock(&root->d_inode->i_mutex);
 }
-- 
1.5.2.5
