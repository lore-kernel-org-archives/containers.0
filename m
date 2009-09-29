From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Tue, 29 Sep 2009 10:10:49 -0400
Message-ID: <20090929141049.GA12141__26736.9093643085$1254233587$gmane$org@redhat.com>
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

The new design is essentially the old design. Except the fact that
suggestion is that in the first step instead of covering all the 4 IO
schedulers, first cover only CFQ and then later others. 

So providing fairness for NOOP is not an issue. Even if we introduce new
IO schedulers down the line, I can't think of a reason why can't we cover
that too with common layer.

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

So far could not think of anything clean. Do you have something in mind.

I was thinking that elevator layer will do the merge of bios. So IO
scheduler/elevator can time stamp the first bio in the request as it goes
into the disk and again timestamp with finish time once request finishes.

This way higher layer can get an idea how much disk time a group of bios
used. But on multi queue, if we dispatch say 4 requests from same queue,
then time accounting becomes an issue.

Consider following where four requests rq1, rq2, rq3 and rq4 are
dispatched to disk at time t0, t1, t2 and t3 respectively and these
requests finish at time t4, t5, t6 and t7. For sake of simlicity assume
time elapsed between each of milestones is t. Also assume that all these
requests are from same queue/group.

        t0   t1   t2   t3  t4   t5   t6   t7
        rq1  rq2  rq3 rq4  rq1  rq2  rq3 rq4

Now higher layer will think that time consumed by group is:

(t4-t0) + (t5-t1) + (t6-t2) + (t7-t3) = 16t

But the time elapsed is only 7t.

Secondly if a different group is running only single sequential reader,
there CFQ will be driving queue depth of 1 and time will not be running
faster and this inaccuracy in accounting will lead to unfair share between
groups.

So we need something better to get a sense which group used how much of
disk time.

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

What are the cases where time based policy does not work and size based
policy works better and user would choose size based policy and not timed
based one?

I am not against implementing things in higher layer as long as we can
ensure tight control on latencies, strong isolation between groups and
not break CFQ's class and ioprio model with-in group.

> BTW, I will start to reimplement dm-ioband into block layer.

Can you elaborate little bit on this?

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

I am not sure how big an issue is this. This can be easily solved by
making use of NOOP scheduler by these devices. What are the reasons for
these devices to not use even noop? 

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

So far both in dm-ioband and IO throttling solution I have seen that
higher layer implements some of kind leaky bucket/token bucket algorithm,
which inherently allows IO from all the competing groups until they run
out of tokens and then these groups are made to wait till fresh tokens are
issued.

That means, most of the times, IO scheduler will see requests from more
than one group at the same time and that will be the source of weak
isolation between groups.

Consider following simple examples. Assume there are two groups and one
contains 16 random readers and other contains 1 random reader.

		G1	G2
	       16RR	1RR 

Now it might happen that IO scheduler sees requests from all the 17 RR
readers at the same time. (Throttling probably will kick in later because
you would like to give one group a nice slice of 100ms otherwise
sequential readers will suffer a lot and disk will become seek bound).

So CFQ will dispatch requests (at least one), from each of the 16 random
readers first and then from 1 random reader in group 2 and this increases
the max latency for the application in group 2 and provides weak
isolation.

There will also be additional issues with CFQ preemtpion logic. CFQ will
have no knowledge of groups and it will do cross group preemtptions. For
example if a meta data request comes in group1, it will preempt any of
the queue being served in other groups. So somebody doing "find . *" or
"cat <small files>" in one group will keep on preempting a sequential
reader in other group. Again this will probably lead to higher max
latencies.  

Note, even if CFQ does not enable idling on random readers, and expires
queue after single dispatch, seeking time between queues can be
significant. Similarly, if instead of 16 random reders we had 16 random
synchronous writers we will have seek time issue as well as writers can
often dump bigger requests which also adds to latency.

This latency issue can be solved if we dispatch requests only from one
group for a certain time of time and then move to next group. (Something
what common layer is doing).

