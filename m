From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Wed, 30 Sep 2009 07:05:00 -0400
Message-ID: <20090930110500.GA26631__41150.8515863263$1254308822$gmane$org@redhat.com>
References: <20090929032255.GA10664@redhat.com>
	<20090929.185653.183056711.ryov@valinux.co.jp>
	<20090929141049.GA12141@redhat.com>
	<20090930.174319.183036386.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090930.174319.183036386.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Sep 30, 2009 at 05:43:19PM +0900, Ryo Tsuruta wrote:
> Hi Vivek,
> 
> Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > I was thinking that elevator layer will do the merge of bios. So IO
> > scheduler/elevator can time stamp the first bio in the request as it goes
> > into the disk and again timestamp with finish time once request finishes.
> > 
> > This way higher layer can get an idea how much disk time a group of bios
> > used. But on multi queue, if we dispatch say 4 requests from same queue,
> > then time accounting becomes an issue.
> > 
> > Consider following where four requests rq1, rq2, rq3 and rq4 are
> > dispatched to disk at time t0, t1, t2 and t3 respectively and these
> > requests finish at time t4, t5, t6 and t7. For sake of simlicity assume
> > time elapsed between each of milestones is t. Also assume that all these
> > requests are from same queue/group.
> > 
> >         t0   t1   t2   t3  t4   t5   t6   t7
> >         rq1  rq2  rq3 rq4  rq1  rq2  rq3 rq4
> > 
> > Now higher layer will think that time consumed by group is:
> > 
> > (t4-t0) + (t5-t1) + (t6-t2) + (t7-t3) = 16t
> > 
> > But the time elapsed is only 7t.
> 
> IO controller can know how many requests are issued and still in
> progress. Is it not enough to accumulate the time while in-flight IOs
> exist?
> 

That time would not reflect disk time used. It will be follwoing.

(time spent waiting in CFQ queues) + (time spent in dispatch queue) +
(time spent in disk)

> > Secondly if a different group is running only single sequential reader,
> > there CFQ will be driving queue depth of 1 and time will not be running
> > faster and this inaccuracy in accounting will lead to unfair share between
> > groups.
> >
> > So we need something better to get a sense which group used how much of
> > disk time.
> 
> It could be solved by implementing the way to pass on such information
> from IO scheduler to higher layer controller.
> 

How would you do that? Can you give some details exactly how and what
information IO scheduler will pass to higher level IO controller so that IO
controller can attribute right time to the group.

> > > How about making throttling policy be user selectable like the IO
> > > scheduler and putting it in the higher layer? So we could support
> > > all of policies (time-based, size-based and rate limiting). There
> > > seems not to only one solution which satisfies all users. But I agree
> > > with starting with proportional bandwidth control first. 
> > > 
> > 
> > What are the cases where time based policy does not work and size based
> > policy works better and user would choose size based policy and not timed
> > based one?
> 
> I think that disk time is not simply proportional to IO size. If there
> are two groups whose wights are equally assigned and they issue
> different sized IOs repsectively, the bandwidth of each group would
> not distributed equally as expected. 
> 

If we are providing fairness in terms of time, it is fair. If we provide
equal time slots to two processes and if one got more IO done because it
was not wasting time seeking or it issued bigger size IO, it deserves that
higher BW. IO controller will make sure that process gets fair share in
terms of time and exactly how much BW one got will depend on the workload.

That's the precise reason that fairness in terms of time is better on
seeky media.

> > I am not against implementing things in higher layer as long as we can
> > ensure tight control on latencies, strong isolation between groups and
> > not break CFQ's class and ioprio model with-in group.
> > 
> > > BTW, I will start to reimplement dm-ioband into block layer.
> > 
> > Can you elaborate little bit on this?
> 
> bio is grabbed in generic_make_request() and throttled as well as
> dm-ioband's mechanism. dmsetup command is not necessary any longer.
> 

Ok, so one would not need dm-ioband device now, but same dm-ioband
throttling policies will apply. So until and unless we figure out a
better way, the issues I have pointed out will still exists even in
new implementation.

