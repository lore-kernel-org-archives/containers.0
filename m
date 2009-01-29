From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 2/5] Parse mount options just once and copy them to
	super block
Date: Wed, 28 Jan 2009 22:46:12 -0800
Message-ID: <20090129064612.GC23160@us.ibm.com>
References: <20090129064259.GA23160@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090129064259.GA23160-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Cc: "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 27 Jan 2009 23:15:47 -0800
Subject: [RFC][PATCH 2/5] Parse mount options just once and copy them to super block

Since all the mount option parsing is done in devpts, we could do it
just once and pass it around in devpts functions and eventually store
it in the super block.
---
 fs/devpts/inode.c |   99 +++++++++++-----------------------------------------
 1 files changed, 21 insertions(+), 78 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index de15e73..8e00779 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -325,49 +325,14 @@ static int compare_init_pts_sb(struct super_block *s, void *p)
 }
 
 /*
- * Safely parse the mount options in @data and update @opts.
- *
- * devpts ends up parsing options two times during mount, due to the
- * two modes of operation it supports. The first parse occurs in
- * devpts_get_sb() when determining the mode (single-instance or
- * multi-instance mode). The second parse happens in devpts_remount()
- * or new_pts_mount() depending on the mode.
- *
- * Parsing of options modifies the @data making subsequent parsing
- * incorrect. So make a local copy of @data and parse it.
- *
- * Return: 0 On success, -errno on error
- */
-static int safe_parse_mount_options(void *data, struct pts_mount_opts *opts)
-{
-	int rc;
-	void *datacp;
-
-	if (!data)
-		return 0;
-
-	/* Use kstrdup() ?  */
-	datacp = kmalloc(PAGE_SIZE, GFP_KERNEL);
-	if (!datacp)
-		return -ENOMEM;
-
-	memcpy(datacp, data, PAGE_SIZE);
-	rc = parse_mount_options((char *)datacp, PARSE_MOUNT, opts);
-	kfree(datacp);
-
-	return rc;
-}
-
-/*
  * Mount a new (private) instance of devpts.  PTYs created in this
  * instance are independent of the PTYs in other devpts instances.
  */
 static int new_pts_mount(struct file_system_type *fs_type, int flags,
-		void *data, struct vfsmount *mnt)
+		void *data, struct pts_mount_opts *opts, struct vfsmount *mnt)
 {
 	int err;
 	struct pts_fs_info *fsi;
-	struct pts_mount_opts *opts;
 
 	printk(KERN_NOTICE "devpts: newinstance mount\n");
 
@@ -376,11 +341,7 @@ static int new_pts_mount(struct file_system_type *fs_type, int flags,
 		return err;
 
 	fsi = DEVPTS_SB(mnt->mnt_sb);
-	opts = &fsi->mount_opts;
-
-	err = parse_mount_options(data, PARSE_MOUNT, opts);
-	if (err)
-		goto fail;
+	memcpy(&fsi->mount_opts, opts, sizeof(opts));
 
 	err = mknod_ptmx(mnt->mnt_sb);
 	if (err)
@@ -396,28 +357,6 @@ fail:
 }
 
 /*
- * Check if 'newinstance' mount option was specified in @data.
- *
- * Return: -errno  	on error (eg: invalid mount options specified)
- * 	 : 1 		if 'newinstance' mount option was specified
- * 	 : 0 		if 'newinstance' mount option was NOT specified
- */
-static int is_new_instance_mount(void *data)
-{
-	int rc;
-	struct pts_mount_opts opts;
-
-	if (!data)
-		return 0;
-
-	rc = safe_parse_mount_options(data, &opts);
-	if (!rc)
-		rc = opts.newinstance;
-
-	return rc;
-}
-
-/*
  * get_init_pts_sb()
  *
  *     This interface is needed to support multiple namespace semantics in
@@ -439,10 +378,9 @@ static int is_new_instance_mount(void *data)
  *     presence of the private namespace (i.e 'newinstance') super-blocks.
  */
 static int get_init_pts_sb(struct file_system_type *fs_type, int flags,
-		void *data, struct vfsmount *mnt)
+		void *data, struct pts_mount_opts *opts, struct vfsmount *mnt)
 {
 	struct super_block *s;
-	struct pts_mount_opts *opts;
 	struct pts_fs_info *fsi;
 	int error;
 
@@ -460,11 +398,12 @@ static int get_init_pts_sb(struct file_system_type *fs_type, int flags,
 		}
 		s->s_flags |= MS_ACTIVE;
 	}
-	fsi = DEVPTS_SB(s);
-	opts = &fsi->mount_opts;
-	parse_mount_options(data, PARSE_REMOUNT, opts);
 
 	simple_set_mnt(mnt, s);
+
+	fsi = DEVPTS_SB(mnt->mnt_sb);
+	memcpy(&fsi->mount_opts, opts, sizeof(opts));
+
 	return 0;
 }
 
@@ -474,11 +413,11 @@ static int get_init_pts_sb(struct file_system_type *fs_type, int flags,
  * kernel still allows multiple-instances.
  */
 static int init_pts_mount(struct file_system_type *fs_type, int flags,
-		void *data, struct vfsmount *mnt)
+		void *data, struct pts_mount_opts *opts, struct vfsmount *mnt)
 {
 	int err;
 
-	err = get_init_pts_sb(fs_type, flags, data, mnt);
+	err = get_init_pts_sb(fs_type, flags, data, opts, mnt);
 	if (err)
 		return err;
 
@@ -495,17 +434,21 @@ static int init_pts_mount(struct file_system_type *fs_type, int flags,
 static int devpts_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
 {
-	int new;
-
-	new = is_new_instance_mount(data);
-	if (new < 0)
-		return new;
+	int error;
+	struct pts_mount_opts opts = { 0, }; // check
 
-	if (new)
-		return new_pts_mount(fs_type, flags, data, mnt);
+	if (data) {
+		error = parse_mount_options(data, PARSE_MOUNT, &opts);
+		if (error)
+			return error;
+	}
 
-	return init_pts_mount(fs_type, flags, data, mnt);
+	if (opts.newinstance)
+		return new_pts_mount(fs_type, flags, data, &opts, mnt);
+	else
+		return init_pts_mount(fs_type, flags, data, &opts, mnt);
 }
+
 #else
 /*
  * This supports only the legacy single-instance semantics (no
-- 
1.5.2.5
