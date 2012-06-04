From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET] block: implement per-blkg request allocation
Date: Mon,  4 Jun 2012 00:08:07 -0700
Message-ID: <1338793697-10735-1-git-send-email-tj@kernel.org>
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
To: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

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

 0001-blkcg-fix-blkg_alloc-failure-path.patch
 0002-blkcg-__blkg_lookup_create-doesn-t-have-to-fail-on-r.patch
 0003-blkcg-make-root-blkcg-allocation-use-GFP_KERNEL.patch
 0004-mempool-add-gfp_mask-to-mempool_create_node.patch
 0005-block-drop-custom-queue-draining-used-by-scsi_transp.patch
 0006-block-refactor-get_request-_wait.patch
 0007-block-allocate-io_context-upfront.patch
 0008-blkcg-inline-bio_blkcg-and-friends.patch
 0009-block-add-q-nr_rqs-and-move-q-rq.elvpriv-to-q-nr_rqs.patch
 0010-block-prepare-for-multiple-request_lists.patch
 0011-blkcg-implement-per-blkg-request-allocation.patch

0001-0003 are assorted fixes / improvements which can be separated
from this patchset.  Just sending as part of this series for
convenience.

0004 adds @gfp_mask to mempool_create_node().  This is necessary
because blkg allocation is on the IO path and now blkg contains
mempool for request_list.  Note that blkg allocation failure doesn't
lead to catastrophic failure.  It just hinders blkcg enforcement.

0005 drops custom queue draining which I dont't think is necessary and
hinders with further updates.

0006-0010 are prep patches and 0011 implements per-blkg request
allocation.

This patchset is on top of,

  block/for-3.5/core bd1a68b59c "vmsplice: relax alignement requireme..."
+ [1] blkcg: tg_stats_alloc_lock is an irq lock

and is also available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git blkcg-rl

Jens, I still can't reproduce the boot failure you were seeing on
block/for-3.5/core, so am just basing this series on top.  Once we
figure that one out, we can resequence the patches.

Thanks.

 block/blk-cgroup.c                  |  147 ++++++++++++++++----------
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
 13 files changed, 379 insertions(+), 291 deletions(-)

--
tejun

[1] http://article.gmane.org/gmane.linux.kernel/1288400
