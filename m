From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 03/12] memcg: convert away from cftype->read() and
	->read_map()
Date: Thu, 28 Nov 2013 09:26:38 +0100
Message-ID: <20131128082638.GB2761@dhcp22.suse.cz>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
	<1385595759-17656-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1385595759-17656-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed 27-11-13 18:42:30, Tejun Heo wrote:
> In preparation of conversion to kernfs, cgroup file handling is being
> consolidated so that it can be easily mapped to the seq_file based
> interface of kernfs.
> 
> cftype->read_map() doesn't add any value and being replaced with
> ->read_seq_string(), and all users of cftype->read() can be easily
> served, usually better, by seq_file and other methods.
> 
> Update mem_cgroup_read() to return u64 instead of printing itself and
> rename it to mem_cgroup_read_u64(), and update
> mem_cgroup_oom_control_read() to use ->read_seq_string() instead of
> ->read_map().
> 
> This patch doesn't make any visible behavior changes.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

Thanks!

> ---
>  mm/memcontrol.c | 49 +++++++++++++++++++++----------------------------
>  1 file changed, 21 insertions(+), 28 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7aa0d40..f149521 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5150,14 +5150,12 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
>  	return val << PAGE_SHIFT;
>  }
>  
> -static ssize_t mem_cgroup_read(struct cgroup_subsys_state *css,
> -			       struct cftype *cft, struct file *file,
> -			       char __user *buf, size_t nbytes, loff_t *ppos)
> +static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
> +				   struct cftype *cft)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> -	char str[64];
>  	u64 val;
> -	int name, len;
> +	int name;
>  	enum res_type type;
>  
>  	type = MEMFILE_TYPE(cft->private);
> @@ -5183,8 +5181,7 @@ static ssize_t mem_cgroup_read(struct cgroup_subsys_state *css,
>  		BUG();
>  	}
>  
> -	len = scnprintf(str, sizeof(str), "%llu\n", (unsigned long long)val);
> -	return simple_read_from_buffer(buf, nbytes, ppos, str, len);
> +	return val;
>  }
>  
>  static int memcg_update_kmem_limit(struct cgroup_subsys_state *css, u64 val)
> @@ -5911,16 +5908,12 @@ static void mem_cgroup_oom_unregister_event(struct mem_cgroup *memcg,
>  }
>  
>  static int mem_cgroup_oom_control_read(struct cgroup_subsys_state *css,
> -	struct cftype *cft,  struct cgroup_map_cb *cb)
> +				       struct cftype *cft, struct seq_file *sf)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  
> -	cb->fill(cb, "oom_kill_disable", memcg->oom_kill_disable);
> -
> -	if (atomic_read(&memcg->under_oom))
> -		cb->fill(cb, "under_oom", 1);
> -	else
> -		cb->fill(cb, "under_oom", 0);
> +	seq_printf(sf, "oom_kill_disable %d\n", memcg->oom_kill_disable);
> +	seq_printf(sf, "under_oom %d\n", (bool)atomic_read(&memcg->under_oom));
>  	return 0;
>  }
>  
> @@ -6239,31 +6232,31 @@ static struct cftype mem_cgroup_files[] = {
>  	{
>  		.name = "usage_in_bytes",
>  		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
> -		.read = mem_cgroup_read,
> +		.read_u64 = mem_cgroup_read_u64,
>  	},
>  	{
>  		.name = "max_usage_in_bytes",
>  		.private = MEMFILE_PRIVATE(_MEM, RES_MAX_USAGE),
>  		.trigger = mem_cgroup_reset,
> -		.read = mem_cgroup_read,
> +		.read_u64 = mem_cgroup_read_u64,
>  	},
>  	{
>  		.name = "limit_in_bytes",
>  		.private = MEMFILE_PRIVATE(_MEM, RES_LIMIT),
>  		.write_string = mem_cgroup_write,
> -		.read = mem_cgroup_read,
> +		.read_u64 = mem_cgroup_read_u64,
>  	},
>  	{
>  		.name = "soft_limit_in_bytes",
>  		.private = MEMFILE_PRIVATE(_MEM, RES_SOFT_LIMIT),
>  		.write_string = mem_cgroup_write,
> -		.read = mem_cgroup_read,
> +		.read_u64 = mem_cgroup_read_u64,
>  	},
>  	{
>  		.name = "failcnt",
>  		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
>  		.trigger = mem_cgroup_reset,
> -		.read = mem_cgroup_read,
> +		.read_u64 = mem_cgroup_read_u64,
>  	},
>  	{
>  		.name = "stat",
> @@ -6297,7 +6290,7 @@ static struct cftype mem_cgroup_files[] = {
>  	},
>  	{
>  		.name = "oom_control",
> -		.read_map = mem_cgroup_oom_control_read,
> +		.read_seq_string = mem_cgroup_oom_control_read,
>  		.write_u64 = mem_cgroup_oom_control_write,
>  		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
>  	},
> @@ -6315,24 +6308,24 @@ static struct cftype mem_cgroup_files[] = {
>  		.name = "kmem.limit_in_bytes",
>  		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
>  		.write_string = mem_cgroup_write,
> -		.read = mem_cgroup_read,
> +		.read_u64 = mem_cgroup_read_u64,
>  	},
>  	{
>  		.name = "kmem.usage_in_bytes",
>  		.private = MEMFILE_PRIVATE(_KMEM, RES_USAGE),
> -		.read = mem_cgroup_read,
> +		.read_u64 = mem_cgroup_read_u64,
>  	},
>  	{
>  		.name = "kmem.failcnt",
>  		.private = MEMFILE_PRIVATE(_KMEM, RES_FAILCNT),
>  		.trigger = mem_cgroup_reset,
> -		.read = mem_cgroup_read,
> +		.read_u64 = mem_cgroup_read_u64,
>  	},
>  	{
>  		.name = "kmem.max_usage_in_bytes",
>  		.private = MEMFILE_PRIVATE(_KMEM, RES_MAX_USAGE),
>  		.trigger = mem_cgroup_reset,
> -		.read = mem_cgroup_read,
> +		.read_u64 = mem_cgroup_read_u64,
>  	},
>  #ifdef CONFIG_SLABINFO
>  	{
> @@ -6349,25 +6342,25 @@ static struct cftype memsw_cgroup_files[] = {
>  	{
>  		.name = "memsw.usage_in_bytes",
>  		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
> -		.read = mem_cgroup_read,
> +		.read_u64 = mem_cgroup_read_u64,
>  	},
>  	{
>  		.name = "memsw.max_usage_in_bytes",
>  		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_MAX_USAGE),
>  		.trigger = mem_cgroup_reset,
> -		.read = mem_cgroup_read,
> +		.read_u64 = mem_cgroup_read_u64,
>  	},
>  	{
>  		.name = "memsw.limit_in_bytes",
>  		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_LIMIT),
>  		.write_string = mem_cgroup_write,
> -		.read = mem_cgroup_read,
> +		.read_u64 = mem_cgroup_read_u64,
>  	},
>  	{
>  		.name = "memsw.failcnt",
>  		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_FAILCNT),
>  		.trigger = mem_cgroup_reset,
> -		.read = mem_cgroup_read,
> +		.read_u64 = mem_cgroup_read_u64,
>  	},
>  	{ },	/* terminate */
>  };
> -- 
> 1.8.4.2
> 

-- 
Michal Hocko
SUSE Labs
