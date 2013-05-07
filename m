From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET v2] blk-throttle: implement proper hierarchy support
Date: Tue, 7 May 2013 10:02:03 -0400
Message-ID: <20130507140202.GB7082@redhat.com>
References: <1367880372-28312-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1367880372-28312-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, May 06, 2013 at 03:45:39PM -0700, Tejun Heo wrote:
> Changes since the last take[L] are
> 
> * Unnecessary throtl_schedule_delayed_work() call dropped from 0007.
> 
> * throtl_log() implement in 0021 forgot to print space after blkg
>   path.  Fixed.
> 
> * 0030-blk-throttle-add-throtl_qnode-for-dispatch-fairness.patch added
>   to address dispatch fairness.
> 
> * 0031-blk-throttle-Account-for-child-group-s-start-time-in.patch
>   added to address unwarranted penalty of nested limit enforcement due
>   to staggered delays of slice start times at multiple levels.
> 
> The original patchset description follows.
> 

This patch series looks good to me.

Acked-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Vivek

> blk-throttle is the last controller with broken hierarchy support
> making blkcg the last one tagged with .broken_hierarchy.  This
> patchset implements hierarchy support for blk-throttle.  The semantics
> is pretty simple - limits on an intermediate node applies to the whole
> subtree and the statistics remain local.
> 
> As this changes the meaning of the knobs in an incompatible manner -
> e.g. configuring limits on root cgroup now means setting the limit for
> the whole system - the hierarchy mode is enabled by "sane_behavior"
> cgroup mount flag.  If the flag is not specified, the original broken
> flat hierarchy behavior is retained.
> 
> While this patchset contains many patches, the implementation is
> pretty straight-forward.  throtl_grp's form a tree anchored at
> throtl_data and bios climb the tree as they get dispatched at each
> level.  The bios which reach the top of the tree - throl_data - are
> issued.  The scheduling algorithm remains unchanged at each level and
> blk-throttle should behave the same for flat hierarchy after the
> changes.  The same algorithm is repeated until bios clear all limits
> to the top of the tree.
> 
> This patchset contains the following 33 patches.
> 
>  0001-blkcg-fix-error-return-path-in-blkg_create.patch
>  0002-blkcg-move-blkg_for_each_descendant_pre-to-block-blk.patch
>  0003-blkcg-implement-blkg_for_each_descendant_post.patch
>  0004-blkcg-invoke-blkcg_policy-pd_init-after-parent-is-li.patch
>  0005-blkcg-move-bulk-of-blkcg_gq-release-operations-to-th.patch
>  0006-blk-throttle-remove-spurious-throtl_enqueue_tg-call-.patch
>  0007-blk-throttle-removed-deferred-config-application-mec.patch
>  0008-blk-throttle-collapse-throtl_dispatch-into-the-work-.patch
>  0009-blk-throttle-relocate-throtl_schedule_delayed_work.patch
>  0010-blk-throttle-remove-pointless-throtl_nr_queued-optim.patch
>  0011-blk-throttle-rename-throtl_rb_root-to-throtl_service.patch
>  0012-blk-throttle-simplify-throtl_grp-flag-handling.patch
>  0013-blk-throttle-add-backlink-pointer-from-throtl_grp-to.patch
>  0014-blk-throttle-pass-around-throtl_service_queue-instea.patch
>  0015-blk-throttle-reorganize-throtl_service_queue-passed-.patch
>  0016-blk-throttle-add-throtl_grp-service_queue.patch
>  0017-blk-throttle-move-bio_lists-and-friends-to-throtl_se.patch
>  0018-blk-throttle-dispatch-to-throtl_data-service_queue.b.patch
>  0019-blk-throttle-generalize-update_disptime-optimization.patch
>  0020-blk-throttle-add-throtl_service_queue-parent_sq.patch
>  0021-blk-throttle-implement-sq_to_tg-sq_to_td-and-throtl_.patch
>  0022-blk-throttle-set-REQ_THROTTLED-from-throtl_charge_bi.patch
>  0023-blk-throttle-separate-out-throtl_service_queue-pendi.patch
>  0024-blk-throttle-implement-dispatch-looping.patch
>  0025-blk-throttle-dispatch-from-throtl_pending_timer_fn.patch
>  0026-blk-throttle-make-blk_throtl_drain-ready-for-hierarc.patch
>  0027-blk-throttle-make-blk_throtl_bio-ready-for-hierarchy.patch
>  0028-blk-throttle-make-tg_dispatch_one_bio-ready-for-hier.patch
>  0029-blk-throttle-make-throtl_pending_timer_fn-ready-for-.patch
>  0030-blk-throttle-add-throtl_qnode-for-dispatch-fairness.patch
>  0031-blk-throttle-Account-for-child-group-s-start-time-in.patch
>  0032-blk-throttle-implement-throtl_grp-has_rules.patch
>  0033-blk-throttle-implement-proper-hierarchy-support.patch
> 
> 0001-0005 prepare blkcg so that hierarchy operations are easier.
> 
> 0006-0016 reorganize code piece-by-piece so that hierarchy support can
> be added.  These don't change behaviors.
> 
> 0017-0025 prepare for hierarchy support.  Moves fields which are used
> in hierarchy to throtl_service_queue and define parent-child
> relationship.
> 
> 0026-0032 make queueing, dispatching and configuration changes
> propagate through the hierarchy.
> 
> 0033 implemenats hierarchy support.
> 
> As we're in the middle of a merge window, this patchset is currently
> based on cgroup/for-3.10.  Once 3.10-rc1 drops, I'll rebase the tree
> and send pull request to Jens so that it can be routed with other
> block changes.  The patches are also available on the following git
> branch.
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-throtl-hierarchy
> 
> diffstat follows.  Thanks.
> 
>  block/blk-cgroup.c     |  105 +---
>  block/blk-cgroup.h     |   38 +
>  block/blk-throttle.c   | 1064 ++++++++++++++++++++++++++++++++++---------------
>  include/linux/cgroup.h |    2 
>  4 files changed, 822 insertions(+), 387 deletions(-)
> 
> --
> tejun
> 
> [L] http://thread.gmane.org/gmane.linux.kernel.containers/25845
