From: Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
Subject: Re: [lxc-devel] Memory Resources
Date: Mon, 24 Aug 2009 21:22:04 +0200
Message-ID: <ac1c4bf20908241222w127f9f7em5175213281491a8d@mail.gmail.com>
References: <ac1c4bf20908230513q383fb338ne02e8f19f6ef18a6@mail.gmail.com>
	<ac1c4bf20908240245ydbc1b9bxacfcf2398049505c@mail.gmail.com>
	<4A92676A.1080609@free.fr>
	<ac1c4bf20908240327u424bd021t8848cf1cafb24ada@mail.gmail.com>
	<4A9275CB.7030108@free.fr>
	<ac1c4bf20908240431p1fda5a15qd26629618397696@mail.gmail.com>
	<4A929F83.80207@free.fr>
	<ac1c4bf20908240926j401003dft11f50d3be1466f90@mail.gmail.com>
	<4A92C01E.5010809@free.fr>
	<ac1c4bf20908240936t1bee38e3h9388298f435f056c@mail.gmail.com>
Reply-To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ac1c4bf20908240936t1bee38e3h9388298f435f056c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

2009/8/24 Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>

> 2009/8/24 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>
>> Krzysztof Taraszka wrote:
>>
>>> 2009/8/24 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>>>
>>>
>>>> [ snip ]
>>>>
>>>>   i think that /proc/meminfo should be mounted after /proc . why? i
>>>>> think
>>>>>
>>>>>> that, because mounting /proc may override /proc/meminfo
>>>>>>> Am I right? :)
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>  Ha ! haha ! arrgh ! no way ! You are right :/
>>>>>>
>>>>>>
>>>>>>
>>>>>>  Hehe ;)
>>>>>
>>>>>
>>>>>
>>>>>  In the case of application container, lxc mounts /proc but in the case
>>>>>> of
>>>>>> system container it is the system who do that so after the
>>>>>> /proc/meminfo
>>>>>> has
>>>>>> been mounted.
>>>>>>
>>>>>> Maybe we can look at modifying fs/proc/meminfo.c instead. Let me do a
>>>>>> small
>>>>>> patch for the kernel...
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>>  Okey. I am waiting for your patch :)
>>>>>
>>>>>  Quick and dirty patch but at least working. It is no synced on the
>>>> latest
>>>> kernel version.
>>>> I do not really like to touch fs/proc/meminfo.c but it's an example
>>>> here.
>>>>
>>>>
>>>
>>> Hi Daniel,
>>>
>>> I tried to compile my kernel tree (2.6.30.5) with your patch using
>>> gcc-4.4,
>>> gcc-4.3 and gcc-4.2 and i got this error on every gcc when linking
>>> kernel:
>>>
>>> mm/built-in.o: In function `mem_cgroup_info':
>>> (.text+0x27651): undefined reference to `__udivdi3'
>>> mm/built-in.o: In function `mem_cgroup_info':
>>> (.text+0x27678): undefined reference to `__udivdi3'
>>> mm/built-in.o: In function `mem_cgroup_info':
>>> (.text+0x276b0): undefined reference to `__udivdi3'
>>> mm/built-in.o: In function `mem_cgroup_info':
>>> (.text+0x276dd): undefined reference to `__udivdi3'
>>> make: *** [.tmp_vmlinux1] Error 1
>>>
>>> this can be gcc based error. What kernel and gcc did you use for compile
>>> your kernel?
>>>
>>
>> I used a 2.6.30 kernel and
>> gcc (GCC) 4.3.0 20080428 (Red Hat 4.3.0-8)
>> Compiled on a x86_64 host.
>>
>> Do you have any warning at the compile time ?
>>
>>
> No, did not see any warnings when memcontrol.c or fs/meminfo.c was
> compiled.
> Anyway, I will try to build in on the stable (lenny) version of debian
> (right now I am working on unstable debian tree).
> That might be gcc from unstable problem.
>
> I will let you know what exactly problem is.
>
>
ok Daniel,

i found a problem. I am runnning my debian box under vmware 32bit box so
your patch can not be compiled propertly on the 32bit system, so I decided
to make a little change in your patch.
I used shift operation instead of div. in the asm/div64.h is macro do_div()
but using shift instead of div is easier that implementing do_div macro, so
here is a small patch:

--- memcontrol.c.orig    2009-08-24 21:19:36.000000000 +0200
+++ memcontrol.c    2009-08-24 21:20:37.000000000 +0200
@@ -1834,14 +1834,13 @@
         si_swapinfo(info);

     if (limit != LLONG_MAX) {
-        info->totalram = limit / info->mem_unit;
-        info->freeram = (limit - mystat.stat[MCS_RSS]) / info->mem_unit;
+        info->totalram = limit >> info->mem_unit;
+        info->freeram = (limit - mystat.stat[MCS_RSS]) >> info->mem_unit;
     }

     if (memsw_limit != LLONG_MAX) {
-        info->totalswap = memsw_limit / info->mem_unit;
-        info->freeswap = (memsw_limit - swap_in_u) / info->mem_unit;
-
+        info->totalswap = memsw_limit >> info->mem_unit;
+        info->freeswap = (memsw_limit - swap_in_u) >> info->mem_unit;
     }

     return 0;


I hope that simple change won't to break on your 64bit :)

-- 
Krzysztof Taraszka
dzimi-k0Z414SquRyhPH1hqNUYSQ@public.gmane.org
