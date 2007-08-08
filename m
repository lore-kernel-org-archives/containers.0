From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 0/25] Sysfs cleanups & tagged directory support
Date: Wed, 08 Aug 2007 17:54:44 +0900
Message-ID: <46B984D4.9020600@gmail.com>
References: <11860582832964-git-send-email-htejun@gmail.com>	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>	<20070808093815.0935a18e@gondolin.boeblingen.de.ibm.com>	<m1bqdifowo.fsf@ebiederm.dsl.xmission.com>	<20070808095432.4a520735@gondolin.boeblingen.de.ibm.com>	<m17io6foh8.fsf@ebiederm.dsl.xmission.com> <20070808103759.0850383c@gondolin.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764181AbXHHIzH@vger.kernel.org>
In-Reply-To: <20070808103759.0850383c@gondolin.boeblingen.de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

Cornelia Huck wrote:
> On Wed, 08 Aug 2007 01:57:07 -0600,
> ebiederm@xmission.com (Eric W. Biederman) wrote:
> 
>>> Got it: It's patch 6, the readdir simplification.
>>>
>>> (The udev on that guest is ancient (063)...)
>> Ok.  That is weird.
> 
> More weirdness. If I activate another dasd from the repair file
> system, /dev/dasdb is created...
> 
> Same if I set the card reader online: /dev/vmrdr-0.0.000c is created as
> expected.
> 
>> Does it depend on the order in which the dentries are returned from
>> readdir?
> 
> I'd think not.
> 
>> Unless I made a really stupid error otherwise the two versions
>> of readdir should have the same semantics.
> 
> Yes, your patch looks sane. I have no idea why it breaks stuff...

Are you sure it's patch 6?  Patch 17 adds a deadlock in rename path.

-- 
tejun
