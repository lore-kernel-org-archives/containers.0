From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC] [-mm PATCH] Memory controller fix swap charging context in
	unuse_pte()
Date: Fri, 05 Oct 2007 09:44:06 +0530
Message-ID: <20071005041406.21236.88707.sendpatchset@balbir-laptop>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linux MM Mailing List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Found-by: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>

mem_cgroup_charge() in unuse_pte() is called under a lock, the pte_lock. That's
clearly incorrect, since we pass GFP_KERNEL to mem_cgroup_charge() for
allocation of page_cgroup.

This patch release the lock and reacquires the lock after the call to
mem_cgroup_charge().

Tested on a powerpc box by calling swapoff in the middle of a cgroup
running a workload that pushes pages to swap.

Signed-off-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 mm/swapfile.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff -puN mm/swapfile.c~memory-controller-fix-unuse-pte-charging mm/swapfile.c
--- linux-2.6.23-rc8/mm/swapfile.c~memory-controller-fix-unuse-pte-charging	2007-10-03 13:45:56.000000000 +0530
+++ linux-2.6.23-rc8-balbir/mm/swapfile.c	2007-10-05 08:49:54.000000000 +0530
@@ -507,11 +507,18 @@ unsigned int count_swap_pages(int type, 
  * just let do_wp_page work it out if a write is requested later - to
  * force COW, vm_page_prot omits write permission from any private vma.
  */
-static int unuse_pte(struct vm_area_struct *vma, pte_t *pte,
-		unsigned long addr, swp_entry_t entry, struct page *page)
+static int unuse_pte(struct vm_area_struct *vma, pte_t *pte, pmd_t *pmd,
+		unsigned long addr, swp_entry_t entry, struct page *page,
+		spinlock_t **ptl)
 {
-	if (mem_cgroup_charge(page, vma->vm_mm, GFP_KERNEL))
+	pte_unmap_unlock(pte - 1, *ptl);
+
+	if (mem_cgroup_charge(page, vma->vm_mm, GFP_KERNEL)) {
+		pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);
 		return -ENOMEM;
+	}
+
+	pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);
 
 	inc_mm_counter(vma->vm_mm, anon_rss);
 	get_page(page);
@@ -543,7 +550,8 @@ static int unuse_pte_range(struct vm_are
 		 * Test inline before going to call unuse_pte.
 		 */
 		if (unlikely(pte_same(*pte, swp_pte))) {
-			ret = unuse_pte(vma, pte++, addr, entry, page);
+			ret = unuse_pte(vma, pte++, pmd, addr, entry, page,
+					&ptl);
 			break;
 		}
 	} while (pte++, addr += PAGE_SIZE, addr != end);
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
