From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 0/3] BFQ I/O Scheduler (second take)
Date: Wed, 12 Nov 2008 10:48:00 +0800
Message-ID: <491A43E0.2080109@cn.fujitsu.com>
References: <20081111125148.GD9508@gandalf.sssup.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081111125148.GD9508-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

CC: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
    Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Fabio Checconi wrote:
> Hi Jens, hi all,
> 

Hi Fabio,

>   this is an updated version of the patchset introducing the BFQ (Budget
> Fair Queueing) I/O scheduler.  It is based on CFQ and it has been
> developed trying to improve the predictability and the fairness of the
> service prvided, without penalizing the aggregate throughput.
> 
> This new version hopefully addresses the issues pointed out after the
> first submission[1]:
> 
>   1) it introduces a bitmap to notify priority changes to the bfq/cfq;
>   2) it introduces a timeout to put an higher limit to the time a
>       task can take to consume its budget;
>   3) it supports hierarchical scheduling.
> 

So this is another cgroup-aware block i/o controller. ;)

People are sending different proposals for bio controller. A summary
on this can be found here:
	http://marc.info/?l=linux-kernel&m=121798534716673&w=2

And a new proposal sent by Vivek several days ago:
	http://lkml.org/lkml/2008/11/6/227

And there are some discussions about can we modify the elevator layer
and create a common layer so we can provide group control for all
the 4 io schedulers. (in the above mail thread)

You may share some ideas with us.

> With the introduction of a budget timeout, each task is still assigned
> a budget measured in number of sectors instead of amount of time,
> but a budget is not served to its exhaustion if it's taking too much
> to complete.  Budgets are still scheduled using a modified version
> of WF2Q+.
> 
> Using huge values for max_budget turns the scheduler into a pure
> time-domain proportional share one, and the timeout controls the duration
> of the time quanta.
> 
> WRT the support for hierarchical scheduling, that is being discussed
> so much in these days, this scheduler does not add anything new, it
> supports proportional share distribution of disk bandwidth among
> full cgroup hierarchies; the mapping from requests to cgroups is
> correct only in case of synchronous reads.
> 
> The overall diffstat is the following:
> 
>  block/Kconfig.iosched         |   25 +
>  block/Makefile                |    1 +
>  block/bfq-cgroup.c            |  743 +++++++++++++++
>  block/bfq-ioc.c               |  375 ++++++++
>  block/bfq-iosched.c           | 2010 +++++++++++++++++++++++++++++++++++++++++
>  block/bfq-sched.c             |  950 +++++++++++++++++++
>  block/bfq.h                   |  514 +++++++++++
>  block/blk-ioc.c               |   27 +-
>  block/cfq-iosched.c           |   10 +-
>  fs/ioprio.c                   |    9 +-
>  include/linux/cgroup_subsys.h |    6 +
>  include/linux/iocontext.h     |   18 +-
>  12 files changed, 4669 insertions(+), 19 deletions(-)
> 
> For a complete description of the algorithm and of its properties
> please refer to [2], (where extensive experiments on older hw can
> also be found), and for some performance measurements and implementation
> details, to [3].
> 
> [1] http://lkml.org/lkml/2008/4/1/234
> [2] http://algo.ing.unimo.it/people/paolo/disk_sched/
> [3] http://feanor.sssup.it/~fabio/linux/bfq/
> 
> As usual, any kind of feedback will be greatly appreciated, thanks
> in advance.
> 
> Fabio Checconi, Paolo Valente
