From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 11/11][v3]: Enable multiple instances of devpts
Date: Wed, 3 Sep 2008 22:35:51 -0700
Message-ID: <20080904053551.GL3680@us.ibm.com>
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
Subject: [PATCH 11/11]: Enable multiple instances of devpts

To support containers, allow multiple instances of devpts filesystem.
such that indices of ptys allocated in one instance are independent
of ptys allocated in other instances of devpts.

But to preserve backward compatibility, enable this support for multiple
instances under the new mount option, '-o newinstance'.

IOW, devpts must support both single-mount and multiple-mount semantics.
If the filesystem is mounted without the 'newinstance' option (as in current
start-up scripts) the new mount simply binds to the initial kernel mount
of devpts and thus current behavior is preserved.

If the 'newinstance' option is specified (by new startup scripts) a new
instance of the devpts fs is created and any ptys created in this instance
are independent of the ptys in other mounts of devpts.

Eg: A container startup script could do the following:

	$ ns_exec -cm /bin/bash
	$ umount /dev/pts
	$ mount -t devpts -o newinstance lxcpts /dev/pts
	$ mount -o bind /dev/pts/ptmx /dev/ptmx
	$ sshd -p 6710

where 'ns_exec -cm /bin/bash' is calls clone() with CLONE_NEWNS flag
and execs /bin/bash in the child process.  A pty created by the sshd
is not visible in the original mount of /dev/pts.

USER-SPACE-IMPACT:

	In the 'legacy mode' (i.e '-o newinstance' option is never specified),
	there should be no change in behavior.
	
	In multi-instance mode (i.e '-o newinstance mount option is specified
	at least once) following user-space issues should be noted.
	
	1. The multi-instance mounts have a 'ptmx' node created/destroyed
	   automatically when devpts is mounted/unmounted. The legacy-mode
	   mounts do not have this node.

	2. To effectively use the multi-instance mode, applications/libraries
	    should, open "/dev/pts/ptmx" instead of "/dev/ptmx" but obviously
	    this would fail in the legacy mode.
	    
	    To work in either legacy or multi-instance mode, applications
	    could replace:

		master_fd = open("/dev/ptmx", flags);

	    with

		if (access("/dev/pts/ptmx", A_OK))
			master_fd = open("/dev/pts/ptmx", flags);
		else
			master_fd = open("/dev/ptmx", flags);

	   To maintain backward compatibility, administrators or startup
	   scripts can "redirect" open of /dev/ptmx to /dev/pts/ptmx in
	   multi-instance mode using a bind mount.

		mount -t devpts -o newinstance devpts /dev/pts
		mount -o bind /dev/pts/ptmx /dev/ptmx

	3. A multi-instance mount that is not accompanied by above bind mount
	   would result in an unusable/unreachable tty to applications that
	   open "/dev/ptmx". i.e

	   	mount -t devpts -o newinstance lxcpts /dev/pts

	   followed by:

		open("/dev/ptmx")

	    would create a pty, say /dev/pts/7, in the initial kernel mount.
	    But /dev/pts/7 would be invisible in the new mount.

	    TODO:

		- We need to document this clearly somewhere (or can the kernel
		  automatically establish the bind mount).
	   
	4. The permissions for "/dev/pts/ptmx" node should be specified when
	   mounting /dev/pts, using the '-o ptmxmode=%o' mount option (default
	   is 0666). 
	   
	   	mount -t devpts -o newinstance -o ptmxmode=0644 devpts /dev/pts

	   The permissions can be later be changed as usual with 'chmod'.

	   	chmod 666 /dev/pts/ptmx

TODO:

	- Document impact of not bind mounting /dev/pts/ptmx after a 
	  multi-instance mount

	- Can we print some friendly message either from kernel or in common
	  user-space commands when this disconnect happens ?

	  
Implementation note:

	See comments in new get_sb_ref() function in fs/super.c on why
	get_sb_single() cannot be directly used.

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
 fs/devpts/inode.c  |  162 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/super.c         |   43 ++++++++++++++
 include/linux/fs.h |    2 
 3 files changed, 203 insertions(+), 4 deletions(-)

