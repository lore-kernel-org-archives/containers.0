From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 19/25] blkio_cgroup patches from Ryo to track async bios.
Date: Thu,  2 Jul 2009 16:01:51 -0400
Message-ID: <1246564917-19603-20-git-send-email-vgoyal__66.2234532230244$1246568226$gmane$org@redhat.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246564917-19603-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

o blkio_cgroup patches from Ryo to track async bios.

o Fernando is also working on another IO tracking mechanism. We are not
  particular about any IO tracking mechanism. This patchset can make use
  of any mechanism which makes it to upstream. For the time being making
  use of Ryo's posting.

Based on 2.6.30-rc3-git3
Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
---
 block/blk-ioc.c               |   36 +++--
 fs/buffer.c                   |    2 +
 fs/direct-io.c                |    2 +
 include/linux/biotrack.h      |  103 +++++++++++++
 include/linux/cgroup_subsys.h |    6 +
 include/linux/iocontext.h     |    1 +
 include/linux/memcontrol.h    |    6 +
 include/linux/mmzone.h        |    4 +-
 include/linux/page_cgroup.h   |   31 ++++-
 init/Kconfig                  |   15 ++
 mm/Makefile                   |    4 +-
 mm/biotrack.c                 |  321 +++++++++++++++++++++++++++++++++++++++++
 mm/bounce.c                   |    2 +
 mm/filemap.c                  |    2 +
 mm/memcontrol.c               |    6 +
 mm/memory.c                   |    5 +
 mm/page-writeback.c           |    2 +
 mm/page_cgroup.c              |   17 ++-
 mm/swap_state.c               |    2 +
 19 files changed, 537 insertions(+), 30 deletions(-)
 create mode 100644 include/linux/biotrack.h
 create mode 100644 mm/biotrack.c

diff --git a/block/blk-ioc.c b/block/blk-ioc.c
index 0d56336..890d475 100644
--- a/block/blk-ioc.c
+++ b/block/blk-ioc.c
@@ -84,27 +84,31 @@ void exit_io_context(void)
 	}
 }
 
+void init_io_context(struct io_context *ioc)
+{
+	atomic_long_set(&ioc->refcount, 1);
+	atomic_set(&ioc->nr_tasks, 1);
+	spin_lock_init(&ioc->lock);
+	ioc->ioprio_changed = 0;
+	ioc->ioprio = 0;
+#ifdef CONFIG_GROUP_IOSCHED
+	ioc->cgroup_changed = 0;
+#endif
+	ioc->last_waited = jiffies; /* doesn't matter... */
+	ioc->nr_batch_requests = 0; /* because this is 0 */
+	ioc->aic = NULL;
+	INIT_RADIX_TREE(&ioc->radix_root, GFP_ATOMIC | __GFP_HIGH);
+	INIT_HLIST_HEAD(&ioc->cic_list);
+	ioc->ioc_data = NULL;
+}
+
 struct io_context *alloc_io_context(gfp_t gfp_flags, int node)
 {
 	struct io_context *ret;
 
 	ret = kmem_cache_alloc_node(iocontext_cachep, gfp_flags, node);
-	if (ret) {
-		atomic_long_set(&ret->refcount, 1);
-		atomic_set(&ret->nr_tasks, 1);
-		spin_lock_init(&ret->lock);
-		ret->ioprio_changed = 0;
-		ret->ioprio = 0;
-#ifdef CONFIG_GROUP_IOSCHED
-		ret->cgroup_changed = 0;
-#endif
-		ret->last_waited = jiffies; /* doesn't matter... */
-		ret->nr_batch_requests = 0; /* because this is 0 */
-		ret->aic = NULL;
-		INIT_RADIX_TREE(&ret->radix_root, GFP_ATOMIC | __GFP_HIGH);
-		INIT_HLIST_HEAD(&ret->cic_list);
-		ret->ioc_data = NULL;
-	}
+	if (ret)
+		init_io_context(ret);
 
 	return ret;
 }
diff --git a/fs/buffer.c b/fs/buffer.c
index a3ef091..cb68608 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -36,6 +36,7 @@
 #include <linux/buffer_head.h>
 #include <linux/task_io_accounting_ops.h>
 #include <linux/bio.h>
