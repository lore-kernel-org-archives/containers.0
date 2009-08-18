From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-dev,
	updated. v2.6.27-rc5-46194-g1344cd0
Date: Tue, 18 Aug 2009 15:00:02 -0400
Message-ID: <200908181900.n7IJ024W030812@gorgona.ncl.cs.columbia.edu>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The branch, ckpt-v17-dev has been updated
       via  1344cd02706d6730ea7168c2f5f5681026e86213 (commit)
       via  d928bdf97a9dafa55f78fc1d6156bfb03f398079 (commit)
       via  6bc04e6cc46dd7e6f68cafcd2b0d91ff4c151c9d (commit)
       via  67dfd223054db933da405a2c7bc2eb75d0dee386 (commit)
       via  eb1d2d53921e5fd063fbe74e84d80663425ff9ff (commit)
       via  06f46a8a47416dff631e219802503319fbe4c951 (commit)
       via  6746319e53bf943002054cd9baad2dba42438a66 (commit)
       via  1012f279b7536cd2670ecea48c388c65ed9900ec (commit)
       via  6110b587a471fba2a065df61d7068a28167a9721 (commit)
      from  e861b44b93a6e14571bcc2f9d68b46ca8c44a734 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit 1344cd02706d6730ea7168c2f5f5681026e86213
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Aug 18 13:15:20 2009 -0400

    c/r: [signal 4/4] support for real/virt/prof itimers
    
    This patch adds support for real/virt/prof itimers.
    Expiry and the interval values are both saved in nanoseconds.
    
    Changelog[v1]:
      - [Louis Rilling] Fix saving of signal->it_real_incr if not expired
      - Fix restoring of signal->it_real_incr if expire is zero
      - Save virt/prof expire relative to process accumulated time
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit d928bdf97a9dafa55f78fc1d6156bfb03f398079
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Aug 18 13:15:20 2009 -0400

    c/r: [signal 3/4] pending signals (private, shared)
    
    This patch adds checkpoint and restart of pending signals queues:
    struct sigpending, both per-task t->sigpending and shared (per-
    thread-group) t->signal->shared_sigpending.
    
    To checkpoint pending signals (private/shared) we first detach the
    signal queue (and copy the mask) to a separate struct sigpending.
    This separate structure can be iterated through without locking.
    
    Once the state is saved, we re-attaches (prepends) the original signal
    queue back to the original struct sigpending.
    
    Signals that arrive(d) in the meantime will be suitably queued after
    these (for real-time signals). Repeated non-realtime signals will not
    be queued because they will already be marked in the pending mask,
    that remains as is. This is the expected behavior of non-realtime
    signals.
    
    Changelog [v3]:
      - [Dan Smith] Sanity check for number of pending signals in buffer
    Changelog [v2]:
      - Validate si_errno from checkpoint image
    Changelog [v1]:
      - Fix compilation warnings
      - [Louis Rilling] Remove SIGQUEUE_PREALLOC flag from queued signals
      - [Louis Rilling] Fail if task has posix-timers or SI_TIMER signal
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 6bc04e6cc46dd7e6f68cafcd2b0d91ff4c151c9d
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Aug 18 13:15:18 2009 -0400

    c/r: [signal 2/4] checkpoint/restart of rlimit
    
    This patch adds checkpoint and restart of rlimit information
    that is part of shared signal_struct.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 67dfd223054db933da405a2c7bc2eb75d0dee386
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Aug 18 13:15:09 2009 -0400

    c/r: [signal 1/4] blocked and template for shared signals
    
    This patch adds checkpoint/restart of blocked signals mask
    (t->blocked) and a template for shared signals (t->signal).
    
    Because t->signal sharing is tied to threads, we ensure proper sharing
    of t->signal (struct signal_struct) for threads only.
    
    Access to t->signal is protected by locking t->sighand->lock.
    Therefore, the usual checkpoint_obj() invoking the callback
    checkpoint_signal(ctx, signal) is insufficient because the task
    pointer is unavailable.
    
    Instead, handling of t->signal sharing is explicit using helpers
    like ckpt_obj_lookup_add(), ckpt_obj_fetch() and ckpt_obj_insert().
    The actual state is saved (if needed) _after_ the task_objs data.
    
    To prevent tasks from handling restored signals during restart,
    set their mask to block all signals and only restore the original
    mask at the very end (before the last sync point).
    
    Introduce per-task pointer 'ckpt_data' to temporary store data
    for restore actions that are deferred to the end (like restoring
    the signal block mask).
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit eb1d2d53921e5fd063fbe74e84d80663425ff9ff
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Aug 18 13:15:08 2009 -0400

    c/r: invoke set_close_on_exec() unconditionally on restart
    
    When restoring a file descriptor (restore_file_desc), make the call to
    set_close_on_exec() not only to set the flags, but also to unset it.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 06f46a8a47416dff631e219802503319fbe4c951
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Aug 18 13:14:43 2009 -0400

    c/r: cleanup - follow naming conventions
    
    More cleanup of the sockets c/r code. Now that we use the methods from
    struct proto_ops (checkpoint,restore), we no longer need the prefix
    "sock_unix_..." for function names in net/unix/checkpoint.c; Instead
    we follow the convention (e.g. in net/unix/afunix.c) "unix_...".
    
    Speaking about code conventions, it is also customary to use 'sock'
    for a struct socket, and a 'sk' for struct sock. This patch also makes
    changes accordingly where necessary.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 6746319e53bf943002054cd9baad2dba42438a66
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Aug 18 13:14:39 2009 -0400

    c/r: add checkpoint/restore methods to struct proto_ops
    
    This patch adds checkpoint and restore methods to struct proto_ops
    which should allow compilation of af-unix sockets as a module. It also
    simplifies the code.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 1012f279b7536cd2670ecea48c388c65ed9900ec
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Aug 18 13:14:29 2009 -0400

    c/r: cleanup sock_file_restore()/sock_file_checkpoint()
    
    This patch was intended to fix a compilation warning regarding the
    sock_file_restore():
    
    checkpoint/files.c: At top level:
    checkpoint/files.c:573: warning: initialization from incompatible pointer type
    
    and evolved to some cleanup of that code, making the following changes:
    
    * Make ckpt_hdr_socket be part of ckpt_hdr_file_socket; There is no
      good reason to use a separate header for it. This saves write/read
      of an extra structure.
    
    * Fold do_sock_file_checkpoint() into sock_file_checkpoint(), and also
      do_sock_file_restore() into sock_file_restore(). This makes the code
      a bit simpler and more streamlined.
    
    * Move sock_file_{checkpoint,restore} to net/checkpoint.c, which is a
      more proper place than net/socket.c.
    
    * Properly define sock_file_{checkpoint,restore} in header file
    
    * Have sock_file_restore() call restore_file_common(), which was
      omitted previously.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 6110b587a471fba2a065df61d7068a28167a9721
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Aug 17 20:20:52 2009 -0400

    c/r: Improve debug output from ckpt_notify_error()
    
    Make ckpt_debug() report a more useful location than the
    line of some generic debug/error wrapper.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 checkpoint/checkpoint.c        |    2 +
 checkpoint/files.c             |    4 +-
 checkpoint/objhash.c           |    7 +
 checkpoint/process.c           |   65 +++++-
 checkpoint/restart.c           |   14 +-
 checkpoint/signal.c            |  493 +++++++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint.h     |    6 +
 include/linux/checkpoint_hdr.h |  176 ++++++++++-----
 include/linux/net.h            |    9 +
 include/linux/posix-timers.h   |    9 +
 include/linux/resource.h       |    4 +
 include/net/af_unix.h          |   33 +---
 include/net/sock.h             |   10 +-
 kernel/posix-cpu-timers.c      |    9 -
 kernel/sys.c                   |   36 ++-
 net/checkpoint.c               |  220 +++++++++++--------
 net/socket.c                   |   84 +-------
 net/unix/af_unix.c             |    6 +
 net/unix/checkpoint.c          |  153 ++++++-------
 19 files changed, 951 insertions(+), 389 deletions(-)


hooks/post-receive
--
linux-cr
