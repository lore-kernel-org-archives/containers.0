From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 0/13] Adding a userns owner to struct super_block
Date: Mon, 20 Jun 2016 12:09:43 -0500
Message-ID: <87fus77pns.fsf@x220.int.ebiederm.org>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


Available from git at:

    git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-testing

This changeset is part of ongoing work by Seth Forshee and myself to
update the VFS to allow ordinary users to mount filesystems with a
backing store.  The primary target is the fuse filesystem but there
are other filesystems such as shiftfs that will benefit.

The high level idea is to:

- Assign filesystems a owning user namespace (s_user_ns).

- Update permission checks (such as the one in remount) to use s_user_ns.

- Interpret uids/gids from outside the kernels control as coming
  from inside s_user_ns.

- Handle vfs uid and gid fields containing INVALID_UID and INVALID_GID
  indicating there is no mapping from the filesystem uids and gids into
  the kernel representation.

This changeset addresses the first step in this process mounting
filesystems, and adding a s_user_ns field to struct super_block and
populating it appropriately.

The goal is to keep everything that is not filesystem specific at the
VFS layer and to ensure the VFS and security module issues are properly
handled before updating adding support for filesystems with backing
store external to the kernel such as fuse.

The bulk of this changeset is spent in the weird corner cases that exist
for the existing filesystems we allow mounting with just user namespace
permissions.  Cleaning up and reorganizing that code and handling the
generic mount options nodeve, noexec and nosuid.  The s_iflags flag
SB_I_NODEV is added to mark filesystems that may never contain devices
(which is everything except devpts that is mounted with just user
 namespace permissions).

Eric W. Biederman (13):
      mnt: Account for MS_RDONLY in fs_fully_visible
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

 fs/block_dev.c        |  2 +-
 fs/devpts/inode.c     |  3 +-
 fs/kernfs/mount.c     |  5 ++-
 fs/namei.c            |  8 ++++-
 fs/namespace.c        | 90 ++++++++++++++++++++++-----------------------------
 fs/nfsd/nfsctl.c      | 13 +++-----
 fs/proc/inode.c       |  8 ++++-
 fs/proc/internal.h    |  3 +-
 fs/proc/root.c        | 54 +++----------------------------
 fs/super.c            | 69 ++++++++++++++++++++++++++++++++++-----
 fs/sysfs/mount.c      |  5 ++-
 include/linux/fs.h    | 24 +++++++++++---
 ipc/mqueue.c          | 20 ++++++------
 ipc/namespace.c       |  5 +--
 net/sunrpc/rpc_pipe.c |  8 ++---
 15 files changed, 169 insertions(+), 148 deletions(-)

Eric
