From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Wed, 3 Jul 2013 01:57:05 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1307030021480.4013__46295.009161304$1372812076$gmane$org@ionos.tec.linutronix.de>
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
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Lennart,

On Sun, 30 Jun 2013, Lennart Poettering wrote:
> On 29.06.2013 05:05, Tim Hockin wrote:
> > But that's not my point.  It seems pretty easy to make this cgroup
> > management (in "native mode") a library that can have either a thin
> > veneer of a main() function, while also being usable by systemd.  The
> > point is to solve all of the problems ONCE.  I'm trying to make the
> > case that systemd itself should be focusing on features and policies
> > and awesome APIs.
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
> you need a graph of units, where you can propagate things, and schedule things
> based on some execution/event queue. And the propagation and scheduling are
> closely intermingled.

you are confusing policy and mechanisms.

    The access to cgroupfs is mechanism.

    The propagation of changes, the scheduling of cgroupfs access and
    the correlation to external conditions are policy.

What Tim is asking for is to have a common interface, i.e. a library
which implements the low level access to the cgroupfs mechanism
without imposing systemd defined policies to it (It might implement a
set of common useful policies, but that's a different discussion).

That's definitely not an unreasonable request, because he wants to
implement his own set of policies which are not necessarily the same
as those which are implemented by systemd.

You are simply ignoring the fact, that Linux is used in other ways
than those which you are focussed on. That's true for Google's way to
manage its gazillion machines and that's equally true for the other
end of the spectrum which is deep embedded or any other specialized
use case. Just face it: running Linux on your laptop and on some RHT
lab machines is covering about 1% of the use cases.

Nevertheless you repeatedly claim, that systemd is the only way to
deal with system startup and system management, is covering _ALL_ use
cases and the interfaces you expose are sufficient.

Did you ever work on specialized embedded or big data use cases? I
really doubt that, but I might be wrong as usual.

So I invite you to prove that you can beat an existing setup for an
automotive use case with your magic systemd foo. I refund you fully,
if you can beat the mark of a functional system less than 800ms after
reset release on a 200MHz ARM machine. Functional is defined by the
use case requirements and means:

    - Basic cgroups management working
    - GUI up and running
    - Main communication interface (CAN bus) up and running

The rest of the system is starting up after that including a more
complex cgroup management.

According to your claim that systemd is covering everything and some
more, this should take you a few hours. I grant you a full week to
work on that.

The use case Tim is talking about is different, but has similar
constraints which are completely driven by his particular use case
scenario. I'm sure, that Tim can persuade his management to setup a
similar contest to prove your expertise on the other extreme of the
Linux world.

Before answering please think about the relevance of your statements
"getting this all right isn't easy", "something like a scheduler",
"users probably want ..."  and "stable /dev/disk/by-id/* symlinks" in
those contexts.

Thanks,

	tglx
