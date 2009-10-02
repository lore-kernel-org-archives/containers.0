From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Thu, 1 Oct 2009 22:57:31 -0400
Message-ID: <20091002025731.GA2738__10816.6838683703$1254452351$gmane$org@redhat.com>
References: <20090929141049.GA12141@redhat.com>
	<20090930.174319.183036386.ryov@valinux.co.jp>
	<20090930110500.GA26631@redhat.com>
	<20091001.154125.104044685.ryov@valinux.co.jp>
	<20091001133109.GA4058@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091001133109.GA4058-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Thu, Oct 01, 2009 at 09:31:09AM -0400, Vivek Goyal wrote:
> On Thu, Oct 01, 2009 at 03:41:25PM +0900, Ryo Tsuruta wrote:
> > Hi Vivek,
> > 
> > Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > On Wed, Sep 30, 2009 at 05:43:19PM +0900, Ryo Tsuruta wrote:
> > > > Hi Vivek,
> > > > 
> > > > Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > > > I was thinking that elevator layer will do the merge of bios. So IO
> > > > > scheduler/elevator can time stamp the first bio in the request as it goes
> > > > > into the disk and again timestamp with finish time once request finishes.
> > > > > 
> > > > > This way higher layer can get an idea how much disk time a group of bios
> > > > > used. But on multi queue, if we dispatch say 4 requests from same queue,
> > > > > then time accounting becomes an issue.
> > > > > 
> > > > > Consider following where four requests rq1, rq2, rq3 and rq4 are
> > > > > dispatched to disk at time t0, t1, t2 and t3 respectively and these
> > > > > requests finish at time t4, t5, t6 and t7. For sake of simlicity assume
> > > > > time elapsed between each of milestones is t. Also assume that all these
> > > > > requests are from same queue/group.
> > > > > 
> > > > >         t0   t1   t2   t3  t4   t5   t6   t7
> > > > >         rq1  rq2  rq3 rq4  rq1  rq2  rq3 rq4
> > > > > 
> > > > > Now higher layer will think that time consumed by group is:
> > > > > 
> > > > > (t4-t0) + (t5-t1) + (t6-t2) + (t7-t3) = 16t
> > > > > 
> > > > > But the time elapsed is only 7t.
> > > > 
> > > > IO controller can know how many requests are issued and still in
> > > > progress. Is it not enough to accumulate the time while in-flight IOs
> > > > exist?
> > > > 
> > > 
> > > That time would not reflect disk time used. It will be follwoing.
> > > 
> > > (time spent waiting in CFQ queues) + (time spent in dispatch queue) +
> > > (time spent in disk)
> > 
> > In the case where multiple IO requests are issued from IO controller,
> > that time measurement is the time from when the first IO request is
> > issued until when the endio is called for the last IO request. Does
> > not it reflect disk time?
> > 
> 
> Not accurately as it will be including the time spent in CFQ queues as
> well as dispatch queue. I will not worry much about dispatch queue time
> but time spent CFQ queues can be significant.
> 
> This is assuming that you are using token based scheme and will be
> dispatching requests from multiple groups at the same time.
> 

Thinking more about it...

Does time based fairness make sense at higher level logical devices?

- Time based fairness generally helps with rotational devices which have
  high seek costs. At higher level we don't even know what is the nature
  of underlying device where IO will ultimately go.

- For time based fairness to work accurately at higher level, most likely
  it will require dispatch from the single group at a time and wait for
  requests to complete from that group and then dispatch from next. 
  Something like CFQ model of queue.  

  Dispatching from single queue/group works well in case of a single
  underlying device where CFQ is operating but at higher level devices
  where typically there will be multiple physical devices under it, it
  might not make sense as it made things more linear and reduced
  parallel processing further. So dispatching from single group at a time
  and waiting before we dispatch from next group will most likely be
  killer for throughput in higher level devices and might not make sense.

  If we don't adopt the policy of dispatch from single group, then we run
  into all the issues of weak isolation between groups, higher latencies,
  preemptions across groups etc.

More I think about the whole issue and desired set of requirements, more
I am convinced that we probably need two io controlling mechanisms. One
which focusses purely on providing bandwidth fairness numbers on high
level devices and the other which works at low level devices with CFQ
and provides good bandwidth shaping, strong isolation, preserves fairness
with-in group and good control on latencies.

Higher level controller will not worry about time based policies. It can
implemente max bw and proportional bw control based on size of IO and
number of IO. 

Lower level controller at CFQ level will implement time based group
scheduling. Keeping it at low level will have the advantage of better
utitlization of hardware in various dm/md configurations (as no throttling
takes place at higher level) but at the cost of not so strict fairness numbers
at higher level. So those who want strict fairness number policies at higher
level devices irrespective of shortcomings, can use that. Others can stick to
lower level controller.

For buffered write control we anyway have to do either something in memory
controller or come up with another cgroup controller which throttles IO
before it goes into cache. Or, in fact we can have a re-look at Andrea
Righi's controller which provided max BW and throttled buffered writes
before they got into page cache and try to provide proportional BW also
there.

