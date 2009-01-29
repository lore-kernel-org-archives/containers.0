From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 5/5] Merge code for single and multiple-instance mounts
Date: Wed, 28 Jan 2009 22:47:53 -0800
Message-ID: <20090129064753.GF23160@us.ibm.com>
References: <20090129064259.GA23160@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758728AbZA2GwW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090129064259.GA23160@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, hpa@zytor.com, serue@us.ibm.com, "David C. Hansen" <haveblue@us.ibm.com>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Date: Wed, 28 Jan 2009 19:11:15 -0800
Subject: [RFC][PATCH 5/5] Merge code for single and multiple-instance mounts

new_pts_mount() (including the get_sb_nodev()), shares a lot of code
with init_pts_mount(). The only difference between them is the 'test-super'
function passed into sget().

Move the shared code into a new, common function, do_pts_mount() and
remove new_pts_mount() and init_pts_mount() functions,

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 fs/devpts/inode.c |   34 ++++++++++------------------------
 1 files changed, 10 insertions(+), 24 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 733e8e0..8d0b675 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -328,23 +328,6 @@ static int compare_init_pts_sb(struct super_block *s, void *p)
  * Mount a new (private) instance of devpts.  PTYs created in this
  * instance are independent of the PTYs in other devpts instances.
  */
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
 
 /*
  * init_pts_mount()
@@ -371,14 +354,21 @@ static int new_pts_mount(struct file_system_type *fs_type, int flags,
  *     consistently selects the 'single-namespace' superblock even in the
  *     presence of the private namespace (i.e 'newinstance') super-blocks.
  */
-static int init_pts_mount(struct file_system_type *fs_type, int flags,
+static int do_pts_mount(struct file_system_type *fs_type, int flags,
 		void *data, struct pts_mount_opts *opts, struct vfsmount *mnt)
 {
 	struct super_block *s;
 	struct pts_fs_info *fsi;
 	int error;
 
-	s = sget(fs_type, compare_init_pts_sb, set_anon_super, NULL);
+	if (opts->newinstance) {
+		printk(KERN_NOTICE "devpts: newinstance mount\n");
+		s = sget(fs_type, NULL, set_anon_super, NULL);
+	} else {
+		printk(KERN_NOTICE "devpts: single-instance mount\n");
+		s = sget(fs_type, compare_init_pts_sb, set_anon_super, NULL);
+	}
+
 	if (IS_ERR(s))
 		return PTR_ERR(s);
 
@@ -413,11 +403,7 @@ static int devpts_get_sb(struct file_system_type *fs_type,
 			return error;
 	}
 
-	if (opts.newinstance)
-		error = new_pts_mount(fs_type, flags, data, &opts, mnt);
-	else
-		error = init_pts_mount(fs_type, flags, data, &opts, mnt);
-
+	error = do_pts_mount(fs_type, flags, data, &opts, mnt);
 	if (error)
 		return error;
 
-- 
1.5.2.5
