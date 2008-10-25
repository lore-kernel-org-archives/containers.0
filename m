From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: container userspace tools
Date: Sat, 25 Oct 2008 17:47:28 +0200
Message-ID: <49033F90.8090201@fr.ibm.com>
References: <48EF35F1.2060308@fr.ibm.com>
	<8f34198c0810150033p42b74badrf194e66433e32cd5@mail.gmail.com>
	<48F5BE23.1060602@fr.ibm.com>
	<8f34198c0810150351n7549a1dcx63547746344fce25@mail.gmail.com>
	<48F5DB43.70003@fr.ibm.com>
	<8f34198c0810150602w70d31453je6fd8811799a3857@mail.gmail.com>
	<48F5EBF3.1070204@fr.ibm.com>
	<8f34198c0810250406s4f1c9337ha2bccc10faed1948@mail.gmail.com>
	<49031A54.70806@fr.ibm.com>
	<8f34198c0810250739s77ad8271u93992c0bcf61345c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8f34198c0810250739s77ad8271u93992c0bcf61345c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ian jonhson <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Ian jonhson wrote:
>> The container will be more or less isolated depending of what you specify in
>> the configuration file.
>>
> yes
> 
>> Without any configuration file, you will have pid, ipc and mount points
>> isolated. If you specify the utsname, it will be isolated and if you specify
>> the network you will have a new network stack allowing to run for example a
>> new sshd server.
>>
> 
> hmm.... then, how to configure the container to get the isolation of
> pid, ipc and
> mount points? 

This is done automatically, with or without configuration.

For examples:

	lxc-execute -n foo -- ps -ef --forest

UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 16:55 ?        00:00:00 lxc-execute -n foo -- ps 
-ef --forest
root         2     1  0 16:55 pts/6    00:00:00 ps -ef --forest


	lxc-execute -n foo ls /proc

will only show process 1 and 2, showing the /proc fs has been remount 
inside the container without interfering with your own /proc.

You can do the same check by looking at the ipcs inside and outside the 
container  (assuming they are different).

> I have looked through the whole configuration example in README
> and fond the following settings(which are not tried in my test because
> I don't understand
> them very well)

>  * lxc.mount: is it to mount a file (or volume) so that all the
> processes in this container can access the content in file?

It is a file location in the fstab format. All the mounts point 
specified in this file will be mounted when launching the container.
You have a good example in the sshd contrib package.

>  * lxc.utsname: I don't know what exact functionlity of this setting is.

This option will set the hostname inside the container, so the hostname 
command will be private to the container.

>  * lxc.network.xxx: are there other options expect
> "link","hwaddr","ipv4" and "ipv6"?

This are the most complicated options:

lxc.network.type:
=================
That will specify the type of configuration, there are:
	* empty : new network stack but only with the loopback
	* veth : a bridge + veth pair device configuration, your system should 
be configured with a bridge before this kind of configuration
	* macvlan : virtualize using a macvlan

lxc.network.hwaddr:
===================
That will set a mac address for the virtualized network device (if not 
specified, a random value is used).

lxc.network.link:
=================
That specify the physical network device to be linked with the 
virtualized network device: eg. usually eth0 for macvlan configuration 
or br0 for bridge configuration.

lxc.network.ipv4:
=================
That sets the ipv4 address for the virtualized network device, it is in 
the form 1.2.3.4 and the prefix can be specified by adding "/24"

lxc.network.ipv6:
=================
Idem but for ipv6

There is a documentation about the network virtualization at 
http://lxc.sourceforge.net/network/configuration.php
Please forget Method 1 , it is pointless.

>  * lxc.rootfs:for application writing data in it?

This is the location of where the container will be chrooted, read the 
application will read/write inside.

> I am now looking into the codes and find some information about what the
> container can do maximally. It seems all the configuration settings are
> binding with a container and all the schedules are based on container unit.
> Configuration settings only can be setup before container creation and
> can not be changed in container lifecycle, right?

Yes, that's right.

