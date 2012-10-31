From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 8/8] cgroup: make ->pre_destroy() return void
Date: Wed, 31 Oct 2012 22:23:51 +0100
Message-ID: <20121031212351.GB5286@dhcp22.suse.cz>
References: <1351712650-23709-1-git-send-email-tj@kernel.org>
	<1351712650-23709-9-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351712650-23709-9-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed 31-10-12 12:44:10, Tejun Heo wrote:
> All ->pre_destory() implementations return 0 now, which is the only
> allowed return value.  Make it return void.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

I thought I already gave my r-b but anyway
Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

> ---
>  block/blk-cgroup.c     | 3 +--
>  include/linux/cgroup.h | 2 +-
>  kernel/cgroup.c        | 2 +-
>  mm/hugetlb_cgroup.c    | 4 +---
>  mm/memcontrol.c        | 3 +--
>  5 files changed, 5 insertions(+), 9 deletions(-)
> 
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index f3b44a6..a7816f3 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -600,7 +600,7 @@ struct cftype blkcg_files[] = {
>   *
>   * This is the blkcg counterpart of ioc_release_fn().
>   */
> -static int blkcg_pre_destroy(struct cgroup *cgroup)
> +static void blkcg_pre_destroy(struct cgroup *cgroup)
>  {
>  	struct blkcg *blkcg = cgroup_to_blkcg(cgroup);
>  
> @@ -622,7 +622,6 @@ static int blkcg_pre_destroy(struct cgroup *cgroup)
>  	}
>  
>  	spin_unlock_irq(&blkcg->lock);
> -	return 0;
>  }
>  
>  static void blkcg_destroy(struct cgroup *cgroup)
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 47868a8..adb2adc 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -436,7 +436,7 @@ int cgroup_taskset_size(struct cgroup_taskset *tset);
>  
>  struct cgroup_subsys {
>  	struct cgroup_subsys_state *(*create)(struct cgroup *cgrp);
> -	int (*pre_destroy)(struct cgroup *cgrp);
> +	void (*pre_destroy)(struct cgroup *cgrp);
>  	void (*destroy)(struct cgroup *cgrp);
>  	int (*can_attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
>  	void (*cancel_attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index c5f6fb2..83cd7d0 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -4054,7 +4054,7 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
>  	mutex_unlock(&cgroup_mutex);
>  	for_each_subsys(cgrp->root, ss)
>  		if (ss->pre_destroy)
> -			WARN_ON_ONCE(ss->pre_destroy(cgrp));
> +			ss->pre_destroy(cgrp);
>  	mutex_lock(&cgroup_mutex);
>  
>  	/*
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index dc595c6..0d3a1a3 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -155,7 +155,7 @@ out:
>   * Force the hugetlb cgroup to empty the hugetlb resources by moving them to
>   * the parent cgroup.
>   */
> -static int hugetlb_cgroup_pre_destroy(struct cgroup *cgroup)
> +static void hugetlb_cgroup_pre_destroy(struct cgroup *cgroup)
>  {
>  	struct hstate *h;
>  	struct page *page;
> @@ -172,8 +172,6 @@ static int hugetlb_cgroup_pre_destroy(struct cgroup *cgroup)
>  		}
>  		cond_resched();
>  	} while (hugetlb_cgroup_have_usage(cgroup));
> -
> -	return 0;
>  }
>  
>  int hugetlb_cgroup_charge_cgroup(int idx, unsigned long nr_pages,
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6678f99..a1811ce 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5002,12 +5002,11 @@ free_out:
>  	return ERR_PTR(error);
>  }
>  
> -static int mem_cgroup_pre_destroy(struct cgroup *cont)
> +static void mem_cgroup_pre_destroy(struct cgroup *cont)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
>  
>  	mem_cgroup_reparent_charges(memcg);
> -	return 0;
>  }
>  
>  static void mem_cgroup_destroy(struct cgroup *cont)
> -- 
> 1.7.11.7
> 

-- 
Michal Hocko
SUSE Labs
