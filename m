From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/4] c/r: [signal] pending signals (private, shared)
Date: Mon, 17 Aug 2009 09:47:32 -0700
Message-ID: <87vdkm5qvv.fsf@caffeine.danplanet.com>
References: <1250287636-16463-1-git-send-email-orenl@librato.com>
	<1250287636-16463-4-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1250287636-16463-4-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org> (Oren
	Laadan's message of "Fri\, 14 Aug 2009 18\:07\:15 -0400")
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
Cc: Luis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

OL> +static int load_siginfo(siginfo_t *info, struct ckpt_hdr_siginfo *si)
OL> +{
OL> +	if (!valid_signal(si->signo))
OL> +		return -EINVAL;
OL> +
OL> +	info->si_signo = si->signo;
OL> +	info->si_errno = si->_errno;
OL> +	info->si_code = si->code;
OL> +
OL> +	/* TODO: validate remaining signal fields */
OL> +
OL> +	switch(info->si_code & __SI_MASK) {
OL> +	case __SI_TIMER:
OL> +		info->si_tid = si->pid;
OL> +		info->si_overrun = si->uid;
OL> +		info->si_int = si->sigval_int;
OL> +		info->si_sys_private = si->utime;
OL> +		break;
OL> +	case __SI_POLL:
OL> +		info->si_band = si->pid;
OL> +		info->si_fd = si->sigval_int;
OL> +		break;
OL> +	case __SI_FAULT:
OL> +		info->si_addr = (void __user *) (unsigned long) si->sigval_ptr;
OL> +#ifdef __ARCH_SI_TRAPNO
OL> +		info->si_trapno = si->sigval_int;
OL> +#endif
OL> +		break;
OL> +	case __SI_CHLD:
OL> +		info->si_pid = si->pid;
OL> +		info->si_uid = si->uid;
OL> +		info->si_status = si->sigval_int;
OL> +		info->si_stime = si->stime;
OL> +		info->si_utime = si->utime;
OL> +		break;
OL> +	case __SI_KILL:
OL> +	case __SI_RT:
OL> +	case __SI_MESGQ:
OL> +		info->si_pid = si->pid;
OL> +		info->si_uid = si->uid;
OL> +		info->si_ptr = (void __user *) (unsigned long) si->sigval_ptr;
OL> +		break;
OL> +	default:
OL> +		return -EINVAL;
OL> +	}
OL> +
OL> +	return 0;
OL> +}
OL> +

This seems like a perfect place to use the CKPT_COPY() macros, if
we're going to have them.  This and the save equivalent could be
almost identical.

OL> +static int restore_sigpending(struct ckpt_ctx *ctx, struct sigpending *pending)
OL> +{
OL> +	struct ckpt_hdr_sigpending *h;
OL> +	struct ckpt_hdr_siginfo *si;
OL> +	struct sigqueue *q;
OL> +	int ret = 0;
OL> +
OL> +	h = ckpt_read_buf_type(ctx, 0, CKPT_HDR_SIGPENDING);
OL> +	if (IS_ERR(h))
OL> +		return PTR_ERR(h);
OL> +
OL> +	INIT_LIST_HEAD(&pending->list);
OL> +	load_sigset(&pending->signal, &h->signal);
OL> +
OL> +	si = h->siginfo;
OL> +	while (h->nr_pending--) {
OL> +		q = sigqueue_alloc();
OL> +		if (!q) {
OL> +			ret = -ENOMEM;
OL> +			break;
OL> +		}
OL> +
OL> +		ret = load_siginfo(&q->info, si++);

I think there should be a sanity check here, no?  The checkpoint
stream claims h->nr_pending structures in h->siginfo, but we can't
trust that we're not going to march through memory to a segv unless we
check that the header length matches your calculation in
checkpoint_sigpending().

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
