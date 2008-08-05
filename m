From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/7] bio-cgroup: Split the cgroup memory subsystem into
	two parts
Date: Tue,  5 Aug 2008 12:25:33 +0200 (MEST)
Message-ID: <48982A9D.2000803@gmail.com>
References: <20080804.175214.226796876.ryov@valinux.co.jp>	<20080804.175254.71094191.ryov@valinux.co.jp>	<20080804.175707.104036289.ryov@valinux.co.jp>
	<20080804.175748.189722512.ryov@valinux.co.jp>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080804.175748.189722512.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org
List-Id: containers.vger.kernel.org

Ryo Tsuruta wrote:
> +static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
> +				gfp_t gfp_mask, enum charge_type ctype,
> +				struct mem_cgroup *memcg)
> +{
> +	struct page_cgroup *pc;
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	struct mem_cgroup *mem;
> +	unsigned long flags;
> +	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> +	struct mem_cgroup_per_zone *mz;
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +
> +	pc = kmem_cache_alloc(page_cgroup_cache, gfp_mask);
> +	if (unlikely(pc == NULL))
> +		goto err;
> +
> +	/*
> +	 * We always charge the cgroup the mm_struct belongs to.
> +	 * The mm_struct's mem_cgroup changes on task migration if the
> +	 * thread group leader migrates. It's possible that mm is not
> +	 * set, if so charge the init_mm (happens for pagecache usage).
> +	 */
> +	if (likely(!memcg)) {
> +		rcu_read_lock();
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> +		/*
> +		 * For every charge from the cgroup, increment reference count
> +		 */
> +		css_get(&mem->css);
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +		rcu_read_unlock();
> +	} else {
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +		mem = memcg;
> +		css_get(&memcg->css);
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +	}
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
> +		if (!(gfp_mask & __GFP_WAIT))
> +			goto out;
> +
> +		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
> +			continue;
> +
> +		/*
> +		 * try_to_free_mem_cgroup_pages() might not give us a full
> +		 * picture of reclaim. Some pages are reclaimed and might be
> +		 * moved to swap cache or just unmapped from the cgroup.
> +		 * Check the limit again to see if the reclaim reduced the
> +		 * current usage of the cgroup before giving up
> +		 */
> +		if (res_counter_check_under_limit(&mem->res))
> +			continue;
> +
> +		if (!nr_retries--) {
> +			mem_cgroup_out_of_memory(mem, gfp_mask);
> +			goto out;
> +		}
> +	}
> +	pc->mem_cgroup = mem;
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */

you can remove some ifdefs doing:

#ifdef CONFIG_CGROUP_MEM_RES_CTLR
	if (likely(!memcg)) {
		rcu_read_lock();
		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
		/*
		 * For every charge from the cgroup, increment reference count
		 */
		css_get(&mem->css);
		rcu_read_unlock();
	} else {
		mem = memcg;
		css_get(&memcg->css);
	}
	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
		if (!(gfp_mask & __GFP_WAIT))
			goto out;

		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
			continue;

		/*
		 * try_to_free_mem_cgroup_pages() might not give us a full
		 * picture of reclaim. Some pages are reclaimed and might be
		 * moved to swap cache or just unmapped from the cgroup.
		 * Check the limit again to see if the reclaim reduced the
		 * current usage of the cgroup before giving up
		 */
		if (res_counter_check_under_limit(&mem->res))
			continue;

		if (!nr_retries--) {
			mem_cgroup_out_of_memory(mem, gfp_mask);
			goto out;
		}
	}
	pc->mem_cgroup = mem;
#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
