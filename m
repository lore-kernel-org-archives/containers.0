From: Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
Subject: Re: [lxc-devel] Memory Resources
Date: Sun, 23 Aug 2009 21:22:23 +0200
Message-ID: <ac1c4bf20908231222t182e6ca6u716b98e13d85cbad@mail.gmail.com>
References: <ac1c4bf20908230513q383fb338ne02e8f19f6ef18a6@mail.gmail.com>
	<4A916BC9.8040905@free.fr>
	<ac1c4bf20908230959j4cda58cel3bcf4f3822d50bb1@mail.gmail.com>
	<4A9183B2.7090005@free.fr>
	<ac1c4bf20908231117sb180e78q3eed64db3573ec35@mail.gmail.com>
	<ac1c4bf20908231138j2ce7bb48v69a8ac8ede6bc314@mail.gmail.com>
Reply-To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ac1c4bf20908231138j2ce7bb48v69a8ac8ede6bc314-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

2009/8/23 Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>

> 2009/8/23 Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
>
>>
>>
>> 2009/8/23 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>>
>>> Krzysztof Taraszka wrote:
>>>
>>>> 2009/8/23 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>>>>
>>>>  Krzysztof Taraszka wrote:
>>>>>
>>>>>  Hello,
>>>>>>
>>>>>> I am running lxc on my debian unstable sandbox and I have a few
>>>>>> question
>>>>>> about memory managament inside linux containers based on lxc project.
>>>>>>
>>>>>> I have got linux kernel 2.6.30.5 with enabled :
>>>>>>
>>>>>> +Resource counter
>>>>>> ++ Memory Resource Controller for Control Groups
>>>>>>  +++ Memory Resource Controller Swap Extension(EXPERIMENTAL)
>>>>>>
>>>>>> lxc-checkconfig pass all checks.
>>>>>>
>>>>>> I read about cgroups memory managament
>>>>>> (Documentation/cgroups/memory.txt)
>>>>>> and I tried to pass those value to my debian sandbox.
>>>>>>
>>>>>> And...
>>>>>> 'free -m' and 'top/htop' still show all available memory inside
>>>>>> container
>>>>>> (also If I set 32M for lxc.cgroup.memory.limit_in_bytes and
>>>>>> lxc.cgroup.memory.usage_in_bytes; and 64M for
>>>>>> lxc.cgroup.memory.memsw.usage_in_bytes and
>>>>>> lxc.cgroup.memory.memsw.limit_in_bytes free and top show all
>>>>>> resources).
>>>>>>
>>>>>> What I did wrong? Does the container always show all available memory
>>>>>> resources  without cgroup limitations?
>>>>>>
>>>>>>  At the first glance I would say the configuration is correct.
>>>>> But AFAIR, the memory cgroup is not isolated, if you specify 32MB you
>>>>> will
>>>>> see all the memory available on the system either if you are not
>>>>> allowed to
>>>>> use more than 32MB. If you create a program which allocates 64MB within
>>>>> a
>>>>> container configured with 32MB, and you "touch" the pages (may be that
>>>>> can
>>>>> be done with one mmap call with the MAP_POPULATE option), you should
>>>>> see the
>>>>> application swapping and the "memory.failcnt" increasing.
>>>>>
>>>>> IMHO, showing all the memory available for the system instead of
>>>>> showing
>>>>> the allowed memory with the cgroup is weird but maybe there is a good
>>>>> reason
>>>>> to do that.
>>>>>
>>>>>
>>>>>
>>>> Thank you Daniel for your reply.
>>>> I think that LXC should isolate memory available for containers like
>>>> Vserver
>>>> or FreeVPS do (memory + swap) if .cgroup.memory.* and
>>>> lxc.cgroup.memory.memsw.* is set.
>>>> Is there any possibility to make a patch for linux kernel / lxc-tools to
>>>> show the limitations inside cointainers propertly? I think is a good
>>>> idea
>>>> and it should be apply as soon as possible.
>>>>
>>>
>>> Maybe a solution can be to add a new memory.meminfo file in the same
>>> format than /proc/meminfo, so it will be possible to mount --bind
>>> /cgroup/foo/memory.meminfo to /proc/meminfo for the container.
>>>
>>
>> Yes, I thought the same. This should allow the user-space tools based on
>> /proc/meminfo (such as comand line "free") show limited information :)
>>
>
> Hmmm... does the memory.stat is a good start point for make new one object
> memory.meminfo similar to /proc/meminfo? If so, I can play by my self with
> lxc-tools code.
>


Hmmm... Daniel, I have got a question (that do I thinking in the right way).
here is an output from /proc/meminfo from openvz:


MemTotal:             262144 kB
MemFree:            232560 kB
Buffers:             0 kB
Cached:            0 kB
SwapCached:        0 kB
Active:            0 kB
Inactive:            0 kB
HighTotal:            0 kB
HighFree:            0 kB
LowTotal:             262144 kB
LowFree:            232560 kB
SwapTotal:        0 kB
SwapFree:        0 kB
Dirty:             0 kB
Writeback:        0 kB
AnonPages:        0 kB
Mapped:            0 kB
Slab:                0 kB
SReclaimable:            0 kB
SUnreclaim:              0 kB
PageTables:              0 kB
NFS_Unstable:           0 kB
Bounce:                  0 kB
WritebackTmp:            0 kB
CommitLimit:             0 kB
Committed_AS:            0 kB
VmallocTotal:            0 kB
VmallocUsed:             0 kB
VmallocChunk:            0 kB
HugePages_Total:    0
HugePages_Free:    0
HugePages_Rsvd:   0
HugePages_Surp:    0
Hugepagesize:         2048 kB

most of values are 0.

I have an question about SwapTotal and SwapFree for LXC.
As I thinking that:

MemTotal might be: hierarchical_memory_limit
MemFree might be: hierarchical_memory_limit - cache

the

SwapTotal might be: hierarchical_memsw_limit
SwapFree might be: hierarchical_memsw_limit - rss

rss - # of bytes of anonymous and swap cache memory
I don't know at all that hierarchical_memsw_limit is an good value for swap
total, because as I read it is a mem+swap at all.

Does the lxc memory.meminfo might look like above? Where can I get the
Hugepagesize?

-- 
Krzysztof Taraszka
