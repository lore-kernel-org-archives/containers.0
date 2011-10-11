From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Detecting if you are running in a container
Date: Mon, 10 Oct 2011 22:40:34 -0700
Message-ID: <m1obxojdbh.fsf@fess.ebiederm.org>
References: <1317943022.1095.25.camel@mop>
	<20111007074904.GC16723@count0.beaverton.ibm.com>
	<20111007160113.GB14201@tango.0pointer.de>
	<m17h4g2jqy.fsf@fess.ebiederm.org>
	<20111010163140.GA22191@tango.0pointer.de>
	<m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
	<20111010214148.GB26510@tango.0pointer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111010214148.GB26510@tango.0pointer.de> (Lennart Poettering's
	message of "Mon, 10 Oct 2011 23:41:48 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Lennart Poettering <mzxreary@0pointer.de>
Cc: Matt Helsley <matthltc@us.ibm.com>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

Lennart Poettering <mzxreary@0pointer.de> writes:

> On Mon, 10.10.11 13:59, Eric W. Biederman (ebiederm@xmission.com) wrote:
>
>> > Quite a few kernel subsystems are
>> > currently not virtualized, for example SELinux, VTs, most of sysfs, most
>> > of /proc/sys, audit, udev or file systems (by which I mean that for a
>> > container you probably don't want to fsck the root fs, and so on), and
>> > containers tend to be much more lightweight than real systems.
>> 
>> That is an interesting viewpoint on what is not complete.  But as a
>> listing of the tasks that distribution startup needs to do differently in
>> a container the list seems more or less reasonable.
>
> Note that this is just what came to my mind while I was typing this, I
> am quite sure there's actually more like this.
>
>> There are two questions 
>> - How in the general case do we detect if we are running in a container.
>> - How do we make reasonable tests during bootup to see if it makes sense
>>   to perform certain actions.
>> 
>> For the general detection if we are running in a linux container I can
>> see two reasonable possibilities.
>> 
>> - Put a file in / that let's you know by convention that you are in a
>>   linux container.  I am inclined to do this because this is something
>>   we can support on all kernels old and new.
>
> Hmpf. That would break the stateless read-only-ness of the root dir.
>
> After pointing the issue out to the LXC folks they are now setting
> "container=lxc" as env var when spawning a container. In systemd-nspawn
> I have then adopted a similar scheme. Not sure though that that isp
> particularly nice however, since env vars are inherited further down the
> tree where we probably don't want them.

Interesting.  That seems like a reasonable enough thing to require
of the programs that create containers.

> In case you are curious: this is the code we use in systemd:
>
> http://cgit.freedesktop.org/systemd/tree/src/virt.c
>
> What matters to me though is that we can generically detect Linux
> containers instead of specific implementations.

>> - Allow modification to the output of uname(2).  The uts namespace
>>   already covers uname(2) and uname is the standard method to
>>   communicate to userspace the vageries about the OS level environment
>>   they are running in.
>
> Well, I am not a particular fan of having userspace tell userspace about
> containers. I would prefer if userspace could get that info from the
> kernel without any explicit agreement to set some specific variable.

Well userspace tells userspace about stdin and it works reliably.

Containers are a userspace construct built with kernel facilities.
I don't see why asking userspace to implement a convention is any more
important than the other things that have to be done.

We do need to document the convetions.  Just like we document the
standard device names but I don't beyond that we should be fine.

>> My list of things that still have work left to do looks like:
>> - cgroups.  It is not safe to create a new hierarchies with groups
>>   that are in existing hierarchies.  So cgroups don't work.
>
> Well, for systemd they actually work quite fine since systemd will
> always place its own cgroups below the cgroup it is started in. cgroups
> hence make these things nicely stackable.
>
> In fact, most folks involved in cgroups userspace have agreed to these
> rules now:
>
> http://www.freedesktop.org/wiki/Software/systemd/PaxControlGroups
>
> Among other things they ask all userspace code to only create subgroups
> below the group they are started in, so not only systemd should work
> fine in a container environment but everything else following these
> rules.
>
> In other words: so far one gets away quite nicely with the fact that the
> cgroup tree is not virtualized.

Assuming you bind mount the cgroups inside and generally don't allow
people in a container to create cgroup hierarchies.  At the very least
that is nasty information leakage.

But I am glad there is a solution for right now.

For my uses I have yet to find control groups anything but borked.

>> - VTs.  Ptys should be well supported at this point.  For the rest
>>   they are physical hardware that a container should not be playing with
>>   so I would base which gettys to start up based on which device nodes
>>   are present in /dev.
>
> Well, I am not sure it's that easy since device nodes tend to show up
> dynamically in bare systems. So if you just check whether /dev/tty0 is
> there you might end up thinking you are in a container when you actually
> aren't simply because you did that check before udev loaded the DRI
> driver or so.

But the point isn't to detect a container the point is to decide if
a getty needs to be spawned.  Even with the configuration for a getty
you need to wait for the device node to exist before spawning one.

>> - sysctls (aka /proc/sys) that is a trick one.  Until the user namespace
>>   is fleshed out a little more sysctls are going to be a problem,
>>   because root can write to most of them.  My gut feel says you probably
>>   want to base that to poke at sysctls on CAP_SYS_ADMIN.  At least that
>>   test will become true when the userspaces are rolled out, and at
>>   that point you will want to set all of the sysctls you have permission
>>   to.
>
> So what we did right now in systemd-nspawn is that the container
> supervisor premounts /proc/sys read-only into the container. That way
> writes to it will fail in the container, and while you get a number of
> warnings things will work as they should (though not necessarily safely
> since the container can still remount the fs unless you take
> CAP_SYS_ADMIN away).

That sort of works.  In practice it means you can't setup interesting
things like forwarding in the networking stack.  But it certainly gets
things going.

>> So while I agree a check to see if something is a container seems
>> reasonable.  I do not agree that the pid namespace is the place to put
>> that information.  I see no natural to put that information in the
>> pid namespace.
>
> Well, a simple way would be to have a line /proc/1/status called
> "PIDNamespaceLevel:" or so which would be 0 for the root namespace, and
> increased for each namespace nested in it. Then, processes could simply
> read that and be happy.

Not a chance.  PIDNamespaceLevel is implementing an implementation
detail that may well change in the lifetime of a process.  It is true
we don't have migration mreged in the kernel yet but one of these days
I expect we will.

>> I further think there are a lot of reasonable checks for if a
>> kernel feature is supported in the current environment I would
>> rather pursue over hacks based the fact we are in a container.
>
> Well, believe me we have been tryiung to find nicer hooks that explicit
> checks for containers, but I am quite sure that at the end of the day
> you won't be able to go without it entirely.

And you have explicit information you are in a container at this point.

It looks like all that is left is Documentation of the conventions.

Eric
