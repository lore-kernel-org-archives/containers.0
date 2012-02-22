From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Wed, 22 Feb 2012 16:45:04 +0100
Message-ID: <20120222154501.GA1693@somewhere.redhat.com>
References: <20120221211938.GE12236@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120221211938.GE12236-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 21, 2012 at 01:19:38PM -0800, Tejun Heo wrote:
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
> 
> A related limitation is that as different subsystems don't know which
> hierarchies they'll end up on, they can't cooperate.  Wouldn't it make
> more sense if task counter is a separate thing watching the resources
> and triggers different actions as conifgured - be it failing forks or
> freezing?

For this particular example, I think we'd better have a file in which
a task can poll and get woken up when the task limit has been reached.
Then that task can decide to freeze or whatever.

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
> 
> 
> * So, what to do?
> 
> Heh, I don't know.  IIRC, last year at LinuxCon Japan, I heard
> Christoph saying that the biggest problem w/ cgroup was that it was
> building completely separate hierarchies out of the traditional
> process hierarchies.  After thinking about this stuff for a while, I
> fully agree with him.  I think this whole thing should have been a
> layer over the process tree like sessions or program groups.
> 
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

Thing is we have an ABI now and it has been there for a while now. Aren't
we stuck with it? I'm no big fan of that multiple hierarchies thing either
but now I fear we have to support it.

> 
> 2. Make it more flexible (and likely more complex, unfortunately).
>    Allow the utility type subsystems to be used in multiple
>    hierarchies.  The easiest and probably dirtiest way to achieve that
>    would be embedding them into cgroup core.
> 
>    Thinking about doing this depresses me and it's not like I have a
>    cheerful personality to begin with. :(

Another solution is to support a class of multi-bindable subsystems as in
this old patch from Paul:

	https://lkml.org/lkml/2009/7/1/578

It sounds to me more healthy to iterate only over subsystems in fork/exit.
We probably don't want to add a new iteration over cgroups themselves
on these fast path.
