From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] userns related vfs enhancements for v4.8
Date: Tue, 26 Jul 2016 09:44:42 -0500
Message-ID: <87bn1kwjad.fsf@x220.int.ebiederm.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: aeaa4a79ff6a5ed912b7362f206cf8576fca538b fs: Call d_automount with the filesystems creds

[ Merging note.  There are some minor merge conflicts between this tree
  and your own.  My sample merge resolution against v4.7 is at the end ]

This tree contains some very long awaited work on generalizing the user
namespace support for mounting filesystems to include filesystems with a
backing store.  The real world target is fuse but the goal is to update
the vfs to allow any filesystem to be supported.  This patchset is
based on a lot of code review and testing to approach that goal.

While looking at what is needed to support the fuse filesystem it became
clear that there were things like xattrs for security modules that
needed special treatment.  That the resolution of those concerns would
not be fuse specific.  That sorting out these general issues made most
sense at the generic level, where the right people could be drawn into
the conversation, and the issues could be solved for everyone.

At a high level what this patchset does a couple of simple things.
- Add a user namespace owner (s_user_ns) to struct super_block.
- Teach the vfs to handle filesystem uids and gids not mapping
  into to kuids and kgids and being reported as INVALID_UID
  and INVALID_GID in vfs data structures.

By assigning a user namespace owner filesystems that are mounted with
only user namespace privilege can be detected.  This allows security
modules and the like to know which mounts may not be trusted.  This also
allows the set of uids and gids that are communicated to the filesystem
to be capped at the set of kuids and kgids that are in the owning user
namespace of the filesystem.

One of the crazier corner casees this handles is the case of inodes
whose i_uid or i_gid are not mapped into the vfs.  Most of the code
simply doesn't care but it is easy to confuse the inode writeback
path so no operation that could cause an inode write-back is
permitted for such inodes (aka only reads are allowed).

This set of changes starts out by cleaning up the code paths involved
in user namespace permirted mounts.  Then when things are clean enough
adds code that cleanly sets s_user_ns.  Then additional restrictions
are added that are possible now that the filesystem superblock contains
owner information.

These changes should not affect anyone in practice, but there
are some parts of these restrictions that are changes in behavior.

- Andy's restriction on suid executables that does not
  honor the suid bit when the path is from another mount namespace
  (think /proc/[pid]/fd/) or when the filesystem was mounted by
  a less privileged user.

- The replacement of the user namespace implicit setting of MNT_NODEV
  with implicitly setting SB_I_NODEV on the filesystem superblock
  instead.

  Using SB_I_NODEV is a stronger form that happens to make this state
  user invisible.  The user visibility can be managed but it caused
  problems when it was introduced from applications reasonably expecting
  mount flags to be what they were set to.

There is a little bit of work remaining before it is safe to support
mounting filesystems with backing store in user namespaces, beyond
what is in this set of changes.

- Verifying the mounter has permission to read/write the block device
  during mount.

- Teaching the integrity modules IMA and EVM to handle filesystems
  mounted with only user namespace root and to reduce trust in
  their security xattrs accordingly.

- Capturing the mounters credentials and using that for permission
  checks in d_automount and the like.  (Given that overlayfs already
  does this, and we need the work in d_automount it make sense to
  generalize this case).

Furthermore there are a few changes that are on the wishlist.
- Get all filesystems supporting posix acls using the generic posix acls
  so that posix_acl_fix_xattr_from_user and posix_acl_fix_xattr_to_user
  may be removed.  [Maintainability]

- Reducing the permission checks in places such as remount
  to allow the superblock owner to perform them.

- Allowing the superblock owner to chown files with unmapped
  uids and gids to something that is mapped so the files
  may be treated normally.

I am not considering even obvious relaxations of permission checks until
it is clear there are no more corner cases that need to be locked down
and handled generically.

Many thanks to Seth Forshee who kept this code alive, and putting up
with me rewriting substantial portions of what he did to handle more
corner cases, and for his diligent testing and reviewing of my changes.

Andy Lutomirski (1):
      fs: Treat foreign mounts as nosuid

Eric W. Biederman (20):
      mnt: Refactor fs_fully_visible into mount_too_revealing
      ipc: Initialize ipc_namespace->user_ns early.
      vfs: Pass data, ns, and ns->userns to mount_ns
      proc: Convert proc_mount to use mount_ns.
      fs: Add user namespace member to struct super_block
      mnt: Move the FS_USERNS_MOUNT check into sget_userns
      kernfs: The cgroup filesystem also benefits from SB_I_NOEXEC
      ipc/mqueue: The mqueue filesystem should never contain executables
      vfs: Generalize filesystem nodev handling.
      mnt: Simplify mount_too_revealing
      userns: Remove implicit MNT_NODEV fragility.
      userns: Remove the now unnecessary FS_USERNS_DEV_MOUNT flag
      userns: Handle -1 in k[ug]id_has_mapping when !CONFIG_USER_NS
      vfs: Verify acls are valid within superblock's s_user_ns.
      vfs: Don't modify inodes with a uid or gid unknown to the vfs
      vfs: Don't create inodes with a uid or gid unknown to the vfs
      quota: Ensure qids map to the filesystem
      quota: Handle quota data stored in s_user_ns in quota_setxquota
      dquot: For now explicitly don't support filesystems outside of init_user_ns
      fs: Call d_automount with the filesystems creds

