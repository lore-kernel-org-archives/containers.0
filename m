From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Mon, 08 Nov 2010 13:14:12 -0500
Message-ID: <4CD83DF4.4080009@cs.columbia.edu>
References: <AANLkTinOg6n3ZA+0gHzw9LouRuUmJ7DJwHtABRy5c=gM@mail.gmail.com> <4CD26948.7050009@kernel.org> <20101104164401.GC10656@sundance.ccs.neu.edu> <4CD3CE29.2010105@kernel.org> <AANLkTimDXKsBCxbsEOfgkYV2R8FK=bhFdmx9UQow5hqp@mail.gmail.com> <4CD5DCE3.3000109@cs.columbia.edu> <20101107194222.GG31077@sundance.ccs.neu.edu> <4CD71A6B.3020905@cs.columbia.edu> <20101107230516.GJ31077@sundance.ccs.neu.edu> <4CD774CA.8030004@cs.columbia.edu> <20101108162630.GN31077@sundance.ccs.neu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101108162630.GN31077@sundance.ccs.neu.edu>
Sender: linux-kernel-owner@vger.kernel.org
To: Gene Cooperman <gene@ccs.neu.edu>
Cc: Kapil Arya <kapil@ccs.neu.edu>, Tejun Heo <tj@kernel.org>, ksummit-2010-discuss@lists.linux-foundation.org, linux-kernel@vger.kernel.org, hch@lst.de, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Hi,

Ok, I'll bite the bullet for now - to be continued...

Just one important clarification:

>> Linux-cr can do live migration - e.g. VDI, move the desktop - in
>> which case skype's sockets' network stacks are reconstructed,
>> transparently to both skype (local apps) and the peer (remote apps).
>> Then, at the destination host and skype continues to work.
>
> That's a really cool thing to do, and it's definitely not part of what
> DMTCP does.  It might be possible to do userland live migration,
> but it's definitely not part of our current scope.  But if we're talking
> about live migration, have you also looked at the work of
> Andres Lagar Caviilla on SnowFlock?
>      http://andres.lagarcavilla.com/publications/LagarCavillaEurosys09.pdf
> He does live migration of entire virtual machines, again with very
> small delay.  Of course, the issue for any type of live migration is that
> if the rate of dirtying pages is very high (e.g. HPC), then there is
> still a delay or slow response, due to page faults to a remote host.

VMware, Xen and KVM already do live migration. However, VMs
are a separate beast.

We are concerned about _application_ level c/r and migration
(complete containers or individual applications). Many proven
techniques from the VM world apply to our context too (in your
example, post-copy migration).

Oren.
