From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 10/12] memcg: make cgroup_event deal with mem_cgroup
	instead of cgroup_subsys_state
Date: Fri, 30 Aug 2013 13:15:51 +0200
Message-ID: <20130830111551.GD31605__10474.2120056928$1377861368$gmane$org@dhcp22.suse.cz>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
	<1376582550-12548-11-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1376582550-12548-11-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On Thu 15-08-13 12:02:28, Tejun Heo wrote:
> cgroup_event is now memcg specific.  Replace cgroup_event->css with
> ->memcg and convert [un]register_event() callbacks to take mem_cgroup
> pointer instead of cgroup_subsys_state one.  This simplifies the code
> slightly and makes css_to_vmpressure() unnecessary which is removed.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

> ---
>  include/linux/vmpressure.h |  5 ++---
>  mm/memcontrol.c            | 53 +++++++++++++++++++---------------------------
>  mm/vmpressure.c            | 12 +++++------
>  3 files changed, 30 insertions(+), 40 deletions(-)
> 
> diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
> index dd0b025..3c67eb3 100644
> --- a/include/linux/vmpressure.h
> +++ b/include/linux/vmpressure.h
> @@ -33,11 +33,10 @@ extern void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio);
>  extern void vmpressure_init(struct vmpressure *vmpr);
>  extern struct vmpressure *memcg_to_vmpressure(struct mem_cgroup *memcg);
>  extern struct cgroup_subsys_state *vmpressure_to_css(struct vmpressure *vmpr);
> -extern struct vmpressure *css_to_vmpressure(struct cgroup_subsys_state *css);
> -extern int vmpressure_register_event(struct cgroup_subsys_state *css,
> +extern int vmpressure_register_event(struct mem_cgroup *memcg,
>  				     struct eventfd_ctx *eventfd,
>  				     const char *args);
> -extern void vmpressure_unregister_event(struct cgroup_subsys_state *css,
> +extern void vmpressure_unregister_event(struct mem_cgroup *memcg,
>  					struct eventfd_ctx *eventfd);
>  #else
>  static inline void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 18e98ae..8663d6c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -245,9 +245,9 @@ struct mem_cgroup_eventfd_list {
>   */
>  struct cgroup_event {
>  	/*
> -	 * css which the event belongs to.
> +	 * memcg which the event belongs to.
>  	 */
> -	struct cgroup_subsys_state *css;
> +	struct mem_cgroup *memcg;
>  	/*
>  	 * eventfd to signal userspace about the event.
>  	 */
> @@ -261,14 +261,14 @@ struct cgroup_event {
>  	 * waiter for changes related to this event.  Use eventfd_signal()
>  	 * on eventfd to send notification to userspace.
>  	 */
> -	int (*register_event)(struct cgroup_subsys_state *css,
> +	int (*register_event)(struct mem_cgroup *memcg,
>  			      struct eventfd_ctx *eventfd, const char *args);
>  	/*
>  	 * unregister_event() callback will be called when userspace closes
>  	 * the eventfd or on cgroup removing.  This callback must be set,
>  	 * if you want provide notification functionality.
>  	 */
> -	void (*unregister_event)(struct cgroup_subsys_state *css,
> +	void (*unregister_event)(struct mem_cgroup *memcg,
>  				 struct eventfd_ctx *eventfd);
>  	/*
>  	 * All fields below needed to unregister event when
> @@ -546,11 +546,6 @@ struct cgroup_subsys_state *vmpressure_to_css(struct vmpressure *vmpr)
>  	return &container_of(vmpr, struct mem_cgroup, vmpressure)->css;
>  }
>  
> -struct vmpressure *css_to_vmpressure(struct cgroup_subsys_state *css)
> -{
> -	return &mem_cgroup_from_css(css)->vmpressure;
> -}
> -
>  static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
>  {
>  	return (memcg == root_mem_cgroup);
> @@ -5653,10 +5648,9 @@ static void mem_cgroup_oom_notify(struct mem_cgroup *memcg)
>  		mem_cgroup_oom_notify_cb(iter);
>  }
>  
> -static int __mem_cgroup_usage_register_event(struct cgroup_subsys_state *css,
> +static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
>  	struct eventfd_ctx *eventfd, const char *args, enum res_type type)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	struct mem_cgroup_thresholds *thresholds;
>  	struct mem_cgroup_threshold_ary *new;
>  	u64 threshold, usage;
> @@ -5735,22 +5729,21 @@ unlock:
>  	return ret;
>  }
>  
> -static int mem_cgroup_usage_register_event(struct cgroup_subsys_state *css,
> +static int mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
>  	struct eventfd_ctx *eventfd, const char *args)
>  {
> -	return __mem_cgroup_usage_register_event(css, eventfd, args, _MEM);
> +	return __mem_cgroup_usage_register_event(memcg, eventfd, args, _MEM);
>  }
>  
> -static int memsw_cgroup_usage_register_event(struct cgroup_subsys_state *css,
> +static int memsw_cgroup_usage_register_event(struct mem_cgroup *memcg,
>  	struct eventfd_ctx *eventfd, const char *args)
>  {
> -	return __mem_cgroup_usage_register_event(css, eventfd, args, _MEMSWAP);
> +	return __mem_cgroup_usage_register_event(memcg, eventfd, args, _MEMSWAP);
>  }
>  
> -static void __mem_cgroup_usage_unregister_event(struct cgroup_subsys_state *css,
> +static void __mem_cgroup_usage_unregister_event(struct mem_cgroup *memcg,
>  	struct eventfd_ctx *eventfd, enum res_type type)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	struct mem_cgroup_thresholds *thresholds;
>  	struct mem_cgroup_threshold_ary *new;
>  	u64 usage;
> @@ -5825,22 +5818,21 @@ unlock:
>  	mutex_unlock(&memcg->thresholds_lock);
>  }
>  
> -static void mem_cgroup_usage_unregister_event(struct cgroup_subsys_state *css,
> +static void mem_cgroup_usage_unregister_event(struct mem_cgroup *memcg,
>  	struct eventfd_ctx *eventfd)
>  {
> -	return __mem_cgroup_usage_unregister_event(css, eventfd, _MEM);
> +	return __mem_cgroup_usage_unregister_event(memcg, eventfd, _MEM);
>  }
>  
> -static void memsw_cgroup_usage_unregister_event(struct cgroup_subsys_state *css,
> +static void memsw_cgroup_usage_unregister_event(struct mem_cgroup *memcg,
>  	struct eventfd_ctx *eventfd)
>  {
> -	return __mem_cgroup_usage_unregister_event(css, eventfd, _MEMSWAP);
> +	return __mem_cgroup_usage_unregister_event(memcg, eventfd, _MEMSWAP);
>  }
>  
> -static int mem_cgroup_oom_register_event(struct cgroup_subsys_state *css,
> +static int mem_cgroup_oom_register_event(struct mem_cgroup *memcg,
>  	struct eventfd_ctx *eventfd, const char *args)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	struct mem_cgroup_eventfd_list *event;
>  
>  	event = kmalloc(sizeof(*event),	GFP_KERNEL);
> @@ -5860,10 +5852,9 @@ static int mem_cgroup_oom_register_event(struct cgroup_subsys_state *css,
>  	return 0;
>  }
>  
> -static void mem_cgroup_oom_unregister_event(struct cgroup_subsys_state *css,
> +static void mem_cgroup_oom_unregister_event(struct mem_cgroup *memcg,
>  	struct eventfd_ctx *eventfd)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	struct mem_cgroup_eventfd_list *ev, *tmp;
>  
>  	spin_lock(&memcg_oom_lock);
> @@ -5990,18 +5981,18 @@ static void cgroup_event_remove(struct work_struct *work)
>  {
>  	struct cgroup_event *event = container_of(work, struct cgroup_event,
>  			remove);
> -	struct cgroup_subsys_state *css = event->css;
> +	struct mem_cgroup *memcg = event->memcg;
>  
>  	remove_wait_queue(event->wqh, &event->wait);
>  
> -	event->unregister_event(css, event->eventfd);
> +	event->unregister_event(memcg, event->eventfd);
>  
>  	/* Notify userspace the event is going away. */
>  	eventfd_signal(event->eventfd, 1);
>  
>  	eventfd_ctx_put(event->eventfd);
>  	kfree(event);
> -	css_put(css);
> +	css_put(&memcg->css);
>  }
>  
>  /*
> @@ -6014,7 +6005,7 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
>  {
>  	struct cgroup_event *event = container_of(wait,
>  			struct cgroup_event, wait);
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(event->css);
> +	struct mem_cgroup *memcg = event->memcg;
>  	unsigned long flags = (unsigned long)key;
>  
>  	if (flags & POLLHUP) {
> @@ -6085,7 +6076,7 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
>  	if (!event)
>  		return -ENOMEM;
>  
> -	event->css = css;
> +	event->memcg = memcg;
>  	INIT_LIST_HEAD(&event->list);
>  	init_poll_funcptr(&event->pt, cgroup_event_ptable_queue_proc);
>  	init_waitqueue_func_entry(&event->wait, cgroup_event_wake);
> @@ -6156,7 +6147,7 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
>  	if (ret)
>  		goto out_put_cfile;
>  
> -	ret = event->register_event(css, event->eventfd, buffer);
> +	ret = event->register_event(memcg, event->eventfd, buffer);
>  	if (ret)
>  		goto out_put_css;
>  
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 40ed6e8..96f7509 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -278,7 +278,7 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
>  
>  /**
>   * vmpressure_register_event() - Bind vmpressure notifications to an eventfd
> - * @css:	css that is interested in vmpressure notifications
> + * @memcg:	memcg that is interested in vmpressure notifications
>   * @eventfd:	eventfd context to link notifications with
>   * @args:	event arguments (used to set up a pressure level threshold)
>   *
> @@ -290,10 +290,10 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
>   *
>   * To be used as memcg event method.
>   */
> -int vmpressure_register_event(struct cgroup_subsys_state *css,
> +int vmpressure_register_event(struct mem_cgroup *memcg,
>  			      struct eventfd_ctx *eventfd, const char *args)
>  {
> -	struct vmpressure *vmpr = css_to_vmpressure(css);
> +	struct vmpressure *vmpr = memcg_to_vmpressure(memcg);
>  	struct vmpressure_event *ev;
>  	int level;
>  
> @@ -321,7 +321,7 @@ int vmpressure_register_event(struct cgroup_subsys_state *css,
>  
>  /**
>   * vmpressure_unregister_event() - Unbind eventfd from vmpressure
> - * @css:	css handle
> + * @memcg:	memcg handle
>   * @eventfd:	eventfd context that was used to link vmpressure with the @cg
>   *
>   * This function does internal manipulations to detach the @eventfd from
> @@ -330,10 +330,10 @@ int vmpressure_register_event(struct cgroup_subsys_state *css,
>   *
>   * To be used as memcg event method.
>   */
> -void vmpressure_unregister_event(struct cgroup_subsys_state *css,
> +void vmpressure_unregister_event(struct mem_cgroup *memcg,
>  				 struct eventfd_ctx *eventfd)
>  {
> -	struct vmpressure *vmpr = css_to_vmpressure(css);
> +	struct vmpressure *vmpr = memcg_to_vmpressure(memcg);
>  	struct vmpressure_event *ev;
>  
>  	mutex_lock(&vmpr->events_lock);
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
