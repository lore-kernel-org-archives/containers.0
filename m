From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by
	tgid at once
Date: Mon, 3 Aug 2009 12:54:52 -0500
Message-ID: <20090803175452.GA5481__25314.6800132983$1249322685$gmane$org@us.ibm.com>
References: <20090731012908.27908.62208.stgit@hastromil.mtv.corp.google.com>
	<20090731015154.27908.9639.stgit@hastromil.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090731015154.27908.9639.stgit-/yCBOHwbXCxd3OlUiQof+WCaruZE5nAUZeezCHUQhQ4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Ben Blum (bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
...
> +static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
> +			       struct task_struct *tsk, int guarantee)
> +{
> +	struct css_set *oldcg;
> +	struct css_set *newcg;
> +
> +	/*
> +	 * get old css_set. we need to take task_lock and refcount it, because
> +	 * an exiting task can change its css_set to init_css_set and drop its
> +	 * old one without taking cgroup_mutex.
> +	 */
> +	task_lock(tsk);
> +	oldcg = tsk->cgroups;
> +	get_css_set(oldcg);
> +	task_unlock(tsk);
> +	/*
> +	 * locate or allocate a new css_set for this task. 'guarantee' tells
> +	 * us whether or not we are sure that a new css_set already exists;
> +	 * in that case, we are not allowed to fail, as we won't need malloc.
> +	 */
> +	if (guarantee) {
> +		/*
> +		 * our caller promises us that the css_set we want already
> +		 * exists, so we use find_existing_css_set directly.
> +		 */
> +		struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
> +		read_lock(&css_set_lock);
> +		newcg = find_existing_css_set(oldcg, cgrp, template);
> +		BUG_ON(!newcg);
> +		get_css_set(newcg);
> +		read_unlock(&css_set_lock);
> +	} else {
> +		might_sleep();

So cgroup_task_migrate() might sleep, but

...


> +	down_write(&leader->cgroup_fork_mutex);
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(tsk, &leader->thread_group, thread_group) {
> +		/* leave current thread as it is if it's already there */
> +		oldcgrp = task_cgroup(tsk, subsys_id);
> +		if (cgrp == oldcgrp)
> +			continue;
> +		/* we don't care whether these threads are exiting */
> +		retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, 1);

Here it is called under rcu_read_lock().

...

> -void cgroup_fork(struct task_struct *child)
> +void cgroup_fork(struct task_struct *child, int clone_flags)
>  {
> +	if (clone_flags & CLONE_THREAD)
> +		down_read(&current->group_leader->cgroup_fork_mutex);
> +	else
> +		init_rwsem(&child->cgroup_fork_mutex);

I'm also worried about the overhead here on what should be a
fast case, CLONE_THREAD.  Have you done any benchmarking of
one thread spawning a bunch of others?

What *exactly* is it we are protecting with cgroup_fork_mutex?
'fork' (as the name implies) is not a good answer, since we should be
protecting data, not code.  If it is solely tsk->cgroups, then perhaps
we should in fact try switching to (s?)rcu.  Then cgroup_fork() could
just do rcu_read_lock, while cgroup_task_migrate() would make the change
under a spinlock (to protect against concurrent cgroup_task_migrate()s),
and using rcu_assign_pointer to let cgroup_fork() see consistent data
either before or after the update...  That might mean that any checks done
before completing the migrate which involve the # of tasks might become
invalidated before the migration completes?  Seems acceptable (since
it'll be a small overcharge at most and can be quickly remedied).

-serge
