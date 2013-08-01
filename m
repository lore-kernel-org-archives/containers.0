From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET cgroup/for-3.12] cgroup: use cgroup_subsys_state as the
	primary subsystem interface handle
Date: Thu,  1 Aug 2013 17:49:38 -0400
Message-ID: <1375393801-4817-1-git-send-email-tj__34831.8133074374$1375393819$gmane$org@kernel.org>
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

Currently, struct cgroup * is used as the main interface handle
between cgroup core and its subsystems, which works but is a bit
clunky because subsystems usually care much more about css's
(cgroup_subsys_state) a lot more than cgroups, which is natural as a
css is the intersection between a cgroup and a subsystem.

In addition to being a bit clunky, dealing with cgroups directly pose
a bit of trouble for the planned unified hierarchy support on two
fronts.  First, most iterations become subsystem dependent as task
membership is affected by which subtree has the specific subsystem
enabled and thus require specifying which subsystem the iteration is
for, which is automatically achieved if the interfaces deal with css's
instead of cgroups.

Second, as css's may be created, attached, detached and destroyed
dynamically multiple times across the lifetime of a given cgroup as
they're enabled and disabled, which makes cgroup -> css mapping much
more difficult to synchronize.  Giving out cgroup to subsystems and
then requiring them to take the extra steps to deal with their css's
coming and going dynamically is a lot more fragile than cgroup core
proper handling it internally and giving out the resulting css's to
subsystems.

So, this patchset converts all cgroup subsystem APIs to deal with
css's instead of cgroups.  The patchset is fairly large but most of
the conversions, while being tedious, aren't complex.  At the end of
series, subsystems no longer make cgroup -> css mapping themselves and
cgroup_css() - formerly cgroup_subsys_state() - is made internal to
cgroup core proper.

This is a rather large update to the interface and likely to play as a
barrier when porting commits, which is inconvenient but also provides
an opportunity to clean up the API where we can as doing so won't
significantly raise the level of inconvenience.  As such, this
patchset contains some API cleanups and I'll probably follow up with
further API updates that I've been meaning to do and, if you have some
good idea to clean up cgroup internal API, this probably is a good
time to submit it.

This patchset contains the following 23 patches.

 0001-cgroup-s-cgroup_subsys_state-cgroup_css-s-task_subsy.patch
 0002-cpuset-drop-const-qualifiers-from-struct-cpuset-inst.patch
 0003-netprio_cgroup-pass-around-css-instead-of-cgroup-and.patch
 0004-hugetlb_cgroup-pass-around-hugetlb_cgroup-instead-of.patch
 0005-cgroup-add-subsystem-pointer-to-cgroup_subsys_state.patch
 0006-cgroup-add-update-accessors-which-obtain-subsys-spec.patch
 0007-cgroup-add-css_parent.patch
 0008-cgroup-pass-around-cgroup_subsys_state-instead-of-cg.patch
 0009-cgroup-add-subsys-backlink-pointer-to-cftype.patch
 0010-cgroup-pin-cgroup_subsys_state-when-opening-a-cgroup.patch
 0011-cgroup-add-cgroup-dummy_css.patch
 0012-cgroup-pass-around-cgroup_subsys_state-instead-of-cg.patch
 0013-cgroup-convert-cgroup_next_sibling-to-cgroup_next_ch.patch
 0014-cgroup-always-use-cgroup_next_child-to-walk-the-chil.patch
 0015-cgroup-make-hierarchy-iterators-deal-with-cgroup_sub.patch
 0016-cgroup-relocate-cgroup_advance_iter.patch
 0017-cgroup-rename-cgroup_iter-to-cgroup_task_iter.patch
 0018-cgroup-make-cgroup_task_iter-remember-the-cgroup-bei.patch
 0019-cgroup-remove-struct-cgroup_scanner.patch
 0020-cgroup-make-task-iterators-deal-with-cgroup_subsys_s.patch
 0021-cgroup-make-cftype-un-register_event-deal-with-cgrou.patch
 0022-cgroup-make-cgroup_taskset-deal-with-cgroup_subsys_s.patch
 0023-cgroup-unexport-cgroup_css.patch

0001-0007 prepare for css-based interface.  Individual subsystems are
updated so that they're easier to convert and css_parent() is added so
that upward travelsal can be done without going through cgroup.

0008 updates all subsystem methods.

0009-0012 update file operations.

0013-0015 update hierarchy iterators.

0016-0020 update task iterators.

0021 updates events.

0022 updates task_set handling.

0023 unexports cgroup_css().

This patchset is available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cssfy

diffstat follows.

 block/blk-cgroup.c           |   41 +-
 block/blk-cgroup.h           |   34 -
 block/blk-throttle.c         |   40 +-
 block/cfq-iosched.c          |   90 ++--
 fs/bio.c                     |    2
 include/linux/cgroup.h       |  268 +++++++-------
 include/linux/memcontrol.h   |    2
 include/linux/vmpressure.h   |    6
 include/net/cls_cgroup.h     |    4
 include/net/netprio_cgroup.h |    8
 kernel/cgroup.c              |  798 ++++++++++++++++++++++++-------------------
 kernel/cgroup_freezer.c      |  128 +++---
 kernel/cpuset.c              |  265 ++++++--------
 kernel/events/core.c         |   22 -
 kernel/sched/core.c          |  113 +++---
 kernel/sched/cpuacct.c       |   51 +-
 kernel/sched/sched.h         |    6
 mm/hugetlb_cgroup.c          |   69 +--
 mm/memcontrol.c              |  216 +++++------
 mm/vmpressure.c              |   25 -
 net/core/netprio_cgroup.c    |   72 +--
 net/ipv4/tcp_memcontrol.c    |   12
 net/sched/cls_cgroup.c       |   39 +-
 security/device_cgroup.c     |   63 +--
 24 files changed, 1210 insertions(+), 1164 deletions(-)

Thanks.

--
tejun
