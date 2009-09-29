From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Mon, 28 Sep 2009 23:22:55 -0400
Message-ID: <20090929032255.GA10664__14496.5466497981$1254194674$gmane$org@redhat.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<e98e18940909281737q142c788dpd20b8bdc05dd0eff@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e98e18940909281737q142c788dpd20b8bdc05dd0eff-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Sep 28, 2009 at 05:37:28PM -0700, Nauman Rafique wrote:
> Hi Vivek,
> Me, Divyesh, Fernando and Yoshikawa had a chance to have a chat with
> Jens about IO controller during Linux Plumbers Conference '09. Jens
> expressed his concerns about the size and complexity of the patches. I
> believe that is a reasonable concern. We talked about things that
> could be done to reduce the size of the patches. The requirement that
> the "solution has to work with all IO schedulers" seems like a
> secondary concern at this point; and it came out as one thing that can
> help to reduce the size of the patch set.

Initially doing cgroup based IO control only for CFQ should help a lot in
reducing the patchset size.

> Another possibility is to
> use a simpler scheduling algorithm e.g. weighted round robin, instead
> of BFQ scheduler. BFQ indeed has great properties, but we cannot deny
> the fact that it is complex to understand, and might be cumbersome to
> maintain.

Core of the BFQ I have gotten rid of already. The remaining part is idle tree
and data structures. I will see how can I simplify it further.

> Also, hierarchical scheduling is something that could be
> unnecessary in the first set of patches, even though cgroups are
> hierarchical in nature.

Sure. Though I don't think that a lot of code is there because of
hierarchical nature. If we solve the issue at CFQ layer, we have to
maintain atleast two levels. One for queue and other for groups. So even
the simplest solution becomes almost hierarchical in nature. But I will
still see how to get rid of some code here too...
> 
> We are starting from a point where there is no cgroup based IO
> scheduling in the kernel. And it is probably not reasonable to satisfy
> all IO scheduling related requirements in one patch set. We can start
> with something simple, and build on top of that. So a very simple
> patch set that enables cgroup based proportional scheduling for CFQ
> seems like the way to go at this point.

Sure, we can start with CFQ only. But a bigger question we need to answer
is that is CFQ the right place to solve the issue? Jens, do you think 
that CFQ is the right place to solve the problem?

Andrew seems to favor a high level approach so that IO schedulers are less
complex and we can provide fairness at high level logical devices also. 

I will again try to summarize my understanding so far about the pros/cons
of each approach and then we can take the discussion forward.

Fairness in terms of size of IO or disk time used
=================================================
On a seeky media, fairness in terms of disk time can get us better results
instead fairness interms of size of IO or number of IO.

If we implement some kind of time based solution at higher layer, then 
that higher layer should know who used how much of time each group used. We
can probably do some kind of timestamping in bio to get a sense when did it
get into disk and when did it finish. But on a multi queue hardware there
can be multiple requests in the disk either from same queue or from differnet
queues and with pure timestamping based apparoch, so far I could not think
how at high level we will get an idea who used how much of time.

So this is the first point of contention that how do we want to provide
fairness. In terms of disk time used or in terms of size of IO/number of
IO.

Max bandwidth Controller or Proportional bandwidth controller
=============================================================
What is our primary requirement here? A weight based proportional
bandwidth controller where we can use the resources optimally and any
kind of throttling kicks in only if there is contention for the disk.

Or we want max bandwidth control where a group is not allowed to use the
disk even if disk is free. 

Or we need both? I would think that at some point of time we will need
both but we can start with proportional bandwidth control first.

Fairness for higher level logical devices
=========================================
Do we want good fairness numbers for higher level logical devices also
or it is sufficient to provide fairness at leaf nodes. Providing fairness
at leaf nodes can help us use the resources optimally and in the process
we can get fairness at higher level also in many of the cases.

But do we want strict fairness numbers on higher level logical devices
even if it means sub-optimal usage of unerlying phsical devices?

I think that for proportinal bandwidth control, it should be ok to provide
fairness at higher level logical device but for max bandwidth control it
might make more sense to provide fairness at higher level. Consider a
case where from a striped device a customer wants to limit a group to
30MB/s and in case of leaf node control, if every leaf node provides
30MB/s, it might accumulate to much more than specified rate at logical
device.

