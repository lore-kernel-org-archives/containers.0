From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] blk-throttle: implement proper hierarchy support
Date: Tue, 14 May 2013 14:09:33 -0700
Message-ID: <20130514210933.GW6795__5864.32174682177$1368565791$gmane$org@mtj.dyndns.org>
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

This is the pull request for patches which implement proper hierarchy
support in blk-throttle and remove .broken_hierarchy tagging from
blkcg.

  http://thread.gmane.org/gmane.linux.kernel.cgroups/7119

The implementation is fairly straight-forward in that it just repeats
the same scheduling at each layer until it reaches the top and thus
isn't very scalable.  It also still has an issue where a nested cgroup
could get lower than configured limits as it travels towards root but
the severity is at an acceptable level after Vivke's start time
adjustment patch.  The issue ultimately is a problem in the scheduling
algorithm itself and can also show up in flat hierarchy given the
right (well, wrong) IO pattern.  If it still is an actual problem,
which I don't think is, we should be able to work on it later on in
fairly isolated manner.

While the implementation isn't perfect, it should be good enough in
most cases with a few levels of nesting and this allows the rest of
cgroup to proceed towards unified hierarchy handling.

The series is based on top of v3.10-rc1 and available in the following
git branch

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git blk-throttle-hierarchy

for you to fetch changes up to 9138125beabbb76b4a373d4a619870f6f5d86fc5:

  blk-throttle: implement proper hierarchy support (2013-05-14 13:52:38 -0700)

Thanks.

----------------------------------------------------------------
Tejun Heo (32):
      blkcg: fix error return path in blkg_create()
      blkcg: move blkg_for_each_descendant_pre() to block/blk-cgroup.h
      blkcg: implement blkg_for_each_descendant_post()
      blkcg: invoke blkcg_policy->pd_init() after parent is linked
      blkcg: move bulk of blkcg_gq release operations to the RCU callback
      blk-throttle: remove spurious throtl_enqueue_tg() call from throtl_select_dispatch()
      blk-throttle: remove deferred config application mechanism
      blk-throttle: collapse throtl_dispatch() into the work function
      blk-throttle: relocate throtl_schedule_delayed_work()
      blk-throttle: remove pointless throtl_nr_queued() optimizations
      blk-throttle: rename throtl_rb_root to throtl_service_queue
      blk-throttle: simplify throtl_grp flag handling
      blk-throttle: add backlink pointer from throtl_grp to throtl_data
      blk-throttle: pass around throtl_service_queue instead of throtl_data
      blk-throttle: reorganize throtl_service_queue passed around as argument
      blk-throttle: add throtl_grp->service_queue
      blk-throttle: move bio_lists[] and friends to throtl_service_queue
      blk-throttle: dispatch to throtl_data->service_queue.bio_lists[]
      blk-throttle: generalize update_disptime optimization in blk_throtl_bio()
      blk-throttle: add throtl_service_queue->parent_sq
      blk-throttle: implement sq_to_tg(), sq_to_td() and throtl_log()
      blk-throttle: set REQ_THROTTLED from throtl_charge_bio() and gate stats update with it
      blk-throttle: separate out throtl_service_queue->pending_timer from throtl_data->dispatch_work
      blk-throttle: implement dispatch looping
      blk-throttle: dispatch from throtl_pending_timer_fn()
      blk-throttle: make blk_throtl_drain() ready for hierarchy
      blk-throttle: make blk_throtl_bio() ready for hierarchy
      blk-throttle: make tg_dispatch_one_bio() ready for hierarchy
      blk-throttle: make throtl_pending_timer_fn() ready for hierarchy
      blk-throttle: add throtl_qnode for dispatch fairness
      blk-throttle: implement throtl_grp->has_rules[]
      blk-throttle: implement proper hierarchy support

Vivek Goyal (1):
      blk-throttle: Account for child group's start time in parent while bio climbs up

 Documentation/cgroups/blkio-controller.txt |   29 +-
 block/blk-cgroup.c                         |  105 ++-
 block/blk-cgroup.h                         |   38 +-
 block/blk-throttle.c                       | 1064 +++++++++++++++++++---------
 include/linux/cgroup.h                     |    2 +
 5 files changed, 837 insertions(+), 401 deletions(-)

--
tejun
