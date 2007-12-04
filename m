From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [RFC][for -mm] memory controller enhancements for reclaiming
 take2 [7/8] bacground reclaim for memory controller
Date: Tue,  4 Dec 2007 12:07:55 +0900 (JST)
Message-ID: <20071204030756.25A971D0B8F@siro.lan>
References: <20071203184244.200faee8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Mon, 3 Dec 2007 18:42:44 +0900"
	<20071203184244.200faee8.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

> @@ -1186,6 +1251,16 @@ static void free_mem_cgroup_per_zone_inf
>  
>  static struct mem_cgroup init_mem_cgroup;
>  
> +static int __init mem_cgroup_reclaim_init(void)
> +{
> +	init_mem_cgroup.daemon.thread = kthread_run(mem_cgroup_reclaim_daemon,
> +					&init_mem_cgroup, "memcontd");
> +	if (IS_ERR(init_mem_cgroup.daemon.thread))
> +		BUG();
> +	return 0;
> +}
> +late_initcall(mem_cgroup_reclaim_init);
> +
>  static struct cgroup_subsys_state *
>  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  {
> @@ -1213,6 +1288,17 @@ mem_cgroup_create(struct cgroup_subsys *
>  		if (alloc_mem_cgroup_per_zone_info(mem, node))
>  			goto free_out;
>  
> +	/* Memory Reclaim Daemon per cgroup */
> +	init_waitqueue_head(&mem->daemon.waitq);
> +	if (mem != &init_mem_cgroup) {
> +		/* Complicated...but we cannot call kthread create here..*/
> +		/* init call will later assign kthread */
> +		mem->daemon.thread = kthread_run(mem_cgroup_reclaim_daemon,
> +					mem, "memcontd");
> +		if (IS_ERR(mem->daemon.thread))
> +			goto free_out;
> +	}
> +
>  	return &mem->css;
>  free_out:
>  	for_each_node_state(node, N_POSSIBLE)

you don't need the kthread as far as RES_HWMARK is "infinite".
given the current default value of RES_HWMARK, you can simplify
initialization by deferring the kthread creation to mem_cgroup_write.

YAMAMOTO Takashi
