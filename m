From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [CRED bug?] 2.6.29-rc3 don't survive on stress workload
Date: Wed, 11 Feb 2009 21:25:01 +0900 (JST)
Message-ID: <20090211212208.C3C6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090210142443.629E.KOSAKI.MOTOHIRO@jp.fujitsu.com> <19f34abd0902092310g513fb776s2e4d37285c8fa7be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755746AbZBKMZe@vger.kernel.org>
In-Reply-To: <19f34abd0902092310g513fb776s2e4d37285c8fa7be@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Howells <dhowells@redhat.com>, Serge Hallyn <serue@us.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Eric Sesterhenn <snakebyte@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Hi

> On Tue, Feb 10, 2009 at 6:41 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > Hi
> >
> > I periodically test kernel on stress workload.
> > Unfortunately, recent kerenel don't survive >24H.
> >
> > It paniced with following stack.
> > Do you have any suggestions?
> >
> > thanks!
> 
> That stack trace looks somewhat similar to the one in
> http://lkml.org/lkml/2009/2/6/136
> 
> If this is reproducible, maybe a patch like the one attached can help
> pinpoint it?

Unfortunately, your patch don't help analysis.
(and slub debug option don't help too)

Today's panic information is here.


----------------------------------------------------
 e100 processor container button mii dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mod lpfc mptspi mptscsih mptbase ehci_hcd ohci_hcd uhci_hcd usbcore

Pid: 315753, CPU 0, comm:                pidof
psr : 0000101008026038 ifs : 800000000000028a ip  : [<a0000001001c4b00>]    Not tainted (2.6.29-rc3)
ip is at kfree+0x40/0x2c0
unat: 0000000000000000 pfs : 0000000000000205 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 0000000000aa95a5
ldrs: 0000000000000000 ccv : 0000000000000093 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100123210 b6  : a0000001001231e0 b7  : a000000100014d20
f6  : 1003e6b6b6b6b6b6b6b6b f7  : 0ffe6af8e85a500000000
f8  : 1003e0000000000000a50 f9  : 1003efffffffffffffef8
f10 : 100029ffffffff55c35f6 f11 : 1003e0000000000000000
r1  : a000000100f683c0 r2  : 0000000000000092 r3  : 0000000000403400
r8  : 00000000000100d0 r9  : a000000100d6fe60 r10 : a000000100d6fe60
r11 : a0000001001231e0 r12 : e00000408c61fc30 r13 : e00000408c610000
r14 : 0000000000000093 r15 : a040000000000000 r16 : ffffffffdead4ead
r17 : 00000000dead4ead r18 : a000000100cd2274 r19 : a000000100d6b6c0
r20 : 0000000000004000 r21 : 0000000000004000 r22 : 0000000000000011
r23 : e000016006920a10 r24 : 0000000000000019 r25 : 5fc0000000000000
r26 : e000016006920a0f r27 : e000016006920a12 r28 : 0000000000000000
r29 : e00000408c610d54 r30 : 0000000000000000 r31 : 0000000000000008

Call Trace:
 [<a000000100017780>] show_stack+0x80/0xa0
                                sp=e00000408c61f800 bsp=e00000408c611598
 [<a000000100018080>] show_regs+0x880/0x8c0
                                sp=e00000408c61f9d0 bsp=e00000408c611540
 [<a000000100040290>] die+0x1b0/0x2e0
                                sp=e00000408c61f9d0 bsp=e00000408c6114f8
 [<a0000001007af0b0>] ia64_do_page_fault+0x810/0xb00
                                sp=e00000408c61f9d0 bsp=e00000408c611498
 [<a00000010000c860>] ia64_native_leave_kernel+0x0/0x270
                                sp=e00000408c61fa60 bsp=e00000408c611498
 [<a0000001001c4b00>] kfree+0x40/0x2c0
                                sp=e00000408c61fc30 bsp=e00000408c611448
 [<a000000100123210>] free_user_ns+0x30/0x60
                                sp=e00000408c61fc30 bsp=e00000408c611428
 [<a00000010037b5f0>] kref_put+0x110/0x140
                                sp=e00000408c61fc30 bsp=e00000408c611400
 [<a0000001000c5bf0>] free_uid+0x110/0x1a0
                                sp=e00000408c61fc30 bsp=e00000408c6113d0
 [<a0000001000ec340>] put_cred_rcu+0xa0/0xe0
                                sp=e00000408c61fc40 bsp=e00000408c6113a8
 [<a00000010012db90>] __rcu_process_callbacks+0x2f0/0x580
                                sp=e00000408c61fc40 bsp=e00000408c611368
 [<a00000010012de70>] rcu_process_callbacks+0x50/0xc0
                                sp=e00000408c61fc40 bsp=e00000408c611348
 [<a0000001000b7ac0>] __do_softirq+0x220/0x320
                                sp=e00000408c61fc40 bsp=e00000408c6112a8
 [<a0000001000b7c30>] do_softirq+0x70/0xc0
                                sp=e00000408c61fc40 bsp=e00000408c611248
 [<a0000001000b7d00>] irq_exit+0x80/0xa0
                                sp=e00000408c61fc40 bsp=e00000408c611230
 [<a000000100014600>] ia64_handle_irq+0x1e0/0x400
                                sp=e00000408c61fc40 bsp=e00000408c6111b0
 [<a00000010000c860>] ia64_native_leave_kernel+0x0/0x270
                                sp=e00000408c61fc40 bsp=e00000408c6111b0
 [<a0000001001c5940>] kmem_cache_alloc+0x1e0/0x260
                                sp=e00000408c61fe10 bsp=e00000408c611150
 [<a000000100219e10>] seq_read+0x530/0x980
                                sp=e00000408c61fe10 bsp=e00000408c6110b8
 [<a0000001001de180>] vfs_read+0x1a0/0x320
                                sp=e00000408c61fe20 bsp=e00000408c611068
 [<a0000001001de830>] sys_read+0x70/0xe0
                                sp=e00000408c61fe20 bsp=e00000408c610fe8
 [<a00000010000c6c0>] ia64_ret_from_syscall+0x0/0x20
                                sp=e00000408c61fe30 bsp=e00000408c610fe8
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=e00000408c620000 bsp=e00000408c610fe8
Kernel panic - not syncing: Fatal exception
