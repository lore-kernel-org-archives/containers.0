From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] namespace related changes for 4.9-rc1
Date: Wed, 05 Oct 2016 12:52:49 -0500
Message-ID: <877f9mfzta.fsf@x220.int.ebiederm.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: 069d5ac9ae0d271903cc4607890616418118379a autofs:  Fix automounts by using current_real_cred()->uid

This set of changes is a number of smaller things that have been
overlooked in other development cycles focused on more fundamental
change.  The devpts changes are small things that were a distraction
until we managed to kill off DEVPTS_MULTPLE_INSTANCES.  There is an
trivial regression fix to autofs for the unprivileged mount changes that
went in last cycle.  A pair of ioctls has been added by Andrey Vagin
making it is possible to discover the relationships between namespaces
when referring to them through file descriptors.

The big user visible change is starting to add simple resource limits to
catch programs that misbehave.  With namespaces in general and user
namespaces in particular allowing users to use more kinds of resources,
it has become important to have something to limit errant programs.
Because the purpose of these limits is to catch errant programs the code
needs to be inexpensive to use as it always on, and the default limits
need to be high enough that well behaved programs on well behaved
systems don't encounter them.

To this end, after some review I have implemented per user per user
namespace limits, and use them to limit the number of namespaces.  The
limits being per user mean that one user can not exhause the limits of
another user.  The limits being per user namespace allow contexts where
the limit is 0 and security conscious folks can remove from their threat
anlysis the code used to manage namespaces (as they have historically
done as it root only).  At the same time the limits being per user
namespace allow other parts of the system to use namespaces.

Namespaces are increasingly being used in application sand boxing
scenarios so an all or nothing disable for the entire system for the
security conscious folks makes increasing use of these sandboxes
impossible.

There is also added a limit on the maximum number of mounts present in a
single mount namespace.  It is nontrivial to guess what a reasonable
system wide limit on the number of mount structure in the kernel would
be, especially as it various based on how a system is using containers.
A limit on the number of mounts in a mount namespace however is much
easier to understand and set.  In most cases in practice only about 1000
mounts are used.  Given that some autofs scenarious have the potential
to be 30,000 to 50,000 mounts I have set the default limit for the
number of mounts at 100,000 which is well above every known set of users
but low enough that the mount hash tables don't degrade unreaonsably.

These limits are a start.  I expect this estabilishes a pattern that
other limits for resources that namespaces use will follow.  There has
been interest in making inotify event limits per user per user namespace
as well as interest expressed in making details about what is going on
in the kernel more visible.

Eric

Andrey Vagin (4):
      kernel: add a helper to get an owning user namespace for a namespace
      nsfs: add ioctl to get an owning user namespace for ns file descriptor
      nsfs: add ioctl to get a parent namespace
      tools/testing: add a test to check nsfs ioctl-s

Arnd Bergmann (1):
      netns: move {inc,dec}_net_namespaces into #ifdef

Eric W. Biederman (24):
      sysctl: Stop implicitly passing current into sysctl_table_root.lookup
      userns: Free user namespaces in process context
      userns: Add per user namespace sysctls.
      userns: Add a limit on the number of user namespaces
      userns: Make the count of user namespaces per user
      userns: Generalize the user namespace count into ucount
      pidns: Add a limit on the number of pid namespaces
      utsns: Add a limit on the number of uts namespaces
      ipcns: Add a  limit on the number of ipc namespaces
      cgroupns: Add a limit on the number of cgroup namespaces
      netns: Add a limit on the number of net namespaces
      mntns: Add a limit on the number of mount namespaces.
      userns; Document per user per user namespace limits.
      userns: When the per user per user namespace limit is reached return ENOSPC
      devpts: Move parse_mount_options into fill_super
      devpts: Move the creation of /dev/pts/ptmx into fill_super
      devpts: Simplify devpts_mount by using mount_nodev
      devpts: Make devpts_kill_sb safe if fsi is NULL
      devpts: Remove sync_filesystems
      devpts: Change the owner of /dev/pts/ptmx to the mounter of /dev/pts
      Merge branch 'nsfs-ioctls' into HEAD
      nsfs: Simplify __ns_get_path
      mnt: Add a per mount namespace limit on the number of mounts
      autofs:  Fix automounts by using current_real_cred()->uid


 Documentation/sysctl/README           |   1 +
 Documentation/sysctl/fs.txt           |   7 +
 Documentation/sysctl/user.txt         |  66 ++++++++++
 fs/autofs4/waitq.c                    |   4 +-
 fs/devpts/inode.c                     |  71 ++++------
 fs/mount.h                            |   3 +
 fs/namespace.c                        |  77 ++++++++++-
 fs/nsfs.c                             | 105 ++++++++++++---
 fs/pnode.c                            |   2 +-
 fs/pnode.h                            |   1 +
 fs/proc/proc_sysctl.c                 |  14 +-
 include/linux/cgroup.h                |   1 +
 include/linux/ipc_namespace.h         |   1 +
 include/linux/mount.h                 |   2 +
 include/linux/pid_namespace.h         |   1 +
 include/linux/proc_ns.h               |   2 +
 include/linux/sysctl.h                |   3 +-
 include/linux/user_namespace.h        |  44 ++++++-
 include/linux/utsname.h               |   1 +
 include/net/net_namespace.h           |   1 +
 include/uapi/linux/nsfs.h             |  13 ++
 ipc/namespace.c                       |  51 ++++++--
 kernel/Makefile                       |   2 +-
 kernel/cgroup.c                       |  24 ++++
 kernel/fork.c                         |   5 +
 kernel/pid_namespace.c                |  50 +++++++-
 kernel/sysctl.c                       |   9 ++
 kernel/ucount.c                       | 235 ++++++++++++++++++++++++++++++++++
 kernel/user_namespace.c               |  99 ++++++++++++--
 kernel/utsname.c                      |  40 +++++-
 net/core/net_namespace.c              |  28 +++-
 net/sysctl_net.c                      |   4 +-
 tools/testing/selftests/Makefile      |   1 +
 tools/testing/selftests/nsfs/Makefile |  12 ++
 tools/testing/selftests/nsfs/owner.c  |  91 +++++++++++++
 tools/testing/selftests/nsfs/pidns.c  |  78 +++++++++++
 36 files changed, 1033 insertions(+), 116 deletions(-)
