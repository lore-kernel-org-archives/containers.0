From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] user namespace and namespace infrastructure changes for 3.9
Date: Wed, 20 Feb 2013 16:36:03 -0800
Message-ID: <87sj4q7bbg.fsf@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus git tree from:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: 139321c65c0584cd65c4c87a5eb3fdb4fdbd0e19 cifs: Enable building with user namespaces enabled.

   This tree is against v3.8-rc1 with the first few bug-fix commits
   already merged into v3.8.

This set of changes starts with a few small enhnacements to the user
namespace.  reboot support, allowing more arbitrary mappings, and
support for mounting devpts, ramfs, tmpfs, and mqueuefs as just the user
namespace root.

I do my best to document that if you care about limiting your
unprivileged users that when you have the user namespace support enabled
you will need to enable memory control groups.

There is a minor bug fix to prevent overflowing the stack if someone
creates way too many user namespaces.

The bulk of the changes are a continuation of the kuid/kgid push down
work through the filesystems.  These changes make using uids and gids
typesafe which ensures that these filesystems are safe to use when
multiple user namespaces are in use.  The filesystems converted for 3.9
are ceph, 9p, afs, ocfs2, gfs2, ncpfs, nfs, nfsd, and cifs.  The changes
for these filesystems were a little more involved so I split the changes
into smaller hopefully obviously correct changes.

XFS is the only filesystem that remains.  I was hoping I could get that
in this release so that user namespace support would be enabled with an
allyesconfig or an allmodconfig but it looks like the xfs changes need
another couple of days before it they are ready.

Eric W. Biederman (91):
      userns: Avoid recursion in put_user_ns
      userns: Allow any uid or gid mappings that don't overlap.
      userns: Recommend use of memory control groups.
      userns: Allow the userns root to mount of devpts
      userns: Allow the userns root to mount ramfs.
      userns: Allow the userns root to mount tmpfs.
      ceph: Only allow mounts in the initial network namespace
      ceph: Translate between uid and gids in cap messages and kuids and kgids
      ceph: Translate inode uid and gid attributes to/from kuids and kgids.
      ceph: Convert struct ceph_mds_request to use kuid_t and kgid_t
      ceph: Convert kuids and kgids before printing them.
      ceph: Enable building when user namespaces are enabled.
      9p: Add 'u' and 'g' format specifies for kuids and kgids
      9p: Transmit kuid and kgid values
      9p: Modify the stat structures to use kuid_t and kgid_t
      9p: Modify struct 9p_fid to use a kuid_t not a uid_t
      9p: Modify struct v9fs_session_info to use a kuids and kgids
      9p: Modify v9fs_get_fsgid_for_create to return a kgid
      9p: Allow building 9p with user namespaces enabled.
      afs: Remove unused structure afs_store_status
      afs: Only allow mounting afs in the intial network namespace
      afs: Support interacting with multiple user namespaces
      coda: Restrict coda messages to the initial pid namespace
      coda: Restrict coda messages to the initial user namespace
      coda: Cache permisions in struct coda_inode_info in a kuid_t.
      coda: Allow coda to be built when user namespace support is enabled
      ocfs2: Handle kuids and kgids in acl/xattr conversions.
      ocfs2: convert between kuids and kgids and DLM locks
      ocfs2: Convert uid and gids between in core and on disk inodes
      ocfs2: For tracing report the uid and gid values in the initial user namespace
      ocfs2: Compare kuids and kgids using uid_eq and gid_eq
      ocfs2: Enable building with user namespaces enabled
      gfs2: Remove improper checks in gfs2_set_dqblk.
      gfs2: Split NO_QUOTA_CHANGE inot NO_UID_QUTOA_CHANGE and NO_GID_QUTOA_CHANGE
      gfs2: Report quotas in the caller's user namespace.
      gfs2: Introduce qd2index
      gfs2: Modify struct gfs2_quota_change_host to use struct kqid
      gfs2: Modify qdsb_get to take a struct kqid
      gfs2: Convert gfs2_quota_refresh to take a kqid
      gfs2: Store qd_id in struct gfs2_quota_data as a struct kqid
      gfs2: Remove the QUOTA_USER and QUOTA_GROUP defines
      gfs2: Use kuid_t and kgid_t types where appropriate.
      gfs2: Use uid_eq and gid_eq where appropriate
      gfs2: Convert uids and gids between dinodes and vfs inodes.
      gfs2: Enable building with user namespaces enabled
      ncpfs: Support interacting with multiple user namespaces
      nfs_common: Update the translation between nfsv3 acls linux posix acls
      sunrpc: Use userns friendly constants.
      sunrpc: Use kuid_t and kgid_t where appropriate
      sunrpc: Use uid_eq and gid_eq where appropriate
      sunrpc: Simplify auth_unix now that everything is a kgid_t
      sunrpc: Convert kuids and kgids to uids and gids for printing
      sunrpc: Use gid_valid to test for gid != INVALID_GID
      sunrpc: Update gss uid to security context mapping.
      sunrpc: Update svcgss xdr handle to rpsec_contect cache
      sunrpc: Hash uids by first computing their value in the initial userns
      sunrpc: Properly encode kuids and kgids in RPC_AUTH_UNIX credentials
      sunrpc: Properly encode kuids and kgids in auth.unix.gid rpc pipe upcalls.
      sunrpc: Properly decode kuids and kgids in RPC_AUTH_UNIX credentials
      nfs: Pass GLOBAL_ROOT_UID and GLOBAL_ROOT_GID to keyring alloc
      nfs: Convert struct nfs_fattr to Use kuid_t and kgid_t
      nfs: Convert idmap to use kuids and kgids
      nfs: Convert nfs2xdr to use kuids and kgids
      nfs: Convert nfs3xdr to use kuids and kgids
      nfs: Convert nfs4xdr to use kuids and kgids
      nfs: kuid and kgid conversions for nfs/inode.c
      nfs: Enable building with user namespaces enabled.
      nfsd: Remove declaration of nonexistent nfs4_acl_permisison
      nfsd: idmap use u32 not uid_t as the intermediate type
      nfsd: Convert idmap to use kuids and kgids
      nfsd: Remove nfsd_luid, nfsd_lgid, nfsd_ruid and nfsd_rgid
      nfsd: Convert nfs3xdr to use kuids and kgids
      nfsd: Convert nfsxdr to use kuids and kgids
      nfsd: Handle kuids and kgids in the nfs4acl to posix_acl conversion
      nfsd: Modify nfsd4_cb_sec to use kuids and kgids
      nfsd: Store ex_anon_uid and ex_anon_gid as kuids and kgids
      nfsd: Properly compare and initialize kuids and kgids
      nfsd: Enable building with user namespaces enabled.
      cifs: Override unmappable incoming uids and gids
      cifs: Use BUILD_BUG_ON to validate uids and gids are the same size
      cifs: Pass GLOBAL_ROOT_UID and GLOBAL_ROOT_GID to keyring_alloc
      cifs: Use kuids and kgids SID to uid/gid mapping
      cifs: Convert from a kuid before printing current_fsuid
      cifs: Modify struct cifs_unix_set_info_args to hold a kuid_t and a kgid_t
      cifs: Convert struct tcon_link to use a kuid.
      cifs: Convert struct cifs_fattr to use kuid and kgids
      cifs: Convert struct cifsFileInfo to use a kuid
      cifs: Modify struct smb_vol to use kuids and kgids
      cifs: Convert struct cifs_sb_info to use kuids and kgids
      cifs: Convert struct cifs_ses to use a kuid_t and a kgid_t
      cifs: Enable building with user namespaces enabled.

