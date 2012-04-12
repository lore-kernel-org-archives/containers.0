From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [RFD] Merge task counter into memcg
Date: Thu, 12 Apr 2012 17:30:55 +0200
Message-ID: <20120412153055.GL1787__25478.8312865005$1334244689$gmane$org@cmpxchg.org>
References: <20120411185715.GA4317@somewhere.redhat.com>
	<4F862851.3040208@jp.fujitsu.com>
	<20120412113217.GB11455@somewhere.redhat.com>
	<4F86BFC6.2050400@parallels.com>
	<20120412123256.GI1787@cmpxchg.org>
	<4F86D4BD.1040305@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F86D4BD.1040305-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 12, 2012 at 10:12:29AM -0300, Glauber Costa wrote:
> On 04/12/2012 09:32 AM, Johannes Weiner wrote:
> >On Thu, Apr 12, 2012 at 08:43:02AM -0300, Glauber Costa wrote:
> >>On 04/12/2012 08:32 AM, Frederic Weisbecker wrote:
> >>>>But I think increasing number of subsystem is not very good....
> >>>If the result is a better granularity on the overhead, I believe this
> >>>can be a good thing.
> >>
> >>But again, since there is quite number of people trying to merge
> >>those stuff together, you are just swimming against the tide.
> >
> >I don't see where merging unrelated controllers together is being
> >discussed, do you have a reference?
> 
> https://lkml.org/lkml/2012/2/21/379
> 
> But also, I believe this has been widely discussed in person by
> people, in separate groups. Maybe Tejun can do a small writeup of
> where we stand?
> 
> I would also point out that this is exactly what it is (IMHO): an
> ongoing discussion. You are more than welcome to chime in.

I thought the conclusion was that nobody really had any sane use case
for multiple hierarchies.  So while nobody wanted to just disable them
in fear of breaking someones usecase, individual controllers still can
only be active in a single hierarchy.  I don't see why the task
controller should now as a precedence support a level of flexibility
that is very doubtful in the first place.

> >>If this gets really integrated, out of a sudden the overhead will
> >>appear. So better care about it now.
> >
> >Forcing people that want to account/limit one resource to take the hit
> >for something else they are not interested in requires justification.
> 
> Agree. Even people aiming for unified hierarchies are okay with an
> opt-in/out system, I believe. So the controllers need not to be
> active at all times. One way of doing this is what I suggested to
> Frederic: If you don't limit, don't account.

I don't agree, it's a valid usecase to monitor a workload without
limiting it in any way.  I do it all the time.

> >You can optimize only so much, in the end, the hierarchical accounting
> >is just expensive and unacceptable if you don't care about a certain
> >resource.  For that reason, I think controllers should stay opt-in.
> 
> see above.
> 
> >Btw, can we please have a discussion where raised concerns are
> >supported by more than gut feeling?  "I think X is not very good" is
> >hardly an argument.  Where is the technical problem in increasing the
> >number of available controllers?
> 
> Kame said that, not me. But FWIW, I don't disagree. And this is
> hardly gut feeling.
> 
> A big number of controllers creates complexity. When coding, we can
> assume a lot less things about their relationships, and more
> importantly: at some point people get confused. Fuck, sometimes *we*
> get confused about which controller do what, where its
> responsibility end and where the other's begin. And we're the ones
> writing it! Avoiding complexity is an engineering principle, not a
> gut feeling.

And that's why I have a horrible feeling about extending the cgroup
core to do hierarchical accounting and limiting.  See below.

> Now, of course, we should aim to make things as simple as possible,
> but not simpler: So you can argue that in Frederic's specific case,
> it is justified. And I'd be fine with that 100 %. If I agreed...
> 
> There are two natural points for inclusion here:
> 
> 1) every cgroup has a task counter by itself. If we're putting the
> tasks there anyway, this provides a natural point of accounting.

I do think there is a big difference between having a list of tasks
per individual cgroup to manage basic task-cgroup relationship on one
hand, and accounting and limiting the number of allowed tasks over
multi-level group hierarchies on the other.  It may seem natural on
the face of it, but it really isn't, IMO.  One is basic plumbing, the
other is applying actual semantics to a hierarchy of groups, which has
always been the domain of controllers.  It's simply a layering
violation in my eyes.

> 2) The cpu cgroup, in the end, is the realm of the scheduler. We
> determine which % of the cpu the process will get, bandwidth, time
> spent by tasks, and all that. It is also more natural for that,
> because it is task based.
> 
> Don't get me wrong: I actually love the feature Frederic is working on.
> I just don't believe a different controller is justified. Nor do I
> believe memcg is the place for that (specially now that I thought it
> overnight)

To reraise a point from my other email that was ignored: do users
actually really care about the number of tasks when they want to
prevent forkbombs?  If a task would use neither CPU nor memory, you
would not be interested in limiting the number of tasks.

Because the number of tasks is not a resource.  CPU and memory are.

So again, if we would include the memory impact of tasks properly
(structures, kernel stack pages) in the kernel memory counters which
we allow to limit, shouldn't this solve our problem?

You said in private email that you didn't like the idea because
administrators wouldn't know how big the kernel stack was and that the
number of tasks would be a more natural thing to limit.  But I think
that is actually an argument in favor of the kmem approach: the user
has no idea how much impact a task actually has resource-wise!  On the
other hand, he knows exactly how much memory and CPU his machine has
and how he wants to distribute these resources.  So why provide him
with an interface to control some number in an unknowwn unit?

You don't propose we allow limiting the number of dcache entries,
either, but rather the memory they use.

The historical limiting of number of tasks through rlimit is anything
but scientific or natural.  You essentially set it to a random value
between allowing most users to do their job and preventing things from
taking down the machine.  With proper resource accounting, which we
want to have anyway, we can do much better than that, so why shouldn't
we?
