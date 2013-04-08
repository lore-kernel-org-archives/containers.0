From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v3 30/32] memcg: shrink dead memcgs upon global memory
	pressure.
Date: Mon,  8 Apr 2013 18:00:57 +0400
Message-ID: <1365429659-22108-31-git-send-email-glommer@parallels.com>
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

When a kmem enable memcg dies, it can still be walking dead around
because some caches hold a reference to it (it can happen due to swap as
well).

Past efforts to actively insist on shrinking them upon memcg destruction
led to extra complication, so the goal has been since them to do it from
global reclaim.

Now that the case of kmemcg shrinker is more clear, we can also include
a shrink_slab-time reaper that will try to get rid of the dangling
caches.

There are two reasons why I am not using a normal shrinker interface:
First, it is hard and expensive for us to determine how many objects we
have. We also don't need to save any of those objects since they are not
expecting to be caching anything: we want here to free as many memory as
we can.
Second, the caches are pinned down by cache objects which will, in turn,
be shrunk by shrink_slab. We would like that to be the last step. So to
avoid complicating the shrinker registration, we can just manually
insert this step

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
Andrew: This will conflict with a -mm-only debug patch you have since I
am reusing its dead-list infrastructure. You will have to dump that, and
apply a new version that only adds the debugging interface.
---
 include/linux/memcontrol.h |  6 ++++
 mm/memcontrol.c            | 75 ++++++++++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c                |  1 +
 3 files changed, 80 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 782dcbf..fec50ef 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -482,6 +482,7 @@ int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
 
 void mem_cgroup_destroy_cache(struct kmem_cache *cachep);
 void kmem_cache_destroy_memcg_children(struct kmem_cache *s);
+void reap_dead_memcgs(void);
 
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
@@ -660,6 +661,11 @@ static inline struct mem_cgroup *mem_cgroup_from_kmem_page(struct page *page)
 {
 	return NULL;
 }
+
+static inline void reap_dead_memcgs(void)
+{
+}
+
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1f1ded3..cafb3c5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -310,8 +310,16 @@ struct mem_cgroup {
 	/* thresholds for mem+swap usage. RCU-protected */
 	struct mem_cgroup_thresholds memsw_thresholds;
 
-	/* For oom notifier event fd */
-	struct list_head oom_notify;
+	union {
+		/* For oom notifier event fd */
+		struct list_head oom_notify;
+		/*
+		 * we can only trigger an oom event if the memcg is alive.
+		 * so we will reuse this field to hook the memcg in the list
+		 * of dead memcgs.
+		 */
+		struct list_head dead;
+	};
 
 	/*
 	 * Should we move charges of a task when a task is moved into this
@@ -373,6 +381,24 @@ static size_t memcg_size(void)
 
 static DEFINE_MUTEX(set_limit_mutex);
 
+static LIST_HEAD(dangling_memcgs);
+static DEFINE_MUTEX(dangling_memcgs_mutex);
+
+static inline void memcg_dangling_free(struct mem_cgroup *memcg)
+{
+	mutex_lock(&dangling_memcgs_mutex);
+	list_del(&memcg->dead);
+	mutex_unlock(&dangling_memcgs_mutex);
+}
+
+static inline void memcg_dangling_add(struct mem_cgroup *memcg)
+{
+	INIT_LIST_HEAD(&memcg->dead);
+	mutex_lock(&dangling_memcgs_mutex);
+	list_add(&memcg->dead, &dangling_memcgs);
+	mutex_unlock(&dangling_memcgs_mutex);
+}
+
 /* internal only representation about the status of kmem accounting. */
 enum {
 	KMEM_ACCOUNTED_ACTIVE = 0, /* accounted by this cgroup itself */
@@ -6023,6 +6049,48 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 }
 
 #ifdef CONFIG_MEMCG_KMEM
+static void memcg_shrink_dead_fn(struct work_struct *w)
+{
+	struct memcg_cache_params *params, *tmp;
+	struct kmem_cache *cachep;
+	struct mem_cgroup *memcg;
+
+	mutex_lock(&dangling_memcgs_mutex);
+	list_for_each_entry(memcg, &dangling_memcgs, dead) {
+		mem_cgroup_get(memcg);
+		mutex_lock(&memcg->slab_caches_mutex);
+		/* The element may go away as an indirect result of shrink */
+		list_for_each_entry_safe(params, tmp,
+					 &memcg->memcg_slab_caches, list) {
+			cachep = memcg_params_to_cache(params);
+			/*
+			 * the cpu_hotplug lock is taken in kmem_cache_create
+			 * outside the slab_caches_mutex manipulation. It will
+			 * be taken by kmem_cache_shrink to flush the cache.
+			 * So we need to drop the lock. It is all right because
+			 * the lock only protects elements moving in and out the
+			 * list.
+			 */
+			mutex_unlock(&memcg->slab_caches_mutex);
+			kmem_cache_shrink(cachep);
+			mutex_lock(&memcg->slab_caches_mutex);
+		}
+		mutex_unlock(&memcg->slab_caches_mutex);
+		mem_cgroup_put(memcg);
+	}
+	mutex_unlock(&dangling_memcgs_mutex);
+}
+static DECLARE_WORK(kmemcg_dangling_work, memcg_shrink_dead_fn);
+
+/*
+ * We can't take any of our locks in reclaim context, because we've taken them
+ * in other contexts before, so we could deadlock.
+ */
+void reap_dead_memcgs(void)
+{
+	schedule_work(&kmemcg_dangling_work);
+}
+
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	int ret;
@@ -6317,6 +6385,8 @@ static void free_work(struct work_struct *work)
 	struct mem_cgroup *memcg;
 
 	memcg = container_of(work, struct mem_cgroup, work_freeing);
+
+	memcg_dangling_free(memcg);
 	__mem_cgroup_free(memcg);
 }
 
@@ -6491,6 +6561,7 @@ static void mem_cgroup_css_free(struct cgroup *cont)
 
 	kmem_cgroup_destroy(memcg);
 
+	memcg_dangling_add(memcg);
 	mem_cgroup_put(memcg);
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 752e9c7..c72e7dd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -378,6 +378,7 @@ unsigned long shrink_slab(struct shrink_control *sc,
 	up_read(&shrinker_rwsem);
 out:
 	cond_resched();
+	reap_dead_memcgs();
 	return freed;
 }
 
-- 
1.8.1.4
