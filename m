From: "Maciej W. Rozycki" <macro-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/7] signal/mips: Document a conflict with SI_USER with
	SIGFPE
Date: Wed, 9 Aug 2017 00:19:12 +0100
Message-ID: <alpine.DEB.2.00.1708082212400.17596__13988.324502907$1502234384$gmane$org@tp.orcam.me.uk>
References: <87o9shg7t7.fsf_-_@xmission.com>
	<20170718140651.15973-4-ebiederm@xmission.com>
	<alpine.DEB.2.00.1708071706290.17596@tp.orcam.me.uk>
	<87mv7agjsh.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87mv7agjsh.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 8 Aug 2017, Eric W. Biederman wrote:

> >  This is an "impossible" state to reach unless your hardware is on fire.  
> > One or more of the FCSR Cause bits will have been set (in `fcr31') or the 
> > FPE exception would not have happened.
> >
> >  Of course there could be a simulator bug, or we could have breakage 
> > somewhere causing `process_fpemu_return' to be called with SIGFPE and 
> > inconsistent `fcr31'.  So we need to handle it somehow.
> >
> >  So what would be the right value of `si_code' to use here for such an 
> > unexpected exception condition?  I think `BUG()' would be too big a 
> > hammer here.  Or wouldn't it?
> 
> The possible solutions I can think of are:
> 
> WARN_ON_ONCE with a comment.
> 
> Add a new si_code to uapi/asm-generic/siginfo.h perhaps FPE_IMPOSSIBLE.
> Like syscall numbers si_codes are cheap.

 I think we ought to do both.

 First, we have our own FP emulation code, which is changed from time to 
time, that uses the same exit path that the hardware exception does.  It 
could happen that we miss something and return SIGFPE from the emulation 
code without setting the cause bits appropriately.  This would be our own 
bug which might trigger exceedingly rarely and could then be caught by 
WARN_ON_ONCE or otherwise stay there forever in the absence of that check.

 Second, changing `si_code' from __SI_FAULT to 0 aka __SI_KILL will likely 
interfere with `copy_siginfo_to_user32' in arch/mips/kernel/signal32.c, 
making the userland lose the address of the faulting instruction in 32-bit 
software run on 64-bit hardware only, making our API inconsistent.  Using 
a distinct `si_code' value such as FPE_IMPOSSIBLE (though we might choose 
say FPE_FLTUNK for "FLoaTing point UNKnown" instead, for consistency; mind 
that most `si_code' macros have the same number of characters within 
groups associated with individual signals) for such odd traps is allowed 
by SUS and will prevent the inconsistency from happening, very cheaply as 
you say.

  Maciej