Basically I see the space for two IO controllers. At the moment can't
think of a way of coming up with single controller which satisfies all
the requirements. So instead provide two and let user choose one based on
his need.

Any thoughts?

Before finishing this mail, will throw a whacky idea in the ring. I was
going through the request based dm-multipath paper. Will it make sense
to implement request based dm-ioband? So basically we implement all the
group scheduling in CFQ and let dm-ioband implement a request function
to take the request and break it back into bios. This way we can keep
all the group control at one place and also meet most of the requirements.

So request based dm-ioband will have a request in hand once that request
has passed group control and prio control. Because dm-ioband is a device
mapper target, one can put it on higher level devices (practically taking
CFQ at higher level device), and provide fairness there. One can also 
put it on those SSDs which don't use IO scheduler (this is kind of forcing
them to use the IO scheduler.)

I am sure that will be many issues but one big issue I could think of that
CFQ thinks that there is one device beneath it and dipsatches requests
from one queue (in case of idling) and that would kill parallelism at
higher layer and throughput will suffer on many of the dm/md configurations.

Thanks
Vivek

> But if you figure out a way that you dispatch requests from one group only
> at one time and wait for all requests to finish and then let next group
> go, then above can work fairly accurately. In that case it will become
> like CFQ with the only difference that effectively we have one queue per
> group instread of per process.
> 
> > > > > Secondly if a different group is running only single sequential reader,
> > > > > there CFQ will be driving queue depth of 1 and time will not be running
> > > > > faster and this inaccuracy in accounting will lead to unfair share between
> > > > > groups.
> > > > >
> > > > > So we need something better to get a sense which group used how much of
> > > > > disk time.
> > > > 
> > > > It could be solved by implementing the way to pass on such information
> > > > from IO scheduler to higher layer controller.
> > > > 
> > > 
> > > How would you do that? Can you give some details exactly how and what
> > > information IO scheduler will pass to higher level IO controller so that IO
> > > controller can attribute right time to the group.
> > 
> > If you would like to know when the idle timer is expired, how about
> > adding a function to IO controller to be notified it from IO
> > scheduler? IO scheduler calls the function when the timer is expired.
> > 
> 
> This probably can be done. So this is like syncing between lower layers
> and higher layers about when do we start idling and when do we stop it and
> both the layers should be in sync.
> 
> This is something my common layer approach does. Becuase it is so close to
> IO scheuler, I can do it relatively easily.
> 
> One probably can create interfaces to even propogate this information up.
> But this all will probably come into the picture only if we don't use
> token based schemes and come up with something where at one point of time
> dispatch are from one group only.
> 
> > > > > > How about making throttling policy be user selectable like the IO
> > > > > > scheduler and putting it in the higher layer? So we could support
> > > > > > all of policies (time-based, size-based and rate limiting). There
> > > > > > seems not to only one solution which satisfies all users. But I agree
> > > > > > with starting with proportional bandwidth control first. 
> > > > > > 
> > > > > 
> > > > > What are the cases where time based policy does not work and size based
> > > > > policy works better and user would choose size based policy and not timed
> > > > > based one?
> > > > 
> > > > I think that disk time is not simply proportional to IO size. If there
> > > > are two groups whose wights are equally assigned and they issue
> > > > different sized IOs repsectively, the bandwidth of each group would
> > > > not distributed equally as expected. 
> > > > 
> > > 
> > > If we are providing fairness in terms of time, it is fair. If we provide
> > > equal time slots to two processes and if one got more IO done because it
> > > was not wasting time seeking or it issued bigger size IO, it deserves that
> > > higher BW. IO controller will make sure that process gets fair share in
> > > terms of time and exactly how much BW one got will depend on the workload.
> > > 
> > > That's the precise reason that fairness in terms of time is better on
> > > seeky media.
> > 
> > If the seek time is negligible, the bandwidth would not be distributed 
> > according to a proportion of weight settings. I think that it would be
> > unclear for users to understand how bandwidth is distributed. And I
> > also think that seeky media would gradually become obsolete,
> > 
> 
> I can understand that if lesser the seek cost game starts changing and
> probably a size based policy also work decently.
> 
> In that case at some point of time probably CFQ will also need to support
> another mode/policy where fairness is provided in terms of size of IO, if
> it detects a SSD with hardware queuing. Currently it seem to be disabling
> the idling in that case. But this is not very good from fairness point of
> view. I guess if CFQ wants to provide fairness in such cases, it needs to
> dynamically change the shape and start thinking in terms of size of IO.
> 
> So far my testing has been very limited to hard disks connected to my
> computer. I will do some testing on high end enterprise storage and see
> how much do seek matter and how well both the implementations work.
> 
> > > > > I am not against implementing things in higher layer as long as we can
> > > > > ensure tight control on latencies, strong isolation between groups and
> > > > > not break CFQ's class and ioprio model with-in group.
> > > > > 
> > > > > > BTW, I will start to reimplement dm-ioband into block layer.
> > > > > 
> > > > > Can you elaborate little bit on this?
> > > > 
> > > > bio is grabbed in generic_make_request() and throttled as well as
> > > > dm-ioband's mechanism. dmsetup command is not necessary any longer.
> > > > 
> > > 
> > > Ok, so one would not need dm-ioband device now, but same dm-ioband
> > > throttling policies will apply. So until and unless we figure out a
> > > better way, the issues I have pointed out will still exists even in
> > > new implementation.
> > 
> > Yes, those still exist, but somehow I would like to try to solve them.
> > 
> > > > The default value of io_limit on the previous test was 128 (not 192)
> > > > which is equall to the default value of nr_request.
> > > 
> > > Hm..., I used following commands to create two ioband devices.
> > > 
> > > echo "0 $(blockdev --getsize /dev/sdb2) ioband /dev/sdb2 1 0 0 none"
> > > "weight 0 :100" | dmsetup create ioband1
> > > echo "0 $(blockdev --getsize /dev/sdb3) ioband /dev/sdb3 1 0 0 none"
> > > "weight 0 :100" | dmsetup create ioband2
> > > 
> > > Here io_limit value is zero so it should pick default value. Following is
> > > output of "dmsetup table" command.
> > > 
> > > ioband2: 0 89899740 ioband 8:19 1 4 192 none weight 768 :100
> > > ioband1: 0 41961780 ioband 8:18 1 4 192 none weight 768 :100
> > >                                     ^^^^
> > > IIUC, above number 192 is reflecting io_limit? If yes, then default seems
> > > to be 192?
> > 
> > The default vaule has changed since v1.12.0 and increased from 128 to 192.
> > 
> > > > > I set it up to 256 as you suggested. I still see writer starving reader. I
> > > > > have removed "conv=fdatasync" from writer so that a writer is pure buffered
> > > > > writes.
> > > > 
> > > > O.K. You removed "conv=fdatasync", the new dm-ioband handles
> > > > sync/async requests separately, and it solves this
> > > > buffered-write-starves-read problem. I would like to post it soon
> > > > after doing some more test.
> > > > 
> > > > > On top of that can you please give some details how increasing the
> > > > > buffered queue length reduces the impact of writers?
> > > > 
> > > > When the number of in-flight IOs exceeds io_limit, processes which are
> > > > going to issue IOs are made sleep by dm-ioband until all the in-flight
> > > > IOs are finished. But IO scheduler layer can accept IO requests more
> > > > than the value of io_limit, so it was a bottleneck of the throughput.
> > > > 
> > > 
> > > Ok, so it should have been throughput bottleneck but how did it solve the
> > > issue of writer starving the reader as you had mentioned in the mail.
> > 
> > As wrote above, I modified dm-ioband to handle sync/async requests
> > separately, so even if writers do a lot of buffered IOs, readers can
> > issue IOs regardless writers' busyness. Once the IOs are backlogged
> > for throttling, the both sync and async requests are issued according
> > to the other of arrival.
> > 
> 
> Ok, so if both the readers and writers are buffered and some tokens become
> available then these tokens will be divided half and half between readers
> or writer queues?
> 
> > > Secondly, you mentioned that processes are made to sleep once we cross 
> > > io_limit. This sounds like request descriptor facility on requeust queue
> > > where processes are made to sleep.
> > >
> > > There are threads in kernel which don't want to sleep while submitting
> > > bios. For example, btrfs has bio submitting thread which does not want
> > > to sleep hence it checks with device if it is congested or not and not
> > > submit the bio if it is congested.  How would you handle such cases. Have
> > > you implemented any per group congestion kind of interface to make sure
> > > such IO's don't sleep if group is congested.
> > >
> > > Or this limit is per ioband device which every group on the device is
> > > sharing. If yes, then how would you provide isolation between groups 
> > > because if one groups consumes io_limit tokens, then other will simply
> > > be serialized on that device?
> > 
> > There are two kind of limit and both limit the number of IO requests
> > which can be issued simultaneously, but one is for per ioband device, 
> > the other is for per ioband group. The per group limit assigned to
> > each group is calculated by dividing io_limit according to their
> > proportion of weight.
> > 
> > The kernel thread is not made to sleep by the per group limit, because
> > several kinds of kernel threads submit IOs from multiple groups and
> > for multiple devices in a single thread. At this time, the kernel
> > thread is made to sleep by the per device limit only.
> > 
> 
> Interesting. Actually not blocking kernel threads on per group limit
> and instead blocking it only on per device limts sounds like a good idea.
> 
> I can also do something similar and that will take away the need of
> exporting per group congestion interface to higher layers and reduce
> complexity. If some kernel thread does not want to block, these will
> continue to use existing per device/bdi congestion interface.
> 
> Thanks
> Vivek
