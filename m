From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 11391] New: Kernel NULL pointer dereference in
	do_notify_parent()
Date: Thu, 21 Aug 2008 09:23:22 -0700
Message-ID: <20080821092322.76621dab.akpm@linux-foundation.org>
References: <bug-11391-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <bug-11391-10286-V0hAGp6uBxO456/isadD/XN4h3HLQggn@public.gmane.org/>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, robert.rex-GD4dBWQXeU/QT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 21 Aug 2008 05:58:52 -0700 (PDT) bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11391
> 
>            Summary: Kernel NULL pointer dereference in do_notify_parent()
>            Product: Process Management
>            Version: 2.5
>      KernelVersion: 2.6.26.3

Should have been 2.6.26.4?

>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: process_other-ztI5WcYan/vQLgFONoPN62D2FQJk+8+b@public.gmane.org
>         ReportedBy: robert.rex-GD4dBWQXeU/QT0dZR+AlfA@public.gmane.org
> 
> 
> Latest working kernel version: 2.6.26.3
> 
> Earliest failing kernel version: 2.6.25.4 (didn't test with former kernels)

Appears to be a regression in -stable.   Did any namespacy things go into
2.6.26.4?

> Distribution: CentOS 5.1 (with Vanilla kernel from kernel.org)
> 
> Hardware Environment: several x86_64 plattforms (AMD Opteron, Intel Xeon)
> 
> Problem Description:
> -------------------------------------
> BUG: unable to handle kernel NULL pointer dereference at virtual address
> 0000000000000020
> IP: [<ffffffff8023d5d0>] do_notify_parent+0x66/0x194
> PGD 0
> Oops: 0000 [1] SMP
> CPU 1
> Modules linked in: ipv6 autofs4 hidp rfcomm l2cap bluetooth sunrpc dm_mirror
> dm_
> log dm_multipath dm_mod video output sbs sbshc battery acpi_memhotplug ac lp sg
> floppy button tg3 serio_raw parport_pc parport k8temp hwmon i2c_amd756
> i2c_amd81
> 11 i2c_core amd_rng shpchp pcspkr usb_storage 3w_9xxx sata_sil libata sd_mod
> scs
> i_mod raid456 async_xor async_memcpy async_tx xor ext3 jbd ehci_hcd ohci_hcd
> uhc
> i_hcd
> Pid: 3800, comm: sshd Not tainted 2.6.26.3 #1
> RIP: 0010 [<ffffffff8023d5d0>]  [<ffffffff8023d5d0>]
> do_notify_parent+0x66/0x194
> RSP: 0018:ffff8101fd943c78  EFLAGS: 00010046
> RAX: 0000000000000000 RBX: ffff8101fe08f2f0 RCX: ffff8101fd956870
> RDX: ffff8101fe08f4c0 RSI: 0000000000000011 RDI: ffff8101fe08f2f0
> RBP: 0000000000000000 R08: 0000000000000009 R09: 0000000000000009
> R10: 0000000000000002 R11: ffffffff802f1c0e R12: 0000000000000011
> R13: ffff8101fe4e00c0 R14: 0000000000000000 R15: 0000000000000001
> FS:  00007fce4b4b2710(0000) GS:ffff8101ff08c8c0(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000020 CR3: 0000000000201000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process sshd (pid: 3800, threadinfo ffff8101fd942000, task ffff8101fe4e00d0)
> Stack:  0000000000000011 ffff8101fec76630 ffff8101fe0e1180 ffffffff8029d597
>  0000000000000008 ffff8101fe0e1180 ffff8101fe7e87c0 ffffffff802a1915
>  ffff8101fd856c40 ffff8101fe0e1180 ffff8101fd856c40 0000000000000000
> Call Trace:
> [<ffffffff8029d597>] dput+0x26/0xe7
> [<ffffffff802a1915>] mntput_no_expire+0x20/0x119
> [<ffffffff8028b557>] filp_close+0x5d/0x65
> [<ffffffff80233cd1>] reparent_thread+0x139/0x14d
> [<ffffffff802350ba>] do_exit+0x39a/0x68c
> [<ffffffff80235412>] do_group_exit+0x66/0x96
> [<ffffffff8023d4f7>] get_signal_to_deliver+0x2ea/0x305
> [<ffffffff8020b166>] do_notify_resume+0xaf/0x7de
> [<ffffffff802435de>] autoremove_wake_function+0x0/0x2e
> [<ffffffff80236198>] current_fd_time+0x1e/0x24
> [<ffffffff8036dfdb>] tty_ldisc_deref+0x62/0x75
> [<ffffffff8025bdfe>] autit_syscall_exit+0x2e4/0x303
> [<ffffffff8020bf8c>] int_signal+x012/0x17
> 
> Code: 00 48 39 87 30 02 00 00 74 04 0f 0b eb fe 44 89 24 24 c7 44 24 04 00 00
> 00
>  00 48 8b 83 b8 01 00 00 48 89 df 48 8b 80 98 04 00 00 <48> 8b 70 20 e8 57 39
> 00
>  00 48 8b 93 a0 04 00 00 89 44 24 10 8b
> RIP  [<ffffffff8023d5c9>] do_notify_parent+0x66/0x194
>  RSP <ffff8101f7535c78>
> CR2: 0000000000000020
> ---[ end trace 8df15d3ad47033c0 ]---
> Fixing recursive fault but reboot is needed!
> -------------------------------------
> 
> Problem happens with PID namespaces enabled. After killing the child reaper of
> a new namespace with SIGKILL, the kernel crashes. I did some debugging and as
> far as I could see, the NULL pointer dereference happens on this line:
> 
> info.si_pid = task_pid_nr_ns(tsk, tsk->parent->nsproxy->pid_ns);
> 
> I did a BUG_ON(!tsk->parent->nsproxy) one line above and got an appropriate
> message before the kernel crashed.
> 
> Software Environment:
> (test program attached)
> 
> Steps to reproduce:
> 
> Compile the attached test program with "gcc -o ns_exec ns_exec.c -lpthread".
> After being started, it will create a new PID namespace, mount a proc
> filesystem herein, create a new thread and fork() into an SSHd.
> Login via SSH (the port of the started SSHd is hardcoded in the test program,
> so you'll have to modify it appropriately if you wish to do so ;-) ). Do a
> "kill -9 1". On my machines, the kernel crashed in over 90% of all tests.
> 
> 
