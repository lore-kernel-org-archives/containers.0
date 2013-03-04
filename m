From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 0/2] userns bug fixes for v3.9-rc2 for review
Date: Sun, 03 Mar 2013 23:48:55 -0800
Message-ID: <87k3pnmwpk.fsf_-_@xmission.com>
References: <CAGXu5jK7x+gFKgCN5=ZF+kSc4xSNbGtSERHCoOnCEgiJ1_wNGg@mail.gmail.com>
	<20130303005700.GA32213@austin.hallyn.com>
	<874ngtxgt5.fsf@xmission.com>
	<CAGXu5j+bwUx6r++ttvYg4yJrUUHxoQ86tQ0JzEBoQQU6KAh9ww@mail.gmail.com>
	<874ngsrvrh.fsf@xmission.com>
	<CAGXu5jJiO=BmjVbpVJhxHbafn5T_SQbe5g-RLxRbmknNnQMyfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAGXu5jJiO=BmjVbpVJhxHbafn5T_SQbe5g-RLxRbmknNnQMyfQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Kees Cook's message of "Sun, 3 Mar 2013 18:35:28 -0800")
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


Baring problems these are the changes I intend to put in linux-next and
then send to Linus for v3.9-rc2.

The first is a trivial oops fix.
The second reworks how mount -t triggers module loading to make it
harder to abuse. 

Eric W. Biederman (2):
      userns: Stop oopsing in key_change_session_keyring
      fs: Limit sys_mount to only request filesystem modules.

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
 security/keys/process_keys.c              |    2 +-
 70 files changed, 78 insertions(+), 13 deletions(-)
