From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by
	tgid at	once
Date: Mon, 03 Aug 2009 11:00:55 +0800
Message-ID: <4A7652E7.4020206__26678.2998726287$1249268681$gmane$org@cn.fujitsu.com>
References: <20090731012908.27908.62208.stgit@hastromil.mtv.corp.google.com>
	<20090731015154.27908.9639.stgit@hastromil.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Ben Blum wrote:
> Makes procs file writable to move all threads by tgid at once
> 
> This patch adds functionality that enables users to move all threads in a
> threadgroup at once to a cgroup by writing the tgid to the 'cgroup.procs'
> file. This current implementation makes use of a per-threadgroup rwsem that's
> taken for reading in the fork() path to prevent newly forking threads within
> the threadgroup from "escaping" while the move is in progress.
> 
> There is a gap between releasing the fork_mutex and calling each subsystem's
> attach function, which could possibly lead to problems if the subsystem relies
> on something that could change in the meantime as caused by forking threads.
> No particular issue seems apparent, but were some subsystem to have a problem
> here, the per-threadgroup fork mutex could be held longer until after the
> attach calls are done.
> 

This seems to work.

A few comments below..

> Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> ---
> 
>  Documentation/cgroups/cgroups.txt |   12 +
>  include/linux/cgroup.h            |   12 +
>  include/linux/init_task.h         |    9 +
>  include/linux/sched.h             |    2 
>  kernel/cgroup.c                   |  417 +++++++++++++++++++++++++++++++++----
>  kernel/fork.c                     |    6 -
>  6 files changed, 406 insertions(+), 52 deletions(-)
> 
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
> index 6eb1a97..d579346 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt
> @@ -228,6 +228,7 @@ Each cgroup is represented by a directory in the cgroup file system
>  containing the following files describing that cgroup:
>  
>   - tasks: list of tasks (by pid) attached to that cgroup
> + - cgroup.procs: list of unique tgids in the cgroup
>   - notify_on_release flag: run the release agent on exit?
>   - release_agent: the path to use for release notifications (this file
>     exists in the top cgroup only)
> @@ -374,7 +375,7 @@ Now you want to do something with this cgroup.
>  
>  In this directory you can find several files:
>  # ls
> -notify_on_release tasks
> +cgroup.procs notify_on_release tasks
>  (plus whatever files added by the attached subsystems)
>  
>  Now attach your shell to this cgroup:
> @@ -408,6 +409,15 @@ You can attach the current shell task by echoing 0:
>  
>  # echo 0 > tasks
>  
> +The cgroup.procs file is useful for managing all tasks in a threadgroup at
> +once. It works the same way as the tasks file, but moves all tasks in the
> +threadgroup with the specified tgid.
> +
> +Writing the pid of a task that's not the threadgroup leader (i.e., a pid
> +that isn't a tgid) is treated as invalid. Writing a '0' to cgroup.procs will
> +attach the writing task and all tasks in its threadgroup, but is invalid if
> +the writing task is not the leader of the threadgroup.
> +
>  3. Kernel API
>  =============
>  
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 8286758..105d681 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -30,10 +30,12 @@ extern int cgroup_init(void);
>  extern void cgroup_lock(void);
>  extern bool cgroup_lock_live_group(struct cgroup *cgrp);
>  extern void cgroup_unlock(void);
> -extern void cgroup_fork(struct task_struct *p);
> +extern void cgroup_fork(struct task_struct *p, int clone_flags);
>  extern void cgroup_fork_callbacks(struct task_struct *p);
> -extern void cgroup_post_fork(struct task_struct *p);
> +extern void cgroup_post_fork(struct task_struct *p, int clone_flags);
>  extern void cgroup_exit(struct task_struct *p, int run_callbacks);
> +extern void cgroup_fork_failed(struct task_struct *p, int run_callbacks,
> +			       int clone_flags);
>  extern int cgroupstats_build(struct cgroupstats *stats,
>  				struct dentry *dentry);
>  
> @@ -551,10 +553,12 @@ unsigned short css_depth(struct cgroup_subsys_state *css);
>  
>  static inline int cgroup_init_early(void) { return 0; }
>  static inline int cgroup_init(void) { return 0; }
> -static inline void cgroup_fork(struct task_struct *p) {}
> +static inline void cgroup_fork(struct task_struct *p, int clone_flags) {}
>  static inline void cgroup_fork_callbacks(struct task_struct *p) {}
> -static inline void cgroup_post_fork(struct task_struct *p) {}
> +static inline void cgroup_post_fork(struct task_struct *p, int clone_flags) {}
>  static inline void cgroup_exit(struct task_struct *p, int callbacks) {}
> +static inline void cgroup_fork_failed(struct task_struct *p, int callbacks,
> +				      int clone_flags) {}
>  
>  static inline void cgroup_lock(void) {}
>  static inline void cgroup_unlock(void) {}
> diff --git a/include/linux/init_task.h b/include/linux/init_task.h
> index aecd24e..26d814f 100644
> --- a/include/linux/init_task.h
> +++ b/include/linux/init_task.h
> @@ -105,6 +105,14 @@ extern struct cred init_cred;
>  # define INIT_PERF_COUNTERS(tsk)
>  #endif
>  
> +#ifdef CONFIG_CGROUPS
> +# define INIT_CGROUP_FORK_MUTEX(tsk)					\
> +	.cgroup_fork_mutex =						\
> +		__RWSEM_INITIALIZER(tsk.cgroup_fork_mutex),
> +#else
> +# define INIT_CGROUP_FORK_MUTEX(tsk)
> +#endif
> +
>  /*
>   *  INIT_TASK is used to set up the first task table, touch at
>   * your own risk!. Base=0, limit=0x1fffff (=2MB)
> @@ -174,6 +182,7 @@ extern struct cred init_cred;
>  	INIT_LOCKDEP							\
>  	INIT_FTRACE_GRAPH						\
>  	INIT_TRACE_RECURSION						\
> +	INIT_CGROUP_FORK_MUTEX(tsk)					\
>  }
>  
>  
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 55e3e11..5d38980 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1400,6 +1400,8 @@ struct task_struct {
>  	struct css_set *cgroups;
>  	/* cg_list protected by css_set_lock and tsk->alloc_lock */
>  	struct list_head cg_list;
> +	/* guarantees atomic threadgroup movement via the procs file */
> +	struct rw_semaphore cgroup_fork_mutex;
>  #endif
>  #ifdef CONFIG_FUTEX
>  	struct robust_list_head __user *robust_list;
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index ea05d6b..3ce7298 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1297,6 +1297,87 @@ static void get_first_subsys(const struct cgroup *cgrp,
>  		*subsys_id = test_ss->subsys_id;
>  }
>  
> +/*
> + * cgroup_task_migrate - move a task from one cgroup to another.
> + *
> + * 'guarantee' is set if the caller promises that a new css_set for the task
> + * will already exist. If not set, this function might sleep, and can fail
> + * with -ENOMEM. Otherwise, it can only fail with -ESRCH.
> + */
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

