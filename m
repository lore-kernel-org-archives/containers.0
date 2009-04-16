From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Thu, 16 Apr 2009 14:37:53 -0400
Message-ID: <20090416183753.GE8896@redhat.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090312001146.74591b9d.akpm@linux-foundation.org>
	<20090312180126.GI10919@redhat.com> <49D8CB17.7040501@gmail.com>
	<20090407064046.GB20498@redhat.com> <20090408203756.GB10077@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090408203756.GB10077@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jen
List-Id: containers.vger.kernel.org

On Wed, Apr 08, 2009 at 10:37:59PM +0200, Andrea Righi wrote:

[..]
> > 
> > - I can think of atleast one usage of uppper limit controller where we
> >   might have spare IO resources still we don't want to give it to a
> >   cgroup because customer has not paid for that kind of service level. In
> >   those cases we need to implement uppper limit also.
> > 
> >   May be prportional weight and max bw controller can co-exist depending
> >   on what user's requirements are.
> >  
> >   If yes, then can't this control be done at the same layer/level where
> >   proportional weight control is being done? IOW, this set of patches is
> >   trying to do prportional weight control at IO scheduler level. I think
> >   we should be able to store another max rate as another feature in 
> >   cgroup (apart from weight) and not dispatch requests from the queue if
> >   we have exceeded the max BW as specified by the user?
> 
> The more I think about a "perfect" solution (at least for my
> requirements), the more I'm convinced that we need both functionalities.
> 

I agree here. In some scenarios people might want to put an upper cap on BW
even if more BW is available and in some scenarios people will like to do
proportional distribution and let one get more share of disk if it is
free.

> I think it would be possible to implement both proportional and limiting
> rules at the same level (e.g., the IO scheduler), but we need also to
> address the memory consumption problem (I still need to review your
> patchset in details and I'm going to test it soon :), so I don't know if
> you already addressed this issue).
> 

Can you please elaborate a bit on this? Are you concerned about that data
structures created to solve the problem consume a lot of memory?

> IOW if we simply don't dispatch requests and we don't throttle the tasks
> in the cgroup that exceeds its limit, how do we avoid the waste of
> memory due to the succeeding IO requests and the increasingly dirty
> pages in the page cache (that are also hard to reclaim)? I may be wrong,
> but I think we talked about this problem in a previous email... sorry I
> don't find the discussion in my mail archives.
> 
> IMHO a nice approach would be to measure IO consumption at the IO
> scheduler level, and control IO applying proportional weights / absolute
> limits _both_ at the IO scheduler / elevator level _and_ at the same
> time block the tasks from dirtying memory that will generate additional
> IO requests.
> 
> Anyway, there's no need to provide this with a single IO controller, we
> could split the problem in two parts: 1) provide a proportional /
> absolute IO controller in the IO schedulers and 2) allow to set, for
> example, a maximum limit of dirty pages for each cgroup.
> 

I think setting a maximum limit on dirty pages is an interesting thought.
It sounds like as if memory controller can handle it?

I guess currently memory controller puts limit on total amount of memory
consumed by cgroup and there are no knobs on type of memory consumed. So
if one can limit amount of dirty page cache memory per cgroup, it
automatically throttles the aysnc writes at the input itself.
 
So I agree that if we can limit the process from dirtying too much of
memory than IO scheduler level controller should be able to do both
proportional weight and max bw controller.

Currently doing proportional weight control for async writes is very
tricky. I am not seeing constantly backlogged traffic at IO scheudler
level and hence two different weight processes seem to be getting same
BW.

I will dive deeper into the patches on dm-ioband to see how they have
solved this issue. Looks like they are just waiting longer for slowest
group to consume its tokens and that will keep the disk idle. Extended
delays might now show up immediately as performance hog, because it might
also promote increased merging but it should lead to increased latency of
response. And proving latency issues is hard. :-)   

> Maybe I'm just repeating what we already said in a previous
> discussion... in this case sorry for the duplicate thoughts. :)
> 
> > 
> > - Have you thought of doing hierarchical control? 
> > 
> 
> Providing hiearchies in cgroups is in general expensive, deeper
> hierarchies imply checking all the way up to the root cgroup, so I think
> we need to be very careful and be aware of the trade-offs before
> providing such feature. For this particular case (IO controller)
> wouldn't it be simpler and more efficient to just ignore hierarchies in
> the kernel and opportunely handle them in userspace? for absolute
> limiting rules this isn't difficult at all, just imagine a config file
> and a script or a deamon that dynamically create the opportune cgroups
> and configure them accordingly to what is defined in the configuration
> file.
> 
> I think we can simply define hierarchical dependencies in the
> configuration file, translate them in absolute values and use the
> absolute values to configure the cgroups' properties.
> 
> For example, we can just check that the BW allocated for a particular
> parent cgroup is not greater than the total BW allocated for the
> children. And for each child just use the min(parent_BW, BW) or equally
> divide the parent's BW among the children, etc.

IIUC, you are saying that allow hiearchy in user space and then flatten it
out and pass it to kernel?

Hmm.., agree that handling hierarchies is hard and expensive. But at the
same time rest of the controllers like cpu and memory are handling it in
kernel so it probably makes sense to keep the IO controller also in line.

In practice I am not expecting deep hiearchices. May be 2- 3 levels would
be good for most of the people.

> 
> > - What happens to the notion of CFQ task classes and task priority. Looks
> >   like max bw rule supercede everything. There is no way that an RT task
> >   get unlimited amount of disk BW even if it wants to? (There is no notion
> >   of RT cgroup etc)
> 
> What about moving all the RT tasks in a separate cgroup with unlimited
> BW?

