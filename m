From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: container userspace tools
Date: Mon, 27 Oct 2008 21:28:50 +0100
Message-ID: <49062482.7070006@fr.ibm.com>
References: <48EF35F1.2060308@fr.ibm.com> <48F5BE23.1060602@fr.ibm.com>
	<8f34198c0810150351n7549a1dcx63547746344fce25@mail.gmail.com>
	<48F5DB43.70003@fr.ibm.com>
	<8f34198c0810150602w70d31453je6fd8811799a3857@mail.gmail.com>
	<48F5EBF3.1070204@fr.ibm.com>
	<8f34198c0810250406s4f1c9337ha2bccc10faed1948@mail.gmail.com>
	<49031A54.70806@fr.ibm.com>
	<8f34198c0810250739s77ad8271u93992c0bcf61345c@mail.gmail.com>
	<49033F90.8090201@fr.ibm.com>
	<8f34198c0810270923s40ee505ay214bc9dd8ebae26d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8f34198c0810270923s40ee505ay214bc9dd8ebae26d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
>>> hmm.... then, how to configure the container to get the isolation of
>>> pid, ipc and
>>> mount points?
>> This is done automatically, with or without configuration.
>>
>> For examples:
>>
>>        lxc-execute -n foo -- ps -ef --forest
>>
>> UID        PID  PPID  C STIME TTY          TIME CMD
>> root         1     0  0 16:55 ?        00:00:00 lxc-execute -n foo -- ps -ef
>> --forest
>> root         2     1  0 16:55 pts/6    00:00:00 ps -ef --forest
>>
>>
>>        lxc-execute -n foo ls /proc
>>
>> will only show process 1 and 2, showing the /proc fs has been remount inside
>> the container without interfering with your own /proc.
>>
>> You can do the same check by looking at the ipcs inside and outside the
>> container  (assuming they are different).
>>
> 
> Is it possible to isolate processes in two different containers when they access
> given local file. For example, I run a process_A in container_A to create a
> file named "shared_file". Then, another process (for example, process_B)
> in container_A can access the "shared_file", but another process, named
> process_C in container_B can not access the same file. The process_A,
> process_B, and process_C are run with same uid/gid. how to set the
> configurations of container_A and container_B to achieve the isolation?
> Is is possible to do this?

Yes, you can do this in different ways. The first one is as Serge 
suggested with chroot, sshd contrib is a good example on how a directory 
tree with a set of mount --bind can be chrooted to ensure file isolation 
(cf the fstab file for this configuration).

This first solution provides isolation and security. Isolation because 
in a container A, the processes running inside can access a file at the 
same location than the processes running inside a container B without 
interacting. Security because processes from container A can not access 
the file in container B.

But, if someone wants to run several instances of the same application 
and wants to avoid the file to be overwritten, the security is pointless 
in this case and a simpler configuration can be used with just a bind 
mount specified in the fstab file lxc option.

For example, we have a computing program writing its results in the 
directory /tmp/results and we want to launch multiple instances of this 
program in parallel. We can do:

mkdir -p /tmp/container_A/results
mkdir -p /tmp/container_B/results

One fstab per container

for container_A:
/tmp/container_A/results /tmp/results none ro,bind 0 0

for container_B:
/tmp/container_B/results /tmp/results none ro,bind 0 0

And one configuration per container with:

for container_A:
lxc.mount = fstab.container_A

for container_B:
lxc.mount = fstab.container_B

And finally:

lxc-execute -n container_A -f ./container_A.conf
lxc-execute -n container_B -f ./configure_B.conf

(if the container was not created before lxc-execute will automatically 
create it and autodestroy it after at exit).

So, the application is unmodified and will continue writing the results 
in /tmp/results which is in fact a private location for the container.

