From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [dm-devel] [PATCH 1/2] dm-ioband: I/O bandwidth controller
	v1.10.0: Source code and patch
Date: Thu, 22 Jan 2009 11:12:18 -0500
Message-ID: <20090122161218.GA28795@redhat.com>
References: <20090120.141022.193708059.ryov@valinux.co.jp>
	<20090120.141114.226778416.ryov@valinux.co.jp>
	<20090120155334.GH9859@agk.fab.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090120155334.GH9859-swAlYijrCMMf7BdofF/totBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Alasdair G Kergon <agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Chris Wright <chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Rik Van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux kernel mailing list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jan 20, 2009 at 03:53:34PM +0000, Alasdair G Kergon wrote:
> So, what needs to be reviewed?
> 
> 
> 1. General style/layout/naming cleanup.
> - It's pretty good compared to a lot of patches that get sent, but there are
> still a few things we can improve.
> 
> Lindent is throwing up some stuff (but remember it doesn't get things
> perfect so don't make all the changes it recommends).
> Remove double blank lines, plenty of unnecessary braces, "unsigned int" ->
> "unsigned".  
> Review the names - should a few more things get a DM_ or dm_ prefix?
> Are all the names consistent and as self-explanatory as they can reasonably be?
> (e.g. a variable called 'new' - new what?)
> 
> 
> 2. A high-level review.
> Review the documentation and what the code does and how it does it.
> - Does it make sense to add this to the kernel in this way?
> 

CCing lkml, containers mailing list and other folks who might be 
interested in the thread.

It is a long mail. You have been warned. :-)

Here are some of my thoughts and also summary of some of the past
discussions about dm-ioband either on lkml or off lkml. Following is
one of the relevant link of past discussion on lkml about this.

http://lkml.org/lkml/2008/11/6/227

At this point of time looks like there are two schools of thought regarding
how IO controller should be implemented. The first one believes (dm-ioband)
that io controller should be implemented as 2 level approach where higher
level of IO control is done by this dm-ioband driver and lower level of
scheduling is done by elevator/iosched code (noop, deadline, AS and cfq).

Second school of thought (me, nauman from google and may be others) belive
that introducing another level of IO control at higher layer breaks the
assumptions of lower level scheduling hence we should be doing IO control
and IO scheduing both in single layer and that is at elevator layer.

Before I dive into details how assumptions are broken, let me discuss
requirment part a bit. We seem to be differing on requirement part also.

I think that we need IO control only at the point where real contetion
is and not on every logical block device where there is no real contetion
for the resource. Real contention for the resource is at the end node
physical device where device is slow and then arises the need of some kind
of resource control. 

I am not very sure why dm-ioband folks want to enable IO control on any
xyz block device but in the past I got two responses.

1. Need to control end devices which don't have any elevator attached.
2. Need to do IO control for devices which are effectively network backed.
  for example, an NFS mounted file loop mounted as a block device.

I don't fully understand the first requirement. Which are the device drviers
that don't use any of the standard ioschedulers? I am not aware of any
in-kernel drviers and I am assuming it will be binary drivers.  If that's the
case, then those binary drviers need to be modified to take advantange of IO
control provided by elevator layer.

Regarding the second requirement I think this sounds more like a network
controller issue. Again the real contention is at network layer and not
at logical block device.

So at this point of time my understanding is that most common case for
IO resource control is at the end devices in the system and it can be
controlled by one level of IO control and scheudling. Please correct
me if that's not the case from requirement point of view.

Having said that even if we really find genuine cases where we need to
control IO on any xyz block device, then we should be able to come
up with generic IO controller which can reuse some of the code from 1
level controller. I am not against that and I think probably 1 level IO
controller and a generic IO controller can co-exist. But there are few points
which I find little odd about dm-ioband.

Why generic IO controller is not good for every case
====================================================
To my knowledge, there have been two generic controller implementations.
One is dm-ioband and other is an RFC patch by me. Following is the link.

http://lkml.org/lkml/2008/11/6/227

The biggest issue with generic controller is that they can buffer the
bio's at higher layer (once a cgroup is backed up) and then later release
those bios in FIFO manner. This can conflict with unerlying IO scheduler's
assumptions. Following  example comes to mind.

- If there is one task of io priority 0 in a cgroup and rest of the tasks
  are of io prio 7. All the tasks belong to best effort class. If tasks of
  lower priority (7) do lot of IO, then due to buffering there is a chance
  that IO from lower prio tasks is seen by CFQ first and io from higher prio
  task is not seen by cfq for quite some time hence that task not getting it
  fair share with in the cgroup. Similar situation can arise with RT tasks
  also.
 

Some of the issues with dm-ioband implementation
===============================================
- Breaks the assumptions of underlying IO schedulers.
	- There is no notion of task classes. So tasks of all the classes are
	  at same level from resource contention point of view. The only thing
	  which differentiates them is cgroup weight. Which does not answer the
	  question that an RT task or RT cgroup should starve the peer cgroup
	  if need be as RT cgroup should get priority access.

	- Because of FIFO release of buffered bios, it is possible that task
	  of lower priority gets more IO done than the task of higher
	  priority.

- Task grouping logic
	- We already have the notion of cgroup where tasks can be grouped
	  in hierarhical manner. dm-ioband does not make full use of that and
	  comes up with own mechansim of grouping tasks (apart from cgroup).
	  And there are odd ways of specifying cgroup id which configuring the
	  dm-ioband device. I think once somebody has created the cgroup
	  hieararchy, any IO controller logic should be able to internally
	  read that hiearchy and provide control. There should not be need
	  of any other configuration utity on top of cgroup.

	  My RFC patches had done that.


- Need of a dm device for every device we want to control

	- This requirement looks odd. It forces everybody to use dm-tools
	  and if there are lots of disks in the system, configuation is
	  pain.

- Does it support hiearhical grouping?

	- I have not looked very closely at dm-ioband patches about this and
	  had asked ryo a question about this (no response).

	  Ryo does, dm-ioband support hierarhical grouping configuration?

Summary
=======
- IMHO, for common case we don't need a generic IO controller and by
  implementing an IO controller at elevator layer with close coupling
  to io schedulers, we should be able to achive the goal.

  Currently there is work in progress (off the list) by me, nauman, Fabio,
  Paolo and others to implement a common IO control layer which can be
  used by all the four IO schedulers without too much of code duplication.
  Hopefully in next 2-3 weeks we should be able to post the initial patches
  for RFC.

- Even if there are cases for controlling a xyz block device, we can have
  a generic io controller also to cover that case. Ideally this controller
  should not be used by devices which use standard io schedulers.

  IMHO, dm-ioband as few odd points as mentioned above when it comes to
  generic controller and I think those should be addressed if we can really
  justify the need of a generic IO controller.

Your comments are welcome.    

Thanks
Vivek
