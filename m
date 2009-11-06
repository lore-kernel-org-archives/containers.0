From: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Subject: Re: [patch 4/5] cgroup: pass the clone_flags to the
	cgroup_fork_callback
Date: Fri, 06 Nov 2009 09:21:21 +0100
Message-ID: <4AF3DC81.1010603@free.fr>
References: <20091105202143.180978630@mai-009101017029.toulouse-stg.fr.ibm.com>
	<20091105202810.809650098@mai-009101017029.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091105202810.809650098-+lpkiSBCrgqwGcPS5fe+fxcU4LlsiAD9x8DZ0lRKBDr1ENwx4SLHqw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 11/05/2009 09:21 PM, Daniel Lezcano wrote:
> The fork callback is called but with just the task as parameter.
> This one is fine to retrieve the different parameters passed to
> the copy_process function but the clone_flags information is
> missing, so the hook in the cgroup won't be able to use of it.
> 
> This patch passes the clone_flags to the cgroup fork callback.
> That will be useful for a cgroup making process and thread
> accounting for example.
> 
> Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/cgroup.h  |    9 ++++++---
>  kernel/cgroup.c         |    4 ++--
>  kernel/cgroup_freezer.c |    3 ++-
>  kernel/fork.c           |    2 +-
>  4 files changed, 11 insertions(+), 7 deletions(-)

it lacks a small change in :

	Documentation/cgroups/cgroups.txt

same comment for the following patch :

	[patch 5/5] cgroup: call cgroup_exit with do_exit parameter

thanks,

C.

> Index: linux-2.6/include/linux/cgroup.h
> ===================================================================
> --- linux-2.6.orig/include/linux/cgroup.h
> +++ linux-2.6/include/linux/cgroup.h
> @@ -31,7 +31,8 @@ extern void cgroup_lock(void);
>  extern bool cgroup_lock_live_group(struct cgroup *cgrp);
>  extern void cgroup_unlock(void);
>  extern void cgroup_fork(struct task_struct *p);
> -extern int cgroup_fork_callbacks(struct task_struct *p);
> +extern int cgroup_fork_callbacks(struct task_struct *p,
> +				 unsigned long clone_flags);
>  extern void cgroup_post_fork(struct task_struct *p);
>  extern void cgroup_exit(struct task_struct *p);
>  extern int cgroupstats_build(struct cgroupstats *stats,
> @@ -430,7 +431,8 @@ struct cgroup_subsys {
>  	void (*attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
>  			struct cgroup *old_cgrp, struct task_struct *tsk,
>  			bool threadgroup);
> -	int  (*fork)(struct cgroup_subsys *ss, struct task_struct *task);
> +	int  (*fork)(struct cgroup_subsys *ss, struct task_struct *task,
> +		     unsigned long clone_flags);
>  	void (*exit)(struct cgroup_subsys *ss, struct task_struct *task);
>  	int (*populate)(struct cgroup_subsys *ss,
>  			struct cgroup *cgrp);
> @@ -569,7 +571,8 @@ unsigned short css_depth(struct cgroup_s
>  static inline int cgroup_init_early(void) { return 0; }
>  static inline int cgroup_init(void) { return 0; }
>  static inline void cgroup_fork(struct task_struct *p) {}
> -static inline int cgroup_fork_callbacks(struct task_struct *p) {}
> +static inline int cgroup_fork_callbacks(struct task_struct *p,
> +					unsigned long clone_flags) {}
>  static inline void cgroup_post_fork(struct task_struct *p) {}
>  static inline void cgroup_exit(struct task_struct *p, int callbacks) {}
> 
> Index: linux-2.6/kernel/cgroup.c
> ===================================================================
> --- linux-2.6.orig/kernel/cgroup.c
> +++ linux-2.6/kernel/cgroup.c
> @@ -3436,7 +3436,7 @@ void cgroup_fork(struct task_struct *chi
>   * tasklist. No need to take any locks since no-one can
>   * be operating on this task.
>   */
> -int cgroup_fork_callbacks(struct task_struct *child)
> +int cgroup_fork_callbacks(struct task_struct *child, unsigned long clone_flags)
>  {
>  	int i, ret = 0;
>  	struct cgroup_subsys *ss;
> @@ -3448,7 +3448,7 @@ int cgroup_fork_callbacks(struct task_st
>  		ss = subsys[i];
>  		if (!ss->fork)
>  			continue;
> -		ret = ss->fork(ss, child);
> +		ret = ss->fork(ss, child, clone_flags);
>  		if (ret)
>  			goto out_exit;
>  	}
> Index: linux-2.6/kernel/cgroup_freezer.c
> ===================================================================
> --- linux-2.6.orig/kernel/cgroup_freezer.c
> +++ linux-2.6/kernel/cgroup_freezer.c
> @@ -193,7 +193,8 @@ static int freezer_can_attach(struct cgr
>  	return 0;
>  }
> 
> -static int freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
> +static int freezer_fork(struct cgroup_subsys *ss, struct task_struct *task,
> +			unsigned long clone_flags)
>  {
>  	struct freezer *freezer;
> 
> Index: linux-2.6/kernel/fork.c
> ===================================================================
> --- linux-2.6.orig/kernel/fork.c
> +++ linux-2.6/kernel/fork.c
> @@ -1216,7 +1216,7 @@ static struct task_struct *copy_process(
>  	/* Now that the task is set up, run cgroup callbacks if
>  	 * necessary. We need to run them before the task is visible
>  	 * on the tasklist. */
> -	retval = cgroup_fork_callbacks(p);
> +	retval = cgroup_fork_callbacks(p, clone_flags);
>  	if (retval)
>  		goto bad_fork_free_pid;
> 
> 
