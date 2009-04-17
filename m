From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: IO Controller discussion (Was: Re: [PATCH 01/10] Documentation)
Date: Fri, 17 Apr 2009 09:49:24 -0400
Message-ID: <20090417134924.GC29086@redhat.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090312001146.74591b9d.akpm@linux-foundation.org>
	<20090312180126.GI10919@redhat.com> <49D8CB17.7040501@gmail.com>
	<20090407064046.GB20498@redhat.com> <20090408203756.GB10077@linux>
	<20090416183753.GE8896@redhat.com>
	<20090417053517.GC26437@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090417053517.GC26437-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 17, 2009 at 11:05:17AM +0530, Dhaval Giani wrote:
> On Thu, Apr 16, 2009 at 02:37:53PM -0400, Vivek Goyal wrote:
> > On Wed, Apr 08, 2009 at 10:37:59PM +0200, Andrea Righi wrote:
> > 
> > [..]
> > > > 
> > > > - I can think of atleast one usage of uppper limit controller where we
> > > >   might have spare IO resources still we don't want to give it to a
> > > >   cgroup because customer has not paid for that kind of service level. In
> > > >   those cases we need to implement uppper limit also.
> > > > 
> > > >   May be prportional weight and max bw controller can co-exist depending
> > > >   on what user's requirements are.
> > > >  
> > > >   If yes, then can't this control be done at the same layer/level where
> > > >   proportional weight control is being done? IOW, this set of patches is
> > > >   trying to do prportional weight control at IO scheduler level. I think
> > > >   we should be able to store another max rate as another feature in 
> > > >   cgroup (apart from weight) and not dispatch requests from the queue if
> > > >   we have exceeded the max BW as specified by the user?
> > > 
> > > The more I think about a "perfect" solution (at least for my
> > > requirements), the more I'm convinced that we need both functionalities.
> > > 
> 
> hard limits vs work conserving argument again :). I agree, we need
> both of the functionalities. I think first the aim should be to get the
> proportional weight functionality and then look at doing hard limits.
> 

Agreed.

> [..]
> 
> > > > 
> > > > - Have you thought of doing hierarchical control? 
> > > > 
> > > 
> > > Providing hiearchies in cgroups is in general expensive, deeper
> > > hierarchies imply checking all the way up to the root cgroup, so I think
> > > we need to be very careful and be aware of the trade-offs before
> > > providing such feature. For this particular case (IO controller)
> > > wouldn't it be simpler and more efficient to just ignore hierarchies in
> > > the kernel and opportunely handle them in userspace? for absolute
> > > limiting rules this isn't difficult at all, just imagine a config file
> > > and a script or a deamon that dynamically create the opportune cgroups
> > > and configure them accordingly to what is defined in the configuration
> > > file.
> > > 
> > > I think we can simply define hierarchical dependencies in the
> > > configuration file, translate them in absolute values and use the
> > > absolute values to configure the cgroups' properties.
> > > 
> > > For example, we can just check that the BW allocated for a particular
> > > parent cgroup is not greater than the total BW allocated for the
> > > children. And for each child just use the min(parent_BW, BW) or equally
> > > divide the parent's BW among the children, etc.
> > 
> > IIUC, you are saying that allow hiearchy in user space and then flatten it
> > out and pass it to kernel?
> > 
> > Hmm.., agree that handling hierarchies is hard and expensive. But at the
> > same time rest of the controllers like cpu and memory are handling it in
> > kernel so it probably makes sense to keep the IO controller also in line.
> > 
> > In practice I am not expecting deep hiearchices. May be 2- 3 levels would
> > be good for most of the people.
> > 
> 
> FWIW, even in the CPU controller having deep hierarchies is not a good idea.
> I think this can be documented for IO Controller as well. Beyond that,
> we realized that having a proportional system and doing it in userspace
> is not a good idea. It would require a lot of calculations dependending
> on the system load. (Because, the sub-group should be just the same as a
> process in the parent group). Having hierarchy in the kernel just makes it way
> more easier and way more accurate.

Agreed. I will prefer to keep hierarchical support in kernel inline with
other controllers.

> 
> > > 
> > > > - What happens to the notion of CFQ task classes and task priority. Looks
> > > >   like max bw rule supercede everything. There is no way that an RT task
> > > >   get unlimited amount of disk BW even if it wants to? (There is no notion
> > > >   of RT cgroup etc)
> > > 
> > > What about moving all the RT tasks in a separate cgroup with unlimited
> > > BW?
> > 
> > Hmm.., I think that should work. I have yet to look at your patches in
> > detail but it looks like unlimited BW group will not be throttled at all
> > hence RT tasks can just go right through without getting impacted.
> > 
> 
> This is where the cpu scheduler design helped a lot :). Having different
> classes for differnet types of processes allowed us to handle them
> separately.

In common layer scheduling approach, we do have separate classes (RT, BE
and IDLE) and scheduling is done accordingly. Code primarily taken fro
bfq and cfq.

dm-ioband has no notion of separate classes and everything was being
treated at same level which is a problem as end level IO scheduler will
loose its capability to differentiate we mixup he things above it.

Time to play with max bw controller patches and then I can probably have
more insights into it.

Thanks
Vivek
