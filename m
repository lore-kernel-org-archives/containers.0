From: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 3/6 mm] memcgroup: fix try_to_free order
Date: Fri, 9 Nov 2007 07:11:12 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0711090710310.21663@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0711090700530.21638@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0711090700530.21638-VFT1Jj/mpSzq8/QPP7pA5326JSxr+BKB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Why does try_to_free_mem_cgroup_pages try for order 1 pages?  It's called
when mem_cgroup_charge_common would go over the limit, and that's adding
an order 0 page.  I see no reason: it has to be a typo: fix it.

Signed-off-by: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
---
Insert just after memory-controller-add-per-container-lru-and-reclaim-v7.patch

 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- patch2/mm/vmscan.c	2007-11-08 15:46:21.000000000 +0000
+++ patch3/mm/vmscan.c	2007-11-08 15:48:08.000000000 +0000
@@ -1354,7 +1354,7 @@ unsigned long try_to_free_mem_cgroup_pag
 		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = vm_swappiness,
-		.order = 1,
+		.order = 0,
 		.mem_cgroup = mem_cont,
 		.isolate_pages = mem_cgroup_isolate_pages,
 	};
