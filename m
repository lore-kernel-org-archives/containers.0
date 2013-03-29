From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v2 25/28] list_lru: per-memcg walks
Date: Fri, 29 Mar 2013 13:14:07 +0400
Message-ID: <1364548450-28254-26-git-send-email-glommer__27428.5658648752$1364548644$gmane$org@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1364548450-28254-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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
Cc: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch extend the list_lru interfaces to allow for a memcg
parameter. Because most of its users won't need it, instead of
modifying the function signatures we create a new set of _memcg()
functions and write the old API ontop of that.

At this point, the infrastructure is mostly in place. We already walk
the nodes using all memcg indexes, so we just need to make sure we skip
all but the one we're interested in. We could just go directly to the
memcg of interest, but I am assuming that given the gained simplicity,
spending a few cycles here won't hurt *that* much (but that can be
improved if needed, of course).

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
 include/linux/list_lru.h | 24 +++++++++++++++++----
 lib/list_lru.c           | 56 ++++++++++++++++++++++++++++++++++++------------
 2 files changed, 62 insertions(+), 18 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 0856899..2481756 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -69,20 +69,36 @@ static inline int list_lru_init_memcg(struct list_lru *lru)
 
 int list_lru_add(struct list_lru *lru, struct list_head *item);
 int list_lru_del(struct list_lru *lru, struct list_head *item);
-long list_lru_count_nodemask(struct list_lru *lru, nodemask_t *nodes_to_count);
+
+long list_lru_count_nodemask_memcg(struct list_lru *lru,
+			nodemask_t *nodes_to_count, struct mem_cgroup *memcg);
+
+static inline long
+list_lru_count_nodemask(struct list_lru *lru, nodemask_t *nodes_to_count)
+{
+	return list_lru_count_nodemask_memcg(lru, nodes_to_count, NULL);
+}
 
 static inline long list_lru_count(struct list_lru *lru)
 {
 	return list_lru_count_nodemask(lru, &lru->active_nodes);
 }
 
-
 typedef int (*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock,
 				void *cb_arg);
 typedef void (*list_lru_dispose_cb)(struct list_head *dispose_list);
 
-long list_lru_walk_nodemask(struct list_lru *lru, list_lru_walk_cb isolate,
-		   void *cb_arg, long nr_to_walk, nodemask_t *nodes_to_walk);
+long list_lru_walk_nodemask_memcg(struct list_lru *lru,
+	list_lru_walk_cb isolate, void *cb_arg, long nr_to_walk,
+	nodemask_t *nodes_to_walk, struct mem_cgroup *memcg);
+
+static inline long list_lru_walk_nodemask(struct list_lru *lru,
+	list_lru_walk_cb isolate, void *cb_arg, long nr_to_walk,
+	nodemask_t *nodes_to_walk)
+{
+	return list_lru_walk_nodemask_memcg(lru, isolate, cb_arg, nr_to_walk,
+					    &lru->active_nodes, NULL);
+}
 
 static inline long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
 				 void *cb_arg, long nr_to_walk)
diff --git a/lib/list_lru.c b/lib/list_lru.c
index e8d04a1..a49a9b5 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -16,6 +16,11 @@
  * memcg_limited_groups_array_size will be 0. _idx starts at -1, and it will
  * still be allowed to execute once.
  *
+ * If a memcg is specified at memcg_id, we will make sure that the loop only
+ * have one iteration, corresponding to that memcg. This makes sure that the
+ * interface is kept for both cases and there is no need for separate code to
+ * handle that case, at the price of complicating the macro a bit.
+ *
  * We convention that for _idx = -1, the global node info should be used.
  * After that, we will go through each of the memcgs, starting at 0.
  *
@@ -24,8 +29,11 @@
  * end. The old ones are just copied, and any interesting manipulation happen
  * in the node list itself, and we already lock the list.
  */
