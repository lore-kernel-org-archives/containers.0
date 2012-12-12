From: "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] mm/hugetlb: create hugetlb cgroup file in hugetlb_init
Date: Wed, 12 Dec 2012 22:35:54 +0530
Message-ID: <8738zb9p59.fsf__47222.5007754334$1355332591$gmane$org@linux.vnet.ibm.com>
References: <50C83F97.3040009@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50C83F97.3040009-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jianguo Wu <wujianguo-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Liujiang <jiang.liu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, dhillf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Jiang Liu <liuj97-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, qiuxishi <qiuxishi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Hanjun Guo <guohanjun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Jianguo Wu <wujianguo-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> writes:

> Build kernel with CONFIG_HUGETLBFS=y,CONFIG_HUGETLB_PAGE=y
> and CONFIG_CGROUP_HUGETLB=y, then specify hugepagesz=xx boot option,
> system will boot fail.
>
> This failure is caused by following code path:
> setup_hugepagesz
> 	hugetlb_add_hstate
> 		hugetlb_cgroup_file_init
> 			cgroup_add_cftypes
> 				kzalloc <--slab is *not available* yet
>
> For this path, slab is not available yet, so memory allocated will be
> failed, and cause WARN_ON() in hugetlb_cgroup_file_init().
>
> So I move hugetlb_cgroup_file_init() into hugetlb_init().
>
> Signed-off-by: Jianguo Wu <wujianguo-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Jiang Liu <jiang.liu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/hugetlb_cgroup.h |    7 ++-----
>  mm/hugetlb.c                   |   11 +----------
>  mm/hugetlb_cgroup.c            |   23 +++++++++++++++++++++--
>  3 files changed, 24 insertions(+), 17 deletions(-)
>
> diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
> index d73878c..5bb9c28 100644
> --- a/include/linux/hugetlb_cgroup.h
> +++ b/include/linux/hugetlb_cgroup.h
> @@ -62,7 +62,7 @@ extern void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
>  					 struct page *page);
>  extern void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
>  					   struct hugetlb_cgroup *h_cg);
> -extern int hugetlb_cgroup_file_init(int idx) __init;
> +extern void hugetlb_cgroup_file_init(void) __init;
>  extern void hugetlb_cgroup_migrate(struct page *oldhpage,
>  				   struct page *newhpage);
>
> @@ -111,10 +111,7 @@ hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
>  	return;
>  }
>
> -static inline int __init hugetlb_cgroup_file_init(int idx)
> -{
> -	return 0;
> -}
> +static inline void __init hugetlb_cgroup_file_init() {}
>
>  static inline void hugetlb_cgroup_migrate(struct page *oldhpage,
>  					  struct page *newhpage)
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 1ef2cd4..a30da48 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1906,14 +1906,12 @@ static int __init hugetlb_init(void)
>  		default_hstate.max_huge_pages = default_hstate_max_huge_pages;
>
>  	hugetlb_init_hstates();
> -
>  	gather_bootmem_prealloc();
> -
>  	report_hugepages();
>
>  	hugetlb_sysfs_init();
> -
>  	hugetlb_register_all_nodes();
> +	hugetlb_cgroup_file_init();
>
>  	return 0;
>  }
> @@ -1943,13 +1941,6 @@ void __init hugetlb_add_hstate(unsigned order)
>  	h->next_nid_to_free = first_node(node_states[N_HIGH_MEMORY]);
>  	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
>  					huge_page_size(h)/1024);
> -	/*
> -	 * Add cgroup control files only if the huge page consists
> -	 * of more than two normal pages. This is because we use
> -	 * page[2].lru.next for storing cgoup details.
> -	 */
> -	if (order >= HUGETLB_CGROUP_MIN_ORDER)
> -		hugetlb_cgroup_file_init(hugetlb_max_hstate - 1);
>
>  	parsed_hstate = h;
>  }
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index a3f358f..284cb68 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -340,7 +340,7 @@ static char *mem_fmt(char *buf, int size, unsigned long hsize)
>  	return buf;
>  }
>
> -int __init hugetlb_cgroup_file_init(int idx)
> +static void __init __hugetlb_cgroup_file_init(int idx)
>  {
>  	char buf[32];
>  	struct cftype *cft;
> @@ -382,7 +382,26 @@ int __init hugetlb_cgroup_file_init(int idx)
>
>  	WARN_ON(cgroup_add_cftypes(&hugetlb_subsys, h->cgroup_files));
>
> -	return 0;
> +	return;
> +}
> +
> +void __init hugetlb_cgroup_file_init()
> +{
> +	struct hstate *h;
> +	int idx;
> +
> +	idx = 0;
> +	for_each_hstate(h) {
> +		/*
> +		 * Add cgroup control files only if the huge page consists
> +		 * of more than two normal pages. This is because we use
> +		 * page[2].lru.next for storing cgoup details.
> +		 */
> +		if (h->order >= HUGETLB_CGROUP_MIN_ORDER)
> +			__hugetlb_cgroup_file_init(idx);

Is it better to say ?

             if (huge_page_order(h) >= HUGETLB_CGROUP_MIN_ORDER)
                          __hugetlb_cgroup_file_init(hstate_index(h));                                

It should be ok both case.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

> +
> +		idx++;
> +	}
>  }
>
>  /*
> -- 1.7.1

-anesh
