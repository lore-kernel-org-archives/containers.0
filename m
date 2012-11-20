From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH RFC 0/12] Final userns conversions
Date: Tue, 20 Nov 2012 04:42:16 -0800
Message-ID: <87pq38wimv.fsf@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


This patchset contain the basic user namespace changes for filesystems
that have needed nontrivial work.  Along with the 2 patches that depend
on these changes.

I belive these patches to be correct for allowing the remaining
filesystems to work in the presence of user namespaces.  At the same
time I would like to give all of these much deeper scrutiny, just
because there is so much going on.  Unfortunately these patches
individually are not obviously correct.

Since I won't have much time until after Thanksgiving and because the
merge window is looming I figure I will put these changes out there and
let people see I am looking at these changes, and see if anyone happens
to spot anything.

If I can figure out how to responsibly get these changes into linux-next
I want to get these changes into linux-next so that user namespace bugs
show up in allyesconfig builds.

For people who want to see what else I am cooking my git tree is at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git

Eric W. Biederman (12):
      userns: Support 9p interacting with multiple user namespaces
      userns: Convert afs to use kuid/kgid where appropriate
      userns: Convert ceph to use kuid/kgid where appropriate
      userns: Convert cifs to use kuid/kgid where appropriate
      userns: Convert coda's to use kuid/kgid where appropriate
      userns: Convert gfs2 to use kuid/kgid where appropriate
      userns: Convert ncpfs to use kuid and kgid where appropriate
      userns: Convert nfs and nfsd to use kuid/kgid where appropriate
      userns: Convert ocfs2 to use kuid and kgid where appropriate
      userns: Convert xfs to use kuid/kgid/kprojid where appropriate
      userns: Now that everything has been converted remove the unnecessary infrastructure
      userns: Remove the EXPERMINTAL kconfig tag

 fs/9p/fid.c                       |   17 +++--
 fs/9p/v9fs.c                      |   34 ++++++++--
 fs/9p/v9fs.h                      |   10 ++--
 fs/9p/vfs_inode.c                 |    8 +-
 fs/9p/vfs_inode_dotl.c            |   22 +++---
 fs/afs/afs.h                      |    4 +-
 fs/afs/fsclient.c                 |   14 +++-
 fs/afs/inode.c                    |    6 +-
 fs/ceph/caps.c                    |   16 ++--
 fs/ceph/inode.c                   |   18 +++---
 fs/ceph/mds_client.c              |    4 +-
 fs/ceph/super.h                   |    4 +-
 fs/cifs/cifs_fs_sb.h              |    8 +-
 fs/cifs/cifs_spnego.c             |    4 +-
 fs/cifs/cifsacl.c                 |  115 +++++++++++++++++++++++++--------
 fs/cifs/cifsacl.h                 |   16 ++++-
 fs/cifs/cifsfs.c                  |   12 ++-
 fs/cifs/cifsglob.h                |   22 +++---
 fs/cifs/cifspdu.h                 |    2 +
 fs/cifs/cifsproto.h               |    9 ++-
 fs/cifs/cifssmb.c                 |   11 +++-
 fs/cifs/connect.c                 |   58 +++++++++++++----
 fs/cifs/dir.c                     |   18 +++---
 fs/cifs/file.c                    |    8 +-
 fs/cifs/inode.c                   |   28 ++++----
 fs/cifs/misc.c                    |    2 +-
 fs/coda/cache.c                   |    4 +-
 fs/coda/coda_fs_i.h               |    2 +-
 fs/coda/coda_linux.c              |    8 +-
 fs/coda/inode.c                   |    2 +-
 fs/coda/upcall.c                  |    6 +-
 fs/gfs2/acl.c                     |    2 +-
 fs/gfs2/bmap.c                    |    2 +-
 fs/gfs2/dir.c                     |    2 +-
 fs/gfs2/glops.c                   |    4 +-
 fs/gfs2/incore.h                  |    3 +-
 fs/gfs2/inode.c                   |   36 ++++++-----
 fs/gfs2/quota.c                   |  128 ++++++++++++++++---------------------
 fs/gfs2/quota.h                   |   15 ++--
 fs/gfs2/super.c                   |    6 +-
 fs/gfs2/sys.c                     |   14 ++++-
 fs/gfs2/xattr.c                   |    4 +-
 fs/ncpfs/inode.c                  |   55 ++++++++++------
 fs/ncpfs/ioctl.c                  |   25 ++++---
 fs/ncpfs/ncp_fs_sb.h              |    6 +-
 fs/nfs/idmap.c                    |   45 ++++++++-----
 fs/nfs/inode.c                    |   12 ++--
 fs/nfs/nfs2xdr.c                  |    8 +-
 fs/nfs/nfs3xdr.c                  |    8 +-
 fs/nfs/nfs4xdr.c                  |   16 ++--
 fs/nfs_common/nfsacl.c            |   37 ++++++----
 fs/nfsd/acl.h                     |    2 -
 fs/nfsd/auth.c                    |   12 ++--
 fs/nfsd/export.c                  |   22 ++++--
 fs/nfsd/idmap.h                   |    8 +-
 fs/nfsd/nfs3xdr.c                 |    9 ++-
 fs/nfsd/nfs4acl.c                 |   63 +++++++++++++-----
 fs/nfsd/nfs4idmap.c               |   34 ++++++----
 fs/nfsd/nfs4recover.c             |    4 +-
 fs/nfsd/nfs4state.c               |    6 +-
 fs/nfsd/nfs4xdr.c                 |   42 ++++++++-----
 fs/nfsd/nfsxdr.c                  |    9 ++-
 fs/nfsd/vfs.c                     |    8 +-
 fs/ocfs2/acl.c                    |   31 ++++++++-
 fs/ocfs2/dlmglue.c                |    8 +-
 fs/ocfs2/file.c                   |   11 ++--
 fs/ocfs2/inode.c                  |   12 ++--
 fs/ocfs2/namei.c                  |    4 +-
 fs/ocfs2/refcounttree.c           |    2 +-
 fs/xfs/xfs_acl.c                  |   23 ++++++-
 fs/xfs/xfs_dquot.c                |   36 +++++++----
 fs/xfs/xfs_dquot.h                |    5 +-
 fs/xfs/xfs_inode.c                |   33 ++++++----
 fs/xfs/xfs_inode.h                |   32 ++--------
 fs/xfs/xfs_ioctl.c                |   23 +++++--
 fs/xfs/xfs_iops.c                 |   18 +++---
 fs/xfs/xfs_itable.c               |    8 +-
 fs/xfs/xfs_qm.c                   |   87 +++++++++++++------------
 fs/xfs/xfs_qm.h                   |    4 +-
 fs/xfs/xfs_qm_bhv.c               |    3 +-
 fs/xfs/xfs_qm_syscalls.c          |   24 ++++---
 fs/xfs/xfs_quota.h                |    4 +-
 fs/xfs/xfs_quotaops.c             |   20 +-----
 fs/xfs/xfs_rename.c               |    2 +-
 fs/xfs/xfs_trans_dquot.c          |    6 +--
 fs/xfs/xfs_utils.c                |    2 +-
 fs/xfs/xfs_utils.h                |    2 +-
 fs/xfs/xfs_vnodeops.c             |   14 ++--
 include/linux/coda_psdev.h        |    2 +-
 include/linux/nfs4.h              |    6 ++-
 include/linux/nfs_idmap.h         |   10 ++--
 include/linux/nfs_xdr.h           |    4 +-
 include/linux/nfsd/export.h       |    4 +-
 include/linux/posix_acl.h         |    3 -
 include/linux/projid.h            |   15 ----
 include/linux/sunrpc/auth.h       |    7 +-
 include/linux/sunrpc/svcauth.h    |    4 +-
 include/linux/uidgid.h            |   22 ------
 include/net/9p/client.h           |   12 ++--
 init/Kconfig                      |   40 +-----------
 net/9p/client.c                   |   28 +++++----
 net/sunrpc/auth.c                 |    6 +-
 net/sunrpc/auth_generic.c         |   16 +++--
 net/sunrpc/auth_gss/auth_gss.c    |   33 ++++++----
 net/sunrpc/auth_gss/svcauth_gss.c |   14 ++++-
 net/sunrpc/auth_unix.c            |   36 ++++------
 net/sunrpc/svcauth_unix.c         |   40 +++++++-----
 107 files changed, 1035 insertions(+), 820 deletions(-)
