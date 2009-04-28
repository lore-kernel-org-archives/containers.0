From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v15 3/7] page_cgroup: provide a generic page tracking
	infrastructure
Date: Tue, 28 Apr 2009 10:43:50 +0200
Message-ID: <1240908234-15434-4-git-send-email-righi.andrea__34357.0698671558$1240908929$gmane$org@gmail.com>
References: <1240908234-15434-1-git-send-email-righi.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240908234-15434-1-git-send-email-righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, tytso-3s7WtUTddSA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Dirty pages in the page cache can be processed asynchronously by kernel
threads (pdflush) using a writeback policy. For this reason the real
writes to the underlying block devices occur in a different IO context
respect to the task that originally generated the dirty pages involved
in the IO operation. This makes the tracking and throttling of writeback
IO more complicate respect to the synchronous IO.

The page_cgroup infrastructure, currently available only for the memory
cgroup controller, can be used to store the owner of each page and
opportunely track the writeback IO. This information is encoded in
page_cgroup->flags.

A owner can be identified using a generic ID number and the following
interfaces are provided to store a retrieve this information:

  unsigned long page_cgroup_get_owner(struct page *page);
  int page_cgroup_set_owner(struct page *page, unsigned long id);
  int page_cgroup_copy_owner(struct page *npage, struct page *opage);

The io-throttle controller uses the cgroup css_id() as the owner's ID
number.

