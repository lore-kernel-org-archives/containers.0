From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] user namespace and namespace infrastructure changes for 3.8
Date: Mon, 17 Dec 2012 15:18:57 -0800
Message-ID: <87wqwggtcu.fsf__5867.7674075172$1355786375$gmane$org@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus git tree from:

   git://git.kernel.org:/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: 5155040ed349950e16c093ba8e65ad534994df2a userns: Fix typo in description of the limitation of userns_install

   This tree is against v3.7-rc3

The embarrasing oversights that Andy found have been corrected.

While small this set of changes is very significant with respect to
containers in general and user namespaces in particular.  The user space
interface is now complete.

This set of changes adds support for unprivileged users to create user
namespaces and as a user namespace root to create other namespaces.  The
tyrrany of supporting suid root preventing unprivileged users from using
cool new kernel features is broken.

This set of changes completes the work on setns, adding support for
the pid, user, mount namespaces.

This set of changes includes a bunch of basic pid namespace
cleanups/simplifications.  Of particular significance is the rework of
the pid namespace cleanup so it no longer requires sending out tendrils
into all kinds of unexpected cleanup paths for operation.  At least one
case of broken error handling is fixed by this cleanup.

The files under /proc/<pid>/ns/ have been converted from regular files
to magic symlinks which prevents incorrect caching by the VFS, ensuring
the files always refer to the namespace the process is currently using
and ensuring that the ptrace_mayaccess permission checks are always
applied.

The files under /proc/<pid>/ns/ have been given stable inode numbers so
it is now possible to see if different processes share the same
namespaces.

Through the David Miller's net tree are changes to relax many of the
permission checks in the networking stack to allowing the user namespace
root to usefully use the networking stack.  Similar changes for the
mount namespace and the pid namespace are coming through my tree.

Two small changes to add user namespace support were commited here
adn in David Miller's -net tree so that I could complete the work on the
/proc/<pid>/ns/ files in this tree.  

Work remains to make it safe to build user namespaces and 9p, afs,
ceph, cifs, coda, gfs2, ncpfs, nfs, nfsd, ocfs2, and xfs so the Kconfig
guard remains in place preventing that user namespaces from being built
when any of those filesystems are enabled.

Future design work remains to allow root users outside of the initial
user namespace to mount more than just /proc and /sys.

Eric W. Biederman (41):
      userns: Support autofs4 interacing with multiple user namespaces
      userns: Support fuse interacting with multiple user namespaces
      netns: Deduplicate and fix copy_net_ns when !CONFIG_NET_NS
      userns: make each net (net_ns) belong to a user_ns
      userns: On mips modify check_same_owner to use uid_eq
      procfs: Use the proc generic infrastructure for proc/self.
      procfs: Don't cache a pid in the root inode.
      pidns: Capture the user namespace and filter ns_last_pid
      pidns: Use task_active_pid_ns where appropriate
      pidns: Make the pidns proc mount/umount logic obvious.
      pidns: Don't allow new processes in a dead pid namespace.
      pidns: Wait in zap_pid_ns_processes until pid_ns->nr_hashed == 1
      pidns: Deny strange cases when creating pid namespaces.
      pidns: Add setns support
      pidns: Consolidate initialzation of special init task state
      pidns: Support unsharing the pid namespace.
      vfs: Allow chroot if you have CAP_SYS_CHROOT in your user namespace
      vfs: Add setns support for the mount namespace
      vfs: Add a user namespace reference from struct mnt_namespace
      vfs: Only support slave subtrees across different user namespaces
      vfs: Allow unprivileged manipulation of the mount namespace.
      userns: Ignore suid and sgid on binaries if the uid or gid can not be mapped
      userns: Allow unprivileged users to create user namespaces.
      userns: Allow chown and setgid preservation
      userns: Allow setting a userns mapping to your current uid.
      userns: Allow unprivileged users to create new namespaces
      userns: Allow unprivileged use of setns.
      userns: Make create_new_namespaces take a user_ns parameter
      userns: Kill task_user_ns
      userns: Implent proc namespace operations
      userns: Implement unshare of the user namespace
      procfs: Print task uids and gids in the userns that opened the proc file
      userns: For /proc/self/{uid,gid}_map derive the lower userns from the struct file
      userns: Allow unprivilged mounts of proc and sysfs
      proc: Generalize proc inode allocation
      proc: Fix the namespace inode permission checks.
      proc: Usable inode numbers for the namespace file descriptors.
      Fix cap_capable to only allow owners in the parent user namespace to have caps.
      userns: Require CAP_SYS_ADMIN for most uses of setns.
      userns: Add a more complete capability subset test to commit_creds
      userns: Fix typo in description of the limitation of userns_install

