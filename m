From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Wed, 26 Jun 2013 18:04:27 -0700
Message-ID: <20130627010427.GF4536@htj.dyndns.org>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<CAAAKZwvh_R2Xz--bmSLiN33fsqKanOJMq_6+6hoFWFRx38O4gA@mail.gmail.com>
	<20130422214159.GG12543@htj.dyndns.org>
	<CAAAKZwuXJwwyj7KSqb7rZ+nrTwBWEaUCWfa7kWecTBnHL8koGw@mail.gmail.com>
	<CAAAKZwvP_7wBBYMmtFuiE2hZt=ByaLrnTyiR83CZr3OMip63Gg@mail.gmail.com>
	<20130625000118.GT1918@mtj.dyndns.org>
	<CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA@mail.gmail.com>
	<20130626212047.GB4536@htj.dyndns.org>
	<CAAAKZws1qkSik4G4pRr7z+067Jp9-jHfpx9-euqbvmdHjoN_Zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAAAKZws1qkSik4G4pRr7z+067Jp9-jHfpx9-euqbvmdHjoN_Zg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Cc: jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Wed, Jun 26, 2013 at 05:06:02PM -0700, Tim Hockin wrote:
> The first assertion, as I understood, was that (eventually) cgroupfs
> will not allow split hierarchies - that unified hierarchy would be the
> only mode.  Is that not the case?

No, unified hierarchy would be an optional thing for quite a while.

> The second assertion, as I understood, was that (eventually) cgroupfs
> would not support granting access to some cgroup control files to
> users (through chown/chmod).  Is that not the case?

Again, it'll be an opt-in thing.  The hierarchy controller would be
able to notice that and issue warnings if it wants to.

> Hmm, so what exactly is changing then?  If, as you say here, the
> existing interfaces will keep working - what is changing?

New interface is being added and new features will be added only for
the new interface.  The old one will eventually be deprecated and
removed, but that *years* away.

> As I said, it's controlled delegated access.  And we have some patches
> that we carry to prevent some of these DoS situations.

I don't know.  You can probably hack around some of the most serious
problems but the whole thing isn't built for proper delgation and
that's not the direction the upstream kernel is headed at the moment.

> I actually can not speak to the details of the default IO problem, as
> it happened before I really got involved.  But just think through it.
> If one half of the split has 5 processes running and the other half
> has 200, the processes in the 200 set each get FAR less spindle time
> than those in the 5 set.  That is NOT the semantic we need.  We're
> trying to offer ~equal access for users of the non-DTF class of jobs.
> 
> This is not the tail doing the wagging.  This is your assertion that
> something should work, when it just doesn't.  We have two, totally
> orthogonal classes of applications on two totally disjoint sets of
> resources.  Conjoining them is the wrong answer.

As I've said multiple times, there sure are things that you cannot
achieve without orthogonal multiple hierarchies, but given the options
we have at hands, compromising inside a unified hierarchy seems like
the best trade-off.  Please take a step back from the immediate detail
and think of the general hierarchical organization of workloads.  If
DTF / non-DTF is a fundamental part of your workload classfication,
that should go above.

I don't really understand your example anyway because you can classify
by DTF / non-DTF first and then just propagate cpuset settings along.
You won't lose anything that way, right?

Again, in general, you might not be able to achieve *exactly* what
you've been doing, but, an acceptable compromise should be possible
and not doing so leads to complete mess.

> > But I don't follow the conclusion here.  For short term workaround,
> > sure, but having that dictate the whole architecture decision seems
> > completely backwards to me.
> 
> My point is that the orthogonality of resources is intrinsic.  Letting
> "it's hard to make it work" dictate the architecture is what's
> backwards.

No, it's not "it's hard to make it work".  It's more "it's
fundamentally broken".  You can't identify a resource to be belonging
to a cgroup independent of who's looking at the resource.

> I'm not sure what "differing level of granularities" means?  But that

It means that you'll be able to ignore subtrees depending on
controllers.

> aside, who have you spoken to here?  On our internal discussions I
> have not heard a SINGLE member of our prod-kernel team nor our cluster
> management team who think this is a good idea.  Not one.

Some of memcg and blkcg people in infra kernel team.

> I still don't really get what the hellish mess is, and why it can't be
> solved another way.  Your statement of "unified hierarchy isn't gonna
> break them" is patently false, though.  If we did this it would a)
> cause a large amount of work to happen and b) cause a major regression
> for our users.

No, what I meant was that unified hierarchy won't break the multiple
hierarchy support immediately.

> I'm trying to understand your root problem so that I can try to find
> other solutions.  "Just do what I say" is not a great way to defend
> your position in the face of evidence to the contrary.  I'm presenting
> you real life cases of situations that simply do not work, neither
> philosophically nor in practice, and you continue to assert that it's
> fine.  It's not fine.

I wrote about that many times, but here are two of the problems.

* There's no way to designate a cgroup to a resource, because cgroup
  is only defined by the combination of who's looking at it for which
  controller.  That's how you end up with tagging the same resource
  multiple times for different controllers and even then it's broken
  as when you move resources from one cgroup to another, you can't
  tell what to do with other tags.

  While allowing obscene level of flexibility, multiple hierarchies
  destroy a very fundamental concept that it *should* provide - that
  of a resource container.  It can't because a "cgroup" is undefined
  under multiple hierarchies.

* The level of flexibility makes it very difficult to scope the common
  usage models.  It's a problem for both the kernel and userland.  The
  kernel has to be prepared to cope with anything - e.g. with unified
  hierarchy, we can assume things like either all tasks in a cgroup
  are frozen or not, with multiple, any combination is possible - and
  the userland is generally lost on what to do and has been in a
  complete disarray, and it's not really userland's fault because
  enforcing any rule would mean hindering some crazy setup that
  someone is using.

cgroup as it currently stands invites pretty insane usages which we
can't back out of later on.  Well, it's already painful to back out
but the sooner the better.  And all that for what?  Allowing exotic
specialized configurations which in all likelihood will be served
acceptably with unified hierarchy anyway?

> Somewhere I picked up the notion that you were talking about making
> these changes in O(1.5 years).  Perhaps I got that wrong.  what *is*
> the timeframe?  At what point will everything we depend on today no
> longer be supported?

I'm making the changes as soon as possible.  There of course are two
steps involved here - implementing the new thing and then removing the
old thing.  Implementing the new thing is gonna happen, hopefully, in
a year's timeframe.  The latter.  I don't know for sure but probably
over five years.

> OK.  So please shed some light?  Will split-hierarchies continue to
> work for the indefinite future?  Or will they be disabled at some
> point?  Or will they become so crippled or bit-rotted that they are
> effectively removed, without having to actually say that?

It's gonna be properly maintained but new features in general will
only be implemented for the unified hierarchy.  In time, hopefully,
the difference in capabilities between the new and old interfaces
combined with other efforts will drive users towards the new
interface.  After the old interface's usage has sufficiently dwindled,
it will be deprecated.

Thanks.

-- 
tejun