A big part of this code is taken from the Ryo and Hirokazu's
bio-cgroup controller (http://people.valinux.co.jp/~ryov/bio-cgroup/).

TODO: try to remove the lock/unlock_page_cgroup() in
page_cgroup_*_owner().

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
---
 include/linux/memcontrol.h  |    6 +++
 include/linux/mmzone.h      |    4 +-
 include/linux/page_cgroup.h |   33 +++++++++++++-
 init/Kconfig                |    4 ++
 mm/Makefile                 |    3 +-
 mm/memcontrol.c             |    6 +++
 mm/page_cgroup.c            |   96 ++++++++++++++++++++++++++++++++++++++-----
 7 files changed, 135 insertions(+), 17 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index a9e3b76..e80e335 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -37,6 +37,8 @@ struct mm_struct;
  * (Of course, if memcg does memory allocation in future, GFP_KERNEL is sane.)
  */
 
+extern void __init_mem_page_cgroup(struct page_cgroup *pc);
+
 extern int mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
 /* for swap handling */
@@ -120,6 +122,10 @@ extern bool mem_cgroup_oom_called(struct task_struct *task);
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
+static inline void __init_mem_page_cgroup(struct page_cgroup *pc)
+{
+}
+
 static inline int mem_cgroup_newpage_charge(struct page *page,
 					struct mm_struct *mm, gfp_t gfp_mask)
 {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 186ec6a..b178eb9 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -607,7 +607,7 @@ typedef struct pglist_data {
 	int nr_zones;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP	/* means !SPARSEMEM */
 	struct page *node_mem_map;
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+#ifdef CONFIG_PAGE_TRACKING
 	struct page_cgroup *node_page_cgroup;
 #endif
 #endif
@@ -958,7 +958,7 @@ struct mem_section {
 
 	/* See declaration of similar field in struct zone */
 	unsigned long *pageblock_flags;
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+#ifdef CONFIG_PAGE_TRACKING
 	/*
 	 * If !SPARSEMEM, pgdat doesn't have page_cgroup pointer. We use
 	 * section. (see memcontrol.h/page_cgroup.h about this.)
diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 7339c7b..f24d081 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -1,7 +1,7 @@
 #ifndef __LINUX_PAGE_CGROUP_H
 #define __LINUX_PAGE_CGROUP_H
 
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+#ifdef CONFIG_PAGE_TRACKING
 #include <linux/bit_spinlock.h>
 /*
  * Page Cgroup can be considered as an extended mem_map.
@@ -12,11 +12,38 @@
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
 
+/*
+ * use lower 16 bits for flags and reserve the rest for the page tracking id
+ */
+#define PAGE_TRACKING_ID_SHIFT	(16)
+#define PAGE_TRACKING_ID_BITS \
+		(8 * sizeof(unsigned long) - PAGE_TRACKING_ID_SHIFT)
+
+/* NOTE: must be called with page_cgroup() held */
+static inline unsigned long page_cgroup_get_id(struct page_cgroup *pc)
+{
+	return pc->flags >> PAGE_TRACKING_ID_SHIFT;
+}
+
+/* NOTE: must be called with page_cgroup() held */
+static inline void page_cgroup_set_id(struct page_cgroup *pc, unsigned long id)
+{
+	WARN_ON(id >= (1UL << PAGE_TRACKING_ID_BITS));
+	pc->flags &= (1UL << PAGE_TRACKING_ID_SHIFT) - 1;
+	pc->flags |= (unsigned long)(id << PAGE_TRACKING_ID_SHIFT);
+}
+
+unsigned long page_cgroup_get_owner(struct page *page);
+int page_cgroup_set_owner(struct page *page, unsigned long id);
+int page_cgroup_copy_owner(struct page *npage, struct page *opage);
+
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
 void __init page_cgroup_init(void);
 struct page_cgroup *lookup_page_cgroup(struct page *page);
@@ -71,7 +98,7 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
-#else /* CONFIG_CGROUP_MEM_RES_CTLR */
+#else /* CONFIG_PAGE_TRACKING */
 struct page_cgroup;
 
 static inline void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
diff --git a/init/Kconfig b/init/Kconfig
index 7be4d38..5428ac7 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -569,6 +569,7 @@ config CGROUP_MEM_RES_CTLR
 	bool "Memory Resource Controller for Control Groups"
 	depends on CGROUPS && RESOURCE_COUNTERS
 	select MM_OWNER
+	select PAGE_TRACKING
 	help
 	  Provides a memory resource controller that manages both anonymous
 	  memory and page cache. (See Documentation/cgroups/memory.txt)
@@ -611,6 +612,9 @@ endif # CGROUPS
 config MM_OWNER
 	bool
 
+config PAGE_TRACKING
+	bool
+
 config SYSFS_DEPRECATED
 	bool
 
diff --git a/mm/Makefile b/mm/Makefile
index ec73c68..b94e074 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -37,4 +37,5 @@ else
 obj-$(CONFIG_SMP) += allocpercpu.o
 endif
 obj-$(CONFIG_QUICKLIST) += quicklist.o
-obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_PAGE_TRACKING) += page_cgroup.o
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e44fb0f..69d1c31 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2524,6 +2524,12 @@ struct cgroup_subsys mem_cgroup_subsys = {
 	.use_id = 1,
 };
 
+void __meminit __init_mem_page_cgroup(struct page_cgroup *pc)
+{
+	pc->mem_cgroup = NULL;
+	INIT_LIST_HEAD(&pc->lru);
+}
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 
 static int __init disable_swap_account(char *s)
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 791905c..ec9ed05 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -3,6 +3,7 @@
 #include <linux/bootmem.h>
 #include <linux/bit_spinlock.h>
 #include <linux/page_cgroup.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/hash.h>
 #include <linux/slab.h>
 #include <linux/memory.h>
@@ -14,9 +15,8 @@ static void __meminit
 __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
 {
 	pc->flags = 0;
-	pc->mem_cgroup = NULL;
 	pc->page = pfn_to_page(pfn);
-	INIT_LIST_HEAD(&pc->lru);
+	__init_mem_page_cgroup(pc);
 }
 static unsigned long total_usage;
 
@@ -74,7 +74,7 @@ void __init page_cgroup_init(void)
 
 	int nid, fail;
 
-	if (mem_cgroup_disabled())
+	if (mem_cgroup_disabled() && iothrottle_disabled())
 		return;
 
 	for_each_online_node(nid)  {
@@ -83,12 +83,13 @@ void __init page_cgroup_init(void)
 			goto fail;
 	}
 	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try cgroup_disable=memory option if you"
-	" don't want\n");
+	printk(KERN_INFO
+		"try cgroup_disable=memory,blockio option if you don't want\n");
 	return;
 fail:
 	printk(KERN_CRIT "allocation of page_cgroup was failed.\n");
-	printk(KERN_CRIT "please try cgroup_disable=memory boot option\n");
+	printk(KERN_CRIT
+		"try cgroup_disable=memory,blockio boot option\n");
 	panic("Out of memory");
 }
 
@@ -248,7 +249,7 @@ void __init page_cgroup_init(void)
 	unsigned long pfn;
 	int fail = 0;
 
-	if (mem_cgroup_disabled())
+	if (mem_cgroup_disabled() && iothrottle_disabled())
 		return;
 
 	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
@@ -257,14 +258,15 @@ void __init page_cgroup_init(void)
 		fail = init_section_page_cgroup(pfn);
 	}
 	if (fail) {
-		printk(KERN_CRIT "try cgroup_disable=memory boot option\n");
+		printk(KERN_CRIT
+			"try cgroup_disable=memory,blockio boot option\n");
 		panic("Out of memory");
 	} else {
 		hotplug_memory_notifier(page_cgroup_callback, 0);
 	}
 	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try cgroup_disable=memory option if you don't"
