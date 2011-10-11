From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Detecting if you are running in a container
Date: Mon, 10 Oct 2011 23:42:36 -0700
Message-ID: <m1ty7ghvvn.fsf@fess.ebiederm.org>
References: <1317943022.1095.25.camel@mop>
	<20111007074904.GC16723@count0.beaverton.ibm.com>
	<20111007160113.GB14201@tango.0pointer.de>
	<m17h4g2jqy.fsf@fess.ebiederm.org>
	<20111010163140.GA22191@tango.0pointer.de>
	<m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
	<20111011013201.GA7948@thunk.org>
	<20111011020530.GG16723@count0.beaverton.ibm.com>
	<20111011032523.GB7948@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111011032523.GB7948@thunk.org> (Ted Ts'o's message of "Mon, 10
	Oct 2011 23:25:23 -0400")
Sender: linux-kernel-owner@vger.kernel.org
To: Ted Ts'o <tytso@mit.edu>
Cc: Matt Helsley <matthltc@us.ibm.com>, Lennart Poettering <mzxreary@0pointer.de>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

Ted Ts'o <tytso@mit.edu> writes:

> On Mon, Oct 10, 2011 at 07:05:30PM -0700, Matt Helsley wrote:
>> Yes, it does detract from the unique advantages of using a container.
>> However, I think the value here is not the effeciency of the initial
>> system configuration but the fact that it gives users a better place to
>> start.
>> 
>> Right now we're effectively asking users to start with non-working
>> and/or unfamiliar systems and repair them until they work.
>
> If things are not working with containers, I would submit to you that
> we're doing something wrong(tm). 

That is what this discussion is about.  What we are doing wrong(tm).
Mostly it is about the bits that have not yet been namespacified but
need to be.

I am totally in favor of not starting the entire world.  But just
like I find it convienient to loopback mount an iso image to see
what is on a disk image.  It would be handy to be able to just
download a distro image and play with it, without doing anything
special.

We can pair things down farther for the people who are running 1000
copies of apache but not requiring detailed distro surgery before
starting up the binaries on a livecd sounds handy.

> Things should just work, except that
> processes in one container can't use more than their fair share (as
> dictated by policy) of memory, CPU, networking, and I/O bandwidth.

You have to be careful with the limiters.  The fundamental reason
why containers are more efficient than hardware virtualization is
that with containers we can do over commit of resources, especially
memory.  I keep seeing implementations of resource limiters that want
to do things in a heavy handed way that break resource over commit.

> Something which is baked in my world view of containers (which I
> suspect is not shared by other people who are interested in using
> containers) is that given that kernel is shared, trying to use
> containers to provide better security isolation between mutually
> suspicious users is hopeless.  That is, it's pretty much impossible to
> prevent a user from finding one or more zero day local privilege
> escalation bugs that will allow a user to break root.  And at that
> point, they will be able to penetrate the kernel, and from there,
> break security of other processes.

You don't even have to get to security problems to have that concern.
There are enough crazy timing and side channel attacks.

I don't know what concern you have security wise, but the problem that
wants to be solved with user namespaces is something you hit much
earlier than when you worry about sharing a kernel between mutually
distrusting users.  Right now root inside a container is root rout
outside of a container just like in a chroot jail.  Where this becomes a
problem is that people change things like like
/proc/sys/kernel/print-fatal-signals expecting it to be a setting local
to their sand box when in fact the global setting and things start
behaving weirdly for other users.  Running sysctl -a during bootup 
has that problem in spades.

With user namespaces what we get is that the global root user is not the
container root user and we have been working our way through the
permission checks in the kernel to ensure we get them right in the
context of the user namespace.  This trivially means that the things
that we allow the global root user to do in /proc/ and /sysfs and
the like simply won't be allowed as a container root user.  Which
makes doing something stupid and affecting other people much more
difficult.

What the user namespace also allows is an escape hatch from the
bonds of suid.  Right now anything that could confuse an existing
app with that is suid root we have to only allow to root, or risk
adding a security hole.  With the user namespaces we can relax
that check and allow it also for container root users as well
as global root users.  When we are brave enough and certain
enough of our code we can allow non-root users to create their
own user namespaces.

There is the third use for containers where for some reason
we have uid assignment overlap.  Perhaps one distroy assigns
uid 22 to sshd and another to the nobody user.  Or perhaps there
are two departments who have that have done the silly thing
of assigning overlapping uids to their users and we want to
accesses filesystems created by both departments at the same
time without a chance of confusion and conflict.

With my sysadmin hat on I would not want to touch two untrusting groups
of users on the same machine.  Because of the probability there is at
least one security hole that can be found and exploited to allow
privilege escalation.

With my kernel developer hat on I can't just say surrender to the
idea that there will in fact be a privilege escalation bug that
is easy to exploit.  The code has to be built and designed so that
privilege escalation is difficult.  Otherwise we might as well
assume if you visit a website an stealthy worm has taken over your
computer.

It is my hope at the end of the day that the user namespaces will be one
more line of defense in messing up and slowing down the evil omnicient
worms that seem to uneering go for every privilege exploit there is.

Eric
