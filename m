From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Detecting if you are running in a container
Date: Mon, 10 Oct 2011 13:59:10 -0700
Message-ID: <m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
References: <1317943022.1095.25.camel@mop>
	<20111007074904.GC16723@count0.beaverton.ibm.com>
	<20111007160113.GB14201@tango.0pointer.de>
	<m17h4g2jqy.fsf@fess.ebiederm.org>
	<20111010163140.GA22191@tango.0pointer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111010163140.GA22191@tango.0pointer.de> (Lennart Poettering's
	message of "Mon, 10 Oct 2011 18:31:41 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Lennart Poettering <mzxreary@0pointer.de>
Cc: Matt Helsley <matthltc@us.ibm.com>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org


Cc's and subject updated so hopefully we get the correct people
on this discussion to make progress.

Lennart Poettering <mzxreary@0pointer.de> writes:

> To make a standard distribution run nicely in a Linux container you
> usually have to make quite a number of modifications to it and disable
> certain things from the boot process. Ideally however, one could simply
> boot the same image on a real machine and in a container and would just
> do the right thing, fully stateless. And for that you need to be able to
> detect containers, and currently you can't.

I agree getting to the point where we can run a standard distribution
unmodified in a container sounds like a reasonable goal.

> Quite a few kernel subsystems are
> currently not virtualized, for example SELinux, VTs, most of sysfs, most
> of /proc/sys, audit, udev or file systems (by which I mean that for a
> container you probably don't want to fsck the root fs, and so on), and
> containers tend to be much more lightweight than real systems.

That is an interesting viewpoint on what is not complete.  But as a
listing of the tasks that distribution startup needs to do differently in
a container the list seems more or less reasonable.

There are two questions 
- How in the general case do we detect if we are running in a container.
- How do we make reasonable tests during bootup to see if it makes sense
  to perform certain actions.

For the general detection if we are running in a linux container I can
see two reasonable possibilities.

- Put a file in / that let's you know by convention that you are in a
  linux container.  I am inclined to do this because this is something
  we can support on all kernels old and new.

- Allow modification to the output of uname(2).  The uts namespace
  already covers uname(2) and uname is the standard method to
  communicate to userspace the vageries about the OS level environment
  they are running in.


My list of things that still have work left to do looks like:
- cgroups.  It is not safe to create a new hierarchies with groups
  that are in existing hierarchies.  So cgroups don't work.

- user namespace.  We are very close to have something workable
  on this one, but until we do all of the users inside and outside
  of a container are the same, and pass the same permission checks.

  As a result we have to drop most of roots privileges, and we have
  to be a bit careful what binaries that can gain privileges (think suid
  root) are in the container filesystem.

- Reboot.  I know Daniel was working on something not long ago
  but I am not certain where he would up.

- device namespaces.  We periodically think about having a separate
  set of devices and to support things like losetup in a container
  that seems necessary.  Most of the time getting all of the way
  to device namespaces seems unnecessary.


As for tests on what to startup.

- udev.  All of the kernel interfaces for udev should be supported in
  current kernels.  However I believe udev is useless because container
  start drops CAP_MKNOD so we can't do evil things.  So I would
  recommend basing the startup of udev on presence of CAP_MKNOD.

- VTs.  Ptys should be well supported at this point.  For the rest
  they are physical hardware that a container should not be playing with
  so I would base which gettys to start up based on which device nodes
  are present in /dev.

- sysctls (aka /proc/sys) that is a trick one.  Until the user namespace
  is fleshed out a little more sysctls are going to be a problem,
  because root can write to most of them.  My gut feel says you probably
  want to base that to poke at sysctls on CAP_SYS_ADMIN.  At least that
  test will become true when the userspaces are rolled out, and at
  that point you will want to set all of the sysctls you have permission
  to.

- audit.  My memory is very fuzzy on this one.  The issue in question is
  should we start auditd?  I believe the audit calls actually fail in a
  container so we should be able to trigger starting auditd on if audit
  works at all.  If we can't do it that way certainly the work should be
  put in so that it can be done that way.

- fsck.  A rw filesystem check like you mentioned earlier seems like a
  reasonable place to be I know the OpenVz folks were talking about
  putting containers in their own block devices for their next round of
  supporting containers.  At which point a filesystem check on container
  startup might not be a bad idea at all.

- cgroups hierarchies.  I don't know at which point in the system
  startup we care.  The appropriate solution would seem to be to try
  it and if the operation fails figure it isn't supported.

- selinux.  It really should be in the same category.  You should be
  able to attempt to load a policy and have it fail in a way that
  indicates that selinux is currently supported.  I don't know if
  we can make that work right until we get the user namespace into
  a usable shame.

In general things in a container should work or the kernel feature
should fail in a way that indicates that the feature is not supported.
That currently works well for the networking stack, and with the
pending usablilty of the user namespace it should work just about
everywhere else as well.  For things that don't fit that model we
need to fix the kernel.

So while I agree a check to see if something is a container seems
reasonable.  I do not agree that the pid namespace is the place to put
that information.  I see no natural to put that information in the
pid namespace.

I further think there are a lot of reasonable checks for if a
kernel feature is supported in the current environment I would
rather pursue over hacks based the fact we are in a container.

Eric
