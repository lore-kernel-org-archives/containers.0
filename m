From: Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
Subject: Re: [lxc-devel] Memory Resources
Date: Mon, 24 Aug 2009 18:26:50 +0200
Message-ID: <ac1c4bf20908240926j401003dft11f50d3be1466f90@mail.gmail.com>
References: <ac1c4bf20908230513q383fb338ne02e8f19f6ef18a6@mail.gmail.com>
	<4A924F5C.1000208@fr.ibm.com>
	<ac1c4bf20908240138l67cfabfcid2bb7224a1f6ab24@mail.gmail.com>
	<4A925794.7050808@free.fr>
	<ac1c4bf20908240245ydbc1b9bxacfcf2398049505c@mail.gmail.com>
	<4A92676A.1080609@free.fr>
	<ac1c4bf20908240327u424bd021t8848cf1cafb24ada@mail.gmail.com>
	<4A9275CB.7030108@free.fr>
	<ac1c4bf20908240431p1fda5a15qd26629618397696@mail.gmail.com>
	<4A929F83.80207@free.fr>
Reply-To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A929F83.80207-GANU6spQydw@public.gmane.org>
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

2009/8/24 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

>
>
> [ snip ]
>
>>  i think that /proc/meminfo should be mounted after /proc . why? i think
>>>> that, because mounting /proc may override /proc/meminfo
>>>> Am I right? :)
>>>>
>>>>
>>>>
>>>>
>>> Ha ! haha ! arrgh ! no way ! You are right :/
>>>
>>>
>>>
>>
>> Hehe ;)
>>
>>
>>
>>> In the case of application container, lxc mounts /proc but in the case of
>>> system container it is the system who do that so after the /proc/meminfo
>>> has
>>> been mounted.
>>>
>>> Maybe we can look at modifying fs/proc/meminfo.c instead. Let me do a
>>> small
>>> patch for the kernel...
>>>
>>>
>>>
>>>
>> Okey. I am waiting for your patch :)
>>
>
> Quick and dirty patch but at least working. It is no synced on the latest
> kernel version.
> I do not really like to touch fs/proc/meminfo.c but it's an example here.
>


Hi Daniel,

I tried to compile my kernel tree (2.6.30.5) with your patch using gcc-4.4,
gcc-4.3 and gcc-4.2 and i got this error on every gcc when linking kernel:

mm/built-in.o: In function `mem_cgroup_info':
(.text+0x27651): undefined reference to `__udivdi3'
mm/built-in.o: In function `mem_cgroup_info':
(.text+0x27678): undefined reference to `__udivdi3'
mm/built-in.o: In function `mem_cgroup_info':
(.text+0x276b0): undefined reference to `__udivdi3'
mm/built-in.o: In function `mem_cgroup_info':
(.text+0x276dd): undefined reference to `__udivdi3'
make: *** [.tmp_vmlinux1] Error 1

this can be gcc based error. What kernel and gcc did you use for compile
your kernel?

-- 
Krzysztof Taraszka
