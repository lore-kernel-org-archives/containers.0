From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v2 0/3] Write dump into container's filesystem for pipe_type
	core_pattern
Date: Tue, 7 Jun 2016 17:52:54 +0800
Message-ID: <cover.1465293010.git.zhaolei@cn.fujitsu.com>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

In current system, when we set core_pattern to a pipe, both pipe program
and program's output are in host's filesystem.
But when we set core_pattern to a file, the container will write dump
into container's filesystem.

For example, when we set following core_pattern:
 # echo "|/my_dump_pipe %s %c %p %u %g %t e" >/proc/sys/kernel/core_pattern
and trigger a segment fault in a container, my_dump_pipe is searched from
host's filesystem, and it will write coredump into host's filesystem too.

In a privileged container, user can destroy host system by following
command:
 # # In a container
 # echo "|/bin/dd of=/boot/vmlinuz" >/proc/sys/kernel/core_pattern
 # make_dump

Actually, all operation in a container should not change host's
environment, the container should use core_pattern as its private setting.
In detail, in core dump action:
1: Search pipe program in container's fs namespace.
2: Run pipe program in container's fs namespace to write coredump to it.

I rewrited this patch from origional:
  http://www.gossamer-threads.com/lists/linux/kernel/2395715?do=post_view_flat
and changed the impliment way and function detail discussed in:
  http://www.gossamer-threads.com/lists/linux/kernel/2397602?nohighlight=1#2397602

Changelog v1->v2:
1: Move path_put() out of spin_lock, suggested by:
   Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>

Changelog RFC->v1:
1: RFC->v1
2: Rebase on top of v4.7-rc2

Changes against previous impliment:
1: Avoid forking thread from the crach process.
   Suggested-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
2: To keep compatibility with current code, if user hadn't change
   core_pattern in container, the dump file will still write to
   the host filesystem.
   Suggested-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Zhao Lei (3):
  Save dump_root into pid_namespace
  Make dump_pipe thread possilbe to select the rootfs
  Write dump into container's filesystem for pipe_type core_pattern

 fs/coredump.c                 | 19 ++++++++++++++++++-
 fs/fs_struct.c                | 25 ++++++++++++++++---------
 include/linux/fs_struct.h     |  3 ++-
 include/linux/kmod.h          |  4 +++-
 include/linux/pid_namespace.h |  3 +++
 include/linux/sched.h         |  5 +++--
 init/do_mounts_initrd.c       |  3 ++-
 init/main.c                   |  4 ++--
 kernel/fork.c                 | 34 ++++++++++++++++++++--------------
 kernel/kmod.c                 | 13 ++++++++-----
 kernel/kthread.c              |  3 ++-
 kernel/pid.c                  |  1 +
 kernel/pid_namespace.c        |  6 ++++++
 kernel/sysctl.c               | 33 +++++++++++++++++++++++++++++----
 lib/kobject_uevent.c          |  3 ++-
 security/keys/request_key.c   |  2 +-
 16 files changed, 118 insertions(+), 43 deletions(-)

-- 
1.8.5.1
