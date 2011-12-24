From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: [PATCH 6/6] memcg: drop redundant brackets
Date: Sat, 24 Dec 2011 05:00:19 +0200
Message-ID: <1324695619-5537-6-git-send-email-kirill__28332.1519651965$1324696232$gmane$org@shutemov.name>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1324695619-5537-1-git-send-email-kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>

Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
---
 mm/memcontrol.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3833a7b..48cba05 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -73,7 +73,7 @@ static int really_do_swap_account __initdata = 0;
 #endif
 
 #else
-#define do_swap_account		(0)
+#define do_swap_account		0
 #endif
 
 
@@ -113,9 +113,9 @@ enum mem_cgroup_events_target {
 	MEM_CGROUP_TARGET_NUMAINFO,
 	MEM_CGROUP_NTARGETS,
 };
-#define THRESHOLDS_EVENTS_TARGET (128)
-#define SOFTLIMIT_EVENTS_TARGET (1024)
-#define NUMAINFO_EVENTS_TARGET	(1024)
+#define THRESHOLDS_EVENTS_TARGET 128
+#define SOFTLIMIT_EVENTS_TARGET 1024
+#define NUMAINFO_EVENTS_TARGET	1024
 
 struct mem_cgroup_stat_cpu {
 	long count[MEM_CGROUP_STAT_NSTATS];
@@ -148,7 +148,7 @@ struct mem_cgroup_per_zone {
 						/* use container_of	   */
 };
 /* Macro for accessing counter */
-#define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
+#define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[idx])
 
 struct mem_cgroup_per_node {
 	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
@@ -346,8 +346,8 @@ static bool move_file(void)
  * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
  * limit reclaim to prevent infinite loops, if they ever occur.
  */
-#define	MEM_CGROUP_MAX_RECLAIM_LOOPS		(100)
-#define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	(2)
+#define	MEM_CGROUP_MAX_RECLAIM_LOOPS		100
+#define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	2
 
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
@@ -368,11 +368,11 @@ enum mem_type {
 	_KMEM,
 };
 
-#define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
-#define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
+#define MEMFILE_PRIVATE(x, val)	((x) << 16 | (val))
+#define MEMFILE_TYPE(val)	((val) >> 16 & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
 /* Used for OOM nofiier */
-#define OOM_CONTROL		(0)
+#define OOM_CONTROL		0
 
 /*
  * Reclaim flags for mem_cgroup_hierarchical_reclaim
@@ -1913,7 +1913,7 @@ struct memcg_stock_pcp {
 	unsigned int nr_pages;
 	struct work_struct work;
 	unsigned long flags;
-#define FLUSHING_CACHED_CHARGE	(0)
+#define FLUSHING_CACHED_CHARGE	0
 };
 static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
 static DEFINE_MUTEX(percpu_charge_mutex);
@@ -2094,7 +2094,7 @@ static int __cpuinit memcg_cpu_hotplug_callback(struct notifier_block *nb,
 	struct memcg_stock_pcp *stock;
 	struct mem_cgroup *iter;
 
-	if ((action == CPU_ONLINE)) {
+	if (action == CPU_ONLINE) {
 		for_each_mem_cgroup(iter)
 			synchronize_mem_cgroup_on_move(iter, cpu);
 		return NOTIFY_OK;
@@ -2458,8 +2458,8 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
-#define PCGF_NOCOPY_AT_SPLIT ((1 << PCG_LOCK) | (1 << PCG_MOVE_LOCK) |\
-			(1 << PCG_MIGRATION))
+#define PCGF_NOCOPY_AT_SPLIT (1 << PCG_LOCK | 1 << PCG_MOVE_LOCK |\
+		1 << PCG_MIGRATION)
 /*
  * Because tail pages are not marked as "used", set it. We're under
  * zone->lru_lock, 'splitting on pmd' and compound_lock.
-- 
1.7.7.3
