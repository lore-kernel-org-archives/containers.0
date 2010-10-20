From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 04/11] checkpoint: introduce device vma type
Date: Wed, 20 Oct 2010 13:56:39 -0500
Message-ID: <1287601006-13794-5-git-send-email-ntl@pobox.com>
References: <1287601006-13794-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1287601006-13794-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This is intended to be used by drivers that allow userspace to map
hardware resources via mmap(2).  The mapping is restored but we don't
worry about the contents.  This is pretty much how we treat shared
file mappings, where it is the user's responsibility to ensure file
(device) availability and integrity for restart.  I think this is a
reasonable approach for the timer implementations in drivers/char as
well as the bsr driver (for which a patch follows).

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/checkpoint.h     |    3 ++-
 include/linux/checkpoint_hdr.h |    2 ++
 mm/checkpoint.c                |   37 +++++++++++++++++++++++++++++++++++++
 3 files changed, 41 insertions(+), 1 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 49cf01e..a02f27a 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -290,7 +290,8 @@ extern int shmem_vma_checkpoint(struct ckpt_ctx *ctx,
 				struct vm_area_struct *vma,
 				enum vma_type type,
 				int ino_objref);
-
+extern int device_vma_checkpoint(struct ckpt_ctx *ctx,
+				 struct vm_area_struct *vma);
 extern int checkpoint_obj_mm(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_obj_mm(struct ckpt_ctx *ctx, int mm_objref);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 049bb82..6a3e309 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -914,6 +914,8 @@ enum vma_type {
 #define CKPT_VMA_SHM_IPC CKPT_VMA_SHM_IPC
 	CKPT_VMA_SHM_IPC_SKIP,	/* shared sysvipc (skip contents) */
 #define CKPT_VMA_SHM_IPC_SKIP CKPT_VMA_SHM_IPC_SKIP
+	CKPT_VMA_DEVICE,	/* c/r mapping only, skip contents */
+#define CKPT_VMA_DEVICE CKPT_VMA_DEVICE
 	CKPT_VMA_MAX,
 #define CKPT_VMA_MAX CKPT_VMA_MAX
 };
diff --git a/mm/checkpoint.c b/mm/checkpoint.c
index c30a195..38c8b1f 100644
--- a/mm/checkpoint.c
+++ b/mm/checkpoint.c
@@ -591,6 +591,20 @@ static int anonymous_checkpoint(struct ckpt_ctx *ctx,
 	return private_vma_checkpoint(ctx, vma, CKPT_VMA_ANON, 0);
 }
 
+int device_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
+{
+	int vma_objref;
+	int ret;
+
+        vma_objref = checkpoint_obj(ctx, vma->vm_file, CKPT_OBJ_FILE);
+        if (vma_objref < 0)
+                return vma_objref;
+
+	ret = generic_vma_checkpoint(ctx, vma, CKPT_VMA_DEVICE, vma_objref, 0);
+
+        return ret;
+}
+
 static int checkpoint_vmas(struct ckpt_ctx *ctx, struct mm_struct *mm)
 {
 	struct vm_area_struct *vma, *next;
@@ -1114,6 +1128,23 @@ static int bad_vma_restore(struct ckpt_ctx *ctx,
 	return -EINVAL;
 }
 
+static int device_vma_restore(struct ckpt_ctx *ctx,
+			      struct mm_struct *mm,
+			      struct ckpt_hdr_vma *h)
+{
+	unsigned long addr;
+	struct file *file;
+
+	file = ckpt_obj_fetch(ctx, h->vma_objref, CKPT_OBJ_FILE);
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+
+	addr = generic_vma_restore(mm, file, h);
+
+	return IS_ERR((void *)addr) ? PTR_ERR((void *)addr) : 0;
+}
+
+
 /* callbacks to restore vma per its type: */
 struct restore_vma_ops {
 	char *vma_name;
@@ -1180,6 +1211,12 @@ static struct restore_vma_ops restore_vma_ops[] = {
 		.vma_type = CKPT_VMA_SHM_IPC_SKIP,
 		.restore = ipcshm_restore,
 	},
+	/* device memory - restore mapping, not contents */
+	{
+		.vma_name = "DEVICE",
+		.vma_type = CKPT_VMA_DEVICE,
+		.restore = device_vma_restore,
+	},
 };
 
 /**
-- 
1.7.2.2
