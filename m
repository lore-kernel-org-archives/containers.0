From: Alex Williamson <alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroups: fix API thinko
Date: Fri, 06 Aug 2010 09:09:08 -0600
Message-ID: <1281107348.6598.377.camel__16062.6110424802$1281107512$gmane$org@x201>
References: <20100805225914.GA26772@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100805225914.GA26772-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2010-08-06 at 01:59 +0300, Michael S. Tsirkin wrote:
> cgroup_attach_task_current_cg API that have upstream is backwards: we
> really need an API to attach to the cgroups from another process A to
> the current one.
> 
> In our case (vhost), a priveledged user wants to attach it's task to cgroups
> from a less priveledged one, the API makes us run it in the other
> task's context, and this fails.
> 
> So let's make the API generic and just pass in 'from' and 'to' tasks.
> Add an inline wrapper for cgroup_attach_task_current_cg to avoid
> breaking bisect.
> 
> Signed-off-by: Michael S. Tsirkin <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
> 
> Paul, Li, Sridhar, could you please review the following
> patch?
> 
> I only compile-tested it due to travel, but looks
> straight-forward to me.
> Alex Williamson volunteered to test and report the results.
> Sending out now for review as I might be offline for a bit.
> Will only try to merge when done, obviously.

This does seem to be working here, so please review and let us know if
this looks like a suitable interface.  Thanks,

Alex

> If OK, I would like to merge this through -net tree,
> together with the patch fixing vhost-net.
> Let me know if that sounds ok.
> 
> Thanks!
> 
> This patch is on top of net-next, it is needed for fix
> vhost-net regression in net-next, where a non-priveledged
> process can't enable the device anymore:
> 
> when qemu uses vhost, inside the ioctl call it
> creates a thread, and tries to add
> this thread to the groups of current, and it fails.
> But we control the thread, so to solve the problem,
> we really should tell it 'connect to out cgroups'.
> 
> What this patch does is add an API for that.
> 
>  include/linux/cgroup.h |   11 ++++++++++-
>  kernel/cgroup.c        |    9 +++++----
>  2 files changed, 15 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 43b2072..b38ec60 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -525,7 +525,11 @@ struct task_struct *cgroup_iter_next(struct cgroup *cgrp,
>  void cgroup_iter_end(struct cgroup *cgrp, struct cgroup_iter *it);
>  int cgroup_scan_tasks(struct cgroup_scanner *scan);
>  int cgroup_attach_task(struct cgroup *, struct task_struct *);
> -int cgroup_attach_task_current_cg(struct task_struct *);
> +int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
> +static inline int cgroup_attach_task_current_cg(struct task_struct *tsk)
> +{
> +	return cgroup_attach_task_all(current, tsk);
> +}
>  
>  /*
>   * CSS ID is ID for cgroup_subsys_state structs under subsys. This only works
> @@ -583,6 +587,11 @@ static inline int cgroupstats_build(struct cgroupstats *stats,
>  }
>  
>  /* No cgroups - nothing to do */
> +static inline int cgroup_attach_task_all(struct task_struct *from,
> +					 struct task_struct *t)
> +{
> +	return 0;
> +}
>  static inline int cgroup_attach_task_current_cg(struct task_struct *t)
>  {
>  	return 0;
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index dce8ebc..e6293b8 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1606,10 +1606,11 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
>  }
>  
>  /**
> - * cgroup_attach_task_current_cg - attach task 'tsk' to current task's cgroup
> + * cgroup_attach_task_all - attach task 'tsk' to all cgroups of task 'from'
> + * @from: attach to all cgroups of a given task
>   * @tsk: the task to be attached
>   */
> -int cgroup_attach_task_current_cg(struct task_struct *tsk)
> +int cgroup_attach_task_all(struct task_struct *from, struct task_struct *tsk)
>  {
>  	struct cgroupfs_root *root;
>  	struct cgroup *cur_cg;
> @@ -1617,7 +1618,7 @@ int cgroup_attach_task_current_cg(struct task_struct *tsk)
>  
>  	cgroup_lock();
>  	for_each_active_root(root) {
> -		cur_cg = task_cgroup_from_root(current, root);
> +		cur_cg = task_cgroup_from_root(from, root);
>  		retval = cgroup_attach_task(cur_cg, tsk);
>  		if (retval)
>  			break;
> @@ -1626,7 +1627,7 @@ int cgroup_attach_task_current_cg(struct task_struct *tsk)
>  
>  	return retval;
>  }
> -EXPORT_SYMBOL_GPL(cgroup_attach_task_current_cg);
> +EXPORT_SYMBOL_GPL(cgroup_attach_task_all);
>  
>  /*
>   * Attach task with pid 'pid' to cgroup 'cgrp'. Call with cgroup_mutex
