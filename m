From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 044/100] c/r: add checkpoint operation for opened files of
	generic filesystems
Date: Sat,  1 May 2010 10:15:26 -0400
Message-ID: <1272723382-19470-45-git-send-email-orenl__37120.380139868$1272729147$gmane$org@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

These patches extend the use of the generic file checkpoint operation to
non-extX filesystems which have lseek operations that ensure we can save
and restore the files for later use. Note that this does not include
things like FUSE, network filesystems, or pseudo-filesystem kernel
interfaces.

Only compile and boot tested (on x86-32).

[Oren Laadan] Folded patch series into a single patch; original post
included 36 separate patches for individual filesystems:

  [PATCH 01/36] Add the checkpoint operation for affs files and directories.
  [PATCH 02/36] Add the checkpoint operation for befs directories.
  [PATCH 03/36] Add the checkpoint operation for bfs files and directories.
  [PATCH 04/36] Add the checkpoint operation for btrfs files and directories.
  [PATCH 05/36] Add the checkpoint operation for cramfs directories.
  [PATCH 06/36] Add the checkpoint operation for ecryptfs files and directories.
  [PATCH 07/36] Add the checkpoint operation for fat files and directories.
  [PATCH 08/36] Add the checkpoint operation for freevxfs directories.
  [PATCH 09/36] Add the checkpoint operation for hfs files and directories.
  [PATCH 10/36] Add the checkpoint operation for hfsplus files and directories.
  [PATCH 11/36] Add the checkpoint operation for hpfs files and directories.
  [PATCH 12/36] Add the checkpoint operation for hppfs files and directories.
  [PATCH 13/36] Add the checkpoint operation for iso directories.
  [PATCH 14/36] Add the checkpoint operation for jffs2 files and directories.
  [PATCH 15/36] Add the checkpoint operation for jfs files and directories.
  [PATCH 16/36] Add the checkpoint operation for regular nfs files and directories. Skip the various /proc files for now.
  [PATCH 17/36] Add the checkpoint operation for ntfs directories.
  [PATCH 18/36] Add the checkpoint operation for openromfs directories. Explicitly skip the properties for now.
  [PATCH 19/36] Add the checkpoint operation for qnx4 files and directories.
  [PATCH 20/36] Add the checkpoint operation for reiserfs files and directories.
  [PATCH 21/36] Add the checkpoint operation for romfs directories.
  [PATCH 22/36] Add the checkpoint operation for squashfs directories.
  [PATCH 23/36] Add the checkpoint operation for sysv filesystem files and directories.
  [PATCH 24/36] Add the checkpoint operation for ubifs files and directories.
  [PATCH 25/36] Add the checkpoint operation for udf filesystem files and directories.
  [PATCH 26/36] Add the checkpoint operation for xfs files and directories.
  [PATCH 27/36] Add checkpoint operation for efs directories.
  [PATCH 28/36] Add the checkpoint operation for generic, read-only files. At present, some/all files of the following filesystems use this generic definition:
  [PATCH 29/36] Add checkpoint operation for minix filesystem files and directories.
  [PATCH 30/36] Add checkpoint operations for omfs files and directories.
  [PATCH 31/36] Add checkpoint operations for ufs files and directories.
  [PATCH 32/36] Add checkpoint operations for ramfs files. NOTE: since simple_dir_operations are shared between multiple filesystems including ramfs, it's not currently possible to checkpoint open ramfs directories.
  [PATCH 33/36] Add the checkpoint operation for adfs files and directories.
  [PATCH 34/36] Add the checkpoint operation to exofs files and directories.
  [PATCH 35/36] Add the checkpoint operation to nilfs2 files and directories.
  [PATCH 36/36] Add checkpoint operations for UML host filesystem files and directories.

Changelog[v21]:
  - Put file_ops->checkpoint under CONFIG_CHECKPOINT
