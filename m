From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCHSET] cgroup: introduce cgroup_taskset and consolidate subsys
	methods, take#2
Date: Fri, 26 Aug 2011 16:05:39 +0800
Message-ID: <4E5753D3.9080500__40564.4163991839$1314346084$gmane$org@cn.fujitsu.com>
References: <1314312192-26885-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1314312192-26885-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

Tejun Heo wrote:
> Hello,
> 
> This is the second take of cgroup_taskset patchset.  This patchset
> introduces cgroup_taskset along with some accessors and iterator,
> updates methods to use it, consolidates usages and drops superflous
> methods.  For more info, please read the head message and discussions
> from the last take[L].
> 
> Changes from the last take[L] are mostly minor.
> 
> * Acked-by's added
> * patch contamination fixed
> * local variable renamed
> * documentation updated
> 
> It contains the following six patches.
> 
>  0001-cgroup-subsys-attach_task-should-be-called-after-mig.patch
>  0002-cgroup-improve-old-cgroup-handling-in-cgroup_attach_.patch
>  0003-cgroup-introduce-cgroup_taskset-and-use-it-in-subsys.patch
>  0004-cgroup-don-t-use-subsys-can_attach_task-or-attach_ta.patch
>  0005-cgroup-cpuset-don-t-use-ss-pre_attach.patch
>  0006-cgroup-kill-subsys-can_attach_task-pre_attach-and-at.patch

This is really nice.

Acked-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

> 
> and is based on the current linux-pm/pm-freezer (7b5b95b3f5 "freezer:
> remove should_send_signal() and update frozen()"), and available in
> the following git tree.
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git freezer
> 
> Any ideas on how to route these patches?  If we float these in -mm,
> further freezer patches would have to be in -mm too which in turn will
> force job control patches depending on them to -mm too.  It would be
> really nice if we can find a stable git branch to host these.  Routing
> through pm-freezer might not be such a bad idea either, I think.
> 

It's fine for me to route those patches through pm-freezer, since this
work is initiated and needed for the work on freezer.

> Thank you.
> 
>  Documentation/cgroups/cgroups.txt |   51 +++------
>  block/blk-cgroup.c                |   45 +++++---
>  include/linux/cgroup.h            |   31 ++++-
>  kernel/cgroup.c                   |  200 ++++++++++++++++++++++++--------------
>  kernel/cgroup_freezer.c           |   16 ---
>  kernel/cpuset.c                   |  105 +++++++++----------
>  kernel/events/core.c              |   13 +-
>  kernel/sched.c                    |   31 +++--
>  mm/memcontrol.c                   |   16 +--
>  security/device_cgroup.c          |    7 -
>  10 files changed, 294 insertions(+), 221 deletions(-)
