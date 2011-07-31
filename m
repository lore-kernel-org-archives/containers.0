From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH 1/4] Keep nr_dentry per super block
Date: Sun, 31 Jul 2011 10:50:46 +1000
Message-ID: <20110731005046.GK5404__10761.3025502816$1312073590$gmane$org@dastard>
References: <1311947059-17209-1-git-send-email-glommer@parallels.com>
	<1311947059-17209-2-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1311947059-17209-2-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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

On Fri, Jul 29, 2011 at 05:44:16PM +0400, Glauber Costa wrote:
> Now that we have per-sb shrinkers, it makes sense to have nr_dentries
> stored per sb as well. We turn them into per-cpu counters so we can
> keep acessing them without locking.

Comments below.

> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> CC: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
> ---
>  fs/dcache.c        |   18 ++++++++++--------
>  fs/super.c         |    2 ++
>  include/linux/fs.h |    2 ++
>  3 files changed, 14 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index b05aac3..9cb6395 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -115,16 +115,18 @@ struct dentry_stat_t dentry_stat = {
>  	.age_limit = 45,
>  };
>  
> -static DEFINE_PER_CPU(unsigned int, nr_dentry);
> -
>  #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
> +static void super_nr_dentry(struct super_block *sb, void *arg)
> +{
> +	int *dentries = arg;
> +	*dentries += percpu_counter_sum_positive(&sb->s_nr_dentry);
> +}
> +
>  static int get_nr_dentry(void)
>  {
> -	int i;
>  	int sum = 0;
> -	for_each_possible_cpu(i)
> -		sum += per_cpu(nr_dentry, i);
> -	return sum < 0 ? 0 : sum;
> +	iterate_supers(super_nr_dentry, &sum);
> +	return sum;
>  }

That is rather expensive for large CPU count machines. Think of what
happens now when someone now reads nr_dentrys on a 4096 CPU machine
with a couple of hundred active superblocks.

If you are going to use the struct percpu_counter (see below,
however), then we coul dprobably just get away with a
percpu_counter_read_positive() call as this summation is used only
by /proc readers.

However, I'd suggest that you just leave the existing global counter
alone - it has very little overhead and avoids the need for per-sb,
per-cpu iteration explosions.

>  int proc_nr_dentry(ctl_table *table, int write, void __user *buffer,
> @@ -151,7 +153,7 @@ static void __d_free(struct rcu_head *head)
>  static void d_free(struct dentry *dentry)
>  {
>  	BUG_ON(dentry->d_count);
> -	this_cpu_dec(nr_dentry);
> +	percpu_counter_dec(&dentry->d_sb->s_nr_dentry);
>  	if (dentry->d_op && dentry->d_op->d_release)
>  		dentry->d_op->d_release(dentry);
>  
> @@ -1225,7 +1227,7 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
>  	INIT_LIST_HEAD(&dentry->d_u.d_child);
>  	d_set_d_op(dentry, dentry->d_sb->s_d_op);
>  
> -	this_cpu_inc(nr_dentry);
> +	percpu_counter_inc(&dentry->d_sb->s_nr_dentry);
>  
>  	return dentry;
>  }
> diff --git a/fs/super.c b/fs/super.c
> index 3f56a26..b16d8e8 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -183,6 +183,8 @@ static struct super_block *alloc_super(struct file_system_type *type)
>  		s->s_shrink.seeks = DEFAULT_SEEKS;
>  		s->s_shrink.shrink = prune_super;
>  		s->s_shrink.batch = 1024;
> +
> +		percpu_counter_init(&s->s_nr_dentry, 0);
>  	}
>  out:
>  	return s;
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index f23bcb7..8150f52 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1399,6 +1399,8 @@ struct super_block {
>  	struct list_head	s_dentry_lru;	/* unused dentry lru */
>  	int			s_nr_dentry_unused;	/* # of dentry on lru */
>  
> +	struct percpu_counter 	s_nr_dentry;		/* # of dentry on this sb */
> +

I got well and truly beaten down for trying to use struct
percpu_counter counters in the inode and dentry cache because "they
have way too much overhead for fast path operations" compared to
this_cpu_inc() and this_cpu_dec(). That requires more work to set
up, though, for embedded structures like this (i.e. needs it's own
initialisation via alloc_percpu(), IIRC), but should result in an
implementation with no additional overhead.

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
