From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] s390: set TIF_RESTARTBLOCK after sys_restart()
Date: Wed, 27 Jan 2010 17:56:48 -0600
Message-ID: <20100127235648.GA467@us.ibm.com>
References: <20100127165954.GA14950@us.ibm.com>
	<4B60B3D5.4030009@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B60B3D5.4030009-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > (this is on top of the patch
> > 	's390: actually restart syscalls after sys_restart'
> > which I sent last Thursday)
> > 
> > We use TIF_RESTARTBLOCK in do_signal() to tell sys_checkpoint()
> > to mark the thread as needing a sysc_do_restart to restart an
> > interrupted syscall after sys_restart().
> > 
> > However, as Oren pointed out, if the task receives a signal
> > after sys_restart() but before returning to userspace, and
> > enters do_signal, then conditions will not be met to set
> > TIF_RESTARTBLOCK.  So if the restarted task freezes here and is
> > checkpointed, then the resulting checkpoint image will not restart
> > the interrupted syscall.
> > 
> > So, set TIF_RESTARTBLOCK in sys_restart() if TIF_RESTARTBLOCK was set
> > at checkpoint.  Clear TIF_RESTARTBLOCK in ssyc_do_restart, so that
> 
> All I see in this patch (below) is the "clear" part. I don't see
> the "set" part.

Drat.  And I seem to have wiped it from my working tree - though
it was just:

diff --git a/arch/s390/mm/checkpoint.c b/arch/s390/mm/checkpoint.c
index d8d4b6b..3e8109b 100644
--- a/arch/s390/mm/checkpoint.c
+++ b/arch/s390/mm/checkpoint.c
@@ -74,6 +74,7 @@ static void s390_copy_regs(int op, struct ckpt_hdr_cpu *h,
	if (op == CKPT_RST && h->should_restart) {
		regs->gprs[2] = __NR_restart_syscall;
		set_thread_flag(TIF_RESTART_SVC);
+		set_thread_flag(TIF_RESTARTBLOCK);
	}
	CKPT_COPY_ARRAY(op, h->fprs, thr->fp_regs.fprs, NUM_FPRS);
	CKPT_COPY_ARRAY(op, h->acrs, thr->acrs, NUM_ACRS);


> Also, I'm still not convinced that this fixes all 3 issues that
> I mentioned in the other thread.

Well, at the end of sys_restart(), we've set up the registers and
flags (almost) exactly as they would have been if a signal 0 had
been received and processed through do_signal (which it was, from
the freezer).  That is for the -ERESTART_RESTARTBLOCK case.  In the
case that we went into the freezing do_signal (the one where we
were originally checkpointed) with -ERESTARTNOHAND, -ERESTARTSYS,
or -ERESTARTNOINTR, then for a signr == 0 we don't do any further
processing in do_signal - it was all done before get_signal_to_deliver()
which is where we froze.  So there is nothing further to emulate
(except sigmask restore which is not handled atm).

The only thing that isn't done is the unsetting of TIF_RESTARTBLOCK.
IIUC the only paths we can follow after the sys_restart() syscall,
are do_sysc_restart or do_signal.  In do_signal we will re-set it,
and after this patch we also do in do_sysc_restart.

I do agree I should still restore certain TIF flags in the
arch/s390/mm/checkpoint.c:arch_restore_thread() function, such
as TIF_RESTORE_SIGMASK.  However that will require still more
emulation work as TIF_RESTORE_SIGMASK gets tweaked at the end of
do_signal().

Anyway, I think a full patch including these two patches plus the
resetting of TIF_RESTORE_SIGMASK should go to the s390 devel list
where I'm sure they'll gladly tear me to tasty little bits.

-serge
