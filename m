From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] namespace updates for v3.17-rc1
Date: Tue, 05 Aug 2014 17:57:31 -0700
Message-ID: <87fvhav3ic.fsf@x220.int.ebiederm.org>
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

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: 344470cac42e887e68cfb5bdfa6171baf27f1eb5 proc: Point /proc/mounts at /proc/thread-self/mounts instead of /proc/self/mounts

This is a bunch of small changes built against 3.16-rc6.  The most
significant change for users is the first patch which makes setns
drmatically faster by removing unneded rcu handling.

The next chunk of changes are so that "mount -o remount,.." will not
allow the user namespace root to drop flags on a mount set by the system
wide root.  Aks this forces read-only mounts to stay read-only, no-dev
mounts to stay no-dev, no-suid mounts to stay no-suid, no-exec mounts to
stay no exec and it prevents unprivileged users from messing with a
mounts atime settings.  I have included my test case as the last patch
in this series so people performing backports can verify this change
works correctly.

The next change fixes a bug in NFS that was discovered while auditing
nsproxy users for the first optimization.  Today you can oops the kernel
by reading /proc/fs/nfsfs/{servers,volumes} if you are clever with pid
namespaces.  I rebased and fixed the build of the !CONFIG_NFS_FS case
yesterday when a build bot caught my typo.  Given that no one to my
knowledge bases anything on my tree fixing the typo in place seems more
responsible that requiring a typo-fix to be backported as well.

The last change is a small semantic cleanup introducing
/proc/thread-self and pointing /proc/mounts and /proc/net at it.  This
prevents several kinds of problemantic corner cases.  It is a
user-visible change so it has a minute chance of causing regressions so
the change to /proc/mounts and /proc/net are individual one line commits
that can be trivially reverted.  Unfortunately I lost and could not find
the email of the original reporter so he is not credited.  From at least
one perspective this change to /proc/net is a refgression fix to allow
pthread /proc/net uses that were broken by the introduction of the network
namespace.

Eric

Eric W. Biederman (11):
      namespaces: Use task_lock and not rcu to protect nsproxy
      mnt: Only change user settable mount flags in remount
      mnt: Move the test for MNT_LOCK_READONLY from change_mount_flags into do_remount
      mnt: Correct permission checks in do_remount
      mnt: Change the default remount atime from relatime to the existing value
      mnt: Add tests for unprivileged remount cases that have found to be faulty
      NFS: Fix /proc/fs/nfsfs/servers and /proc/fs/nfsfs/volumes
      proc: Have net show up under /proc/<tgid>/task/<tid>
      proc: Implement /proc/thread-self to point at the directory of the current thread
      proc: Point /proc/net at /proc/thread-self/net instead of /proc/self/net
      proc: Point /proc/mounts at /proc/thread-self/mounts instead of /proc/self/mounts

 fs/namespace.c                                     |  65 +++++-
 fs/nfs/client.c                                    |  95 ++++----
 fs/nfs/inode.c                                     |   3 +-
 fs/nfs/internal.h                                  |   9 +
 fs/nfs/netns.h                                     |   3 +
 fs/proc/Makefile                                   |   1 +
 fs/proc/base.c                                     |  18 +-
 fs/proc/inode.c                                    |   7 +-
 fs/proc/internal.h                                 |   6 +
 fs/proc/proc_net.c                                 |   6 +-
 fs/proc/root.c                                     |   5 +-
 fs/proc/thread_self.c                              |  85 ++++++++
 fs/proc_namespace.c                                |   8 +-
 include/linux/mount.h                              |   9 +-
 include/linux/nsproxy.h                            |  16 +-
 include/linux/pid_namespace.h                      |   1 +
 ipc/namespace.c                                    |   6 +-
 kernel/nsproxy.c                                   |  15 +-
 kernel/utsname.c                                   |   6 +-
 net/core/net_namespace.c                           |  10 +-
 tools/testing/selftests/Makefile                   |   1 +
 tools/testing/selftests/mount/Makefile             |  17 ++
 .../selftests/mount/unprivileged-remount-test.c    | 242 +++++++++++++++++++++
 23 files changed, 537 insertions(+), 97 deletions(-)