Changelog[v19-rc3]:
  - [Suka] Enable C/R while executing over NFS

Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/adfs/dir.c               |    3 +++
 fs/adfs/file.c              |    3 +++
 fs/affs/dir.c               |    3 +++
 fs/affs/file.c              |    3 +++
 fs/befs/linuxvfs.c          |    3 +++
 fs/bfs/dir.c                |    3 +++
 fs/bfs/file.c               |    3 +++
 fs/btrfs/file.c             |    3 +++
 fs/btrfs/inode.c            |    3 +++
 fs/btrfs/super.c            |    3 +++
 fs/cramfs/inode.c           |    3 +++
 fs/ecryptfs/file.c          |    6 ++++++
 fs/ecryptfs/miscdev.c       |    3 +++
 fs/efs/dir.c                |    3 +++
 fs/exofs/dir.c              |    3 +++
 fs/exofs/file.c             |    3 +++
 fs/fat/dir.c                |    3 +++
 fs/fat/file.c               |    3 +++
 fs/freevxfs/vxfs_lookup.c   |    3 +++
 fs/hfs/dir.c                |    3 +++
 fs/hfs/inode.c              |    3 +++
 fs/hfsplus/dir.c            |    3 +++
 fs/hfsplus/inode.c          |    3 +++
 fs/hostfs/hostfs_kern.c     |    6 ++++++
 fs/hpfs/dir.c               |    3 +++
 fs/hpfs/file.c              |    3 +++
 fs/hppfs/hppfs.c            |    6 ++++++
 fs/isofs/dir.c              |    3 +++
 fs/jffs2/dir.c              |    3 +++
 fs/jffs2/file.c             |    3 +++
 fs/jfs/file.c               |    3 +++
 fs/jfs/namei.c              |    3 +++
 fs/minix/dir.c              |    3 +++
 fs/minix/file.c             |    3 +++
 fs/nfs/dir.c                |    3 +++
 fs/nfs/file.c               |    6 ++++++
 fs/nilfs2/dir.c             |    4 +++-
 fs/nilfs2/file.c            |    3 +++
 fs/ntfs/dir.c               |    3 +++
 fs/ntfs/file.c              |    5 ++++-
 fs/omfs/dir.c               |    3 +++
 fs/omfs/file.c              |    3 +++
 fs/openpromfs/inode.c       |    6 ++++++
 fs/qnx4/dir.c               |    3 +++
 fs/ramfs/file-mmu.c         |    3 +++
 fs/ramfs/file-nommu.c       |    3 +++
 fs/read_write.c             |    3 +++
 fs/reiserfs/dir.c           |    3 +++
 fs/reiserfs/file.c          |    3 +++
 fs/romfs/mmap-nommu.c       |    3 +++
 fs/romfs/super.c            |    3 +++
 fs/squashfs/dir.c           |    5 ++++-
 fs/sysv/dir.c               |    3 +++
 fs/sysv/file.c              |    3 +++
 fs/ubifs/debug.c            |    3 +++
 fs/ubifs/dir.c              |    3 +++
 fs/ubifs/file.c             |    3 +++
 fs/udf/dir.c                |    3 +++
 fs/udf/file.c               |    3 +++
 fs/ufs/dir.c                |    3 +++
 fs/ufs/file.c               |    3 +++
 fs/xfs/linux-2.6/xfs_file.c |    6 ++++++
 62 files changed, 206 insertions(+), 3 deletions(-)

