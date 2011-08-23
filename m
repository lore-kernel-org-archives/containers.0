From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET] cgroup: introduce cgroup_taskset and consolidate subsys
	methods
Date: Wed, 24 Aug 2011 00:19:54 +0200
Message-ID: <1314138000-2049-1-git-send-email-tj__24127.6341992945$1314138154$gmane$org@kernel.org>
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
To: rjw-KKrjLPT3xs0@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

cgroup has grown quite some number of subsys methods.  Some of them
are overlapping, inconsistent with each other and called under
different conditions depending on whether they're called for a single
task or whole process.  Unfortunately, these callbacks are complicated
and incomplete at the same time.

* ->attach_task() is called after migration for task attach but before
  for process.

* Ditto for ->pre_attach().

* ->can_attach_task() is called for every task in the thread group but
  ->attach_task() skips the ones which don't actually change cgroups.

* Task attach becomes noop if the task isn't actually moving.  Process
  attach is always performed.

* ->attach_task() doesn't (or at least aren't supposed to) have access
  to the old cgroup.

* During cancel, there's no way to access the affected tasks.

This patchset introduces cgroup_taskset along with some accessors and
iterator, updates methods to use it, consolidates usages and drops
superflous methods.

It contains the following six patches.

 0001-cgroup-subsys-attach_task-should-be-called-after-mig.patch
 0002-cgroup-improve-old-cgroup-handling-in-cgroup_attach_.patch
 0003-cgroup-introduce-cgroup_taskset-and-use-it-in-subsys.patch
 0004-cgroup-don-t-use-subsys-can_attach_task-or-attach_ta.patch
 0005-cgroup-cpuset-don-t-use-ss-pre_attach.patch
 0006-cgroup-kill-subsys-can_attach_task-pre_attach-and-at.patch

and is based on the current linux-pm/pm-freezer (7b5b95b3f5 "freezer:
remove should_send_signal() and update frozen()"), and available in
the following git tree.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git freezer

I based this on top of pm-freezer because cgroup_freezer changes
conflict (easy to resolve but still) and I'm planning on making
further changes to cgroup_freezer which will depend on both freezer
and cgroup changes.  How should we route these changes?

1. As this patchset would affect other cgroup changes, it makes sense
   to route these through the cgroup branch (BTW, where is it?) and
   propagate things there.  In that case, I'll re-spin the patches on
   top of that tree and send a pull request for the merged branch to
   Rafael.

2. Alternatively, if cgroup isn't expected to have too extensive
   changes in this cycle, we can just funnel all these through
   Rafael's tree.

3. Yet another choice would be applying these on Rafael's tree and
   then pull that into cgroup tree as further changes aren't gonna
   affect cgroup all that much.

What do you guys think?

Thank you.

 Documentation/cgroups/cgroups.txt |   46 +++-----
 block/blk-cgroup.c                |   45 +++++---
 include/linux/cgroup.h            |   31 ++++-
 kernel/cgroup.c                   |  200 ++++++++++++++++++++++++--------------
 kernel/cgroup_freezer.c           |   16 ---
 kernel/cpuset.c                   |  105 +++++++++----------
 kernel/events/core.c              |   13 +-
 kernel/sched.c                    |   31 +++--
 mm/memcontrol.c                   |   16 +--
 security/device_cgroup.c          |    7 -
 10 files changed, 289 insertions(+), 221 deletions(-)

--
tejun
