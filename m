From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET] cgroup: cftype based file interface
Date: Fri, 16 Mar 2012 16:35:53 -0700
Message-ID: <1331940963-15756-1-git-send-email-tj@kernel.org>
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

Hello, guys.

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
 0005-cgroup-convert-all-non-memcg-controllers-to-the-new-.patch
 0006-cgroup-convert-memcg-controller-to-the-new-cftype-in.patch
 0007-cgroup-remove-cgroup_add_file-s.patch
 0008-cgroup-relocate-__d_cgrp-and-__d_cft.patch
 0009-cgroup-introduce-struct-cfent.patch
 0010-cgroup-implement-cgroup_rm_cftypes.patch

and is on top of

  cgroup/for-3.4 3ce3230a0cff484e5130153f244d4fb8a56b3a8b
+ [1] cgroup: deprecate remount option changes mount option

and is also available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git cgroup-cftype

Glauber, can you please try to move net kmem stuff out of
->populate().  If ->create() doesn't work for whatever reason, can you
please explain it to me so that we can find a proper solution?

diffstat follows.

 block/blk-cgroup.c        |   10 -
 include/linux/cgroup.h    |   56 +++++--
 kernel/cgroup.c           |  351 ++++++++++++++++++++++++++++++++++------------
 kernel/cgroup_freezer.c   |   11 -
 kernel/cpuset.c           |   31 +---
 kernel/sched/core.c       |   16 --
 mm/memcontrol.c           |   31 ----
 net/core/netprio_cgroup.c |    9 -
 net/ipv4/tcp_memcontrol.c |    8 -
 net/sched/cls_cgroup.c    |    9 -
 security/device_cgroup.c  |   10 -
 11 files changed, 341 insertions(+), 201 deletions(-)

Thanks.

--
tejun

[1] http://thread.gmane.org/gmane.linux.kernel.cgroups/1192/focus=22611
