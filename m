From: Stephan Peijnik <stephan@peijnik.at>
Subject: Re: LSM stacking/secondary modules / RFC: Socket MAC LSM
Date: Sun, 18 Jan 2009 16:46:33 +0100
Message-ID: <1232293593.14309.7.camel@sp-laptop3.sp-local>
References: <1231952352.5315.13.camel@sp-laptop3.sp-local>
	 <1232027832.14136.8.camel@sp-laptop3.sp-local>
	 <6599ad830901150925p771dcc3if60b8ec5ed617963@mail.gmail.com>
	 <200901161543.29320.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200901161543.29320.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Cc: Paul Menage <menage@google.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Greg KH <greg@kroah.com>, Rafael Konrath <rafael.konrath@gmail.com>, linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Li Zefan <lizf@cn.fujitsu.com>, Grzegorz Nosek <root@localdomain.pl>
List-Id: containers.vger.kernel.org

On Fri, 2009-01-16 at 15:43 -0500, Paul Moore wrote: 
> On Thursday 15 January 2009 12:25:34 pm Paul Menage wrote:
> > On Thu, Jan 15, 2009 at 5:57 AM, Stephan Peijnik <stephan@peijnik.at> 
> wrote:
> > > So Paul, do you think the interface would be of any use to you?
> >
> > Potentially, yes. My concern was that we not add another new
> > (incomplete) userspace API in cgroups for doing socket permissions -
> > hooking into iptables was one way to do it, but if sactl is going to
> > become the official way to do this, then hooking a cgroups filter
> > into that seems like a good alternative.
> 
> I'll confess to knowing very little about cgroups and even less about 
> Stephan's sactl concept (only what I've read so far in this thread), 
> however, like Paul Menage I tend to prefer solutions which leverage 
> existing mechanisms as much as possible.
> 
> Conceptually, I've always associated iptables/netfilter as more of a 
> per-packet traffic control mechanism whereas the LSM approach was 
> geared more towards per-connection and per-application traffic control 
> mechanism; although I will be the first to admit this is a very fuzzy 
> distinction and could easily be argued the other way as well.  Other 
> than the issues around blocking due to userspace notification and 
> potential conflicts with other LSMs are there any objections to using 
> the LSM interface?

The interface itself might be exactly what's needed, but as only one LSM
may be running at one time it is probably not the right one to use for
personal firewalls.
I just don't want users to get the problem of having to decide whether
they are going to use a general purpose LSM, like AppFilter or SELinux,
or if they are going to use a tiny personal firewall. Both at once are
not going to work using LSM.

Also, don't get me wrong here. I don't want LSM stacking back either. I
do see that there were problems with it and they cannot be solved
easily. Why shouldn't there be a new interface specifically for personal
firewalls? It seems there are a few possible use cases for such an
interface (tuxguardian, the cgroup-based MAC system, etc).

> I know I've come out against the LSM networking hooks proposed by the 
> TOMOYO developers in the past to address the blocking issues, and while 
> I still believe this is not the "ideal" solution I recognize that there 
> are certain use cases and "personal firewall" projects that could 
> benefit from such LSM hooks.  While I stand by my original objections, 
> I'm most interested in making sure that if we do decide to go forward 
> with introducing such functionality into the mainline kernel that we do 
> so in the most appropriate manner.

As I said, maybe it's a good idea to not use LSM for that. I tried using LSM
for my very own personal firewall project first, but it's not going to work.
Firstly LSM seems to be overkill for something like a personal firewall and
secondly I would love to have the ability to load/unload a personal firewall
at runtime, just like I can load netfilter or better said IPTables targets
at runtime.
That's why the latest sactl code doesn't use LSM at all, but rather calls 
its own functions directly from "net/socket.c".

Now maybe the LSM list isn't the right place to discuss this issue anymore. 
What I can see clearly is that there are several projects in need of a way
of doing MAC on sockets and that there is no solution available in the kernel
right now: that's why I wrote sactl.
The question that remains unanswered is whether a.) this is actually needed
in the kernel and b.) if the thing I've hacked together is the right solution
for this problem.

-- Stephan

