From: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Wed, 26 Jun 2013 17:06:02 -0700
Message-ID: <CAAAKZws1qkSik4G4pRr7z+067Jp9-jHfpx9-euqbvmdHjoN_Zg__33837.1858852499$1372291596$gmane$org@mail.gmail.com>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<CAAAKZwvh_R2Xz--bmSLiN33fsqKanOJMq_6+6hoFWFRx38O4gA@mail.gmail.com>
	<20130422214159.GG12543@htj.dyndns.org>
	<CAAAKZwuXJwwyj7KSqb7rZ+nrTwBWEaUCWfa7kWecTBnHL8koGw@mail.gmail.com>
	<CAAAKZwvP_7wBBYMmtFuiE2hZt=ByaLrnTyiR83CZr3OMip63Gg@mail.gmail.com>
	<20130625000118.GT1918@mtj.dyndns.org>
	<CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA@mail.gmail.com>
	<20130626212047.GB4536@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130626212047.GB4536-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jun 26, 2013 at 2:20 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Hello, Tim.
>
> On Mon, Jun 24, 2013 at 09:07:47PM -0700, Tim Hockin wrote:
>> I really want to understand why this is SO IMPORTANT that you have to
>> break userspace compatibility?  I mean, isn't Linux supposed to be the
>> OS with the stable kernel interface?  I've seen Linus rant time and
>> time again about this - why is it OK now?
>
> What the hell are you talking about?  Nobody is breaking userland
> interface.  A new version of interface is being phased in and the old

The first assertion, as I understood, was that (eventually) cgroupfs
will not allow split hierarchies - that unified hierarchy would be the
only mode.  Is that not the case?

The second assertion, as I understood, was that (eventually) cgroupfs
would not support granting access to some cgroup control files to
users (through chown/chmod).  Is that not the case?

> one will stay there for the foreseeable future.  It will be phased out
> eventually but that's gonna take a long time and it will have to be
> something hardly noticeable.  Of course new features will only be
> available with the new interface and there will be efforts to nudge
> people away from the old one but the existing interface will keep
> working it does.

Hmm, so what exactly is changing then?  If, as you say here, the
existing interfaces will keep working - what is changing?

>> Examples?  we obviously don't grant full access, but our kernel gang
>> and security gang seem to trust the bits we're enabling well enough...
>
> Then the security gang doesn't have any clue what's going on, or at
> least operating on very different assumptions (ie. the workloads are
> trusted by default).  You can OOM the whole kernel by creating many
> cgroups, completely mess up controllers by creating deep hierarchies,
> affect your siblings by adjusting your weight and so on.  It's really
> easy to DoS the whole system if you have write access to a cgroup
> directory.

As I said, it's controlled delegated access.  And we have some patches
that we carry to prevent some of these DoS situations.

>> The non-DTF jobs have a combined share that is small but non-trivial.
>> If we cut that share in half, giving one slice to prod and one slice
>> to batch, we get bad sharing under contention.  We tried this.  We
>
> Why is that tho?  It *should* work fine and I can't think of a reason
> why that would behave particularly badly off the top of my head.
> Maybe I forgot too much of the iosched modification used in google.
> Anyways, if there's a problem, that should be fixable, right?  And
> controller-specific issues like that should really dictate the
> architectural design too much.

I actually can not speak to the details of the default IO problem, as
it happened before I really got involved.  But just think through it.
If one half of the split has 5 processes running and the other half
has 200, the processes in the 200 set each get FAR less spindle time
than those in the 5 set.  That is NOT the semantic we need.  We're
trying to offer ~equal access for users of the non-DTF class of jobs.

This is not the tail doing the wagging.  This is your assertion that
something should work, when it just doesn't.  We have two, totally
orthogonal classes of applications on two totally disjoint sets of
resources.  Conjoining them is the wrong answer.

>> could add control loops in userspace code which try to balance the
>> shares in proportion to the load.  We did that with CPU, and it's sort
>
> Yeah, that is horrible.

Yeah, I would love to explain some of the really nasty things we have
done and are moving away from.  I am not sure I am allowed to, though
:)

>> of horrible.  We're moving AWAY from all this craziness in favor of
>> well-defined hierarchical behaviors.
>
> But I don't follow the conclusion here.  For short term workaround,
> sure, but having that dictate the whole architecture decision seems
> completely backwards to me.

