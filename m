From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: statistics accounting in container
Date: Tue, 04 Nov 2008 22:37:12 +0100
Message-ID: <4910C088.4050109@fr.ibm.com>
References: <8f34198c0811022345t6030bb8cg4ccb48ef49f6b4bb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8f34198c0811022345t6030bb8cg4ccb48ef49f6b4bb-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Ian jonhson wrote:
> Dear all,
> 
> I am now working in the development of user tool for container
> (built by Daniel Lezcano) and interest in the accounting
> of container. Now, I would like to know whether the patches stated
> in:
> http://lwn.net/Articles/229974/

I think this one is known as CONFIG_CGROUP_CPUACCT and it is in mainline.

> http://lwn.net/Articles/243795/

This one is in mainline too. It is a subsystem of the resource
controller. Note that it is related to physical memory.

> is been embedded in mainstream. More further, what is the
> development status of  CPU,MEM, network bandwidth in container?

I am not sure what you mean by CPU bandwidth. There is the cgroup
scheduler which allows to prioritize a group of processes but I don't 
think there is a resource controller which blocks a set of processes 
when a cpu consumption limit has been reached.

For the memory, there is the memory controller which gives an amount of 
physical memory to a group of processes. When the limit is reached, the 
processes begin to swap. There is some statistics in the cgroup files 
about the memory consumption and the limits reached by the group.

Concerning network bandwidth, there is a patch walking around netdev for 
cgroup packet classifier allowing to do some QoS between containers. 
AFAICS, it is about to be merged. The traffic control can be used to 
assign a bandwidth to the network devices belonging to a specific container.

> Can I use these functionalities directly in my work now?

These features are all provided by the control groups. The control 
groups are supported by 'lxc'.

For example, if you want to retrieve the cpu used you can do:

	lxc-cgroup -n foo cpuacct.usage

If you want to set a memory limit:

	lxc-cgroup -n foo memory.limit_in_bytes 262144

If you want to set a priority:

	lxc-cgroup -n foo cpu.shares 1234

Assign cpu:

	lxc-cgroup -n foo cpuset.cpus 0,3

etc ...

What will you work consist in ?

> I am using the kernel recommended by Daniel:
> git://git.kernel.org/pub/scm/linux/kernel/git/daveh/linux-2.6-lxc.git
> and wonder whether this version of kernel has been equipped with
> accounting mechanisms of container?

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
will be more up to date. You won't have sysfs per namespace neither the 
checkpoint/restart, so you will have a warning for 'lxc-execute' 
complaining for sysfs being busy when mounting but that should not be a 
blocker.

Thanks
   -- Daniel
