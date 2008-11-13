From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 7/8] bio-cgroup: Page tracking hooks
Date: Thu, 13 Nov 2008 12:15:07 +0900 (JST)
Message-ID: <20081113.121507.722554765817591488.ryov__14620.7447782674$1226546203$gmane$org@valinux.co.jp>
References: <20081113.121322.653026525707351102.ryov@valinux.co.jp>
	<20081113.121357.75173118738921642.ryov@valinux.co.jp>
	<20081113.121433.632868945383117577.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081113.121433.632868945383117577.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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
Cc: fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org
List-Id: containers.vger.kernel.org

This patch contains several hooks that let the bio-cgroup framework to know
which bio-group is the owner of a page before starting I/O against the page.

Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>

diff -dupr linux-2.6.28-rc2.bc2/fs/buffer.c linux-2.6.28-rc2/fs/buffer.c
--- linux-2.6.28-rc2.bc2/fs/buffer.c	2008-11-12 11:20:52.000000000 +0900
+++ linux-2.6.28-rc2/fs/buffer.c	2008-11-12 11:22:00.000000000 +0900
@@ -36,6 +36,7 @@
 #include <linux/buffer_head.h>
 #include <linux/task_io_accounting_ops.h>
 #include <linux/bio.h>
+#include <linux/biotrack.h>
 #include <linux/notifier.h>
 #include <linux/cpu.h>
 #include <linux/bitops.h>
@@ -779,6 +780,7 @@ static int __set_page_dirty(struct page 
 					BDI_RECLAIMABLE);
 			task_io_account_write(PAGE_CACHE_SIZE);
 		}
+		bio_cgroup_reset_owner_pagedirty(page, current->mm);
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 	}
diff -dupr linux-2.6.28-rc2.bc2/fs/direct-io.c linux-2.6.28-rc2/fs/direct-io.c
--- linux-2.6.28-rc2.bc2/fs/direct-io.c	2008-11-12 11:20:53.000000000 +0900
+++ linux-2.6.28-rc2/fs/direct-io.c	2008-11-12 11:22:00.000000000 +0900
@@ -33,6 +33,7 @@
 #include <linux/err.h>
 #include <linux/blkdev.h>
 #include <linux/buffer_head.h>
+#include <linux/biotrack.h>
 #include <linux/rwsem.h>
 #include <linux/uio.h>
 #include <asm/atomic.h>
@@ -799,6 +800,7 @@ static int do_direct_IO(struct dio *dio)
 			ret = PTR_ERR(page);
 			goto out;
 		}
