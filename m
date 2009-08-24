From: Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
Subject: Re: [lxc-devel] Memory Resources
Date: Mon, 24 Aug 2009 02:48:59 +0200
Message-ID: <ac1c4bf20908231748s26c2f18bv9aa931728826a85e@mail.gmail.com>
References: <ac1c4bf20908230513q383fb338ne02e8f19f6ef18a6@mail.gmail.com>
	<4A916BC9.8040905@free.fr>
	<ac1c4bf20908230959j4cda58cel3bcf4f3822d50bb1@mail.gmail.com>
	<4A9183B2.7090005@free.fr>
	<ac1c4bf20908231117sb180e78q3eed64db3573ec35@mail.gmail.com>
	<ac1c4bf20908231138j2ce7bb48v69a8ac8ede6bc314@mail.gmail.com>
	<ac1c4bf20908231222t182e6ca6u716b98e13d85cbad@mail.gmail.com>
	<4A91A103.6020207@free.fr>
	<ac1c4bf20908231318v1586c2ciffd3df5fe1b70c20@mail.gmail.com>
	<4A91ADE1.9090204@free.fr>
Reply-To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A91ADE1.9090204-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

I added the swap resource monitoring to your patch.
I did it in the very simple way, because if: memsw = swap + mem, then
swap_in_use == memsw.usage_in_bytes - memory.usage_in_bytes

simple patch:

