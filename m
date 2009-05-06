From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Wed, 6 May 2009 17:21:21 -0400
Message-ID: <20090506212121.GI8180__25315.4506361627$1241645371$gmane$org@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<20090505132441.1705bfad.akpm@linux-foundation.org>
	<20090506023332.GA1212@redhat.com> <20090506200751.GA4282@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090506200751.GA4282@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, May 06, 2009 at 10:07:53PM +0200, Andrea Righi wrote:
> On Tue, May 05, 2009 at 10:33:32PM -0400, Vivek Goyal wrote:
> > On Tue, May 05, 2009 at 01:24:41PM -0700, Andrew Morton wrote:
> > > On Tue,  5 May 2009 15:58:27 -0400
> > > Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > 
> > > > 
> > > > Hi All,
> > > > 
> > > > Here is the V2 of the IO controller patches generated on top of 2.6.30-rc4.
> > > > ...
> > > > Currently primarily two other IO controller proposals are out there.
> > > > 
> > > > dm-ioband
> > > > ---------
> > > > This patch set is from Ryo Tsuruta from valinux.
> > > > ...
> > > > IO-throttling
> > > > -------------
> > > > This patch set is from Andrea Righi provides max bandwidth controller.
> > > 
> > > I'm thinking we need to lock you guys in a room and come back in 15 minutes.
> > > 
> > > Seriously, how are we to resolve this?  We could lock me in a room and
> > > cmoe back in 15 days, but there's no reason to believe that I'd emerge
> > > with the best answer.
> > > 
> > > I tend to think that a cgroup-based controller is the way to go. 
> > > Anything else will need to be wired up to cgroups _anyway_, and that
> > > might end up messy.
> > 
> > Hi Andrew,
> > 
> > Sorry, did not get what do you mean by cgroup based controller? If you
> > mean that we use cgroups for grouping tasks for controlling IO, then both
> > IO scheduler based controller as well as io throttling proposal do that.
> > dm-ioband also supports that up to some extent but it requires extra step of
> > transferring cgroup grouping information to dm-ioband device using dm-tools.
> > 
> > But if you meant that io-throttle patches, then I think it solves only
> > part of the problem and that is max bw control. It does not offer minimum
> > BW/minimum disk share gurantees as offered by proportional BW control.
> > 
> > IOW, it supports upper limit control and does not support a work conserving
> > IO controller which lets a group use the whole BW if competing groups are
> > not present. IMHO, proportional BW control is an important feature which
> > we will need and IIUC, io-throttle patches can't be easily extended to support
> > proportional BW control, OTOH, one should be able to extend IO scheduler
> > based proportional weight controller to also support max bw control. 
> 
> Well, IMHO the big concern is at which level we want to implement the
> logic of control: IO scheduler, when the IO requests are already
> submitted and need to be dispatched, or at high level when the
> applications generates IO requests (or maybe both).
> 
> And, as pointed by Andrew, do everything by a cgroup-based controller.

I am not sure what's the rationale behind that. Why to do it at higher
layer? Doing it at IO scheduler layer will make sure that one does not
breaks the IO scheduler's properties with-in cgroup. (See my other mail
with some io-throttling test results).

The advantage of higher layer mechanism is that it can also cover software
RAID devices well. 

> 
> The other features, proportional BW, throttling, take the current ioprio
> model in account, etc. are implementation details and any of the
> proposed solutions can be extended to support all these features. I
> mean, io-throttle can be extended to support proportional BW (for a
> certain perspective it is already provided by the throttling water mark
> in v16), as well as the IO scheduler based controller can be extended to
> support absolute BW limits. The same for dm-ioband. I don't think
> there're huge obstacle to merge the functionalities in this sense.

Yes, from technical point of view, one can implement a proportional BW
controller at higher layer also. But that would practically mean almost
re-implementing the CFQ logic at higher layer. Now why to get into all
that complexity. Why not simply make CFQ hiearchical to also handle the
groups?

Secondly, think of following odd scenarios if we implement a higher level
proportional BW controller which can offer the same feature as CFQ and
also can handle group scheduling.

Case1:
======	 
           (Higher level proportional BW controller)
			/dev/sda (CFQ)

So if somebody wants a group scheduling, we will be doing same IO control
at two places (with-in group). Once at higher level and second time at CFQ
level. Does not sound too logical to me.

