From: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 00/12] New version of the BFQ I/O
	Scheduler
Date: Mon, 02 Jun 2014 08:29:27 -0600
Message-ID: <538C8A47.1050502@kernel.dk>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
	<538926F6.7080409@kernel.dk>
	<20140531051635.GA19925@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140531051635.GA19925-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2014-05-30 23:16, Tejun Heo wrote:
>> for turning patch #2 into a series of changes for CFQ instead. We need to
>> end up with something where we can potentially bisect our way down to
>> whatever caused any given regression. The worst possible situation is "CFQ
>> works fine for this workload, but BFQ does not" or vice versa. Or hangs, or
>> whatever it might be.
>
> It's likely that there will be some workloads out there which may be
> affected adversely, which is true for any change really but with both
> the core scheduling and heuristics properly characterized at least
> finding a reasonable trade-off should be much less of a crapshoot and
> the expected benefits seem to easily outweigh the risks as long as we
> can properly sequence the changes.

Exactly, I think we are pretty much on the same page here. As I said in 
the previous email, the biggest thing I care about is not adding a new 
IO scheduler wholesale. If Paolo can turn the "add BFQ" patch into a 
series of patches against CFQ, then I would have no issue merging it for 
testing (and inclusion, when it's stable enough).

One thing I've neglected to bring up but have been thinking about - 
we're quickly getting to the point where the old request_fn IO path will 
become a legacy thing, mostly in maintenance mode. That isn't a problem 
for morphing bfq and cfq, but it does mean that development efforts in 
this area would be a lot better spent writing an IO scheduler that fits 
into the blk-mq framework instead.

I realize this is a tall order right now, as I haven't included any sort 
of framework for that in blk-mq yet. So what I envision happening is 
that I will write a basic deadline (ish) scheduler for blk-mq, and 
hopefully others can then pitch in and we can get the ball rolling on 
that side as well.

-- 
Jens Axboe
