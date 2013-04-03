From: Sha Zhengju <handai.szj-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 05/28] dcache: remove dentries from LRU before putting
	on dispose list
Date: Wed, 3 Apr 2013 14:51:43 +0800
Message-ID: <CAFj3OHU_o5o_n_kcci1U_=M0tCpYEwy8abRvHKBdp-GoJ-cs3w@mail.gmail.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-6-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1364548450-28254-6-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 29, 2013 at 5:13 PM, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>wrote:

> From: Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>
> One of the big problems with modifying the way the dcache shrinker
> and LRU implementation works is that the LRU is abused in several
> ways. One of these is shrink_dentry_list().
>
> Basically, we can move a dentry off the LRU onto a different list
> without doing any accounting changes, and then use dentry_lru_prune()
> to remove it from what-ever list it is now on to do the LRU
> accounting at that point.
>
> This makes it -really hard- to change the LRU implementation. The
> use of the per-sb LRU lock serialises movement of the dentries
> between the different lists and the removal of them, and this is the
> only reason that it works. If we want to break up the dentry LRU
> lock and lists into, say, per-node lists, we remove the only
> serialisation that allows this lru list/dispose list abuse to work.
>
> To make this work effectively, the dispose list has to be isolated
> from the LRU list - dentries have to be removed from the LRU
> *before* being placed on the dispose list. This means that the LRU
> accounting and isolation is completed before disposal is started,
> and that means we can change the LRU implementation freely in
> future.
>
> This means that dentries *must* be marked with DCACHE_SHRINK_LIST
> when they are placed on the dispose list so that we don't think that
> parent dentries found in try_prune_one_dentry() are on the LRU when
> the are actually on the dispose list. This would result in
> accounting the dentry to the LRU a second time. Hence
> dentry_lru_prune() has to handle the DCACHE_SHRINK_LIST case
> differently because the dentry isn't on the LRU list.
>
> Signed-off-by: Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  fs/dcache.c | 73
> ++++++++++++++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 63 insertions(+), 10 deletions(-)
>
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 0a1d7b3..d15420b 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -330,7 +330,6 @@ static void dentry_lru_add(struct dentry *dentry)
>  static void __dentry_lru_del(struct dentry *dentry)
>  {
>         list_del_init(&dentry->d_lru);
> -       dentry->d_flags &= ~DCACHE_SHRINK_LIST;
>         dentry->d_sb->s_nr_dentry_unused--;
>         this_cpu_dec(nr_dentry_unused);
>  }
> @@ -340,6 +339,8 @@ static void __dentry_lru_del(struct dentry *dentry)
>   */
>  static void dentry_lru_del(struct dentry *dentry)
>  {
> +       BUG_ON(dentry->d_flags & DCACHE_SHRINK_LIST);
> +
>         if (!list_empty(&dentry->d_lru)) {
>                 spin_lock(&dentry->d_sb->s_dentry_lru_lock);
>                 __dentry_lru_del(dentry);
> @@ -351,28 +352,42 @@ static void dentry_lru_del(struct dentry *dentry)
>   * Remove a dentry that is unreferenced and about to be pruned
>   * (unhashed and destroyed) from the LRU, and inform the file system.
>   * This wrapper should be called _prior_ to unhashing a victim dentry.
> + *
> + * Check that the dentry really is on the LRU as it may be on a private
> dispose
> + * list and in that case we do not want to call the generic LRU removal
> + * functions. This typically happens when shrink_dcache_sb() clears the
> LRU in
> + * one go and then try_prune_one_dentry() walks back up the parent chain
> finding
> + * dentries that are also on the dispose list.
>   */
>  static void dentry_lru_prune(struct dentry *dentry)
>  {
>         if (!list_empty(&dentry->d_lru)) {
> +
>                 if (dentry->d_flags & DCACHE_OP_PRUNE)
>                         dentry->d_op->d_prune(dentry);
>
> -               spin_lock(&dentry->d_sb->s_dentry_lru_lock);
> -               __dentry_lru_del(dentry);
> -               spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
> +               if ((dentry->d_flags & DCACHE_SHRINK_LIST))
> +                       list_del_init(&dentry->d_lru);
> +               else {
> +                       spin_lock(&dentry->d_sb->s_dentry_lru_lock);
> +                       __dentry_lru_del(dentry);
> +                       spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
> +               }
> +               dentry->d_flags &= ~DCACHE_SHRINK_LIST;
>         }
>  }
>
>  static void dentry_lru_move_list(struct dentry *dentry, struct list_head
> *list)
>  {
> +       BUG_ON(dentry->d_flags & DCACHE_SHRINK_LIST);
> +
>         spin_lock(&dentry->d_sb->s_dentry_lru_lock);
>         if (list_empty(&dentry->d_lru)) {
>                 list_add_tail(&dentry->d_lru, list);
> -               dentry->d_sb->s_nr_dentry_unused++;
> -               this_cpu_inc(nr_dentry_unused);
>         } else {
>                 list_move_tail(&dentry->d_lru, list);
> +               dentry->d_sb->s_nr_dentry_unused--;
> +               this_cpu_dec(nr_dentry_unused);
>         }
>         spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
>  }
> @@ -814,12 +829,18 @@ static void shrink_dentry_list(struct list_head
> *list)
>                 }
>
>                 /*
> +                * The dispose list is isolated and dentries are not
> accounted
> +                * to the LRU here, so we can simply remove it from the
> list
> +                * here regardless of whether it is referenced or not.
> +                */
> +               list_del_init(&dentry->d_lru);
> +
> +               /*
>                  * We found an inuse dentry which was not removed from
> -                * the LRU because of laziness during lookup.  Do not free
> -                * it - just keep it off the LRU list.
> +                * the LRU because of laziness during lookup. Do not free
> it.
>                  */
>                 if (dentry->d_count) {
> -                       dentry_lru_del(dentry);
> +                       dentry->d_flags &= ~DCACHE_SHRINK_LIST;
>                         spin_unlock(&dentry->d_lock);
>                         continue;
>                 }
> @@ -871,6 +892,8 @@ relock:
>                 } else {
>                         list_move_tail(&dentry->d_lru, &tmp);
>                         dentry->d_flags |= DCACHE_SHRINK_LIST;
> +                       this_cpu_dec(nr_dentry_unused);
> +                       sb->s_nr_dentry_unused--;
>                         spin_unlock(&dentry->d_lock);
>                         if (!--count)
>                                 break;
> @@ -884,6 +907,28 @@ relock:
>         shrink_dentry_list(&tmp);
>  }
>
> +/*
> + * Mark all the dentries as on being the dispose list so we don't think
> they are
> + * still on the LRU if we try to kill them from ascending the parent
> chain in
> + * try_prune_one_dentry() rather than directly from the dispose list.
> + */
> +static void
> +shrink_dcache_list(
> +       struct list_head *dispose)
> +{
> +       struct dentry *dentry;
> +
> +       rcu_read_lock();
> +       list_for_each_entry_rcu(dentry, dispose, d_lru) {
> +               spin_lock(&dentry->d_lock);
> +               dentry->d_flags |= DCACHE_SHRINK_LIST;
> +               this_cpu_dec(nr_dentry_unused);
>

Why here dec nr_dentry_unused again? Has it been decreased in the following
shrink_dcache_sb()?



> +               spin_unlock(&dentry->d_lock);
> +       }
> +       rcu_read_unlock();
> +       shrink_dentry_list(dispose);
> +}
> +
>  /**
>   * shrink_dcache_sb - shrink dcache for a superblock
>   * @sb: superblock
> @@ -898,8 +943,16 @@ void shrink_dcache_sb(struct super_block *sb)
>         spin_lock(&sb->s_dentry_lru_lock);
>         while (!list_empty(&sb->s_dentry_lru)) {
>                 list_splice_init(&sb->s_dentry_lru, &tmp);
> +
> +               /*
> +                * account for removal here so we don't need to handle it
> later
> +                * even though the dentry is no longer on the lru list.
> +                */
> +               this_cpu_sub(nr_dentry_unused, sb->s_nr_dentry_unused);
> +               sb->s_nr_dentry_unused = 0;
> +
>                 spin_unlock(&sb->s_dentry_lru_lock);
> -               shrink_dentry_list(&tmp);
> +               shrink_dcache_list(&tmp);
>                 spin_lock(&sb->s_dentry_lru_lock);
>         }
>         spin_unlock(&sb->s_dentry_lru_lock);
>
>

-- 
Thanks,
Sha
