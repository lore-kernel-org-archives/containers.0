From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 17/23] cgroup: rename cgroup_iter to cgroup_task_iter
Date: Fri, 2 Aug 2013 15:35:22 +0200
Message-ID: <20130802133522.GE25432__20456.9778441966$1375450536$gmane$org@dhcp22.suse.cz>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
	<1375393801-4817-18-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1375393801-4817-18-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On Thu 01-08-13 17:49:55, Tejun Heo wrote:
> cgroup now has multiple iterators and it's quite confusing to have
> something which walks over tasks of a single cgroup cgroup_iter.
> Let's rename it to cgroup_task_iter.
> 
> While at it, reformat / update comments and replace the overview
> comment above the interface function decls with proper function
> comments.  Such overview can be useful but function comments should be
> more than enough here.
> 
> This is pure rename and doesn't introduce any functional changes.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Makes sense
Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

> ---
>  include/linux/cgroup.h  |  31 ++++---------
>  kernel/cgroup.c         | 114 ++++++++++++++++++++++++++++++++----------------
>  kernel/cgroup_freezer.c |  24 +++++-----
>  mm/memcontrol.c         |  10 ++---
>  4 files changed, 102 insertions(+), 77 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 7fba0d0..4478336 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -890,31 +890,16 @@ css_next_descendant_post(struct cgroup_subsys_state *pos,
>  	for ((pos) = css_next_descendant_post(NULL, (css)); (pos);	\
>  	     (pos) = css_next_descendant_post((pos), (css)))
>  
> -/* A cgroup_iter should be treated as an opaque object */
> -struct cgroup_iter {
> -	struct list_head *cset_link;
> -	struct list_head *task;
> +/* A cgroup_task_iter should be treated as an opaque object */
> +struct cgroup_task_iter {
> +	struct list_head		*cset_link;
> +	struct list_head		*task;
>  };
>  
> -/*
> - * To iterate across the tasks in a cgroup:
> - *
> - * 1) call cgroup_iter_start to initialize an iterator
> - *
> - * 2) call cgroup_iter_next() to retrieve member tasks until it
> - *    returns NULL or until you want to end the iteration
> - *
> - * 3) call cgroup_iter_end() to destroy the iterator.
> - *
> - * Or, call cgroup_scan_tasks() to iterate through every task in a
> - * cgroup - cgroup_scan_tasks() holds the css_set_lock when calling
> - * the test_task() callback, but not while calling the process_task()
> - * callback.
> - */
> -void cgroup_iter_start(struct cgroup *cgrp, struct cgroup_iter *it);
> -struct task_struct *cgroup_iter_next(struct cgroup *cgrp,
> -					struct cgroup_iter *it);
> -void cgroup_iter_end(struct cgroup *cgrp, struct cgroup_iter *it);
> +void cgroup_task_iter_start(struct cgroup *cgrp, struct cgroup_task_iter *it);
> +struct task_struct *cgroup_task_iter_next(struct cgroup *cgrp,
> +					  struct cgroup_task_iter *it);
> +void cgroup_task_iter_end(struct cgroup *cgrp, struct cgroup_task_iter *it);
>  int cgroup_scan_tasks(struct cgroup_scanner *scan);
>  int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
>  int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 1085439..7a4f89b 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -367,9 +367,11 @@ static struct cgrp_cset_link init_cgrp_cset_link;
>  static int cgroup_init_idr(struct cgroup_subsys *ss,
>  			   struct cgroup_subsys_state *css);
>  
> -/* css_set_lock protects the list of css_set objects, and the
> - * chain of tasks off each css_set.  Nests outside task->alloc_lock
> - * due to cgroup_iter_start() */
> +/*
> + * css_set_lock protects the list of css_set objects, and the chain of
> + * tasks off each css_set.  Nests outside task->alloc_lock due to
> + * cgroup_task_iter_start().
> + */
>  static DEFINE_RWLOCK(css_set_lock);
>  static int css_set_count;
>  
> @@ -394,10 +396,12 @@ static unsigned long css_set_hash(struct cgroup_subsys_state *css[])
>  	return key;
>  }
>  
> -/* We don't maintain the lists running through each css_set to its
> - * task until after the first call to cgroup_iter_start(). This
> - * reduces the fork()/exit() overhead for people who have cgroups
> - * compiled into their kernel but not actually in use */
> +/*
> + * We don't maintain the lists running through each css_set to its task
> + * until after the first call to cgroup_task_iter_start().  This reduces
> + * the fork()/exit() overhead for people who have cgroups compiled into
> + * their kernel but not actually in use.
> + */
>  static int use_task_css_set_links __read_mostly;
>  
>  static void __put_css_set(struct css_set *cset, int taskexit)
> @@ -2975,10 +2979,10 @@ int cgroup_task_count(const struct cgroup *cgrp)
>  }
>  
>  /*
> - * To reduce the fork() overhead for systems that are not actually
> - * using their cgroups capability, we don't maintain the lists running
> - * through each css_set to its tasks until we see the list actually
> - * used - in other words after the first call to cgroup_iter_start().
> + * To reduce the fork() overhead for systems that are not actually using
> + * their cgroups capability, we don't maintain the lists running through
> + * each css_set to its tasks until we see the list actually used - in other
> + * words after the first call to cgroup_task_iter_start().
>   */
>  static void cgroup_enable_task_cg_lists(void)
>  {
> @@ -3192,11 +3196,15 @@ css_next_descendant_post(struct cgroup_subsys_state *pos,
>  }
>  EXPORT_SYMBOL_GPL(css_next_descendant_post);
>  
> -/*
> - * Advance a list_head iterator.  The iterator should be positioned at
> - * the start of a css_set
> +/**
> + * cgroup_advance_task_iter - advance a task itererator to the next css_set
> + * @cgrp: the cgroup to walk tasks of
> + * @it: the iterator to advance
> + *
> + * Advance @it to the next css_set to walk.
>   */
> -static void cgroup_advance_iter(struct cgroup *cgrp, struct cgroup_iter *it)
> +static void cgroup_advance_task_iter(struct cgroup *cgrp,
> +				     struct cgroup_task_iter *it)
>  {
>  	struct list_head *l = it->cset_link;
>  	struct cgrp_cset_link *link;
> @@ -3216,7 +3224,21 @@ static void cgroup_advance_iter(struct cgroup *cgrp, struct cgroup_iter *it)
>  	it->task = cset->tasks.next;
>  }
>  
> -void cgroup_iter_start(struct cgroup *cgrp, struct cgroup_iter *it)
> +/**
> + * cgroup_task_iter_start - initiate task iteration
> + * @cgrp: the cgroup to walk tasks of
> + * @it: the task iterator to use
> + *
> + * Initiate iteration through the tasks of @cgrp.  The caller can call
> + * cgroup_task_iter_next() to walk through the tasks until the function
> + * returns NULL.  On completion of iteration, cgroup_task_iter_end() must
> + * be called.
> + *
> + * Note that this function acquires a lock which is released when the
> + * iteration finishes.  The caller can't sleep while iteration is in
> + * progress.
> + */
> +void cgroup_task_iter_start(struct cgroup *cgrp, struct cgroup_task_iter *it)
>  	__acquires(css_set_lock)
>  {
>  	/*
> @@ -3229,11 +3251,20 @@ void cgroup_iter_start(struct cgroup *cgrp, struct cgroup_iter *it)
>  
>  	read_lock(&css_set_lock);
>  	it->cset_link = &cgrp->cset_links;
> -	cgroup_advance_iter(cgrp, it);
> +	cgroup_advance_task_iter(cgrp, it);
>  }
>  
> -struct task_struct *cgroup_iter_next(struct cgroup *cgrp,
> -					struct cgroup_iter *it)
> +/**
> + * cgroup_task_iter_next - return the next task for the iterator
> + * @cgrp: the cgroup to walk tasks of
> + * @it: the task iterator being iterated
> + *
> + * The "next" function for task iteration.  @it should have been
> + * initialized via cgroup_task_iter_start().  Returns NULL when the
> + * iteration reaches the end.
> + */
> +struct task_struct *cgroup_task_iter_next(struct cgroup *cgrp,
> +					  struct cgroup_task_iter *it)
>  {
>  	struct task_struct *res;
>  	struct list_head *l = it->task;
> @@ -3247,16 +3278,25 @@ struct task_struct *cgroup_iter_next(struct cgroup *cgrp,
>  	l = l->next;
>  	link = list_entry(it->cset_link, struct cgrp_cset_link, cset_link);
>  	if (l == &link->cset->tasks) {
> -		/* We reached the end of this task list - move on to
> -		 * the next cg_cgroup_link */
> -		cgroup_advance_iter(cgrp, it);
> +		/*
> +		 * We reached the end of this task list - move on to the
> +		 * next cgrp_cset_link.
> +		 */
> +		cgroup_advance_task_iter(cgrp, it);
>  	} else {
>  		it->task = l;
>  	}
>  	return res;
>  }
>  
> -void cgroup_iter_end(struct cgroup *cgrp, struct cgroup_iter *it)
> +/**
> + * cgroup_task_iter_end - finish task iteration
> + * @cgrp: the cgroup to walk tasks of
> + * @it: the task iterator to finish
> + *
> + * Finish task iteration started by cgroup_task_iter_start().
> + */
> +void cgroup_task_iter_end(struct cgroup *cgrp, struct cgroup_task_iter *it)
>  	__releases(css_set_lock)
>  {
>  	read_unlock(&css_set_lock);
> @@ -3305,7 +3345,7 @@ static inline int started_after(void *p1, void *p2)
>   * Iterate through all the tasks in a cgroup, calling test_task() for each,
>   * and if it returns true, call process_task() for it also.
>   * The test_task pointer may be NULL, meaning always true (select all tasks).
> - * Effectively duplicates cgroup_iter_{start,next,end}()
> + * Effectively duplicates cgroup_task_iter_{start,next,end}()
>   * but does not lock css_set_lock for the call to process_task().
>   * The struct cgroup_scanner may be embedded in any structure of the caller's
>   * creation.
> @@ -3326,7 +3366,7 @@ static inline int started_after(void *p1, void *p2)
>  int cgroup_scan_tasks(struct cgroup_scanner *scan)
>  {
>  	int retval, i;
> -	struct cgroup_iter it;
> +	struct cgroup_task_iter it;
>  	struct task_struct *p, *dropped;
>  	/* Never dereference latest_task, since it's not refcounted */
>  	struct task_struct *latest_task = NULL;
> @@ -3361,8 +3401,8 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
>  	 * guarantees forward progress and that we don't miss any tasks.
>  	 */
>  	heap->size = 0;
> -	cgroup_iter_start(scan->cgrp, &it);
> -	while ((p = cgroup_iter_next(scan->cgrp, &it))) {
> +	cgroup_task_iter_start(scan->cgrp, &it);
> +	while ((p = cgroup_task_iter_next(scan->cgrp, &it))) {
>  		/*
>  		 * Only affect tasks that qualify per the caller's callback,
>  		 * if he provided one
> @@ -3395,7 +3435,7 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
>  		 * the heap and wasn't inserted
>  		 */
>  	}
> -	cgroup_iter_end(scan->cgrp, &it);
> +	cgroup_task_iter_end(scan->cgrp, &it);
>  
>  	if (heap->size) {
>  		for (i = 0; i < heap->size; i++) {
> @@ -3601,7 +3641,7 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
>  	pid_t *array;
>  	int length;
>  	int pid, n = 0; /* used for populating the array */
> -	struct cgroup_iter it;
> +	struct cgroup_task_iter it;
>  	struct task_struct *tsk;
>  	struct cgroup_pidlist *l;
>  
> @@ -3616,8 +3656,8 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
>  	if (!array)
>  		return -ENOMEM;
>  	/* now, populate the array */
> -	cgroup_iter_start(cgrp, &it);
> -	while ((tsk = cgroup_iter_next(cgrp, &it))) {
> +	cgroup_task_iter_start(cgrp, &it);
> +	while ((tsk = cgroup_task_iter_next(cgrp, &it))) {
>  		if (unlikely(n == length))
>  			break;
>  		/* get tgid or pid for procs or tasks file respectively */
> @@ -3628,7 +3668,7 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
>  		if (pid > 0) /* make sure to only use valid results */
>  			array[n++] = pid;
>  	}
> -	cgroup_iter_end(cgrp, &it);
> +	cgroup_task_iter_end(cgrp, &it);
>  	length = n;
>  	/* now sort & (if procs) strip out duplicates */
>  	sort(array, length, sizeof(pid_t), cmppid, NULL);
> @@ -3662,7 +3702,7 @@ int cgroupstats_build(struct cgroupstats *stats, struct dentry *dentry)
>  {
>  	int ret = -EINVAL;
>  	struct cgroup *cgrp;
> -	struct cgroup_iter it;
> +	struct cgroup_task_iter it;
>  	struct task_struct *tsk;
>  
>  	/*
> @@ -3676,8 +3716,8 @@ int cgroupstats_build(struct cgroupstats *stats, struct dentry *dentry)
>  	ret = 0;
>  	cgrp = dentry->d_fsdata;
>  
> -	cgroup_iter_start(cgrp, &it);
> -	while ((tsk = cgroup_iter_next(cgrp, &it))) {
> +	cgroup_task_iter_start(cgrp, &it);
> +	while ((tsk = cgroup_task_iter_next(cgrp, &it))) {
>  		switch (tsk->state) {
>  		case TASK_RUNNING:
>  			stats->nr_running++;
> @@ -3697,7 +3737,7 @@ int cgroupstats_build(struct cgroupstats *stats, struct dentry *dentry)
>  			break;
>  		}
>  	}
> -	cgroup_iter_end(cgrp, &it);
> +	cgroup_task_iter_end(cgrp, &it);
>  
>  err:
>  	return ret;
> @@ -5128,7 +5168,7 @@ void cgroup_fork(struct task_struct *child)
>   * Adds the task to the list running through its css_set if necessary and
>   * call the subsystem fork() callbacks.  Has to be after the task is
>   * visible on the task list in case we race with the first call to
> - * cgroup_iter_start() - to guarantee that the new task ends up on its
> + * cgroup_task_iter_start() - to guarantee that the new task ends up on its
>   * list.
>   */
>  void cgroup_post_fork(struct task_struct *child)
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index 98ca48d..c9177f8 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -258,7 +258,7 @@ static void update_if_frozen(struct cgroup_subsys_state *css)
>  {
>  	struct freezer *freezer = css_freezer(css);
>  	struct cgroup_subsys_state *pos;
> -	struct cgroup_iter it;
> +	struct cgroup_task_iter it;
>  	struct task_struct *task;
>  
>  	WARN_ON_ONCE(!rcu_read_lock_held());
> @@ -279,9 +279,9 @@ static void update_if_frozen(struct cgroup_subsys_state *css)
>  	}
>  
>  	/* are all tasks frozen? */
> -	cgroup_iter_start(css->cgroup, &it);
> +	cgroup_task_iter_start(css->cgroup, &it);
>  
> -	while ((task = cgroup_iter_next(css->cgroup, &it))) {
> +	while ((task = cgroup_task_iter_next(css->cgroup, &it))) {
>  		if (freezing(task)) {
>  			/*
>  			 * freezer_should_skip() indicates that the task
> @@ -296,7 +296,7 @@ static void update_if_frozen(struct cgroup_subsys_state *css)
>  
>  	freezer->state |= CGROUP_FROZEN;
>  out_iter_end:
> -	cgroup_iter_end(css->cgroup, &it);
> +	cgroup_task_iter_end(css->cgroup, &it);
>  out_unlock:
>  	spin_unlock_irq(&freezer->lock);
>  }
> @@ -323,25 +323,25 @@ static int freezer_read(struct cgroup_subsys_state *css, struct cftype *cft,
>  static void freeze_cgroup(struct freezer *freezer)
>  {
>  	struct cgroup *cgroup = freezer->css.cgroup;
> -	struct cgroup_iter it;
> +	struct cgroup_task_iter it;
>  	struct task_struct *task;
>  
> -	cgroup_iter_start(cgroup, &it);
> -	while ((task = cgroup_iter_next(cgroup, &it)))
> +	cgroup_task_iter_start(cgroup, &it);
> +	while ((task = cgroup_task_iter_next(cgroup, &it)))
>  		freeze_task(task);
> -	cgroup_iter_end(cgroup, &it);
> +	cgroup_task_iter_end(cgroup, &it);
>  }
>  
>  static void unfreeze_cgroup(struct freezer *freezer)
>  {
>  	struct cgroup *cgroup = freezer->css.cgroup;
> -	struct cgroup_iter it;
> +	struct cgroup_task_iter it;
>  	struct task_struct *task;
>  
> -	cgroup_iter_start(cgroup, &it);
> -	while ((task = cgroup_iter_next(cgroup, &it)))
> +	cgroup_task_iter_start(cgroup, &it);
> +	while ((task = cgroup_task_iter_next(cgroup, &it)))
>  		__thaw_task(task);
> -	cgroup_iter_end(cgroup, &it);
> +	cgroup_task_iter_end(cgroup, &it);
>  }
>  
>  /**
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2285319..00b055d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1800,11 +1800,11 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
>  	for_each_mem_cgroup_tree(iter, memcg) {
>  		struct cgroup *cgroup = iter->css.cgroup;
> -		struct cgroup_iter it;
> +		struct cgroup_task_iter it;
>  		struct task_struct *task;
>  
> -		cgroup_iter_start(cgroup, &it);
> -		while ((task = cgroup_iter_next(cgroup, &it))) {
> +		cgroup_task_iter_start(cgroup, &it);
> +		while ((task = cgroup_task_iter_next(cgroup, &it))) {
>  			switch (oom_scan_process_thread(task, totalpages, NULL,
>  							false)) {
>  			case OOM_SCAN_SELECT:
> @@ -1817,7 +1817,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  			case OOM_SCAN_CONTINUE:
>  				continue;
>  			case OOM_SCAN_ABORT:
> -				cgroup_iter_end(cgroup, &it);
> +				cgroup_task_iter_end(cgroup, &it);
>  				mem_cgroup_iter_break(memcg, iter);
>  				if (chosen)
>  					put_task_struct(chosen);
> @@ -1834,7 +1834,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  				get_task_struct(chosen);
>  			}
>  		}
> -		cgroup_iter_end(cgroup, &it);
> +		cgroup_task_iter_end(cgroup, &it);
>  	}
>  
>  	if (!chosen)
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