If we go for only single group dispatching requests, then we shall have
to implemnt some of the preemption semantics also in higher layer because
in certain cases we want to do preemption across the groups. Like RT task
group preemting non-RT task group etc.

Once we go deeper into implementation, I think we will find more issues.

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

Ok, I re-ran that test. Previously default io_limit value was 192 and now
I set it up to 256 as you suggested. I still see writer starving reader. I
have removed "conv=fdatasync" from writer so that a writer is pure buffered
writes.

With vanilla CFQ
----------------
reader: 578867200 bytes (579 MB) copied, 10.803 s, 53.6 MB/s
writer: 2147483648 bytes (2.1 GB) copied, 39.4596 s, 54.4 MB/s

with dm-ioband default io_limit=192
-----------------------------------
writer: 2147483648 bytes (2.1 GB) copied, 46.2991 s, 46.4 MB/s
reader: 578867200 bytes (579 MB) copied, 52.1419 s, 11.1 MB/s

ioband2: 0 40355280 ioband 8:50 1 4 192 none weight 768 :100
ioband1: 0 37768752 ioband 8:49 1 4 192 none weight 768 :100

with dm-ioband default io_limit=256
-----------------------------------
reader: 578867200 bytes (579 MB) copied, 42.6231 s, 13.6 MB/s
writer: 2147483648 bytes (2.1 GB) copied, 49.1678 s, 43.7 MB/s

ioband2: 0 40355280 ioband 8:50 1 4 256 none weight 1024 :100
ioband1: 0 37768752 ioband 8:49 1 4 256 none weight 1024 :100

Notice that with vanilla CFQ, reader is taking 10 seconds to finish and
with dm-ioband it takes more than 40 seconds to finish. So writer is still
starving the reader with both io_limit 192 and 256.

On top of that can you please give some details how increasing the
buffered queue length reduces the impact of writers?

IO Prio issue
--------------
I ran another test where two ioband devices were created of weight 100 
each on two partitions. In first group 4 readers were launched. Three
readers are of class BE and prio 7, fourth one is of class BE prio 0. In
group2, I launched a buffered writer.

One would expect that prio0 reader gets more bandwidth as compared to
prio 4 readers and prio 7 readers will get more or less same bw. Looks like
that is not happening. Look how vanilla CFQ provides much more bandwidth
to prio0 reader as compared to prio7 reader and how putting them in the
group reduces the difference betweej prio0 and prio7 readers.

Following are the results.

Vanilla CFQ
===========
set1
----
prio 0 reader: 578867200 bytes (579 MB) copied, 14.6287 s, 39.6 MB/s
578867200 bytes (579 MB) copied, 50.5431 s, 11.5 MB/s
578867200 bytes (579 MB) copied, 51.0175 s, 11.3 MB/s
578867200 bytes (579 MB) copied, 52.1346 s, 11.1 MB/s
writer: 2147483648 bytes (2.1 GB) copied, 85.2212 s, 25.2 MB/s

set2
----
prio 0 reader: 578867200 bytes (579 MB) copied, 14.3198 s, 40.4 MB/s
578867200 bytes (579 MB) copied, 48.8599 s, 11.8 MB/s
578867200 bytes (579 MB) copied, 51.206 s, 11.3 MB/s
578867200 bytes (579 MB) copied, 51.5233 s, 11.2 MB/s
writer: 2147483648 bytes (2.1 GB) copied, 83.0834 s, 25.8 MB/s

set3
----
prio 0 reader: 578867200 bytes (579 MB) copied, 14.5222 s, 39.9 MB/s
578867200 bytes (579 MB) copied, 51.1256 s, 11.3 MB/s
578867200 bytes (579 MB) copied, 51.2004 s, 11.3 MB/s
578867200 bytes (579 MB) copied, 51.9652 s, 11.1 MB/s
writer: 2147483648 bytes (2.1 GB) copied, 82.7328 s, 26.0 MB/s