>> In the other side, the cgroup are tied with the container, so you can
>> freeze/unfreeze all processes belonging to the container, change the
>> priority or assign an amount of physical memory to be used by the container.
>>
> 
> In my brain, the cgroup is mainly used in multiple CPUs. In traditional single
> CPU machine, can the container separate or determine how much CPU cycle
> are used by its processes now? Also, administrator has to configure cgroup
> before it takes action. I have no idea whether both of cgroup and container are
> totally integrate with each other, or both of them have to be handle
> in some cases.

Yes, the cpuset was integrated into the cgroup. But people is adding 
more subsystem to the cgroup. At present, there are the cpuset, the cpu 
accounting and the dev whitelist. There are the memory controller and 
cgroup fair scheduler too. Some other subsystems are not already in the 
mainline but -mm or in a specific patchset, this is the case of the freezer.

The lxc acts as a proxy for the cgroup. So if you mount the cgroup file 
system, you can see there are several subsystem. I have these ones for 
examples for my kernel:

cpuacct.usage			cpuset.sched_relax_domain_level
cpu.rt_period_us		cpu.shares
cpu.rt_runtime_us		devices.allow
cpuset.cpu_exclusive		devices.deny
cpuset.cpus			devices.list
cpuset.mem_exclusive		memory.failcnt
cpuset.mem_hardwall		memory.force_empty
cpuset.memory_migrate		memory.limit_in_bytes
cpuset.memory_pressure		memory.max_usage_in_bytes
cpuset.memory_pressure_enabled	memory.stat
cpuset.memory_spread_page	memory.usage_in_bytes
cpuset.memory_spread_slab	notify_on_release
cpuset.mems			release_agent
cpuset.sched_load_balance	tasks

For example, if I want to assign cpu 1 to my container 'foo', I will 
specify in the configuration file:

lxc.cgroup.cpuset.cpus = 1

If the container is already running, I can change this value by doing:

lxc-cgroup -n foo cpuset.cpu "0,1"


>> Allowing to assign quota per container is a good idea, but I don't think it
>> is supported by the kernel right now. Perhaps there is a trick to do that
>> but I don't know it :)
>>
> I would like to do this part of job. Also, I need to control several groups of
> processes (belonged to same user) in the same time, isolating them,
> enforced them with given resource quota, and freeze/unfreeze some of
> them.

Yeah, it is a good idea, I am not expert in fs/quota but perhaps someone 
in this mailing list can give some info.

Concerning the freeze, this is already part of lxc via 
lxc-freeze/lxc-unfreeze but that relies on the freezer cgroup subsystem 
which should be in mainline soon.

> BTW, as for checkpointing of container, is it easy to checkpoint/restart
> given group of processes in above example?

This is the objective. You should be able to checkpoint at any time the 
container. For example, you launched the container with the command 
lxc-execute -n foo, and later you want to checkpoint it. You can do 
lxc-checkpoint -n foo > my_checkpoint_file.

But the checkpoint / restart is actually under development. The lxc 
checkpoint/restart commands are experimental and the kernel code is at 
the beginning, just a single process can be checkpointed / restarted. 
Before being able to checkpoint multiple processes that will take 
awhile, especially to have it in the kernel mainline. I guess the quota 
do not need to be checkpointed as it is part of the file system, so it 
is always saved.

>> The rootfs option allows you to specify the root file system to be used by
>> the container, so if you specify it, your container will be chrooted inside.
>> This feature is at a very early stage and will be improved in the future,
>> allowing to example to specify a iso image of a file system tree and make
>> use of it.
>>
> 
> Good. what kinds of rootfs are supported now?  I fond there are a debian file
> in sourceforge, is it a rootfs image?

Right now, this is only a directory entry. I plan to change that to 
something more powerful, for example use the union mount, iso image and 
more.

The debian file is a rootfs image.

>> There are two contributions which are good examples on how to setup a
>> container, I added them to:
>>
>> http://sourceforge.net/projects/lxc/
>>
>> The first one is a chroot of a sshd server and the second one is a
>> minimalist debian showing a full distro booting.
>>
> 
> In sourceforge, there are
> 
> *  	sshd.tar.gz
> *  	debian.tar.gz
> *       utsname (actually, utstest.c)
> 
> I wonder what is the utstest.c?

This is a very old testcase, it checks the utsname is private.

> Thanks again,

Thanks.
   -- Daniel