Case2:
======

           (Higher level proportional BW controller)
			/dev/sda (NOOP)
	
This is other extrememt. Lower level IO scheduler does not offer any kind
of notion of class or prio with-in class and higher level scheduler will
still be maintaining all the infrastructure unnecessarily.

That's why I get back to this simple question again, why not extend the
IO schedulers to handle group scheduling and do both proportional BW and
max bw control there.

> 
> > 
> > Andrea, last time you were planning to have a look at my patches and see
> > if max bw controller can be implemented there. I got a feeling that it
> > should not be too difficult to implement it there. We already have the
> > hierarchical tree of io queues and groups in elevator layer and we run
> > BFQ (WF2Q+) algorithm to select next queue to dispatch the IO from. It is
> > just a matter of also keeping track of IO rate per queue/group and we should
> > be easily be able to delay the dispatch of IO from a queue if its group has
> > crossed the specified max bw.
> 
> Yes, sorry for my late, I quickly tested your patchset, but I still need
> to understand many details of your solution. In the next days I'll
> re-read everything carefully and I'll try to do a detailed review of
> your patchset (just re-building the kernel with your patchset applied).
> 

Sure. My patchset is still in the infancy stage. So don't expect great
results. But it does highlight the idea and design very well.

> > 
> > This should lead to less code and reduced complextiy (compared with the
> > case where we do max bw control with io-throttling patches and proportional
> > BW control using IO scheduler based control patches).
> 
> mmmh... changing the logic at the elevator and all IO schedulers doesn't
> sound like reduced complexity and less code changed. With io-throttle we
> just need to place the cgroup_io_throttle() hook in the right functions
> where we want to apply throttling. This is a quite easy approach to
> extend the IO control also to logical devices (more in general devices
> that use their own make_request_fn) or even network-attached devices, as
> well as networking filesystems, etc.
> 
> But I may be wrong. As I said I still need to review in the details your
> solution.

Well I meant reduced code in the sense if we implement both max bw and
proportional bw at IO scheduler level instead of proportional BW at
IO scheduler and max bw at higher level.

I agree that doing max bw control at higher level has this advantage that
it covers all the kind of deivces (higher level logical devices) and IO
scheduler level solution does not do that. But this comes at the price
of broken IO scheduler properties with-in cgroup.

Maybe we can then implement both. A higher level max bw controller and a
max bw feature implemented along side proportional BW controller at IO
scheduler level. Folks who use hardware RAID, or single disk devices can
use max bw control of IO scheduler and those using software RAID devices
can use higher level max bw controller.

> 
> >  
> > So do you think that it would make sense to do max BW control along with
> > proportional weight IO controller at IO scheduler? If yes, then we can
> > work together and continue to develop this patchset to also support max
> > bw control and meet your requirements and drop the io-throttling patches.
> 
> It is surely worth to be explored. Honestly, I don't know if it would be
> a better solution or not. Probably comparing some results with different
> IO workloads is the best way to proceed and decide which is the right
> way to go. This is necessary IMHO, before totally dropping one solution
> or another.

Sure. My patches have started giving some basic results but because there
is lot of work remaining before a fair comparison can be done on the
basis of performance under various work loads. So some more time to
go before we can do a fair comparison based on numbers.
 
> 
> > 
> > The only thing which concerns me is the fact that IO scheduler does not
> > have the view of higher level logical device. So if somebody has setup a
> > software RAID and wants to put max BW limit on software raid device, this
> > solution will not work. One shall have to live with max bw limits on 
> > individual disks (where io scheduler is actually running). Do your patches
> > allow to put limit on software RAID devices also? 
> 
> No, but as said above my patchset provides the interfaces to apply the
> IO control and accounting wherever we want. At the moment there's just
> one interface, cgroup_io_throttle().

Sorry, I did not get it clearly. I guess I did not ask the question right.
So lets say I got a setup where there are two phyical devices /dev/sda and
/dev/sdb and I create a logical device (say using device mapper facilities)
on top of these two physical disks. And some application is generating
the IO for logical device lv0.

				Appl
				 |
				lv0
			       /  \
			    sda	   sdb


Where should I put the bandwidth limiting rules now for io-throtle. I 
specify these for lv0 device or for sda and sdb devices?

Thanks
Vivek
