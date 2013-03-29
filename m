From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v2 22/28] memcg,list_lru: duplicate LRUs upon kmemcg creation
Date: Fri, 29 Mar 2013 13:14:04 +0400
Message-ID: <1364548450-28254-23-git-send-email-glommer__44376.2528863319$1364548657$gmane$org@parallels.com>
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

When a new memcg is created, we need to open up room for its descriptors
in all of the list_lrus that are marked per-memcg. The process is quite
similar to the one we are using for the kmem caches: we initialize the
new structures in an array indexed by kmemcg_id, and grow the array if
needed. Key data like the size of the array will be shared between the
kmem cache code and the list_lru code (they basically describe the same
thing)

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
 include/linux/list_lru.h   |  37 ++++++++++-
 include/linux/memcontrol.h |  12 ++++
 lib/list_lru.c             | 101 +++++++++++++++++++++++++++---
 mm/memcontrol.c            | 151 +++++++++++++++++++++++++++++++++++++++++++--
 mm/slab_common.c           |   1 -
 5 files changed, 285 insertions(+), 17 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 02796da..d6cf126 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -16,12 +16,47 @@ struct list_lru_node {
 	long			nr_items;
 } ____cacheline_aligned_in_smp;
 
+/*
+ * This is supposed to be M x N matrix, where M is kmem-limited memcg,
+ * and N is the number of nodes.
+ */
+struct list_lru_array {
+	struct list_lru_node node[1];
+};
+
 struct list_lru {
 	struct list_lru_node	node[MAX_NUMNODES];
 	nodemask_t		active_nodes;
+#ifdef CONFIG_MEMCG_KMEM
+	struct list_head	lrus;
+	struct list_lru_array	**memcg_lrus;
+#endif
 };
 
-int list_lru_init(struct list_lru *lru);
+struct mem_cgroup;
+#ifdef CONFIG_MEMCG_KMEM
+struct list_lru_array *lru_alloc_array(void);
+int memcg_update_all_lrus(unsigned long num);
+void list_lru_destroy(struct list_lru *lru);
+void list_lru_destroy_memcg(struct mem_cgroup *memcg);
+int __memcg_init_lru(struct list_lru *lru);
+#else
+static inline void list_lru_destroy(struct list_lru *lru)
+{
+}
+#endif
+
+int __list_lru_init(struct list_lru *lru, bool memcg_enabled);
+static inline int list_lru_init(struct list_lru *lru)
+{
+	return __list_lru_init(lru, false);
+}
+
+static inline int list_lru_init_memcg(struct list_lru *lru)
+{
+	return __list_lru_init(lru, true);
+}
+
 int list_lru_add(struct list_lru *lru, struct list_head *item);
 int list_lru_del(struct list_lru *lru, struct list_head *item);
 long list_lru_count_nodemask(struct list_lru *lru, nodemask_t *nodes_to_count);
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 4c24249..ee3199d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -23,6 +23,7 @@
 #include <linux/vm_event_item.h>
 #include <linux/hardirq.h>
 #include <linux/jump_label.h>
+#include <linux/list_lru.h>
 
 struct mem_cgroup;
 struct page_cgroup;
@@ -469,6 +470,12 @@ void memcg_update_array_size(int num_groups);
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
+int memcg_new_lru(struct list_lru *lru);
+int memcg_init_lru(struct list_lru *lru);
+
+int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
+			       bool new_lru);
+
 void mem_cgroup_destroy_cache(struct kmem_cache *cachep);
 void kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
@@ -632,6 +639,11 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 static inline void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 {
 }
+
+static inline int memcg_init_lru(struct list_lru *lru)
+{
+	return 0;
+}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/lib/list_lru.c b/lib/list_lru.c
index 0f08ed6..a9616a0 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -8,6 +8,7 @@
 #include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/list_lru.h>
