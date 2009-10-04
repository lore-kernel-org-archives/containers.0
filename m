From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/4] Was: pidns : PR_SET_PDEATHSIG + SIGKILL regression
Date: Sun, 4 Oct 2009 04:18:44 +0200
Message-ID: <20091004021844.GA21006@redhat.com>
References: <4AC608BE.9020805@fr.ibm.com> <20091003171029.GA30442@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091003171029.GA30442-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/03, Sukadev Bhattiprolu wrote:
>
>  static void reparent_thread(struct task_struct *father, struct task_struct *p,
>  				struct list_head *dead)
>  {
> -	if (p->pdeath_signal)
> -		group_send_sig_info(p->pdeath_signal, SEND_SIG_NOINFO, p);
> +	if (p->pdeath_signal) {
> +		struct siginfo info;
> +
> +		info.si_code = SI_USER;
> +		info.si_signo = p->pdeath_signal;
> +		info.si_errno = 0;
> +
> +		rcu_read_lock();
> +		info.si_pid = task_tgid_nr_ns(father, task_active_pid_ns(p));
> +		info.si_uid = __task_cred(father)->uid;
> +		rcu_read_unlock();
> +
> +		group_send_sig_info(p->pdeath_signal, &info, p);
> +	}

I think the patch is correct.

But afaics we should clarify the "from user" semantics and fix
send_signal() instead.

What do you think about this simple series? (the last 2 patches
are pure cosmetic and off-topic).

Oleg.
