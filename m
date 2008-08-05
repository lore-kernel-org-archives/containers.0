From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 4/7] bio-cgroup: Split the cgroup memory subsystem into
	two parts
Date: Tue, 05 Aug 2008 19:35:51 +0900 (JST)
Message-ID: <20080805.193551.14286210.taka__3235.76321029595$1217932673$gmane$org@valinux.co.jp>
References: <20080804.175707.104036289.ryov@valinux.co.jp>
	<20080804.175748.189722512.ryov@valinux.co.jp>
	<48982A9D.2000803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48982A9D.2000803-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Andrea,

> you can remove some ifdefs doing:

I think you don't have to care about this much, since one of the following
patches removes most of these ifdefs.

> #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> 	if (likely(!memcg)) {
> 		rcu_read_lock();
> 		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> 		/*
> 		 * For every charge from the cgroup, increment reference count
> 		 */
> 		css_get(&mem->css);
> 		rcu_read_unlock();
> 	} else {
> 		mem = memcg;
> 		css_get(&memcg->css);
> 	}
> 	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
> 		if (!(gfp_mask & __GFP_WAIT))
> 			goto out;
> 
> 		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
> 			continue;
> 
> 		/*
> 		 * try_to_free_mem_cgroup_pages() might not give us a full
> 		 * picture of reclaim. Some pages are reclaimed and might be
> 		 * moved to swap cache or just unmapped from the cgroup.
> 		 * Check the limit again to see if the reclaim reduced the
> 		 * current usage of the cgroup before giving up
> 		 */
> 		if (res_counter_check_under_limit(&mem->res))
> 			continue;
> 
> 		if (!nr_retries--) {
> 			mem_cgroup_out_of_memory(mem, gfp_mask);
> 			goto out;
> 		}
> 	}
> 	pc->mem_cgroup = mem;
> #endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
