From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC] [PATCH -mm 1/2] memcg dirty_ratio and additional page statistics
Date: Fri, 12 Sep 2008 17:09:51 +0200
Message-ID: <1221232192-13553-2-git-send-email-righi.andrea__49159.0446945795$1221232442$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <>
References: <>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: David Radford <dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org>, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, =?utf-8?q?Fernando=20Luis=20V=C3=A1zquez=20Cao?= <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, Matt Heaton <matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Collect dirty file and writeback pages to be used by memory cgroup dirty_ratio
to evaluate dirty limits.

Moreover, the following entries are added to the file memory.stat of each
cgroup to export these statistics to userspace:
 - filedirty (number of dirty file pages)
 - writeback (number of pages under writeback)

[ Note: currently only non-anonymous pages are accounted in writeback pages;
for swapped-out pages with swap_writepage() it's not possible to retrieve the
memory cgroup they belong to, so there would be a leak in writeback statistics
if we also try to account these pages without changing too much stuff. ]

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/buffer.c                |    2 +
 fs/nfs/write.c             |    4 +
 fs/nilfs2/page.h           |    9 ++-
 fs/reiser4/as_ops.c        |    5 +-
 fs/reiser4/page_cache.c    |    5 +-
 include/linux/memcontrol.h |   76 ++++++++++++++++++
 mm/filemap.c               |    2 +
 mm/memcontrol.c            |  187 ++++++++++++++++++++++++++++++++++++++++----
 mm/page-writeback.c        |   13 +++-
 mm/truncate.c              |    2 +
 10 files changed, 284 insertions(+), 21 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 8274f5e..fc45593 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -31,6 +31,7 @@
 #include <linux/highmem.h>
 #include <linux/module.h>
 #include <linux/writeback.h>
+#include <linux/memcontrol.h>
 #include <linux/hash.h>
 #include <linux/suspend.h>
 #include <linux/buffer_head.h>
@@ -718,6 +719,7 @@ static int __set_page_dirty(struct page *page,
 		WARN_ON_ONCE(warn && !PageUptodate(page));
 
 		if (mapping_cap_account_dirty(mapping)) {
+			mem_cgroup_charge_file_dirty(page, 1);
 			__inc_zone_page_state(page, NR_FILE_DIRTY);
 			__inc_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3229e21..cd95d3f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -12,6 +12,7 @@
 #include <linux/pagemap.h>
 #include <linux/file.h>
 #include <linux/writeback.h>
+#include <linux/memcontrol.h>
 #include <linux/swap.h>
 
 #include <linux/sunrpc/clnt.h>
@@ -410,6 +411,7 @@ nfs_mark_request_commit(struct nfs_page *req)
 			req->wb_index,
 			NFS_PAGE_TAG_COMMIT);
 	spin_unlock(&inode->i_lock);
+	mem_cgroup_charge_file_dirty(req->wb_page, 1);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
@@ -421,6 +423,7 @@ nfs_clear_request_commit(struct nfs_page *req)
 	struct page *page = req->wb_page;
 
 	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
+		mem_cgroup_charge_file_dirty(page, -1);
 		dec_zone_page_state(page, NR_UNSTABLE_NFS);
 		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
 		return 1;
@@ -1263,6 +1266,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_mark_request_commit(req);
+		mem_cgroup_charge_file_dirty(page, -1);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
 				BDI_RECLAIMABLE);
diff --git a/fs/nilfs2/page.h b/fs/nilfs2/page.h
index b77c91c..a88f84c 100644
--- a/fs/nilfs2/page.h
+++ b/fs/nilfs2/page.h
@@ -24,6 +24,7 @@
 #ifndef _NILFS_PAGE_H
 #define _NILFS_PAGE_H
 
