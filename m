From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: ckpt-16-dev BUG() - bisected
Date: Wed, 3 Jun 2009 20:31:55 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0906032027370.22069@takamine.ncl.cs.columbia.edu>
References: <m3vdndkmec.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m3vdndkmec.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

I couldn't reproduce the problem on my system - your script
works fine (checkpoint and restart) on my kernel.

The actual logic is borrowed from Alexey's i386 patches.

My best guess is that either the issue occurs because you are
running under KVM which uses different segments (?)

Either that, or something is wrong with Alexey's original code.

Alexey - any idea ?

Also, you can you apply this patch so we know what was the
segment's value:

----------------------------------
diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index 7242762..18e957a 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -83,6 +83,8 @@ static __u32 encode_segment(unsigned long seg)
 	seg >>= 3;
 	if (GDT_ENTRY_TLS_MIN <= seg && seg <= GDT_ENTRY_TLS_MAX)
 		return CKPT_X86_SEG_TLS | (seg - GDT_ENTRY_TLS_MIN);
+
+	printk(KERN_ERR "bad segment %#lx\n", seg);
 	BUG();
 }
 
@@ -103,6 +105,8 @@ static unsigned long decode_segment(__u32 seg)
 		seg &= ~CKPT_X86_SEG_LDT;
 		return (seg << 3) | 7;
 	}
+
+	printk(KERN_ERR "bad segment %#lx\n", seg);
 	BUG();
 }
 
----------------------------------

Oren.


On Wed, 3 Jun 2009, Nathan Lynch wrote:

> Pulled latest updates today, started seeing the bug below when doing
> simple bash shell checkpoint/restart.  Git bisect blames:
> 
> commit 505d9949cac385c5111bbd8ff3d2e123d5c468d8
> Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> Date:   Sun May 31 12:59:40 2009 -0400
> 
>     c/r: [X86_32] validate task's cpu registers and tls during restart
>     
>     Check the eflags, segment registers and tls entries from the
>     checkpoint image to prevent breakpoints inside the kernel code.
>     
>     Fixes in restore_thread() and load_cpu_regs():
>             /* TODO: ADD SANITY CHECKS TO VERIFY VALIDITY OF VALUES */
>     
>     Based on patch from Alexey Dobriyan:
>     https://lists.linux-foundation.org/pipermail/containers/2009-May/017886.html
>         Segment registers are abstracted to allow i386 => x86_64
>         migration (BTW, I'm not so sure if just making 32-bit selectors
>         the same will achieve same effect)
> 
> 
> kernel BUG at arch/x86/mm/checkpoint.c:86!
> invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> last sysfs file: /sys/block/sda/size
> Modules linked in:
> 
> Pid: 2236, comm: ckpt Not tainted (2.6.30-rc7-00054-g505d994 #55) 
> EIP: 0060:[<c021c3dd>] EFLAGS: 00010202 CPU: 0
> EIP is at encode_segment+0x51/0x57
> EAX: 1fffe009 EBX: df03a720 ECX: 00000130 EDX: 1fffe00f
> ESI: df996fb4 EDI: def3f250 EBP: de8abf18 ESP: de8abf18
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process ckpt (pid: 2236, ti=de8ab000 task=de8e28e0 task.ti=de8ab000)
> Stack:
>  de8abf38 c021cc07 decf51c0 def3f250 00000062 dc99a440 00000000 def3f250
>  de8abf58 c038eb3c decf51c0 decf54e8 00000007 00000000 00000000 def3f250
>  de8abf98 c038d7bf c07a69e0 00000001 00000001 00000000 def73ee0 c07ad224
> Call Trace:
>  [<c021cc07>] ? checkpoint_cpu+0x11a/0x426
>  [<c038eb3c>] ? checkpoint_task+0x226/0x239
>  [<c038d7bf>] ? do_checkpoint+0x404/0x511
>  [<c038c669>] ? sys_checkpoint+0x6d/0x83
>  [<c0202ce5>] ? syscall_call+0x7/0xb
> Code: 74 2d 83 fa 7b b8 02 00 00 00 74 23 f6 c2 04 74 0a 89 d0 c1 e8 03 80 cc 80 eb 14 c1 ea 03 8d 42 fa 83 f8 02 77 05 80 cc 40 eb 04 <0f> 0b eb fe 5d c3 55 89 e5 e8 f9 72 fe ff 85 c0 74 40 83 f8 01 
> EIP: [<c021c3dd>] encode_segment+0x51/0x57 SS:ESP 0068:de8abf18
> ---[ end trace 270dba57a69e79e1 ]---
> 
> 
