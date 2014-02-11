From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.15] cgroup: convert to kernfs
Date: Tue, 11 Feb 2014 17:24:09 +0800
Message-ID: <52F9EC39.40504@huawei.com>
References: <1390953285-16360-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390953285-16360-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2014/1/29 7:54, Tejun Heo wrote:
> Hello,
> 
> cgroup filesystem code was derived from the original sysfs
> implementation which was heavily intertwined with vfs objects and
> locking with the goal of re-using the existing vfs infrastructure.
> That experiment turned out rather disastrous and sysfs switched, a
> long time ago, to distributed filesystem model where a separate
> representation is maintained which is queried by vfs.  Unfortunately,
> cgroup stuck with the failed experiment all these years and
> accumulated even more problems over time.
> 
> Locking and object lifetime management being entangled with vfs is
> probably the most egregious.  vfs was never designed to be misused
> like this and cgroup ends up jumping through various convoluted
> dancing to make things work.  Even then, operations across multiple
> cgroups can't be done safely as it'll deadlock with rename locking.
> 
> Recently, kernfs is separated out from sysfs so that it can be used by
> users other than sysfs.  This patchset converts cgroup to use kernfs.
> This simplifies code base quite a bit and allows further cleanups and
> implementation of features which depend on operating across multiple
> nodes.
> 
> This patchset contains the following 13 patches.
> 
>  0001-cgroup-improve-css_from_dir-into-css_tryget_from_dir.patch
>  0002-cgroup-introduce-cgroup_tree_mutex.patch
>  0003-cgroup-release-cgroup_mutex-over-file-removals.patch
>  0004-cgroup-restructure-locking-and-error-handling-in-cgr.patch
>  0005-cgroup-factor-out-cgroup_setup_root-from-cgroup_moun.patch
>  0006-cgroup-update-cgroup-name-handling.patch
>  0007-cgroup-make-cgroup_subsys-base_cftypes-use-cgroup_ad.patch
>  0008-cgroup-update-the-meaning-of-cftype-max_write_len.patch
>  0009-cgroup-introduce-cgroup_init-exit_cftypes.patch
>  0010-cgroup-introduce-cgroup_ino.patch
>  0011-cgroup-misc-preps-for-kernfs-conversion.patch
>  0012-cgroup-relocate-functions-in-preparation-of-kernfs-c.patch
>  0013-cgroup-convert-to-kernfs.patch
> 
> 0001 updates css_from_dir() into css_tryget_from_dir() so that the
> caller doesn't have to worry about RCU locking.
> 
> 0002-0004 introduce cgroup_tree_mutex and prepare locking.
> 
> 0005-0006 are misc preps.
> 
> 0007-0008 update cftype handling in preparation.
> 
> 0009-0012 are misc preps.
> 
> 0013 converts cgroup to kernfs.
> 
> This patchset is on top of
> 
>   linus#master 54c0a4b46150 ("Merge branch 'akpm' (incoming from Andrew)")
> + [1] [PATCHSET cgroup/for-3.14-fixes] cgroup: four misc fixes
> + [2] [PATCH] arm, pm, vmpressure: add missing slab.h includes
> + [3] [PATCHSET v2 cgroup/for-3.15] cgroup: drop module support and cgroup_root_mutex
> + git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git review-kernfs-cgroup-prep
> 
> and also available in the following git branch.
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-kernfs-conversion
> 
> diffstat follows.
> 
>  block/blk-throttle.c   |    4
>  block/cfq-iosched.c    |    3
>  include/linux/cgroup.h |   71 --
>  kernel/cgroup.c        | 1712 ++++++++++++++++++++-----------------------------
>  kernel/events/core.c   |   17
>  mm/memcontrol.c        |   16
>  mm/memory-failure.c    |    8
>  7 files changed, 754 insertions(+), 1077 deletions(-)
> 

Looks good to me!

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Will look into remaining patchsets tomorrow.
