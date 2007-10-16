From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCHSET 3/4] sysfs: divorce sysfs from kobject and driver model
Date: Tue, 16 Oct 2007 17:54:06 -0600
Message-ID: <m1r6jufwf5.fsf@ebiederm.dsl.xmission.com>
References: <11902755392688-git-send-email-htejun@gmail.com>
	<20070925221736.GA3566@kroah.com> <46FB956B.8000205@gmail.com>
	<m1zlz7hpvn.fsf_-_@ebiederm.dsl.xmission.com>
	<20071005062302.GB16914@kroah.com>
	<m1d4vtn4jq.fsf@ebiederm.dsl.xmission.com>
	<20071009225139.GF21228@kroah.com>
	<m14pgzun27.fsf@ebiederm.dsl.xmission.com>
	<20071016221816.GA14787@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934671AbXJPXz6@vger.kernel.org>
In-Reply-To: <20071016221816.GA14787@us.ibm.com> (sukadev@us.ibm.com's message
	of "Tue, 16 Oct 2007 15:18:16 -0700")
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@us.ibm.com
Cc: Greg KH <greg@kroah.com>, Tejun Heo <htejun@gmail.com>, kay.sievers@vrfy.org, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, stern@rowland.harvard.edu, cornelia.huck@de.ibm.com
List-Id: containers.vger.kernel.org

sukadev@us.ibm.com writes:

> | No. The "other" device namespace I would construct on machine B to
> | look just like the device namespace that existed on machine A.
> | Making /sys/devices/block/sda would still be 8:0.
> | 
> | So to be very clear on machine B when talking about disk-1 I would have.
> | initial device namespace:
> |   /sys/devices/block/sdb
> |   /sys/devices/block/sdb/dev 8:16
> | 
> | "other" device namespace:
> |   /sys/devices/block/sda
> |   /sys/devices/block/sda/dev 8:0
> | 
> | Similarly on machine B when talking about disk-2 I would have.
> | initial device namespace:
> |   /sys/devices/block/sda
> |   /sys/devices/block/sda/dev 8:0
> | 
> | "other" device namespace:
> |   /sys/devices/block/sdb
> |   /sys/devices/block/sdb/dev 8:16
> | 
> | So between the two devices namespaces on machine B the two disks
> | would exchange their user visible identities.
>
> So an application that would migrate from machine A to B has to
> use virtual names (like "disk-1" and "disk-2") to access the disk
> right ? 

No.  It is worse you need to access a filesystem and probably
a block device that is available on both machine A and machine B.
With care we can introduce appropriate namespaces and namespace semantics
so we can make the names be what we need.

For a classic tricky case think what it would require to migrate
a git archive with checked out files and not need to say
"git-update-index --refresh" before you work with the files.

I used names like disk-1 and disk-2 instead of UUIDs because it
was easier for me to type and think about.  You do need some
kind of absolute disk or filesystem identity you can refer back to.

Eric
