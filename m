From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] namespace bug fixes
Date: Sat, 09 Mar 2013 15:44:57 -0800
Message-ID: <87zjycp286.fsf__41006.6105345779$1362872749$gmane$org@xmission.com>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus git tree from:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: db04dc679bcc780ad6907943afe24a30de974a1b  proc: Use nd_jump_link in proc_ns_follow_link

This is three simple fixes against 3.9-rc1.  I have tested each of these
fixes and verified they work correctly.

The userns oops in key_change_session_keyring and the BUG_ON triggered
by proc_ns_follow_link were found by Dave Jones.

I am including the enhancement for mount to only trigger requests of
filesystem modules here instead of delaying this for the 3.10 merge
window because it is both trivial and the kind of change that tends to
bit-rot if left untouched for two months.

Eric W. Biederman (4):
      userns: Stop oopsing in key_change_session_keyring
      fs: Limit sys_mount to only request filesystem modules.
      fs: Limit sys_mount to only request filesystem modules (Part 2).
      proc: Use nd_jump_link in proc_ns_follow_link

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
 fs/ocfs2/super.c                          |    1 +
 fs/omfs/inode.c                           |    1 +
 fs/openpromfs/inode.c                     |    1 +
 fs/proc/namespaces.c                      |   12 ++++++------
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
 security/keys/process_keys.c              |    2 +-
 71 files changed, 84 insertions(+), 19 deletions(-)
