From: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 00/12] New version of the BFQ I/O
	Scheduler
Date: Mon, 02 Jun 2014 11:32:05 -0600
Message-ID: <538CB515.3090700__23165.8441749916$1401730331$gmane$org@kernel.dk>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
	<538926F6.7080409@kernel.dk>
	<20140531051635.GA19925@mtj.dyndns.org>
	<538C8A47.1050502@kernel.dk> <20140602172454.GA8912@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140602172454.GA8912-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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

On 06/02/2014 11:24 AM, Tejun Heo wrote:
> Hello, Jens.
> 
> On Mon, Jun 02, 2014 at 08:29:27AM -0600, Jens Axboe wrote:
>> One thing I've neglected to bring up but have been thinking about - we're
>> quickly getting to the point where the old request_fn IO path will become a
>> legacy thing, mostly in maintenance mode. That isn't a problem for morphing
>> bfq and cfq, but it does mean that development efforts in this area would be
>> a lot better spent writing an IO scheduler that fits into the blk-mq
>> framework instead.
> 
> What I'm planning right now is improving blkcg so that it can do both
> proportional and hard limits with high cpu scalability, most likely
> using percpu charge caches.  It probably would be best to roll all
> those into one piece of logic.  I don't think, well at least hope,
> that we'd need multiple modular scheduler / blkcg implementations for
> blk-mq and both can be served by built-in scheduling logic.
> Regardless of device speed, we'd need some form of fairness
> enforcement after all.

For things like blkcg, I agree, it should be able to be common code and
reusable. But there's a need for scheduling beyond that, for people that
don't use control groups (ie most...). And it'd be hard to retrofit cfq
into blk-mq, without rewriting it. I don't believe we need anything this
fancy for blk-mq, hopefully. At least having simple deadline scheduling
would be Good Enough for the foreseeable future.

-- 
Jens Axboe
