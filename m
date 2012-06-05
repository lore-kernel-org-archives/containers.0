From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET] block: implement per-blkg request allocation, take#2
Date: Mon,  4 Jun 2012 20:40:50 -0700
Message-ID: <1338867660-4689-1-git-send-email-tj@kernel.org>
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
To: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

(The posting yesterday went out w/o lkml cc'd and old head message,
 resending w/ Vivek's suggestions applied.  Sorry about the noise.)

This is the second take of "implement per-blkg request allocation"
patchset.  Changes from the last take[L] are

* 0001-fix-blkg_alloc-failure-path patch is separated from this series
  and merged to block/for-linus.

* Updated patches posted incrementally merged into the series.

* Rebased on top of the current block/for-linus.

* Documentation/block/queue-sysfs.txt updated to note that nr_requests
  is per-blkcg.

* Acked/Reviewed-by's added.

The original description follows.

Currently block layer shares a single request_list (@q->rq) for all
IOs regardless of their blkcg associations.  This means that once the
shared pool is exhausted, blkcg limits don't mean much.  Whoever grabs
the requests being freed the first grabs the next IO slot.

This priority inversion can be easily demonstrated by creating a blkio
cgroup w/ very low weight, put a program which can issue a lot of
random direct IOs there and running a sequential IO from a different
cgroup.  As soon as the request pool is used up, the sequential IO
bandwidth crashes.

This patchset implements per-blkg request allocation so that each
blkcg-request_queue pair has its own request pool to allocate from.
This isolates different blkcgs in terms of request allocation.

Most changes are straight-forward; unfortunately, bdi isn't
blkcg-aware yet so it currently just propagates the congestion state
from root blkcg.  As writeback currently is always on the root blkcg,
this kinda works for write congestion but readahead may behave
non-optimally under congestion for now.  This needs to be improved but
the situation is still way better than blkcg completely collapsing.

 0001-blkcg-__blkg_lookup_create-doesn-t-need-radix-preloa.patch
 0002-blkcg-make-root-blkcg-allocation-use-GFP_KERNEL.patch
 0003-mempool-add-gfp_mask-to-mempool_create_node.patch
 0004-block-drop-custom-queue-draining-used-by-scsi_transp.patch
 0005-block-refactor-get_request-_wait.patch
 0006-block-allocate-io_context-upfront.patch
 0007-blkcg-inline-bio_blkcg-and-friends.patch
 0008-block-add-q-nr_rqs-and-move-q-rq.elvpriv-to-q-nr_rqs.patch
 0009-block-prepare-for-multiple-request_lists.patch
 0010-blkcg-implement-per-blkg-request-allocation.patch

0001-0002 are misc preps.

0003 adds @gfp_mask to mempool_create_node().  This is necessary
because blkg allocation is on the IO path and now blkg contains
mempool for request_list.  Note that blkg allocation failure doesn't
lead to catastrophic failure.  It just hinders blkcg enforcement.

0004 drops custom queue draining which I dont't think is necessary and
hinders with further updates.

0005-0009 are prep patches and 0010 implements per-blkg request
allocation.

This patchset is on top of the current block/for-linus - 9b2ea86bc9e
"blkcg: fix blkg_alloc() failure path" and is also available in the
following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git blkcg-rl

 Documentation/block/queue-sysfs.txt |    7 +
 block/blk-cgroup.c                  |  139 ++++++++++++++++---------
 block/blk-cgroup.h                  |  121 +++++++++++++++++++++
 block/blk-core.c                    |  200 ++++++++++++++++++------------------
 block/blk-sysfs.c                   |   34 +++---
 block/blk-throttle.c                |    3 
 block/blk.h                         |    3 
 block/bsg-lib.c                     |   53 ---------
 drivers/scsi/scsi_transport_fc.c    |   38 ------
 drivers/scsi/scsi_transport_iscsi.c |    2 
 include/linux/blkdev.h              |   53 +++++----
 include/linux/bsg-lib.h             |    1 
 include/linux/mempool.h             |    3 
 mm/mempool.c                        |   12 +-
 14 files changed, 382 insertions(+), 287 deletions(-)

Thanks.

--
tejun

[L] http://thread.gmane.org/gmane.linux.kernel.containers/23159
