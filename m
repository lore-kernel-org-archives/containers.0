From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] namespace chnages for 3.12
Date: Thu, 05 Sep 2013 14:07:29 -0700
Message-ID: <87mwnrht9q.fsf@xmission.com>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus git tree from:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: c7b96acf1456ef127fef461fcfedb54b81fecfbb userns:  Kill nsown_capable it makes the wrong thing easy

   This tree is against v3.11-rc1

This is an assorted mishmash of small cleanups, enhancements and bug
fixes.  The major theme is user namespace mount restrictions.
nsown_capable is killed as it encourages not thinking about details that
need to be considered.  A very hard to hit pid namespace exiting bug was
finally tracked and fixed.  A couple of cleanups to the basic namespace
infrastructure.

Finally there is an enhancement that makes per user namespace
capabilities usable as capabilities, and an enhancement that allows the
per userns root to nice other processes in the user namespace.

Eric W. Biederman (10):
      vfs: Lock in place mounts from more privileged users
      proc: Restrict mounting the proc filesystem
      vfs: Don't copy mount bind mounts of /proc/<pid>/ns/mnt between namespaces
      userns: Better restrictions on when proc and sysfs can be mounted
      sysfs: Restrict mounting sysfs
      pidns: Fix hang in zap_pid_ns_processes by sending a potentially extra wakeup
      namespaces: Simplify copy_namespaces so it is clear what is going on.
      userns: Allow PR_CAPBSET_DROP in a user namespace.
      pidns: Don't have unshare(CLONE_NEWPID) imply CLONE_THREAD
      userns:  Kill nsown_capable it makes the wrong thing easy

Raphael S.Carvalho (1):
      kernel/nsproxy.c: Improving a snippet of code.

Serge Hallyn (1):
      capabilities: allow nice if we are privileged

 fs/namespace.c                 |  121 +++++++++++++++++++++++++++++++---------
 fs/open.c                      |    2 +-
 fs/pnode.h                     |    5 +-
 fs/proc/root.c                 |    6 ++-
 fs/sysfs/mount.c               |   11 +++-
 include/linux/capability.h     |    1 -
 include/linux/fs.h             |    1 +
 include/linux/kobject_ns.h     |    2 +
 include/linux/mount.h          |    1 +
 include/linux/user_namespace.h |    4 -
 ipc/namespace.c                |    2 +-
 kernel/capability.c            |   12 ----
 kernel/fork.c                  |    5 --
 kernel/groups.c                |    2 +-
 kernel/nsproxy.c               |   36 ++++--------
 kernel/pid.c                   |    1 +
 kernel/pid_namespace.c         |    2 +-
 kernel/sys.c                   |   20 +++---
 kernel/uid16.c                 |    2 +-
 kernel/user.c                  |    2 -
 kernel/user_namespace.c        |    2 -
 kernel/utsname.c               |    2 +-
 lib/kobject.c                  |   15 +++++
 net/core/net-sysfs.c           |    8 +++
 net/core/net_namespace.c       |    2 +-
 net/core/scm.c                 |    4 +-
 security/commoncap.c           |   10 ++--
 27 files changed, 177 insertions(+), 104 deletions(-)
