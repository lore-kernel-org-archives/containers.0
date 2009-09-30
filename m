From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Tue, 29 Sep 2009 23:11:25 -0400
Message-ID: <20090930031125.GA24756__1970.51179497993$1254280386$gmane$org@redhat.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<e98e18940909281737q142c788dpd20b8bdc05dd0eff@mail.gmail.com>
	<20090929032255.GA10664@redhat.com>
	<20090929.185653.183056711.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090929.185653.183056711.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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

On Tue, Sep 29, 2009 at 06:56:53PM +0900, Ryo Tsuruta wrote:
> Hi Vivek and all,
> 
> Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Mon, Sep 28, 2009 at 05:37:28PM -0700, Nauman Rafique wrote:
> 
> > > We are starting from a point where there is no cgroup based IO
> > > scheduling in the kernel. And it is probably not reasonable to satisfy
> > > all IO scheduling related requirements in one patch set. We can start
> > > with something simple, and build on top of that. So a very simple
> > > patch set that enables cgroup based proportional scheduling for CFQ
> > > seems like the way to go at this point.
> > 
> > Sure, we can start with CFQ only. But a bigger question we need to answer
> > is that is CFQ the right place to solve the issue? Jens, do you think 
> > that CFQ is the right place to solve the problem?
> > 
> > Andrew seems to favor a high level approach so that IO schedulers are less
> > complex and we can provide fairness at high level logical devices also. 
> 
> I'm not in favor of expansion of CFQ, because some enterprise storages
> are better performed with NOOP rather than CFQ, and I think bandwidth
> control is needed much more for such storage system. Is it easy to
> support other IO schedulers even if a new IO scheduler is introduced?
> I would like to know a bit more specific about Namuman's scheduler design.
> 
> > I will again try to summarize my understanding so far about the pros/cons
> > of each approach and then we can take the discussion forward.
> 
> Good summary. Thanks for your work.
> 
> > Fairness in terms of size of IO or disk time used
> > =================================================
> > On a seeky media, fairness in terms of disk time can get us better results
> > instead fairness interms of size of IO or number of IO.
> > 
> > If we implement some kind of time based solution at higher layer, then 
> > that higher layer should know who used how much of time each group used. We
> > can probably do some kind of timestamping in bio to get a sense when did it
> > get into disk and when did it finish. But on a multi queue hardware there
> > can be multiple requests in the disk either from same queue or from differnet
> > queues and with pure timestamping based apparoch, so far I could not think
> > how at high level we will get an idea who used how much of time.
> 
> IIUC, could the overlap time be calculated from time-stamp on a multi
> queue hardware?
>  
> > So this is the first point of contention that how do we want to provide
> > fairness. In terms of disk time used or in terms of size of IO/number of
> > IO.
> >
> > Max bandwidth Controller or Proportional bandwidth controller
> > =============================================================
> > What is our primary requirement here? A weight based proportional
> > bandwidth controller where we can use the resources optimally and any
> > kind of throttling kicks in only if there is contention for the disk.
> > 
> > Or we want max bandwidth control where a group is not allowed to use the
> > disk even if disk is free. 
> > 
> > Or we need both? I would think that at some point of time we will need
> > both but we can start with proportional bandwidth control first.
> 
> How about making throttling policy be user selectable like the IO
> scheduler and putting it in the higher layer? So we could support
> all of policies (time-based, size-based and rate limiting). There
> seems not to only one solution which satisfies all users. But I agree
> with starting with proportional bandwidth control first. 
> 
> BTW, I will start to reimplement dm-ioband into block layer.
> 
> > Fairness for higher level logical devices
> > =========================================
> > Do we want good fairness numbers for higher level logical devices also
> > or it is sufficient to provide fairness at leaf nodes. Providing fairness
> > at leaf nodes can help us use the resources optimally and in the process
> > we can get fairness at higher level also in many of the cases.
> 
> We should also take care of block devices which provide their own
> make_request_fn() and not use a IO scheduler. We can't use the leaf
> nodes approach to such devices.
> 
> > But do we want strict fairness numbers on higher level logical devices
> > even if it means sub-optimal usage of unerlying phsical devices?
> > 
> > I think that for proportinal bandwidth control, it should be ok to provide
> > fairness at higher level logical device but for max bandwidth control it
> > might make more sense to provide fairness at higher level. Consider a
> > case where from a striped device a customer wants to limit a group to
> > 30MB/s and in case of leaf node control, if every leaf node provides
> > 30MB/s, it might accumulate to much more than specified rate at logical
> > device.
> >
> > Latency Control and strong isolation between groups
> > ===================================================
> > Do we want a good isolation between groups and better latencies and
> > stronger isolation between groups?
> > 
> > I think if problem is solved at IO scheduler level, we can achieve better
> > latency control and hence stronger isolation between groups.
> > 
> > Higher level solutions should find it hard to provide same kind of latency
> > control and isolation between groups as IO scheduler based solution.
> 
> Why do you think that the higher level solution is hard to provide it? 
> I think that it is a matter of how to implement throttling policy.
> 
> > Fairness for buffered writes
> > ============================
> > Doing io control at any place below page cache has disadvantage that page
> > cache might not dispatch more writes from higher weight group hence higher
> > weight group might not see more IO done. Andrew says that we don't have
> > a solution to this problem in kernel and he would like to see it handled
> > properly.
> > 
> > Only way to solve this seems to be to slow down the writers before they
> > write into page cache. IO throttling patch handled it by slowing down 
> > writer if it crossed max specified rate. Other suggestions have come in
> > the form of dirty_ratio per memory cgroup or a separate cgroup controller
> > al-together where some kind of per group write limit can be specified.
> > 
> > So if solution is implemented at IO scheduler layer or at device mapper
> > layer, both shall have to rely on another controller to be co-mounted
> > to handle buffered writes properly.
> >
> > Fairness with-in group
> > ======================
> > One of the issues with higher level controller is that how to do fair
> > throttling so that fairness with-in group is not impacted. Especially
> > the case of making sure that we don't break the notion of ioprio of the
> > processes with-in group.
> 
> I ran your test script to confirm that the notion of ioprio was not
> broken by dm-ioband. Here is the results of the test.
> https://lists.linux-foundation.org/pipermail/containers/2009-May/017834.html
> 
> I think that the time period during which dm-ioband holds IO requests
> for throttling would be too short to break the notion of ioprio.
> 

