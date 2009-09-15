From: Sharyathi Nagesh <sharyath@in.ibm.com>
Subject: Re: BUG: soft lockup - CPU#3 stuck for 61s! , while running cpu controller
 latency testcase on two containers parallaly
Date: Tue, 15 Sep 2009 19:42:03 +0530
Message-ID: <4AAFA0B3.4050805@in.ibm.com>
References: <4AA8C7E2.1080002@linux.vnet.ibm.com> <20090911112504.GI4474@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754393AbZIOOMI@vger.kernel.org>
In-Reply-To: <20090911112504.GI4474@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Cc: Rishikesh <risrajak@linux.vnet.ibm.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, iranna.ankad@in.ibm.com, bharanga@in.ibm.com, sharyath@linux.vnet.ibm.com, risrajak@in.ibm.com, bharata.rao@in.ibm.com, mbeeraka@in.ibm.com, svishuku@in.ibm.com, santwana.samantray@in.ibm.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-Id: containers.vger.kernel.org


The same problem was observed while testing with 2.6.29 kernel, this is what I could gather 
from looking into the error message,

Dhaval Giani wrote:
> [Adding the scheduler maintainers to the cc]
> 
>> BUG: soft lockup - CPU#3 stuck for 61s! [cpuctl_latency_:17174]
>> Modules linked in: bridge stp llc bnep sco l2cap bluetooth sunrpc ipv6 
>> p4_clockmod dm_multipath uinput qla2xxx ata_generic pata_acpi 
>> usb_storage e1000 scsi_transport_fc joydev scsi_tgt i2c_piix4 
>> pata_serverworks pcspkr serio_raw mptspi mptscsih mptbase 
>> scsi_transport_spi radeon ttm drm i2c_algo_bit i2c_core [last unloaded: 
>> scsi_wait_scan]
>>
>> Pid: 17174, comm: cpuctl_latency_ Tainted: G        W  (2.6.31-rc7 #1) 
>> IBM eServer BladeCenter HS40 -[883961X]-                    
>> EIP: 0060:[<c058aded>] EFLAGS: 00000283 CPU: 3
>> EIP is at find_next_bit+0x9/0x79
>> EAX: c2c437a0 EBX: f3d433c0 ECX: 00000000 EDX: 00000020
>> ESI: c2c436bc EDI: 00000000 EBP: f063be6c ESP: f063be64
>>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
>> CR0: 80050033 CR2: 008765a4 CR3: 314d7000 CR4: 000006d0
>> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
>> DR6: ffff0ff0 DR7: 00000400
>> Call Trace:
>>  [<c0427b6e>] cpumask_next+0x17/0x19


EIP matches to 'tg_shares_up+0xd9/0x149',
-----------------------
   This maps to address location 5c37 in the objdump
/root/rpmbuild/BUILD/kernel-2.6.29/linux-2.6.29.i686/kernel/sched.c:1511

         if (abs(shares - tg->se[cpu]->load.weight) >
     5c33:       89 d0                   mov    %edx,%eax
     5c35:       2b 01                   sub    (%ecx),%eax
     5c37:       89 c1                   mov    %eax,%ecx
     5c39:       c1 f9 1f                sar    $0x1f,%ecx
     5c3c:       31 c8                   xor    %ecx,%eax
     5c3e:       29 c8                   sub    %ecx,%eax
     5c40:       3b 05 00 00 00 00       cmp    0x0,%eax
     5c46:       76 3d                   jbe    5c85 <tg_shares_up+0x127>
/root/rpmbuild/BUILD/kernel-2.6.29/linux-2.6.29.i686/kernel/sched.c:1516
                         sysctl_sched_shares_thresh) {
                 struct rq *rq = cpu_rq(cpu);
-----------------------
This matches to line 1511 - 1516 in the kernel code

1511                if (abs(shares - tg->se[cpu]->load.weight) >
1512                         sysctl_sched_shares_thresh) {
1513                 struct rq *rq = cpu_rq(cpu);
1514                 unsigned long flags;
1515
1516                 spin_lock_irqsave(&rq->lock, flags);
-----------------------
I suspect this soft lock ups are due to rq->lock contention.
Thanks
Sharyathi
