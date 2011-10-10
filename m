From: Lennart Poettering <mzxreary@0pointer.de>
Subject: Re: Detecting if you are running in a container
Date: Mon, 10 Oct 2011 23:41:48 +0200
Message-ID: <20111010214148.GB26510@tango.0pointer.de>
References: <1317943022.1095.25.camel@mop>
 <20111007074904.GC16723@count0.beaverton.ibm.com>
 <20111007160113.GB14201@tango.0pointer.de>
 <m17h4g2jqy.fsf@fess.ebiederm.org>
 <20111010163140.GA22191@tango.0pointer.de>
 <m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Matt Helsley <matthltc@us.ibm.com>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

On Mon, 10.10.11 13:59, Eric W. Biederman (ebiederm@xmission.com) wrote:

> > Quite a few kernel subsystems are
> > currently not virtualized, for example SELinux, VTs, most of sysfs, most
> > of /proc/sys, audit, udev or file systems (by which I mean that for a
> > container you probably don't want to fsck the root fs, and so on), and
> > containers tend to be much more lightweight than real systems.
> 
> That is an interesting viewpoint on what is not complete.  But as a
> listing of the tasks that distribution startup needs to do differently in
> a container the list seems more or less reasonable.

Note that this is just what came to my mind while I was typing this, I
am quite sure there's actually more like this.

> There are two questions 
> - How in the general case do we detect if we are running in a container.
> - How do we make reasonable tests during bootup to see if it makes sense
>   to perform certain actions.
> 
> For the general detection if we are running in a linux container I can
> see two reasonable possibilities.
> 
> - Put a file in / that let's you know by convention that you are in a
>   linux container.  I am inclined to do this because this is something
>   we can support on all kernels old and new.

Hmpf. That would break the stateless read-only-ness of the root dir.

After pointing the issue out to the LXC folks they are now setting
"container=lxc" as env var when spawning a container. In systemd-nspawn
I have then adopted a similar scheme. Not sure though that that is
particularly nice however, since env vars are inherited further down the
tree where we probably don't want them.

In case you are curious: this is the code we use in systemd:

http://cgit.freedesktop.org/systemd/tree/src/virt.c

What matters to me though is that we can generically detect Linux
containers instead of specific implementations.

> - Allow modification to the output of uname(2).  The uts namespace
>   already covers uname(2) and uname is the standard method to
>   communicate to userspace the vageries about the OS level environment
>   they are running in.

Well, I am not a particular fan of having userspace tell userspace about
containers. I would prefer if userspace could get that info from the
kernel without any explicit agreement to set some specific variable.

That said detecting CLONE_NEWUTS by looking at the output of uname(2)
would be a workable solution for us. CLONE_NEWPID and CLONE_NEWUTS are
probably equally definining for what a container is, so I'd be happy if
we could detect either.

For example, if the kernel would append "(container)" or so to
utsname.machine[] after CLONE_NEWUTS is used I'd be quite happy.

> My list of things that still have work left to do looks like:
> - cgroups.  It is not safe to create a new hierarchies with groups
>   that are in existing hierarchies.  So cgroups don't work.

Well, for systemd they actually work quite fine since systemd will
always place its own cgroups below the cgroup it is started in. cgroups
hence make these things nicely stackable.

In fact, most folks involved in cgroups userspace have agreed to these
rules now:

http://www.freedesktop.org/wiki/Software/systemd/PaxControlGroups

Among other things they ask all userspace code to only create subgroups
below the group they are started in, so not only systemd should work
fine in a container environment but everything else following these
rules.

In other words: so far one gets away quite nicely with the fact that the
cgroup tree is not virtualized.

> - device namespaces.  We periodically think about having a separate
>   set of devices and to support things like losetup in a container
>   that seems necessary.  Most of the time getting all of the way
>   to device namespaces seems unnecessary.

Well, I am sure people use containers in all kinds of weird ways, but
for me personally I am quitre sure that containers should live in a
fully virtualized world and never get access to real devices.

> As for tests on what to startup.

Note again that my list above is not complete at all and the point I was
trying to make is that while you can find nice hooks for this for many
cases at the end of the day you actually do want to detect containers
for a few specific cases.

> - udev.  All of the kernel interfaces for udev should be supported in
>   current kernels.  However I believe udev is useless because container
>   start drops CAP_MKNOD so we can't do evil things.  So I would
>   recommend basing the startup of udev on presence of CAP_MKNOD.

Using CAP_MKNOD as test here is indeed a good idea. I'll make sure udev
in a systemd world makes use of that.

> - VTs.  Ptys should be well supported at this point.  For the rest
>   they are physical hardware that a container should not be playing with
>   so I would base which gettys to start up based on which device nodes
>   are present in /dev.

Well, I am not sure it's that easy since device nodes tend to show up
dynamically in bare systems. So if you just check whether /dev/tty0 is
there you might end up thinking you are in a container when you actually
aren't simply because you did that check before udev loaded the DRI
driver or so.

> - sysctls (aka /proc/sys) that is a trick one.  Until the user namespace
>   is fleshed out a little more sysctls are going to be a problem,
>   because root can write to most of them.  My gut feel says you probably
>   want to base that to poke at sysctls on CAP_SYS_ADMIN.  At least that
>   test will become true when the userspaces are rolled out, and at
>   that point you will want to set all of the sysctls you have permission
>   to.

So what we did right now in systemd-nspawn is that the container
supervisor premounts /proc/sys read-only into the container. That way
writes to it will fail in the container, and while you get a number of
warnings things will work as they should (though not necessarily safely
since the container can still remount the fs unless you take
CAP_SYS_ADMIN away).

> - selinux.  It really should be in the same category.  You should be
>   able to attempt to load a policy and have it fail in a way that
>   indicates that selinux is currently supported.  I don't know if
>   we can make that work right until we get the user namespace into
>   a usable shame.

The SELinux folks modified libselinux on my request to consider selinux
off if /sys/fs/selinux is already mounted and read-only. That means with
a new container userspace this problem is mostly worked around too. It
is crucial to make libselinux know that selinux is off because otherwise
it will continue to muck with the xattr labels where it shouldn't. In
if you want to fully virtualize this you probably should hide selinux
xattrs entirely in the container.

> So while I agree a check to see if something is a container seems
> reasonable.  I do not agree that the pid namespace is the place to put
> that information.  I see no natural to put that information in the
> pid namespace.

Well, a simple way would be to have a line /proc/1/status called
"PIDNamespaceLevel:" or so which would be 0 for the root namespace, and
increased for each namespace nested in it. Then, processes could simply
read that and be happy.

> I further think there are a lot of reasonable checks for if a
> kernel feature is supported in the current environment I would
> rather pursue over hacks based the fact we are in a container.

Well, believe me we have been tryiung to find nicer hooks that explicit
checks for containers, but I am quite sure that at the end of the day
you won't be able to go without it entirely.

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
