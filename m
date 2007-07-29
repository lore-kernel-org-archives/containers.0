From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 5/15] Introduce struct upid
Date: Sun, 29 Jul 2007 13:52:10 +0400
Message-ID: <20070729095210.GA120@tv-sign.ru>
References: <46A8B37B.6050108@openvz.org> <46A8B486.3030006@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46A8B486.3030006-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/26, Pavel Emelyanov wrote:
>
> --- linux-2.6.23-rc1-mm1.orig/include/linux/pid.h	2007-07-26 16:34:45.000000000 +0400
> +++ linux-2.6.23-rc1-mm1-7/include/linux/pid.h	2007-07-26 16:36:37.000000000 +0400
> @@ -40,15 +40,21 @@ enum pid_type
>   * processes.
>   */
>  
> -struct pid
> -{
> -	atomic_t count;
> +struct upid {
>  	/* Try to keep pid_chain in the same cacheline as nr for find_pid */
>  	int nr;
> +	struct pid_namespace *ns;
>  	struct hlist_node pid_chain;
> +};
> +
> +struct pid
> +{
> +	atomic_t count;
>  	/* lists of tasks that use this pid */
>  	struct hlist_head tasks[PIDTYPE_MAX];
>  	struct rcu_head rcu;
> +	int level;
> +	struct upid numbers[1];
>  };

Well. Definitely, the kernel can't be compiled with this patch applied,
this seems to be against the rules...

So. The task has a single (PIDTYPE_MAX) pid no matter how many namespaces
can see it, and "struct pid" has an array of numbers for each namespace.

Still I can't understand why do we need upid->ns, can't we kill it?
Suppose we add "struct pid_namespace *parent_ns" to "struct pid_namespace",
init_pid_ns.parent_ns == NULL.

Now,

	struct upid {
		int nr;
		struct hlist_node pid_chain;
	};

	struct pid
	{
		atomic_t count;
		struct hlist_head tasks[PIDTYPE_MAX];
		struct rcu_head rcu;
		struct pid_namespace *active_ns;
		struct upid numbers[0];
	};

We populate pid->numbers in "reverse" order, so that pid->numbers[0] lives
in pid->active_ns.

Now, for example,

	void free_pid(struct pid *pid)
	{
		struct pid_namespace *ns;
		unsigned long flags;
		int i;

		spin_lock_irqsave(&pidmap_lock, flags);
		for (i = 0, ns = pid->active_ns; ns; i++, ns = ns->parent_ns)
			hlist_del_rcu(&pid->numbers[i].pid_chain);
		spin_unlock_irqrestore(&pidmap_lock, flags);

		for (i = 0, ns = pid->active_ns; ns; i++, ns = ns->parent_ns)
			free_pidmap(ns, pid->numbers[i].nr);

		call_rcu(&pid->rcu, delayed_put_pid);
	}

Possible?

Oleg.
