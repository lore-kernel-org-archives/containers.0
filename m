From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: [RFC][PATCH]example: use css_tryget() in memcg Re: [RFC][PATCH 3/3]
	CGroups: Add css_tryget()
Date: Thu, 11 Dec 2008 16:02:22 +0900
Message-ID: <20081211160222.1898ad2f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081210233654.563182000@menage.corp.google.com>
	<20081210234432.407064000@menage.corp.google.com>
	<20081211095255.8763905f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081211095255.8763905f.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

An exmaple. and css_is_removed() is added (by other patch)

bool	css_is_removed(struct cgroup_subsys_state *css)
{
	return test_bit(CSS_REMOVED, &css->flags);
}
==
From:KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Use css_tryget() in memcg.

css_tryget() newly is added and we can know css is alive or not and
get refcnt of css in very safe way.
("alive" here means "rmdir/destroy" is not called.)

This patch replaces css_get() to css_tryget(), where I cannot explain
why css_get() is safe. And removes memcg->obsolete flag.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
 mm/memcontrol.c |   98 ++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 61 insertions(+), 37 deletions(-)

Index: mmotm-2.6.28-Dec10/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec10.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec10/mm/memcontrol.c
@@ -162,7 +162,6 @@ struct mem_cgroup {
 	 */
 	bool use_hierarchy;
 	unsigned long	last_oom_jiffies;
-	int		obsolete;
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
@@ -286,6 +285,31 @@ struct mem_cgroup *mem_cgroup_from_task(
 				struct mem_cgroup, css);
 }
 
