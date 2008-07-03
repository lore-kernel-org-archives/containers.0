From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 06/11] sysfs: Implement sysfs tagged directory support.
Date: Thu, 03 Jul 2008 13:08:52 -0700
Message-ID: <m13amqloh7.fsf@frodo.ebiederm.org>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<20080618170731.002784342@theryb.frec.bull.fr>
	<485F04E1.70204@gmail.com> <m1y74svtff.fsf@frodo.ebiederm.org>
	<486706C9.9040303@gmail.com> <m18wwmsqdv.fsf@frodo.ebiederm.org>
	<4869D314.5030403@gmail.com> <m1ej6enep7.fsf@frodo.ebiederm.org>
	<486A0751.9080602@gmail.com> <m1wsk5hjm0.fsf@frodo.ebiederm.org>
	<486AF4FA.8020805@gmail.com> <m1ej6d9c2r.fsf@frodo.ebiederm.org>
	<486B060C.7030607@gmail.com> <m14p78s02q.fsf@frodo.ebiederm.org>
	<486C4515.1070007@gmail.com> <m1hcb7o8lv.fsf@frodo.ebiederm.org>
	<486CB051.5000507@fr.ibm.com> <m14p77m9uy.fsf@frodo.ebiederm.org>
	<486CF71F.5090405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755888AbYGCULt@vger.kernel.org>
In-Reply-To: <486CF71F.5090405@gmail.com> (Tejun Heo's message of "Fri, 04 Jul
	2008 00:58:23 +0900")
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Thery <benjamin.thery@bull.net>
List-Id: containers.vger.kernel.org

Tejun Heo <htejun@gmail.com> writes:

> Related delta: I've been thinking that uevents should be part of sysfs
> not kobject as that's what the userland is gonna associate the event
> with.  Would that solve the problem you're thinking about?

The good news is that uevent_sock is currently restricted to just
the initial network namespace (so the functionality completely
disappears in the other namespaces), and that it is broadcast only.

So it should be possible to look at who the client is and by some
magic criterian decide if it should receive the broadcast message.

The call to the user mode helper is trickier.  How do we setup the
proper user space context.

None of this is fundamentally hard just different work, for a different
day.

Eric
