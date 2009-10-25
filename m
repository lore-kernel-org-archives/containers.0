From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] c/r: do not hold mmap_sem while checkpointing vma's
Date: Sun, 25 Oct 2009 18:23:29 -0400
Message-ID: <1256509409-3866-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch modifies the memory checkpoint code to _not_ hold the
mmap_sem while dumping out the vma's.

The problem with holding the mmap_sem is that it first takes the
mmap_sem and then takes the file's inode semaphore. This violates the
normal locking order, e,g, when taking a page fault during a copyout,
which is inode sem and then the mmap_sem.

Normally this reverse locking order won't cause a lockup because a the
output file for the checkpoint image isn't used by the checkpointee.
However, there a couple of cases where it may be a problem, e.g. when
some async-IO happens to complete and triggers a page fault at the
wrong time.

This fixes complaints from the lockdep about this reverse ordering.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/memory.c |  133 ++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 94 insertions(+), 39 deletions(-)

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index 0da948f..656614c 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -644,11 +644,80 @@ static int anonymous_checkpoint(struct ckpt_ctx *ctx,
 	return private_vma_checkpoint(ctx, vma, CKPT_VMA_ANON, 0);
 }
 
+static int checkpoint_vmas(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct vm_area_struct *vma, *next;
+	int map_count = 0;
+	int ret = 0;
+
+	vma = kzalloc(sizeof(*vma), GFP_KERNEL);
+	if (!vma)
+		return -ENOMEM;
+
+	/*
+	 * Must not hold mm->mmap_sem when writing to image file, so
+	 * can't simply traverse the vma list. Instead, use find_vma()
+	 * to get the @next and make a local "copy" of it.
+	 */
+	while (1) {
+		down_read(&mm->mmap_sem);
+		next = find_vma(mm, vma->vm_end);
+		if (!next) {
+			up_read(&mm->mmap_sem);
+			break;
+		}
+		if (vma->vm_file)
+			fput(vma->vm_file);
+		*vma = *next;
+		if (vma->vm_file)
+			get_file(vma->vm_file);
+		up_read(&mm->mmap_sem);
+
+		map_count++;
+
+		ckpt_debug("vma %#lx-%#lx flags %#lx\n",
+			 vma->vm_start, vma->vm_end, vma->vm_flags);
+
+		if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
+			ckpt_write_err(ctx, "TE", "vma: bad flags (%#lx)\n",
+				       -ENOSYS, vma->vm_flags);
+			ret = -ENOSYS;
+			break;
+		}
+
+		if (!vma->vm_ops)
+			ret = anonymous_checkpoint(ctx, vma);
+		else if (vma->vm_ops->checkpoint)
+			ret = (*vma->vm_ops->checkpoint)(ctx, vma);
+		else
+			ret = -ENOSYS;
+		if (ret < 0) {
+			ckpt_write_err(ctx, "TE", "vma: failed", ret);
+			break;
+		}
+		/*
+		 * The file was collected, but not always checkpointed;
+		 * be safe and mark as visited to appease leak detection
+		 */
+		if (vma->vm_file && !(ctx->uflags & CHECKPOINT_SUBTREE)) {
+			ret = ckpt_obj_visit(ctx, vma->vm_file, CKPT_OBJ_FILE);
+			if (ret < 0)
+				break;
+		}
+	}
+
+	if (vma->vm_file)
+		fput(vma->vm_file);
+
+	kfree(vma);
+
+	return ret < 0 ? ret : map_count;
+}
+
 static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 {
 	struct ckpt_hdr_mm *h;
-	struct vm_area_struct *vma;
-	int exe_objref = 0;
+	struct file *exe_file = NULL;
 	int ret;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_MM);
@@ -674,14 +743,23 @@ static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 
 	h->map_count = mm->map_count;
 
-	/* checkpoint the ->exe_file */
-	if (mm->exe_file) {
-		exe_objref = checkpoint_obj(ctx, mm->exe_file, CKPT_OBJ_FILE);
-		if (exe_objref < 0) {
-			ret = exe_objref;
+	if (mm->exe_file) {  /* checkpoint the ->exe_file */
+		exe_file = mm->exe_file;
+		get_file(exe_file);
+	}
+
+	/*
+	 * Drop mm->mmap_sem before writing data to checkpoint image
+	 * to avoid reverse locking order (inode must come before mm).
+	 */
+	up_read(&mm->mmap_sem);
+
+	if (exe_file) {
+		h->exe_objref = checkpoint_obj(ctx, exe_file, CKPT_OBJ_FILE);
+		if (h->exe_objref < 0) {
+			ret = h->exe_objref;
 			goto out;
 		}
-		h->exe_objref = exe_objref;
 	}
 
 	ret = ckpt_write_obj(ctx, &h->h);
@@ -692,40 +770,17 @@ static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	if (ret < 0)
 		return ret;
 
-	/* write the vma's */
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		ckpt_debug("vma %#lx-%#lx flags %#lx\n",
-			 vma->vm_start, vma->vm_end, vma->vm_flags);
-		if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
-			ckpt_write_err(ctx, "TE", "vma: bad flags (%#lx)\n",
-				       -ENOSYS, vma->vm_flags);
-			return -ENOSYS;
-		}
-		if (!vma->vm_ops)
-			ret = anonymous_checkpoint(ctx, vma);
-		else if (vma->vm_ops->checkpoint)
-			ret = (*vma->vm_ops->checkpoint)(ctx, vma);
-		else
-			ret = -ENOSYS;
-		if (ret < 0) {
-			ckpt_write_err(ctx, "TE", "vma: failed", ret);
-			goto out;
-		}
-		/*
-		 * The file was collected, but not always checkpointed;
-		 * be safe and mark as visited to appease leak detection
-		 */
-		if (vma->vm_file && !(ctx->uflags & CHECKPOINT_SUBTREE)) {
-			ret = ckpt_obj_visit(ctx, vma->vm_file, CKPT_OBJ_FILE);
-			if (ret < 0)
-				goto out;
-		}
-	}
+	ret = checkpoint_vmas(ctx, mm);
+	if (ret != h->map_count && ret >= 0)
+		ret = -EBUSY; /* checkpoint mm leak */
+	if (ret < 0)
+		goto out;
 
 	ret = checkpoint_mm_context(ctx, mm);
  out:
+	if (exe_file)
+		fput(exe_file);
 	ckpt_hdr_put(ctx, h);
-	up_read(&mm->mmap_sem);
 	return ret;
 }
 
@@ -1288,9 +1343,9 @@ static struct mm_struct *do_restore_mm(struct ckpt_ctx *ctx)
 		}
 		set_mm_exe_file(mm, file);
 	}
+	up_write(&mm->mmap_sem);
 
 	ret = _ckpt_read_buffer(ctx, mm->saved_auxv, sizeof(mm->saved_auxv));
-	up_write(&mm->mmap_sem);
 	if (ret < 0)
 		goto out;
 
-- 
1.6.0.4
