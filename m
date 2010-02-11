From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] RFC: s390: Move get_signal_to_deliver() up in do_signal
Date: Thu, 11 Feb 2010 11:29:17 -0600
Message-ID: <20100211172917.GD6884@us.ibm.com>
References: <20100210204019.GA24269@us.ibm.com>
	<20100211094838.4550edd9@mschwide.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100211094838.4550edd9-Ne9dzUzLWq+XI4yAdoq52KN5r0PSdgG1zG2AekJRRhI@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, s390 <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Martin Schwidefsky (schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org):
> On Wed, 10 Feb 2010 14:40:19 -0600
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > The current placement of get_signal_to_deliver() means that
> > try_to_freeze() in get_signal_to_deliver() will happen after
> > regs->psw.addr, regs->svcnr, and regs->gprs[2] may have been
> > mangled.  Since the app may get checkpointed while frozen and
> > then restarted, this means we have to attempt a complicated
> > and subtle re-calculation of the initial conditions.
> > 
> > If we just move the get_signal_to_deliver() above the
> > immediately preceding block, we enourmously simplify the
> > arch-specific checkpoint/restart code.
> > 
> > A full ltp run seems to show no regressions do to this move,
> > though I'm not familiar enough with the entry_64.S code in
> > particular to be absolutely confident.
> > 
> > Is this a bad idea?
> 
> I think it is a bad idea. The comment of get_signal_to_deliver tells
> you that the debugger is invoked and may want to change the registers.
> If the get_signal_to_deliver calls is moved then the debugger sees
> the unmodified registers which is imho wrong. A comparison of the
> gdb testsuite with and without the patch will tell us more.

Right, but I guess what's confounding me is exactly why the values
being set for the debugger make more sense to the debugger than the
initial ones.  Note that they're not actually the same as they will
be upon exit, for instance in the -ERESTARTNOHAND case if certain
signals are delivered we'll change psw.addr back after all and set
-EINTR.

So yeah, with this patch, if I send a signal to a program being
debugged and then do 'i r' I see -516 instead of the -4 which I
otherwise see, and a different $pswa.  Results for 'sleep' (which
is ERESTART_RESTARTBLOCK) and 'getchar' (which is not) being
interupted is below.  Frankly I think the info you see with the
patch is more informative, not less, and the debugger certainly
functions as well as it did before.

Of course there is probably fancier userspace tracing/debugging
code out there which depends on the current behavior?  And the
most convincing argument might be that it's all so magical that
changing it is begging for trouble.

But it sure would simplify checkpoint.

thanks,
-serge

================================================================
Results without signals patch
================================================================
sleeping program control-c'd under gdb:

(gdb) i r
r0             0x3ff00000000	4393751543808
r1             0x4d7dbeedb0	332822146480
r2             0xfffffffffffffffc	-4
r3             0x3ffff806608	4398038148616
r4             0x0	0
r5             0x8	8
r6             0x80002b40	2147494720
r7             0x3ffff8068e0	4398038149344
r8             0x80000fcc	2147487692
r9             0x80002b44	2147494724
r10            0x3ffff806508	4398038148360
r11            0x3ffff806618	4398038148632
r12            0x4d7dbea000	332822126592
r13            0x4d7dbb3c40	332821904448
r14            0x4d7db2caaa	332821351082
r15            0x3ffff8063d0	4398038148048
pc             0x4d7db2ccfc	0x4d7db2ccfc <__nanosleep_nocancel+2>
cc             0x0	0
x/i $pswa
0x4d7db2ccfc <__nanosleep_nocancel+2>:	lghi	%r4,-4095

readc.c (getchar)  ctrl-c'd in gdb:
(gdb) i r
r0             0xffffffff00000000       -4294967296
r1             0x4d7dbeedb0     332822146480
r2             0x0      0
r3             0x20000005000    2199023276032
r4             0x400    1024
r5             0x4d7daf8fd8     332821139416
r6             0x80000604       2147485188
r7             0x3ffffba43c0    4398041940928
r8             0x4d7dbeaf90     332822130576
r9             0x4d7dbea908     332822128904
r10            0x4d7da79c38     332820618296
r11            0x4d7dbea9e8     332822129128
r12            0x4d7dbea000     332822126592
r13            0x4d7dbb1b50     332821896016
r14            0x4d7dafa1ac     332821143980
r15            0x3ffffba3f28    4398041939752
pc             0x4d7db52f6a     0x4d7db52f6a <__read_nocancel>
cc             0x0      0


================================================================
Results with signals patch
================================================================

sleeping program control-c'd under gdb:
(gdb) i r
r0             0x3ff00000000    4393751543808
r1             0x4d7dbeedb0     332822146480
r2             0xfffffffffffffdfc       -516
r3             0x3ffffa340c8    4398040432840
r4             0x0      0
r5             0x8      8
r6             0x80002b40       2147494720
r7             0x3ffffa343a0    4398040433568
r8             0x80000fcc       2147487692
r9             0x80002b44       2147494724
r10            0x3ffffa33fc8    4398040432584
r11            0x3ffffa340d8    4398040432856
r12            0x4d7dbea000     332822126592
r13            0x4d7dbb3c40     332821904448
r14            0x4d7db2caaa     332821351082
r15            0x3ffffa33e90    4398040432272
pc             0x4d7db2ccfc     0x4d7db2ccfc <__nanosleep_nocancel+2>
cc             0x0      0
x/i $pswa
0x4d7db2ccfc <__nanosleep_nocancel+2>:  lghi    %r4,-4095


readc.c (getchar), ctrl-c'd in gdb:

(gdb) i r
r0             0xffffffff00000000       -4294967296
r1             0x4d7dbeedb0     332822146480
r2             0xfffffffffffffe00       -512
r3             0x20000005000    2199023276032
r4             0x400    1024
r5             0x4d7daf8fd8     332821139416
r6             0x80000604       2147485188
r7             0x3fffff433c0    4398045737920
r8             0x4d7dbeaf90     332822130576
r9             0x4d7dbea908     332822128904
r10            0x4d7da79c38     332820618296
r11            0x4d7dbea9e8     332822129128
r12            0x4d7dbea000     332822126592
r13            0x4d7dbb1b50     332821896016
r14            0x4d7dafa1ac     332821143980
r15            0x3fffff42f28    4398045736744
pc             0x4d7db52f6c     0x4d7db52f6c <__read_nocancel+2>
cc             0x0      0
