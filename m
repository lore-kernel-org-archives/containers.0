From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 8/8]: Enable multiple mounts of devpts
Date: Wed, 20 Aug 2008 19:29:32 -0700
Message-ID: <20080821022932.GH29658@us.ibm.com>
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
Subject: [RFC][PATCH 8/8]: Enable multiple mounts of devpts

To support containers, allow multiple instances of devpts filesystem.

But to preserve backward compatibility, provide this support for
multiple-mounts under the new mount option, '-o newmnt'.

IOW, devpts must support both single-mount and multiple-mount semantics.
If the filesystem is mounted without the 'newmnt' option (as in current
start-up scripts) the new mount simply binds to the initial kernel mount
of devpts and thus current behavior is preserved.

If the 'newmnt' option is specified (by new container-startup scripts) a
new instance of the devpts fs is created and any ptys created in this
instance are independent of the ptys in other mounts of devpts.

(Hmm would 'private-mount' be a better name as in MAP_PRIVATE) ?

Eg: A container startup script could do the following:

	$ ns_exec -cm /bin/bash
	$ umount /dev/pts
	$ mount -t devpts -o newmnt lxcpts /dev/pts
	$ sshd -p 6710

where 'ns_exec -cm /bin/bash' is calls clone() with CLONE_NEWNS flag
and execs /bin/bash in the child process.  A pty created by the sshd
is not visible in the original mount of /dev/pts.

USER-SPACE-IMPACT:

	The -onewmnt option is meant to minimize userspace impact. Following
	are known impacts.

	1. /dev/ptmx symlink to pts/ptmx. This is optional if only single-
	   mount semantics is desired but is required if multi-mount semantics.

	2. /dev/pts fs has a new entry (ptmx device node) that is created/
	   destroyed automatically.

	TODO: Others impacts ?

Implementation note:

	See comments in new get_sb_ref() function in fs/super.c
	(yes fs/super.c !) on why get_sb_single() cannot be
	directly used.


Changelog[v2]:
	Support both single-mount and multiple-mount semantics and
	provide '-onewmnt' option to select the semantics.

---
 fs/devpts/inode.c  |   43 +++++++++++++++++++++++++++++++++++++++++--
 fs/super.c         |   44 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h |    2 ++
 3 files changed, 87 insertions(+), 2 deletions(-)

Index: linux-2.6.26-rc8-mm1/fs/devpts/inode.c
===================================================================
--- linux-2.6.26-rc8-mm1.orig/fs/devpts/inode.c	2008-08-20 17:44:29.000000000 -0700
+++ linux-2.6.26-rc8-mm1/fs/devpts/inode.c	2008-08-20 17:50:42.000000000 -0700
@@ -41,10 +41,11 @@ struct pts_mount_opts {
 	gid_t   gid;
 	umode_t mode;
 	umode_t ptmx_mode;
+	int newmnt;
 };
 
 enum {
-	Opt_uid, Opt_gid, Opt_mode, Opt_ptmx_mode,
+	Opt_uid, Opt_gid, Opt_mode, Opt_ptmx_mode, Opt_newmnt,
 	Opt_err
 };
 
@@ -53,6 +54,7 @@ static match_table_t tokens = {
 	{Opt_gid, "gid=%u"},
 	{Opt_mode, "mode=%o"},
 	{Opt_ptmx_mode, "ptmx_mode=%o"},
+	{ Opt_newmnt, "newmnt" },
 	{Opt_err, NULL}
 };
 
@@ -84,6 +86,7 @@ static int parse_mount_options(char *dat
 	opts->gid     = 0;
 	opts->mode    = DEVPTS_DEFAULT_MODE;
 	opts->ptmx_mode = DEVPTS_DEFAULT_PTMX_MODE;
+	opts->newmnt = 0;
 
 	while ((p = strsep(&data, ",")) != NULL) {
 		substring_t args[MAX_OPT_ARGS];
@@ -117,6 +120,9 @@ static int parse_mount_options(char *dat
 				return -EINVAL;
 			opts->ptmx_mode = option & S_IALLUGO;
 			break;
+		case Opt_newmnt:
+			opts->newmnt = 1;
+			break;
 		default:
 			printk(KERN_ERR "devpts: called with bogus options\n");
 			return -EINVAL;
@@ -145,6 +151,8 @@ static int devpts_show_options(struct se
 		seq_printf(seq, ",gid=%u", opts->gid);
 	seq_printf(seq, ",mode=%03o", opts->mode);
 	seq_printf(seq, ",ptmx_mode=%03o", opts->ptmx_mode);
+	if (opts->newmnt)
+		seq_printf(seq, ",newmnt");
 
 	return 0;
 }
@@ -256,12 +264,43 @@ int mknod_ptmx(struct super_block *sb)
 	return 0;
 }
 
+static int mount_init_pts(struct file_system_type *fs_type, int flags,
+		void *data, struct vfsmount *mnt)
+{
+	int err;
+
+	if (!devpts_mnt) {
+		err = get_sb_single(fs_type, flags, data, devpts_fill_super,
+			mnt);
+		if (!err)
+			devpts_mnt = mnt;
+		return err;
+	}
+
+	err = get_sb_ref(devpts_mnt->mnt_sb, flags, data, mnt);
+
+	printk(KERN_ERR "mount_init_pts(): returning %d\n", err);
+	return err;
+}
+
 static int devpts_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
 {
 	int err;
+	struct pts_mount_opts opts;
+
+	if (parse_mount_options((char *)data, &opts))
+		return -EINVAL;
+
+	printk(KERN_ERR "devpts_get_sb(): newmnt option is %d\n", opts.newmnt);
+
+	if (opts.newmnt) {
+		err = get_sb_nodev(fs_type, flags, data, devpts_fill_super,
+				mnt);
+	} else {
+		err = mount_init_pts(fs_type, flags, data, mnt);
+	}
 
-	err = get_sb_single(fs_type, flags, data, devpts_fill_super, mnt);
 	if (err)
 		return err;
 
Index: linux-2.6.26-rc8-mm1/fs/super.c
===================================================================
--- linux-2.6.26-rc8-mm1.orig/fs/super.c	2008-08-20 17:44:29.000000000 -0700
+++ linux-2.6.26-rc8-mm1/fs/super.c	2008-08-20 18:07:38.000000000 -0700
@@ -883,6 +883,50 @@ int get_sb_single(struct file_system_typ
 
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
+	 * may mounted with the '-onewmnt' option since the initial mount
+	 * and get_sb_single() would pick that super-block).
+	 *
+	 * Caller is responsible to ensure that 'sb' is valid initialized.
+	 * So armed with that fact, unroll essentials of get_sb_single()
+	 * here.
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
Index: linux-2.6.26-rc8-mm1/include/linux/fs.h
===================================================================
--- linux-2.6.26-rc8-mm1.orig/include/linux/fs.h	2008-08-20 17:46:27.000000000 -0700
+++ linux-2.6.26-rc8-mm1/include/linux/fs.h	2008-08-20 17:47:04.000000000 -0700
@@ -1522,6 +1522,8 @@ extern int get_sb_nodev(struct file_syst
 	int flags, void *data,
 	int (*fill_super)(struct super_block *, void *, int),
 	struct vfsmount *mnt);
+extern int get_sb_ref(struct super_block *sb, int flags, void *data,
+	struct vfsmount *mnt);
 void generic_shutdown_super(struct super_block *sb);
 void kill_block_super(struct super_block *sb);
 void kill_anon_super(struct super_block *sb);
