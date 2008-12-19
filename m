From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Relax ns_can_attach checks to allow attaching to
	grandchild cgroups
Date: Fri, 19 Dec 2008 16:23:04 -0600
Message-ID: <20081219222304.GA25828@us.ibm.com>
References: <20081219120954.GB27472@megiteam.pl>
	<20081219131641.cafc65ac.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081219131641.cafc65ac.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> (cc containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org)
> 
> Please don't send patches via private email!
> 
> 
> 
> From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
> 
> The ns_proxy cgroup allows moving processes to child cgroups only one
> level deep at a time.  This commit relaxes this restriction and makes it
> possible to attach tasks directly to grandchild cgroups, e.g.:
> 
> ($pid is in the root cgroup)
> echo $pid > /cgroup/CG1/CG2/tasks
> 
> Previously this operation would fail with -EPERM and would have to be
> performed as two steps:
> echo $pid > /cgroup/CG1/tasks
> echo $pid > /cgroup/CG1/CG2/tasks
> 
> Signed-off-by: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
> Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Cc: Balbir Singh <balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Cc: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

I trust (since you're not removing it) that the restriction that
the target cgroup be empty is not a problem?

Also, 'rule 1' in the comment above ns_can_attach should be modified
accordingly (s/child/descendant).

thanks,
-serge

> ---
> 
>  include/linux/cgroup.h |    4 ++--
>  kernel/cgroup.c        |   12 +++++++-----
>  kernel/ns_cgroup.c     |    9 +++------
>  3 files changed, 12 insertions(+), 13 deletions(-)
> 
> diff -puN include/linux/cgroup.h~relax-ns_can_attach-checks-to-allow-attaching-to-grandchild-cgroups include/linux/cgroup.h
> --- a/include/linux/cgroup.h~relax-ns_can_attach-checks-to-allow-attaching-to-grandchild-cgroups
> +++ a/include/linux/cgroup.h
> @@ -344,8 +344,8 @@ int cgroup_path(const struct cgroup *cgr
> 
>  int cgroup_task_count(const struct cgroup *cgrp);
> 
> -/* Return true if the cgroup is a descendant of the current cgroup */
> -int cgroup_is_descendant(const struct cgroup *cgrp);
> +/* Return true if cgrp is a descendant of the task's cgroup */
> +int cgroup_is_descendant(const struct cgroup *cgrp, struct task_struct *task);
> 
>  /* Control Group subsystem type. See Documentation/cgroups.txt for details */
> 
> diff -puN kernel/cgroup.c~relax-ns_can_attach-checks-to-allow-attaching-to-grandchild-cgroups kernel/cgroup.c
> --- a/kernel/cgroup.c~relax-ns_can_attach-checks-to-allow-attaching-to-grandchild-cgroups
> +++ a/kernel/cgroup.c
> @@ -3072,18 +3072,19 @@ int cgroup_clone(struct task_struct *tsk
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
> @@ -3093,7 +3094,8 @@ int cgroup_is_descendant(const struct cg
>  		return 1;
> 
>  	get_first_subsys(cgrp, NULL, &subsys_id);
> -	target = task_cgroup(current, subsys_id);
> +	target = task_cgroup(task, subsys_id);
> +
>  	while (cgrp != target && cgrp!= cgrp->top_cgroup)
>  		cgrp = cgrp->parent;
>  	ret = (cgrp == target);
> diff -puN kernel/ns_cgroup.c~relax-ns_can_attach-checks-to-allow-attaching-to-grandchild-cgroups kernel/ns_cgroup.c
> --- a/kernel/ns_cgroup.c~relax-ns_can_attach-checks-to-allow-attaching-to-grandchild-cgroups
> +++ a/kernel/ns_cgroup.c
> @@ -45,21 +45,18 @@ int ns_cgroup_clone(struct task_struct *
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
>  	if (atomic_read(&new_cgroup->count) != 0)
>  		return -EPERM;
> 
> -	orig = task_cgroup(task, ns_subsys_id);
> -	if (orig && orig != new_cgroup->parent)
> +	if (!cgroup_is_descendant(new_cgroup, task))
>  		return -EPERM;
> 
>  	return 0;
> @@ -77,7 +74,7 @@ static struct cgroup_subsys_state *ns_cr
> 
>  	if (!capable(CAP_SYS_ADMIN))
>  		return ERR_PTR(-EPERM);
> -	if (!cgroup_is_descendant(cgroup))
> +	if (!cgroup_is_descendant(cgroup, current))
>  		return ERR_PTR(-EPERM);
> 
>  	ns_cgroup = kzalloc(sizeof(*ns_cgroup), GFP_KERNEL);
> _
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
