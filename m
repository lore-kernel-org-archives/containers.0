From: Tejun Heo <tj@kernel.org>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Fri, 19 Nov 2010 17:10:26 +0100
Message-ID: <4CE6A172.7010603@kernel.org>
References: <20101104164401.GC10656@sundance.ccs.neu.edu>	<4CD3CE29.2010105@kernel.org>	<20101106053204.GB12449@count0.beaverton.ibm.com>	<20101106204008.GA31077@sundance.ccs.neu.edu>	<4CD5D99A.8000402@cs.columbia.edu>	<20101107184927.GF31077@sundance.ccs.neu.edu>	<4CD72150.9070705@cs.columbia.edu>	<4CE3C334.9080401@kernel.org>	<20101117153902.GA1155@hallyn.com>	<4CE3F8D1.10003@kernel.org>	<20101119041045.GC24031@hallyn.com>	<4CE683E1.6010500@kernel.org>	<04F4899E-B5C7-4BAF-8F2F-05D507A91408@parallels.com>	<4CE698C5.5060806@kernel.org>	<AANLkTikRHuaCpaROtty6X_Oe6JixzgcbVsxHxvtsu+UV@mail.gmail.com> <AANLkTikqpv8j-H15qjyhy7RJ92wNsWzeFykVMFKypt13@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikqpv8j-H15qjyhy7RJ92wNsWzeFykVMFKypt13@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Kirill Korotaev <dev@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>, Kapil Arya <kapil@ccs.neu.edu>, Gene Cooperman <gene@ccs.neu.edu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pavel Emelianov <xemul@parallels.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On 11/19/2010 05:01 PM, Alexey Dobriyan wrote:
> On Fri, Nov 19, 2010 at 6:00 PM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
>>>> - setting different statistics counters (like netdev stats etc.)
>>>> and so on...
>>>
>>> Why would this matter?
>>
>> Because you'll introduce million stupid interfaces not interesting to
>> anyone but C/R.
> 
> Just like CLONE_SET_PID.

Well, if you ask me, having pidns w/o a way to reinstate PID from
userland is pretty silly and you and I might not know yet but it's
quite imaginable that there will be other use cases for the capability
unlike in-kernel CR.  Kernel provides building blocks not the whole
frigging package and for very good reasons.

-- 
tejun
