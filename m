From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] Relax ns_can_attach checks to allow attaching to
	grandchild cgroups
Date: Mon, 12 Jan 2009 16:37:29 -0800
Message-ID: <20090112163729.774b5b50.akpm@linux-foundation.org>
References: <20090106222536.GA25228@eskarina.localdomain.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090106222536.GA25228-IaEwMO9oKu/77SC2UrCW1JJg/dWx8T/9@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 6 Jan 2009 23:25:36 +0100
Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org> wrote:

> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -3104,18 +3104,19 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
>  }
>  
>  /**
> - * cgroup_is_descendant - see if @cgrp is a descendant of current task's cgrp
> + * cgroup_is_descendant - see if @cgrp is a descendant of @task's cgrp
>   * @cgrp: the cgroup in question
> + * @task: the task in question
>   *
> - * See if @cgrp is a descendant of the current task's cgroup in
> - * the appropriate hierarchy.
> + * See if @cgrp is a descendant of @task's cgroup in the appropriate
> + * hierarchy.
>   *
>   * If we are sending in dummytop, then presumably we are creating
>   * the top cgroup in the subsystem.
>   *
>   * Called only by the ns (nsproxy) cgroup.
>   */
> -int cgroup_is_descendant(const struct cgroup *cgrp)
> +int cgroup_is_descendant(const struct cgroup *cgrp, struct task_struct *task)
>  {
>  	int ret;
>  	struct cgroup *target;
> @@ -3125,7 +3126,7 @@ int cgroup_is_descendant(const struct cgroup *cgrp)
>  		return 1;
>  
>  	get_first_subsys(cgrp, NULL, &subsys_id);
> -	target = task_cgroup(current, subsys_id);
> +	target = task_cgroup(task, subsys_id);

What locking prevents *task from vanishing here?

>  	while (cgrp != target && cgrp!= cgrp->top_cgroup)
>  		cgrp = cgrp->parent;
>  	ret = (cgrp == target);
> diff --git a/kernel/ns_cgroup.c b/kernel/ns_cgroup.c
> index 43c2111..890691a 100644
> --- a/kernel/ns_cgroup.c
> +++ b/kernel/ns_cgroup.c
> @@ -35,7 +35,7 @@ int ns_cgroup_clone(struct task_struct *task, struct pid *pid)
>  
>  /*
>   * Rules:
> - *   1. you can only enter a cgroup which is a child of your current
> + *   1. you can only enter a cgroup which is a descendant of your current
>   *     cgroup
>   *   2. you can only place another process into a cgroup if
>   *     a. you have CAP_SYS_ADMIN
> @@ -46,21 +46,15 @@ int ns_cgroup_clone(struct task_struct *task, struct pid *pid)
>  static int ns_can_attach(struct cgroup_subsys *ss,
>  		struct cgroup *new_cgroup, struct task_struct *task)
>  {
> -	struct cgroup *orig;
> -
>  	if (current != task) {
>  		if (!capable(CAP_SYS_ADMIN))
>  			return -EPERM;
>  
> -		if (!cgroup_is_descendant(new_cgroup))
> +		if (!cgroup_is_descendant(new_cgroup, current))
>  			return -EPERM;
>  	}
>  
> -	if (atomic_read(&new_cgroup->count) != 0)
> -		return -EPERM;
> -
> -	orig = task_cgroup(task, ns_subsys_id);

Same question applied to the previous code.

> -	if (orig && orig != new_cgroup->parent)
> +	if (!cgroup_is_descendant(new_cgroup, task))
>  		return -EPERM;
>  
>  	return 0;
> @@ -78,7 +72,7 @@ static struct cgroup_subsys_state *ns_create(struct cgroup_subsys *ss,
>  
>  	if (!capable(CAP_SYS_ADMIN))
>  		return ERR_PTR(-EPERM);
> -	if (!cgroup_is_descendant(cgroup))
> +	if (!cgroup_is_descendant(cgroup, current))
>  		return ERR_PTR(-EPERM);
>  
>  	ns_cgroup = kzalloc(sizeof(*ns_cgroup), GFP_KERNEL);
