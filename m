From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] io-controller: optimization for iog deletion when
	elevator exiting
Date: Mon, 29 Jun 2009 10:06:31 -0400
Message-ID: <20090629140631.GA4622__32222.9728255936$1246284506$gmane$org@redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<1245443858-8487-6-git-send-email-vgoyal@redhat.com>
	<4A4850D3.3000700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A4850D3.3000700-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jun 29, 2009 at 01:27:47PM +0800, Gui Jianfeng wrote:
> Hi Vivek,
> 
> There's no need to travel the iocg->group_data for each iog
> when exiting a elevator, that costs too much. An alternative 
> solution is reseting iocg_id as soon as an io group unlinking 
> from a iocg. Make a decision that whether it's need to carry 
> out deleting action by checking iocg_id.
> 

Thanks Gui. This makes sense to me. We can check iog->iocg_id to determine
wheter group is still on iocg list or not instead of traversing the list.

Nauman, do you see any issues with the patch?

Thanks
Vivek

> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  block/elevator-fq.c |   29 ++++++++++-------------------
>  1 files changed, 10 insertions(+), 19 deletions(-)
> 
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index d779282..b26fe0f 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -2218,8 +2218,6 @@ void io_group_cleanup(struct io_group *iog)
>  	BUG_ON(iog->sched_data.active_entity != NULL);
>  	BUG_ON(entity != NULL && entity->tree != NULL);
>  
> -	iog->iocg_id = 0;
> -
>  	/*
>  	 * Wait for any rcu readers to exit before freeing up the group.
>  	 * Primarily useful when io_get_io_group() is called without queue
> @@ -2376,6 +2374,7 @@ remove_entry:
>  			  group_node);
>  	efqd = rcu_dereference(iog->key);
>  	hlist_del_rcu(&iog->group_node);
> +	iog->iocg_id = 0;
>  	spin_unlock_irqrestore(&iocg->lock, flags);
>  
>  	spin_lock_irqsave(efqd->queue->queue_lock, flags);
> @@ -2403,35 +2402,27 @@ done:
>  void io_group_check_and_destroy(struct elv_fq_data *efqd, struct io_group *iog)
>  {
>  	struct io_cgroup *iocg;
> -	unsigned short id = iog->iocg_id;
> -	struct hlist_node *n;
> -	struct io_group *__iog;
>  	unsigned long flags;
>  	struct cgroup_subsys_state *css;
>  
>  	rcu_read_lock();
>  
> -	BUG_ON(!id);
> -	css = css_lookup(&io_subsys, id);
> +	css = css_lookup(&io_subsys, iog->iocg_id);
>  
> -	/* css can't go away as associated io group is still around */
> -	BUG_ON(!css);
> +	if (!css)
> +		goto out;
>  
>  	iocg = container_of(css, struct io_cgroup, css);
>  
>  	spin_lock_irqsave(&iocg->lock, flags);
> -	hlist_for_each_entry_rcu(__iog, n, &iocg->group_data, group_node) {
> -		/*
> -		 * Remove iog only if it is still in iocg list. Cgroup
> -		 * deletion could have deleted it already.
> -		 */
> -		if (__iog == iog) {
> -			hlist_del_rcu(&iog->group_node);
> -			__io_destroy_group(efqd, iog);
> -			break;
> -		}
> +
> +	if (iog->iocg_id) {
> +		hlist_del_rcu(&iog->group_node);
> +		__io_destroy_group(efqd, iog);
>  	}
> +
>  	spin_unlock_irqrestore(&iocg->lock, flags);
> +out:
>  	rcu_read_unlock();
>  }
>  
> -- 1.5.4.rc3 
