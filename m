From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 8/9] blkio-cgroup-v9: Fast page tracking
Date: Tue, 21 Jul 2009 23:24:01 +0900 (JST)
Message-ID: <20090721.232401.39167673.ryov__14446.2440548979$1248186700$gmane$org@valinux.co.jp>
References: <20090721.231405.189716609.ryov@valinux.co.jp>
	<20090721.231505.112612378.ryov@valinux.co.jp>
	<20090721.232316.183036419.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090721.232316.183036419.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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

This is an extra patch which reduces the overhead of IO tracking but
increases the size of struct page_cgroup.

Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>

---
 include/linux/biotrack.h    |    5 -
 include/linux/page_cgroup.h |   26 --------
 mm/biotrack.c               |  138 ++++++++++++++++++++++++++------------------
 3 files changed, 87 insertions(+), 82 deletions(-)

Index: linux-2.6.31-rc3/mm/biotrack.c
===================================================================
--- linux-2.6.31-rc3.orig/mm/biotrack.c
+++ linux-2.6.31-rc3/mm/biotrack.c
@@ -3,9 +3,6 @@
  * Copyright (C) VA Linux Systems Japan, 2008-2009
  * Developed by Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
  *
- * Copyright (C) 2008 Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
- * Use part of page_cgroup->flags to store blkio-cgroup ID.
- *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 2 of the License, or
@@ -20,6 +17,7 @@
 #include <linux/module.h>
 #include <linux/smp.h>
 #include <linux/bit_spinlock.h>
+#include <linux/idr.h>
 #include <linux/blkdev.h>
 #include <linux/biotrack.h>
 #include <linux/mm_inline.h>
@@ -45,8 +43,11 @@ static inline struct blkio_cgroup *blkio
 					struct blkio_cgroup, css);
 }
 
+static struct idr blkio_cgroup_id;
+static DEFINE_SPINLOCK(blkio_cgroup_idr_lock);
 static struct io_context default_blkio_io_context;
 static struct blkio_cgroup default_blkio_cgroup = {
+	.id		= 0,
 	.io_context	= &default_blkio_io_context,
 };
 
