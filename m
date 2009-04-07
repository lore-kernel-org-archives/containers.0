From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc3][PATCH 15/36] c/r of restart-blocks
Date: Tue, 07 Apr 2009 14:44:17 -0400
Message-ID: <49DB9F01.4050605@cs.columbia.edu>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>	<1239107264-21775-16-git-send-email-orenl@cs.columbia.edu>
	<87r6042uwm.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87r6042uwm.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Dan Smith wrote:
> OL> +int cr_retval_restart(struct cr_ctx *ctx)
> OL> +{
> OL> +	struct pt_regs *regs = task_pt_regs(current);
> OL> +	int ret = 0;
> OL> +
> OL> +	/*
> OL> +	 * The retval should be either zero if the checkpointed task
> OL> +	 * had been in user-space when frozen, or the retval from the
> OL> +	 * syscall that had been interrupted then.
> OL> +	 *
> OL> +	 * In the latter, if the syscall succeeded (perhaps partially)
> OL> +	 * then the retval is non-negative. If it failed, the error
> OL> +	 * may be one of -ERESTART... gang, interpreted in the signal
> OL> +	 * handling code. In restart it must happen, too.
> OL> +	 *
> OL> +	 * To force execution of the signal handler now, too, we fake
> OL> +	 * a signal to ourselves (a la freeze/thaw) when ret < 0.
> OL> +	 */
> OL> +
> OL> +	/* were we from a system call?  if so, get old error/retval */
> OL> +	if (syscall_get_nr(current, regs) >= 0)
> OL> +		ret = syscall_get_error(current, regs);

The test "were we from a system call ?" is implemented differently on
the s390, for example. Compare the code in handle_signal(), whose logic
I follow.

> OL> +	/* old error ?  if so, make sure signal handling kicks in */
> OL> +	if (ret < 0)
> OL> +		set_tsk_thread_flag(current, TIF_SIGPENDING);
> OL> +	return ret;

> OL> +}
> 
> Does this need to be arch-specific?  At first glance, I can't think of
> anything I'd need to change for s390, for example.
> 

So the code above is similar to that in handle_signal() of x86_32 arch.
The same code in other architectures looks differently, and I didn't
investigate whether the code in other architectures can be transformed
to a common form.

Oren.