+#include <linux/biotrack.h>
 #include <linux/notifier.h>
 #include <linux/cpu.h>
 #include <linux/bitops.h>
@@ -668,6 +669,7 @@ static void __set_page_dirty(struct page *page,
 	if (page->mapping) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
 		account_page_dirtied(page, mapping);
+		blkio_cgroup_reset_owner_pagedirty(page, current->mm);
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 	}
diff --git a/fs/direct-io.c b/fs/direct-io.c
index 8b10b87..185ba0a 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -33,6 +33,7 @@
 #include <linux/err.h>
 #include <linux/blkdev.h>
 #include <linux/buffer_head.h>
+#include <linux/biotrack.h>
 #include <linux/rwsem.h>
 #include <linux/uio.h>
 #include <asm/atomic.h>
@@ -797,6 +798,7 @@ static int do_direct_IO(struct dio *dio)
 			ret = PTR_ERR(page);
 			goto out;
 		}
+		blkio_cgroup_reset_owner(page, current->mm);
 
 		while (block_in_page < blocks_per_page) {
 			unsigned offset_in_page = block_in_page << blkbits;
diff --git a/include/linux/biotrack.h b/include/linux/biotrack.h
new file mode 100644
index 0000000..0b4491a
--- /dev/null
+++ b/include/linux/biotrack.h
@@ -0,0 +1,103 @@
+#include <linux/cgroup.h>
+#include <linux/mm.h>
+#include <linux/page_cgroup.h>
+
+#ifndef _LINUX_BIOTRACK_H
+#define _LINUX_BIOTRACK_H
+
+#ifdef	CONFIG_CGROUP_BLKIO
+
+struct io_context;
+struct block_device;
+
+struct blkio_cgroup {
+	struct cgroup_subsys_state css;
+	struct io_context *io_context;	/* default io_context */
+/*	struct radix_tree_root io_context_root; per device io_context */
+};
+
+/**
+ * __init_blkio_page_cgroup() - initialize a blkio_page_cgroup
+ * @pc:		page_cgroup of the page
+ *
+ * Reset the owner ID of a page.
+ */
+static inline void __init_blkio_page_cgroup(struct page_cgroup *pc)
+{
+	lock_page_cgroup(pc);
+	page_cgroup_set_id(pc, 0);
+	unlock_page_cgroup(pc);
+}
+
+/**
+ * blkio_cgroup_disabled - check whether blkio_cgroup is disabled
+ *
+ * Returns true if disabled, false if not.
+ */
+static inline bool blkio_cgroup_disabled(void)
+{
+	if (blkio_cgroup_subsys.disabled)
+		return true;
+	return false;
+}
+
+extern void blkio_cgroup_set_owner(struct page *page, struct mm_struct *mm);
+extern void blkio_cgroup_reset_owner(struct page *page, struct mm_struct *mm);
+extern void blkio_cgroup_reset_owner_pagedirty(struct page *page,
+						 struct mm_struct *mm);
+extern void blkio_cgroup_copy_owner(struct page *page, struct page *opage);
+
+extern struct io_context *get_blkio_cgroup_iocontext(struct bio *bio);
+extern unsigned long get_blkio_cgroup_id(struct bio *bio);
+extern unsigned long get_blkio_cgroup_id_page(struct page *page);
+extern struct cgroup *blkio_cgroup_lookup(int id);
+
+#else	/* CONFIG_CGROUP_BIO */
+
+struct blkio_cgroup;
+
+static inline void __init_blkio_page_cgroup(struct page_cgroup *pc)
+{
+}
+
+static inline bool blkio_cgroup_disabled(void)
+{
+	return true;
+}
+
+static inline void blkio_cgroup_set_owner(struct page *page, struct mm_struct *mm)
+{
+}
+
+static inline void blkio_cgroup_reset_owner(struct page *page,
+						struct mm_struct *mm)
+{
+}
+
+static inline void blkio_cgroup_reset_owner_pagedirty(struct page *page,
+						struct mm_struct *mm)
+{
+}
+
+static inline void blkio_cgroup_copy_owner(struct page *page, struct page *opage)
+{
+}
+
+static inline struct io_context *get_blkio_cgroup_iocontext(struct bio *bio)
+{
+	return NULL;
+}
+
+static inline unsigned long get_blkio_cgroup_id(struct bio *bio)
+{
+	return 0;
+}
+
+static inline unsigned long get_blkio_cgroup_id_page(struct page *page)
+{
+	return 0;
+}
+
+#endif	/* CONFIG_CGROUP_BLKIO */
+
+#endif /* _LINUX_BIOTRACK_H */
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index baf544f..78504f3 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -43,6 +43,12 @@ SUBSYS(mem_cgroup)
 
 /* */
 
+#ifdef CONFIG_CGROUP_BLKIO
+SUBSYS(blkio_cgroup)
+#endif
+
+/* */
+
 #ifdef CONFIG_CGROUP_DEVICE
 SUBSYS(devices)
 #endif
diff --git a/include/linux/iocontext.h b/include/linux/iocontext.h
index ccecf53..c595842 100644
--- a/include/linux/iocontext.h
+++ b/include/linux/iocontext.h
@@ -104,6 +104,7 @@ int put_io_context(struct io_context *ioc);
 void exit_io_context(void);
 struct io_context *get_io_context(gfp_t gfp_flags, int node);
 struct io_context *alloc_io_context(gfp_t gfp_flags, int node);
+void init_io_context(struct io_context *ioc);
 void copy_io_context(struct io_context **pdst, struct io_context **psrc);
 #else
 static inline void exit_io_context(void)
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e46a073..eb45fe9 100644
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
@@ -121,6 +123,10 @@ void mem_cgroup_update_mapped_file_stat(struct page *page, int val);
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
index 8895985..c9d1ed4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
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
diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 13f126c..f470fd2 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
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
@@ -83,7 +85,7 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
-#else /* CONFIG_CGROUP_MEM_RES_CTLR */
+#else /* CONFIG_CGROUP_PAGE */
 struct page_cgroup;
 
 static inline void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
@@ -138,4 +140,27 @@ static inline void swap_cgroup_swapoff(int type)
 }
 
 #endif
