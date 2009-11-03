From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: pidns memory leak
Date: Tue, 03 Nov 2009 00:41:36 -0800
Message-ID: <m1ljiogfun.fsf@fess.ebiederm.org>
References: <20091006040526.GA22923@us.ibm.com> <4ACAFD6A.3060008@fr.ibm.com>
	<20091008030828.GA18973@us.ibm.com> <4ACD9ECC.90508@fr.ibm.com>
	<20091009032928.GA2031@us.ibm.com> <4ACF381F.9050808@fr.ibm.com>
	<20091010013235.GA11904@us.ibm.com> <4AD2EBC7.2020109@fr.ibm.com>
	<20091014061533.GA23569@us.ibm.com>
	<20091102133326.e3dc51fb.akpm@linux-foundation.org>
	<20091102223818.GA15628@us.ibm.com>
	<20091102144752.71fd4a31.akpm@linux-foundation.org>
	<4AEFDAAE.500@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755947AbZKCIlo@vger.kernel.org>
In-Reply-To: <4AEFDAAE.500@free.fr> (Cedric Le Goater's message of "Tue\, 03 Nov 2009 08\:24\:30 +0100")
Sender: linux-kernel-owner@vger.kernel.org
To: Cedric Le Goater <legoater@free.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Serge E. Hallyn" <serue@us.ibm.com>, andrea@cpushare.com, Linux Containers <containers@lists.osdl.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Emelianov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@mail.ru>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Cedric Le Goater <legoater@free.fr> writes:

> On 11/02/2009 11:47 PM, Andrew Morton wrote:
>> On Mon, 2 Nov 2009 16:38:18 -0600
>> "Serge E. Hallyn" <serue@us.ibm.com> wrote:
>> 
>>>> This bug hasn't been fixed yet, has it?
>>>
>>> Well Suka did trace the bug to commit 7766755a2f249e7, and posted a patch
>>> to revert that, acked by Eric on Oct 20.  Suka, were you going to repost
>>> that patch?
>> 
>> Ah.  OK.  Thanks.  Found it in the backlog pile.
>
> We've added the patch to our patchset and we confirm that the pid_* leaks have 
> been reduced to 'nearly' nothing but we still have a lot of inodes and dentries
> leaks. I hope to find some time to investigate and reproduce with a small 
> scenario, we are running a LTP like testsuite in a container environment.

Does forcing a cache flush help with the other leaks?

Eric
