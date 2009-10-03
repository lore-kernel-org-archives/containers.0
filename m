From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Sat, 3 Oct 2009 07:29:15 -0400
Message-ID: <20091003112915.GA12925__22525.71328213$1254569467$gmane$org@redhat.com>
References: <alpine.LFD.2.01.0910020811490.6996@localhost.localdomain>
	<20091002171129.GG31616@kernel.dk> <20091002172046.GA2376@elte.hu>
	<20091002172554.GJ31616@kernel.dk> <20091002172842.GA4884@elte.hu>
	<20091002173732.GK31616@kernel.dk>
	<1254507215.8667.7.camel@marge.simson.net>
	<20091002181903.GN31616@kernel.dk>
	<1254548931.8299.18.camel@marge.simson.net>
	<1254549378.8299.21.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1254549378.8299.21.camel-YqMYhexLQo1vAv1Ojkdn7Q@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Oct 03, 2009 at 07:56:18AM +0200, Mike Galbraith wrote:
> On Sat, 2009-10-03 at 07:49 +0200, Mike Galbraith wrote:
> > On Fri, 2009-10-02 at 20:19 +0200, Jens Axboe wrote:
> > 
> > > If you could do a cleaned up version of your overload patch based on
> > > this:
> > > 
> > > http://git.kernel.dk/?p=linux-2.6-block.git;a=commit;h=1d2235152dc745c6d94bedb550fea84cffdbf768
> > > 
> > > then lets take it from there.
> 

> Note to self: build the darn thing after last minute changes.
> 
> Block:  Delay overloading of CFQ queues to improve read latency.
> 
> Introduce a delay maximum dispatch timestamp, and stamp it when:
>         1. we encounter a known seeky or possibly new sync IO queue.
>         2. the current queue may go idle and we're draining async IO.
>         3. we have sync IO in flight and are servicing an async queue.
>         4  we are not the sole user of disk.
> Disallow exceeding quantum if any of these events have occurred recently.
> 

So it looks like primarily the issue seems to be that we done lot of
dispatch from async queue and if some sync queue comes in now, it will
experience latencies.

For a ongoing seeky sync queue issue will be solved up to some extent
because previously we did not choose to idle for that queue now we will
idle, hence async queue will not get a chance to overload the dispatch
queue.

For the sync queues where we choose not to enable idle, we still will see
the latencies. Instead of time stamping on all the above events, can we 
just keep track of last sync request completed in the system and don't
allow async queue to flood/overload the dispatch queue with-in certain 
time limit of that last sync request completion. This just gives a buffer
period to that sync queue to come back and submit more requests and
still not suffer large latencies?

Thanks
Vivek


