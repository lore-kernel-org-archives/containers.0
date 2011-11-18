From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: user namespace: make signal.c respect user namespaces (v5)
Date: Thu, 17 Nov 2011 19:24:34 -0800
Message-ID: <m1aa7u2jv1.fsf@fess.ebiederm.org>
References: <20111117045230.GA26345@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111117045230.GA26345-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Thu, 17 Nov 2011 04:52:30 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: richard-/L3Ra7n9ekc@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> ipc/mqueue.c: for __SI_MESQ, convert the uid being sent to recipient's
> user namespace. (new, thanks Oleg)
>
> __send_signal: convert current's uid to the recipient's user namespace
> for any siginfo which is not SI_FROMKERNEL (patch from Oleg, thanks
> again :)
>
> do_notify_parent and do_notify_parent_cldstop: map task's uid to parent's
> user namespace
>
> ptrace_signal maps parent's uid into current's user namespace before
> including in signal to current.  IIUC Oleg has argued that this shouldn't
> matter as the debugger will play with it, but it seems like not converting
> the value currently being set is misleading.
>
> Changelog:
> Sep 20: Inspired by Oleg's suggestion, define map_cred_ns() helper to
> 	simplify callers and help make clear what we are translating
>         (which uid into which namespace).  Passing the target task would
> 	make callers even easier to read, but we pass in user_ns because
> 	current_user_ns() != task_cred_xxx(current, user_ns).
> Sep 20: As recommended by Oleg, also put task_pid_vnr() under rcu_read_lock
> 	in ptrace_signal().
> Sep 23: In send_signal(), detect when (user) signal is coming from an
> 	ancestor or unrelated user namespace.  Pass that on to __send_signal,
> 	which sets si_uid to 0 or overflowuid if needed.
> Oct 12: Base on Oleg's fixup_uid() patch.  On top of that, handle all
> 	SI_FROMKERNEL cases at callers, because we can't assume sender is
> 	current in those cases.
> Nov 10: (mhelsley) rename fixup_uid to more meaningful usern_fixup_signal_uid
> Nov 10: (akpm) make the !CONFIG_USER_NS case clearer
>

> @@ -1088,6 +1117,9 @@ static int __send_signal(int sig, struct siginfo *info, struct task_struct *t,
>  				q->info.si_pid = 0;
>  			break;
>  		}
> +
> +		userns_fixup_signal_uid(info, t);

There is a small bug here.  You want to fixup q->info, not info.
Otherwise you might try dereferencing one of the special signals and get
a NULL pointer dereference.

Eric

> +
>  	} else if (!is_si_special(info)) {
>  		if (sig >= SIGRTMIN && info->si_code != SI_USER) {
>  			/*
