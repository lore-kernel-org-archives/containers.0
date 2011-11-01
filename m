From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET] cgroup: stable threadgroup during attach & subsys methods
	consolidation
Date: Tue,  1 Nov 2011 16:46:23 -0700
Message-ID: <1320191193-8110-1-git-send-email-tj@kernel.org>
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
To: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

NOT FOR THIS MERGE WINDOW.

This patchset is combination of the following two patchsets.

 [1] cgroup: extend threadgroup locking
 [2] cgroup: introduce cgroup_taskset and consolidate subsys methods, take#2

Changes from the last postings are

* 0001-cgroup-add-cgroup_root_mutex.patch replaces mutex ordering
  reversal patch, which Oleg found out to be broken.  Instead, a new
  sub-mutex cgroup_root_mutex is introduced to break circular
  dependency.

* Rebased on top of the current linus/master.

* Other minor changes to reflect comments from reviews.

* Reviewed/Acked-by's added.

This patchset addresses the following two issues.

1. cgroup currently only blocks new threads from joining the target
   threadgroup during migration, and on-going migration could race
   against exec and exit leading to interesting problems - the
   symmetry between various attach methods, task exiting during method
   execution, ->exit() racing against attach methods, migrating task
   switching basic properties during exec and so on.

   This is resolved by extending threadgroup locking such that it
   covers all operations which can alter the threadgroup - fork, exit
   and exec, and update cgroup to take advantage of it.  rwsem read
   ops are added to exit path but exec is excluded by grabbing the
   existing cred_guard_mutex from threadgroup locking helper.

   This makes threadgroup locking complete and resolves cgroup issues
   stemming from the target taskset being unstable.

2. cgroup has grown quite some number of subsys methods.  Some of them
   are overlapping, inconsistent with each other and called under
   different conditions depending on whether they're called for a
   single task or whole process.  Unfortunately, these callbacks are
   complicated and incomplete at the same time.

   * ->attach_task() is called after migration for task attach but
     before for process.

   * Ditto for ->pre_attach().

   * ->can_attach_task() is called for every task in the thread group
     ->but attach_task() skips the ones which don't actually change
     ->cgroups.

   * Task attach becomes noop if the task isn't actually moving.
     Process attach is always performed.

   * ->attach_task() doesn't (or at least aren't supposed to) have
     access to the old cgroup.

   * During cancel, there's no way to access the affected tasks.

   This patchset introduces cgroup_taskset along with some accessors
   and iterator, updates methods to use it, consolidates usages and
   drops superflous methods.

 0001-cgroup-add-cgroup_root_mutex.patch
 0002-threadgroup-rename-signal-threadgroup_fork_lock-to-g.patch
 0003-threadgroup-extend-threadgroup_lock-to-cover-exit-an.patch
 0004-cgroup-always-lock-threadgroup-during-migration.patch
 0005-cgroup-subsys-attach_task-should-be-called-after-mig.patch
 0006-cgroup-improve-old-cgroup-handling-in-cgroup_attach_.patch
 0007-cgroup-introduce-cgroup_taskset-and-use-it-in-subsys.patch
 0008-cgroup-don-t-use-subsys-can_attach_task-or-attach_ta.patch
 0009-cgroup-cpuset-don-t-use-ss-pre_attach.patch
 0010-cgroup-kill-subsys-can_attach_task-pre_attach-and-at.patch

0001-0004 implement stable thread group.

0005-0010 introduce taskset and consolidate subsys callbacks.

This patchset is on top of the current linus/master 839d881074 "Merge
branch 'i2c-for-linus' of ..." and also available in the following git
branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git cgroup-cleanup

If this looks okay, I think it would be best to route this through pm
tree as there are and will be intersecting changes (mostly around
cgroup_freezer).

diffstat follows.

 Documentation/cgroups/cgroups.txt |   51 ++----
 block/blk-cgroup.c                |   45 +++--
 include/linux/cgroup.h            |   31 ++-
 include/linux/init_task.h         |    9 -
 include/linux/sched.h             |   62 +++++--
 kernel/cgroup.c                   |  320 +++++++++++++++++++++++---------------
 kernel/cgroup_freezer.c           |   27 +--
 kernel/cpuset.c                   |  105 +++++-------
 kernel/events/core.c              |   13 -
 kernel/exit.c                     |   17 +-
 kernel/fork.c                     |    8 
 kernel/sched.c                    |   31 ++-
 mm/memcontrol.c                   |   16 -
 security/device_cgroup.c          |    7 
 14 files changed, 430 insertions(+), 312 deletions(-)

Thanks.

--
tejun

[1] http://thread.gmane.org/gmane.linux.kernel/1187853
[2] http://thread.gmane.org/gmane.linux.kernel/1184375
