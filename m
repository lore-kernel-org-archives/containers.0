From: Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
Subject: Re: [lxc-devel] Memory Resources
Date: Mon, 24 Aug 2009 12:58:21 +0200
Message-ID: <ac1c4bf20908240358g4c2942b9n37d76fc933ebe1eb@mail.gmail.com>
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
Reply-To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A92676A.1080609-GANU6spQydw@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

2009/8/24 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

> Krzysztof Taraszka wrote:
>
>> 2009/8/24 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>>
>>
>>
>>> Krzysztof Taraszka wrote:
>>>
>>>
>>>
>>>> 2009/8/24 Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
>>>>
>>>>
>>>>
>>>>
>>>>
>>>>> Krzysztof Taraszka wrote:
>>>>>
>>>>>
>>>>>
>>>>>
>>>>>
>>>>>> 2009/8/24 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>>>>>>
>>>>>>  Krzysztof Taraszka wrote:
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>>>  2009/8/23 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>> (...)
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>  With the lxc tools I did:
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>>    lxc-execute -n foo /bin/bash
>>>>>>>>>    echo 268435456 > /cgroup/foo/memory.limit_in_bytes
>>>>>>>>>    mount --bind /cgroup/foo/memory.meminfo /proc/meminfo
>>>>>>>>>    for i in $(seq 1 100); do sleep 3600 & done
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>> (...)
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>  :)
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>>  hmmm... I think that access to the cgroup inside container is very
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>> risk
>>>>>>>> because I am able to manage for example memory resources (what if I
>>>>>>>> am
>>>>>>>> not
>>>>>>>> the host owner and... I can give me via non-secure mounted /cgroup
>>>>>>>> (inside
>>>>>>>> container) all available memory resources...).
>>>>>>>> I think that the /proc/meminfo should be pass to the container in
>>>>>>>> the
>>>>>>>> other
>>>>>>>> way, but this is the topic for the other thread.
>>>>>>>>
>>>>>>>>
>>>>>>>>  It is not a problem, I did it in this way because it's easy to test
>>>>>>>> but
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>> in
>>>>>>> a real use case, the memory limit is setup by the lxc configuration
>>>>>>> file
>>>>>>> and
>>>>>>> the cgroup directory will be no longer accessible from the container.
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>> So.. how there will be another method (more secure) for giving
>>>>>> /proc/meminfo
>>>>>> with limits to the container, right?
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>> Same method. The lxc tools can be configured with a fstab to mount more
>>>>> mount points, furthermore if memory.meminfo is available I will add the
>>>>> code
>>>>> to mount it automatically to /proc/meminfo in the lxc tools.
>>>>>
>>>>>
>>>>>
>>>>>
>>>>>
>>>> Hmm... setup_fs() from lxc_init.c or another way?
>>>>
>>>>
>>>>
>>>>
>>> No, I was thinking in the setup_cgroup() function in conf.c.
>>>
>>> Something like:
>>>
>>> ...
>>>
>>> if (!access("/var/lib/lxc/mycontainer/nsgroup/memory.meminfo"), F_OK) {
>>>  mount("/var/lib/lxc/mycontainer/nsgroup/memory.meminfo",
>>> "/proc/meminfo",
>>> MS_BIND, ...);
>>> }
>>>
>>> ...
>>>
>>>
>>> but a bit more clean :)
>>>
>>>
>>>
>>
>>
>> hmm... ok, got it, but don't know why does it won't work ;)
>>
>> @@ -999,12 +999,14 @@
>>  static int setup_cgroup(const char *name)
>>  {
>>     char filename[MAXPATHLEN];
>> +    char meminfofilename[MAXPATHLEN];
>>     char line[MAXPATHLEN];
>>     struct stat s;
>>     int ret;
>>
>>     snprintf(filename, MAXPATHLEN, LXCPATH "/%s/cgroup", name);
>> -
>> +    snprintf(meminfofilename, MAXPATHLEN, LXCPATH
>> "/%s/nsgroup/memory.meminfo", name);
>> +
>>     if (stat(filename, &s)) {
>>         SYSERROR("failed to stat '%s'", filename);
>>         return -1;
>> @@ -1024,6 +1026,10 @@
>>
>>     INFO("cgroup has been setup");
>>
>> +    /* mount memory.meminfo as /proc/meminfo */
>> +    if (!access(meminfofilename, F_OK)) {
>> +        mount(meminfofilename, "/proc/meminfo", "none", MS_BIND, 0);
>> +     }
>>     return 0;
>>  }
>>
>>
>> hmm... any idea Daniel? :)
>>
>>
> Yep, can you check the return code of the mount call and return an error ?
> if (mount(....)) {
>   SYSERROR("failed to mount '%s' to '/proc/meminfo'", meminfofilename);
>   return -1;
> }
> at least to verify if this does not fail.
> and maybe add an INFO trace if the mount is successful saying
> "/proc/meminfo" is setup with the cgroup.
>
> ps : you should launch the command with the "-l INFO" to see the message.
>


Weird. I made a test and move the mount the /proc/meminfo to the
setup_console() and it did not take effect. mount() did not fail (there were
no failed log).
Why I moved this part of code? Well.. I was wonder that what was happend if
I mount /proc/meminfo after the setup_mount() to override /proc/meminfo.
Don't have idea what can I do next ;) Daniel?

-- 
Krzysztof Taraszka
