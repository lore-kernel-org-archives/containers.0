From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Mon, 08 Nov 2010 14:34:24 -0500
Message-ID: <4CD850C0.7020609@cs.columbia.edu>
References: <20101104164401.GC10656@sundance.ccs.neu.edu> <4CD3CE29.2010105@kernel.org> <AANLkTimDXKsBCxbsEOfgkYV2R8FK=bhFdmx9UQow5hqp@mail.gmail.com> <4CD5DCE3.3000109@cs.columbia.edu> <20101107194222.GG31077@sundance.ccs.neu.edu> <4CD71A6B.3020905@cs.columbia.edu> <20101107230516.GJ31077@sundance.ccs.neu.edu> <4CD774CA.8030004@cs.columbia.edu> <20101108162630.GN31077@sundance.ccs.neu.edu> <4CD83DF4.4080009@cs.columbia.edu> <20101108183701.GA20262@sundance.ccs.neu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101108183701.GA20262@sundance.ccs.neu.edu>
Sender: linux-kernel-owner@vger.kernel.org
To: Gene Cooperman <gene@ccs.neu.edu>
Cc: Kapil Arya <kapil@ccs.neu.edu>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, hch@lst.de, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org



On 11/08/2010 01:37 PM, Gene Cooperman wrote:
> Thanks for the careful response, Oren.  For others who read this,
> one could interpret Oren's rapid post as criticizing the work of
> Andres Lagar Cavilla.  I'm sure that this was not Oren's intention.
> Please read below for a brief clarification of the novelty of SnowFlock.

Err... yes, that was careless of me. I was too focused on
getting the thread back to track. Thanks for pointing out.

>>> about live migration, have you also looked at the work of
>>> Andres Lagar Caviilla on SnowFlock?
>>>      http://andres.lagarcavilla.com/publications/LagarCavillaEurosys09.pdf
>>> He does live migration of entire virtual machines, again with very
>>> small delay.  Of course, the issue for any type of live migration is that
>>> if the rate of dirtying pages is very high (e.g. HPC), then there is
>>> still a delay or slow response, due to page faults to a remote host.
>>
>> VMware, Xen and KVM already do live migration. However, VMs
>> are a separate beast.
>
> I absolutely agree with your point that live migration of
> applications is a different beast, and technically very novel.
>      Since I know Andres Lagar Cavilla personally, I also feel obligated
> to comment why SnowFlock truly is novel in the VM space.  First, as Andres
> writes:
> "SnowFlock is an open-source project [SnowFlock] built on the Xen 3.0.3
> VMM [Barham 2003]."
> In the abstract, Andres points out one of the major points of novelty:
> "To evaluate SnowFlock, we focus on the demanding
> scenario of services requiring on-the-fly creation of hundreds
> of parallel workers in order to solve computationallyintensive
> queries in seconds."
> We must be careful that we don't destroy someone's reputation without
> a careful study of their work.

Yes, it's really nice work - I saw it when I visited there.
(Coincidentally the post-copy idea with Xen appeared also in
VEE 09 briefly before).

Oren.
