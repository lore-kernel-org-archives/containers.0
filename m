From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Mon, 6 Jul 2009 20:31:35 -0700
Message-ID: <20090707033135.GA29461@us.ibm.com>
References: <d06d0dd6a4ddf760bea53291c048e291@[::1]>
	<20090413142038.GB13007@us.ibm.com>
	<20090704132851.GA16373@megiteam.pl>
	<20090704143412.GA27523@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090704143412.GA27523-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Grzegorz Nosek [root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org] wrote:
| On Sat, Jul 04, 2009 at 03:28:52PM +0200, Grzegorz Nosek wrote:
| > Decoding the code yields:
| > All code
| > ========
| >    0:   81 fb 00 f0 ff ff       cmp    $0xfffff000,%ebx
| >    6:   76 11                   jbe    0x19
| >    8:   48 c7 c7 60 61 7d 80    mov    $0xffffffff807d6160,%rdi
| >    f:   e8 c1 38 17 00          callq  0x1738d5
| >   14:   e9 a9 00 00 00          jmpq   0xc2
| >   19:   48 85 db                test   %rbx,%rbx
| >   1c:   74 5c                   je     0x7a
| >   1e:   80 bb 40 01 00 00 00    cmpb   $0x0,0x140(%rbx)
| >   25:   48 8b 53 08             mov    0x8(%rbx),%rdx
| >   29:   78 64                   js     0x8f
| >   2b:*  81 ba 9c 00 00 00 04    cmpl   $0x10004,0x9c(%rdx)     <-- trapping instruction
| >   32:   00 01 00
| >   35:   75 16                   jne    0x4d
| >   37:   83                      .byte 0x83
| >   38:   bb 48 01 00 00          mov    $0x148,%ebx
| > 
| > Code starting with the faulting instruction
| > ===========================================
| >    0:   81 ba 9c 00 00 00 04    cmpl   $0x10004,0x9c(%rdx)
| >    7:   00 01 00
| >    a:   75 16                   jne    0x22
| >    c:   83                      .byte 0x83
| >    d:   bb 48 01 00 00          mov    $0x148,%ebx
| 
| To my untrained eye it looks like the cmpl corresponds to:
| 
| 1841        if (tty->driver->type == TTY_DRIVER_TYPE_PTY &&
| 1842            tty->driver->subtype == PTY_TYPE_MASTER)
| 
| in drivers/char/tty_io.c

I don't yet have the exact version of tty_io.c so the line numbers don't
match, but even so isn't the above 'cmpl' comparing a constant 0x10004
with the %rdx+0x9c address ? If so, I am not sure how it matches up to
either TTY_DRIVER_TYPE_PTY (0x0004) or PTY_TYPE_MASTER (0x0001).

Wouldn't the above 'if' require two separate compare instructions ?

| 
| That means that %rdx should contain tty->driver, but contains
| 0x6973646e65732f64, which looks like a part of '/etc/init.d/sendsigs'.
| So, we're possibly using an already freed and overwritten tty struct.

Is it possibly related to this bug where they talk of some sort of
corruption going on with tty data structures (kernel versions appear
to be close, but need to double check).

	http://lkml.org/lkml/2009/6/16/131
