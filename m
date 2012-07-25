From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH net-next] netns: correctly use per-netns ipv4
	sysctl_tcp_mem
Date: Wed, 25 Jul 2012 16:45:37 +0400
Message-ID: <500FEA71.9080005__3213.0766929642$1343220521$gmane$org@parallels.com>
References: <50079D47.6040001@huawei.com>
	<1342677832.2626.3839.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1342677832.2626.3839.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,


On 07/19/2012 10:03 AM, Eric Dumazet wrote:
> On Thu, 2012-07-19 at 13:38 +0800, Huang Qiang wrote:
>> From: Yang Zhenzhang <yangzhenzhang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>
>> Now, kernel allows each net namespace to independently set up its levels
>> for tcp memory pressure thresholds.

Not really.

So the real limitation here, is done by the memory controller in cgroup,
not the proc files. AFAIK, lxc does not (yet) touches that file by
default, but it does create a memcg placeholder for you container, where
you can set that yourself.

cgroups are outside the realm of the admin, however. So once the
limitation is in place, you might want to restrain their further,
and that's the role of the files in /proc.

The goal is to have something that is as close as possible to a real
system in a container, where an admin could freely set this. (but of
course, never going over its allowance)

You can note this by what reads in sysctl_ipv4.c, when that file is
written to:

#ifdef CONFIG_MEMCG_KMEM
        rcu_read_lock();
        memcg = mem_cgroup_from_task(current);

        tcp_prot_mem(memcg, vec[0], 0);
        tcp_prot_mem(memcg, vec[1], 1);
        tcp_prot_mem(memcg, vec[2], 2);
        rcu_read_unlock();
#endif

This function is defined in tcp_memcontrol.c

void tcp_prot_mem(struct mem_cgroup *memcg, long val, int idx)
{
        struct tcp_memcontrol *tcp;
        struct cg_proto *cg_proto;

        cg_proto = tcp_prot.proto_cgroup(memcg);
        if (!cg_proto)
                return;

        tcp = tcp_from_cgproto(cg_proto);

        tcp->tcp_prot_mem[idx] = val;
}

tcp_prot_mem[] ends up being the vector you access as:

	prot = sk->sk_cgrp->sysctl_mem;

in the function you patch.

I hope it helps.
