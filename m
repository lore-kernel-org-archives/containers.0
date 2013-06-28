From: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Subject: Re: [Workman-devel] cgroup: status-quo and userland efforts
Date: Fri, 28 Jun 2013 11:58:10 -0700
Message-ID: <CAAAKZwsnSBbDV6nKVr+DOw-OUwkc68tm3bbWXJJfROURwzahqg@mail.gmail.com>
References: <CAAAKZwvh_R2Xz--bmSLiN33fsqKanOJMq_6+6hoFWFRx38O4gA@mail.gmail.com>
	<20130422214159.GG12543@htj.dyndns.org>
	<CAAAKZwuXJwwyj7KSqb7rZ+nrTwBWEaUCWfa7kWecTBnHL8koGw@mail.gmail.com>
	<CAAAKZwvP_7wBBYMmtFuiE2hZt=ByaLrnTyiR83CZr3OMip63Gg@mail.gmail.com>
	<20130625000118.GT1918@mtj.dyndns.org>
	<CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA@mail.gmail.com>
	<20130626212047.GB4536@htj.dyndns.org>
	<1372311907.5871.78.camel@marge.simpson.net>
	<20130627132206.GE4003@sergelap> <20130628090910.GB2507@redhat.com>
	<20130628155306.GC26841@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130628155306.GC26841@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jun 28, 2013 at 8:53 AM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
> Quoting Daniel P. Berrange (berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):

>> Are you also planning to actually write a new cgroup parent manager
>> daemon too ? Currently my plan for libvirt is to just talk directly
>
> I'm toying with the idea, yes.  (Right now my toy runs in either native
> mode, using cgroupfs, or child mode, talking to a parent manager)  I'd
> love if someone else does it, but it needs to be done.
>
> As I've said elsewhere in the thread, I see 2 problems to be addressed:
>
> 1. The ability to nest the cgroup manager daemons, so that a daemon
> running in a container can talk to a daemon running on the host.  This
> is the problem my current toy is aiming to address.  But the API it
> exports is just a thin layer over cgroupfs.
>
> 2. Abstract away the kernel/cgroupfs details so that userspace can
> explain its cgroup needs generically.  This is IIUC what systemd is
> addressing with slices and scopes.
>
> (2) is where I'd really like to have a well thought out, community
> designed API that everyone can agree on, and it might be worth getting
> together (with Tejun) at plumbers or something to lay something out.

We're also working on (2) (well, we HAVE it, but we're dis-integrating
it so we can hopefully publish more widely).  But our (2) depends on
direct cgroupfs access.  If that is to change, we need a really robust
(1).  It's OK (desireable, in fact) that (1) be a very thin layer of
abstraction.

> In the end, something like libvirt or lxc should not need to care
> what is running underneat it.  It should be able to make its requests
> the same way regardless of whether it running in fedora or ubuntu,
> and whether it is running on the host or in a tightly bound container.
> That's my goal anyway :)
>
>> to systemd's new DBus APIs for all management of cgroups, and then
>> fall back to writing to cgroupfs directly for cases where systemd
>> is not around.  Having a library to abstract these two possible
>> alternatives isn't all that compelling unless we think there will
>> be multiple cgroups manager daemons. I've been somewhat assuming that
>> even Ubuntu will eventually see the benefits & switch to systemd,
>
> So far I've seen no indication of that :)
>
> If the systemd code to manage slices could be made separately
> compileable as a standalone library or daemon, then I'd advocate
> using that.  But I don't see a lot of incentive for systemd to do
> that, so I'd feel like a heel even asking.

I want to say "let the best API win", but I know that systemd is a
giant katamari ball, and it's absorbing subsystems so it may win by
default.  That isn't going to stop us from trying to do what we do,
and share that with the world.

>> then the issue of multiple manager daemons wouldn't really exist.
>
> True.  But I'm running under the assumption that Ubuntu will stick with
> upstart, and therefore yes I'll need a separate (perhaps pair of)
> management daemons.
>
> Even if we were to switch to systemd, I'd like the API for userspace
> programs to configure and use cgroups to be as generic as possible,
> so that anyone who wanted to write their own daemon could do so.
>
> -serge
