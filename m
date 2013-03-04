From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 2/2] fs: Limit sys_mount to only request filesystem modules.
Date: Sun, 03 Mar 2013 23:51:00 -0800
Message-ID: <878v63mwm3.fsf_-_@xmission.com>
References: <CAGXu5jK7x+gFKgCN5=ZF+kSc4xSNbGtSERHCoOnCEgiJ1_wNGg@mail.gmail.com>
	<20130303005700.GA32213@austin.hallyn.com>
	<874ngtxgt5.fsf@xmission.com>
	<CAGXu5j+bwUx6r++ttvYg4yJrUUHxoQ86tQ0JzEBoQQU6KAh9ww@mail.gmail.com>
	<874ngsrvrh.fsf@xmission.com>
	<CAGXu5jJiO=BmjVbpVJhxHbafn5T_SQbe5g-RLxRbmknNnQMyfQ@mail.gmail.com>
	<87k3pnmwpk.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k3pnmwpk.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Sun, 03 Mar 2013 23:48:55 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kees Cook <keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Brad Spengler <spender-JNS0hek0TMl4qEwOxq4T+Q@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, PaX Team <pageexec-Y8qEzhMunLyT9ig0jae3mg@public.gmane.org>, Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Modify the request_module to prefix the file system type with "fs-"
and add aliases to all of the filesystems that can be built as modules
to match.

A common practice is to build all of the kernel code and leave code
that is not commonly needed as modules, with the result that many
users are exposed to any bug anywhere in the kernel.

Looking for filesystems with a fs- prefix limits the pool of possible
modules that can be loaded by mount to just filesystems trivially
making things safer with no real cost.

