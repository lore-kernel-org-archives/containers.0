From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup changes for v3.10-rc1
Date: Mon, 29 Apr 2013 17:52:14 -0700
Message-ID: <20130430005214.GK2395__30370.8071857274$1367283153$gmane$org@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Linus.

* Fixes and a lot of cleanups.  Locking cleanup is finally complete.
  cgroup_mutex is no longer exposed to individual controlelrs which
  used to cause nasty deadlock issues.  Li fixed and cleaned up quite
  a bit including long standing ones like racy cgroup_path().

* device cgroup now supports proper hierarchy thanks to Aristeu.

* perf_event cgroup now supports proper hierarchy.

* A new mount option "__DEVEL__sane_behavior" is added.  As indicated
  by the name, this option is to be used for development only at this
  point and generates a warning message when used.  Unfortunately,
  cgroup interface currently has too many brekages and inconsistencies
  to implement a consistent and unified hierarchy on top.  The new
  flag is used to collect the behavior changes which are necessary to
  implement consistent unified hierarchy.  It's likely that this flag
  won't be used verbatim when it becomes ready but will be enabled
  implicitly along with unified hierarchy.

  The option currently disables some of broken behaviors in cgroup
  core and also .use_hierarchy switch in memcg (will be routed through
  -mm), which can be used to make very unusual hierarchy where nesting
  is partially honored.  It will also be used to implement hierarchy
  support for blk-throttle which would be impossible otherwise without
  introducing a full separate set of control knobs.

  This is essentially versioning of interface which isn't very nice
  but at this point I can't see any other options which would allow
  keeping the interface the same while moving towards hierarchy
  behavior which is at least somewhat sane.  The planned unified
  hierarchy is likely to require some level of adaptation from
  userland anyway, so I think it'd be best to take the chance and
  update the interface such that it's supportable in the long term.

  Maintaining the existing interface does complicate cgroup core but
  shouldn't put too much strain on individual controllers and I think
  it'd be manageable for the foreseeable future.  Maybe we'll be able
  to drop it in a decade.

This pull request creates the following trivial conflict in
include/linux/res_counter.h

  <<<<<<< HEAD
  #include <linux/cgroup.h>
  #include <linux/errno.h>
  =======
  #include <linux/spinlock.h>
  >>>>>>> 2a0010af17b1739ef8ea8cf02647a127241ee674

The conflict is between the following two commits.

* ebf47beb6 ("include/linux/res_counter.h needs errno.h") added
  errno.h inclusion.

* 9259826cc ("res_counter: remove include of cgroup.h from
  res_counter.h") removed cgroup.h inclusion.

And can be resolved like the following - errno.h added and cgroup.h
removed.  Just in case, test merge is available in the
test-merge-v3.10 branch.

  #include <linux/spinlock.h>
  #include <linux/errno.h>

Also, ff794dea52ea ("cpuset: remove include of cgroup.h from
cpuset.h") caused build failure on ppc64 because
arch/powerpc/mm/numa.c was getting slab.h through cpuset.h.  Stephen
noticed this in -next and provided the following patch.  I think
Benjamin is gonna pick this up before pushing the ppc tree but in case
it breaks for you the patch is at

  http://marc.info/?l=linux-next&m=136720831327947&w=2

Thanks.

The following changes since commit 6dbe51c251a327e012439c4772097a13df43c5b8:

  Linux 3.9-rc1 (2013-03-03 15:11:05 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.10

for you to fetch changes up to 2a0010af17b1739ef8ea8cf02647a127241ee674:

  cpuset: fix compile warning when CONFIG_SMP=n (2013-04-27 19:55:04 -0700)

----------------------------------------------------------------
Aristeu Rozanski (4):
      devcg: expand may_access() logic
      devcg: prepare may_access() for hierarchy support
      devcg: use css_online and css_offline
      devcg: propagate local changes down the hierarchy

Kevin Wilson (1):
      cgroup: remove unused parameter in cgroup_task_migrate().

Li Zefan (22):
      cgroup: fix cgroup_path() vs rename() race
      cpuset: use cgroup_name() in cpuset_print_task_mems_allowed()
      cgroup: no need to check css refs for release notification
      cgroup: avoid accessing modular cgroup subsys structure without locking
      res_counter: remove include of cgroup.h from res_counter.h
      cpuset: remove include of cgroup.h from cpuset.h
      cpuset: fix RCU lockdep splat in cpuset_print_task_mems_allowed()
      cgroup: remove cgroup_is_descendant()
      cgroup: remove unused variables in cgroup_destroy_locked()
      cgroup: hold cgroup_mutex before calling css_offline()
      cgroup: don't bother to resize pid array
      cgroup: remove useless code in cgroup_write_event_control()
      cgroup: fix an off-by-one bug which may trigger BUG_ON()
      cgroup: consolidate cgroup_attach_task() and cgroup_attach_proc()
      cgroup: make sure parent won't be destroyed before its children
      cgroup: implement cgroup_is_descendant()
      cgroup: remove cgrp->top_cgroup
      cgroup: fix broken file xattrs
      cgroup: fix use-after-free when umounting cgroupfs
      cgroup: restore the call to eventfd->poll()
      cpuset: fix cpu hotplug vs rebuild_sched_domains() race
      cpuset: fix compile warning when CONFIG_SMP=n

Li Zhong (1):
      cpuset: use rebuild_sched_domains() in cpuset_hotplug_workfn()

Michal Hocko (1):
      memcg: fix memcg_cache_name() to use cgroup_name()

Rami Rosen (3):
      cgroups: Documentation/cgroup/cgroup.txt - a trivial fix.
      cgroup: remove bind() method from cgroup_subsys.
      devcg: remove parent_cgroup.

Tejun Heo (13):
      cgroup, cpuset: replace move_member_tasks_to_cpuset() with cgroup_transfer_tasks()
      cgroup: relocate cgroup_lock_live_group() and cgroup_attach_task_all()
      cgroup: unexport locking interface and cgroup_attach_task()
      cgroup: kill cgroup_[un]lock()
      cgroup: remove cgroup_lock_is_held()
      devcg: remove broken_hierarchy tag
      perf: make perf_event cgroup hierarchical
      Revert "cgroup: remove bind() method from cgroup_subsys."
      cgroup: make cgroup_path() not print double slashes
      cgroup: convert cgroupfs_root flag bits to masks and add CGRP_ prefix
      move cgroupfs_root to include/linux/cgroup.h
      cgroup: introduce sane_behavior mount option
      memcg: force use_hierarchy if sane_behavior

 Documentation/cgroups/cgroups.txt |   3 +-
 Documentation/cgroups/devices.txt |  70 +++-
 block/blk-cgroup.h                |   2 -
 include/linux/cgroup.h            | 170 ++++++++-
 include/linux/cpuset.h            |   1 -
 include/linux/res_counter.h       |   2 +-
 kernel/cgroup.c                   | 724 ++++++++++++++++----------------------
 kernel/cpuset.c                   | 115 ++----
 kernel/events/core.c              |  24 +-
 mm/memcontrol.c                   |  80 +++--
 security/device_cgroup.c          | 267 +++++++++++---
 11 files changed, 825 insertions(+), 633 deletions(-)

--
tejun
