From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 3/8] create fs flags to mark c/r supported fs's
Date: Fri, 27 Feb 2009 12:34:28 -0800
Message-ID: <20090227203428.556600DA@kernel>
References: <20090227203425.F3B51176@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090227203425.F3B51176@kernel>
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
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


There are plenty of filesystems that are not supported for
c/r at this point.  Think of things like hugetlbfs which
are externally visible or pipefs which are kernel-internal.

This provides a quick way to mark the filesystems as they
get supported.  We won't mark wery many filesystems
explicitly for now.  That's because we will assume that
FS_REQUIRES_DEV implies FS_CHECKPOINTABLE for now.  This
assumption may need to get overridden in the future, but
it should be OK for now.

Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 linux-2.6.git-dave/fs/nfs/super.c     |   13 ++++++++-----
 linux-2.6.git-dave/include/linux/fs.h |    1 +
 2 files changed, 9 insertions(+), 5 deletions(-)

diff -puN fs/nfs/super.c~FS_CHECKPOINTABLE-flag fs/nfs/super.c
--- linux-2.6.git/fs/nfs/super.c~FS_CHECKPOINTABLE-flag	2009-02-27 12:07:38.000000000 -0800
+++ linux-2.6.git-dave/fs/nfs/super.c	2009-02-27 12:07:38.000000000 -0800
@@ -233,12 +233,15 @@ static int nfs_xdev_get_sb(struct file_s
 static void nfs_kill_super(struct super_block *);
 static int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
 
+#define NFS_FS_FLAGS FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|\
+		     FS_BINARY_MOUNTDATA|FS_CHECKPOINTABLE
+
 static struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs",
 	.get_sb		= nfs_get_sb,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= NFS_FS_FLAGS,
 };
 
 struct file_system_type nfs_xdev_fs_type = {
@@ -246,7 +249,7 @@ struct file_system_type nfs_xdev_fs_type
 	.name		= "nfs",
 	.get_sb		= nfs_xdev_get_sb,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= NFS_FS_FLAGS,
 };
 
 static const struct super_operations nfs_sops = {
@@ -275,7 +278,7 @@ static struct file_system_type nfs4_fs_t
 	.name		= "nfs4",
 	.get_sb		= nfs4_get_sb,
 	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= NFS_FS_FLAGS,
 };
 
 struct file_system_type nfs4_xdev_fs_type = {
@@ -283,7 +286,7 @@ struct file_system_type nfs4_xdev_fs_typ
 	.name		= "nfs4",
 	.get_sb		= nfs4_xdev_get_sb,
 	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= NFS_FS_FLAGS,
 };
 
 struct file_system_type nfs4_referral_fs_type = {
@@ -291,7 +294,7 @@ struct file_system_type nfs4_referral_fs
 	.name		= "nfs4",
 	.get_sb		= nfs4_referral_get_sb,
 	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= NFS_FS_FLAGS,
 };
 
 static const struct super_operations nfs4_sops = {
diff -puN include/linux/fs.h~FS_CHECKPOINTABLE-flag include/linux/fs.h
--- linux-2.6.git/include/linux/fs.h~FS_CHECKPOINTABLE-flag	2009-02-27 12:07:38.000000000 -0800
+++ linux-2.6.git-dave/include/linux/fs.h	2009-02-27 12:07:38.000000000 -0800
@@ -109,6 +109,7 @@ struct inodes_stat_t {
 #define FS_REQUIRES_DEV 1 
 #define FS_BINARY_MOUNTDATA 2
 #define FS_HAS_SUBTYPE 4
+#define FS_CHECKPOINTABLE 8
 #define FS_REVAL_DOT	16384	/* Check the paths ".", ".." for staleness */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move()
 					 * during rename() internally.
_