+
+#ifdef CONFIG_CGROUP_BLKIO
+/*
+ * use lower 16 bits for flags and reserve the rest for the page tracking id
+ */
+#define PCG_TRACKING_ID_SHIFT	(16)
+#define PCG_TRACKING_ID_BITS \
+	(8 * sizeof(unsigned long) - PCG_TRACKING_ID_SHIFT)
+
+/* NOTE: must be called with page_cgroup() held */
+static inline unsigned long page_cgroup_get_id(struct page_cgroup *pc)
+{
+	return pc->flags >> PCG_TRACKING_ID_SHIFT;
+}
+
+/* NOTE: must be called with page_cgroup() held */
+static inline void page_cgroup_set_id(struct page_cgroup *pc, unsigned long id)
+{
+	WARN_ON(id >= (1UL << PCG_TRACKING_ID_BITS));
+	pc->flags &= (1UL << PCG_TRACKING_ID_SHIFT) - 1;
+	pc->flags |= (unsigned long)(id << PCG_TRACKING_ID_SHIFT);
+}
+#endif
 #endif
diff --git a/init/Kconfig b/init/Kconfig
index eaa44db..1241018 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -622,6 +622,21 @@ config GROUP_IOSCHED
 
 endif # CGROUPS
 
+config CGROUP_BLKIO
+	bool "Block I/O cgroup subsystem"
+	depends on CGROUPS && BLOCK
+	select MM_OWNER
+	help
+	  Provides a Resource Controller which enables to track the onwner
+	  of every Block I/O requests.
+	  The information this subsystem provides can be used from any
+	  kind of module such as dm-ioband device mapper modules or
+	  the cfq-scheduler.
+
+config CGROUP_PAGE
+	def_bool y
+	depends on CGROUP_MEM_RES_CTLR || CGROUP_BLKIO
+
 config MM_OWNER
 	bool
 
diff --git a/mm/Makefile b/mm/Makefile
index 5e0bd64..6208744 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -39,6 +39,8 @@ else
 obj-$(CONFIG_SMP) += allocpercpu.o
 endif
 obj-$(CONFIG_QUICKLIST) += quicklist.o
-obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_CGROUP_PAGE) += page_cgroup.o
+obj-$(CONFIG_CGROUP_BLKIO) += biotrack.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
diff --git a/mm/biotrack.c b/mm/biotrack.c
new file mode 100644
index 0000000..320f511
--- /dev/null
+++ b/mm/biotrack.c
@@ -0,0 +1,321 @@
+/* biotrack.c - Block I/O Tracking
+ *
+ * Copyright (C) VA Linux Systems Japan, 2008-2009
+ * Developed by Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
+ *
+ * Copyright (C) 2008 Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ * Use part of page_cgroup->flags to store blkio-cgroup ID.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/module.h>
+#include <linux/smp.h>
+#include <linux/bit_spinlock.h>
+#include <linux/blkdev.h>
+#include <linux/biotrack.h>
+#include <linux/mm_inline.h>
+
+/*
+ * The block I/O tracking mechanism is implemented on the cgroup memory
+ * controller framework. It helps to find the the owner of an I/O request
+ * because every I/O request has a target page and the owner of the page
+ * can be easily determined on the framework.
+ */
+
+/* Return the blkio_cgroup that associates with a cgroup. */
+static inline struct blkio_cgroup *cgroup_blkio(struct cgroup *cgrp)
+{
+	return container_of(cgroup_subsys_state(cgrp, blkio_cgroup_subsys_id),
+					struct blkio_cgroup, css);
+}
+
+/* Return the blkio_cgroup that associates with a process. */
+static inline struct blkio_cgroup *blkio_cgroup_from_task(struct task_struct *p)
+{
+	return container_of(task_subsys_state(p, blkio_cgroup_subsys_id),
+					struct blkio_cgroup, css);
+}
+
+static struct io_context default_blkio_io_context;
+static struct blkio_cgroup default_blkio_cgroup = {
+	.io_context	= &default_blkio_io_context,
+};
+
+/**
+ * blkio_cgroup_set_owner() - set the owner ID of a page.
+ * @page:	the page we want to tag
+ * @mm:		the mm_struct of a page owner
+ *
+ * Make a given page have the blkio-cgroup ID of the owner of this page.
+ */
+void blkio_cgroup_set_owner(struct page *page, struct mm_struct *mm)
+{
+	struct blkio_cgroup *biog;
+	struct page_cgroup *pc;
+	unsigned long id;
+
+	if (blkio_cgroup_disabled())
+		return;
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!pc))
+		return;
+
+	lock_page_cgroup(pc);
+	page_cgroup_set_id(pc, 0);	/* 0: default blkio_cgroup id */
+	unlock_page_cgroup(pc);
+	if (!mm)
+		return;
+
+	rcu_read_lock();
+	biog = blkio_cgroup_from_task(rcu_dereference(mm->owner));
+	if (unlikely(!biog)) {
+		rcu_read_unlock();
+		return;
+	}
+	/*
+	 * css_get(&bio->css) isn't called to increment the reference
+	 * count of this blkio_cgroup "biog" so the css_id might turn
+	 * invalid even if this page is still active.
+	 * This approach is chosen to minimize the overhead.
+	 */
+	id = css_id(&biog->css);
+	rcu_read_unlock();
+	lock_page_cgroup(pc);
+	page_cgroup_set_id(pc, id);
+	unlock_page_cgroup(pc);
+}
+
+/**
+ * blkio_cgroup_reset_owner() - reset the owner ID of a page
+ * @page:	the page we want to tag
+ * @mm:		the mm_struct of a page owner
+ *
+ * Change the owner of a given page if necessary.
+ */
+void blkio_cgroup_reset_owner(struct page *page, struct mm_struct *mm)
+{
+	blkio_cgroup_set_owner(page, mm);
+}
+
+/**
+ * blkio_cgroup_reset_owner_pagedirty() - reset the owner ID of a pagecache page
+ * @page:	the page we want to tag
+ * @mm:		the mm_struct of a page owner
+ *
+ * Change the owner of a given page if the page is in the pagecache.
+ */
+void blkio_cgroup_reset_owner_pagedirty(struct page *page, struct mm_struct *mm)
+{
+	if (!page_is_file_cache(page))
+		return;
+	if (current->flags & PF_MEMALLOC)
+		return;
+
+	blkio_cgroup_reset_owner(page, mm);
+}
+
+/**
+ * blkio_cgroup_copy_owner() - copy the owner ID of a page into another page
+ * @npage:	the page where we want to copy the owner
+ * @opage:	the page from which we want to copy the ID
+ *
+ * Copy the owner ID of @opage into @npage.
+ */
+void blkio_cgroup_copy_owner(struct page *npage, struct page *opage)
+{
+	struct page_cgroup *npc, *opc;
+	unsigned long id;
+
+	if (blkio_cgroup_disabled())
+		return;
+	npc = lookup_page_cgroup(npage);
+	if (unlikely(!npc))
+		return;
+	opc = lookup_page_cgroup(opage);
+	if (unlikely(!opc))
+		return;
+
+	lock_page_cgroup(opc);
+	lock_page_cgroup(npc);
+	id = page_cgroup_get_id(opc);
+	page_cgroup_set_id(npc, id);
+	unlock_page_cgroup(npc);
+	unlock_page_cgroup(opc);
+}
+
+/* Create a new blkio-cgroup. */
+static struct cgroup_subsys_state *
+blkio_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct blkio_cgroup *biog;
+	struct io_context *ioc;
+
+	if (!cgrp->parent) {
+		biog = &default_blkio_cgroup;
+		init_io_context(biog->io_context);
+		/* Increment the referrence count not to be released ever. */
+		atomic_long_inc(&biog->io_context->refcount);
+		return &biog->css;
+	}
+
+	biog = kzalloc(sizeof(*biog), GFP_KERNEL);
+	if (!biog)
+		return ERR_PTR(-ENOMEM);
+	ioc = alloc_io_context(GFP_KERNEL, -1);
+	if (!ioc) {
+		kfree(biog);
+		return ERR_PTR(-ENOMEM);
+	}
+	biog->io_context = ioc;
+	return &biog->css;
+}
+
+/* Delete the blkio-cgroup. */
+static void blkio_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct blkio_cgroup *biog = cgroup_blkio(cgrp);
+
+	put_io_context(biog->io_context);
+	free_css_id(&blkio_cgroup_subsys, &biog->css);
+	kfree(biog);
+}
+
+/**
+ * get_blkio_cgroup_id() - determine the blkio-cgroup ID
+ * @bio:	the &struct bio which describes the I/O
+ *
+ * Returns the blkio-cgroup ID of a given bio. A return value zero
+ * means that the page associated with the bio belongs to default_blkio_cgroup.
+ */
+unsigned long get_blkio_cgroup_id(struct bio *bio)
+{
+	struct page_cgroup *pc;
+	struct page *page = bio_iovec_idx(bio, 0)->bv_page;
+	unsigned long id = 0;
+
+	pc = lookup_page_cgroup(page);
+	if (pc) {
+		lock_page_cgroup(pc);
+		id = page_cgroup_get_id(pc);
+		unlock_page_cgroup(pc);
+	}
+	return id;
+}
+
+/**
+ * get_blkio_cgroup_id_page() - determine the blkio-cgroup ID
+ * @page:	the &struct page which describes the I/O
+ *
+ * Returns the blkio-cgroup ID of a given page. A return value zero
+ * means that the page associated with the IO belongs to default_blkio_cgroup.
+ */
+unsigned long get_blkio_cgroup_id_page(struct page *page)
+{
+	struct page_cgroup *pc;
+	unsigned long id = 0;
+
+	pc = lookup_page_cgroup(page);
+	if (pc) {
+		lock_page_cgroup(pc);
+		id = page_cgroup_get_id(pc);
+		unlock_page_cgroup(pc);
+	}
+	return id;
+}
+
+/**
+ * get_blkio_cgroup_iocontext() - determine the blkio-cgroup iocontext
+ * @bio:	the &struct bio which describe the I/O
+ *
+ * Returns the iocontext of blkio-cgroup that issued a given bio.
+ */
+struct io_context *get_blkio_cgroup_iocontext(struct bio *bio)
+{
+	struct cgroup_subsys_state *css;
+	struct blkio_cgroup *biog;
+	struct io_context *ioc;
+	unsigned long id;
+
+	id = get_blkio_cgroup_id(bio);
+	rcu_read_lock();
+	css = css_lookup(&blkio_cgroup_subsys, id);
+	if (css)
+		biog = container_of(css, struct blkio_cgroup, css);
+	else
+		biog = &default_blkio_cgroup;
+	ioc = biog->io_context;	/* default io_context for this cgroup */
+	atomic_long_inc(&ioc->refcount);
+	rcu_read_unlock();
+	return ioc;
+}
+
+/**
+ * blkio_cgroup_lookup() - lookup a cgroup by blkio-cgroup ID
+ * @id:		blkio-cgroup ID
+ *
+ * Returns the cgroup associated with the specified ID, or NULL if lookup
+ * fails.
+ *
+ * Note:
+ * This function should be called under rcu_read_lock().
+ */
+struct cgroup *blkio_cgroup_lookup(int id)
+{
+	struct cgroup *cgrp;
+	struct cgroup_subsys_state *css;
+
+	if (blkio_cgroup_disabled())
+		return NULL;
+
+	css = css_lookup(&blkio_cgroup_subsys, id);
+	if (!css)
+		return NULL;
+	cgrp = css->cgroup;
+	return cgrp;
+}
+EXPORT_SYMBOL(get_blkio_cgroup_iocontext);
+EXPORT_SYMBOL(get_blkio_cgroup_id);
+EXPORT_SYMBOL(blkio_cgroup_lookup);
+
+static u64 blkio_id_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct blkio_cgroup *biog = cgroup_blkio(cgrp);
+	unsigned long id;
+
+	rcu_read_lock();
+	id = css_id(&biog->css);
+	rcu_read_unlock();
+	return (u64)id;
+}
+
+
+static struct cftype blkio_files[] = {
+	{
+		.name = "id",
+		.read_u64 = blkio_id_read,
+	},
+};
+
+static int blkio_cgroup_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	return cgroup_add_files(cgrp, ss, blkio_files,
+					ARRAY_SIZE(blkio_files));
+}
+
+struct cgroup_subsys blkio_cgroup_subsys = {
+	.name		= "blkio",
+	.create		= blkio_cgroup_create,
+	.destroy	= blkio_cgroup_destroy,
+	.populate	= blkio_cgroup_populate,
+	.subsys_id	= blkio_cgroup_subsys_id,
+	.use_id		= 1,
+};
diff --git a/mm/bounce.c b/mm/bounce.c
index a2b76a5..422d89c 100644
--- a/mm/bounce.c
+++ b/mm/bounce.c
@@ -14,6 +14,7 @@
 #include <linux/hash.h>
 #include <linux/highmem.h>
 #include <asm/tlbflush.h>