+#include <linux/memcontrol.h>
 #include "nilfs.h"
 
 extern struct buffer_head *nilfs_get_page_block(struct page *, unsigned long,
@@ -68,8 +69,10 @@ nilfs_page_get_nth_block(struct page *page, unsigned int count)
 static inline void nilfs_set_page_writeback(struct page *page)
 {
 	if (buffer_nilfs_allocated(page_buffers(page))) {
-		if (!TestSetPageWriteback(page))
+		if (!TestSetPageWriteback(page)) {
+			mem_cgroup_charge_writeback(page, 1);
 			inc_zone_page_state(page, NR_WRITEBACK);
+		}
 	} else
 		set_page_writeback(page);
 }
@@ -77,8 +80,10 @@ static inline void nilfs_set_page_writeback(struct page *page)
 static inline void nilfs_end_page_writeback(struct page *page)
 {
 	if (buffer_nilfs_allocated(page_buffers(page))) {
-		if (TestClearPageWriteback(page))
+		if (TestClearPageWriteback(page)) {
+			mem_cgroup_charge_writeback(page, -1);
 			dec_zone_page_state(page, NR_WRITEBACK);
+		}
 	} else
 		end_page_writeback(page);
 }
diff --git a/fs/reiser4/as_ops.c b/fs/reiser4/as_ops.c
index decb9eb..1e144ec 100644
--- a/fs/reiser4/as_ops.c
+++ b/fs/reiser4/as_ops.c
@@ -40,6 +40,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/writeback.h>
+#include <linux/memcontrol.h>
 #include <linux/backing-dev.h>
 #include <linux/quotaops.h>
 #include <linux/security.h>
@@ -82,9 +83,11 @@ int reiser4_set_page_dirty(struct page *page)
 			/* check for race with truncate */
 			if (page->mapping) {
 				assert("vs-1652", page->mapping == mapping);
-				if (mapping_cap_account_dirty(mapping))
+				if (mapping_cap_account_dirty(mapping)) {
+					mem_cgroup_charge_file_dirty(page, 1);
 					inc_zone_page_state(page,
 							NR_FILE_DIRTY);
+				}
 				radix_tree_tag_set(&mapping->page_tree,
 						   page->index,
 						   PAGECACHE_TAG_REISER4_MOVED);
diff --git a/fs/reiser4/page_cache.c b/fs/reiser4/page_cache.c
index 654e7ae..7dadb9b 100644
--- a/fs/reiser4/page_cache.c
+++ b/fs/reiser4/page_cache.c
@@ -202,6 +202,7 @@
 #include <linux/pagemap.h>
 #include <linux/bio.h>
 #include <linux/writeback.h>
+#include <linux/memcontrol.h>
 #include <linux/blkdev.h>
 
 static struct bio *page_bio(struct page *, jnode * , int rw, gfp_t gfp);
@@ -467,8 +468,10 @@ int reiser4_set_page_dirty_internal(struct page *page)
 	BUG_ON(mapping == NULL);
 
 	if (!TestSetPageDirty(page)) {
-		if (mapping_cap_account_dirty(mapping))
+		if (mapping_cap_account_dirty(mapping)) {
+			mem_cgroup_charge_file_dirty(page, 1);
 			inc_zone_page_state(page, NR_FILE_DIRTY);
+		}
 
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	}
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ee1b2fc..c3a1f19 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -20,15 +20,48 @@
 #ifndef _LINUX_MEMCONTROL_H
 #define _LINUX_MEMCONTROL_H
 
+#include <linux/cgroup.h>
+
 struct mem_cgroup;
 struct page_cgroup;
 struct page;
 struct mm_struct;
+extern int vm_dirty_ratio;
+
+/*
+ * Statistics for memory cgroup.
+ */
+enum mem_cgroup_stat_index {
+	/*
+	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
+	 */
+	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
+	MEM_CGROUP_STAT_RSS,		/* # of pages charged as rss */
+	MEM_CGROUP_STAT_FILE_DIRTY,	/* # of dirty pages in page cache */
+	MEM_CGROUP_STAT_WRITEBACK,	/* # of pages under writeback */
+	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
+	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
+
+	MEM_CGROUP_STAT_NSTATS,
+};
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
 #define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
 
+struct mem_cgroup *get_current_mem_cgroup(void);
+extern void put_mem_cgroup(struct mem_cgroup *mem);
+
+extern unsigned long mem_cgroup_global_lru_pages(struct mem_cgroup *mem);
+extern unsigned long mem_cgroup_get_free_pages(struct mem_cgroup *mem);
+extern long mem_cgroup_dirty_ratio(struct mem_cgroup *mem);
+
+extern void mem_cgroup_charge_file_dirty(struct page *page, int charge);
+extern s64 mem_cgroup_nr_file_dirty(struct mem_cgroup *mem);
+
+extern void mem_cgroup_charge_writeback(struct page *page, int charge);
+extern s64 mem_cgroup_nr_writeback(struct mem_cgroup *mem);
+
 extern struct page_cgroup *page_get_page_cgroup(struct page *page);
 extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
@@ -132,6 +165,49 @@ static inline void mem_cgroup_end_migration(struct page *page)
 {
 }
 
+static inline struct mem_cgroup *get_current_mem_cgroup(void)
+{
+	return NULL;
+}
+
+static inline void put_mem_cgroup(struct mem_cgroup *mem)
+{
+}
+
+static inline unsigned long mem_cgroup_global_lru_pages(struct mem_cgroup *mem)
+{
+	return 0;
+}
+
+static inline unsigned long mem_cgroup_get_free_pages(struct mem_cgroup *mem)
+{
+	return 0;
+}
+
+static inline long mem_cgroup_dirty_ratio(struct mem_cgroup *mem)
+{
+	return vm_dirty_ratio;
+}
+
+static inline void mem_cgroup_charge_file_dirty(struct page *page, int charge)
+{
+}
+
+static inline void mem_cgroup_charge_writeback(struct page *page, int charge)
+{
+}
+
+static inline s64 mem_cgroup_nr_file_dirty(struct mem_cgroup *mem)
+{
+	return global_page_state(NR_FILE_DIRTY) +
+		global_page_state(NR_UNSTABLE_NFS);
+}
+
+static inline s64 mem_cgroup_nr_writeback(struct mem_cgroup *mem)
+{
+	return global_page_state(NR_WRITEBACK);
+}
+
 static inline int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
 {
 	return 0;
diff --git a/mm/filemap.c b/mm/filemap.c
index 0df6e1f..54f8689 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -25,6 +25,7 @@
 #include <linux/uio.h>
 #include <linux/hash.h>
 #include <linux/writeback.h>
+#include <linux/memcontrol.h>
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 #include <linux/blkdev.h>
@@ -131,6 +132,7 @@ void __remove_from_page_cache(struct page *page)
 	 * having removed the page entirely.
 	 */
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
+		mem_cgroup_charge_file_dirty(page, -1);
 		dec_zone_page_state(page, NR_FILE_DIRTY);
 		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 	}
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2979d22..6de911e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -40,21 +40,6 @@ struct cgroup_subsys mem_cgroup_subsys __read_mostly;
 static struct kmem_cache *page_cgroup_cache __read_mostly;
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 
-/*
- * Statistics for memory cgroup.
- */
-enum mem_cgroup_stat_index {
-	/*
-	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
-	 */
-	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
-	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as rss */
-	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
-	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
-
-	MEM_CGROUP_STAT_NSTATS,
-};
-
 struct mem_cgroup_stat_cpu {
 	s64 count[MEM_CGROUP_STAT_NSTATS];
 } ____cacheline_aligned_in_smp;
@@ -73,6 +58,14 @@ static void __mem_cgroup_stat_add_safe(struct mem_cgroup_stat *stat,
 	stat->cpustat[cpu].count[idx] += val;
 }
 
+static void __mem_cgroup_stat_add(struct mem_cgroup_stat *stat,
+		enum mem_cgroup_stat_index idx, int val)
+{
+	int cpu = get_cpu();
+	stat->cpustat[cpu].count[idx] += val;
+	put_cpu();
+}
+
 static s64 mem_cgroup_read_stat(struct mem_cgroup_stat *stat,
 		enum mem_cgroup_stat_index idx)
 {
@@ -133,6 +126,9 @@ struct mem_cgroup {
 	 * statistics.
 	 */
 	struct mem_cgroup_stat stat;
+
+	/* per memory cgroup dirty_ratio */
+	long dirty_ratio;
 };
 static struct mem_cgroup init_mem_cgroup;
 
@@ -358,6 +354,141 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
 	return ret;
 }
 
+static struct mem_cgroup *get_mem_cgroup_from_page(struct page *page)
+{
+	struct page_cgroup *pc;
+	struct mem_cgroup *mem = NULL;
+
+	lock_page_cgroup(page);
+	pc = page_get_page_cgroup(page);
+	if (pc) {
+		mem = pc->mem_cgroup;
+		css_get(&mem->css);
+	}
+	unlock_page_cgroup(page);
+	return mem;
+}
+
+struct mem_cgroup *get_current_mem_cgroup(void)
+{
+	struct mem_cgroup *mem;
+
+	rcu_read_lock();
+	mem = mem_cgroup_from_task(current);
+	if (likely(mem))
+		css_get(&mem->css);
+	rcu_read_unlock();
+
+	return mem;
+}
+
+void put_mem_cgroup(struct mem_cgroup *mem)
+{
+	css_put(&mem->css);
+}
+
+static void mem_cgroup_charge_stat(struct page *page,
+			enum mem_cgroup_stat_index idx, int charge)
+{
+	struct mem_cgroup *mem;
+
+	mem = get_mem_cgroup_from_page(page);
+	VM_BUG_ON(!mem);
+	__mem_cgroup_stat_add(&mem->stat, idx, charge);
+	css_put(&mem->css);
+}
+
+void mem_cgroup_charge_file_dirty(struct page *page, int charge)
+{
+	mem_cgroup_charge_stat(page, MEM_CGROUP_STAT_FILE_DIRTY, charge);
+}
+
+void mem_cgroup_charge_writeback(struct page *page, int charge)
+{
+	mem_cgroup_charge_stat(page, MEM_CGROUP_STAT_WRITEBACK, charge);
+}
+
+s64 mem_cgroup_nr_file_dirty(struct mem_cgroup *mem)
+{
+	s64 ret;
+
+	if (mem == NULL) {
+		mem = get_current_mem_cgroup();
+		if (unlikely(!mem))
+			return global_page_state(NR_FILE_DIRTY) +
+				global_page_state(NR_UNSTABLE_NFS);
+	} else
+		css_get(&mem->css);
+	ret = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_FILE_DIRTY);
+	css_put(&mem->css);
+	return ret;
+}
+
+s64 mem_cgroup_nr_writeback(struct mem_cgroup *mem)
+{
+	s64 ret;
+
+	if (mem == NULL) {
+		mem = get_current_mem_cgroup();
+		if (unlikely(!mem))
+			return global_page_state(NR_WRITEBACK);
+	} else
+		css_get(&mem->css);
+	ret = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_WRITEBACK);
+	css_put(&mem->css);
+	return ret;
+}
+
+unsigned long mem_cgroup_get_free_pages(struct mem_cgroup *mem)
+{
+	long ret;
+
+	if (mem == NULL) {
+		mem = get_current_mem_cgroup();
+		if (unlikely(!mem))
+			return 0;
+	} else
+		css_get(&mem->css);
+	ret = ((res_counter_read_u64(&mem->res, RES_LIMIT)
+		- res_counter_read_u64(&mem->res, RES_USAGE))
+		>> PAGE_SHIFT) + 1; /* Ensure that we never return 0 */
+	css_put(&mem->css);
+	return ret;
+}
+
+unsigned long mem_cgroup_global_lru_pages(struct mem_cgroup *mem)
+{
+	long ret;
+
+	if (mem == NULL) {
+		mem = get_current_mem_cgroup();
+		if (unlikely(!mem))
+			return 0;
+	} else
+		css_get(&mem->css);
+	ret = mem_cgroup_get_all_zonestat(mem, LRU_ACTIVE_ANON)
+		+ mem_cgroup_get_all_zonestat(mem, LRU_ACTIVE_FILE)
+		+ mem_cgroup_get_all_zonestat(mem, LRU_INACTIVE_FILE)
+		+ mem_cgroup_get_all_zonestat(mem, LRU_INACTIVE_FILE);
+	css_put(&mem->css);
+	return ret;
+}
+
+long mem_cgroup_dirty_ratio(struct mem_cgroup *mem)
+{
+	long ret;
+
+	if (mem == NULL) {
+		mem = get_current_mem_cgroup();
+		if (unlikely(!mem))
+			return vm_dirty_ratio;
+	} else
+		css_get(&mem->css);
+	ret = mem->dirty_ratio;
+	css_put(&mem->css);
+	return ret;
+}
+
 /*
  * This routine assumes that the appropriate zone's lru lock is already held
  */
