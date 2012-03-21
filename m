From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET] cgroup: cftype based file interface, take #2
Date: Wed, 21 Mar 2012 15:17:33 -0700
Message-ID: <1332368265-21586-1-git-send-email-tj__8634.69415712661$1332368282$gmane$org@kernel.org>
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
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

This is the second take at improving cgroup file addition/removal
interface.  Changes from the last take[L] are,

* CGROUP_SUBSYS_CFTYPES[_COND]() dropped and
  cgroup_subsys->base_cftypes is added instead.  This works better for
  subsystems implemented as module.  tcp_memcontrol now uses an
  explicit __initcall() to register its cftypes.

* 0005-cgroup-relocate-cftype-and-cgroup_subsys-definitions.patch
  added as cleanup.

* 0007-memcg-always-create-memsw-files-if-CONFIG_CGROUP_MEM.patch
  added so that memsw files are always created if enabled in config as
  suggested by KAMEZAWA.

This patch replaces cgroup file interface with cftype based one which
allows dynamic additions and removals of cftype arrays whether the
target subsystem is attached or not.  This can be used to make subsys
rebinding via remount work properly but I intentionally avoided doing
that at the moment.

This makes cgroup population simpler for controllers and will be used
to allow controllers to be more dynamic.  e.g. blkio subsys has
sub-policies which may come and go while blkio subsys is attached and
it currently uses fixed set of files which stays blank if not in use.
This will also be useful for implementing unified hierarchy.

This patchset contains the following patches.

 0001-cgroup-move-cgroup_clear_directory-call-out-of-cgrou.patch
 0002-cgroup-build-list-of-all-cgroups-under-a-given-cgrou.patch
 0003-cgroup-implement-cgroup_add_cftypes-and-friends.patch
 0004-cgroup-merge-cft_release_agent-cftype-array-into-the.patch
 0005-cgroup-relocate-cftype-and-cgroup_subsys-definitions.patch
 0006-cgroup-convert-all-non-memcg-controllers-to-the-new-.patch
 0007-memcg-always-create-memsw-files-if-CONFIG_CGROUP_MEM.patch
 0008-cgroup-convert-memcg-controller-to-the-new-cftype-in.patch
 0009-cgroup-remove-cgroup_add_file-s.patch
 0010-cgroup-relocate-__d_cgrp-and-__d_cft.patch
 0011-cgroup-introduce-struct-cfent.patch
 0012-cgroup-implement-cgroup_rm_cftypes.patch

and is on top of

  cgroup/for-3.4 3ce3230a0cff484e5130153f244d4fb8a56b3a8b
+ [1] cgroup: deprecate remount option changes mount option

and is also available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git cgroup-cftype

Glauber, I think the cftypes registration for tcp_memcontrol is fine
as is in this patchset and we just need to move the init to the tail
of ->create().  Let's worry about memcg for module-loadable protocols
whey they are added.  Can you please send a patch to move init to
->create()?

If nobody objects && after Li comes back and acks the changes, I'll
route these through cgroup/for-3.5.

diffstat follows.

 block/blk-cgroup.c        |   45 ++---
 include/linux/cgroup.h    |   51 ++++--
 kernel/cgroup.c           |  359 +++++++++++++++++++++++++++++++++++-----------
 kernel/cgroup_freezer.c   |   11 -
 kernel/cpuset.c           |   31 +--
 kernel/sched/core.c       |   16 --
 mm/memcontrol.c           |   77 ++++-----
 net/core/netprio_cgroup.c |   30 +--
 net/ipv4/tcp_memcontrol.c |   71 ++++-----
 net/sched/cls_cgroup.c    |   31 +--
 security/device_cgroup.c  |   10 -
 11 files changed, 437 insertions(+), 295 deletions(-)

Thanks.

--
tejun

[L] http://thread.gmane.org/gmane.linux.kernel.containers/22623
[1] http://thread.gmane.org/gmane.linux.kernel.cgroups/1192/focus=22611