+static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
+{
+	struct mem_cgroup *mem = NULL;
+	/*
+	 * Because we have no locks, mm->owner's may be being moved to other
+	 * cgroup. We use css_tryget() here even if this looks
+	 * pessimistic (rather than adding locks here).
+	 */
+	rcu_read_lock();
+	do {
+		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
+		if (unlikely(!mem))
+			break;
+	} while (!css_tryget(&mem->css));
+	rcu_read_unlock();
+	return mem;
+}
+
+static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
+{
+	if (!mem)
+		return true;
+	return css_is_removed(&mem->css);
+}
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -592,8 +616,9 @@ mem_cgroup_get_first_node(struct mem_cgr
 {
 	struct cgroup *cgroup;
 	struct mem_cgroup *ret;
-	bool obsolete = (root_mem->last_scanned_child &&
-				root_mem->last_scanned_child->obsolete);
+	bool obsolete;
+
+	obsolete = mem_cgroup_is_obsolete(root_mem->last_scanned_child);
 
 	/*
 	 * Scan all children under the mem_cgroup mem
@@ -681,7 +706,7 @@ static int mem_cgroup_hierarchical_recla
 	next_mem = mem_cgroup_get_first_node(root_mem);
 
 	while (next_mem != root_mem) {
-		if (next_mem->obsolete) {
+		if (mem_cgroup_is_obsolete(next_mem)) {
 			mem_cgroup_put(next_mem);
 			next_mem = mem_cgroup_get_first_node(root_mem);
 			continue;
@@ -737,23 +762,17 @@ static int __mem_cgroup_try_charge(struc
 	 * thread group leader migrates. It's possible that mm is not
 	 * set, if so charge the init_mm (happens for pagecache usage).
 	 */
-	if (likely(!*memcg)) {
-		rcu_read_lock();
-		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-		if (unlikely(!mem)) {
-			rcu_read_unlock();
-			return 0;
-		}
-		/*
-		 * For every charge from the cgroup, increment reference count
-		 */
-		css_get(&mem->css);
+	mem = *memcg;
+	if (likely(!mem)) {
+		mem = try_get_mem_cgroup_from_mm(mm);
 		*memcg = mem;
-		rcu_read_unlock();
 	} else {
-		mem = *memcg;
 		css_get(&mem->css);
 	}
+	if (unlikely(!mem))
+		return 0;
+
+	VM_BUG_ON(mem_cgroup_is_obsolete(mem));
 
 	while (1) {
 		int ret;
@@ -1040,12 +1059,19 @@ int mem_cgroup_cache_charge(struct page 
 				MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
 }
 
+/*
+ * While swap-in, try_charge -> commit or cancel, the page is locked.
+ * And when try_charge() successfully returns, one refcnt to memcg without
+ * struct page_cgroup is aquired. This refcnt will be cumsumed by
+ * "commit()" or removed by "cancel()"
+ */
 int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 				 struct page *page,
 				 gfp_t mask, struct mem_cgroup **ptr)
 {
 	struct mem_cgroup *mem;
 	swp_entry_t     ent;
+	int ret;
 
 	if (mem_cgroup_disabled())
 		return 0;
@@ -1064,10 +1090,15 @@ int mem_cgroup_try_charge_swapin(struct 
 	ent.val = page_private(page);
 
 	mem = lookup_swap_cgroup(ent);
-	if (!mem || mem->obsolete)
+	if (!mem)
+		goto charge_cur_mm;
+	if (css_tryget(&mem->css))
 		goto charge_cur_mm;
 	*ptr = mem;
-	return __mem_cgroup_try_charge(NULL, mask, ptr, true);
+	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true);
+	/* drop extra refcnt from tryget */
+	css_put(&mem->css);
+	return ret;
 charge_cur_mm:
 	if (unlikely(!mm))
 		mm = &init_mm;
@@ -1098,13 +1129,18 @@ int mem_cgroup_cache_charge_swapin(struc
 		ent.val = page_private(page);
 		if (do_swap_account) {
 			mem = lookup_swap_cgroup(ent);
-			if (mem && mem->obsolete)
-				mem = NULL;
-			if (mem)
-				mm = NULL;
+			if (mem) {
+				if (css_tryget(&mem->css))
+					mm = NULL; /* charge to recorded */
+				else
+					mem = NULL; /* charge to current */
+			}
 		}
 		ret = mem_cgroup_charge_common(page, mm, mask,
 				MEM_CGROUP_CHARGE_TYPE_SHMEM, mem);
+		/* drop extra refcnt from tryget */
+		if (mem)
+			css_put(&mem->css);
 
 		if (!ret && do_swap_account) {
 			/* avoid double counting */
@@ -1145,7 +1181,6 @@ void mem_cgroup_commit_charge_swapin(str
 		struct mem_cgroup *memcg;
 		memcg = swap_cgroup_record(ent, NULL);
 		if (memcg) {
-			/* If memcg is obsolete, memcg can be != ptr */
 			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
 			mem_cgroup_put(memcg);
 		}
@@ -1388,14 +1423,9 @@ int mem_cgroup_shrink_usage(struct mm_st
 	if (!mm)
 		return 0;
 
-	rcu_read_lock();
-	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-	if (unlikely(!mem)) {
-		rcu_read_unlock();
+	mem = try_get_mem_cgroup_from_mm(mm);
+	if (unlikely(!mem))
 		return 0;
-	}
-	css_get(&mem->css);
-	rcu_read_unlock();
 
 	do {
 		progress = mem_cgroup_hierarchical_reclaim(mem, gfp_mask, true);
@@ -2081,9 +2111,6 @@ static struct mem_cgroup *mem_cgroup_all
  * the number of reference from swap_cgroup and free mem_cgroup when
  * it goes down to 0.
  *
- * When mem_cgroup is destroyed, mem->obsolete will be set to 0 and
- * entry which points to this memcg will be ignore at swapin.
- *
  * Removal of cgroup itself succeeds regardless of refs from swap.
  */
 
@@ -2112,8 +2139,6 @@ static void mem_cgroup_get(struct mem_cg
 static void mem_cgroup_put(struct mem_cgroup *mem)
 {
 	if (atomic_dec_and_test(&mem->refcnt)) {
-		if (!mem->obsolete)
-			return;
 		mem_cgroup_free(mem);
 	}
 }
@@ -2179,7 +2204,6 @@ static void mem_cgroup_pre_destroy(struc
 					struct cgroup *cont)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
-	mem->obsolete = 1;
 	mem_cgroup_force_empty(mem, false);
 }
