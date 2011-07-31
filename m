From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH 2/4] limit nr_dentries per superblock
Date: Sun, 31 Jul 2011 11:15:31 +1000
Message-ID: <20110731011531.GL5404__23233.9710150429$1312075061$gmane$org@dastard>
References: <1311947059-17209-1-git-send-email-glommer@parallels.com>
	<1311947059-17209-3-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1311947059-17209-3-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jul 29, 2011 at 05:44:17PM +0400, Glauber Costa wrote:
> This patch lays the foundation for us to limit the dcache size.
> Each super block can have only a maximum amount of dentries under its
> sub-tree. Allocation fails if we we're over limit and the cache
> can't be pruned to free up space for the newcomers.
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> CC: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
> ---
>  fs/dcache.c        |   45 +++++++++++++++++++++++++++++++++++++--------
>  fs/super.c         |    1 +
>  include/linux/fs.h |    1 +
>  3 files changed, 39 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 9cb6395..3bdb106 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -663,7 +663,7 @@ EXPORT_SYMBOL(d_prune_aliases);
>   *
>   * This may fail if locks cannot be acquired no problem, just try again.
>   */
> -static void try_prune_one_dentry(struct dentry *dentry)
> +static int try_prune_one_dentry(struct dentry *dentry)
>  	__releases(dentry->d_lock)
>  {
>  	struct dentry *parent;

Comment explaining the return value?

[...]
> @@ -740,7 +744,7 @@ static void shrink_dentry_list(struct list_head *list)
>   *
>   * If flags contains DCACHE_REFERENCED reference dentries will not be pruned.
>   */
> -static void __shrink_dcache_sb(struct super_block *sb, int count, int flags)
> +static int __shrink_dcache_sb(struct super_block *sb, int count, int flags)
>  {
>  	struct dentry *dentry;
>  	LIST_HEAD(referenced);

What's the new return value do?

> @@ -781,7 +785,7 @@ relock:
>  		list_splice(&referenced, &sb->s_dentry_lru);
>  	spin_unlock(&dcache_lru_lock);
>  
> -	shrink_dentry_list(&tmp);
> +	return shrink_dentry_list(&tmp);
>  }
>  
>  /**
> @@ -1176,6 +1180,28 @@ void shrink_dcache_parent(struct dentry * parent)
>  }
>  EXPORT_SYMBOL(shrink_dcache_parent);
>  
> +static int dcache_mem_check(struct super_block *sb)
> +{
> +	int nr_dentry;
> +	int count;
> +
> +	if (percpu_counter_read_positive(&sb->s_nr_dentry) <=
> +						sb->s_nr_dentry_max)
> +		return 0;
> +
> +	do {
> +		nr_dentry = percpu_counter_sum_positive(&sb->s_nr_dentry);
> +
> +		if (nr_dentry < sb->s_nr_dentry_max)
> +			return 0;
> +
> +		count = (nr_dentry - sb->s_nr_dentry_max) << 1;
> +
> +	} while (__shrink_dcache_sb(sb, count, DCACHE_REFERENCED) > 0);
> +
> +	return -ENOMEM;
> +}


I don't like the idea of trying to be exact on how many we shrink.
percpu_counter_read_positive() will always have an error in it:
+/-(N cpus * 31) by default. Statistically speaking 50% of the cases
it passes will then get rejected on the expensive sum operation. And
then we shrink only 2x the difference between the counter and the
max value, which will leave it inside the error margin of the
counter anyway. Hence once we hit the threshold, we'll continually
take expensive sum operations, many for no reason.  There needs to
be some hysteresis here to avoid simply hammering the percpu counter
on every single __d_alloc call. Perhaps per-cpu counters are not
suited for this purpose?

Indeed, what happens if one caller saw the read and sum over the
limit, then starts shrinking but other callers don't see the read
over the limit but keep allocating dentries and hence keeping the
shrinking caller's sum over the limit and hence forever shrinking?
That seems like a unprivileged random process DOS, yes?

So at minimum, the loop should not recalculate how much to shrink -
calculate the amount to shrink, the run a loop to shrink that much
and only that much. If there are other concurrent callers, then
they'll also do a shrink, but nothing will get stuck in a loop.

Hmmm, what happens when the size of the cache and/or the max value
are less than the error margin of the counter?

Also, this doesn't address the problem I originally commented on -
it only shrinks the dcache, not the inode or filesystem caches that
hold all the memory.  I mentioned the new per-sb shrinkers for a
reason - you should be calling them, not __shrink_dcache_sb(). i.e.
building a scan_control structure and calling
sb->shrinker.shrink(&sb->shrinker, &sc);

I'm seriously starting to think that this needs to share an
implementation with the mm shrinker code, because it already
solves most of these problems...

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
