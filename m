From: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Thu, 27 Jun 2013 13:46:18 -0700
Message-ID: <CAAAKZwvabGRsce43ymru7OBr0LX93DRnTVkzn-nhahTR6yMUZw__43039.093926973$1372366010$gmane$org@mail.gmail.com>
References: <CAAAKZwvh_R2Xz--bmSLiN33fsqKanOJMq_6+6hoFWFRx38O4gA@mail.gmail.com>
	<20130422214159.GG12543@htj.dyndns.org>
	<CAAAKZwuXJwwyj7KSqb7rZ+nrTwBWEaUCWfa7kWecTBnHL8koGw@mail.gmail.com>
	<CAAAKZwvP_7wBBYMmtFuiE2hZt=ByaLrnTyiR83CZr3OMip63Gg@mail.gmail.com>
	<20130625000118.GT1918@mtj.dyndns.org>
	<CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA@mail.gmail.com>
	<20130626212047.GB4536@htj.dyndns.org>
	<CAAAKZws1qkSik4G4pRr7z+067Jp9-jHfpx9-euqbvmdHjoN_Zg@mail.gmail.com>
	<20130627010427.GF4536@htj.dyndns.org>
	<CAAAKZwsMT7FRccyVxSn77GR8+9JsSeqmDO6oOy7ycNCY7Desnw@mail.gmail.com>
	<20130627173809.GB5599@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130627173809.GB5599-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, dawnchen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jun 27, 2013 at 10:38 AM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Hello, Tim.
>
> On Wed, Jun 26, 2013 at 08:42:21PM -0700, Tim Hockin wrote:
>> OK, then what I don't know is what is the new interface?  A new cgroupfs?
>
> It's gonna be a new mount option for cgroupfs.
>
>> DTF and CPU and cpuset all have "default" groups for some tasks (and
>> not others) in our world today.  DTF actually has default, prio, and
>> "normal".  I was simplifying before.  I really wish it were as simple
>> as you think it is.  But if it were, do you think I'd still be
>> arguing?
>
> How am I supposed to know when you don't communicate it but just wave
> your hands saying it's all very complicated?  The cpuset / blkcg
> example is pretty bad because you can enforce any cpuset rules at the
> leaves.

Modifying hundreds of cgroups is really painful, and yes, we do it
often enough to be able to see it.

>> This really doesn't scale when I have thousands of jobs running.
>> Being able to disable at some levels on some controllers probably
>> helps some, but I can't say for sure without knowing the new interface
>
> How does the number of jobs affect it?  Does each job create a new
> cgroup?

Well, in your model it does...

>> We tried it in unified hierarchy.  We had our Top People on the
>> problem.  The best we could get was bad enough that we embarked on a
>> LITERAL 2 year transition to make it better.
>
> What didn't work?  What part was so bad?  I find it pretty difficult
> to believe that multiple orthogonal hierarchies is the only possible
> solution, so please elaborate the issues that you guys have
> experienced.

I'm looping in more Google people.

> The hierarchy is for organization and enforcement of dynamic
> hierarchical resource distribution and that's it.  If its expressive
> power is lacking, take compromise or tune the configuration according
> to the workloads.  The latter is necessary in workloads which have
> clear distinction of foreground and background anyway - anything which
> interacts with human beings including androids.

So what you're saying is that you don't care that this new thing is
less capable than the old thing, despite it having real impact.

>> In other words, define a container as a set of cgroups, one under each
>> each active controller type.  A TID enters the container atomically,
>> joining all of the cgroups or none of the cgroups.
>>
>> container C1 = { /cgroup/cpu/foo, /cgroup/memory/bar,
>> /cgroup/io/default/foo/bar, /cgroup/cpuset/
>>
>> This is an abstraction that we maintain in userspace (more or less)
>> and we do actually have headaches from split hierarchies here
>> (handling partial failures, non-atomic joins, etc)
>
> That'd separate out task organization from controllre config
> hierarchies.  Kay had a similar idea some time ago.  I think it makes
> things even more complex than it is right now.  I'll continue on this
> below.
>
>> I'm still a bit fuzzy - is all of this written somewhere?
>
> If you dig through cgroup ML, most are there.  There'll be
> "cgroup.controllers" file with which you can enable / disable
> controllers.  Enabling a controller in a cgroup implies that the
> controller is enabled in all ancestors.

Implies or requires?  Cause or predicate?

If controller C is enabled at level X but disabled at level X/Y, does
that mean that X/Y uses the limits set in X?  How about X/Y/Z?

This will get rid of the bulk of the cpuset scaling problem, but not
all of it.  I think we still have the same problems with cpu as we do
with io.  Perhaps that should have been the example.

>> It sounds like you're missing a layer of abstraction.  Why not add the
>> abstraction you want to expose on top of powerful primitives, instead
>> of dumbing down the primitives?
>
> It sure would be possible build more and try to address the issues
> we're seeing now; however, after looking at cgroups for some time now,
> the underlying theme is failure to take reasonable trade-offs and
> going for maximum flexibility in making each choice - the choice of
> interface, multiple hierarchies, no restriction on hierarchical
> behavior, splitting threads of the same process into separate cgroups,
> semi-encouraging delegation through file permission without actually
> pondering the consequences and so on.  And each choice probably made
> sense trying to serve each immediate requirement at the time but added
> up it's a giant pile of mess which developed without direction.

I am very sympathetic to this problem.  You could have just described
some of our internal problems too.  The difference is that we are
trying to make changes that provide more structure and boundaries in
ways that retain the fundamental power, without tossing out the baby
with the bathwater.

> So, at this point, I'm very skeptical about adding more flexibility.
> Once the basics are settled, we sure can look into the missing pieces
> but I don't think that's what we should be doing right now.  Another
> thing is that the unified hierarchy can be implemented by using most
> of the constructs cgroup core already has in more controller way.
> Given that we're gonna have to maintain both interfaces for quite some
> time, the deviation should be kept as minimal as possible.
>
>> But it seems vastly better to define a next-gen API that retains the
>> important flexibility but adds structure where it was lacking
>> previously.
>
> I suppose that's where we disagree.  I think a lot of cgroup's
> problems stem from too much flexibility.  The problem with such level
> of flexibility is that, in addition to breaking fundamental constructs
> and adding significantly to maintenance overhead, it blocks reasonable
> trade-offs to be made at the right places, in turn requiring more
> "flexibility" to address the introduced deficiencies.

So take away some of the flexibility that has minimal impact and
maximum return.  Splitting threads across cgroups - we use it, but we
could get off that.  Force all-or-nothing joining of an aggregate
construct (a container vs N cgroups).

But perform surgery with a scalpel, not a hatchet.
