From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: memrlimit controller merge to mainline
Date: Sun, 10 Aug 2008 22:34:54 +0530
Message-ID: <489F1FB6.9070503@linux.vnet.ibm.com>
References: <6599ad830807250114h7ab0fdb1u98c0968961647642@mail.gmail.com>
	<Pine.LNX.4.64.0807251004570.31120@blonde.site>
	<489752AA.9060500@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0808042226430.4300@blonde.site>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0808042226430.4300-popGQ1T0qN76K7/ahGyk6A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Hugh Dickins wrote:
>> but I do have an initial hypothesis
>>
>> CPU0					CPU1
>> 					try_to_unuse
>> task 1 stars exiting			look at mm = task1->mm
>> ..					increment mm_users
>> task 1 exits
>> mm->owner needs to be updated, but
>> no new owner is found
>> (mm_users > 1, but no other task
>> has task->mm = task1->mm)
>> mm_update_next_owner() leaves
>>
>> grace period
>> 					user count drops, call mmput(mm)
>> task 1 freed
>> 					dereferencing mm->owner fails
> 
> Yes, that looks right to me: seems obvious now.  I don't think your
> careful alternation of CPU0/1 events at the end matters: the swapoff
> CPU simply dereferences mm->owner after that task has gone.
> 
> (That's a shame, I'd always hoped that mm->owner->comm was going to
> be good for use in mm messages, even when tearing down the mm.)
> 

Hi, Hugh,

I do have fixes for the problem above, but I've run into something strange. I
see that when I create a new cgroup and set 500M as it's limit and run kernbench
under it, I see a strange problem

1. memrlimit determines that limit is exceeded and fails the fork of the new process
2. The process that failed to fork, encounters a page fault and faults in find_vma

I tried chasing the problem, but I am lost wondering how a page fault
(do_page_fault) can occur in a process that has not yet been created and is
going to fail with -ENOMEM. The interesting thing is that the OOPS occurs in
find_vma

My trace so far
----------------

limit exceeded
Pid: 3695, comm: sh Not tainted 2.6.27-rc1-mm1 #12

Call Trace:
 [<ffffffff802b0473>] memrlimit_cgroup_charge_as+0x3a/0x3c
 [<ffffffff8023a82f>] dup_mm+0xea/0x410
 [<ffffffff8023b648>] copy_process+0xabe/0x12ef
 [<ffffffff8023c0df>] do_fork+0x114/0x2d2
 [<ffffffff8025b42c>] ? trace_hardirqs_on_caller+0xf9/0x124
 [<ffffffff8025b464>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff805bda1f>] ? _spin_unlock_irq+0x2b/0x30
 [<ffffffff805bd24e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff8020bf4b>] ? system_call_fastpath+0x16/0x1b
 [<ffffffff8020a44a>] sys_clone+0x23/0x25
 [<ffffffff8020c2c7>] ptregscall_common+0x67/0xb0

putting mm ffff88003d931400 3695 sh
copy_mm, retval -12
copy_process returning -12
copy_process returned fffffffffffffff4 -12
fork failed -12
general protection fault: 0000 [1] copy_process returned ffff880037a11600 -13194
0462029312
SMP
last sysfs file: /sys/block/sda/size
CPU 2
Modules linked in: coretemp hwmon kvm_intel kvm rtc_cmos rtc_core rtc_lib mptsas
 mptscsih mptbase scsi_transport_sas uhci_hcd ohci_hcd ehci_hcd
Pid: 3695, comm: sh Not tainted 2.6.27-rc1-mm1 #12
RIP: 0010:[<ffffffff802954f8>]  [<ffffffff802954f8>] find_vma+0x2f/0x62
RSP: 0000:ffff88003544bee8  EFLAGS: 00010202
RAX: 6b6b6b6b6b6b6b6b RBX: 0000000000000000 RCX: ffff8800399e34d8
RDX: ffff8800399e34d8 RSI: 0000003a2729ad22 RDI: ffff88003e5c8500
RBP: ffff88003544bee8 R08: 0000000000000000 R09: 0000000000000000
R10: ffff88003e5c8568 R11: 0000000000000246 R12: 0000003a2729ad22
R13: 0000000000000014 R14: ffff88003544bf58 R15: ffff88003e8bac00
FS:  00002b3b978f3f50(0000) GS:ffff8800bfd954b0(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000003a2729ad22 CR3: 000000003549f000 CR4: 00000000000026e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process sh (pid: 3695, threadinfo ffff88003544a000, task ffff88003e8bac00)
Stack:  ffff88003544bf48 ffffffff805bfec0 00000000ffffffff 00000000008cae50
 ffff88003e5c8560 ffff88003e5c8500 0003000100000000 0000000000000000
 00007fff131e72c0 00000000ffffffff 00000000008cae50 0000000000000000
Call Trace:
 [<ffffffff805bfec0>] do_page_fault+0x36f/0x7ad
 [<ffffffff805bdd4d>] error_exit+0x0/0xa9


Code: 85 ff 48 89 e5 74 55 eb 05 48 89 ca eb 47 48 8b 47 10 48 85 c0 74 0c 48 39
 70 10 76 06 48 39 70 08 76 39 48 8b 47 08 31 d2 eb 1d <48> 39 70 e0 48 8d 48 d0
 76 0f 48 39 70 d8 76 ce 48 8b 40 10 48
RIP  [<ffffffff802954f8>] find_vma+0x2f/0x62
 RSP <ffff88003544bee8>

---[ end trace 89156336afdfaec3 ]---

I hope that I'll be able to think more clearly on Monday, but it's hard to say :)

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