@@ -953,12 +1084,32 @@ static int mem_force_empty_write(struct cgroup *cont, unsigned int event)
 	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont));
 }
 
+static s64 mem_cgroup_dirty_ratio_read(struct cgroup *cont, struct cftype *cft)
+{
+	return mem_cgroup_from_cont(cont)->dirty_ratio;
+}
+
+static int mem_cgroup_dirty_ratio_write(struct cgroup *cont, struct cftype *cft,
+			const char *buffer)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	long val;
+	int ret;
+
+	ret = strict_strtol(buffer, 10, &val);
+	if (!ret)
+		mem->dirty_ratio = val;
+	return ret;
+}
+
 static const struct mem_cgroup_stat_desc {
 	const char *msg;
 	u64 unit;
 } mem_cgroup_stat_desc[] = {
 	[MEM_CGROUP_STAT_CACHE] = { "cache", PAGE_SIZE, },
 	[MEM_CGROUP_STAT_RSS] = { "rss", PAGE_SIZE, },
+	[MEM_CGROUP_STAT_FILE_DIRTY] = { "filedirty", 1, },
+	[MEM_CGROUP_STAT_WRITEBACK] = { "writeback", 1, },
 	[MEM_CGROUP_STAT_PGPGIN_COUNT] = {"pgpgin", 1, },
 	[MEM_CGROUP_STAT_PGPGOUT_COUNT] = {"pgpgout", 1, },
 };
