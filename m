From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Mon, 16 Mar 2009 09:39:48 -0400
Message-ID: <20090316133948.GB10872__7406.25767871297$1237211098$gmane$org@redhat.com>
References: <1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090312001146.74591b9d.akpm@linux-foundation.org>
	<20090312180126.GI10919@redhat.com>
	<20090316.174043.193698189.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090316.174043.193698189.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Mar 16, 2009 at 05:40:43PM +0900, Ryo Tsuruta wrote:
> Hi Vivek,
> 
> > dm-ioband
> > ---------
> > I have briefly looked at dm-ioband also and following were some of the
> > concerns I had raised in the past.
> > 
> > - Need of a dm device for every device we want to control
> > 
> > 	- This requirement looks odd. It forces everybody to use dm-tools
> > 	  and if there are lots of disks in the system, configuation is
> > 	  pain.
> 
> I don't think it's a pain. Could it be easily done by writing a small
> script?
> 

I think it is an extra hassle which can be avoided. Following are some
of the thoughts about configuration and issues. Looking at these, IMHO,
it is not simple to configure dm-ioband.

- So if there are 100 disks in a system, and lets say 5 partitions on each
  disk, then script needs to create a dm-ioband device for every partition.
  So I will end up creating 500 dm-ioband devices. This is not taking into
  picture the dm-ioband devices people might end up creating on
  intermediate logical nodes.

- Need of dm tools to create devices and create groups.

- I am look at dm-ioband help on web and thinking are these commands
  really simple and hassle free for a user who does not use dm in his
  setup.
  
  For two dm-ioband device creations on two partitions.

 # echo "0 $(blockdev --getsize /dev/sda1) ioband /dev/sda1 1 0 0 none" \
     "weight 0 :40" | dmsetup create ioband1
 # echo "0 $(blockdev --getsize /dev/sda2) ioband /dev/sda2 1 0 0 none" \
     "weight 0 :10" | dmsetup create ioband2 

- Following are the commands just to create two groups on a single io-band
  device.

 # dmsetup message ioband1 0 type user
 # dmsetup message ioband1 0 attach 1000
 # dmsetup message ioband1 0 attach 2000
 # dmsetup message ioband1 0 weight 1000:30
 # dmsetup message ioband1 0 weight 2000:20

Now think of a decent size group hierarchy (say 50 groups) on 500 ioband device
system. So that would be 50*500 = 25000 group creation commands.

- So if an admin wants to group applications using cgroup, first he needs
  to create cgroup hierarchy. Then he needs to take all the cgroup ids
  and provide these to this dm-ioband device with the help of dmsetup
  command.

	dmsetup message ioband1 0 attach <cgroup id>

  cgroup has already provided us nice grouping facility in hierarchical
  manner. This extra step is cumbersome and completely unnecessary.

- These configuration commands will become even much more complicated
  once you start supporting hierachical setup. All the hierarchy
  information shall have to passed in the command itself in one way or
  other once a group is being created.

- You will be limited in terms of functionlity. I am assuming these group
  creation operations will be limited to "root" user. A very common
  requiremnt we are seeming now a days is that admin will create a top
  level cgroup and then let user create/manage more groups with-in top
  level group. 

  For example.

			  root
			/  |  \
		     u1    u2 others 		      

  Here u1 and u2 are two different users on the system. Here admin can
  create top level cgroups for users and assign users weight from IO
  point of view. Now individual users should be able to create groups
  of their own and manage their tasks. Cgroup infrastructure allows all
  this.

  In the above setup it will become very very hard to let user also create
  its own groups in top level group. You shall have to keep all the 
  information which filesystem keeps in terms of file permissions etc.
   
So IMHO, configuration of dm-ioband devices and groups is complicated and
it can be simplified a lot. Secondly, it does not seem to be a good idea
to not make use of cgroup infrastrucuture and come up own ways of
grouping things.

> > - It does not support hiearhical grouping.
> 
> I can implement hierarchical grouping to dm-ioband if it's really
> necessary, but at this point, I don't think it's really necessary
> and I want to keep the code simple.
> 

We do need hierarchical support.

In fact later in the mail you have specified that you will consider treating
task and groups at same level. The moment you do that, one flat hiearchy will
mean a single "root" group only and no groups with-in that. Until and unless
you implement hiearchical support you can't create even single level of groups
with-in "root".

Secondly, i think dm-ioband will become very complex (especially in terms
of managing configuration), the moment hiearchical support is introduced.
So it would be a good idea to implement the hiearchical support now and
get to know the full complexity of the system.

> > - Possibly can break the assumptions of underlying IO schedulers.
> > 
> > 	- There is no notion of task classes. So tasks of all the classes
> > 	  are at same level from resource contention point of view.
> > 	  The only thing which differentiates them is cgroup weight. Which
> > 	  does not answer the question that an RT task or RT cgroup should
> > 	  starve the peer cgroup if need be as RT cgroup should get priority
> > 	  access.
> > 
> > 	- Because of FIFO release of buffered bios, it is possible that
> > 	  task of lower priority gets more IO done than the task of higher
> > 	  priority.
> > 
> > 	- Buffering at multiple levels and FIFO dispatch can have more
> > 	  interesting hard to solve issues.
> > 
> > 		- Assume there is sequential reader and an aggressive
> > 		  writer in the cgroup. It might happen that writer
> > 		  pushed lot of write requests in the FIFO queue first
> > 		  and then a read request from reader comes. Now it might
> > 		  happen that cfq does not see this read request for a long
> > 		  time (if cgroup weight is less) and this writer will 
> > 		  starve the reader in this cgroup.
> > 
> > 		  Even cfq anticipation logic will not help here because
> > 		  when that first read request actually gets to cfq, cfq might
> > 		  choose to idle for more read requests to come, but the
> > 		  agreesive writer might have again flooded the FIFO queue
> > 		  in the group and cfq will not see subsequent read request
> > 		  for a long time and will unnecessarily idle for read.
> 
> I think it's just a matter of which you prioritize, bandwidth or
> io-class. What do you do when the RT task issues a lot of I/O?
> 