+#include <linux/memcontrol.h>
 
 int
 list_lru_add(
@@ -184,18 +185,100 @@ list_lru_dispose_all(
 	return total;
 }
 
-int
-list_lru_init(
-	struct list_lru	*lru)
+/*
+ * This protects the list of all LRU in the system. One only needs
+ * to take when registering an LRU, or when duplicating the list of lrus.
+ * Transversing an LRU can and should be done outside the lock
+ */
+static DEFINE_MUTEX(all_memcg_lrus_mutex);
+static LIST_HEAD(all_memcg_lrus);
+
+static void list_lru_init_one(struct list_lru_node *lru)
 {
+	spin_lock_init(&lru->lock);
+	INIT_LIST_HEAD(&lru->list);
+	lru->nr_items = 0;
+}
+
+struct list_lru_array *lru_alloc_array(void)
+{
+	struct list_lru_array *lru_array;
 	int i;
 
-	nodes_clear(lru->active_nodes);
-	for (i = 0; i < MAX_NUMNODES; i++) {
-		spin_lock_init(&lru->node[i].lock);
-		INIT_LIST_HEAD(&lru->node[i].list);
-		lru->node[i].nr_items = 0;
+	lru_array = kzalloc(nr_node_ids * sizeof(struct list_lru_node),
+				GFP_KERNEL);
+	if (!lru_array)
+		return NULL;
+
+	for (i = 0; i < nr_node_ids ; i++)
+		list_lru_init_one(&lru_array->node[i]);
+
+	return lru_array;
+}
+
+#ifdef CONFIG_MEMCG_KMEM
+int __memcg_init_lru(struct list_lru *lru)
+{
+	int ret;
+
+	INIT_LIST_HEAD(&lru->lrus);
+	mutex_lock(&all_memcg_lrus_mutex);
+	list_add(&lru->lrus, &all_memcg_lrus);
+	ret = memcg_new_lru(lru);
+	mutex_unlock(&all_memcg_lrus_mutex);
+	return ret;
+}
+
+int memcg_update_all_lrus(unsigned long num)
+{
+	int ret = 0;
+	struct list_lru *lru;
+
+	mutex_lock(&all_memcg_lrus_mutex);
+	list_for_each_entry(lru, &all_memcg_lrus, lrus) {
+		ret = memcg_kmem_update_lru_size(lru, num, false);
+		if (ret)
+			goto out;
+	}
+out:
+	mutex_unlock(&all_memcg_lrus_mutex);
+	return ret;
+}
+
+void list_lru_destroy(struct list_lru *lru)
+{
+	if (!lru->memcg_lrus)
+		return;
+
+	mutex_lock(&all_memcg_lrus_mutex);
+	list_del(&lru->lrus);
+	mutex_unlock(&all_memcg_lrus_mutex);
+}
+
+void list_lru_destroy_memcg(struct mem_cgroup *memcg)
+{
+	struct list_lru *lru;
+	mutex_lock(&all_memcg_lrus_mutex);
+	list_for_each_entry(lru, &all_memcg_lrus, lrus) {
+		kfree(lru->memcg_lrus[memcg_cache_id(memcg)]);
+		lru->memcg_lrus[memcg_cache_id(memcg)] = NULL;
+		/* everybody must beaware that this memcg is no longer valid */
+		wmb();
 	}
+	mutex_unlock(&all_memcg_lrus_mutex);
+}
+#endif
+
+int __list_lru_init(struct list_lru *lru, bool memcg_enabled)
+{
+	int i;
+
+	nodes_clear(lru->active_nodes);
+	for (i = 0; i < MAX_NUMNODES; i++)
+		list_lru_init_one(&lru->node[i]);
+
+	if (memcg_enabled)
+		return memcg_init_lru(lru);
 	return 0;
 }
-EXPORT_SYMBOL_GPL(list_lru_init);
+EXPORT_SYMBOL_GPL(__list_lru_init);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ecdae39..c6c90d8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2988,16 +2988,30 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 	memcg_kmem_set_activated(memcg);
 
 	ret = memcg_update_all_caches(num+1);
-	if (ret) {
-		ida_simple_remove(&kmem_limited_groups, num);
-		memcg_kmem_clear_activated(memcg);
-		return ret;
-	}
+	if (ret)
+		goto out;
+
+	/*
+	 * We should make sure that the array size is not updated until we are
+	 * done; otherwise we have no easy way to know whether or not we should
+	 * grow the array.
+	 */
+	ret = memcg_update_all_lrus(num + 1);
+	if (ret)
+		goto out;
 
 	memcg->kmemcg_id = num;
+
+	memcg_update_array_size(num + 1);
+
 	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
 	mutex_init(&memcg->slab_caches_mutex);
+
 	return 0;
+out:
+	ida_simple_remove(&kmem_limited_groups, num);
+	memcg_kmem_clear_activated(memcg);
+	return ret;
 }
 
 static size_t memcg_caches_array_size(int num_groups)
@@ -3081,6 +3095,129 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 	return 0;
 }
 
