From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC][PATCH][v2] Define/use siginfo_from_ancestor_ns()
Date: Tue, 18 Nov 2008 18:53:36 +0100
Message-ID: <20081118175336.GA14178@redhat.com>
References: <20081115212133.GA32140@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754627AbYKRQxr@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081115212133.GA32140@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: ebiederm@xmission.com, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 11/15, Sukadev Bhattiprolu wrote:
>
> Subject: [PATCH] Define/use siginfo_from_ancestor_ns()

Imho, the main problem with this patch is that it tries to do many
different things at once, and each part is suboptimal/incomplete.

This needs several patches. Not only because this is easier to review,
but also because each part needs the good changelog.

Also. I don't think we should try do solve the "whole" problem right
now. For example, if we add/use siginfo_from_ancestor_ns(), we should
also change sys_sigaction(SIG_IGN). As I said, imho we should start
with:

	- cinit can't be killed from its namespace

	- the parent ns can always SIGKILL cinit

This solves most of problems, and this is very simple.

As for .si_pid mangling, this again needs a separate patch.

Sukadev, I don't have a time today, I'll return tomorrow with more
comments on this...

> +static int sig_ignored(struct task_struct *t, int sig, int same_ns)
>  {
>  	void __user *handler;
>
> @@ -68,6 +68,14 @@ static int sig_ignored(struct task_struct *t, int sig)
>  	handler = sig_handler(t, sig);
>  	if (!sig_handler_ignored(handler, sig))
>  		return 0;
> +	/*
> +	 * ignores SIGSTOP/SIGKILL signals to init from same namespace.
> +	 *
> +	 * TODO: Ignore unblocked SIG_DFL signals also here or drop them
> +	 * 	 in get_signal_to_deliver() ?
> +	 */
> +	if (is_container_init(t) && same_ns && sig_kernel_only(sig))
> +		return 1;

No, no. is_container_init() is slow and unneeded, same_ns is bogus,
the usage of sig_kernel_only() is suboptimal. The comment is not
right too...

As I already said, this problem is not namespace-specific, we need
some changes for the global init too.

Actually, I already did the patch, I'll send it soon.

>  static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
>  			int group)
>  {
>  	struct sigpending *pending;
>  	struct sigqueue *q;
> +	int from_ancestor_ns;
> +
> +	from_ancestor_ns = 0;
> +	if (siginfo_from_user(info)) {
> +		/* if t can't see us we are from parent ns */
> +		if (task_pid_nr_ns(current, task_active_pid_ns(t)) == 0)
                                            ^^^^^^^^^^^^^^^^^^

->nsproxy may be NULL, but we can use task_pid(t)->numbers[-1].ns

> @@ -864,6 +902,9 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
>  		 * and sent by user using something other than kill().
>  		 */
>  			return -EAGAIN;
> +
> +		if (from_ancestor_ns)
> +			return -ENOMEM;

This change alone needs a fat comment in changelog. But I don't think
we need it now. Until we change the dequeue path to check "from_ancestor_ns".

> +static inline int siginfo_from_ancestor_ns(siginfo_t *info)
> +{
> +	return SI_FROMUSER(info) && (info->si_pid == 0);
> +}

Yes, this is problem... I doubt we can rely on !si_pid here.
More on this later.

> @@ -2296,10 +2347,25 @@ sys_rt_sigqueueinfo(pid_t pid, int sig, siginfo_t __user *uinfo)
>  	   Nor can they impersonate a kill(), which adds source info.  */
>  	if (info.si_code >= 0)
>  		return -EPERM;
> -	info.si_signo = sig;
> +	info.si_signo = sig | SIG_FROM_USER;
>
>  	/* POSIX.1b doesn't mention process groups.  */
> -	return kill_proc_info(sig, &info, pid);
> +	rcu_read_lock();
> +	spid = find_vpid(pid);
> +	/* 
> +	 * A container-init (cinit) ignores/drops fatal signals unless sender
> +	 * is in an ancestor namespace.  Cinit uses 'si_pid == 0' to check if
> +	 * sender is an ancestor. See siginfo_from_ancestor_ns().
> +	 *
> +	 * If signalling a descendant cinit, set si_pid to 0 so it does not
> +	 * get ignored/dropped.
> +	 */
> +	if (!pid_nr_ns(spid, task_active_pid_ns(current)))
> +		info.si_pid = 0;
> +	error = kill_pid_info(sig, &info, spid);

Can't understand. We set SIG_FROM_USER, If signalling a descendant task
(not only cinit), send_signal() will clear .si_pid anyway?

Oleg.
