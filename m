From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Notify container-init parent a 'reboot' occured
Date: Sun, 14 Aug 2011 18:01:12 +0200
Message-ID: <20110814160112.GA29798__48742.2023005367$1313337896$gmane$org@redhat.com>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/11, Daniel Lezcano wrote:
>
> When the reboot syscall is called and the pid namespace where the calling
> process belongs to is not from the init pidns, we send a SIGCHLD with CLD_REBOOTED
> to the parent of this pid namespace.

OK, but why you can't simply send the signal?

Why do you need the strange do_notify_parent_cldreboot() which tries
to mimic do_notify_parent() for (afaics) no reason ?

> +void do_notify_parent_cldreboot(struct task_struct *tsk, int why, char *buffer)

buffer is not used. Why?

> +	if (tsk->ptrace)
> +		parent = tsk->parent;
> +	else {
> +		tsk = tsk->group_leader;
> +		parent = tsk->real_parent;
> +	}

For what? I simply can't understand this...

> +     sighand = parent->sighand;
> +     spin_lock_irqsave(&sighand->siglock, flags);

this is unsafe, we can't trust ->sighand and parent.

> +	 * Even if SIGCHLD is not generated, we must wake up wait4 calls.

but not in this case, afaics?

> +	__wake_up_parent(tsk, parent);

Why do you need __wake_up_parent()?

> +static void pid_namespace_reboot(struct pid_namespace *pid_ns,
> +				int cmd, char *buffer)
> +{
> +	struct task_struct *tsk = pid_ns->child_reaper;
> +	do_notify_parent_cldreboot(tsk, cmd, buffer);

nothing prevents ->child_reaper from exiting it it is multithreaded,
this can crash the kernel.

> @@ -426,10 +434,18 @@ SYSCALL_DEFINE4(reboot, int, magic1, int, magic2, unsigned int, cmd,
>  {
>  	char buffer[256];

again, it is not used.

>  	int ret = 0;
> +	struct pid_namespace *pid_ns = current->nsproxy->pid_ns;
> +
> +        /* We only trust the superuser with rebooting the system. */
> +	if (!capable(CAP_SYS_BOOT)) {
> +		/* If we are not in the initial pid namespace, we send a signal
> +		 * to the parent of this init pid namespace, notifying a shutdown
> +		 * occured */
> +		if (pid_ns != &init_pid_ns)
> +			pid_namespace_reboot(pid_ns, cmd, buffer);

Hmm. Looks like pid_ns should be checked after CAP_SYS_BOOT?

Oleg.
