From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [8/10]
 changes in vmscan.c
Date: Sat, 17 Nov 2007 23:07:46 +0530
Message-ID: <473F26EA.5090808@linux.vnet.ibm.com>
References: <20071116191107.46dd523a.kamezawa.hiroyu@jp.fujitsu.com>
	<20071116192536.0a9f2d61.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071116192536.0a9f2d61.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> When using memory controller, there are 2 levels of memory reclaim.
>  1. zone memory reclaim because of system/zone memory shortage.
>  2. memory cgroup memory reclaim because of hitting limit.
> 
> These two can be distinguished by sc->mem_cgroup parameter.
> 
> This patch tries to make memory cgroup reclaim routine avoid affecting
> system/zone memory reclaim. This patch inserts if (!sc->mem_cgroup) and
> hook to memory_cgroup reclaim support functions.
> 
> This patch can be a help for isolating system lru activity and group lru
> activity and shows what additional functions are necessary.
> 
>  * mem_cgroup_calc_mapped_ratio() ... calculate mapped ratio for cgroup.
>  * mem_cgroup_reclaim_imbalance() ... calculate active/inactive balance in
>                                         cgroup.
>  * mem_cgroup_calc_reclaim_active() ... calculate the number of active pages to
>                                 be scanned in this priority in mem_cgroup.
> 
>  * mem_cgroup_calc_reclaim_inactive() ... calculate the number of inactive pages
>                                 to be scanned in this priority in mem_cgroup.
> 
>  * mem_cgroup_all_unreclaimable() .. checks cgroup's page is all unreclaimable
>                                      or not.
>  * mem_cgroup_get_reclaim_priority() ...
>  * mem_cgroup_note_reclaim_priority() ... record reclaim priority (temporal)
>  * mem_cgroup_remember_reclaim_priority()
>                              .... record reclaim priority as
>                                   zone->prev_priority.
>                                   This value is used for calc reclaim_mapped.
> Changelog:
>  - merged calc_reclaim_mapped patch in previous version.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

The overall idea looks good, it brings the two reclaims closer. The one
pending to do for memory controllers is to make the reclaim lumpy
reclaim aware. But at this point, I don't see a need for it, since
we track only order 1 allocations in the memory controller.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
