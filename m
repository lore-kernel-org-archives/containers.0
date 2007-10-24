From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] memory cgroup enhancements updated [3/10] remember
 pagecache
Date: Wed, 24 Oct 2007 19:26:34 +0530
Message-ID: <471F4F12.8050708@linux.vnet.ibm.com>
References: <20071019182436.485e20cd.kamezawa.hiroyu@jp.fujitsu.com>
	<20071019183106.b5afda2f.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071019183106.b5afda2f.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> Add PCGF_PAGECACHE flag to page_cgroup to remember "this page is
> charged as page-cache."
> This is very useful for implementing precise accounting in memory cgroup.
> 
> Changelog v1 -> v2
>   - moved #define to out-side of struct definition
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Signed-off-by: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> 
>  mm/memcontrol.c |   18 +++++++++++++++---
>  1 file changed, 15 insertions(+), 3 deletions(-)
> 
> Index: devel-2.6.23-mm1/mm/memcontrol.c
> ===================================================================
> --- devel-2.6.23-mm1.orig/mm/memcontrol.c
> +++ devel-2.6.23-mm1/mm/memcontrol.c
> @@ -83,7 +83,9 @@ struct page_cgroup {
>  	struct mem_cgroup *mem_cgroup;
>  	atomic_t ref_cnt;		/* Helpful when pages move b/w  */
>  					/* mapped and cached states     */
> +	int	 flags;
>  };
> +#define PCGF_PAGECACHE		(0x1)	/* charged as page-cache */
> 
>  enum {
>  	MEM_CGROUP_TYPE_UNSPEC = 0,
> @@ -315,8 +317,8 @@ unsigned long mem_cgroup_isolate_pages(u
>   * 0 if the charge was successful
>   * < 0 if the cgroup is over its limit
>   */
> -int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
> -				gfp_t gfp_mask)
> +static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
> +				gfp_t gfp_mask, int is_cache)
>  {
>  	struct mem_cgroup *mem;
>  	struct page_cgroup *pc;
> @@ -418,6 +420,10 @@ noreclaim:
>  	atomic_set(&pc->ref_cnt, 1);
>  	pc->mem_cgroup = mem;
>  	pc->page = page;
> +	if (is_cache)
> +		pc->flags = PCGF_PAGECACHE;

I prefer PAGE_CGROUP_CACHE since cache can be page cache/swap cache.

> +	else
> +		pc->flags = 0;
>  	if (page_cgroup_assign_new_page_cgroup(page, pc)) {
>  		/*
>  		 * an another charge is added to this page already.
> @@ -442,6 +448,12 @@ err:
>  	return -ENOMEM;
>  }
> 
> +int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
> +			gfp_t gfp_mask)
> +{
> +	return mem_cgroup_charge_common(page, mm, gfp_mask, 0);

Could we define

enum {
	MEM_CGROUP_CHARGE_TYPE_CACHE  = 0,
	MEM_CGROUP_CHARGE_TYPE_MAPPED = 1,
};

and use the enums here and below.

> +}
> +
>  /*
>   * See if the cached pages should be charged at all?
>   */
> @@ -454,7 +466,7 @@ int mem_cgroup_cache_charge(struct page 
> 
>  	mem = rcu_dereference(mm->mem_cgroup);
>  	if (mem->control_type == MEM_CGROUP_TYPE_ALL)
> -		return mem_cgroup_charge(page, mm, gfp_mask);
> +		return mem_cgroup_charge_common(page, mm, gfp_mask, 1);
>  	else
>  		return 0;
>  }
> 


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
