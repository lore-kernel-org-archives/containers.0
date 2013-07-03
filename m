From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Wed, 03 Jul 2013 10:11:42 -0700
Message-ID: <1372871502.3601.59.camel__18266.4298140027$1372871517$gmane$org@dabdike>
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
	<alpine.DEB.2.02.1307030021480.4013@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.02.1307030021480.4013-3cz04HxQygjZikZi3RtOZ1XZhhPuCNm+@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Lennart Poettering <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2013-07-03 at 01:57 +0200, Thomas Gleixner wrote:
> Lennart,
> 
> On Sun, 30 Jun 2013, Lennart Poettering wrote:
> > On 29.06.2013 05:05, Tim Hockin wrote:
> > > But that's not my point.  It seems pretty easy to make this cgroup
> > > management (in "native mode") a library that can have either a thin
> > > veneer of a main() function, while also being usable by systemd.  The
> > > point is to solve all of the problems ONCE.  I'm trying to make the
> > > case that systemd itself should be focusing on features and policies
> > > and awesome APIs.
> > 
> > You know, getting this all right isn't easy. If you want to do things
> > properly, then you need to propagate attribute changes between the units you
> > manage. You also need something like a scheduler, since a number of
> > controllers can only be configured under certain external conditions (for
> > example: the blkio or devices controller use major/minor parameters for
> > configuring per-device limits. Since major/minor assignments are pretty much
> > unpredictable these days -- and users probably want to configure things with
> > friendly and stable /dev/disk/by-id/* symlinks anyway -- this requires us to
> > wait for devices to show up before we can configure the parameters.) Soo...
> > you need a graph of units, where you can propagate things, and schedule things
> > based on some execution/event queue. And the propagation and scheduling are
> > closely intermingled.
> 
> you are confusing policy and mechanisms.
> 
>     The access to cgroupfs is mechanism.
> 
>     The propagation of changes, the scheduling of cgroupfs access and
>     the correlation to external conditions are policy.
> 
> What Tim is asking for is to have a common interface, i.e. a library
> which implements the low level access to the cgroupfs mechanism
> without imposing systemd defined policies to it (It might implement a
> set of common useful policies, but that's a different discussion).
> 
> That's definitely not an unreasonable request, because he wants to
> implement his own set of policies which are not necessarily the same
> as those which are implemented by systemd.

Could I just add a me too to this from Parallels.  We need the ability
to impose our own container policy on the kernel mechanisms.

Perhaps I should step back a bit and say first of all that we all use
the word "container" a lot, but if you analyse what we mean, you'll find
that a Google container is different from a Parallels/OpenVZ container
which is different from an LXC container and so on.  How we all build
our containers is a policy we impose on the various cgroup and namespace
mechanisms within the kernel.  We've spent a lot of discussion time over
the years making sure that the kernel mechanisms support all of our
different use cases, so I really don't want to see that change in the
name of simplifying the API.

I also don't think any quest for the one true container will be
successful for the simple reason that containers are best when tuned for
the job they're doing. For instance at Parallels we do IaaS containers.
That means we can take a container, boot up any old Linux OS inside it
and give you root on it in exactly the same way as you could for a
virtual machine.  Google does something more like application containers
for job control and some network companies do pure namespace containers
without any cgroup controllers at all.  There's no one container
description that would fit all use cases.

So where we are is that the current APIs may be messy, but they support
all use cases and all container structure policies.  If anyone, systemd
included, wants to do a new API, it must support all use cases as well.
Ideally, it should be agreed to and in the kernel as well rather than
having some userspace filter.

James