Index: linux-2.6.27-rc3-tty/fs/devpts/inode.c
===================================================================
--- linux-2.6.27-rc3-tty.orig/fs/devpts/inode.c	2008-09-03 21:34:36.000000000 -0700
+++ linux-2.6.27-rc3-tty/fs/devpts/inode.c	2008-09-03 21:53:59.000000000 -0700
@@ -42,10 +42,11 @@ struct pts_mount_opts {
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
 
@@ -54,6 +55,7 @@ static match_table_t tokens = {
 	{Opt_gid, "gid=%u"},
 	{Opt_mode, "mode=%o"},
 	{Opt_ptmxmode, "ptmxmode=%o"},
+	{Opt_newinstance, "newinstance"},
 	{Opt_err, NULL}
 };
 
@@ -85,6 +87,7 @@ static int parse_mount_options(char *dat
 	opts->gid     = 0;
 	opts->mode    = DEVPTS_DEFAULT_MODE;
 	opts->ptmxmode = DEVPTS_DEFAULT_PTMX_MODE;
+	opts->newinstance = 0;
 
 	while ((p = strsep(&data, ",")) != NULL) {
 		substring_t args[MAX_OPT_ARGS];
@@ -118,6 +121,9 @@ static int parse_mount_options(char *dat
 				return -EINVAL;
 			opts->ptmxmode = option & S_IALLUGO;
 			break;
+		case Opt_newinstance:
+			opts->newinstance = 1;
+			break;
 		default:
 			printk(KERN_ERR "devpts: called with bogus options\n");
 			return -EINVAL;
@@ -127,6 +133,53 @@ static int parse_mount_options(char *dat
 	return 0;
 }
 
+/*
+ * Safely parse the mount options in @data and update @opts.
+ *
+ * devpts ends up parsing options several times during mount, due to the
+ * two modes of operation it supports.
+ *
+ * The initial mount of single-instance mode parses options twwo times:
+ * 	- in devpts_get_sb() to determine the type of mount
+ * 	- in devpts_remount (when get_sb_single() calls do_remount_sb())
+ *
+ * Subsequent mounts in single-instance mode parses options two times:
+ * 	- in devpts_get_sb() to determine type of mount
+ * 	- in devpts_remount (when get_sb_single() calls do_remount_sb())
+ *
+ * Multi-instance mount parses options two times:
+ * 	- in devpts_get_sb() to determine type of mount
+ * 	- in new_pts_mount() to record options
+ *
+ * Since the locations that we parse the options can occur from more than
+ * one place, there does not seem to be a way to parse once and save/use
+ * the results.
+ *
+ * As if this was not messy enough, parsing of options modifies the @data
+ * making subsequent parsing incorrect. Hence the safe_parse_mount_options().
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
+	rc = parse_mount_options((char *)datacp, opts);
+	kfree(datacp);
+
+	return rc;
+}
+
 static int devpts_remount(struct super_block *sb, int *flags, char *data)
 {
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
@@ -145,7 +198,10 @@ static int devpts_show_options(struct se
 	if (opts->setgid)
 		seq_printf(seq, ",gid=%u", opts->gid);
 	seq_printf(seq, ",mode=%03o", opts->mode);
-	seq_printf(seq, ",ptmxmode=%03o", opts->ptmxmode);
+	if (opts->newinstance) {
+		seq_printf(seq, ",ptmxmode=%03o", opts->ptmxmode);
+		seq_printf(seq, ",newinstance");
+	}
 
 	return 0;
 }
@@ -259,10 +315,107 @@ int mknod_ptmx(struct super_block *sb)
 	return 0;
 }
 
+/*
+ * Mount or remount the initial kernel mount of devpts. This type of
+ * mount maintains the legacy, single-instance semantics.
+ */
+static int init_pts_mount(struct file_system_type *fs_type, int flags,
+		void *data, struct vfsmount *mnt)
+{
+	int err;
+
+	if (!devpts_mnt) {
+		err = get_sb_single(fs_type, flags, data, devpts_fill_super,
+				mnt);
+		if (!err)
+			devpts_mnt = mnt;
+
+		return err;
+	}
+
+	return get_sb_ref(devpts_mnt->mnt_sb, flags, data, mnt);
+}
+
+/*
+ * Mount a new (private) instance of devpts. This is selected via
+ * the '-o newinstance' mount option and the PTYs created in this
+ * instance are independent of the PTYs in other devpts instances.
+ *
+ * This type of mount is used in containers to provide isolated PTYs.
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
+	/*
+	 * Parse mount options here rather than in devpts_fill_super()
+	 * to avoid unnecessary repetition of the parsing in single-
+	 * instance mode.
+	 */
+	fsi = DEVPTS_SB(mnt->mnt_sb);
+	opts = &fsi->mount_opts;
+
+	err = parse_mount_options(data, opts);
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
+
 static int devpts_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
 {
-	return get_sb_single(fs_type, flags, data, devpts_fill_super, mnt);
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
 }
 
 
@@ -393,8 +546,9 @@ void devpts_pty_kill(struct tty_struct *
 	if (dentry && !IS_ERR(dentry)) {
 		inode->i_nlink--;
 		d_delete(dentry);
-		dput(dentry);
+		dput(dentry);		// d_lookup in devpts_pty_new
 	}
+	dput(dentry);			// d_find_alias above
 
 	mutex_unlock(&root->d_inode->i_mutex);
 }
Index: linux-2.6.27-rc3-tty/fs/super.c
===================================================================
--- linux-2.6.27-rc3-tty.orig/fs/super.c	2008-09-03 21:28:11.000000000 -0700
+++ linux-2.6.27-rc3-tty/fs/super.c	2008-09-03 21:59:42.000000000 -0700
@@ -883,6 +883,49 @@ int get_sb_single(struct file_system_typ
 
 EXPORT_SYMBOL(get_sb_single);
 
+int get_sb_ref(struct super_block *sb, int flags, void *data,
+		struct vfsmount *mnt)
+{
+	int err;
+
+	/*
+	 * UGLY:
+	 *
+	 * This is needed to support multiple mounts in devpts while
+	 * preserving backward compatibility of the current 'single-mount'
+	 * semantics.
+	 *
+	 * devpts cannot simply use get_sb_single(), bc get_sb_single() or
+	 * more specifically, sget() finds the most recent mount of devpts.
+	 * But that recent mount may not the be initial kernel mount (user
+	 * may have mounted with the '-onewinstance' option since the initial
+	 * mount and get_sb_single() would pick that super-block).
+	 *
+	 * Assuming caller has a valid/initialized sb, unroll essentials of
+	 * get_sb_single() here.
+	 */
+	spin_lock(&sb_lock);
+
+	if (!grab_super(sb)) {
+		/*
+		 * TODO: anymore cleanup ?
+		 */
+		return -EAGAIN;
+	}
+
+	err = do_remount_sb(sb, flags, data, 0);
+	if (err) {
+		/*
+		 * (don't deactivate_super() here - its from initial pts mount)
+		 *
+		 * TODO: anymore cleanup ?
+		 */
+		up_write(&sb->s_umount);
+		return err;
+	}
+	return simple_set_mnt(mnt, sb);
+}
+
 struct vfsmount *
 vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void *data)
 {
Index: linux-2.6.27-rc3-tty/include/linux/fs.h
===================================================================
--- linux-2.6.27-rc3-tty.orig/include/linux/fs.h	2008-09-03 21:28:11.000000000 -0700
+++ linux-2.6.27-rc3-tty/include/linux/fs.h	2008-09-03 21:34:47.000000000 -0700
@@ -1516,6 +1516,8 @@ extern int get_sb_nodev(struct file_syst
 	int flags, void *data,
 	int (*fill_super)(struct super_block *, void *, int),
 	struct vfsmount *mnt);
+extern int get_sb_ref(struct super_block *sb, int flags, void *data,
+	struct vfsmount *mnt);
 void generic_shutdown_super(struct super_block *sb);
 void kill_block_super(struct super_block *sb);
 void kill_anon_super(struct super_block *sb);
