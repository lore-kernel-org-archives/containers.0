From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] io-controller: Get rid of css id from io cgroup
Date: Wed, 8 Jul 2009 10:04:11 -0400
Message-ID: <20090708140411.GD24048__12215.330094523$1247062092$gmane$org@redhat.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<1246564917-19603-10-git-send-email-vgoyal@redhat.com>
	<4A51657B.7000008@cn.fujitsu.com>
	<20090706141650.GD8279@redhat.com>
	<4A52A77E.8050203@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A52A77E.8050203-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Tue, Jul 07, 2009 at 09:40:14AM +0800, Gui Jianfeng wrote:
> Get rid of css id from io cgroup since it's nothing
> more than keeping track of iocg. An alternative is
> caching iocg pointer in io group, just remove the
> complexity.
> 

Gui, one advantage of using css_id is that we store only 2 bytes of id
instead of 8 bytes of iocg* pointer (on 64bit). So saving of 6 bytes per
group. May be it is not a bad idea to keep the usage of css id around
because anyway we don't seem to gain much by getting rid of it.

So for the time being I tend to think that lets continue using css id.

Thanks
Vivek

> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  block/elevator-fq.c |   36 ++++++++++++------------------------
>  block/elevator-fq.h |    2 +-
>  2 files changed, 13 insertions(+), 25 deletions(-)
> 
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index 7c83d1e..f499b54 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -191,25 +191,19 @@ static inline struct io_group *iog_parent(struct io_group *iog)
>  #ifdef CONFIG_DEBUG_GROUP_IOSCHED
>  static void io_group_path(struct io_group *iog, char *buf, int buflen)
>  {
> -	unsigned short id = iog->iocg_id;
> -	struct cgroup_subsys_state *css;
> +	struct io_cgroup *iocg;
> +	int ret;
>  
>  	rcu_read_lock();
>  
> -	if (!id)
> +	iocg = iog->iocg;
> +	if (!iocg)
>  		goto out;
>  
> -	css = css_lookup(&io_subsys, id);
> -	if (!css)
> -		goto out;
> -
> -	if (!css_tryget(css))
> +	ret = cgroup_path(iocg->css.cgroup, buf, buflen);
> +	if (ret)
>  		goto out;
>  
> -	cgroup_path(css->cgroup, buf, buflen);
> -
> -	css_put(css);
> -
>  	rcu_read_unlock();
>  	return;
>  out:
> @@ -1847,7 +1841,6 @@ struct cgroup_subsys io_subsys = {
>  	.destroy = iocg_destroy,
>  	.populate = iocg_populate,
>  	.subsys_id = io_subsys_id,
> -	.use_id = 1,
>  };
>  
>  static inline unsigned int iog_weight(struct io_group *iog)
> @@ -1890,7 +1883,7 @@ io_group_chain_alloc(struct request_queue *q, void *key, struct cgroup *cgroup)
>  		if (!iog)
>  			goto cleanup;
>  
> -		iog->iocg_id = css_id(&iocg->css);
> +		iog->iocg = iocg;
>  
>  		sscanf(dev_name(bdi->dev), "%u:%u", &major, &minor);
>  		iog->dev = MKDEV(major, minor);
> @@ -2201,7 +2194,7 @@ static struct io_group *io_alloc_root_group(struct request_queue *q,
>  	spin_lock_irq(&iocg->lock);
>  	rcu_assign_pointer(iog->key, key);
>  	hlist_add_head_rcu(&iog->group_node, &iocg->group_data);
> -	iog->iocg_id = css_id(&iocg->css);
> +	iog->iocg = iocg;
>  	spin_unlock_irq(&iocg->lock);
>  
>  #ifdef CONFIG_DEBUG_GROUP_IOSCHED
> @@ -2397,7 +2390,7 @@ remove_entry:
>  			  group_node);
>  	efqd = rcu_dereference(iog->key);
>  	hlist_del_rcu(&iog->group_node);
> -	iog->iocg_id = 0;
> +	iog->iocg = NULL;
>  	spin_unlock_irqrestore(&iocg->lock, flags);
>  
>  	spin_lock_irqsave(efqd->queue->queue_lock, flags);
> @@ -2411,7 +2404,6 @@ done:
>  		kfree(pn);
>  	}
>  
> -	free_css_id(&io_subsys, &iocg->css);
>  	rcu_read_unlock();
>  	BUG_ON(!hlist_empty(&iocg->group_data));
>  	kfree(iocg);
> @@ -2427,20 +2419,16 @@ static void io_group_check_and_destroy(struct elv_fq_data *efqd,
>  {
>  	struct io_cgroup *iocg;
>  	unsigned long flags;
> -	struct cgroup_subsys_state *css;
>  
>  	rcu_read_lock();
>  
> -	css = css_lookup(&io_subsys, iog->iocg_id);
> -
> -	if (!css)
> +	iocg = iog->iocg;
> +	if (!iocg)
>  		goto out;
>  
> -	iocg = container_of(css, struct io_cgroup, css);
> -
>  	spin_lock_irqsave(&iocg->lock, flags);
>  
> -	if (iog->iocg_id) {
> +	if (iog->iocg) {
>  		hlist_del_rcu(&iog->group_node);
>  		__io_destroy_group(efqd, iog);
>  	}
> diff --git a/block/elevator-fq.h b/block/elevator-fq.h
> index f089a55..75fee82 100644
> --- a/block/elevator-fq.h
> +++ b/block/elevator-fq.h
> @@ -251,7 +251,7 @@ struct io_group {
>  	unsigned int busy_rt_queues;
>  
>  	int deleting;
> -	unsigned short iocg_id;
> +	struct io_cgroup *iocg;
>  
>  	/* The device MKDEV(major, minor), this group has been created for */
>  	dev_t	dev;
> -- 
> 1.5.4.rc3 
> 
