From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/1] freezer: change ptrace_stop/do_signal_stop to use
	freezable_schedule()
Date: Thu, 25 Oct 2012 10:18:12 -0700
Message-ID: <20121025171812.GE11442__5883.771836716$1351185509$gmane$org@htj.dyndns.org>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<1350426526-14254-3-git-send-email-tj@kernel.org>
	<20121022174404.GA21553@redhat.com>
	<20121022211317.GD5951@atj.dyndns.org>
	<20121023153919.GA16201@redhat.com>
	<20121024185710.GA12182@atj.dyndns.org>
	<20121025163941.GA3801@redhat.com>
	<20121025163959.GB3801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121025163959.GB3801-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Oleg.

On Thu, Oct 25, 2012 at 06:39:59PM +0200, Oleg Nesterov wrote:
> Change ptrace_stop() and do_signal_stop() to use freezable_schedule()
> rather than rely on subsequent try_to_freeze().
> 
> This allows to remove the task_is_stopped_or_traced() checks from
> try_to_freeze_tasks() and update_if_frozen(), and this fixes the
> unlikely race with ptrace_stop(). If the tracee does not schedule()
> it can miss a freezing condition.

I think it would be great if the description is more detailed.  This
code path always makes my head spin and I think we can definitely use
some more guiding in understanding this dang thing. :)

> @@ -48,18 +48,7 @@ static int try_to_freeze_tasks(bool user_only)
>  			if (p == current || !freeze_task(p))
>  				continue;
>  
> -			/*
> -			 * Now that we've done set_freeze_flag, don't
> -			 * perturb a task in TASK_STOPPED or TASK_TRACED.
> -			 * It is "frozen enough".  If the task does wake
> -			 * up, it will immediately call try_to_freeze.
> -			 *
> -			 * Because freeze_task() goes through p's scheduler lock, it's
> -			 * guaranteed that TASK_STOPPED/TRACED -> TASK_RUNNING
> -			 * transition can't race with task state testing here.
> -			 */
> -			if (!task_is_stopped_or_traced(p) &&
> -			    !freezer_should_skip(p))
> +			if (!freezer_should_skip(p))
>  				todo++;
>  		} while_each_thread(g, p);
>  		read_unlock(&tasklist_lock);

This looks really good.

> diff --git a/kernel/signal.c b/kernel/signal.c
> index 0af8868..1660d7d 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -1908,7 +1908,7 @@ static void ptrace_stop(int exit_code, int why, int clear_code, siginfo_t *info)
>  		preempt_disable();
>  		read_unlock(&tasklist_lock);
>  		preempt_enable_no_resched();
> -		schedule();
> +		freezable_schedule();
>  	} else {
>  		/*
>  		 * By the time we got the lock, our tracer went away.
> @@ -1930,13 +1930,6 @@ static void ptrace_stop(int exit_code, int why, int clear_code, siginfo_t *info)
>  	}
>  
>  	/*
> -	 * While in TASK_TRACED, we were considered "frozen enough".
> -	 * Now that we woke up, it's crucial if we're supposed to be
> -	 * frozen that we freeze now before running anything substantial.
> -	 */
> -	try_to_freeze();
> -
> -	/*
>  	 * We are back.  Now reacquire the siglock before touching
>  	 * last_siginfo, so that we are sure to have synchronized with
>  	 * any signal-sending on another CPU that wants to examine it.
> @@ -2092,7 +2085,7 @@ static bool do_signal_stop(int signr)
>  		}
>  
>  		/* Now we don't run again until woken by SIGCONT or SIGKILL */
> -		schedule();
> +		freezable_schedule();

This makes me wonder whether we still need try_to_freeze() in
get_signal_to_deliver() right after the relock: label.  Freezer no
longer treats STOPPED/TRACED special and both sleeping sites in signal
deliver path are marked freezable_schedule().  We shouldn't need the
explicit try_to_freeze(), right?

Thanks.

-- 
tejun
