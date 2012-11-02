From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 6/8] memcg: make mem_cgroup_reparent_charges non failing
Date: Fri, 02 Nov 2012 18:54:47 +0900
Message-ID: <50939867.1050205@jp.fujitsu.com>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
	<1351657365-25055-7-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351657365-25055-7-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

(2012/10/31 13:22), Tejun Heo wrote:
> From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> 
> Now that pre_destroy callbacks are called from the context where neither
> any task can attach the group nor any children group can be added there
> is no other way to fail from mem_cgroup_pre_destroy.
> mem_cgroup_pre_destroy doesn't have to take a reference to memcg's css
> because all css' are marked dead already.
> 
> tj: Remove now unused local variable @cgrp from
>      mem_cgroup_reparent_charges().
> 
> Signed-off-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Reviewed-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

+1
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>


> ---
>   mm/memcontrol.c | 19 ++++++-------------
>   1 file changed, 6 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1033b2b..47c4680 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3740,14 +3740,11 @@ static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>    *
>    * Caller is responsible for holding css reference on the memcg.
>    */
> -static int mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
> +static void mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
>   {
> -	struct cgroup *cgrp = memcg->css.cgroup;
>   	int node, zid;
>   
>   	do {
> -		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
> -			return -EBUSY;
>   		/* This is for making all *used* pages to be on LRU. */
>   		lru_add_drain_all();
>   		drain_all_stock_sync(memcg);
> @@ -3773,8 +3770,6 @@ static int mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
>   		 * charge before adding to the LRU.
>   		 */
>   	} while (res_counter_read_u64(&memcg->res, RES_USAGE) > 0);
> -
> -	return 0;
>   }
>   
>   /*
> @@ -3811,7 +3806,9 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
>   
>   	}
>   	lru_add_drain();
> -	return mem_cgroup_reparent_charges(memcg);
> +	mem_cgroup_reparent_charges(memcg);
> +
> +	return 0;
>   }
>   
>   static int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
> @@ -5008,13 +5005,9 @@ free_out:
>   static int mem_cgroup_pre_destroy(struct cgroup *cont)
>   {
>   	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> -	int ret;
>   
> -	css_get(&memcg->css);
> -	ret = mem_cgroup_reparent_charges(memcg);
> -	css_put(&memcg->css);
> -
> -	return ret;
> +	mem_cgroup_reparent_charges(memcg);
> +	return 0;
>   }
>   
>   static void mem_cgroup_destroy(struct cgroup *cont)
> 
