From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/7] freezer: add missing mb's to freezer_count() and
	freezer_should_skip()
Date: Mon, 22 Oct 2012 19:44:04 +0200
Message-ID: <20121022174404.GA21553@redhat.com>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<1350426526-14254-3-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1350426526-14254-3-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/16, Tejun Heo wrote:
>
> +/**
> + * freezer_count - tell freezer to stop ignoring %current
> + *
> + * Undo freezer_do_not_count().  It tells freezers that %current should be
> + * considered again and tries to freeze if freezing condition is already in
> + * effect.
>   */
>  static inline void freezer_count(void)
>  {
>  	current->flags &= ~PF_FREEZER_SKIP;
> +	/*
> +	 * If freezing is in progress, the following paired with smp_mb()
> +	 * in freezer_should_skip() ensures that either we see %true
> +	 * freezing() or freezer_should_skip() sees !PF_FREEZER_SKIP.
> +	 */
> +	smp_mb();
>  	try_to_freeze();

I agree, this looks like a bug fix.

> -static inline int freezer_should_skip(struct task_struct *p)
> +static inline bool freezer_should_skip(struct task_struct *p)
>  {
> -	return !!(p->flags & PF_FREEZER_SKIP);
> +	/*
> +	 * The following smp_mb() paired with the one in freezer_count()
> +	 * ensures that either freezer_count() sees %true freezing() or we
> +	 * see cleared %PF_FREEZER_SKIP and return %false.  This makes it
> +	 * impossible for a task to slip frozen state testing after
> +	 * clearing %PF_FREEZER_SKIP.
> +	 */
> +	smp_mb();
> +	return p->flags & PF_FREEZER_SKIP;
>  }

I am not sure we really need smp_mb() here. Speaking of cgroup_freezer,
it seems that a single mb() after "->state = CGROUP_FREEZING" should be
enough.

But even if I am right, I agree that it looks better in freezer_should_skip()
and this is more robust.

So I think the patch is fine and fixes the bug.





We probably have another similar race. If ptrace_stop()->may_ptrace_stop()
returns false, the task does

	__set_current_state(TASK_RUNNING);
	// no mb in between
	try_to_freeze();

And this can race with task_is_stopped_or_traced() check in the same way.
(of course this is only theoretical).


do_signal_stop() is probably fine, we can rely on ->siglock.

Oleg.
