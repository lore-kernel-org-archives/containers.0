From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET cgroup/for-3.8] netcls_cgroup: implement hierarchy support
Date: Fri, 16 Nov 2012 19:30:59 -0800
Message-ID: <1353123062-23193-1-git-send-email-tj__4526.42137320272$1353123088$gmane$org@kernel.org>
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
To: daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, guys.

This patchset implements proper hierarchy support for netcls_cgroup.
Pretty simliar to the netprio one[3].  Simpler as each cgroup has
single config value instead of array of them.

This patchset contains the following three patches.

 0001-netcls_cgroup-introduce-netcls_mutex.patch
 0002-netcls_cgroup-introduce-cgroup_cls_state-is_local.patch
 0003-netcls_cgroup-implement-proper-hierarchy-support.patch

This patchset is on top of

cgroup/for-3.8 ef9fe980c6 ("cgroup_freezer: implement proper hierarchy support")
+ [1] "[PATCHSET cgroup/for-3.8] cgroup: allow ->post_create() to fail"
+ [2] "[PATCH 1/2] cgroup: s/CGRP_CLONE_CHILDREN/CGRP_CPUSET_CLONE_CHILDREN/"
      "[PATCH 2/2] cgroup, cpuset: remove cgroup_subsys->post_clone()"
+ [3] "[PATCHSET cgroup/for-3.8] netprio_cgroup: implement hierarchy support"

and available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-netcls_cgroup-hierarchy

diffstat follows.

 include/net/cls_cgroup.h |    1
 net/sched/cls_cgroup.c   |  102 ++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 88 insertions(+), 15 deletions(-)

Thanks.

--
tejun

[1] http://thread.gmane.org/gmane.linux.kernel.cgroups/5047
[2] http://thread.gmane.org/gmane.linux.kernel/1393151
[3] https://lkml.org/lkml/2012/11/16/514
