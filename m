From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 20/23] cgroup: make task iterators deal with
	cgroup_subsys_state instead of cgroup
Date: Fri, 2 Aug 2013 15:40:51 +0200
Message-ID: <20130802134051.GG25432@dhcp22.suse.cz>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
	<1375393801-4817-21-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1375393801-4817-21-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu 01-08-13 17:49:58, Tejun Heo wrote:
> cgroup is in the process of converting to css (cgroup_subsys_state)
> from cgroup as the principal subsystem interface handle.  This is
> mostly to prepare for the unified hierarchy support where css's will
> be created and destroyed dynamically but also helps cleaning up
> subsystem implementations as css is usually what they are interested
> in anyway.
> 
> This patch converts task iterators to deal with css instead of cgroup.
> Note that under unified hierarchy, different sets of tasks will be
> considered belonging to a given cgroup depending on the subsystem in
> question and making the iterators deal with css instead cgroup
> provides them with enough information about the iteration.
> 
> While at it, fix several function comment formats in cpuset.c.
> 
> This patch doesn't introduce any behavior differences.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

For memcg part
Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

> ---
>  include/linux/cgroup.h  |  21 ++++-----
>  kernel/cgroup.c         | 112 ++++++++++++++++++++++++------------------------
>  kernel/cgroup_freezer.c |  26 ++++++-----
>  kernel/cpuset.c         |  41 ++++++++----------
>  mm/memcontrol.c         |  11 +++--
>  5 files changed, 104 insertions(+), 107 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 2e9a799..6f6d87b 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -881,21 +881,22 @@ css_next_descendant_post(struct cgroup_subsys_state *pos,
>  	for ((pos) = css_next_descendant_post(NULL, (css)); (pos);	\
>  	     (pos) = css_next_descendant_post((pos), (css)))
>  
> -/* A cgroup_task_iter should be treated as an opaque object */
> -struct cgroup_task_iter {
> -	struct cgroup			*origin_cgrp;
> +/* A css_task_iter should be treated as an opaque object */
> +struct css_task_iter {
> +	struct cgroup_subsys_state	*origin_css;
>  	struct list_head		*cset_link;
>  	struct list_head		*task;
>  };
>  
> -void cgroup_task_iter_start(struct cgroup *cgrp, struct cgroup_task_iter *it);
> -struct task_struct *cgroup_task_iter_next(struct cgroup_task_iter *it);
> -void cgroup_task_iter_end(struct cgroup_task_iter *it);
> +void css_task_iter_start(struct cgroup_subsys_state *css,
> +			 struct css_task_iter *it);
> +struct task_struct *css_task_iter_next(struct css_task_iter *it);
> +void css_task_iter_end(struct css_task_iter *it);
>  
> -int cgroup_scan_tasks(struct cgroup *cgrp,
> -		      bool (*test)(struct task_struct *, void *),
> -		      void (*process)(struct task_struct *, void *),
> -		      void *data, struct ptr_heap *heap);
> +int css_scan_tasks(struct cgroup_subsys_state *css,
> +		   bool (*test)(struct task_struct *, void *),
> +		   void (*process)(struct task_struct *, void *),
> +		   void *data, struct ptr_heap *heap);
>  
>  int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
>  int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 4e354b59..c61b24f 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -370,7 +370,7 @@ static int cgroup_init_idr(struct cgroup_subsys *ss,
>  /*
>   * css_set_lock protects the list of css_set objects, and the chain of
>   * tasks off each css_set.  Nests outside task->alloc_lock due to
> - * cgroup_task_iter_start().
> + * css_task_iter_start().
>   */
>  static DEFINE_RWLOCK(css_set_lock);
>  static int css_set_count;
> @@ -398,9 +398,9 @@ static unsigned long css_set_hash(struct cgroup_subsys_state *css[])
>  
>  /*
>   * We don't maintain the lists running through each css_set to its task
> - * until after the first call to cgroup_task_iter_start().  This reduces
> - * the fork()/exit() overhead for people who have cgroups compiled into
> - * their kernel but not actually in use.
> + * until after the first call to css_task_iter_start().  This reduces the
> + * fork()/exit() overhead for people who have cgroups compiled into their
> + * kernel but not actually in use.
>   */
>  static int use_task_css_set_links __read_mostly;
>  
> @@ -2982,7 +2982,7 @@ int cgroup_task_count(const struct cgroup *cgrp)
>   * To reduce the fork() overhead for systems that are not actually using
>   * their cgroups capability, we don't maintain the lists running through
>   * each css_set to its tasks until we see the list actually used - in other
> - * words after the first call to cgroup_task_iter_start().
> + * words after the first call to css_task_iter_start().
>   */
>  static void cgroup_enable_task_cg_lists(void)
>  {
> @@ -3197,12 +3197,12 @@ css_next_descendant_post(struct cgroup_subsys_state *pos,
>  EXPORT_SYMBOL_GPL(css_next_descendant_post);
>  
>  /**
> - * cgroup_advance_task_iter - advance a task itererator to the next css_set
> + * css_advance_task_iter - advance a task itererator to the next css_set
>   * @it: the iterator to advance
>   *
>   * Advance @it to the next css_set to walk.
>   */
> -static void cgroup_advance_task_iter(struct cgroup_task_iter *it)
> +static void css_advance_task_iter(struct css_task_iter *it)
>  {
>  	struct list_head *l = it->cset_link;
>  	struct cgrp_cset_link *link;
> @@ -3211,7 +3211,7 @@ static void cgroup_advance_task_iter(struct cgroup_task_iter *it)
>  	/* Advance to the next non-empty css_set */
>  	do {
>  		l = l->next;
> -		if (l == &it->origin_cgrp->cset_links) {
> +		if (l == &it->origin_css->cgroup->cset_links) {
>  			it->cset_link = NULL;
>  			return;
>  		}
> @@ -3223,47 +3223,48 @@ static void cgroup_advance_task_iter(struct cgroup_task_iter *it)
>  }
>  
>  /**
> - * cgroup_task_iter_start - initiate task iteration
> - * @cgrp: the cgroup to walk tasks of
> + * css_task_iter_start - initiate task iteration
> + * @css: the css to walk tasks of
>   * @it: the task iterator to use
>   *
> - * Initiate iteration through the tasks of @cgrp.  The caller can call
> - * cgroup_task_iter_next() to walk through the tasks until the function
> - * returns NULL.  On completion of iteration, cgroup_task_iter_end() must
> - * be called.
> + * Initiate iteration through the tasks of @css.  The caller can call
> + * css_task_iter_next() to walk through the tasks until the function
> + * returns NULL.  On completion of iteration, css_task_iter_end() must be
> + * called.
>   *
>   * Note that this function acquires a lock which is released when the
>   * iteration finishes.  The caller can't sleep while iteration is in
>   * progress.
>   */
> -void cgroup_task_iter_start(struct cgroup *cgrp, struct cgroup_task_iter *it)
> +void css_task_iter_start(struct cgroup_subsys_state *css,
> +			 struct css_task_iter *it)
>  	__acquires(css_set_lock)
>  {
>  	/*
> -	 * The first time anyone tries to iterate across a cgroup,
> -	 * we need to enable the list linking each css_set to its
> -	 * tasks, and fix up all existing tasks.
> +	 * The first time anyone tries to iterate across a css, we need to
> +	 * enable the list linking each css_set to its tasks, and fix up
> +	 * all existing tasks.
>  	 */
>  	if (!use_task_css_set_links)
>  		cgroup_enable_task_cg_lists();
>  
>  	read_lock(&css_set_lock);
>  
> -	it->origin_cgrp = cgrp;
> -	it->cset_link = &cgrp->cset_links;
> +	it->origin_css = css;
> +	it->cset_link = &css->cgroup->cset_links;
>  
> -	cgroup_advance_task_iter(it);
> +	css_advance_task_iter(it);
>  }
>  
>  /**
> - * cgroup_task_iter_next - return the next task for the iterator
> + * css_task_iter_next - return the next task for the iterator
>   * @it: the task iterator being iterated
>   *
>   * The "next" function for task iteration.  @it should have been
> - * initialized via cgroup_task_iter_start().  Returns NULL when the
> - * iteration reaches the end.
> + * initialized via css_task_iter_start().  Returns NULL when the iteration
> + * reaches the end.
>   */
> -struct task_struct *cgroup_task_iter_next(struct cgroup_task_iter *it)
> +struct task_struct *css_task_iter_next(struct css_task_iter *it)
>  {
>  	struct task_struct *res;
>  	struct list_head *l = it->task;
> @@ -3281,7 +3282,7 @@ struct task_struct *cgroup_task_iter_next(struct cgroup_task_iter *it)
>  		 * We reached the end of this task list - move on to the
>  		 * next cgrp_cset_link.
>  		 */
> -		cgroup_advance_task_iter(it);
> +		css_advance_task_iter(it);
>  	} else {
>  		it->task = l;
>  	}
> @@ -3289,12 +3290,12 @@ struct task_struct *cgroup_task_iter_next(struct cgroup_task_iter *it)
>  }
>  
>  /**
> - * cgroup_task_iter_end - finish task iteration
> + * css_task_iter_end - finish task iteration
>   * @it: the task iterator to finish
>   *
> - * Finish task iteration started by cgroup_task_iter_start().
> + * Finish task iteration started by css_task_iter_start().
>   */
> -void cgroup_task_iter_end(struct cgroup_task_iter *it)
> +void css_task_iter_end(struct css_task_iter *it)
>  	__releases(css_set_lock)
>  {
>  	read_unlock(&css_set_lock);
> @@ -3335,24 +3336,24 @@ static inline int started_after(void *p1, void *p2)
>  }
>  
>  /**
> - * cgroup_scan_tasks - iterate though all the tasks in a cgroup
> - * @cgrp: the cgroup to iterate tasks of
> + * css_scan_tasks - iterate though all the tasks in a css
> + * @css: the css to iterate tasks of
>   * @test: optional test callback
>   * @process: process callback
>   * @data: data passed to @test and @process
>   * @heap: optional pre-allocated heap used for task iteration
>   *
> - * Iterate through all the tasks in a cgroup, calling @test for each, and
> - * if it returns %true, call @process for it also.
> + * Iterate through all the tasks in @css, calling @test for each, and if it
> + * returns %true, call @process for it also.
>   *
>   * @test may be NULL, meaning always true (select all tasks), which
> - * effectively duplicates cgroup_task_iter_{start,next,end}() but does not
> + * effectively duplicates css_task_iter_{start,next,end}() but does not
>   * lock css_set_lock for the call to @process.
>   *
>   * It is guaranteed that @process will act on every task that is a member
> - * of @cgrp for the duration of this call.  This function may or may not
> - * call @process for tasks that exit or move to a different cgroup during
> - * the call, or are forked or move into the cgroup during the call.
> + * of @css for the duration of this call.  This function may or may not
> + * call @process for tasks that exit or move to a different css during the
> + * call, or are forked or move into the css during the call.
>   *
>   * Note that @test may be called with locks held, and may in some
>   * situations be called multiple times for the same task, so it should be
> @@ -3363,13 +3364,13 @@ static inline int started_after(void *p1, void *p2)
>   * temporary heap will be used (allocation of which may cause this function
>   * to fail).
>   */
> -int cgroup_scan_tasks(struct cgroup *cgrp,
> -		      bool (*test)(struct task_struct *, void *),
> -		      void (*process)(struct task_struct *, void *),
> -		      void *data, struct ptr_heap *heap)
> +int css_scan_tasks(struct cgroup_subsys_state *css,
> +		   bool (*test)(struct task_struct *, void *),
> +		   void (*process)(struct task_struct *, void *),
> +		   void *data, struct ptr_heap *heap)
>  {
>  	int retval, i;
> -	struct cgroup_task_iter it;
> +	struct css_task_iter it;
>  	struct task_struct *p, *dropped;
>  	/* Never dereference latest_task, since it's not refcounted */
>  	struct task_struct *latest_task = NULL;
> @@ -3390,7 +3391,7 @@ int cgroup_scan_tasks(struct cgroup *cgrp,
>  
>   again:
>  	/*
> -	 * Scan tasks in the cgroup, using the @test callback to determine
> +	 * Scan tasks in the css, using the @test callback to determine
>  	 * which are of interest, and invoking @process callback on the
>  	 * ones which need an update.  Since we don't want to hold any
>  	 * locks during the task updates, gather tasks to be processed in a
> @@ -3401,8 +3402,8 @@ int cgroup_scan_tasks(struct cgroup *cgrp,
>  	 * guarantees forward progress and that we don't miss any tasks.
>  	 */
>  	heap->size = 0;
> -	cgroup_task_iter_start(cgrp, &it);
> -	while ((p = cgroup_task_iter_next(&it))) {
> +	css_task_iter_start(css, &it);
> +	while ((p = css_task_iter_next(&it))) {
>  		/*
>  		 * Only affect tasks that qualify per the caller's callback,
>  		 * if he provided one
> @@ -3435,7 +3436,7 @@ int cgroup_scan_tasks(struct cgroup *cgrp,
>  		 * the heap and wasn't inserted
>  		 */
>  	}
> -	cgroup_task_iter_end(&it);
> +	css_task_iter_end(&it);
>  
>  	if (heap->size) {
>  		for (i = 0; i < heap->size; i++) {
> @@ -3478,7 +3479,8 @@ static void cgroup_transfer_one_task(struct task_struct *task, void *data)
>   */
>  int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from)
>  {
> -	return cgroup_scan_tasks(from, NULL, cgroup_transfer_one_task, to, NULL);
> +	return css_scan_tasks(&from->dummy_css, NULL, cgroup_transfer_one_task,
> +			      to, NULL);
>  }
>  
>  /*
> @@ -3632,7 +3634,7 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
>  	pid_t *array;
>  	int length;
>  	int pid, n = 0; /* used for populating the array */
> -	struct cgroup_task_iter it;
> +	struct css_task_iter it;
>  	struct task_struct *tsk;
>  	struct cgroup_pidlist *l;
>  
> @@ -3647,8 +3649,8 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
>  	if (!array)
>  		return -ENOMEM;
>  	/* now, populate the array */
> -	cgroup_task_iter_start(cgrp, &it);
> -	while ((tsk = cgroup_task_iter_next(&it))) {
> +	css_task_iter_start(&cgrp->dummy_css, &it);
> +	while ((tsk = css_task_iter_next(&it))) {
>  		if (unlikely(n == length))
>  			break;
>  		/* get tgid or pid for procs or tasks file respectively */
> @@ -3659,7 +3661,7 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
>  		if (pid > 0) /* make sure to only use valid results */
>  			array[n++] = pid;
>  	}
> -	cgroup_task_iter_end(&it);
> +	css_task_iter_end(&it);
>  	length = n;
>  	/* now sort & (if procs) strip out duplicates */
>  	sort(array, length, sizeof(pid_t), cmppid, NULL);
> @@ -3693,7 +3695,7 @@ int cgroupstats_build(struct cgroupstats *stats, struct dentry *dentry)
>  {
>  	int ret = -EINVAL;
>  	struct cgroup *cgrp;
> -	struct cgroup_task_iter it;
> +	struct css_task_iter it;
>  	struct task_struct *tsk;
>  
>  	/*
> @@ -3707,8 +3709,8 @@ int cgroupstats_build(struct cgroupstats *stats, struct dentry *dentry)
>  	ret = 0;
>  	cgrp = dentry->d_fsdata;
>  
> -	cgroup_task_iter_start(cgrp, &it);
> -	while ((tsk = cgroup_task_iter_next(&it))) {
> +	css_task_iter_start(&cgrp->dummy_css, &it);
> +	while ((tsk = css_task_iter_next(&it))) {
>  		switch (tsk->state) {
>  		case TASK_RUNNING:
>  			stats->nr_running++;
> @@ -3728,7 +3730,7 @@ int cgroupstats_build(struct cgroupstats *stats, struct dentry *dentry)
>  			break;
>  		}
>  	}
> -	cgroup_task_iter_end(&it);
> +	css_task_iter_end(&it);
>  
>  err:
>  	return ret;
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index e0ab9bf..5cd2b6d 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -258,7 +258,7 @@ static void update_if_frozen(struct cgroup_subsys_state *css)
>  {
>  	struct freezer *freezer = css_freezer(css);
>  	struct cgroup_subsys_state *pos;
> -	struct cgroup_task_iter it;
> +	struct css_task_iter it;
>  	struct task_struct *task;
>  
>  	WARN_ON_ONCE(!rcu_read_lock_held());
> @@ -279,9 +279,9 @@ static void update_if_frozen(struct cgroup_subsys_state *css)
>  	}
>  
>  	/* are all tasks frozen? */
> -	cgroup_task_iter_start(css->cgroup, &it);
> +	css_task_iter_start(css, &it);
>  
> -	while ((task = cgroup_task_iter_next(&it))) {
> +	while ((task = css_task_iter_next(&it))) {
>  		if (freezing(task)) {
>  			/*
>  			 * freezer_should_skip() indicates that the task
> @@ -296,7 +296,7 @@ static void update_if_frozen(struct cgroup_subsys_state *css)
>  
>  	freezer->state |= CGROUP_FROZEN;
>  out_iter_end:
> -	cgroup_task_iter_end(&it);
> +	css_task_iter_end(&it);
>  out_unlock:
>  	spin_unlock_irq(&freezer->lock);
>  }
> @@ -322,26 +322,24 @@ static int freezer_read(struct cgroup_subsys_state *css, struct cftype *cft,
>  
>  static void freeze_cgroup(struct freezer *freezer)
>  {
> -	struct cgroup *cgroup = freezer->css.cgroup;
> -	struct cgroup_task_iter it;
> +	struct css_task_iter it;
>  	struct task_struct *task;
>  
> -	cgroup_task_iter_start(cgroup, &it);
> -	while ((task = cgroup_task_iter_next(&it)))
> +	css_task_iter_start(&freezer->css, &it);
> +	while ((task = css_task_iter_next(&it)))
>  		freeze_task(task);
> -	cgroup_task_iter_end(&it);
> +	css_task_iter_end(&it);
>  }
>  
>  static void unfreeze_cgroup(struct freezer *freezer)
>  {
> -	struct cgroup *cgroup = freezer->css.cgroup;
> -	struct cgroup_task_iter it;
> +	struct css_task_iter it;
>  	struct task_struct *task;
>  
> -	cgroup_task_iter_start(cgroup, &it);
> -	while ((task = cgroup_task_iter_next(&it)))
> +	css_task_iter_start(&freezer->css, &it);
> +	while ((task = css_task_iter_next(&it)))
>  		__thaw_task(task);
> -	cgroup_task_iter_end(&it);
> +	css_task_iter_end(&it);
>  }
>  
>  /**
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 6fe23f2..39e5217 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -832,8 +832,8 @@ static struct cpuset *effective_nodemask_cpuset(struct cpuset *cs)
>   * @tsk: task to test
>   * @data: cpuset to @tsk belongs to
>   *
> - * Called by cgroup_scan_tasks() for each task in a cgroup whose
> - * cpus_allowed mask needs to be changed.
> + * Called by css_scan_tasks() for each task in a cgroup whose cpus_allowed
> + * mask needs to be changed.
>   *
>   * We don't need to re-check for the cgroup/cpuset membership, since we're
>   * holding cpuset_mutex at this point.
> @@ -849,27 +849,26 @@ static void cpuset_change_cpumask(struct task_struct *tsk, void *data)
>  /**
>   * update_tasks_cpumask - Update the cpumasks of tasks in the cpuset.
>   * @cs: the cpuset in which each task's cpus_allowed mask needs to be changed
> - * @heap: if NULL, defer allocating heap memory to cgroup_scan_tasks()
> + * @heap: if NULL, defer allocating heap memory to css_scan_tasks()
>   *
>   * Called with cpuset_mutex held
>   *
> - * The cgroup_scan_tasks() function will scan all the tasks in a cgroup,
> + * The css_scan_tasks() function will scan all the tasks in a cgroup,
>   * calling callback functions for each.
>   *
> - * No return value. It's guaranteed that cgroup_scan_tasks() always returns 0
> + * No return value. It's guaranteed that css_scan_tasks() always returns 0
>   * if @heap != NULL.
>   */
>  static void update_tasks_cpumask(struct cpuset *cs, struct ptr_heap *heap)
>  {
> -	cgroup_scan_tasks(cs->css.cgroup, NULL, cpuset_change_cpumask, cs,
> -			  heap);
> +	css_scan_tasks(&cs->css, NULL, cpuset_change_cpumask, cs, heap);
>  }
>  
>  /*
>   * update_tasks_cpumask_hier - Update the cpumasks of tasks in the hierarchy.
>   * @root_cs: the root cpuset of the hierarchy
>   * @update_root: update root cpuset or not?
> - * @heap: the heap used by cgroup_scan_tasks()
> + * @heap: the heap used by css_scan_tasks()
>   *
>   * This will update cpumasks of tasks in @root_cs and all other empty cpusets
>   * which take on cpumask of @root_cs.
> @@ -1082,11 +1081,10 @@ static void *cpuset_being_rebound;
>  /**
>   * update_tasks_nodemask - Update the nodemasks of tasks in the cpuset.
>   * @cs: the cpuset in which each task's mems_allowed mask needs to be changed
> - * @heap: if NULL, defer allocating heap memory to cgroup_scan_tasks()
> + * @heap: if NULL, defer allocating heap memory to css_scan_tasks()
>   *
> - * Called with cpuset_mutex held
> - * No return value. It's guaranteed that cgroup_scan_tasks() always returns 0
> - * if @heap != NULL.
> + * Called with cpuset_mutex held.  No return value. It's guaranteed that
> + * css_scan_tasks() always returns 0 if @heap != NULL.
>   */
>  static void update_tasks_nodemask(struct cpuset *cs, struct ptr_heap *heap)
>  {
> @@ -1109,8 +1107,7 @@ static void update_tasks_nodemask(struct cpuset *cs, struct ptr_heap *heap)
>  	 * It's ok if we rebind the same mm twice; mpol_rebind_mm()
>  	 * is idempotent.  Also migrate pages in each mm to new nodes.
>  	 */
> -	cgroup_scan_tasks(cs->css.cgroup, NULL, cpuset_change_nodemask, &arg,
> -			  heap);
> +	css_scan_tasks(&cs->css, NULL, cpuset_change_nodemask, &arg, heap);
>  
>  	/*
>  	 * All the tasks' nodemasks have been updated, update
> @@ -1126,7 +1123,7 @@ static void update_tasks_nodemask(struct cpuset *cs, struct ptr_heap *heap)
>   * update_tasks_nodemask_hier - Update the nodemasks of tasks in the hierarchy.
>   * @cs: the root cpuset of the hierarchy
>   * @update_root: update the root cpuset or not?
> - * @heap: the heap used by cgroup_scan_tasks()
> + * @heap: the heap used by css_scan_tasks()
>   *
>   * This will update nodemasks of tasks in @root_cs and all other empty cpusets
>   * which take on nodemask of @root_cs.
> @@ -1254,12 +1251,12 @@ static int update_relax_domain_level(struct cpuset *cs, s64 val)
>  	return 0;
>  }
>  
> -/*
> +/**
>   * cpuset_change_flag - make a task's spread flags the same as its cpuset's
>   * @tsk: task to be updated
>   * @data: cpuset to @tsk belongs to
>   *
> - * Called by cgroup_scan_tasks() for each task in a cgroup.
> + * Called by css_scan_tasks() for each task in a cgroup.
>   *
>   * We don't need to re-check for the cgroup/cpuset membership, since we're
>   * holding cpuset_mutex at this point.
> @@ -1271,22 +1268,22 @@ static void cpuset_change_flag(struct task_struct *tsk, void *data)
>  	cpuset_update_task_spread_flag(cs, tsk);
>  }
>  
> -/*
> +/**
>   * update_tasks_flags - update the spread flags of tasks in the cpuset.
>   * @cs: the cpuset in which each task's spread flags needs to be changed
> - * @heap: if NULL, defer allocating heap memory to cgroup_scan_tasks()
> + * @heap: if NULL, defer allocating heap memory to css_scan_tasks()
>   *
>   * Called with cpuset_mutex held
>   *
> - * The cgroup_scan_tasks() function will scan all the tasks in a cgroup,
> + * The css_scan_tasks() function will scan all the tasks in a cgroup,
>   * calling callback functions for each.
>   *
> - * No return value. It's guaranteed that cgroup_scan_tasks() always returns 0
> + * No return value. It's guaranteed that css_scan_tasks() always returns 0
>   * if @heap != NULL.
>   */
>  static void update_tasks_flags(struct cpuset *cs, struct ptr_heap *heap)
>  {
> -	cgroup_scan_tasks(cs->css.cgroup, NULL, cpuset_change_flag, cs, heap);
> +	css_scan_tasks(&cs->css, NULL, cpuset_change_flag, cs, heap);
>  }
>  
>  /*
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5a5f4dc..95106a9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1799,12 +1799,11 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
>  	totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
>  	for_each_mem_cgroup_tree(iter, memcg) {
> -		struct cgroup *cgroup = iter->css.cgroup;
> -		struct cgroup_task_iter it;
> +		struct css_task_iter it;
>  		struct task_struct *task;
>  
> -		cgroup_task_iter_start(cgroup, &it);
> -		while ((task = cgroup_task_iter_next(&it))) {
> +		css_task_iter_start(&iter->css, &it);
> +		while ((task = css_task_iter_next(&it))) {
>  			switch (oom_scan_process_thread(task, totalpages, NULL,
>  							false)) {
>  			case OOM_SCAN_SELECT:
> @@ -1817,7 +1816,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  			case OOM_SCAN_CONTINUE:
>  				continue;
>  			case OOM_SCAN_ABORT:
> -				cgroup_task_iter_end(&it);
> +				css_task_iter_end(&it);
>  				mem_cgroup_iter_break(memcg, iter);
>  				if (chosen)
>  					put_task_struct(chosen);
> @@ -1834,7 +1833,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  				get_task_struct(chosen);
>  			}
>  		}
> -		cgroup_task_iter_end(&it);
> +		css_task_iter_end(&it);
>  	}
>  
>  	if (!chosen)
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
