From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] c/r: Un-blacklist VM_NORESERVE and VM_LOCKED
Date: Fri, 18 Jun 2010 17:49:35 -0400
Message-ID: <1276897775-4911-1-git-send-email-orenl@cs.columbia.edu>
References: <1276808838.6401.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1276808838.6401.6.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Add support for VM_NORESERVE and VM_LOCKED and remove them from
the blacklist of vm flags.

VM_NORESERVE: a vma with VM_NORESERVE may segv on a write under
low-memory, but reading it (as we do during checkpoint) is fine.

VM_LOCKED: this flag is now explicitly restored for a vma that had
this flag, using sys_mlock()

Original patch and reports by Nathan Lynch and Dan Smith.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/checkpoint.h |    2 +-
 mm/checkpoint.c            |   10 ++++++++++
 2 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index c338149..a796308 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -306,7 +306,7 @@ extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
 
 #define CKPT_VMA_NOT_SUPPORTED						\
 	(VM_IO | VM_HUGETLB | VM_NONLINEAR | VM_PFNMAP |		\
-	 VM_RESERVED | VM_NORESERVE | VM_HUGETLB | VM_NONLINEAR |	\
+	 VM_RESERVED | VM_HUGETLB | VM_NONLINEAR |	\
 	 VM_MAPPED_COPY | VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
 
 /* signals */
diff --git a/mm/checkpoint.c b/mm/checkpoint.c
index d1d0bcb..70300e8 100644
--- a/mm/checkpoint.c
+++ b/mm/checkpoint.c
@@ -24,6 +24,7 @@
 #include <linux/shm.h>
 #include <linux/proc_fs.h>
 #include <linux/swap.h>
+#include <linux/syscalls.h>
 #include <linux/checkpoint.h>
 
 /*
@@ -1018,6 +1019,8 @@ static unsigned long calc_map_flags_bits(unsigned long orig_vm_flags)
 		vm_flags |= MAP_SHARED;
 	else
 		vm_flags |= MAP_PRIVATE;
+	if (orig_vm_flags & VM_NORESERVE)
+		vm_flags |= MAP_NORESERVE;
 
 	return vm_flags;
 }
@@ -1034,6 +1037,7 @@ unsigned long generic_vma_restore(struct mm_struct *mm,
 {
 	unsigned long vm_size, vm_start, vm_flags, vm_prot, vm_pgoff;
 	unsigned long addr;
+	int ret;
 
 	if (h->vm_end < h->vm_start)
 		return -EINVAL;
@@ -1053,6 +1057,12 @@ unsigned long generic_vma_restore(struct mm_struct *mm,
 	ckpt_debug("size %#lx prot %#lx flag %#lx pgoff %#lx => %#lx\n",
 		 vm_size, vm_prot, vm_flags, vm_pgoff, addr);
 
+	if (h->vm_flags & VM_LOCKED && !IS_ERR((void *) addr)) {
+		ret = sys_mlock(addr, vm_size);
+		if (ret < 0)
+			addr = (unsigned long) ret;
+	}
+
 	return addr;
 }
 
-- 
1.7.0.4