@@ -61,7 +62,6 @@ void blkio_cgroup_set_owner(struct page 
 {
 	struct blkio_cgroup *biog;
 	struct page_cgroup *pc;
-	unsigned long id;
 
 	if (blkio_cgroup_disabled())
 		return;
@@ -69,29 +69,27 @@ void blkio_cgroup_set_owner(struct page 
 	if (unlikely(!pc))
 		return;
 
-	lock_page_cgroup(pc);
-	page_cgroup_set_id(pc, 0);	/* 0: default blkio_cgroup id */
-	unlock_page_cgroup(pc);
+	pc->blkio_cgroup_id = 0;	/* 0: default blkio_cgroup id */
 	if (!mm)
 		return;
 
+	/*
+	 * Locking "pc" isn't necessary here since the current process is
+	 * the only one that can access the members related to blkio_cgroup.
+	 */
 	rcu_read_lock();
 	biog = blkio_cgroup_from_task(rcu_dereference(mm->owner));
-	if (unlikely(!biog)) {
-		rcu_read_unlock();
-		return;
-	}
+	if (unlikely(!biog))
+		goto out;
 	/*
 	 * css_get(&bio->css) isn't called to increment the reference
 	 * count of this blkio_cgroup "biog" so the css_id might turn
 	 * invalid even if this page is still active.
 	 * This approach is chosen to minimize the overhead.
 	 */
-	id = css_id(&biog->css);
+	pc->blkio_cgroup_id = biog->id;
+out:
 	rcu_read_unlock();
-	lock_page_cgroup(pc);
-	page_cgroup_set_id(pc, id);
-	unlock_page_cgroup(pc);
 }
 
 /**
@@ -103,6 +101,13 @@ void blkio_cgroup_set_owner(struct page 
  */
 void blkio_cgroup_reset_owner(struct page *page, struct mm_struct *mm)
 {
+	/*
+	 * A little trick:
+	 * Just call blkio_cgroup_set_owner() for pages which are already
+	 * active since the blkio_cgroup_id member of page_cgroup can be
+	 * updated without any locks. This is because an integer type of
+	 * variable can be set a new value at once on modern cpus.
+	 */
 	blkio_cgroup_set_owner(page, mm);
 }
 
@@ -133,7 +138,6 @@ void blkio_cgroup_reset_owner_pagedirty(
 void blkio_cgroup_copy_owner(struct page *npage, struct page *opage)
 {
 	struct page_cgroup *npc, *opc;
-	unsigned long id;
 
 	if (blkio_cgroup_disabled())
 		return;
@@ -144,12 +148,11 @@ void blkio_cgroup_copy_owner(struct page
 	if (unlikely(!opc))
 		return;
 
-	lock_page_cgroup(opc);
-	lock_page_cgroup(npc);
-	id = page_cgroup_get_id(opc);
-	page_cgroup_set_id(npc, id);
-	unlock_page_cgroup(npc);
-	unlock_page_cgroup(opc);
+	/*
+	 * Do this without any locks. The reason is the same as
+	 * blkio_cgroup_reset_owner().
+	 */
+	npc->blkio_cgroup_id = opc->blkio_cgroup_id;
 }
 
 /* Create a new blkio-cgroup. */
@@ -158,25 +161,44 @@ blkio_cgroup_create(struct cgroup_subsys
 {
 	struct blkio_cgroup *biog;
 	struct io_context *ioc;
+	int ret;
 
 	if (!cgrp->parent) {
 		biog = &default_blkio_cgroup;
 		init_io_context(biog->io_context);
 		/* Increment the referrence count not to be released ever. */
 		atomic_inc(&biog->io_context->refcount);
+		idr_init(&blkio_cgroup_id);
 		return &biog->css;
 	}
 
 	biog = kzalloc(sizeof(*biog), GFP_KERNEL);
-	if (!biog)
-		return ERR_PTR(-ENOMEM);
 	ioc = alloc_io_context(GFP_KERNEL, -1);
-	if (!ioc) {
-		kfree(biog);
-		return ERR_PTR(-ENOMEM);
+	if (!ioc || !biog) {
+		ret = -ENOMEM;
+		goto out_err;
 	}
 	biog->io_context = ioc;
+retry:
+	if (!idr_pre_get(&blkio_cgroup_id, GFP_KERNEL)) {
+		ret = -EAGAIN;
+		goto out_err;
+	}
+	spin_lock_irq(&blkio_cgroup_idr_lock);
+	ret = idr_get_new_above(&blkio_cgroup_id, (void *)biog, 1, &biog->id);
+	spin_unlock_irq(&blkio_cgroup_idr_lock);
+	if (ret == -EAGAIN)
+		goto retry;
+	else if (ret)
+		goto out_err;
+
 	return &biog->css;
+out_err:
+	if (biog)
+		kfree(biog);
+	if (ioc)
+		put_io_context(ioc);
+	return ERR_PTR(ret);
 }
 
 /* Delete the blkio-cgroup. */
@@ -185,10 +207,28 @@ static void blkio_cgroup_destroy(struct 
 	struct blkio_cgroup *biog = cgroup_blkio(cgrp);
 
 	put_io_context(biog->io_context);
-	free_css_id(&blkio_cgroup_subsys, &biog->css);
+
+	spin_lock_irq(&blkio_cgroup_idr_lock);
+	idr_remove(&blkio_cgroup_id, biog->id);
+	spin_unlock_irq(&blkio_cgroup_idr_lock);
+
 	kfree(biog);
 }
 
+static struct blkio_cgroup *find_blkio_cgroup(int id)
+{
+	struct blkio_cgroup *biog;
+	spin_lock_irq(&blkio_cgroup_idr_lock);
+	/*
+	 * It might fail to find A bio-group associated with "id" since it
+	 * is allowed to remove the bio-cgroup even when some of I/O requests
+	 * this group issued haven't completed yet.
+	 */
+	biog = (struct blkio_cgroup *)idr_find(&blkio_cgroup_id, id);
+	spin_unlock_irq(&blkio_cgroup_idr_lock);
+	return biog;
+}
+
 /**
  * get_blkio_cgroup_id() - determine the blkio-cgroup ID
  * @bio:	the &struct bio which describes the I/O
@@ -200,14 +240,11 @@ unsigned long get_blkio_cgroup_id(struct
 {
 	struct page_cgroup *pc;
 	struct page *page = bio_iovec_idx(bio, 0)->bv_page;
-	unsigned long id = 0;
+	int	id = 0;
 
 	pc = lookup_page_cgroup(page);
-	if (pc) {
-		lock_page_cgroup(pc);
-		id = page_cgroup_get_id(pc);
-		unlock_page_cgroup(pc);
-	}
+	if (pc)
+		id = pc->blkio_cgroup_id;
 	return id;
 }
 
@@ -219,21 +256,17 @@ unsigned long get_blkio_cgroup_id(struct
  */
 struct io_context *get_blkio_cgroup_iocontext(struct bio *bio)
 {
-	struct cgroup_subsys_state *css;
-	struct blkio_cgroup *biog;
+	struct blkio_cgroup *biog = NULL;
 	struct io_context *ioc;
-	unsigned long id;
+	int	id = 0;
 
 	id = get_blkio_cgroup_id(bio);
-	rcu_read_lock();
-	css = css_lookup(&blkio_cgroup_subsys, id);
-	if (css)
-		biog = container_of(css, struct blkio_cgroup, css);
-	else
+	if (id)
+		biog = find_blkio_cgroup(id);
+	if (!biog)
 		biog = &default_blkio_cgroup;
 	ioc = biog->io_context;	/* default io_context for this cgroup */
 	atomic_inc(&ioc->refcount);
-	rcu_read_unlock();
 	return ioc;
 }
 
@@ -249,17 +282,15 @@ struct io_context *get_blkio_cgroup_ioco
  */
 struct cgroup *blkio_cgroup_lookup(int id)
 {
-	struct cgroup *cgrp;
-	struct cgroup_subsys_state *css;
+	struct blkio_cgroup *biog = NULL;
 
 	if (blkio_cgroup_disabled())
 		return NULL;
-
-	css = css_lookup(&blkio_cgroup_subsys, id);
-	if (!css)
+	if (id)
+		biog = find_blkio_cgroup(id);
+	if (!biog)
 		return NULL;
-	cgrp = css->cgroup;
-	return cgrp;
+	return biog->css.cgroup;
 }
 EXPORT_SYMBOL(get_blkio_cgroup_iocontext);
 EXPORT_SYMBOL(get_blkio_cgroup_id);
@@ -268,12 +299,8 @@ EXPORT_SYMBOL(blkio_cgroup_lookup);
 static u64 blkio_id_read(struct cgroup *cgrp, struct cftype *cft)
 {
 	struct blkio_cgroup *biog = cgroup_blkio(cgrp);
-	unsigned long id;
 
-	rcu_read_lock();
-	id = css_id(&biog->css);
-	rcu_read_unlock();
-	return (u64)id;
+	return (u64) biog->id;
 }
 
 
@@ -296,5 +323,4 @@ struct cgroup_subsys blkio_cgroup_subsys
 	.destroy	= blkio_cgroup_destroy,
 	.populate	= blkio_cgroup_populate,
 	.subsys_id	= blkio_cgroup_subsys_id,
-	.use_id		= 1,
 };
Index: linux-2.6.31-rc3/include/linux/biotrack.h
===================================================================
--- linux-2.6.31-rc3.orig/include/linux/biotrack.h
+++ linux-2.6.31-rc3/include/linux/biotrack.h
@@ -12,6 +12,7 @@ struct block_device;
 
 struct blkio_cgroup {
 	struct cgroup_subsys_state css;
+	int id;
 	struct io_context *io_context;	/* default io_context */
 /*	struct radix_tree_root io_context_root; per device io_context */
 };
@@ -24,9 +25,7 @@ struct blkio_cgroup {
  */
 static inline void __init_blkio_page_cgroup(struct page_cgroup *pc)
 {
-	lock_page_cgroup(pc);
-	page_cgroup_set_id(pc, 0);
-	unlock_page_cgroup(pc);
+	pc->blkio_cgroup_id = 0;
 }
 
 /**
Index: linux-2.6.31-rc3/include/linux/page_cgroup.h
===================================================================
--- linux-2.6.31-rc3.orig/include/linux/page_cgroup.h
+++ linux-2.6.31-rc3/include/linux/page_cgroup.h
@@ -17,6 +17,9 @@ struct page_cgroup {
 	struct mem_cgroup *mem_cgroup;
 	struct list_head lru;		/* per cgroup LRU list */
 #endif
+#ifdef CONFIG_CGROUP_BLKIO
+	int blkio_cgroup_id;
+#endif
 };
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
@@ -140,27 +143,4 @@ static inline void swap_cgroup_swapoff(i
 }
 
 #endif
-
-#ifdef CONFIG_CGROUP_BLKIO
-/*
- * use lower 16 bits for flags and reserve the rest for the page tracking id
- */
-#define PCG_TRACKING_ID_SHIFT	(16)
-#define PCG_TRACKING_ID_BITS \
-	(8 * sizeof(unsigned long) - PCG_TRACKING_ID_SHIFT)
-
-/* NOTE: must be called with page_cgroup() held */
-static inline unsigned long page_cgroup_get_id(struct page_cgroup *pc)
-{
-	return pc->flags >> PCG_TRACKING_ID_SHIFT;
-}
-
-/* NOTE: must be called with page_cgroup() held */
-static inline void page_cgroup_set_id(struct page_cgroup *pc, unsigned long id)
-{
-	WARN_ON(id >= (1UL << PCG_TRACKING_ID_BITS));
-	pc->flags &= (1UL << PCG_TRACKING_ID_SHIFT) - 1;
-	pc->flags |= (unsigned long)(id << PCG_TRACKING_ID_SHIFT);
-}
-#endif
 #endif
