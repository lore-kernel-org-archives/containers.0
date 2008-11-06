From: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Subject: [patch 2/4] io controller: biocgroup implementation
Date: Thu, 06 Nov 2008 10:30:24 -0500
Message-ID: <20081106153135.790621895__49512.9070397981$1225986027$gmane$org@redhat.com>
References: <20081106153022.215696930@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=bio-cgroup-implementation
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3ieIwRZHo2/mJg@public.gmane.org>
Cc: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


o biocgroup functionality.
o Implemented new controller "bio"
o Most of it picked from dm-ioband biocgroup implementation patches.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Index: linux17/include/linux/cgroup_subsys.h
===================================================================
--- linux17.orig/include/linux/cgroup_subsys.h	2008-10-09 18:13:53.000000000 -0400
+++ linux17/include/linux/cgroup_subsys.h	2008-11-05 18:12:32.000000000 -0500
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
Index: linux17/init/Kconfig
===================================================================
--- linux17.orig/init/Kconfig	2008-10-09 18:13:53.000000000 -0400
+++ linux17/init/Kconfig	2008-11-05 18:12:32.000000000 -0500
@@ -408,6 +408,13 @@ config CGROUP_MEM_RES_CTLR
 	  This config option also selects MM_OWNER config option, which
 	  could in turn add some fork/exit overhead.
 
+config CGROUP_BIO
+	bool "Block I/O cgroup subsystem"
+	depends on CGROUP_MEM_RES_CTLR
+	select MM_OWNER
+	help
+	  A generic proportinal weight IO controller.
+
 config SYSFS_DEPRECATED
 	bool
 
