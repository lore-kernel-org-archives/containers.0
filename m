From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Detecting if you are running in a container
Date: Tue, 11 Oct 2011 14:16:24 -0700
Message-ID: <m17h4bfcuv.fsf@fess.ebiederm.org>
References: <1317943022.1095.25.camel@mop>
	<20111007074904.GC16723@count0.beaverton.ibm.com>
	<20111007160113.GB14201@tango.0pointer.de>
	<m17h4g2jqy.fsf@fess.ebiederm.org>
	<20111010163140.GA22191@tango.0pointer.de>
	<m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
	<20111011013201.GA7948@thunk.org>
	<20111011020530.GG16723@count0.beaverton.ibm.com>
	<20111011032523.GB7948@thunk.org> <m1ty7ghvvn.fsf@fess.ebiederm.org>
	<203BBB0D-293D-4BFB-A57B-41C56F58F9B3@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <203BBB0D-293D-4BFB-A57B-41C56F58F9B3@mit.edu> (Theodore Tso's
	message of "Tue, 11 Oct 2011 08:53:46 -0400")
Sender: linux-kernel-owner@vger.kernel.org
To: Theodore Tso <tytso@MIT.EDU>
Cc: Matt Helsley <matthltc@us.ibm.com>, Lennart Poettering <mzxreary@0pointer.de>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

Theodore Tso <tytso@MIT.EDU> writes:

> On Oct 11, 2011, at 2:42 AM, Eric W. Biederman wrote:
>
>> I am totally in favor of not starting the entire world.  But just
>> like I find it convienient to loopback mount an iso image to see
>> what is on a disk image.  It would be handy to be able to just
>> download a distro image and play with it, without doing anything
>> special.
>
> Agreed, but what's wrong with firing up KVM to play with a distro
> image?  Personally, I don't consider that "doing something special".

Then let me flip this around and give a much more practical use case.
Testing.  A very interesting number of cases involve how multiple
machines interact.  You can test a lot more logical machines interacting
with containers than you can with vms.  And you can test on all the
aritectures and platforms linux supports not just the handful that are
well supported by hardware virtualization.

I admit for a lot of test cases that it makes sense not to use a full
set of userspace daemons.  At the same time there is not particularly
good reason to have a design that doesn't allow you to run a full
userspace.

>>> Things should just work, except that
>>> processes in one container can't use more than their fair share (as
>>> dictated by policy) of memory, CPU, networking, and I/O bandwidth.
>> 
>> You have to be careful with the limiters.  The fundamental reason
>> why containers are more efficient than hardware virtualization is
>> that with containers we can do over commit of resources, especially
>> memory.  I keep seeing implementations of resource limiters that want
>> to do things in a heavy handed way that break resource over commit.
>
> Oh, sure.   Resource limiting is something that should be done only
> when there are other demands on the resource in question.   Put
> another way, it should be considered more of a resource guarantee than
> a resource limit.   (You will have at least 10% of the CPU, not at
> most 10% of the CPU.)

Resource guarantees I suspect may be worse.  But all of this is to say
that the problem control groups are tackling is a hard one.  Resource
control and resource limits across multiple processes is a challenge
problem and in some contexts it is a hard problem.

My observations have been that when you want any kind of strong resource
guarantee or resource limit, it is currently a lot easier to implement
that with hardware virtualization than with control groups (at least for
memory).  I think the cpu scheduling has been solved but until you also
at least solve user space memory there are going to be issues.

At the same time getting better resource controls is an area where
there is a strong interest from all over the place.

>> I don't know what concern you have security wise, but the problem that
>> wants to be solved with user namespaces is something you hit much
>> earlier than when you worry about sharing a kernel between mutually
>> distrusting users.  Right now root inside a container is root rout
>> outside of a container just like in a chroot jail.  Where this becomes a
>> problem is that people change things like like
>> /proc/sys/kernel/print-fatal-signals expecting it to be a setting local
>> to their sand box when in fact the global setting and things start
>> behaving weirdly for other users.  Running sysctl -a during bootup 
>> has that problem in spades.
>
> The moment you start caring about global sysctl settings is the moment
> I start wondering whether or not VM and separate kernel images is the
> better solution.   Do we really want to add so much complexity that we
> are multiplexing different sysctl settings across containers?   To my
> mind, that way lies madness, and in some cases, it simply can't be
> done from a semantics perspective.

It actually isn't much complexity and for the most part the code that
I care about in that area is already merged.  In principle all I care
about are having the identiy checks go from:
(uid1 == uid2) to ((user_ns1 == user_ns2) && (uid1 == uid2))

There are some per subsystem sysctls that do make sense to make per
subsystem and that work is mostly done.  I expect there are a few
more in the networking stack that interesting to make per network
namespace.

The only real world issue right now that I am aware of is the user
namespace aren't quite ready for prime-time and so people run into
issues where something like sysctl -a during bootup sets a bunch of
sysctls and they change sysctls they didn't mean to.  Once the
user namespaces are in place accessing a truly global sysctl will
result in EPERM when you are in a container and everyone will be
happy. ;)


Where all of this winds up interesting in the field of oncoming kernel
work is that uids are persistent and are stored in file systems.  So
once we have all of the permission checks in the kernel tweaked to care
about user namespaces we next look at the filesystems.   The easy
initial implementation is going to be just associating a user namespace
with a super block.  But farther out being able to store uids from
different user namespaces on the same filesystem becomes an interesting
problem.

We already have things like user mapping in 9p and nfsv4 so it isn't
wholly uncharted territory.  But it could get interesting.   Just
a heads up.

>> With my sysadmin hat on I would not want to touch two untrusting groups
>> of users on the same machine.  Because of the probability there is at
>> least one security hole that can be found and exploited to allow
>> privilege escalation.
>> 
>> With my kernel developer hat on I can't just say surrender to the
>> idea that there will in fact be a privilege escalation bug that
>> is easy to exploit.  The code has to be built and designed so that
>> privilege escalation is difficult.  Otherwise we might as well
>> assume if you visit a website an stealthy worm has taken over your
>> computer.
>
> Oh, I agree that we should try to stop privilege escalation attacks.
> And it will be a grand and glorious fight, like Leonidas and his 300
> men at the pass at Thermopylae.  :-) Or it will be like Steve Jobs
> struggling against cancer.  It's a fight that you know that you're
> going to lose, but it's not about winning or losing but how much you
> accomplish and how you fight that counts.
>
> Personally, though, if the issue is worries about visiting a website,
> the primary protection against that has got to be done at the browser
> level (i.e., the process level sandboxing done by Chrome).

My concern is any externally implemented service, but in general 
browsers and web sites are your most likely candidates.  Both because
there is more complexity there and because http is used far more often
than other protocols.

And yes I agree that the first line of defense needs to be in the
browser source code, and then the application level sand boxing
features that the browser takes advantage of.  Last I paid attention
one of the layers of defense that chrome is user was to setup different
namespaces to make the sandbox tight even at the syscall level.   When
it is complete I would not be at all surprised if the user namespace
wound up being used in chrome as well.  Just as one more thing that
helps.

I have found it very surprising how many of the namespaces are
used for what you can't do with them.

Eric
