From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH] memcg: fix a race when setting memcg.swappiness
Date: Wed, 14 Jan 2009 13:26:16 +0900
Message-ID: <20090114132616.3cb7d568.kamezawa.hiroyu__25756.9656860598$1231907373$gmane$org@jp.fujitsu.com>
References: <496D5AE2.2020403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <496D5AE2.2020403-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 14 Jan 2009 11:24:18 +0800
Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:

> (suppose: memcg->use_hierarchy == 0 and memcg->swappiness == 60)
> 
> echo 10 > /memcg/0/swappiness   |
>   mem_cgroup_swappiness_write() |
>     ...                         | echo 1 > /memcg/0/use_hierarchy
>                                 | mkdir /mnt/0/1
>                                 |   sub_memcg->swappiness = 60;
>     memcg->swappiness = 10;     |
> 
> In the above scenario, we end up having 2 different swappiness
> values in a single hierarchy.
> 
> Note we can't use hierarchy_lock here, because it doesn't protect
> the create() method.
> 
> Though IMO use cgroup_lock() in simple write functions is OK,
> Paul would like to avoid it. And he sugguested use a counter to
> count the number of children instead of check cgrp->children list:
> 
> =================
> create() does:
> 
> lock memcg_parent
> memcg->swappiness = memcg->parent->swappiness;
> memcg_parent->child_count++;
> unlock memcg_parent
> 
> and write() does:
> 
> lock memcg
> if (!memcg->child_count) {
>   memcg->swappiness = swappiness;
> } else {
>   report error;
> }
> unlock memcg
> 
> destroy() does:
> lock memcg_parent
> memcg_parent->child_count--;
> unlock memcg_parent
> 
> =================
> 
> And there is a suble differnce with checking cgrp->children,
> that a cgroup is removed from parent's list in cgroup_rmdir(),
> while memcg->child_count is decremented in cgroup_diput().
> 
> 
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Seems reasonable, but, hmm...

Why hierarchy_mutex can't be used for create() ?

-Kame

> ---
>  mm/memcontrol.c |   10 +++++++++-
>  1 files changed, 9 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e2996b8..0274223 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1971,6 +1971,7 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
>  	struct mem_cgroup *parent;
> +
>  	if (val > 100)
>  		return -EINVAL;
>  
> @@ -1978,15 +1979,22 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  		return -EINVAL;
>  
>  	parent = mem_cgroup_from_cont(cgrp->parent);
> +
> +	cgroup_lock();
> +
>  	/* If under hierarchy, only empty-root can set this value */
>  	if ((parent->use_hierarchy) ||
> -	    (memcg->use_hierarchy && !list_empty(&cgrp->children)))
> +	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
> +		cgroup_unlock();
>  		return -EINVAL;
> +	}
>  
>  	spin_lock(&memcg->reclaim_param_lock);
>  	memcg->swappiness = val;
>  	spin_unlock(&memcg->reclaim_param_lock);
>  
> +	cgroup_unlock();
> +
>  	return 0;
>  }
>  
> -- 
> 1.5.4.rc3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo-Bw31MaZKKs0EbZ0PF+XxCw@public.gmane.org  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org"> email-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org </a>
> 
