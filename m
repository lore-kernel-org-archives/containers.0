From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH pm-freezer 2/4] freezer: set PF_NOFREEZE on a dying
	task right before TASK_DEAD
Date: Mon, 29 Aug 2011 20:02:48 +0200
Message-ID: <20110829180248.GA13346__3051.25617092035$1314641232$gmane$org@redhat.com>
References: <20110829140418.GB18871@mtj.dyndns.org>
	<20110829140509.GC18871@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110829140509.GC18871-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/29, Tejun Heo wrote:
>
> There's no try_to_freeze() call in the exit path and the only
> necessary guarantee is that freezer doesn't hang waiting for zombies.
> Set PF_NOFREEZE right before setting tsk->state to TASK_DEAD instead.

Agreed.

But I'd like to repeat, this looks "asymmetrical". do_each_thread()
can't see the (auto)reaped tasks after they do exit_notify(). So we
can only see this PF_NOFREEZE if the thread becomes a zombie.

> @@ -1044,6 +1038,10 @@ NORET_TYPE void do_exit(long code)
>
>  	preempt_disable();
>  	exit_rcu();
> +
> +	/* this task is now dead and freezer should ignore it */
> +	current->flags |= PF_NOFREEZE;
> +
>  	/* causes final put_task_struct in finish_task_switch(). */
>  	tsk->state = TASK_DEAD;

May be freezing_slow_path() can check TASK_DEAD along with PF_NOFREEZE
instead? (or tsk->exit_state != 0 to avoid the asymmetry above). Just
to keep this logic in the freezer code. I dunno.

But this all is up to you and Rafael, I am not arguing. Just random
thoughts.

Oleg.
