From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET cgroup/for-3.14] cgroup: consolidate file handling
Date: Wed, 27 Nov 2013 18:42:27 -0500
Message-ID: <1385595759-17656-1-git-send-email-tj__26184.8603062846$1385595776$gmane$org@kernel.org>
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
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

cgroup is scheduled to be converted to use kernfs, which is currently
in the process of being separated out of sysfs, so that, among other
things, cgroup core locking can be decoupled from vfs layer.  This
patchset cleans up and conslidates cgroup file handling to facilitate
such conversion.

There currently are a couple different rw paths including the ones
which don't impose any structure.  All existing users and expected
reasonable use cases can be served with standard seq_file interface
and buffered writes, which is what's provided by kernfs.

This patchset updates cgroup file handling so that the interface and
usages are more concise and there is single path for read and single
path for write, both of which closely map to the interface kernfs
provides.

This series ends up adding some amount of code which will be replaced
by kernfs but, overall, things get more streamlined and LOC is
reduced.

The following 12 patches are included in the series.

 0001-cgroup-sched-convert-away-from-cftype-read_map.patch
 0002-cpuset-convert-away-from-cftype-read.patch
 0003-memcg-convert-away-from-cftype-read-and-read_map.patch
 0004-netprio_cgroup-convert-away-from-cftype-read_map.patch
 0005-hugetlb_cgroup-convert-away-from-cftype-read.patch
 0006-cgroup-remove-cftype-read-read_map-and-write.patch
 0007-cgroup-unify-cgroup_write_X64-and-cgroup_write_strin.patch
 0008-cgroup-unify-read-path-so-that-seq_file-is-always-us.patch
 0009-cgroup-generalize-cgroup_pidlist_open_file.patch
 0010-cgroup-attach-cgroup_open_file-to-all-cgroup-files.patch
 0011-cgroup-replace-cftype-read_seq_string-with-cftype-se.patch
 0012-cgroup-unify-pidlist-and-other-file-handling.patch

While this series touches a lot of controllers, all updates to the
controllers are mostly mechnical.  I think it'd be best if the series
can be routed through cgroup/for-3.14 branch.

This patchset is on top of

  cgroup/for-3.14 c729b11edf74 ("cgroup: Merge branch 'for-3.13-fixes' into for-3.14")
+ [1] [PATCHSET] cgroup: restructure pidlist handling

and available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-consolidate-file-handling

diffstat follows.

 block/blk-throttle.c      |   35 +---
 block/cfq-iosched.c       |  131 +++++++--------
 include/linux/cgroup.h    |   71 ++++----
 kernel/cgroup.c           |  380 ++++++++++++++++------------------------------
 kernel/cgroup_freezer.c   |    7
 kernel/cpuset.c           |   71 ++------
 kernel/sched/core.c       |   13 -
 kernel/sched/cpuacct.c    |   18 --
 mm/hugetlb_cgroup.c       |   22 --
 mm/memcontrol.c           |   73 +++-----
 net/core/netprio_cgroup.c |    8
 security/device_cgroup.c  |    7
 12 files changed, 339 insertions(+), 497 deletions(-)

Thanks.

--
tejun

[1] http://lkml.kernel.org/g/1385331096-7918-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
