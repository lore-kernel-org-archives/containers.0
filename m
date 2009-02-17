From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/3] powerpc: bare minimum checkpoint/restart
	implementation
Date: Tue, 17 Feb 2009 01:03:55 -0600
Message-ID: <20090217010355.58afd5cf__14391.5269327865$1234854466$gmane$org@thinkcentre.lan>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>
	<1233182478-27113-2-git-send-email-ntl@pobox.com>
	<49814FA2.9060108@cs.columbia.edu> <20090129214035.GB6913@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090129214035.GB6913@localdomain>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org> wrote:
>
> Oren Laadan wrote:
> > 
> > Nathan Lynch wrote:
> > > 
> > > What doesn't work:
> > > * restarting a 32-bit task from a 64-bit task and vice versa
> > 
> > Is there a test to bail if we attempt to checkpoint such tasks ?
> 
> No, but I'll add one if it looks too hard to fix for the next round.

Unfortunately, adding a check for this is hard.

The "point of no return" in the restart path is cr_read_mm, which tears
down current's address space.  cr_read_mm runs way before cr_read_cpu,
which is the only restart method I've implemented for powerpc so far.
So, checking for this condition in cr_read_cpu is too late if I want
restart(2) to return an error and leave the caller's memory map
intact.  (And I do want this: restart should be as robust as execve.)

Well okay then, cr_read_head_arch seems to be the right place in the
restart sequence for the architecture code to handle this.  However,
cr_write_head_arch (which produces the buffer that cr_read_head_arch
consumes) is not provided a reference to the task to be checkpointed,
nor can it assume that it's operating on current.  I need a reference
to a task before I can determine whether it's running in 32- or 64-bit
mode, or using the FPU, Altivec, SPE, whatever.

In any case, mixing 32- and 64-bit tasks across restart is something I
eventually want to support, not reject.  But the problem I've outlined
applies to FPU state and vector extensions (VMX, SPE), as well as
sanity-checking debug register (DABR) contents.  We'll need to be able
to error out gracefully from restart when a checkpoint image specifies a
feature unsupported by the current kernel or hardware.  But I don't see
how to do it with the current architecture.  Am I missing something?
