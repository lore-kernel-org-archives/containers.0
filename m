From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 3/5] bio-cgroup: The body of bio-cgroup
Date: Thu, 16 Apr 2009 21:30:19 +0900 (JST)
Message-ID: <20090416.213019.104045053.ryov__2292.43570142916$1239885546$gmane$org@valinux.co.jp>
References: <20090416.212836.226792104.ryov@valinux.co.jp>
	<20090416.212931.71100972.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090416.212931.71100972.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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
List-Id: containers.vger.kernel.org

This is the body of bio-cgroup.

Based on 2.6.30-rc1
Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>

---
 block/blk-ioc.c               |   30 ++---
 include/linux/biotrack.h      |   83 ++++++++++++++
 include/linux/cgroup_subsys.h |    6 +
 include/linux/iocontext.h     |    1 
 include/linux/page_cgroup.h   |    3 
 init/Kconfig                  |   13 ++
 mm/biotrack.c                 |  244 ++++++++++++++++++++++++++++++++++++++++++
 mm/page_cgroup.c              |   12 +-
 8 files changed, 373 insertions(+), 19 deletions(-)

Index: linux-2.6.30-rc1/block/blk-ioc.c
===================================================================
--- linux-2.6.30-rc1.orig/block/blk-ioc.c
+++ linux-2.6.30-rc1/block/blk-ioc.c
@@ -84,24 +84,28 @@ void exit_io_context(void)
 	}
 }
 
