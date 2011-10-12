From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Detecting if you are running in a container
Date: Tue, 11 Oct 2011 21:26:32 -0700
Message-ID: <m139eyg7if.fsf@fess.ebiederm.org>
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
	<m17h4bfcuv.fsf@fess.ebiederm.org>
	<alpine.DEB.2.02.1110111525450.28233@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1110111525450.28233@asgard.lang.hm>
	(david@lang.hm's message of "Tue, 11 Oct 2011 15:30:25 -0700 (PDT)")
Sender: linux-kernel-owner@vger.kernel.org
To: david@lang.hm
Cc: Theodore Tso <tytso@MIT.EDU>, Matt Helsley <matthltc@us.ibm.com>, Lennart Poettering <mzxreary@0pointer.de>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

david@lang.hm writes:

> On Tue, 11 Oct 2011, Eric W. Biederman wrote:
>
>> Theodore Tso <tytso@MIT.EDU> writes:
>>
>>> On Oct 11, 2011, at 2:42 AM, Eric W. Biederman wrote:
>>>
>>>> I am totally in favor of not starting the entire world.  But just
>>>> like I find it convienient to loopback mount an iso image to see
>>>> what is on a disk image.  It would be handy to be able to just
>>>> download a distro image and play with it, without doing anything
>>>> special.
>>>
>>> Agreed, but what's wrong with firing up KVM to play with a distro
>>> image?  Personally, I don't consider that "doing something special".
>>
>> Then let me flip this around and give a much more practical use case.
>> Testing.  A very interesting number of cases involve how multiple
>> machines interact.  You can test a lot more logical machines interacting
>> with containers than you can with vms.  And you can test on all the
>> aritectures and platforms linux supports not just the handful that are
>> well supported by hardware virtualization.
>
> but in containers, you are not really testing lots of machines, you are testing
> lots of processes on the same machine (they share the same kernel)

True.  But usually that is the interesting part.

>> I admit for a lot of test cases that it makes sense not to use a full
>> set of userspace daemons.  At the same time there is not particularly
>> good reason to have a design that doesn't allow you to run a full
>> userspace.
>
> how do you share the display between all the different containers if they are
> trying to run the X server?

Either X does not start because the hardware it needs is not present or
Xnest or similar gets started.

> how do you avoid all the containers binding to the same port on the default IP
> address?

Network namespaces.

> how do you arbitrate dbus across the containers.

Why should you?

> when a new USB device gets plugged in, which container gets control of
> it?

None of them.  Although today they may all get the uevent.  None of the
containers should have permission to call mknod to mess with it.

> there are a LOT of hard questions when you start talking about running a full
> system inside a container that do not apply for other use of
> containers.

Not really mostly the answer is that you say no.

Eric