+		bio_cgroup_reset_owner(page, current->mm);
 
 		while (block_in_page < blocks_per_page) {
 			unsigned offset_in_page = block_in_page << blkbits;
diff -dupr linux-2.6.28-rc2.bc2/mm/bounce.c linux-2.6.28-rc2/mm/bounce.c
--- linux-2.6.28-rc2.bc2/mm/bounce.c	2008-11-12 11:20:53.000000000 +0900
+++ linux-2.6.28-rc2/mm/bounce.c	2008-11-12 11:22:00.000000000 +0900
@@ -14,6 +14,7 @@
 #include <linux/hash.h>
 #include <linux/highmem.h>
 #include <linux/blktrace_api.h>
+#include <linux/biotrack.h>
 #include <asm/tlbflush.h>
 
 #define POOL_SIZE	64
@@ -204,6 +205,7 @@ static void __blk_queue_bounce(struct re
 		to->bv_len = from->bv_len;
 		to->bv_offset = from->bv_offset;
 		inc_zone_page_state(to->bv_page, NR_BOUNCE);
+		bio_cgroup_copy_owner(to->bv_page, page);
 
 		if (rw == WRITE) {
 			char *vto, *vfrom;
diff -dupr linux-2.6.28-rc2.bc2/mm/filemap.c linux-2.6.28-rc2/mm/filemap.c
--- linux-2.6.28-rc2.bc2/mm/filemap.c	2008-11-12 11:20:53.000000000 +0900
+++ linux-2.6.28-rc2/mm/filemap.c	2008-11-12 11:22:00.000000000 +0900
@@ -33,6 +33,7 @@
 #include <linux/cpuset.h>
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
+#include <linux/biotrack.h>
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
 #include "internal.h"
 
@@ -464,6 +465,7 @@ int add_to_page_cache_locked(struct page
 					gfp_mask & ~__GFP_HIGHMEM);
 	if (error)
 		goto out;
+	bio_cgroup_set_owner(page, current->mm);
 
 	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error == 0) {
diff -dupr linux-2.6.28-rc2.bc2/mm/Makefile linux-2.6.28-rc2/mm/Makefile
--- linux-2.6.28-rc2.bc2/mm/Makefile	2008-11-12 11:20:51.000000000 +0900
+++ linux-2.6.28-rc2/mm/Makefile	2008-11-12 11:22:00.000000000 +0900
@@ -36,4 +36,5 @@ obj-$(CONFIG_SMP) += allocpercpu.o cpu_a
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
 obj-$(CONFIG_CGROUP_PAGE) += page_cgroup.o
+obj-$(CONFIG_CGROUP_BIO) += biotrack.o
 obj-$(CONFIG_KMEMTRACE) += kmemtrace.o
diff -dupr linux-2.6.28-rc2.bc2/mm/memory.c linux-2.6.28-rc2/mm/memory.c
--- linux-2.6.28-rc2.bc2/mm/memory.c	2008-11-12 11:20:53.000000000 +0900
+++ linux-2.6.28-rc2/mm/memory.c	2008-11-12 11:22:00.000000000 +0900
@@ -51,6 +51,7 @@
 #include <linux/init.h>
 #include <linux/writeback.h>
 #include <linux/memcontrol.h>
+#include <linux/biotrack.h>
 #include <linux/mmu_notifier.h>
 
 #include <asm/pgalloc.h>
@@ -1915,6 +1916,7 @@ gotten:
 		 */
 		ptep_clear_flush_notify(vma, address, page_table);
 		SetPageSwapBacked(new_page);
+		bio_cgroup_set_owner(new_page, mm);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		page_add_new_anon_rmap(new_page, vma, address);
 
@@ -2354,6 +2356,7 @@ static int do_swap_page(struct mm_struct
 	flush_icache_page(vma, page);
 	set_pte_at(mm, address, page_table, pte);
 	page_add_anon_rmap(page, vma, address);
+	bio_cgroup_reset_owner(page, mm);
 	mem_cgroup_commit_charge_swapin(page, ptr);
 
 	swap_free(entry);
@@ -2416,6 +2419,7 @@ static int do_anonymous_page(struct mm_s
 		goto release;
 	inc_mm_counter(mm, anon_rss);
 	SetPageSwapBacked(page);
+	bio_cgroup_set_owner(page, mm);
 	lru_cache_add_active_or_unevictable(page, vma);
 	page_add_new_anon_rmap(page, vma, address);
 	set_pte_at(mm, address, page_table, entry);
@@ -2566,6 +2570,7 @@ static int __do_fault(struct mm_struct *
 		if (anon) {
 			inc_mm_counter(mm, anon_rss);
 			SetPageSwapBacked(page);
+			bio_cgroup_set_owner(page, mm);
 			lru_cache_add_active_or_unevictable(page, vma);
 			page_add_new_anon_rmap(page, vma, address);
 		} else {
diff -dupr linux-2.6.28-rc2.bc2/mm/page-writeback.c linux-2.6.28-rc2/mm/page-writeback.c
--- linux-2.6.28-rc2.bc2/mm/page-writeback.c	2008-11-12 11:20:53.000000000 +0900
+++ linux-2.6.28-rc2/mm/page-writeback.c	2008-11-12 11:22:00.000000000 +0900
@@ -23,6 +23,7 @@
 #include <linux/init.h>
 #include <linux/backing-dev.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/biotrack.h>
 #include <linux/blkdev.h>
 #include <linux/mpage.h>
 #include <linux/rmap.h>
@@ -1100,6 +1101,7 @@ int __set_page_dirty_nobuffers(struct pa
 						BDI_RECLAIMABLE);
 				task_io_account_write(PAGE_CACHE_SIZE);
 			}
+			bio_cgroup_reset_owner_pagedirty(page, current->mm);
 			radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 		}
diff -dupr linux-2.6.28-rc2.bc2/mm/swap_state.c linux-2.6.28-rc2/mm/swap_state.c
--- linux-2.6.28-rc2.bc2/mm/swap_state.c	2008-11-12 11:20:53.000000000 +0900
+++ linux-2.6.28-rc2/mm/swap_state.c	2008-11-12 11:22:00.000000000 +0900
@@ -17,6 +17,7 @@
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
+#include <linux/biotrack.h>
 
 #include <asm/pgtable.h>
 
@@ -305,6 +306,7 @@ struct page *read_swap_cache_async(swp_e
 		 */
 		__set_page_locked(new_page);
 		SetPageSwapBacked(new_page);
+		bio_cgroup_set_owner(new_page, current->mm);
 		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
 		if (likely(!err)) {
 			/*
