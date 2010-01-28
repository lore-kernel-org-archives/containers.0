From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 1/2] mm: move destroy_mm into mmap.c and remove len check
Date: Wed, 27 Jan 2010 22:21:37 -0600
Message-ID: <20100128042137.GA15723@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Break do_munmap into two pieces, so we can avoid the check
for > TASK_SIZE in destroy_mm(), when we trust the vmas are
proper.

Really I wonder whether we can pull a lot more out of the
fn used by destroy_mm: is there really a need to be looking
whether we need to split vmas?  We always send in one full
vma at a time, so maybe we should just be calling
detach_vmas_to_be_unmapped() and unmap_region() by hand?

this makes 32-bit tasks on x86-64 with COMPAT_VDSO work again.
It also gets us passed the munmap -EINVAL when restart_64
restarts a 32-bit image and unloads its own 64-bit vmas.

(But there is still a 

	ckpt[2446] general protection ip:ffffe42f sp:ffc9304c error:0

with that case)

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/memory.c |   18 ------------------
 include/linux/mm.h  |    1 +
 mm/mmap.c           |   38 ++++++++++++++++++++++++++++++++++----
 3 files changed, 35 insertions(+), 22 deletions(-)

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index f907b88..d51f94b 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -1205,24 +1205,6 @@ static int restore_vma(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	return ret;
 }
 
-static int destroy_mm(struct mm_struct *mm)
-{
-	struct vm_area_struct *vmnext = mm->mmap;
-	struct vm_area_struct *vma;
-	int ret;
-
-	while (vmnext) {
-		vma = vmnext;
-		vmnext = vmnext->vm_next;
-		ret = do_munmap(mm, vma->vm_start, vma->vm_end-vma->vm_start);
-		if (ret < 0) {
-			pr_warning("c/r: failed do_munmap (%d)\n", ret);
-			return ret;
-		}
-	}
-	return 0;
-}
-
 static struct mm_struct *do_restore_mm(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_mm *h;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index dc34b87..4485296 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1168,6 +1168,7 @@ out:
 }
 
 extern int do_munmap(struct mm_struct *, unsigned long, size_t);
+extern int destroy_mm(struct mm_struct *);
 
 extern unsigned long do_brk(unsigned long, unsigned long);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 0b2319f..15afae6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1890,14 +1890,11 @@ int split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
  * work.  This now handles partial unmappings.
  * Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>
  */
-int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
+int do_munmap_nocheck(struct mm_struct *mm, unsigned long start, size_t len)
 {
 	unsigned long end;
 	struct vm_area_struct *vma, *prev, *last;
 
-	if ((start & ~PAGE_MASK) || start > TASK_SIZE || len > TASK_SIZE-start)
-		return -EINVAL;
-
 	if ((len = PAGE_ALIGN(len)) == 0)
 		return -EINVAL;
 
@@ -1961,8 +1958,41 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	return 0;
 }
 
+int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
+{
+	unsigned long end;
+	struct vm_area_struct *vma, *prev, *last;
+
+	if ((start & ~PAGE_MASK) || start > TASK_SIZE || len > TASK_SIZE-start)
+		return -EINVAL;
+
+	return do_munmap_nocheck(mm, start, len);
+}
+
 EXPORT_SYMBOL(do_munmap);
 
+/*
+ * called with mm->mmap-sem held
+ * only called from checkpoint/memory.c:restore_mm()
+ */
+int destroy_mm(struct mm_struct *mm) {
+	struct vm_area_struct *vmnext = mm->mmap;
+	struct vm_area_struct *vma;
+	int ret;
+
+	while (vmnext) {
+		vma = vmnext;
+		vmnext = vmnext->vm_next;
+		ret = do_munmap_nocheck(mm, vma->vm_start,
+					vma->vm_end-vma->vm_start);
+		if (ret < 0) {
+			pr_warning("%s: failed munmap (%d)\n", __func__, ret);
+			return ret;
+		}
+	}
+	return 0;
+}
+
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 {
 	int ret;
-- 
1.6.0.6
