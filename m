From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/10] blkcg: __blkg_lookup_create() doesn't need radix
	preload
Date: Mon, 4 Jun 2012 14:57:02 -0400
Message-ID: <20120604185702.GK4458@redhat.com>
References: <1338793697-10735-1-git-send-email-tj@kernel.org>
	<1338793697-10735-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1338793697-10735-2-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jun 04, 2012 at 12:08:08AM -0700, Tejun Heo wrote:
> There's no point in calling radix_tree_preload() if preloading doesn't
> use more permissible GFP mask.  Drop preloading from
> __blkg_lookup_create().
> 
> While at it, drop sparse locking annotation which no longer applies.
> 
> v2: Vivek pointed out the odd preload usage.  Instead of updating,
>     just drop it.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Looks good to me.

Acked-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Vivek

> ---
>  block/blk-cgroup.c |   10 +---------
>  1 files changed, 1 insertions(+), 9 deletions(-)
> 
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index 4ab7420..af61db0 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -177,7 +177,6 @@ EXPORT_SYMBOL_GPL(blkg_lookup);
>  
>  static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
>  					     struct request_queue *q)
> -	__releases(q->queue_lock) __acquires(q->queue_lock)
>  {
>  	struct blkcg_gq *blkg;
>  	int ret;
> @@ -203,10 +202,6 @@ static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
>  		goto err_put;
>  
>  	/* insert */
> -	ret = radix_tree_preload(GFP_ATOMIC);
> -	if (ret)
> -		goto err_free;
> -
>  	spin_lock(&blkcg->lock);
>  	ret = radix_tree_insert(&blkcg->blkg_tree, q->id, blkg);
>  	if (likely(!ret)) {
> @@ -215,14 +210,11 @@ static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
>  	}
>  	spin_unlock(&blkcg->lock);
>  
> -	radix_tree_preload_end();
> -
>  	if (!ret)
>  		return blkg;
> -err_free:
> -	blkg_free(blkg);
>  err_put:
>  	css_put(&blkcg->css);
> +	blkg_free(blkg);
>  	return ERR_PTR(ret);
>  }
>  
> -- 
> 1.7.7.3
