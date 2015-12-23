From: Dongsheng Yang <yangds.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [Propose] Isolate core_pattern in mnt namespace.
Date: Wed, 23 Dec 2015 11:13:47 +0800
Message-ID: <567A116B.6050805__45734.6791321926$1450840905$gmane$org@cn.fujitsu.com>
References: <56729B3D.1040502@cn.fujitsu.com> <56760F05.3020308@cn.fujitsu.com>
	<20151220023712.GT20997@ZenIV.linux.org.uk>
	<567616D6.6060202@cn.fujitsu.com>
	<87fuyx1mfn.fsf@x220.int.ebiederm.org>
	<567798EC.1040304@cn.fujitsu.com>
	<87twnbzcz8.fsf@x220.int.ebiederm.org>
	<5678BFA3.9090608@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5678BFA3.9090608-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 12/22/2015 11:12 AM, Kamezawa Hiroyuki wrote:
> On 2015/12/22 6:52, Eric W. Biederman wrote:
>> Dongsheng Yang <yangds.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
>>
>>> On 12/20/2015 05:47 PM, Eric W. Biederman wrote:
>>>> Dongsheng Yang <yangds.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
>>>>
>>>>> On 12/20/2015 10:37 AM, Al Viro wrote:
>>>>>> On Sun, Dec 20, 2015 at 10:14:29AM +0800, Dongsheng Yang wrote:
>>>>>>> On 12/17/2015 07:23 PM, Dongsheng Yang wrote:
>>>>>>>> Hi guys,
>>>>>>>>         We are working on making core dump behaviour isolated in
>>>>>>>> container. But the problem is, the /proc/sys/kernel/core_pattern
>>>>>>>> is a kernel wide setting, not belongs to a container.
>>>>>>>>
>>>>>>>>         So we want to add core_pattern into mnt namespace. What
>>>>>>>> do you think about it?
>>>>>>>
>>>>>>> Hi Eric,
>>>>>>> 	I found your patch about "net: Implement the per network namespace
>>>>>>> sysctl infrastructure", I want to do the similar thing
>>>>>>> in mnt namespace. Is that suggested way?
>>>>>>
>>>>>> Why mnt namespace and not something else?
>>>>>
>>>>> Hi Al,
>>>>>
>>>>> Well, because core_pattern indicates the path to store core file.
>>>>> In different mnt namespace, we would like to change the path with
>>>>> different value.
>>>>>
>>>>> In addition, Let's considering other namespaces:
>>>>> UTS ns: contains informations of kernel and arch, not proper for core_pattern.
>>>>> IPC ns: communication informations, not proper for core_pattern
>>>>> PID ns: core_pattern is not related with pid
>>>>> net ns: obviousely no.
>>>>> user ns: not proper too.
>>>>>
>>>>> Then I believe it's better to do this in mnt namespace. of course,
>>>>> core_pattern is just one example. After this infrastructure finished,
>>>>> we can implement more sysctls as per-mnt if necessary, I think.
>>>>>
>>>>> Al, what do you think about this idea?
>>>>
>>>> The hard part is not the sysctl.  The hard part is starting the usermode
>>>> helper, in an environment that it can deal with.  The mount namespace
>>>> really provides you with no help there.
>>>
>>> Do you mean the core dump helper? But I think I don't want to touch it
>>> in my development. I think I can use non-pipe way to get what I want,
>>> Let me try to explain what I want here.
>>>
>>> (1). introduce a --core-path option in docker run command to specify the
>>> path in host to store core file in one container.
>>> E.g: docker run --core-path=/core/test --name=test IMAGE
>>>
>>> (2). When the container starting, docker attach a volume to it, similar
>>> with "-v /core/test:/var/lib/docker/coredump". That means, the path of
>>> /var/lib/docker/coredump in container is a link to /core/test in host.
>>>
>>> (3). Set the /proc/sys/kernel/core_pattern in container as
>>> "/var/lib/docker/coredump". But that should not affect the core_pattern
>>> in host or other containers.
>>>
>>> Then I think I can collect the core files from each container and save
>>> them in the paths where I want.
>>
>> For your case that sounds like it would work.  Unfortunately for this to
>> be generally applicable and to let the OS in the contianer control it's
>> fate the core dump pattern needs to be supported.
>>
>> Otherwise something clever in userspace that can be written now should
>> be sufficient to fill the gap.  There is enough information for the user
>> mode helper to implement the policy you would like today.
>>
> Let me clarify my understanding.
> 
> 1) running user-mode-helper in a container.
>     It's not supported by the kernel. user-mode-helper always works on a host.
> 
> 2) running user mode helper in a host.
>    It's supported in the newest distro(FC23). (abrt supports container.)
>    Summary is here. https://github.com/abrt/abrt/wiki/Containers-and-chroots
> 
> If a guest user doesn't want to pass a core to the host owner, core_pattern
> should be configurable but it can't.

Agreed, then we have to make the core_pattern namespace-ed in mnt
namespace.

Thanx
Yang
> 
> Thanks,
> -Kame
> 
> 
> 
> 
> .
> 
