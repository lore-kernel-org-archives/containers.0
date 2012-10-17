From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/7] cgroup: cgroup_subsys->fork() should be called after
	the task is added to css_set
Date: Wed, 17 Oct 2012 16:28:59 +0800
Message-ID: <507E6C4B.6000704@huawei.com>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<1350426526-14254-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1350426526-14254-2-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2012/10/17 6:28, Tejun Heo wrote:
> cgroup core has a bug which violates a basic rule about event
> notifications - when a new entity needs to be added, you add that to
> the notification list first and then make the new entity conform to
> the current state.  If done in the reverse order, an event happening
> inbetween will be lost.
> 
> cgroup_subsys->fork() is invoked way before the new task is added to
> the css_set.  Currently, cgroup_freezer is the only user of ->fork()
> and uses it to make new tasks conform to the current state of the
> freezer.  If FROZEN state is requested while fork is in progress
> between cgroup_fork_callbacks() and cgroup_post_fork(), the child
> could escape freezing - the cgroup isn't frozen when ->fork() is
> called and the freezer couldn't see the new task on the css_set.
> 
> This patch moves cgroup_subsys->fork() invocation to
> cgroup_post_fork() after the new task is added to the css_set.
> cgroup_fork_callbacks() is removed.
> 
> Because now a task may be migrated during cgroup_subsys->fork(),
> freezer_fork() is updated so that it adheres to the usual RCU locking
> and the rather pointless comment on why locking can be different there
> is removed (if it doesn't make anything simpler, why even bother?).
> 

I don't think rcu read section is sufficient. It guarantees the data you're
accessing is valid, but the data can be new or can be old.

So a case below is possible:

in freezer_fork():
rcu_read_lock();
freezer = task_freezer(task);
                                  move task from freezer to freezer2
                                  which is in FREEZING/FROZEN state
freezer is in THAWED state,
nothing to do.
rcu_read_unlock();

> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  include/linux/cgroup.h  |    1 -
>  kernel/cgroup.c         |   62 ++++++++++++++++++++++------------------------
>  kernel/cgroup_freezer.c |   13 +++-------
>  kernel/fork.c           |    9 +------
>  4 files changed, 35 insertions(+), 50 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index f8a030c..4cd1d0f 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -34,7 +34,6 @@ extern int cgroup_lock_is_held(void);
>  extern bool cgroup_lock_live_group(struct cgroup *cgrp);
>  extern void cgroup_unlock(void);
>  extern void cgroup_fork(struct task_struct *p);
> -extern void cgroup_fork_callbacks(struct task_struct *p);
>  extern void cgroup_post_fork(struct task_struct *p);
>  extern void cgroup_exit(struct task_struct *p, int run_callbacks);
>  extern int cgroupstats_build(struct cgroupstats *stats,
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 13774b3..b7a0171 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -4844,44 +4844,19 @@ void cgroup_fork(struct task_struct *child)
>  }
>  
>  /**
> - * cgroup_fork_callbacks - run fork callbacks
> - * @child: the new task
> - *
> - * Called on a new task very soon before adding it to the
> - * tasklist. No need to take any locks since no-one can
> - * be operating on this task.
> - */
> -void cgroup_fork_callbacks(struct task_struct *child)
> -{
> -	if (need_forkexit_callback) {
> -		int i;
> -		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> -			struct cgroup_subsys *ss = subsys[i];
> -
> -			/*
> -			 * forkexit callbacks are only supported for
> -			 * builtin subsystems.
> -			 */
> -			if (!ss || ss->module)
> -				continue;
> -
> -			if (ss->fork)
> -				ss->fork(child);
> -		}
> -	}
> -}
> -
> -/**
>   * cgroup_post_fork - called on a new task after adding it to the task list
>   * @child: the task in question
>   *
> - * Adds the task to the list running through its css_set if necessary.
> - * Has to be after the task is visible on the task list in case we race
> - * with the first call to cgroup_iter_start() - to guarantee that the
> - * new task ends up on its list.
> + * Adds the task to the list running through its css_set if necessary and
> + * call the subsystem fork() callbacks.  Has to be after the task is
> + * visible on the task list in case we race with the first call to
> + * cgroup_iter_start() - to guarantee that the new task ends up on its
> + * list.
>   */
>  void cgroup_post_fork(struct task_struct *child)
>  {
> +	int i;
> +
>  	/*
>  	 * use_task_css_set_links is set to 1 before we walk the tasklist
>  	 * under the tasklist_lock and we read it here after we added the child
> @@ -4910,7 +4885,30 @@ void cgroup_post_fork(struct task_struct *child)
>  		}
>  		write_unlock(&css_set_lock);
>  	}
> +
> +	/*
> +	 * Call ss->fork().  This must happen after @child is linked on
> +	 * css_set; otherwise, @child might change state between ->fork()
> +	 * and addition to css_set.
> +	 */
> +	if (need_forkexit_callback) {
> +		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> +			struct cgroup_subsys *ss = subsys[i];
> +
> +			/*
> +			 * fork/exit callbacks are supported only for
> +			 * builtin subsystems and we don't need further
> +			 * synchronization as they never go away.
> +			 */
> +			if (!ss || ss->module)
> +				continue;
> +
> +			if (ss->fork)
> +				ss->fork(child);
> +		}
> +	}
>  }
> +
>  /**
>   * cgroup_exit - detach cgroup from exiting task
>   * @tsk: pointer to task_struct of exiting process
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index b1724ce..12bfedb 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -186,23 +186,15 @@ static void freezer_fork(struct task_struct *task)
>  {
>  	struct freezer *freezer;
>  
> -	/*
> -	 * No lock is needed, since the task isn't on tasklist yet,
> -	 * so it can't be moved to another cgroup, which means the
> -	 * freezer won't be removed and will be valid during this
> -	 * function call.  Nevertheless, apply RCU read-side critical
> -	 * section to suppress RCU lockdep false positives.
> -	 */
>  	rcu_read_lock();
>  	freezer = task_freezer(task);
> -	rcu_read_unlock();
>  
>  	/*
>  	 * The root cgroup is non-freezable, so we can skip the
>  	 * following check.
>  	 */
>  	if (!freezer->css.cgroup->parent)
> -		return;
> +		goto out;
>  
>  	spin_lock_irq(&freezer->lock);
>  	BUG_ON(freezer->state == CGROUP_FROZEN);
> @@ -210,7 +202,10 @@ static void freezer_fork(struct task_struct *task)
>  	/* Locking avoids race with FREEZING -> THAWED transitions. */
>  	if (freezer->state == CGROUP_FREEZING)
>  		freeze_task(task);
> +
>  	spin_unlock_irq(&freezer->lock);
> +out:
> +	rcu_read_unlock();
>  }
>  
>  /*
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 8b20ab7..acc4cb6 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1135,7 +1135,6 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  {
>  	int retval;
>  	struct task_struct *p;
> -	int cgroup_callbacks_done = 0;
>  
>  	if ((clone_flags & (CLONE_NEWNS|CLONE_FS)) == (CLONE_NEWNS|CLONE_FS))
>  		return ERR_PTR(-EINVAL);
> @@ -1393,12 +1392,6 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  	INIT_LIST_HEAD(&p->thread_group);
>  	p->task_works = NULL;
>  
> -	/* Now that the task is set up, run cgroup callbacks if
> -	 * necessary. We need to run them before the task is visible
> -	 * on the tasklist. */
> -	cgroup_fork_callbacks(p);
> -	cgroup_callbacks_done = 1;
> -
>  	/* Need tasklist lock for parent etc handling! */
>  	write_lock_irq(&tasklist_lock);
>  
> @@ -1503,7 +1496,7 @@ bad_fork_cleanup_cgroup:
>  #endif
>  	if (clone_flags & CLONE_THREAD)
>  		threadgroup_change_end(current);
> -	cgroup_exit(p, cgroup_callbacks_done);
> +	cgroup_exit(p, 0);
>  	delayacct_tsk_free(p);
>  	module_put(task_thread_info(p)->exec_domain->module);
>  bad_fork_cleanup_count:
> 
