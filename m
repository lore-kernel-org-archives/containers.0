From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Fri, 19 Nov 2010 18:16:52 +0200
Message-ID: <AANLkTikz++4_SvqU_Wvx5CjcpKJhPsD7q470swdqwn94@mail.gmail.com>
References: <20101104164401.GC10656@sundance.ccs.neu.edu>
	<4CD3CE29.2010105@kernel.org>
	<20101106053204.GB12449@count0.beaverton.ibm.com>
	<20101106204008.GA31077@sundance.ccs.neu.edu>
	<4CD5D99A.8000402@cs.columbia.edu>
	<20101107184927.GF31077@sundance.ccs.neu.edu>
	<4CD72150.9070705@cs.columbia.edu>
	<4CE3C334.9080401@kernel.org>
	<20101117153902.GA1155@hallyn.com>
	<4CE3F8D1.10003@kernel.org>
	<20101119041045.GC24031@hallyn.com>
	<4CE683E1.6010500@kernel.org>
	<04F4899E-B5C7-4BAF-8F2F-05D507A91408@parallels.com>
	<4CE698C5.5060806@kernel.org>
	<AANLkTikRHuaCpaROtty6X_Oe6JixzgcbVsxHxvtsu+UV@mail.gmail.com>
	<4CE6A076.2020807@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CE6A076.2020807@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Kirill Korotaev <dev@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>, Kapil Arya <kapil@ccs.neu.edu>, Gene Cooperman <gene@ccs.neu.edu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pavel Emelianov <xemul@parallels.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Fri, Nov 19, 2010 at 6:06 PM, Tejun Heo <tj@kernel.org> wrote:
>>>> - setting different statistics counters (like netdev stats etc.)
>>>> and so on...
>>>
>>> Why would this matter?
>>
>> Because you'll introduce million stupid interfaces not interesting t=
o
>> anyone but C/R.
>
> In this thread, how many have you guys come up with? =A0Not even a do=
zen
> and most can be sovled almost trivially. =A0Seriously, what the hell.=
=2E

I do not count them.

The paragon of absurdity is struct task_struct::did_exec .
