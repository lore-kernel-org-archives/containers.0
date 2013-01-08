From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 24/24] cfq-iosched: add hierarchical cfq_group statistics
Date: Tue, 8 Jan 2013 13:27:50 -0500
Message-ID: <20130108182750.GF29933__11277.4758403704$1357669703$gmane$org@redhat.com>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
	<1356726946-26037-25-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1356726946-26037-25-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On Fri, Dec 28, 2012 at 12:35:46PM -0800, Tejun Heo wrote:
> Unfortunately, at this point, there's no way to make the existing
> statistics hierarchical without creating nasty surprises for the
> existing users.  Just create recursive counterpart of the existing
> stats.
> 

No recursive counterparts for stats under DEBUG? Well, I would not 
complain. There are too many stats already and if somebody needs
recursive stats for debug stats, let them do it.

Acked-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Vivek

> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>  block/cfq-iosched.c | 105 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 105 insertions(+)
> 
> diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
> index 4d75b79..b66365b 100644
> --- a/block/cfq-iosched.c
> +++ b/block/cfq-iosched.c
> @@ -1528,6 +1528,32 @@ static void cfq_pd_offline(struct blkcg_gq *blkg)
>  	cfqg_stats_xfer_dead(blkg_to_cfqg(blkg));
>  }
>  
> +/* offset delta from cfqg->stats to cfqg->dead_stats */
> +static const int dead_stats_off_delta = offsetof(struct cfq_group, dead_stats) -
> +					offsetof(struct cfq_group, stats);
> +
> +/* to be used by recursive prfill, sums live and dead stats recursively */
> +static u64 cfqg_stat_pd_recursive_sum(struct blkg_policy_data *pd, int off)
> +{
> +	u64 sum = 0;
> +
> +	sum += blkg_stat_recursive_sum(pd, off);
> +	sum += blkg_stat_recursive_sum(pd, off + dead_stats_off_delta);
> +	return sum;
> +}
> +
> +/* to be used by recursive prfill, sums live and dead rwstats recursively */
> +static struct blkg_rwstat cfqg_rwstat_pd_recursive_sum(struct blkg_policy_data *pd,
> +						       int off)
> +{
> +	struct blkg_rwstat a, b;
> +
> +	a = blkg_rwstat_recursive_sum(pd, off);
> +	b = blkg_rwstat_recursive_sum(pd, off + dead_stats_off_delta);
> +	blkg_rwstat_merge(&a, &b);
> +	return a;
> +}
> +
>  static void cfq_pd_reset_stats(struct blkcg_gq *blkg)
>  {
>  	struct cfq_group *cfqg = blkg_to_cfqg(blkg);
> @@ -1732,6 +1758,42 @@ static int cfqg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
>  	return 0;
>  }
>  
> +static u64 cfqg_prfill_stat_recursive(struct seq_file *sf,
> +				      struct blkg_policy_data *pd, int off)
> +{
> +	u64 sum = cfqg_stat_pd_recursive_sum(pd, off);
> +
> +	return __blkg_prfill_u64(sf, pd, sum);
> +}
> +
> +static u64 cfqg_prfill_rwstat_recursive(struct seq_file *sf,
> +					struct blkg_policy_data *pd, int off)
> +{
> +	struct blkg_rwstat sum = cfqg_rwstat_pd_recursive_sum(pd, off);
> +
> +	return __blkg_prfill_rwstat(sf, pd, &sum);
> +}
> +
> +static int cfqg_print_stat_recursive(struct cgroup *cgrp, struct cftype *cft,
> +				     struct seq_file *sf)
> +{
> +	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
> +
> +	blkcg_print_blkgs(sf, blkcg, cfqg_prfill_stat_recursive,
> +			  &blkcg_policy_cfq, cft->private, false);
> +	return 0;
> +}
> +
> +static int cfqg_print_rwstat_recursive(struct cgroup *cgrp, struct cftype *cft,
> +				       struct seq_file *sf)
> +{
> +	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
> +
> +	blkcg_print_blkgs(sf, blkcg, cfqg_prfill_rwstat_recursive,
> +			  &blkcg_policy_cfq, cft->private, true);
> +	return 0;
> +}
> +
>  #ifdef CONFIG_DEBUG_BLK_CGROUP
>  static u64 cfqg_prfill_avg_queue_size(struct seq_file *sf,
>  				      struct blkg_policy_data *pd, int off)
> @@ -1803,6 +1865,7 @@ static struct cftype cfq_blkcg_files[] = {
>  		.write_u64 = cfq_set_leaf_weight,
>  	},
>  
> +	/* statistics, covers only the tasks in the cfqg */
>  	{
>  		.name = "time",
>  		.private = offsetof(struct cfq_group, stats.time),
> @@ -1843,6 +1906,48 @@ static struct cftype cfq_blkcg_files[] = {
>  		.private = offsetof(struct cfq_group, stats.queued),
>  		.read_seq_string = cfqg_print_rwstat,
>  	},
> +
> +	/* the same statictics which cover the cfqg and its descendants */
> +	{
> +		.name = "time_recursive",
> +		.private = offsetof(struct cfq_group, stats.time),
> +		.read_seq_string = cfqg_print_stat_recursive,
> +	},
> +	{
> +		.name = "sectors_recursive",
> +		.private = offsetof(struct cfq_group, stats.sectors),
> +		.read_seq_string = cfqg_print_stat_recursive,
> +	},
> +	{
> +		.name = "io_service_bytes_recursive",
> +		.private = offsetof(struct cfq_group, stats.service_bytes),
> +		.read_seq_string = cfqg_print_rwstat_recursive,
> +	},
> +	{
> +		.name = "io_serviced_recursive",
> +		.private = offsetof(struct cfq_group, stats.serviced),
> +		.read_seq_string = cfqg_print_rwstat_recursive,
> +	},
> +	{
> +		.name = "io_service_time_recursive",
> +		.private = offsetof(struct cfq_group, stats.service_time),
> +		.read_seq_string = cfqg_print_rwstat_recursive,
> +	},
> +	{
> +		.name = "io_wait_time_recursive",
> +		.private = offsetof(struct cfq_group, stats.wait_time),
> +		.read_seq_string = cfqg_print_rwstat_recursive,
> +	},
> +	{
> +		.name = "io_merged_recursive",
> +		.private = offsetof(struct cfq_group, stats.merged),
> +		.read_seq_string = cfqg_print_rwstat_recursive,
> +	},
> +	{
> +		.name = "io_queued_recursive",
> +		.private = offsetof(struct cfq_group, stats.queued),
> +		.read_seq_string = cfqg_print_rwstat_recursive,
> +	},
>  #ifdef CONFIG_DEBUG_BLK_CGROUP
>  	{
>  		.name = "avg_queue_size",
> -- 
> 1.8.0.2
