From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: nsproxy c/r bug?
Date: Tue, 26 May 2009 13:37:02 -0500
Message-ID: <m3tz37ogmp.fsf@pobox.com>
References: <20090526180419.GA14372@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090526180419.GA14372-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message
	of "Tue\, 26 May 2009 13\:04\:19 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Linux-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> Unable to handle kernel pointer dereference at virtual kernel address fffffffd132b4000
> Oops: 0038 [#4] SMP 
> CPU: 0 Tainted: G      D    2.6.30-rc3-00080-g2b1009c #261
> Process ns_exec (pid: 3842, task: 000000001fdf9d50, ksp: 0000000012d83d90)
> Krnl PSW : 0404100180000000 00000000000ae266 (kmem_cache_alloc+0xa6/0x104)
>            R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:0 CC:1 PM:0 EA:3
> Krnl GPRS: 000003ff00000000 0000000000000000 00000000004bf308 000000000000063b
>            00000000000ae20e 0000000000422088 0000000000dc5098 0000000000000030
>            000000000005f0ea 000000001fc19200 00000000000000d0 0000000012d83d58
>            0700000000000400 00000000004075a8 fffffffd132b4090 0000000012d83d58
> Krnl Code: 00000000000ae256: a7f4000e		brc	15,ae272
>            00000000000ae25a: e31060140016	llgf	%r1,20(%r6)
>            00000000000ae260: eb110003000d	sllg	%r1,%r1,3
>           >00000000000ae266: e321e0000004	lg	%r2,0(%r1,%r14)
>            00000000000ae26c: e32060000024	stg	%r2,0(%r6)
>            00000000000ae272: e3c0b0a00024	stg	%r12,160(%r11)
>            00000000000ae278: 8000b0a0		ssm	160(%r11)
>            00000000000ae27c: a7a18000		tmll	%r10,32768
> Call Trace:
> ([<00000000000ae20e>] kmem_cache_alloc+0x4e/0x104)
>  [<000000000005f0ea>] create_new_namespaces+0x4e/0x204
>  [<000000000005f4fa>] unshare_nsproxy_namespaces+0x82/0xf8
>  [<000000000003c222>] SyS_unshare+0x11a/0x2f4
>  [<0000000000026b94>] sysc_do_restart+0x20/0x26
>  [<0000004d7db60ce6>] 0x4d7db60ce6

Turning on slab/slub debugging might help, if you haven't already done
so.
