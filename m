From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 12/23] cgroup: pass around cgroup_subsys_state instead of
	cgroup in file methods
Date: Fri, 2 Aug 2013 15:27:06 +0200
Message-ID: <20130802132706.GC25432@dhcp22.suse.cz>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
	<1375393801-4817-13-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1375393801-4817-13-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu 01-08-13 17:49:50, Tejun Heo wrote:
> cgroup is currently in the process of transitioning to using struct
> cgroup_subsys_state * as the primary handle instead of struct cgroup.
> Please see the previous commit which converts the subsystem methods
> for rationale.
> 
> This patch converts all cftype file operations to take @css instead of
> @cgroup.  cftypes for the cgroup core files don't have their subsytem
> pointer set.  These will automatically use the dummy_css added by the
> previous patch and can be converted the same way.
> 
> Most subsystem conversions are straight forwards but there are some
> interesting ones.
> 
> * freezer: update_if_frozen() is also converted to take @css instead
>   of @cgroup for consistency.  This will make the code look simpler
>   too once iterators are converted to use css.
> 
> * memory/vmpressure: mem_cgroup_from_css() needs to be exported to
>   vmpressure while mem_cgroup_from_cont() can be made static.
>   Updated accordingly.
> 
> * cpu: cgroup_tg() doesn't have any user left.  Removed.
> 
> * cpuacct: cgroup_ca() doesn't have any user left.  Removed.
> 
> * hugetlb: hugetlb_cgroup_form_cgroup() doesn't have any user left.
>   Removed.
> 
> * net_cls: cgrp_cls_state() doesn't have any user left.  Removed.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
> Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>

Looks good to me. For memcg parts
Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

