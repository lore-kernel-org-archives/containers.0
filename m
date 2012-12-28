From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET] block: implement blkcg hierarchy support in cfq, take#2
Date: Fri, 28 Dec 2012 12:35:22 -0800
Message-ID: <1356726946-26037-1-git-send-email-tj__282.00907768241$1356726977$gmane$org@kernel.org>
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
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

This is the second iteration to implement blkcg hierarchy support in
cfq-iosched.  Changes from the first task[L] are

* Vivek's cfq cleanup patches are included in the series for
  convenience.

* Divide by zero bug when !CONFIG_CFQ_GROUP_IOSCHED reported by
  Fengguang fixed.

* Updated to reflect Vivek's reviews - renames & documentation.

* Recursive stats no longer forget stats from dead descendants.  This
  turned out to be more complex than I wished involving implementing
  policy on/offline callbacks.

cfq-iosched is currently utterly broken in how it handles cgroup
hierarchy.  It ignores the hierarchy structure and just treats every
blkcgs equally.  This is simply broken.  This breakage makes blkcg
behave very differently from other properly-hierarchical controllers
and makes it impossible to give any uniform interpretation to the
hierarchy, which in turn makes it impossible to implement unified
hierarchy.

Given the relative simplicity of cfqg scheduling, implementing proper
hierarchy support isn't that difficult.  All that's necessary is
determining how much fraction each cfqg on the service tree has claim
to considering the hierarchy.  The calculation can be done by
maintaining the sum of active weights at each level and compounding
the ratios from the cfqg in question to root.  The overhead isn't
significant.  Tree traversals happen only when cfqgs are added or
removed from the service tree and they are from the cfqg being
modified to the root.

There are some design choices which are worth mentioning.

* Internal (non-leaf) cfqgs w/ tasks treat the tasks as a single unit
  competeting against the children cfqgs.  New config knobs -
  blkio.leaf_weight[_device] - are added to configure the weight of
  these tasks.  Another way to look at it is that each cfqg has a
  hidden leaf child node attached to it which hosts all tasks and
  leaf_weight controls the weight of that hidden node.

  Treating cfqqs and cfqgs as equals doesn't make much sense to me and
  is hairy - we need to establish ioprio to weight mapping and the
  weights fluctuate as processes fork and exit.  This becomes hairier
  when considering multiple controllers, Such mappings can't be
  established consistently across different controllers and the
  weights are given out differently - ie. blkcg give weights out to
  io_contexts while cpu to tasks, which may share io_contexts.  It's
  difficult to make sense of what's going on.

  The goal is to bring cpu, currently the only other controller which
  implements weight based resource allocation, to similar behavior.

* The existing stats aren't converted to hierarchical but new
  hierarchical ones are added.  There isn't a way to do that w/o
  introducing nasty silent surprises to the existing flat hierarchy
  users, so while being a bit clumsy, I can't see a better way.

* I based it on top of Vivek's cleanup patchset[1] but not the cfqq,
  cfqg scheduling unification patchset.  I don't think it's necessary
  or beneficial to mix the two and would really like to avoid messing
  with !blkcg scheduling logic.

The hierarchical scheduling itself is fairly simple.  The cfq part is
only ~260 lines with ~60 lines being comment, and the hierarchical
weight scaling is really straight-forward.

This patchset contains the following 24 patches.

 0001-cfq-iosched-Properly-name-all-references-to-IO-class.patch
 0002-cfq-iosched-More-renaming-to-better-represent-wl_cla.patch
 0003-cfq-iosched-Rename-service_tree-to-st-at-some-places.patch
 0004-cfq-iosched-Rename-few-functions-related-to-selectin.patch
 0005-cfq-iosched-Get-rid-of-unnecessary-local-variable.patch
 0006-cfq-iosched-Print-sync-noidle-information-in-blktrac.patch
 0007-blkcg-fix-minor-bug-in-blkg_alloc.patch
 0008-blkcg-reorganize-blkg_lookup_create-and-friends.patch
 0009-blkcg-cosmetic-updates-to-blkg_create.patch
 0010-blkcg-make-blkcg_gq-s-hierarchical.patch
 0011-cfq-iosched-add-leaf_weight.patch
 0012-cfq-iosched-implement-cfq_group-nr_active-and-childr.patch
 0013-cfq-iosched-implement-hierarchy-ready-cfq_group-char.patch
 0014-cfq-iosched-convert-cfq_group_slice-to-use-cfqg-vfra.patch
 0015-cfq-iosched-enable-full-blkcg-hierarchy-support.patch
 0016-blkcg-add-blkg_policy_data-plid.patch
 0017-blkcg-implement-blkcg_policy-on-offline_pd_fn-and-bl.patch
 0018-blkcg-s-blkg_rwstat_sum-blkg_rwstat_total.patch
 0019-blkcg-implement-blkg_-rw-stat_recursive_sum-and-blkg.patch
 0020-block-RCU-free-request_queue.patch
 0021-blkcg-make-blkcg_print_blkgs-grab-q-locks-instead-of.patch
 0022-cfq-iosched-separate-out-cfqg_stats_reset-from-cfq_p.patch
 0023-cfq-iosched-collect-stats-from-dead-cfqgs.patch
 0024-cfq-iosched-add-hierarchical-cfq_group-statistics.patch

0001-0006 are Vivek's cfq cleanup patches.

0007-0009 are prep patches.

0010 makes blkcg core always allocate non-leaf blkgs so that any given
blkg is guaranteed to have all its ancestor blkgs to the root.

0011-0012 prepare for hierarchical scheduling.

0013-0014 implement hierarchy-ready cfqg scheduling.

0015 enbles hierarchical scheduling.

0016-0022 prepare for hierarchical stats.

0023-0024 implement hierarchical stats.

This patchset is on top of linus#master (ecccd1248d ("mm: fix null
pointer dereference in wait_iff_congested()")).

and available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git blkcg-cfq-hierarchy

Thanks.

 Documentation/block/cfq-iosched.txt |   58 +++
 block/blk-cgroup.c                  |  276 +++++++++++++--
 block/blk-cgroup.h                  |   68 +++
 block/blk-sysfs.c                   |    9 
 block/cfq-iosched.c                 |  627 +++++++++++++++++++++++++++++-------
 include/linux/blkdev.h              |    2 
 6 files changed, 877 insertions(+), 163 deletions(-)

--
tejun

[L] http://thread.gmane.org/gmane.linux.kernel.cgroups/5440
[1] https://lkml.org/lkml/2012/10/3/502
