From: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Fri, 28 Jun 2013 20:05:43 -0700
Message-ID: <CAAAKZwuzhSzPj99HZW=KD4emGXZbcsjsUu=+TCpafhs9MKD2JA@mail.gmail.com>
References: <CAAAKZwvP_7wBBYMmtFuiE2hZt=ByaLrnTyiR83CZr3OMip63Gg@mail.gmail.com>
	<20130625000118.GT1918@mtj.dyndns.org>
	<CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA@mail.gmail.com>
	<20130626212047.GB4536@htj.dyndns.org>
	<1372311907.5871.78.camel@marge.simpson.net>
	<20130627180143.GD5599@mtj.dyndns.org>
	<1372391198.5989.110.camel@marge.simpson.net>
	<20130628040930.GC2500@htj.dyndns.org>
	<1372394950.5989.128.camel@marge.simpson.net>
	<20130628050138.GD2500@htj.dyndns.org>
	<20130628150513.GD5125@dhcp22.suse.cz>
	<CAAAKZwtqYe-c0bfkgHFbzsOKVHifjTwkqcpci=uS1JwqS9TJHQ@mail.gmail.com>
	<51CE3CE0.9010506@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51CE3CE0.9010506-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lennart Poettering <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Come on, now, Lennart.  You put a lot of words in my mouth.

On Fri, Jun 28, 2013 at 6:48 PM, Lennart Poettering <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 28.06.2013 20:53, Tim Hockin wrote:
>
>> a single-agent, we should make a kick-ass implementation that is
>> flexible and scalable, and full-featured enough to not require
>> divergence at the lowest layer of the stack.  Then build systemd on
>> top of that. Let systemd offer more features and policies and
>> "semantic" APIs.
>
>
> Well, what if systemd is already kick-ass? I mean, if you have a problem
> with systemd, then that's your own problem, but I really don't think why I
> should bother?

I didn't say it wasn't.  I said that we can build a common substrate
that systemd can build on *and* non-systemd systems can use *and*
Google can participate in.

> I for sure am not going to make the PID 1 a client of another daemon. That's
> just wrong. If you have a daemon that is both conceptually the manager of
> another service and the client of that other service, then that's bad design
> and you will easily run into deadlocks and such. Just think about it: if you
> have some external daemon for managing cgroups, and you need cgroups for
> running external daemons, how are you going to start the external daemon for
> managing cgroups? Sure, you can hack around this, make that daemon special,
> and magic, and stuff -- or you can just not do such nonsense. There's no
> reason to repeat the fuckup that cgroup became in kernelspace a second time,
> but this time in userspace, with multiple manager daemons all with different
> and slightly incompatible definitions what a unit to manage actualy is...

I forgot about the tautology of systemd.  systemd is monolithic.
Therefore it can not have any external dependencies.  Therefore it
must absorb anything it depends on.  Therefore systemd continues to
grow in size and scope.  Up next: systemd manages your X sessions!

But that's not my point.  It seems pretty easy to make this cgroup
management (in "native mode") a library that can have either a thin
veneer of a main() function, while also being usable by systemd.  The
point is to solve all of the problems ONCE.  I'm trying to make the
case that systemd itself should be focusing on features and policies
and awesome APIs.

> We want to run fewer, simpler things on our systems, we want to reuse as

Fewer and simpler are not compatible, unless you are losing
functionality.  Systemd is fewer, but NOT simpler.

> much of the code as we can. You don't achieve that by running yet another
> daemon that does worse what systemd can anyway do simpler, easier and
> better.

Considering this is all hypothetical, I find this to be a funny
debate.  My hypothetical idea is better than your hypothetical idea.

> The least you could grant us is to have a look at the final APIs we will
> have to offer before you already imply that systemd cannot be a valid
> implementation of any API people could ever agree on.

Whoah, don't get defensive.  I said nothing of the sort.  The fact of
the matter is that we do not run systemd, at least in part because of
the monolithic nature.  That's unlikely to change in this timescale.
What I said was that it would be a shame if we had to invent our own
low-level cgroup daemon just because the "upstream" daemons was too
tightly coupled with systemd.

I think we have a lot of experience to offer to this project, and a
vested interest in seeing it done well.  But if it is purely
targetting systemd, we have little incentive to devote resources to
it.

Please note that I am strictly talking about the lowest layer of the
API.  Just the thing that guards cgroupfs against mere mortals.  The
higher layers - where abstractions exist, that are actually USEFUL to
end users - are not really in scope right now.  We already have our
own higher level APIs.

This is supposed to be collaborative, not combative.

Tim