-#define for_each_memcg_lru_index(_idx)	\
-	for ((_idx) = -1; ((_idx) < memcg_limited_groups_array_size); (_idx)++)
+#define for_each_memcg_lru_index(_idx, memcg_id)		\
+	for ((_idx) = ((memcg_id) >= 0) ? memcg_id : -1;	\
+	     ((memcg_id < 0) || ((_idx) <= (memcg_id))) &&	\
+	     ((_idx) < memcg_limited_groups_array_size);	\
+	     (_idx)++)
 
 int
 list_lru_add(
@@ -86,25 +94,44 @@ list_lru_del(
 EXPORT_SYMBOL_GPL(list_lru_del);
 
 long
-list_lru_count_nodemask(
+list_lru_count_nodemask_memcg(
 	struct list_lru *lru,
-	nodemask_t	*nodes_to_count)
+	nodemask_t	*nodes_to_count,
+	struct mem_cgroup *memcg)
 {
 	long count = 0;
 	int nid;
+	nodemask_t nodes;
+	struct list_lru_node *nlru;
+	int memcg_id = memcg_cache_id(memcg);
+
+	/*
+	 * Conservative code can call this setting nodes with node_setall.
+	 * This will generate an out of bound access for memcg.
+	 */
+	nodes_and(nodes, *nodes_to_count, node_online_map);
 
-	for_each_node_mask(nid, *nodes_to_count) {
+	for_each_node_mask(nid, nodes) {
 		/*
 		 * We don't need to loop through all memcgs here, because we
 		 * have the node_totals information for the node. If we hadn't,
 		 * this would still be achieavable by a loop-over-all-groups
 		 */
-		count += atomic_long_read(&lru->node_totals[nid]);
-	}
+		if (!memcg)
+			count += atomic_long_read(&lru->node_totals[nid]);
+		else {
+			nlru = lru_node_of_index(lru, memcg_id, nid);
+			WARN_ON(!nlru);
 
+			spin_lock(&nlru->lock);
+			BUG_ON(nlru->nr_items < 0);
+			count += nlru->nr_items;
+			spin_unlock(&nlru->lock);
+		}
+	}
 	return count;
 }
-EXPORT_SYMBOL_GPL(list_lru_count_nodemask);
+EXPORT_SYMBOL_GPL(list_lru_count_nodemask_memcg);
 
 static long
 list_lru_walk_node(
@@ -151,16 +178,18 @@ restart:
 }
 
 long
-list_lru_walk_nodemask(
+list_lru_walk_nodemask_memcg(
 	struct list_lru	*lru,
 	list_lru_walk_cb isolate,
 	void		*cb_arg,
 	long		nr_to_walk,
-	nodemask_t	*nodes_to_walk)
+	nodemask_t	*nodes_to_walk,
+	struct mem_cgroup *memcg)
 {
 	long isolated = 0;
 	int nid;
 	nodemask_t nodes;
+	int memcg_id = memcg_cache_id(memcg);
 	int idx;
 	struct list_lru_node *nlru;
 
@@ -171,8 +200,7 @@ list_lru_walk_nodemask(
 	nodes_and(nodes, *nodes_to_walk, node_online_map);
 
 	for_each_node_mask(nid, nodes) {
-		for_each_memcg_lru_index(idx) {
-
+		for_each_memcg_lru_index(idx, memcg_id) {
 			nlru = lru_node_of_index(lru, idx, nid);
 			if (!nlru)
 				continue;
@@ -185,7 +213,7 @@ list_lru_walk_nodemask(
 	}
 	return isolated;
 }
-EXPORT_SYMBOL_GPL(list_lru_walk_nodemask);
+EXPORT_SYMBOL_GPL(list_lru_walk_nodemask_memcg);
 
 long
 list_lru_dispose_all_node(
@@ -198,7 +226,7 @@ list_lru_dispose_all_node(
 	long disposed = 0;
 	int idx;
 
-	for_each_memcg_lru_index(idx) {
+	for_each_memcg_lru_index(idx, -1) {
 		nlru = lru_node_of_index(lru, idx, nid);
 		if (!nlru)
 			continue;
-- 
1.8.1.4
