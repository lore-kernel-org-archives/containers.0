From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCHSET 3/4] sysfs: divorce sysfs from kobject and driver model
Date: Wed, 10 Oct 2007 15:16:57 -0600
Message-ID: <m1ir5ek6uu.fsf@ebiederm.dsl.xmission.com>
References: <11902755392688-git-send-email-htejun@gmail.com>
	<20070925221736.GA3566@kroah.com> <46FB956B.8000205@gmail.com>
	<m1zlz7hpvn.fsf_-_@ebiederm.dsl.xmission.com>
	<20071005062302.GB16914@kroah.com>
	<m1d4vtn4jq.fsf@ebiederm.dsl.xmission.com>
	<20071009225139.GF21228@kroah.com>
	<m14pgzun27.fsf@ebiederm.dsl.xmission.com>
	<20071010204449.GA23680@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757335AbXJJVSs@vger.kernel.org>
In-Reply-To: <20071010204449.GA23680@kroah.com> (Greg KH's message of "Wed, 10
	Oct 2007 13:44:49 -0700")
Sender: linux-kernel-owner@vger.kernel.org
To: Greg KH <greg@kroah.com>
Cc: Tejun Heo <htejun@gmail.com>, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, kay.sievers@vrfy.org, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Greg KH <greg@kroah.com> writes:

> Ah, ok, that makes more sense.
>
> And seems quite difficult to do, good luck with that :)

Thanks.   At least now all I have to do is worry about the
details when we get that far instead of selling the big picture...

My gut feel is that sysfs is probably the hardest part to deal with,
and maybe half of the problem.  Just intercepting the lookup by
device number is fairly simple, I think there is one spot
for block devices and another for character devices.

Anyway once the network namespace support is in with any luck that
will have solved half the sysfs problem.

Eric
