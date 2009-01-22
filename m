From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: commit 7534432dcc3c654a8671b6b0cdffd1dbdbc73074
Date: Thu, 22 Jan 2009 12:47:54 -0600
Message-ID: <20090122184754.GA17511@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
To: laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

The following script gives me a reliable BUG bisected to
commit 7534432dcc3c654a8671b6b0cdffd1dbdbc73074, subject
"cgroups: remove rcu_read_lock() in cgroupstats_build()".
It's not immediately clear to me why that commit should
cause this...

thanks,
-serge

==============================================================
script
==============================================================
#!/bin/bash
mount -t cgroup -o freezer none /cgroup
sleep 100 &
pid=`jobs -p`
mkdir /cgroup/1
echo $pid > /cgroup/1/tasks
umount /cgroup
mount -t cgroup -o freezer,ns none /cgroup
mount -t cgroup -o freezer none /cgroup
#kill %1
sleep 100 &
pid=`jobs -p | tail -1`
mkdir /cgroup/2
echo $pid > /cgroup/2/tasks
umount /cgroup
==============================================================

==============================================================
The BUG output:
==============================================================


------------[ cut here ]------------
kernel BUG at kernel/cgroup.c:468!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/kernel/uevent_seqnum
Modules linked in:

Pid: 2900, comm: sh Not tainted (2.6.28-07513-ge5f6a86 #231)
EIP: 0060:[<c02411bb>] EFLAGS: 00010293 CPU: 2
EIP is at cgroup_attach_task+0x281/0x3ba
EAX: dfb57ee8 EBX: dfbe2914 ECX: df8cda68 EDX: dfb57ef0
ESI: df0ff900 EDI: 00000004 EBP: dfbe2900 ESP: dfb57ec0
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process sh (pid: 2900, ti=dfb56000 task=df88ee00 task.ti=dfb56000)
Stack:
 dfb57ee8 dfaabde0 df0ff900 df294014 c0725b88 df294000 c0621244 df800150
 df809040 df8cd9c0 df9563e0 c0724b48 df8cda68 dfbe2914 dfbe2900 df0ff900
 00000005 c024135f dfb57f2c fffffff2 c0620968 c0241836 00000b5e 00000000
Call Trace:
 [<c024135f>] cgroup_tasks_write+0x6b/0x91
 [<c0241836>] cgroup_file_write+0xcd/0x1c3
 [<c02606ae>] handle_mm_fault+0x4da/0x52a
 [<c0241769>] cgroup_file_write+0x0/0x1c3
 [<c0271fa1>] vfs_write+0x83/0xf6
 [<c027245f>] sys_write+0x3c/0x63
 [<c0202d1a>] syscall_call+0x7/0xb
 [<c04f0000>] do_nanosleep+0x25/0x8c
Code: 8d 50 08 a3 48 4b 72 c0 89 68 10 8b 4d 14 c7 40 04 48 4b 72 c0 89 48 08 89 51 04 89 55 14 89 5a 04 8d 44 24 28 39 44 24 28 74 04 <0f> 0b eb fe 8d 45 1c ff 05 c8 5b 72 c0 e8 d6 ec ff ff 8d 4d 04
EIP: [<c02411bb>] cgroup_attach_task+0x281/0x3ba SS:ESP 0068:dfb57ec0
---[ end trace d624dca4c4cd0d89 ]---

==============================================================