@@ -1023,6 +1174,11 @@ static struct cftype mem_cgroup_files[] = {
 		.read_u64 = mem_cgroup_read,
 	},
 	{
+		.name = "dirty_ratio",
+		.write_string = mem_cgroup_dirty_ratio_write,
+		.read_s64 = mem_cgroup_dirty_ratio_read,
+	},
+	{
 		.name = "failcnt",
 		.private = RES_FAILCNT,
 		.trigger = mem_cgroup_reset,
@@ -1114,6 +1270,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	}
 
 	res_counter_init(&mem->res);
+	mem->dirty_ratio = vm_dirty_ratio;
 
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c6d6088..17c6141 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -25,6 +25,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/blkdev.h>
 #include <linux/mpage.h>
+#include <linux/memcontrol.h>
 #include <linux/rmap.h>
 #include <linux/percpu.h>
 #include <linux/notifier.h>
@@ -1090,6 +1091,7 @@ int __set_page_dirty_nobuffers(struct page *page)
 			BUG_ON(mapping2 != mapping);
 			WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
 			if (mapping_cap_account_dirty(mapping)) {
+				mem_cgroup_charge_file_dirty(page, 1);
 				__inc_zone_page_state(page, NR_FILE_DIRTY);
 				__inc_bdi_stat(mapping->backing_dev_info,
 						BDI_RECLAIMABLE);
@@ -1234,6 +1236,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 * for more comments.
 		 */
 		if (TestClearPageDirty(page)) {
+			mem_cgroup_charge_file_dirty(page, -1);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
@@ -1269,8 +1272,11 @@ int test_clear_page_writeback(struct page *page)
 	} else {
 		ret = TestClearPageWriteback(page);
 	}
-	if (ret)
+	if (ret) {
+		if (!PageAnon(page))
+			mem_cgroup_charge_writeback(page, -1);
 		dec_zone_page_state(page, NR_WRITEBACK);
+	}
 	return ret;
 }
 
@@ -1300,8 +1306,11 @@ int test_set_page_writeback(struct page *page)
 	} else {
 		ret = TestSetPageWriteback(page);
 	}
-	if (!ret)
+	if (!ret) {
+		if (!PageAnon(page))
+			mem_cgroup_charge_writeback(page, 1);
 		inc_zone_page_state(page, NR_WRITEBACK);
+	}
 	return ret;
 
 }
diff --git a/mm/truncate.c b/mm/truncate.c
index e2bdd70..f47bd19 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -10,6 +10,7 @@
 #include <linux/kernel.h>
 #include <linux/backing-dev.h>
 #include <linux/mm.h>
+#include <linux/memcontrol.h>
 #include <linux/swap.h>
 #include <linux/module.h>
 #include <linux/pagemap.h>
@@ -73,6 +74,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 	if (TestClearPageDirty(page)) {
 		struct address_space *mapping = page->mapping;
 		if (mapping && mapping_cap_account_dirty(mapping)) {
+			mem_cgroup_charge_file_dirty(page, -1);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
-- 
1.5.4.3