Latency Control and strong isolation between groups
===================================================
Do we want a good isolation between groups and better latencies and
stronger isolation between groups?

I think if problem is solved at IO scheduler level, we can achieve better
latency control and hence stronger isolation between groups.

Higher level solutions should find it hard to provide same kind of latency
control and isolation between groups as IO scheduler based solution.

Fairness for buffered writes
============================
Doing io control at any place below page cache has disadvantage that page
cache might not dispatch more writes from higher weight group hence higher
weight group might not see more IO done. Andrew says that we don't have
a solution to this problem in kernel and he would like to see it handled
properly.

Only way to solve this seems to be to slow down the writers before they
write into page cache. IO throttling patch handled it by slowing down 
writer if it crossed max specified rate. Other suggestions have come in
the form of dirty_ratio per memory cgroup or a separate cgroup controller
al-together where some kind of per group write limit can be specified.

So if solution is implemented at IO scheduler layer or at device mapper
layer, both shall have to rely on another controller to be co-mounted
to handle buffered writes properly.

Fairness with-in group
======================
One of the issues with higher level controller is that how to do fair
throttling so that fairness with-in group is not impacted. Especially
the case of making sure that we don't break the notion of ioprio of the
processes with-in group.

Especially io throttling patch was very bad in terms of prio with-in 
group where throttling treated everyone equally and difference between
process prio disappeared.

Reads Vs Writes
===============
A higher level control most likely will change the ratio in which reads
and writes are dispatched to disk with-in group. It used to be decided
by IO scheduler so far but with higher level groups doing throttling and
possibly buffering the bios and releasing them later, they will have to
come up with their own policy on in what proportion reads and writes
should be dispatched. In case of IO scheduler based control, all the
queuing takes place at IO scheduler and it still retains control of
in what ration reads and writes should be dispatched.


Summary
=======

- An io scheduler based io controller can provide better latencies,
  stronger isolation between groups, time based fairness and will not
  interfere with io schedulers policies like class, ioprio and
  reader vs writer issues.

  But it can gunrantee fairness at higher logical level devices.
  Especially in case of max bw control, leaf node control does not sound
  to be the most appropriate thing.

- IO throttling provides max bw control in terms of absolute rate. It has
  the advantage that it can provide control at higher level logical device
  and also control buffered writes without need of additional controller
  co-mounted.

  But it does only max bw control and not proportion control so one might
  not be using resources optimally. It looses sense of task prio and class
  with-in group as any of the task can be throttled with-in group. Because
  throttling does not kick in till you hit the max bw limit, it should find
  it hard to provide same latencies as io scheduler based control.

- dm-ioband also has the advantage that it can provide fairness at higher
  level logical devices.

  But, fairness is provided only in terms of size of IO or number of IO.
  No time based fairness. It is very throughput oriented and does not 
  throttle high speed group if other group is running slow random reader.
  This results in bad latnecies for random reader group and weaker
  isolation between groups.

  Also it does not provide fairness if a group is not continuously
  backlogged. So if one is running 1-2 dd/sequential readers in the group,
  one does not get fairness until workload is increased to a point where
  group becomes continuously backlogged. This also results in poor
  latencies and limited fairness.

At this point of time it does not look like a single IO controller all
the scenarios/requirements. This means few things to me.

- Drop some of the requirements and go with one implementation which meets
  those reduced set of requirements.

- Have more than one IO controller implementation in kenrel. One for lower
  level control for better latencies, stronger isolation and optimal resource
  usage and other one for fairness at higher level logical devices and max
  bandwidth control. 

  And let user decide which one to use based on his/her needs. 

- Come up with more intelligent way of doing IO control where single
  controller covers all the cases.

At this point of time, I am more inclined towards option 2 of having more
than one implementation in kernel. :-) (Until and unless we can brainstrom
and come up with ideas to make option 3 happen).

> 
> It would be great if we discuss our plans on the mailing list, so we
> can get early feedback from everyone.
 
This is what comes to my mind so far. Please add to the list if I have missed
some points. Also correct me if I am wrong about the pros/cons of the
approaches.

Thoughts/ideas/opinions are welcome...

Thanks
Vivek
