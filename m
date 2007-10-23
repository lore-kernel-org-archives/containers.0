From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] memory cgroup enhancements updated [1/10]
 try_to_free_mem_cgroup_pages bugfix
Date: Tue, 23 Oct 2007 09:30:53 +0530
Message-ID: <471D71F5.9060007@linux.vnet.ibm.com>
References: <20071019182436.485e20cd.kamezawa.hiroyu@jp.fujitsu.com>
	<20071019182952.0a414751.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071019182952.0a414751.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
> Because NODE_DATA(node)->node_zonelists[] is guaranteed to contain
> all necessary zones, it is not necessary to use for_each_online_node.
> 
> And this for_each_online_node() makes reclaim routine start always
> from node 0. This is bad.
> 

But with this change, we'll start reclaim on the node that the task
hit the limit on - right?

> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> 
> 
> 
>  mm/vmscan.c |    8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> Index: devel-2.6.23-mm1/mm/vmscan.c
> ===================================================================
> --- devel-2.6.23-mm1.orig/mm/vmscan.c
> +++ devel-2.6.23-mm1/mm/vmscan.c
> @@ -1375,15 +1375,13 @@ unsigned long try_to_free_mem_cgroup_pag
>  		.mem_cgroup = mem_cont,
>  		.isolate_pages = mem_cgroup_isolate_pages,
>  	};
> -	int node;
> +	int node = numa_node_id();
>  	struct zone **zones;
>  	int target_zone = gfp_zone(GFP_HIGHUSER_MOVABLE);
> 
> -	for_each_online_node(node) {
> -		zones = NODE_DATA(node)->node_zonelists[target_zone].zones;
> -		if (do_try_to_free_pages(zones, sc.gfp_mask, &sc))
> +	zones = NODE_DATA(node)->node_zonelists[target_zone].zones;
> +	if (do_try_to_free_pages(zones, sc.gfp_mask, &sc))
>  			return 1;
> -	}
>  	return 0;
>  }
>  #endif
> 


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