Hmm.., I think that should work. I have yet to look at your patches in
detail but it looks like unlimited BW group will not be throttled at all
hence RT tasks can just go right through without getting impacted.

> 
> > 
> > > > 
> > > >   Above requirement can create configuration problems.
> > > > 
> > > > 	- If there are large number of disks in system, per cgroup one shall
> > > > 	  have to create rules for each disk. Until and unless admin knows
> > > > 	  what applications are in which cgroup and strictly what disk
> > > > 	  these applications do IO to and create rules for only those
> > > >  	  disks.
> > > 
> > > I don't think this is a huge problem anyway. IMHO a userspace tool, e.g.
> > > a script, would be able to efficiently create/modify rules parsing user
> > > defined rules in some human-readable form (config files, etc.), even in
> > > presence of hundreds of disk. The same is valid for dm-ioband I think.
> > > 
> > > > 
> > > > 	- I think problem gets compounded if there is a hierarchy of
> > > > 	  logical devices. I think in that case one shall have to create
> > > > 	  rules for logical devices and not actual physical devices.
> > > 
> > > With logical devices you mean device-mapper devices (i.e. LVM, software
> > > RAID, etc.)? or do you mean that we need to introduce the concept of
> > > "logical device" to easily (quickly) configure IO requirements and then
> > > map those logical devices to the actual physical devices? In this case I
> > > think this can be addressed in userspace. Or maybe I'm totally missing
> > > the point here.
> > 
> > Yes, I meant LVM, Software RAID etc. So if I have got many disks in the system
> > and I have created software raid on some of them, I need to create rules for
> > lvm devices or physical devices behind those lvm devices? I am assuming
> > that it will be logical devices.
> > 
> > So I need to know exactly to what all devices applications in a particular
> > cgroup is going to do IO, and also know exactly how many cgroups are
> > contending for that cgroup, and also know what worst case disk rate I can
> > expect from that device and then I can do a good job of giving a
> > reasonable value to the max rate of that cgroup on a particular device?
> 
> ok, I understand. For these cases dm-ioband perfectly addresses the
> problem. For the general case, I think the only solution is to provide a
> common interface that each dm subsystem must call to account IO and
> apply limiting and proportional rules.
> 
> > 
> > > 
> > > > 
> > > > - Because it is not proportional weight distribution, if some
> > > >   cgroup is not using its planned BW, other group sharing the
> > > >   disk can not make use of spare BW.  
> > > > 	
> > > 
> > > Right.
> > > 
> > > > - I think one should know in advance the throughput rate of underlying media
> > > >   and also know competing applications so that one can statically define
> > > >   the BW assigned to each cgroup on each disk.
> > > > 
> > > >   This will be difficult. Effective BW extracted out of a rotational media
> > > >   is dependent on the seek pattern so one shall have to either try to make
> > > >   some conservative estimates and try to divide BW (we will not utilize disk
> > > >   fully) or take some peak numbers and divide BW (cgroup might not get the
> > > >   maximum rate configured).
> > > 
> > > Correct. I think the proportional weight approach is the only solution
> > > to efficiently use the whole BW. OTOH absolute limiting rules offer a
> > > better control over QoS, because you can totally remove performance
> > > bursts/peaks that could break QoS requirements for short periods of
> > > time.
> > 
> > Can you please give little more details here regarding how QoS requirements
> > are not met with proportional weight?
> 
> With proportional weights the whole bandwidth is allocated if no one
> else is using it. When IO is submitted other tasks with a higher weight
> can be forced to sleep until the IO generated by the low weight tasks is
> not completely dispatched. Or any extent of the priority inversion
> problems.

Hmm..., I am not very sure here. When admin is allocating the weights, he
has the whole picture. He knows how many groups are conteding for the disk
and what could be the worst case scenario. So if I have got two groups
with A and B with weight 1 and 2 and both are contending, then as an 
admin one would expect to get 33% of BW for group A in worst case (if
group B is continuously backlogged). If B is not contending than A can get
100% of BW. So while configuring the system, will one not plan for worst
case (33% for A, and 66 % for B)?
  
> 
> Maybe it's not an issue at all for the most part of the cases, but using
> a solution that is able to provide also a real partitioning of the
> available resources can be profitely used by those who need to guarantee
> _strict_ BW requirements (soft real-time, maximize the responsiveness of
> certain services, etc.), because in this case we're sure that a certain
> amount of "spare" BW will be always available when needed by some
> "critical" services.
> 

Will the same thing not happen in proportional weight? If it is an RT
application, one can put it in RT groups to make sure it always gets
the BW first even if there is contention. 

Even in regular group, the moment you issue the IO and IO scheduler sees
it, you will start getting your reserved share according to your weight.

How it will be different in the case of io throttling? Even if I don't
utilize the disk fully, cfq will still put the new guy in the queue and
then try to give its share (based on prio).

Are you saying that by keeping disk relatively free, the latency of
response for soft real time application will become better? In that
case can't one simply underprovision the disk?

But having said that I am not disputing the need of max BW controller
as some people have expressed the need of a constant BW view and don't
want too big a fluctuations even if BW is available. Max BW controller
can't gurantee the minumum BW hence can't avoid the fluctuations
completely, but it can still help in smoothing the traffic because
other competitiors will be stopped from doing too much of IO.

Thanks
Vivek

> > 
> > > So, my "ideal" IO controller should allow to define both rules:
> > > absolute and proportional limits.
> > > 
> > > I still have to look closely at your patchset anyway. I will do and give
> > > a feedback.
> > 
> > You feedback is always welcome.
> > 
> > Thanks
> > Vivek
> 
> Thanks,
> -Andrea
