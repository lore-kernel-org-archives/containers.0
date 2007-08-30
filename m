From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [RFC][PATCH 1/3] Pid ns helpers for signals
Date: Thu, 30 Aug 2007 12:21:48 +0400
Message-ID: <20070830082148.GA243@tv-sign.ru>
References: <20070830061910.GA29340@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070830061910.GA29340-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> +static int ancestor_pid_ns(struct pid_namespace *ns1, struct pid_namespace *ns2)
> +{
> +	int i;
> +	struct pid_namespace *tmp;
> +
> +	if (ns1 == NULL || ns2 == NULL)
> +		return 0;
> +
> +	if (ns1->level >= ns2->level)
> +		return 0;

Looks like this check is not needed, because

> +	tmp = ns2->parent;
> +	for (i = tmp->level; i >= ns1->level; i--) {
> +		if (tmp == ns1)
> +			return 1;
> +		tmp = tmp->parent;
> +	}
> +
> +	return 0;
> +}

"for ()" does the necessary comparison. The same for descendant_pid_ns().

But do we really need two different functions with 2 arguments? Afaics, we
only need is_current_ancestor_pid_ns(tsk).

kill_something_info() needs is_current_ancestor_or_the_same_pid_ns(tsk) which
could be trivially implemented using the previous one.

> --- 2.6.23-rc3-mm1.orig/include/linux/sched.h	2007-08-27 20:04:23.000000000 -0700
> +++ 2.6.23-rc3-mm1/include/linux/sched.h	2007-08-28 23:12:54.000000000 -0700
> @@ -1290,6 +1290,23 @@ static inline pid_t task_ppid_nr_ns(stru
>  	return pid_nr_ns(task_pid(rcu_dereference(tsk->real_parent)), ns);
>  }
>  
> +static inline struct pid_namespace *pid_active_ns(struct pid *pid)
> +{
> +       if (pid == NULL)
> +               return NULL;
> +
> +       return pid->numbers[pid->level].ns;
> +}

The function itself is racy, this pid can be already freed. Perhaps not
a problem currently, afaics it is only used on signal sending path, the
receiver is locked (or the task was found under tasklist), and another
task is current.

>  static inline struct pid_namespace *task_active_pid_ns(struct task_struct *tsk)
>  {
> -	return tsk->nsproxy->pid_ns;
> +	/*
> +	 * If task still has its namespaces (i.e it is not exiting)
> +	 * get the pid ns from nsproxy.
> +	 */
> +	if (tsk->nsproxy)
> +		return tsk->nsproxy->pid_ns;

Racy. Needs task_lock() or rcu_lock(). Please see below,

> +	/*
> +	 * If it is exiting but has not been reaped, get pid ns from
> +	 * pid->numbers[]. Otherwise return NULL.
> +	 */
> +	return pid_active_ns(task_pid(tsk));

Why can't we just use this chunk and avoid using ->nsproxy?

Oleg.
