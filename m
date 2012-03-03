From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Sat, 03 Mar 2012 01:58:57 -0800
Message-ID: <m162em2efy.fsf@fess.ebiederm.org>
References: <20120221211938.GE12236@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120221211938.GE12236-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> (Tejun Heo's message of "Tue,
	21 Feb 2012 13:19:38 -0800")
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
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:

> Hello, guys.
>
> I've been thinking about multiple hierarchy support in cgroup for a
> while, especially after Frederic's pending task counter patchset.
> This is a write up of what I've been thinking.  I don't know what to
> do yet and simply continuing the current situation definitely is an
> option, so please read on and throw in your 20 Won (or whatever amount
> in whatever currency you want).
>
> * The problems.
>
> The support for multiple process hierarchies always struck me as
> rather strange.  If you forget about the current cgroup controllers
> and their implementations, the *only* reason to support multiple
> hierarchies is if you want to apply resource limits based on different
> orthogonal categorizations.
>
> Documentation/cgroups.txt seems to be written with this consideration
> on mind.  It's giving an example of applying limits accoring to two
> orthogonal categorizations - user groups (profressors, students...)
> and applications (WWW, NFS...).  While it may sound like a valid use
> case, I'm very skeptical how useful or common mixing such orthogonal
> categorizations in a single setup would be.
>
> If support for multiple hierarchies comes for free, at least in terms
> of features, maybe it can be better but of course it isn't so.  Any
> given cgroup subsystem (or controller) can only be applied to a single
> hierarchy, which makes sense for a lot of things - what would two
> different limits on the same resource from different hierarchies mean?
> But, there also are things which can be used and useful in all
> hierarchies - e.g. cgroup freezer and task counter.
>
> While the current cgroup implementation and conventions can probably
> allow admins and engineers to tailor cgroup configuration for a
> specific setup, it is very difficult to use in generic and automated
> way.  I mean, who owns the freezer or task counter?  If they're
> mounted on their own hierarchies, how should they be structured?
> Should the different hierarchies be structured such that they are
> projections of one unified hierarchy so that those generic mechanisms
> can be applied uniformly?  If so, why do we need multiple hierarchies
> at all?

I think I will come in at suggesting we need the logical ability to nest
hierarchies.  That it makes sense for a process to put it's children
in which ever sort of sub-hiearchy that makes sense for it.

> A related limitation is that as different subsystems don't know which
> hierarchies they'll end up on, they can't cooperate.  Wouldn't it make
> more sense if task counter is a separate thing watching the resources
> and triggers different actions as conifgured - be it failing forks or
> freezing?
>
> And yet another oddity is how cgroup handles nested cgroups - some
> care about nesting but others just treat both internal and leaf nodes
> equally.  They don't care about the topology at all.  This, too, can
> be fine if you approach things subsys by subsys and use them in
> different ways but if you try to combine them in generic way you get
> sucked into the lala land of whatevers.
>
> The following is a "best practices" document on using cgroups.
>
>   http://www.freedesktop.org/wiki/Software/systemd/PaxControlGroups
>
> To me, it seems to demonstrate the rather ugly situation that the
> current cgroup is providing.  Everyone should tip-toe around cgroup
> hierarchies and nobody has full knowledge or control over them.
> e.g. base system management (e.g. systemd) can't use freezer or task
> counter as someone else might want to use it for different hierarchy
> layout.
>
> It seems to me that cgroup interface is too complicated and inflexible
> at the same time to be useful in generic manner.  Sure, it can be
> useful for setups individually crafted by engineers and admins to
> match specific sites or applications but as soon as you try to do
> something automatic and generic with it, there just are too many
> different scenarios and limitations to consider.

With this I agree.

> * So, what to do?
>
> Heh, I don't know.  IIRC, last year at LinuxCon Japan, I heard
> Christoph saying that the biggest problem w/ cgroup was that it was
> building completely separate hierarchies out of the traditional
> process hierarchies.  After thinking about this stuff for a while, I
> fully agree with him.  I think this whole thing should have been a
> layer over the process tree like sessions or program groups.

I am totally baffled at this reasoning.

The session and process group hierarchies are separate from the process
tree hierarchy.  Processes can be put in and taken out of process
groups. Think about what happens when a middle child exits.

One of the adopters of controls groups systemd wants control groups
because they implement groups that are separate from the process
hierarchy.

> Unfortunately, that ship sailed long ago and we gotta make do with
> what we have on our collective hands.  Here are some paths that we can
> take.
>
> 1. We're screwed anyway.  Just don't worry about it and continue down
>    on this path.  Can't get much worse, right?
>
>    This approach has the apparent advantage of not having to do
>    anything and is probably most likely to be taken.  This isn't ideal
>    but hey nothing is. :P
> 2. Make it more flexible (and likely more complex, unfortunately).
>    Allow the utility type subsystems to be used in multiple
>    hierarchies.  The easiest and probably dirtiest way to achieve that
>    would be embedding them into cgroup core.
>
>    Thinking about doing this depresses me and it's not like I have a
>    cheerful personality to begin with. :(
>
> 3. Head towards single hierarchy with the pie-in-the-sky goal of
>    merging things into process hierarchy in some distant future.
>
>    The first step would be herding people to use a unified hierarchy
>    (ie. all subsystems mounted on a single cgroup tree) which is
>    controlled by single entity in userland (be it systemd or cgroupd,
>    cgroup-kit or whatever); however, even if we exclude supporting
>    orthogonal categorizations, there are good number of non-trivial
>    hurdles to clear before this can be realized.
>
>    Most importantly, we would need to clean up how nesting is handled
>    across different subsystems.  Handling internal and leaf nodes as
>    equals simply can't work.  Membership should be recursive, and for
>    subsystems which can't support proper nesting, the right thing to
>    do would be somehow ensuring that only single node in the path from
>    root to leaf is active for the controller.  We may even have to
>    introduce an alternative of operation to support this (yuck).
>
>    This path would require the most amount of work and we would be
>    excluding a feature - support for multiple orthogonal
>    categorizations - which has been available till now, probably
>    through deprecation process spanning years; however, this at least
>    gives us hope that we may reach sanity in the end, how distant that
>    end may be.  Oh, hope. :)

4.  Only allow a single controller per hierarchy.  So that we can
make reasonable choice points.  If the hierarchy is to be about
policy I am baffled by concept of putting multiple controllers in
a single hierarchy.  Because where you clump things together for
policy for one controller in general does not seem to be where you
want to clump things together for another controller.

> So, I mean, I don't know.  What do other people think?  Is this a
> unnecessary worry?  Are people generally happy with the way things
> are?  Lennart, Kay, what do you guys think?

I think the current situation is crazy.

I especially think it is crazy that inside a container I can't create
a fresh set of cgroup mounts, and establish a fresh "hierarchy" relative
to the process that created the cgroup mounts.  It sucks that
controllers may nest fine but hierarchies don't nest.


Eric
