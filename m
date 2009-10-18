From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: New LXC HOW-TO
Date: Sun, 18 Oct 2009 17:44:31 +0200
Message-ID: <4ADB37DF.8050907@free.fr>
References: <68e6eac60910171732w6b7fe5dbt755963653e417302@mail.gmail.com>
	<68e6eac60910180710j6ebce156w886588013786b4e9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <68e6eac60910180710j6ebce156w886588013786b4e9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Dwight Schauer wrote:
> I'm trying to get the needed LXC kernel config options into the default Arch
> Linux kernel package.
> http://bugs.archlinux.org/task/16715
>
> There is a concern about any potential drawbacks in enabling these options,
> especially for those that don't use Linux containers.
>
> Is anyone aware of any negative impact (apart from size maybe) of having
> these features being enabled? Especially for those not using these features?
>
> On Sat, Oct 17, 2009 at 7:32 PM, Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
>   
>> I just made it and it is somewhat archlinux specific, but others might find
>> it useful.
>>
>> http://lxc.teegra.net/
>>
>> --
>> Dwight
>>
>>
>>
>>
>>     
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
>
>
>   
In general the cgroup adds a small overhead at fork/exit when a subsystem make use of the cgroup_callbacks, for example the freezer. But that can be considered as negligeable.

CONFIG_GROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_RT_GROUP_SCHED=y
CONFIG_CGROUP_SCHED=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_NS=y
CONFIG_CGROUP_FREEZER=y

This one does not add any overhead.

CONFIG_CGROUP_DEVICE=y

For these ones, I don't know.

CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y

AFAIR these following options add some overhead especially the memory resource controller.

CONFIG_CGROUP_CPUACCT=y
CONFIG_RESOURCE_COUNTERS=y
CONFIG_CGROUP_MEM_RES_CTLR=y
CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
CONFIG_MM_OWNER=y


The overhead and footprint of the following options are neligeable

CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_NET_CLS_CGROUP=y


This one, no overhead.
CONFIG_SECURITY_FILE_CAPABILITIES=y
