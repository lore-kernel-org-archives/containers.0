From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 5/9] blkio-cgroup-v12: The body of blkio-cgroup
Date: Mon, 14 Sep 2009 21:30:11 +0900 (JST)
Message-ID: <20090914.213011.189721100.ryov__15167.6403162584$1252932208$gmane$org@valinux.co.jp>
References: <20090914.212839.226798134.ryov@valinux.co.jp>
	<20090914.212909.71094050.ryov@valinux.co.jp>
	<20090914.212946.104038099.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090914.212946.104038099.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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

The body of blkio-cgroup.

Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>

---
 include/linux/biotrack.h      |  100 ++++++++++++++
 include/linux/cgroup_subsys.h |    6 
 init/Kconfig                  |   13 +
 mm/Makefile                   |    1 
 mm/biotrack.c                 |  293 ++++++++++++++++++++++++++++++++++++++++++
 mm/page_cgroup.c              |   20 +-
 6 files changed, 424 insertions(+), 9 deletions(-)

Index: linux-2.6.31/include/linux/biotrack.h
===================================================================
--- /dev/null
+++ linux-2.6.31/include/linux/biotrack.h
@@ -0,0 +1,100 @@
+#include <linux/cgroup.h>
+#include <linux/mm.h>
+#include <linux/page_cgroup.h>
+
+#ifndef _LINUX_BIOTRACK_H
+#define _LINUX_BIOTRACK_H
+
+#ifdef CONFIG_CGROUP_BLKIO
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
+	pc->blkio_cgroup_id = 0;
+}
+
+/**
+ * blkio_cgroup_disabled() - check whether blkio_cgroup is disabled
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
+extern struct cgroup *get_cgroup_from_page(struct page *page);
+
+#else /* !CONFIG_CGROUP_BLKIO */
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
+static inline struct cgroup *get_cgroup_from_page(struct page *page)
+{
+	return NULL;
+}
+
+#endif /* CONFIG_CGROUP_BLKIO */
+
+#endif /* _LINUX_BIOTRACK_H */
Index: linux-2.6.31/include/linux/cgroup_subsys.h
===================================================================
--- linux-2.6.31.orig/include/linux/cgroup_subsys.h
+++ linux-2.6.31/include/linux/cgroup_subsys.h
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
Index: linux-2.6.31/init/Kconfig
===================================================================
--- linux-2.6.31.orig/init/Kconfig
+++ linux-2.6.31/init/Kconfig
@@ -614,9 +614,20 @@ config CGROUP_MEM_RES_CTLR_SWAP
 
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
 config CGROUP_PAGE
 	def_bool y
-	depends on CGROUP_MEM_RES_CTLR
+	depends on CGROUP_MEM_RES_CTLR || CGROUP_BLKIO
 
 config MM_OWNER
 	bool
