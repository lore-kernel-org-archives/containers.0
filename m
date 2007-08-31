From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: containers - bug
Date: Fri, 31 Aug 2007 18:29:12 +0200
Message-ID: <46D841D8.6000100@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Paul,

I was playing with the container filesystem (very nice) and I fall 
inside a kbug.

I did the following:

	mkdir /dev/container

	mount -t container -o cpuset cpuset /dev/container

	cd /dev/container/

	mkdir Charlie

	cd Charlie

	echo $$ > tasks

	bash

	cd ..

	rmdir Charlie

	exit

	ls => bang !

I run a 2.6.23-rc3-mm1 kernel with qemu.

Here is the message:
--------------------
	
BUG: unable to handle kernel paging request at virtual address 6b6b6c23
printing eip: c016719d *pde = 00000000
Oops: 0000 [#1] SMP
Modules linked in:

Pid: 960, comm: bash Not tainted (2.6.23-rc3-mm1 #522)
EIP: 0060:[<c016719d>] EFLAGS: 00000246 CPU: 0
EIP is at __link_path_walk+0x41/0xb54
EAX: c1873320 EBX: c141c608 ECX: c167be38 EDX: c15de000
ESI: c167bef4 EDI: 6b6b6b6b EBP: c167be3c ESP: c167bde8
  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process bash (pid: 960, ti=c167a000 task=c1466b50 task.ti=c167a000)
Stack: c15de000 00000000 00000400 00000001 000000bf 00008a31 7f1c0300 
01000415
        1a131100 170f1200 00000000 00009600 00009600 00000500 00000003 
c03ab570
        00000082 c167be38 c141c608 c167bef4 c1873320 c167bea8 c0167cfb 
c15de000
Call Trace:
  [<c010398d>] show_trace_log_lvl+0x1a/0x2f
  [<c0103a3f>] show_stack_log_lvl+0x9d/0xa5
  [<c0103aee>] show_registers+0xa7/0x178
  [<c0103cc6>] die+0x107/0x227
  [<c011447c>] do_page_fault+0x47f/0x567
  [<c030800a>] error_code+0x72/0x78
  [<c0167cfb>] link_path_walk+0x4b/0xc0
  [<c0167d89>] path_walk+0x19/0x1b
  [<c0168057>] do_path_lookup+0x179/0x193
  [<c0168823>] __user_walk_fd+0x32/0x49
  [<c0162a09>] vfs_stat_fd+0x1b/0x41
  [<c0162ade>] vfs_stat+0x11/0x13
  [<c0162af4>] sys_stat64+0x14/0x28
  [<c0102a5a>] syscall_call+0x7/0xb
  =======================
Code: ff 45 ac 8b 55 ac 8a 02 3c 2f 74 f4 84 c0 0f 84 99 0a 00 00 8b 06 
83 7e 1c 00 8b 78 18 74 08 83 65 b8 04 83 4d b8 01 83 4e 14 04 <8b> 87 
b8 00 00 00 0f b7 5f 6e 85 c0 74 0a 83 78 34 00 0f 85 b7
EIP: [<c016719d>] __link_path_walk+0x41/0xb54 SS:ESP 0068:c167bde8
