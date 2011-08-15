From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH v3 3/4] limit nr_dentries per superblock
Date: Mon, 15 Aug 2011 17:03:51 +1000
Message-ID: <20110815070350.GE26978__48241.0046541647$1313391870$gmane$org@dastard>
References: <1313334832-1150-1-git-send-email-glommer@parallels.com>
	<1313334832-1150-4-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1313334832-1150-4-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Aug 14, 2011 at 07:13:51PM +0400, Glauber Costa wrote:
> This patch lays the foundation for us to limit the dcache size.
> Each super block can have only a maximum amount of dentries under its
> sub-tree. Allocation fails if we we're over limit and the cache
> can't be pruned to free up space for the newcomers.
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> CC: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
> CC: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  fs/dcache.c        |   28 ++++++++++++++++++++++++++++
>  fs/super.c         |    1 +
>  include/linux/fs.h |    1 +
>  3 files changed, 30 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 815d9fd..ddd02a2 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1180,6 +1180,31 @@ void shrink_dcache_parent(struct dentry * parent)
>  }
>  EXPORT_SYMBOL(shrink_dcache_parent);
>  
> +static inline int dcache_mem_check(struct super_block *sb)
> +{
> +	struct shrink_control sc = {
> +		.gfp_mask = GFP_KERNEL,
> +	};
> +
> +	if (sb->s_nr_dentry_max == INT_MAX)
> +		return 0;
> +
> +	do {
> +		int nr_dentry;
> +
> +		nr_dentry = percpu_counter_read_positive(&sb->s_nr_dentry);
> +		if (nr_dentry > sb->s_nr_dentry_max)
> +			nr_dentry =
> +				percpu_counter_sum_positive(&sb->s_nr_dentry);
> +		if (nr_dentry < sb->s_nr_dentry_max)
> +			return 0;
> +
> +	/* nr_pages = 1, lru_pages = 0 should get delta ~ 2 */
> +	} while (shrink_one_shrinker(&sb->s_shrink, &sc, 1, 0));
> +
> +	return -ENOMEM;
> +}

The changes here don't address the comments I made previously about
the error range of the per-cpu counter and update frequency of the
the global counter. w.r.t to small delta changes of the counted
amount.

That is, you cannot expect percpu_counter_read_positive() to change
when you decrement a counter by 2 counts (assuming both objects are
freed), and there's no guarantee that percpu_counter_sum_positive()
will drop below the threshold either while
percpu_counter_read_positive() is returning numbers above the
threshold. That makes this a very expensive and oft-repeated loop.

Indeed, that even assumes that 2 objects that are freed are
dentries. If there are more inodes that dentries in memory, the the
dentries won't even be trimmed, and you'll get stuck in the horribly
expensive loop trimming the cache 2 inodes at a time until the
caches start to balance. Shrinking must be done in large batches to
be effective, not one object at a time.

Further, the shrinker may not make progress freeing items, which
will result in this code returning ENOMEM when the shrinker may
simply have been passing over referenced (i.e. cache hot) dentries.
That will return spurious ENOMEM results back to d_alloc, resulting
in spurious failures that will be impossible to track down...

This also demonstrates my comment about where you factored
shrink_one_shrinker() to be the wrong place. You've already got a
shrink-control structure, so adding a value to .nr_to_scan to the
initialisation gets around the entire need to do all that guess work
of running through the vmscan specific algorithms to get 2 objects
freed.

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
