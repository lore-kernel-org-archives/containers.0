From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 08/10] Introduce functions to restart a process
Date: Thu, 23 Oct 2008 12:53:34 +0400
Message-ID: <200810231253.35532.major__15000.6324206062$1224752210$gmane$org@openvz.org>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<200810221412.14174.major@openvz.org>
	<20081022104630.GY15171@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081022104630.GY15171-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wednesday 22 October 2008 14:46 Louis Rilling wrote:
> On Wed, Oct 22, 2008 at 02:12:12PM +0400, Andrey Mirkin wrote:
> > On Wednesday 22 October 2008 13:25 Louis Rilling wrote:
> > > On Wed, Oct 22, 2008 at 12:49:54PM +0400, Andrey Mirkin wrote:
> > > > On Monday 20 October 2008 13:23 Cedric Le Goater wrote:
> > > > > Hello Andrey !
> > > > >
> > > > > > diff --git a/arch/x86/kernel/entry_32.S
> > > > > > b/arch/x86/kernel/entry_32.S index 109792b..a4848a3 100644
> > > > > > --- a/arch/x86/kernel/entry_32.S
> > > > > > +++ b/arch/x86/kernel/entry_32.S
> > > > > > @@ -225,6 +225,7 @@ ENTRY(ret_from_fork)
> > > > > >  	GET_THREAD_INFO(%ebp)
> > > > > >  	popl %eax
> > > > > >  	CFI_ADJUST_CFA_OFFSET -4
> > > > > > +ret_from_fork_tail:
> > > > > >  	pushl $0x0202			# Reset kernel eflags
> > > > > >  	CFI_ADJUST_CFA_OFFSET 4
> > > > > >  	popfl
> > > > > > @@ -233,6 +234,26 @@ ENTRY(ret_from_fork)
> > > > > >  	CFI_ENDPROC
> > > > > >  END(ret_from_fork)
> > > > > >
> > > > > > +ENTRY(i386_ret_from_resume)
> > > > > > +	CFI_STARTPROC
> > > > > > +	pushl %eax
> > > > > > +	CFI_ADJUST_CFA_OFFSET 4
> > > > > > +	call schedule_tail
> > > > > > +	GET_THREAD_INFO(%ebp)
> > > > > > +	popl %eax
> > > > > > +	CFI_ADJUST_CFA_OFFSET -4
> > > > > > +	movl (%esp), %eax
> > > > > > +	testl %eax, %eax
> > > > > > +	jz    1f
> > > > > > +	pushl %esp
> > > > > > +	call  *%eax
> > > > > > +	addl  $4, %esp
> > > > > > +1:
> > > > > > +	addl  $256, %esp
> > > > > > +	jmp   ret_from_fork_tail
> > > > > > +	CFI_ENDPROC
> > > > > > +END(i386_ret_from_resume)
> > > > >
> > > > > Could you explain why you need to do this
> > > > >
> > > > > 	call  *%eax
> > > > >
> > > > > is it related to the freezer code ?
> > > >
> > > > It is not related to the freezer code actually.
> > > > That is needed to restart syscalls. Right now I don't have a code in
> > > > my patchset which restarts a syscall, but later I plan to add it. In
> > > > OpenVZ checkpointing we restart syscalls if process was caught in
> > > > syscall during checkpointing.
> > >
> > > Do you checkpoint uninterruptible syscalls as well? If only
> > > interruptible syscalls are checkpointed, I'd say that either this
> > > syscall uses ERESTARTSYS or ERESTART_RESTARTBLOCK, and then signal
> > > handling code already does the trick, or this syscall does not restart
> > > itself when interrupted, and well, this is life, userspace just sees
> > > -EINTR, which is allowed by the syscall spec.
> > > Actually this is how we checkpoint/migrate tasks in interruptible
> > > syscalls in Kerrighed and this works.
> >
> > We checkpoint only interruptible syscalls. Some syscalls do not restart
> > themself, that is why after restarting a process we restart syscall to
> > complete it.
>
> I guess you do that to avoid breaking application that are badly written
> and do not handle -EINTR correctly with interruptible syscalls. Right?

Right, also this is needed to restart some syscalls (like pause) from kernel 
without returning to user space. Let me explain it in more details. There is 
a gap when process will be in user space just before entering syscall again. 
At this time a signal can be delivered to process and it even can be handled. 
So, we will miss a signal which must interrupt pause syscall.

Andrey