> Protect this behavioral change with a "desktop_dispatch" knob and default
> it to "on".. providing an easy means of regression verification prior to
> hate-mail dispatch :) to CC list.
> 
> Signed-off-by: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
> Cc: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> ... others who let somewhat hacky tweak slip by
> 
> ---
>  block/cfq-iosched.c |   45 +++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 41 insertions(+), 4 deletions(-)
> 
> Index: linux-2.6/block/cfq-iosched.c
> ===================================================================
> --- linux-2.6.orig/block/cfq-iosched.c
> +++ linux-2.6/block/cfq-iosched.c
> @@ -174,6 +174,9 @@ struct cfq_data {
>  	unsigned int cfq_slice_async_rq;
>  	unsigned int cfq_slice_idle;
>  	unsigned int cfq_desktop;
> +	unsigned int cfq_desktop_dispatch;
> +
> +	unsigned long desktop_dispatch_ts;
>  
>  	struct list_head cic_list;
>  
> @@ -1283,6 +1286,7 @@ static int cfq_dispatch_requests(struct
>  	struct cfq_data *cfqd = q->elevator->elevator_data;
>  	struct cfq_queue *cfqq;
>  	unsigned int max_dispatch;
> +	unsigned long delay;
>  
>  	if (!cfqd->busy_queues)
>  		return 0;
> @@ -1297,19 +1301,26 @@ static int cfq_dispatch_requests(struct
>  	/*
>  	 * Drain async requests before we start sync IO
>  	 */
> -	if (cfq_cfqq_idle_window(cfqq) && cfqd->rq_in_driver[BLK_RW_ASYNC])
> +	if (cfq_cfqq_idle_window(cfqq) && cfqd->rq_in_driver[BLK_RW_ASYNC]) {
> +		cfqd->desktop_dispatch_ts = jiffies;
>  		return 0;
> +	}
>  
>  	/*
>  	 * If this is an async queue and we have sync IO in flight, let it wait
>  	 */
> -	if (cfqd->sync_flight && !cfq_cfqq_sync(cfqq))
> +	if (cfqd->sync_flight && !cfq_cfqq_sync(cfqq)) {
> +		cfqd->desktop_dispatch_ts = jiffies;
>  		return 0;
> +	}
>  
>  	max_dispatch = cfqd->cfq_quantum;
>  	if (cfq_class_idle(cfqq))
>  		max_dispatch = 1;
>  
> +	if (cfqd->busy_queues > 1)
> +		cfqd->desktop_dispatch_ts = jiffies;
> +
>  	/*
>  	 * Does this cfqq already have too much IO in flight?
>  	 */
> @@ -1327,6 +1338,16 @@ static int cfq_dispatch_requests(struct
>  			return 0;
>  
>  		/*
> +		 * Don't start overloading until we've been alone for a bit.
> +		 */
> +		if (cfqd->cfq_desktop_dispatch) {
> +			delay = cfqd->desktop_dispatch_ts + cfq_slice_sync;
> +
> +			if (time_before(jiffies, max_delay))
> +				return 0;
> +		}
> +
> +		/*
>  		 * we are the only queue, allow up to 4 times of 'quantum'
>  		 */
>  		if (cfqq->dispatched >= 4 * max_dispatch)
> @@ -1942,7 +1963,7 @@ static void
>  cfq_update_idle_window(struct cfq_data *cfqd, struct cfq_queue *cfqq,
>  		       struct cfq_io_context *cic)
>  {
> -	int old_idle, enable_idle;
> +	int old_idle, enable_idle, seeky = 0;
>  
>  	/*
>  	 * Don't idle for async or idle io prio class
> @@ -1950,10 +1971,20 @@ cfq_update_idle_window(struct cfq_data *
>  	if (!cfq_cfqq_sync(cfqq) || cfq_class_idle(cfqq))
>  		return;
>  
> +	if (cfqd->hw_tag) {
> +		if (CIC_SEEKY(cic))
> +			seeky = 1;
> +		/*
> +		 * If seeky or incalculable seekiness, delay overloading.
> +		 */
> +		if (seeky || !sample_valid(cic->seek_samples))
> +			cfqd->desktop_dispatch_ts = jiffies;
> +	}
> +
>  	enable_idle = old_idle = cfq_cfqq_idle_window(cfqq);
>  
>  	if (!atomic_read(&cic->ioc->nr_tasks) || !cfqd->cfq_slice_idle ||
> -	    (!cfqd->cfq_desktop && cfqd->hw_tag && CIC_SEEKY(cic)))
> +	    (!cfqd->cfq_desktop && seeky))
>  		enable_idle = 0;
>  	else if (sample_valid(cic->ttime_samples)) {
>  		if (cic->ttime_mean > cfqd->cfq_slice_idle)
> @@ -2483,6 +2514,9 @@ static void *cfq_init_queue(struct reque
>  	cfqd->cfq_slice_async_rq = cfq_slice_async_rq;
>  	cfqd->cfq_slice_idle = cfq_slice_idle;
>  	cfqd->cfq_desktop = 1;
> +	cfqd->cfq_desktop_dispatch = 1;
> +
> +	cfqd->desktop_dispatch_ts = INITIAL_JIFFIES;
>  	cfqd->hw_tag = 1;
>  
>  	return cfqd;
> @@ -2553,6 +2587,7 @@ SHOW_FUNCTION(cfq_slice_sync_show, cfqd-
>  SHOW_FUNCTION(cfq_slice_async_show, cfqd->cfq_slice[0], 1);
>  SHOW_FUNCTION(cfq_slice_async_rq_show, cfqd->cfq_slice_async_rq, 0);
>  SHOW_FUNCTION(cfq_desktop_show, cfqd->cfq_desktop, 0);
> +SHOW_FUNCTION(cfq_desktop_dispatch_show, cfqd->cfq_desktop_dispatch, 0);
>  #undef SHOW_FUNCTION
>  
>  #define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
> @@ -2585,6 +2620,7 @@ STORE_FUNCTION(cfq_slice_async_store, &c
>  STORE_FUNCTION(cfq_slice_async_rq_store, &cfqd->cfq_slice_async_rq, 1,
>  		UINT_MAX, 0);
>  STORE_FUNCTION(cfq_desktop_store, &cfqd->cfq_desktop, 0, 1, 0);
> +STORE_FUNCTION(cfq_desktop_dispatch_store, &cfqd->cfq_desktop_dispatch, 0, 1, 0);
>  #undef STORE_FUNCTION
>  
>  #define CFQ_ATTR(name) \
> @@ -2601,6 +2637,7 @@ static struct elv_fs_entry cfq_attrs[] =
>  	CFQ_ATTR(slice_async_rq),
>  	CFQ_ATTR(slice_idle),
>  	CFQ_ATTR(desktop),
> +	CFQ_ATTR(desktop_dispatch),
>  	__ATTR_NULL
>  };
>  
> 
