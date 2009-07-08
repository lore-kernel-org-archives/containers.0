From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/1] Memory usage limit notification addition to memcg
Date: Wed, 8 Jul 2009 09:56:16 +0900
Message-ID: <20090708095616.cdfe8c7c.kamezawa.hiroyu__8611.20772683552$1247014822$gmane$org@jp.fujitsu.com>
References: <1239660512-25468-1-git-send-email-dan@embeddedalley.com>
	<1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>
	<1246998310-16764-2-git-send-email-vbuzov@embeddedalley.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246998310-16764-2-git-send-email-vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
Cc: Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers Mailing List <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Linux-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

A few comments. Maybe adding linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org in CC. list makes it easier to
find this thread in the next post.

On Tue,  7 Jul 2009 13:25:10 -0700
Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org> wrote:

> This patch updates the Memory Controller cgroup to add
> a configurable memory usage limit notification. The feature
> was presented at the April 2009 Embedded Linux Conference.
> 
> Signed-off-by: Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
> Signed-off-by: Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
> ---
>  Documentation/cgroups/mem_notify.txt |  140 ++++++++++++++++++++++++++
>  include/linux/memcontrol.h           |   21 ++++
>  init/Kconfig                         |    9 ++
>  mm/memcontrol.c                      |  178 ++++++++++++++++++++++++++++++++++
>  4 files changed, 348 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/cgroups/mem_notify.txt
> 
> diff --git a/Documentation/cgroups/mem_notify.txt b/Documentation/cgroups/mem_notify.txt
> new file mode 100644
> index 0000000..b4f20d0
> --- /dev/null
> +++ b/Documentation/cgroups/mem_notify.txt
> @@ -0,0 +1,140 @@
> +
> +Memory Limit Notificiation
> +
> +Attempts have been made in the past to provide a mechanism for
> +the notification to processes (task, an address space) when memory
> +usage is approaching a high limit.  The intention is that it gives
> +the application an opportunity to release some memory and continue
> +operation rather than be OOM killed.  The CE Linux Forum requested
> +a more comtemporary implementation, and this is the result.
> +
> +The memory threshold notification is a configurable extension to the
> +existing Memory Resource Controller.  Please read memory.txt in this
> +directory to understand its operation before continuing here.
> +
> +1. Operation
> +
> +When a kernel is configured with CGROUP_MEM_NOTIFY, three additional
> +files will appear in the memory resource controller:
> +
> +	memory.notify_threshold_in_bytes
> +	memory.notify_available_in_bytes
> +	memory.notify_threshold_lowait
> +
> +The notification is based upon reaching a threshold below the memory
> +resouce controller limit (memory.limit_in_bytes). The threshold
> +represents the minimal number of bytes that should be available under
> +the limit. When the controller group is created, the threshold is set
> +to zero which triggers notification when the memory resource controller
> +limit is reached.
> +
> +The threshold may be set by writing to memory.notify_threshold_in_bytes,
> +such as:
> +
> +	echo 10M > memory.notify_threshold_in_bytes
> +
> +The current number of available bytes may be read at any time from
> +the memory.notify_available_in_bytes
> +
> +The memory.notify_threshold_lowait is a blocking read file.  The read will
> +block until one of four conditions occurs:
> +
> +    - The amount of available memory is equal or less than the threshold
> +      defined in memory.notify_threshold_in_bytes
> +    - The memory.notify_threshold_lowait file is written with any value (debug)
> +    - A thread is moved to another controller group
> +    - The cgroup is destroyed or forced empty (memory.force_empty)
> +

I don't think notify_available_in_bytes is necessary.

For making this kind of threashold useful, I think some relaxing margin is good.
for example) Once triggered, "notiry" will not be triggered in next 1ms
Do you have an idea ?

I know people likes to wait for file descriptor to get notification in these days.
Can't we have "event" file descriptor in cgroup layer and make it reusable for
other purposes ? 