Hi Ryo,

I am doing some more tests to see how do we maintain notion of prio
with-in group.

I have created two ioband devies ioband1 and ioband2 of weight 100 each on
two disk partitions. On one partition/device (ioband1) a buffered writer is
doing writeout and on other partition I launch one prio0 reader and
increasing number of prio4 readers using fio and let it run for 30 
seconds and see how BW got distributed between prio0 and prio4 processes.

Note, here readers are doing direct IO.

I did this test with vanilla CFQ and with dm-ioband + cfq.

With vanilla CFQ
----------------
<---------prio4 readers --------------------------> <---prio0 reader--->
nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency Agg-bdwidth Max-latency 
1   12892KiB/s  12892KiB/s  12892KiB/s  409K usec   14705KiB/s  252K usec   
2   5667KiB/s   5637KiB/s   11302KiB/s  717K usec   17555KiB/s  339K usec   
4   4395KiB/s   4173KiB/s   17027KiB/s  933K usec   12437KiB/s  553K usec   
8   2652KiB/s   2391KiB/s   20268KiB/s  1410K usec  9482KiB/s   685K usec   
16  1653KiB/s   1413KiB/s   24035KiB/s  2418K usec  5860KiB/s   1027K usec  

Note, as we increase number of prio4 readers, prio0 processes aggregate
bandwidth goes down (nr=2 seems to be only exception) but it still
maintains more BW than prio4 process.

Also note that as we increase number of prio4 readers, their aggreagate
bandwidth goes up which is expected. 

With dm-ioband
--------------
<---------prio4 readers --------------------------> <---prio0 reader--->
nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency Agg-bdwidth Max-latency 
1   11242KiB/s  11242KiB/s  11242KiB/s  415K usec   3884KiB/s   244K usec   
2   8110KiB/s   6236KiB/s   14345KiB/s  304K usec   320KiB/s    125K usec   
4   6898KiB/s   622KiB/s    11059KiB/s  206K usec   503KiB/s    201K usec   
8   345KiB/s    47KiB/s     850KiB/s    342K usec   8350KiB/s   164K usec   
16  28KiB/s     28KiB/s     451KiB/s    688 msec    5092KiB/s   306K usec   

Looking at the output with dm-ioband, it seems to be all over the place.
Look at aggregate bandwidth of prio0 reader and how wildly it is swinging.
It first goes down and then suddenly jumps up way high.

