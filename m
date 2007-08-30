From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [RFC][PATCH 2/3] Signal semantics for /sbin/init
Date: Thu, 30 Aug 2007 11:00:32 +0400
Message-ID: <20070830070032.GA189@tv-sign.ru>
References: <20070830062029.GB29340@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070830062029.GB29340-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 08/29, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> 
> --- 2.6.23-rc3-mm1.orig/kernel/signal.c	2007-08-29 22:53:20.000000000 -0700
> +++ 2.6.23-rc3-mm1/kernel/signal.c	2007-08-29 23:10:16.000000000 -0700
> @@ -26,6 +26,7 @@
>  #include <linux/freezer.h>
>  #include <linux/pid_namespace.h>
>  #include <linux/nsproxy.h>
> +#include <linux/hardirq.h>
>  
>  #include <asm/param.h>
>  #include <asm/uaccess.h>
> @@ -39,11 +40,42 @@
>  
>  static struct kmem_cache *sigqueue_cachep;
>  
> +static int sig_init_ignore(struct task_struct *tsk)
> +{
>  
> -static int sig_ignored(struct task_struct *t, int sig)
> +	// Currently this check is a bit racy with exec(),
> +	// we can _simplify_ de_thread and close the race.
> +	if (likely(!is_container_init(tsk->group_leader)))
> +		return 0;
> +
> +	/*
> +	 * If signal is from an ancestor pid namespace, do not
> +	 * ignore the signal.
> +	 */
> +	if (task_ancestor_pid_ns(current, tsk))
> +		return 0;
> +

This patch was intended as a fix for the current behaviour, and a preparation
for the pid_ns requirements. If possible, it should go ahead of all other
pid_ns changes, imho.

In any case, we shouldn't mix all this in one patch.

If there are no objections to this approach, I'll re-send the patch on weekend.

> @@ -2320,6 +2346,13 @@ int do_sigaction(int sig, struct k_sigac
>  	k = &current->sighand->action[sig-1];
>  
>  	spin_lock_irq(&current->sighand->siglock);
> +
> +	if (current->signal->flags & SIGNAL_GROUP_EXIT) {
> +		spin_unlock_irq(&current->sighand->siglock);
> +		/* The return value doesn't matter, SIGKILL is pending */
> +		return -EINTR;
> +	}

This is not needed. Please look at

	http://marc.info/?l=linux-kernel&m=118763989718143

I specially removed this chunk in a separate patch, no need to re-introduce.

Oleg.
