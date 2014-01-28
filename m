From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET v2 cgroup/for-3.15] cgroup: drop module support and
	cgroup_root_mutex
Date: Tue, 28 Jan 2014 18:43:55 -0500
Message-ID: <1390952641-15950-1-git-send-email-tj@kernel.org>
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
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

This is the second take.  Changes from the last take[L] are

* Updated to reflect changes in fe1217c4f3f7 ("net: net_cls: move
  cgroupfs classid handling into core").

* Rebased on top of the current linus#master + some cgroup fix
  patches.

There's only one controller which makes use of the module support -
net_prio, which, non-coincidentally, isn't an actual resource
controller.  It's highly unlikely that the actual resource controlling
controllers are gonna be made modular and we aren't gonna add more
non-resource controllers either, so the value of module support is
strictly restricted to the particular controller.

The controller is fairly simple while module support in cgroup core
adds quite a bit of complexity.  Building the one controller as module
only saves less than half-page in vmlinux, which really can't justify
the additional complexity and (minute but existing) runtime overhead.

This patchset makes net_prio config options bool so that it can't be
built as modules and drops module support from cgroup core, which in
turn facilitates further simplification leading to removal of
cgroup_root_mutex by allowing iterating subsystems outside the
mutexes.

This patchset contains the following six patches.

 0001-cgroup-make-CONFIG_CGROUP_NET_PRIO-bool-and-drop-unn.patch
 0002-cgroup-drop-module-support.patch
 0003-cgroup-clean-up-cgroup_subsys-names-and-initializati.patch
 0004-cgroup-rename-cgroup_subsys-subsys_id-to-id.patch
 0005-cgroup-update-locking-in-cgroup_show_options.patch
 0006-cgroup-remove-cgroup_root_mutex.patch

0001-0002 drop cgroup module support.

0003-0004 are cleanups.

0005-0006 remove cgroup_root_mutex.

The patchset is on top of

  linus#master 54c0a4b46150 ("Merge branch 'akpm' (incoming from Andrew)")
+ [1] [PATCHSET cgroup/for-3.14-fixes] cgroup: four misc fixes
+ [2] [PATCH] arm, pm, vmpressure: add missing slab.h includes

and also available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-simplify

diffstat follows.  Thanks.

 block/blk-cgroup.c             |    9
 block/blk-cgroup.h             |    2
 fs/bio.c                       |    2
 include/linux/cgroup.h         |   38 ---
 include/linux/cgroup_subsys.h  |   30 +--
 include/linux/hugetlb_cgroup.h |    2
 include/linux/memcontrol.h     |    2
 include/net/cls_cgroup.h       |    2
 include/net/netprio_cgroup.h   |   17 -
 kernel/cgroup.c                |  394 ++++++-----------------------------------
 kernel/cgroup_freezer.c        |    8
 kernel/cpuset.c                |   10 -
 kernel/events/core.c           |    8
 kernel/sched/core.c            |    6
 kernel/sched/cpuacct.c         |    6
 mm/hugetlb_cgroup.c            |    9
 mm/memcontrol.c                |   22 +-
 net/Kconfig                    |    2
 net/core/netclassid_cgroup.c   |   13 -
 net/core/netprio_cgroup.c      |   37 ---
 net/ipv4/tcp_memcontrol.c      |    2
 security/device_cgroup.c       |    8
 22 files changed, 128 insertions(+), 501 deletions(-)

Thanks.

--
tejun

[L] http://lkml.kernel.org/g/<1389982317-22225-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
[1] http://lkml.kernel.org/g/<1390923125-4369-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
[2] http://lkml.kernel.org/g/<20140128221922.GC16060-9pTldWuhBndy/B6EtB590w@public.gmane.org>
