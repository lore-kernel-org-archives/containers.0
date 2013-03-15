From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/4] dev_cgroup: keep track of which cgroup is the root
	cgroup
Date: Fri, 15 Mar 2013 09:07:43 -0500
Message-ID: <20130315140743.GC3782__9596.77808355099$1363356502$gmane$org@sergelap>
References: <1363338823-25292-1-git-send-email-glommer@parallels.com>
	<1363338823-25292-2-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1363338823-25292-2-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> Most of the other subsystems already keep track of that in some way.  We
> will do that internally and provide a test to determine whether or not
> our task is in a device cgroup that is not the root one. We can relax
> some of our checks in that case, trusting that whoever set device cgroup
> rules will be responsible to control access to their devices.
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> Cc: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Cc: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Patch looks fine.  AFAIK we're still waiting on Aristeu's patchset to
hit upstream.  As your patches are simpler I'd prefer, if there is
churn, for yours to be refactored than his.

Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/security.h |  1 +
>  security/device_cgroup.c | 15 +++++++++++++--
>  2 files changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/security.h b/include/linux/security.h
> index eee7478..fe58f71 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -96,6 +96,7 @@ extern int cap_task_setscheduler(struct task_struct *p);
>  extern int cap_task_setioprio(struct task_struct *p, int ioprio);
>  extern int cap_task_setnice(struct task_struct *p, int nice);
>  extern int cap_vm_enough_memory(struct mm_struct *mm, long pages);
> +bool *task_in_child_devcgroup(struct task_struct *task);
>  
>  struct msghdr;
>  struct sk_buff;
> diff --git a/security/device_cgroup.c b/security/device_cgroup.c
> index 1c69e38..03df5b2 100644
> --- a/security/device_cgroup.c
> +++ b/security/device_cgroup.c
> @@ -63,6 +63,16 @@ static inline struct dev_cgroup *task_devcgroup(struct task_struct *task)
>  	return css_to_devcgroup(task_subsys_state(task, devices_subsys_id));
>  }
>  
> +static struct dev_cgroup *root_devcgroup;
> +bool task_in_child_devcgroup(struct task_struct *task)
> +{
> +	bool ret;
> +	rcu_read_lock();
> +	ret = task_devcgroup(task) != root_devcgroup;
> +	rcu_read_unlock();
> +	return ret;
> +}
> +
>  struct cgroup_subsys devices_subsys;
>  
>  static int devcgroup_can_attach(struct cgroup *new_cgrp,
> @@ -197,9 +207,10 @@ static struct cgroup_subsys_state *devcgroup_css_alloc(struct cgroup *cgroup)
>  	INIT_LIST_HEAD(&dev_cgroup->exceptions);
>  	parent_cgroup = cgroup->parent;
>  
> -	if (parent_cgroup == NULL)
> +	if (parent_cgroup == NULL) {
>  		dev_cgroup->behavior = DEVCG_DEFAULT_ALLOW;
> -	else {
> +		root_devcgroup = dev_cgroup;
> +	} else {
>  		parent_dev_cgroup = cgroup_to_devcgroup(parent_cgroup);
>  		mutex_lock(&devcgroup_mutex);
>  		ret = dev_exceptions_copy(&dev_cgroup->exceptions,
> -- 
> 1.8.1.2
> 
