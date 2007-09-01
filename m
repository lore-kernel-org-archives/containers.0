From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 2/3] Pid ns helpers for signals
Date: Sat, 1 Sep 2007 15:29:03 +0400
Message-ID: <20070901112903.GD191@tv-sign.ru>
References: <20070831203634.GB3268@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070831203634.GB3268-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On 08/31, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
>
> Define some helper functions that will be used to implement signal semantics
> with multiple pid namespaces. 
> 
> 	is_current_in_ancestor_pid_ns(task)
> 
> 		TRUE iff active pid namespace of 'current' is an ancestor of
> 		active pid namespace of @task.
> 
> 	is_current_in_same_or_ancestor_pid_ns(task)
> 
> 		TRUE iff active pid namespace of 'current' is either same as 
> 		or an ancestor of active pid namespace of @task.

These names are awfull :) Yes, yes, it was me who suggested them... No, I can't
suggest something better.

> + * Caller must hold a reference to @pid.
> + */
> +static inline struct pid_namespace *pid_active_ns(struct pid *pid)
> +{
> +	if (!pid)
> +		return NULL;
> +
> +	return pid->numbers[pid->level].ns;
> +}

Well, the comment is a bit misleading. Yes, my previous comment was not very
clear. Yes, the function itself is not safe unless you know what are you doing,
like, for example, get_pid(). I think it is better to just kill the comment.
Please see below.

> +static struct pid_namespace *get_task_pid_ns(struct task_struct *tsk)
> +{
> +	struct pid *pid;
> +	struct pid_namespace *ns;
> +
> +	pid = get_task_pid(tsk, PIDTYPE_PID);
> +	ns = get_pid_ns(pid_active_ns(pid));
> +	put_pid(pid);
> +
> +	return ns;
> +}

Hmm. Firstly, we don't need this for the "current", but all users of this func
also do get_task_pid_ns(current).

Also, we don't need get/put_pid. rcu locks are enough,

	rcu_read_lock();
	ns = get_pid_ns(pid_active_ns(task_pid(tks)));
	rcu_read_unlock();

However, do we really need this complications right now? Currently, we use
this "compare namespaces" helpers only when we know that "struct pid" is
stable. We are sending the signal to that task, it must be pid_alive(), and
we either locked the task itself, or we hold tasklist.

Oleg.
