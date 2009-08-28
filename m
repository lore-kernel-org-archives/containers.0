From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [lxc-devel] Memory Resources
Date: Fri, 28 Aug 2009 11:32:56 +0200
Message-ID: <4A97A448.5050506@free.fr>
References: <ac1c4bf20908230513q383fb338ne02e8f19f6ef18a6@mail.gmail.com>	
	<ac1c4bf20908240245ydbc1b9bxacfcf2398049505c@mail.gmail.com>	
	<4A92676A.1080609@free.fr>	
	<ac1c4bf20908240327u424bd021t8848cf1cafb24ada@mail.gmail.com>	
	<4A9275CB.7030108@free.fr>	
	<ac1c4bf20908240431p1fda5a15qd26629618397696@mail.gmail.com>	
	<4A929F83.80207@free.fr>	
	<20090826104312.97ff028f.kamezawa.hiroyu@jp.fujitsu.com>	
	<4A952689.9020704@free.fr>	
	<ac1c4bf20908260650x3311d5d3q44631a30205089b7@mail.gmail.com>
	<ac1c4bf20908261625g71dff96cu77190056540cbb7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ac1c4bf20908261625g71dff96cu77190056540cbb7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Krzysztof Taraszka wrote:
> 2009/8/26 Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
>
>   
>> 2009/8/26 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>>
>>     
>>> KAMEZAWA Hiroyuki wrote:
>>>
>>>       
>>>> On Mon, 24 Aug 2009 16:11:15 +0200
>>>> Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:
>>>>
>>>>
>>>>
>>>>         
>>>>> [ snip ]
>>>>>
>>>>>
>>>>>           
>>>>>>  i think that /proc/meminfo should be mounted after /proc . why? i
>>>>>>             
>>>>>>>> think
>>>>>>>> that, because mounting /proc may override /proc/meminfo
>>>>>>>> Am I right? :)
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>                 
>>>>>>> Ha ! haha ! arrgh ! no way ! You are right :/
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>               
>>>>>> Hehe ;)
>>>>>>
>>>>>>
>>>>>>
>>>>>>             
>>>>>>> In the case of application container, lxc mounts /proc but in the case
>>>>>>> of
>>>>>>> system container it is the system who do that so after the
>>>>>>> /proc/meminfo has
>>>>>>> been mounted.
>>>>>>>
>>>>>>> Maybe we can look at modifying fs/proc/meminfo.c instead. Let me do a
>>>>>>> small
>>>>>>> patch for the kernel...
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>               
>>>>>> Okey. I am waiting for your patch :)
>>>>>>
>>>>>>
>>>>>>             
>>>>> Quick and dirty patch but at least working. It is no synced on the
>>>>> latest kernel version.
>>>>> I do not really like to touch fs/proc/meminfo.c but it's an example
>>>>> here.
>>>>>
>>>>>
>>>>>
>>>>>           
>>>> I'll strongly Nack to this.
>>>> plz find a way to ln -s /path_to_cgroup/memory.meminfo
>>>> /mycontainer/meminfo
>>>>
>>>>
>>>>         
>>> Yep, I agree with you, I don't like this approach.
>>>
>>> We are trying to solve the problem of the userspace tools which look at
>>> the /proc/meminfo file to display memory informations. That looks weird to
>>> set a max memory usage of 256MB via the cgroup and having the 'free' command
>>> showing 4GB of total memory. More than looking weird, Dietmar explained that
>>> can puzzle applications relying on these informations for taking some
>>> decisions.
>>>
>>> If we consider having /cgroup/mycontainer/memory.meminfo with memory
>>> information in the same format than /proc/meminfo, that solves partially the
>>> problem:
>>> - we run an application container, the application won't mount /proc so
>>> the lxc tools do that for the application (at least to isolate the pids
>>> information), it is easy to mount --bind /cgroup/mycontainer/memory.meminfo
>>> to /proc/meminfo before the application takes the control, that is to say
>>> before 'exec'. Tested and verified with the memory tools (free, top, etc
>>> ...)
>>>
>>> - we run a system container, we can do this mount-bind but when the
>>> application, aka /sbin/init, takes the control, the /proc is mounted by the
>>> system services, so we lose the /proc/meminfo we previously set. Hence
>>> meminfo in the cgroup directory does not solve the problem for this use
>>> case.
>>>
>>> Any ideas ?
>>>
>>>
>>>       
>> If I may... I have been thinking about that last few days and... I think
>> that mounting /proc/meminfo can be done with mounted cgrop and secured by
>> SMACK64.
>> I will test it tonight and give you raport how does it works for me.
>>
>>
>>     
>
> Okey.
> I made few tests and this two ways work:
>
> First way:
> =======
> lxc. smack enabled, policy loaded. cgroup not labeled.
>
> a) start container
> b) mount cgroup inside container
> c) mount --bind /cgroup/foo/memory.meminfo /proc/meminfo
> d) secure the /cgroup on the host (ie: attr -S -s SMACK64 -V host /cgroup).
>
> this step can be done inside lxc tools ;)
>
> Second way:
> ==========
> lxc. smack enabled, policy loaded. cgroup not labeled.
>
> a) do not label whole /cgrop directory (DO NOT DO: attr -S -s SMACK64 -V
> host /cgroup). Label dedicate files only (for example: /cgroup/cpuset.cpus,
> /cgroup/vs1/cpuset.cpus, etc). Do not label the /cgrop/vs1 directory. Label
> with vs1 label only /cgroup/vs1/memory.meminfo. All other files label with
> host label to do not allow read them.
> b) start container
> c) mount cgroup inside container
> d) mount --bind /cgroup/foo/memory.meminfo /proc/meminfo
>
> steps: b, c, d can be done inside lxc tools. step a can't and it is base on
> the admin policy.
>
> I think that the first solution is more automatic and can be done by lxc
> tools (maybe command line switch? I can prepare a patch for that.
>   

I do not know smack, what does smack here ? Will this solution avoid the 
container to overwrite /proc/meminfo by remounting /proc ?
