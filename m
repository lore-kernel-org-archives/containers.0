From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm] CPU controller statistics (v5)
Date: Wed, 11 Jun 2008 14:10:28 +0530
Message-ID: <484F8F7C.8040009@linux.vnet.ibm.com>
References: <20080603200515.GA25753@balbir.in.ibm.com> <6599ad830806110132j1b3f899bx57fd3c894fd0c1c6@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756865AbYFKIk5@vger.kernel.org>
In-Reply-To: <6599ad830806110132j1b3f899bx57fd3c894fd0c1c6@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Balaji Rao <balajirrao@gmail.com>, containers@lists.osdl.org, vatsa@linux.vnet.ibm.com, a.p.zijlstra@chello.nl
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Tue, Jun 3, 2008 at 1:05 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
>> index e155aa7..60a25cb 100644
>> --- a/include/linux/cgroup.h
>> +++ b/include/linux/cgroup.h
>> @@ -293,6 +293,7 @@ int cgroup_is_descendant(const struct cgroup *cgrp);
>>  struct cgroup_subsys {
>>        struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
>>                                                  struct cgroup *cgrp);
>> +       void (*initialize)(int early);
>>        void (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
>>        void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
>>        int (*can_attach)(struct cgroup_subsys *ss,
>> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
>> index 15ac0e1..77569d7 100644
>> --- a/kernel/cgroup.c
>> +++ b/kernel/cgroup.c
>> @@ -2553,6 +2553,9 @@ int __init cgroup_init_early(void)
>>
>>                if (ss->early_init)
>>                        cgroup_init_subsys(ss);
>> +
>> +               if (ss->initialize)
>> +                       ss->initialize(1);
>>        }
>>        return 0;
>>  }
>> @@ -2577,6 +2580,9 @@ int __init cgroup_init(void)
>>                struct cgroup_subsys *ss = subsys[i];
>>                if (!ss->early_init)
>>                        cgroup_init_subsys(ss);
>> +
>> +               if (ss->initialize)
>> +                       ss->initialize(0);
>>        }
> 
> This seems a little weird - even if the subsystem didn't want early
> initialization, we call its initialize() during early setup?
> 
> I assume the idea is to move away from the current model where the
> subsystem is expected to initialize itself during the first call to
> its create() method, when it gets passed a cgroup with a NULL parent?
> I agree that was a bit icky. How about we call ss->initialize() from
> cgroup_init_subsys()? Then we wouldn't need the "early" parameter,
> since it would be implicit based on whether the subsystem wanted early
> initialization or not.
> 

The motivation was to ensure that kmalloc* calls are available at the time of
ss_initialize

> Also, if you're adding a new subsystem method, you should document it
> in Documentation/cgroups.txt

Thanks for the comments. There were some more things that are wrong with this
patch and Andrew pointed them out. We'll work on a newer vesion.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
