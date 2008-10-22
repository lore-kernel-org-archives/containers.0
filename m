From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 08/10] Introduce functions to restart a process
Date: Wed, 22 Oct 2008 12:49:54 +0400
Message-ID: <200810221249.55600.major__25690.414364408$1224665616$gmane$org@openvz.org>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-9-git-send-email-major@openvz.org>
	<48FC4E0C.7050008@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48FC4E0C.7050008-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
To: devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Monday 20 October 2008 13:23 Cedric Le Goater wrote:
> Hello Andrey !
>
> > diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
> > index 109792b..a4848a3 100644
> > --- a/arch/x86/kernel/entry_32.S
> > +++ b/arch/x86/kernel/entry_32.S
> > @@ -225,6 +225,7 @@ ENTRY(ret_from_fork)
> >  	GET_THREAD_INFO(%ebp)
> >  	popl %eax
> >  	CFI_ADJUST_CFA_OFFSET -4
> > +ret_from_fork_tail:
> >  	pushl $0x0202			# Reset kernel eflags
> >  	CFI_ADJUST_CFA_OFFSET 4
> >  	popfl
> > @@ -233,6 +234,26 @@ ENTRY(ret_from_fork)
> >  	CFI_ENDPROC
> >  END(ret_from_fork)
> >
> > +ENTRY(i386_ret_from_resume)
> > +	CFI_STARTPROC
> > +	pushl %eax
> > +	CFI_ADJUST_CFA_OFFSET 4
> > +	call schedule_tail
> > +	GET_THREAD_INFO(%ebp)
> > +	popl %eax
> > +	CFI_ADJUST_CFA_OFFSET -4
> > +	movl (%esp), %eax
> > +	testl %eax, %eax
> > +	jz    1f
> > +	pushl %esp
> > +	call  *%eax
> > +	addl  $4, %esp
> > +1:
> > +	addl  $256, %esp
> > +	jmp   ret_from_fork_tail
> > +	CFI_ENDPROC
> > +END(i386_ret_from_resume)
>
> Could you explain why you need to do this
>
> 	call  *%eax
>
> is it related to the freezer code ?

It is not related to the freezer code actually.
That is needed to restart syscalls. Right now I don't have a code in my 
patchset which restarts a syscall, but later I plan to add it.
In OpenVZ checkpointing we restart syscalls if process was caught in syscall 
during checkpointing.

Andrey
