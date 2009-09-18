From: Rishikesh <risrajak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 14150] New: BUG: soft lockup - CPU#3 stuck	for
	61s!, while running cpu controller latency testcase on two	containers
	parallaly
Date: Fri, 18 Sep 2009 13:56:45 +0530
Message-ID: <4AB34445.4060700__23015.4091296301$1253262713$gmane$org@linux.vnet.ibm.com>
References: <bug-14150-10286@http.bugzilla.kernel.org/>
	<20090911142813.dc823bf1.akpm@linux-foundation.org>
	<20090915125836.GA4087@linux.vnet.ibm.com>
	<4AB20086.8070105@linux.vnet.ibm.com>
	<4AB32EA7.20904@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AB32EA7.20904-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: iranna.ankad-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, markwiz-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, Bharata B Rao <bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, lxie-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, sharyath-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, santwana.samantray-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

I am able to reproduce this bug on F12-Alpha on 64 bit machine also. So 
looks like it is a sever bug which need early fix.
For all at same page, i am rewriting the steps once again.

- Create two container using lxc tool. ( used lxc-0.6.3).
    lxc-execute -n foo1 -f /usr/etc/lxc/lxc-macvlan.conf /bin/bash
    lxc-execute -n foo2 -f /usr/etc/lxc/lxc-complex-config /bin/bash

- Compile and run ltp controller testcase inside both container.
- once it runs cpu latency testcase you can observe the trace.

-Rishi

BUG: soft lockup - CPU#1 stuck for 61s! [cpuctl_latency_:27296]
Modules linked in: veth fuse tun ipt_MASQUERADE iptable_nat nf_nat 
bridge stp llc nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipv6 
p4_clockmod freq_table speedstep_lib dm_multipath kvm_intel kvm uinput 
ibmpex ibmaem ipmi_msghandler ics932s401 iTCO_wdt iTCO_vendor_support 
joydev serio_raw i2c_i801 bnx2 ses enclosure i5k_amb hwmon igb shpchp 
i5000_edac edac_core dca aacraid radeon ttm drm_kms_helper drm 
i2c_algo_bit i2c_core [last unloaded: freq_table]
irq event stamp: 0
hardirqs last  enabled at (0): [<(null)>] (null)
hardirqs last disabled at (0): [<ffffffff81062500>] 
copy_process+0x5b9/0x1478
softirqs last  enabled at (0): [<ffffffff81062500>] 
copy_process+0x5b9/0x1478
softirqs last disabled at (0): [<(null)>] (null)
CPU 1:
Modules linked in: veth fuse tun ipt_MASQUERADE iptable_nat nf_nat 
bridge stp llc nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipv6 
p4_clockmod freq_table speedstep_lib dm_multipath kvm_intel kvm uinput 
ibmpex ibmaem ipmi_msghandler ics932s401 iTCO_wdt iTCO_vendor_support 
joydev serio_raw i2c_i801 bnx2 ses enclosure i5k_amb hwmon igb shpchp 
i5000_edac edac_core dca aacraid radeon ttm drm_kms_helper drm 
i2c_algo_bit i2c_core [last unloaded: freq_table]
Pid: 27296, comm: cpuctl_latency_ Tainted: G        W  
2.6.31-14.fc12.x86_64 #1 IBM System x3550 -[7978C5Z]-
RIP: 0010:[<ffffffff81276dff>]  [<ffffffff81276dff>] find_next_bit+0x5b/0xc3
RSP: 0000:ffff8800047e1c50  EFLAGS: 00000286
RAX: 0000000000000000 RBX: ffff8800047e1c60 RCX: 0000000000000004
RDX: 0000000000000004 RSI: 0000000000000200 RDI: 0000000000000200
RBP: ffffffff81012bf3 R08: 0000000000000000 R09: ffff8800047ede88
R10: 0000000000000000 R11: 0000000000000000 R12: ffff8800047e1bd0
R13: 0000000000000400 R14: ffff8800392bb6c0 R15: 00000000096981ea
FS:  00007f395ff0e700(0000) GS:ffff8800047de000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fbfb98f0db0 CR3: 000000000d394000 CR4: 00000000000026f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Call Trace:
 <IRQ>  [<ffffffff8104eb31>] ? cpumask_next+0x30/0x46
 [<ffffffff81054442>] ? tg_shares_up+0x17b/0x1af
 [<ffffffff810542c7>] ? tg_shares_up+0x0/0x1af
 [<ffffffff81049447>] ? tg_nop+0x0/0x32
 [<ffffffff8104f708>] ? walk_tg_tree+0x8e/0xca
 [<ffffffff8104f682>] ? walk_tg_tree+0x8/0xca
 [<ffffffff810579fc>] ? update_shares+0x59/0x74
 [<ffffffff8105c8e7>] ? rebalance_domains+0x178/0x599
 [<ffffffff81085a1b>] ? hrtimer_interrupt+0x158/0x183
 [<ffffffff8109602f>] ? trace_hardirqs_on_caller+0x32/0x175
 [<ffffffff8105cd60>] ? run_rebalance_domains+0x58/0xf6
 [<ffffffff815063eb>] ? _spin_unlock_irq+0x3f/0x61
 [<ffffffff8106bf96>] ? __do_softirq+0xf6/0x1f0
 [<ffffffff81095123>] ? trace_hardirqs_off_caller+0x32/0xd0
 [<ffffffff8101322c>] ? call_softirq+0x1c/0x30
 [<ffffffff81014d77>] ? do_softirq+0x5f/0xd7
 [<ffffffff8106b8ad>] ? irq_exit+0x66/0xbc
 [<ffffffff8102b724>] ? smp_apic_timer_interrupt+0x99/0xbf
 [<ffffffff81012bf3>] ? apic_timer_interrupt+0x13/0x20
 <EOI>


