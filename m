From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 0/43] Completing the user namespace
Date: Sat, 07 Apr 2012 22:10:28 -0700
Message-ID: <m11unyn70b.fsf@fess.ebiederm.org>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org


This is a course correction for the user namespace, so that we can reach
an inexpensive, maintainable, and reasonably complete implementation.

If anyone can think of a reason why the user namespace should not
evolve in the direction taken in this patchset please let me know.

There is not an obvious maintainer for the scope of what this patchset
covers so I intend to host this tree myself and to place it in
linux-next after this round of review.

Highlights.
- The kernel will now fail to build if you attempt to compile in
  code whose permission checks have not been updated to be user
  namespace safe.

- All uids from child user namespaces are mapped into the initial user
  namespace before they are processed.  Removing the need to add
  an additional check to see if the user namespace of the compared
  uids remains the same.

- With the user namespaces compiled out the performance is as good or
  better than it is today.

- For most operations absolutely nothing changes performance or
  operationally with the user namespace enabled.

- The worse case performance I could come up with was timing 1 billion
  cache code stat operations with the user namespace code enabled.  This
  went from 156s to 164s on my laptop (or 156ns to 164ns per stat
  operation).

- (uid_t)-1 and (gid_t)-1 are reserved as an internal error value.
  Most uid/gid setting system calls treat these value specially anyway
  so attempting to use -1 as a uid would likely cause entertaining
  failures in userspace.

- If setuid is called with a uid that can not be mapped setuid fails.
  I have looked at sendmail, login, ssh and every other program I could
  think of that would call setuid and they all check for and handle
  the case where setuid fails.

- If stat or a similar system call is called from a context in which we
  can not map a uid we lie and return overflowuid.  The LFS experience
  suggests not lying and returning an error code might be better, but
  the historical precedent with uids is different and I can't figure out
  what would break by lying about a uid we can't map.

- Capabilities are localized to the current user namespace making
  it safe to give the initial user in a user namespace all capabilities.

This patchset covers all the modifications needed to convert the core
kernel and make enough other bits to make a bootable result.

These patches are against linux-3.4-rc1 and are also available at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git master

An essentially complete conversion of the entire kernel is available at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git userns-always-map-user-v26
I have reviewed the additional patches less stringently.  The diffstat
for the additional changes is:
 211 files changed, 1496 insertions(+), 979 deletions(-)