> > > > Fairness for higher level logical devices
> > > > =========================================
> > > > Do we want good fairness numbers for higher level logical devices also
> > > > or it is sufficient to provide fairness at leaf nodes. Providing fairness
> > > > at leaf nodes can help us use the resources optimally and in the process
> > > > we can get fairness at higher level also in many of the cases.
> > > 
> > > We should also take care of block devices which provide their own
> > > make_request_fn() and not use a IO scheduler. We can't use the leaf
> > > nodes approach to such devices.
> > > 
> > 
> > I am not sure how big an issue is this. This can be easily solved by
> > making use of NOOP scheduler by these devices. What are the reasons for
> > these devices to not use even noop? 
> 
> I'm not sure why the developers of the device driver choose their own
> way, and the driver is provided in binary form, so we can't modify it.
> 
> > > > Fairness with-in group
> > > > ======================
> > > > One of the issues with higher level controller is that how to do fair
> > > > throttling so that fairness with-in group is not impacted. Especially
> > > > the case of making sure that we don't break the notion of ioprio of the
> > > > processes with-in group.
> > > 
> > > I ran your test script to confirm that the notion of ioprio was not
> > > broken by dm-ioband. Here is the results of the test.
> > > https://lists.linux-foundation.org/pipermail/containers/2009-May/017834.html
> > > 
> > > I think that the time period during which dm-ioband holds IO requests
> > > for throttling would be too short to break the notion of ioprio.
> > 
> > Ok, I re-ran that test. Previously default io_limit value was 192 and now
> 
> The default value of io_limit on the previous test was 128 (not 192)
> which is equall to the default value of nr_request.

Hm..., I used following commands to create two ioband devices.

echo "0 $(blockdev --getsize /dev/sdb2) ioband /dev/sdb2 1 0 0 none"
"weight 0 :100" | dmsetup create ioband1
echo "0 $(blockdev --getsize /dev/sdb3) ioband /dev/sdb3 1 0 0 none"
"weight 0 :100" | dmsetup create ioband2

Here io_limit value is zero so it should pick default value. Following is
output of "dmsetup table" command.

ioband2: 0 89899740 ioband 8:19 1 4 192 none weight 768 :100
ioband1: 0 41961780 ioband 8:18 1 4 192 none weight 768 :100
                                    ^^^^
IIUC, above number 192 is reflecting io_limit? If yes, then default seems
to be 192?

> 
> > I set it up to 256 as you suggested. I still see writer starving reader. I
> > have removed "conv=fdatasync" from writer so that a writer is pure buffered
> > writes.
> 
> O.K. You removed "conv=fdatasync", the new dm-ioband handles
> sync/async requests separately, and it solves this
> buffered-write-starves-read problem. I would like to post it soon
> after doing some more test.
> 
> > On top of that can you please give some details how increasing the
> > buffered queue length reduces the impact of writers?
> 
> When the number of in-flight IOs exceeds io_limit, processes which are
> going to issue IOs are made sleep by dm-ioband until all the in-flight
> IOs are finished. But IO scheduler layer can accept IO requests more
> than the value of io_limit, so it was a bottleneck of the throughput.
> 

Ok, so it should have been throughput bottleneck but how did it solve the
issue of writer starving the reader as you had mentioned in the mail.

Secondly, you mentioned that processes are made to sleep once we cross 
io_limit. This sounds like request descriptor facility on requeust queue
where processes are made to sleep.

There are threads in kernel which don't want to sleep while submitting
bios. For example, btrfs has bio submitting thread which does not want
to sleep hence it checks with device if it is congested or not and not
submit the bio if it is congested.  How would you handle such cases. Have
you implemented any per group congestion kind of interface to make sure
such IO's don't sleep if group is congested.

Or this limit is per ioband device which every group on the device is
sharing. If yes, then how would you provide isolation between groups 
because if one groups consumes io_limit tokens, then other will simply
be serialized on that device?

> > IO Prio issue
> > --------------
> > I ran another test where two ioband devices were created of weight 100 
> > each on two partitions. In first group 4 readers were launched. Three
> > readers are of class BE and prio 7, fourth one is of class BE prio 0. In
> > group2, I launched a buffered writer.
> > 
> > One would expect that prio0 reader gets more bandwidth as compared to
> > prio 4 readers and prio 7 readers will get more or less same bw. Looks like
> > that is not happening. Look how vanilla CFQ provides much more bandwidth
> > to prio0 reader as compared to prio7 reader and how putting them in the
> > group reduces the difference betweej prio0 and prio7 readers.
> > 
> > Following are the results.
> 
> O.K. I'll try to do more test with dm-ioband according to your
> comments especially working with CFQ. Thanks for pointing out.
> 
> Thanks,
> Ryo Tsuruta
