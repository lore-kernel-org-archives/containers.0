From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: CPU and Memory Quota for LXC
Date: Sat, 10 Jul 2010 13:33:08 +0200
Message-ID: <4C385A74.5060007__33002.3690745749$1278761733$gmane$org@free.fr>
References: <AANLkTilZtuL-YwbT7NpzrRJA3PXdq7NFRiDtKVbV0jAS@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTilZtuL-YwbT7NpzrRJA3PXdq7NFRiDtKVbV0jAS-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Abi Wilson <abi-ETsMpvZGyKJdeDdKuUvyIgC/G2K4zDHf@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/09/2010 05:57 AM, Abi Wilson wrote:

> Hi,
>    

Hi Abi,

actually the quota is working well but the /proc information is not 
virtualized, so you will see the memory available on your host, not the 
memory you set with the cgroup.

> I tried to allocate quota(CPU and Memory)  for each containers , for that I
> have tried with the below lxc-config file . With this config I am able to
> create container and able to start the container, But the RAM memory
> displayed is same as Host. Do I need to modify anything to get Quota
> working? Will Lxc support Quota management ? I am using 2.6.29 kernel with
> the following config for lxc and using lxc-0.6.5.
>
> CONFIG_CGROUPS=y
> CONFIG_CGROUP_DEBUG=y
> CONFIG_CGROUP_NS=y
> CONFIG_CGROUP_FREEZER=y
> CONFIG_CGROUP_DEVICE=y
> CONFIG_CPUSETS=y
> CONFIG_PROC_PID_CPUSET=y
> CONFIG_CGROUP_CPUACCT=y
> CONFIG_RESOURCE_COUNTERS=y
> CONFIG_CGROUP_MEM_RES_CTLR=y
> CONFIG_NAMESPACES=y
> CONFIG_UTS_NS=y
> CONFIG_IPC_NS=y
> CONFIG_USER_NS=y
> CONFIG_PID_NS=y
> CONFIG_NET_NS=y
>
>
> # veth pair virtual network devices
> lxc.utsname = vsys1
>
> # === Internal control bridge
> lxc.network.type = veth
> lxc.network.flags = up
> lxc.network.link = br0
> lxc.network.name = eth0
> lxc.network.hwaddr = 00:09:00:09:00:01
> lxc.network.ipv4 = 192.168.18.25
>
> lxc.cgroup.memory.limit_in_bytes = 67108864
> #lxc.cgroup.shares=5
>
> *RAM memory of Host:*
>
>               total       used       free     shared    buffers     cached
> Mem:       1028904     472380     556524          0        352     350960
> -/+ buffers/cache:     121068     907836
> Swap:            0          0          0
>
> *RAM memory of container:*
>
> Mem:       1028904     508640     520264          0        352     384608
> -/+ buffers/cache:     123680     905224
> Swap:            0          0          0
>    
