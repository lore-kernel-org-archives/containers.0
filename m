From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][-mm] [2/2] Simple stats for memory resource controller
Date: Thu, 27 Mar 2008 00:24:42 +0530
Message-ID: <47EA9BF2.2060301@linux.vnet.ibm.com>
References: <200803262348.59785.balajirrao@gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762394AbYCZS6U@vger.kernel.org>
In-Reply-To: <200803262348.59785.balajirrao@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Balaji Rao <balajirrao@gmail.com>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org, menage@google.com, balbir@in.ibm.com, dhaval@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

Balaji Rao wrote:
> This patch implements trivial statistics for the memory resource controller.
> 
> Signed-off-by: Balaji Rao <balajirrao@gmail.com>
> CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> CC: Dhaval Giani <dhaval@linux.vnet.ibm.com>
> 
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index eb681a6..84f3fe5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -45,6 +45,8 @@ enum mem_cgroup_stat_index {
>  	 */
>  	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
>  	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as rss */
> +	MEM_CGROUP_STAT_PGIN_COUNT,	/* # of pages paged in */
> +	MEM_CGROUP_STAT_PGOUT_COUNT,	/* # of pages paged out */
> 
>  	MEM_CGROUP_STAT_NSTATS,
>  };
> @@ -196,6 +198,13 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem, int flags,
>  		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_CACHE, val);
>  	else
>  		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_RSS, val);
> +
> +	if (charge)
> +		__mem_cgroup_stat_add_safe(stat,
> +				MEM_CGROUP_STAT_PGIN_COUNT, 1);
> +	else
> +		__mem_cgroup_stat_add_safe(stat,
> +				MEM_CGROUP_STAT_PGOUT_COUNT, 1);
>  }
> 
>  static struct mem_cgroup_per_zone *
> @@ -886,6 +895,8 @@ static const struct mem_cgroup_stat_desc {
>  } mem_cgroup_stat_desc[] = {
>  	[MEM_CGROUP_STAT_CACHE] = { "cache", PAGE_SIZE, },
>  	[MEM_CGROUP_STAT_RSS] = { "rss", PAGE_SIZE, },
> +	[MEM_CGROUP_STAT_PGIN_COUNT] = {"page_in_count", 1, },
> +	[MEM_CGROUP_STAT_PGOUT_COUNT] = {"page_out_count", 1, },
>  };
> 
>  static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,

Looks simple and nice. Please see Paul's mail on the suggested name change as well

Acked-by:  Balbir Singh <balbir@linux.vnet.ibm.com>


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
