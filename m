From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 00/15] sysfs support for namespaces
Date: Thu, 03 Jul 2008 17:48:40 -0700
Message-ID: <m1y74iiidz.fsf_-_@frodo.ebiederm.org>
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
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <486CF71F.5090405@gmail.com> (Tejun Heo's message of "Fri, 04 Jul
	2008 00:58:23 +0900")
Sender: netdev-owner@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <htejun@gmail.com>, Daniel Lezcano <dlezcano@fr.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>, Benjamin Thery <benjamin.thery@bull.net>, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org


When multiple namespaces are in use we can get multiple kernel objects
with the same name which is currently impossible to represent in sysfs.
In particular directories like /sys/class/net and /sys/kernel/uids have
significant problems.

Not wanting to change the user space interface and wanting to have a simple
implementation where all objects are in the kobject and sysfs trees.  The
decision has been made to tag objects with the namespace they live in,
and in a particular mount of sysfs only display objects with the tag
that corresponds to the namespaces in effect when sysfs was mounted.

After the last round of reviews the mount/umount logic is
significantly cleaned up and easier to maintain.  From a 10,000
foot view the code and the way it functions has remained the
same since we settled on tagged directories a year or so ago.   I
intend any future cleanups to be as incremental patches on top
of this existing set.

Lack of these patches are keeping the generally complete network
namespace work in 2.6.26 from being used and tested more heavily.
Can we please get the patches merged?

These patches are based off of 2.6.26-rc8 + the -gregkh tree from
last night.  Hopefully that means they apply -mm -gregkh and
-linux-next.

Eric