Using aliases means user space can control the policy of which
filesystem modules are auto-loaded by editing /etc/modprobe.d/*.conf
with blacklist and alias directives.  Allowing simple, safe,
well understood work-arounds to known problematic software.

This also addresses a rare but unfortunate problem where the filesystem
name is not the same as it's module name and module auto-loading
would not work.  While writing this patch I saw a handful of such
cases.  The most significant being autofs that lives in the module
autofs4.

This is relevant to user namespaces because we can reach the request
module in get_fs_type() without having any special permissions, and
people get uncomfortable when a user specified string (in this case
the filesystem type) goes all of the way to request_module.

After having looked at this issue I don't think there is any
particular reason to perform any filtering or permission checks beyond
making it clear in the module request that we want a filesystem
module.  The common pattern in the kernel is to call request_module()
without regards to the users permissions.  In general all a filesystem
module does once loaded is call register_filesystem() and go to sleep.
Which means there is not much attack surface exposed by loading a
filesytem module unless the filesystem is mounted.  In a user
namespace filesystems are not mounted unless .fs_flags = FS_USERNS_MOUNT,
which most filesystems do not set today.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Acked-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Reported-by: Kees Cook <keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 arch/ia64/kernel/perfmon.c                |    1 +
 arch/powerpc/platforms/cell/spufs/inode.c |    1 +
 arch/s390/hypfs/inode.c                   |    1 +
 drivers/firmware/efivars.c                |    1 +
 drivers/infiniband/hw/ipath/ipath_fs.c    |    1 +
 drivers/infiniband/hw/qib/qib_fs.c        |    1 +
 drivers/misc/ibmasm/ibmasmfs.c            |    1 +
 drivers/mtd/mtdchar.c                     |    1 +
 drivers/oprofile/oprofilefs.c             |    1 +
 drivers/staging/ccg/f_fs.c                |    1 +
 drivers/usb/gadget/f_fs.c                 |    1 +
 drivers/usb/gadget/inode.c                |    1 +
 drivers/xen/xenfs/super.c                 |    1 +
 fs/9p/vfs_super.c                         |    1 +
 fs/adfs/super.c                           |    1 +
 fs/affs/super.c                           |    1 +
 fs/afs/super.c                            |    1 +
 fs/autofs4/init.c                         |    1 +
 fs/befs/linuxvfs.c                        |    1 +
 fs/bfs/inode.c                            |    1 +
 fs/binfmt_misc.c                          |    1 +
 fs/btrfs/super.c                          |    1 +
 fs/ceph/super.c                           |    1 +
 fs/coda/inode.c                           |    1 +
 fs/configfs/mount.c                       |    1 +
 fs/cramfs/inode.c                         |    1 +
 fs/debugfs/inode.c                        |    1 +
 fs/devpts/inode.c                         |    1 +
 fs/ecryptfs/main.c                        |    1 +
 fs/efs/super.c                            |    1 +
 fs/exofs/super.c                          |    1 +
 fs/ext2/super.c                           |    1 +
 fs/ext3/super.c                           |    1 +
 fs/ext4/super.c                           |    5 +++--
 fs/f2fs/super.c                           |    1 +
 fs/fat/namei_msdos.c                      |    1 +
 fs/fat/namei_vfat.c                       |    1 +
 fs/filesystems.c                          |    2 +-
 fs/freevxfs/vxfs_super.c                  |    2 +-
 fs/fuse/control.c                         |    1 +
 fs/fuse/inode.c                           |    2 ++
 fs/gfs2/ops_fstype.c                      |    4 +++-
 fs/hfs/super.c                            |    1 +
 fs/hfsplus/super.c                        |    1 +
 fs/hppfs/hppfs.c                          |    1 +
 fs/hugetlbfs/inode.c                      |    1 +
 fs/isofs/inode.c                          |    3 +--
 fs/jffs2/super.c                          |    1 +
 fs/jfs/super.c                            |    1 +
 fs/logfs/super.c                          |    1 +
 fs/minix/inode.c                          |    1 +
 fs/ncpfs/inode.c                          |    1 +
 fs/nfs/super.c                            |    3 ++-
 fs/nfsd/nfsctl.c                          |    1 +
 fs/nilfs2/super.c                         |    1 +
 fs/ntfs/super.c                           |    1 +
 fs/ocfs2/dlmfs/dlmfs.c                    |    1 +
 fs/omfs/inode.c                           |    1 +
 fs/openpromfs/inode.c                     |    1 +
 fs/qnx4/inode.c                           |    1 +
 fs/qnx6/inode.c                           |    1 +
 fs/reiserfs/super.c                       |    1 +
 fs/romfs/super.c                          |    1 +
 fs/sysv/super.c                           |    3 ++-
 fs/ubifs/super.c                          |    1 +
 fs/ufs/super.c                            |    1 +
 fs/xfs/xfs_super.c                        |    1 +
 include/linux/fs.h                        |    2 ++
 net/sunrpc/rpc_pipe.c                     |    4 +---
 69 files changed, 77 insertions(+), 12 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 433f5e8..2eda284 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -619,6 +619,7 @@ static struct file_system_type pfm_fs_type = {
 	.mount    = pfmfs_mount,
 	.kill_sb  = kill_anon_super,
 };
+MODULE_ALIAS_FS("pfmfs");
 
 DEFINE_PER_CPU(unsigned long, pfm_syst_info);
 DEFINE_PER_CPU(struct task_struct *, pmu_owner);
diff --git a/arch/powerpc/platforms/cell/spufs/inode.c b/arch/powerpc/platforms/cell/spufs/inode.c
index 863184b..3f3bb4c 100644
--- a/arch/powerpc/platforms/cell/spufs/inode.c
+++ b/arch/powerpc/platforms/cell/spufs/inode.c
@@ -749,6 +749,7 @@ static struct file_system_type spufs_type = {
 	.mount = spufs_mount,
 	.kill_sb = kill_litter_super,
 };
+MODULE_ALIAS_FS("spufs");
 
 static int __init spufs_init(void)
 {
diff --git a/arch/s390/hypfs/inode.c b/arch/s390/hypfs/inode.c
index 8538015..5f7d7ba 100644
--- a/arch/s390/hypfs/inode.c
+++ b/arch/s390/hypfs/inode.c
@@ -456,6 +456,7 @@ static struct file_system_type hypfs_type = {
 	.mount		= hypfs_mount,
 	.kill_sb	= hypfs_kill_super
 };
+MODULE_ALIAS_FS("s390_hypfs");
 
 static const struct super_operations hypfs_s_ops = {
 	.statfs		= simple_statfs,
diff --git a/drivers/firmware/efivars.c b/drivers/firmware/efivars.c
index 7320bf8..3edade0 100644
--- a/drivers/firmware/efivars.c
+++ b/drivers/firmware/efivars.c
@@ -1234,6 +1234,7 @@ static struct file_system_type efivarfs_type = {
 	.mount   = efivarfs_mount,
 	.kill_sb = efivarfs_kill_sb,
 };
+MODULE_ALIAS_FS("efivarfs");
 
 /*
  * Handle negative dentry.
diff --git a/drivers/infiniband/hw/ipath/ipath_fs.c b/drivers/infiniband/hw/ipath/ipath_fs.c
index a479375..e0c404b 100644
--- a/drivers/infiniband/hw/ipath/ipath_fs.c
+++ b/drivers/infiniband/hw/ipath/ipath_fs.c
@@ -410,6 +410,7 @@ static struct file_system_type ipathfs_fs_type = {
 	.mount =	ipathfs_mount,
 	.kill_sb =	ipathfs_kill_super,
 };
+MODULE_ALIAS_FS("ipathfs");
 
 int __init ipath_init_ipathfs(void)
 {
diff --git a/drivers/infiniband/hw/qib/qib_fs.c b/drivers/infiniband/hw/qib/qib_fs.c
index 644bd6f..f247fc6e 100644
--- a/drivers/infiniband/hw/qib/qib_fs.c
+++ b/drivers/infiniband/hw/qib/qib_fs.c
@@ -604,6 +604,7 @@ static struct file_system_type qibfs_fs_type = {
 	.mount =        qibfs_mount,
 	.kill_sb =      qibfs_kill_super,
 };
+MODULE_ALIAS_FS("ipathfs");
 
 int __init qib_init_qibfs(void)
 {
diff --git a/drivers/misc/ibmasm/ibmasmfs.c b/drivers/misc/ibmasm/ibmasmfs.c
index 6673e57..ce5b756 100644
--- a/drivers/misc/ibmasm/ibmasmfs.c
+++ b/drivers/misc/ibmasm/ibmasmfs.c
@@ -110,6 +110,7 @@ static struct file_system_type ibmasmfs_type = {
 	.mount          = ibmasmfs_mount,
 	.kill_sb        = kill_litter_super,
 };
+MODULE_ALIAS_FS("ibmasmfs");
 
 static int ibmasmfs_fill_super (struct super_block *sb, void *data, int silent)
 {
diff --git a/drivers/mtd/mtdchar.c b/drivers/mtd/mtdchar.c
index 82c0616..92ab30a 100644
--- a/drivers/mtd/mtdchar.c
+++ b/drivers/mtd/mtdchar.c
@@ -1238,6 +1238,7 @@ static struct file_system_type mtd_inodefs_type = {
        .mount = mtd_inodefs_mount,
        .kill_sb = kill_anon_super,
 };
+MODULE_ALIAS_FS("mtd_inodefs");
 
 static int __init init_mtdchar(void)
 {
diff --git a/drivers/oprofile/oprofilefs.c b/drivers/oprofile/oprofilefs.c
index 445ffda..7c12d9c 100644
--- a/drivers/oprofile/oprofilefs.c
+++ b/drivers/oprofile/oprofilefs.c
@@ -276,6 +276,7 @@ static struct file_system_type oprofilefs_type = {
 	.mount		= oprofilefs_mount,
 	.kill_sb	= kill_litter_super,
 };
+MODULE_ALIAS_FS("oprofilefs");
 
 
 int __init oprofilefs_register(void)
diff --git a/drivers/staging/ccg/f_fs.c b/drivers/staging/ccg/f_fs.c
index 8adc79d..f6373da 100644
--- a/drivers/staging/ccg/f_fs.c
+++ b/drivers/staging/ccg/f_fs.c
@@ -1223,6 +1223,7 @@ static struct file_system_type ffs_fs_type = {
 	.mount		= ffs_fs_mount,
 	.kill_sb	= ffs_fs_kill_sb,
 };
+MODULE_ALIAS_FS("functionfs");
 
 
 /* Driver's main init/cleanup functions *************************************/
