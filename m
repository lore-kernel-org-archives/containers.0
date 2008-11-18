From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH][v2] Define/use siginfo_from_ancestor_ns()
Date: Tue, 18 Nov 2008 10:37:35 -0800
Message-ID: <20081118183735.GA13517@us.ibm.com>
References: <20081115212133.GA32140@us.ibm.com> <20081118175336.GA14178@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753201AbYKRSlS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081118175336.GA14178@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: ebiederm@xmission.com, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg@redhat.com] wrote:
| On 11/15, Sukadev Bhattiprolu wrote:
| >
| > Subject: [PATCH] Define/use siginfo_from_ancestor_ns()
| 
| Imho, the main problem with this patch is that it tries to do many
| different things at once, and each part is suboptimal/incomplete.
| 
| This needs several patches. Not only because this is easier to review,
| but also because each part needs the good changelog.

I agree I sent this as an RFC to show the overall changes.
I do plan to include the following two patches, which should address
the issue of ->nsproxy being NULL.
	https://lists.linux-foundation.org/pipermail/containers/2008-November/014187.html
	https://lists.linux-foundation.org/pipermail/containers/2008-November/014188.html

| 
| Also. I don't think we should try do solve the "whole" problem right
| now. For example, if we add/use siginfo_from_ancestor_ns(), we should
| also change sys_sigaction(SIG_IGN). As I said, imho we should start
| with:
| 
| 	- cinit can't be killed from its namespace
| 
| 	- the parent ns can always SIGKILL cinit
| 
| This solves most of problems, and this is very simple.

Yes, I agree and am trying to solve only those two :-) I moved out
changes to __do_notify() and others to separate patches, but maybe
we can simplify this patch further.

| 
| As for .si_pid mangling, this again needs a separate patch.

I thought we were going to use SIG_FROM_USER to decide if the siginfo
does in fact have a ->si_pid (so we don't need the switch statement
we had in an earlier patch).

| 
| Sukadev, I don't have a time today, I'll return tomorrow with more
| comments on this...

No problem. Thanks for the comments so far.

| 
| > +static int sig_ignored(struct task_struct *t, int sig, int same_ns)
| >  {
| >  	void __user *handler;
| >
| > @@ -68,6 +68,14 @@ static int sig_ignored(struct task_struct *t, int sig)
| >  	handler = sig_handler(t, sig);
| >  	if (!sig_handler_ignored(handler, sig))
| >  		return 0;
| > +	/*
| > +	 * ignores SIGSTOP/SIGKILL signals to init from same namespace.
| > +	 *
| > +	 * TODO: Ignore unblocked SIG_DFL signals also here or drop them
| > +	 * 	 in get_signal_to_deliver() ?
| > +	 */
| > +	if (is_container_init(t) && same_ns && sig_kernel_only(sig))
| > +		return 1;
| 
| No, no. is_container_init() is slow and unneeded, same_ns is bogus,
| the usage of sig_kernel_only() is suboptimal. The comment is not
| right too...

Maybe in a separate patch, but same_ns is needed to ensure container-init
does not ignore signals from ancestor namespace - no ? 

I was undecided between the above sig_kernel_only() check and 
'handler == SIG_DFL' (hence the TODO).

| 
| As I already said, this problem is not namespace-specific, we need
| some changes for the global init too.

Right I used is_container_init() since it includes global init().
Again, maybe it could have been separate patches for just global_init
first.

But I see from your patch that we could use SIGNAL_UNKILLABLE instead
of is_container_init(). That is more efficient.

| 
| Actually, I already did the patch, I'll send it soon.

Ok. I will review that.

| 
| >  static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
| >  			int group)
| >  {
| >  	struct sigpending *pending;
| >  	struct sigqueue *q;
| > +	int from_ancestor_ns;
| > +
| > +	from_ancestor_ns = 0;
| > +	if (siginfo_from_user(info)) {
| > +		/* if t can't see us we are from parent ns */
| > +		if (task_pid_nr_ns(current, task_active_pid_ns(t)) == 0)
|                                             ^^^^^^^^^^^^^^^^^^
| 
| ->nsproxy may be NULL, but we can use task_pid(t)->numbers[-1].ns

Eric's patch of generalizing task_active_pid_ns() should fix this. It
was reviewed several times, so I did not send it, but yes, I should
have mentioned it.

| 
| > @@ -864,6 +902,9 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
| >  		 * and sent by user using something other than kill().
| >  		 */
| >  			return -EAGAIN;
| > +
| > +		if (from_ancestor_ns)
| > +			return -ENOMEM;
| 
| This change alone needs a fat comment in changelog. But I don't think
| we need it now. Until we change the dequeue path to check "from_ancestor_ns".

Ok.

| 
| > +static inline int siginfo_from_ancestor_ns(siginfo_t *info)
| > +{
| > +	return SI_FROMUSER(info) && (info->si_pid == 0);
| > +}
| 
| Yes, this is problem... I doubt we can rely on !si_pid here.
| More on this later.
| 
| > @@ -2296,10 +2347,25 @@ sys_rt_sigqueueinfo(pid_t pid, int sig, siginfo_t __user *uinfo)
| >  	   Nor can they impersonate a kill(), which adds source info.  */
| >  	if (info.si_code >= 0)
| >  		return -EPERM;
| > -	info.si_signo = sig;
| > +	info.si_signo = sig | SIG_FROM_USER;
| >
| >  	/* POSIX.1b doesn't mention process groups.  */
| > -	return kill_proc_info(sig, &info, pid);
| > +	rcu_read_lock();
| > +	spid = find_vpid(pid);
| > +	/* 
| > +	 * A container-init (cinit) ignores/drops fatal signals unless sender
| > +	 * is in an ancestor namespace.  Cinit uses 'si_pid == 0' to check if
| > +	 * sender is an ancestor. See siginfo_from_ancestor_ns().
| > +	 *
| > +	 * If signalling a descendant cinit, set si_pid to 0 so it does not
| > +	 * get ignored/dropped.
| > +	 */
| > +	if (!pid_nr_ns(spid, task_active_pid_ns(current)))
| > +		info.si_pid = 0;
| > +	error = kill_pid_info(sig, &info, spid);
| 
| Can't understand. We set SIG_FROM_USER, If signalling a descendant task
| (not only cinit), send_signal() will clear .si_pid anyway?

Good point. We had gone back and forth on this and I thought one of the
emails mentioned this check. Maybe I misread that.

But yes, its not needed since send_signal() does it.
