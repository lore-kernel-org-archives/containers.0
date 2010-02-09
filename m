From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] s390: let tasks know to restart syscalls after
	sys_restart()
Date: Tue, 9 Feb 2010 11:12:32 -0600
Message-ID: <20100209171232.GA21899@us.ibm.com>
References: <20100128233528.GA10140@us.ibm.com>
	<4B6B908F.10709@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B6B908F.10709-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > (This is a patch against the checkpoint/restart kernel tree at
> > http://git.ncl.cs.columbia.edu/?p=linux-cr.git;a=shortlog;h=refs/heads/ckpt-v19-rc2.9)
> > 
> > On x86, do_signal() leaves -516 in eax while it freezes, which
> > sys_restart() can use to detect that it should restart the
> > syscall which was interrupted by a signal (or the freezer).
> > 
> > On s390, gprs[2] gets tweaked to -EINTR (-4) instead, leaving
> > us no reliable way to tell whether should be restarted.  If the
> > task is checkpointed here and then restarted, then the last part
> > of do_signal() won't be done, and the interrupted syscall won't
> > be restarted.
> > 
> > This patch defines TIF_RESTARTBLOCK as a thread flag showing that
> > the thread expects to be frozen while kicked out of a restartable
> > syscall by a signal.
> > 
> > The TIF_RESTARTBLOCK flag is only set for the duration of the
> > get get_signal_to_deliver() which is where the task may get
> > frozen.  We also set it in sys_restart() if the checkpointed task
> > had had TIF_RESTARTBLOCK set.  It will get cleared if upon exiting
> > sys_restart() we jump to sysc_sigpending.  If instead we jump back
> > to do_signal(), then TIF_RESTARTBLOCK will stay set again until
> > after get_signal_to_deliver() so that if it immediately freezes and
> > is re-checkpointed, the resulting second checkpoint image again
> > will have TIF_RESTARTBLOCK set.
> 
> Two comments:
> 
> 1) This note will be lost once we fold this patch into a clean
> patchset. Can you please make it part of the code ?

Sure, good idea.

> 2) Maybe I'm missing something, but I'm not convinced. Can you
> elaborate on why this is correct in different cases ?  Also, in
> particular with respect to the post-signal-sent snippet in the
> signal handling code:
> 
>         if (retval == -ERESTART_RESTARTBLOCK
>             && regs->psw.addr == continue_addr) {
> 
>                 regs->gprs[2] = __NR_restart_syscall;
> 
>                 set_thread_flag(TIF_RESTART_SVC);
> 
>         }
> 
> 
> Would it do what you expect after a restart ?  (restart modifies
> the psw.addr)

I don't understand the question.  After sys_restart(), we won't be
returning to this kernel code.  We'll either immediately call
restart_syscall(), or, if a signal was delivered before sys_restart(),
completed, then do_signal() will start again from the top.

In the first case we're doing exactly what we wanted to.

In that second case, we enter do_signal with very different
initial conditions than the checkpointed case:  regs->svcnr is 0,
so none of the gprs[2] or svcnr or psw-addr tweaking that
would have happened the first time will happen.  We'll just
handle the signal (if any), then, upon exit of do_signal,
proceed again with regs->gprs[2] == __NR_restart_syscall.

But, since thread_info_flags->TIF_RESTARTBLOCK is set,
if we get frozen and checkpointed again during the
get_signal_to_deliver(), a restart of that image should
be exactly the same as a restart of the current image.

(That, at least, is my intent and understanding :)

-serge
