From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Wed, 26 Nov 2008 11:41:46 -0800
Message-ID: <e98e18940811261141x307cf06fldd5e481e85da5c2d__24516.6618064561$1227728871$gmane$org@mail.gmail.com>
References: <20081113221304.GH7542@redhat.com>
	<20081120.182053.220301508585579959.ryov@valinux.co.jp>
	<20081120134701.GB29306@redhat.com>
	<20081125.113359.623571555980951312.ryov@valinux.co.jp>
	<20081125162720.GH341@redhat.com>
	<e98e18940811251438v245f79aegfdc92bee737af64c@mail.gmail.com>
	<492D57E1.5090608@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <492D57E1.5090608-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Nov 26, 2008 at 6:06 AM, Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org> wrote:
> Fabio and I are a little bit worried about the fact that the problem
> of working in the time domain instead of the service domain is not
> being properly dealt with.  Probably we did not express ourselves very
> clearly, so we will try to put in more practical terms.  Using B-WF2Q+
> in the time domain instead of using CFQ (Round-Robin) means introducing
> higher complexity than CFQ to get almost the same service properties
> of CFQ.  With regard to fairness (long term) B-WF2Q+ in the time domain

Are we talking about a case where all the contenders have equal
weights and are continuously backlogged? That seems to be the only
case when B-WF2Q+ would behave like Round-Robin. Am I missing
something here?

I can see that the only direct advantage of using WF2Q+ scheduling is
reduced jitter or latency in certain cases. But under heavy loads,
that might result in request latencies seen by RT threads to be
reduced from a few seconds to a few msec.

> has exactly the same (un)fairness problems of CFQ.  As far as bandwidth
> differentiation is concerned, it can be obtained with CFQ by just
> increasing the time slice (e.g., double weight => double slice).  This
> has no impact on long term guarantees and certainly does not decrease
> the throughput.
>
> With regard to short term guarantees (request completion time), one of
> the properties of the reference ideal system of Wf2Q+ is that, assuming
> for simplicity that all the queues have the same weight, as the ideal
> system serves each queue at the same speed, shorter budgets are completed
> in a shorter time intervals than longer budgets.  B-WF2Q+ guarantees
> O(1) deviation from this ideal service.  Hence, the tight delay/jitter
> measured in our experiments with BFQ is a consequence of the simple (and
> probably still improvable) budget assignment mechanism of (the overall)
> BFQ.  In contrast, if all the budgets are equal, as it happens if we use
> time slices, the resulting scheduler is exactly a Round-Robin, again
> as in CFQ (see [1]).

Can the budget assignment mechanism of BFQ be converted to time slice
assignment mechanism? What I am trying to say here is that we can have
variable time slices, just like we have variable budgets.

>
> Finally, with regard to completion time delay differentiation through
> weight differentiation, this is probably the only case in which B-WF2Q+
> would perform better than CFQ, because, in case of CFQ, reducing the
> time slices may reduce the throughput, whereas increasing the time slice
> would increase the worst-case delay/jitter.
>
> In the end, BFQ succeeds in guaranteeing fairness (or in general the
> desired bandwidth distribution) because it works in the service domain
> (and this is probably the only way to achieve this goal), not because
> it uses WF2Q+ instead of Round-Robin.  Similarly, it provides tight
> delay/jitter only because B-WF2Q+ is used in combination with a simple
> budget assignment (differentiation) mechanism (again in the service
> domain).
>
> [1] http://feanor.sssup.it/~fabio/linux/bfq/results.php
>
> --
> -----------------------------------------------------------
> | Paolo Valente              |                            |
> | Algogroup                  |                            |
> | Dip. Ing. Informazione     | tel:   +39 059 2056318     |
> | Via Vignolese 905/b        | fax:   +39 059 2056199     |
> | 41100 Modena               |                            |
> |     home:  http://algo.ing.unimo.it/people/paolo/       |
> -----------------------------------------------------------
>
>
