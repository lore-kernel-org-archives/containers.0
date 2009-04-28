From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 15/54] Record 'struct file' object instead of the
	file name for VMAs
Date: Tue, 28 Apr 2009 19:23:45 -0400
Message-ID: <1240961064-13991-16-git-send-email-orenl@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240961064-13991-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

The vma->vm_file can be an arbitrary file pointer, including one that
is in use by a process as well and provided originally via the mmap()
syscall.

Thus, when dumping the state of a VMA, save a file object instead
of only the file name. As with other file objects, if it's seen for
the first time it is dumped entirely, otherwise only the 'objref' is
saved. The restart logic updated accordingly.

(Also suggested by Alexey Dobriyan)

Changelog[v14]:
  - Introduce patch

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/memory.c            |   63 +++++++++++++++++++++++++++++++++-------
 include/linux/checkpoint.h     |    6 ++-
 include/linux/checkpoint_hdr.h |    4 +-
 mm/filemap.c                   |   22 ++++++--------
 mm/mmap.c                      |    2 +-
 5 files changed, 68 insertions(+), 29 deletions(-)

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index c725519..4fa634a 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -20,6 +20,7 @@
 #include <linux/mman.h>
 #include <linux/pagemap.h>
 #include <linux/mm_types.h>
+#include <linux/proc_fs.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -472,9 +473,10 @@ static int checkpoint_private_contents(struct ckpt_ctx *ctx,
  * @ctx: checkpoint context
  * @vma: vma object
  * @type: vma type
+ * @objref: vma object id
  */