-	" want\n");
+	printk(KERN_INFO
+		"try cgroup_disable=memory,blockio option if you don't want\n");
 }
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
@@ -272,8 +274,80 @@ void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
 	return;
 }
 
-#endif
+#endif /* !defined(CONFIG_SPARSEMEM) */
+
+/**
+ * page_cgroup_get_owner() - get the owner ID of a page
+ * @page:	the page we want to find the owner
+ *
+ * Returns the owner ID of the page, 0 means that the owner cannot be
+ * retrieved.
+ **/
+unsigned long page_cgroup_get_owner(struct page *page)
+{
+	struct page_cgroup *pc;
+	unsigned long ret;
+
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!pc))
+		return 0;
+
+	lock_page_cgroup(pc);
+	ret = page_cgroup_get_id(pc);
+	unlock_page_cgroup(pc);
+	return ret;
+}
+
+/**
+ * page_cgroup_set_owner() - set the owner ID of a page
+ * @page:	the page we want to tag
+ * @id:		the ID number that will be associated to page
+ *
+ * Returns 0 if the owner is correctly associated to the page. Returns a
+ * negative value in case of failure.
+ **/
+int page_cgroup_set_owner(struct page *page, unsigned long id)
+{
+	struct page_cgroup *pc;
+
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!pc))
+		return -ENOENT;
+
+	lock_page_cgroup(pc);
+	page_cgroup_set_id(pc, id);
+	unlock_page_cgroup(pc);
+	return 0;
+}
 
+/**
+ * page_cgroup_copy_owner() - copy the owner ID of a page into another page
+ * @npage:	the page where we want to copy the owner
+ * @opage:	the page from which we want to copy the ID
+ *
+ * Returns 0 if the owner is correctly associated to npage. Returns a negative
+ * value in case of failure.
+ **/
+int page_cgroup_copy_owner(struct page *npage, struct page *opage)
+{
+	struct page_cgroup *npc, *opc;
+	unsigned long id;
+
+	npc = lookup_page_cgroup(npage);
+	if (unlikely(!npc))
+		return -ENOENT;
+	opc = lookup_page_cgroup(opage);
+	if (unlikely(!opc))
+		return -ENOENT;
+	lock_page_cgroup(opc);
+	lock_page_cgroup(npc);
+	id = page_cgroup_get_id(opc);
+	page_cgroup_set_id(npc, id);
+	unlock_page_cgroup(npc);
+	unlock_page_cgroup(opc);
+
+	return 0;
+}
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 
-- 
1.6.0.4
