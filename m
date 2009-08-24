From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [lxc-devel] Memory Resources
Date: Mon, 24 Aug 2009 13:13:15 +0200
Message-ID: <4A9275CB.7030108@free.fr>
References: <ac1c4bf20908230513q383fb338ne02e8f19f6ef18a6@mail.gmail.com>	
	<4A91ADE1.9090204@free.fr>	
	<ac1c4bf20908231758i13fef75p6f8a0fd7a4a425ec@mail.gmail.com>	
	<4A924D11.80002@free.fr>	
	<ac1c4bf20908240125q1e126cdq2d2b7659ca167d52@mail.gmail.com>	
	<4A924F5C.1000208@fr.ibm.com>	
	<ac1c4bf20908240138l67cfabfcid2bb7224a1f6ab24@mail.gmail.com>	
	<4A925794.7050808@free.fr>	
	<ac1c4bf20908240245ydbc1b9bxacfcf2398049505c@mail.gmail.com>	
	<4A92676A.1080609@free.fr>
	<ac1c4bf20908240327u424bd021t8848cf1cafb24ada@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ac1c4bf20908240327u424bd021t8848cf1cafb24ada-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Krzysztof Taraszka wrote:
> 2009/8/24 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>
>   
>> Krzysztof Taraszka wrote:
>>
>>     
>>> 2009/8/24 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>>>
>>>
>>>
>>>       
>>>> Krzysztof Taraszka wrote:
>>>>
>>>>
>>>>
>>>>         
>>>>> 2009/8/24 Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
>>>>>
>>>>>
>>>>>
>>>>>
>>>>>
>>>>>           
>>>>>> Krzysztof Taraszka wrote:
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>>             
>>>>>>> 2009/8/24 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>>>>>>>
>>>>>>>  Krzysztof Taraszka wrote:
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>               
>>>>>>>>  2009/8/23 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>                 
>>>>>>>>> (...)
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>  With the lxc tools I did:
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>                   
>>>>>>>>>>    lxc-execute -n foo /bin/bash
>>>>>>>>>>    echo 268435456 > /cgroup/foo/memory.limit_in_bytes
>>>>>>>>>>    mount --bind /cgroup/foo/memory.meminfo /proc/meminfo
>>>>>>>>>>    for i in $(seq 1 100); do sleep 3600 & done
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>                     
>>>>>>>>> (...)
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>  :)
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>                   
>>>>>>>>>>  hmmm... I think that access to the cgroup inside container is very
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>                     
>>>>>>>>> risk
>>>>>>>>> because I am able to manage for example memory resources (what if I
>>>>>>>>> am
>>>>>>>>> not
>>>>>>>>> the host owner and... I can give me via non-secure mounted /cgroup
>>>>>>>>> (inside
>>>>>>>>> container) all available memory resources...).
>>>>>>>>> I think that the /proc/meminfo should be pass to the container in
>>>>>>>>> the
>>>>>>>>> other
>>>>>>>>> way, but this is the topic for the other thread.
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>  It is not a problem, I did it in this way because it's easy to test
>>>>>>>>> but
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>                   
>>>>>>>> in
>>>>>>>> a real use case, the memory limit is setup by the lxc configuration
>>>>>>>> file
>>>>>>>> and
>>>>>>>> the cgroup directory will be no longer accessible from the container.
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>                 
>>>>>>> So.. how there will be another method (more secure) for giving
>>>>>>> /proc/meminfo
>>>>>>> with limits to the container, right?
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>               
>>>>>> Same method. The lxc tools can be configured with a fstab to mount more
>>>>>> mount points, furthermore if memory.meminfo is available I will add the
>>>>>> code
>>>>>> to mount it automatically to /proc/meminfo in the lxc tools.
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>>             
>>>>> Hmm... setup_fs() from lxc_init.c or another way?
>>>>>
>>>>>
>>>>>
>>>>>
>>>>>           
>>>> No, I was thinking in the setup_cgroup() function in conf.c.
>>>>
>>>> Something like:
>>>>
>>>> ...
>>>>
>>>> if (!access("/var/lib/lxc/mycontainer/nsgroup/memory.meminfo"), F_OK) {
>>>>  mount("/var/lib/lxc/mycontainer/nsgroup/memory.meminfo",
>>>> "/proc/meminfo",
>>>> MS_BIND, ...);
>>>> }
>>>>
>>>> ...
>>>>
>>>>
>>>> but a bit more clean :)
>>>>
>>>>
>>>>
>>>>         
>>> hmm... ok, got it, but don't know why does it won't work ;)
>>>
>>> @@ -999,12 +999,14 @@
>>>  static int setup_cgroup(const char *name)
>>>  {
>>>     char filename[MAXPATHLEN];
>>> +    char meminfofilename[MAXPATHLEN];
>>>     char line[MAXPATHLEN];
>>>     struct stat s;
>>>     int ret;
>>>
>>>     snprintf(filename, MAXPATHLEN, LXCPATH "/%s/cgroup", name);
>>> -
>>> +    snprintf(meminfofilename, MAXPATHLEN, LXCPATH
>>> "/%s/nsgroup/memory.meminfo", name);
>>> +
>>>     if (stat(filename, &s)) {
>>>         SYSERROR("failed to stat '%s'", filename);
>>>         return -1;
>>> @@ -1024,6 +1026,10 @@
>>>
>>>     INFO("cgroup has been setup");
>>>
>>> +    /* mount memory.meminfo as /proc/meminfo */
>>> +    if (!access(meminfofilename, F_OK)) {
>>> +        mount(meminfofilename, "/proc/meminfo", "none", MS_BIND, 0);
>>> +     }
>>>     return 0;
>>>  }
>>>
>>>
>>> hmm... any idea Daniel? :)
>>>
>>>
>>>       
>> Yep, can you check the return code of the mount call and return an error ?
>> if (mount(....)) {
>>   SYSERROR("failed to mount '%s' to '/proc/meminfo'", meminfofilename);
>>   return -1;
>> }
>> at least to verify if this does not fail.
>> and maybe add an INFO trace if the mount is successful saying
>> "/proc/meminfo" is setup with the cgroup.
>>
>> ps : you should launch the command with the "-l INFO" to see the message.
>>
>>     
>
>
>
>
> Hmmm....
> i think that I know where the problem might be:
>
> look here:
>
> lxc1:~# cat debin.log
>       lxc-start 1251109397.922 INFO     lxc_conf - tty's configured
>       lxc-start 1251109397.922 INFO     lxc_start - 'debian' is initialized
>       lxc-start 1251109397.974 INFO     lxc_conf - 'debian' hostname has
> been setup
>       lxc-start 1251109397.975 INFO     lxc_conf - network has been setup
>       lxc-start 1251109397.976 INFO     lxc_conf - cgroup has been setup
>       lxc-start 1251109397.976 INFO     lxc_conf - /proc/meminfo is setup
> with the cgroup
>       lxc-start 1251109397.976 INFO     lxc_conf - mount points have been
> setup
>       lxc-start 1251109397.976 INFO     lxc_conf - console '/dev/pts/1'
> mounted to '/usr/local/var/lib/lxc/debian/rootfs/dev/console'
>       lxc-start 1251109397.977 INFO     lxc_conf - 4 tty(s) has been setup
>       lxc-start 1251109397.977 INFO     lxc_conf - chrooted to
> '/usr/local/var/lib/lxc/debian/rootfs'
>       lxc-start 1251109397.977 INFO     lxc_conf - created new pts instance
>       lxc-start 1251109397.977 NOTICE   lxc_conf - 'debian' is setup.
>       lxc-start 1251109397.977 NOTICE   lxc_start - exec'ing '/sbin/init'
>       lxc-start 1251109397.978 NOTICE   lxc_start - '/sbin/init' started
> with pid '24339'
>
> i think that /proc/meminfo should be mounted after /proc . why? i think
> that, because mounting /proc may override /proc/meminfo
> Am I right? :)
>   
Ha ! haha ! arrgh ! no way ! You are right :/

In the case of application container, lxc mounts /proc but in the case 
of system container it is the system who do that so after the 
/proc/meminfo has been mounted.

Maybe we can look at modifying fs/proc/meminfo.c instead. Let me do a 
small patch for the kernel...
