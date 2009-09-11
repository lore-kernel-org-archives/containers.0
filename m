From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] IO scheduler based IO controller V9
Date: Fri, 11 Sep 2009 11:01:35 -0400
Message-ID: <20090911150135.GA10297__44789.5398283892$1252681383$gmane$org@redhat.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<4AA918C1.6070907@redhat.com> <20090910205227.GB3617@redhat.com>
	<20090910205657.GD3617@redhat.com> <4AAA4DA7.8010909@redhat.com>
	<20090911143040.GB6758@redhat.com>
	<20090911144341.GC6758@redhat.com> <4AAA64F6.2050800@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AAA64F6.2050800-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jerome Marchand <jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Sep 11, 2009 at 04:55:50PM +0200, Jerome Marchand wrote:
> Vivek Goyal wrote:
> > On Fri, Sep 11, 2009 at 10:30:40AM -0400, Vivek Goyal wrote:
> >> On Fri, Sep 11, 2009 at 03:16:23PM +0200, Jerome Marchand wrote:
> >>> Vivek Goyal wrote:
> >>>> On Thu, Sep 10, 2009 at 04:52:27PM -0400, Vivek Goyal wrote:
> >>>>> On Thu, Sep 10, 2009 at 05:18:25PM +0200, Jerome Marchand wrote:
> >>>>>> Vivek Goyal wrote:
> >>>>>>> Hi All,
> >>>>>>>
> >>>>>>> Here is the V9 of the IO controller patches generated on top of 2.6.31-rc7.
> >>>>>>  
> >>>>>> Hi Vivek,
> >>>>>>
> >>>>>> I've run some postgresql benchmarks for io-controller. Tests have been
> >>>>>> made with 2.6.31-rc6 kernel, without io-controller patches (when
> >>>>>> relevant) and with io-controller v8 and v9 patches.
> >>>>>> I set up two instances of the TPC-H database, each running in their
> >>>>>> own io-cgroup. I ran two clients to these databases and tested on each
> >>>>>> that simple request:
> >>>>>> $ select count(*) from LINEITEM;
> >>>>>> where LINEITEM is the biggest table of TPC-H (6001215 entries,
> >>>>>> 720MB). That request generates a steady stream of IOs.
> >>>>>>
> >>>>>> Time is measure by psql (\timing switched on). Each test is run twice
> >>>>>> or more if there is any significant difference between the first two
> >>>>>> runs. Before each run, the cache is flush:
> >>>>>> $ echo 3 > /proc/sys/vm/drop_caches
> >>>>>>
> >>>>>>
> >>>>>> Results with 2 groups of same io policy (BE) and same io weight (1000):
> >>>>>>
> >>>>>> 	w/o io-scheduler	io-scheduler v8		io-scheduler v9
> >>>>>> 	first	second		first	second		first	second
> >>>>>> 	DB	DB		DB	DB		DB	DB
> >>>>>>
> >>>>>> CFQ	48.4s	48.4s		48.2s	48.2s		48.1s	48.5s
> >>>>>> Noop	138.0s	138.0s		48.3s	48.4s		48.5s	48.8s
> >>>>>> AS	46.3s	47.0s		48.5s	48.7s		48.3s	48.5s
> >>>>>> Deadl.	137.1s	137.1s		48.2s	48.3s		48.3s	48.5s
> >>>>>>
> >>>>>> As you can see, there is no significant difference for CFQ
> >>>>>> scheduler.
> >>>>> Thanks Jerome.  
> >>>>>
> >>>>>> There is big improvement for noop and deadline schedulers
> >>>>>> (why is that happening?).
> >>>>> I think because now related IO is in a single queue and it gets to run
> >>>>> for 100ms or so (like CFQ). So previously, IO from both the instances
> >>>>> will go into a single queue which should lead to more seeks as requests
> >>>>> from two groups will kind of get interleaved.
> >>>>>
> >>>>> With io controller, both groups have separate queues so requests from
> >>>>> both the data based instances will not get interleaved (This almost
> >>>>> becomes like CFQ where ther are separate queues for each io context
> >>>>> and for sequential reader, one io context gets to run nicely for certain
> >>>>> ms based on its priority).
> >>>>>
> >>>>>> The performance with anticipatory scheduler
> >>>>>> is a bit lower (~4%).
> >>>>>>
> >>>> Hi Jerome, 
> >>>>
> >>>> Can you also run the AS test with io controller patches and both the
> >>>> database in root group (basically don't put them in to separate group). I 
> >>>> suspect that this regression might come from that fact that we now have
> >>>> to switch between queues and in AS we wait for request to finish from
> >>>> previous queue before next queue is scheduled in and probably that is
> >>>> slowing down things a bit.., just a wild guess..
> >>>>
> >>> Hi Vivek,
> >>>
> >>> I guess that's not the reason. I got 46.6s for both DB in root group with
> >>> io-controller v9 patches. I also rerun the test with DB in different groups
> >>> and found about the same result as above (48.3s and 48.6s).
> >>>
> >> Hi Jerome,
> >>
> >> Ok, so when both the DB's are in root group (with io-controller V9
> >> patches), then you get 46.6 seconds time for both the DBs. That means there
> >> is no regression in this case. In this case there is only one queue of 
> >> root group and AS is running timed read/write batches on this queue.
> >>
> >> But when both the DBs are put in separate groups then you get 48.3 and
> >> 48.6 seconds respectively and we see regression. In this case there are
> >> two queues belonging to each group. Elevator layer takes care of queue
> >> group queue switch and AS runs timed read/write batches on these queues.
> >>
> >> If it is correct, then it does not exclude the possiblity that it is queue
> >> switching overhead between groups?
> >>  
> > 
> > Does your hard drive support command queuing? May be we are driving deeper
> > queue depths for reads and during queue switch we will wait for requests
> > to finish from last queue to finish before next queue is scheduled in (for
> > AS) and that probably will cause more delay if we are driving deeper queue
> > depth.
> > 
> > Can you please set queue depth to "1" (/sys/block/<disk>/device/queue_depth) on
> > this disk and see time consumed in two cases are same or different. I think
> > setting depth to "1" will bring down overall throughput but if times are same
> > in two cases, at least we will know where the delay is coming from.
> > 
> > Thanks
> > Vivek
> 
> It looks like command queuing is supported but disabled. Queue depth is already 1
> and the file /sys/block/<disk>/device/queue_depth is read-only.

Hmm..., time to run blktraces and in both the cases and compare the two
cases and see what's the issue.

Would be great if you can capture and look at traces. Otherwise I will try
to do it sometime soon..

Thanks
Vivek
