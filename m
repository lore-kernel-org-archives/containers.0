From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET cgroup/for-3.8] cgroup_freezer: implement proper hierarchy
	support
Date: Sat,  3 Nov 2012 01:38:26 -0700
Message-ID: <1351931915-1701-1-git-send-email-tj@kernel.org>
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
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

This patchset implement proper hierarchy support for cgroup_freezer as
discussed in "[RFC] cgroup TODOs"[1].

The patchset first implements generic cgroup iteration macros -
cgroup_for_each_children(), cgroup_for_each_descendant_{pre|post}().
Combined with the newly introduced ->post_create() callback, this
allows controllers to implement reliable iteration over descendants
without messing with cgroup internal locking.  Controllers can perform
reliable walking using simple hierarchy-wide locking or finer-grained
parent-children locking.

Using the iteration macros and ->post_create(), cgroup_freezer is
updated to propagate state updates to and collect FROZEN completions
from the descendants.  This removes .broken_hierarchy marking from
cgroup_freezer.

cgroup_freezer hierarchy support is implemented using finer-grained
locking not necessarily because it's necessary but more because I
wanted an example controller doing that.

This patchset contains the following nine patches.

 0001-cgroup-add-cgroup_subsys-post_create.patch
 0002-cgroup-Use-rculist-ops-for-cgroup-children.patch
 0003-cgroup-implement-generic-child-descendant-walk-macro.patch
 0004-cgroup_freezer-trivial-cleanups.patch
 0005-cgroup_freezer-prepare-freezer_change_state-for-full.patch
 0006-cgroup_freezer-make-freezer-state-mask-of-flags.patch
 0007-cgroup_freezer-introduce-CGROUP_FREEZING_-SELF-PAREN.patch
 0008-cgroup_freezer-add-post_create-and-pre_destroy-and-t.patch
 0009-cgroup_freezer-implement-proper-hierarchy-support.patch

0001-0003 implement cgroup descendant iterators.

0004-0008 prepare cgroup_freezer for hierarchy support.  0009
implements it.

This patchset is on top of

 v3.6 (a0d271cbfe)
+ [2] the first three patches of
      "memcg/cgroup: do not fail fail on pre_destroy callbacks" patchset
+ [3] "cgroup: simplify cgroup removal path" v2 patchset

with cgroup/for-3.8 pulled into it.  The branch is rather floaty at
the moment so it would be the easiest to pull the following branch for
review.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup_freezer-hierarchy

Thanks.

 kernel/cgroup.c         |  106 +++++++++++++-
 kernel/cgroup_freezer.c |  359 +++++++++++++++++++++++++++++++++++-------------
 3 files changed, 445 insertions(+), 104 deletions(-)

--
tejun

[1] http://thread.gmane.org/gmane.linux.kernel.containers/23698
[2] http://thread.gmane.org/gmane.linux.kernel.cgroups/4757
[3] http://thread.gmane.org/gmane.linux.kernel.cgroups/4861