diff --git a/drivers/usb/gadget/f_fs.c b/drivers/usb/gadget/f_fs.c
index 38388d7..c377ff8 100644
--- a/drivers/usb/gadget/f_fs.c
+++ b/drivers/usb/gadget/f_fs.c
@@ -1235,6 +1235,7 @@ static struct file_system_type ffs_fs_type = {
 	.mount		= ffs_fs_mount,
 	.kill_sb	= ffs_fs_kill_sb,
 };
+MODULE_ALIAS_FS("functionfs");
 
 
 /* Driver's main init/cleanup functions *************************************/
diff --git a/drivers/usb/gadget/inode.c b/drivers/usb/gadget/inode.c
index 8ac840f..e2b2e9c 100644
--- a/drivers/usb/gadget/inode.c
+++ b/drivers/usb/gadget/inode.c
@@ -2105,6 +2105,7 @@ static struct file_system_type gadgetfs_type = {
 	.mount		= gadgetfs_mount,
 	.kill_sb	= gadgetfs_kill_sb,
 };
+MODULE_ALIAS_FS("gadgetfs");
 
 /*----------------------------------------------------------------------*/
 
diff --git a/drivers/xen/xenfs/super.c b/drivers/xen/xenfs/super.c
index ec0abb6..7167987 100644
--- a/drivers/xen/xenfs/super.c
+++ b/drivers/xen/xenfs/super.c
@@ -75,6 +75,7 @@ static struct file_system_type xenfs_type = {
 	.mount =	xenfs_mount,
 	.kill_sb =	kill_litter_super,
 };
