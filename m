From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: cgroup information proc file format
Date: Thu, 11 Aug 2011 19:58:52 -0300
Message-ID: <4E445EAC.6030908@parallels.com>
References: <4E4441C3.5020603@free.fr> <4E4449F5.3010909@parallels.com>
	<4E444D96.7080206@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4E444D96.7080206-GANU6spQydw@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh1 <balbir.singh-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 08/11/2011 06:45 PM, Daniel Lezcano wrote:
> On 08/11/2011 11:30 PM, Glauber Costa wrote:
>> On 08/11/2011 05:55 PM, Daniel Lezcano wrote:
>>> Hi all,
>>>
>>> the cgroup cpuset and memory reduce access to a part of the resources on
>>> the system. Some applications use the /proc/cpuinfo and /proc/meminfo to
>>> allocate the resources. For instance, HPC jobs look at /proc/cpuinfo to
>>> fork the number of cpu found in this file either look at /proc/meminfo
>>> to allocate a big chunk of memory. Each process set the affinity on each
>>> cpu, which in case a subset of cpus is used, some affinity will fail.
>>>
>>> In the case of the container, the cgroup is used to reduce the memory or
>>> to assign a cpu to the container. Unfortunately, as this partitioning is
>>> not reflected in /proc, the different system tools (ps, top, free, ...)
>>> show a wrong information.
>>>
>>> I was wondering if that would make sense to create for the different
>>> cgroup subsystem, when it is relevant, a proc formatted file we can bind
>>> mount /proc.
>>>
>>> For example: /cgroup/memory.proc and /cgroup/cpuset.proc
>>
>> Not only that. user/sys/nice,etc statistics also are expected to be
>> different than the main system one, among other things.
>>
>> One way I was thinking of doing it, was to always show per-cgroup
>> data in /proc files when relevant, using the cgroup of the current
>> process as a base.
>
> That was proposed initially but refused. I tried to do that from
> userspace with a fuse filesystem and by translating the cgroup
> information into proc information. I was proud of the result but I
> noticed fuse is not really friendly with us for the containers: adds a
> lot of processes, does not support some file operations and adds an
> important overhead, so I gave up because it leads to a deadend.
>
> http://lxc.sourceforge.net/download/procfs/

Thanks for the pointer. I wasn't aware of such proposal.

>>
>> bind mounting proc files from their cgroup is a nice alternative,
>> though. But it leaves the possibility of any user of it not setting it
>> up.
>
> AFAIK, an user can set up an cgroup, so I guess it is up to the cgroup
> creator to handle that.
>
>> Although it is certainly more flexible, it makes me wonder if a
>> constrained process should ever know about resources it can't access...
>>
>> If bind mounts are used, I'd suggest we represent them as directories,
>> like cpuset.proc/cpuinfo. (It is not clear for me what exactly you meant
>> in your proposal, sorry if it was just that).
>
> Well this can not be organized in directory because a directory is a
> cgroup :)

Sure it can (with some effort). Doesn't mean it should, though, so 
moving on:

> The naming was an example, that would make more sense to name them
> cpuset.cpuinfo and memory.meminfo.
I might very well be overdesigning, but I guess that once the first 
files appear, others will follow. So what I'd like to see, is an easy
way for future userspace to find out that it should/could bind mount 
this at proc, regardless of what it is

How about cpuset.proc.cpuinfo , memory.proc.meminfo, and so on?

Other than this tiny nitpick, specially considering the fact that the 
alternate proposal I referred to was already rejected, I have to say I 
really like the overall idea.
