From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCHSET] cpuset: decouple cpuset locking from cgroup core,
	take#2
Date: Mon, 07 Jan 2013 17:12:05 +0900
Message-ID: <50EA8355.5080007@jp.fujitsu.com>
References: <1357248967-24959-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1357248967-24959-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

(2013/01/04 6:35), Tejun Heo wrote:
> Hello, guys.
> 
> This is the second attempt at decoupling cpuset locking from cgroup
> core.  Changes from the last take[L] are
> 
> * cpuset-drop-async_rebuild_sched_domains.patch moved from 0007 to
>    0009.  This reordering makes cpu hotplug handling async first and
>    removes the temporary cyclic locking dependency.
> 
> * 0006-cpuset-cleanup-cpuset-_can-_attach.patch no longer converts
>    cpumask_var_t to cpumask_t as per Rusty Russell.
> 
> * 0008-cpuset-don-t-nest-cgroup_mutex-inside-get_online_cpu.patch now
>    synchronously rebuilds sched domains from cpu hotplug callback.
>    This fixes various issues caused by confused scheduler puttings
>    tasks into a dead cpu including the RCU stall problem reported by Li
>    Zefan.
> 
> Original patchset description follows.
> 
> Depending on cgroup core locking - cgroup_mutex - is messy and makes
> cgroup prone to locking dependency problems.  The current code already
> has lock dependency loop - memcg nests get_online_cpus() inside
> cgroup_mutex.  cpuset the other way around.
> 
> Regardless of the locking details, whatever is protecting cgroup has
> inherently to be something outer to most other locking constructs.
> cgroup calls into a lot of major subsystems which in turn have to
> perform subsystem-specific locking.  Trying to nest cgroup
> synchronization inside other locks isn't something which can work
> well.
> 
> cgroup now has enough API to allow subsystems to implement their own
> locking and cgroup_mutex is scheduled to be made private to cgroup
> core.  This patchset makes cpuset implement its own locking instead of
> relying on cgroup_mutex.
> 
> cpuset is rather nasty in this respect.  Some of it seems to have come
> from the implementation history - cgroup core grew out of cpuset - but
> big part stems from cpuset's need to migrate tasks to an ancestor
> cgroup when an hotunplug event makes a cpuset empty (w/o any cpu or
> memory).
> 
> This patchset decouples cpuset locking from cgroup_mutex.  After the
> patchset, cpuset uses cpuset-specific cpuset_mutex instead of
> cgroup_mutex.  This also removes the lockdep warning triggered during
> cpu offlining (see 0009).
> 
> Note that this leaves memcg as the only external user of cgroup_mutex.
> Michal, Kame, can you guys please convert memcg to use its own locking
> too?
> 

Okay...but If Costa has a new version of his patch, I'd like to see it.
I'm sorry if I missed his new patches for removing cgroup_lock.

Thanks,
-Kame

Thanks,
-Kame