Eric W. Biederman (43):
      vfs: Don't allow a user namespace root to make device nodes
      userns: Kill bogus declaration of function release_uids
      userns: Replace netlink uses of cap_raised with capable.
      userns: Remove unnecessary cast to struct user_struct when copying cred->user.
      cred: Add forward declaration of init_user_ns in all cases.
      userns: Use cred->user_ns instead of cred->user->user_ns
      cred: Refcount the user_ns pointed to by the cred.
      userns: Add an explicit reference to the parent user namespace
      mqueue: Explicitly capture the user namespace to send the notification to.
      userns: Deprecate and rename the user_namespace reference in the user_struct
      userns: Start out with a full set of capabilities.
      userns: Replace the hard to write inode_userns with inode_capable.
      userns: Add kuid_t and kgid_t and associated infrastructure in uidgid.h
      userns: Add a Kconfig option to enforce strict kuid and kgid type checks
      userns: Disassociate user_struct from the user_namespace.
      userns: Simplify the user_namespace by making userns->creator a kuid.
      userns: Rework the user_namespace adding uid/gid mapping support
      userns: Convert group_info values from gid_t to kgid_t.
      userns: Store uid and gid values in struct cred with kuid_t and kgid_t types
      userns: Replace user_ns_map_uid and user_ns_map_gid with from_kuid and from_kgid
      userns: Convert sched_set_affinity and sched_set_scheduler's permission checks
      userns: Convert capabilities related permsion checks
      userns: Convert setting and getting uid and gid system calls to use kuid and kgid
      userns: Convert ptrace, kill, set_priority permission checks to work with kuids and kgids
      userns: Store uid and gid types in vfs structures with kuid_t and kgid_t types
      userns: Convert in_group_p and in_egroup_p to use kgid_t
      userns: Use uid_eq gid_eq helpers when comparing kuids and kgids in the vfs
      userns: Convert user specfied uids and gids in chown into kuids and kgid
      userns: Convert stat to return values mapped from kuids and kgids
      userns: Fail exec for suid and sgid binaries with ids outside our user namespace.
      userns: Teach inode_capable to understand inodes whose uids map to other namespaces.
      userns: signal remove unnecessary map_cred_ns
      userns: Convert binary formats to use kuid/kgid where appropriate
      userns: Convert devpts to use kuid/kgid where appropriate
      userns: Convert ext2 to use kuid/kgid where appropriate.
      userns: Convert ext3 to use kuid/kgid where appropriate
      userns: Convert ext4 to user kuid/kgid where appropriate
      userns: Convert proc to use kuid/kgid where appropriate
      userns: Convert sysctl permission checks to use kuid and kgids.
      userns: Convert sysfs to use kgid/kuid where appropriate
      userns: Convert tmpfs to use kuid and kgid where appropriate
      userns: Convert cgroup permission checks to use uid_eq
      userns: Convert the move_pages, and migrate_pages permission checks to use uid_eq


 arch/arm/kernel/sys_oabi-compat.c      |    4 +-
 arch/parisc/hpux/fs.c                  |    4 +-
 arch/s390/kernel/compat_linux.c        |   17 +-
 arch/sparc/kernel/sys_sparc32.c        |    4 +-
 arch/x86/ia32/sys_ia32.c               |    4 +-
 arch/x86/mm/fault.c                    |    2 +-
 drivers/block/drbd/drbd_nl.c           |    2 +-
 drivers/md/dm-log-userspace-transfer.c |    2 +-
 drivers/video/uvesafb.c                |    2 +-
 fs/attr.c                              |    8 +-
 fs/binfmt_elf.c                        |   12 +-
 fs/binfmt_elf_fdpic.c                  |   12 +-
 fs/compat.c                            |    4 +-
 arch/arm/kernel/sys_oabi-compat.c      |    4 +-
 arch/parisc/hpux/fs.c                  |    4 +-
 arch/s390/kernel/compat_linux.c        |   17 +-
 arch/sparc/kernel/sys_sparc32.c        |    4 +-
 arch/x86/ia32/sys_ia32.c               |    4 +-
 arch/x86/mm/fault.c                    |    2 +-
 drivers/block/drbd/drbd_nl.c           |    2 +-
 drivers/md/dm-log-userspace-transfer.c |    2 +-
 drivers/video/uvesafb.c                |    2 +-
 fs/attr.c                              |    8 +-
 fs/binfmt_elf.c                        |   12 +-
 fs/binfmt_elf_fdpic.c                  |   12 +-
 fs/compat.c                            |    4 +-
 fs/devpts/inode.c                      |   24 +-
 fs/ecryptfs/messaging.c                |    2 +-
 fs/exec.c                              |   15 +-
 fs/ext2/balloc.c                       |    5 +-
 fs/ext2/ext2.h                         |    8 +-
 fs/ext2/inode.c                        |   20 +-
 fs/ext2/super.c                        |   31 ++-
 fs/ext3/balloc.c                       |    5 +-
 fs/ext3/ext3.h                         |    8 +-
 fs/ext3/inode.c                        |   32 +-
 fs/ext3/super.c                        |   35 ++-
 fs/ext4/balloc.c                       |    4 +-
 fs/ext4/ext4.h                         |    4 +-
 fs/ext4/ialloc.c                       |    4 +-
 fs/ext4/inode.c                        |   34 +-
 fs/ext4/migrate.c                      |    4 +-
 fs/ext4/super.c                        |   38 ++-
 fs/fcntl.c                             |    6 +-
 fs/inode.c                             |   10 +-
 fs/ioprio.c                            |   18 +-
 fs/locks.c                             |    2 +-
 fs/namei.c                             |   29 +-
 fs/nfsd/auth.c                         |    5 +-
 fs/open.c                              |   16 +-
 fs/proc/array.c                        |   15 +-
 fs/proc/base.c                         |   93 +++++-
 fs/proc/inode.c                        |    4 +-
 fs/proc/proc_sysctl.c                  |    4 +-
 fs/proc/root.c                         |    2 +-
 fs/stat.c                              |    8 +-
 fs/sysfs/inode.c                       |    4 +-
 include/linux/capability.h             |    2 +
 include/linux/cred.h                   |   33 +-
 include/linux/fs.h                     |   42 ++-
 include/linux/pid_namespace.h          |    2 +-
 include/linux/proc_fs.h                |    4 +-
 include/linux/quotaops.h               |    4 +-
 include/linux/sched.h                  |    9 +-
 include/linux/shmem_fs.h               |    4 +-
 include/linux/stat.h                   |    5 +-
 include/linux/uidgid.h                 |  200 +++++++++++
 include/linux/user_namespace.h         |   39 +-
 include/trace/events/ext3.h            |    4 +-
 include/trace/events/ext4.h            |    4 +-
 init/Kconfig                           |   12 +-
 ipc/mqueue.c                           |   10 +-
 ipc/namespace.c                        |    2 +-
 kernel/capability.c                    |   21 ++
 kernel/cgroup.c                        |    6 +-
 kernel/cred.c                          |   44 ++-
 kernel/exit.c                          |    6 +-
 kernel/groups.c                        |   50 ++--
 kernel/ptrace.c                        |   15 +-
 kernel/sched/core.c                    |    7 +-
 kernel/signal.c                        |   51 +--
 kernel/sys.c                           |  266 ++++++++++-----
 kernel/timer.c                         |    8 +-
 kernel/uid16.c                         |   48 ++-
 kernel/user.c                          |   51 ++-
 kernel/user_namespace.c                |  594 ++++++++++++++++++++++++++++----
 kernel/utsname.c                       |    2 +-
 mm/mempolicy.c                         |    4 +-
 mm/migrate.c                           |    4 +-
 mm/oom_kill.c                          |    4 +-
 mm/shmem.c                             |   22 +-
 net/core/sock.c                        |    4 +-
 net/ipv4/ping.c                        |   11 +-
 net/sunrpc/auth_generic.c              |    4 +-
 net/sunrpc/auth_gss/svcauth_gss.c      |    7 +-
 net/sunrpc/auth_unix.c                 |   15 +-
 net/sunrpc/svcauth_unix.c              |   18 +-
 security/commoncap.c                   |   63 ++--
 security/keys/key.c                    |    2 +-
 security/keys/permission.c             |    5 +-
 security/keys/process_keys.c           |    2 +-
 88 files changed, 1670 insertions(+), 606 deletions(-)
