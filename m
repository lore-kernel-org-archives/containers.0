From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] mount namespace bug fixes
Date: Wed, 13 Mar 2013 00:30:18 -0700
Message-ID: <871ubjpxit.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Cristian =?utf-8?Q?Rodr=C3=ADguez?= <crrodriguez-stAJ6ESoqRxg9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arthur Marsh <arthur.marsh-CkBdp7X+a1oIQCUVoCVjmQ@public.gmane.org>
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus git tree from:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: fa7614ddd6c2368b8cd54cc67ab4b767af0a2a50 fs: Readd the fs module aliases.

This tree includes a partial revert for "fs: Limit sys_mount to only
request filesystem modules." When I added the new style module aliases
to the filesystems I deleted the old ones.  A bad move.   It turns out
that distributions like Arch linux use module aliases when constructing
ramdisks.  Which meant ultimately that an ext3 filesystem mounted with
ext4 would not result in the ext4 module being put into the ramdisk.

The other change in this tree adds a handful of filesystem module alias
I simply failed to add the first time.  Which inconvinienced a few folks
using cifs.

I don't want to inconvinience folks any longer than I have to so here
are these trivial fixes.

Eric W. Biederman (2):
      fs: Limit sys_mount to only request filesystem modules. (Part 3)
      fs: Readd the fs module aliases.

 fs/cifs/cifsfs.c         |    1 +
 fs/ext4/super.c          |    2 ++
 fs/freevxfs/vxfs_super.c |    1 +
 fs/hostfs/hostfs_kern.c  |    1 +
 fs/hpfs/super.c          |    1 +
 fs/isofs/inode.c         |    1 +
 fs/nfs/super.c           |    1 +
 fs/squashfs/super.c      |    1 +
 fs/sysv/super.c          |    1 +
 fs/udf/super.c           |    1 +
 net/sunrpc/rpc_pipe.c    |    1 +
 11 files changed, 12 insertions(+), 0 deletions(-)
---
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 1a052c0..3cf8a15 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -777,6 +777,7 @@ struct file_system_type cifs_fs_type = {
 	.kill_sb = cifs_kill_sb,
 	/*  .fs_flags */
 };
+MODULE_ALIAS_FS("cifs");
 const struct inode_operations cifs_dir_inode_ops = {
 	.create = cifs_create,
 	.atomic_open = cifs_atomic_open,
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 34e8552..b3818b4 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -91,6 +91,7 @@ static struct file_system_type ext2_fs_type = {
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 MODULE_ALIAS_FS("ext2");
+MODULE_ALIAS("ext2");
 #define IS_EXT2_SB(sb) ((sb)->s_bdev->bd_holder == &ext2_fs_type)
 #else
 #define IS_EXT2_SB(sb) (0)
@@ -106,6 +107,7 @@ static struct file_system_type ext3_fs_type = {
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 MODULE_ALIAS_FS("ext3");
+MODULE_ALIAS("ext3");
 #define IS_EXT3_SB(sb) ((sb)->s_bdev->bd_holder == &ext3_fs_type)
 #else
 #define IS_EXT3_SB(sb) (0)
diff --git a/fs/freevxfs/vxfs_super.c b/fs/freevxfs/vxfs_super.c
index 4550743..e37eb27 100644
--- a/fs/freevxfs/vxfs_super.c
+++ b/fs/freevxfs/vxfs_super.c
@@ -258,6 +258,7 @@ static struct file_system_type vxfs_fs_type = {
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 MODULE_ALIAS_FS("vxfs"); /* makes mount -t vxfs autoload the module */
+MODULE_ALIAS("vxfs");
 
 static int __init
 vxfs_init(void)
diff --git a/fs/hostfs/hostfs_kern.c b/fs/hostfs/hostfs_kern.c
index fbabb90..e3c6d50 100644
--- a/fs/hostfs/hostfs_kern.c
+++ b/fs/hostfs/hostfs_kern.c
@@ -993,6 +993,7 @@ static struct file_system_type hostfs_type = {
 	.kill_sb	= hostfs_kill_sb,
 	.fs_flags 	= 0,
 };
+MODULE_ALIAS_FS("hostfs");
 
 static int __init init_hostfs(void)
 {
diff --git a/fs/hpfs/super.c b/fs/hpfs/super.c
index a307622..a0617e7 100644
--- a/fs/hpfs/super.c
+++ b/fs/hpfs/super.c
@@ -688,6 +688,7 @@ static struct file_system_type hpfs_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("hpfs");
 
 static int __init init_hpfs_fs(void)
 {
diff --git a/fs/isofs/inode.c b/fs/isofs/inode.c
index a67f16e..d9b8aeb 100644
--- a/fs/isofs/inode.c
+++ b/fs/isofs/inode.c
@@ -1557,6 +1557,7 @@ static struct file_system_type iso9660_fs_type = {
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 MODULE_ALIAS_FS("iso9660");
+MODULE_ALIAS("iso9660");
 
 static int __init init_iso9660_fs(void)
 {
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 95cdcb2..2f8a29d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -335,6 +335,7 @@ struct file_system_type nfs4_fs_type = {
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
 };
 MODULE_ALIAS_FS("nfs4");
+MODULE_ALIAS("nfs4");
 EXPORT_SYMBOL_GPL(nfs4_fs_type);
 
 static int __init register_nfs4_fs(void)
diff --git a/fs/squashfs/super.c b/fs/squashfs/super.c
index 260e392..60553a9 100644
--- a/fs/squashfs/super.c
+++ b/fs/squashfs/super.c
@@ -489,6 +489,7 @@ static struct file_system_type squashfs_fs_type = {
 	.kill_sb = kill_block_super,
 	.fs_flags = FS_REQUIRES_DEV
 };
+MODULE_ALIAS_FS("squashfs");
 
 static const struct super_operations squashfs_super_ops = {
 	.alloc_inode = squashfs_alloc_inode,
diff --git a/fs/sysv/super.c b/fs/sysv/super.c
index a39938b..d0c6a00 100644
--- a/fs/sysv/super.c
+++ b/fs/sysv/super.c
@@ -555,6 +555,7 @@ static struct file_system_type v7_fs_type = {
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 MODULE_ALIAS_FS("v7");
+MODULE_ALIAS("v7");
 
 static int __init init_sysv_fs(void)
 {
diff --git a/fs/udf/super.c b/fs/udf/super.c
index bc5b30a..9ac4057 100644
--- a/fs/udf/super.c
+++ b/fs/udf/super.c
@@ -118,6 +118,7 @@ static struct file_system_type udf_fstype = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("udf");
 
 static struct kmem_cache *udf_inode_cachep;
 
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index a0f48a5..a9129f8 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1175,6 +1175,7 @@ static struct file_system_type rpc_pipe_fs_type = {
 	.kill_sb	= rpc_kill_sb,
 };
 MODULE_ALIAS_FS("rpc_pipefs");
+MODULE_ALIAS("rpc_pipefs");
 
 static void
 init_once(void *foo)
