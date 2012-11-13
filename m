From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET cgroup/for-3.8] cgroup: allow ->post_create() to fail
Date: Mon, 12 Nov 2012 19:01:27 -0800
Message-ID: <1352775704-9023-1-git-send-email-tj__20362.047563731$1352775727$gmane$org@kernel.org>
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
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

This became a rather large patchset mostly because there are a lot of
weirdities and subtle breakages in create/destroy/load/unload paths.
The goal of the patchset is allowing ->post_create() to fail and
renaming ->create/post_create/pre_destroy/destroy() to
->css_alloc/css_online/css_offline/css_free().

This patchset contains the following seventeen patches.

 0001-cgroup-remove-incorrect-dget-dput-pair-in-cgroup_cre.patch
 0002-cgroup-initialize-cgrp-allcg_node-in-init_cgroup_hou.patch
 0003-cgroup-open-code-cgroup_create_dir.patch
 0004-cgroup-create-directory-before-linking-while-creatin.patch
 0005-cgroup-cgroup-dentry-isn-t-a-RCU-pointer.patch
 0006-cgroup-remove-duplicate-RCU-free-on-struct-cgroup.patch
 0007-cgroup-make-CSS_-flags-bit-masks-instead-of-bit-posi.patch
 0008-cgroup-trivial-cleanup-for-cgroup_init-load_subsys.patch
 0009-cgroup-lock-cgroup_mutex-in-cgroup_init_subsys.patch
 0010-cgroup-fix-harmless-bugs-in-cgroup_load_subsys-fail-.patch
 0011-cgroup-separate-out-cgroup_destroy_locked.patch
 0012-cgroup-introduce-CSS_ONLINE-flag-and-on-offline_css-.patch
 0013-cgroup-simplify-cgroup_load_subsys-failure-path.patch
 0014-cgroup-use-mutex_trylock-when-grabbing-i_mutex-of-a-.patch
 0015-cgroup-update-cgroup_create-failure-path.patch
 0016-cgroup-allow-post_create-to-fail.patch
 0017-cgroup-rename-create-post_create-pre_destroy-destroy.patch

0001 is a bugfix.  Tagged for -stable.  I don't I'll push it through
for-3.7-fixes tho.  This has been broken forever and nobody reported
anything yet.

0002-0011 are various fixes and cleanups to prepare for the following
changes.  Each should be self-explanatory.

0012-0015 are preparation patches more directly related to allowing
failure of ->post_create().

0016 allows ->post_create() to fail.

0017 renames ops and updates documentation.

This patchst is on top of cgroup/for-3.8 and available on the
following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-online-may-fail

and contains the following changes.

 Documentation/cgroups/cgroups.txt |   49 +++---
 block/blk-cgroup.c                |   14 -
 include/linux/cgroup.h            |   47 +++---
 kernel/cgroup.c                   |  288 +++++++++++++++++++++-----------------
 kernel/cgroup_freezer.c           |   22 +-
 kernel/cpuset.c                   |   10 -
 kernel/events/core.c              |    8 -
 kernel/sched/core.c               |   16 +-
 mm/hugetlb_cgroup.c               |   14 -
 mm/memcontrol.c                   |   12 -
 net/core/netprio_cgroup.c         |    8 -
 net/sched/cls_cgroup.c            |    8 -
 security/device_cgroup.c          |    8 -
 13 files changed, 278 insertions(+), 226 deletions(-)

Thanks.

--
tejun
