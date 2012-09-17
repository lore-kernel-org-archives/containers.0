From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Mon, 17 Sep 2012 11:05:18 -0400
Message-ID: <20120917150518.GB5094@redhat.com>
References: <20120913205827.GO7677@google.com>
	<20120914142539.GC6221@redhat.com>
	<20120914213938.GV17747@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120914213938.GV17747-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Sep 14, 2012 at 02:39:38PM -0700, Tejun Heo wrote:
[..]
> > I am still little concerned about changing the blkio behavior
> > unexpectedly. Can we have some kind of mount time flag which retains
> > the old flat behavior and we warn user that this mode is deprecated
> > and will soon be removed. Move over to hierarchical mode. Then after
> > few release we can drop the flag and cleanup any extra code which
> > supports flat mode in CFQ. This will atleast make transition smooth.
> 
> I don't know.  That essentially is what we're doing with memcg now and
> it doesn't seem any less messy.  Given the already scary complexity,
> do we really want to support both flat and hierarchy models at the
> same time?

As a developer, I will be happy to support only one model and keep code
simple. I am only concerned that for blkcg we have still not charted
out a clear migration path. The warning message your patch is giving
out will work only if we decide to not treat task and groups at same
level.

I guess first we need to decide task vs groups issue and then look
into this issue again.

> 
> > >   memcg can be handled by memcg people and I can handle cgroup_freezer
> > >   and others with help from the authors.  The problematic one is
> > >   blkio.  If anyone is interested in working on blkio, please be my
> > >   guest.  Vivek?  Glauber?
> > 
> > I will try to spend some time on this. Doing changes in blk-throttle
> > should be relatively easy. Painful part if CFQ. It does so much that
> > it is not clear whether a particular change will bite us badly or
> > not. So doing changes becomes hard. There are heuristics, preemptions,
> > queue selection logic, service tree and bringing it all together
> > for full hierarchy becomes interesting.
> > 
> > I think first thing which needs to be done is merge group scheduling
> > and cfqq scheduling. Because of flat hierarchy currently we use two
> > scheduling algorithm. Old logic for queue selection and new logic
> > for group scheduling. If we treat task and group at same level then
> > we have to merge two and come up with single logic.
> 
> I think this depends on how we decide to handle tasks vs. groups,
> right?

Yes. If we decide to account all the tasks of a group into a hidden
group which completes with other group children, then there is no
way one can create hiearchy where tasks and groups are competing at
same level. So we can still continue to retain the existing logic.

> 
> > [..]
> > >   * Vivek brought up the issue of distributing resources to tasks and
> > >     groups in the same cgroup.  I don't know.  Need to think more
> > >     about it.
> > 
> > This one will require some thought. I have heard arguments for both the
> > models. Treating tasks and groups at same level seem to have one
> > disadvantange and that is that people can't think of system resources
> > in terms of %. People often say, give 20% of disk resources to a
> > particular cgroup. But it is not possible as there are all kernel
> > threads running in root cgroup and tasks come and go and that means
> > % share of a group is variable and not fixed.
> 
> Another problem is that configuration isn't contained in cgroup
> proper.  We need a way to assign weights to individual tasks which can
> be somehow directly compared against group weights.  cpu cooks
> priority for this and blkcg may be able to cook ioprio but it's nasty
> and unobvious.  Also, let's say we grow network bandwidth controller
> for whatever reason.  What value are we gonna use?

So if somebody cares about settting SO_PRIORITY for traffic originating
from a tasks, move it into a cgroup. Otherwise they all get default
priority.

I think question here is that why do you want to provide a hidden group
as default mechianism from kernel. If a user does not like the idea of
tasks and groups competing at same level, he can always create a cgroups
and move all the tasks there. Only thing we need to provide is reliable
ways of migrating group of tasks into other cgroups at run time.

By creating a hidden group for tasks, there also comes an issue for
configuration of that hidden group (group weight, stats etc). By forcing
user space to create a new group for tasks, it is an explicit cgroup
and user space already knows how to handle it.

So to me, leaving this decision to userspace based on their requirement
makes sense.

Also, I think cpu controller has already discussed this in the past
(the possibility of a hidden group for tasks). Peter will have
more details about it, I think.

> 
> > To make it fixed, we will need to make sure that number of entities
> > fighting for resources are not variable. That means only group fight
> > for resources at a level and tasks with-in groups. 
> > 
> > Now the question is should kernel enforce it or should it be left to 
> > user space. I think doing it in user space is also messy as different
> > agents control different part of hiearchy. For example, if somebody says
> > that give a particular virtual machine a x% of system resource, libvirt
> > has no way to do that. At max it can ensure x% of parent group but above
> > that hierarchy is controlled by systemd and libvirtd has no control
> > over that.
> >
> > Only possible way to do this will seem to be that systemd creates libvirt
> > group at top level with a minimum fixed % of quota and then libvirt can
> > figure out % share of each virtual machine. But it is hard to do.
> > 
> > So while % model is more intutive to users, it is hard to implement. So
> > an easier way is to stick to the model of relative weights/share and
> > let user specify relative importance of a virtual machine and actual
> > quota or % will vary dynamically depending on other tasks/components
> > in the system.
> 
> Why is it hard to implement?  You just need to treat tasks in the
> current node as another group competing with other cgroups on equal
> terms.  If anything, isn't that simpler than treating scheduling
> "entities"?

I meant "hard to implement" in the sense of if kernel has to keep track of
% and enforce it across hiearchy etc.

Yes, creating a hidden group for tasks in current group should not be
hard from implementation point of view. But again, I am concerned about
configuration of hidden group and I also don't like the idea of taking
flexibility away from user to treat tasks and group at same level.

Thanks
Vivek
