From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 2/2] Notify container-init parent a 'reboot' occured
Date: Thu, 11 Aug 2011 16:09:52 -0500
Message-ID: <20110811210951.GA17349__29321.5888472789$1313097128$gmane$org@peqn>
References: <1313094241-3674-1-git-send-email-daniel.lezcano@free.fr>
	<1313094241-3674-3-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1313094241-3674-3-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> When the reboot syscall is called and the pid namespace where the calling
> process belongs to is not from the init pidns, we send a SIGCHLD with CLD_REBOOTED
> to the parent of this pid namespace.
> 
> Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

...

> +void do_notify_parent_cldreboot(struct task_struct *tsk, int why, char *buffer)
> +{
> +	struct siginfo info = { };
> +	struct task_struct *parent;
> +	struct sighand_struct *sighand;
> +	unsigned long flags;
> +
> +	if (tsk->ptrace)
> +		parent = tsk->parent;
> +	else {
> +		tsk = tsk->group_leader;
> +		parent = tsk->real_parent;
> +	}
> +
> +	info.si_signo = SIGCHLD;
> +	info.si_errno = 0;
> +	info.si_status = why;
> +
> +	rcu_read_lock();
> +	info.si_pid = task_pid_nr_ns(tsk, parent->nsproxy->pid_ns);
> +	info.si_uid = __task_cred(tsk)->uid;
	
	This eventually should become:

	info.si_uid = user_ns_map_uid(task_cred_xxx(t, user_ns),
	                              current_cred(), current_uid());

	I've got a first-stab patch at converting the rest of
	kernel/signal.c in http://kernel.ubuntu.com/git?p=serge/userns-2.6.git

> +	rcu_read_unlock();
> +
> +	info.si_utime = cputime_to_clock_t(tsk->utime);
> +	info.si_stime = cputime_to_clock_t(tsk->stime);
> +
> +	info.si_code = CLD_REBOOTED;
> +
> +	sighand = parent->sighand;
> +	spin_lock_irqsave(&sighand->siglock, flags);
> +	if (sighand->action[SIGCHLD-1].sa.sa_handler != SIG_IGN &&
> +	    sighand->action[SIGCHLD-1].sa.sa_flags & SA_CLDREBOOT)
> +		__group_send_sig_info(SIGCHLD, &info, parent);
> +	/*
> +	 * Even if SIGCHLD is not generated, we must wake up wait4 calls.
> +	 */
> +	__wake_up_parent(tsk, parent);
> +	spin_unlock_irqrestore(&sighand->siglock, flags);
> +}

...

> @@ -426,10 +434,18 @@ SYSCALL_DEFINE4(reboot, int, magic1, int, magic2, unsigned int, cmd,
>  {
>  	char buffer[256];
>  	int ret = 0;
> +	struct pid_namespace *pid_ns = current->nsproxy->pid_ns;
> +
> +        /* We only trust the superuser with rebooting the system. */
> +	if (!capable(CAP_SYS_BOOT)) {

Doesn't this mean that an unprivileged task in a container can shut
down the container?

The pidns->user_ns patch I sent earlier today gives you what you need
so that you can add

		if (!ns_capable(current_pid_ns()->user_ns, CAP_SYS_BOOT)
			return -EPERM;

right here to prevent that.

> +		/* If we are not in the initial pid namespace, we send a signal
> +		 * to the parent of this init pid namespace, notifying a shutdown
> +		 * occured */
> +		if (pid_ns != &init_pid_ns)
> +			pid_namespace_reboot(pid_ns, cmd, buffer);
>  
> -	/* We only trust the superuser with rebooting the system. */
> -	if (!capable(CAP_SYS_BOOT))
>  		return -EPERM;
> +	}
>  
>  	/* For safety, we require "magic" arguments. */
>  	if (magic1 != LINUX_REBOOT_MAGIC1 ||
> -- 
> 1.7.4.1
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