Index: linux17/mm/biocontrol.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux17/mm/biocontrol.c	2008-11-05 18:12:44.000000000 -0500
@@ -0,0 +1,409 @@
+/* biocontrol.c - Block I/O Controller
+ *
+ * Copyright IBM Corporation, 2007
+ * Author Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
+ *
+ * Copyright 2007 OpenVZ SWsoft Inc
+ * Author: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
+ *
+ * Copyright VA Linux Systems Japan, 2008
+ * Author Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
+ *
+ * Copyright RedHat Inc, 2008
+ * Author Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
+#include <linux/cgroup.h>
+#include <linux/mm.h>
+#include <linux/blkdev.h>
+#include <linux/smp.h>
+#include <linux/bit_spinlock.h>
+#include <linux/idr.h>
+#include <linux/err.h>
+#include <linux/biocontrol.h>
+
+
+/* return corresponding bio_cgroup object of a cgroup */
+static inline struct bio_cgroup *cgroup_bio(struct cgroup *cgrp)
+{
+	return container_of(cgroup_subsys_state(cgrp, bio_cgroup_subsys_id),
+			    struct bio_cgroup, css);
+}
+
+static inline void bio_list_add_head(struct bio_list *bl, struct bio *bio)
+{
+	bio->bi_next = NULL;
+
+	if (bl->head)
+		bio->bi_next = bl->head;
+	else
+		bl->tail = bio;
+
+	bl->head = bio;
+}
+
+void __bio_group_queue_bio_head(struct bio_group *biog, struct bio *bio)
+{
+	bio_list_add_head(&biog->bio_queue, bio);
+}
+
+void bio_group_queue_bio_head(struct bio_group *biog, struct bio *bio)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&biog->bio_group_lock, flags);
+	 __bio_group_queue_bio_head(biog, bio);
+	spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+}
+
+void  __bio_group_queue_bio_tail(struct bio_group *biog, struct bio *bio)
+{
+	bio_list_add(&biog->bio_queue, bio);
+}
+
+void bio_group_queue_bio_tail(struct bio_group *biog, struct bio *bio)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&biog->bio_group_lock, flags);
+	 __bio_group_queue_bio_tail(biog, bio);
+	spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+}
+
+/* Removes first request from the bio-cgroup request list */
+struct bio* __bio_group_dequeue_bio(struct bio_group *biog)
+{
+       struct bio *bio = NULL;
+
+	if (bio_list_empty(&biog->bio_queue))
+		return NULL;
+	bio = bio_list_pop(&biog->bio_queue);
+	return bio;
+}
+
+struct bio* bio_group_dequeue_bio(struct bio_group *biog)
+{
+	unsigned long flags;
+	struct bio *bio;
+	spin_lock_irqsave(&biog->bio_group_lock, flags);
+		bio = __bio_group_dequeue_bio(biog);
+	spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+	return bio;
+}
+
+/* Traverse through all the active bio_group list of this cgroup and see
+ * if there is an active bio_group for the request queue. */
+struct bio_group* bio_group_from_cgroup(struct bio_cgroup *biocg,
+						struct request_queue *q)
+{
+	unsigned long flags;
+	struct bio_group *biog = NULL;
+
+	spin_lock_irqsave(&biocg->biog_list_lock, flags);
+		if (list_empty(&biocg->bio_group_list))
+			goto out;
+		list_for_each_entry(biog, &biocg->bio_group_list, next) {
+			if (biog->q == q) {
+				bio_group_get(biog);
+				goto out;
+			}
+		}
+
+	/* did not find biog */
+	spin_unlock_irqrestore(&biocg->biog_list_lock, flags);
+	return NULL;
+out:
+	spin_unlock_irqrestore(&biocg->biog_list_lock, flags);
+	return biog;
+}
+
+struct bio_cgroup *bio_cgroup_from_bio(struct bio *bio)
+{
+	struct page_cgroup *pc;
+	struct bio_cgroup *biocg = NULL;
+	struct page *page = bio_iovec_idx(bio, 0)->bv_page;
+
+	lock_page_cgroup(page);
+	pc = page_get_page_cgroup(page);
+	if (pc)
+		biocg = pc->bio_cgroup;
+	if (!biocg)
+		biocg = bio_cgroup_from_task(rcu_dereference(init_mm.owner));
+	unlock_page_cgroup(page);
+	return biocg;
+}
+
+static struct cgroup_subsys_state * bio_cgroup_create(struct cgroup_subsys *ss,
+							 struct cgroup *cgrp)
+{
+	struct bio_cgroup *biocg;
+	int error;
+
+	if (!cgrp->parent) {
+		static struct bio_cgroup default_bio_cgroup;
+
+		biocg = &default_bio_cgroup;
+	} else {
+		biocg = kzalloc(sizeof(*biocg), GFP_KERNEL);
+		if (!biocg) {
+			error = -ENOMEM;
+			goto out;
+		}
+	}
+
+	/* Bind the cgroup to bio_cgroup object we just created */
+	biocg->css.cgroup = cgrp;
+	spin_lock_init(&biocg->biog_list_lock);
+	spin_lock_init(&biocg->page_list_lock);
+	/* Assign default shares */
+	biocg->shares = 1024;
+	INIT_LIST_HEAD(&biocg->bio_group_list);
+	INIT_LIST_HEAD(&biocg->page_list);
+
+	return &biocg->css;
+out:
+	kfree(biocg);
+	return ERR_PTR(error);
+}
+
+void free_biog_elements(struct bio_cgroup *biocg)
+{
+	unsigned long flags, flags1;
+	struct bio_group *biog = NULL;
+
+	spin_lock_irqsave(&biocg->biog_list_lock, flags);
+	while (1) {
+		if (list_empty(&biocg->bio_group_list))
+			goto out;
+
+		list_for_each_entry(biog, &biocg->bio_group_list, next) {
+			spin_lock_irqsave(&biog->bio_group_lock, flags1);
+			if (!atomic_read(&biog->refcnt)) {
+				list_del(&biog->next);
+				BUG_ON(bio_group_on_queue(biog));
+				spin_unlock_irqrestore(&biog->bio_group_lock,
+								flags1);
+				kfree(biog);
+				break;
+			} else {
+				/* Drop the locks and schedule out. */
+				spin_unlock_irqrestore(&biog->bio_group_lock,
+								flags1);
+				spin_unlock_irqrestore(&biocg->biog_list_lock,
+								flags);
+				msleep(1);
+
+				/* Re-acquire the lock */
+				spin_lock_irqsave(&biocg->biog_list_lock,
+							flags);
+				break;
+			}
+		}
+	}
+
+out:
+	spin_unlock_irqrestore(&biocg->biog_list_lock, flags);
+	return;
+}
+
+void free_bio_cgroup(struct bio_cgroup *biocg)
+{
+	free_biog_elements(biocg);
+}
+
+static void __clear_bio_cgroup(struct page_cgroup *pc)
+{
+	struct bio_cgroup *biocg = pc->bio_cgroup;
+	pc->bio_cgroup = NULL;
+	/* Respective bio group got deleted hence reference to
+	 * bio cgroup removed from page during force empty. But page
+	 * is being freed now. Igonore it. */
+	if (!biocg)
+		return;
+	put_bio_cgroup(biocg);
+}
+
+void clear_bio_cgroup(struct page_cgroup *pc)
+{
+	__clear_bio_cgroup(pc);
+}
+
+#define FORCE_UNCHARGE_BATCH	(128)
+void bio_cgroup_force_empty(struct bio_cgroup *biocg)
+{
+	struct page_cgroup *pc;
+	struct page *page;
+	int count = FORCE_UNCHARGE_BATCH;
+	struct list_head *list = &biocg->page_list;
+	unsigned long flags;
+
+	spin_lock_irqsave(&biocg->page_list_lock, flags);
+	while (!list_empty(list)) {
+		pc = list_entry(list->prev, struct page_cgroup, blist);
+		page = pc->page;
+		get_page(page);
+		__bio_cgroup_remove_page(pc);
+		__clear_bio_cgroup(pc);
+		spin_unlock_irqrestore(&biocg->page_list_lock, flags);
+		put_page(page);
+		if (--count <= 0) {
+			count = FORCE_UNCHARGE_BATCH;
+			cond_resched();
+		}
+		spin_lock_irqsave(&biocg->page_list_lock, flags);
+	}
+	spin_unlock_irqrestore(&biocg->page_list_lock, flags);
+	/* Now free up all the bio groups releated to cgroup */
+	free_bio_cgroup(biocg);
+	return;
+}
+
+static void bio_cgroup_pre_destroy(struct cgroup_subsys *ss,
+						struct cgroup *cgrp)
+{
+	struct bio_cgroup *biocg = cgroup_bio(cgrp);
+	bio_cgroup_force_empty(biocg);
+}
+
+static void bio_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct bio_cgroup *biocg = cgroup_bio(cgrp);
+	kfree(biocg);
+}
+
+static u64 bio_shares_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct bio_cgroup *biog = cgroup_bio(cgrp);
+
+	return (u64) biog->shares;
+}
+
+static int bio_shares_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
+{
+	struct bio_cgroup *biog = cgroup_bio(cgrp);
+
+	biog->shares = val;
+	return 0;
+}
+
+static u64 bio_aggregate_tokens_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct bio_cgroup *biocg = cgroup_bio(cgrp);
+
+	return (u64) biocg->aggregate_tokens;
+}
+
+static int bio_aggregate_tokens_write(struct cgroup *cgrp, struct cftype *cft,
+						u64 val)
+{
+	struct bio_cgroup *biocg = cgroup_bio(cgrp);
+
+	biocg->aggregate_tokens = val;
+	return 0;
+}
+
+static u64 bio_jiffies_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct bio_cgroup *biocg = cgroup_bio(cgrp);
+
+	return (u64) biocg->jiffies;
+}
+
+static u64 bio_nr_off_the_tree_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct bio_cgroup *biocg = cgroup_bio(cgrp);
+
+	return (u64) biocg->nr_off_the_tree;
+}
+
+static int bio_nr_off_the_tree_write(struct cgroup *cgrp, struct cftype *cft,
+						u64 val)
+{
+	struct bio_cgroup *biocg = cgroup_bio(cgrp);
+
+	biocg->nr_off_the_tree = val;
+	return 0;
+}
+
+static u64 bio_nr_token_slices_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct bio_cgroup *biocg = cgroup_bio(cgrp);
+
+	return (u64) biocg->nr_token_slices;
+}
+
+static int bio_nr_token_slices_write(struct cgroup *cgrp,
+						struct cftype *cft, u64 val)
+{
+	struct bio_cgroup *biocg = cgroup_bio(cgrp);
+
+	biocg->nr_token_slices = val;
+	return 0;
+}
+
+
+
+static struct cftype bio_files[] = {
+	{
+		.name = "shares",
+		.read_u64 = bio_shares_read,
+		.write_u64 = bio_shares_write,
+	},
+	{
+		.name = "aggregate_tokens",
+		.read_u64 = bio_aggregate_tokens_read,
+		.write_u64 = bio_aggregate_tokens_write,
+	},
+	{
+		.name = "jiffies",
+		.read_u64 = bio_jiffies_read,
+	},
+	{
+		.name = "nr_off_the_tree",
+		.read_u64 = bio_nr_off_the_tree_read,
+		.write_u64 = bio_nr_off_the_tree_write,
+	},
+	{
+		.name = "nr_token_slices",
+		.read_u64 = bio_nr_token_slices_read,
+		.write_u64 = bio_nr_token_slices_write,
+	},
+};
+
+static int bio_cgroup_populate(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	if (bio_cgroup_disabled())
+		return 0;
+	return cgroup_add_files(cont, ss, bio_files, ARRAY_SIZE(bio_files));
+}
+
+static void bio_cgroup_move_task(struct cgroup_subsys *ss,
+				struct cgroup *cont,
+				struct cgroup *old_cont,
+				struct task_struct *p)
+{
+	/* do nothing */
+}
+
+
+struct cgroup_subsys bio_cgroup_subsys = {
+	.name           = "bio",
+	.subsys_id      = bio_cgroup_subsys_id,
+	.create         = bio_cgroup_create,
+	.destroy        = bio_cgroup_destroy,
+	.pre_destroy	= bio_cgroup_pre_destroy,
+	.populate       = bio_cgroup_populate,
+	.attach		= bio_cgroup_move_task,
+	.early_init	= 0,
+};
Index: linux17/include/linux/biocontrol.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux17/include/linux/biocontrol.h	2008-11-05 18:12:44.000000000 -0500
@@ -0,0 +1,174 @@
+#include <linux/cgroup.h>
+#include <linux/mm.h>
+#include <linux/memcontrol.h>
+#include <linux/blkdev.h>
+#include "../../drivers/md/dm-bio-list.h"
+
+#ifndef _LINUX_BIOCONTROL_H
+#define _LINUX_BIOCONTROL_H
+
+#ifdef	CONFIG_CGROUP_BIO
+
+struct io_context;
+struct block_device;
+
+struct bio_cgroup {
+	struct cgroup_subsys_state css;
+	/* Share/weight of the cgroup */
+	unsigned long		shares;
+
+	/* list of bio-groups associated with this cgroup. */
+	struct list_head	bio_group_list;
+	spinlock_t		biog_list_lock;
+
+	/* list of pages associated with this bio cgroup */
+	spinlock_t		page_list_lock;
+	struct list_head	page_list;
+
+	/* Debug Aid */
+	unsigned long 		aggregate_tokens;
+	unsigned long 		jiffies;
+	unsigned long 		nr_off_the_tree;
+	unsigned long 		nr_token_slices;
+};
+
+static inline int bio_cgroup_disabled(void)
+{
+	return bio_cgroup_subsys.disabled;
+}
+
+static inline struct bio_cgroup *bio_cgroup_from_task(struct task_struct *p)
+{
+	return container_of(task_subsys_state(p, bio_cgroup_subsys_id),
+				struct bio_cgroup, css);
+}
+
+static inline void get_bio_cgroup(struct bio_cgroup *biocg)
+{
+	css_get(&biocg->css);
+}
+
+static inline void put_bio_cgroup(struct bio_cgroup *biocg)
+{
+	css_put(&biocg->css);
+}
+
+static inline void set_bio_cgroup(struct page_cgroup *pc,
+					struct bio_cgroup *biog)
+{
+	pc->bio_cgroup = biog;
+}
+
+static inline struct bio_cgroup *get_bio_page_cgroup(struct page_cgroup *pc)
+{
+	struct bio_cgroup *biog = pc->bio_cgroup;
+	get_bio_cgroup(biog);
+	return biog;
+}
+
+/* This sould be called in an RCU-protected section. */
+static inline struct bio_cgroup *mm_get_bio_cgroup(struct mm_struct *mm)
+{
+	struct bio_cgroup *biog;
+	biog = bio_cgroup_from_task(rcu_dereference(mm->owner));
+	get_bio_cgroup(biog);
+	return biog;
+}
+
+static inline void __bio_cgroup_add_page(struct page_cgroup *pc)
+{
+	struct bio_cgroup *biocg = pc->bio_cgroup;
+	list_add(&pc->blist, &biocg->page_list);
+}
+
+static inline void bio_cgroup_add_page(struct page_cgroup *pc)
+{
+	struct bio_cgroup *biocg = pc->bio_cgroup;
+	unsigned long flags;
+	spin_lock_irqsave(&biocg->page_list_lock, flags);
+	__bio_cgroup_add_page(pc);
+	spin_unlock_irqrestore(&biocg->page_list_lock, flags);
+}
+
+static inline void __bio_cgroup_remove_page(struct page_cgroup *pc)
+{
+	list_del_init(&pc->blist);
+}
+
+static inline void bio_cgroup_remove_page(struct page_cgroup *pc)
+{
+	struct bio_cgroup *biocg = pc->bio_cgroup;
+	unsigned long flags;
+
+	/* Respective bio group got deleted hence reference to
+	 * bio cgroup removed from page during force empty. But page
+	 * is being freed now. Igonore it. */
+	if (!biocg)
+		return;
+	spin_lock_irqsave(&biocg->page_list_lock, flags);
+	__bio_cgroup_remove_page(pc);
+	spin_unlock_irqrestore(&biocg->page_list_lock, flags);
+}
+
+extern void clear_bio_cgroup(struct page_cgroup *pc);
+
+extern int bio_group_controller(struct request_queue *q, struct bio *bio);
+extern void blk_biogroup_work(struct work_struct *work);
+#else	/* CONFIG_CGROUP_BIO */
+
+struct bio_cgroup;
+
+static inline int bio_cgroup_disabled(void)
+{
+	return 1;
+}
+
+static inline void get_bio_cgroup(struct bio_cgroup *biocg)
+{
+}
+
+static inline void put_bio_cgroup(struct bio_cgroup *biocg)
+{
+}
+
+static inline void set_bio_cgroup(struct page_cgroup *pc,
+					struct bio_cgroup *biog)
+{
+}
+
+static inline void clear_bio_cgroup(struct page_cgroup *pc)
+{
+}
+
+static inline struct bio_cgroup *get_bio_page_cgroup(struct page_cgroup *pc)
+{
+	return NULL;
+}
+
+static inline struct bio_cgroup *mm_get_bio_cgroup(struct mm_struct *mm)
+{
+	return NULL;
+}
+
+static inline void bio_cgroup_add_page(struct page_cgroup *pc)
+{
+	return;
+}
+
+static inline void bio_cgroup_remove_page(struct page_cgroup *pc)
+{
+	return;
+}
+
+static inline int bio_group_controller(struct request_queue *q, struct bio *bio)
+{
+	return 0;
+}
+static inline void blk_biogroup_work(struct work_struct *work)
+{
+}
+
+
+#endif	/* CONFIG_CGROUP_BIO */
+
+#endif /* _LINUX_BIOCONTROL_H */
Index: linux17/mm/Makefile
===================================================================
--- linux17.orig/mm/Makefile	2008-10-09 18:13:53.000000000 -0400
+++ linux17/mm/Makefile	2008-11-05 18:12:32.000000000 -0500
@@ -34,4 +34,5 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_CGROUP_BIO) += biocontrol.o
 