> ---
>  block/blk-cgroup.c         |   6 +-
>  block/blk-throttle.c       |  32 ++++-----
>  block/cfq-iosched.c        |  90 ++++++++++++-------------
>  include/linux/cgroup.h     |  24 ++++---
>  include/linux/memcontrol.h |   2 +-
>  kernel/cgroup.c            | 162 +++++++++++++++++++++++----------------------
>  kernel/cgroup_freezer.c    |  40 +++++------
>  kernel/cpuset.c            |  35 +++++-----
>  kernel/sched/core.c        |  65 +++++++++---------
>  kernel/sched/cpuacct.c     |  28 +++-----
>  mm/hugetlb_cgroup.c        |  26 +++-----
>  mm/memcontrol.c            |  88 ++++++++++++------------
>  mm/vmpressure.c            |   4 +-
>  net/core/netprio_cgroup.c  |  10 ++-
>  net/ipv4/tcp_memcontrol.c  |  12 ++--
>  net/sched/cls_cgroup.c     |  14 ++--
>  security/device_cgroup.c   |  12 ++--
>  17 files changed, 322 insertions(+), 328 deletions(-)
> 
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index 3406373..f46f3c6 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -437,10 +437,10 @@ struct request_list *__blk_queue_next_rl(struct request_list *rl,
>  	return &blkg->rl;
>  }
>  
> -static int blkcg_reset_stats(struct cgroup *cgroup, struct cftype *cftype,
> -			     u64 val)
> +static int blkcg_reset_stats(struct cgroup_subsys_state *css,
> +			     struct cftype *cftype, u64 val)
>  {
> -	struct blkcg *blkcg = cgroup_to_blkcg(cgroup);
> +	struct blkcg *blkcg = css_to_blkcg(css);
>  	struct blkcg_gq *blkg;
>  	int i;
>  
> diff --git a/block/blk-throttle.c b/block/blk-throttle.c
> index 08a32df..88bcfb6 100644
> --- a/block/blk-throttle.c
> +++ b/block/blk-throttle.c
> @@ -1293,10 +1293,10 @@ static u64 tg_prfill_cpu_rwstat(struct seq_file *sf,
>  	return __blkg_prfill_rwstat(sf, pd, &rwstat);
>  }
>  
> -static int tg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
> -			       struct seq_file *sf)
> +static int tg_print_cpu_rwstat(struct cgroup_subsys_state *css,
> +			       struct cftype *cft, struct seq_file *sf)
>  {
> -	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
> +	struct blkcg *blkcg = css_to_blkcg(css);
>  
>  	blkcg_print_blkgs(sf, blkcg, tg_prfill_cpu_rwstat, &blkcg_policy_throtl,
>  			  cft->private, true);
> @@ -1325,26 +1325,26 @@ static u64 tg_prfill_conf_uint(struct seq_file *sf, struct blkg_policy_data *pd,
>  	return __blkg_prfill_u64(sf, pd, v);
>  }
>  
> -static int tg_print_conf_u64(struct cgroup *cgrp, struct cftype *cft,
> -			     struct seq_file *sf)
> +static int tg_print_conf_u64(struct cgroup_subsys_state *css,
> +			     struct cftype *cft, struct seq_file *sf)
>  {
> -	blkcg_print_blkgs(sf, cgroup_to_blkcg(cgrp), tg_prfill_conf_u64,
> +	blkcg_print_blkgs(sf, css_to_blkcg(css), tg_prfill_conf_u64,
>  			  &blkcg_policy_throtl, cft->private, false);
>  	return 0;
>  }
>  
> -static int tg_print_conf_uint(struct cgroup *cgrp, struct cftype *cft,
> -			      struct seq_file *sf)
> +static int tg_print_conf_uint(struct cgroup_subsys_state *css,
> +			      struct cftype *cft, struct seq_file *sf)
>  {
> -	blkcg_print_blkgs(sf, cgroup_to_blkcg(cgrp), tg_prfill_conf_uint,
> +	blkcg_print_blkgs(sf, css_to_blkcg(css), tg_prfill_conf_uint,
>  			  &blkcg_policy_throtl, cft->private, false);
>  	return 0;
>  }
>  
> -static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
> -		       bool is_u64)
> +static int tg_set_conf(struct cgroup_subsys_state *css, struct cftype *cft,
> +		       const char *buf, bool is_u64)
>  {
> -	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
> +	struct blkcg *blkcg = css_to_blkcg(css);
>  	struct blkg_conf_ctx ctx;
>  	struct throtl_grp *tg;
>  	struct throtl_service_queue *sq;
> @@ -1403,16 +1403,16 @@ static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
>  	return 0;
>  }
>  
> -static int tg_set_conf_u64(struct cgroup *cgrp, struct cftype *cft,
> +static int tg_set_conf_u64(struct cgroup_subsys_state *css, struct cftype *cft,
>  			   const char *buf)
>  {
> -	return tg_set_conf(cgrp, cft, buf, true);
> +	return tg_set_conf(css, cft, buf, true);
>  }
>  
> -static int tg_set_conf_uint(struct cgroup *cgrp, struct cftype *cft,
> +static int tg_set_conf_uint(struct cgroup_subsys_state *css, struct cftype *cft,
>  			    const char *buf)
>  {
> -	return tg_set_conf(cgrp, cft, buf, false);
> +	return tg_set_conf(css, cft, buf, false);
>  }
>  
>  static struct cftype throtl_files[] = {
> diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
> index d5bbdcf..dabb9d0 100644
> --- a/block/cfq-iosched.c
> +++ b/block/cfq-iosched.c
> @@ -1607,12 +1607,11 @@ static u64 cfqg_prfill_weight_device(struct seq_file *sf,
>  	return __blkg_prfill_u64(sf, pd, cfqg->dev_weight);
>  }
>  
> -static int cfqg_print_weight_device(struct cgroup *cgrp, struct cftype *cft,
> -				    struct seq_file *sf)
> +static int cfqg_print_weight_device(struct cgroup_subsys_state *css,
> +				    struct cftype *cft, struct seq_file *sf)
>  {
> -	blkcg_print_blkgs(sf, cgroup_to_blkcg(cgrp),
> -			  cfqg_prfill_weight_device, &blkcg_policy_cfq, 0,
> -			  false);
> +	blkcg_print_blkgs(sf, css_to_blkcg(css), cfqg_prfill_weight_device,
> +			  &blkcg_policy_cfq, 0, false);
>  	return 0;
>  }
>  
> @@ -1626,35 +1625,34 @@ static u64 cfqg_prfill_leaf_weight_device(struct seq_file *sf,
>  	return __blkg_prfill_u64(sf, pd, cfqg->dev_leaf_weight);
>  }
>  
> -static int cfqg_print_leaf_weight_device(struct cgroup *cgrp,
> +static int cfqg_print_leaf_weight_device(struct cgroup_subsys_state *css,
>  					 struct cftype *cft,
>  					 struct seq_file *sf)
>  {
> -	blkcg_print_blkgs(sf, cgroup_to_blkcg(cgrp),
> -			  cfqg_prfill_leaf_weight_device, &blkcg_policy_cfq, 0,
> -			  false);
> +	blkcg_print_blkgs(sf, css_to_blkcg(css), cfqg_prfill_leaf_weight_device,
> +			  &blkcg_policy_cfq, 0, false);
>  	return 0;
>  }
>  
> -static int cfq_print_weight(struct cgroup *cgrp, struct cftype *cft,
> +static int cfq_print_weight(struct cgroup_subsys_state *css, struct cftype *cft,
>  			    struct seq_file *sf)
>  {
> -	seq_printf(sf, "%u\n", cgroup_to_blkcg(cgrp)->cfq_weight);
> +	seq_printf(sf, "%u\n", css_to_blkcg(css)->cfq_weight);
>  	return 0;
>  }
>  
> -static int cfq_print_leaf_weight(struct cgroup *cgrp, struct cftype *cft,
> -				 struct seq_file *sf)
> +static int cfq_print_leaf_weight(struct cgroup_subsys_state *css,
> +				 struct cftype *cft, struct seq_file *sf)
>  {
> -	seq_printf(sf, "%u\n",
> -		   cgroup_to_blkcg(cgrp)->cfq_leaf_weight);
> +	seq_printf(sf, "%u\n", css_to_blkcg(css)->cfq_leaf_weight);
>  	return 0;
>  }
>  
> -static int __cfqg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
> -				    const char *buf, bool is_leaf_weight)
> +static int __cfqg_set_weight_device(struct cgroup_subsys_state *css,
> +				    struct cftype *cft, const char *buf,
> +				    bool is_leaf_weight)
>  {
> -	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
> +	struct blkcg *blkcg = css_to_blkcg(css);
>  	struct blkg_conf_ctx ctx;
>  	struct cfq_group *cfqg;
>  	int ret;
> @@ -1680,22 +1678,22 @@ static int __cfqg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
>  	return ret;
>  }
>  
> -static int cfqg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
> -				  const char *buf)
> +static int cfqg_set_weight_device(struct cgroup_subsys_state *css,
> +				  struct cftype *cft, const char *buf)
>  {
> -	return __cfqg_set_weight_device(cgrp, cft, buf, false);
> +	return __cfqg_set_weight_device(css, cft, buf, false);
>  }
>  
> -static int cfqg_set_leaf_weight_device(struct cgroup *cgrp, struct cftype *cft,
> -				       const char *buf)
> +static int cfqg_set_leaf_weight_device(struct cgroup_subsys_state *css,
> +				       struct cftype *cft, const char *buf)
>  {
> -	return __cfqg_set_weight_device(cgrp, cft, buf, true);
> +	return __cfqg_set_weight_device(css, cft, buf, true);
>  }
>  
> -static int __cfq_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val,
> -			    bool is_leaf_weight)
> +static int __cfq_set_weight(struct cgroup_subsys_state *css, struct cftype *cft,
> +			    u64 val, bool is_leaf_weight)
>  {
> -	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
> +	struct blkcg *blkcg = css_to_blkcg(css);
>  	struct blkcg_gq *blkg;
>  
>  	if (val < CFQ_WEIGHT_MIN || val > CFQ_WEIGHT_MAX)
> @@ -1727,30 +1725,32 @@ static int __cfq_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val,
>  	return 0;
>  }
>  
> -static int cfq_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
> +static int cfq_set_weight(struct cgroup_subsys_state *css, struct cftype *cft,
> +			  u64 val)
>  {
> -	return __cfq_set_weight(cgrp, cft, val, false);
> +	return __cfq_set_weight(css, cft, val, false);
>  }
>  
> -static int cfq_set_leaf_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
> +static int cfq_set_leaf_weight(struct cgroup_subsys_state *css,
> +			       struct cftype *cft, u64 val)
>  {
> -	return __cfq_set_weight(cgrp, cft, val, true);
> +	return __cfq_set_weight(css, cft, val, true);
>  }
>  
> -static int cfqg_print_stat(struct cgroup *cgrp, struct cftype *cft,
> +static int cfqg_print_stat(struct cgroup_subsys_state *css, struct cftype *cft,
>  			   struct seq_file *sf)
>  {
> -	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
> +	struct blkcg *blkcg = css_to_blkcg(css);
>  
>  	blkcg_print_blkgs(sf, blkcg, blkg_prfill_stat, &blkcg_policy_cfq,
>  			  cft->private, false);
>  	return 0;
>  }
>  
> -static int cfqg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
> -			     struct seq_file *sf)
> +static int cfqg_print_rwstat(struct cgroup_subsys_state *css,
> +			     struct cftype *cft, struct seq_file *sf)
>  {
> -	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
> +	struct blkcg *blkcg = css_to_blkcg(css);
>  
>  	blkcg_print_blkgs(sf, blkcg, blkg_prfill_rwstat, &blkcg_policy_cfq,
>  			  cft->private, true);
> @@ -1773,20 +1773,20 @@ static u64 cfqg_prfill_rwstat_recursive(struct seq_file *sf,
>  	return __blkg_prfill_rwstat(sf, pd, &sum);
>  }
>  
> -static int cfqg_print_stat_recursive(struct cgroup *cgrp, struct cftype *cft,
> -				     struct seq_file *sf)
> +static int cfqg_print_stat_recursive(struct cgroup_subsys_state *css,
> +				     struct cftype *cft, struct seq_file *sf)
>  {
> -	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
> +	struct blkcg *blkcg = css_to_blkcg(css);
>  
>  	blkcg_print_blkgs(sf, blkcg, cfqg_prfill_stat_recursive,
>  			  &blkcg_policy_cfq, cft->private, false);
>  	return 0;
>  }
>  
> -static int cfqg_print_rwstat_recursive(struct cgroup *cgrp, struct cftype *cft,
> -				       struct seq_file *sf)
> +static int cfqg_print_rwstat_recursive(struct cgroup_subsys_state *css,
> +				       struct cftype *cft, struct seq_file *sf)
>  {
> -	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
> +	struct blkcg *blkcg = css_to_blkcg(css);
>  
>  	blkcg_print_blkgs(sf, blkcg, cfqg_prfill_rwstat_recursive,
>  			  &blkcg_policy_cfq, cft->private, true);
> @@ -1810,10 +1810,10 @@ static u64 cfqg_prfill_avg_queue_size(struct seq_file *sf,
>  }
>  
>  /* print avg_queue_size */
> -static int cfqg_print_avg_queue_size(struct cgroup *cgrp, struct cftype *cft,
> -				     struct seq_file *sf)
> +static int cfqg_print_avg_queue_size(struct cgroup_subsys_state *css,
> +				     struct cftype *cft, struct seq_file *sf)
>  {
> -	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
> +	struct blkcg *blkcg = css_to_blkcg(css);
>  
>  	blkcg_print_blkgs(sf, blkcg, cfqg_prfill_avg_queue_size,
>  			  &blkcg_policy_cfq, 0, false);
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 085ca93..9749d63 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -439,34 +439,34 @@ struct cftype {
>  	struct cgroup_subsys *ss;
>  
>  	int (*open)(struct inode *inode, struct file *file);
> -	ssize_t (*read)(struct cgroup *cgrp, struct cftype *cft,
> +	ssize_t (*read)(struct cgroup_subsys_state *css, struct cftype *cft,
>  			struct file *file,
>  			char __user *buf, size_t nbytes, loff_t *ppos);
>  	/*
>  	 * read_u64() is a shortcut for the common case of returning a
>  	 * single integer. Use it in place of read()
>  	 */
> -	u64 (*read_u64)(struct cgroup *cgrp, struct cftype *cft);
> +	u64 (*read_u64)(struct cgroup_subsys_state *css, struct cftype *cft);
>  	/*
>  	 * read_s64() is a signed version of read_u64()
>  	 */
> -	s64 (*read_s64)(struct cgroup *cgrp, struct cftype *cft);
> +	s64 (*read_s64)(struct cgroup_subsys_state *css, struct cftype *cft);
>  	/*
>  	 * read_map() is used for defining a map of key/value
>  	 * pairs. It should call cb->fill(cb, key, value) for each
>  	 * entry. The key/value pairs (and their ordering) should not
>  	 * change between reboots.
>  	 */
> -	int (*read_map)(struct cgroup *cgrp, struct cftype *cft,
> +	int (*read_map)(struct cgroup_subsys_state *css, struct cftype *cft,
>  			struct cgroup_map_cb *cb);
>  	/*
>  	 * read_seq_string() is used for outputting a simple sequence
>  	 * using seqfile.
>  	 */
> -	int (*read_seq_string)(struct cgroup *cgrp, struct cftype *cft,
> -			       struct seq_file *m);
> +	int (*read_seq_string)(struct cgroup_subsys_state *css,
> +			       struct cftype *cft, struct seq_file *m);
>  
> -	ssize_t (*write)(struct cgroup *cgrp, struct cftype *cft,
> +	ssize_t (*write)(struct cgroup_subsys_state *css, struct cftype *cft,
>  			 struct file *file,
>  			 const char __user *buf, size_t nbytes, loff_t *ppos);
>  
> @@ -475,18 +475,20 @@ struct cftype {
>  	 * a single integer (as parsed by simple_strtoull) from
>  	 * userspace. Use in place of write(); return 0 or error.
>  	 */
> -	int (*write_u64)(struct cgroup *cgrp, struct cftype *cft, u64 val);
> +	int (*write_u64)(struct cgroup_subsys_state *css, struct cftype *cft,
> +			 u64 val);
>  	/*
>  	 * write_s64() is a signed version of write_u64()
>  	 */
> -	int (*write_s64)(struct cgroup *cgrp, struct cftype *cft, s64 val);
> +	int (*write_s64)(struct cgroup_subsys_state *css, struct cftype *cft,
> +			 s64 val);
>  
>  	/*
>  	 * write_string() is passed a nul-terminated kernelspace
>  	 * buffer of maximum length determined by max_write_len.
>  	 * Returns 0 or -ve error code.
>  	 */
> -	int (*write_string)(struct cgroup *cgrp, struct cftype *cft,
> +	int (*write_string)(struct cgroup_subsys_state *css, struct cftype *cft,
>  			    const char *buffer);
>  	/*
>  	 * trigger() callback can be used to get some kick from the
> @@ -494,7 +496,7 @@ struct cftype {
>  	 * at all. The private field can be used to determine the
>  	 * kick type for multiplexing.
>  	 */
> -	int (*trigger)(struct cgroup *cgrp, unsigned int event);
> +	int (*trigger)(struct cgroup_subsys_state *css, unsigned int event);
>  
>  	int (*release)(struct inode *inode, struct file *file);
>  
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 7b4d9d7..6c41609 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -85,7 +85,7 @@ extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
>  extern struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm);
>  
>  extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
> -extern struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont);
> +extern struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css);
>  
>  static inline
>  bool mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *memcg)
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index bb87c9f..6c68192 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2228,34 +2228,38 @@ int cgroup_attach_task_all(struct task_struct *from, struct task_struct *tsk)
>  }
>  EXPORT_SYMBOL_GPL(cgroup_attach_task_all);
>  
> -static int cgroup_tasks_write(struct cgroup *cgrp, struct cftype *cft, u64 pid)
> +static int cgroup_tasks_write(struct cgroup_subsys_state *css,
> +			      struct cftype *cft, u64 pid)
>  {
> -	return attach_task_by_pid(cgrp, pid, false);
> +	return attach_task_by_pid(css->cgroup, pid, false);
>  }
>  
> -static int cgroup_procs_write(struct cgroup *cgrp, struct cftype *cft, u64 tgid)
> +static int cgroup_procs_write(struct cgroup_subsys_state *css,
> +			      struct cftype *cft, u64 tgid)
>  {
> -	return attach_task_by_pid(cgrp, tgid, true);
> +	return attach_task_by_pid(css->cgroup, tgid, true);
>  }
>  
> -static int cgroup_release_agent_write(struct cgroup *cgrp, struct cftype *cft,
> -				      const char *buffer)
> +static int cgroup_release_agent_write(struct cgroup_subsys_state *css,
> +				      struct cftype *cft, const char *buffer)
>  {
> -	BUILD_BUG_ON(sizeof(cgrp->root->release_agent_path) < PATH_MAX);
> +	BUILD_BUG_ON(sizeof(css->cgroup->root->release_agent_path) < PATH_MAX);
>  	if (strlen(buffer) >= PATH_MAX)
>  		return -EINVAL;
> -	if (!cgroup_lock_live_group(cgrp))
> +	if (!cgroup_lock_live_group(css->cgroup))
>  		return -ENODEV;
>  	mutex_lock(&cgroup_root_mutex);
> -	strcpy(cgrp->root->release_agent_path, buffer);
> +	strcpy(css->cgroup->root->release_agent_path, buffer);
>  	mutex_unlock(&cgroup_root_mutex);
>  	mutex_unlock(&cgroup_mutex);
>  	return 0;
>  }
>  
> -static int cgroup_release_agent_show(struct cgroup *cgrp, struct cftype *cft,
> -				     struct seq_file *seq)
> +static int cgroup_release_agent_show(struct cgroup_subsys_state *css,
> +				     struct cftype *cft, struct seq_file *seq)
>  {
> +	struct cgroup *cgrp = css->cgroup;
> +
>  	if (!cgroup_lock_live_group(cgrp))
>  		return -ENODEV;
>  	seq_puts(seq, cgrp->root->release_agent_path);
> @@ -2264,10 +2268,10 @@ static int cgroup_release_agent_show(struct cgroup *cgrp, struct cftype *cft,
>  	return 0;
>  }
>  
> -static int cgroup_sane_behavior_show(struct cgroup *cgrp, struct cftype *cft,
> -				     struct seq_file *seq)
> +static int cgroup_sane_behavior_show(struct cgroup_subsys_state *css,
> +				     struct cftype *cft, struct seq_file *seq)
>  {
> -	seq_printf(seq, "%d\n", cgroup_sane_behavior(cgrp));
> +	seq_printf(seq, "%d\n", cgroup_sane_behavior(css->cgroup));
>  	return 0;
>  }
>  
> @@ -2285,10 +2289,10 @@ static struct cgroup_subsys_state *cgroup_file_css(struct cfent *cfe)
>  /* A buffer size big enough for numbers or short strings */
>  #define CGROUP_LOCAL_BUFFER_SIZE 64
>  
> -static ssize_t cgroup_write_X64(struct cgroup *cgrp, struct cftype *cft,
> -				struct file *file,
> -				const char __user *userbuf,
> -				size_t nbytes, loff_t *unused_ppos)
> +static ssize_t cgroup_write_X64(struct cgroup_subsys_state *css,
> +				struct cftype *cft, struct file *file,
> +				const char __user *userbuf, size_t nbytes,
> +				loff_t *unused_ppos)
>  {
>  	char buffer[CGROUP_LOCAL_BUFFER_SIZE];
>  	int retval = 0;
> @@ -2306,22 +2310,22 @@ static ssize_t cgroup_write_X64(struct cgroup *cgrp, struct cftype *cft,
>  		u64 val = simple_strtoull(strstrip(buffer), &end, 0);
>  		if (*end)
>  			return -EINVAL;
> -		retval = cft->write_u64(cgrp, cft, val);
> +		retval = cft->write_u64(css, cft, val);
>  	} else {
>  		s64 val = simple_strtoll(strstrip(buffer), &end, 0);
>  		if (*end)
>  			return -EINVAL;
> -		retval = cft->write_s64(cgrp, cft, val);
> +		retval = cft->write_s64(css, cft, val);
>  	}
>  	if (!retval)
>  		retval = nbytes;
>  	return retval;
>  }
>  
> -static ssize_t cgroup_write_string(struct cgroup *cgrp, struct cftype *cft,
> -				   struct file *file,
> -				   const char __user *userbuf,
> -				   size_t nbytes, loff_t *unused_ppos)
> +static ssize_t cgroup_write_string(struct cgroup_subsys_state *css,
> +				   struct cftype *cft, struct file *file,
> +				   const char __user *userbuf, size_t nbytes,
> +				   loff_t *unused_ppos)
>  {
>  	char local_buffer[CGROUP_LOCAL_BUFFER_SIZE];
>  	int retval = 0;
> @@ -2344,7 +2348,7 @@ static ssize_t cgroup_write_string(struct cgroup *cgrp, struct cftype *cft,
>  	}
>  
>  	buffer[nbytes] = 0;     /* nul-terminate */
> -	retval = cft->write_string(cgrp, cft, strstrip(buffer));
> +	retval = cft->write_string(css, cft, strstrip(buffer));
>  	if (!retval)
>  		retval = nbytes;
>  out:
> @@ -2354,60 +2358,60 @@ out:
>  }
>  
>  static ssize_t cgroup_file_write(struct file *file, const char __user *buf,
> -						size_t nbytes, loff_t *ppos)
> +				 size_t nbytes, loff_t *ppos)
>  {
> +	struct cfent *cfe = __d_cfe(file->f_dentry);
>  	struct cftype *cft = __d_cft(file->f_dentry);
> -	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
> +	struct cgroup_subsys_state *css = cgroup_file_css(cfe);
>  
>  	if (cft->write)
> -		return cft->write(cgrp, cft, file, buf, nbytes, ppos);
> +		return cft->write(css, cft, file, buf, nbytes, ppos);
>  	if (cft->write_u64 || cft->write_s64)
> -		return cgroup_write_X64(cgrp, cft, file, buf, nbytes, ppos);
> +		return cgroup_write_X64(css, cft, file, buf, nbytes, ppos);
>  	if (cft->write_string)
> -		return cgroup_write_string(cgrp, cft, file, buf, nbytes, ppos);
> +		return cgroup_write_string(css, cft, file, buf, nbytes, ppos);
>  	if (cft->trigger) {
> -		int ret = cft->trigger(cgrp, (unsigned int)cft->private);
> +		int ret = cft->trigger(css, (unsigned int)cft->private);
>  		return ret ? ret : nbytes;
>  	}
>  	return -EINVAL;
>  }
>  
> -static ssize_t cgroup_read_u64(struct cgroup *cgrp, struct cftype *cft,
> -			       struct file *file,
> -			       char __user *buf, size_t nbytes,
> -			       loff_t *ppos)
> +static ssize_t cgroup_read_u64(struct cgroup_subsys_state *css,
> +			       struct cftype *cft, struct file *file,
> +			       char __user *buf, size_t nbytes, loff_t *ppos)
>  {
>  	char tmp[CGROUP_LOCAL_BUFFER_SIZE];
> -	u64 val = cft->read_u64(cgrp, cft);
> +	u64 val = cft->read_u64(css, cft);
>  	int len = sprintf(tmp, "%llu\n", (unsigned long long) val);
>  
>  	return simple_read_from_buffer(buf, nbytes, ppos, tmp, len);
>  }
>  
> -static ssize_t cgroup_read_s64(struct cgroup *cgrp, struct cftype *cft,
> -			       struct file *file,
> -			       char __user *buf, size_t nbytes,
> -			       loff_t *ppos)
> +static ssize_t cgroup_read_s64(struct cgroup_subsys_state *css,
> +			       struct cftype *cft, struct file *file,
> +			       char __user *buf, size_t nbytes, loff_t *ppos)
>  {
>  	char tmp[CGROUP_LOCAL_BUFFER_SIZE];
> -	s64 val = cft->read_s64(cgrp, cft);
> +	s64 val = cft->read_s64(css, cft);
>  	int len = sprintf(tmp, "%lld\n", (long long) val);
>  
>  	return simple_read_from_buffer(buf, nbytes, ppos, tmp, len);
>  }
>  
>  static ssize_t cgroup_file_read(struct file *file, char __user *buf,
> -				   size_t nbytes, loff_t *ppos)
> +				size_t nbytes, loff_t *ppos)
>  {
> +	struct cfent *cfe = __d_cfe(file->f_dentry);
>  	struct cftype *cft = __d_cft(file->f_dentry);
> -	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
> +	struct cgroup_subsys_state *css = cgroup_file_css(cfe);
>  
>  	if (cft->read)
> -		return cft->read(cgrp, cft, file, buf, nbytes, ppos);
> +		return cft->read(css, cft, file, buf, nbytes, ppos);
>  	if (cft->read_u64)
> -		return cgroup_read_u64(cgrp, cft, file, buf, nbytes, ppos);
> +		return cgroup_read_u64(css, cft, file, buf, nbytes, ppos);
>  	if (cft->read_s64)
> -		return cgroup_read_s64(cgrp, cft, file, buf, nbytes, ppos);
> +		return cgroup_read_s64(css, cft, file, buf, nbytes, ppos);
>  	return -EINVAL;
>  }
>  
> @@ -2426,16 +2430,16 @@ static int cgroup_seqfile_show(struct seq_file *m, void *arg)
>  {
>  	struct cfent *cfe = m->private;
>  	struct cftype *cft = cfe->type;
> -	struct cgroup *cgrp = __d_cgrp(cfe->dentry->d_parent);
> +	struct cgroup_subsys_state *css = cgroup_file_css(cfe);
>  
>  	if (cft->read_map) {
>  		struct cgroup_map_cb cb = {
>  			.fill = cgroup_map_add,
>  			.state = m,
>  		};
> -		return cft->read_map(cgrp, cft, &cb);
> +		return cft->read_map(css, cft, &cb);
>  	}
> -	return cft->read_seq_string(cgrp, cft, m);
> +	return cft->read_seq_string(css, cft, m);
>  }
>  
>  static const struct file_operations cgroup_seqfile_operations = {
> @@ -3853,21 +3857,20 @@ static int cgroup_procs_open(struct inode *unused, struct file *file)
>  	return cgroup_pidlist_open(file, CGROUP_FILE_PROCS);
>  }
>  
> -static u64 cgroup_read_notify_on_release(struct cgroup *cgrp,
> -					    struct cftype *cft)
> +static u64 cgroup_read_notify_on_release(struct cgroup_subsys_state *css,
> +					 struct cftype *cft)
>  {
> -	return notify_on_release(cgrp);
> +	return notify_on_release(css->cgroup);
>  }
>  
> -static int cgroup_write_notify_on_release(struct cgroup *cgrp,
> -					  struct cftype *cft,
> -					  u64 val)
> +static int cgroup_write_notify_on_release(struct cgroup_subsys_state *css,
> +					  struct cftype *cft, u64 val)
>  {
> -	clear_bit(CGRP_RELEASABLE, &cgrp->flags);
> +	clear_bit(CGRP_RELEASABLE, &css->cgroup->flags);
>  	if (val)
> -		set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
> +		set_bit(CGRP_NOTIFY_ON_RELEASE, &css->cgroup->flags);
>  	else
> -		clear_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
> +		clear_bit(CGRP_NOTIFY_ON_RELEASE, &css->cgroup->flags);
>  	return 0;
>  }
>  
> @@ -3965,9 +3968,10 @@ static void cgroup_event_ptable_queue_proc(struct file *file,
>   * Input must be in format '<event_fd> <control_fd> <args>'.
>   * Interpretation of args is defined by control file implementation.
>   */
> -static int cgroup_write_event_control(struct cgroup *cgrp, struct cftype *cft,
> -				      const char *buffer)
> +static int cgroup_write_event_control(struct cgroup_subsys_state *css,
> +				      struct cftype *cft, const char *buffer)
>  {
> +	struct cgroup *cgrp = css->cgroup;
>  	struct cgroup_event *event;
>  	struct cgroup *cgrp_cfile;
>  	unsigned int efd, cfd;
> @@ -4075,20 +4079,19 @@ out_kfree:
>  	return ret;
>  }
>  
> -static u64 cgroup_clone_children_read(struct cgroup *cgrp,
> -				    struct cftype *cft)
> +static u64 cgroup_clone_children_read(struct cgroup_subsys_state *css,
> +				      struct cftype *cft)
>  {
> -	return test_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags);
> +	return test_bit(CGRP_CPUSET_CLONE_CHILDREN, &css->cgroup->flags);
>  }
>  
> -static int cgroup_clone_children_write(struct cgroup *cgrp,
> -				     struct cftype *cft,
> -				     u64 val)
> +static int cgroup_clone_children_write(struct cgroup_subsys_state *css,
> +				       struct cftype *cft, u64 val)
>  {
>  	if (val)
> -		set_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags);
> +		set_bit(CGRP_CPUSET_CLONE_CHILDREN, &css->cgroup->flags);
>  	else
> -		clear_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags);
> +		clear_bit(CGRP_CPUSET_CLONE_CHILDREN, &css->cgroup->flags);
>  	return 0;
>  }
>  
> @@ -5576,17 +5579,19 @@ static void debug_css_free(struct cgroup_subsys_state *css)
>  	kfree(css);
>  }
>  
> -static u64 debug_taskcount_read(struct cgroup *cgrp, struct cftype *cft)
> +static u64 debug_taskcount_read(struct cgroup_subsys_state *css,
> +				struct cftype *cft)
>  {
> -	return cgroup_task_count(cgrp);
> +	return cgroup_task_count(css->cgroup);
>  }
>  
> -static u64 current_css_set_read(struct cgroup *cgrp, struct cftype *cft)
> +static u64 current_css_set_read(struct cgroup_subsys_state *css,
> +				struct cftype *cft)
>  {
>  	return (u64)(unsigned long)current->cgroups;
>  }
>  
> -static u64 current_css_set_refcount_read(struct cgroup *cgrp,
> +static u64 current_css_set_refcount_read(struct cgroup_subsys_state *css,
>  					 struct cftype *cft)
>  {
>  	u64 count;
> @@ -5597,7 +5602,7 @@ static u64 current_css_set_refcount_read(struct cgroup *cgrp,
>  	return count;
>  }
>  
> -static int current_css_set_cg_links_read(struct cgroup *cgrp,
> +static int current_css_set_cg_links_read(struct cgroup_subsys_state *css,
>  					 struct cftype *cft,
>  					 struct seq_file *seq)
>  {
> @@ -5624,14 +5629,13 @@ static int current_css_set_cg_links_read(struct cgroup *cgrp,
>  }
>  
>  #define MAX_TASKS_SHOWN_PER_CSS 25
> -static int cgroup_css_links_read(struct cgroup *cgrp,
> -				 struct cftype *cft,
> -				 struct seq_file *seq)
> +static int cgroup_css_links_read(struct cgroup_subsys_state *css,
> +				 struct cftype *cft, struct seq_file *seq)
>  {
>  	struct cgrp_cset_link *link;
>  
>  	read_lock(&css_set_lock);
> -	list_for_each_entry(link, &cgrp->cset_links, cset_link) {
> +	list_for_each_entry(link, &css->cgroup->cset_links, cset_link) {
>  		struct css_set *cset = link->cset;
>  		struct task_struct *task;
>  		int count = 0;
> @@ -5650,9 +5654,9 @@ static int cgroup_css_links_read(struct cgroup *cgrp,
>  	return 0;
>  }
>  
> -static u64 releasable_read(struct cgroup *cgrp, struct cftype *cft)
> +static u64 releasable_read(struct cgroup_subsys_state *css, struct cftype *cft)
>  {
> -	return test_bit(CGRP_RELEASABLE, &cgrp->flags);
> +	return test_bit(CGRP_RELEASABLE, &css->cgroup->flags);
>  }
>  
>  static struct cftype debug_files[] =  {
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index f03a857..19613ba 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -245,7 +245,7 @@ out:
>  
>  /**
>   * update_if_frozen - update whether a cgroup finished freezing
> - * @cgroup: cgroup of interest
> + * @css: css of interest
>   *
>   * Once FREEZING is initiated, transition to FROZEN is lazily updated by
>   * calling this function.  If the current state is FREEZING but not FROZEN,
> @@ -256,12 +256,12 @@ out:
>   * update_if_frozen() on all descendants prior to invoking this function.
>   *
>   * Task states and freezer state might disagree while tasks are being
> - * migrated into or out of @cgroup, so we can't verify task states against
> + * migrated into or out of @css, so we can't verify task states against
>   * @freezer state here.  See freezer_attach() for details.
>   */
> -static void update_if_frozen(struct cgroup *cgroup)
> +static void update_if_frozen(struct cgroup_subsys_state *css)
>  {
> -	struct freezer *freezer = cgroup_freezer(cgroup);
> +	struct freezer *freezer = css_freezer(css);
>  	struct cgroup *pos;
>  	struct cgroup_iter it;
>  	struct task_struct *task;
> @@ -275,7 +275,7 @@ static void update_if_frozen(struct cgroup *cgroup)
>  		goto out_unlock;
>  
>  	/* are all (live) children frozen? */
> -	cgroup_for_each_child(pos, cgroup) {
> +	cgroup_for_each_child(pos, css->cgroup) {
>  		struct freezer *child = cgroup_freezer(pos);
>  
>  		if ((child->state & CGROUP_FREEZER_ONLINE) &&
> @@ -284,9 +284,9 @@ static void update_if_frozen(struct cgroup *cgroup)
>  	}
>  
>  	/* are all tasks frozen? */
> -	cgroup_iter_start(cgroup, &it);
> +	cgroup_iter_start(css->cgroup, &it);
>  
> -	while ((task = cgroup_iter_next(cgroup, &it))) {
> +	while ((task = cgroup_iter_next(css->cgroup, &it))) {
>  		if (freezing(task)) {
>  			/*
>  			 * freezer_should_skip() indicates that the task
> @@ -301,12 +301,12 @@ static void update_if_frozen(struct cgroup *cgroup)
>  
>  	freezer->state |= CGROUP_FROZEN;
>  out_iter_end:
> -	cgroup_iter_end(cgroup, &it);
> +	cgroup_iter_end(css->cgroup, &it);
>  out_unlock:
>  	spin_unlock_irq(&freezer->lock);
>  }
>  
> -static int freezer_read(struct cgroup *cgroup, struct cftype *cft,
> +static int freezer_read(struct cgroup_subsys_state *css, struct cftype *cft,
>  			struct seq_file *m)
>  {
>  	struct cgroup *pos;
> @@ -314,13 +314,13 @@ static int freezer_read(struct cgroup *cgroup, struct cftype *cft,
>  	rcu_read_lock();
>  
>  	/* update states bottom-up */
> -	cgroup_for_each_descendant_post(pos, cgroup)
> -		update_if_frozen(pos);
> -	update_if_frozen(cgroup);
> +	cgroup_for_each_descendant_post(pos, css->cgroup)
> +		update_if_frozen(cgroup_css(pos, freezer_subsys_id));
> +	update_if_frozen(css);
>  
>  	rcu_read_unlock();
>  
> -	seq_puts(m, freezer_state_strs(cgroup_freezer(cgroup)->state));
> +	seq_puts(m, freezer_state_strs(css_freezer(css)->state));
>  	seq_putc(m, '\n');
>  	return 0;
>  }
> @@ -426,7 +426,7 @@ static void freezer_change_state(struct freezer *freezer, bool freeze)
>  	rcu_read_unlock();
>  }
>  
> -static int freezer_write(struct cgroup *cgroup, struct cftype *cft,
> +static int freezer_write(struct cgroup_subsys_state *css, struct cftype *cft,
>  			 const char *buffer)
>  {
>  	bool freeze;
> @@ -438,20 +438,22 @@ static int freezer_write(struct cgroup *cgroup, struct cftype *cft,
>  	else
>  		return -EINVAL;
>  
> -	freezer_change_state(cgroup_freezer(cgroup), freeze);
> +	freezer_change_state(css_freezer(css), freeze);
>  	return 0;
>  }
>  
> -static u64 freezer_self_freezing_read(struct cgroup *cgroup, struct cftype *cft)
> +static u64 freezer_self_freezing_read(struct cgroup_subsys_state *css,
> +				      struct cftype *cft)
>  {
> -	struct freezer *freezer = cgroup_freezer(cgroup);
> +	struct freezer *freezer = css_freezer(css);
>  
>  	return (bool)(freezer->state & CGROUP_FREEZING_SELF);
>  }
>  
> -static u64 freezer_parent_freezing_read(struct cgroup *cgroup, struct cftype *cft)
> +static u64 freezer_parent_freezing_read(struct cgroup_subsys_state *css,
> +					struct cftype *cft)
>  {
> -	struct freezer *freezer = cgroup_freezer(cgroup);
> +	struct freezer *freezer = css_freezer(css);
>  
>  	return (bool)(freezer->state & CGROUP_FREEZING_PARENT);
>  }
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 8ce3fdc..89b76e1 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -1603,9 +1603,10 @@ typedef enum {
>  	FILE_SPREAD_SLAB,
>  } cpuset_filetype_t;
>  
> -static int cpuset_write_u64(struct cgroup *cgrp, struct cftype *cft, u64 val)
> +static int cpuset_write_u64(struct cgroup_subsys_state *css, struct cftype *cft,
> +			    u64 val)
>  {
> -	struct cpuset *cs = cgroup_cs(cgrp);
> +	struct cpuset *cs = css_cs(css);
>  	cpuset_filetype_t type = cft->private;
>  	int retval = -ENODEV;
>  
> @@ -1650,9 +1651,10 @@ out_unlock:
>  	return retval;
>  }
>  
> -static int cpuset_write_s64(struct cgroup *cgrp, struct cftype *cft, s64 val)
> +static int cpuset_write_s64(struct cgroup_subsys_state *css, struct cftype *cft,
> +			    s64 val)
>  {
> -	struct cpuset *cs = cgroup_cs(cgrp);
> +	struct cpuset *cs = css_cs(css);
>  	cpuset_filetype_t type = cft->private;
>  	int retval = -ENODEV;
>  
> @@ -1676,10 +1678,10 @@ out_unlock:
>  /*
>   * Common handling for a write to a "cpus" or "mems" file.
>   */
> -static int cpuset_write_resmask(struct cgroup *cgrp, struct cftype *cft,
> -				const char *buf)
> +static int cpuset_write_resmask(struct cgroup_subsys_state *css,
> +				struct cftype *cft, const char *buf)
>  {
> -	struct cpuset *cs = cgroup_cs(cgrp);
> +	struct cpuset *cs = css_cs(css);
>  	struct cpuset *trialcs;
>  	int retval = -ENODEV;
>  
> @@ -1758,13 +1760,12 @@ static size_t cpuset_sprintf_memlist(char *page, struct cpuset *cs)
>  	return count;
>  }
>  
> -static ssize_t cpuset_common_file_read(struct cgroup *cgrp,
> -				       struct cftype *cft,
> -				       struct file *file,
> -				       char __user *buf,
> -				       size_t nbytes, loff_t *ppos)
> +static ssize_t cpuset_common_file_read(struct cgroup_subsys_state *css,
> +				       struct cftype *cft, struct file *file,
> +				       char __user *buf, size_t nbytes,
> +				       loff_t *ppos)
>  {
> -	struct cpuset *cs = cgroup_cs(cgrp);
> +	struct cpuset *cs = css_cs(css);
>  	cpuset_filetype_t type = cft->private;
>  	char *page;
>  	ssize_t retval = 0;
> @@ -1794,9 +1795,9 @@ out:
>  	return retval;
>  }
>  
> -static u64 cpuset_read_u64(struct cgroup *cgrp, struct cftype *cft)
> +static u64 cpuset_read_u64(struct cgroup_subsys_state *css, struct cftype *cft)
>  {
> -	struct cpuset *cs = cgroup_cs(cgrp);
> +	struct cpuset *cs = css_cs(css);
>  	cpuset_filetype_t type = cft->private;
>  	switch (type) {
>  	case FILE_CPU_EXCLUSIVE:
> @@ -1825,9 +1826,9 @@ static u64 cpuset_read_u64(struct cgroup *cgrp, struct cftype *cft)
>  	return 0;
>  }
>  
> -static s64 cpuset_read_s64(struct cgroup *cgrp, struct cftype *cft)
> +static s64 cpuset_read_s64(struct cgroup_subsys_state *css, struct cftype *cft)
>  {
> -	struct cpuset *cs = cgroup_cs(cgrp);
> +	struct cpuset *cs = css_cs(css);
>  	cpuset_filetype_t type = cft->private;
>  	switch (type) {
>  	case FILE_SCHED_RELAX_DOMAIN_LEVEL:
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 622b7ef..cc9a492 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -7088,12 +7088,6 @@ static inline struct task_group *css_tg(struct cgroup_subsys_state *css)
>  	return css ? container_of(css, struct task_group, css) : NULL;
>  }
>  
> -/* return corresponding task_group object of a cgroup */
> -static inline struct task_group *cgroup_tg(struct cgroup *cgrp)
> -{
> -	return css_tg(cgroup_css(cgrp, cpu_cgroup_subsys_id));
> -}
> -
>  static struct cgroup_subsys_state *
>  cpu_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
>  {
> @@ -7179,15 +7173,16 @@ static void cpu_cgroup_exit(struct cgroup_subsys_state *css,
>  }
>  
>  #ifdef CONFIG_FAIR_GROUP_SCHED
> -static int cpu_shares_write_u64(struct cgroup *cgrp, struct cftype *cftype,
> -				u64 shareval)
> +static int cpu_shares_write_u64(struct cgroup_subsys_state *css,
> +				struct cftype *cftype, u64 shareval)
>  {
> -	return sched_group_set_shares(cgroup_tg(cgrp), scale_load(shareval));
> +	return sched_group_set_shares(css_tg(css), scale_load(shareval));
>  }
>  
> -static u64 cpu_shares_read_u64(struct cgroup *cgrp, struct cftype *cft)
> +static u64 cpu_shares_read_u64(struct cgroup_subsys_state *css,
> +			       struct cftype *cft)
>  {
> -	struct task_group *tg = cgroup_tg(cgrp);
> +	struct task_group *tg = css_tg(css);
>  
>  	return (u64) scale_load_down(tg->shares);
>  }
> @@ -7309,26 +7304,28 @@ long tg_get_cfs_period(struct task_group *tg)
>  	return cfs_period_us;
>  }
>  
> -static s64 cpu_cfs_quota_read_s64(struct cgroup *cgrp, struct cftype *cft)
> +static s64 cpu_cfs_quota_read_s64(struct cgroup_subsys_state *css,
> +				  struct cftype *cft)
>  {
> -	return tg_get_cfs_quota(cgroup_tg(cgrp));
> +	return tg_get_cfs_quota(css_tg(css));
>  }
>  
> -static int cpu_cfs_quota_write_s64(struct cgroup *cgrp, struct cftype *cftype,
> -				s64 cfs_quota_us)
> +static int cpu_cfs_quota_write_s64(struct cgroup_subsys_state *css,
> +				   struct cftype *cftype, s64 cfs_quota_us)
>  {
> -	return tg_set_cfs_quota(cgroup_tg(cgrp), cfs_quota_us);
> +	return tg_set_cfs_quota(css_tg(css), cfs_quota_us);
>  }
>  
> -static u64 cpu_cfs_period_read_u64(struct cgroup *cgrp, struct cftype *cft)
> +static u64 cpu_cfs_period_read_u64(struct cgroup_subsys_state *css,
> +				   struct cftype *cft)
>  {
> -	return tg_get_cfs_period(cgroup_tg(cgrp));
> +	return tg_get_cfs_period(css_tg(css));
>  }
>  
> -static int cpu_cfs_period_write_u64(struct cgroup *cgrp, struct cftype *cftype,
> -				u64 cfs_period_us)
> +static int cpu_cfs_period_write_u64(struct cgroup_subsys_state *css,
> +				    struct cftype *cftype, u64 cfs_period_us)
>  {
> -	return tg_set_cfs_period(cgroup_tg(cgrp), cfs_period_us);
> +	return tg_set_cfs_period(css_tg(css), cfs_period_us);
>  }
>  
>  struct cfs_schedulable_data {
> @@ -7409,10 +7406,10 @@ static int __cfs_schedulable(struct task_group *tg, u64 period, u64 quota)
>  	return ret;
>  }
>  
> -static int cpu_stats_show(struct cgroup *cgrp, struct cftype *cft,
> +static int cpu_stats_show(struct cgroup_subsys_state *css, struct cftype *cft,
>  		struct cgroup_map_cb *cb)
>  {
> -	struct task_group *tg = cgroup_tg(cgrp);
> +	struct task_group *tg = css_tg(css);
>  	struct cfs_bandwidth *cfs_b = &tg->cfs_bandwidth;
>  
>  	cb->fill(cb, "nr_periods", cfs_b->nr_periods);
> @@ -7425,26 +7422,28 @@ static int cpu_stats_show(struct cgroup *cgrp, struct cftype *cft,
>  #endif /* CONFIG_FAIR_GROUP_SCHED */
>  
>  #ifdef CONFIG_RT_GROUP_SCHED
> -static int cpu_rt_runtime_write(struct cgroup *cgrp, struct cftype *cft,
> -				s64 val)
> +static int cpu_rt_runtime_write(struct cgroup_subsys_state *css,
> +				struct cftype *cft, s64 val)
>  {
> -	return sched_group_set_rt_runtime(cgroup_tg(cgrp), val);
> +	return sched_group_set_rt_runtime(css_tg(css), val);
>  }
>  
> -static s64 cpu_rt_runtime_read(struct cgroup *cgrp, struct cftype *cft)
> +static s64 cpu_rt_runtime_read(struct cgroup_subsys_state *css,
> +			       struct cftype *cft)
>  {
> -	return sched_group_rt_runtime(cgroup_tg(cgrp));
> +	return sched_group_rt_runtime(css_tg(css));
>  }
>  
> -static int cpu_rt_period_write_uint(struct cgroup *cgrp, struct cftype *cftype,
> -		u64 rt_period_us)
> +static int cpu_rt_period_write_uint(struct cgroup_subsys_state *css,
> +				    struct cftype *cftype, u64 rt_period_us)
>  {
> -	return sched_group_set_rt_period(cgroup_tg(cgrp), rt_period_us);
> +	return sched_group_set_rt_period(css_tg(css), rt_period_us);
>  }
>  
> -static u64 cpu_rt_period_read_uint(struct cgroup *cgrp, struct cftype *cft)
> +static u64 cpu_rt_period_read_uint(struct cgroup_subsys_state *css,
> +				   struct cftype *cft)
>  {
> -	return sched_group_rt_period(cgroup_tg(cgrp));
> +	return sched_group_rt_period(css_tg(css));
>  }
>  #endif /* CONFIG_RT_GROUP_SCHED */
>  
> diff --git a/kernel/sched/cpuacct.c b/kernel/sched/cpuacct.c
> index 1b784d9..f64722f 100644
> --- a/kernel/sched/cpuacct.c
> +++ b/kernel/sched/cpuacct.c
> @@ -38,12 +38,6 @@ static inline struct cpuacct *css_ca(struct cgroup_subsys_state *css)
>  	return css ? container_of(css, struct cpuacct, css) : NULL;
>  }
>  
> -/* return cpu accounting group corresponding to this container */
> -static inline struct cpuacct *cgroup_ca(struct cgroup *cgrp)
> -{
> -	return css_ca(cgroup_css(cgrp, cpuacct_subsys_id));
> -}
> -
>  /* return cpu accounting group to which this task belongs */
>  static inline struct cpuacct *task_ca(struct task_struct *tsk)
>  {
> @@ -138,9 +132,9 @@ static void cpuacct_cpuusage_write(struct cpuacct *ca, int cpu, u64 val)
>  }
>  
>  /* return total cpu usage (in nanoseconds) of a group */
> -static u64 cpuusage_read(struct cgroup *cgrp, struct cftype *cft)
> +static u64 cpuusage_read(struct cgroup_subsys_state *css, struct cftype *cft)
>  {
> -	struct cpuacct *ca = cgroup_ca(cgrp);
> +	struct cpuacct *ca = css_ca(css);
>  	u64 totalcpuusage = 0;
>  	int i;
>  
> @@ -150,10 +144,10 @@ static u64 cpuusage_read(struct cgroup *cgrp, struct cftype *cft)
>  	return totalcpuusage;
>  }
>  
> -static int cpuusage_write(struct cgroup *cgrp, struct cftype *cftype,
> -								u64 reset)
> +static int cpuusage_write(struct cgroup_subsys_state *css, struct cftype *cft,
> +			  u64 reset)
>  {
> -	struct cpuacct *ca = cgroup_ca(cgrp);
> +	struct cpuacct *ca = css_ca(css);
>  	int err = 0;
>  	int i;
>  
> @@ -169,10 +163,10 @@ out:
>  	return err;
>  }
>  
> -static int cpuacct_percpu_seq_read(struct cgroup *cgroup, struct cftype *cft,
> -				   struct seq_file *m)
> +static int cpuacct_percpu_seq_read(struct cgroup_subsys_state *css,
> +				   struct cftype *cft, struct seq_file *m)
>  {
> -	struct cpuacct *ca = cgroup_ca(cgroup);
> +	struct cpuacct *ca = css_ca(css);
>  	u64 percpu;
>  	int i;
>  
> @@ -189,10 +183,10 @@ static const char * const cpuacct_stat_desc[] = {
>  	[CPUACCT_STAT_SYSTEM] = "system",
>  };
>  
> -static int cpuacct_stats_show(struct cgroup *cgrp, struct cftype *cft,
> -			      struct cgroup_map_cb *cb)
> +static int cpuacct_stats_show(struct cgroup_subsys_state *css,
> +			      struct cftype *cft, struct cgroup_map_cb *cb)
>  {
> -	struct cpuacct *ca = cgroup_ca(cgrp);
> +	struct cpuacct *ca = css_ca(css);
>  	int cpu;
>  	s64 val = 0;
>  
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index e213243..bda8e44 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -40,12 +40,6 @@ struct hugetlb_cgroup *hugetlb_cgroup_from_css(struct cgroup_subsys_state *s)
>  }
>  
>  static inline
> -struct hugetlb_cgroup *hugetlb_cgroup_from_cgroup(struct cgroup *cgroup)
> -{
> -	return hugetlb_cgroup_from_css(cgroup_css(cgroup, hugetlb_subsys_id));
> -}
> -
> -static inline
>  struct hugetlb_cgroup *hugetlb_cgroup_from_task(struct task_struct *task)
>  {
>  	return hugetlb_cgroup_from_css(task_css(task, hugetlb_subsys_id));
> @@ -248,14 +242,15 @@ void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
>  	return;
>  }
>  
> -static ssize_t hugetlb_cgroup_read(struct cgroup *cgroup, struct cftype *cft,
> -				   struct file *file, char __user *buf,
> -				   size_t nbytes, loff_t *ppos)
> +static ssize_t hugetlb_cgroup_read(struct cgroup_subsys_state *css,
> +				   struct cftype *cft, struct file *file,
> +				   char __user *buf, size_t nbytes,
> +				   loff_t *ppos)
>  {
>  	u64 val;
>  	char str[64];
>  	int idx, name, len;
> -	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cgroup);
> +	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(css);
>  
>  	idx = MEMFILE_IDX(cft->private);
>  	name = MEMFILE_ATTR(cft->private);
> @@ -265,12 +260,12 @@ static ssize_t hugetlb_cgroup_read(struct cgroup *cgroup, struct cftype *cft,
>  	return simple_read_from_buffer(buf, nbytes, ppos, str, len);
>  }
>  
> -static int hugetlb_cgroup_write(struct cgroup *cgroup, struct cftype *cft,
> -				const char *buffer)
> +static int hugetlb_cgroup_write(struct cgroup_subsys_state *css,
> +				struct cftype *cft, const char *buffer)
>  {
>  	int idx, name, ret;
>  	unsigned long long val;
> -	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cgroup);
> +	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(css);
>  
>  	idx = MEMFILE_IDX(cft->private);
>  	name = MEMFILE_ATTR(cft->private);
> @@ -295,10 +290,11 @@ static int hugetlb_cgroup_write(struct cgroup *cgroup, struct cftype *cft,
>  	return ret;
>  }
>  
> -static int hugetlb_cgroup_reset(struct cgroup *cgroup, unsigned int event)
> +static int hugetlb_cgroup_reset(struct cgroup_subsys_state *css,
> +				unsigned int event)
>  {
>  	int idx, name, ret = 0;
> -	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cgroup);
> +	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(css);
>  
>  	idx = MEMFILE_IDX(event);
>  	name = MEMFILE_ATTR(event);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 32cca0f..ab64dfc 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -483,7 +483,6 @@ enum res_type {
>   */
>  static DEFINE_MUTEX(memcg_create_mutex);
>  
> -static inline
>  struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
>  {
>  	return s ? container_of(s, struct mem_cgroup, css) : NULL;
> @@ -1035,7 +1034,7 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
>  		preempt_enable();
>  }
>  
> -struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
> +static inline struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
>  {
>  	return mem_cgroup_from_css(cgroup_css(cont, mem_cgroup_subsys_id));
>  }
> @@ -2951,10 +2950,10 @@ static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
>  }
>  
>  #ifdef CONFIG_SLABINFO
> -static int mem_cgroup_slabinfo_read(struct cgroup *cont, struct cftype *cft,
> -					struct seq_file *m)
> +static int mem_cgroup_slabinfo_read(struct cgroup_subsys_state *css,
> +				    struct cftype *cft, struct seq_file *m)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	struct memcg_cache_params *params;
>  
>  	if (!memcg_can_account_kmem(memcg))
> @@ -4999,9 +4998,10 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
>  	return 0;
>  }
>  
> -static int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
> +static int mem_cgroup_force_empty_write(struct cgroup_subsys_state *css,
> +					unsigned int event)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	int ret;
>  
>  	if (mem_cgroup_is_root(memcg))
> @@ -5014,16 +5014,17 @@ static int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
>  }
>  
>  
> -static u64 mem_cgroup_hierarchy_read(struct cgroup *cont, struct cftype *cft)
> +static u64 mem_cgroup_hierarchy_read(struct cgroup_subsys_state *css,
> +				     struct cftype *cft)
>  {
> -	return mem_cgroup_from_cont(cont)->use_hierarchy;
> +	return mem_cgroup_from_css(css)->use_hierarchy;
>  }
>  
> -static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
> -					u64 val)
> +static int mem_cgroup_hierarchy_write(struct cgroup_subsys_state *css,
> +				      struct cftype *cft, u64 val)
>  {
>  	int retval = 0;
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	struct mem_cgroup *parent_memcg = mem_cgroup_from_css(css_parent(&memcg->css));
>  
>  	mutex_lock(&memcg_create_mutex);
> @@ -5094,11 +5095,11 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
>  	return val << PAGE_SHIFT;
>  }
>  
> -static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
> -			       struct file *file, char __user *buf,
> -			       size_t nbytes, loff_t *ppos)
> +static ssize_t mem_cgroup_read(struct cgroup_subsys_state *css,
> +			       struct cftype *cft, struct file *file,
> +			       char __user *buf, size_t nbytes, loff_t *ppos)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	char str[64];
>  	u64 val;
>  	int name, len;
> @@ -5131,11 +5132,11 @@ static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
>  	return simple_read_from_buffer(buf, nbytes, ppos, str, len);
>  }
>  
> -static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
> +static int memcg_update_kmem_limit(struct cgroup_subsys_state *css, u64 val)
>  {
>  	int ret = -EINVAL;
>  #ifdef CONFIG_MEMCG_KMEM
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	/*
>  	 * For simplicity, we won't allow this to be disabled.  It also can't
>  	 * be changed if the cgroup has children already, or if tasks had
> @@ -5151,7 +5152,7 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
>  	mutex_lock(&memcg_create_mutex);
>  	mutex_lock(&set_limit_mutex);
>  	if (!memcg->kmem_account_flags && val != RESOURCE_MAX) {
> -		if (cgroup_task_count(cont) || memcg_has_children(memcg)) {
> +		if (cgroup_task_count(css->cgroup) || memcg_has_children(memcg)) {
>  			ret = -EBUSY;
>  			goto out;
>  		}
> @@ -5221,10 +5222,10 @@ out:
>   * The user of this function is...
>   * RES_LIMIT.
>   */
> -static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
> +static int mem_cgroup_write(struct cgroup_subsys_state *css, struct cftype *cft,
>  			    const char *buffer)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	enum res_type type;
>  	int name;
>  	unsigned long long val;
> @@ -5248,7 +5249,7 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
>  		else if (type == _MEMSWAP)
>  			ret = mem_cgroup_resize_memsw_limit(memcg, val);
>  		else if (type == _KMEM)
> -			ret = memcg_update_kmem_limit(cont, val);
> +			ret = memcg_update_kmem_limit(css, val);
>  		else
>  			return -EINVAL;
>  		break;
> @@ -5297,9 +5298,9 @@ out:
>  	*memsw_limit = min_memsw_limit;
>  }
>  
> -static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
> +static int mem_cgroup_reset(struct cgroup_subsys_state *css, unsigned int event)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	int name;
>  	enum res_type type;
>  
> @@ -5332,17 +5333,17 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
>  	return 0;
>  }
>  
> -static u64 mem_cgroup_move_charge_read(struct cgroup *cgrp,
> +static u64 mem_cgroup_move_charge_read(struct cgroup_subsys_state *css,
>  					struct cftype *cft)
>  {
> -	return mem_cgroup_from_cont(cgrp)->move_charge_at_immigrate;
> +	return mem_cgroup_from_css(css)->move_charge_at_immigrate;
>  }
>  
>  #ifdef CONFIG_MMU
> -static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
> +static int mem_cgroup_move_charge_write(struct cgroup_subsys_state *css,
>  					struct cftype *cft, u64 val)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  
>  	if (val >= (1 << NR_MOVE_TYPE))
>  		return -EINVAL;
> @@ -5357,7 +5358,7 @@ static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
>  	return 0;
>  }
>  #else
> -static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
> +static int mem_cgroup_move_charge_write(struct cgroup_subsys_state *css,
>  					struct cftype *cft, u64 val)
>  {
>  	return -ENOSYS;
> @@ -5365,13 +5366,13 @@ static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
>  #endif
>  
>  #ifdef CONFIG_NUMA
> -static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
> -				      struct seq_file *m)
> +static int memcg_numa_stat_show(struct cgroup_subsys_state *css,
> +				struct cftype *cft, struct seq_file *m)
>  {
>  	int nid;
>  	unsigned long total_nr, file_nr, anon_nr, unevictable_nr;
>  	unsigned long node_nr;
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  
>  	total_nr = mem_cgroup_nr_lru_pages(memcg, LRU_ALL);
>  	seq_printf(m, "total=%lu", total_nr);
> @@ -5416,10 +5417,10 @@ static inline void mem_cgroup_lru_names_not_uptodate(void)
>  	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
>  }
>  
> -static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
> +static int memcg_stat_show(struct cgroup_subsys_state *css, struct cftype *cft,
>  				 struct seq_file *m)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	struct mem_cgroup *mi;
>  	unsigned int i;
>  
> @@ -5503,17 +5504,18 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
>  	return 0;
>  }
>  
> -static u64 mem_cgroup_swappiness_read(struct cgroup *cgrp, struct cftype *cft)
> +static u64 mem_cgroup_swappiness_read(struct cgroup_subsys_state *css,
> +				      struct cftype *cft)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  
>  	return mem_cgroup_swappiness(memcg);
>  }
>  
> -static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
> -				       u64 val)
> +static int mem_cgroup_swappiness_write(struct cgroup_subsys_state *css,
> +				       struct cftype *cft, u64 val)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(&memcg->css));
>  
>  	if (val > 100 || !parent)
> @@ -5829,10 +5831,10 @@ static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
>  	spin_unlock(&memcg_oom_lock);
>  }
>  
> -static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
> +static int mem_cgroup_oom_control_read(struct cgroup_subsys_state *css,
>  	struct cftype *cft,  struct cgroup_map_cb *cb)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  
>  	cb->fill(cb, "oom_kill_disable", memcg->oom_kill_disable);
>  
> @@ -5843,10 +5845,10 @@ static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
>  	return 0;
>  }
>  
> -static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
> +static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
>  	struct cftype *cft, u64 val)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(&memcg->css));
>  
>  	/* cannot set to root cgroup and only 0 and 1 are allowed */
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 7f1654d..2a8a736 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -81,8 +81,8 @@ static struct vmpressure *cg_to_vmpressure(struct cgroup *cg)
>  
>  static struct vmpressure *vmpressure_parent(struct vmpressure *vmpr)
>  {
> -	struct cgroup *cg = vmpressure_to_css(vmpr)->cgroup;
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cg);
> +	struct cgroup_subsys_state *css = vmpressure_to_css(vmpr);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  
>  	memcg = parent_mem_cgroup(memcg);
>  	if (!memcg)
> diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
> index 8d095b4..e00f60e 100644
> --- a/net/core/netprio_cgroup.c
> +++ b/net/core/netprio_cgroup.c
> @@ -168,15 +168,14 @@ static void cgrp_css_free(struct cgroup_subsys_state *css)
>  	kfree(css);
>  }
>  
> -static u64 read_prioidx(struct cgroup *cgrp, struct cftype *cft)
> +static u64 read_prioidx(struct cgroup_subsys_state *css, struct cftype *cft)
>  {
> -	return cgrp->id;
> +	return css->cgroup->id;
>  }
>  
> -static int read_priomap(struct cgroup *cont, struct cftype *cft,
> +static int read_priomap(struct cgroup_subsys_state *css, struct cftype *cft,
>  			struct cgroup_map_cb *cb)
>  {
> -	struct cgroup_subsys_state *css = cgroup_css(cont, net_prio_subsys_id);
>  	struct net_device *dev;
>  
>  	rcu_read_lock();
> @@ -186,10 +185,9 @@ static int read_priomap(struct cgroup *cont, struct cftype *cft,
>  	return 0;
>  }
>  
> -static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
> +static int write_priomap(struct cgroup_subsys_state *css, struct cftype *cft,
>  			 const char *buffer)
>  {
> -	struct cgroup_subsys_state *css = cgroup_css(cgrp, net_prio_subsys_id);
>  	char devname[IFNAMSIZ + 1];
>  	struct net_device *dev;
>  	u32 prio;
> diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
> index da14436..8a57d79 100644
> --- a/net/ipv4/tcp_memcontrol.c
> +++ b/net/ipv4/tcp_memcontrol.c
> @@ -132,10 +132,10 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
>  	return 0;
>  }
>  
> -static int tcp_cgroup_write(struct cgroup *cont, struct cftype *cft,
> +static int tcp_cgroup_write(struct cgroup_subsys_state *css, struct cftype *cft,
>  			    const char *buffer)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	unsigned long long val;
>  	int ret = 0;
>  
> @@ -180,9 +180,9 @@ static u64 tcp_read_usage(struct mem_cgroup *memcg)
>  	return res_counter_read_u64(&tcp->tcp_memory_allocated, RES_USAGE);
>  }
>  
> -static u64 tcp_cgroup_read(struct cgroup *cont, struct cftype *cft)
> +static u64 tcp_cgroup_read(struct cgroup_subsys_state *css, struct cftype *cft)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	u64 val;
>  
>  	switch (cft->private) {
> @@ -202,13 +202,13 @@ static u64 tcp_cgroup_read(struct cgroup *cont, struct cftype *cft)
>  	return val;
>  }
>  
> -static int tcp_cgroup_reset(struct cgroup *cont, unsigned int event)
> +static int tcp_cgroup_reset(struct cgroup_subsys_state *css, unsigned int event)
>  {
>  	struct mem_cgroup *memcg;
>  	struct tcp_memcontrol *tcp;
>  	struct cg_proto *cg_proto;
>  
> -	memcg = mem_cgroup_from_cont(cont);
> +	memcg = mem_cgroup_from_css(css);
>  	cg_proto = tcp_prot.proto_cgroup(memcg);
>  	if (!cg_proto)
>  		return 0;
> diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
> index dc39838..8ea1184 100644
> --- a/net/sched/cls_cgroup.c
> +++ b/net/sched/cls_cgroup.c
> @@ -28,11 +28,6 @@ static inline struct cgroup_cls_state *css_cls_state(struct cgroup_subsys_state
>  	return css ? container_of(css, struct cgroup_cls_state, css) : NULL;
>  }
>  
> -static inline struct cgroup_cls_state *cgrp_cls_state(struct cgroup *cgrp)
> -{
> -	return css_cls_state(cgroup_css(cgrp, net_cls_subsys_id));
> -}
> -
>  static inline struct cgroup_cls_state *task_cls_state(struct task_struct *p)
>  {
>  	return css_cls_state(task_css(p, net_cls_subsys_id));
> @@ -87,14 +82,15 @@ static void cgrp_attach(struct cgroup_subsys_state *css,
>  	}
>  }
>  
> -static u64 read_classid(struct cgroup *cgrp, struct cftype *cft)
> +static u64 read_classid(struct cgroup_subsys_state *css, struct cftype *cft)
>  {
> -	return cgrp_cls_state(cgrp)->classid;
> +	return css_cls_state(css)->classid;
>  }
>  
> -static int write_classid(struct cgroup *cgrp, struct cftype *cft, u64 value)
> +static int write_classid(struct cgroup_subsys_state *css, struct cftype *cft,
> +			 u64 value)
>  {
> -	cgrp_cls_state(cgrp)->classid = (u32) value;
> +	css_cls_state(css)->classid = (u32) value;
>  	return 0;
>  }
>  
> diff --git a/security/device_cgroup.c b/security/device_cgroup.c
> index 7293ac4..e0ca464 100644
> --- a/security/device_cgroup.c
> +++ b/security/device_cgroup.c
> @@ -289,10 +289,10 @@ static void set_majmin(char *str, unsigned m)
>  		sprintf(str, "%u", m);
>  }
>  
> -static int devcgroup_seq_read(struct cgroup *cgroup, struct cftype *cft,
> -				struct seq_file *m)
> +static int devcgroup_seq_read(struct cgroup_subsys_state *css,
> +			      struct cftype *cft, struct seq_file *m)
>  {
> -	struct dev_cgroup *devcgroup = cgroup_to_devcgroup(cgroup);
> +	struct dev_cgroup *devcgroup = css_to_devcgroup(css);
>  	struct dev_exception_item *ex;
>  	char maj[MAJMINLEN], min[MAJMINLEN], acc[ACCLEN];
>  
> @@ -669,13 +669,13 @@ static int devcgroup_update_access(struct dev_cgroup *devcgroup,
>  	return rc;
>  }
>  
> -static int devcgroup_access_write(struct cgroup *cgrp, struct cftype *cft,
> -				  const char *buffer)
> +static int devcgroup_access_write(struct cgroup_subsys_state *css,
> +				  struct cftype *cft, const char *buffer)
>  {
>  	int retval;
>  
>  	mutex_lock(&devcgroup_mutex);
> -	retval = devcgroup_update_access(cgroup_to_devcgroup(cgrp),
> +	retval = devcgroup_update_access(css_to_devcgroup(css),
>  					 cft->private, buffer);
>  	mutex_unlock(&devcgroup_mutex);
>  	return retval;
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
