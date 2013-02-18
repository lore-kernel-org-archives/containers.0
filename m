From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 00/16] userns: Completion of kuid/kgid/kprojid pushdown.
Date: Sun, 17 Feb 2013 17:04:08 -0800
Message-ID: <87txpaph4n.fsf@xmission.com>
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
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>
List-Id: containers.vger.kernel.org


I have spent some more time with the xfs code and finally figured out
what needed to be done to safely add kuid/kgid support without
significant logic changes.

My first two xfs changes make the small logical adjustments required of
xfs to get the primary inode uid, gid, and projid fields that xfs uses
not live in struct xfs_icdinode.  After that the patches are pretty much
what I have posted before just split up and cleaned up so it is much
easier to understand the patches and see that they are doing reasonable
things.

xfs being the last of the filesystems to need the userns compatibility
code I my patches to remove that compatibility code are at the end of
this patchset.

Eric W. Biederman (16):
      xfs: Convert uids and gids in xfs acls to/from kuids and kgids
      xfs: Store projectid as a single variable.
      xfs: Always read uids and gids from the vfs inode
      xfs: Update inode uids, gids, and projids to be kuids, kgids, and kprojids
      xfs: Update xfs_ioctl_setattr to handle projids in any user namespace
      xfs: Use kuids and kgids in xfs_setattr_nonsize
      xfs: Update ioctl(XFS_IOC_FREE_EOFBLOCKS) to handle callers in any userspace
      xfs: Use kprojids when allocating inodes.
      xfs: Modify xfs_qm_vop_dqalloc to take kuids, kgids, and kprojids.
      xfs: Push struct kqid into xfs_qm_scall_qmlim and xfs_qm_scall_getquota
      xfs: Modify xfs_qm_dqget to take a struct kqid.
      xfs: Remember the kqid for a quota
      xfs: Use q_id instead of q_core.d_id.
      xfs: Enable building with user namespaces enabled.
      userns: Now that everything has been converted remove the unnecessary infrastructure
      userns: Remove the EXPERMINTAL kconfig tag

 fs/xfs/xfs_acl.c          |   23 ++++++++++--
 fs/xfs/xfs_dquot.c        |   39 ++++++++++++++-------
 fs/xfs/xfs_dquot.h        |   13 +++++--
 fs/xfs/xfs_icache.c       |   12 +++---
 fs/xfs/xfs_icache.h       |   11 +++++-
 fs/xfs/xfs_inode.c        |   25 +++++++++----
 fs/xfs/xfs_inode.h        |   24 +++++++++----
 fs/xfs/xfs_ioctl.c        |   54 ++++++++++++++++++++++------
 fs/xfs/xfs_iops.c         |   34 ++++++++----------
 fs/xfs/xfs_itable.c       |   10 +++--
 fs/xfs/xfs_qm.c           |   85 ++++++++++++++++++++++-----------------------
 fs/xfs/xfs_qm.h           |    4 +-
 fs/xfs/xfs_qm_bhv.c       |    2 +-
 fs/xfs/xfs_qm_syscalls.c  |   24 +++++++------
 fs/xfs/xfs_quota.h        |    4 +-
 fs/xfs/xfs_quotaops.c     |   20 +---------
 fs/xfs/xfs_rename.c       |    2 +-
 fs/xfs/xfs_trace.h        |    2 +-
 fs/xfs/xfs_trans_dquot.c  |    8 +---
 fs/xfs/xfs_utils.c        |    2 +-
 fs/xfs/xfs_utils.h        |    2 +-
 fs/xfs/xfs_vnodeops.c     |   14 ++++----
 include/linux/posix_acl.h |    3 --
 include/linux/projid.h    |   15 --------
 include/linux/uidgid.h    |   22 ------------
 init/Kconfig              |   27 +--------------
 26 files changed, 244 insertions(+), 237 deletions(-)
