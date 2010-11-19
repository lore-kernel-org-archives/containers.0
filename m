From: Tejun Heo <tj@kernel.org>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Fri, 19 Nov 2010 17:50:01 +0100
Message-ID: <4CE6AAB9.3070009@kernel.org>
References: <20101104164401.GC10656@sundance.ccs.neu.edu>	<4CD3CE29.2010105@kernel.org>	<20101106053204.GB12449@count0.beaverton.ibm.com>	<20101106204008.GA31077@sundance.ccs.neu.edu>	<4CD5D99A.8000402@cs.columbia.edu>	<20101107184927.GF31077@sundance.ccs.neu.edu>	<4CD72150.9070705@cs.columbia.edu>	<4CE3C334.9080401@kernel.org>	<20101117153902.GA1155@hallyn.com>	<4CE3F8D1.10003@kernel.org>	<20101119041045.GC24031@hallyn.com>	<4CE683E1.6010500@kernel.org>	<04F4899E-B5C7-4BAF-8F2F-05D507A91408@parallels.com>	<4CE698C5.5060806@kernel.org>	<AANLkTikRHuaCpaROtty6X_Oe6JixzgcbVsxHxvtsu+UV@mail.gmail.com>	<4CE6A076.2020807@kernel.org>	<AANLkTikz++4_SvqU_Wvx5CjcpKJhPsD7q470swdqwn94@mail.gmail.com>	<4CE6A397.6010105@kernel.org>	<AANLkTin7kd3crS+fTLLea5PhAii7B3dz=n7p7YtQ6d4g@mail.gmail.com>	<4CE6A69F
 .4030008@kernel.org> <AANLkTim-M02Z1igZ4LyXH_Qgyzx1iD0ZQkRT6dxcSE3P@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTim-M02Z1igZ4LyXH_Qgyzx1iD0ZQkRT6dxcSE3P@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Kirill Korotaev <dev@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>, Kapil Arya <kapil@ccs.neu.edu>, Gene Cooperman <gene@ccs.neu.edu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pavel Emelianov <xemul@parallels.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On 11/19/2010 05:38 PM, Alexey Dobriyan wrote:
> On Fri, Nov 19, 2010 at 6:32 PM, Tejun Heo <tj@kernel.org> wrote:
>> On 11/19/2010 05:27 PM, Alexey Dobriyan wrote:
>>> On Fri, Nov 19, 2010 at 6:19 PM, Tejun Heo <tj@kernel.org> wrote:
>>>>> The paragon of absurdity is struct task_struct::did_exec .
>>>>
>>>> Yeah, then go and figure how to do that in a way which would be useful
>>>> for other purposes too instead of trying to shove the whole
>>>> checkpointer inside the kernel.  It sure would be harder but hey
>>>> that's the way it is.
>>>
>>> System call for one bit? This is ridiculous.
>>
>> Why not just a flag in proc entry?  It's a frigging single bit.
> 
> Because /proc/*/did_exec useless to anyone but C/R (even for reading!).

I don't think you'll need a full file.  Just shove it in status or
somewhere.  Your argument is completely absurd.  So, because exporting
single bit is so horrible to everyone else, you want to shove the
whole frigging checkpointer inside the kernel?

> Because code is much simpler:
> 
>     tsk->did_exec = !!tsk_img->did_exec;
> +
>     __u8 did_exec;

Sigh, yeah, except for the horror show to create tsk_img.  Your
"paragon of absurdity" is did_exec which is only ever used to decide
whether setpgid() should fail with -EACCES, seriously?  Here's a
thought.  Ignore it for now and concentrate on more relevant problems.
I'm fairly sure CR'd program malfunctioning over did_exec wouldn't
mark the beginning of the end of our civilization.  You gotta be
kidding me.

-- 
tejun