Similiarly look at aggregate bandwidth of prio4 readers and the moment we
hit 8 readers, it suddenly tanks.

Look at prio4 reader and prio 7 reader BW with 16 prio4 processes running.
prio4 process gets 28Kb/s and prio 0 process gets 5MB/s.

Can you please look into it? It looks like we got serious issues w.r.t
to fairness and bandwidth distribution with-in group.

Thanks
Vivek


> > Especially io throttling patch was very bad in terms of prio with-in 
> > group where throttling treated everyone equally and difference between
> > process prio disappeared.
> >
> > Reads Vs Writes
> > ===============
> > A higher level control most likely will change the ratio in which reads
> > and writes are dispatched to disk with-in group. It used to be decided
> > by IO scheduler so far but with higher level groups doing throttling and
> > possibly buffering the bios and releasing them later, they will have to
> > come up with their own policy on in what proportion reads and writes
> > should be dispatched. In case of IO scheduler based control, all the
> > queuing takes place at IO scheduler and it still retains control of
> > in what ration reads and writes should be dispatched.
> 
> I don't think it is a concern. The current implementation of dm-ioband
> is that sync/async IO requests are handled separately and the
> backlogged IOs are released according to the order of arrival if both
> sync and async requests are backlogged.
> 
> > Summary
> > =======
> > 
> > - An io scheduler based io controller can provide better latencies,
> >   stronger isolation between groups, time based fairness and will not
> >   interfere with io schedulers policies like class, ioprio and
> >   reader vs writer issues.
> > 
> >   But it can gunrantee fairness at higher logical level devices.
> >   Especially in case of max bw control, leaf node control does not sound
> >   to be the most appropriate thing.
> > 
> > - IO throttling provides max bw control in terms of absolute rate. It has
> >   the advantage that it can provide control at higher level logical device
> >   and also control buffered writes without need of additional controller
> >   co-mounted.
> > 
> >   But it does only max bw control and not proportion control so one might
> >   not be using resources optimally. It looses sense of task prio and class
> >   with-in group as any of the task can be throttled with-in group. Because
> >   throttling does not kick in till you hit the max bw limit, it should find
> >   it hard to provide same latencies as io scheduler based control.
> > 
> > - dm-ioband also has the advantage that it can provide fairness at higher
> >   level logical devices.
> > 
> >   But, fairness is provided only in terms of size of IO or number of IO.
> >   No time based fairness. It is very throughput oriented and does not 
> >   throttle high speed group if other group is running slow random reader.
> >   This results in bad latnecies for random reader group and weaker
> >   isolation between groups.
> 
> A new policy can be added to dm-ioband. Actually, range-bw policy,
> which provides min and max bandwidth control, does time-based
> throttling. Moreover there is room for improvement for existing
> policies. The write-starve-read issue you pointed out will be solved
> soon.
> 
> >   Also it does not provide fairness if a group is not continuously
> >   backlogged. So if one is running 1-2 dd/sequential readers in the group,
> >   one does not get fairness until workload is increased to a point where
> >   group becomes continuously backlogged. This also results in poor
> >   latencies and limited fairness.
> 
> This is intended to efficiently use bandwidth of underlying devices
> when IO load is low.
>  
> > At this point of time it does not look like a single IO controller all
> > the scenarios/requirements. This means few things to me.
> > 
> > - Drop some of the requirements and go with one implementation which meets
> >   those reduced set of requirements.
> >
> > - Have more than one IO controller implementation in kenrel. One for lower
> >   level control for better latencies, stronger isolation and optimal resource
> >   usage and other one for fairness at higher level logical devices and max
> >   bandwidth control. 
> > 
> >   And let user decide which one to use based on his/her needs. 
> > 
> > - Come up with more intelligent way of doing IO control where single
> >   controller covers all the cases.
> > 
> > At this point of time, I am more inclined towards option 2 of having more
> > than one implementation in kernel. :-) (Until and unless we can brainstrom
> > and come up with ideas to make option 3 happen).
> >
> > > It would be great if we discuss our plans on the mailing list, so we
> > > can get early feedback from everyone.
> >  
> > This is what comes to my mind so far. Please add to the list if I have missed
> > some points. Also correct me if I am wrong about the pros/cons of the
> > approaches.
> >
> > Thoughts/ideas/opinions are welcome...
> > 
> > Thanks
> > Vivek
> 
> Thanks,
> Ryo Tsuruta
