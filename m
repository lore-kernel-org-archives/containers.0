From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 20/24] block: RCU free request_queue
Date: Tue, 8 Jan 2013 13:05:18 -0500
Message-ID: <20130108180517.GB29933__38411.6804729731$1357668350$gmane$org@redhat.com>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
	<1356726946-26037-21-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1356726946-26037-21-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Dec 28, 2012 at 12:35:42PM -0800, Tejun Heo wrote:
> RCU free request_queue so that blkcg_gq->q can be dereferenced under
> RCU lock.  This will be used to implement hierarchical stats.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Acked-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Vivek

> ---
>  block/blk-sysfs.c      | 9 ++++++++-
>  include/linux/blkdev.h | 2 ++
>  2 files changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
> index 7881477..6206a93 100644
> --- a/block/blk-sysfs.c
> +++ b/block/blk-sysfs.c
> @@ -497,6 +497,13 @@ queue_attr_store(struct kobject *kobj, struct attribute *attr,
>  	return res;
>  }
>  
> +static void blk_free_queue_rcu(struct rcu_head *rcu_head)
> +{
> +	struct request_queue *q = container_of(rcu_head, struct request_queue,
> +					       rcu_head);
> +	kmem_cache_free(blk_requestq_cachep, q);
> +}
> +
>  /**
>   * blk_release_queue: - release a &struct request_queue when it is no longer needed
>   * @kobj:    the kobj belonging to the request queue to be released
> @@ -538,7 +545,7 @@ static void blk_release_queue(struct kobject *kobj)
>  	bdi_destroy(&q->backing_dev_info);
>  
>  	ida_simple_remove(&blk_queue_ida, q->id);
> -	kmem_cache_free(blk_requestq_cachep, q);
> +	call_rcu(&q->rcu_head, blk_free_queue_rcu);
>  }
>  
>  static const struct sysfs_ops queue_sysfs_ops = {
> diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
> index f94bc83..406343c 100644
> --- a/include/linux/blkdev.h
> +++ b/include/linux/blkdev.h
> @@ -19,6 +19,7 @@
>  #include <linux/gfp.h>
>  #include <linux/bsg.h>
>  #include <linux/smp.h>
> +#include <linux/rcupdate.h>
>  
>  #include <asm/scatterlist.h>
>  
> @@ -437,6 +438,7 @@ struct request_queue {
>  	/* Throttle data */
>  	struct throtl_data *td;
>  #endif
> +	struct rcu_head		rcu_head;
>  };
>  
>  #define QUEUE_FLAG_QUEUED	1	/* uses generic tag queueing */
> -- 
> 1.8.0.2
