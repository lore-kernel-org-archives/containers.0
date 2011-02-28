From: ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
Subject: [RFC 00/10] container-based checkpoint/restart prototype
Date: Mon, 28 Feb 2011 17:40:22 -0600
Message-ID: <1298936432-29607-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Checkpoint/restart is a facility by which one can save the state of a
job to a file and restart it later under the right conditions.  This
is a C/R prototype intended to illustrate how well (or poorly) it
would fit into the Linux kernel.  It is basically a fork of the
"linux-cr" patch set by Oren Laadan and others, but it is more limited
in scope and has a different system call interface.  I believe what I
have here is a decent starting point for a C/R implementation that can
go upstream, but I'm releasing early with the hope of receiving some
feedback/review on the overall approach before pursuing it too much
further.

The intended users are HPC, big homogeneous clusters, environments
with long-running jobs that are not easily interrupted without losing
work, for whatever reason (perhaps you've misplaced the source code
for your program and can't modify it to checkpoint and restore its own
state).  In these situations checkpoint/restart provides a rollback
mechanism to mitigate the effects of hardware/system failures as well
as a means of migrating jobs between nodes.


How it works:

Only a process with PID 1 ("init") can call checkpoint or restart.

Checkpoint freezes the rest of the pidns and goes about dumping the
state of all the other tasks in the PID namespace to the specificed
file descriptor.  The state of the caller is not recorded.

Before calling restart, init is expected to set up the environment
(mounts, net devices and such) in accord with the checkpointed job's
"expectations".  The restart system call recreates the task tree
(except for init itself) and the tasks resume execution; init can
then wait(2) for tasks to exit in the normal fashion.


Limitations:

This implementation is limited to containers by design (and this
prototype is limited to checkpoint/restore of a single simple task).
A Linux "container" doesn't have a universally agreed upon definition,
but in this context we are referring to a group of processes for which
the PID namespace (and possibly other namespaces) is isolated from the
rest of the system (see clone(2)).  This is the tradeoff we ask users
to make - the ability to C/R and migrate is provided in exchange for
accepting some isolation and slightly reduced ease of use.  A tool
such as lxc (http://lxc.sourceforge.net) can be used to isolate jobs.
A patch against lxc is available which adds C/R capability.

The user must ensure that a restarted job's view of the filesystem is
effectively the same as it was at the time of checkpoint.

Processes that map device memory and other such hardware-dependent
things will probably not be supported.


To do:

Multiple tasks
Signal state
System call restart blocks
More code cleanup/simplification
Other architecture support
System V IPC
Network/sockets
And much more


 Documentation/filesystems/vfs.txt  |   13 +-
 arch/x86/Kconfig                   |    4 +
 arch/x86/include/asm/checkpoint.h  |   17 +
 arch/x86/include/asm/elf.h         |    5 +
 arch/x86/include/asm/ldt.h         |    7 +
 arch/x86/include/asm/unistd_32.h   |    4 +-
 arch/x86/kernel/Makefile           |    2 +
 arch/x86/kernel/checkpoint.c       |  677 +++++++++++++++++++++++++++
 arch/x86/kernel/syscall_table_32.S |    2 +
 arch/x86/vdso/vdso32-setup.c       |   25 +-
 drivers/char/mem.c                 |    6 +
 drivers/char/random.c              |    6 +
 fs/Makefile                        |    1 +
 fs/aio.c                           |   27 ++
 fs/checkpoint.c                    |  695 +++++++++++++++++++++++++++
 fs/exec.c                          |    2 +-
 fs/ext2/dir.c                      |    3 +
 fs/ext2/file.c                     |    6 +
 fs/ext3/dir.c                      |    3 +
 fs/ext3/file.c                     |    3 +
 fs/ext4/dir.c                      |    3 +
 fs/ext4/file.c                     |    6 +
 fs/fcntl.c                         |   21 +-
 fs/locks.c                         |   35 ++
 include/linux/aio.h                |    2 +
 include/linux/checkpoint.h         |  347 ++++++++++++++
 include/linux/fs.h                 |   15 +
 include/linux/magic.h              |    3 +
 include/linux/mm.h                 |   15 +
 init/Kconfig                       |    2 +
 kernel/Makefile                    |    1 +
 kernel/checkpoint/Kconfig          |   15 +
 kernel/checkpoint/Makefile         |    9 +
 kernel/checkpoint/checkpoint.c     |  437 +++++++++++++++++
 kernel/checkpoint/objhash.c        |  368 +++++++++++++++
 kernel/checkpoint/restart.c        |  651 ++++++++++++++++++++++++++
 kernel/checkpoint/sys.c            |  208 +++++++++
 kernel/sys_ni.c                    |    4 +
 mm/Makefile                        |    1 +
 mm/checkpoint.c                    |  906 ++++++++++++++++++++++++++++++++++++
 mm/filemap.c                       |    4 +
 mm/mmap.c                          |    3 +
 42 files changed, 4549 insertions(+), 15 deletions(-)
 create mode 100644 arch/x86/include/asm/checkpoint.h
 create mode 100644 arch/x86/kernel/checkpoint.c
 create mode 100644 fs/checkpoint.c
 create mode 100644 include/linux/checkpoint.h
 create mode 100644 kernel/checkpoint/Kconfig
 create mode 100644 kernel/checkpoint/Makefile
 create mode 100644 kernel/checkpoint/checkpoint.c
 create mode 100644 kernel/checkpoint/objhash.c
 create mode 100644 kernel/checkpoint/restart.c
 create mode 100644 kernel/checkpoint/sys.c
 create mode 100644 mm/checkpoint.c

-- 
1.7.4
