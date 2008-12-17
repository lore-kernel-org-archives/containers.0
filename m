From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: ns_can_attach (nsproxy cgroup)
Date: Wed, 17 Dec 2008 08:52:03 +0800
Message-ID: <49484D33.5020308@cn.fujitsu.com>
References: <20081212095153.GA20956@megiteam.pl>
	<20081212140908.GA9571@us.ibm.com>
	<20081212213042.GA23581@megiteam.pl>
	<49435E58.9050209@cn.fujitsu.com>
	<20081214140604.GA22768@megiteam.pl>
	<20081216230808.GA26026@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081216230808.GA26026-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

>>From 2abb608222f3dfd1c5da3022a75c824f2b00b3f5 Mon Sep 17 00:00:00 2001
> From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
> Date: Fri, 12 Dec 2008 21:48:09 +0100
> Subject: [PATCH] Relax ns_can_attach checks to allow attaching to grandchild cgroups
> 
> The ns_proxy cgroup allows moving processes to child cgroups only one
> level deep at a time. This commit relaxes this restriction and makes it
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

Now looks good to me. :)

Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

> Signed-off-by: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
> ---
>  include/linux/cgroup.h |    4 ++--
>  kernel/cgroup.c        |   12 +++++++-----
>  kernel/ns_cgroup.c     |    9 +++------
>  3 files changed, 12 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 1ba3ded..53188f5 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -301,8 +301,8 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen);
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
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 2ae040d..5512d78 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -3101,18 +3101,19 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
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
> @@ -3122,7 +3123,8 @@ int cgroup_is_descendant(const struct cgroup *cgrp)
>  		return 1;
>  
>  	get_first_subsys(cgrp, NULL, &subsys_id);
> -	target = task_cgroup(current, subsys_id);
> +	target = task_cgroup(task, subsys_id);
> +
>  	while (cgrp != target && cgrp!= cgrp->top_cgroup)
>  		cgrp = cgrp->parent;
>  	ret = (cgrp == target);
> diff --git a/kernel/ns_cgroup.c b/kernel/ns_cgroup.c
> index 43c2111..d99b4cc 100644
> --- a/kernel/ns_cgroup.c
> +++ b/kernel/ns_cgroup.c
> @@ -46,21 +46,18 @@ int ns_cgroup_clone(struct task_struct *task, struct pid *pid)
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
> @@ -78,7 +75,7 @@ static struct cgroup_subsys_state *ns_create(struct cgroup_subsys *ss,
>  
>  	if (!capable(CAP_SYS_ADMIN))
>  		return ERR_PTR(-EPERM);
> -	if (!cgroup_is_descendant(cgroup))
> +	if (!cgroup_is_descendant(cgroup, current))
>  		return ERR_PTR(-EPERM);
>  
>  	ns_cgroup = kzalloc(sizeof(*ns_cgroup), GFP_KERNEL);
