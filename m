From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET cgroup/for-3.14] cgroup: drop module support and
	cgroup_root_mutex
Date: Fri, 17 Jan 2014 13:11:51 -0500
Message-ID: <1389982317-22225-1-git-send-email-tj@kernel.org>
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

There are only two controllers which make use of the module support -
net_cls and net_prio, both of which, non-coincidentally, aren't actual
resource controllers.  It's highly unlikely that the actual resource
controlling controllers are gonna be made modular and we aren't gonna
add more non-resource controllers either, so the value of module
support is strictly restricted to the two existing controllers.

Both controllers are fairly simple while module support in cgroup core
adds quite a bit of complexity.  Building those two controllers as
module only saves about half-page in vmlinux, which really can't
justify the additional complexity and (minute but existing) runtime
overhead.

This patchset makes net_cls and net_prio config options bool so that
they can't be built as modules and drop module support from cgroup
core, which in turn facilitates further simplification leading to
removal of cgroup_root_mutex by allowing iterating subsystems outside
the mutexes.

This patchset contains the following six patches.

 0001-cgroup-make-CONFIG_NET_CLS_CGROUP-and-CONFIG_NETPRIO.patch
 0002-cgroup-drop-module-support.patch
 0003-cgroup-clean-up-cgroup_subsys-names-and-initializati.patch
 0004-cgroup-rename-cgroup_subsys-subsys_id-to-id.patch
 0005-cgroup-update-locking-in-cgroup_show_options.patch
 0006-cgroup-remove-cgroup_root_mutex.patch

0001-0002 drop cgroup module support.

0003-0004 are cleanups.

0005-0006 remove cgroup_root_mutex.

The patchset is also available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-simplify

diffstat follows.  Thanks.

 block/blk-cgroup.c             |    9
 block/blk-cgroup.h             |    2
 fs/bio.c                       |    2
 include/linux/cgroup.h         |   38 ---
 include/linux/cgroup_subsys.h  |   30 +--
 include/linux/hugetlb_cgroup.h |    2
 include/linux/memcontrol.h     |    2
 include/net/cls_cgroup.h       |    4
 include/net/netprio_cgroup.h   |    4
 kernel/cgroup.c                |  392 ++++++-----------------------------------
 kernel/cgroup_freezer.c        |    8
 kernel/cpuset.c                |   10 -
 kernel/events/core.c           |    8
 kernel/sched/core.c            |    6
 kernel/sched/cpuacct.c         |    6
 mm/hugetlb_cgroup.c            |    9
 mm/memcontrol.c                |   22 +-
 net/Kconfig                    |    2
 net/core/netprio_cgroup.c      |   37 ---
 net/ipv4/tcp_memcontrol.c      |    2
 net/sched/Kconfig              |    2
 net/sched/cls_cgroup.c         |   30 ---
 security/device_cgroup.c       |    8
 23 files changed, 132 insertions(+), 503 deletions(-)

--
tejun
