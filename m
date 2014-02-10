From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 05/16] cgroup: implement cgroup_has_tasks() and unexport
	cgroup_task_count()
Date: Mon, 10 Feb 2014 13:36:36 +0100
Message-ID: <20140210123636.GC7117__29081.6693952822$1392035814$gmane$org@dhcp22.suse.cz>
References: <1391953964-22088-1-git-send-email-tj@kernel.org>
	<1391953964-22088-6-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1391953964-22088-6-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On Sun 09-02-14 08:52:33, Tejun Heo wrote:
> cgroup_task_count() read-locks css_set_lock and walks all tasks to
> count them and then returns the result.  The only thing all the users
> want is determining whether the cgroup is empty or not.  This patch
> implements cgroup_has_tasks() which tests whether cgroup->cset_links
> is empty, replaces all cgroup_task_count() usages and unexports it.
> 
> Note that the test isn't synchronized.  This is the same as before.
> The test has always been racy.
> 
> This will help planned css_set locking update.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

Looks good.
Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

> ---
>  include/linux/cgroup.h | 8 ++++++--
>  kernel/cgroup.c        | 2 +-
>  kernel/cpuset.c        | 2 +-
>  mm/memcontrol.c        | 4 ++--
>  4 files changed, 10 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 8ca31c1..f173cfb 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -455,6 +455,12 @@ static inline bool cgroup_sane_behavior(const struct cgroup *cgrp)
>  	return cgrp->root->flags & CGRP_ROOT_SANE_BEHAVIOR;
>  }
>  
> +/* no synchronization, the result can only be used as a hint */
> +static inline bool cgroup_has_tasks(struct cgroup *cgrp)
> +{
> +	return !list_empty(&cgrp->cset_links);
> +}
> +
>  /* returns ino associated with a cgroup, 0 indicates unmounted root */
>  static inline ino_t cgroup_ino(struct cgroup *cgrp)
>  {
> @@ -514,8 +520,6 @@ int cgroup_rm_cftypes(struct cftype *cfts);
>  
>  bool cgroup_is_descendant(struct cgroup *cgrp, struct cgroup *ancestor);
>  
> -int cgroup_task_count(const struct cgroup *cgrp);
> -
>  /*
>   * Control Group taskset, used to pass around set of tasks to cgroup_subsys
>   * methods.
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 1ebc6e30..96a3a85 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2390,7 +2390,7 @@ EXPORT_SYMBOL_GPL(cgroup_add_cftypes);
>   *
>   * Return the number of tasks in the cgroup.
>   */
> -int cgroup_task_count(const struct cgroup *cgrp)
> +static int cgroup_task_count(const struct cgroup *cgrp)
>  {
>  	int count = 0;
>  	struct cgrp_cset_link *link;
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index e97a6e8..ae190b0 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -467,7 +467,7 @@ static int validate_change(struct cpuset *cur, struct cpuset *trial)
>  	 * be changed to have empty cpus_allowed or mems_allowed.
>  	 */
>  	ret = -ENOSPC;
> -	if ((cgroup_task_count(cur->css.cgroup) || cur->attach_in_progress)) {
> +	if ((cgroup_has_tasks(cur->css.cgroup) || cur->attach_in_progress)) {
>  		if (!cpumask_empty(cur->cpus_allowed) &&
>  		    cpumask_empty(trial->cpus_allowed))
>  			goto out;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c1c2549..d9c6ac1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4958,7 +4958,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
>  	struct cgroup *cgrp = memcg->css.cgroup;
>  
>  	/* returns EBUSY if there is a task or if we come here twice. */
> -	if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
> +	if (cgroup_has_tasks(cgrp) || !list_empty(&cgrp->children))
>  		return -EBUSY;
>  
>  	/* we call try-to-free pages for make this cgroup empty */
> @@ -5140,7 +5140,7 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
>  	 * of course permitted.
>  	 */
>  	mutex_lock(&memcg_create_mutex);
> -	if (cgroup_task_count(memcg->css.cgroup) || memcg_has_children(memcg))
> +	if (cgroup_has_tasks(memcg->css.cgroup) || memcg_has_children(memcg))
>  		err = -EBUSY;
>  	mutex_unlock(&memcg_create_mutex);
>  	if (err)
> -- 
> 1.8.5.3
> 

-- 
Michal Hocko
SUSE Labs
