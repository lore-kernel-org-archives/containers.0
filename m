From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] user-cr: invoke exit system call directly from
	ckpt_do_feeder
Date: Wed, 25 Nov 2009 13:35:28 -0500
Message-ID: <4B0D78F0.7010108@cs.columbia.edu>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Nice catch, Queued for v19-rc2.

Nathan Lynch wrote:
> The feeder thread can cause the restart process to fail by indirectly
> calling exit_group, which sends SIGKILL to all other threads in the
> process.  If the feeder thread "wins" the race, the restart is
> disrupted.  A common symptom of this race is the coordinator task
> returning from the wait_for_completion_interruptible in
> wait_all_tasks_finish with a signal (the SIGKILL) pending.
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