>> This are the most complicated options:
>>
>> lxc.network.type:
>> =================
>> That will specify the type of configuration, there are:
>>        * empty : new network stack but only with the loopback
>>        * veth : a bridge + veth pair device configuration, your system
>> should be configured with a bridge before this kind of configuration
>>        * macvlan : virtualize using a macvlan
>>
>> lxc.network.hwaddr:
>> lxc.network.link:
>> lxc.network.ipv4:
>> lxc.network.ipv6:
>>
>> There is a documentation about the network virtualization at
>> http://lxc.sourceforge.net/network/configuration.php
>> Please forget Method 1 , it is pointless.
>>
> 
> It seems that all the network settings just tell how the container
> uses network devices. Is it equipped with the functionalities
> in somewhere (or in kernel ) to limit which container can connect
> outside in a given time or how to schedule  multiple containers
> access network via only one network device? Or, further, how much
> bandwidth can each container use?

I didn't think about the scheduling. I guess this is certainly a job for 
an upper layer build on top of the liblxc. I wrote a small network 
namespace freezer patch I will post soon. It blocks all the network 
traffic for a given network namespace, so having some kind of resource 
manager making use of this feature can do easily the trick.

Concerning the bandwidth, this is part of the traffic control job and it 
can be plugged with the container. This is something I have in mind, 
that is specify the bandwidth per container. We have all the tools to do 
that now, network isolation and traffic control :)

>>>> In the other side, the cgroup are tied with the container, so you can
>>>> freeze/unfreeze all processes belonging to the container, change the
>> Yes, the cpuset was integrated into the cgroup. But people is adding more
>> subsystem to the cgroup. At present, there are the cpuset, the cpu
>> accounting and the dev whitelist. There are the memory controller and cgroup
>> fair scheduler too. Some other subsystems are not already in the mainline
>> but -mm or in a specific patchset, this is the case of the freezer.
>>
>> The lxc acts as a proxy for the cgroup. So if you mount the cgroup file
>> system, you can see there are several subsystem. I have these ones for
>> examples for my kernel:
>>
> 
> I wonder here whether cgroup can efficiently isolate two containers access
> given memory spaces. In my previous experiment about cgroup, I can not
> achieve a ideal result.

The cgroup does not aim to do isolation, it only provides a mechanism to 
group the processes under the same identifier. Each subsystem, written 
as plugins, make use of this to assign cpu, identify cpu consumption...

But in the other hand, if we use both cgroup and namespaces to provide a 
container with resource management, some isolation should be provided. 
For example, on a 8 cpus system, we assign 2 cpus to a container via 
cgroup/cpuset, because the cpus are not isolated, inside the container 
browsing /proc/cpuinfo will show all the cpus of the system and that 
can, in some cases, lead to an error (eg. sched_setaffinity), IMO.

>> Concerning the freeze, this is already part of lxc via
>> lxc-freeze/lxc-unfreeze but that relies on the freezer cgroup subsystem
>> which should be in mainline soon.
>>
> 
> The image of frozen container may be more easy to be migrated to other
> homogeneous system.
> 
>>> BTW, as for checkpointing of container, is it easy to checkpoint/restart
>>> given group of processes in above example?
>> This is the objective. You should be able to checkpoint at any time the
>> container. For example, you launched the container with the command
>> lxc-execute -n foo, and later you want to checkpoint it. You can do
>> lxc-checkpoint -n foo > my_checkpoint_file.
>>
>> But the checkpoint / restart is actually under development. The lxc
>> checkpoint/restart commands are experimental and the kernel code is at the
>> beginning, just a single process can be checkpointed / restarted. Before
>> being able to checkpoint multiple processes that will take awhile,
>> especially to have it in the kernel mainline.
> 
> good
> 
>> I guess the quota do not need
>> to be checkpointed as it is part of the file system, so it is always saved.
>>
> 
> Not just concerning with file system, the quota I meant also includes how many
> CPU cycle, memory, bandwidth are allowed to use for a running container.
> Ideally,  it should also be changed dynamically.

Ah ok, I see, quota + accounting. I think there is some work around that 
in this mailing list :)

>> Right now, this is only a directory entry. I plan to change that to
>> something more powerful, for example use the union mount, iso image and
>> more.
>>
> 
> I agree.
> 
> 
> Best Regards,

Thanks
   -- Daniel
