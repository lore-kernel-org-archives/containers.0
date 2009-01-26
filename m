From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [dm-devel] [PATCH 1/2] dm-ioband: I/O bandwidth controller
	v1.10.0: Source code and patch
Date: Mon, 26 Jan 2009 11:29:51 -0500
Message-ID: <20090126162951.GI31802__17273.1176637628$1232987666$gmane$org@redhat.com>
References: <20090120.141114.226778416.ryov@valinux.co.jp>
	<20090120155334.GH9859@agk.fab.redhat.com>
	<20090122161218.GA28795@redhat.com>
	<20090123.191404.39168431.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090123.191404.39168431.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jan 23, 2009 at 07:14:04PM +0900, Ryo Tsuruta wrote:
> Hi Vivek,
> 
> Thanks for your comments.
> 
> > I am not very sure why dm-ioband folks want to enable IO control on any
> > xyz block device but in the past I got two responses.
> > 
> > 1. Need to control end devices which don't have any elevator attached.
> > 2. Need to do IO control for devices which are effectively network backed.
> >   for example, an NFS mounted file loop mounted as a block device.
> 
> The two responses are issues of IO scheduler based controllers, not
> reasons why we implement the IO controller as a device mapper driver.
> The reasons of that are:
> - A user have a choice whether to use dm-ioband or not, and dm-ioband
>   doesn't make any effects on the system if a user doesn't want to
>   use it.

Even in in-kernel solution, cgroup code will be compiled out if user
is not using IO controller. Some code might still be present in run time
but I don't think it will be any big run time penalty.
  
> - The dm device is highly independent module, so we don't need to modify
>   the existing kernel code including the IO schedulers. It can keep
>   the IO scheduler implementation simple.
> 

Agree that dm device is highly independent module but I think in this it
does not look like the right place to implement the  IO controller.

I think with the introduction of cgroup, IO scheduling has become now
a hierarhical scheduling. Previously it was flat scheduling where there
was only one level. Not there can be multiple levels and each level
can have groups and queues. I don't think that we can break down
hiearchical scheduling problem in two parts where top level part is moved
into a module. It is something like saying that lets break out cpu group
schedling into a separate module and it should not be part of kernel.

I think we need to implement this hiearchical IO scheduler in kernel which
can schedule groups as well as end level io queues. (maintained by cfq,
deadline, as, or noop).

> So, dm-ioband can co-exist with any other IO controllers from a
> user's and kernel developer's perspective.

Just because device mapper framework allows one to implement IO controller
in a separate module, we should not implement it there. It will be
difficult to take care of issues like, configuration, breaking underlying IO
scheduler's assumptions, capability to treat tasks and groups at same level
etc.

> 
> > Why generic IO controller is not good for every case
> > ====================================================
> > To my knowledge, there have been two generic controller implementations.
> > One is dm-ioband and other is an RFC patch by me. Following is the link.
> > 
> > http://lkml.org/lkml/2008/11/6/227
> > 
> > The biggest issue with generic controller is that they can buffer the
> > bio's at higher layer (once a cgroup is backed up) and then later release
> > those bios in FIFO manner. This can conflict with unerlying IO scheduler's
> > assumptions. Following  example comes to mind.
> 
> I don't think you are completely right.
> 
> > - If there is one task of io priority 0 in a cgroup and rest of the tasks
> >   are of io prio 7. All the tasks belong to best effort class. If tasks of
> >   lower priority (7) do lot of IO, then due to buffering there is a chance
> >   that IO from lower prio tasks is seen by CFQ first and io from higher prio
> >   task is not seen by cfq for quite some time hence that task not getting it
> >   fair share with in the cgroup. Similar situation can arise with RT tasks
> >   also.
> 
> Whether using dm-ioband or not, if the tasks of IO priority 7 do lot
> of IO, then the device queue is going to be full and tasks which tries
> to issue IOs are blocked until the queue get a slot. The IOs are
> backlogged even if they are issued from the task of IO priority 0.
> I don't understand why you think it's the biggest issue. The same
> thing is going to happen without dm-ioband. 
> 

True that even limited availability of request descriptors can be a
bottleneck and can lead to same kind of issues but my contention is
that you are aggravating the problem. Putting a 2nd layer can break IO
scheduler's assumption even before underlying request queue is full.

