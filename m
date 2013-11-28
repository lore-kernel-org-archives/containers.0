From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 11/12] cgroup: replace cftype->read_seq_string() with
	cftype->seq_show()
Date: Thu, 28 Nov 2013 12:25:00 +0100
Message-ID: <20131128112500.GH2761@dhcp22.suse.cz>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
	<1385595759-17656-12-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1385595759-17656-12-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed 27-11-13 18:42:38, Tejun Heo wrote:
> In preparation of conversion to kernfs, cgroup file handling is
> updated so that it can be easily mapped to kernfs.  This patch
> replaces cftype->read_seq_string() with cftype->seq_show() which is
> not limited to single_open() operation and will map directcly to
> kernfs seq_file interface.
> 
> The conversions are mechanical.  As ->seq_show() doesn't have @css and
> @cft, the functions which make use of them are converted to use
> seq_css() and seq_cft() respectively.  In several occassions, e.f. if
> it has seq_string in its name, the function name is updated to fit the
> new method better.
> 
> This patch does not introduce any behavior changes.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
> Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> Cc: Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Looks good to me. For memcg part
Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

Thanks!

> ---
>  block/blk-throttle.c      |  35 ++++++-------
>  block/cfq-iosched.c       | 131 ++++++++++++++++++++--------------------------
>  include/linux/cgroup.h    |   9 ++--
>  kernel/cgroup.c           |  34 ++++++------
>  kernel/cgroup_freezer.c   |   7 ++-
>  kernel/cpuset.c           |  12 ++---
>  kernel/sched/core.c       |   7 ++-
>  kernel/sched/cpuacct.c    |  14 +++--
>  mm/memcontrol.c           |  28 +++++-----
>  net/core/netprio_cgroup.c |   8 +--
>  security/device_cgroup.c  |   7 ++-
>  11 files changed, 128 insertions(+), 164 deletions(-)
> 
> diff --git a/block/blk-throttle.c b/block/blk-throttle.c
> index 0653404..a760857 100644
> --- a/block/blk-throttle.c
> +++ b/block/blk-throttle.c
> @@ -1303,13 +1303,10 @@ static u64 tg_prfill_cpu_rwstat(struct seq_file *sf,
>  	return __blkg_prfill_rwstat(sf, pd, &rwstat);
>  }
>  
> -static int tg_print_cpu_rwstat(struct cgroup_subsys_state *css,
> -			       struct cftype *cft, struct seq_file *sf)
> +static int tg_print_cpu_rwstat(struct seq_file *sf, void *v)
>  {
> -	struct blkcg *blkcg = css_to_blkcg(css);
> -
> -	blkcg_print_blkgs(sf, blkcg, tg_prfill_cpu_rwstat, &blkcg_policy_throtl,
> -			  cft->private, true);
> +	blkcg_print_blkgs(sf, css_to_blkcg(seq_css(sf)), tg_prfill_cpu_rwstat,
> +			  &blkcg_policy_throtl, seq_cft(sf)->private, true);
>  	return 0;
>  }
>  
> @@ -1335,19 +1332,17 @@ static u64 tg_prfill_conf_uint(struct seq_file *sf, struct blkg_policy_data *pd,
>  	return __blkg_prfill_u64(sf, pd, v);
>  }
>  
> -static int tg_print_conf_u64(struct cgroup_subsys_state *css,
> -			     struct cftype *cft, struct seq_file *sf)
> +static int tg_print_conf_u64(struct seq_file *sf, void *v)
>  {
> -	blkcg_print_blkgs(sf, css_to_blkcg(css), tg_prfill_conf_u64,
> -			  &blkcg_policy_throtl, cft->private, false);
> +	blkcg_print_blkgs(sf, css_to_blkcg(seq_css(sf)), tg_prfill_conf_u64,
> +			  &blkcg_policy_throtl, seq_cft(sf)->private, false);
>  	return 0;
>  }
>  
> -static int tg_print_conf_uint(struct cgroup_subsys_state *css,
> -			      struct cftype *cft, struct seq_file *sf)
> +static int tg_print_conf_uint(struct seq_file *sf, void *v)
>  {
> -	blkcg_print_blkgs(sf, css_to_blkcg(css), tg_prfill_conf_uint,
> -			  &blkcg_policy_throtl, cft->private, false);
> +	blkcg_print_blkgs(sf, css_to_blkcg(seq_css(sf)), tg_prfill_conf_uint,
> +			  &blkcg_policy_throtl, seq_cft(sf)->private, false);
>  	return 0;
>  }
>  
> @@ -1428,40 +1423,40 @@ static struct cftype throtl_files[] = {
>  	{
>  		.name = "throttle.read_bps_device",
>  		.private = offsetof(struct throtl_grp, bps[READ]),
> -		.read_seq_string = tg_print_conf_u64,
> +		.seq_show = tg_print_conf_u64,
>  		.write_string = tg_set_conf_u64,
>  		.max_write_len = 256,
>  	},
>  	{
>  		.name = "throttle.write_bps_device",
>  		.private = offsetof(struct throtl_grp, bps[WRITE]),
> -		.read_seq_string = tg_print_conf_u64,
> +		.seq_show = tg_print_conf_u64,
>  		.write_string = tg_set_conf_u64,
>  		.max_write_len = 256,
>  	},
>  	{
>  		.name = "throttle.read_iops_device",
>  		.private = offsetof(struct throtl_grp, iops[READ]),
> -		.read_seq_string = tg_print_conf_uint,
> +		.seq_show = tg_print_conf_uint,
>  		.write_string = tg_set_conf_uint,
>  		.max_write_len = 256,
>  	},
>  	{
>  		.name = "throttle.write_iops_device",
>  		.private = offsetof(struct throtl_grp, iops[WRITE]),
> -		.read_seq_string = tg_print_conf_uint,
> +		.seq_show = tg_print_conf_uint,
>  		.write_string = tg_set_conf_uint,
>  		.max_write_len = 256,
>  	},
>  	{
>  		.name = "throttle.io_service_bytes",
>  		.private = offsetof(struct tg_stats_cpu, service_bytes),
> -		.read_seq_string = tg_print_cpu_rwstat,
> +		.seq_show = tg_print_cpu_rwstat,
>  	},
>  	{
>  		.name = "throttle.io_serviced",
>  		.private = offsetof(struct tg_stats_cpu, serviced),
> -		.read_seq_string = tg_print_cpu_rwstat,
> +		.seq_show = tg_print_cpu_rwstat,
>  	},
>  	{ }	/* terminate */
>  };
> diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
> index 4d5cec1..744833b 100644
> --- a/block/cfq-iosched.c
> +++ b/block/cfq-iosched.c
> @@ -1632,11 +1632,11 @@ static u64 cfqg_prfill_weight_device(struct seq_file *sf,
>  	return __blkg_prfill_u64(sf, pd, cfqg->dev_weight);
>  }
>  
> -static int cfqg_print_weight_device(struct cgroup_subsys_state *css,
> -				    struct cftype *cft, struct seq_file *sf)
> +static int cfqg_print_weight_device(struct seq_file *sf, void *v)
>  {
> -	blkcg_print_blkgs(sf, css_to_blkcg(css), cfqg_prfill_weight_device,
> -			  &blkcg_policy_cfq, 0, false);
> +	blkcg_print_blkgs(sf, css_to_blkcg(seq_css(sf)),
> +			  cfqg_prfill_weight_device, &blkcg_policy_cfq,
> +			  0, false);
>  	return 0;
>  }
>  
> @@ -1650,26 +1650,23 @@ static u64 cfqg_prfill_leaf_weight_device(struct seq_file *sf,
>  	return __blkg_prfill_u64(sf, pd, cfqg->dev_leaf_weight);
>  }
>  
> -static int cfqg_print_leaf_weight_device(struct cgroup_subsys_state *css,
> -					 struct cftype *cft,
> -					 struct seq_file *sf)
> +static int cfqg_print_leaf_weight_device(struct seq_file *sf, void *v)
>  {
> -	blkcg_print_blkgs(sf, css_to_blkcg(css), cfqg_prfill_leaf_weight_device,
> -			  &blkcg_policy_cfq, 0, false);
> +	blkcg_print_blkgs(sf, css_to_blkcg(seq_css(sf)),
> +			  cfqg_prfill_leaf_weight_device, &blkcg_policy_cfq,
> +			  0, false);
>  	return 0;
>  }
>  
> -static int cfq_print_weight(struct cgroup_subsys_state *css, struct cftype *cft,
> -			    struct seq_file *sf)
> +static int cfq_print_weight(struct seq_file *sf, void *v)
>  {
> -	seq_printf(sf, "%u\n", css_to_blkcg(css)->cfq_weight);
> +	seq_printf(sf, "%u\n", css_to_blkcg(seq_css(sf))->cfq_weight);
>  	return 0;
>  }
>  
> -static int cfq_print_leaf_weight(struct cgroup_subsys_state *css,
> -				 struct cftype *cft, struct seq_file *sf)
> +static int cfq_print_leaf_weight(struct seq_file *sf, void *v)
>  {
> -	seq_printf(sf, "%u\n", css_to_blkcg(css)->cfq_leaf_weight);
> +	seq_printf(sf, "%u\n", css_to_blkcg(seq_css(sf))->cfq_leaf_weight);
>  	return 0;
>  }
>  
> @@ -1762,23 +1759,17 @@ static int cfq_set_leaf_weight(struct cgroup_subsys_state *css,
>  	return __cfq_set_weight(css, cft, val, true);
>  }
>  
> -static int cfqg_print_stat(struct cgroup_subsys_state *css, struct cftype *cft,
> -			   struct seq_file *sf)
> +static int cfqg_print_stat(struct seq_file *sf, void *v)
>  {
> -	struct blkcg *blkcg = css_to_blkcg(css);
> -
> -	blkcg_print_blkgs(sf, blkcg, blkg_prfill_stat, &blkcg_policy_cfq,
> -			  cft->private, false);
> +	blkcg_print_blkgs(sf, css_to_blkcg(seq_css(sf)), blkg_prfill_stat,
> +			  &blkcg_policy_cfq, seq_cft(sf)->private, false);
>  	return 0;
>  }
>  
> -static int cfqg_print_rwstat(struct cgroup_subsys_state *css,
> -			     struct cftype *cft, struct seq_file *sf)
> +static int cfqg_print_rwstat(struct seq_file *sf, void *v)
>  {
> -	struct blkcg *blkcg = css_to_blkcg(css);
> -
> -	blkcg_print_blkgs(sf, blkcg, blkg_prfill_rwstat, &blkcg_policy_cfq,
> -			  cft->private, true);
> +	blkcg_print_blkgs(sf, css_to_blkcg(seq_css(sf)), blkg_prfill_rwstat,
> +			  &blkcg_policy_cfq, seq_cft(sf)->private, true);
>  	return 0;
>  }
>  
> @@ -1798,23 +1789,19 @@ static u64 cfqg_prfill_rwstat_recursive(struct seq_file *sf,
>  	return __blkg_prfill_rwstat(sf, pd, &sum);
>  }
>  
> -static int cfqg_print_stat_recursive(struct cgroup_subsys_state *css,
> -				     struct cftype *cft, struct seq_file *sf)
> +static int cfqg_print_stat_recursive(struct seq_file *sf, void *v)
>  {
> -	struct blkcg *blkcg = css_to_blkcg(css);
> -
> -	blkcg_print_blkgs(sf, blkcg, cfqg_prfill_stat_recursive,
> -			  &blkcg_policy_cfq, cft->private, false);
> +	blkcg_print_blkgs(sf, css_to_blkcg(seq_css(sf)),
> +			  cfqg_prfill_stat_recursive, &blkcg_policy_cfq,
> +			  seq_cft(sf)->private, false);
>  	return 0;
>  }
>  
> -static int cfqg_print_rwstat_recursive(struct cgroup_subsys_state *css,
> -				       struct cftype *cft, struct seq_file *sf)
> +static int cfqg_print_rwstat_recursive(struct seq_file *sf, void *v)
>  {
> -	struct blkcg *blkcg = css_to_blkcg(css);
> -
> -	blkcg_print_blkgs(sf, blkcg, cfqg_prfill_rwstat_recursive,
> -			  &blkcg_policy_cfq, cft->private, true);
> +	blkcg_print_blkgs(sf, css_to_blkcg(seq_css(sf)),
> +			  cfqg_prfill_rwstat_recursive, &blkcg_policy_cfq,
> +			  seq_cft(sf)->private, true);
>  	return 0;
>  }
>  
> @@ -1835,13 +1822,11 @@ static u64 cfqg_prfill_avg_queue_size(struct seq_file *sf,
>  }
>  
>  /* print avg_queue_size */
> -static int cfqg_print_avg_queue_size(struct cgroup_subsys_state *css,
> -				     struct cftype *cft, struct seq_file *sf)
> +static int cfqg_print_avg_queue_size(struct seq_file *sf, void *v)
>  {
> -	struct blkcg *blkcg = css_to_blkcg(css);
> -
> -	blkcg_print_blkgs(sf, blkcg, cfqg_prfill_avg_queue_size,
> -			  &blkcg_policy_cfq, 0, false);
> +	blkcg_print_blkgs(sf, css_to_blkcg(seq_css(sf)),
> +			  cfqg_prfill_avg_queue_size, &blkcg_policy_cfq,
> +			  0, false);
>  	return 0;
>  }
>  #endif	/* CONFIG_DEBUG_BLK_CGROUP */
> @@ -1851,14 +1836,14 @@ static struct cftype cfq_blkcg_files[] = {
>  	{
>  		.name = "weight_device",
>  		.flags = CFTYPE_ONLY_ON_ROOT,
> -		.read_seq_string = cfqg_print_leaf_weight_device,
> +		.seq_show = cfqg_print_leaf_weight_device,
>  		.write_string = cfqg_set_leaf_weight_device,
>  		.max_write_len = 256,
>  	},
>  	{
>  		.name = "weight",
>  		.flags = CFTYPE_ONLY_ON_ROOT,
> -		.read_seq_string = cfq_print_leaf_weight,
> +		.seq_show = cfq_print_leaf_weight,
>  		.write_u64 = cfq_set_leaf_weight,
>  	},
>  
> @@ -1866,26 +1851,26 @@ static struct cftype cfq_blkcg_files[] = {
>  	{
>  		.name = "weight_device",
>  		.flags = CFTYPE_NOT_ON_ROOT,
> -		.read_seq_string = cfqg_print_weight_device,
> +		.seq_show = cfqg_print_weight_device,
>  		.write_string = cfqg_set_weight_device,
>  		.max_write_len = 256,
>  	},
>  	{
>  		.name = "weight",
>  		.flags = CFTYPE_NOT_ON_ROOT,
> -		.read_seq_string = cfq_print_weight,
> +		.seq_show = cfq_print_weight,
>  		.write_u64 = cfq_set_weight,
>  	},
>  
>  	{
>  		.name = "leaf_weight_device",
> -		.read_seq_string = cfqg_print_leaf_weight_device,
> +		.seq_show = cfqg_print_leaf_weight_device,
>  		.write_string = cfqg_set_leaf_weight_device,
>  		.max_write_len = 256,
>  	},
>  	{
>  		.name = "leaf_weight",
> -		.read_seq_string = cfq_print_leaf_weight,
> +		.seq_show = cfq_print_leaf_weight,
>  		.write_u64 = cfq_set_leaf_weight,
>  	},
>  
> @@ -1893,114 +1878,114 @@ static struct cftype cfq_blkcg_files[] = {
>  	{
>  		.name = "time",
>  		.private = offsetof(struct cfq_group, stats.time),
> -		.read_seq_string = cfqg_print_stat,
> +		.seq_show = cfqg_print_stat,
>  	},
>  	{
>  		.name = "sectors",
>  		.private = offsetof(struct cfq_group, stats.sectors),
> -		.read_seq_string = cfqg_print_stat,
> +		.seq_show = cfqg_print_stat,
>  	},
>  	{
>  		.name = "io_service_bytes",
>  		.private = offsetof(struct cfq_group, stats.service_bytes),
> -		.read_seq_string = cfqg_print_rwstat,
> +		.seq_show = cfqg_print_rwstat,
>  	},
>  	{
>  		.name = "io_serviced",
>  		.private = offsetof(struct cfq_group, stats.serviced),
> -		.read_seq_string = cfqg_print_rwstat,
> +		.seq_show = cfqg_print_rwstat,
>  	},
>  	{
>  		.name = "io_service_time",
>  		.private = offsetof(struct cfq_group, stats.service_time),
> -		.read_seq_string = cfqg_print_rwstat,
> +		.seq_show = cfqg_print_rwstat,
>  	},
>  	{
>  		.name = "io_wait_time",
>  		.private = offsetof(struct cfq_group, stats.wait_time),
> -		.read_seq_string = cfqg_print_rwstat,
> +		.seq_show = cfqg_print_rwstat,
>  	},
>  	{
>  		.name = "io_merged",
>  		.private = offsetof(struct cfq_group, stats.merged),
> -		.read_seq_string = cfqg_print_rwstat,
> +		.seq_show = cfqg_print_rwstat,
>  	},
>  	{
>  		.name = "io_queued",
>  		.private = offsetof(struct cfq_group, stats.queued),
> -		.read_seq_string = cfqg_print_rwstat,
> +		.seq_show = cfqg_print_rwstat,
>  	},
>  
>  	/* the same statictics which cover the cfqg and its descendants */
>  	{
>  		.name = "time_recursive",
>  		.private = offsetof(struct cfq_group, stats.time),
> -		.read_seq_string = cfqg_print_stat_recursive,
> +		.seq_show = cfqg_print_stat_recursive,
>  	},
>  	{
>  		.name = "sectors_recursive",
>  		.private = offsetof(struct cfq_group, stats.sectors),
> -		.read_seq_string = cfqg_print_stat_recursive,
> +		.seq_show = cfqg_print_stat_recursive,
>  	},
>  	{
>  		.name = "io_service_bytes_recursive",
>  		.private = offsetof(struct cfq_group, stats.service_bytes),
> -		.read_seq_string = cfqg_print_rwstat_recursive,
> +		.seq_show = cfqg_print_rwstat_recursive,
>  	},
>  	{
>  		.name = "io_serviced_recursive",
>  		.private = offsetof(struct cfq_group, stats.serviced),
> -		.read_seq_string = cfqg_print_rwstat_recursive,
> +		.seq_show = cfqg_print_rwstat_recursive,
>  	},
>  	{
>  		.name = "io_service_time_recursive",
>  		.private = offsetof(struct cfq_group, stats.service_time),
> -		.read_seq_string = cfqg_print_rwstat_recursive,
> +		.seq_show = cfqg_print_rwstat_recursive,
>  	},
>  	{
>  		.name = "io_wait_time_recursive",
>  		.private = offsetof(struct cfq_group, stats.wait_time),
> -		.read_seq_string = cfqg_print_rwstat_recursive,
> +		.seq_show = cfqg_print_rwstat_recursive,
>  	},
>  	{
>  		.name = "io_merged_recursive",
>  		.private = offsetof(struct cfq_group, stats.merged),
> -		.read_seq_string = cfqg_print_rwstat_recursive,
> +		.seq_show = cfqg_print_rwstat_recursive,
>  	},
>  	{
>  		.name = "io_queued_recursive",
>  		.private = offsetof(struct cfq_group, stats.queued),
> -		.read_seq_string = cfqg_print_rwstat_recursive,
> +		.seq_show = cfqg_print_rwstat_recursive,
>  	},
>  #ifdef CONFIG_DEBUG_BLK_CGROUP
>  	{
>  		.name = "avg_queue_size",
> -		.read_seq_string = cfqg_print_avg_queue_size,
> +		.seq_show = cfqg_print_avg_queue_size,
>  	},
>  	{
>  		.name = "group_wait_time",
>  		.private = offsetof(struct cfq_group, stats.group_wait_time),
> -		.read_seq_string = cfqg_print_stat,
> +		.seq_show = cfqg_print_stat,
>  	},
>  	{
>  		.name = "idle_time",
>  		.private = offsetof(struct cfq_group, stats.idle_time),
> -		.read_seq_string = cfqg_print_stat,
> +		.seq_show = cfqg_print_stat,
>  	},
>  	{
>  		.name = "empty_time",
>  		.private = offsetof(struct cfq_group, stats.empty_time),
> -		.read_seq_string = cfqg_print_stat,
> +		.seq_show = cfqg_print_stat,
>  	},
>  	{
>  		.name = "dequeue",
>  		.private = offsetof(struct cfq_group, stats.dequeue),
> -		.read_seq_string = cfqg_print_stat,
> +		.seq_show = cfqg_print_stat,
>  	},
>  	{
>  		.name = "unaccounted_time",
>  		.private = offsetof(struct cfq_group, stats.unaccounted_time),
> -		.read_seq_string = cfqg_print_stat,
> +		.seq_show = cfqg_print_stat,
>  	},
>  #endif	/* CONFIG_DEBUG_BLK_CGROUP */
>  	{ }	/* terminate */
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index c3d698a..b32a0f8 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -444,12 +444,9 @@ struct cftype {
>  	 * read_s64() is a signed version of read_u64()
>  	 */
>  	s64 (*read_s64)(struct cgroup_subsys_state *css, struct cftype *cft);
> -	/*
> -	 * read_seq_string() is used for outputting a simple sequence
> -	 * using seqfile.
> -	 */
> -	int (*read_seq_string)(struct cgroup_subsys_state *css,
> -			       struct cftype *cft, struct seq_file *m);
> +
> +	/* generic seq_file read interface */
> +	int (*seq_show)(struct seq_file *sf, void *v);
>  
>  	/*
>  	 * write_u64() is a shortcut for the common case of accepting
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 1189de7..39fdf75 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2212,10 +2212,9 @@ static int cgroup_release_agent_write(struct cgroup_subsys_state *css,
>  	return 0;
>  }
>  
> -static int cgroup_release_agent_show(struct cgroup_subsys_state *css,
> -				     struct cftype *cft, struct seq_file *seq)
> +static int cgroup_release_agent_show(struct seq_file *seq, void *v)
>  {
> -	struct cgroup *cgrp = css->cgroup;
> +	struct cgroup *cgrp = seq_css(seq)->cgroup;
>  
>  	if (!cgroup_lock_live_group(cgrp))
>  		return -ENODEV;
> @@ -2225,10 +2224,11 @@ static int cgroup_release_agent_show(struct cgroup_subsys_state *css,
>  	return 0;
>  }
>  
> -static int cgroup_sane_behavior_show(struct cgroup_subsys_state *css,
> -				     struct cftype *cft, struct seq_file *seq)
> +static int cgroup_sane_behavior_show(struct seq_file *seq, void *v)
>  {
> -	seq_printf(seq, "%d\n", cgroup_sane_behavior(css->cgroup));
> +	struct cgroup *cgrp = seq_css(seq)->cgroup;
> +
> +	seq_printf(seq, "%d\n", cgroup_sane_behavior(cgrp));
>  	return 0;
>  }
>  
> @@ -2291,8 +2291,8 @@ static int cgroup_seqfile_show(struct seq_file *m, void *arg)
>  	struct cftype *cft = seq_cft(m);
>  	struct cgroup_subsys_state *css = seq_css(m);
>  
> -	if (cft->read_seq_string)
> -		return cft->read_seq_string(css, cft, m);
> +	if (cft->seq_show)
> +		return cft->seq_show(m, arg);
>  
>  	if (cft->read_u64)
>  		seq_printf(m, "%llu\n", cft->read_u64(css, cft));
> @@ -2556,7 +2556,7 @@ static umode_t cgroup_file_mode(const struct cftype *cft)
>  	if (cft->mode)
>  		return cft->mode;
>  
> -	if (cft->read_u64 || cft->read_s64 || cft->read_seq_string)
> +	if (cft->read_u64 || cft->read_s64 || cft->seq_show)
>  		mode |= S_IRUGO;
>  
>  	if (cft->write_u64 || cft->write_s64 || cft->write_string ||
> @@ -3873,7 +3873,7 @@ static struct cftype cgroup_base_files[] = {
>  	{
>  		.name = "cgroup.sane_behavior",
>  		.flags = CFTYPE_ONLY_ON_ROOT,
> -		.read_seq_string = cgroup_sane_behavior_show,
> +		.seq_show = cgroup_sane_behavior_show,
>  	},
>  
>  	/*
> @@ -3898,7 +3898,7 @@ static struct cftype cgroup_base_files[] = {
>  	{
>  		.name = "release_agent",
>  		.flags = CFTYPE_INSANE | CFTYPE_ONLY_ON_ROOT,
> -		.read_seq_string = cgroup_release_agent_show,
> +		.seq_show = cgroup_release_agent_show,
>  		.write_string = cgroup_release_agent_write,
>  		.max_write_len = PATH_MAX,
>  	},
> @@ -5273,9 +5273,7 @@ static u64 current_css_set_refcount_read(struct cgroup_subsys_state *css,
>  	return count;
>  }
>  
> -static int current_css_set_cg_links_read(struct cgroup_subsys_state *css,
> -					 struct cftype *cft,
> -					 struct seq_file *seq)
> +static int current_css_set_cg_links_read(struct seq_file *seq, void *v)
>  {
>  	struct cgrp_cset_link *link;
>  	struct css_set *cset;
> @@ -5300,9 +5298,9 @@ static int current_css_set_cg_links_read(struct cgroup_subsys_state *css,
>  }
>  
>  #define MAX_TASKS_SHOWN_PER_CSS 25
> -static int cgroup_css_links_read(struct cgroup_subsys_state *css,
> -				 struct cftype *cft, struct seq_file *seq)
> +static int cgroup_css_links_read(struct seq_file *seq, void *v)
>  {
> +	struct cgroup_subsys_state *css = seq_css(seq);
>  	struct cgrp_cset_link *link;
>  
>  	read_lock(&css_set_lock);
> @@ -5348,12 +5346,12 @@ static struct cftype debug_files[] =  {
>  
>  	{
>  		.name = "current_css_set_cg_links",
> -		.read_seq_string = current_css_set_cg_links_read,
> +		.seq_show = current_css_set_cg_links_read,
>  	},
>  
>  	{
>  		.name = "cgroup_css_links",
> -		.read_seq_string = cgroup_css_links_read,
> +		.seq_show = cgroup_css_links_read,
>  	},
>  
>  	{
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index f0ff64d..6c3154e 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -301,10 +301,9 @@ out_unlock:
>  	spin_unlock_irq(&freezer->lock);
>  }
>  
> -static int freezer_read(struct cgroup_subsys_state *css, struct cftype *cft,
> -			struct seq_file *m)
> +static int freezer_read(struct seq_file *m, void *v)
>  {
> -	struct cgroup_subsys_state *pos;
> +	struct cgroup_subsys_state *css = seq_css(m), *pos;
>  
>  	rcu_read_lock();
>  
> @@ -458,7 +457,7 @@ static struct cftype files[] = {
>  	{
>  		.name = "state",
>  		.flags = CFTYPE_NOT_ON_ROOT,
> -		.read_seq_string = freezer_read,
> +		.seq_show = freezer_read,
>  		.write_string = freezer_write,
>  	},
>  	{
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 032929f..4410ac6 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -1732,12 +1732,10 @@ out_unlock:
>   * and since these maps can change value dynamically, one could read
>   * gibberish by doing partial reads while a list was changing.
>   */
> -static int cpuset_common_read_seq_string(struct cgroup_subsys_state *css,
> -					 struct cftype *cft,
> -					 struct seq_file *sf)
> +static int cpuset_common_seq_show(struct seq_file *sf, void *v)
>  {
> -	struct cpuset *cs = css_cs(css);
> -	cpuset_filetype_t type = cft->private;
> +	struct cpuset *cs = css_cs(seq_css(sf));
> +	cpuset_filetype_t type = seq_cft(sf)->private;
>  	ssize_t count;
>  	char *buf, *s;
>  	int ret = 0;
> @@ -1824,7 +1822,7 @@ static s64 cpuset_read_s64(struct cgroup_subsys_state *css, struct cftype *cft)
>  static struct cftype files[] = {
>  	{
>  		.name = "cpus",
> -		.read_seq_string = cpuset_common_read_seq_string,
> +		.seq_show = cpuset_common_seq_show,
>  		.write_string = cpuset_write_resmask,
>  		.max_write_len = (100U + 6 * NR_CPUS),
>  		.private = FILE_CPULIST,
> @@ -1832,7 +1830,7 @@ static struct cftype files[] = {
>  
>  	{
>  		.name = "mems",
> -		.read_seq_string = cpuset_common_read_seq_string,
> +		.seq_show = cpuset_common_seq_show,
>  		.write_string = cpuset_write_resmask,
>  		.max_write_len = (100U + 6 * MAX_NUMNODES),
>  		.private = FILE_MEMLIST,
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index f28ec67..7e8cbb9 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -7256,10 +7256,9 @@ static int __cfs_schedulable(struct task_group *tg, u64 period, u64 quota)
>  	return ret;
>  }
>  
> -static int cpu_stats_show(struct cgroup_subsys_state *css, struct cftype *cft,
> -			  struct seq_file *sf)
> +static int cpu_stats_show(struct seq_file *sf, void *v)
>  {
> -	struct task_group *tg = css_tg(css);
> +	struct task_group *tg = css_tg(seq_css(sf));
>  	struct cfs_bandwidth *cfs_b = &tg->cfs_bandwidth;
>  
>  	seq_printf(sf, "nr_periods %d\n", cfs_b->nr_periods);
> @@ -7318,7 +7317,7 @@ static struct cftype cpu_files[] = {
>  	},
>  	{
>  		.name = "stat",
> -		.read_seq_string = cpu_stats_show,
> +		.seq_show = cpu_stats_show,
>  	},
>  #endif
>  #ifdef CONFIG_RT_GROUP_SCHED
> diff --git a/kernel/sched/cpuacct.c b/kernel/sched/cpuacct.c
> index dd88738..622e081 100644
> --- a/kernel/sched/cpuacct.c
> +++ b/kernel/sched/cpuacct.c
> @@ -163,10 +163,9 @@ out:
>  	return err;
>  }
>  
> -static int cpuacct_percpu_seq_read(struct cgroup_subsys_state *css,
> -				   struct cftype *cft, struct seq_file *m)
> +static int cpuacct_percpu_seq_show(struct seq_file *m, void *V)
>  {
> -	struct cpuacct *ca = css_ca(css);
> +	struct cpuacct *ca = css_ca(seq_css(m));
>  	u64 percpu;
>  	int i;
>  
> @@ -183,10 +182,9 @@ static const char * const cpuacct_stat_desc[] = {
>  	[CPUACCT_STAT_SYSTEM] = "system",
>  };
>  
> -static int cpuacct_stats_show(struct cgroup_subsys_state *css,
> -			      struct cftype *cft, struct seq_file *sf)
> +static int cpuacct_stats_show(struct seq_file *sf, void *v)
>  {
> -	struct cpuacct *ca = css_ca(css);
> +	struct cpuacct *ca = css_ca(seq_css(sf));
>  	int cpu;
>  	s64 val = 0;
>  
> @@ -220,11 +218,11 @@ static struct cftype files[] = {
>  	},
>  	{
>  		.name = "usage_percpu",
> -		.read_seq_string = cpuacct_percpu_seq_read,
> +		.seq_show = cpuacct_percpu_seq_show,
>  	},
>  	{
>  		.name = "stat",
> -		.read_seq_string = cpuacct_stats_show,
> +		.seq_show = cpuacct_stats_show,
>  	},
>  	{ }	/* terminate */
>  };
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f149521..9252219 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3014,10 +3014,9 @@ static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
>  }
>  
>  #ifdef CONFIG_SLABINFO
> -static int mem_cgroup_slabinfo_read(struct cgroup_subsys_state *css,
> -				    struct cftype *cft, struct seq_file *m)
> +static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
>  	struct memcg_cache_params *params;
>  
>  	if (!memcg_can_account_kmem(memcg))
> @@ -5418,8 +5417,7 @@ static int mem_cgroup_move_charge_write(struct cgroup_subsys_state *css,
>  #endif
>  
>  #ifdef CONFIG_NUMA
> -static int memcg_numa_stat_show(struct cgroup_subsys_state *css,
> -				struct cftype *cft, struct seq_file *m)
> +static int memcg_numa_stat_show(struct seq_file *m, void *v)
>  {
>  	struct numa_stat {
>  		const char *name;
> @@ -5435,7 +5433,7 @@ static int memcg_numa_stat_show(struct cgroup_subsys_state *css,
>  	const struct numa_stat *stat;
>  	int nid;
>  	unsigned long nr;
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
>  
>  	for (stat = stats; stat < stats + ARRAY_SIZE(stats); stat++) {
>  		nr = mem_cgroup_nr_lru_pages(memcg, stat->lru_mask);
> @@ -5474,10 +5472,9 @@ static inline void mem_cgroup_lru_names_not_uptodate(void)
>  	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
>  }
>  
> -static int memcg_stat_show(struct cgroup_subsys_state *css, struct cftype *cft,
> -				 struct seq_file *m)
> +static int memcg_stat_show(struct seq_file *m, void *v)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
>  	struct mem_cgroup *mi;
>  	unsigned int i;
>  
> @@ -5907,10 +5904,9 @@ static void mem_cgroup_oom_unregister_event(struct mem_cgroup *memcg,
>  	spin_unlock(&memcg_oom_lock);
>  }
>  
> -static int mem_cgroup_oom_control_read(struct cgroup_subsys_state *css,
> -				       struct cftype *cft, struct seq_file *sf)
> +static int mem_cgroup_oom_control_read(struct seq_file *sf, void *v)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(sf));
>  
>  	seq_printf(sf, "oom_kill_disable %d\n", memcg->oom_kill_disable);
>  	seq_printf(sf, "under_oom %d\n", (bool)atomic_read(&memcg->under_oom));
> @@ -6260,7 +6256,7 @@ static struct cftype mem_cgroup_files[] = {
>  	},
>  	{
>  		.name = "stat",
> -		.read_seq_string = memcg_stat_show,
> +		.seq_show = memcg_stat_show,
>  	},
>  	{
>  		.name = "force_empty",
> @@ -6290,7 +6286,7 @@ static struct cftype mem_cgroup_files[] = {
>  	},
>  	{
>  		.name = "oom_control",
> -		.read_seq_string = mem_cgroup_oom_control_read,
> +		.seq_show = mem_cgroup_oom_control_read,
>  		.write_u64 = mem_cgroup_oom_control_write,
>  		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
>  	},
> @@ -6300,7 +6296,7 @@ static struct cftype mem_cgroup_files[] = {
>  #ifdef CONFIG_NUMA
>  	{
>  		.name = "numa_stat",
> -		.read_seq_string = memcg_numa_stat_show,
> +		.seq_show = memcg_numa_stat_show,
>  	},
>  #endif
>  #ifdef CONFIG_MEMCG_KMEM
> @@ -6330,7 +6326,7 @@ static struct cftype mem_cgroup_files[] = {
>  #ifdef CONFIG_SLABINFO
>  	{
>  		.name = "kmem.slabinfo",
> -		.read_seq_string = mem_cgroup_slabinfo_read,
> +		.seq_show = mem_cgroup_slabinfo_read,
>  	},
>  #endif
>  #endif
> diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
> index 498710d..56cbb69 100644
> --- a/net/core/netprio_cgroup.c
> +++ b/net/core/netprio_cgroup.c
> @@ -173,14 +173,14 @@ static u64 read_prioidx(struct cgroup_subsys_state *css, struct cftype *cft)
>  	return css->cgroup->id;
>  }
>  
> -static int read_priomap(struct cgroup_subsys_state *css, struct cftype *cft,
> -			struct seq_file *sf)
> +static int read_priomap(struct seq_file *sf, void *v)
>  {
>  	struct net_device *dev;
>  
>  	rcu_read_lock();
>  	for_each_netdev_rcu(&init_net, dev)
> -		seq_printf(sf, "%s %u\n", dev->name, netprio_prio(css, dev));
> +		seq_printf(sf, "%s %u\n", dev->name,
> +			   netprio_prio(seq_css(sf), dev));
>  	rcu_read_unlock();
>  	return 0;
>  }
> @@ -238,7 +238,7 @@ static struct cftype ss_files[] = {
>  	},
>  	{
>  		.name = "ifpriomap",
> -		.read_seq_string = read_priomap,
> +		.seq_show = read_priomap,
>  		.write_string = write_priomap,
>  	},
>  	{ }	/* terminate */
> diff --git a/security/device_cgroup.c b/security/device_cgroup.c
> index 7c2a0a7..d3b6d2c 100644
> --- a/security/device_cgroup.c
> +++ b/security/device_cgroup.c
> @@ -274,10 +274,9 @@ static void set_majmin(char *str, unsigned m)
>  		sprintf(str, "%u", m);
>  }
>  
> -static int devcgroup_seq_read(struct cgroup_subsys_state *css,
> -			      struct cftype *cft, struct seq_file *m)
> +static int devcgroup_seq_show(struct seq_file *m, void *v)
>  {
> -	struct dev_cgroup *devcgroup = css_to_devcgroup(css);
> +	struct dev_cgroup *devcgroup = css_to_devcgroup(seq_css(m));
>  	struct dev_exception_item *ex;
>  	char maj[MAJMINLEN], min[MAJMINLEN], acc[ACCLEN];
>  
> @@ -679,7 +678,7 @@ static struct cftype dev_cgroup_files[] = {
>  	},
>  	{
>  		.name = "list",
> -		.read_seq_string = devcgroup_seq_read,
> +		.seq_show = devcgroup_seq_show,
>  		.private = DEVCG_LIST,
>  	},
>  	{ }	/* terminate */
> -- 
> 1.8.4.2
> 

-- 
Michal Hocko
SUSE Labs
