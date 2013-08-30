From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 11/12] memcg: rename cgroup_event to mem_cgroup_event
Date: Fri, 30 Aug 2013 13:19:50 +0200
Message-ID: <20130830111950.GE31605__1808.97919131002$1377861607$gmane$org@dhcp22.suse.cz>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
	<1376582550-12548-12-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1376582550-12548-12-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu 15-08-13 12:02:29, Tejun Heo wrote:
> cgroup_event is only available in memcg now.  Let's brand it that way.
> While at it, add a comment encouraging deprecation of the feature and
> remove the respective section from cgroup documentation.
> 
> This patch is cosmetic.
> 
> v2: Index in cgroups.txt updated accordingly as suggested by Li Zefan.

OK, Documentation/cgroups/memory.txt contains a documentation for all
interfaces so this can go.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

> ---
>  Documentation/cgroups/cgroups.txt | 20 --------------
>  mm/memcontrol.c                   | 57 +++++++++++++++++++++++++--------------
>  2 files changed, 37 insertions(+), 40 deletions(-)
> 
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
> index 638bf17..821de56 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt
> @@ -24,7 +24,6 @@ CONTENTS:
>    2.1 Basic Usage
>    2.2 Attaching processes
>    2.3 Mounting hierarchies by name
> -  2.4 Notification API
>  3. Kernel API
>    3.1 Overview
>    3.2 Synchronization
> @@ -472,25 +471,6 @@ you give a subsystem a name.
>  The name of the subsystem appears as part of the hierarchy description
>  in /proc/mounts and /proc/<pid>/cgroups.
>  
> -2.4 Notification API
> ---------------------
> -
> -There is mechanism which allows to get notifications about changing
> -status of a cgroup.
> -
> -To register a new notification handler you need to:
> - - create a file descriptor for event notification using eventfd(2);
> - - open a control file to be monitored (e.g. memory.usage_in_bytes);
> - - write "<event_fd> <control_fd> <args>" to cgroup.event_control.
> -   Interpretation of args is defined by control file implementation;
> -
> -eventfd will be woken up by control file implementation or when the
> -cgroup is removed.
> -
> -To unregister a notification handler just close eventfd.
> -
> -NOTE: Support of notifications should be implemented for the control
> -file. See documentation for the subsystem.
>  
>  3. Kernel API
>  =============
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8663d6c..2f0a8e1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -243,7 +243,7 @@ struct mem_cgroup_eventfd_list {
>  /*
>   * cgroup_event represents events which userspace want to receive.
>   */
> -struct cgroup_event {
> +struct mem_cgroup_event {
>  	/*
>  	 * memcg which the event belongs to.
>  	 */
> @@ -5973,14 +5973,27 @@ static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
>  #endif
>  
>  /*
> + * DO NOT USE IN NEW FILES.
> + *
> + * "cgroup.event_control" implementation.
> + *
> + * This is way over-engineered.  It tries to support fully configureable
> + * events for each user.  Such level of flexibility is completely
> + * unnecessary especially in the light of the planned unified hierarchy.
> + *
> + * Please deprecate this and replace with something simpler if at all
> + * possible.
> + */
> +
> +/*
>   * Unregister event and free resources.
>   *
>   * Gets called from workqueue.
>   */
> -static void cgroup_event_remove(struct work_struct *work)
> +static void memcg_event_remove(struct work_struct *work)
>  {
> -	struct cgroup_event *event = container_of(work, struct cgroup_event,
> -			remove);
> +	struct mem_cgroup_event *event =
> +		container_of(work, struct mem_cgroup_event, remove);
>  	struct mem_cgroup *memcg = event->memcg;
>  
>  	remove_wait_queue(event->wqh, &event->wait);
> @@ -6000,11 +6013,11 @@ static void cgroup_event_remove(struct work_struct *work)
>   *
>   * Called with wqh->lock held and interrupts disabled.
>   */
> -static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
> -		int sync, void *key)
> +static int memcg_event_wake(wait_queue_t *wait, unsigned mode,
> +			    int sync, void *key)
>  {
> -	struct cgroup_event *event = container_of(wait,
> -			struct cgroup_event, wait);
> +	struct mem_cgroup_event *event =
> +		container_of(wait, struct mem_cgroup_event, wait);
>  	struct mem_cgroup *memcg = event->memcg;
>  	unsigned long flags = (unsigned long)key;
>  
> @@ -6033,27 +6046,29 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
>  	return 0;
>  }
>  
> -static void cgroup_event_ptable_queue_proc(struct file *file,
> +static void memcg_event_ptable_queue_proc(struct file *file,
>  		wait_queue_head_t *wqh, poll_table *pt)
>  {
> -	struct cgroup_event *event = container_of(pt,
> -			struct cgroup_event, pt);
> +	struct mem_cgroup_event *event =
> +		container_of(pt, struct mem_cgroup_event, pt);
>  
>  	event->wqh = wqh;
>  	add_wait_queue(wqh, &event->wait);
>  }
>  
>  /*
> + * DO NOT USE IN NEW FILES.
> + *
>   * Parse input and register new cgroup event handler.
>   *
>   * Input must be in format '<event_fd> <control_fd> <args>'.
>   * Interpretation of args is defined by control file implementation.
>   */
> -static int cgroup_write_event_control(struct cgroup_subsys_state *css,
> -				      struct cftype *cft, const char *buffer)
> +static int memcg_write_event_control(struct cgroup_subsys_state *css,
> +				     struct cftype *cft, const char *buffer)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> -	struct cgroup_event *event;
> +	struct mem_cgroup_event *event;
>  	struct cgroup_subsys_state *cfile_css;
>  	unsigned int efd, cfd;
>  	struct file *efile;
> @@ -6078,9 +6093,9 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
>  
>  	event->memcg = memcg;
>  	INIT_LIST_HEAD(&event->list);
> -	init_poll_funcptr(&event->pt, cgroup_event_ptable_queue_proc);
> -	init_waitqueue_func_entry(&event->wait, cgroup_event_wake);
> -	INIT_WORK(&event->remove, cgroup_event_remove);
> +	init_poll_funcptr(&event->pt, memcg_event_ptable_queue_proc);
> +	init_waitqueue_func_entry(&event->wait, memcg_event_wake);
> +	INIT_WORK(&event->remove, memcg_event_remove);
>  
>  	efile = eventfd_fget(efd);
>  	if (IS_ERR(efile)) {
> @@ -6111,6 +6126,8 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
>  	 * to be done via struct cftype but cgroup core no longer knows
>  	 * about these events.  The following is crude but the whole thing
>  	 * is for compatibility anyway.
> +	 *
> +	 * DO NOT ADD NEW FILES.
>  	 */
>  	name = cfile->f_dentry->d_name.name;
>  
> @@ -6221,8 +6238,8 @@ static struct cftype mem_cgroup_files[] = {
>  		.read_u64 = mem_cgroup_hierarchy_read,
>  	},
>  	{
> -		.name = "cgroup.event_control",
> -		.write_string = cgroup_write_event_control,
> +		.name = "cgroup.event_control",		/* XXX: for compat */
> +		.write_string = memcg_write_event_control,
>  		.flags = CFTYPE_NO_PREFIX,
>  		.mode = S_IWUGO,
>  	},
> @@ -6555,7 +6572,7 @@ static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)
>  static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> -	struct cgroup_event *event, *tmp;
> +	struct mem_cgroup_event *event, *tmp;
>  
>  	/*
>  	 * Unregister events and notify userspace.
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs
