From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v3 27/32] list_lru: reclaim proportionaly between memcgs and
	nodes
Date: Mon,  8 Apr 2013 18:00:54 +0400
Message-ID: <1365429659-22108-28-git-send-email-glommer__5786.34651978991$1365441036$gmane$org@parallels.com>
References: <1365429659-22108-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1365429659-22108-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
Cc: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

The current list_lru code will try to scan objects until nr_to_walk is
reached, and then stop. This number can be different from the total
number of objects we have as returned by our count function. This is
because the main shrinker driver is the one ultimately responsible for
determining how many objects to shrink from each shrinker.

Specially if this number is lower than the number of objects, and
because we transverse the list always in the same order, we can have
the last node and/or the last memcg always being less penalized than
the others.

My proposed solution is to introduce some metric of proportionality
based on the total number of objects per node and then scan all nodes
and memcgs up until their share is reached.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>
Cc: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
---
 lib/list_lru.c | 96 ++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 83 insertions(+), 13 deletions(-)

diff --git a/lib/list_lru.c b/lib/list_lru.c
index 3093f98..8434a18 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -234,6 +234,43 @@ restart:
 	return isolated;
 }
 
+static long
+memcg_isolate_lru(
+	struct list_lru	*lru,
+	list_lru_walk_cb isolate,
+	void		*cb_arg,
+	long		nr_to_walk,
+	struct mem_cgroup *memcg,
+	int nid, unsigned long total_node)
+{
+	int memcg_id = memcg_cache_id(memcg);
+	unsigned long nr_to_walk_this;
+	long isolated = 0;
+	int idx;
+	struct list_lru_node *nlru;
+
+	for_each_memcg_lru_index(idx, memcg_id) {
+		nlru = lru_node_of_index(lru, idx, nid);
+		if (!nlru || !nlru->nr_items)
+			continue;
+
+		/*
+		 * no memcg: walk every memcg proportionally.
+		 * memcg case: scan everything (total_node)
+		 */
+		if (!memcg)
+			nr_to_walk_this = mult_frac(nlru->nr_items, nr_to_walk,
+						    total_node);
+		else
+			nr_to_walk_this = total_node;
+
+		isolated += list_lru_walk_node(lru, nlru, nid, isolate,
+				       cb_arg, &nr_to_walk_this);
+	}
+
+	return isolated;
+}
+
 long
 list_lru_walk_nodemask_memcg(
 	struct list_lru	*lru,
@@ -246,9 +283,7 @@ list_lru_walk_nodemask_memcg(
 	long isolated = 0;
 	int nid;
 	nodemask_t nodes;
-	int memcg_id = memcg_cache_id(memcg);
-	int idx;
-	struct list_lru_node *nlru;
+	unsigned long n_node, total_node, total = 0;
 
 	/*
 	 * Conservative code can call this setting nodes with node_setall.
@@ -256,17 +291,52 @@ list_lru_walk_nodemask_memcg(
 	 */
 	nodes_and(nodes, *nodes_to_walk, node_online_map);
 
+	/*
+	 * We will first find out how many objects there are in the LRU, in
+	 * total. We could store that in a per-LRU counter as well, the same
+	 * way we store it in a per-NLRU. But lru_add and lru_del are way more
+	 * frequent operations, so it is better to pay the price here.
+	 *
+	 * Once we have that number, we will try to scan the nodes
+	 * proportionally to the amount of objects they have. The main shrinker
+	 * driver in vmscan.c will often ask us to shrink a quantity different
+	 * from the total quantity we reported in the count function (usually
+	 * less). This means that not scanning proportionally may leave nodes
+	 * (usually the last), unfairly charged.
+	 *
+	 * The final number we want is
+	 *
+	 * n_node = nr_to_scan * total_node / total
+	 */
+	for_each_node_mask(nid, nodes)
+		total += atomic_long_read(&lru->node_totals[nid]);
+
 	for_each_node_mask(nid, nodes) {
-		for_each_memcg_lru_index(idx, memcg_id) {
-			nlru = lru_node_of_index(lru, idx, nid);
-			if (!nlru)
-				continue;
-
-			isolated += list_lru_walk_node(lru, nlru, nid, isolate,
-						       cb_arg, &nr_to_walk);
-			if (nr_to_walk <= 0)
-				break;
-		}
+		total_node = atomic_long_read(&lru->node_totals[nid]);
+		if (!total_node)
+			continue;
+
+		 /*
+		  * There are items, but in less proportion. Because we have no
+		  * information about where exactly the pressure originates
+		  * from, it is better to try shrinking the few we have than to
+		  * skip it.  It might very well be that this node is under
+		  * pressure and any help would be welcome.
+		  */
+		n_node = mult_frac(total_node, nr_to_walk, total);
+		if (!n_node)
+			n_node = total_node;
+
+		/*
+		 * We will now scan all memcg-like entities (which includes the
+		 * global LRU, of index -1, and also try to mantain
+		 * proportionality among them.
+		 *
+		 * We will try to isolate:
+		 *	nr_memcg = n_node * nr_memcg_lru / total_node
+		 */
+		isolated += memcg_isolate_lru(lru, isolate, cb_arg,
+				      n_node, memcg, nid, total_node);
 	}
 	return isolated;
 }
-- 
1.8.1.4