+static int mem_cgroup_meminfo(struct cgroup *cgrp, struct cftype *cft,
+                              struct seq_file *seq)
+{
+#define K(x) ((x) << 10)
+
+       struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cgrp);
+       struct mcs_total_stat mystat = { };
+       unsigned long long limit, memsw_limit;
+
+       u64 swap_in_u, m_usage, s_usage;
+
+       s_usage = res_counter_read_u64(&mem_cont->memsw, RES_USAGE);
+       m_usage = res_counter_read_u64(&mem_cont->res, RES_USAGE);
+
+       swap_in_u = s_usage - m_usage;
+
+       mem_cgroup_get_local_stat(mem_cont, &mystat);
+       memcg_get_hierarchical_limit(mem_cont, &limit, &memsw_limit);
+
+       seq_printf(seq,
+                  "MemTotal:       %8llu kB\n"
+                  "MemFree:        %8llu kB\n"
+                  "SwapTotal:       %8llu kB\n"
+                  "SwapFree:       %8llu kB\n",
+                  limit / 1024, (limit - mystat.stat[MCS_RSS]) / 1024,
+                  memsw_limit / 1024, (memsw_limit - swap_in_u) / 1024);
+
+       return 0;
+#undef K
+}

 static struct cftype mem_cgroup_files[] = {
     {
@@ -2228,6 +2258,10 @@
         .name = "stat",
         .read_map = mem_control_stat_show,
     },
+        {
+               .name = "meminfo",
+               .read_seq_string = mem_cgroup_meminfo,
+        },
     {
         .name = "force_empty",
         .trigger = mem_cgroup_force_empty_write,

-- 
Krzysztof Taraszka

2009/8/23 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

> Krzysztof Taraszka wrote:
>
>> 2009/8/23 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>>
>>  Krzysztof Taraszka wrote:
>>>
>>>  2009/8/23 Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
>>>>
>>>>
>>>>
>>>>  2009/8/23 Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
>>>>>
>>>>>
>>>>>
>>>>>  2009/8/23 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>>>>>>
>>>>>>
>>>>>>
>>>>>>  Krzysztof Taraszka wrote:
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>  2009/8/23 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>>>>>>>>
>>>>>>>>  Krzysztof Taraszka wrote:
>>>>>>>>
>>>>>>>>
>>>>>>>>   Hello,
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>  I am running lxc on my debian unstable sandbox and I have a few
>>>>>>>>>> question
>>>>>>>>>> about memory managament inside linux containers based on lxc
>>>>>>>>>> project.
>>>>>>>>>>
>>>>>>>>>> I have got linux kernel 2.6.30.5 with enabled :
>>>>>>>>>>
>>>>>>>>>> +Resource counter
>>>>>>>>>> ++ Memory Resource Controller for Control Groups
>>>>>>>>>>  +++ Memory Resource Controller Swap Extension(EXPERIMENTAL)
>>>>>>>>>>
>>>>>>>>>> lxc-checkconfig pass all checks.
>>>>>>>>>>
>>>>>>>>>> I read about cgroups memory managament
>>>>>>>>>> (Documentation/cgroups/memory.txt)
>>>>>>>>>> and I tried to pass those value to my debian sandbox.
>>>>>>>>>>
>>>>>>>>>> And...
>>>>>>>>>> 'free -m' and 'top/htop' still show all available memory inside
>>>>>>>>>> container
>>>>>>>>>> (also If I set 32M for lxc.cgroup.memory.limit_in_bytes and
>>>>>>>>>> lxc.cgroup.memory.usage_in_bytes; and 64M for
>>>>>>>>>> lxc.cgroup.memory.memsw.usage_in_bytes and
>>>>>>>>>> lxc.cgroup.memory.memsw.limit_in_bytes free and top show all
>>>>>>>>>> resources).
>>>>>>>>>>
>>>>>>>>>> What I did wrong? Does the container always show all available
>>>>>>>>>> memory
>>>>>>>>>> resources  without cgroup limitations?
>>>>>>>>>>
>>>>>>>>>>  At the first glance I would say the configuration is correct.
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>  But AFAIR, the memory cgroup is not isolated, if you specify 32MB
>>>>>>>>> you
>>>>>>>>> will
>>>>>>>>> see all the memory available on the system either if you are not
>>>>>>>>> allowed to
>>>>>>>>> use more than 32MB. If you create a program which allocates 64MB
>>>>>>>>> within
>>>>>>>>> a
>>>>>>>>> container configured with 32MB, and you "touch" the pages (may be
>>>>>>>>> that
>>>>>>>>> can
>>>>>>>>> be done with one mmap call with the MAP_POPULATE option), you
>>>>>>>>> should
>>>>>>>>> see the
>>>>>>>>> application swapping and the "memory.failcnt" increasing.
>>>>>>>>>
>>>>>>>>> IMHO, showing all the memory available for the system instead of
>>>>>>>>> showing
>>>>>>>>> the allowed memory with the cgroup is weird but maybe there is a
>>>>>>>>> good
>>>>>>>>> reason
>>>>>>>>> to do that.
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>  Thank you Daniel for your reply.
>>>>>>>> I think that LXC should isolate memory available for containers like
>>>>>>>> Vserver
>>>>>>>> or FreeVPS do (memory + swap) if .cgroup.memory.* and
>>>>>>>> lxc.cgroup.memory.memsw.* is set.
>>>>>>>> Is there any possibility to make a patch for linux kernel /
>>>>>>>> lxc-tools
>>>>>>>> to
>>>>>>>> show the limitations inside cointainers propertly? I think is a good
>>>>>>>> idea
>>>>>>>> and it should be apply as soon as possible.
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>  Maybe a solution can be to add a new memory.meminfo file in the
>>>>>>> same
>>>>>>> format than /proc/meminfo, so it will be possible to mount --bind
>>>>>>> /cgroup/foo/memory.meminfo to /proc/meminfo for the container.
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>  Yes, I thought the same. This should allow the user-space tools
>>>>>> based on
>>>>>> /proc/meminfo (such as comand line "free") show limited information :)
>>>>>>
>>>>>>
>>>>>>
>>>>>>  Hmmm... does the memory.stat is a good start point for make new one
>>>>> object
>>>>> memory.meminfo similar to /proc/meminfo? If so, I can play by my self
>>>>> with
>>>>> lxc-tools code.
>>>>>
>>>>>
>>>>>
>>>>>
>>>> Hmmm... Daniel, I have got a question (that do I thinking in the right
>>>> way).
>>>> here is an output from /proc/meminfo from openvz:
>>>>
>>>>
>>>> MemTotal:             262144 kB
>>>> MemFree:            232560 kB
>>>> Buffers:             0 kB
>>>> Cached:            0 kB
>>>> SwapCached:        0 kB
>>>> Active:            0 kB
>>>> Inactive:            0 kB
>>>> HighTotal:            0 kB
>>>> HighFree:            0 kB
>>>> LowTotal:             262144 kB
>>>> LowFree:            232560 kB
>>>> SwapTotal:        0 kB
>>>> SwapFree:        0 kB
>>>> Dirty:             0 kB
>>>> Writeback:        0 kB
>>>> AnonPages:        0 kB
>>>> Mapped:            0 kB
>>>> Slab:                0 kB
>>>> SReclaimable:            0 kB
>>>> SUnreclaim:              0 kB
>>>> PageTables:              0 kB
>>>> NFS_Unstable:           0 kB
>>>> Bounce:                  0 kB
>>>> WritebackTmp:            0 kB
>>>> CommitLimit:             0 kB
>>>> Committed_AS:            0 kB
>>>> VmallocTotal:            0 kB
>>>> VmallocUsed:             0 kB
>>>> VmallocChunk:            0 kB
>>>> HugePages_Total:    0
>>>> HugePages_Free:    0
>>>> HugePages_Rsvd:   0
>>>> HugePages_Surp:    0
>>>> Hugepagesize:         2048 kB
>>>>
>>>> most of values are 0.
>>>>
>>>> I have an question about SwapTotal and SwapFree for LXC.
>>>> As I thinking that:
>>>>
>>>> MemTotal might be: hierarchical_memory_limit
>>>> MemFree might be: hierarchical_memory_limit - cache
>>>>
>>>>
>>>>  I am not a memory expert, but isn't MemFree : hierarchical_memory_limit
>>> -
>>> rss ?
>>>
>>>  the
>>>>
>>>> SwapTotal might be: hierarchical_memsw_limit
>>>> SwapFree might be: hierarchical_memsw_limit - rss
>>>>
>>>> rss - # of bytes of anonymous and swap cache memory
>>>> I don't know at all that hierarchical_memsw_limit is an good value for
>>>> swap
>>>> total, because as I read it is a mem+swap at all.
>>>>
>>>> Does the lxc memory.meminfo might look like above? Where can I get the
>>>> Hugepagesize?
>>>>
>>>>
>>>>  Right, I agree most of the interesting information to create a
>>> memory.meminfo is already there in another file and another format.
>>> Probably
>>> some informations in memory.stat can be moved to memory.meminfo and this
>>> one
>>> can be step by step filled with cgroup memory statistic informations.
>>> IMO,
>>> if the memory controller displays memory statistics like a proc/meminfo
>>> file
>>> format, that will make consistency for these informations and make
>>> trivial
>>> the isolation/virtualization with a simple mount-bind.
>>>
>>>
>>>
>>>  Hmm..
>> might be. Right now I am looking for and writing new function in
>> mm/memcontrol.c file for writing some stats in memory.meminfo file for
>> tests.
>> Dirty and ugly part of code, but if it will work as we thought
>> (mount-bind)
>> and as you wrote above, that will be very simple.
>> I am going to look how does the /proc/meminfo is doing by the openvz.
>> mm/memcontrol.c was wrote by xemul from openvz and balbir from ibm.
>> If I am thinking in the right way, guys from openvz made their own patch
>> for
>> meminfo based on the mm/memcontrol.c. If I am wrong - where do they taking
>> meminfo data? :)
>>
>
> I did this ugly patch patch for MemTotal/MemFree - maybe wrong :)
>
> Index: linux-2.6/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.orig/mm/memcontrol.c      2009-06-23 12:00:52.000000000 +0200
> +++ linux-2.6/mm/memcontrol.c   2009-08-23 22:49:02.000000000 +0200
> @@ -2200,6 +2200,27 @@ static int mem_cgroup_swappiness_write(s
>  }
>
>
> +static int mem_cgroup_meminfo(struct cgroup *cgrp, struct cftype *cft,
> +                             struct seq_file *seq)
> +{
> +#define K(x) ((x) << 10)
> +
> +       struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cgrp);
> +       struct mcs_total_stat mystat = { };
> +       unsigned long long limit, memsw_limit;
> +
> +       mem_cgroup_get_local_stat(mem_cont, &mystat);
> +       memcg_get_hierarchical_limit(mem_cont, &limit, &memsw_limit);
> +
> +       seq_printf(seq,
> +                  "MemTotal:       %8llu kB\n"
> +                  "MemFree:        %8llu kB\n",
> +                  limit / 1024, (limit - mystat.stat[MCS_RSS]) / 1024);
> +
> +       return 0;
> +#undef K
> +}
> +
>  static struct cftype mem_cgroup_files[] = {
>        {
>                .name = "usage_in_bytes",
> @@ -2242,6 +2263,10 @@ static struct cftype mem_cgroup_files[]
>                .read_u64 = mem_cgroup_swappiness_read,
>                .write_u64 = mem_cgroup_swappiness_write,
>        },
> +       {
> +               .name = "meminfo",
> +               .read_seq_string = mem_cgroup_meminfo,
> +       },
>  };
>
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>
>
> With the lxc tools I did:
>
>        lxc-execute -n foo /bin/bash
>        echo 268435456 > /cgroup/foo/memory.limit_in_bytes
>        mount --bind /cgroup/foo/memory.meminfo /proc/meminfo
>        for i in $(seq 1 100); do sleep 3600 & done
>
> And the result for "free" is:
>
> free:
>
>             total       used       free     shared    buffers     cached
> Mem:        262144       9692     252452          0          0          0
> -/+ buffers/cache:       9692     252452
> Swap:            0          0          0
>
>
> and for "top":
>
> top - 22:57:37 up 8 min,  1 user,  load average: 0.00, 0.02, 0.00
> Tasks: 104 total,   1 running, 103 sleeping,   0 stopped,   0 zombie
> Cpu(s):  0.3%us,  1.0%sy,  0.0%ni, 98.4%id,  0.0%wa,  0.0%hi,  0.3%si,
> 0.0%st
> Mem:    262144k total,     9864k used,   252280k free,        0k buffers
> Swap:        0k total,        0k used,        0k free,        0k cached
>
>  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
>  337 root      20   0 14748 1132  872 R  1.0  0.4   0:00.24 top
>    1 root      20   0  8136  484  408 S  0.0  0.2   0:00.00 lxc-init
>    2 root      20   0 89980 1724 1348 S  0.0  0.7   0:00.70 bash
>   25 root      20   0 86916  612  524 S  0.0  0.2   0:00.00 sleep
>  232 root      20   0 86916  616  524 S  0.0  0.2   0:00.00 sleep
>  233 root      20   0 86916  612  524 S  0.0  0.2   0:00.00 sleep
>  234 root      20   0 86916  612  524 S  0.0  0.2   0:00.00 sleep
>  235 root      20   0 86916  612  524 S  0.0  0.2   0:00.00 sleep
> .....
>
>
> :)
>
>
