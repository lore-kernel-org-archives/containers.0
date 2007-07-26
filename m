From: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 8/15] Helpers to find the task by its numerical ids
Date: Thu, 26 Jul 2007 12:05:41 -0700
Message-ID: <1185476741.18414.118.camel@localhost>
References: <46A8B37B.6050108@openvz.org>  <46A8B502.8070606@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46A8B502.8070606-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2007-07-26 at 18:51 +0400, Pavel Emelyanov wrote:
> +extern struct task_struct *find_task_by_pid_type_ns(int type, int pid,
> +		struct pid_namespace *ns);
> +
> +#define find_task_by_pid_ns(nr, ns)	\
> +		find_task_by_pid_type_ns(PIDTYPE_PID, nr, ns)
> +#define find_task_by_pid_type(type, nr)	\
> +		find_task_by_pid_type_ns(type, nr, &init_pid_ns)
> +#define find_task_by_pid(nr)		\
> +		find_task_by_pid_type(PIDTYPE_PID, nr)
> +
>  extern void __set_special_pids(pid_t session, pid_t pgrp);

Do these _have_ to be macros?

>  /* per-UID process charging. */
> diff -upr linux-2.6.23-rc1-mm1.orig/kernel/pid.c linux-2.6.23-rc1-mm1-7/kernel/pid.c
> --- linux-2.6.23-rc1-mm1.orig/kernel/pid.c	2007-07-26 16:34:45.000000000 +0400
> +++ linux-2.6.23-rc1-mm1-7/kernel/pid.c	2007-07-26 16:36:37.000000000 +0400
> @@ -204,19 +221,20 @@ static void delayed_put_pid(struct rcu_h
>  	goto out;
>  }
> 
> -struct pid * fastcall find_pid(int nr)
> +struct pid * fastcall find_pid_ns(int nr, struct pid_namespace *ns)
>  {
>  	struct hlist_node *elem;
> -	struct pid *pid;
> +	struct upid *pnr;
> +
> +	hlist_for_each_entry_rcu(pnr, elem,
> +			&pid_hash[pid_hashfn(nr, ns)], pid_chain)
> +		if (pnr->nr == nr && pnr->ns == ns)
> +			return container_of(pnr, struct pid,
> +					numbers[ns->level]);

Do we do this loop anywhere else?  Should we have a for_each_pid() that
makes this a little less messy?

> -	hlist_for_each_entry_rcu(pid, elem,
> -			&pid_hash[pid_hashfn(nr)], pid_chain) {
> -		if (pid->nr == nr)
> -			return pid;
> -	}
>  	return NULL;
>  }
> -EXPORT_SYMBOL_GPL(find_pid);
> +EXPORT_SYMBOL_GPL(find_pid_ns);
> 
>  /*
>   * attach_pid() must be called with the tasklist_lock write-held.
> @@ -318,12 +355,13 @@ struct task_struct * fastcall pid_task(s
>  /*
>   * Must be called under rcu_read_lock() or with tasklist_lock read-held.
>   */
> -struct task_struct *find_task_by_pid_type(int type, int nr)
> +struct task_struct *find_task_by_pid_type_ns(int type, int nr,
> +		struct pid_namespace *ns)
>  {
> -	return pid_task(find_pid(nr), type);
> +	return pid_task(find_pid_ns(nr, ns), type);
>  }
> 
> -EXPORT_SYMBOL(find_task_by_pid_type);
> +EXPORT_SYMBOL(find_task_by_pid_type_ns);
> 
>  struct pid *get_task_pid(struct task_struct *task, enum pid_type type)
>  {
> @@ -342,7 +426,7 @@ struct pid *find_get_pid(pid_t nr)
>  	struct pid *pid;
> 
>  	rcu_read_lock();
> -	pid = get_pid(find_pid(nr));
> +	pid = get_pid(find_vpid(nr));
>  	rcu_read_unlock();

OK, I think this is really confusing.  If find_get_pid() finds vpids,
should we not call it find_get_vpid()?

-- Dave