+/*
+ * memcg_kmem_update_lru_size - fill in kmemcg info into a list_lru
+ *
+ * @lru: the lru we are operating with
+ * @num_groups: how many kmem-limited cgroups we have
+ * @new_lru: true if this is a new_lru being created, false if this
+ * was triggered from the memcg side
+ *
+ * Returns 0 on success, and an error code otherwise.
+ *
+ * This function can be called either when a new kmem-limited memcg appears,
+ * or when a new list_lru is created. The work is roughly the same in two cases,
+ * but in the later we never have to expand the array size.
+ *
+ * This is always protected by the all_lrus_mutex from the list_lru side.  But
+ * a race can still exists if a new memcg becomes kmem limited at the same time
+ * that we are registering a new memcg. Creation is protected by the
+ * memcg_mutex, so the creation of a new lru have to be protected by that as
+ * well.
+ *
+ * The lock ordering is that the memcg_mutex needs to be acquired before the
+ * lru-side mutex.
+ */
+int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
+			       bool new_lru)
+{
+	struct list_lru_array **new_lru_array;
+	struct list_lru_array *lru_array;
+
+	lru_array = lru_alloc_array();
+	if (!lru_array)
+		return -ENOMEM;
+
+	/*
+	 * When a new LRU is created, we still need to update all data for that
+	 * LRU. The procedure for late LRUs and new memcgs are quite similar, we
+	 * only need to make sure we get into the loop even if num_groups <
+	 * memcg_limited_groups_array_size.
+	 */
+	if ((num_groups > memcg_limited_groups_array_size) || new_lru) {
+		int i;
+		struct list_lru_array **old_array;
+		size_t size = memcg_caches_array_size(num_groups);
+		int num_memcgs = memcg_limited_groups_array_size;
+
+		new_lru_array = kzalloc(size * sizeof(void *), GFP_KERNEL);
+		if (!new_lru_array) {
+			kfree(lru_array);
+			return -ENOMEM;
+		}
+
+		for (i = 0; lru->memcg_lrus && (i < num_memcgs); i++) {
+			if (lru->memcg_lrus && lru->memcg_lrus[i])
+				continue;
+			new_lru_array[i] =  lru->memcg_lrus[i];
+		}
+
+		old_array = lru->memcg_lrus;
+		lru->memcg_lrus = new_lru_array;
+		/*
+		 * We don't need a barrier here because we are just copying
+		 * information over. Anybody operating in memcg_lrus will
+		 * either follow the new array or the old one and they contain
+		 * exactly the same information. The new space in the end is
+		 * always empty anyway.
+		 */
+		if (lru->memcg_lrus)
+			kfree(old_array);
+	}
+
+	if (lru->memcg_lrus) {
+		lru->memcg_lrus[num_groups - 1] = lru_array;
+		/*
+		 * Here we do need the barrier, because of the state transition
+		 * implied by the assignment of the array. All users should be
+		 * able to see it
+		 */
+		wmb();
+	}
+	return 0;
+}
+
+/*
+ * This is called with the LRU-mutex being held.
+ */
+int memcg_new_lru(struct list_lru *lru)
+{
+	struct mem_cgroup *iter;
+
+	if (!memcg_kmem_enabled())
+		return 0;
+
+	for_each_mem_cgroup(iter) {
+		int ret;
+		int memcg_id = memcg_cache_id(iter);
+		if (memcg_id < 0)
+			continue;
+
+		ret = memcg_kmem_update_lru_size(lru, memcg_id + 1, true);
+		if (ret) {
+			mem_cgroup_iter_break(root_mem_cgroup, iter);
+			return ret;
+		}
+	}
+	return 0;
+}
+
+/*
+ * We need to call back and forth from memcg to LRU because of the lock
+ * ordering.  This complicates the flow a little bit, but since the memcg mutex
+ * is held through the whole duration of memcg creation, we need to hold it
+ * before we hold the LRU-side mutex in the case of a new list creation as
+ * well.
+ */
+int memcg_init_lru(struct list_lru *lru)
+{
+	int ret;
+	mutex_lock(&memcg_create_mutex);
+	ret = __memcg_init_lru(lru);
+	mutex_unlock(&memcg_create_mutex);
+	return ret;
+}
+
 int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
 			 struct kmem_cache *root_cache)
 {
@@ -5775,8 +5912,10 @@ static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
 	 * possible that the charges went down to 0 between mark_dead and the
 	 * res_counter read, so in that case, we don't need the put
 	 */
-	if (memcg_kmem_test_and_clear_dead(memcg))
+	if (memcg_kmem_test_and_clear_dead(memcg)) {
+		list_lru_destroy_memcg(memcg);
 		mem_cgroup_put(memcg);
+	}
 }
 #else
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3f3cd97..2470d11 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -102,7 +102,6 @@ int memcg_update_all_caches(int num_memcgs)
 			goto out;
 	}
 
-	memcg_update_array_size(num_memcgs);
 out:
 	mutex_unlock(&slab_mutex);
 	return ret;
-- 
1.8.1.4
