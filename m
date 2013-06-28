From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Fri, 28 Jun 2013 11:30:59 -0700
Message-ID: <20130628183059.GE18889@mtj.dyndns.org>
References: <20130625000118.GT1918@mtj.dyndns.org>
	<CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA@mail.gmail.com>
	<20130626212047.GB4536@htj.dyndns.org>
	<1372311907.5871.78.camel@marge.simpson.net>
	<20130627180143.GD5599@mtj.dyndns.org>
	<1372391198.5989.110.camel@marge.simpson.net>
	<20130628040930.GC2500@htj.dyndns.org>
	<1372394950.5989.128.camel@marge.simpson.net>
	<20130628050138.GD2500@htj.dyndns.org>
	<20130628150513.GD5125@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130628150513.GD5125-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Michal.

On Fri, Jun 28, 2013 at 05:05:13PM +0200, Michal Hocko wrote:
> OK, this really depends on what you expose to non-root users. I have
> seen use cases where admin prepares top-level which is root-only but
> it allows creating sub-groups which are under _full_ control of the
> subdomain. This worked nicely for memcg for example because hard limit,
> oom handling and other knobs are hierarchical so the subdomain cannot
> overwrite what admin has said.

Some knobs are safer than others and memcg probably has it easy as it
doesn't implement proportional control.  But, even then, there's a
huge chasm between cgroup knobs and proper kernel API visible to
normal programs.  Just imagine exposing memcg features by extending
rlimits.  It'll take months if not a couple years ironing out the API
details and going through review process, and rightfully so, these
things, once published and made widely available, can't be taken back.
Now compare that to how we decide what knobs to expose in cgroup.  I
mean, you even recently suggested flipping the default polarity of
soft limit knob.

cgroup's interface standard is very low.  It's probably a notch higher
than boot params but about at the same level as sysctl knobs.  It
isn't necessarily a bad thing as it allows us to rapidly explore
various options and expose useable things in a very agile manner, but
we should be very aware of how widely the interface is exposed;
otherwise, we'd be exposing features and leaking kernel implementation
details directly into userland programs without going through proper
review process or buliding consensus, which, in the long term, is
gonna be much worse than not having the feature exposed at all.

"It works for special cases XXX and YYY" is a very poor and extremely
short-sighted argument when the whole approach is breaching the very
fundamentals of kernel API conventions.

In addition, I really don't think cgroup is the right interface to
directly expose to individual programs.  As a management thing, it
does make some sense but kernel API already has its, at times ancient
but, generally working hierarchy and inheritance rules and conventions
and primitive resource control contructs - nice, ionice, rlimits and
so on.  If exposing cgroup-level resource control directly to
individual applications proves to be beneficial enough, what we should
do is extending those things.  The backend sure can be supported by
cgroups but this mkdiring and echoing things with separate hierarchy
from the usual process hierarchy isn't something which should be
visible to individual applications.

Currently, I'm not convinced that this is something which should be
exposed to individual applications, but I sure can be wrong.  But,
right now, let's first get the existing part settled.  We can worry
about the rest later.

Also, in light of the rather sneaky subversion happened with cgroup
filesystem interface, I wonder whether we need to add some sort of
generic warning mechanism which warns when permissions of pseudo file
systems like cgroupfs are delegated to lesser security domains.  In
itself, it could be harmless but it can serves as a useful beacon.
Not sure to what extent or how tho.

> OK, so libcgroup's rules daemon will still work and place my tasks in
> appropriate cgroups?

You have two competing managers of the same hierarchy.  There are ways
to make them not interfere with each other too much but ultimately
it's gonna be something clunky.  That said, libcgroup itself is pretty
clunky, so maybe you'll be okay with it.  I don't know.

> This is not quite in par with "libcgroup is dead and others have to
> migrate to systemd as well" statements from the link posted earlier.
> I really do not think that _any_ central agent will understand my
> requirements and needs so I need a way to talk to cgroupfs somehow - I
> have used libcgroups so far but touching cgroupfs is quite convinient
> as well.

As a developer who knows what's going on, I don't think it'd be too
difficult to meddle with things manually with or without the central
manager.  It'll complain that someone else is meddling with the cgroup
hierarchy and some functionalities might not work as expected, but I
don't think it'll lock you out.

At the same time, while us, the developers, having the level of
latitude required to do our work is necessary, that shouldn't be the
overruling focal point of the design of the whole system.  It's
something to be used and supporting the actual use cases should be the
priority.  I'm not saying developer convenience is not important but
that it's not the only thing which matters.  The way I see it, cgroup
has basically been a playground for devs going wild without too much,
if any, thought on how it'll actually be useable and useful to wider
audience, so let's please adjust our priorities a bit.

And, no, I don't believe that the use cases are so wildly different
that we can't have a capable enough central manager.  That's usually a
symptom of not understanding the problem space well enough and how one
ends up with mess like e.g. grub2 configuration.  There sure are and
will be outliers but it should be possible to come up with something
which can serve most of the use cases reasonably well, and right now,
I believe that should be the focus.

> And the systemd, with its history of eating projects and not caring much
> about their previous users who are not willing to jump in to the systemd
> car, doesn't sound like a good place where to place the new interface to
> me.

That part I don't know.  I really don't care whether it's systemd or
something else but it sure seems there are people who dislike it with
passion.  To me, it seems rather silly but to each his/her own.  Maybe
ubuntu will come up with their own manager paired with upstart and
people can use that one instead?  Who knows.

Thanks.

-- 
tejun