This is a multi-class scheduler. We first prioritize class and then handle
tasks with-in class. So RT class will always get to dispatch first and
can starve Best effort class tasks if it is issueing lots of IO.

You just don't have any notion of RT groups. So if admin wants to make
sure that and RT tasks always gets the disk access first, there is no way to
ensure that. The best thing in this setup one can do is assign higher
weight to RT task group. This group will still be doing proportional
weight scheduling with Best effort class groups or Idle task groups. That's
not multi-class scheduling is.

So in your patches there is no differentiation between classes. A best effort
task is competing equally hard as RT task. For example.

			root
		 	/  \
		   RT task  Group (best effort class)
				/ \
			       T1  T2 

Here T1 and T2 are best effort class tasks and they are sharing disk 
bandwidth with RT task. Instead, RT task should get exclusive access to
disk.

Secondly, two of the above issues I have mentioned are for tasks with-in same
class and how FIFO dispatch will create the problems. These are problems
with any second level controller. These will be really hard to solve the
issues and will force us to copy more code from cfq and other subsystems.

> > - Task grouping logic
> > 	- We already have the notion of cgroup where tasks can be grouped
> > 	  in hierarhical manner. dm-ioband does not make full use of that
> > 	  and comes up with own mechansim of grouping tasks (apart from
> > 	  cgroup).  And there are odd ways of specifying cgroup id while
> > 	  configuring the dm-ioband device.
> > 
> > 	  IMHO, once somebody has created the cgroup hieararchy, any IO
> > 	  controller logic should be able to internally read that hiearchy
> > 	  and provide control. There should not be need of any other
> > 	  configuration utity on top of cgroup.
> > 
> > 	  My RFC patches had tried to get rid of this external
> > 	  configuration requirement.
> 
> The reason is that it makes bio-cgroup easy to use for dm-ioband.
> But It's not a final design of the interface between dm-ioband and
> cgroup.

It makes it easy for dm-ioband implementation but harder for the user.

What is the alternate interface?

> 
> > - Task and Groups can not be treated at same level.
> > 
> > 	- Because at any second level solution we are controlling bio
> > 	  per cgroup and don't have any notion of which task queue bio
> > 	  belongs to, one can not treat task and group  at same level.
> > 	
> > 	  What I meant is following.
> > 
> > 			root
> > 			/ | \
> > 		       1  2  A
> > 			    / \
> > 			   3   4
> > 
> > 	In dm-ioband approach, at top level tasks 1 and 2 will get 50%
> > 	of BW together and group A will get 50%. Ideally along the lines
> > 	of cpu controller, I would expect it to be 33% each for task 1
> > 	task 2 and group A.
> > 
> > 	This can create interesting scenarios where assumg task1 is
> > 	an RT class task. Now one would expect task 1 get all the BW
> > 	possible starving task 2 and group A, but that will not be the
> > 	case and task1 will get 50% of BW.
> > 
> >  	Not that it is critically important but it would probably be
> > 	nice if we can maitain same semantics as cpu controller. In
> > 	elevator layer solution we can do it at least for CFQ scheduler
> > 	as it maintains separate io queue per io context. 	
> 
> I will consider following the CPU controller's manner when dm-ioband
> supports hierarchical grouping.

But this is an issue even now. If you want to consider task and group
at the same level, then you will end up creating separate queues for
all the tasks (and not only queues for groups). This will essentially
become CFQ.
 
> 
> > 	This is in general an issue for any 2nd level IO controller which
> > 	only accounts for io groups and not for io queues per process.
> > 
> > - We will end copying a lot of code/logic from cfq
> > 
> > 	- To address many of the concerns like multi class scheduler
> > 	  we will end up duplicating code of IO scheduler. Why can't
> > 	  we have a one point hierarchical IO scheduling (This patchset).

More details about this point.

- To make dm-ioband support multiclass task/groups, we will end up
  inheriting logic from cfq/bfq.

- To treat task and group at same level we will end up creating separate
  queues for each task and then import lots of cfq/bfq logic for managing
  those queues.

- The moment we move to hiearchical support, you will end up creating
  equivalent logic of our patches.

The point is, why to do all this? CFQ has already solved the problem of
multi class IO scheduler and providing service differentiation between
tasks of different priority. With cgroup stuff, we need to just extend
existing CFQ logic so that it supports hiearchical scheduling and we will
have a good IO controller in place.

Can you please point out specifically why do you think extending CFQ
logic to support hiearchical scheduling and sharing code with other IO
schedulers is not a good idea to implement hiearchical IO control?

Thanks
Vivek