> +
> +1.1 Example Usage
> +
> +An application must be designed to properly take advantage of this
> +memory threshold notification feature.  It is a powerful management component
> +of some operating systems and embedded devices that must provide
> +highly available and reliable computing services.  The application works
> +in conjunction with information provided by the operating system to
> +control limited resource usage.  Since many programmers still think
> +memory is infinite and never check the return value from malloc(), it
> +may come as a surprise that such mechanisms have been utilized long ago.
> +
> +A typical application will be multithreaded, with one thread either
> +polling or waiting for the notification event.  When the event occurs,
> +the thread will take whatever action is appropriate within the application
> +design.  This could be actually running a garbage collection algorithm
> +or to simply signal other processing threads they must do something to
> +reduce their memory usage.  The notification thread will then be required
> +to poll the actual usage until the low limit of its choosing is met,
> +at which time the reclaim of memory can stop and the notification thread
> +will wait for the next event.
> +
> +Internally, the application only needs to
> +fopen("memory.notify_available_in_bytes" ..) or
> +fopen("memory.notify_threshold_lowait" ...), then either poll the former
> +file or block read on the latter file using fread() or fscanf() as desired.
> +Comparing the value returned from either of these read function with the
> +value obtained by reading memory.notify_threshold_in_bytes will be an
> +indication of the amount of memory used over the threshold limit.
> +

I hope this application will not block rmdir() ;)



> +2. Configuration
> +
> +Follow the instructions in memory.txt for the configuration and usage of
> +the Memory Resource Controller cgroup.  Once this is created and tasks
> +assigned, use the memory threshold notification as described here.
> +
> +The only action that is needed outside of the application waiting or polling
> +is to set the memory.notify_threshold_in_bytes.  To set a notification to occur
> +when memory usage of the cgroup reaches or exceeds 1 MByte below the limit
> +can be simply done:
> +
> +	echo 1M > memory.notify_threshold_in_bytes
> +
> +This value may be read or changed at any time.  Writing a higher value once
> +the Memory Resource Controller is in operation may trigger immediate
> +notification if the usage is above the new threshold.
> +

One question is how this works under hierarchical accounting.

Considering following.

/cgroup/A/                     no thresh
          001/                 thresh=5M
              John             thresh=1M
          002/                 no thresh
              Hiroyuki         no thresh

If Hiroyuki use too much and hit /cgroup/A's limit, memory will be reclaimed from all
A,001,John,002,Hiroyuki and OOM Killer may kill processes in John.
But 001/John's notifier will not fire. Right ?


