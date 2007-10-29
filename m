From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 1/2] Container-init must be immune to unwanted signals
Date: Mon, 29 Oct 2007 14:17:51 -0600
Message-ID: <m1bqahoets.fsf@ebiederm.dsl.xmission.com>
References: <20071027190729.GC10397@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071027190729.GC10397-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org's message
	of "Sat, 27 Oct 2007 12:07:29 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org writes:

> Note: this patch applies on top of Eric's patch:
>
> 	http://lkml.org/lkml/2007/10/26/440
>
> ---
>
> From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Subject: [PATCH 1/2] Container-init must be immune to unwanted signals
>
> Container-init process must appear like a normal process to its sibling
> in the parent namespace and should be killable (or not) in the usual way.
>
> But it must be immune to any unwanted signals from within its own namespace.
>
> At the time of sending the signal, check if receiver is container-init
> and if signal is an unwanted one. If its unwanted signal, ignore the
> signal right away.
>
> Note: 
> 	A limitation with this patch is that if the signal is blocked by the
> 	container-init at the time of the check, we cannot ignore the signal
> 	because the container-init may install a handler for the signal before
> 	unblocking it.
>
> 	But if the container-init unblocks the signal without installing the
> 	handler, the unwanted signal will still be delivered to the container-
> 	init. If the unwanted signal is fatal (i.e default action is to
> 	terminate), we end up terminating the container-init and hence the
> 	container.
>
> 	We have not been able to find a clean-way to address this blocked
> 	signal issue in the kernel. It appears easier to let the container-
> 	init decide what it wants to do with signals i.e have it _explicitly_
> 	ignore or handle all fatal signals.
>
> 	The next patch in this set prints a warning the first time a
> 	container-init process fork()s without ignoring or handling a fatal
> 	signal.
>
> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/pid_namespace.h |    6 +++++-
>  kernel/pid.c                  |    9 ++++++++-
>  kernel/signal.c               |    5 ++++-
>  3 files changed, 17 insertions(+), 3 deletions(-)
>
> Index: 2.6.23-mm1/kernel/signal.c
> ===================================================================
> --- 2.6.23-mm1.orig/kernel/signal.c	2007-10-27 10:08:36.000000000 -0700
> +++ 2.6.23-mm1/kernel/signal.c	2007-10-27 10:08:36.000000000 -0700
> @@ -45,7 +45,10 @@ static int sig_init_ignore(struct task_s
>  
>  	// Currently this check is a bit racy with exec(),
>  	// we can _simplify_ de_thread and close the race.
> -	if (likely(!is_global_init(tsk->group_leader)))
> +	if (likely(!is_container_init(tsk->group_leader)))
> +		return 0;
> +
> +	if (task_in_descendant_pid_ns(tsk) && !in_interrupt())
>  		return 0;
>  
>  	return 1;

Ok.  This is where we are handling the pid namespace case.
This begins to feel correct.

What is the in_interrupt() check for?  That looks bogus on
the face of it.

I would suggest setting the signal handlers in flush_signal_handlers
to SIG_IGN but that looks like the children of /sbin/init would
the a different set of signals by default.

Eric
