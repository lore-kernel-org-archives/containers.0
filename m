From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: BUG: soft lockup - CPU#3 stuck for 61s! , while running cpu
	controller latency testcase on two containers parallaly
Date: Fri, 11 Sep 2009 16:55:04 +0530
Message-ID: <20090911112504.GI4474@linux.vnet.ibm.com>
References: <4AA8C7E2.1080002@linux.vnet.ibm.com>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753150AbZIKLZy@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AA8C7E2.1080002@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Rishikesh <risrajak@linux.vnet.ibm.com>
Cc: containers@lists.osdl.org, linux-kernel@vger.kernel.org, iranna.ankad@in.ibm.com, bharanga@in.ibm.com, sharyath@linux.vnet.ibm.com, risrajak@in.ibm.com, bharata.rao@in.ibm.com, mbeeraka@in.ibm.com, svishuku@in.ibm.com, santwana.samantray@in.ibm.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-Id: containers.vger.kernel.org

[Adding the scheduler maintainers to the cc]

On Thu, Sep 10, 2009 at 03:03:22PM +0530, Rishikesh wrote:
> Hi,
> 
> I am hitting this soft lock issue while running this scenario on 
> 2.6.31-rc7 kernel on SystemX 32 bit on multiple machines.
> 
> Opened bug : http://bugzilla.kernel.org/show_bug.cgi?id=14150
> 
> Scenario:
>     - While running cpu controller latency testcase from LTP same time 
> on two containers.
> 
> Steps:
> 1. Create two container e.g:
>     lxc-execute -n foo1 -f /usr/etc/lxc/lxc-macvlan.conf /bin/bash
>     lxc-execute -n foo2 -f /usr/etc/lxc/lxc-macvlan.conf /bin/bash
> 2. Compile ltp-full-20090731.tgz on host.
> 3. Either you run cpu_latency testcase alone or run "./runltp -f 
> controllers" at same time on both the containers.
> 4. After testcase execution completes, you can see this message in dmesg.
> 
> Expected Result:
>     - Should not reproduce soft lock up issue.
> - This reproduces 3 times out of 5 tries.
> 
> hrtimer: interrupt too slow, forcing clock min delta to 5843235 ns
> hrtimer: interrupt too slow, forcing clock min delta to 5842476 ns
> Clocksource tsc unstable (delta = 18749057581 ns)
> BUG: soft lockup - CPU#3 stuck for 61s! [cpuctl_latency_:17174]
> Modules linked in: bridge stp llc bnep sco l2cap bluetooth sunrpc ipv6 
> p4_clockmod dm_multipath uinput qla2xxx ata_generic pata_acpi 
> usb_storage e1000 scsi_transport_fc joydev scsi_tgt i2c_piix4 
> pata_serverworks pcspkr serio_raw mptspi mptscsih mptbase 
> scsi_transport_spi radeon ttm drm i2c_algo_bit i2c_core [last unloaded: 
> scsi_wait_scan]
> 
> Pid: 17174, comm: cpuctl_latency_ Tainted: G        W  (2.6.31-rc7 #1) 
> IBM eServer BladeCenter HS40 -[883961X]-                    
> EIP: 0060:[<c058aded>] EFLAGS: 00000283 CPU: 3
> EIP is at find_next_bit+0x9/0x79
> EAX: c2c437a0 EBX: f3d433c0 ECX: 00000000 EDX: 00000020
> ESI: c2c436bc EDI: 00000000 EBP: f063be6c ESP: f063be64
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> CR0: 80050033 CR2: 008765a4 CR3: 314d7000 CR4: 000006d0
> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> DR6: ffff0ff0 DR7: 00000400
> Call Trace:
>  [<c0427b6e>] cpumask_next+0x17/0x19
>  [<c042c28d>] tg_shares_up+0x53/0x149
>  [<c0424082>] ? tg_nop+0x0/0xc
>  [<c0424082>] ? tg_nop+0x0/0xc
>  [<c042406e>] walk_tg_tree+0x63/0x77
>  [<c042c23a>] ? tg_shares_up+0x0/0x149
>  [<c042e836>] update_shares+0x5d/0x65
>  [<c0432af3>] rebalance_domains+0x114/0x460
>  [<c0403393>] ? restore_all_notrace+0x0/0x18
>  [<c0432e75>] run_rebalance_domains+0x36/0xa3
>  [<c043c324>] __do_softirq+0xbc/0x173
>  [<c043c416>] do_softirq+0x3b/0x5f
>  [<c043c52d>] irq_exit+0x3a/0x68
>  [<c0417846>] smp_apic_timer_interrupt+0x6d/0x7b
>  [<c0403c9b>] apic_timer_interrupt+0x2f/0x34
> BUG: soft lockup - CPU#2 stuck for 61s! [watchdog/2:11]
> Modules linked in: bridge stp llc bnep sco l2cap bluetooth sunrpc ipv6 
> p4_clockmod dm_multipath uinput qla2xxx ata_generic pata_acpi 
> usb_storage e1000 scsi_transport_fc joydev scsi_tgt i2c_piix4 
> pata_serverworks pcspkr serio_raw mptspi mptscsih mptbase 
> scsi_transport_spi radeon ttm drm i2c_algo_bit i2c_core [last unloaded: 
> scsi_wait_scan]
> 
> Pid: 11, comm: watchdog/2 Tainted: G        W  (2.6.31-rc7 #1) IBM 
> eServer BladeCenter HS40 -[883961X]-                    
> EIP: 0060:[<c042c313>] EFLAGS: 00000246 CPU: 2
> EIP is at tg_shares_up+0xd9/0x149
> EAX: 00000000 EBX: f09b3c00 ECX: f0baac00 EDX: 00000100
> ESI: 00000002 EDI: 00000400 EBP: f6cb7de0 ESP: f6cb7db8
>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> CR0: 8005003b CR2: 08070680 CR3: 009c8000 CR4: 000006d0
> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> DR6: ffff0ff0 DR7: 00000400
> Call Trace:
>  [<c0424082>] ? tg_nop+0x0/0xc
>  [<c0424082>] ? tg_nop+0x0/0xc
>  [<c042406e>] walk_tg_tree+0x63/0x77
>  [<c042c23a>] ? tg_shares_up+0x0/0x149
>  [<c042e836>] update_shares+0x5d/0x65
>  [<c0432af3>] rebalance_domains+0x114/0x460
>  [<c0432e75>] run_rebalance_domains+0x36/0xa3
>  [<c043c324>] __do_softirq+0xbc/0x173
>  [<c043c416>] do_softirq+0x3b/0x5f
>  [<c043c52d>] irq_exit+0x3a/0x68
>  [<c0417846>] smp_apic_timer_interrupt+0x6d/0x7b
>  [<c0403c9b>] apic_timer_interrupt+0x2f/0x34
>  [<c0430d37>] ? finish_task_switch+0x5d/0xc4
>  [<c0744b11>] schedule+0x74c/0x7b2
>  [<c0590e28>] ? trace_hardirqs_on_thunk+0xc/0x10
>  [<c0403393>] ? restore_all_notrace+0x0/0x18
>  [<c0471e19>] ? watchdog+0x0/0x79
>  [<c0471e19>] ? watchdog+0x0/0x79
>  [<c0471e63>] watchdog+0x4a/0x79
>  [<c0449a53>] kthread+0x70/0x75
>  [<c04499e3>] ? kthread+0x0/0x75
>  [<c0403e93>] kernel_thread_helper+0x7/0x10
> [root@hs40 ltp-full-20090731]# uname -a
> Linux hs40.in.ibm.com 2.6.31-rc7 #1 SMP Thu Sep 3 10:14:41 IST 2009 i686 
> i686 i386 GNU/Linux
> [root@hs40 ltp-full-20090731]#

thanks,
-- 
regards,
Dhaval
