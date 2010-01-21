From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] s390: actually restart syscalls after sys_restart
Date: Thu, 21 Jan 2010 10:21:52 -0500 (EST)
Message-ID: <Pine.LNX.4.64.1001210904210.6064@takamine.ncl.cs.columbia.edu>
References: <20100121062802.GA2770@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100121062802.GA2770-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

I'm not sure thix fix is totally correct. 

First, a reminder of how -ERESTART... errors behave:

1) If a (user) signal handler was *not* called then:
  -ERESTARTSYS:    re-execute syscall
  -ERESTARTNOHAND:    re-execute syscall   
  -ERESTARTNOINTR:    re-execute syscall
  -ERESTART_RESTARTBLOCK:   arrange to call sys_restart_syscall

2) If a (user) signal handler *was* called then:
  -ERESTARTSYS:    re-execute syscall iff SA_RESTART (else EINTR)
  -ERESTARTNOHAND:    return -EINTR
  -ERESTARTNOINTR:    re-execute syscall
  -ERESTART_RESTARTBLOCK:   return -EINTR

The difference between x86 and s390 is _when_ (and how) the task state is
altered (to arrange for re-execution), in case of task freezing:

* In x86, changes occur _after_ the task is frozen, and the work is split 
between handle_signal() and do_signal().

* In s390, some changes occur _before_ the task is frozen, and possibly 
undone after the freeze if a signal handler was called. All work is done 
is do_signal(). Because of that, our checkpoint only sees a partial view 
of the task's state.

Now back to the proposed fix: it isn't sufficient because:

(a) If the process has a signal pending when checkpointed, then the state 
already reflects some changes by do_signal(). If the signal leads to a 
(user) signal handler after restart, then do_signal() (after restart) will 
_not_ undo the changes originally done before the checkpoint.

This issue holds for ERESTARTSYS, ERESTARTNOHAND and ERESTART_RESTARTBLOCK.

Note that do_signal() after restart will not do the changes again either
in case of -ERESTART.... value, because the regs->svcnr was set to 0 and
recorded that way.

(b) Same, but also if the process didn't have a signal at checkpoint 
time, but will have one during/after restart but before resuming.

(c) Because do_restart() selects its return value from gprs[2] (upon 
successful completion), then when it tries to resume userspace and 
enters do_signal() it will have -EINTR (which isn't the original return 
value!), and therefore not set your new TIF_RESTARTBLOCK bit. If the task 
is now checkpointed again, that state will be lost.


As a side note: I noticed that on x86 there are {checkpoint,restore}_thread() 
that save the thread flags and restore the necessary flags. They also 
check the flags - at checkpoint to ensure the task is checkpointable, and 
at restore for sanity.  Is there not a need for something similar for s390?

That would be an appropriate place to svae and restore a TIF_RESTARTBLOCK
thread flag and fix (c) above, should you stick to that method.

Oren.


On Thu, 21 Jan 2010, Serge E. Hallyn wrote:

> On x86, do_signal() leaves -516 in eax while it freezes, which
> sys_restart() can use to detect that it should restart the
> syscall which was interrupted by a signal (or the freezer).
> On s390, gprs[2] gets tweaked to -EINTR (-4) instead, leaving
> us no reliable way to tell whether should be restarted.
> 
> Define TIF_RESTARTBLOCK as a thread flag showing that the
> thread expects to be frozen while kicked out of a restartable
> syscall by a signal.
> 
> This is needed so that, if it is checkpointed and restarted,
> the restarted task has a way to tell that, upon completion
> of sys_restart(), it should restart the interrupted syscall.
> 
> Without this patch, restart of the program
> 
> 	close(0); close(1); close(2);
> 	sleep(30);
> 
> immediately exits.  With the patch, it continues to sleep for
> the remaining sleep time.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  arch/s390/include/asm/checkpoint_hdr.h |    1 +
>  arch/s390/include/asm/thread_info.h    |    2 ++
>  arch/s390/kernel/signal.c              |    3 +++
>  arch/s390/mm/checkpoint.c              |   16 ++++++++++++++++
>  4 files changed, 22 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
> index bc9f624..4ef14e8 100644
> --- a/arch/s390/include/asm/checkpoint_hdr.h
> +++ b/arch/s390/include/asm/checkpoint_hdr.h
> @@ -73,6 +73,7 @@ struct ckpt_hdr_cpu {
>  	__u8 access_id;
>  	__u8 single_step;
>  	__u8 instruction_fetch;
> +	__u8 should_restart;
>  };
>  
>  struct ckpt_hdr_mm_context {
> diff --git a/arch/s390/include/asm/thread_info.h b/arch/s390/include/asm/thread_info.h
> index 07eb61b..2fac866 100644
> --- a/arch/s390/include/asm/thread_info.h
> +++ b/arch/s390/include/asm/thread_info.h
> @@ -100,6 +100,7 @@ static inline struct thread_info *current_thread_info(void)
>  #define TIF_MEMDIE		19
>  #define TIF_RESTORE_SIGMASK	20	/* restore signal mask in do_signal() */
>  #define TIF_FREEZE		21	/* thread is freezing for suspend */
> +#define TIF_RESTARTBLOCK	23	/* for checkpoint */
>  
>  #define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
>  #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
> @@ -116,6 +117,7 @@ static inline struct thread_info *current_thread_info(void)
>  #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
>  #define _TIF_31BIT		(1<<TIF_31BIT)
>  #define _TIF_FREEZE		(1<<TIF_FREEZE)
> +#define _TIF_RESTARTBLOCK	(1<<TIF_RESTARTBLOCK)
>  
>  #endif /* __KERNEL__ */
>  
> diff --git a/arch/s390/kernel/signal.c b/arch/s390/kernel/signal.c
> index 6b4fef8..1179b19 100644
> --- a/arch/s390/kernel/signal.c
> +++ b/arch/s390/kernel/signal.c
> @@ -458,6 +458,7 @@ void do_signal(struct pt_regs *regs)
>  			regs->psw.addr = restart_addr;
>  			break;
>  		case -ERESTART_RESTARTBLOCK:
> +			set_thread_flag(TIF_RESTARTBLOCK);
>  			regs->gprs[2] = -EINTR;
>  		}
>  		regs->svcnr = 0;	/* Don't deal with this again. */
> @@ -467,6 +468,8 @@ void do_signal(struct pt_regs *regs)
>  	   the debugger may change all our registers ... */
>  	signr = get_signal_to_deliver(&info, &ka, regs, NULL);
>  
> +	clear_thread_flag(TIF_RESTARTBLOCK);
> +
>  	/* Depending on the signal settings we may need to revert the
>  	   decision to restart the system call. */
>  	if (signr > 0 && regs->psw.addr == restart_addr) {
> diff --git a/arch/s390/mm/checkpoint.c b/arch/s390/mm/checkpoint.c
> index 40dd417..d8d4b6b 100644
> --- a/arch/s390/mm/checkpoint.c
> +++ b/arch/s390/mm/checkpoint.c
> @@ -65,6 +65,16 @@ static void s390_copy_regs(int op, struct ckpt_hdr_cpu *h,
>  		BUG_ON(h->gprs[2] < 0);
>  		h->gprs[2] = 0;
>  	}
> +	/*
> +	 * if the checkpointed task was frozen in a syscall with
> +	 * -ERESTART_RESTARTBLOCK (switched to -EINTR during do_signal()
> +	 * before try_to_freeze() happened) * then after restart we need
> +	 * to call __NR_restart_syscall to continue.  Fix up here.
> +	 */
> +	if (op == CKPT_RST && h->should_restart) {
> +		regs->gprs[2] = __NR_restart_syscall;
> +		set_thread_flag(TIF_RESTART_SVC);
> +	}
>  	CKPT_COPY_ARRAY(op, h->fprs, thr->fp_regs.fprs, NUM_FPRS);
>  	CKPT_COPY_ARRAY(op, h->acrs, thr->acrs, NUM_ACRS);
>  	CKPT_COPY_ARRAY(op, h->per_control_regs,
> @@ -98,6 +108,12 @@ int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
>  
>  	s390_copy_regs(CKPT_CPT, h, t);
>  
> +	/*
> +	 * if t was frozen while in a restartable syscall, note that
> +	 */
> +	if (test_ti_thread_flag(task_thread_info(t), TIF_RESTARTBLOCK))
> +		h->should_restart = 1;
> +
>  	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
>  	ckpt_hdr_put(ctx, h);
>  
> 