diff --git a/fs/adfs/dir.c b/fs/adfs/dir.c
index 23aa52f..c205b40 100644
--- a/fs/adfs/dir.c
+++ b/fs/adfs/dir.c
@@ -198,6 +198,9 @@ const struct file_operations adfs_dir_operations = {
 	.llseek		= generic_file_llseek,
 	.readdir	= adfs_readdir,
 	.fsync		= simple_fsync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static int
diff --git a/fs/adfs/file.c b/fs/adfs/file.c
index 005ea34..09ce6c7 100644
--- a/fs/adfs/file.c
+++ b/fs/adfs/file.c
@@ -30,6 +30,9 @@ const struct file_operations adfs_file_operations = {
 	.write		= do_sync_write,
 	.aio_write	= generic_file_aio_write,
 	.splice_read	= generic_file_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations adfs_file_inode_operations = {
diff --git a/fs/affs/dir.c b/fs/affs/dir.c
index 8ca8f3a..02511bf 100644
--- a/fs/affs/dir.c
+++ b/fs/affs/dir.c
@@ -22,6 +22,9 @@ const struct file_operations affs_dir_operations = {
 	.llseek		= generic_file_llseek,
 	.readdir	= affs_readdir,
 	.fsync		= affs_file_fsync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 /*
diff --git a/fs/affs/file.c b/fs/affs/file.c
index 184e55c..22577fa 100644
--- a/fs/affs/file.c
+++ b/fs/affs/file.c
@@ -36,6 +36,9 @@ const struct file_operations affs_file_operations = {
 	.release	= affs_file_release,
 	.fsync		= affs_file_fsync,
 	.splice_read	= generic_file_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations affs_file_inode_operations = {
diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
index 34ddda8..71488ba 100644
--- a/fs/befs/linuxvfs.c
+++ b/fs/befs/linuxvfs.c
@@ -67,6 +67,9 @@ static const struct file_operations befs_dir_operations = {
 	.read		= generic_read_dir,
 	.readdir	= befs_readdir,
 	.llseek		= generic_file_llseek,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static const struct inode_operations befs_dir_inode_operations = {
diff --git a/fs/bfs/dir.c b/fs/bfs/dir.c
index 1e41aad..18bea30 100644
--- a/fs/bfs/dir.c
+++ b/fs/bfs/dir.c
@@ -80,6 +80,9 @@ const struct file_operations bfs_dir_operations = {
 	.readdir	= bfs_readdir,
 	.fsync		= simple_fsync,
 	.llseek		= generic_file_llseek,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 extern void dump_imap(const char *, struct super_block *);
diff --git a/fs/bfs/file.c b/fs/bfs/file.c
index 88b9a3f..844ff41 100644
--- a/fs/bfs/file.c
+++ b/fs/bfs/file.c
@@ -29,6 +29,9 @@ const struct file_operations bfs_file_operations = {
 	.aio_write	= generic_file_aio_write,
 	.mmap		= generic_file_mmap,
 	.splice_read	= generic_file_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static int bfs_move_block(unsigned long from, unsigned long to,
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 29ff749..be325e1 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1170,4 +1170,7 @@ const struct file_operations btrfs_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= btrfs_ioctl,
 #endif
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 2bfdc64..7ee1a98 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -5954,6 +5954,9 @@ static const struct file_operations btrfs_dir_file_operations = {
 #endif
 	.release        = btrfs_release_file,
 	.fsync		= btrfs_sync_file,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static struct extent_io_ops btrfs_extent_io_ops = {
diff --git a/fs/btrfs/super.c b/fs/btrfs/super.c
index 1866dff..2e31e14 100644
--- a/fs/btrfs/super.c
+++ b/fs/btrfs/super.c
@@ -829,6 +829,9 @@ static const struct file_operations btrfs_ctl_fops = {
 	.unlocked_ioctl	 = btrfs_control_ioctl,
 	.compat_ioctl = btrfs_control_ioctl,
 	.owner	 = THIS_MODULE,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = generic_file_checkpoint,
+#endif
 };
 
 static struct miscdevice btrfs_misc = {
diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index dd3634e..01ee36d 100644
--- a/fs/cramfs/inode.c
+++ b/fs/cramfs/inode.c
@@ -532,6 +532,9 @@ static const struct file_operations cramfs_directory_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= generic_read_dir,
 	.readdir	= cramfs_readdir,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static const struct inode_operations cramfs_dir_inode_operations = {
diff --git a/fs/ecryptfs/file.c b/fs/ecryptfs/file.c
index e7440a6..e34e59a 100644
--- a/fs/ecryptfs/file.c
+++ b/fs/ecryptfs/file.c
@@ -306,6 +306,9 @@ const struct file_operations ecryptfs_dir_fops = {
 	.fsync = ecryptfs_fsync,
 	.fasync = ecryptfs_fasync,
 	.splice_read = generic_file_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = generic_file_checkpoint,
+#endif
 };
 
 const struct file_operations ecryptfs_main_fops = {
@@ -323,6 +326,9 @@ const struct file_operations ecryptfs_main_fops = {
 	.fsync = ecryptfs_fsync,
 	.fasync = ecryptfs_fasync,
 	.splice_read = generic_file_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = generic_file_checkpoint,
+#endif
 };
 
 static int
diff --git a/fs/ecryptfs/miscdev.c b/fs/ecryptfs/miscdev.c
index 3745f61..9aa5d8b 100644
--- a/fs/ecryptfs/miscdev.c
+++ b/fs/ecryptfs/miscdev.c
@@ -482,6 +482,9 @@ static const struct file_operations ecryptfs_miscdev_fops = {
 	.read    = ecryptfs_miscdev_read,
 	.write   = ecryptfs_miscdev_write,
 	.release = ecryptfs_miscdev_release,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = generic_file_checkpoint,
+#endif
 };
 
 static struct miscdevice ecryptfs_miscdev = {
diff --git a/fs/efs/dir.c b/fs/efs/dir.c
index 7ee6f7e..ff08a3b 100644
--- a/fs/efs/dir.c
+++ b/fs/efs/dir.c
@@ -13,6 +13,9 @@ const struct file_operations efs_dir_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= generic_read_dir,
 	.readdir	= efs_readdir,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations efs_dir_inode_operations = {
diff --git a/fs/exofs/dir.c b/fs/exofs/dir.c
index 4cfab1c..62347ff 100644
--- a/fs/exofs/dir.c
+++ b/fs/exofs/dir.c
@@ -667,4 +667,7 @@ const struct file_operations exofs_dir_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= generic_read_dir,
 	.readdir	= exofs_readdir,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
diff --git a/fs/exofs/file.c b/fs/exofs/file.c
index 839b9dc..ec7e15a 100644
--- a/fs/exofs/file.c
+++ b/fs/exofs/file.c
@@ -84,6 +84,9 @@ const struct file_operations exofs_file_operations = {
 	.flush		= exofs_flush,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations exofs_file_inode_operations = {
diff --git a/fs/fat/dir.c b/fs/fat/dir.c
index 530b4ca..4a4c7bb 100644
--- a/fs/fat/dir.c
+++ b/fs/fat/dir.c
@@ -841,6 +841,9 @@ const struct file_operations fat_dir_operations = {
 	.compat_ioctl	= fat_compat_dir_ioctl,
 #endif
 	.fsync		= fat_file_fsync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static int fat_get_short_entry(struct inode *dir, loff_t *pos,
diff --git a/fs/fat/file.c b/fs/fat/file.c
index e8c159d..38132c2 100644
--- a/fs/fat/file.c
+++ b/fs/fat/file.c
@@ -162,6 +162,9 @@ const struct file_operations fat_file_operations = {
 	.ioctl		= fat_generic_ioctl,
 	.fsync		= fat_file_fsync,
 	.splice_read	= generic_file_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static int fat_cont_expand(struct inode *inode, loff_t size)
diff --git a/fs/freevxfs/vxfs_lookup.c b/fs/freevxfs/vxfs_lookup.c
index aee049c..41dfea9 100644
--- a/fs/freevxfs/vxfs_lookup.c
+++ b/fs/freevxfs/vxfs_lookup.c
@@ -58,6 +58,9 @@ const struct inode_operations vxfs_dir_inode_ops = {
 
 const struct file_operations vxfs_dir_operations = {
 	.readdir =		vxfs_readdir,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint =		generic_file_checkpoint,
+#endif
 };
 
  
diff --git a/fs/hfs/dir.c b/fs/hfs/dir.c
index 2b3b861..f4dafc5 100644
--- a/fs/hfs/dir.c
+++ b/fs/hfs/dir.c
@@ -329,6 +329,9 @@ const struct file_operations hfs_dir_operations = {
 	.readdir	= hfs_readdir,
 	.llseek		= generic_file_llseek,
 	.release	= hfs_dir_release,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations hfs_dir_inode_operations = {
diff --git a/fs/hfs/inode.c b/fs/hfs/inode.c
index 14f5cb1..3b10d84 100644
--- a/fs/hfs/inode.c
+++ b/fs/hfs/inode.c
@@ -607,6 +607,9 @@ static const struct file_operations hfs_file_operations = {
 	.fsync		= file_fsync,
 	.open		= hfs_file_open,
 	.release	= hfs_file_release,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static const struct inode_operations hfs_file_inode_operations = {
diff --git a/fs/hfsplus/dir.c b/fs/hfsplus/dir.c
index 5f40236..7656143 100644
--- a/fs/hfsplus/dir.c
+++ b/fs/hfsplus/dir.c
@@ -497,4 +497,7 @@ const struct file_operations hfsplus_dir_operations = {
 	.ioctl          = hfsplus_ioctl,
 	.llseek		= generic_file_llseek,
 	.release	= hfsplus_dir_release,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
diff --git a/fs/hfsplus/inode.c b/fs/hfsplus/inode.c
index 1bcf597..43a6da2 100644
--- a/fs/hfsplus/inode.c
+++ b/fs/hfsplus/inode.c
@@ -286,6 +286,9 @@ static const struct file_operations hfsplus_file_operations = {
 	.open		= hfsplus_file_open,
 	.release	= hfsplus_file_release,
 	.ioctl          = hfsplus_ioctl,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 struct inode *hfsplus_new_inode(struct super_block *sb, int mode)
diff --git a/fs/hostfs/hostfs_kern.c b/fs/hostfs/hostfs_kern.c
index 3a029d8..1514aee 100644
--- a/fs/hostfs/hostfs_kern.c
+++ b/fs/hostfs/hostfs_kern.c
@@ -427,12 +427,18 @@ static const struct file_operations hostfs_file_fops = {
 	.open		= hostfs_file_open,
 	.release	= NULL,
 	.fsync		= hostfs_fsync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static const struct file_operations hostfs_dir_fops = {
 	.llseek		= generic_file_llseek,
 	.readdir	= hostfs_readdir,
 	.read		= generic_read_dir,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 int hostfs_writepage(struct page *page, struct writeback_control *wbc)
diff --git a/fs/hpfs/dir.c b/fs/hpfs/dir.c
index 2338130..a2e95fe 100644
--- a/fs/hpfs/dir.c
+++ b/fs/hpfs/dir.c
@@ -323,4 +323,7 @@ const struct file_operations hpfs_dir_ops =
 	.readdir	= hpfs_readdir,
 	.release	= hpfs_dir_release,
 	.fsync		= hpfs_file_fsync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
diff --git a/fs/hpfs/file.c b/fs/hpfs/file.c
index 3efabff..7a78261 100644
--- a/fs/hpfs/file.c
+++ b/fs/hpfs/file.c
@@ -139,6 +139,9 @@ const struct file_operations hpfs_file_ops =
 	.release	= hpfs_file_release,
 	.fsync		= hpfs_file_fsync,
 	.splice_read	= generic_file_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations hpfs_file_iops =
diff --git a/fs/hppfs/hppfs.c b/fs/hppfs/hppfs.c
index 2e4dfa8..d059b38 100644
--- a/fs/hppfs/hppfs.c
+++ b/fs/hppfs/hppfs.c
@@ -546,6 +546,9 @@ static const struct file_operations hppfs_file_fops = {
 	.read		= hppfs_read,
 	.write		= hppfs_write,
 	.open		= hppfs_open,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 struct hppfs_dirent {
@@ -597,6 +600,9 @@ static const struct file_operations hppfs_dir_fops = {
 	.readdir	= hppfs_readdir,
 	.open		= hppfs_dir_open,
 	.fsync		= hppfs_fsync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static int hppfs_statfs(struct dentry *dentry, struct kstatfs *sf)
diff --git a/fs/isofs/dir.c b/fs/isofs/dir.c
index b9ab69b..fe41d7f 100644
--- a/fs/isofs/dir.c
+++ b/fs/isofs/dir.c
@@ -274,6 +274,9 @@ const struct file_operations isofs_dir_operations =
 {
 	.read = generic_read_dir,
 	.readdir = isofs_readdir,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = generic_file_checkpoint,
+#endif
 };
 
 /*
diff --git a/fs/jffs2/dir.c b/fs/jffs2/dir.c
index 7aa4417..482e34a 100644
--- a/fs/jffs2/dir.c
+++ b/fs/jffs2/dir.c
@@ -41,6 +41,9 @@ const struct file_operations jffs2_dir_operations =
 	.unlocked_ioctl=jffs2_ioctl,
 	.fsync =	jffs2_fsync,
 	.llseek =	generic_file_llseek,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint =	generic_file_checkpoint,
+#endif
 };
 
 
diff --git a/fs/jffs2/file.c b/fs/jffs2/file.c
index e7291c1..c2bcb4d 100644
--- a/fs/jffs2/file.c
+++ b/fs/jffs2/file.c
@@ -49,6 +49,9 @@ const struct file_operations jffs2_file_operations =
 	.mmap =		generic_file_readonly_mmap,
 	.fsync =	jffs2_fsync,
 	.splice_read =	generic_file_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint =	generic_file_checkpoint,
+#endif
 };
 
 /* jffs2_file_inode_operations */
diff --git a/fs/jfs/file.c b/fs/jfs/file.c
index 14ba982..cda38cb 100644
--- a/fs/jfs/file.c
+++ b/fs/jfs/file.c
@@ -143,4 +143,7 @@ const struct file_operations jfs_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= jfs_compat_ioctl,
 #endif
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
diff --git a/fs/jfs/namei.c b/fs/jfs/namei.c
index 4a3e9f3..83f2490 100644
--- a/fs/jfs/namei.c
+++ b/fs/jfs/namei.c
@@ -1571,6 +1571,9 @@ const struct file_operations jfs_dir_operations = {
 	.compat_ioctl	= jfs_compat_ioctl,
 #endif
 	.llseek		= generic_file_llseek,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static int jfs_ci_hash(struct dentry *dir, struct qstr *this)
diff --git a/fs/minix/dir.c b/fs/minix/dir.c
index 6198731..715dd03 100644
--- a/fs/minix/dir.c
+++ b/fs/minix/dir.c
@@ -23,6 +23,9 @@ const struct file_operations minix_dir_operations = {
 	.read		= generic_read_dir,
 	.readdir	= minix_readdir,
 	.fsync		= simple_fsync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static inline void dir_put_page(struct page *page)
diff --git a/fs/minix/file.c b/fs/minix/file.c
index 3eec3e6..8e8f6a9 100644
--- a/fs/minix/file.c
+++ b/fs/minix/file.c
@@ -21,6 +21,9 @@ const struct file_operations minix_file_operations = {
 	.mmap		= generic_file_mmap,
 	.fsync		= simple_fsync,
 	.splice_read	= generic_file_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations minix_file_inode_operations = {
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index be46f26..ac4c291 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -63,6 +63,9 @@ const struct file_operations nfs_dir_operations = {
 	.open		= nfs_opendir,
 	.release	= nfs_release,
 	.fsync		= nfs_fsync_dir,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations nfs_dir_inode_operations = {
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 8d965bd..456e861 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -78,6 +78,9 @@ const struct file_operations nfs_file_operations = {
 	.splice_write	= nfs_file_splice_write,
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations nfs_file_inode_operations = {
@@ -583,6 +586,9 @@ out_unlock:
 static const struct vm_operations_struct nfs_file_vm_ops = {
 	.fault = filemap_fault,
 	.page_mkwrite = nfs_vm_page_mkwrite,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = filemap_checkpoint,
+#endif
 };
 
 static int nfs_need_sync_write(struct file *filp, struct inode *inode)
diff --git a/fs/nilfs2/dir.c b/fs/nilfs2/dir.c
index 85c89df..d677449 100644
--- a/fs/nilfs2/dir.c
+++ b/fs/nilfs2/dir.c
@@ -702,5 +702,7 @@ const struct file_operations nilfs_dir_operations = {
 	.compat_ioctl	= nilfs_ioctl,
 #endif	/* CONFIG_COMPAT */
 	.fsync		= nilfs_sync_file,
-
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index 30292df..9306d6f 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -149,6 +149,9 @@ const struct file_operations nilfs_file_operations = {
 	/* .release	= nilfs_release_file, */
 	.fsync		= nilfs_sync_file,
 	.splice_read	= generic_file_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations nilfs_file_inode_operations = {
diff --git a/fs/ntfs/dir.c b/fs/ntfs/dir.c
index fe44d3f..229d00b 100644
--- a/fs/ntfs/dir.c
+++ b/fs/ntfs/dir.c
@@ -1573,4 +1573,7 @@ const struct file_operations ntfs_dir_ops = {
 	/*.ioctl	= ,*/			/* Perform function on the
 						   mounted filesystem. */
 	.open		= ntfs_dir_open,	/* Open directory. */
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index 8804f09..303ee8e 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -2225,7 +2225,7 @@ const struct file_operations ntfs_file_ops = {
 						    mounted filesystem. */
 	.mmap		= generic_file_mmap,	 /* Mmap file. */
 	.open		= ntfs_file_open,	 /* Open file. */
-	.splice_read	= generic_file_splice_read /* Zero-copy data send with
+	.splice_read	= generic_file_splice_read, /* Zero-copy data send with
 						    the data source being on
 						    the ntfs partition.  We do
 						    not need to care about the
@@ -2235,6 +2235,9 @@ const struct file_operations ntfs_file_ops = {
 						    on the ntfs partition.  We
 						    do not need to care about
 						    the data source. */
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations ntfs_file_inode_ops = {
diff --git a/fs/omfs/dir.c b/fs/omfs/dir.c
index b42d624..3b08c84 100644
--- a/fs/omfs/dir.c
+++ b/fs/omfs/dir.c
@@ -502,4 +502,7 @@ const struct file_operations omfs_dir_operations = {
 	.read = generic_read_dir,
 	.readdir = omfs_readdir,
 	.llseek = generic_file_llseek,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = generic_file_checkpoint,
+#endif
 };
diff --git a/fs/omfs/file.c b/fs/omfs/file.c
index 399487c..fb5fa02 100644
--- a/fs/omfs/file.c
+++ b/fs/omfs/file.c
@@ -331,6 +331,9 @@ const struct file_operations omfs_file_operations = {
 	.mmap = generic_file_mmap,
 	.fsync = simple_fsync,
 	.splice_read = generic_file_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations omfs_file_inops = {
diff --git a/fs/openpromfs/inode.c b/fs/openpromfs/inode.c
index ffcd04f..f5e4649 100644
--- a/fs/openpromfs/inode.c
+++ b/fs/openpromfs/inode.c
@@ -160,6 +160,9 @@ static const struct file_operations openpromfs_prop_ops = {
 	.read		= seq_read,
 	.llseek		= seq_lseek,
 	.release	= seq_release,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= NULL,
+#endif
 };
 
 static int openpromfs_readdir(struct file *, void *, filldir_t);
@@ -168,6 +171,9 @@ static const struct file_operations openprom_operations = {
 	.read		= generic_read_dir,
 	.readdir	= openpromfs_readdir,
 	.llseek		= generic_file_llseek,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static struct dentry *openpromfs_lookup(struct inode *, struct dentry *, struct nameidata *);
diff --git a/fs/qnx4/dir.c b/fs/qnx4/dir.c
index 6f30c3d..3414bf8 100644
--- a/fs/qnx4/dir.c
+++ b/fs/qnx4/dir.c
@@ -80,6 +80,9 @@ const struct file_operations qnx4_dir_operations =
 	.read		= generic_read_dir,
 	.readdir	= qnx4_readdir,
 	.fsync		= simple_fsync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations qnx4_dir_inode_operations =
diff --git a/fs/ramfs/file-mmu.c b/fs/ramfs/file-mmu.c
index 78f613c..34dc7f2 100644
--- a/fs/ramfs/file-mmu.c
+++ b/fs/ramfs/file-mmu.c
@@ -47,6 +47,9 @@ const struct file_operations ramfs_file_operations = {
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
 	.llseek		= generic_file_llseek,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations ramfs_file_inode_operations = {
diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
index 5ea4ad8..7aa0d43 100644
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -46,6 +46,9 @@ const struct file_operations ramfs_file_operations = {
 	.splice_read		= generic_file_splice_read,
 	.splice_write		= generic_file_splice_write,
 	.llseek			= generic_file_llseek,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint		= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations ramfs_file_inode_operations = {
diff --git a/fs/read_write.c b/fs/read_write.c
index 67b7d83..d566214 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -27,6 +27,9 @@ const struct file_operations generic_ro_fops = {
 	.aio_read	= generic_file_aio_read,
 	.mmap		= generic_file_readonly_mmap,
 	.splice_read	= generic_file_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 EXPORT_SYMBOL(generic_ro_fops);
diff --git a/fs/reiserfs/dir.c b/fs/reiserfs/dir.c
index f8a6075..1fb4ce6 100644
--- a/fs/reiserfs/dir.c
+++ b/fs/reiserfs/dir.c
@@ -25,6 +25,9 @@ const struct file_operations reiserfs_dir_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl = reiserfs_compat_ioctl,
 #endif
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = generic_file_checkpoint,
+#endif
 };
 
 static int reiserfs_dir_fsync(struct file *filp, struct dentry *dentry,
diff --git a/fs/reiserfs/file.c b/fs/reiserfs/file.c
index 1d9c127..5b2d720 100644
--- a/fs/reiserfs/file.c
+++ b/fs/reiserfs/file.c
@@ -297,6 +297,9 @@ const struct file_operations reiserfs_file_operations = {
 	.splice_read = generic_file_splice_read,
 	.splice_write = generic_file_splice_write,
 	.llseek = generic_file_llseek,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations reiserfs_file_inode_operations = {
diff --git a/fs/romfs/mmap-nommu.c b/fs/romfs/mmap-nommu.c
index f0511e8..f488a8a 100644
--- a/fs/romfs/mmap-nommu.c
+++ b/fs/romfs/mmap-nommu.c
@@ -72,4 +72,7 @@ const struct file_operations romfs_ro_fops = {
 	.splice_read		= generic_file_splice_read,
 	.mmap			= romfs_mmap,
 	.get_unmapped_area	= romfs_get_unmapped_area,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint		= generic_file_checkpoint,
+#endif
 };
diff --git a/fs/romfs/super.c b/fs/romfs/super.c
index 42d2135..6a07e29 100644
--- a/fs/romfs/super.c
+++ b/fs/romfs/super.c
@@ -282,6 +282,9 @@ error:
 static const struct file_operations romfs_dir_operations = {
 	.read		= generic_read_dir,
 	.readdir	= romfs_readdir,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static const struct inode_operations romfs_dir_inode_operations = {
diff --git a/fs/squashfs/dir.c b/fs/squashfs/dir.c
index 12b933a..1bc7cc0 100644
--- a/fs/squashfs/dir.c
+++ b/fs/squashfs/dir.c
@@ -230,5 +230,8 @@ failed_read:
 
 const struct file_operations squashfs_dir_ops = {
 	.read = generic_read_dir,
-	.readdir = squashfs_readdir
+	.readdir = squashfs_readdir,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = generic_file_checkpoint,
+#endif
 };
diff --git a/fs/sysv/dir.c b/fs/sysv/dir.c
index 4e50286..e1030d4 100644
--- a/fs/sysv/dir.c
+++ b/fs/sysv/dir.c
@@ -25,6 +25,9 @@ const struct file_operations sysv_dir_operations = {
 	.read		= generic_read_dir,
 	.readdir	= sysv_readdir,
 	.fsync		= simple_fsync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static inline void dir_put_page(struct page *page)
diff --git a/fs/sysv/file.c b/fs/sysv/file.c
index 96340c0..78b7e65 100644
--- a/fs/sysv/file.c
+++ b/fs/sysv/file.c
@@ -28,6 +28,9 @@ const struct file_operations sysv_file_operations = {
 	.mmap		= generic_file_mmap,
 	.fsync		= simple_fsync,
 	.splice_read	= generic_file_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations sysv_file_inode_operations = {
diff --git a/fs/ubifs/debug.c b/fs/ubifs/debug.c
index c2a68ba..b357ca3 100644
--- a/fs/ubifs/debug.c
+++ b/fs/ubifs/debug.c
@@ -2625,6 +2625,9 @@ static const struct file_operations dfs_fops = {
 	.open = open_debugfs_file,
 	.write = write_debugfs_file,
 	.owner = THIS_MODULE,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = generic_file_checkpoint,
+#endif
 };
 
 /**
diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index 401e503..a72070e 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -1228,4 +1228,7 @@ const struct file_operations ubifs_dir_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl   = ubifs_compat_ioctl,
 #endif
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint     = generic_file_checkpoint,
+#endif
 };
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 5692cf7..566e172 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1583,4 +1583,7 @@ const struct file_operations ubifs_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl   = ubifs_compat_ioctl,
 #endif
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint     = generic_file_checkpoint,
+#endif
 };
diff --git a/fs/udf/dir.c b/fs/udf/dir.c
index f0f2a43..43bf889 100644
--- a/fs/udf/dir.c
+++ b/fs/udf/dir.c
@@ -211,4 +211,7 @@ const struct file_operations udf_dir_operations = {
 	.readdir		= udf_readdir,
 	.ioctl			= udf_ioctl,
 	.fsync			= simple_fsync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint		= generic_file_checkpoint,
+#endif
 };
diff --git a/fs/udf/file.c b/fs/udf/file.c
index 4b6a46c..0c73a47 100644
--- a/fs/udf/file.c
+++ b/fs/udf/file.c
@@ -216,6 +216,9 @@ const struct file_operations udf_file_operations = {
 	.fsync			= simple_fsync,
 	.splice_read		= generic_file_splice_read,
 	.llseek			= generic_file_llseek,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint		= generic_file_checkpoint,
+#endif
 };
 
 int udf_setattr(struct dentry *dentry, struct iattr *iattr)
diff --git a/fs/ufs/dir.c b/fs/ufs/dir.c
index 317a0d4..9841034 100644
--- a/fs/ufs/dir.c
+++ b/fs/ufs/dir.c
@@ -668,4 +668,7 @@ const struct file_operations ufs_dir_operations = {
 	.readdir	= ufs_readdir,
 	.fsync		= simple_fsync,
 	.llseek		= generic_file_llseek,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
diff --git a/fs/ufs/file.c b/fs/ufs/file.c
index a8962ce..f180014 100644
--- a/fs/ufs/file.c
+++ b/fs/ufs/file.c
@@ -44,4 +44,7 @@ const struct file_operations ufs_file_operations = {
 	.open           = dquot_file_open,
 	.fsync		= simple_fsync,
 	.splice_read	= generic_file_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
diff --git a/fs/xfs/linux-2.6/xfs_file.c b/fs/xfs/linux-2.6/xfs_file.c
index 42dd3bc..8aea381 100644
--- a/fs/xfs/linux-2.6/xfs_file.c
+++ b/fs/xfs/linux-2.6/xfs_file.c
@@ -1015,6 +1015,9 @@ const struct file_operations xfs_file_operations = {
 #ifdef HAVE_FOP_OPEN_EXEC
 	.open_exec	= xfs_file_open_exec,
 #endif
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct file_operations xfs_dir_file_operations = {
@@ -1027,6 +1030,9 @@ const struct file_operations xfs_dir_file_operations = {
 	.compat_ioctl	= xfs_file_compat_ioctl,
 #endif
 	.fsync		= xfs_file_fsync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static const struct vm_operations_struct xfs_file_vm_ops = {
-- 
1.6.3.3
