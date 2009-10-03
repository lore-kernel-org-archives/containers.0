From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: pidns : PR_SET_PDEATHSIG + SIGKILL regression
Date: Sat, 3 Oct 2009 04:52:30 +0200
Message-ID: <20091003025200.GA18478@redhat.com>
References: <4AC608BE.9020805@fr.ibm.com> <20091002154702.GB26864@us.ibm.com>
	<20091003003929.GA20034@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091003003929.GA20034-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/02, Sukadev Bhattiprolu wrote:
>
> --- linux-2.6.orig/kernel/exit.c	2009-10-02 16:36:47.000000000 -0700
> +++ linux-2.6/kernel/exit.c	2009-10-02 17:19:06.000000000 -0700
> @@ -738,8 +738,19 @@ static struct task_struct *find_new_reap
>  static void reparent_thread(struct task_struct *father, struct task_struct *p,
>  				struct list_head *dead)
>  {
> -	if (p->pdeath_signal)
> -		group_send_sig_info(p->pdeath_signal, SEND_SIG_NOINFO, p);
> +	struct siginfo info;
> +
> +	if (p->pdeath_signal) {
> +		info.si_signo = p->pdeath_signal;
> +		info.si_errno = 0;
> +
> +		rcu_read_lock();
> +		info.si_pid = task_pid_nr_ns(father, task_active_pid_ns(p));
> +		info.si_uid = __task_cred(father)->uid;
> +		rcu_read_unlock();
> +
> +		group_send_sig_info(p->pdeath_signal, &info, p);
> +	}

This patch forgets to set "info.si_code = SI_USER", this means SI_FROMXXX()
will return the random value.

Imho it would be more clean to move the declaration of "info" under
"if (pdeath_signal)".

Actually, perhaps we should consider SEND_SIG_NOINFO as SI_FROMUSER().
I'll try to check tomorrow.

Oleg.