> +3. Debug and Testing
> +
> +The design of cgroups makes it easier to perform some debugging or
> +monitoring tasks without modification to the application.  For example,
> +a write of any value to memory.notify_threshold_lowait will wake up all
> +threads waiting for notifications regardless of current memory usage.
> +
> +Collecting performance data about the cgroup is also simplified, as
> +no application modifications are necessary.  A separate task can be
> +created that will open and monitor any necessary files of the cgroup
> +(such as current limits, usage and usage percentages and even when
> +notification occurs).  This task can also operate outside of the cgroup,
> +so its memory usage is not charged to the cgroup.
> +
> +4. Design
> +
> +The memory threshold notification is a configurable extension to the
> +existing Memory Resource Controller, which operates as described to
> +track and manage the memory of the Control Group. The Memory Resource
> +Controller will still continue to reclaim memory under pressure
> +of the limits, and may OOM kill tasks within the cgroup according to
> +the OOM Killer configuration.
> +
> +The memory notification threshold was chosen as a number of bytes of the
> +memory not in use so the cgroup paramaters may continue to be dynamically
> +modified without the need to modify the notificaton parameters.
> +Otherwise, the notification threshold would have to also be computed
> +and modified on any Memory Resource Controller operating parameter change.
> +
> +The cgroup file semantics are not well suited for this type of notificaton
> +mechanism.  While applications may choose to simply poll the current
> +usage at their convenience, it was also desired to have a notification
> +event that would trigger when the usage attained the threshold.  The
> +blocking read() was chosen, as it is the only current useful method.
> +This presented the problems of "out of band" notification, when you want
> +to return some exceptional status other than reaching the notification
> +threshold.  In the cases listed above, the read() on the
> +memory.notify_threshold_lowait file will not block and return "0" for
> +the remaining size.  When this occurs, the thread must determine if the task
> +has moved to a new cgroup or if the cgroup has been destroyed.  Due to
> +the usage model of this cgroup, neither is likely to happen during normal
> +operation of a product.
> +
> +Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
> +Embedded Alley Solutions, Inc.
> +6 July 2009
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index e46a073..78205a3 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -118,6 +118,27 @@ static inline bool mem_cgroup_disabled(void)
>  
>  extern bool mem_cgroup_oom_called(struct task_struct *task);
>  void mem_cgroup_update_mapped_file_stat(struct page *page, int val);
> +
> +#ifdef CONFIG_CGROUP_MEM_NOTIFY
> +void mem_cgroup_notify_test_and_wakeup(struct mem_cgroup *mcg,
> +			unsigned long long usage, unsigned long long limit);
> +void mem_cgroup_notify_new_limit(struct mem_cgroup *mcg,
> +						unsigned long long newlimit);
> +void mem_cgroup_notify_move_task(struct cgroup *old_cont);
> +#else
> +static inline void mem_cgroup_notify_test_and_wakeup(struct mem_cgroup *mcg,
> +			unsigned long long usage, unsigned long long limit)
> +{
> +}
> +static inline void mem_cgroup_notify_new_limit(struct mem_cgroup *mcg,
> +						unsigned long long newlimit)
> +{
> +}
> +static inline void mem_cgroup_notify_move_task(struct cgroup *old_cont)
> +{
> +}
> +#endif
> +
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct mem_cgroup;
>  
> diff --git a/init/Kconfig b/init/Kconfig
> index 1ce05a4..fb2f7d5 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -594,6 +594,15 @@ config CGROUP_MEM_RES_CTLR
>  	  This config option also selects MM_OWNER config option, which
>  	  could in turn add some fork/exit overhead.
>  
> +config CGROUP_MEM_NOTIFY
> +	bool "Memory Usage Limit Notification"
> +	depends on CGROUP_MEM_RES_CTLR
> +	help
> +	  Provides a memory notification when usage reaches a preset limit.
> +	  It is an extenstion to the memory resource controller, since it
> +	  uses the memory usage accounting of the cgroup to test against
> +	  the notification limit.  (See Documentation/cgroups/mem_notify.txt)
> +

I don't think CONFIG is necessary. Let this always used.


