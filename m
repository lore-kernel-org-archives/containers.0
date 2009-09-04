From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-dev,
	updated. v2.6.27-rc5-46206-ga34b0e0
Date: Fri, 4 Sep 2009 00:42:26 -0400
Message-ID: <200909040442.n844gQnv010173@gorgona.ncl.cs.columbia.edu>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The branch, ckpt-v17-dev has been updated
       via  a34b0e08104452ef2d3eff49d6530915701cdbc8 (commit)
       via  82dd88568ff45f515e7801a5be2b199dbe277696 (commit)
      from  ec1611a161a6f51e693ec660afe8559b58d63241 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit a34b0e08104452ef2d3eff49d6530915701cdbc8
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Thu Sep 3 16:31:33 2009 -0400

    c/r: interface to pass simple pointers as data with deferqueue
    
    This patch adds two interfaces to simplify the case of passing
    a single pointer as data for deferqueue:
    
    deferqueue_add_ptr(deferqueue, ptr, func, dtor): enqueue a deferred
    work whos data is @ptr.
    
    deferqueue_data_ptr(data): convert a deferqueue @data to a void *
    pointer.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 82dd88568ff45f515e7801a5be2b199dbe277696
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Jul 13 06:58:15 2009 -0700

    Add the checkpoint operation for opened files of generic filesystems
    
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
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

-----------------------------------------------------------------------

Summary of changes:
 fs/adfs/dir.c               |    1 +
 fs/adfs/file.c              |    1 +
 fs/affs/dir.c               |    1 +
 fs/affs/file.c              |    1 +
 fs/befs/linuxvfs.c          |    1 +
 fs/bfs/dir.c                |    1 +
 fs/bfs/file.c               |    1 +
 fs/btrfs/file.c             |    1 +
 fs/btrfs/inode.c            |    1 +
 fs/btrfs/super.c            |    1 +
 fs/cramfs/inode.c           |    1 +
 fs/ecryptfs/file.c          |    2 ++
 fs/ecryptfs/miscdev.c       |    1 +
 fs/efs/dir.c                |    1 +
 fs/exofs/dir.c              |    1 +
 fs/exofs/file.c             |    1 +
 fs/fat/dir.c                |    1 +
 fs/fat/file.c               |    1 +
 fs/freevxfs/vxfs_lookup.c   |    1 +
 fs/hfs/dir.c                |    1 +
 fs/hfs/inode.c              |    1 +
 fs/hfsplus/dir.c            |    1 +
 fs/hfsplus/inode.c          |    1 +
 fs/hostfs/hostfs_kern.c     |    2 ++
 fs/hpfs/dir.c               |    1 +
 fs/hpfs/file.c              |    1 +
 fs/hppfs/hppfs.c            |    2 ++
 fs/isofs/dir.c              |    1 +
 fs/jffs2/dir.c              |    1 +
 fs/jffs2/file.c             |    1 +
 fs/jfs/file.c               |    1 +
 fs/jfs/namei.c              |    1 +
 fs/minix/dir.c              |    1 +
 fs/minix/file.c             |    1 +
 fs/nfs/dir.c                |    1 +
 fs/nfs/file.c               |    1 +
 fs/nilfs2/dir.c             |    2 +-
 fs/nilfs2/file.c            |    1 +
 fs/ntfs/dir.c               |    1 +
 fs/ntfs/file.c              |    3 ++-
 fs/omfs/dir.c               |    1 +
 fs/omfs/file.c              |    1 +
 fs/openpromfs/inode.c       |    2 ++
 fs/qnx4/dir.c               |    1 +
 fs/qnx4/file.c              |    1 +
 fs/ramfs/file-mmu.c         |    1 +
 fs/ramfs/file-nommu.c       |    1 +
 fs/read_write.c             |    1 +
 fs/reiserfs/dir.c           |    1 +
 fs/reiserfs/file.c          |    1 +
 fs/romfs/mmap-nommu.c       |    1 +
 fs/romfs/super.c            |    1 +
 fs/squashfs/dir.c           |    3 ++-
 fs/sysv/dir.c               |    1 +
 fs/sysv/file.c              |    1 +
 fs/ubifs/debug.c            |    1 +
 fs/ubifs/dir.c              |    1 +
 fs/ubifs/file.c             |    1 +
 fs/udf/dir.c                |    1 +
 fs/udf/file.c               |    1 +
 fs/ufs/dir.c                |    1 +
 fs/ufs/file.c               |    1 +
 fs/xfs/linux-2.6/xfs_file.c |    2 ++
 include/linux/deferqueue.h  |   20 ++++++++++++++++++++
 64 files changed, 90 insertions(+), 3 deletions(-)


hooks/post-receive
--
linux-cr
