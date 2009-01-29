From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: 2-Level IO scheduling (Re: [dm-devel] [PATCH 1/2] dm-ioband: I/O
	bandwidth controller v1.10.0: Source code and patch)
Date: Thu, 29 Jan 2009 12:36:44 +0900 (JST)
Message-ID: <20090129.123644.28802208.ryov__15939.2594862313$1233200353$gmane$org@valinux.co.jp>
References: <20090122161218.GA28795@redhat.com>
	<20090123.191404.39168431.ryov@valinux.co.jp>
	<20090126162951.GI31802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090126162951.GI31802-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Vivek,

I split this mail thread into three topics:
  o 2-Level IO scheduling
  o Hierarchical grouping facility for IO controller
  o Implement IO controller as a dm-driver

This mail is about 2-Level IO scheduling.

> Just because device mapper framework allows one to implement IO controller
> in a separate module, we should not implement it there. It will be
> difficult to take care of issues like, configuration, breaking underlying IO
> scheduler's assumptions, capability to treat tasks and groups at same level
> etc.

If you are satisfied with low-accuracy bandwidth control by an IO
scheduler, you don't need to use dm-ioband. If you want to use
dm-ioband with an IO scheduler, dm-ioband can work with any type of IO
scheduler, of course dm-ioband can work with your own IO scheduler
which you are developing.

> > > - If there is one task of io priority 0 in a cgroup and rest of the tasks
> > >   are of io prio 7. All the tasks belong to best effort class. If tasks of
> > >   lower priority (7) do lot of IO, then due to buffering there is a chance
> > >   that IO from lower prio tasks is seen by CFQ first and io from higher prio
> > >   task is not seen by cfq for quite some time hence that task not getting it
> > >   fair share with in the cgroup. Similar situation can arise with RT tasks
> > >   also.
> > 
> > Whether using dm-ioband or not, if the tasks of IO priority 7 do lot
> > of IO, then the device queue is going to be full and tasks which tries
> > to issue IOs are blocked until the queue get a slot. The IOs are
> > backlogged even if they are issued from the task of IO priority 0.
> > I don't understand why you think it's the biggest issue. The same
> > thing is going to happen without dm-ioband. 
> > 
> 
> True that even limited availability of request descriptors can be a
> bottleneck and can lead to same kind of issues but my contention is
> that you are aggravating the problem. Putting a 2nd layer can break IO
> scheduler's assumption even before underlying request queue is full.

I don't think so. Dm-ioband doesn't break IO scheduler's assumptions.
In CFQ's case, the priority order is not changed within a cgroup.

> So second level solution on top will increase the frequency of such
> incidents where a lower priority task can run away with more job done than
> high priority task because there are no separate queues for different
> priority tasks and release of buffered bio is FIFO.
> 
> Secondly what happens to tasks of RT class? dm-ioband does not have any
> notion of handling the RT cgroup or RT tasks.

It's not an issue, it's a talk about how to determine a policy.
I think giving priority to cgroup policy rather than I/O scheduler
policy is more flexible.

> Thirdly, doing any kind of resource control at higher level takes away the
> capability to treat task and groups at same level. I have had this
> discussion in other offline thread also where you are copied. I think
> it is a good idea to treat tasks and groups at same level where possible
> (depends if IO scheduler creates separate queues for tasks or not, cfq
> does.) 
> 
> > If I were you, I create two cgroups and let tasks of lower priority
> > belong to one cgroup and tasks of higher priority belong to another,
> > and give higher bandwidth to the cgroup to which the higher priority
> > tasks belong. What do you think about this way?
> 
> I think this is not practical. What we are talking is that task
> priority does not have any meaning. If we want service difference between
> two tasks, we need to pack them in separate cgroup otherwise we can't
> gurantee things. If we need to pack every task in separate cgroup then
> why to even have the notion of task priority.  

It is possible to modify dm-ioband to cooperate with CFQ, but I'm not
sure it's really meaningful. What do you do when a task of RT class
issues a lot of I/O? Do you always give priority to the I/Os from the
task of RT class despite of the assigned bandwidth? Which one do you
give priority bandwidth or RT class?

Thanks,
Ryo Tsuruta
