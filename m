From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/25] Sysfs cleanups & tagged directory support
Date: Wed, 08 Aug 2007 01:57:07 -0600
Message-ID: <m17io6foh8.fsf@ebiederm.dsl.xmission.com>
References: <11860582832964-git-send-email-htejun@gmail.com>
	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>
	<20070808093815.0935a18e@gondolin.boeblingen.de.ibm.com>
	<m1bqdifowo.fsf@ebiederm.dsl.xmission.com>
	<20070808095432.4a520735@gondolin.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760750AbXHHIEE@vger.kernel.org>
In-Reply-To: <20070808095432.4a520735@gondolin.boeblingen.de.ibm.com>
	(Cornelia Huck's message of "Wed, 8 Aug 2007 09:54:32 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, stern@rowland.harvard.edu, Tejun Heo <htejun@gmail.com>, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

Cornelia Huck <cornelia.huck@de.ibm.com> writes:

> On Wed, 08 Aug 2007 01:47:51 -0600,
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> Cornelia Huck <cornelia.huck@de.ibm.com> writes:
>> 
>> > My udev failed to create /dev/dasd* so it cannot mount root :( I'm
>> > currently trying to find out what causes this, may take some time...
>> 
>> Oh weird.
>> 
>> No great surprise that something goofed up given how many
>> patches were involved.  Still there shouldn't have been
>> any user visible differences in the patchset.
>> 
>> If you can narrow down which patch caused the problem that would be
>> great.
>
> Got it: It's patch 6, the readdir simplification.
>
> (The udev on that guest is ancient (063)...)

Ok.  That is weird.

Does it depend on the order in which the dentries are returned from
readdir?

Unless I made a really stupid error otherwise the two versions
of readdir should have the same semantics.

Eric
