From: "KOSAKI Motohiro" <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: v2.6.26-rc7/cgroups: circular locking dependency
Date: Mon, 23 Jun 2008 00:34:04 +0900
Message-ID: <2f11576a0806220834m3572ee80i72229cb9a1613558__18342.8255645142$1214149047$gmane$org@mail.gmail.com>
References: <20080621173859.GA6846@damson.getinternet.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080621173859.GA6846-nxaqs94rzLmmVpTN6tjYhgHPHiC6WJ74@public.gmane.org>
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
To: Vegard Nossum <vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

CC'ed Paul Jackson

it seems typical ABBA deadlock.
I think cpuset use cgrou_lock() by mistake.

IMHO, cpuset_handle_cpuhp() sholdn't use cgroup_lock() and
shouldn't call rebuild_sched_domains().


 -> #1 (cgroup_mutex){--..}:
       [<c015a435>] __lock_acquire+0xf45/0x1040
       [<c015a5c8>] lock_acquire+0x98/0xd0
       [<c05416d1>] mutex_lock_nested+0xb1/0x300
       [<c0160e6f>] cgroup_lock+0xf/0x20			   cgroup_lock
       [<c0164750>] cpuset_handle_cpuhp+0x20/0x180
       [<c014ea77>] notifier_call_chain+0x37/0x70
       [<c014eae9>] __raw_notifier_call_chain+0x19/0x20
       [<c051f8c8>] _cpu_down+0x78/0x240			cpu_hotplug.lock
       [<c051fabb>] cpu_down+0x2b/0x40				  cpu_add_remove_lock
       [<c0520cd9>] store_online+0x39/0x80
       [<c02f627b>] sysdev_store+0x2b/0x40
       [<c01d3372>] sysfs_write_file+0xa2/0x100
       [<c0195486>] vfs_write+0x96/0x130
       [<c0195b4d>] sys_write+0x3d/0x70
       [<c010831b>] sysenter_past_esp+0x78/0xd1
       [<ffffffff>] 0xffffffff

 -> #0 (&cpu_hotplug.lock){--..}:
       [<c0159fe5>] __lock_acquire+0xaf5/0x1040
       [<c015a5c8>] lock_acquire+0x98/0xd0
       [<c05416d1>] mutex_lock_nested+0xb1/0x300
       [<c015efbc>] get_online_cpus+0x2c/0x40			      cpu_hotplug.lock
       [<c0163e6d>] rebuild_sched_domains+0x7d/0x3a0
       [<c01653a4>] cpuset_common_file_write+0x204/0x440	cgroup_lock
       [<c0162bc7>] cgroup_file_write+0x67/0x130
       [<c0195486>] vfs_write+0x96/0x130
       [<c0195b4d>] sys_write+0x3d/0x70
       [<c010831b>] sysenter_past_esp+0x78/0xd1
       [<ffffffff>] 0xffffffff


> Hi,
>
> I decided to see what cgroups is all about, and followed the instructions
> in Documentation/cgroups.txt :-) It happened when I did this:
>
>    [root@damson /dev/cgroup/Vegard 0]
>    # echo 1 > cpuset.cpus
>
> I can also provide the kernel config if necessary.
>
>
> Vegard
>
>
>  =======================================================
>  [ INFO: possible circular locking dependency detected ]
>  2.6.26-rc7 #25
>  -------------------------------------------------------
>  bash/10032 is trying to acquire lock:
>  (&cpu_hotplug.lock){--..}, at: [<c015efbc>] get_online_cpus+0x2c/0x40
>
>  but task is already holding lock:
>  (cgroup_mutex){--..}, at: [<c0160e6f>] cgroup_lock+0xf/0x20
>
>  which lock already depends on the new lock.
