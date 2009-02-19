From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 1/5] create fs flag to mark c/r supported fs's
Date: Thu, 19 Feb 2009 10:20:07 -0800
Message-ID: <20090219182007.B4B47C1F@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


There are plenty of filesystems that are not supported for
c/r at this point.  Think of things like hugetlbfs which
are externally visible or pipefs which are kernel-internal.

This provides a quick way to make the "normal" filesystems
which are currently supported.  This is also safe if any
new code gets added.  We assume that a fs is non-supported
unless someone takes explicit action to the contrary.

I bet there are some more filesystems that are OK, but
these probably cover 99% of the users for now.

Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 linux-2.6.git-dave/fs/ext2/super.c              |    2 +-
 linux-2.6.git-dave/fs/ext3/super.c              |    2 +-
 linux-2.6.git-dave/fs/ext4/super.c              |    4 ++--
 linux-2.6.git-dave/fs/fat/namei_msdos.c         |    2 +-
 linux-2.6.git-dave/fs/fat/namei_vfat.c          |    2 +-
 linux-2.6.git-dave/fs/jfs/super.c               |    2 +-
 linux-2.6.git-dave/fs/minix/inode.c             |    2 +-
 linux-2.6.git-dave/fs/reiserfs/super.c          |    2 +-
 linux-2.6.git-dave/fs/xfs/linux-2.6/xfs_super.c |    2 +-
 linux-2.6.git-dave/include/linux/fs.h           |    1 +
 10 files changed, 11 insertions(+), 10 deletions(-)

diff -puN fs/ext2/super.c~sb_op-for-checkpointable-files fs/ext2/super.c
--- linux-2.6.git/fs/ext2/super.c~sb_op-for-checkpointable-files	2009-02-19 10:17:23.000000000 -0800
+++ linux-2.6.git-dave/fs/ext2/super.c	2009-02-19 10:17:23.000000000 -0800
@@ -1401,7 +1401,7 @@ static struct file_system_type ext2_fs_t
 	.name		= "ext2",
 	.get_sb		= ext2_get_sb,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_CHECKPOINTABLE,
 };
 
 static int __init init_ext2_fs(void)
diff -puN fs/ext3/super.c~sb_op-for-checkpointable-files fs/ext3/super.c
--- linux-2.6.git/fs/ext3/super.c~sb_op-for-checkpointable-files	2009-02-19 10:17:23.000000000 -0800
+++ linux-2.6.git-dave/fs/ext3/super.c	2009-02-19 10:17:23.000000000 -0800
@@ -2969,7 +2969,7 @@ static struct file_system_type ext3_fs_t
 	.name		= "ext3",
 	.get_sb		= ext3_get_sb,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_CHECKPOINTABLE,
 };
 
 static int __init init_ext3_fs(void)
diff -puN fs/ext4/super.c~sb_op-for-checkpointable-files fs/ext4/super.c
--- linux-2.6.git/fs/ext4/super.c~sb_op-for-checkpointable-files	2009-02-19 10:17:23.000000000 -0800
+++ linux-2.6.git-dave/fs/ext4/super.c	2009-02-19 10:17:23.000000000 -0800
@@ -3543,7 +3543,7 @@ static struct file_system_type ext4_fs_t
 	.name		= "ext4",
 	.get_sb		= ext4_get_sb,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_CHECKPOINTABLE,
 };
 
 #ifdef CONFIG_EXT4DEV_COMPAT
@@ -3562,7 +3562,7 @@ static struct file_system_type ext4dev_f
 	.name		= "ext4dev",
 	.get_sb		= ext4dev_get_sb,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_CHECKPOINTABLE,
 };
 MODULE_ALIAS("ext4dev");
 #endif
diff -puN fs/fat/namei_msdos.c~sb_op-for-checkpointable-files fs/fat/namei_msdos.c
--- linux-2.6.git/fs/fat/namei_msdos.c~sb_op-for-checkpointable-files	2009-02-19 10:17:23.000000000 -0800
+++ linux-2.6.git-dave/fs/fat/namei_msdos.c	2009-02-19 10:17:23.000000000 -0800
@@ -685,7 +685,7 @@ static struct file_system_type msdos_fs_
 	.name		= "msdos",
 	.get_sb		= msdos_get_sb,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_CHECKPOINTABLE,
 };
 
 static int __init init_msdos_fs(void)
