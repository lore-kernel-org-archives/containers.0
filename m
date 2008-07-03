From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 06/11] sysfs: Implement sysfs tagged directory support.
Date: Thu, 03 Jul 2008 12:57:14 -0700
Message-ID: <m1od5elp0l.fsf@frodo.ebiederm.org>
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
	<486CC81D.9010003@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755711AbYGCUBy@vger.kernel.org>
In-Reply-To: <486CC81D.9010003@bull.net> (Benjamin Thery's message of "Thu, 03
	Jul 2008 14:37:49 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <htejun@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Benjamin Thery <benjamin.thery@bull.net> writes:

> Indeed, we observed some fun things with one distro (which defines some
> particular udev rules) when a device called eth0 in a namespace comes back to
> init net :)

Speaking of.  Don't let me forget but I have a patch I need to send out
that deletes pseudo devices instead of sending them back to eth0.   We can't
do that for real hardware obviously but for things like veth and macvlan
devices it greatly simplifies the cleanup.

Eric