My point is that the orthogonality of resources is intrinsic.  Letting
"it's hard to make it work" dictate the architecture is what's
backwards.

>> It's a bit naive to think that this is some absolute truth, don't you
>> think?  It just isn't so.  You should know better than most what
>> craziness our users do, and what (legit) rationales they can produce.
>> I have $large_number of machines running $huge_number of jobs from
>> thousands of developers running for years upon years backing up my
>> worldview.
>
> If so, you aren't communicating it very well.  I've talked with quite
> a few people about multiple orthogonal hierarchies including people
> inside google.  Sure, some are using it as it is there but I couldn't
> find strong enough rationale to continue that way given the amount of
> crazys it implies / encourages.  On the other hand, most people agreed
> that having a unified hierarchy with differing level of granularities
> would serve their cases well enough while not being crazy.

I'm not sure what "differing level of granularities" means?  But that
aside, who have you spoken to here?  On our internal discussions I
have not heard a SINGLE member of our prod-kernel team nor our cluster
management team who think this is a good idea.  Not one.

> Really, I have $huge_number of machines configured certain way isn't
> much of an argument when unified hierarchy isn't gonna break them and
> many people involved in cgroup both on kernel and userland sides share
> the view that the whole thing is a hellish mess which can only be used
> by crafting very specialized configurations for each setup.

I still don't really get what the hellish mess is, and why it can't be
solved another way.  Your statement of "unified hierarchy isn't gonna
break them" is patently false, though.  If we did this it would a)
cause a large amount of work to happen and b) cause a major regression
for our users.

If 99.99% of users in the world don't need orthogonality, then
co-mounting the controllers is a great solution for them.  But for the
remainder, we need to find a solution that continues to let us do what
we are doing now, which is indeed "very sepcialized".  That's not a
bad thing.

>> I'm not sure I really grok that statement.  I'm OK with defining new
>
> That's about google's blkcg modifications to support blkcg on
> writeback IOs.  It works but can't be upstreamed as it requires
> tagging each page both with memcg and blkcg tags.
>
>> rules that bring some order to the chaos.  Give us new rules to live
>> by.  All-or-nothing would be fine.  What if mounting cgroupfs gives me
>> N sub-dirs, one for each compiled-in controller?  You could make THAT
>> the mount option - you can have either a unified hierarchy of all
>> controllers or fully disjoint hierarchies.  Or some other rule.
>
> Now I'm lost what you're talking about.  But the summary is, in the
> future, use a single unified hierarchy with differing granularities.
> It's still being worked on, so, for now, try not to depend on creating
> completely orthogonal hierarchies for different controllers.

I'm trying to understand your root problem so that I can try to find
other solutions.  "Just do what I say" is not a great way to defend
your position in the face of evidence to the contrary.  I'm presenting
you real life cases of situations that simply do not work, neither
philosophically nor in practice, and you continue to assert that it's
fine.  It's not fine.

>> The time frame you talk about IS reason for panic.  If I know that
>
> What time frame are you referring to?

Somewhere I picked up the notion that you were talking about making
these changes in O(1.5 years).  Perhaps I got that wrong.  what *is*
the timeframe?  At what point will everything we depend on today no
longer be supported?

>> you're going to completely screw me in a a year and a half, I have to
>
> How the hell am I gonna screw you in a year and half?  What are you
> talking about?  Where is this coming from?
>
>> start moving NOW to find new ways to hack around the mess you're
>> making, make my userspace mesh with it, test those things with
>> critical customers, find a way to deploy it safely to a bajillion
>> machines, handle inevitable rollback issues, and so on and so on.
>> Moving from single hierarchy to split hierarchy LITERALLY took 2
>> years.
>>
>> So yeah, I'm in a bit of a panic.  You're making a huge amount of work
>> for us.  You're breaking binary compatibility of the (probably)
>> largest single installation of Linux in the world.  And you're being
>> kind of flip about the reality of it, which is so weird to me,
>> considering you have first-hand experience with it all.
>
> I frankly have no idea what you're talking about.  Calm down and try
> to understand what's actually going on.

OK.  So please shed some light?  Will split-hierarchies continue to
work for the indefinite future?  Or will they be disabled at some
point?  Or will they become so crippled or bit-rotted that they are
effectively removed, without having to actually say that?

I need to know what's happening here both so I can try to help nudge
the ship and so that I can make plans.  As I said, it takes literally
O(year) for us to make a change like this safely.

Tim
