From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] s390: set TIF_RESTARTBLOCK after sys_restart()
Date: Wed, 27 Jan 2010 16:44:53 -0500
Message-ID: <4B60B3D5.4030009@cs.columbia.edu>
References: <20100127165954.GA14950@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100127165954.GA14950-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Serge E. Hallyn wrote:
> (this is on top of the patch
> 	's390: actually restart syscalls after sys_restart'
> which I sent last Thursday)
> 
> We use TIF_RESTARTBLOCK in do_signal() to tell sys_checkpoint()
> to mark the thread as needing a sysc_do_restart to restart an
> interrupted syscall after sys_restart().
> 
> However, as Oren pointed out, if the task receives a signal
> after sys_restart() but before returning to userspace, and
> enters do_signal, then conditions will not be met to set
> TIF_RESTARTBLOCK.  So if the restarted task freezes here and is
> checkpointed, then the resulting checkpoint image will not restart
> the interrupted syscall.
> 
> So, set TIF_RESTARTBLOCK in sys_restart() if TIF_RESTARTBLOCK was set
> at checkpoint.  Clear TIF_RESTARTBLOCK in ssyc_do_restart, so that

All I see in this patch (below) is the "clear" part. I don't see
the "set" part.

Also, I'm still not convinced that this fixes all 3 issues that
I mentioned in the other thread.

Oren.


> if we do not go to do_signal right after sys_restart() we don't
> mistakenly keep running with that flag.
> 
> To test this, add a dummy handler for SIGUSR1 to cr_tests/sleep/sleeptest.c,
> open two terminals, and do:
> 
> Terminal 1:                             Terminal :
> mount -t cgroup -o freezer freezer /cgroup
> mkdir /cgroup/1 /cgroup/2
> echo $$ > /cgroup/1/tasks
> ./sleeptest
> 
>                                         echo FROZEN > /cgroup/1/freezer.state
>                                         checkpoint `pidof sleeptest` > /tmp/out
>                                         thaw
> 
> restart -F /cgroup/2 < /tmp/out
> 
>                                         kill -USR1 `pidof sleeptest`;
>                                         echo THAWED > /cgroup/2/freezer.state ;
>                                         sleep 0.3;
>                                         echo FROZEN > /cgroup/2/freezer.state;
>                                         checkpoint `pidof sleeptest` > /tmp/out2;
>                                         echo THAWED > /cgroup/2/freezer.state
> 
> restart < /tmp/out2
> 
> Without this patch, the final restart will immediately exit.  With
> this patch, it will restart the sleep.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  arch/s390/kernel/entry64.S |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/s390/kernel/entry64.S b/arch/s390/kernel/entry64.S
> index 9aff1d4..798ea9c 100644
> --- a/arch/s390/kernel/entry64.S
> +++ b/arch/s390/kernel/entry64.S
> @@ -58,6 +58,7 @@ _TIF_WORK_INT = (_TIF_SIGPENDING | _TIF_NOTIFY_RESUME | _TIF_NEED_RESCHED | \
>  		 _TIF_MCCK_PENDING)
>  _TIF_SYSCALL = (_TIF_SYSCALL_TRACE>>8 | _TIF_SYSCALL_AUDIT>>8 | \
>  		_TIF_SECCOMP>>8 | _TIF_SYSCALL_TRACEPOINT>>8)
> +CLR_TIF_RESTARTBLOCK = (255 - (_TIF_RESTARTBLOCK>>16))
>  
>  #define BASED(name) name-system_call(%r13)
>  
> @@ -338,6 +339,7 @@ sysc_mcck_pending:
>  #
>  sysc_sigpending:
>  	ni	__TI_flags+7(%r9),255-_TIF_SINGLE_STEP # clear TIF_SINGLE_STEP
> +	ni	__TI_flags+6(%r9),CLR_TIF_RESTARTBLOCK # clear TIF_RESTARTBLOCK
>  	la	%r2,SP_PTREGS(%r15)	# load pt_regs
>  	brasl	%r14,do_signal		# call do_signal
>  	tm	__TI_flags+7(%r9),_TIF_RESTART_SVC