Gao feng (1):
      userns: Allow the unprivileged users to mount mqueue fs

Li Zefan (1):
      userns: Allow unprivileged reboot

 Documentation/namespaces/resource-control.txt |   14 +++
 fs/9p/fid.c                                   |   17 ++--
 fs/9p/v9fs.c                                  |   34 +++++--
 fs/9p/v9fs.h                                  |   10 +-
 fs/9p/vfs_inode.c                             |    6 +-
 fs/9p/vfs_inode_dotl.c                        |   10 +-
 fs/afs/afs.h                                  |   11 +--
 fs/afs/fsclient.c                             |   14 ++-
 fs/afs/inode.c                                |    6 +-
 fs/afs/super.c                                |    6 +
 fs/ceph/caps.c                                |   17 ++--
 fs/ceph/inode.c                               |   23 +++--
 fs/ceph/mds_client.c                          |    4 +-
 fs/ceph/mds_client.h                          |    4 +-
 fs/ceph/super.h                               |    4 +-
 fs/cifs/cifs_fs_sb.h                          |    8 +-
 fs/cifs/cifs_spnego.c                         |    6 +-
 fs/cifs/cifsacl.c                             |   47 ++++++---
 fs/cifs/cifsfs.c                              |   14 ++-
 fs/cifs/cifsglob.h                            |   22 ++--
 fs/cifs/cifspdu.h                             |    1 -
 fs/cifs/cifsproto.h                           |    9 +-
 fs/cifs/cifssmb.c                             |   10 ++-
 fs/cifs/connect.c                             |   66 +++++++++---
 fs/cifs/dir.c                                 |   18 ++--
 fs/cifs/file.c                                |    8 +-
 fs/cifs/inode.c                               |   50 ++++++----
 fs/cifs/misc.c                                |    2 +-
 fs/coda/cache.c                               |    4 +-
 fs/coda/coda_fs_i.h                           |    2 +-
 fs/coda/coda_linux.c                          |    8 +-
 fs/coda/inode.c                               |    6 +-
 fs/coda/psdev.c                               |    7 ++
 fs/coda/upcall.c                              |   10 +-
 fs/devpts/inode.c                             |   18 +++
 fs/gfs2/acl.c                                 |    2 +-
 fs/gfs2/bmap.c                                |    2 +-
 fs/gfs2/dir.c                                 |    2 +-
 fs/gfs2/glops.c                               |    4 +-
 fs/gfs2/incore.h                              |    3 +-
 fs/gfs2/inode.c                               |   32 +++---
 fs/gfs2/quota.c                               |  138 ++++++++++---------------
 fs/gfs2/quota.h                               |   15 ++--
 fs/gfs2/super.c                               |    6 +-
 fs/gfs2/sys.c                                 |   14 ++-
 fs/gfs2/xattr.c                               |    4 +-
 fs/ncpfs/inode.c                              |   55 ++++++----
 fs/ncpfs/ioctl.c                              |   25 +++--
 fs/ncpfs/ncp_fs_sb.h                          |    6 +-
 fs/nfs/idmap.c                                |   53 +++++++---
 fs/nfs/inode.c                                |   12 +-
 fs/nfs/nfs2xdr.c                              |   19 +++-
 fs/nfs/nfs3xdr.c                              |   18 +++-
 fs/nfs/nfs4xdr.c                              |   16 ++--
 fs/nfs_common/nfsacl.c                        |   41 +++++---
 fs/nfsd/acl.h                                 |    2 -
 fs/nfsd/auth.c                                |   12 +-
 fs/nfsd/auth.h                                |    6 -
 fs/nfsd/export.c                              |   22 +++--
 fs/nfsd/idmap.h                               |    8 +-
 fs/nfsd/nfs3xdr.c                             |   14 ++-
 fs/nfsd/nfs4acl.c                             |   63 ++++++++---
 fs/nfsd/nfs4idmap.c                           |   38 +++++--
 fs/nfsd/nfs4recover.c                         |    4 +-
 fs/nfsd/nfs4state.c                           |    6 +-
 fs/nfsd/nfs4xdr.c                             |   54 ++++++----
 fs/nfsd/nfsxdr.c                              |   14 ++-
 fs/nfsd/state.h                               |    4 +-
 fs/nfsd/vfs.c                                 |    8 +-
 fs/ocfs2/acl.c                                |   31 +++++-
 fs/ocfs2/dlmglue.c                            |    8 +-
 fs/ocfs2/file.c                               |   11 +-
 fs/ocfs2/inode.c                              |   12 +-
 fs/ocfs2/namei.c                              |    4 +-
 fs/ocfs2/refcounttree.c                       |    2 +-
 fs/ramfs/inode.c                              |    1 +
 include/linux/coda_psdev.h                    |    2 +-
 include/linux/nfs4.h                          |    6 +-
 include/linux/nfs_idmap.h                     |    9 +-
 include/linux/nfs_xdr.h                       |    4 +-
 include/linux/nfsd/export.h                   |    4 +-
 include/linux/sunrpc/auth.h                   |    7 +-
 include/linux/sunrpc/svcauth.h                |    4 +-
 include/linux/user_namespace.h                |   10 +-
 include/net/9p/9p.h                           |   14 ++--
 include/net/9p/client.h                       |   12 +-
 init/Kconfig                                  |   20 ++---
 ipc/mqueue.c                                  |    1 +
 kernel/sys.c                                  |    5 +-
 kernel/user.c                                 |    4 +-
 kernel/user_namespace.c                       |   62 +++++++++---
 mm/shmem.c                                    |    2 +
 net/9p/client.c                               |   43 +++++---
 net/9p/protocol.c                             |   49 ++++++++-
 net/ceph/ceph_common.c                        |    5 +
 net/sunrpc/auth.c                             |    6 +-
 net/sunrpc/auth_generic.c                     |   16 ++--
 net/sunrpc/auth_gss/auth_gss.c                |   45 +++++---
 net/sunrpc/auth_gss/svcauth_gss.c             |   18 +++-
 net/sunrpc/auth_unix.c                        |   36 +++----
 net/sunrpc/svcauth_unix.c                     |   43 +++++---
 101 files changed, 1058 insertions(+), 656 deletions(-)