Better use blank lines more to improve code readability.

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
> +		/* find_css_set will give us newcg already referenced. */
> +		newcg = find_css_set(oldcg, cgrp);
> +		if (!newcg) {
> +			put_css_set(oldcg);
> +			return -ENOMEM;
> +		}
> +	}
> +	put_css_set(oldcg);
> +
> +	/*
> +	 * we cannot move a task that's declared itself as exiting, as once
> +	 * PF_EXITING is set, the tsk->cgroups pointer is no longer safe.
> +	 */
> +	task_lock(tsk);
> +	if (tsk->flags & PF_EXITING) {
> +		task_unlock(tsk);
> +		put_css_set(newcg);
> +		return -ESRCH;
> +	}
> +	rcu_assign_pointer(tsk->cgroups, newcg);
> +	task_unlock(tsk);
> +
> +	/* Update the css_set linked lists if we're using them */
> +	write_lock(&css_set_lock);
> +	if (!list_empty(&tsk->cg_list)) {
> +		list_del(&tsk->cg_list);
> +		list_add(&tsk->cg_list, &newcg->tasks);

list_move()

> +	}
> +	write_unlock(&css_set_lock);
> +
> +	/*
> +	 * We just gained a reference on oldcg by taking it from the task. As

This comment is incorrect, the ref we just got has been dropped by
the above put_css_set(oldcg).

> +	 * trading it for newcg is protected by cgroup_mutex, we're safe to
> +	 * drop it here; it will be freed under RCU.
> +	 */
> +	put_css_set(oldcg);
> +
> +	set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
> +	return 0;
> +}
> +
>  /**
>   * cgroup_attach_task - attach task 'tsk' to cgroup 'cgrp'
>   * @cgrp: the cgroup the task is attaching to
> @@ -1307,11 +1388,9 @@ static void get_first_subsys(const struct cgroup *cgrp,
>   */
>  int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
>  {
> -	int retval = 0;
> +	int retval;
>  	struct cgroup_subsys *ss;
>  	struct cgroup *oldcgrp;
> -	struct css_set *cg;
> -	struct css_set *newcg;
>  	struct cgroupfs_root *root = cgrp->root;
>  	int subsys_id;
>  
> @@ -1330,75 +1409,293 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
>  		}
>  	}
>  
> -	task_lock(tsk);
> -	cg = tsk->cgroups;
> -	get_css_set(cg);
> -	task_unlock(tsk);
> +	retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, 0);
> +	if (retval)
> +		return retval;
> +
> +	for_each_subsys(root, ss) {
> +		if (ss->attach)
> +			ss->attach(ss, cgrp, oldcgrp, tsk, false);
> +	}
> +
> +	synchronize_rcu();
> +
>  	/*
> -	 * Locate or allocate a new css_set for this task,
> -	 * based on its final set of cgroups
> +	 * wake up rmdir() waiter. the rmdir should fail since the cgroup
> +	 * is no longer empty.
>  	 */
> +	cgroup_wakeup_rmdir_waiters(cgrp);
> +	return 0;
> +}
> +
> +/*
> + * cgroup_attach_proc works in two stages, the first of which prefetches all
> + * new css_sets needed (to make sure we have enough memory before committing
> + * to the move) and stores them in a list, of entries of the following type.
> + * TODO: possible optimization: use css_set->rcu_head for chaining instead
> + */
> +struct cg_list_entry {
> +	struct css_set *cg;
> +	struct list_head links;
> +};
> +
> +static int css_set_check_fetched(struct cgroup *cgrp, struct task_struct *tsk,
> +				 struct css_set *cg,
> +				 struct list_head *newcg_list)
> +{
> +	struct css_set *newcg;
> +	struct cg_list_entry *cg_entry;
> +	struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
> +	read_lock(&css_set_lock);
> +	newcg = find_existing_css_set(cg, cgrp, template);
> +	if (newcg)
> +		get_css_set(newcg);
> +	read_unlock(&css_set_lock);
> +	/* doesn't exist at all? */
> +	if (!newcg)
> +		return 1;

I think it's more intuitive to return 1 if found and 0 if not found.

> +	/* see if it's already in the list */
> +	list_for_each_entry(cg_entry, newcg_list, links) {
> +		if (cg_entry->cg == newcg) {
> +			put_css_set(newcg);
> +			return 0;
> +		}
> +	}
> +	/* not found */
> +	put_css_set(newcg);
> +	return 1;

Those lines are squeezed too tight. ;)

> +}
> +
