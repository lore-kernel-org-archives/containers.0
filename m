From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 0/11] pid namespace cleanups and enhancements
Date: Fri, 16 Nov 2012 08:32:43 -0800
Message-ID: <8739097bkk.fsf@xmission.com>
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
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org


This patchset is my pile of pid namespace patches that I have been
sitting on for entirely too long.  I have been running and testing these
changes for a while but if anyone sees any problems please let me know.

Feature wise this patchset adds unshare and setns support for the pid
namespace.

Cleanup wise this patchset adds an explicit count of how many pids are
hashed in a pid namespace and uses that count to trigger the unmounting
of the internal kernel mount of proc.  The current scheme is buggy and
entirely too clever to continue living.

Some proc bits that were added to support the pid namespace initially
are removed, as they are no no longer necessary.

These patches are also available at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git pidns-v73

Since some of this work is closely allied with the user namespace bits I
have pending I intend to merge these changes through my user namespace
tree.

Eric W. Biederman (11):
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

 arch/powerpc/platforms/cell/spufs/sched.c |    2 +-
 arch/um/drivers/mconsole_kern.c           |    2 +-
 drivers/staging/android/binder.c          |    3 +-
 fs/hppfs/hppfs.c                          |    2 +-
 fs/proc/Makefile                          |    1 +
 fs/proc/base.c                            |  169 +----------------------------
 fs/proc/internal.h                        |    1 +
 fs/proc/namespaces.c                      |    3 +
 fs/proc/root.c                            |   16 +---
 fs/proc/self.c                            |   59 ++++++++++
 include/linux/pid_namespace.h             |   10 ++-
 include/linux/proc_fs.h                   |    1 +
 init/main.c                               |    1 -
 kernel/cgroup.c                           |    2 +-
 kernel/events/core.c                      |    2 +-
 kernel/exit.c                             |   12 --
 kernel/fork.c                             |   42 +++++---
 kernel/nsproxy.c                          |    4 +-
 kernel/pid.c                              |   46 +++++++--
 kernel/pid_namespace.c                    |   99 +++++++++++++----
 kernel/signal.c                           |    2 +-
 kernel/sysctl_binary.c                    |    2 +-
 22 files changed, 231 insertions(+), 250 deletions(-)
