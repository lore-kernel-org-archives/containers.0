From: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Sun, 30 Jun 2013 23:06:18 -0700
Message-ID: <CAAAKZws0xqQ_RAWQX4876fybO3CNHhbiDmkOR5YV7nq5NF8X_Q@mail.gmail.com>
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
	<CAAAKZwuzhSzPj99HZW=KD4emGXZbcsjsUu=+TCpafhs9MKD2JA@mail.gmail.com>
	<51D08976.6040005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51D08976.6040005-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Sun, Jun 30, 2013 at 12:39 PM, Lennart Poettering
<lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> Heya,
>
>
> On 29.06.2013 05:05, Tim Hockin wrote:
>>
>> Come on, now, Lennart.  You put a lot of words in my mouth.
>
>
>>> I for sure am not going to make the PID 1 a client of another daemon.
>>> That's
>>> just wrong. If you have a daemon that is both conceptually the manager of
>>> another service and the client of that other service, then that's bad
>>> design
>>> and you will easily run into deadlocks and such. Just think about it: if
>>> you
>>> have some external daemon for managing cgroups, and you need cgroups for
>>> running external daemons, how are you going to start the external daemon
>>> for
>>> managing cgroups? Sure, you can hack around this, make that daemon
>>> special,
>>> and magic, and stuff -- or you can just not do such nonsense. There's no
>>> reason to repeat the fuckup that cgroup became in kernelspace a second
>>> time,
>>> but this time in userspace, with multiple manager daemons all with
>>> different
>>> and slightly incompatible definitions what a unit to manage actualy is...
>>
>>
>> I forgot about the tautology of systemd.  systemd is monolithic.
>
>
> systemd is certainly not monolithic for almost any definition of that term.
> I am not sure where you are taking that from, and I am not sure I want to
> discuss on that level. This just sounds like FUD you picked up somewhere and
> are repeating carelessly...

It does a number of sort-of-related things.  Maybe it does them better
by doing them together.  I can't say, really.  We don't use it at
work, and I am on Ubuntu elsewhere, for now.

>> But that's not my point.  It seems pretty easy to make this cgroup
>> management (in "native mode") a library that can have either a thin
>> veneer of a main() function, while also being usable by systemd.  The
>> point is to solve all of the problems ONCE.  I'm trying to make the
>> case that systemd itself should be focusing on features and policies
>> and awesome APIs.
>
> You know, getting this all right isn't easy. If you want to do things
> properly, then you need to propagate attribute changes between the units you
> manage. You also need something like a scheduler, since a number of
> controllers can only be configured under certain external conditions (for
> example: the blkio or devices controller use major/minor parameters for
> configuring per-device limits. Since major/minor assignments are pretty much
> unpredictable these days -- and users probably want to configure things with
> friendly and stable /dev/disk/by-id/* symlinks anyway -- this requires us to
> wait for devices to show up before we can configure the parameters.) Soo...
> you need a graph of units, where you can propagate things, and schedule
> things based on some execution/event queue. And the propagation and
> scheduling are closely intermingled.

I'm really just talking about the most basic low-level substrate of
writing to cgroupfs.  Again, we don't use udev (yet?) so we don't have
these problems.  It seems to me that it's possible to formulate a
bottom layer that is usable by both systemd and non-systemd systems.
But, you know, maybe I am wrong and our internal universe is so much
simpler (and behind the times) than the rest of the world that
layering can work for us and not you.

> Now, that's pretty much exactly what systemd actually *is*. It implements a
> graph of units with a scheduler. And if you rip that part out of systemd to
> make this an "easy cgroup management library", then you simply turn what
> systemd is into a library without leaving anything. Which is just bogus.
>
> So no, if you say "seems pretty easy to make this cgroup management a
> library" then well, I have to disagree with you.
>
>
>>> We want to run fewer, simpler things on our systems, we want to reuse as
>>
>>
>> Fewer and simpler are not compatible, unless you are losing
>> functionality.  Systemd is fewer, but NOT simpler.
>
>
> Oh, certainly it is. If we'd split up the cgroup fs access into separate
> daemon of some kind, then we'd need some kind of IPC for that, and so you
> have more daemons and you have some complex IPC between the processes. So
> yeah, the systemd approach is certainly both simpler and uses fewer daemons
> then your hypothetical one.

Well, it SOUNDS like Serge is trying to develop this to demonstrate
that a standalone daemon works.  That's what I am keen to help with
(or else we have to invent ourselves).  I am not really afraid of IPC
or of "more daemons".  I much prefer simple agents doing one thing and
interacting with each other in simple ways.  But that's me.

>>> much of the code as we can. You don't achieve that by running yet another
>>> daemon that does worse what systemd can anyway do simpler, easier and
>>> better.
>>
>>
>> Considering this is all hypothetical, I find this to be a funny
>> debate.  My hypothetical idea is better than your hypothetical idea.
>
>
> Well, systemd is pretty real, and the code to do the unified cgroup
> management within systemd is pretty complete. systemd is certainly not
> hypothetical.

Fair enough - I did not realize you had already done all the work that
Serge is just starting out on.

>>> The least you could grant us is to have a look at the final APIs we will
>>> have to offer before you already imply that systemd cannot be a valid
>>> implementation of any API people could ever agree on.
>>
>>
>> Whoah, don't get defensive.  I said nothing of the sort.  The fact of
>> the matter is that we do not run systemd, at least in part because of
>> the monolithic nature.  That's unlikely to change in this timescale.
>
>
> Oh, my. I am not sure what makes you think it is monolithic.

It is not a replacement for any one thing.  It is a replacement for a
handful of things that we are not keen to change all at once.  That's
all.  I have not personally looked at what subsystems are able to be
compiled-out so we could do an incremental changeover, though, so
maybe it can work in different modes?  I don't know.  I am not
pursuing this anyway, so I am not the person to convince, regardless.

>> What I said was that it would be a shame if we had to invent our own
>> low-level cgroup daemon just because the "upstream" daemons was too
>> tightly coupled with systemd.
>
>
> I have no interest to reimplement systemd as a library, just to make you
> happy... I am quite happy with what we already have....
>
>
>> This is supposed to be collaborative, not combative.
>
>
> It certainly sounds *very* differently in what you are writing.

Sorry, then.  No offense intended.  I'm just looking for opportunities
to not-replicate work, if this whole model is going to be thrust upon
me.

Tim
