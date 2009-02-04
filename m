From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [v2][PATCH 5/5] Merge code for single and multiple-instance mounts
Date: Tue, 3 Feb 2009 20:38:13 -0800
Message-ID: <20090204043813.GE26202@us.ibm.com>
References: <20090204043516.GB25963@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090204043516.GB25963-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, hch-jcswGhMUV9g@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Wed, 28 Jan 2009 19:11:15 -0800
Subject: [v2][PATCH 5/5] Merge code for single and multiple-instance mounts

new_pts_mount() (including the get_sb_nodev()), shares a lot of code
with init_pts_mount(). The only difference between them is the 'test-super'
function passed into sget().

Move all common code into devpts_get_sb() and remove the new_pts_mount() and
init_pts_mount() functions,

Changelog[v2]:
	(Christoph Hellwig): Merge code in 'do_pts_mount()' into devpts_get_sb()

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/devpts/inode.c |  122 +++++++++++++++++++---------------------------------
 1 files changed, 45 insertions(+), 77 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index c821c9a..6438782 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -325,87 +325,38 @@ static int compare_init_pts_sb(struct super_block *s, void *p)
 }
 
 /*
- * Mount a new (private) instance of devpts.  PTYs created in this
- * instance are independent of the PTYs in other devpts instances.
- */
-static int new_pts_mount(struct file_system_type *fs_type, int flags,
-		void *data, struct pts_mount_opts *opts, struct vfsmount *mnt)
-{
-	int err;
-	struct pts_fs_info *fsi;
-
-	printk(KERN_NOTICE "devpts: newinstance mount\n");
-
-	err = get_sb_nodev(fs_type, flags, data, devpts_fill_super, mnt);
-	if (err)
-		return err;
-
-	fsi = DEVPTS_SB(mnt->mnt_sb);
-	memcpy(&fsi->mount_opts, opts, sizeof(opts));
-
-	return 0;
-}
-
-/*
- * init_pts_mount()
+ * devpts_get_sb()
+ *
+ *     If the '-o newinstance' mount option was specified, mount a new
+ *     (private) instance of devpts.  PTYs created in this instance are
+ *     independent of the PTYs in other devpts instances.
+ *
+ *     If the '-o newinstance' option was not specified, mount/remount the
+ *     initial kernel mount of devpts.  This type of mount gives the
+ *     legacy, single-instance semantics.
  *
- *     Mount or remount the initial kernel mount of devpts. This type of
- *     mount maintains the legacy, single-instance semantics, while the
- *     kernel still allows multiple-instances.
+ *     The 'newinstance' option is needed to support multiple namespace
+ *     semantics in devpts while preserving backward compatibility of the
+ *     current 'single-namespace' semantics. i.e all mounts of devpts
+ *     without the 'newinstance' mount option should bind to the initial
+ *     kernel mount, like get_sb_single().
  *
- *     This interface is needed to support multiple namespace semantics in
- *     devpts while preserving backward compatibility of the current 'single-
- *     namespace' semantics. i.e all mounts of devpts without the 'newinstance'
- *     mount option should bind to the initial kernel mount, like
- *     get_sb_single().
+ *     Mounts with 'newinstance' option create a new, private namespace.
  *
- *     Mounts with 'newinstance' option create a new private namespace.
+ *     NOTE:
  *
- *     But for single-mount semantics, devpts cannot use get_sb_single(),
+ *     For single-mount semantics, devpts cannot use get_sb_single(),
  *     because get_sb_single()/sget() find and use the super-block from
  *     the most recent mount of devpts. But that recent mount may be a
  *     'newinstance' mount and get_sb_single() would pick the newinstance
  *     super-block instead of the initial super-block.
- *
- *     This interface is identical to get_sb_single() except that it
- *     consistently selects the 'single-namespace' superblock even in the
- *     presence of the private namespace (i.e 'newinstance') super-blocks.
  */
-static int init_pts_mount(struct file_system_type *fs_type, int flags,
-		void *data, struct pts_mount_opts *opts, struct vfsmount *mnt)
-{
-	struct super_block *s;
-	struct pts_fs_info *fsi;
-	int error;
-
-	s = sget(fs_type, compare_init_pts_sb, set_anon_super, NULL);
-	if (IS_ERR(s))
-		return PTR_ERR(s);
-
-	if (!s->s_root) {
-		s->s_flags = flags;
-		error = devpts_fill_super(s, data, flags & MS_SILENT ? 1 : 0);
-		if (error) {
-			up_write(&s->s_umount);
-			deactivate_super(s);
-			return error;
-		}
-		s->s_flags |= MS_ACTIVE;
-	}
-
-	simple_set_mnt(mnt, s);
-
-	fsi = DEVPTS_SB(mnt->mnt_sb);
-	memcpy(&fsi->mount_opts, opts, sizeof(opts));
-
-	return 0;
-}
-
 static int devpts_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
 {
 	int error;
 	struct pts_mount_opts opts;
+	struct super_block *s;
 
 	memset(&opts, 0, sizeof(opts)); 
 	if (data) {
@@ -414,24 +365,41 @@ static int devpts_get_sb(struct file_system_type *fs_type,
 			return error;
 	}
 
-	if (opts.newinstance)
-		error = new_pts_mount(fs_type, flags, data, &opts, mnt);
-	else
-		error = init_pts_mount(fs_type, flags, data, &opts, mnt);
+	if (opts.newinstance) {
+		printk(KERN_NOTICE "devpts: newinstance mount\n");
+		s = sget(fs_type, NULL, set_anon_super, NULL);
+	} else {
+		printk(KERN_NOTICE "devpts: single-instance mount\n");
+		s = sget(fs_type, compare_init_pts_sb, set_anon_super, NULL);
+	}
 
-	if (error)
-		return error;
+	if (IS_ERR(s))
+		return PTR_ERR(s);
 
-	error = mknod_ptmx(mnt->mnt_sb);
+	if (!s->s_root) {
+		s->s_flags = flags;
+		error = devpts_fill_super(s, data, flags & MS_SILENT ? 1 : 0);
+		if (error)
+			goto out_undo_sget;
+		s->s_flags |= MS_ACTIVE;
+	}
+
+	simple_set_mnt(mnt, s);
+
+	memcpy(&(DEVPTS_SB(s))->mount_opts, &opts, sizeof(opts));
+
+	error = mknod_ptmx(s);
 	if (error)
 		goto out_dput;
 
 	return 0;
 
 out_dput:
-	dput(mnt->mnt_sb->s_root);
-	up_write(&mnt->mnt_sb->s_umount);
-	deactivate_super(mnt->mnt_sb);
+	dput(s->s_root);
+
+out_undo_sget:
+	up_write(&s->s_umount);
+	deactivate_super(s);
 	return error;
 }
 
-- 
1.5.2.5
