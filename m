From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: ckpt-16-dev BUG() - bisected
Date: Thu, 04 Jun 2009 13:08:43 -0500
Message-ID: <m3ab4nkh1w.fsf@pobox.com>
References: <m3vdndkmec.fsf@pobox.com>
	<Pine.LNX.4.64.0906032027370.22069@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0906032027370.22069-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
	(Oren Laadan's message of "Wed\, 3 Jun 2009 20\:31\:55 -0400 \(EDT\)")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
> Hi,
>
> I couldn't reproduce the problem on my system - your script
> works fine (checkpoint and restart) on my kernel.
>
> The actual logic is borrowed from Alexey's i386 patches.
>
> My best guess is that either the issue occurs because you are
> running under KVM which uses different segments (?)
>
> Either that, or something is wrong with Alexey's original code.
>
> Alexey - any idea ?
>
> Also, you can you apply this patch so we know what was the
> segment's value:
>
> ----------------------------------
> diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
> index 7242762..18e957a 100644
> --- a/arch/x86/mm/checkpoint.c
> +++ b/arch/x86/mm/checkpoint.c
> @@ -83,6 +83,8 @@ static __u32 encode_segment(unsigned long seg)
>  	seg >>= 3;
>  	if (GDT_ENTRY_TLS_MIN <= seg && seg <= GDT_ENTRY_TLS_MAX)
>  		return CKPT_X86_SEG_TLS | (seg - GDT_ENTRY_TLS_MIN);
> +
> +	printk(KERN_ERR "bad segment %#lx\n", seg);
>  	BUG();
>  }
>  
> @@ -103,6 +105,8 @@ static unsigned long decode_segment(__u32 seg)
>  		seg &= ~CKPT_X86_SEG_LDT;
>  		return (seg << 3) | 7;
>  	}
> +
> +	printk(KERN_ERR "bad segment %#lx\n", seg);
>  	BUG();
>  }

bad segment 0x1fffe00f
------------[ cut here ]------------
kernel BUG at arch/x86/mm/checkpoint.c:88!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
last sysfs file: /sys/class/net/br0/ifindex
Modules linked in:

Pid: 3117, comm: ckpt Not tainted (2.6.30-rc7-00058-gb0ddfc4-dirty #58) 
EIP: 0060:[<c021c622>] EFLAGS: 00010246 CPU: 0
EIP is at encode_segment+0x5c/0x64
EAX: 0000001a EBX: de86f300 ECX: 00000000 EDX: 00000003
ESI: df1f8fb4 EDI: dfad7020 EBP: df1faf18 ESP: df1faf10
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process ckpt (pid: 3117, ti=df1fa000 task=df9f0000 task.ti=df1fa000)
Stack:
 c06f9756 1fffe00f df1faf38 c021cc21 de810000 dfad7020 00000044 df280200
 00000000 dfad7020 df1faf58 c038edee de810000 de810328 00000007 00000000
 00000000 dfad7020 df1faf98 c038d88c c07ab9e0 00000001 00000001 00000000
Call Trace:
 [<c021cc21>] ? checkpoint_cpu+0x11a/0x426
 [<c038edee>] ? checkpoint_task+0x226/0x239
 [<c038d88c>] ? do_checkpoint+0x459/0x551
 [<c038c689>] ? sys_checkpoint+0x6d/0x83
 [<c0202ce5>] ? syscall_call+0x7/0xb
Code: 30 f6 c2 04 74 0a 89 d0 c1 e8 03 80 cc 80 eb 21 c1 ea 03 8d 42 fa 83 f8 02 77 05 80 cc 40 eb 11 52 68 56 97 6f c0 e8 76 c2 3c 00 <0f> 0b 58 5a eb fe c9 c3 55 89 e5 57 56 53 83 ec 10 e8 ac 70 fe 
EIP: [<c021c622>] encode_segment+0x5c/0x64 SS:ESP 0068:df1faf10
---[ end trace 0c5f24ea38f32c3f ]---