Index: linux17/mm/memcontrol.c
===================================================================
--- linux17.orig/mm/memcontrol.c	2008-10-09 18:13:53.000000000 -0400
+++ linux17/mm/memcontrol.c	2008-11-05 18:12:32.000000000 -0500
@@ -32,6 +32,7 @@
 #include <linux/fs.h>
 #include <linux/seq_file.h>
 #include <linux/vmalloc.h>
+#include <linux/biocontrol.h>
 
 #include <asm/uaccess.h>
 
@@ -144,30 +145,6 @@ struct mem_cgroup {
 };
 static struct mem_cgroup init_mem_cgroup;
 
-/*
- * We use the lower bit of the page->page_cgroup pointer as a bit spin
- * lock.  We need to ensure that page->page_cgroup is at least two
- * byte aligned (based on comments from Nick Piggin).  But since
- * bit_spin_lock doesn't actually set that lock bit in a non-debug
- * uniprocessor kernel, we should avoid setting it here too.
- */
-#define PAGE_CGROUP_LOCK_BIT 	0x0
-#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
-#define PAGE_CGROUP_LOCK 	(1 << PAGE_CGROUP_LOCK_BIT)
-#else
-#define PAGE_CGROUP_LOCK	0x0
-#endif
-
-/*
- * A page_cgroup page is associated with every page descriptor. The
- * page_cgroup helps us identify information about the cgroup
- */
-struct page_cgroup {
-	struct list_head lru;		/* per cgroup LRU list */
-	struct page *page;
-	struct mem_cgroup *mem_cgroup;
-	int flags;
-};
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
 #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
 
