From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Wed, 8 Jul 2009 12:54:17 +0200
Message-ID: <20090708105417.GA16833@megiteam.pl>
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
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On sob, lip 04, 2009 at 04:34:12 +0200, Grzegorz Nosek wrote:
> On Sat, Jul 04, 2009 at 03:28:52PM +0200, Grzegorz Nosek wrote:
> > Decoding the code yields:
> > All code
> > ========
> >    0:   81 fb 00 f0 ff ff       cmp    $0xfffff000,%ebx
> >    6:   76 11                   jbe    0x19
> >    8:   48 c7 c7 60 61 7d 80    mov    $0xffffffff807d6160,%rdi
> >    f:   e8 c1 38 17 00          callq  0x1738d5
> >   14:   e9 a9 00 00 00          jmpq   0xc2
> >   19:   48 85 db                test   %rbx,%rbx
> >   1c:   74 5c                   je     0x7a
> >   1e:   80 bb 40 01 00 00 00    cmpb   $0x0,0x140(%rbx)
> >   25:   48 8b 53 08             mov    0x8(%rbx),%rdx
> >   29:   78 64                   js     0x8f
> >   2b:*  81 ba 9c 00 00 00 04    cmpl   $0x10004,0x9c(%rdx)     <-- trapping instruction
> >   32:   00 01 00
> >   35:   75 16                   jne    0x4d
> >   37:   83                      .byte 0x83
> >   38:   bb 48 01 00 00          mov    $0x148,%ebx
> > 
> > Code starting with the faulting instruction
> > ===========================================
> >    0:   81 ba 9c 00 00 00 04    cmpl   $0x10004,0x9c(%rdx)
> >    7:   00 01 00
> >    a:   75 16                   jne    0x22
> >    c:   83                      .byte 0x83
> >    d:   bb 48 01 00 00          mov    $0x148,%ebx
> 
> To my untrained eye it looks like the cmpl corresponds to:
> 
> 1841        if (tty->driver->type == TTY_DRIVER_TYPE_PTY &&
> 1842            tty->driver->subtype == PTY_TYPE_MASTER)
> 
> in drivers/char/tty_io.c
> 
> That means that %rdx should contain tty->driver, but contains
> 0x6973646e65732f64, which looks like a part of '/etc/init.d/sendsigs'.
> So, we're possibly using an already freed and overwritten tty struct.