+MODULE_ALIAS_FS("xenfs");
 
 static int __init xenfs_init(void)
 {
diff --git a/fs/9p/vfs_super.c b/fs/9p/vfs_super.c
index 91dad63..2756dcd 100644
--- a/fs/9p/vfs_super.c
+++ b/fs/9p/vfs_super.c
@@ -365,3 +365,4 @@ struct file_system_type v9fs_fs_type = {
 	.owner = THIS_MODULE,
 	.fs_flags = FS_RENAME_DOES_D_MOVE,
 };
+MODULE_ALIAS_FS("9p");
diff --git a/fs/adfs/super.c b/fs/adfs/super.c
index d571229..0ff4bae 100644
--- a/fs/adfs/super.c
+++ b/fs/adfs/super.c
@@ -524,6 +524,7 @@ static struct file_system_type adfs_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("adfs");
 
 static int __init init_adfs_fs(void)
 {
diff --git a/fs/affs/super.c b/fs/affs/super.c
index b84dc73..45161a8 100644
--- a/fs/affs/super.c
+++ b/fs/affs/super.c
@@ -622,6 +622,7 @@ static struct file_system_type affs_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("affs");
 
 static int __init init_affs_fs(void)
 {
diff --git a/fs/afs/super.c b/fs/afs/super.c
index 7c31ec3..c486155 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -45,6 +45,7 @@ struct file_system_type afs_fs_type = {
 	.kill_sb	= afs_kill_super,
 	.fs_flags	= 0,
 };
+MODULE_ALIAS_FS("afs");
 
 static const struct super_operations afs_super_ops = {
 	.statfs		= afs_statfs,
diff --git a/fs/autofs4/init.c b/fs/autofs4/init.c
index cddc74b..b3db517 100644
--- a/fs/autofs4/init.c
+++ b/fs/autofs4/init.c
@@ -26,6 +26,7 @@ static struct file_system_type autofs_fs_type = {
 	.mount		= autofs_mount,
 	.kill_sb	= autofs4_kill_sb,
 };
+MODULE_ALIAS_FS("autofs");
 
 static int __init init_autofs4_fs(void)
 {
diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
index c8f4e25..8615ee8 100644
--- a/fs/befs/linuxvfs.c
+++ b/fs/befs/linuxvfs.c
@@ -951,6 +951,7 @@ static struct file_system_type befs_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,	
 };
+MODULE_ALIAS_FS("befs");
 
 static int __init
 init_befs_fs(void)
diff --git a/fs/bfs/inode.c b/fs/bfs/inode.c
index 737aaa3..5e376bb 100644
--- a/fs/bfs/inode.c
+++ b/fs/bfs/inode.c
@@ -473,6 +473,7 @@ static struct file_system_type bfs_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("bfs");
 
 static int __init init_bfs_fs(void)
 {
diff --git a/fs/binfmt_misc.c b/fs/binfmt_misc.c
index fecbbf3..751df5e 100644
--- a/fs/binfmt_misc.c
+++ b/fs/binfmt_misc.c
@@ -720,6 +720,7 @@ static struct file_system_type bm_fs_type = {
 	.mount		= bm_mount,
 	.kill_sb	= kill_litter_super,
 };
+MODULE_ALIAS_FS("binfmt_misc");
 
 static int __init init_misc_binfmt(void)
 {
diff --git a/fs/btrfs/super.c b/fs/btrfs/super.c
index 68a29a1..f6b8859 100644
--- a/fs/btrfs/super.c
+++ b/fs/btrfs/super.c
@@ -1558,6 +1558,7 @@ static struct file_system_type btrfs_fs_type = {
 	.kill_sb	= btrfs_kill_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("btrfs");
 
 /*
  * used by btrfsctl to scan devices when no FS is mounted
diff --git a/fs/ceph/super.c b/fs/ceph/super.c
index 9fe17c6c..6ddc0bc 100644
--- a/fs/ceph/super.c
+++ b/fs/ceph/super.c
@@ -952,6 +952,7 @@ static struct file_system_type ceph_fs_type = {
 	.kill_sb	= ceph_kill_sb,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE,
 };
+MODULE_ALIAS_FS("ceph");
 
 #define _STRINGIFY(x) #x
 #define STRINGIFY(x) _STRINGIFY(x)
diff --git a/fs/coda/inode.c b/fs/coda/inode.c
index dada9d0..4dcc0d8 100644
--- a/fs/coda/inode.c
+++ b/fs/coda/inode.c
@@ -329,4 +329,5 @@ struct file_system_type coda_fs_type = {
 	.kill_sb	= kill_anon_super,
 	.fs_flags	= FS_BINARY_MOUNTDATA,
 };
+MODULE_ALIAS_FS("coda");
 
diff --git a/fs/configfs/mount.c b/fs/configfs/mount.c
index aee0a7e..7f26c3c 100644
--- a/fs/configfs/mount.c
+++ b/fs/configfs/mount.c
@@ -114,6 +114,7 @@ static struct file_system_type configfs_fs_type = {
 	.mount		= configfs_do_mount,
 	.kill_sb	= kill_litter_super,
 };
+MODULE_ALIAS_FS("configfs");
 
 struct dentry *configfs_pin_fs(void)
 {
diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index 3ceb9ec..35b1c7b 100644
--- a/fs/cramfs/inode.c
+++ b/fs/cramfs/inode.c
@@ -573,6 +573,7 @@ static struct file_system_type cramfs_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("cramfs");
 
 static int __init init_cramfs_fs(void)
 {
diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
index 0c4f80b..4888cb3 100644
--- a/fs/debugfs/inode.c
+++ b/fs/debugfs/inode.c
@@ -299,6 +299,7 @@ static struct file_system_type debug_fs_type = {
 	.mount =	debug_mount,
 	.kill_sb =	kill_litter_super,
 };
+MODULE_ALIAS_FS("debugfs");
 
 static struct dentry *__create_file(const char *name, umode_t mode,
 				    struct dentry *parent, void *data,
diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 073d30b..79b6629 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -510,6 +510,7 @@ static struct file_system_type devpts_fs_type = {
 	.fs_flags	= FS_USERNS_MOUNT | FS_USERNS_DEV_MOUNT,
 #endif
 };
+MODULE_ALIAS_FS("devpts");
 
 /*
  * The normal naming convention is simply /dev/pts/<number>; this conforms
diff --git a/fs/ecryptfs/main.c b/fs/ecryptfs/main.c
index 4e0886c..e924cf4 100644
--- a/fs/ecryptfs/main.c
+++ b/fs/ecryptfs/main.c
@@ -629,6 +629,7 @@ static struct file_system_type ecryptfs_fs_type = {
 	.kill_sb = ecryptfs_kill_block_super,
 	.fs_flags = 0
 };
+MODULE_ALIAS_FS("ecryptfs");
 
 /**
  * inode_info_init_once
diff --git a/fs/efs/super.c b/fs/efs/super.c
index 2002431..c6f57a7 100644
--- a/fs/efs/super.c
+++ b/fs/efs/super.c
@@ -33,6 +33,7 @@ static struct file_system_type efs_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("efs");
 
 static struct pt_types sgi_pt_types[] = {
 	{0x00,		"SGI vh"},
diff --git a/fs/exofs/super.c b/fs/exofs/super.c
index 5e59280..9d97633 100644
--- a/fs/exofs/super.c
+++ b/fs/exofs/super.c
@@ -1010,6 +1010,7 @@ static struct file_system_type exofs_type = {
 	.mount          = exofs_mount,
 	.kill_sb        = generic_shutdown_super,
 };
+MODULE_ALIAS_FS("exofs");
 
 static int __init init_exofs(void)
 {
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index 7f68c81..2885349 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -1536,6 +1536,7 @@ static struct file_system_type ext2_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("ext2");
 
 static int __init init_ext2_fs(void)
 {
diff --git a/fs/ext3/super.c b/fs/ext3/super.c
index 5546ca2..1d6e2ed 100644
--- a/fs/ext3/super.c
+++ b/fs/ext3/super.c
@@ -3068,6 +3068,7 @@ static struct file_system_type ext3_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("ext3");
 
 static int __init init_ext3_fs(void)
 {
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 5e6c878..34e8552 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -90,6 +90,7 @@ static struct file_system_type ext2_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("ext2");
 #define IS_EXT2_SB(sb) ((sb)->s_bdev->bd_holder == &ext2_fs_type)
 #else
 #define IS_EXT2_SB(sb) (0)
@@ -104,6 +105,7 @@ static struct file_system_type ext3_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("ext3");
 #define IS_EXT3_SB(sb) ((sb)->s_bdev->bd_holder == &ext3_fs_type)
 #else
 #define IS_EXT3_SB(sb) (0)
@@ -5152,7 +5154,6 @@ static inline int ext2_feature_set_ok(struct super_block *sb)
 		return 0;
 	return 1;
 }
-MODULE_ALIAS("ext2");
 #else
 static inline void register_as_ext2(void) { }
 static inline void unregister_as_ext2(void) { }
@@ -5185,7 +5186,6 @@ static inline int ext3_feature_set_ok(struct super_block *sb)
 		return 0;
 	return 1;
 }
-MODULE_ALIAS("ext3");
 #else
 static inline void register_as_ext3(void) { }
 static inline void unregister_as_ext3(void) { }
@@ -5199,6 +5199,7 @@ static struct file_system_type ext4_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("ext4");
 
 static int __init ext4_init_feat_adverts(void)
 {
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 8c11764..fea6e58 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -687,6 +687,7 @@ static struct file_system_type f2fs_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("f2fs");
 
 static int __init init_inodecache(void)
 {
diff --git a/fs/fat/namei_msdos.c b/fs/fat/namei_msdos.c
index e2cfda9..081b759 100644
--- a/fs/fat/namei_msdos.c
+++ b/fs/fat/namei_msdos.c
@@ -668,6 +668,7 @@ static struct file_system_type msdos_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("msdos");
 
 static int __init init_msdos_fs(void)
 {
diff --git a/fs/fat/namei_vfat.c b/fs/fat/namei_vfat.c
index ac959d6..2da9520 100644
--- a/fs/fat/namei_vfat.c
+++ b/fs/fat/namei_vfat.c
@@ -1073,6 +1073,7 @@ static struct file_system_type vfat_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("vfat");
 
 static int __init init_vfat_fs(void)
 {
diff --git a/fs/filesystems.c b/fs/filesystems.c
index da165f6..92567d9 100644
--- a/fs/filesystems.c
+++ b/fs/filesystems.c
@@ -273,7 +273,7 @@ struct file_system_type *get_fs_type(const char *name)
 	int len = dot ? dot - name : strlen(name);
 
 	fs = __get_fs_type(name, len);
-	if (!fs && (request_module("%.*s", len, name) == 0))
+	if (!fs && (request_module("fs-%.*s", len, name) == 0))
 		fs = __get_fs_type(name, len);
 
 	if (dot && fs && !(fs->fs_flags & FS_HAS_SUBTYPE)) {
diff --git a/fs/freevxfs/vxfs_super.c b/fs/freevxfs/vxfs_super.c
index fed2c8a..4550743 100644
--- a/fs/freevxfs/vxfs_super.c
+++ b/fs/freevxfs/vxfs_super.c
@@ -52,7 +52,6 @@ MODULE_AUTHOR("Christoph Hellwig");
 MODULE_DESCRIPTION("Veritas Filesystem (VxFS) driver");
 MODULE_LICENSE("Dual BSD/GPL");
 
-MODULE_ALIAS("vxfs"); /* makes mount -t vxfs autoload the module */
 
 
 static void		vxfs_put_super(struct super_block *);
@@ -258,6 +257,7 @@ static struct file_system_type vxfs_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("vxfs"); /* makes mount -t vxfs autoload the module */
 
 static int __init
 vxfs_init(void)
diff --git a/fs/fuse/control.c b/fs/fuse/control.c
index b7978b9f..a0b0855 100644
--- a/fs/fuse/control.c
+++ b/fs/fuse/control.c
@@ -341,6 +341,7 @@ static struct file_system_type fuse_ctl_fs_type = {
 	.mount		= fuse_ctl_mount,
 	.kill_sb	= fuse_ctl_kill_sb,
 };
+MODULE_ALIAS_FS("fusectl");
 
 int __init fuse_ctl_init(void)
 {
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index df00993..137185c 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -1117,6 +1117,7 @@ static struct file_system_type fuse_fs_type = {
 	.mount		= fuse_mount,
 	.kill_sb	= fuse_kill_sb_anon,
 };
+MODULE_ALIAS_FS("fuse");
 
 #ifdef CONFIG_BLOCK
 static struct dentry *fuse_mount_blk(struct file_system_type *fs_type,
@@ -1146,6 +1147,7 @@ static struct file_system_type fuseblk_fs_type = {
 	.kill_sb	= fuse_kill_sb_blk,
 	.fs_flags	= FS_REQUIRES_DEV | FS_HAS_SUBTYPE,
 };
+MODULE_ALIAS_FS("fuseblk");
 
 static inline int register_fuseblk(void)
 {
diff --git a/fs/gfs2/ops_fstype.c b/fs/gfs2/ops_fstype.c
index 1b612be..60ede2a 100644
--- a/fs/gfs2/ops_fstype.c
+++ b/fs/gfs2/ops_fstype.c
@@ -20,6 +20,7 @@
 #include <linux/gfs2_ondisk.h>
 #include <linux/quotaops.h>
 #include <linux/lockdep.h>
+#include <linux/module.h>
 
 #include "gfs2.h"
 #include "incore.h"
@@ -1425,6 +1426,7 @@ struct file_system_type gfs2_fs_type = {
 	.kill_sb = gfs2_kill_sb,
 	.owner = THIS_MODULE,
 };
+MODULE_ALIAS_FS("gfs2");
 
 struct file_system_type gfs2meta_fs_type = {
 	.name = "gfs2meta",
@@ -1432,4 +1434,4 @@ struct file_system_type gfs2meta_fs_type = {
 	.mount = gfs2_mount_meta,
 	.owner = THIS_MODULE,
 };
-
+MODULE_ALIAS_FS("gfs2meta");
diff --git a/fs/hfs/super.c b/fs/hfs/super.c
index e93ddaa..bbaaa8a 100644
--- a/fs/hfs/super.c
+++ b/fs/hfs/super.c
@@ -466,6 +466,7 @@ static struct file_system_type hfs_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("hfs");
 
 static void hfs_init_once(void *p)
 {
diff --git a/fs/hfsplus/super.c b/fs/hfsplus/super.c
index 974c26f..7b87284 100644
--- a/fs/hfsplus/super.c
+++ b/fs/hfsplus/super.c
@@ -654,6 +654,7 @@ static struct file_system_type hfsplus_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("hfsplus");
 
 static void hfsplus_init_once(void *p)
 {
diff --git a/fs/hppfs/hppfs.c b/fs/hppfs/hppfs.c
index 74f5570..126d3c2 100644
--- a/fs/hppfs/hppfs.c
+++ b/fs/hppfs/hppfs.c
@@ -748,6 +748,7 @@ static struct file_system_type hppfs_type = {
 	.kill_sb	= kill_anon_super,
 	.fs_flags 	= 0,
 };
+MODULE_ALIAS_FS("hppfs");
 
 static int __init init_hppfs(void)
 {
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 7f94e0c..84e3d85 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -896,6 +896,7 @@ static struct file_system_type hugetlbfs_fs_type = {
 	.mount		= hugetlbfs_mount,
 	.kill_sb	= kill_litter_super,
 };
+MODULE_ALIAS_FS("hugetlbfs");
 
 static struct vfsmount *hugetlbfs_vfsmount[HUGE_MAX_HSTATE];
 
diff --git a/fs/isofs/inode.c b/fs/isofs/inode.c
index 67ce525..a67f16e 100644
--- a/fs/isofs/inode.c
+++ b/fs/isofs/inode.c
@@ -1556,6 +1556,7 @@ static struct file_system_type iso9660_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("iso9660");
 
 static int __init init_iso9660_fs(void)
 {
@@ -1593,5 +1594,3 @@ static void __exit exit_iso9660_fs(void)
 module_init(init_iso9660_fs)
 module_exit(exit_iso9660_fs)
 MODULE_LICENSE("GPL");
-/* Actual filesystem name is iso9660, as requested in filesystems.c */
-MODULE_ALIAS("iso9660");
diff --git a/fs/jffs2/super.c b/fs/jffs2/super.c
index d3d8799..0defb1c 100644
--- a/fs/jffs2/super.c
+++ b/fs/jffs2/super.c
@@ -356,6 +356,7 @@ static struct file_system_type jffs2_fs_type = {
 	.mount =	jffs2_mount,
 	.kill_sb =	jffs2_kill_sb,
 };
+MODULE_ALIAS_FS("jffs2");
 
 static int __init init_jffs2_fs(void)
 {
diff --git a/fs/jfs/super.c b/fs/jfs/super.c
index 060ba63..2003e83 100644
--- a/fs/jfs/super.c
+++ b/fs/jfs/super.c
@@ -833,6 +833,7 @@ static struct file_system_type jfs_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("jfs");
 
 static void init_once(void *foo)
 {
diff --git a/fs/logfs/super.c b/fs/logfs/super.c
index 345c24b..5436029 100644
--- a/fs/logfs/super.c
+++ b/fs/logfs/super.c
@@ -608,6 +608,7 @@ static struct file_system_type logfs_fs_type = {
 	.fs_flags	= FS_REQUIRES_DEV,
 
 };
+MODULE_ALIAS_FS("logfs");
 
 static int __init logfs_init(void)
 {
diff --git a/fs/minix/inode.c b/fs/minix/inode.c
index 99541cc..df12249 100644
--- a/fs/minix/inode.c
+++ b/fs/minix/inode.c
@@ -660,6 +660,7 @@ static struct file_system_type minix_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("minix");
 
 static int __init init_minix_fs(void)
 {
diff --git a/fs/ncpfs/inode.c b/fs/ncpfs/inode.c
index 7dafd6899..26910c8 100644
--- a/fs/ncpfs/inode.c
+++ b/fs/ncpfs/inode.c
@@ -1051,6 +1051,7 @@ static struct file_system_type ncp_fs_type = {
 	.kill_sb	= kill_anon_super,
 	.fs_flags	= FS_BINARY_MOUNTDATA,
 };
+MODULE_ALIAS_FS("ncpfs");
 
 static int __init init_ncp_fs(void)
 {
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 17b32b7..95cdcb2 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -294,6 +294,7 @@ struct file_system_type nfs_fs_type = {
 	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
 };
+MODULE_ALIAS_FS("nfs");
 EXPORT_SYMBOL_GPL(nfs_fs_type);
 
 struct file_system_type nfs_xdev_fs_type = {
@@ -333,6 +334,7 @@ struct file_system_type nfs4_fs_type = {
 	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
 };
+MODULE_ALIAS_FS("nfs4");
 EXPORT_SYMBOL_GPL(nfs4_fs_type);
 
 static int __init register_nfs4_fs(void)
@@ -2717,6 +2719,5 @@ module_param(send_implementation_id, ushort, 0644);
 MODULE_PARM_DESC(send_implementation_id,
 		"Send implementation ID with NFSv4.1 exchange_id");
 MODULE_PARM_DESC(nfs4_unique_id, "nfs_client_id4 uniquifier string");
-MODULE_ALIAS("nfs4");
 
 #endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 13a21c8..f33455b 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1090,6 +1090,7 @@ static struct file_system_type nfsd_fs_type = {
 	.mount		= nfsd_mount,
 	.kill_sb	= nfsd_umount,
 };
+MODULE_ALIAS_FS("nfsd");
 
 #ifdef CONFIG_PROC_FS
 static int create_proc_exports_entry(void)
diff --git a/fs/nilfs2/super.c b/fs/nilfs2/super.c
index 3c991dc..c7d1f9f 100644
--- a/fs/nilfs2/super.c
+++ b/fs/nilfs2/super.c
@@ -1361,6 +1361,7 @@ struct file_system_type nilfs_fs_type = {
 	.kill_sb  = kill_block_super,
 	.fs_flags = FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("nilfs2");
 
 static void nilfs_inode_init_once(void *obj)
 {
diff --git a/fs/ntfs/super.c b/fs/ntfs/super.c
index 4a8289f8..82650d5 100644
--- a/fs/ntfs/super.c
+++ b/fs/ntfs/super.c
@@ -3079,6 +3079,7 @@ static struct file_system_type ntfs_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("ntfs");
 
 /* Stable names for the slab caches. */
 static const char ntfs_index_ctx_cache_name[] = "ntfs_index_ctx_cache";
diff --git a/fs/ocfs2/dlmfs/dlmfs.c b/fs/ocfs2/dlmfs/dlmfs.c
index 4c5fc8d..12bafb7 100644
--- a/fs/ocfs2/dlmfs/dlmfs.c
+++ b/fs/ocfs2/dlmfs/dlmfs.c
@@ -640,6 +640,7 @@ static struct file_system_type dlmfs_fs_type = {
 	.mount		= dlmfs_mount,
 	.kill_sb	= kill_litter_super,
 };
+MODULE_ALIAS_FS("ocfs2_dlmfs");
 
 static int __init init_dlmfs_fs(void)
 {
diff --git a/fs/omfs/inode.c b/fs/omfs/inode.c
index 25d715c..d8b0afd 100644
--- a/fs/omfs/inode.c
+++ b/fs/omfs/inode.c
@@ -572,6 +572,7 @@ static struct file_system_type omfs_fs_type = {
 	.kill_sb = kill_block_super,
 	.fs_flags = FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("omfs");
 
 static int __init init_omfs_fs(void)
 {
diff --git a/fs/openpromfs/inode.c b/fs/openpromfs/inode.c
index ae47fa7..75885ff 100644
--- a/fs/openpromfs/inode.c
+++ b/fs/openpromfs/inode.c
@@ -432,6 +432,7 @@ static struct file_system_type openprom_fs_type = {
 	.mount		= openprom_mount,
 	.kill_sb	= kill_anon_super,
 };
+MODULE_ALIAS_FS("openpromfs");
 
 static void op_inode_init_once(void *data)
 {
diff --git a/fs/qnx4/inode.c b/fs/qnx4/inode.c
index 43098bb..2e8caa6 100644
--- a/fs/qnx4/inode.c
+++ b/fs/qnx4/inode.c
@@ -412,6 +412,7 @@ static struct file_system_type qnx4_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("qnx4");
 
 static int __init init_qnx4_fs(void)
 {
diff --git a/fs/qnx6/inode.c b/fs/qnx6/inode.c
index 57199a5..8d941ed 100644
--- a/fs/qnx6/inode.c
+++ b/fs/qnx6/inode.c
@@ -672,6 +672,7 @@ static struct file_system_type qnx6_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("qnx6");
 
 static int __init init_qnx6_fs(void)
 {
diff --git a/fs/reiserfs/super.c b/fs/reiserfs/super.c
index 418bdc3..194113b 100644
--- a/fs/reiserfs/super.c
+++ b/fs/reiserfs/super.c
@@ -2434,6 +2434,7 @@ struct file_system_type reiserfs_fs_type = {
 	.kill_sb = reiserfs_kill_sb,
 	.fs_flags = FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("reiserfs");
 
 MODULE_DESCRIPTION("ReiserFS journaled filesystem");
 MODULE_AUTHOR("Hans Reiser <reiser-nJ1KrdHEGnBBDgjK7y7TUQ@public.gmane.org>");
diff --git a/fs/romfs/super.c b/fs/romfs/super.c
index 7e8d3a8..15cbc41 100644
--- a/fs/romfs/super.c
+++ b/fs/romfs/super.c
@@ -599,6 +599,7 @@ static struct file_system_type romfs_fs_type = {
 	.kill_sb	= romfs_kill_sb,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("romfs");
 
 /*
  * inode storage initialiser
diff --git a/fs/sysv/super.c b/fs/sysv/super.c
index a38e87b..a39938b 100644
--- a/fs/sysv/super.c
+++ b/fs/sysv/super.c
@@ -545,6 +545,7 @@ static struct file_system_type sysv_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("sysv");
 
 static struct file_system_type v7_fs_type = {
 	.owner		= THIS_MODULE,
@@ -553,6 +554,7 @@ static struct file_system_type v7_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("v7");
 
 static int __init init_sysv_fs(void)
 {
@@ -586,5 +588,4 @@ static void __exit exit_sysv_fs(void)
 
 module_init(init_sysv_fs)
 module_exit(exit_sysv_fs)
-MODULE_ALIAS("v7");
 MODULE_LICENSE("GPL");
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index ddc0f6a..ac838b8 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -2174,6 +2174,7 @@ static struct file_system_type ubifs_fs_type = {
 	.mount   = ubifs_mount,
 	.kill_sb = kill_ubifs_super,
 };
+MODULE_ALIAS_FS("ubifs");
 
 /*
  * Inode slab cache constructor.
diff --git a/fs/ufs/super.c b/fs/ufs/super.c
index dc8e3a8..329f2f5 100644
--- a/fs/ufs/super.c
+++ b/fs/ufs/super.c
@@ -1500,6 +1500,7 @@ static struct file_system_type ufs_fs_type = {
 	.kill_sb	= kill_block_super,
 	.fs_flags	= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("ufs");
 
 static int __init init_ufs_fs(void)
 {
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index c407121..ea341ce 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1561,6 +1561,7 @@ static struct file_system_type xfs_fs_type = {
 	.kill_sb		= kill_block_super,
 	.fs_flags		= FS_REQUIRES_DEV,
 };
+MODULE_ALIAS_FS("xfs");
 
 STATIC int __init
 xfs_init_zones(void)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 74a907b..2c28271 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1825,6 +1825,8 @@ struct file_system_type {
 	struct lock_class_key i_mutex_dir_key;
 };
 
+#define MODULE_ALIAS_FS(NAME) MODULE_ALIAS("fs-" NAME)
+
 extern struct dentry *mount_ns(struct file_system_type *fs_type, int flags,
 	void *data, int (*fill_super)(struct super_block *, void *, int));
 extern struct dentry *mount_bdev(struct file_system_type *fs_type,
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 7b9b402..a0f48a5 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1174,6 +1174,7 @@ static struct file_system_type rpc_pipe_fs_type = {
 	.mount		= rpc_mount,
 	.kill_sb	= rpc_kill_sb,
 };
+MODULE_ALIAS_FS("rpc_pipefs");
 
 static void
 init_once(void *foo)
@@ -1218,6 +1219,3 @@ void unregister_rpc_pipefs(void)
 	kmem_cache_destroy(rpc_inode_cachep);
 	unregister_filesystem(&rpc_pipe_fs_type);
 }
-
-/* Make 'mount -t rpc_pipefs ...' autoload this module. */
-MODULE_ALIAS("rpc_pipefs");
-- 
1.7.5.4