>  config CGROUP_MEM_RES_CTLR_SWAP
>  	bool "Memory Resource Controller Swap Extension(EXPERIMENTAL)"
>  	depends on CGROUP_MEM_RES_CTLR && SWAP && EXPERIMENTAL
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e2fa20d..cf04279 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6,6 +6,10 @@
>   * Copyright 2007 OpenVZ SWsoft Inc
>   * Author: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>   *
> + * Memory Limit Notification update
> + * Copyright 2009 CE Linux Forum and Embedded Alley Solutions, Inc.
> + * Author: Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
> + *
>   * This program is free software; you can redistribute it and/or modify
>   * it under the terms of the GNU General Public License as published by
>   * the Free Software Foundation; either version 2 of the License, or
> @@ -180,6 +184,11 @@ struct mem_cgroup {
>  	/* set when res.limit == memsw.limit */
>  	bool		memsw_is_minimum;
>  
> +#ifdef CONFIG_CGROUP_MEM_NOTIFY
> +	unsigned long long notify_threshold_bytes;
> +	wait_queue_head_t notify_threshold_wait;
> +#endif
> +
>  	/*
>  	 * statistics. This must be placed at the end of memcg.
>  	 */
> @@ -995,6 +1004,13 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  
>  	VM_BUG_ON(css_is_removed(&mem->css));
>  
> +	/*
> +	 * We check on the way in so we don't have to duplicate code
> +	 * in both the normal and error exit path.
> +	 */
> +	mem_cgroup_notify_test_and_wakeup(mem, mem->res.usage + PAGE_SIZE,
> +							mem->res.limit);
> +

2 points.
 - Do we have to check this always we account ?
 - This will not catch hierarchical accounting threshold because this check
   only local cgroup, no ancestors.

I don't want to say this but you need to add hook to res_counter itself.


>  	while (1) {
>  		int ret;
>  		bool noswap = false;
> @@ -1744,6 +1760,12 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  	u64 curusage, oldusage;
>  
>  	/*
> +	 * Test and notify ahead of the necessity to free pages, as
> +	 * applications giving up pages may help this reclaim procedure.
> +	 */
> +	mem_cgroup_notify_new_limit(memcg, val);
> +
> +	/*
>  	 * For keeping hierarchical_reclaim simple, how long we should retry
>  	 * is depends on callers. We set our retry-count to be function
>  	 * of # of children which we should visit in this loop.
> @@ -2308,6 +2330,139 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  	return 0;
>  }
>  
> +#ifdef CONFIG_CGROUP_MEM_NOTIFY
> +/*
> + * Check if a task exceeded notification threshold set for a memory cgroup.
> + * Wake up waiting notification threads, if any.
> + */
> +void mem_cgroup_notify_test_and_wakeup(struct mem_cgroup *mcg,
> +				       unsigned long long usage,
> +				       unsigned long long limit)
> +{
> +	if (unlikely(usage == RESOURCE_MAX))
> +		return;
What this means ?? Can happen ?

> +
> +	if ((limit - usage <= mcg->notify_threshold_bytes) &&
> +	    waitqueue_active(&mcg->notify_threshold_wait))
> +		wake_up(&mcg->notify_threshold_wait);
> +}
> +/*
> + * Check if current notification threshold exceeds new memory usage
> + * limit set for a memory cgroup. If so, set threshold to zero to
> + * notify tasks in the group when maximal memory usage is achieved.
> + */
> +void mem_cgroup_notify_new_limit(struct mem_cgroup *mcg,
> +				 unsigned long long newlimit)
> +{
> +	if (newlimit <= mcg->notify_threshold_bytes)
> +		mcg->notify_threshold_bytes = 0;
> +
> +	mem_cgroup_notify_test_and_wakeup(mcg, mcg->res.usage, newlimit);
> +}
> +
> +static u64 mem_cgroup_notify_threshold_read(struct cgroup *cgrp,
> +					    struct cftype *cft)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	return memcg->notify_threshold_bytes;
> +}
> +
> +static int mem_cgroup_notify_threshold_write(struct cgroup *cgrp,
> +					     struct cftype *cft,
> +					     const char *buffer)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	unsigned long long val;
> +	int ret;
> +
> +	/* This function does all necessary parse...reuse it */
> +	ret = res_counter_memparse_write_strategy(buffer, &val);
> +	if (ret)
> +		return ret;
> +
> +	/* Threshold must be lower than usage limit */
> +	if (val >= memcg->res.limit)
> +		return -EINVAL;

If this is true, "set limit" should be checked to guarantee this.
plz allow minus this for avoiding mess.

> +
> +	memcg->notify_threshold_bytes = val;
> +
> +	/* Check to see if the new threshold should cause notification */
> +	mem_cgroup_notify_test_and_wakeup(memcg, memcg->res.usage,
> +							memcg->res.limit);
> +
> +	return 0;
> +}
> +
> +static u64 mem_cgroup_notify_available_read(struct cgroup *cgrp,
> +					    struct cftype *cft)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	return memcg->res.limit - memcg->res.usage;
> +}
> +
> +static u64 mem_cgroup_notify_threshold_lowait(struct cgroup *cgrp,
> +					      struct cftype *cft)
> +{
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> +	unsigned long long available_bytes;
> +	DEFINE_WAIT(notify_lowait);
> +
> +	/*
> +	 * A memory resource usage of zero is a special case that
> +	 * causes us not to sleep.  It normally happens when the
> +	 * cgroup is about to be destroyed, and we don't want someone
> +	 * trying to sleep on a queue that is about to go away.  This
> +	 * condition can also be forced as part of testing.
> +	 */
> +	available_bytes = mem->res.limit - mem->res.usage;
> +	if (likely(mem->res.usage != 0)) {
> +
> +		prepare_to_wait(&mem->notify_threshold_wait, &notify_lowait,
> +							TASK_INTERRUPTIBLE);
> +
> +		if (available_bytes > mem->notify_threshold_bytes)
> +			schedule();
> +
> +		available_bytes = mem->res.limit - mem->res.usage;
> +
> +		finish_wait(&mem->notify_threshold_wait, &notify_lowait);
> +	}
> +
> +	return available_bytes;
> +}
> +
> +/*
> + * This is used to wake up all threads that may be hanging
> + * out waiting for a low memory condition prior to that happening.
> + * Useful for triggering the event to assist with debug of applications.
> + */
> +static int mem_cgroup_notify_threshold_wake_em_up(struct cgroup *cgrp,
> +						  unsigned int event)
> +{
> +	struct mem_cgroup *mem;
> +
> +	mem = mem_cgroup_from_cont(cgrp);
> +	wake_up(&mem->notify_threshold_wait);
> +	return 0;
> +}
> +
> +/*
> + * We wake up all notification threads any time a migration takes
> + * place.  They will have to check to see if a move is needed to
> + * a new cgroup file to wait for notification.
> + * This isn't so much a task move as it is an attach.  A thread not
> + * a child of an existing task won't have a valid parent, which
> + * is necessary to test because it won't have a valid mem_cgroup
> + * either.  Which further means it won't have a proper wait queue
> + * and we can't do a wakeup.
> + */
> +void mem_cgroup_notify_move_task(struct cgroup *old_cont)
> +{
> +	if (old_cont->parent != NULL)
> +		mem_cgroup_notify_threshold_wake_em_up(old_cont, 0);
> +}
> +#endif /* CONFIG_CGROUP_MEM_NOTIFY */
> +
>  