Rishikesh wrote:
> Rishikesh wrote:
>   
>> Dhaval Giani wrote:
>>     
>>> On Fri, Sep 11, 2009 at 02:28:13PM -0700, Andrew Morton wrote:
>>>  
>>>       
>>>> (switched to email.  Please respond via emailed reply-to-all, not 
>>>> via the
>>>> bugzilla web interface).
>>>>
>>>> On Thu, 10 Sep 2009 09:32:30 GMT
>>>> bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:
>>>>
>>>>    
>>>>         
>>>>> http://bugzilla.kernel.org/show_bug.cgi?id=14150
>>>>>
>>>>>            Summary: BUG: soft lockup - CPU#3 stuck for 61s!, while 
>>>>> running
>>>>>                     cpu controller latency testcase on two containers
>>>>>                     parallaly
>>>>>            Product: Process Management
>>>>>            Version: 2.5
>>>>>     Kernel Version: 2.6.31-rc7
>>>>>           Platform: All
>>>>>         OS/Version: Linux
>>>>>               Tree: Mainline
>>>>>             Status: NEW
>>>>>           Severity: high
>>>>>           Priority: P1
>>>>>          Component: Scheduler
>>>>>         AssignedTo: mingo-X9Un+BFzKDI@public.gmane.org
>>>>>         ReportedBy: risrajak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
>>>>>                 CC: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, iranna.ankad-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org,
>>>>>                     risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org
>>>>>         Regression: No
>>>>>
>>>>>
>>>>> Created an attachment (id=23055)
>>>>>  --> (http://bugzilla.kernel.org/attachment.cgi?id=23055)
>>>>> Config-file-used
>>>>>
>>>>> Hitting this soft lock issue while running this scenario on 
>>>>> 2.6.31-rc7 kernel
>>>>> on SystemX 32 bit on multiple machines.
>>>>>
>>>>> Scenario:
>>>>>     - While running cpu controller latency testcase from LTP same 
>>>>> time on two
>>>>> containers.
>>>>>
>>>>> Steps:
>>>>> 1. Compile ltp-full-20090731.tgz on host.
>>>>> 2. Create two container (Used lxc tool
>>>>> (http://sourceforge.net/projects/lxc/lxc-0.6.3.tar.gz) for creating 
>>>>> container )
>>>>> e.g:
>>>>>     lxc-create -n foo1
>>>>>     lxc-create -n foo2
>>>>> On first shell:
>>>>>     lxc-execute -n foo1 -f /usr/etc/lxc/lxc-macvlan.conf /bin/bash
>>>>> on Second shell:
>>>>>     lxc-execute -n foo2 -f /usr/etc/lxc/lxc-macvlan.conf /bin/bash
>>>>>
>>>>> 3. Either you run cpu_latency testcase alone or run "./runltp -f 
>>>>> controllers"
>>>>> at same time on both the containers.
>>>>> 4. After testcase execution completes, you can see this message in 
>>>>> dmesg.
>>>>>
>>>>> Expected Result:
>>>>>     - Should not reproduce soft lock up issue.
>>>>> - This reproduces 3 times out of 5 tries.
>>>>>
>>>>> hrtimer: interrupt too slow, forcing clock min delta to 5843235 ns
>>>>> hrtimer: interrupt too slow, forcing clock min delta to 5842476 ns
>>>>> Clocksource tsc unstable (delta = 18749057581 ns)
>>>>> BUG: soft lockup - CPU#3 stuck for 61s! [cpuctl_latency_:17174]
>>>>> Modules linked in: bridge stp llc bnep sco l2cap bluetooth sunrpc ipv6
>>>>> p4_clockmod dm_multipath uinput qla2xxx ata_generic pata_acpi 
>>>>> usb_storage e1000
>>>>> scsi_transport_fc joydev scsi_tgt i2c_piix4 pata_serverworks pcspkr 
>>>>> serio_raw
>>>>> mptspi mptscsih mptbase scsi_transport_spi radeon ttm drm 
>>>>> i2c_algo_bit i2c_core
>>>>> [last unloaded: scsi_wait_scan]
>>>>>
>>>>> Pid: 17174, comm: cpuctl_latency_ Tainted: G        W  (2.6.31-rc7 
>>>>> #1) IBM
>>>>> eServer BladeCenter HS40 -[883961X]-                    EIP: 
>>>>> 0060:[<c058aded>] EFLAGS: 00000283 CPU: 3
>>>>> EIP is at find_next_bit+0x9/0x79
>>>>> EAX: c2c437a0 EBX: f3d433c0 ECX: 00000000 EDX: 00000020
>>>>> ESI: c2c436bc EDI: 00000000 EBP: f063be6c ESP: f063be64
>>>>>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
>>>>> CR0: 80050033 CR2: 008765a4 CR3: 314d7000 CR4: 000006d0
>>>>> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
>>>>> DR6: ffff0ff0 DR7: 00000400
>>>>> Call Trace:
>>>>>  [<c0427b6e>] cpumask_next+0x17/0x19
>>>>>  [<c042c28d>] tg_shares_up+0x53/0x149
>>>>>  [<c0424082>] ? tg_nop+0x0/0xc
>>>>>  [<c0424082>] ? tg_nop+0x0/0xc
>>>>>  [<c042406e>] walk_tg_tree+0x63/0x77
>>>>>  [<c042c23a>] ? tg_shares_up+0x0/0x149
>>>>>  [<c042e836>] update_shares+0x5d/0x65
>>>>>  [<c0432af3>] rebalance_domains+0x114/0x460
>>>>>  [<c0403393>] ? restore_all_notrace+0x0/0x18
>>>>>  [<c0432e75>] run_rebalance_domains+0x36/0xa3
>>>>>  [<c043c324>] __do_softirq+0xbc/0x173
>>>>>  [<c043c416>] do_softirq+0x3b/0x5f
>>>>>  [<c043c52d>] irq_exit+0x3a/0x68
>>>>>  [<c0417846>] smp_apic_timer_interrupt+0x6d/0x7b
>>>>>  [<c0403c9b>] apic_timer_interrupt+0x2f/0x34
>>>>> BUG: soft lockup - CPU#2 stuck for 61s! [watchdog/2:11]
>>>>> Modules linked in: bridge stp llc bnep sco l2cap bluetooth sunrpc ipv6
>>>>> p4_clockmod dm_multipath uinput qla2xxx ata_generic pata_acpi 
>>>>> usb_storage e1000
>>>>> scsi_transport_fc joydev scsi_tgt i2c_piix4 pata_serverworks pcspkr 
>>>>> serio_raw
>>>>> mptspi mptscsih mptbase scsi_transport_spi radeon ttm drm 
>>>>> i2c_algo_bit i2c_core
>>>>> [last unloaded: scsi_wait_scan]
>>>>>
>>>>> Pid: 11, comm: watchdog/2 Tainted: G        W  (2.6.31-rc7 #1) IBM 
>>>>> eServer
>>>>> BladeCenter HS40 -[883961X]-                    EIP: 
>>>>> 0060:[<c042c313>] EFLAGS: 00000246 CPU: 2
>>>>> EIP is at tg_shares_up+0xd9/0x149
>>>>> EAX: 00000000 EBX: f09b3c00 ECX: f0baac00 EDX: 00000100
>>>>> ESI: 00000002 EDI: 00000400 EBP: f6cb7de0 ESP: f6cb7db8
>>>>>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
>>>>> CR0: 8005003b CR2: 08070680 CR3: 009c8000 CR4: 000006d0
>>>>> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
>>>>> DR6: ffff0ff0 DR7: 00000400
>>>>> Call Trace:
>>>>>  [<c0424082>] ? tg_nop+0x0/0xc
>>>>>  [<c0424082>] ? tg_nop+0x0/0xc
>>>>>  [<c042406e>] walk_tg_tree+0x63/0x77
>>>>>  [<c042c23a>] ? tg_shares_up+0x0/0x149
>>>>>  [<c042e836>] update_shares+0x5d/0x65
>>>>>  [<c0432af3>] rebalance_domains+0x114/0x460
>>>>>  [<c0432e75>] run_rebalance_domains+0x36/0xa3
>>>>>  [<c043c324>] __do_softirq+0xbc/0x173
>>>>>  [<c043c416>] do_softirq+0x3b/0x5f
>>>>>  [<c043c52d>] irq_exit+0x3a/0x68
>>>>>  [<c0417846>] smp_apic_timer_interrupt+0x6d/0x7b
>>>>>  [<c0403c9b>] apic_timer_interrupt+0x2f/0x34
>>>>>  [<c0430d37>] ? finish_task_switch+0x5d/0xc4
>>>>>  [<c0744b11>] schedule+0x74c/0x7b2
>>>>>  [<c0590e28>] ? trace_hardirqs_on_thunk+0xc/0x10
>>>>>  [<c0403393>] ? restore_all_notrace+0x0/0x18
>>>>>  [<c0471e19>] ? watchdog+0x0/0x79
>>>>>  [<c0471e19>] ? watchdog+0x0/0x79
>>>>>  [<c0471e63>] watchdog+0x4a/0x79
>>>>>  [<c0449a53>] kthread+0x70/0x75
>>>>>  [<c04499e3>] ? kthread+0x0/0x75
>>>>>  [<c0403e93>] kernel_thread_helper+0x7/0x10
>>>>> [root@hs40 ltp-full-20090731]# uname -a
>>>>> Linux hs40.in.ibm.com 2.6.31-rc7 #1 SMP Thu Sep 3 10:14:41 IST 2009 
>>>>> i686 i686
>>>>> i386 GNU/Linux
>>>>> [root@hs40 ltp-full-20090731]#
>>>>>
>>>>>       
>>>>>           
>>> We have been unable to reproduce it on current -tip. Rishi, are you able
>>> to reproduce it on -tip?
>>>
>>> thanks,
>>>   
>>>       
>> I am not able to create container with lxc on -tip kernel with config 
>> file attached. As soon as i am executing "lxc-execute ..." it hangs 
>> and only way to recover is to hard reboot system.
>>     
>
> enabled the nmi_watchdog on tip kernel and found this call trace on 
> system while executing "lxc-execute ..." command ( creating container).
>
> x335a.in.ibm.com login: BUG: NMI Watchdog detected LOCKUP on CPU1, ip 
> c075f208, registers:
> Modules linked in: nfs lockd nfs_acl auth_rpcgss bridge stp llc bnep sco 
> l2cap bluetooth autofs4 sunrpc ipv6 p4_clockmod dm_multipath uinput 
> ata_generic pata_acpi pata_serverworks i2c_piix4 floppy tg3 i2c_core 
> pcspkr serio_raw mptspi mptscsih mptbase scsi_transport_spi [last 
> unloaded: scsi_wait_scan]
>
> Pid: 0, comm: swapper Not tainted (2.6.31-tip #2) eserver xSeries 335 
> -[867641X]-
> EIP: 0060:[<c075f208>] EFLAGS: 00000097 CPU: 1
> EIP is at _spin_lock_irqsave+0x2b/0x39
> EAX: 00002625 EBX: c3128e00 ECX: 00000000 EDX: 00000200
> ESI: 00000086 EDI: 00000400 EBP: f70a9d58 ESP: f70a9d50
>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process swapper (pid: 0, ti=f70a8000 task=f7086780 task.ti=f70a8000)
> Stack:
>  f6461a80 00000001 f70a9d94 c043335a 00000200 00000400 c31243d8 c3124350
> <0> c31244c0 c3128e00 c09f3e00 00000086 00000001 00000800 f6461a80 c31243d8
> <0> c042c0d4 f70a9dac c042c0c0 c0433226 c31243d8 000b71b0 00000000 f70a9dd0
> Call Trace:
>  [<c043335a>] ? tg_shares_up+0x134/0x1bb
>  [<c042c0d4>] ? tg_nop+0x0/0xc
>  [<c042c0c0>] ? walk_tg_tree+0x63/0x77
>  [<c0433226>] ? tg_shares_up+0x0/0x1bb
>  [<c04328f4>] ? update_shares+0x69/0x71
>  [<c04335ec>] ? select_task_rq_fair+0x153/0x5dc
>  [<c043b905>] ? try_to_wake_up+0x7f/0x28a
>  [<c043bb20>] ? default_wake_function+0x10/0x12
>  [<c042ce2d>] ? __wake_up_common+0x37/0x5e
>  [<c0430d62>] ? complete+0x30/0x43
>  [<c0453281>] ? wakeme_after_rcu+0x10/0x12
>  [<c0482997>] ? __rcu_process_callbacks+0x141/0x201
>  [<c0482a7c>] ? rcu_process_callbacks+0x25/0x44
>  [<c0445167>] ? __do_softirq+0xbc/0x173
>  [<c0445259>] ? do_softirq+0x3b/0x5f
>  [<c0445371>] ? irq_exit+0x3a/0x6d
>  [<c041dd82>] ? smp_apic_timer_interrupt+0x6d/0x7b
>  [<c0408d7b>] ? apic_timer_interrupt+0x2f/0x34
>  [<c0425854>] ? native_safe_halt+0xa/0xc
>  [<c040e63b>] ? default_idle+0x4a/0x7c
>  [<c0460b8d>] ? tick_nohz_restart_sched_tick+0x115/0x123
>  [<c0407637>] ? cpu_idle+0x58/0x79
>  [<c075a578>] ? start_secondary+0x19c/0x1a1
> Code: 55 89 e5 56 53 0f 1f 44 00 00 89 c3 9c 58 8d 74 26 00 89 c6 fa 90 
> 8d 74 26 00 e8 96 2b d3 ff b8 00 01 00 00 f0 66 0f c1 03 38 e0 <74> 06 
> f3 90 8a 03 eb f6 89 f0 5b 5e 5d c3 55 89 e5 53 0f 1f 44
> ---[ end trace 8a14be6828557ade ]---
> Kernel panic - not syncing: Non maskable interrupt
> Pid: 0, comm: swapper Tainted: G      D    2.6.31-tip #2
> Call Trace:
>  [<c075d4b7>] ? printk+0x14/0x1d
>  [<c075d3fc>] panic+0x3e/0xe5
>  [<c075fe2a>] die_nmi+0x86/0xd8
>  [<c0760324>] nmi_watchdog_tick+0x107/0x16e
>  [<c075f8bf>] do_nmi+0xa3/0x27f
>  [<c075f485>] nmi_stack_correct+0x28/0x2d
>  [<c075f208>] ? _spin_lock_irqsave+0x2b/0x39
>  [<c043335a>] tg_shares_up+0x134/0x1bb
>  [<c042c0d4>] ? tg_nop+0x0/0xc
>  [<c042c0c0>] walk_tg_tree+0x63/0x77
>  [<c0433226>] ? tg_shares_up+0x0/0x1bb
>  [<c04328f4>] update_shares+0x69/0x71
>  [<c04335ec>] select_task_rq_fair+0x153/0x5dc
>  [<c043b905>] try_to_wake_up+0x7f/0x28a
>  [<c043bb20>] default_wake_function+0x10/0x12
>  [<c042ce2d>] __wake_up_common+0x37/0x5e
>  [<c0430d62>] complete+0x30/0x43
>  [<c0453281>] wakeme_after_rcu+0x10/0x12
>  [<c0482997>] __rcu_process_callbacks+0x141/0x201
>  [<c0482a7c>] rcu_process_callbacks+0x25/0x44
>  [<c0445167>] __do_softirq+0xbc/0x173
>  [<c0445259>] do_softirq+0x3b/0x5f
>  [<c0445371>] irq_exit+0x3a/0x6d
>  [<c041dd82>] smp_apic_timer_interrupt+0x6d/0x7b
>  [<c0408d7b>] apic_timer_interrupt+0x2f/0x34
>  [<c0425854>] ? native_safe_halt+0xa/0xc
>  [<c040e63b>] default_idle+0x4a/0x7c
>  [<c0460b8d>] ? tick_nohz_restart_sched_tick+0x115/0x123
>  [<c0407637>] cpu_idle+0x58/0x79
>  [<c075a578>] start_secondary+0x19c/0x1a1
> Rebooting in 1 seconds..
>
>
>   
>> I am not sure about tip but i am able to create the problem pretty 
>> easily on 2.6.31-rc7 with that config file.
>>
>> Only the changes i have done in the config file from (2.6.31-rc7) is :
>>    - Disabled KVM as it was giving me error on -tip kernel.
>>    - Applied following patch : 
>> http://www.gossamer-threads.com/lists/linux/kernel/1129527
>>
>> Please let me know if you are able to recreate it on -tip with 
>> following config.
>> ------------------------------------------------------------------------
>>
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linux-foundation.org/mailman/listinfo/containers
>>     
>
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
>   
