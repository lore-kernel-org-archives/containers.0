From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Wed, 06 May 2009 16:11:05 +0800
Message-ID: <4A014619.1040000__36179.5803103179$1241597599$gmane$org@cn.fujitsu.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1241553525-28095-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> Hi All,
> 
> Here is the V2 of the IO controller patches generated on top of 2.6.30-rc4.
> First version of the patches was posted here.

Hi Vivek,

I did some simple test for V2, and triggered an kernel panic.
The following script can reproduce this bug. It seems that the cgroup
is already removed, but IO Controller still try to access into it.

#!/bin/sh
echo 1 > /proc/sys/vm/drop_caches
mkdir /cgroup 2> /dev/null
mount -t cgroup -o io,blkio io /cgroup
mkdir /cgroup/test1
mkdir /cgroup/test2
echo 100 > /cgroup/test1/io.weight
echo 500 > /cgroup/test2/io.weight

./rwio -w -f 2000M.1 &  //do async write
pid1=$!
echo $pid1 > /cgroup/test1/tasks

./rwio -w -f 2000M.2 &
pid2=$!
echo $pid2 > /cgroup/test2/tasks

sleep 10
kill -9 $pid1
kill -9 $pid2
sleep 1

echo ======
cat /cgroup/test1/io.disk_time
cat /cgroup/test2/io.disk_time

echo ======
cat /cgroup/test1/io.disk_sectors
cat /cgroup/test2/io.disk_sectors

rmdir /cgroup/test1
rmdir /cgroup/test2
umount /cgroup
rmdir /cgroup


BUG: unable to handle kernel NULL pointer dereferec
IP: [<c0448c24>] cgroup_path+0xc/0x97
*pde = 64d2d067
Oops: 0000 [#1] SMP
last sysfs file: /sys/block/md0/range
Modules linked in: ipv6 cpufreq_ondemand acpi_cpufreq dm_mirror dm_multipath sbd
Pid: 132, comm: kblockd/0 Not tainted (2.6.30-rc4-Vivek-V2 #1) Veriton M460
EIP: 0060:[<c0448c24>] EFLAGS: 00010086 CPU: 0
EIP is at cgroup_path+0xc/0x97
EAX: 00000100 EBX: f60adca0 ECX: 00000080 EDX: f709fe28
ESI: f60adca8 EDI: f709fe28 EBP: 00000100 ESP: f709fdf0
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process kblockd/0 (pid: 132, ti=f709f000 task=f70a8f60 task.ti=f709f000)
Stack:
 f709fe28 f68c5698 f60adca0 f60adca8 f709fe28 f68de801 c04f5389 00000080
 f68de800 f7094d0c f6a29118 f68bde00 00000016 c04f5e8d c04f5340 00000080
 c0579fec f68c5e94 00000082 c042edb4 f68c5fd4 f68c5fd4 c080b520 00000082
Call Trace:
 [<c04f5389>] ? io_group_path+0x6d/0x89
 [<c04f5e8d>] ? elv_ioq_served+0x2a/0x7a
 [<c04f5340>] ? io_group_path+0x24/0x89
 [<c0579fec>] ? ide_build_dmatable+0xda/0x130
 [<c042edb4>] ? lock_timer_base+0x19/0x35
 [<c042ef0c>] ? mod_timer+0x9f/0xa8
 [<c04fdee6>] ? __delay+0x6/0x7
 [<c057364f>] ? ide_execute_command+0x5d/0x71
 [<c0579d4f>] ? ide_dma_intr+0x0/0x99
 [<c0576496>] ? do_rw_taskfile+0x201/0x213
 [<c04f6daa>] ? __elv_ioq_slice_expired+0x212/0x25e
 [<c04f7e15>] ? elv_fq_select_ioq+0x121/0x184
 [<c04e8a2f>] ? elv_select_sched_queue+0x1e/0x2e
 [<c04f439c>] ? cfq_dispatch_requests+0xaa/0x238
 [<c04e7e67>] ? elv_next_request+0x152/0x15f
 [<c04240c2>] ? dequeue_task_fair+0x16/0x2d
 [<c0572f49>] ? do_ide_request+0x10f/0x4c8
 [<c0642d44>] ? __schedule+0x845/0x893
 [<c042edb4>] ? lock_timer_base+0x19/0x35
 [<c042f1be>] ? del_timer+0x41/0x47
 [<c04ea5c6>] ? __generic_unplug_device+0x23/0x25
 [<c04f530d>] ? elv_kick_queue+0x19/0x28
 [<c0434b77>] ? worker_thread+0x11f/0x19e
 [<c04f52f4>] ? elv_kick_queue+0x0/0x28
 [<c0436ffc>] ? autoremove_wake_function+0x0/0x2d
 [<c0434a58>] ? worker_thread+0x0/0x19e
 [<c0436f3b>] ? kthread+0x42/0x67
 [<c0436ef9>] ? kthread+0x0/0x67
 [<c040326f>] ? kernel_thread_helper+0x7/0x10
Code: c0 84 c0 74 0e 89 d8 e8 7c e9 fd ff eb 05 bf fd ff ff ff e8 c0 ea ff ff 8
EIP: [<c0448c24>] cgroup_path+0xc/0x97 SS:ESP 0068:f709fdf0
CR2: 000000000000011c
---[ end trace 2d4bc25a2c33e394 ]---

-- 
Regards
Gui Jianfeng