+void init_io_context(struct io_context *ioc)
+{
+	atomic_set(&ioc->refcount, 1);
+	atomic_set(&ioc->nr_tasks, 1);
+	spin_lock_init(&ioc->lock);
+	ioc->ioprio_changed = 0;
+	ioc->ioprio = 0;
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
-		atomic_set(&ret->refcount, 1);
-		atomic_set(&ret->nr_tasks, 1);
-		spin_lock_init(&ret->lock);
-		ret->ioprio_changed = 0;
-		ret->ioprio = 0;
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
Index: linux-2.6.30-rc1/include/linux/biotrack.h
===================================================================
--- /dev/null
+++ linux-2.6.30-rc1/include/linux/biotrack.h
@@ -0,0 +1,83 @@
+#include <linux/cgroup.h>
+#include <linux/mm.h>
+#include <linux/page_cgroup.h>
+
+#ifndef _LINUX_BIOTRACK_H
+#define _LINUX_BIOTRACK_H
+
+#ifdef	CONFIG_CGROUP_BIO
+
+struct io_context;
+struct block_device;
+
+struct bio_cgroup {
+	struct cgroup_subsys_state css;
+	struct io_context *io_context;	/* default io_context */
+/*	struct radix_tree_root io_context_root; per device io_context */
+};
+
+static inline void __init_bio_page_cgroup(struct page_cgroup *pc)
+{
+	pc->bio_cgroup_id = 0;
+}
+
+static inline bool bio_cgroup_disabled(void)
+{
+	if (bio_cgroup_subsys.disabled)
+		return true;
+	return false;
+}
+
+extern void bio_cgroup_set_owner(struct page *page, struct mm_struct *mm);
+extern void bio_cgroup_reset_owner(struct page *page, struct mm_struct *mm);
+extern void bio_cgroup_reset_owner_pagedirty(struct page *page,
+						 struct mm_struct *mm);
+extern void bio_cgroup_copy_owner(struct page *page, struct page *opage);
+
+extern struct io_context *get_bio_cgroup_iocontext(struct bio *bio);
+extern int get_bio_cgroup_id(struct bio *bio);
+
+#else	/* CONFIG_CGROUP_BIO */
+
+struct bio_cgroup;
+
+static inline void __init_bio_page_cgroup(struct page_cgroup *pc)
+{
+}
+
+static inline bool bio_cgroup_disabled(void)
+{
+	return true;
+}
+
+static inline void bio_cgroup_set_owner(struct page *page, struct mm_struct *mm)
+{
+}
+
+static inline void bio_cgroup_reset_owner(struct page *page,
+						struct mm_struct *mm)
+{
+}
+
+static inline void bio_cgroup_reset_owner_pagedirty(struct page *page,
+						struct mm_struct *mm)
+{
+}
+
+static inline void bio_cgroup_copy_owner(struct page *page, struct page *opage)
+{
+}
+
+static inline struct io_context *get_bio_cgroup_iocontext(struct bio *bio)
+{
+	return NULL;
+}
+
+static inline int get_bio_cgroup_id(struct bio *bio)
+{
+	return 0;
+}
+
+#endif	/* CONFIG_CGROUP_BIO */
+
+#endif /* _LINUX_BIOTRACK_H */
Index: linux-2.6.30-rc1/include/linux/cgroup_subsys.h
===================================================================
--- linux-2.6.30-rc1.orig/include/linux/cgroup_subsys.h
+++ linux-2.6.30-rc1/include/linux/cgroup_subsys.h
@@ -43,6 +43,12 @@ SUBSYS(mem_cgroup)
 
 /* */
 
+#ifdef CONFIG_CGROUP_BIO
+SUBSYS(bio_cgroup)
+#endif
+
+/* */
+
 #ifdef CONFIG_CGROUP_DEVICE
 SUBSYS(devices)
 #endif
Index: linux-2.6.30-rc1/include/linux/iocontext.h
===================================================================
--- linux-2.6.30-rc1.orig/include/linux/iocontext.h
+++ linux-2.6.30-rc1/include/linux/iocontext.h
@@ -104,6 +104,7 @@ int put_io_context(struct io_context *io
 void exit_io_context(void);
 struct io_context *get_io_context(gfp_t gfp_flags, int node);
 struct io_context *alloc_io_context(gfp_t gfp_flags, int node);
+void init_io_context(struct io_context *ioc);
 void copy_io_context(struct io_context **pdst, struct io_context **psrc);
 #else
 static inline void exit_io_context(void)
Index: linux-2.6.30-rc1/include/linux/page_cgroup.h
===================================================================
--- linux-2.6.30-rc1.orig/include/linux/page_cgroup.h
+++ linux-2.6.30-rc1/include/linux/page_cgroup.h
@@ -17,6 +17,9 @@ struct page_cgroup {
 	struct mem_cgroup *mem_cgroup;
 	struct list_head lru;		/* per cgroup LRU list */
 #endif
+#ifdef CONFIG_CGROUP_BIO
+	unsigned short bio_cgroup_id;
+#endif
 };
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
Index: linux-2.6.30-rc1/init/Kconfig
===================================================================
--- linux-2.6.30-rc1.orig/init/Kconfig
+++ linux-2.6.30-rc1/init/Kconfig
@@ -608,9 +608,20 @@ config CGROUP_MEM_RES_CTLR_SWAP
 
 endif # CGROUPS
 
+config CGROUP_BIO
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
 config CGROUP_PAGE
 	def_bool y
-	depends on CGROUP_MEM_RES_CTLR
+	depends on CGROUP_MEM_RES_CTLR || CGROUP_BIO
 
 config MM_OWNER
 	bool
Index: linux-2.6.30-rc1/mm/biotrack.c
===================================================================
--- /dev/null
+++ linux-2.6.30-rc1/mm/biotrack.c
@@ -0,0 +1,244 @@
+/* biotrack.c - Block I/O Tracking
+ *
+ * Copyright (C) VA Linux Systems Japan, 2008-2009
+ * Developed by Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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
+
+/*
+ * The block I/O tracking mechanism is implemented on the cgroup memory
+ * controller framework. It helps to find the the owner of an I/O request
+ * because every I/O request has a target page and the owner of the page
+ * can be easily determined on the framework.
+ */
+
+/* Return the bio_cgroup that associates with a cgroup. */
+static inline struct bio_cgroup *cgroup_bio(struct cgroup *cgrp)
+{
+	return container_of(cgroup_subsys_state(cgrp, bio_cgroup_subsys_id),
+					struct bio_cgroup, css);
+}
+
+/* Return the bio_cgroup that associates with a process. */
+static inline struct bio_cgroup *bio_cgroup_from_task(struct task_struct *p)
+{
+	return container_of(task_subsys_state(p, bio_cgroup_subsys_id),
+					struct bio_cgroup, css);
+}
+
+static struct io_context default_bio_io_context;
+static struct bio_cgroup default_bio_cgroup = {
+	.io_context	= &default_bio_io_context,
+};
+
+/*
+ * This function is used to make a given page have the bio-cgroup id of
+ * the owner of this page.
+ */
+void bio_cgroup_set_owner(struct page *page, struct mm_struct *mm)
+{
+	struct bio_cgroup *biog;
+	struct page_cgroup *pc;
+
+	if (bio_cgroup_disabled())
+		return;
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!pc))
+		return;
+
+	pc->bio_cgroup_id = 0;	/* 0: default bio_cgroup id */
+	if (!mm)
+		return;
+	/*
+	 * Locking "pc" isn't necessary here since the current process is
+	 * the only one that can access the members related to bio_cgroup.
+	 */
+	rcu_read_lock();
+	biog = bio_cgroup_from_task(rcu_dereference(mm->owner));
+	if (unlikely(!biog))
+		goto out;
+	/*
+	 * css_get(&bio->css) isn't called to increment the reference
+	 * count of this bio_cgroup "biog" so pc->bio_cgroup_id might turn
+	 * invalid even if this page is still active.
+	 * This approach is chosen to minimize the overhead.
+	 */
+	pc->bio_cgroup_id = css_id(&biog->css);
+out:
+	rcu_read_unlock();
+}
+
+/*
+ * Change the owner of a given page if necessary.
+ */
+void bio_cgroup_reset_owner(struct page *page, struct mm_struct *mm)
+{
+	/*
+	 * A little trick:
+	 * Just call bio_cgroup_set_owner() for pages which are already
+	 * active since the bio_cgroup_id member of page_cgroup can be
+	 * updated without any locks. This is because an integer type of
+	 * variable can be set a new value at once on modern cpus.
+	 */
+	bio_cgroup_set_owner(page, mm);
+}
+
+/*
+ * Change the owner of a given page. This function is only effective for
+ * pages in the pagecache.
+ */
+void bio_cgroup_reset_owner_pagedirty(struct page *page, struct mm_struct *mm)
+{
+	if (PageSwapCache(page) || PageAnon(page))
+		return;
+	if (current->flags & PF_MEMALLOC)
+		return;
+
+	bio_cgroup_reset_owner(page, mm);
+}
+
+/*
+ * Assign "page" the same owner as "opage."
+ */
+void bio_cgroup_copy_owner(struct page *npage, struct page *opage)
+{
+	struct page_cgroup *npc, *opc;
+
+	if (bio_cgroup_disabled())
+		return;
+	npc = lookup_page_cgroup(npage);
+	if (unlikely(!npc))
+		return;
+	opc = lookup_page_cgroup(opage);
+	if (unlikely(!opc))
+		return;
+
+	/*
+	 * Do this without any locks. The reason is the same as
+	 * bio_cgroup_reset_owner().
+	 */
+	npc->bio_cgroup_id = opc->bio_cgroup_id;
+}
+
+/* Create a new bio-cgroup. */
+static struct cgroup_subsys_state *
+bio_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct bio_cgroup *biog;
+	struct io_context *ioc;
+
+	if (!cgrp->parent) {
+		biog = &default_bio_cgroup;
+		init_io_context(biog->io_context);
+		/* Increment the referrence count not to be released ever. */
+		atomic_inc(&biog->io_context->refcount);
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
+/* Delete the bio-cgroup. */
+static void bio_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct bio_cgroup *biog = cgroup_bio(cgrp);
+
+	put_io_context(biog->io_context);
+	free_css_id(&bio_cgroup_subsys, &biog->css);
+	kfree(biog);
+}
+
+/* Determine the bio-cgroup id of a given bio. */
+int get_bio_cgroup_id(struct bio *bio)
+{
+	struct page_cgroup *pc;
+	struct page *page = bio_iovec_idx(bio, 0)->bv_page;
+	int	id = 0;
+
+	pc = lookup_page_cgroup(page);
+	if (pc)
+		id = pc->bio_cgroup_id;
+	return id;
+}
+
+/* Determine the iocontext of the bio-cgroup that issued a given bio. */
+struct io_context *get_bio_cgroup_iocontext(struct bio *bio)
+{
+	struct cgroup_subsys_state *css;
+	struct bio_cgroup *biog = NULL;
+	struct io_context *ioc;
+	int	id = 0;
+
+	id = get_bio_cgroup_id(bio);
+
+	rcu_read_lock();
+	css = css_lookup(&bio_cgroup_subsys, id);
+	if (css)
+		biog = container_of(css, struct bio_cgroup, css);
+	else
+		biog = &default_bio_cgroup;
+	rcu_read_unlock();
+
+	ioc = biog->io_context;	/* default io_context for this cgroup */
+	atomic_inc(&ioc->refcount);
+	return ioc;
+}
+EXPORT_SYMBOL(get_bio_cgroup_iocontext);
+EXPORT_SYMBOL(get_bio_cgroup_id);
+
+static u64 bio_id_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct bio_cgroup *biog = cgroup_bio(cgrp);
+	int id;
+
+	rcu_read_lock();
+	id = css_id(&biog->css);
+	rcu_read_unlock();
+	return (u64)id;
+}
+
+
+static struct cftype bio_files[] = {
+	{
+		.name = "id",
+		.read_u64 = bio_id_read,
+	},
+};
+
+static int bio_cgroup_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	return cgroup_add_files(cgrp, ss, bio_files, ARRAY_SIZE(bio_files));
+}
+
+struct cgroup_subsys bio_cgroup_subsys = {
+	.name		= "bio",
+	.create		= bio_cgroup_create,
+	.destroy	= bio_cgroup_destroy,
+	.populate	= bio_cgroup_populate,
+	.subsys_id	= bio_cgroup_subsys_id,
+	.use_id		= 1,
+};
Index: linux-2.6.30-rc1/mm/page_cgroup.c
===================================================================
--- linux-2.6.30-rc1.orig/mm/page_cgroup.c
+++ linux-2.6.30-rc1/mm/page_cgroup.c
@@ -9,6 +9,7 @@
 #include <linux/vmalloc.h>
 #include <linux/cgroup.h>
 #include <linux/swapops.h>
