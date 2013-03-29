From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v2 11/28] list_lru: per-node list infrastructure
Date: Fri, 29 Mar 2013 13:13:53 +0400
Message-ID: <1364548450-28254-12-git-send-email-glommer__48270.787849515$1364548559$gmane$org@parallels.com>
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
Cc: hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Now that we have an LRU list API, we can start to enhance the
implementation.  This splits the single LRU list into per-node lists
and locks to enhance scalability. Items are placed on lists
according to the node the memory belongs to. To make scanning the
lists efficient, also track whether the per-node lists have entries
in them in a active nodemask.

Signed-off-by: Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/linux/list_lru.h |  14 +++--
 lib/list_lru.c           | 160 +++++++++++++++++++++++++++++++++++------------
 2 files changed, 129 insertions(+), 45 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 3423949..b0e3ba25 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -8,21 +8,23 @@
 #define _LRU_LIST_H 0
 
 #include <linux/list.h>
+#include <linux/nodemask.h>
 
-struct list_lru {
+struct list_lru_node {
 	spinlock_t		lock;
 	struct list_head	list;
 	long			nr_items;
+} ____cacheline_aligned_in_smp;
+
+struct list_lru {
+	struct list_lru_node	node[MAX_NUMNODES];
+	nodemask_t		active_nodes;
 };
 
 int list_lru_init(struct list_lru *lru);
 int list_lru_add(struct list_lru *lru, struct list_head *item);
 int list_lru_del(struct list_lru *lru, struct list_head *item);
-
-static inline long list_lru_count(struct list_lru *lru)
-{
-	return lru->nr_items;
-}
+long list_lru_count(struct list_lru *lru);
 
 typedef int (*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock,
 				void *cb_arg);
diff --git a/lib/list_lru.c b/lib/list_lru.c
index 475d0e9..881e342 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -6,6 +6,7 @@
  */
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/mm.h>
 #include <linux/list_lru.h>
 
 int
@@ -13,14 +14,19 @@ list_lru_add(
 	struct list_lru	*lru,
 	struct list_head *item)
 {
-	spin_lock(&lru->lock);
+	int nid = page_to_nid(virt_to_page(item));
+	struct list_lru_node *nlru = &lru->node[nid];
+
+	spin_lock(&nlru->lock);
+	BUG_ON(nlru->nr_items < 0);
 	if (list_empty(item)) {
-		list_add_tail(item, &lru->list);
-		lru->nr_items++;
-		spin_unlock(&lru->lock);
+		list_add_tail(item, &nlru->list);
+		if (nlru->nr_items++ == 0)
+			node_set(nid, lru->active_nodes);
+		spin_unlock(&nlru->lock);
 		return 1;
 	}
-	spin_unlock(&lru->lock);
+	spin_unlock(&nlru->lock);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(list_lru_add);
@@ -30,43 +36,72 @@ list_lru_del(
 	struct list_lru	*lru,
 	struct list_head *item)
 {
-	spin_lock(&lru->lock);
+	int nid = page_to_nid(virt_to_page(item));
+	struct list_lru_node *nlru = &lru->node[nid];
+
+	spin_lock(&nlru->lock);
 	if (!list_empty(item)) {
 		list_del_init(item);
-		lru->nr_items--;
-		spin_unlock(&lru->lock);
+		if (--nlru->nr_items == 0)
+			node_clear(nid, lru->active_nodes);
+		BUG_ON(nlru->nr_items < 0);
+		spin_unlock(&nlru->lock);
 		return 1;
 	}
-	spin_unlock(&lru->lock);
+	spin_unlock(&nlru->lock);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(list_lru_del);
 
 long
-list_lru_walk(
-	struct list_lru *lru,
-	list_lru_walk_cb isolate,
-	void		*cb_arg,
-	long		nr_to_walk)
+list_lru_count(
+	struct list_lru *lru)
 {
+	long count = 0;
+	int nid;
+
+	for_each_node_mask(nid, lru->active_nodes) {
+		struct list_lru_node *nlru = &lru->node[nid];
+
+		spin_lock(&nlru->lock);
+		BUG_ON(nlru->nr_items < 0);
+		count += nlru->nr_items;
+		spin_unlock(&nlru->lock);
+	}
+
+	return count;
+}
+EXPORT_SYMBOL_GPL(list_lru_count);
+
+static long
+list_lru_walk_node(
+	struct list_lru		*lru,
+	int			nid,
+	list_lru_walk_cb	isolate,
+	void			*cb_arg,
+	long			*nr_to_walk)
+{
+	struct list_lru_node	*nlru = &lru->node[nid];
 	struct list_head *item, *n;
-	long removed = 0;
+	long isolated = 0;
 restart:
-	spin_lock(&lru->lock);
-	list_for_each_safe(item, n, &lru->list) {
+	spin_lock(&nlru->lock);
+	list_for_each_safe(item, n, &nlru->list) {
 		int ret;
 
-		if (nr_to_walk-- < 0)
+		if ((*nr_to_walk)-- < 0)
 			break;
 
-		ret = isolate(item, &lru->lock, cb_arg);
+		ret = isolate(item, &nlru->lock, cb_arg);
 		switch (ret) {
 		case 0:	/* item removed from list */
-			lru->nr_items--;
-			removed++;
+			if (--nlru->nr_items == 0)
+				node_clear(nid, lru->active_nodes);
+			BUG_ON(nlru->nr_items < 0);
+			isolated++;
 			break;
 		case 1: /* item referenced, give another pass */
-			list_move_tail(item, &lru->list);
+			list_move_tail(item, &nlru->list);
 			break;
 		case 2: /* item cannot be locked, skip */
 			break;
@@ -76,42 +111,89 @@ restart:
 			BUG();
 		}
 	}
-	spin_unlock(&lru->lock);
-	return removed;
+	spin_unlock(&nlru->lock);
+	return isolated;
+}
+
+long
+list_lru_walk(
+	struct list_lru	*lru,
+	list_lru_walk_cb isolate,
+	void		*cb_arg,
+	long		nr_to_walk)
+{
+	long isolated = 0;
+	int nid;
+
+	for_each_node_mask(nid, lru->active_nodes) {
+		isolated += list_lru_walk_node(lru, nid, isolate,
+					       cb_arg, &nr_to_walk);
+		if (nr_to_walk <= 0)
+			break;
+	}
+	return isolated;
 }
 EXPORT_SYMBOL_GPL(list_lru_walk);
 
 long
-list_lru_dispose_all(
-	struct list_lru *lru,
-	list_lru_dispose_cb dispose)
+list_lru_dispose_all_node(
+	struct list_lru		*lru,
+	int			nid,
+	list_lru_dispose_cb	dispose)
 {
-	long disposed = 0;
+	struct list_lru_node	*nlru = &lru->node[nid];
 	LIST_HEAD(dispose_list);
+	long disposed = 0;
 
-	spin_lock(&lru->lock);
-	while (!list_empty(&lru->list)) {
-		list_splice_init(&lru->list, &dispose_list);
-		disposed += lru->nr_items;
-		lru->nr_items = 0;
-		spin_unlock(&lru->lock);
+	spin_lock(&nlru->lock);
+	while (!list_empty(&nlru->list)) {
+		list_splice_init(&nlru->list, &dispose_list);
+		disposed += nlru->nr_items;
+		nlru->nr_items = 0;
+		node_clear(nid, lru->active_nodes);
+		spin_unlock(&nlru->lock);
 
 		dispose(&dispose_list);
 
-		spin_lock(&lru->lock);
+		spin_lock(&nlru->lock);
 	}
-	spin_unlock(&lru->lock);
+	spin_unlock(&nlru->lock);
 	return disposed;
 }
 
+long
+list_lru_dispose_all(
+	struct list_lru		*lru,
+	list_lru_dispose_cb	dispose)
+{
+	long disposed;
+	long total = 0;
+	int nid;
+
+	do {
+		disposed = 0;
+		for_each_node_mask(nid, lru->active_nodes) {
+			disposed += list_lru_dispose_all_node(lru, nid,
+							      dispose);
+		}
+		total += disposed;
+	} while (disposed != 0);
+
+	return total;
+}
+
 int
 list_lru_init(
 	struct list_lru	*lru)
 {
-	spin_lock_init(&lru->lock);
-	INIT_LIST_HEAD(&lru->list);
-	lru->nr_items = 0;
+	int i;
 
+	nodes_clear(lru->active_nodes);
+	for (i = 0; i < MAX_NUMNODES; i++) {
+		spin_lock_init(&lru->node[i].lock);
+		INIT_LIST_HEAD(&lru->node[i].list);
+		lru->node[i].nr_items = 0;
+	}
 	return 0;
 }
 EXPORT_SYMBOL_GPL(list_lru_init);
-- 
1.8.1.4
