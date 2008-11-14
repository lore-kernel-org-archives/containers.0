From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Dynamically allocate struct mem_cgroup_stat_cpu memory
Date: Thu, 13 Nov 2008 19:18:37 -0800
Message-ID: <20081113191837.18ed2ade.akpm@linux-foundation.org>
References: <20081113164201.GV29067@bolzano.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752070AbYKNDTE@vger.kernel.org>
In-Reply-To: <20081113164201.GV29067@bolzano.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Jan Blunck <jblunck@suse.de>
Cc: Linux-Kernel Mailinglist <linux-kernel@vger.kernel.org>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

(cc containers@lists.osdl.org)

On Thu, 13 Nov 2008 17:42:01 +0100 Jan Blunck <jblunck@suse.de> wrote:

> When increasing NR_CPUS to 4096 the size of struct mem_cgroup is growing to
> 507904 bytes per instance on x86_64. This patch changes the allocation of
> struct mem_cgroup_stat_cpu to be based on the number of configured CPUs during
> boot time. The init_mem_cgroup still is that huge since it stays statically
> allocated and therefore uses the compile-time maximum.
> 
> Signed-off-by: Jan Blunck <jblunck@suse.de>
> ---
>  mm/memcontrol.c |   52 +++++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 43 insertions(+), 9 deletions(-)
> 
> Index: b/mm/memcontrol.c
> ===================================================================
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -59,7 +59,7 @@ struct mem_cgroup_stat_cpu {
>  } ____cacheline_aligned_in_smp;
>  
>  struct mem_cgroup_stat {
> -	struct mem_cgroup_stat_cpu cpustat[NR_CPUS];
> +	struct mem_cgroup_stat_cpu *cpustat;
>  };
>  
>  /*
> @@ -142,7 +142,10 @@ struct mem_cgroup {
>  	 */
>  	struct mem_cgroup_stat stat;
>  };
> -static struct mem_cgroup init_mem_cgroup;
> +static struct mem_cgroup_stat_cpu init_mem_cgroup_stat_cpu[NR_CPUS];
> +static struct mem_cgroup init_mem_cgroup = {
> +	.stat = { .cpustat = init_mem_cgroup_stat_cpu },
> +};
>  
>  /*
>   * We use the lower bit of the page->page_cgroup pointer as a bit spin
> @@ -1097,23 +1100,54 @@ static void free_mem_cgroup_per_zone_inf
>  static struct mem_cgroup *mem_cgroup_alloc(void)
>  {
>  	struct mem_cgroup *mem;
> +	struct mem_cgroup_stat_cpu *cpustat;
> +	size_t statsize = nr_cpu_ids * sizeof(*cpustat);
>  
> -	if (sizeof(*mem) < PAGE_SIZE)
> -		mem = kmalloc(sizeof(*mem), GFP_KERNEL);
> -	else
> +	if (sizeof(*mem) > PAGE_SIZE) {
>  		mem = vmalloc(sizeof(*mem));
> -
> -	if (mem)
> +		if (!mem)
> +			goto out;
>  		memset(mem, 0, sizeof(*mem));
> +	} else
> +		mem = kzalloc(sizeof(*mem), GFP_KERNEL);
> +
> +	if (!mem)
> +		goto out;
> +
> +	if (statsize > PAGE_SIZE) {
> +		cpustat = vmalloc(statsize);
> +		if (!cpustat)
> +			goto out_mem;
> +		memset(cpustat, 0, statsize);
> +	} else
> +		cpustat = kzalloc(statsize, GFP_KERNEL);
> +
> +	if (!cpustat)
> +		goto out_mem;
> +
> +	mem->stat.cpustat = cpustat;
>  	return mem;
> +
> +out_mem:
> +	if (is_vmalloc_addr(mem))
> +		vfree(mem);
> +	else
> +		kfree(mem);
> +out:
> +	return NULL;
>  }
>  
>  static void mem_cgroup_free(struct mem_cgroup *mem)
>  {
> -	if (sizeof(*mem) < PAGE_SIZE)
> -		kfree(mem);
> +	if (is_vmalloc_addr(mem->stat.cpustat))
> +		vfree(mem->stat.cpustat);
>  	else
> +		kfree(mem->stat.cpustat);
> +
> +	if (is_vmalloc_addr(mem))
>  		vfree(mem);
> +	else
> +		kfree(mem);
>  }
>  
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
