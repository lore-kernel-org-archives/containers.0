From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][-mm PATCH 2/8] Memory controller containers setup (v3)
Date: Sat, 21 Jul 2007 22:34:01 +0530
Message-ID: <46A23C81.8040300@linux.vnet.ibm.com>
References: <20070720082352.20752.37209.sendpatchset@balbir-laptop> <20070720082416.20752.92946.sendpatchset@balbir-laptop> <6599ad830707201330t419458f2tba2d7a31d3b9701e@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759075AbXGUREY@vger.kernel.org>
In-Reply-To: <6599ad830707201330t419458f2tba2d7a31d3b9701e@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Linux MM Mailing List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Dave Hansen <haveblue@us.ibm.com>, Eric W Biederman <ebiederm@xmission.com>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On 7/20/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>> +config CONTAINER_MEM_CONT
>> +       bool "Memory controller for containers"
>> +       select CONTAINERS
> 
> Andrew asked me to not use "select" in Kconfig files due to some
> unspecified problems seen in the past, so my latest patchset makes the
> subsystems depend on containers rather than selecting them; I prefer
> the select approach over the dependency approach, but if select does
> have problems then we should be consistent.
> 

I'll change it to depends

>> +static struct cftype mem_container_usage = {
>> +       .name = "mem_usage",
>> +       .private = RES_USAGE,
> 
> For V11, the .name field should just be called something like 'usage';
> the subsystem name is automatically prefixed.
> 

Will change

>> +
>> +static int mem_container_create(struct container_subsys *ss,
>> +                               struct container *cont)
>> +{
>> +       struct mem_container *mem;
>> +
>> +       mem = kzalloc(sizeof(struct mem_container), GFP_KERNEL);
>> +       if (!mem)
>> +               return -ENOMEM;
>> +
>> +       res_counter_init(&mem->res);
>> +       cont->subsys[mem_container_subsys_id] = &mem->css;
>> +       mem->css.container = cont;
>> +       return 0;
> 
> For the V11 patchset, you'll want to replace these three lines with just
> 
>  return &mem->css;
> 

Will do

>> +static int mem_container_populate(struct container_subsys *ss,
>> +                               struct container *cont)
>> +{
>> +       int rc = 0;
>> +
>> +       rc = container_add_file(cont, &mem_container_usage);
>> +       if (rc < 0)
>> +               goto err;
>> +
>> +       rc = container_add_file(cont, &mem_container_limit);
>> +       if (rc < 0)
>> +               goto err;
>> +
>> +       rc = container_add_file(cont, &mem_container_failcnt);
>> +       if (rc < 0)
>> +               goto err;
> 
> There's a container_add_files() API in V10 and above that lets you
> register an array of files in one go.
> 

Cool! I'll migrate to that.

>> +
>> +err:
>> +       return rc;
>> +}
>> +
>> +struct container_subsys mem_container_subsys = {
>> +       .name = "mem_container",
> 
> Maybe just "memory" or "pages" for the container name?
> 

Traditionally names like memory_control have been used to
indicate the purpose of the controller. I understand that
container is an overloaded term, so I guess memory might
a be better name.

> Paul


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