diff -puN fs/fat/namei_vfat.c~sb_op-for-checkpointable-files fs/fat/namei_vfat.c
--- linux-2.6.git/fs/fat/namei_vfat.c~sb_op-for-checkpointable-files	2009-02-19 10:17:23.000000000 -0800
+++ linux-2.6.git-dave/fs/fat/namei_vfat.c	2009-02-19 10:17:23.000000000 -0800
@@ -1077,7 +1077,7 @@ static struct file_system_type vfat_fs_t
 	.name		= "vfat",
 	.get_sb		= vfat_get_sb,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_CHECKPOINTABLE,
 };
 
 static int __init init_vfat_fs(void)
diff -puN fs/jfs/super.c~sb_op-for-checkpointable-files fs/jfs/super.c
--- linux-2.6.git/fs/jfs/super.c~sb_op-for-checkpointable-files	2009-02-19 10:17:23.000000000 -0800
+++ linux-2.6.git-dave/fs/jfs/super.c	2009-02-19 10:17:23.000000000 -0800
@@ -757,7 +757,7 @@ static struct file_system_type jfs_fs_ty
 	.name		= "jfs",
 	.get_sb		= jfs_get_sb,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_CHECKPOINTABLE,
 };
 
 static void init_once(void *foo)
diff -puN fs/minix/inode.c~sb_op-for-checkpointable-files fs/minix/inode.c
--- linux-2.6.git/fs/minix/inode.c~sb_op-for-checkpointable-files	2009-02-19 10:17:23.000000000 -0800
+++ linux-2.6.git-dave/fs/minix/inode.c	2009-02-19 10:17:23.000000000 -0800
@@ -623,7 +623,7 @@ static struct file_system_type minix_fs_
 	.name		= "minix",
 	.get_sb		= minix_get_sb,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_CHECKPOINTABLE,
 };
 
 static int __init init_minix_fs(void)
diff -puN fs/reiserfs/super.c~sb_op-for-checkpointable-files fs/reiserfs/super.c
--- linux-2.6.git/fs/reiserfs/super.c~sb_op-for-checkpointable-files	2009-02-19 10:17:23.000000000 -0800
+++ linux-2.6.git-dave/fs/reiserfs/super.c	2009-02-19 10:17:23.000000000 -0800
@@ -2284,7 +2284,7 @@ struct file_system_type reiserfs_fs_type
 	.name = "reiserfs",
 	.get_sb = get_super_block,
 	.kill_sb = reiserfs_kill_sb,
-	.fs_flags = FS_REQUIRES_DEV,
+	.fs_flags = FS_REQUIRES_DEV | FS_CHECKPOINTABLE,
 };
 
 MODULE_DESCRIPTION("ReiserFS journaled filesystem");
diff -puN fs/xfs/linux-2.6/xfs_super.c~sb_op-for-checkpointable-files fs/xfs/linux-2.6/xfs_super.c
--- linux-2.6.git/fs/xfs/linux-2.6/xfs_super.c~sb_op-for-checkpointable-files	2009-02-19 10:17:23.000000000 -0800
+++ linux-2.6.git-dave/fs/xfs/linux-2.6/xfs_super.c	2009-02-19 10:17:23.000000000 -0800
@@ -1866,7 +1866,7 @@ static struct file_system_type xfs_fs_ty
 	.name			= "xfs",
 	.get_sb			= xfs_fs_get_sb,
 	.kill_sb		= kill_block_super,
-	.fs_flags		= FS_REQUIRES_DEV,
+	.fs_flags		= FS_REQUIRES_DEV | FS_CHECKPOINTABLE,
 };
 
 STATIC int __init
diff -puN include/linux/fs.h~sb_op-for-checkpointable-files include/linux/fs.h
--- linux-2.6.git/include/linux/fs.h~sb_op-for-checkpointable-files	2009-02-19 10:17:23.000000000 -0800
+++ linux-2.6.git-dave/include/linux/fs.h	2009-02-19 10:17:23.000000000 -0800
@@ -104,6 +104,7 @@ extern int dir_notify_enable;
 #define FS_REQUIRES_DEV 1 
 #define FS_BINARY_MOUNTDATA 2
 #define FS_HAS_SUBTYPE 4
+#define FS_CHECKPOINTABLE 8
 #define FS_REVAL_DOT	16384	/* Check the paths ".", ".." for staleness */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move()
 					 * during rename() internally.
_