-int generic_vma_checkpoint(struct ckpt_ctx *ctx,
-			   struct vm_area_struct *vma, enum vma_type type)
+int generic_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
+			   enum vma_type type, int vma_objref)
 {
 	struct ckpt_hdr_vma *h;
 	int ret;
@@ -492,6 +494,8 @@ int generic_vma_checkpoint(struct ckpt_ctx *ctx,
 		return -ENOMEM;
 
 	h->vma_type = type;
+	h->vma_objref = vma_objref;
+
 	h->vm_start = vma->vm_start;
 	h->vm_end = vma->vm_end;
 	h->vm_page_prot = pgprot_val(vma->vm_page_prot);
@@ -509,16 +513,17 @@ int generic_vma_checkpoint(struct ckpt_ctx *ctx,
  * @ctx: checkpoint context
  * @vma: vma object
  * @type: vma type
+ * @objref: vma object id
  */
 int private_vma_checkpoint(struct ckpt_ctx *ctx,
 			   struct vm_area_struct *vma,
-			   enum vma_type type)
+			   enum vma_type type, int vma_objref)
 {
 	int ret;
 
 	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
 
-	ret = generic_vma_checkpoint(ctx, vma, type);
+	ret = generic_vma_checkpoint(ctx, vma, type, vma_objref);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_private_contents(ctx, vma);
@@ -542,7 +547,7 @@ static int anonymous_checkpoint(struct ckpt_ctx *ctx,
 
 	BUG_ON(vma->vm_file);
 
-	return private_vma_checkpoint(ctx, vma, CKPT_VMA_ANON);
+	return private_vma_checkpoint(ctx, vma, CKPT_VMA_ANON, 0);
 }
 
 int checkpoint_mm(struct ckpt_ctx *ctx, struct task_struct *t)
@@ -550,6 +555,7 @@ int checkpoint_mm(struct ckpt_ctx *ctx, struct task_struct *t)
 	struct ckpt_hdr_mm *h;
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
+	int exe_objref = 0;
 	int ret;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_MM);
@@ -560,6 +566,8 @@ int checkpoint_mm(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	down_read(&mm->mmap_sem);
 
+	/* FIX: need also mm->flags */
+
 	h->start_code = mm->start_code;
 	h->end_code = mm->end_code;
 	h->start_data = mm->start_data;
@@ -574,10 +582,18 @@ int checkpoint_mm(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	h->map_count = mm->map_count;
 
-	/* FIX: need also mm->flags */
+	/* checkpoint the ->exe_file */
+	if (mm->exe_file) {
+		exe_objref = checkpoint_obj(ctx, mm->exe_file, CKPT_OBJ_FILE);
+		if (exe_objref < 0) {
+			ret = exe_objref;
+			goto out;
+		}
+	}
+
+	h->exefile_objref = exe_objref;
 
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
-	ckpt_hdr_put(ctx, h);
 	if (ret < 0)
 		goto out;
 
@@ -597,6 +613,7 @@ int checkpoint_mm(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	ret = checkpoint_mm_context(ctx, mm);
  out:
+	ckpt_hdr_put(ctx, h);
 	up_read(&mm->mmap_sem);
 	mmput(mm);
 	return ret;
@@ -795,6 +812,8 @@ static unsigned long generic_vma_restore(struct mm_struct *mm,
 
 	if (h->vm_end < h->vm_start)
 		return -EINVAL;
+	if (h->vma_objref < 0)
+		return -EINVAL;
 	if (h->vm_flags & CKPT_VMA_NOT_SUPPORTED)
 		return -ENOSYS;
 
@@ -906,12 +925,16 @@ static int restore_vma(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
-	ckpt_debug("vma %#lx-%#lx type %d\n", (unsigned long) h->vm_start,
-		 (unsigned long) h->vm_end, (int) h->vma_type);
+	ckpt_debug("vma %#lx-%#lx flags %#lx type %d vmaref %d\n",
+		 (unsigned long) h->vm_start, (unsigned long) h->vm_end,
+		 (unsigned long) h->vm_flags, (int) h->vma_type,
+		 (int) h->vma_objref);
 
 	ret = -EINVAL;
 	if (h->vm_end < h->vm_start)
 		goto out;
+	if (h->vma_objref < 0)
+		goto out;
 	if (h->vma_type >= CKPT_VMA_MAX)
 		goto out;
 
@@ -954,6 +977,7 @@ int restore_mm(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_mm *h;
 	struct mm_struct *mm;
+	struct file *file;
 	unsigned int nr;
 	int ret;
 
@@ -969,6 +993,8 @@ int restore_mm(struct ckpt_ctx *ctx)
 	if ((h->start_code > h->end_code) ||
 	    (h->start_data > h->end_data))
 		goto out;
+	if (h->exefile_objref < 0)
+		goto out;
 
 	mm = current->mm;
 
@@ -979,6 +1005,9 @@ int restore_mm(struct ckpt_ctx *ctx)
 		up_write(&mm->mmap_sem);
 		goto out;
 	}
+
+	/* FIX: need also mm->flags */
+
 	mm->start_code = h->start_code;
 	mm->end_code = h->end_code;
 	mm->start_data = h->start_data;
@@ -990,9 +1019,21 @@ int restore_mm(struct ckpt_ctx *ctx)
 	mm->arg_end = h->arg_end;
 	mm->env_start = h->env_start;
 	mm->env_end = h->env_end;
-	up_write(&mm->mmap_sem);
 
-	/* FIX: need also mm->flags */
+	/* restore the ->exe_file */
+	if (h->exefile_objref) {
+		file = ckpt_obj_fetch(ctx, h->exefile_objref, CKPT_OBJ_FILE);
+		if (!file)
+			file = ERR_PTR(-EINVAL);
+		if (IS_ERR(file)) {
+			up_write(&mm->mmap_sem);
+			ret = PTR_ERR(file);
+			goto out;
+		}
+		set_mm_exe_file(mm, file);
+	}
+
+	up_write(&mm->mmap_sem);
 
 	for (nr = h->map_count; nr; nr--) {
 		ret = restore_vma(ctx, mm);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 527a84f..dcc3840 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -63,10 +63,12 @@ extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
 
 extern int generic_vma_checkpoint(struct ckpt_ctx *ctx,
 				  struct vm_area_struct *vma,
-				  enum vma_type type);
+				  enum vma_type type,
+				  int vma_objref);
 extern int private_vma_checkpoint(struct ckpt_ctx *ctx,
 				  struct vm_area_struct *vma,
-				  enum vma_type type);
+				  enum vma_type type,
+				  int vma_objref);
 
 extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 			       struct file *file, struct ckpt_hdr_vma *h);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 7c87bf8..0045c22 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -126,7 +126,7 @@ struct ckpt_hdr_task {
 struct ckpt_hdr_mm {
 	struct ckpt_hdr h;
 	__u32 map_count;
-	__u32 _padding;
+	__u32 exefile_objref;	/* objref for the exefile */
 
 	__u64 start_code, end_code, start_data, end_data;
 	__u64 start_brk, brk, start_stack;
@@ -146,7 +146,7 @@ enum vma_type {
 struct ckpt_hdr_vma {
 	struct ckpt_hdr h;
 	__u32 vma_type;
-	__u32 _padding;
+	__u32 vma_objref;	/* for vma->vm_file */
 
 	__u64 vm_start;
 	__u64 vm_end;
diff --git a/mm/filemap.c b/mm/filemap.c
index f51b537..e515845 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1633,7 +1633,7 @@ EXPORT_SYMBOL(filemap_fault);
 static int filemap_checkpoint(struct ckpt_ctx *ctx,
 				  struct vm_area_struct *vma)
 {
-	int ret;
+	int vma_objref;
 
 	/* should be private anonymous ... verify that this is the case */
 	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
@@ -1643,12 +1643,12 @@ static int filemap_checkpoint(struct ckpt_ctx *ctx,
 
 	BUG_ON(!vma->vm_file);
 
-	ret = checkpoint_file(ctx, vma->vm_file);
-	if (ret < 0)
-		goto out;
-	ret = private_vma_checkpoint(ctx, vma, CKPT_VMA_FILE);
- out:
-	return ret;
+	/* checkpoint the file object first (will add to objhash) */
+	vma_objref = checkpoint_obj(ctx, vma->vm_file, CKPT_OBJ_FILE);
+	if (vma_objref < 0)
+		return vma_objref;
+
+	return  private_vma_checkpoint(ctx, vma, CKPT_VMA_FILE, vma_objref);
 }
 
 int filemap_restore(struct ckpt_ctx *ctx,
@@ -1656,16 +1656,12 @@ int filemap_restore(struct ckpt_ctx *ctx,
 		    struct ckpt_hdr_vma *h)
 {
 	struct file *file;
-	int ret;
 
-	file = restore_file(ctx);
+	file = ckpt_obj_fetch(ctx, h->vma_objref, CKPT_OBJ_FILE);
 	if (IS_ERR(file))
 		return PTR_ERR(file);
 
-	ret = private_vma_restore(ctx, mm, file, h);
-
-	fput(file);
-	return ret;
+	return private_vma_restore(ctx, mm, file, h);
 }
 #else
 #define filemap_checkpoint NULL
diff --git a/mm/mmap.c b/mm/mmap.c
index 3b6356c..0c65512 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2300,7 +2300,7 @@ static int special_mapping_checkpoint(struct ckpt_ctx *ctx,
 	if (!name || strcmp(name, "[vdso]"))
 		return -ENOSYS;
 
-	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_VDSO);
+	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_VDSO, 0);
 }
 
 int special_mapping_restore(struct ckpt_ctx *ctx,
-- 
1.5.4.3
