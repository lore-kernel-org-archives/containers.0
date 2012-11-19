From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 0/16] user namespace and namespace infrastructure
	completion
Date: Mon, 19 Nov 2012 07:08:11 -0800
Message-ID: <87lidx8wbo.fsf@xmission.com>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


The following series of changes completes the user namespace and adds
the much too long delay bits of namespace infrastructure.

This series of changes adds unprivilged creation of all namespaces
support for creating a user namespace with unshare, and support for
entering a user namespace with setns.

The proc namespace files are converted into magic symlinks to avoid
problems with dentry caching excessively keeping a namespace alive and
dentry caching allowing the ptrace_may_access checks to be bypassed.

The proc namespace now have inode numbers that are always the same for
the same user namespace allowing stat to test if two file descriptors
refer to the same namespace.

Eric W. Biederman (16):
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

 fs/attr.c                      |   11 ++-
 fs/exec.c                      |    9 +--
 fs/mount.h                     |    1 +
 fs/namespace.c                 |   14 +++
 fs/proc/array.c                |    2 +-
 fs/proc/generic.c              |   26 +++---
 fs/proc/inode.c                |    6 +-
 fs/proc/namespaces.c           |  177 +++++++++++++++++++++++++++++++++++-----
 fs/proc/root.c                 |    1 +
 fs/sysfs/mount.c               |    1 +
 include/linux/cred.h           |    2 -
 include/linux/ipc_namespace.h  |    9 ++-
 include/linux/nsproxy.h        |    2 +-
 include/linux/pid_namespace.h  |    1 +
 include/linux/proc_fs.h        |   18 ++++-
 include/linux/user_namespace.h |   10 ++
 include/linux/utsname.h        |    7 +-
 include/net/net_namespace.h    |    2 +
 init/version.c                 |    2 +
 ipc/msgutil.c                  |    2 +
 ipc/namespace.c                |   32 ++++++--
 kernel/fork.c                  |   33 +++++---
 kernel/nsproxy.c               |   34 ++++----
 kernel/pid.c                   |    1 +
 kernel/pid_namespace.c         |   12 +++
 kernel/ptrace.c                |   10 ++-
 kernel/sched/core.c            |   10 ++-
 kernel/user.c                  |    2 +
 kernel/user_namespace.c        |  147 +++++++++++++++++++++++++++++----
 kernel/utsname.c               |   33 ++++++--
 net/core/net_namespace.c       |   31 +++++++-
 security/yama/yama_lsm.c       |   12 ++-
 32 files changed, 535 insertions(+), 125 deletions(-)
