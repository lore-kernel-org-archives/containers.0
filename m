From: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Tue, 18 Nov 2008 13:05:08 +0100
Message-ID: <20081118120508.GD15268__46278.4259151251$1227009878$gmane$org@gandalf.sssup.it>
References: <20081113.180558.519459540419535699.ryov@valinux.co.jp>
	<20081113155834.GE7542@redhat.com>
	<af41c7c40811131041t1b8491b6la5574ebe75f89000@mail.gmail.com>
	<20081113214642.GG7542@redhat.com>
	<af41c7c40811131457w472e4a86tb5344cc1d3d366fb@mail.gmail.com>
	<20081114160525.GE24624@redhat.com>
	<e98e18940811141444u5947b806v27fac453ed1e8a5@mail.gmail.com>
	<20081117142309.GA15564@redhat.com>
	<4922224A.5030502@cn.fujitsu.com>
	<e98e18940811172101na345b6bh5c73f9e657aac5a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e98e18940811172101na345b6bh5c73f9e657aac5a7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Date: Mon, Nov 17, 2008 09:01:48PM -0800
>
> If we start with bfq patches, this is how plan would look like:
> 
> 1 Start with BFQ take 2.
> 2 Do the following to support proportional division:
>  a) Expose the per device weight interface to user, instead of calculating
>  from priority.
>  b) Add support for disk time budgets, besides sector budget that is currently
>  available (configurable option). (Fabio: Do you think we can just emulate
> that using the existing code?). Another approach would be to give time slices
> just like CFQ (discussing?)

  it should be possible without altering the code.  The slices can be
assigned in the time domain using big values for max_budget.  The logic
is: each process is assigned a budget (in the range [max_budget/2, max_budget],
choosen from the feedback mechanism, driven in __bfq_bfqq_recalc_budget()),
and if it does not complete it in timeout_sync milliseconds, it is
charged a fixed amount of sectors of service.

Using big values for max_budget (where big means greater than two
times the number of sectors the hard drive can transfer in timeout_sync
milliseconds) makes the budgets always to time out, so the disk time
is scheduled in slices of timeout_sync.

However this is just a temporary workaround to do some basic testing.

Modifying the scheduler to support time slices instead of sector
budgets would indeed simplify the code; I think that the drawback
would be being too unfair in the service domain.  Of course we
have to consider how much is important to be fair in the service
domain, and how much added complexity/new code can we accept for it.

[ Better service domain fairness is one of the main reasons why
  we started working on bfq, so, talking for me and Paolo it _is_
  important :) ]

I have to think a little bit on how it would be possible to support
an option for time-only budgets, coexisting with the current behavior,
but I think it can be done.


> 4 Do the following to support the goals of 2 level schedulers:
>  a) Limit the request descriptors allocated to each cgroup by adding
>  functionality to elv_may_queue()
>  b) Add support for putting an absolute limit on IO consumed by a
>  cgroup. Such support is provided by Andrea
>  Righi's patches too.
>  c) Add support (configurable option) to keep track of total disk
> time/sectors/count
>  consumed at each device, and factor that into scheduling decision
>  (more discussion needed here)
> 6 Incorporate an IO tracking approach which re-uses memory resource
> controller code but is not dependent on it (may be biocgroup patches from
> dm-ioband can be used here directly)
> 7 Start an offline email thread to keep track of progress on the above
> goals.
> 
> BFQ's support for hierarchy of cgroups means that its close to where
> we want to get. Any comments on what approach looks better?
> 

The main problems with this approach (as with the cfq-based ones) in
my opinion are:
  - the request descriptor allocation problem Divyesh talked about,
  - the impossibility of respecting different weights, resulting from
    the interlock problem with synchronous requests Vivek talked about
    [ in cfq/bfq this can happen when idling is disabled, e.g., for
      SSDs, or when using NCQ ],

but I think that correctly addressing your points 4.a) and 4.b) should
solve them.
