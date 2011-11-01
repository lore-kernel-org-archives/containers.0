From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [lxc-devel] Detecting if you are running in a container
Date: Tue, 01 Nov 2011 16:51:22 -0700
Message-ID: <m17h3js8p1.fsf@fess.ebiederm.org>
References: <1317943022.1095.25.camel@mop>
	<20111007074904.GC16723@count0.beaverton.ibm.com>
	<20111007160113.GB14201@tango.0pointer.de>
	<m17h4g2jqy.fsf@fess.ebiederm.org>
	<20111010163140.GA22191@tango.0pointer.de>
	<m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
	<20111010214148.GB26510@tango.0pointer.de>
	<CAPXgP13npxh6UoEtXNiZ+Lhe_QxpO8-7r==WuUXDnNr+sHGXMw@mail.gmail.com>
	<4EB06D27.4020507@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EB06D27.4020507@msgid.tls.msk.ru> (Michael Tokarev's message of
	"Wed, 02 Nov 2011 02:05:27 +0400")
Sender: linux-kernel-owner@vger.kernel.org
To: Michael Tokarev <mjt@tls.msk.ru>
Cc: Kay Sievers <kay.sievers@vrfy.org>, Lennart Poettering <mzxreary@0pointer.de>, greg@kroah.com, Paul Menage <paul@paulmenage.org>, linux-kernel@vger.kernel.org, david@fubar.dk, Linux Containers <lxc-devel@lists.sourceforge.net>, Linux Containers <containers@lists.osdl.org>, "Serge E. Hallyn" <serge@hallyn.com>, harald@redhat.com
List-Id: containers.vger.kernel.org

Michael Tokarev <mjt@tls.msk.ru> writes:

> [Replying to an oldish email...]
>
> On 12.10.2011 20:59, Kay Sievers wrote:
>> On Mon, Oct 10, 2011 at 23:41, Lennart Poettering <mzxreary@0pointer.de> wrote:
>>> On Mon, 10.10.11 13:59, Eric W. Biederman (ebiederm@xmission.com) wrote:
>> 
>>>> - udev.  All of the kernel interfaces for udev should be supported in
>>>>   current kernels.  However I believe udev is useless because container
>>>>   start drops CAP_MKNOD so we can't do evil things.  So I would
>>>>   recommend basing the startup of udev on presence of CAP_MKNOD.
>>>
>>> Using CAP_MKNOD as test here is indeed a good idea. I'll make sure udev
>>> in a systemd world makes use of that.
>> 
>> Done.
>> 
>> http://git.kernel.org/?p=linux/hotplug/udev.git;a=commitdiff;h=9371e6f3e04b03692c23e392fdf005a08ccf1edb
>
> Maybe CAP_MKNOD isn't actually a good idea, having in mind devtmpfs?
>
> Without CAP_MKNOD, is devtmpfs still being populated internally by
> the kernel, so that udev only needs to change ownership/permissions
> and maintain symlinks in response to device changes, and perform
> other duties (reacting to other types of events) normally?
>
> In other words, provided devtmpfs works even without CAP_MKNOD,
> I can easily imagine a whole system running without this capability
> from the very early boot, with all functionality in place, including
> udev and what not...

Agreed devtmpfs does pretty much make dropping CAP_MKNOD useless.  I
expect we should verify that whoever mounts devtmpfs has CAP_MKNOD.

> And having CAP_MKNOD in container may not be that bad either, while
> cgroup device.permission is set correctly - some nodes may need to
> be created still, even in an unprivileged containers.  Who filters
> out CAP_MKNOD during container startup (I don't see it in the code,
> which only removes CAP_SYS_BOOT, and even that due to current
> limitation), and which evil things can be done if it is not filtered?

If you don't filter which device nodes you a process can read/write then
that process can access any device on the system.  Steal the keyboard,
the X display, access any filesystem, directly access memory.  Basically
the process can escalate that permission to full control of the system
without needing any kernel bugs to help it.

Eric
