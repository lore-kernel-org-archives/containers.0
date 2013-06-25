From: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Mon, 24 Jun 2013 21:07:47 -0700
Message-ID: <CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA__35192.8901429803$1372133302$gmane$org@mail.gmail.com>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<CAAAKZwvh_R2Xz--bmSLiN33fsqKanOJMq_6+6hoFWFRx38O4gA@mail.gmail.com>
	<20130422214159.GG12543@htj.dyndns.org>
	<CAAAKZwuXJwwyj7KSqb7rZ+nrTwBWEaUCWfa7kWecTBnHL8koGw@mail.gmail.com>
	<CAAAKZwvP_7wBBYMmtFuiE2hZt=ByaLrnTyiR83CZr3OMip63Gg@mail.gmail.com>
	<20130625000118.GT1918@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130625000118.GT1918-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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

On Mon, Jun 24, 2013 at 5:01 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Hello, Tim.
>
> On Sat, Jun 22, 2013 at 04:13:41PM -0700, Tim Hockin wrote:
>> I'm very sorry I let this fall off my plate.  I was pointed at a
>> systemd-devel message indicating that this is done.  Is it so?  It
>
> It's progressing pretty fast.
>
>> seems so completely ass-backwards to me. Below is one of our use-cases
>> that I just don't see how we can reproduce in a single-heierarchy.
>
> Configurations which depend on orthogonal multiple hierarchies of
> course won't be replicated under unified hierarchy.  It's unfortunate
> but those just have to go.  More on this later.

I really want to understand why this is SO IMPORTANT that you have to
break userspace compatibility?  I mean, isn't Linux supposed to be the
OS with the stable kernel interface?  I've seen Linus rant time and
time again about this - why is it OK now?

>> We're also long into the model that users can control their own
>> sub-cgroups (moderated by permissions decided by admin SW up front).
>
> If you're in control of the base system, nothing prevents you from
> doing so.  It's utterly broken security and policy-enforcement point
> of view but if you can trust each software running on your system to
> do the right thing, it's gonna be fine.

Examples?  we obviously don't grant full access, but our kernel gang
and security gang seem to trust the bits we're enabling well enough...

>> This gives us 4 combinations:
>>   1) { production, DTF }
>>   2) { production, non-DTF }
>>   3) { batch, DTF }
>>   4) { batch non-DTF }
>>
>> Of these, (3) is sort of nonsense, but the others are actually used
>> and needed.  This is only
>> possible because of split hierarchies.  In fact, we undertook a very painful
>> process to move from a unified cgroup hierarchy to split hierarchies in large
>> part _because of_ these examples.
>
> You can create three sibling cgroups and configure cpuset and blkio
> accordingly.  For cpuset, the setup wouldn't make any different.  For
> blkio, the two non-DTFs would now belong to different cgroups and
> compete with each other as two groups, which won't matter at all as
> non-DTFs are given what's left over after serving DTFs anyway, IIRC.

The non-DTF jobs have a combined share that is small but non-trivial.
If we cut that share in half, giving one slice to prod and one slice
to batch, we get bad sharing under contention.  We tried this.  We
could add control loops in userspace code which try to balance the
shares in proportion to the load.  We did that with CPU, and it's sort
of horrible.  We're moving AWAY from all this craziness in favor of
well-defined hierarchical behaviors.

>> Making cgroups composable allows us to build a higher level abstraction that
>> is very powerful and flexible.  Moving back to unified hierarchies goes
>> against everything that we're doing here, and will cause us REAL pain.
>
> Categorizing processes into hierarchical groups of tasks is a
> fundamental idea and a fundamental idea is something to base things on
> top of as it's something people can agree upon relatively easily and
> establish a structure by.  I'd go as far as saying that it's the
> failure on the part of workload design if they in general can't be
> categorized hierarchically.

It's a bit naive to think that this is some absolute truth, don't you
think?  It just isn't so.  You should know better than most what
craziness our users do, and what (legit) rationales they can produce.
I have $large_number of machines running $huge_number of jobs from
thousands of developers running for years upon years backing up my
worldview.

> Even at the practical level, the orthogonal hierarchy encouraged, at
> the very least, the blkcg writeback support which can't be upstreamed
> in any reasonable manner because it is impossible to say that a
> resource can't be said to belong to a cgroup irrespective of who's
> looking at it.

I'm not sure I really grok that statement.  I'm OK with defining new
rules that bring some order to the chaos.  Give us new rules to live
by.  All-or-nothing would be fine.  What if mounting cgroupfs gives me
N sub-dirs, one for each compiled-in controller?  You could make THAT
the mount option - you can have either a unified hierarchy of all
controllers or fully disjoint hierarchies.  Or some other rule.

> It's something fundamentally broken and I have very difficult time
> believing google's workload is so different that it can't be
> categorized in a single hierarchy for the purpose of resource
> distribution.  I'm sure there are cases where some compromises are
> necessary but the laternative is much worse here.  As I wrote multiple
> times now, multiple orthogonal hierarchy support is gonna be around
> for some time, so I don't think there's any rason for panic; that
> said, please at least plan to move on.

The time frame you talk about IS reason for panic.  If I know that
you're going to completely screw me in a a year and a half, I have to
start moving NOW to find new ways to hack around the mess you're
making, make my userspace mesh with it, test those things with
critical customers, find a way to deploy it safely to a bajillion
machines, handle inevitable rollback issues, and so on and so on.
Moving from single hierarchy to split hierarchy LITERALLY took 2
years.

So yeah, I'm in a bit of a panic.  You're making a huge amount of work
for us.  You're breaking binary compatibility of the (probably)
largest single installation of Linux in the world.  And you're being
kind of flip about the reality of it, which is so weird to me,
considering you have first-hand experience with it all.

Tim
