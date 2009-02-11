From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: namespaces?: bug at mm/slub.c:2750
Date: Wed, 11 Feb 2009 00:07:40 -0800
Message-ID: <20090211000740.f1de7cec.akpm@linux-foundation.org>
References: <20090206113556.GA3161@alice>
	<20090206161518.81e7d42c.akpm@linux-foundation.org>
	<19f34abd0902102355o5bf51096o9aa3737e87104fb9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <19f34abd0902102355o5bf51096o9aa3737e87104fb9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Eric Sesterhenn <snakebyte-Mmb7MZpHnFY@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

(cc's added)

On Wed, 11 Feb 2009 08:55:08 +0100 Vegard Nossum <vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Sat, Feb 7, 2009 at 1:15 AM, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> > On Fri, 6 Feb 2009 12:35:56 +0100
> > Eric Sesterhenn <snakebyte-Mmb7MZpHnFY@public.gmane.org> wrote:
> >>
> >> with todays -git i get the following bug when i reboot the machine
> >>
> >> [   94.369135] ------------[ cut here ]------------
> >> [   94.369344] kernel BUG at mm/slub.c:2750!
> 
> [...]
> 
> > Well that's ugly.  We seem to have passed a non-slab address into
> > kfree().
> >
> > void kfree(const void *x)
> > {
> >        struct page *page;
> >        void *object = (void *)x;
> >
> >        if (unlikely(ZERO_OR_NULL_PTR(x)))
> >                return;
> >
> >        page = virt_to_head_page(x);
> >        if (unlikely(!PageSlab(page))) {
> >                BUG_ON(!PageCompound(page));
> >
> >
> > doing BUG_ON(!PageCompound) is a rather odd way of reporting that.
> >
> 
> This might be pointing out the obvious, but page allocator
> pass-through means that we can't really tell slab pages from page
> allocator pages. But since pass-through uses GFP_COMP, we know it'd be
> a bug to pass a non-compound page into this function.
> 
> > I'm unsure what could have caused this.  Could you have a play around
> > please?  Set all the memory debug options, try using slab instead of
> > slub, etc?
> 
> I think it is trying to free the init_user_ns (because of a
> refcounting bug). I am able to reproduce it with a clean stack trace:
> 
> [  648.864710] ------------[ cut here ]------------
> [  648.865554] kernel BUG at mm/slub.c:2750!
> [  648.865554] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
> [  648.865554] last sysfs file: /sys/devices/pnp0/00:0d/id
> [  648.865554] CPU 1
> [  648.865554] Modules linked in:
> [  648.865554] Pid: 917, comm: udevd Not tainted 2.6.29-rc3 #223
> [  648.865554] RIP: 0010:[<ffffffff810b99c9>]  [<ffffffff810b99c9>]
> kfree+0x29/0x87
> [  648.865554] RSP: 0018:ffff88003f187e28  EFLAGS: 00010246
> [  648.865554] RAX: 0100000000000400 RBX: ffffffff8171fe00 RCX: 0000000000000086
> [  648.865554] RDX: ffffe20000050ec8 RSI: 0000000000000085 RDI: ffffe20000050ec8
> [  648.865554] RBP: ffff88003f187e38 R08: 0000000000000000 R09: ffffffff81819cb0
> [  648.865554] R10: 0000000000000002 R11: ffff88003f187e98 R12: ffffffff81072144
> [  648.865554] R13: 00000000000000cf R14: ffffffff818b13e0 R15: 000000000000000a
> [  648.865554] FS:  0000000000000000(0000) GS:ffff88003f156f80(0063)
> knlGS:00000000f7fac700
> [  648.865554] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
> [  648.865554] CR2: 0000000009b2d630 CR3: 000000003e92c000 CR4: 00000000000006a0
> [  648.865554] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  648.865554] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  648.865554] Process udevd (pid: 917, threadinfo ffff88003e458000,
> task ffff88003f1b8e80)
> [  648.865554] Stack:
> [  648.865554]  ffffffff8171fe00 ffffffff81072144 ffff88003f187e58
> ffffffff81072169
> [  648.865554]  ffffffff818b13e0 ffffffff8171fe00 ffff88003f187e78
> ffffffff811b2f68
> [  648.865554]  ffff88003dd4c500 0000000000000286 ffff88003f187e98
> ffffffff81046712
> [  648.865554] Call Trace:
> [  648.865554]  <IRQ> <0> [<ffffffff81072144>] ? free_user_ns+0x0/0x29
> [  648.865554]  [<ffffffff81072169>] free_user_ns+0x25/0x29
> [  648.865554]  [<ffffffff811b2f68>] kref_put+0x66/0x72
> [  648.865554]  [<ffffffff81046712>] free_uid+0x4f/0x90
> [  648.865554]  [<ffffffff810555b8>] put_cred_rcu+0xa5/0xb9
> [  648.865554]  [<ffffffff8107ea86>] __rcu_process_callbacks+0x1f4/0x263
> [  648.865554]  [<ffffffff8107eb2c>] rcu_process_callbacks+0x37/0x5d
> [  648.865554]  [<ffffffff81041bd3>] __do_softirq+0x88/0x149
> [  648.865554]  [<ffffffff8100d53c>] call_softirq+0x1c/0x28
> [  648.865554]  [<ffffffff8100e4e9>] do_softirq+0x39/0x7b
> [  648.865554]  [<ffffffff81041946>] irq_exit+0x44/0x7e
> [  648.865554]  [<ffffffff814c3d8f>] smp_apic_timer_interrupt+0x98/0xb1
> [  648.865554]  [<ffffffff8100cf73>] apic_timer_interrupt+0x13/0x20
> [  648.865554]  <EOI> <0>Code: c9 c3 55 48 89 e5 41 54 53 0f 1f 44 00
> 00 48 83 ff 10 48 89 fb 7
> 6 6d e8 1d ed ff ff 48 89 c7 48 8b 00 84 c0 78 10 f6 c4 60 75 04 <0f>
> 0b eb fe e8 f4 cd fd ff e
> b 4e 48 8b 4d 08 4c 8b 4f 10 9c 41
> [  648.865554] RIP  [<ffffffff810b99c9>] kfree+0x29/0x87
> [  648.865554]  RSP <ffff88003f187e28>
> [  649.131912] ---[ end trace a48f49f69d2bcb3e ]---
> [  649.136840] Kernel panic - not syncing: Fatal exception in interrupt
> [  649.143558] Rebooting in 10 seconds..
> 
> And if you look closely in the stack dump, you will find init_user_ns:
> 
> ffffffff8171fe00 D init_user_ns
> 
> In case you missed it, KOSAKI Motohiro posted a similar stack-trace
> (but not the same BUG) in this thread:
> http://lkml.org/lkml/2009/2/10/7
> 

Both traces include the newly-added put_cred_rcu().  Suspicious.