+#include <linux/biotrack.h>
 
 static void __meminit
 __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
@@ -16,6 +17,7 @@ __init_page_cgroup(struct page_cgroup *p
 	pc->flags = 0;
 	pc->page = pfn_to_page(pfn);
 	__init_mem_page_cgroup(pc);
+	__init_bio_page_cgroup(pc);
 }
 static unsigned long total_usage;
 
@@ -73,7 +75,7 @@ void __init page_cgroup_init(void)
 
 	int nid, fail;
 
-	if (mem_cgroup_disabled())
+	if (mem_cgroup_disabled() && bio_cgroup_disabled())
 		return;
 
 	for_each_online_node(nid)  {
@@ -82,12 +84,12 @@ void __init page_cgroup_init(void)
 			goto fail;
 	}
 	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try cgroup_disable=memory option if you"
+	printk(KERN_INFO "please try cgroup_disable=memory,bio option if you"
 	" don't want\n");
 	return;
 fail:
 	printk(KERN_CRIT "allocation of page_cgroup was failed.\n");
-	printk(KERN_CRIT "please try cgroup_disable=memory boot option\n");
+	printk(KERN_CRIT "please try cgroup_disable=memory,bio boot options\n");
 	panic("Out of memory");
 }
 
@@ -247,7 +249,7 @@ void __init page_cgroup_init(void)
 	unsigned long pfn;
 	int fail = 0;
 
-	if (mem_cgroup_disabled())
+	if (mem_cgroup_disabled() && bio_cgroup_disabled())
 		return;
 
 	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
@@ -262,7 +264,7 @@ void __init page_cgroup_init(void)
 		hotplug_memory_notifier(page_cgroup_callback, 0);
 	}
 	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try cgroup_disable=memory option if you don't"
+	printk(KERN_INFO "please try cgroup_disable=memory,bio option if you don't"
 	" want\n");
 }