with dm-ioband
==============
ioband2: 0 40355280 ioband 8:50 1 4 192 none weight 768 :100
ioband1: 0 37768752 ioband 8:49 1 4 192 none weight 768 :100

set1
----
prio 0 reader: 578867200 bytes (579 MB) copied, 67.4385 s, 8.6 MB/s
578867200 bytes (579 MB) copied, 126.726 s, 4.6 MB/s
578867200 bytes (579 MB) copied, 143.203 s, 4.0 MB/s
578867200 bytes (579 MB) copied, 148.025 s, 3.9 MB/s
writer: 2147483648 bytes (2.1 GB) copied, 156.953 s, 13.7 MB/s

set2
---
prio 0 reader: 578867200 bytes (579 MB) copied, 58.4422 s, 9.9 MB/s
578867200 bytes (579 MB) copied, 113.936 s, 5.1 MB/s
578867200 bytes (579 MB) copied, 122.763 s, 4.7 MB/s
578867200 bytes (579 MB) copied, 128.198 s, 4.5 MB/s
writer: 2147483648 bytes (2.1 GB) copied, 141.394 s, 15.2 MB/s

set3
----
prio 0 reader: 578867200 bytes (579 MB) copied, 59.8992 s, 9.7 MB/s
578867200 bytes (579 MB) copied, 136.858 s, 4.2 MB/s
578867200 bytes (579 MB) copied, 139.91 s, 4.1 MB/s
578867200 bytes (579 MB) copied, 139.986 s, 4.1 MB/s
writer: 2147483648 bytes (2.1 GB) copied, 151.889 s, 14.1 MB/s

Note: In vanilla CFQ, prio0 reader got more than 350% BW of prio 7 reader. 
      With dm-ioband this ratio changed to less than 200%.

      I will run more tests, but this show how notion of priority with-in a
      group changes if we implement throttling at higher layer and don't
      keep it with CFQ. 

     The second thing which strikes me is that I divided the disk 50% each
     between readers and writers and in that case would expect protection
     for writers and expect writers to finish fast. But writers have been
     slowed down like and it also kills overall disk throughput. I think
     it probably became seek bound.

     I think the moment I get more time, I will run some timed fio tests
     and look at how overall disk performed and how bandwidth was
     distributed with-in group and between groups. 

> 
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

At least the version of dm-ioband I have is not producing the desired
results. See above.

Is there a newer version? I will run some tests on that too. But I think
you will again run into same issue where you will decide the ratio of 
read vs write with-in group and as I change the IO schedulers results
will vary. 

So at this point of time I can't think how can you solve read vs write
ratio issue at higher layer without changing the behavior or underlying
IO scheduler.

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

But this has following undesired results.

- Slow moving group does not get reduced latencies. For example, random readers
  in slow moving group get no isolation and will continue to see higher max
  latencies.

- A single sequential reader in one group does not get fair share and
  we might be pushing buffered writes in other group thinking that we
  are getting better throughput. But the fact is that we are eating away
  readers share in group1 and giving it to writers in group2. Also I
  showed that we did not necessarily improve the overall throughput of
  the system by doing so. (Because it increases the number of seeks).

  I had sent you a mail to show that.

http://www.linux-archive.org/device-mapper-development/368752-ioband-limited-fairness-weak-isolation-between-groups-regarding-dm-ioband-tests.html

 But you changed the test case to run 4 readers in a single group to show that
 it throughput does not decrease. Please don't change test cases. In case of 4
 sequential readers in the group, group is continuously backlogged and you
 don't steal bandwidth from slow moving group. So in that mail I was not
 even discussing the scenario when you don't steal the bandwidth from
 other group. 

 I specially created one slow moving group with one reader so that we end up
 stealing bandwidth from slow moving group and show that we did not achive
 higher overall throughput by stealing the BW at the same time we did not get
 fairness for single reader and observed decreasing throughput for single
 reader as number of writers in other group increased.

Thanks
Vivek

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