(CC'ing Alan-the-TTY-guru)

OK, so I'm (hopefully) getting somewhere. I can now reliably reproduce
the oops below (with SLUB debugging) by starting and shutting down a
container twice. Tested 2.6.30.1 and 2.6.31-rc2, both invariably crash
at the second shutdown attempt. Afterwards the system is left unstable,
with just about anything touching TTY code hanging.

The container is Debian Lenny with a tiny bit patched upstart from Sid
(more suited to running as container init, i.e. not crashing with an
empty environment and exiting completely upon request). The host is
again Debian Lenny running libvirt 0.6.4 and again, patched a tiny
little bit (fixed container shutdown to actually send a signal to
container init). /dev/pts inside the container is mounted with -o
newinstance, but even with that option patched out from libvirt (or
disabled in the kernel) the oops is identical.

There are several items inside upstart configuration required:
 - mount --bind /dev/pts/0 /dev/console at the very beginning
   (/etc/event.d/rcS running just this one command)
 - /etc/event.d/logd (set up as "stop on runlevel 0" and "console
   output")
 - /etc/event.d/control-alt-delete switching to runlevel 0

I don't really know what does that logd do, but apparently all three
factors are required (e.g. not shutting down logd cleanly but simply
letting it go down with init does not trigger the crash).

Everything is running on a 386 virtualbox VM, but crashes happened also
on a physical amd64 box (see code above).

If needed, I can supply the virtualbox image somewhere (it's 8G, but
I'll strip it down). I can also test just about anything on this VM.

Best regards,
 Grzegorz Nosek

Jul  8 13:53:52 debian kernel: [   31.429837] BUG: unable to handle kernel paging request at 6b6b6bcf
Jul  8 13:53:52 debian kernel: [   31.429837] IP: [<c122c46c>] tty_open+0x11c/0x4b0
Jul  8 13:53:52 debian kernel: [   31.429837] *pde = 00000000
Jul  8 13:53:52 debian kernel: [   31.429837] Oops: 0000 [#1] SMP
Jul  8 13:53:52 debian kernel: [   31.429837] last sysfs file: /sys/class/net/lo/operstate
Jul  8 13:53:52 debian kernel: [   31.429837] Modules linked in: bridge stp llc
Jul  8 13:53:52 debian kernel: [   31.429837]
Jul  8 13:53:52 debian kernel: [   31.429837] Pid: 1595, comm: init Not tainted (2.6.31-rc2 #2) VirtualBox
Jul  8 13:53:52 debian kernel: [   31.429837] EIP: 0060:[<c122c46c>] EFLAGS: 00210202 CPU: 0
Jul  8 13:53:52 debian kernel: [   31.429837] EIP is at tty_open+0x11c/0x4b0
Jul  8 13:53:52 debian kernel: [   31.429837] EAX: ce49b950 EBX: cfaaf780 ECX: ce49b950 EDX: 6b6b6b6b
Jul  8 13:53:52 debian kernel: [   31.429837] ESI: ce49b950 EDI: 08800000 EBP: ce589e64 ESP: ce589e40
Jul  8 13:53:52 debian kernel: [   31.429837]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Jul  8 13:53:52 debian kernel: [   31.429837] Process init (pid: 1595, ti=ce588000 task=ce545380 task.ti=ce588000)
Jul  8 13:53:52 debian kernel: [   31.429837] Stack:
Jul  8 13:53:52 debian kernel: [   31.429837]  cfaaf784 cf309100 cf6930d8 00000102 00000100 00000000 00000000 cfaaf788
Jul  8 13:53:52 debian kernel: [   31.429837] <0> cf6930d8 ce589e84 c1003c92 cf309100 cf309100 00000000 cf309100 00000000
Jul  8 13:53:52 debian kernel: [   31.429837] <0> cf6930d8 ce589ea0 c10e14a3 cf056cc0 cf6a3d48 cf309100 ce589ef0 cf309100
Jul  8 13:53:52 debian kernel: [   31.429837] Call Trace:
Jul  8 13:53:52 debian kernel: [   31.429837]  [<c1003c92>] ? return_to_handler+0x0/0x1e
Jul  8 13:53:52 debian kernel: [   31.429837]  [<c10058de>] dump_trace+0x8e/0xe0
Jul  8 13:53:52 debian kernel: [   31.429837]  [<c10e14a3>] ? __dentry_open+0xc3/0x280
Jul  8 13:53:52 debian kernel: [   31.429837]  [<c10e175b>] ? nameidata_to_filp+0x5b/0x70
Jul  8 13:53:52 debian kernel: [   31.429837]  [<c10e6430>] ? chrdev_open+0x0/0x190
Jul  8 13:53:52 debian kernel: [   31.429837]  [<c10ef851>] ? do_filp_open+0x271/0x900
Jul  8 13:53:52 debian kernel: [   31.429837]  [<c13f03a4>] ? _spin_unlock+0x4/0x30
Jul  8 13:53:52 debian kernel: [   31.429837]  [<c10f9800>] ? alloc_fd+0xe0/0x100
Jul  8 13:53:52 debian kernel: [   31.429837]  [<c101b5e4>] ? prepare_ftrace_return+0x64/0xa0
Jul  8 13:53:52 debian kernel: [   31.429837]  [<c13f03c2>] ? _spin_unlock+0x22/0x30
Jul  8 13:53:52 debian kernel: [   31.429837]  [<c10f9800>] ? alloc_fd+0xe0/0x100
Jul  8 13:53:52 debian kernel: [   31.429837]  [<c10e126d>] ? do_sys_open+0x6d/0x130
Jul  8 13:53:52 debian kernel: [   31.429837]  [<c10e139e>] ? sys_open+0x2e/0x40
Jul  8 13:53:52 debian kernel: [   31.429837]  [<c1003155>] ? syscall_call+0x7/0xb
Jul  8 13:53:52 debian kernel: [   31.429837] Code: f8 29 d0 8d 53 04 89 45 f0 89 d0 89 55 dc e8 3c 81 f9 ff 85 f6 0f 84 14 02 00 00 80 be 08 01 00 00 00 8b 56 08 0f 88 5c 01 00 00 <81> 7a 64 04 00 01 00 75 1b 8b 86 0c 01 00 00 85 c0 0f 85 45 01
Jul  8 13:53:52 debian kernel: [   31.429837] EIP: [<c122c46c>] tty_open+0x11c/0x4b0 SS:ESP 0068:ce589e40
Jul  8 13:53:52 debian kernel: [   31.429837] CR2: 000000006b6b6bcf
Jul  8 13:53:52 debian kernel: [   31.511274] ---[ end trace 774489600e77c80b ]---
