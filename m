From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET v2 cgroup/for-3.11] cgroup: convert cgroup_subsys_state
	refcnt to percpu_ref
Date: Thu, 13 Jun 2013 14:04:47 +0800
Message-ID: <51B960FF.7070604@huawei.com>
References: <1371096298-24402-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371096298-24402-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/6/13 12:04, Tejun Heo wrote:
> Hello,
> 
> The changes from the last take[L] are,
> 
> * Rebased on top of further percpu-refcount updates.
> 
> * 0003: Broken patch description updated.
> 
> * 0004: Stupid list_del_init() conversions from the last decade
>         dropped.
> 
> * 0005: Typo fix.
> 
> * 0011: percpu_ref_init() error handling fixed.  Premature and
>         duplicate base css ref puts fixed.
> 
> This patchset does a lot of cleanup and then updates css
> (cgroup_subsys_state) refcnt to use the new percpu reference counter.
> A css (cgroup_subsys_state) is how each cgroup is represented to a
> controller.  As such, it can be used in hot paths across the various
> subsystems different controllers are associated with.
> 
> One of the common operations is reference counting, which up until now
> has been implemented using a global atomic counter and can have
> significant adverse impact on scalability.  For example, css refcnt
> can be gotten and put multiple times by blkcg for each IO request.
> For highops configurations which try to do as much per-cpu as
> possible, the global frequent refcnting can be very expensive.
> 
> In general, given the various hugely diverse paths css's end up being
> used from, we need to make it cheap and highly scalable.  In its
> usage, css refcnting isn't very different from module refcnting.
> 
> This patchset contains the following 11 patches.
> 
>  0001-cgroup-remove-now-unused-css_depth.patch
>  0002-cgroup-consistently-use-cset-for-struct-css_set-vari.patch
>  0003-cgroup-bring-some-sanity-to-naming-around-cg_cgroup_.patch
>  0004-cgroup-use-kzalloc-instead-of-kmalloc.patch
>  0005-cgroup-clean-up-css_-try-get-and-css_put.patch
>  0006-cgroup-rename-CGRP_REMOVED-to-CGRP_DEAD.patch
>  0007-cgroup-drop-unnecessary-RCU-dancing-from-__put_css_s.patch
>  0008-cgroup-remove-cgroup-count-and-use.patch
>  0009-cgroup-reorder-the-operations-in-cgroup_destroy_lock.patch
>  0010-cgroup-split-cgroup-destruction-into-two-steps.patch
>  0011-cgroup-use-percpu-refcnt-for-cgroup_subsys_states.patch
> 
> 0001-0007 are cleanups, many of them cosmetic.  They clean up the code
> paths which are related with the refcnting changes.  If you're only
> interested in the precpu usage, you can probably skip these.
> 
> 0008-0010 updates the cgroup destruction path so that percpu refcnting
> can be used.
> 
> 0011 updates css refcnting to use percpu_ref.
> 
> This patchset is on top of
> 
>   cgroup/for-3.11 d5c56ced77 ("cgroup: clean up the cftype array for the base cgroup files")
> + [1] percpu/review-percpu-ref-tryget
> 
> and available in the following git branch.
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-css-percpu-ref
> 
> diffstat follows.  Thanks.
> 
>  include/linux/cgroup.h |   87 ++---
>  kernel/cgroup.c        |  723 ++++++++++++++++++++++++++-----------------------
>  2 files changed, 420 insertions(+), 390 deletions(-)
> 

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