@@ -278,21 +255,6 @@ struct page_cgroup *page_get_page_cgroup
 	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
 }
 
-static void lock_page_cgroup(struct page *page)
-{
-	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
-static int try_lock_page_cgroup(struct page *page)
-{
-	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
-static void unlock_page_cgroup(struct page *page)
-{
-	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
 static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
 			struct page_cgroup *pc)
 {
@@ -535,14 +497,15 @@ unsigned long mem_cgroup_isolate_pages(u
  * < 0 if the cgroup is over its limit
  */
 static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
-				gfp_t gfp_mask, enum charge_type ctype,
-				struct mem_cgroup *memcg)
+			gfp_t gfp_mask, enum charge_type ctype,
+			struct mem_cgroup *memcg, struct bio_cgroup *biocg)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
 	unsigned long flags;
 	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup_per_zone *mz;
+	struct bio_cgroup *biocg_temp;
 
 	pc = kmem_cache_alloc(page_cgroup_cache, gfp_mask);
 	if (unlikely(pc == NULL))
@@ -572,6 +535,10 @@ static int mem_cgroup_charge_common(stru
 		css_get(&memcg->css);
 	}
 
+	rcu_read_lock();
+	biocg_temp = biocg ? biocg : mm_get_bio_cgroup(mm);
+	rcu_read_unlock();
+
 	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
 		if (!(gfp_mask & __GFP_WAIT))
 			goto out;
@@ -597,6 +564,7 @@ static int mem_cgroup_charge_common(stru
 
 	pc->mem_cgroup = mem;
 	pc->page = page;
+	set_bio_cgroup(pc, biocg_temp);
 	/*
 	 * If a page is accounted as a page cache, insert to inactive list.
 	 * If anon, insert to active list.
@@ -611,21 +579,22 @@ static int mem_cgroup_charge_common(stru
 		unlock_page_cgroup(page);
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
+		clear_bio_cgroup(pc);
 		kmem_cache_free(page_cgroup_cache, pc);
 		goto done;
 	}
 	page_assign_page_cgroup(page, pc);
-
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_add_list(mz, pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
-
+	bio_cgroup_add_page(pc);
 	unlock_page_cgroup(page);
 done:
 	return 0;
 out:
 	css_put(&mem->css);
+	put_bio_cgroup(biocg_temp);
 	kmem_cache_free(page_cgroup_cache, pc);
 err:
 	return -ENOMEM;
@@ -648,7 +617,7 @@ int mem_cgroup_charge(struct page *page,
 	if (unlikely(!mm))
 		mm = &init_mm;
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
+				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL, NULL);
 }
 
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
@@ -684,7 +653,7 @@ int mem_cgroup_cache_charge(struct page 
 		mm = &init_mm;
 
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
+				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL, NULL);
 }
 
 /*
@@ -720,14 +689,14 @@ __mem_cgroup_uncharge_common(struct page
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_remove_list(mz, pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
-
+	bio_cgroup_remove_page(pc);
 	page_assign_page_cgroup(page, NULL);
 	unlock_page_cgroup(page);
 
 	mem = pc->mem_cgroup;
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
 	css_put(&mem->css);
-
+	clear_bio_cgroup(pc);
 	kmem_cache_free(page_cgroup_cache, pc);
 	return;
 unlock:
@@ -754,6 +723,7 @@ int mem_cgroup_prepare_migration(struct 
 	struct mem_cgroup *mem = NULL;
 	enum charge_type ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
 	int ret = 0;
+	struct bio_cgroup *biocg = NULL;
 
 	if (mem_cgroup_subsys.disabled)
 		return 0;
@@ -765,12 +735,15 @@ int mem_cgroup_prepare_migration(struct 
 		css_get(&mem->css);
 		if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
 			ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
+		biocg = get_bio_page_cgroup(pc);
 	}
 	unlock_page_cgroup(page);
 	if (mem) {
 		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
-			ctype, mem);
+			ctype, mem, biocg);
 		css_put(&mem->css);
+		if (biocg)
+			put_bio_cgroup(biocg);
 	}
 	return ret;
 }
Index: linux17/include/linux/memcontrol.h
===================================================================
--- linux17.orig/include/linux/memcontrol.h	2008-10-09 18:13:53.000000000 -0400
+++ linux17/include/linux/memcontrol.h	2008-11-05 18:12:32.000000000 -0500
@@ -17,16 +17,47 @@
  * GNU General Public License for more details.
  */
 
+#include <linux/bit_spinlock.h>
+#include <linux/mm_types.h>
+
 #ifndef _LINUX_MEMCONTROL_H
 #define _LINUX_MEMCONTROL_H
 
 struct mem_cgroup;
-struct page_cgroup;
 struct page;
 struct mm_struct;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
+/*
+ * We use the lower bit of the page->page_cgroup pointer as a bit spin
+ * lock.  We need to ensure that page->page_cgroup is at least two
+ * byte aligned (based on comments from Nick Piggin).  But since
+ * bit_spin_lock doesn't actually set that lock bit in a non-debug
+ * uniprocessor kernel, we should avoid setting it here too.
+ */
+#define PAGE_CGROUP_LOCK_BIT 	0x0
+#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
+#define PAGE_CGROUP_LOCK 	(1 << PAGE_CGROUP_LOCK_BIT)
+#else
+#define PAGE_CGROUP_LOCK	0x0
+#endif
+
+/*
+ * A page_cgroup page is associated with every page descriptor. The
+ * page_cgroup helps us identify information about the cgroup
+ */
+struct page_cgroup {
+	struct list_head lru;		/* per cgroup LRU list */
+	struct page *page;
+	struct mem_cgroup *mem_cgroup;
+	int flags;
+#ifdef CONFIG_CGROUP_BIO
+	struct list_head blist;		/* for bio_cgroup page list */
+	struct bio_cgroup *bio_cgroup;
+#endif
+};
+
 #define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
 
 extern struct page_cgroup *page_get_page_cgroup(struct page *page);
@@ -74,6 +105,20 @@ extern long mem_cgroup_calc_reclaim_acti
 extern long mem_cgroup_calc_reclaim_inactive(struct mem_cgroup *mem,
 				struct zone *zone, int priority);
 
+static inline void lock_page_cgroup(struct page *page)
+{
+	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+}
+
+static inline int try_lock_page_cgroup(struct page *page)
+{
+	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+}
+
+static inline void unlock_page_cgroup(struct page *page)
+{
+	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+}
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 static inline void page_reset_bad_cgroup(struct page *page)
 {

-- 