plz call wake_em_up at pre_destroy(), too.

Thanks,
-Kame


>  static struct cftype mem_cgroup_files[] = {
>  	{
> @@ -2351,6 +2506,22 @@ static struct cftype mem_cgroup_files[] = {
>  		.read_u64 = mem_cgroup_swappiness_read,
>  		.write_u64 = mem_cgroup_swappiness_write,
>  	},
> +#ifdef CONFIG_CGROUP_MEM_NOTIFY
> +	{
> +		.name = "notify_threshold_in_bytes",
> +		.write_string = mem_cgroup_notify_threshold_write,
> +		.read_u64 = mem_cgroup_notify_threshold_read,
> +	},
> +	{
> +		.name = "notify_available_in_bytes",
> +		.read_u64 = mem_cgroup_notify_available_read,
> +	},
> +	{
> +		.name = "notify_threshold_lowait",
> +		.trigger = mem_cgroup_notify_threshold_wake_em_up,
> +		.read_u64 = mem_cgroup_notify_threshold_lowait,
> +	},
> +#endif
>  };
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> @@ -2554,6 +2725,11 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	mem->last_scanned_child = 0;
>  	spin_lock_init(&mem->reclaim_param_lock);
>  
> +#ifdef CONFIG_CGROUP_MEM_NOTIFY
> +	init_waitqueue_head(&mem->notify_threshold_wait);
> +	mem->notify_threshold_bytes = 0;
> +#endif
> +
>  	if (parent)
>  		mem->swappiness = get_swappiness(parent);
>  	atomic_set(&mem->refcnt, 1);
> @@ -2597,6 +2773,8 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
>  				struct cgroup *old_cont,
>  				struct task_struct *p)
>  {
> +	mem_cgroup_notify_move_task(old_cont);
> +
>  	mutex_lock(&memcg_tasklist);
>  	/*
>  	 * FIXME: It's better to move charges of this process from old
> -- 
