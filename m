From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH 0/7] Clone PTS namespace
Date: Fri, 25 Apr 2008 12:47:27 -0700
Message-ID: <m1lk314sz4.fsf@frodo.ebiederm.org>
References: <20080408215333.GA8799@us.ibm.com> <47FC138B.4070408@zytor.com>
	<1207779313.16926.12.camel@x61.ebiederm.org>
	<20080410015955.GA18227@sergelap.austin.rr.com>
	<1207812980.7509.25.camel@x61.ebiederm.org>
	<20080422142539.GA12623@sergelap.austin.ibm.com>
	<m1hcdtsovg.fsf@frodo.ebiederm.org>
	<20080423143610.GA13718@sergelap.austin.ibm.com>
	<20080423175749.GA17618@sergelap.austin.ibm.com>
	<m1tzhsmmo5.fsf@frodo.ebiederm.org>
	<20080425192102.GA17896@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762610AbYDYTr4@vger.kernel.org>
In-Reply-To: <20080425192102.GA17896@sergelap.austin.ibm.com> (Serge
	E. Hallyn's message of "Fri, 25 Apr 2008 14:21:02 -0500")
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Containers <containers@lists.osdl.org>, clg@fr.ibm.com, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>, Benjamin Thery <benjamin.thery@bull.net>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue@us.ibm.com> writes:


> Heh, well I tried several approaches - adding tag_ops to kset, to ktype,
> etc.  Finally ended up just calling sysfs_enable_tagging on
> /sys/kernel/uids when that is created.  It's now working perfectly.

Sounds good.

>> I suspect since you are working on this and I seem to be stuck
>> in molasses at the moment it makes sense to figure out what it
>> will take to handle the uid namespace before pushing these
>> patches again.
>
> I had ported your patches to 2.6.25, but Benjamin in the meantime ported
> them to 2.6.25-mm1.  Since that's closer to the -net tree it's a more
> useful port, so I'll let him post his patchset.  Then I'll send the
> userns patch on top of that.  While I'm not actually able to send
> network traffic over a veth dev (I probably am still not setting it up
> right), I am able to pass veth devices into network namespaces, and the
> user namespaces are properly handled.
>
> I believe Benjamin did notice a problem with some symlinks not existing,
> and I think we want one more patch on top of yours removing the
> hold_net() from sysfs_mount, which I don't think was what you really
> wanted to do.  By simply removing that, if all tasks in a netns go away,
> the netns actually goes away and a lookup under a bind-mounted copy of
> its /sys/class/net is empty.

I will have to look, I need to refresh myself on where all of this code is.
I think hold_net was what I wanted.  A record that there is a user
but not something that will keep the network namespace from going away.

Essentially hold_net should be a debugging check rather then a
real limitation.


> Anyway the patches should be hitting the list next week.

Cool.  We can figure out what we need to do to merge them from
there.

>> Taking a quick look and having a clue what we will need to
>> do for a theoretical device namespace is also a possibility.
>
> I'm not sure I'm familiar enough with the kobject/class/sysfs/device
> relationships yet to comment on that.  It doesn't look like it should
> really be a problem, though simply adding tags to every directory
> under /sys/class (/sys/class/tty, /sys/class/usb_device, etc) doesn't
> seem like necessarily the nicest way to go...

True.  And the goal is something maintainable.  There are still a lot
of implications of a device namespace left unexamined so we shall see.

Eric
