From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: [RFC][PATCH] memory controller per zone patches take 2 [0/10]
 introduction
Date: Fri, 16 Nov 2007 19:11:07 +0900
Message-ID: <20071116191107.46dd523a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi, this is updated version of patch set implementing per-zone on memory cgroup.

I still uses x86_64/fake NUMA (my ia64/NUMA box is under maintainance....)
So, RFC again. (I'd like to do 3rd update in the next week.)

Major Changes from previous one.
 - per-zone-lru_lock patch is added.
 - all per-zone objects of memory cgroup are treated in same way.
 - page migration is handled.
 - restructured and cleaned up.

Todo:
 - do test on "real" NUMA.
 - merge YAMAMOTO-san's background page reclaim patch set on this. (If I can)
 - performance measurement at some point
 - more cleanup and adding meaningful comments
 - confirm added logic in vmscan.c is really sane.

Overview:

All per-zone obects are put into 
==
 struct mem_cgroup_per_zone {
        /*
         * spin_lock to protect the per cgroup LRU
         */
        spinlock_t              lru_lock;
        struct list_head        active_list;
        struct list_head        inactive_list;
        unsigned long count[NR_MEM_CGROUP_ZSTAT];
 };
==
And this per-zone area is accessed by following functions.
==
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
 page_cgroup_zoneinfo(struct page_cgroup *pc)
==

Typical usage is following.
==
        mz = page_cgroup_zoneinfo(pc);
        spin_lock_irqsave(&mz->lru_lock, flags);
        __mem_cgroup_add_list(pc);
        spin_unlock_irqrestore(&mz->lru_lock, flags);
==

Thanks,
-Kame
