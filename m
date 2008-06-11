From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm] CPU controller statistics (v5)
Date: Wed, 11 Jun 2008 01:28:20 -0700
Message-ID: <6599ad830806110128y24c9d222t44102e032198582c@mail.gmail.com>
References: <20080603200515.GA25753@balbir.in.ibm.com>
	 <20080604144408.be680056.akpm@linux-foundation.org>
	 <4847B3CB.5020700@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756924AbYFKI2i@vger.kernel.org>
In-Reply-To: <4847B3CB.5020700@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, balajirrao@gmail.com, containers@lists.osdl.org, vatsa@linux.vnet.ibm.com, a.p.zijlstra@chello.nl
List-Id: containers.vger.kernel.org

On Thu, Jun 5, 2008 at 2:37 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>> Can we avoid these tests?  By requiring that cgroup_subsys.initialize()
>> always be non-zero?  It might make sense, and it might not...
>>
>
> They are really hard to avoid, otherwise we might be taking away the flexibility
> we have.

And this is something that only gets called at startup.

>
>> Also, if this code is likely to be executed with any frequency then the
>> test of `early' could be inlined:
>>
>> static inline void cpu_cgroup_initialize(int early)
>> {
>>       if (unlikely(!early))
>>               __cpu_cgroup_initialize();
>> }
>>
>> yes?
>>
>
> Definitely

Er, no. It gets called twice at system boot (once with early=true and
once with early=false) via a vtable. So there's nothing to optimize
for, and making the function inline won't help since the compiler
needs to take its address.

Paul
