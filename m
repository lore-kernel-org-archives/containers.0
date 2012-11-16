From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET cgroup/for-3.8] netprio_cgroup: implement hierarchy support
Date: Fri, 16 Nov 2012 11:20:16 -0800
Message-ID: <1353093624-22608-1-git-send-email-tj__6939.1967998401$1353093649$gmane$org@kernel.org>
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
To: daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, srivatsa.bhat-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, guys.

This patchset implements hierarchy support for netprio_cgroup.
netprio_cgroup along with netcls_cgroup is a rather weird in that it
really isn't about resource control.  It just hitches on cgroup as a
convenient mechanism to do stuff to groups of tasks.  The hierarchy
support reflects such nature.  There's no limit being imposed from
ancestors.  It simply propagates configuration downwards until there's
a node with its own config.  IOW, any given cgroup inherits priorities
from its parent for all netdevs which it doesn't have its own config
for.

As a parent isn't affected by child inheriting its config, the
hierarchy implementation is pretty simple.  It's enough to inherit
config from ->css_online() and propagate new config downwards from
write_priomap().  As each node needs to know which config is its local
one and which is inherited, an extra config array is added -
netprio_map->aux[].  It's a separate array to avoid disturbing spatial
locality of ->priomap[].  While it currently contains single one-bit
flag, I still made it a struct so that adding more configuration
(e.g. max_prio) is easy.

Note that this does change userland-visible behavior.  Now, nesting is
allowed and cgroups at the first level inherit priorities from the
root cgroup.  I can't think of any better way than just biting the
bullet here.  :(

 0001-cgroup-add-cgroup-id.patch
 0002-netprio-simplify-write_priomap.patch
 0003-netprio_cgroup-shorten-variable-names-in-extend_netd.patch
 0004-netprio_cgroup-reimplement-priomap-expansion.patch
 0005-netprio_cgroup-use-cgroup-id-instead-of-cgroup_netpr.patch
 0006-netprio_cgroup-implement-netprio-_set-_prio-helpers.patch
 0007-netprio_cgroup-keep-track-of-whether-prio-is-set-or-.patch
 0008-netprio_cgroup-implement-hierarchy-support.patch

0001 adds cgroup->id.  This will eventually replace css_id.

0002-0006 are prep patches.

0007 implements is_local flag which tracks whether a cgroup has its
own config or should inherit from its parent.

0008 implements hierarchy support.

This patchset is on top of

cgroup/for-3.8 ef9fe980c6 ("cgroup_freezer: implement proper hierarchy support")
+ [1] "[PATCHSET cgroup/for-3.8] cgroup: allow ->post_create() to fail"
+ [2] "[PATCH 1/2] cgroup: s/CGRP_CLONE_CHILDREN/CGRP_CPUSET_CLONE_CHILDREN/"
      "[PATCH 2/2] cgroup, cpuset: remove cgroup_subsys->post_clone()"

and available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-netprio_cgroup-hierarchy

diffstat follows.

 Documentation/cgroups/net_prio.txt |   21 +-
 include/linux/cgroup.h             |    2
 include/net/netprio_cgroup.h       |   21 +-
 kernel/cgroup.c                    |   15 +
 net/core/netprio_cgroup.c          |  376 +++++++++++++++++++++++--------------
 5 files changed, 284 insertions(+), 151 deletions(-)

Thanks.

--
tejun

[1] http://thread.gmane.org/gmane.linux.kernel.cgroups/5047
[2] http://thread.gmane.org/gmane.linux.kernel/1393151
