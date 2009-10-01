From: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Thu, 01 Oct 2009 09:33:25 +0200
Message-ID: <1254382405.7595.9.camel__6667.36233183673$1254382547$gmane$org@marge.simson.net>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<4ABC28DE.7050809@datenparkplatz.de>
	<20090925202636.GC15007@redhat.com>
	<1253976676.7005.40.camel@marge.simson.net>
	<1254034500.7933.6.camel@marge.simson.net>
	<20090927164235.GA23126@kernel.dk>
	<1254340730.7695.32.camel@marge.simson.net>
	<1254341139.7695.36.camel@marge.simson.net>
	<20090930202447.GA28236@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090930202447.GA28236-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2009-09-30 at 16:24 -0400, Vivek Goyal wrote:
> On Wed, Sep 30, 2009 at 10:05:39PM +0200, Mike Galbraith wrote:
> > 
> >  
> > >  		/*
> > > +		 * We may have seeky queues, don't throttle up just yet.
> > > +		 */
> > > +		if (time_before(jiffies, cfqd->last_seeker + CIC_SEEK_THR))
> > > +			return 0;
> > > +
> > 
> > bzzzt.  Window too large, but the though is to let them overload, but
> > not instantly.
> > 
> 
> CIC_SEEK_THR is 8K jiffies so that would be 8seconds on 1000HZ system. Try
> using one "slice_idle" period of 8 ms. But it might turn out to be too
> short depending on the disk speed.

Yeah, it is too short, as is even _400_ ms.  Trouble is, by the time
some new task is determined to be seeky, the damage is already done.

The below does better, though not as well as "just say no to overload"
of course ;-)

I have a patchlet from Corrado to test, likely better time investment
than poking this darn thing with sharp sticks.

	-Mike

grep elapsed testo.log
    0.894345911  seconds time elapsed <== solo seeky test measurement
    3.732472877  seconds time elapsed
    3.208443735  seconds time elapsed
    4.249776673  seconds time elapsed
    2.763449260  seconds time elapsed
    4.235271019  seconds time elapsed

(3.73 + 3.20 + 4.24 + 2.76 + 4.23) / 5 / 0.89 = 4... darn.

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index e2a9b92..44a888d 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -174,6 +174,8 @@ struct cfq_data {
 	unsigned int cfq_slice_async_rq;
 	unsigned int cfq_slice_idle;
 
+	unsigned long od_stamp;
+
 	struct list_head cic_list;
 
 	/*
@@ -1296,19 +1298,26 @@ static int cfq_dispatch_requests(struct request_queue *q, int force)
 	/*
 	 * Drain async requests before we start sync IO
 	 */
-	if (cfq_cfqq_idle_window(cfqq) && cfqd->rq_in_driver[BLK_RW_ASYNC])
+	if (cfq_cfqq_idle_window(cfqq) && cfqd->rq_in_driver[BLK_RW_ASYNC]) {
+		cfqd->od_stamp = jiffies;
 		return 0;
+	}
 
 	/*
 	 * If this is an async queue and we have sync IO in flight, let it wait
 	 */
-	if (cfqd->sync_flight && !cfq_cfqq_sync(cfqq))
+	if (cfqd->sync_flight && !cfq_cfqq_sync(cfqq)) {
+		cfqd->od_stamp = jiffies;
 		return 0;
+	}
 
 	max_dispatch = cfqd->cfq_quantum;
 	if (cfq_class_idle(cfqq))
 		max_dispatch = 1;
 
+	if (cfqd->busy_queues > 1)
+		cfqd->od_stamp = jiffies;
+
 	/*
 	 * Does this cfqq already have too much IO in flight?
 	 */
@@ -1326,6 +1335,12 @@ static int cfq_dispatch_requests(struct request_queue *q, int force)
 			return 0;
 
 		/*
+		 * Don't start overloading until we've been alone for a bit.
+		 */
+		if (time_before(jiffies, cfqd->od_stamp + cfq_slice_sync))
+			return 0;
+
+		/*
 		 * we are the only queue, allow up to 4 times of 'quantum'
 		 */
 		if (cfqq->dispatched >= 4 * max_dispatch)
@@ -1941,7 +1956,7 @@ static void
 cfq_update_idle_window(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 		       struct cfq_io_context *cic)
 {
-	int old_idle, enable_idle;
+	int old_idle, enable_idle, seeky = 0;
 
 	/*
 	 * Don't idle for async or idle io prio class
@@ -1949,10 +1964,19 @@ cfq_update_idle_window(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 	if (!cfq_cfqq_sync(cfqq) || cfq_class_idle(cfqq))
 		return;
 
+	if (cfqd->hw_tag) {
+		if (CIC_SEEKY(cic))
+			seeky = 1;
+		/*
+		 * If known or incalculable seekiness, delay.
+		 */
+		if (seeky || !sample_valid(cic->seek_samples))
+			cfqd->od_stamp = jiffies;
+	}
+
 	enable_idle = old_idle = cfq_cfqq_idle_window(cfqq);
 
-	if (!atomic_read(&cic->ioc->nr_tasks) || !cfqd->cfq_slice_idle ||
-	    (cfqd->hw_tag && CIC_SEEKY(cic)))
+	if (!atomic_read(&cic->ioc->nr_tasks) || !cfqd->cfq_slice_idle || seeky)
 		enable_idle = 0;
 	else if (sample_valid(cic->ttime_samples)) {
 		if (cic->ttime_mean > cfqd->cfq_slice_idle)
@@ -2482,6 +2506,7 @@ static void *cfq_init_queue(struct request_queue *q)
 	cfqd->cfq_slice_async_rq = cfq_slice_async_rq;
 	cfqd->cfq_slice_idle = cfq_slice_idle;
 	cfqd->hw_tag = 1;
+	cfqd->od_stamp = INITIAL_JIFFIES;
 
 	return cfqd;
 }
