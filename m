From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cfq blkcg hierarchy support
Date: Wed, 9 Jan 2013 08:10:34 -0800
Message-ID: <20130109161034.GK3926@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Jens.

Please consider pulling from the following branch to receive cfq blkcg
hierarchy support.  The branch is based on top of v3.8-rc2.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git blkcg-cfq-hierarchy

The patchset was reviewd in the following thread.

  http://thread.gmane.org/gmane.linux.kernel.cgroups/5571

Thanks.

----------------------------------------------------------------
Tejun Heo (19):
      blkcg: fix minor bug in blkg_alloc()
      blkcg: reorganize blkg_lookup_create() and friends
      blkcg: cosmetic updates to blkg_create()
      blkcg: make blkcg_gq's hierarchical
      cfq-iosched: add leaf_weight
      cfq-iosched: implement cfq_group->nr_active and ->children_weight
      cfq-iosched: implement hierarchy-ready cfq_group charge scaling
      cfq-iosched: convert cfq_group_slice() to use cfqg->vfraction
      cfq-iosched: enable full blkcg hierarchy support
      blkcg: add blkg_policy_data->plid
      blkcg: implement blkcg_policy->on/offline_pd_fn() and blkcg_gq->online
      blkcg: s/blkg_rwstat_sum()/blkg_rwstat_total()/
      blkcg: export __blkg_prfill_rwstat()
      blkcg: implement blkg_[rw]stat_recursive_sum() and blkg_[rw]stat_merge()
      block: RCU free request_queue
      blkcg: make blkcg_print_blkgs() grab q locks instead of blkcg lock
      cfq-iosched: separate out cfqg_stats_reset() from cfq_pd_reset_stats()
      cfq-iosched: collect stats from dead cfqgs
      cfq-iosched: add hierarchical cfq_group statistics

Vivek Goyal (6):
      cfq-iosched: Properly name all references to IO class
      cfq-iosched: More renaming to better represent wl_class and wl_type
      cfq-iosched: Rename "service_tree" to "st" at some places
      cfq-iosched: Rename few functions related to selecting workload
      cfq-iosched: Get rid of unnecessary local variable
      cfq-iosched: Print sync-noidle information in blktrace messages

 Documentation/block/cfq-iosched.txt        |  58 +++
 Documentation/cgroups/blkio-controller.txt |  35 +-
 block/blk-cgroup.c                         | 277 +++++++++++--
 block/blk-cgroup.h                         |  68 +++-
 block/blk-sysfs.c                          |   9 +-
 block/cfq-iosched.c                        | 627 +++++++++++++++++++++++------
 include/linux/blkdev.h                     |   2 +
 7 files changed, 902 insertions(+), 174 deletions(-)

-- 
tejun
