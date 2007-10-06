From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] task containersv11 add tasks file interface fix for
 cpusets
Date: Sat, 6 Oct 2007 14:41:57 -0700
Message-ID: <20071006144157.a2243305.pj@sgi.com>
References: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com>
	<6599ad830710030851jb44f00ft9634f9381218b6e9@mail.gmail.com>
	<20071003105817.7adf6516.pj@sgi.com>
	<6599ad830710031110r1a74eafej56f20cc33e72ac81@mail.gmail.com>
	<20071003131632.fed4b848.pj@sgi.com>
	<6599ad830710031331h15d35e90lc63d845efd2de6f5@mail.gmail.com>
	<20071006012437.c0fd3a8a.pj@sgi.com>
	<alpine.DEB.0.9999.0710061047400.24311@chino.kir.corp.google.com>
	<20071006125904.a26ed99f.pj@sgi.com>
	<6599ad830710061409p2dcaa1c8u8c6864beaaafb149@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765691AbXJFVmV@vger.kernel.org>
In-Reply-To: <6599ad830710061409p2dcaa1c8u8c6864beaaafb149@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: rientjes@google.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, serue@us.ibm.com, clg@fr.ibm.com, linux-kernel@vger.kernel.org, ebiederm@xmission.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

Paul M wrote:
>
> What's wrong with:
> 
>   allocate a page of task_struct pointers
> again:
>   need_repeat = false;
>   cgroup_iter_start();
>   while (cgroup_iter_next()) {
>     if (p->cpus_allowed != new_cpumask) {
>       store p;
>       if (page is full) {
>         need_repeat = true;
>         break;
>       }
>     }
>   }
>   for each saved task p {
>     set_cpus_allowed(p, new_cpumask);
>     release p;
>   }
>   if (need_repeat)
>     goto again;

That might work ... nice idea there, comparing the two masks, so one
only needs to store the ones not yet fixed.  Uunfortunately, I need to
put this aside until I return in four days, from a short trip.

Given that cgroups is targeted for 2.6.24, and that cpusets is broken
without this, I'll have to do something soon.  But this, or some such,
should work, soon enough.

Thanks.

> I'd much rather not perpetuate that broken API requirement. The fact
> that cpusets wants this odd behaviour is based on a nasty hack.

Well ... yeah ... it's a bit of an ugly child.  But I'm its daddy.
The kid looks fine in my eyes. <grin>

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