+#include <linux/biotrack.h>
 
 #include <trace/events/block.h>
 
@@ -210,6 +211,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 		to->bv_len = from->bv_len;
 		to->bv_offset = from->bv_offset;
 		inc_zone_page_state(to->bv_page, NR_BOUNCE);
+		blkio_cgroup_copy_owner(to->bv_page, page);
 
 		if (rw == WRITE) {
 			char *vto, *vfrom;
diff --git a/mm/filemap.c b/mm/filemap.c
index 2239671..c2356cd 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -33,6 +33,7 @@
 #include <linux/cpuset.h>
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
+#include <linux/biotrack.h>
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
 #include "internal.h"
 
@@ -464,6 +465,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 					gfp_mask & GFP_RECLAIM_MASK);
 	if (error)
 		goto out;
+	blkio_cgroup_set_owner(page, current->mm);
 
 	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error == 0) {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e2fa20d..41896f6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
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
diff --git a/mm/memory.c b/mm/memory.c
index f46ac18..f1451d6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -51,6 +51,7 @@
 #include <linux/init.h>
 #include <linux/writeback.h>
 #include <linux/memcontrol.h>
+#include <linux/biotrack.h>
 #include <linux/mmu_notifier.h>
 #include <linux/kallsyms.h>
 #include <linux/swapops.h>
@@ -2117,6 +2118,7 @@ gotten:
 		 */
 		ptep_clear_flush_notify(vma, address, page_table);
 		page_add_new_anon_rmap(new_page, vma, address);
+		blkio_cgroup_set_owner(new_page, mm);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		if (old_page) {
@@ -2582,6 +2584,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	flush_icache_page(vma, page);
 	set_pte_at(mm, address, page_table, pte);
 	page_add_anon_rmap(page, vma, address);
+	blkio_cgroup_reset_owner(page, mm);
 	/* It's better to call commit-charge after rmap is established */
 	mem_cgroup_commit_charge_swapin(page, ptr);
 
@@ -2646,6 +2649,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto release;
 	inc_mm_counter(mm, anon_rss);
 	page_add_new_anon_rmap(page, vma, address);
+	blkio_cgroup_set_owner(page, mm);
 	set_pte_at(mm, address, page_table, entry);
 
 	/* No need to invalidate - it was non-present before */
@@ -2793,6 +2797,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (anon) {
 			inc_mm_counter(mm, anon_rss);
 			page_add_new_anon_rmap(page, vma, address);
+			blkio_cgroup_set_owner(page, mm);
 		} else {
 			inc_mm_counter(mm, file_rss);
 			page_add_file_rmap(page);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 7b0dcea..31d3675 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -23,6 +23,7 @@
 #include <linux/init.h>
 #include <linux/backing-dev.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/biotrack.h>
 #include <linux/blkdev.h>
 #include <linux/mpage.h>
 #include <linux/rmap.h>
@@ -1244,6 +1245,7 @@ int __set_page_dirty_nobuffers(struct page *page)
 			BUG_ON(mapping2 != mapping);
 			WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
 			account_page_dirtied(page, mapping);
+			blkio_cgroup_reset_owner_pagedirty(page, current->mm);
 			radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 		}
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index f22b4eb..2883bb7 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -9,14 +9,15 @@
 #include <linux/vmalloc.h>
 #include <linux/cgroup.h>
 #include <linux/swapops.h>
+#include <linux/biotrack.h>
 
 static void __meminit
 __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
 {
 	pc->flags = 0;
-	pc->mem_cgroup = NULL;
 	pc->page = pfn_to_page(pfn);
-	INIT_LIST_HEAD(&pc->lru);
+	__init_mem_page_cgroup(pc);
+	__init_blkio_page_cgroup(pc);
 }
 static unsigned long total_usage;
 
@@ -74,7 +75,7 @@ void __init page_cgroup_init_flatmem(void)
 
 	int nid, fail;
 
-	if (mem_cgroup_disabled())
+	if (mem_cgroup_disabled() && blkio_cgroup_disabled())
 		return;
 
 	for_each_online_node(nid)  {
@@ -83,12 +84,12 @@ void __init page_cgroup_init_flatmem(void)
 			goto fail;
 	}
 	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you"
+	printk(KERN_INFO "please try cgroup_disable=memory,blkio option if you"
 	" don't want memory cgroups\n");
 	return;
 fail:
 	printk(KERN_CRIT "allocation of page_cgroup failed.\n");
-	printk(KERN_CRIT "please try 'cgroup_disable=memory' boot option\n");
+	printk(KERN_CRIT "please try cgroup_disable=memory,blkio boot options\n");
 	panic("Out of memory");
 }
 
@@ -245,7 +246,7 @@ void __init page_cgroup_init(void)
 	unsigned long pfn;
 	int fail = 0;
 
-	if (mem_cgroup_disabled())
+	if (mem_cgroup_disabled() && blkio_cgroup_disabled())
 		return;
 
 	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
@@ -260,8 +261,8 @@ void __init page_cgroup_init(void)
 		hotplug_memory_notifier(page_cgroup_callback, 0);
 	}
 	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you don't"
-	" want memory cgroups\n");
+	printk(KERN_INFO "please try cgroup_disable=memory,blkio option"
+	" if you don't want memory and io cgroups\n");
 }
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 42cd38e..6eb96f1 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -18,6 +18,7 @@
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
 #include <linux/page_cgroup.h>
+#include <linux/biotrack.h>
 
 #include <asm/pgtable.h>
 
@@ -307,6 +308,7 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 */
 		__set_page_locked(new_page);
 		SetPageSwapBacked(new_page);
+		blkio_cgroup_set_owner(new_page, current->mm);
 		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
 		if (likely(!err)) {
 			/*
-- 
1.6.0.6