Index: linux-2.6.31/mm/biotrack.c
===================================================================
--- /dev/null
+++ linux-2.6.31/mm/biotrack.c
@@ -0,0 +1,293 @@
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
+
+	if (blkio_cgroup_disabled())
+		return;
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!pc))
+		return;
+
+	pc->blkio_cgroup_id = 0;	/* 0: default blkio_cgroup id */
+	if (!mm)
+		return;
+	/*
+	 * Locking "pc" isn't necessary here since the current process is
+	 * the only one that can access the members related to blkio_cgroup.
+	 */
+	rcu_read_lock();
+	biog = blkio_cgroup_from_task(rcu_dereference(mm->owner));
+	if (unlikely(!biog))
+		goto out;
+	/*
+	 * css_get(&bio->css) isn't called to increment the reference
+	 * count of this blkio_cgroup "biog" so pc->blkio_cgroup_id
+	 * might turn invalid even if this page is still active.
+	 * This approach is chosen to minimize the overhead.
+	 */
+	pc->blkio_cgroup_id = css_id(&biog->css);
+out:
+	rcu_read_unlock();
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
+	/*
+	 * A little trick:
+	 * Just call blkio_cgroup_set_owner() for pages which are already
+	 * active since the blkio_cgroup_id member of page_cgroup can be
+	 * updated without any locks. This is because an integer type of
+	 * variable can be set a new value at once on modern cpus.
+	 */
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
+	/*
+	 * Do this without any locks. The reason is the same as
+	 * blkio_cgroup_reset_owner().
+	 */
+	npc->blkio_cgroup_id = opc->blkio_cgroup_id;
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
+	if (pc)
+		id = pc->blkio_cgroup_id;
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
+ * get_cgroup_from_page() - determine the cgroup from a page.
+ * @page:	the page to be tracked
+ *
+ * Returns the cgroup of a given page. A return value zero means that
+ * the page associated with the page belongs to default_blkio_cgroup.
+ *
+ * Note:
+ * This function must be called under rcu_read_lock().
+ */
+struct cgroup *get_cgroup_from_page(struct page *page)
+{
+	struct page_cgroup *pc;
+	struct cgroup_subsys_state *css;
+
+	pc = lookup_page_cgroup(page);
+	if (!pc || !pc->blkio_cgroup_id)
+		return NULL;
+
+	css = css_lookup(&blkio_cgroup_subsys, pc->blkio_cgroup_id);
+	if (!css)
+		return NULL;
+
+	return css->cgroup;
+}
+
+EXPORT_SYMBOL(get_blkio_cgroup_id);
+EXPORT_SYMBOL(get_blkio_cgroup_iocontext);
+EXPORT_SYMBOL(get_cgroup_from_page);
+
+/* Read the ID of the specified blkio cgroup. */
+static u64 blkio_id_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct blkio_cgroup *biog = cgroup_blkio(cgrp);
+
+	return (u64)css_id(&biog->css);
+}
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
Index: linux-2.6.31/mm/page_cgroup.c
===================================================================
--- linux-2.6.31.orig/mm/page_cgroup.c
+++ linux-2.6.31/mm/page_cgroup.c
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
+	__init_blkio_page_cgroup(pc);
 }
 static unsigned long total_usage;
 
@@ -73,7 +75,7 @@ void __init page_cgroup_init_flatmem(voi
 
 	int nid, fail;
 
-	if (mem_cgroup_disabled())
+	if (mem_cgroup_disabled() && blkio_cgroup_disabled())
 		return;
 
 	for_each_online_node(nid)  {
@@ -82,12 +84,13 @@ void __init page_cgroup_init_flatmem(voi
 			goto fail;
 	}
 	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you"
-	" don't want memory cgroups\n");
+	printk(KERN_INFO "please try 'cgroup_disable=memory,blkio' option"
+        " if you don't want memory and blkio cgroups\n");
 	return;
 fail:
 	printk(KERN_CRIT "allocation of page_cgroup failed.\n");
-	printk(KERN_CRIT "please try 'cgroup_disable=memory' boot option\n");
+	printk(KERN_CRIT
+		"please try 'cgroup_disable=memory,blkio' boot option\n");
 	panic("Out of memory");
 }
 
@@ -244,7 +247,7 @@ void __init page_cgroup_init(void)
 	unsigned long pfn;
 	int fail = 0;
 
-	if (mem_cgroup_disabled())
+	if (mem_cgroup_disabled() && blkio_cgroup_disabled())
 		return;
 
 	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
@@ -253,14 +256,15 @@ void __init page_cgroup_init(void)
 		fail = init_section_page_cgroup(pfn);
 	}
 	if (fail) {
-		printk(KERN_CRIT "try 'cgroup_disable=memory' boot option\n");
+		printk(KERN_CRIT
+			"try 'cgroup_disable=memory,blkio' boot option\n");
 		panic("Out of memory");
 	} else {
 		hotplug_memory_notifier(page_cgroup_callback, 0);
 	}
 	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you don't"
-	" want memory cgroups\n");
+	printk(KERN_INFO "please try 'cgroup_disable=memory,blkio' option"
+	" if you don't want memory and blkio cgroups\n");
 }
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
Index: linux-2.6.31/mm/Makefile
===================================================================
--- linux-2.6.31.orig/mm/Makefile
+++ linux-2.6.31/mm/Makefile
@@ -41,5 +41,6 @@ endif
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
 obj-$(CONFIG_CGROUP_PAGE) += page_cgroup.o
+obj-$(CONFIG_CGROUP_BLKIO) += biotrack.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
