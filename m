From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 3/9] blkio-cgroup-v9: The new page_cgroup framework
Date: Tue, 21 Jul 2009 23:12:11 +0900 (JST)
Message-ID: <20090721.231211.71098738.ryov__27324.3198440925$1248185609$gmane$org@valinux.co.jp>
References: <20090721.230911.193692312.ryov@valinux.co.jp>
	<20090721.231004.226793074.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090721.231004.226793074.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org
Cc: agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch makes the page_cgroup framework be able to be used even if
the compile option of the cgroup memory controller is off.
So blkio-cgroup can use this framework without the memory controller.

Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>

---
 include/linux/memcontrol.h  |    6 ++++++
 include/linux/mmzone.h      |    4 ++--
 include/linux/page_cgroup.h |    8 +++++---
 init/Kconfig                |    4 ++++
 mm/Makefile                 |    3 ++-
 mm/memcontrol.c             |    6 ++++++
 mm/page_cgroup.c            |    3 +--
 7 files changed, 26 insertions(+), 8 deletions(-)

Index: linux-2.6.31-rc3/include/linux/memcontrol.h
===================================================================
--- linux-2.6.31-rc3.orig/include/linux/memcontrol.h
+++ linux-2.6.31-rc3/include/linux/memcontrol.h
@@ -37,6 +37,8 @@ struct mm_struct;
  * (Of course, if memcg does memory allocation in future, GFP_KERNEL is sane.)
  */
 
+extern void __init_mem_page_cgroup(struct page_cgroup *pc);
+
 extern int mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
 /* for swap handling */
@@ -121,6 +123,10 @@ void mem_cgroup_update_mapped_file_stat(
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
+static inline void __init_mem_page_cgroup(struct page_cgroup *pc)
+{
+}
+
 static inline int mem_cgroup_newpage_charge(struct page *page,
 					struct mm_struct *mm, gfp_t gfp_mask)
 {
Index: linux-2.6.31-rc3/include/linux/mmzone.h
===================================================================
--- linux-2.6.31-rc3.orig/include/linux/mmzone.h
+++ linux-2.6.31-rc3/include/linux/mmzone.h
@@ -605,7 +605,7 @@ typedef struct pglist_data {
 	int nr_zones;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP	/* means !SPARSEMEM */
 	struct page *node_mem_map;
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+#ifdef CONFIG_CGROUP_PAGE
 	struct page_cgroup *node_page_cgroup;
 #endif
 #endif
@@ -956,7 +956,7 @@ struct mem_section {
 
 	/* See declaration of similar field in struct zone */
 	unsigned long *pageblock_flags;
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+#ifdef CONFIG_CGROUP_PAGE
 	/*
 	 * If !SPARSEMEM, pgdat doesn't have page_cgroup pointer. We use
 	 * section. (see memcontrol.h/page_cgroup.h about this.)
Index: linux-2.6.31-rc3/include/linux/page_cgroup.h
===================================================================
--- linux-2.6.31-rc3.orig/include/linux/page_cgroup.h
+++ linux-2.6.31-rc3/include/linux/page_cgroup.h
@@ -1,7 +1,7 @@
 #ifndef __LINUX_PAGE_CGROUP_H
 #define __LINUX_PAGE_CGROUP_H
 
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+#ifdef CONFIG_CGROUP_PAGE
 #include <linux/bit_spinlock.h>
 /*
  * Page Cgroup can be considered as an extended mem_map.
@@ -12,9 +12,11 @@
  */
 struct page_cgroup {
 	unsigned long flags;
-	struct mem_cgroup *mem_cgroup;
 	struct page *page;
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+	struct mem_cgroup *mem_cgroup;
 	struct list_head lru;		/* per cgroup LRU list */
+#endif
 };
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
@@ -83,7 +85,7 @@ static inline void unlock_page_cgroup(st
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
-#else /* CONFIG_CGROUP_MEM_RES_CTLR */
+#else /* CONFIG_CGROUP_PAGE */
 struct page_cgroup;
 
 static inline void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
Index: linux-2.6.31-rc3/init/Kconfig
===================================================================
--- linux-2.6.31-rc3.orig/init/Kconfig
+++ linux-2.6.31-rc3/init/Kconfig
@@ -614,6 +614,10 @@ config CGROUP_MEM_RES_CTLR_SWAP
 
 endif # CGROUPS
 
+config CGROUP_PAGE
+	def_bool y
+	depends on CGROUP_MEM_RES_CTLR
+
 config MM_OWNER
 	bool
 
Index: linux-2.6.31-rc3/mm/Makefile
===================================================================
--- linux-2.6.31-rc3.orig/mm/Makefile
+++ linux-2.6.31-rc3/mm/Makefile
@@ -39,6 +39,7 @@ else
 obj-$(CONFIG_SMP) += allocpercpu.o
 endif
 obj-$(CONFIG_QUICKLIST) += quicklist.o
-obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_CGROUP_PAGE) += page_cgroup.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
Index: linux-2.6.31-rc3/mm/memcontrol.c
===================================================================
--- linux-2.6.31-rc3.orig/mm/memcontrol.c
+++ linux-2.6.31-rc3/mm/memcontrol.c
@@ -129,6 +129,12 @@ struct mem_cgroup_lru_info {
 	struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
 };
 
+void __meminit __init_mem_page_cgroup(struct page_cgroup *pc)
+{
+	pc->mem_cgroup = NULL;
+	INIT_LIST_HEAD(&pc->lru);
+}
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
Index: linux-2.6.31-rc3/mm/page_cgroup.c
===================================================================
--- linux-2.6.31-rc3.orig/mm/page_cgroup.c
+++ linux-2.6.31-rc3/mm/page_cgroup.c
@@ -14,9 +14,8 @@ static void __meminit
 __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
 {
 	pc->flags = 0;
-	pc->mem_cgroup = NULL;
 	pc->page = pfn_to_page(pfn);
-	INIT_LIST_HEAD(&pc->lru);
+	__init_mem_page_cgroup(pc);
 }
 static unsigned long total_usage;