Seth Forshee (9):
      fs: Limit file caps to the user namespace of the super block
      Smack: Add support for unprivileged mounts from user namespaces
      Smack: Handle labels consistently in untrusted mounts
      selinux: Add support for unprivileged mounts from user namespaces
      fs: Refuse uid/gid changes which don't map into s_user_ns
      fs: Check for invalid i_uid in may_follow_link()
      cred: Reject inodes with invalid ids in set_create_file_as()
      evm: Translate user/group ids relative to s_user_ns when computing HMAC
      fs: Update i_[ug]id_(read|write) to translate relative to s_user_ns

 drivers/staging/lustre/lustre/mdc/mdc_request.c |  2 +-
 fs/9p/acl.c                                     |  2 +-
 fs/attr.c                                       | 19 +++++
 fs/block_dev.c                                  |  2 +-
 fs/devpts/inode.c                               |  3 +-
 fs/exec.c                                       |  2 +-
 fs/inode.c                                      |  7 ++
 fs/kernfs/mount.c                               |  5 +-
 fs/namei.c                                      | 55 +++++++++++---
 fs/namespace.c                                  | 99 ++++++++++++-------------
 fs/nfsd/nfsctl.c                                | 13 +---
 fs/posix_acl.c                                  |  8 +-
 fs/proc/inode.c                                 |  8 +-
 fs/proc/internal.h                              |  3 +-
 fs/proc/root.c                                  | 54 ++------------
 fs/quota/dquot.c                                |  8 ++
 fs/quota/quota.c                                | 14 ++--
 fs/super.c                                      | 69 +++++++++++++++--
 fs/sysfs/mount.c                                |  5 +-
 fs/xattr.c                                      |  7 ++
 include/linux/fs.h                              | 79 ++++++++++++--------
 include/linux/mount.h                           |  1 +
 include/linux/posix_acl.h                       |  2 +-
 include/linux/quota.h                           | 10 +++
 include/linux/uidgid.h                          |  4 +-
 include/linux/user_namespace.h                  |  6 ++
 ipc/mqueue.c                                    | 20 +++--
 ipc/namespace.c                                 |  5 +-
 kernel/cred.c                                   |  2 +
 kernel/user_namespace.c                         | 14 ++++
 net/sunrpc/rpc_pipe.c                           |  8 +-
 security/commoncap.c                            | 10 ++-
 security/integrity/evm/evm_crypto.c             |  4 +-
 security/selinux/hooks.c                        | 25 ++++++-
 security/smack/smack.h                          |  8 +-
 security/smack/smack_lsm.c                      | 34 ++++++++-
 36 files changed, 411 insertions(+), 206 deletions(-)

The conflict resolution of my test-merge:

diff --cc fs/posix_acl.c
index edc452c2a563,647c28180675..59d47ab0791a
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@@ -833,24 -839,6 +833,24 @@@ set_posix_acl(struct inode *inode, int 
  	if (!inode_owner_or_capable(inode))
  		return -EPERM;
  
 +	if (acl) {
- 		int ret = posix_acl_valid(acl);
++		int ret = posix_acl_valid(inode->i_sb->s_user_ns, acl);
 +		if (ret)
 +			return ret;
 +	}
 +	return inode->i_op->set_acl(inode, acl, type);
 +}
 +EXPORT_SYMBOL(set_posix_acl);
 +
 +static int
 +posix_acl_xattr_set(const struct xattr_handler *handler,
 +		    struct dentry *unused, struct inode *inode,
 +		    const char *name, const void *value,
 +		    size_t size, int flags)
 +{
 +	struct posix_acl *acl = NULL;
 +	int ret;
 +
  	if (value) {
  		acl = posix_acl_from_xattr(&init_user_ns, value, size);
  		if (IS_ERR(acl))
diff --cc fs/proc/inode.c
index 42305ddcbaa0,a5b2c33745b7..6b1843e78bd7
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@@ -462,6 -463,11 +463,18 @@@ int proc_fill_super(struct super_block 
  	struct inode *root_inode;
  	int ret;
  
++	/*
++	 * procfs isn't actually a stacking filesystem; however, there is
++	 * too much magic going on inside it to permit stacking things on
++	 * top of it
++	 */
++	s->s_stack_depth = FILESYSTEM_MAX_STACK_DEPTH;
++
+ 	if (!proc_parse_options(data, ns))
+ 		return -EINVAL;
+ 
+ 	/* User space would break if executables or devices appear on proc */
+ 	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
  	s->s_flags |= MS_NODIRATIME | MS_NOSUID | MS_NOEXEC;
  	s->s_blocksize = 1024;
  	s->s_blocksize_bits = 10;

Eric
