From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v2 23/28] lru: add an element to a memcg list
Date: Mon, 01 Apr 2013 17:18:32 +0900
Message-ID: <515942D8.1070301__26397.619667887$1364804377$gmane$org@jp.fujitsu.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-24-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1364548450-28254-24-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

(2013/03/29 18:14), Glauber Costa wrote:
> With the infrastructure we now have, we can add an element to a memcg
> LRU list instead of the global list. The memcg lists are still
> per-node.
> 
> Technically, we will never trigger per-node shrinking in the memcg is
> short of memory. Therefore an alternative to this would be to add the
> element to *both* a single-node memcg array and a per-node global array.
> 

per-node shrinking by memcg pressure is not imporant, I think.


> There are two main reasons for this design choice:
> 
> 1) adding an extra list_head to each of the objects would waste 16-bytes
> per object, always remembering that we are talking about 1 dentry + 1
> inode in the common case. This means a close to 10 % increase in the
> dentry size, and a lower yet significant increase in the inode size. In
> terms of total memory, this design pays 32-byte per-superblock-per-node
> (size of struct list_lru_node), which means that in any scenario where
> we have more than 10 dentries + inodes, we would already be paying more
> memory in the two-list-heads approach than we will here with 1 node x 10
> superblocks. The turning point of course depends on the workload, but I
> hope the figures above would convince you that the memory footprint is
> in my side in any workload that matters.
> 
> 2) The main drawback of this, namely, that we loose global LRU order, is
> not really seen by me as a disadvantage: if we are using memcg to
> isolate the workloads, global pressure should try to balance the amount
> reclaimed from all memcgs the same way the shrinkers will already
> naturally balance the amount reclaimed from each superblock. (This
> patchset needs some love in this regard, btw).
> 
> To help us easily tracking down which nodes have and which nodes doesn't
> have elements in the list, we will count on an auxiliary node bitmap in
> the global level.
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> Cc: Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>
> Cc: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> ---
>   include/linux/list_lru.h   | 10 +++++++
>   include/linux/memcontrol.h | 10 +++++++
>   lib/list_lru.c             | 68 +++++++++++++++++++++++++++++++++++++++-------
>   mm/memcontrol.c            | 38 +++++++++++++++++++++++++-
>   4 files changed, 115 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> index d6cf126..0856899 100644
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -26,6 +26,7 @@ struct list_lru_array {
>   
>   struct list_lru {
>   	struct list_lru_node	node[MAX_NUMNODES];
> +	atomic_long_t		node_totals[MAX_NUMNODES];

some comments will be helpful. 

>   	nodemask_t		active_nodes;
>   #ifdef CONFIG_MEMCG_KMEM
>   	struct list_head	lrus;
> @@ -40,10 +41,19 @@ int memcg_update_all_lrus(unsigned long num);
>   void list_lru_destroy(struct list_lru *lru);
>   void list_lru_destroy_memcg(struct mem_cgroup *memcg);
>   int __memcg_init_lru(struct list_lru *lru);
> +struct list_lru_node *
> +lru_node_of_index(struct list_lru *lru, int index, int nid);
>   #else
>   static inline void list_lru_destroy(struct list_lru *lru)
>   {
>   }
> +
> +static inline struct list_lru_node *
> +lru_node_of_index(struct list_lru *lru, int index, int nid)
> +{
> +	BUG_ON(index < 0); /* index != -1 with !MEMCG_KMEM. Impossible */
> +	return &lru->node[nid];
> +}
>   #endif

I'm sorry ...what "lru_node_of_index" means ? What is the "index" ?


Thanks,
-Kame
