From: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Wed, 19 Nov 2008 12:06:55 +0100
Message-ID: <20081119110655.GC20915@gandalf.sssup.it>
References: <20081117142309.GA15564@redhat.com>
	<4922224A.5030502@cn.fujitsu.com>
	<e98e18940811172101na345b6bh5c73f9e657aac5a7@mail.gmail.com>
	<20081118120508.GD15268@gandalf.sssup.it>
	<20081118140751.GA4283@redhat.com>
	<20081118144139.GE15268@gandalf.sssup.it>
	<20081118191208.GJ26308@kernel.dk>
	<20081118211442.GG15268@gandalf.sssup.it>
	<4923716A.5090104@gelato.unsw.edu.au>
	<20081119101701.GA20915@gandalf.sssup.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081119101701.GA20915-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aaron Carroll <aaronc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

> From: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Wed, Nov 19, 2008 11:17:01AM +0100
>
> > From: Aaron Carroll <aaronc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org>
> > Date: Wed, Nov 19, 2008 12:52:42PM +1100
> >
> > Fabio Checconi wrote:
> > >   - To detect hw tagging in BFQ we consider a sample valid iff the
> > >     number of requests that the scheduler could have dispatched (given
> > >     by cfqd->rb_queued + cfqd->rq_in_driver, i.e., the ones still into
> > >     the scheduler plus the ones into the driver) is higher than the
> > >     CFQ_HW_QUEUE_MIN threshold.  This obviously caused no problems
> > >     during testing, but the way CFQ uses now seems a little bit
> > >     strange.
> > 
> > BFQ's tag detection logic is broken in the same way that CFQ's used to
> > be.  Explanation is in this patch:
> > 
> 
> If you look at bfq_update_hw_tag(), the logic introduced by the patch
> you mention is still there; BFQ starts with ->hw_tag = 1, and updates it
> every 32 valid samples.  What changed WRT your patch, apart from the
> number of samples, is that the condition for a sample to be valid is:
> 
>   bfqd->rq_in_driver + bfqd->queued >= 5
> 
> while in your patch it is:
> 
>   cfqd->rq_queued > 5 || cfqd->rq_in_driver > 5
> 
> We preferred the first one because that sum better reflects the number
> of requests that could have been dispatched, and I don't think that this
> is wrong.
> 
> There is a problem, but it's not within the tag detection logic itself.
> From some quick experiments, what happens is that when a process starts,
> CFQ considers it seeky (*), BFQ doesn't.  As a side effect BFQ does not
> always dispatch enough requests to correctly detect tagging.
> 
> At the first seek you cannot tell if the process is going to bee seeky
> or not, and we have chosen to consider it sequential because it improved
> fairness in some sequential workloads (the CIC_SEEKY heuristic is used
> also to determine the idle_window length in [bc]fq_arm_slice_timer()).
> 
> Anyway, we're dealing with heuristics, and they tend to favor some
> workload over other ones.  If recovering this thoughput loss is more
> important than a transient unfairness due to short idling windows assigned
> to sequential processes when they start, I've no problems in switching
> the CIC_SEEKY logic to consider a process seeky when it starts.
> 
> Thank you for testing and for pointing out this issue, we missed it
> in our testing.
> 
> 
> (*) to be correct, the initial classification depends on the position
>     of the first accessed sector.

Sorry, I forgot the patch...  This seems to solve the problem with
your workload here, does it work for you?

[ The magic number would not appear in a definitive fix... ]


---
diff --git a/block/bfq-iosched.c b/block/bfq-iosched.c
index 83e90e9..e9b010f 100644
--- a/block/bfq-iosched.c
+++ b/block/bfq-iosched.c
@@ -1322,10 +1322,12 @@ static void bfq_update_io_seektime(struct bfq_data *bfqd,
 
 	/*
 	 * Don't allow the seek distance to get too large from the
-	 * odd fragment, pagein, etc.
+	 * odd fragment, pagein, etc.  The first request is not
+	 * really a seek, but we consider a cic seeky on creation
+	 * to make the hw_tag detection logic work better.
 	 */
-	if (cic->seek_samples == 0) /* first request, not really a seek */
-		sdist = 0;
+	if (cic->seek_samples == 0)
+		sdist = 8 * 1024 + 1;
 	else if (cic->seek_samples <= 60) /* second&third seek */
 		sdist = min(sdist, (cic->seek_mean * 4) + 2*1024*1024);
 	else
