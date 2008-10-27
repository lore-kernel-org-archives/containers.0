From: "Ian jonhson" <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: container userspace tools
Date: Tue, 28 Oct 2008 00:23:07 +0800
Message-ID: <8f34198c0810270923s40ee505ay214bc9dd8ebae26d@mail.gmail.com>
References: <48EF35F1.2060308@fr.ibm.com> <48F5BE23.1060602@fr.ibm.com>
	<8f34198c0810150351n7549a1dcx63547746344fce25@mail.gmail.com>
	<48F5DB43.70003@fr.ibm.com>
	<8f34198c0810150602w70d31453je6fd8811799a3857@mail.gmail.com>
	<48F5EBF3.1070204@fr.ibm.com>
	<8f34198c0810250406s4f1c9337ha2bccc10faed1948@mail.gmail.com>
	<49031A54.70806@fr.ibm.com>
	<8f34198c0810250739s77ad8271u93992c0bcf61345c@mail.gmail.com>
	<49033F90.8090201@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49033F90.8090201-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

>>
>> hmm.... then, how to configure the container to get the isolation of
>> pid, ipc and
>> mount points?
>
> This is done automatically, with or without configuration.
>
> For examples:
>
>        lxc-execute -n foo -- ps -ef --forest
>
> UID        PID  PPID  C STIME TTY          TIME CMD
> root         1     0  0 16:55 ?        00:00:00 lxc-execute -n foo -- ps -ef
> --forest
> root         2     1  0 16:55 pts/6    00:00:00 ps -ef --forest
>
>
>        lxc-execute -n foo ls /proc
>
> will only show process 1 and 2, showing the /proc fs has been remount inside
> the container without interfering with your own /proc.
>
> You can do the same check by looking at the ipcs inside and outside the
> container  (assuming they are different).
>

Is it possible to isolate processes in two different containers when they access
given local file. For example, I run a process_A in container_A to create a
file named "shared_file". Then, another process (for example, process_B)
in container_A can access the "shared_file", but another process, named
process_C in container_B can not access the same file. The process_A,
process_B, and process_C are run with same uid/gid. how to set the
configurations of container_A and container_B to achieve the isolation?
Is is possible to do this?


>
> This are the most complicated options:
>
> lxc.network.type:
> =================
> That will specify the type of configuration, there are:
>        * empty : new network stack but only with the loopback
>        * veth : a bridge + veth pair device configuration, your system
> should be configured with a bridge before this kind of configuration
>        * macvlan : virtualize using a macvlan
>
> lxc.network.hwaddr:
> lxc.network.link:
> lxc.network.ipv4:
> lxc.network.ipv6:
>
> There is a documentation about the network virtualization at
> http://lxc.sourceforge.net/network/configuration.php
> Please forget Method 1 , it is pointless.
>

It seems that all the network settings just tell how the container
uses network devices. Is it equipped with the functionalities
in somewhere (or in kernel ) to limit which container can connect
outside in a given time or how to schedule  multiple containers
access network via only one network device? Or, further, how much
bandwidth can each container use?


>>> In the other side, the cgroup are tied with the container, so you can
>>> freeze/unfreeze all processes belonging to the container, change the
> Yes, the cpuset was integrated into the cgroup. But people is adding more
> subsystem to the cgroup. At present, there are the cpuset, the cpu
> accounting and the dev whitelist. There are the memory controller and cgroup
> fair scheduler too. Some other subsystems are not already in the mainline
> but -mm or in a specific patchset, this is the case of the freezer.
>
> The lxc acts as a proxy for the cgroup. So if you mount the cgroup file
> system, you can see there are several subsystem. I have these ones for
> examples for my kernel:
>

I wonder here whether cgroup can efficiently isolate two containers access
given memory spaces. In my previous experiment about cgroup, I can not
achieve a ideal result.


> Concerning the freeze, this is already part of lxc via
> lxc-freeze/lxc-unfreeze but that relies on the freezer cgroup subsystem
> which should be in mainline soon.
>

The image of frozen container may be more easy to be migrated to other
homogeneous system.

>> BTW, as for checkpointing of container, is it easy to checkpoint/restart
>> given group of processes in above example?
>
> This is the objective. You should be able to checkpoint at any time the
> container. For example, you launched the container with the command
> lxc-execute -n foo, and later you want to checkpoint it. You can do
> lxc-checkpoint -n foo > my_checkpoint_file.
>
> But the checkpoint / restart is actually under development. The lxc
> checkpoint/restart commands are experimental and the kernel code is at the
> beginning, just a single process can be checkpointed / restarted. Before
> being able to checkpoint multiple processes that will take awhile,
> especially to have it in the kernel mainline.

good

> I guess the quota do not need
> to be checkpointed as it is part of the file system, so it is always saved.
>

Not just concerning with file system, the quota I meant also includes how many
CPU cycle, memory, bandwidth are allowed to use for a running container.
Ideally,  it should also be changed dynamically.



> Right now, this is only a directory entry. I plan to change that to
> something more powerful, for example use the union mount, iso image and
> more.
>

I agree.


Best Regards,

Ian