Zhao Hongjiang (1):
      userns: fix return value on mntns_install() failure

 arch/mips/kernel/mips-mt-fpaff.c          |    4 +-
 arch/powerpc/platforms/cell/spufs/sched.c |    2 +-
 arch/um/drivers/mconsole_kern.c           |    2 +-
 drivers/staging/android/binder.c          |    3 +-
 fs/attr.c                                 |   11 +-
 fs/autofs4/autofs_i.h                     |    8 +-
 fs/autofs4/dev-ioctl.c                    |    4 +-
 fs/autofs4/inode.c                        |   24 ++--
 fs/autofs4/waitq.c                        |    5 +-
 fs/exec.c                                 |    9 +-
 fs/fuse/dev.c                             |    4 +-
 fs/fuse/dir.c                             |   20 ++--
 fs/fuse/fuse_i.h                          |    4 +-
 fs/fuse/inode.c                           |   23 ++--
 fs/hppfs/hppfs.c                          |    2 +-
 fs/mount.h                                |    3 +
 fs/namespace.c                            |  212 ++++++++++++++++++++++++-----
 fs/open.c                                 |    2 +-
 fs/pnode.h                                |    1 +
 fs/proc/Makefile                          |    1 +
 fs/proc/array.c                           |    2 +-
 fs/proc/base.c                            |  169 +----------------------
 fs/proc/generic.c                         |   26 ++--
 fs/proc/inode.c                           |    6 +-
 fs/proc/internal.h                        |    1 +
 fs/proc/namespaces.c                      |  185 ++++++++++++++++++++++---
 fs/proc/root.c                            |   17 +--
 fs/proc/self.c                            |   59 ++++++++
 fs/sysfs/mount.c                          |    1 +
 include/linux/cred.h                      |    2 -
 include/linux/fs.h                        |    2 +
 include/linux/ipc_namespace.h             |    9 +-
 include/linux/mnt_namespace.h             |    3 +-
 include/linux/nsproxy.h                   |    2 +-
 include/linux/pid_namespace.h             |   11 +-
 include/linux/proc_fs.h                   |   26 ++++-
 include/linux/user_namespace.h            |   10 ++
 include/linux/utsname.h                   |    7 +-
 include/net/net_namespace.h               |   26 +++-
 init/Kconfig                              |    2 -
 init/main.c                               |    1 -
 init/version.c                            |    2 +
 ipc/msgutil.c                             |    2 +
 ipc/namespace.c                           |   33 ++++-
 kernel/cgroup.c                           |    2 +-
 kernel/cred.c                             |   27 ++++-
 kernel/events/core.c                      |    2 +-
 kernel/exit.c                             |   12 --
 kernel/fork.c                             |   69 +++++++---
 kernel/nsproxy.c                          |   36 +++---
 kernel/pid.c                              |   47 ++++++-
 kernel/pid_namespace.c                    |  113 ++++++++++++---
 kernel/ptrace.c                           |   10 +-
 kernel/sched/core.c                       |   10 +-
 kernel/signal.c                           |    2 +-
 kernel/sysctl_binary.c                    |    2 +-
 kernel/user.c                             |    2 +
 kernel/user_namespace.c                   |  147 +++++++++++++++++---
 kernel/utsname.c                          |   34 ++++-
 net/core/net_namespace.c                  |   55 ++++++--
 security/commoncap.c                      |   25 +++-
 security/yama/yama_lsm.c                  |   12 ++-
 62 files changed, 1074 insertions(+), 481 deletions(-)
