From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH] memcg: reduce size of per-cpu-stat to be appropriate
 size.
Date: Fri, 14 Nov 2008 14:26:31 +0800
Message-ID: <491D1A17.2060404@cn.fujitsu.com>
References: <20081113164201.GV29067@bolzano.suse.de>	<20081113191837.18ed2ade.akpm@linux-foundation.org>	<491CF609.3050203@cn.fujitsu.com>	<20081114132840.98d38f12.kamezawa.hiroyu@jp.fujitsu.com> <20081114144926.d91f36fd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752588AbYKNG1R@vger.kernel.org>
In-Reply-To: <20081114144926.d91f36fd.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Blunck <jblunck@suse.de>, containers@lists.osdl.org, Linux-Kernel Mailinglist <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> How about this one ?
> tested on x86-64 + mmotm-Nov10, works well. 
> (test on other arch is welcome.)
> 
> -Kame
> ==
> As  Jan Blunck <jblunck@suse.de> pointed out, allocating
> per-cpu stat for memcg to the size of NR_CPUS is not good.
> 
> This patch changes mem_cgroup's cpustat allocation not based
> on NR_CPUS but based on nr_cpu_ids.
> 
> From: Jan Blunck <jblunck@suse.de>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Looks good :) . It's ok to use nr_cpu_ids when cgroup_init() is called 
at boot.

Reviewed-by: Li Zefan <lizf@cn.fujitsu.com>

except..see comments for mem_cgroup_create()

> +static int mem_cgroup_size(void)
> +{
> +	int cpustat_size = nr_cpu_ids * sizeof(struct mem_cgroup_stat_cpu);
> +	return sizeof(struct mem_cgroup) + cpustat_size;
> +}
> +
> +

minor comment: one empty line is suffice.

...

>  static struct cgroup_subsys_state *
>  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  {
>  	struct mem_cgroup *mem;
>  	int node;
>  
> -	if (unlikely((cont->parent) == NULL)) {
> -		mem = &init_mem_cgroup;
> -	} else {
> -		mem = mem_cgroup_alloc();
> -		if (!mem)
> -			return ERR_PTR(-ENOMEM);
> -	}
> +	mem = mem_cgroup_alloc();
> +	if (!mem)
> +		return ERR_PTR(-ENOMEM);
>  
>  	res_counter_init(&mem->res);
>  

free_out:
	for_each_node_state(node, N_POSSIBLE)
		free_mem_cgroup_per_zone_info(mem, node);
	if (cont->parent != NULL)       <---- this check should be removed
		mem_cgroup_free(mem);
