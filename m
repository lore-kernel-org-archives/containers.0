From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] c/r: support for controlling terminal and job control
Date: Mon, 7 Sep 2009 22:21:48 -0500
Message-ID: <20090908032147.GC16460@us.ibm.com>
References: <1252074054-22241-1-git-send-email-orenl@librato.com>
	<1252074054-22241-7-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1252074054-22241-7-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> Add checkpoint/restart of controlling terminal: current->signal->tty.
> This is only done for session leaders.
> 
> If the session leader belongs to the ancestor pid-ns, then checkpoint
> skips this tty; On restart, it will not be restored, and whatever tty
> is in place from parent pid-ns (at restart) will be inherited.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Not exactly my area, but looks good

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  checkpoint/signal.c            |   78 ++++++++++++++++++++++++++++++++++++++-
>  drivers/char/tty_io.c          |   33 +++++++++++++----
>  include/linux/checkpoint.h     |    1 +
>  include/linux/checkpoint_hdr.h |    6 +++
>  include/linux/tty.h            |    5 +++
>  5 files changed, 114 insertions(+), 9 deletions(-)
> 
> diff --git a/checkpoint/signal.c b/checkpoint/signal.c
> index ad06783..178a97c 100644
> --- a/checkpoint/signal.c
> +++ b/checkpoint/signal.c
> @@ -315,11 +315,12 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
>  	struct ckpt_hdr_signal *h;
>  	struct signal_struct *signal;
>  	struct sigpending shared_pending;
> +	struct tty_struct *tty = NULL;
>  	struct rlimit *rlim;
>  	struct timeval tval;
>  	cputime_t cputime;
>  	unsigned long flags;
> -	int i, ret;
> +	int i, ret = 0;
> 
>  	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
>  	if (!h)
> @@ -398,9 +399,34 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
>  	cputime_to_timeval(signal->it_prof_incr, &tval);
>  	h->it_prof_incr = timeval_to_ns(&tval);
> 
> +	/* tty */
> +	if (signal->leader) {
> +		h->tty_old_pgrp = ckpt_pid_nr(ctx, signal->tty_old_pgrp);
> +		tty = tty_kref_get(signal->tty);
> +		if (tty) {
> +			/* irq is already disabled */
> +			spin_lock(&tty->ctrl_lock);
> +			h->tty_pgrp = ckpt_pid_nr(ctx, tty->pgrp);
> +			spin_unlock(&tty->ctrl_lock);
> +			tty_kref_put(tty);
> +		}
> +	}
> +
>  	unlock_task_sighand(t, &flags);
> 
> -	ret = ckpt_write_obj(ctx, &h->h);
> +	/*
> +	 * If the session is in an ancestor namespace, skip this tty
> +	 * and set tty_objref = 0. It will not be explicitly restored,
> +	 * but rather inherited from parent pid-ns at restart time.
> +	 */
> +	if (tty && ckpt_pid_nr(ctx, tty->session) > 0) {
> +		h->tty_objref = checkpoint_obj(ctx, tty, CKPT_OBJ_TTY);
> +		if (h->tty_objref < 0)
> +			ret = h->tty_objref;
> +	}
> +
> +	if (!ret)
> +		ret = ckpt_write_obj(ctx, &h->h);
>  	if (!ret)
>  		ret = checkpoint_sigpending(ctx, &shared_pending);
> 
> @@ -471,8 +497,10 @@ static int restore_signal(struct ckpt_ctx *ctx)
>  	struct ckpt_hdr_signal *h;
>  	struct sigpending new_pending;
>  	struct sigpending *pending;
> +	struct tty_struct *tty = NULL;
>  	struct itimerval itimer;
>  	struct rlimit rlim;
> +	struct pid *pgrp;
>  	int i, ret;
> 
>  	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
> @@ -492,6 +520,36 @@ static int restore_signal(struct ckpt_ctx *ctx)
>  	if (ret < 0)
>  		goto out;
> 
> +	/* tty - session */
> +	if (h->tty_objref) {
> +		tty = ckpt_obj_fetch(ctx, h->tty_objref, CKPT_OBJ_TTY);
> +		if (IS_ERR(tty)) {
> +			ret = PTR_ERR(tty);
> +			goto out;
> +		}
> +		/* this will fail unless we're the session leader */
> +		ret = tiocsctty(tty, 0);
> +		if (ret < 0)
> +			goto out;
> +		/* now restore the foreground group (job control) */
> +		if (h->tty_pgrp) {
> +			ret = do_tiocspgrp(tty, tty_pair_get_tty(tty),
> +					   h->tty_pgrp);
> +			if (ret < 0)
> +				goto out;
> +		}
> +	} else {
> +		/*
> +		 * If tty_objref isn't set, we _keep_ whatever tty we
> +		 * already have as a ctty. Why does this make sense ?
> +		 * - If our session is "within" the restart context,
> +		 * then that session has no controlling terminal.
> +		 * - If out session is "outside" the restart context,
> +                 * then we're like to keep whatever we inherit from
> +                 * the parent pid-ns.
> +		 */
> +	}
> +
>  	/*
>  	 * Reset real/virt/prof itimer (in case they were set), to
>  	 * prevent unwanted signals after flushing current signals
> @@ -503,7 +561,23 @@ static int restore_signal(struct ckpt_ctx *ctx)
>  	do_setitimer(ITIMER_VIRTUAL, &itimer, NULL);
>  	do_setitimer(ITIMER_PROF, &itimer, NULL);
> 
> +	/* tty - tty_old_pgrp */
> +	if (h->tty_old_pgrp) {
> +		ret = -EINVAL;
> +		if (!current->signal->leader)
> +			goto out;
> +		rcu_read_lock();
> +		pgrp = get_pid(_ckpt_find_pgrp(ctx, h->tty_old_pgrp));
> +		rcu_read_unlock();
> +		if (!pgrp)
> +			goto out;
> +	}
> +
>  	spin_lock_irq(&current->sighand->siglock);
> +	/* tty - tty_old_pgrp */
> +	put_pid(current->signal->tty_old_pgrp);
> +	current->signal->tty_old_pgrp = pgrp;
> +	/* pending signals */
>  	pending = &current->signal->shared_pending;
>  	flush_sigqueue(pending);
>  	pending->signal = new_pending.signal;
> diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
> index b8f8d79..0206300 100644
> --- a/drivers/char/tty_io.c
> +++ b/drivers/char/tty_io.c
> @@ -2132,7 +2132,7 @@ static int fionbio(struct file *file, int __user *p)
>   *		Takes ->siglock() when updating signal->tty
>   */
> 
> -static int tiocsctty(struct tty_struct *tty, int arg)
> +int tiocsctty(struct tty_struct *tty, int arg)
>  {
>  	int ret = 0;
>  	if (current->signal->leader && (task_session(current) == tty->session))
> @@ -2221,10 +2221,10 @@ static int tiocgpgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t
>  }
> 
>  /**
> - *	tiocspgrp		-	attempt to set process group
> + *	do_tiocspgrp		-	attempt to set process group
>   *	@tty: tty passed by user
>   *	@real_tty: tty side device matching tty passed by user
> - *	@p: pid pointer
> + *	@pid: pgrp_nr
>   *
>   *	Set the process group of the tty to the session passed. Only
>   *	permitted where the tty session is our session.
> @@ -2232,10 +2232,10 @@ static int tiocgpgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t
>   *	Locking: RCU, ctrl lock
>   */
> 
> -static int tiocspgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t __user *p)
> +int do_tiocspgrp(struct tty_struct *tty,
> +		 struct tty_struct *real_tty, pid_t pgrp_nr)
>  {
>  	struct pid *pgrp;
> -	pid_t pgrp_nr;
>  	int retval = tty_check_change(real_tty);
>  	unsigned long flags;
> 
> @@ -2247,8 +2247,6 @@ static int tiocspgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t
>  	    (current->signal->tty != real_tty) ||
>  	    (real_tty->session != task_session(current)))
>  		return -ENOTTY;
> -	if (get_user(pgrp_nr, p))
> -		return -EFAULT;
>  	if (pgrp_nr < 0)
>  		return -EINVAL;
>  	rcu_read_lock();
> @@ -2270,6 +2268,27 @@ out_unlock:
>  }
> 
>  /**
> + *	tiocspgrp		-	attempt to set process group
> + *	@tty: tty passed by user
> + *	@real_tty: tty side device matching tty passed by user
> + *	@p: pid pointer
> + *
> + *	Set the process group of the tty to the session passed. Only
> + *	permitted where the tty session is our session.
> + *
> + *	Locking: RCU, ctrl lock
> + */
> +
> +static int tiocspgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t __user *p)
> +{
> +	pid_t pgrp_nr;
> +
> +	if (get_user(pgrp_nr, p))
> +		return -EFAULT;
> +	return do_tiocspgrp(tty, real_tty, pgrp_nr);
> +}
> +
> +/**
>   *	tiocgsid		-	get session id
>   *	@tty: tty passed by user
>   *	@real_tty: tty side of the tty pased by the user if a pty else the tty
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 628d6f6..434c6b1 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -87,6 +87,7 @@ extern char *ckpt_fill_fname(struct path *path, struct path *root,
> 
>  /* pids */
>  extern pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid);
> +extern struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid);
> 
>  /* socket functions */
>  extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index c9ded68..398d5f7 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -555,13 +555,19 @@ struct ckpt_rlimit {
> 
>  struct ckpt_hdr_signal {
>  	struct ckpt_hdr h;
> +	/* rlimit */
>  	struct ckpt_rlimit rlim[CKPT_RLIM_NLIMITS];
> +	/* itimer */
>  	__u64 it_real_value;
>  	__u64 it_real_incr;
>  	__u64 it_virt_value;
>  	__u64 it_virt_incr;
>  	__u64 it_prof_value;
>  	__u64 it_prof_incr;
> +	/* tty */
> +	__s32 tty_objref;
> +	__s32 tty_pgrp;
> +	__s32 tty_old_pgrp;
>  } __attribute__((aligned(8)));
> 
>  struct ckpt_hdr_signal_task {
> diff --git a/include/linux/tty.h b/include/linux/tty.h
> index fd77894..ee49d97 100644
> --- a/include/linux/tty.h
> +++ b/include/linux/tty.h
> @@ -467,6 +467,11 @@ extern void tty_ldisc_begin(void);
>  /* This last one is just for the tty layer internals and shouldn't be used elsewhere */
>  extern void tty_ldisc_enable(struct tty_struct *tty);
> 
> +/* These are for checkpoint/restart */
> +extern int tiocsctty(struct tty_struct *tty, int arg);
> +extern int do_tiocspgrp(struct tty_struct *tty,
> +			struct tty_struct *real_tty, pid_t pgrp_nr);
> +
>  #ifdef CONFIG_CHECKPOINT
>  struct ckpt_ctx;
>  struct ckpt_hdr_file;
> -- 
> 1.6.0.4
