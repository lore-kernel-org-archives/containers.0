From: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Mon, 22 Apr 2013 23:26:48 +0200
Message-ID: <CAAAKZwvh_R2Xz--bmSLiN33fsqKanOJMq_6+6hoFWFRx38O4gA__21291.0804468722$1366666039$gmane$org@mail.gmail.com>
References: <20130406012159.GA17159@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130406012159.GA17159-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Tejun,

This email worries me.  A lot.  It sounds very much like retrograde
motion from our (Google's) point of view.

We absolutely depend on the ability to split cgroup hierarchies.  It
pretty much saved our fleet from imploding, in a way that a unified
hierarchy just could not do.  A mandated unified hierarchy is madness.
 Please step away from the ledge.

More, going towards a unified hierarchy really limits what we can
delegate, and that is the word of the day.  We've got a central
authority agent running which manages cgroups, and we want out of this
business.  At least, we want to be able to grant users a set of
constraints, and then let them run wild within those constraints.
Forcing all such work to go through a daemon has proven to be very
problematic, and it has been great now that users can have DIY
sub-cgroups.

berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org said, downthread:

> We ultimately do need the ability to delegate hierarchy creation to
> unprivileged users / programs, in order to allow containerized OS to
> have the ability to use cgroups. Requiring any applications inside a
> container to talk to a cgroups "authority" existing on the host OS is
> not a satisfactory architecture. We need to allow for a container to
> be self-contained in its usage of cgroups.

This!  A thousand times, this!

> At the same time, we don't need/want to give them unrestricted ability
> to create arbitarily complex hiearchies - we need some limits on it
> to avoid them exposing pathelogically bad kernel behaviour.
>
> This could be as simple as saying that each cgroup controller directory
> has a tunable "cgroups.max_children" and/or "cgroups.max_depth" which
> allow limits to be placed when delegating administration of part of a
>cgroups tree to an unprivileged user.

We've been bitten by this, and more limitations would be great.  We've
got some less-than-perfect patches that impose limits for us now.

> I've no disagreement that we need a unified hiearchy. The workman
> app explicitly does /not/ expose the concept of differing hiearchies
> per controller. Likewise libvirt will not allow the user to configure
> non-unified hiearchies.

Strong disagreement, here.  We use split hierarchies to great effect.
Containment should be composable.  If your users or abstractions can't
handle it, please feel free to co-mount the universe, but please
PLEASE don't force us to.

I'm happy to talk more about what we do and why.

Tim




On Sat, Apr 6, 2013 at 3:21 AM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Hello, guys.
>
>  Status-quo
>  ==========
>
> It's been about a year since I wrote up a summary on cgroup status quo
> and future plans.  We're not there yet but much closer than we were
> before.  At least the locking and object life-time management aren't
> crazy anymore and most controllers now support proper hierarchy
> although not all of them agree on how to treat inheritance.
>
> IIRC, the yet-to-be-converted ones are blk-throttle and perf.  cpu
> needs to be updated so that it at least supports a similar mechanism
> as cfq-iosched for configuring ratio between tasks on an internal
> cgroup and its children.  Also, we really should update how cpuset
> handles a cgroup becoming empty (no cpus or memory node left due to
> hot-unplug).  It currently transfers all its tasks to the nearest
> ancestor with executing resources, which is an irreversible process
> which would affect all other co-mounted controllers.  We probably want
> it to just take on the masks of the ancestor until its own executing
> resources become online again, and the new behavior should be gated
> behind a switch (Li, can you please look into this?).
>
> While we have still ways to go, I feel relatively confident saying
> that we aren't too far out now, well, except for the writeback mess
> that still needs to be tackled.  Anyways, once the remaining bits are
> settled, we can proceed to implement the unified hierarchy mode I've
> been talking about forever.  I can't think of any fundamental
> roadblocks at the moment but who knows?  The devil usually is in the
> details.  Let's hope it goes okay.
>
> So, while we aren't moving as fast as we wish we were, the kernel side
> of things are falling into places.  At least, that's how I see it.
> From now on, I think how to make it actually useable to userland
> deserves a bit more focus, and by "useable to userland", I don't mean
> some group hacking up an elaborate, manual configuration which is
> tailored to the point of being eccentric to suit the needs of the said
> group.  There's nothing wrong with that and they can continue to do
> so, but it just isn't generically useable or useful.  It should be
> possible to generically and automatically split resources among, say,
> several servers and a couple users sharing a system without resorting
> to indecipherable ad-hoc shell script running off rc.local.
>
>
>  Userland efforts
>  ================
>
> There are currently a few userland efforts trying to make interfacing
> with cgroup less painful.
>
> * libcg: Make cgroup interface accessible from programming languages
>   with support for configuration persistency, which also brings its
>   own config files to remember what to do on the next boot.  Sans the
>   persistence part, it just seems to directly translate the filesystem
>   interface to function interface.
>
>   http://libcg.sourceforge.net/
>
> * Workman: It's a rather young project but as its name (workload
>   management) implies, its aims are higher level than that of libcg.
>   It aims to provide high-level resource allocation and management and
>   introduces new concepts like resource partitions to represent its
>   view of resource hierarchy.  Like libcg, this one is implemented as
>   a library but provides bindings for more languages.
>
>   https://gitorious.org/workman/pages/Home
>
> * Pax Controla Groupiana: A document on how not to step on other's
>   toes while using cgroup.  It's not a software project but tries to
>   define precautions that a software or user can take to avoid
>   breaking or confusing other users of the cgroup filesystem.
>
>   http://www.freedesktop.org/wiki/Software/systemd/PaxControlGroups
>
> All try to play nice with other possible users of the cgroup
> filesystem - be it libvirt cgroup, applications doing their own cgroup
> tricks, or hand-crafted custom scripts.  While the approach is
> understandable given that those usages already exist, I don't think
> it's a workable solution in the long term.  There are several reasons
> for that.
>
> * The configurations aren't independent.  e.g. for weight-based
>   controllers, your weight is only meaningful in relation to other
>   weights at that level.  Distributing configuration to whatever
>   entities which may write to cgroupfs simply cannot work.  It's
>   fundamentally flawed.
>
> * It's fragile like hell.  There's no accountability.  Nobody really
>   knows what's going on.  Is this subdirectory still there due to a
>   bug in this program, or something or someone else created it and
>   crashed / forgot to remove it, or what?  Oh, the cgroup I wanted to
>   create already exists.  Maybe the previous instance created it and
>   then crashed or maybe some other program just happened to choose the
>   same name.  Who owns config knobs in that directory?  This way lies
>   madness.  I understand why the Pax doc exists but I'm not sure its
>   long-term effect would be positive - best practices which ultimately
>   lead to utter confusion and fragility.
>
> * In many cases, resource distribution is system-wide policy decisions
>   and determining what to do often requires system-wide knowledge.
>   You can't provision memory limits without knowing what's available
>   in the system and what else is going on in the system, and you want
>   to be able to adjust them as situation and configuration changes.
>   Without anybody having full picture of how resources are
>   provisioned, how would any of that be possible?
>
> I think this anything-goes approach is prevalent largely because the
> cgroup filesystem interface encourages such usage.  From the looks of
> it, the filesystem permissions combined with hierarchy should be able
> to handle delegation perfectly.  Well, as it currently stands, it's
> anything but and the interface is just misleading.  Hierarchy support
> was an utter mess, configuration schemes aren't uniform across
> controllers, and, more fundamentally, hierarchy itself is expensive -
> we can't delegate hierarchy creation to unpriviledged users or
> programs safely.
>
> It is in the realm of possibility to make all cgroup operations and
> controllers to do all that; however, it's a very tall order.  Just
> think about how much effort it has been to achieve and maintain proper
> delegation in the core elements of the kernel - processes and
> filesystems, and there will be security implications with cgroup
> likely involving a lot of gotchas and extensions of security
> infrastructures, and, even then, I'm pretty sure it's gonna require
> helps from userland to effect proper policy decisions and config
> changes.  We have things like polkit for a reason and are likely to
> need finer-grained, domain-aware access control than is possible with
> tweaking directory permissions.
>
> Given the above and how relatively marginal cgroup is, I'm extremely
> skeptical that implementing full delegation in kernel is the right
> course of action and likely to scream like a banshee at any attempt
> driving things that way.
>
> I think the only logical thing to do is creating a centralized
> userland authority which takes full ownership of the cgroup filesystem
> interface, gives it a sane structure, represents available resources
> in a sane form, and makes policy decisions based on configuration and
> requests.  I don't have a concerete idea what that authority should be
> like, but I think there already are pretty similar facilities in our
> userland, and don't see why this should be much different.
>
> Another reason why this could be helpful is that we're gonna be
> morphing towards unified hierarchy and it'd very nice to have
> something which can match impedance between the old and new ways and
> not require each individual consumer of cgroup to handle such changes.
> As for the unified hierarchy, we just have to.  It's currently
> fundamentally broken in that it's impossible to tell which cgroup a
> resource belongs to independent of which task is looking at it.  It's
> like this damn thing is designed to honor Hisenberg and Einstein.  No
> disrespect for the great minds, but it just doens't look like the
> proper place.
>
> Even apart from the unified hierarchy thing, I think it generally is a
> good idea to have a buffer layer between the kernel interface and
> individual consumers for cgroup, which is still very immature and
> kinda tightly coupled with internal implementation details.
>
> So, umm, that's what I want.  When I first heard of WorkMan, I was
> excited thinking maybe the universe is being really nice and making
> things happen to my wishes without me actually doing anything. :) Oh
> well, one can dream, but everything is still early, so hopefully we
> have enough time to figure things out.
>
> What do you guys think?
>
> Thanks.
>
> --
> tejun
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
