From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] user-cr: invoke exit system call directly from
	ckpt_do_feeder
Date: Thu, 26 Nov 2009 10:10:15 -0500
Message-ID: <4B0E9A57.4020501@cs.columbia.edu>
References: <1259108404.10928.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1259108404.10928.3.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Nathan Lynch wrote:
> The feeder thread can cause the restart process to fail by indirectly
> calling exit_group, which sends SIGKILL to all other threads in the
> process.  If the feeder thread "wins" the race, the restart is
> disrupted.  A common symptom of this race is the coordinator task
> returning from the wait_for_completion_interruptible in
> wait_all_tasks_finish with a signal (the SIGKILL) pending.

So the clone mage page says:
  ...
  The main use of clone() is to implement threads: multiple threads
  of control in a program that run concurrently in a shared memory
  space.
  ...
  When the fn(arg) function application returns, the child process
  terminates. The integer returned by fn is the exit code for the
  child process.  The child process may also terminate explicitly by
  calling exit(2) or after receiving a fatal signal.
  ...
(http://www.kernel.org/doc/man-pages/online/pages/man2/__clone2.2.html)

I expected "terminates" here to mean invoke the syscall _exit().
Clearly this is desirable with CLONE_THREAD, but not for regular
processes that will want to proceed to the usual glibc exit path
(e.g. process at_exit() and what-not). Then again, the last thread
to exit should also call glibc's exit for the same reason. So
that's probably why it's handled this way.

This matters for us because our user-space wrapper to eclone()
should eventually do what the glibc's clone() wrapper does, instead
of calling _exit() directly as it is today...

???

Oren.

> 
> Calling _exit isn't enough; see
> http://www.kernel.org/doc/man-pages/online/pages/man2/exit.2.html#NOTES
> 
> Exit the feeder thread by using the syscall() macro.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  restart.c |   12 ++++++++++--
>  1 files changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/restart.c b/restart.c
> index d5d069a..ed4268c 100644
> --- a/restart.c
> +++ b/restart.c
> @@ -2079,8 +2079,16 @@ static int ckpt_do_feeder(void *data)
>  		ckpt_read_write_inspect(ctx);
>  	else
>  		ckpt_read_write_blind(ctx);
> -		
> -	/* all is well: feeder thread is done */
> +
> +	/* All is well: feeder thread is done.  However, we must
> +	 * invoke the exit system call directly. Otherwise, upon
> +	 * return from this function, glibc's clone wrapper will call
> +	 * _exit, which calls exit_group, which will terminate the
> +	 * whole process, which is not what we want.
> +	 */
> +	syscall(SYS_exit, 0);
> +
> +	/* not reached */
>  	return 0;
>  }
>  