So second level solution on top will increase the frequency of such
incidents where a lower priority task can run away with more job done than
high priority task because there are no separate queues for different
priority tasks and release of buffered bio is FIFO.

Secondly what happens to tasks of RT class? dm-ioband does not have any
notion of handling the RT cgroup or RT tasks.

Thirdly, doing any kind of resource control at higher level takes away the
capability to treat task and groups at same level. I have had this
discussion in other offline thread also where you are copied. I think
it is a good idea to treat tasks and groups at same level where possible
(depends if IO scheduler creates separate queues for tasks or not, cfq
does.) 

> If I were you, I create two cgroups and let tasks of lower priority
> belong to one cgroup and tasks of higher priority belong to another,
> and give higher bandwidth to the cgroup to which the higher priority
> tasks belong. What do you think about this way?
> 

I think this is not practical. What we are talking is that task
priority does not have any meaning. If we want service difference between
two tasks, we need to pack them in separate cgroup otherwise we can't
gurantee things. If we need to pack every task in separate cgroup then
why to even have the notion of task priority.  

> > - Task grouping logic
> > 	- We already have the notion of cgroup where tasks can be grouped
> > 	  in hierarhical manner. dm-ioband does not make full use of that and
> > 	  comes up with own mechansim of grouping tasks (apart from cgroup).
> > 	  And there are odd ways of specifying cgroup id which configuring the
> > 	  dm-ioband device. I think once somebody has created the cgroup
> > 	  hieararchy, any IO controller logic should be able to internally
> > 	  read that hiearchy and provide control. There should not be need
> > 	  of any other configuration utity on top of cgroup.
> > 
> > 	  My RFC patches had done that.
> 
> Dm-ioband can work with the bio-cgroup mechanism, which makes task groups
> in manner of the cgroup, of course.
> I already have a basic design to make dm-ioband support the cgroup
> hierarchy. This should be started after the core code of bio-cgroup,
> which helps trace each I/O requests, is merged in -mm tree.
> 

bio-cgroup patches are fine because they provide us the capability to 
map delayed writes to right cgroup. And it can be used by any IO
controller. 

> And the reason dm-ioband uses cgroup id to specify a cgroup is that
> the current cgroup infrastructure lacks features to manage resources
> placed in the kernel modules.

Can you elaborate on that please? We have heard in the past that cgroup 
does not give you enough flexibility but never got details.

In this case first you are forcing some functionalilty to go in a kernel
module and then coming up with tools for configuration. I never understood
that why don't you let the controller be inside the kernel, let it
directly interact with cgroup subsystem and work instead of first taking
the functionality out of kernel in a module and then justifying the case
that now we need new ways of configuring that module because cgroup
infrastructure is not sufficient.  

> 
> > - Need of a dm device for every device we want to control
> > 
> > 	- This requirement looks odd. It forces everybody to use dm-tools
> > 	  and if there are lots of disks in the system, configuation is
> > 	  pain.
> 
> I don't think it's so pain. I think you are already using LVM devices on
> your boxes. Setting up dm-ioband is the same as that for LVM. And some
> scripts or something similar will help you set up them.
> 

Not everybody uses LVM. Balbir had asked once, if there are thousands of 
disks in the system, does that mean I need to create this dm-ioband device
for all the disks?

> And it is also possible this algorithm can be directly implemented in the
> block layer if this is really needed.
> 
> > - Does it support hiearhical grouping?
> > 
> > 	- I have not looked very closely at dm-ioband patches about this and
> > 	  had asked ryo a question about this (no response).
> > 
> > 	  Ryo does, dm-ioband support hierarhical grouping configuration?
> 
> I'm sorry I missed your email with the question.
> I already have a design plan for it and I will start to implement it
> if there are a lot of requests for this. But I doubt this should be
> implemented in kernel, which can be placed in user-land, such as
> a daemon program.
> 

We do need hierarhical grouping facility for IO controller also.

I am not sure that I agree to the idea of implementing IO controller 
as a device mapper driver because device mapper framework allows it to
be implemented as a module and one can avoid putting code in kernel. At
this point of time, IMHO, I don't think that IO controller code living
inside the kernel is an issue. I would rather focus on rest of the issues.

Thanks
Vivek
