From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 35/54] Support for share memory address spaces
Date: Tue, 28 Apr 2009 19:24:05 -0400
Message-ID: <1240961064-13991-36-git-send-email-orenl@cs.columbia.edu>
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

The task address space (task->mm) may be shared between processes if
CLONE_VM is used, and particularly among threads. Accordingly, treat
'task->mm' as a shared object: during checkpoint check against the
objhash and only dump the contents if seen for the first time. During
restart, likewise, only restore if it's a new instance, otherwise use
the one already registered in the objhash.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/memory.c            |   59 ++++++++++++++++++++++++++++++++++-----
 checkpoint/objhash.c           |   21 ++++++++++++++
 checkpoint/process.c           |   46 ++++++++++++++++++++++++++++---
 include/linux/checkpoint.h     |    7 +++-
 include/linux/checkpoint_hdr.h |    7 +++++
 5 files changed, 126 insertions(+), 14 deletions(-)

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index f5f8fcf..7a6e3f4 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -650,10 +650,9 @@ static int anonymous_checkpoint(struct ckpt_ctx *ctx,
 	return private_vma_checkpoint(ctx, vma, CKPT_VMA_ANON, 0);
 }
 
-int checkpoint_mm(struct ckpt_ctx *ctx, struct task_struct *t)
+static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 {
 	struct ckpt_hdr_mm *h;
-	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int exe_objref = 0;
 	int ret;
@@ -662,8 +661,6 @@ int checkpoint_mm(struct ckpt_ctx *ctx, struct task_struct *t)
 	if (!h)
 		return -ENOMEM;
 
-	mm = get_task_mm(t);
-
 	down_read(&mm->mmap_sem);
 
 	/* FIX: need also mm->flags */
@@ -715,10 +712,26 @@ int checkpoint_mm(struct ckpt_ctx *ctx, struct task_struct *t)
  out:
 	ckpt_hdr_put(ctx, h);
 	up_read(&mm->mmap_sem);
-	mmput(mm);
 	return ret;
 }
 
+int checkpoint_mm(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_mm(ctx, (struct mm_struct *) ptr);
+}
+
+int checkpoint_mm_obj(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct mm_struct *mm;
+	int objref;
+
+	mm = get_task_mm(t);
+	objref = checkpoint_obj(ctx, mm, CKPT_OBJ_MM);
+	mmput(mm);
+
+	return objref;
+}
+
 /*
  * Restart
  *
@@ -1120,7 +1133,7 @@ static int destroy_mm(struct mm_struct *mm)
 	return 0;
 }
 
-int restore_mm(struct ckpt_ctx *ctx)
+static struct mm_struct *do_restore_mm(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_mm *h;
 	struct mm_struct *mm;
@@ -1130,7 +1143,7 @@ int restore_mm(struct ckpt_ctx *ctx)
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_MM);
 	if (IS_ERR(h))
-		return PTR_ERR(h);
+		return (struct mm_struct *) h;
 
 	ckpt_debug("map_count %d\n", h->map_count);
 
@@ -1142,6 +1155,8 @@ int restore_mm(struct ckpt_ctx *ctx)
 		goto out;
 	if (h->exefile_objref < 0)
 		goto out;
+	if (h->map_count <= 0)
+		goto out;
 
 	mm = current->mm;
 
@@ -1191,5 +1206,33 @@ int restore_mm(struct ckpt_ctx *ctx)
 	ret = restore_mm_context(ctx, mm);
  out:
 	ckpt_hdr_put(ctx, h);
-	return ret;
+	return (ret < 0 ? ERR_PTR(ret) : mm);
 }
+
+void *restore_mm(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_mm(ctx);
+}
+
+int restore_mm_obj(struct ckpt_ctx *ctx, int mm_objref)
+{
+	struct mm_struct *mm;
+	int ret;
+
+	mm = ckpt_obj_fetch(ctx, mm_objref, CKPT_OBJ_MM);
+	if (!mm)
+		return -EINVAL;
+	else if (IS_ERR(mm))
+		return -EINVAL;
+
+	if (mm == current->mm)
+		return 0;
+
+	ret = exec_mmap(mm);
+	if (ret < 0)
+		return ret;
+
+	atomic_inc(&mm->mm_users);
+	return 0;
+}
+
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 8e43432..4fb5afa 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -57,6 +57,7 @@ void *restore_bad(struct ckpt_ctx *ctx)
  *   obj_no_{drop,grab}: for objects ignored/skipped
  *   obj_file_{drop,grab}: for file objects
  *   obj_inode_{drop,grab}: for inode objects
+ *   obj_mm_{drop,grab}: for mm_struct objects
  */
 
 static void obj_no_drop(void *ptr)
@@ -91,6 +92,17 @@ static void obj_inode_drop(void *ptr)
 	iput((struct inode *) ptr);
 }
 
+static int obj_mm_grab(void *ptr)
+{
+	atomic_inc(&((struct mm_struct *) ptr)->mm_users);
+	return 0;
+}
+
+static void obj_mm_drop(void *ptr)
+{
+	mmput((struct mm_struct *) ptr);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -117,6 +129,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_bad,	/* no c/r at inode level */
 		.restore = restore_bad,		/* no c/r at inode level */
 	},
+	/* mm object */
+	{
+		.obj_name = "MM",
+		.obj_type = CKPT_OBJ_MM,
+		.ref_drop = obj_mm_drop,
+		.ref_grab = obj_mm_grab,
+		.checkpoint = checkpoint_mm,
+		.restore = restore_mm,
+	},
 };
 
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index d5ee6fd..0bd4845 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -162,6 +162,28 @@ int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
+static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_task_objs *h;
+	int mm_objref;
+	int ret;
+
+	mm_objref = checkpoint_mm_obj(ctx, t);
+	ckpt_debug("memory: objref %d\n", mm_objref);
+	if (mm_objref < 0)
+		return mm_objref;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
+	if (!h)
+		return -ENOMEM;
+
+	h->mm_objref = mm_objref;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
 /* dump the entire state of a given task */
 int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 {
@@ -171,8 +193,8 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	ckpt_debug("ret %d\n", ret);
 	if (ret < 0)
 		goto out;
-	ret = checkpoint_mm(ctx, t);
-	ckpt_debug("memory: ret %d\n", ret);
+	ret = checkpoint_task_objs(ctx, t);
+	ckpt_debug("objs: ret %d\n", ret);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_fd_table(ctx, t);
@@ -322,6 +344,22 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int restore_task_objs(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task_objs *h;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, CKPT_HDR_TASK_OBJS, sizeof(*h));
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = restore_mm_obj(ctx, h->mm_objref);
+	ckpt_debug("memory: ret %d\n", ret);
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
 /* read the entire state of the current task */
 int restore_task(struct ckpt_ctx *ctx)
 {
@@ -331,8 +369,8 @@ int restore_task(struct ckpt_ctx *ctx)
 	ckpt_debug("ret %d\n", ret);
 	if (ret < 0)
 		goto out;
-	ret = restore_mm(ctx);
-	ckpt_debug("memory: ret %d\n", ret);
+	ret = restore_task_objs(ctx);
+	ckpt_debug("objs: ret %d\n", ret);
 	if (ret < 0)
 		goto out;
 	ret = restore_fd_table(ctx);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index a662ea7..d554776 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -90,8 +90,11 @@ extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 
 extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
 
-extern int checkpoint_mm(struct ckpt_ctx *ctx, struct task_struct *t);
-extern int restore_mm(struct ckpt_ctx *ctx);
+extern int checkpoint_mm(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_mm(struct ckpt_ctx *ctx);
+
+extern int checkpoint_mm_obj(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_mm_obj(struct ckpt_ctx *ctx, int objref);
 
 #define CKPT_VMA_NOT_SUPPORTED						\
 	(VM_IO | VM_HUGETLB | VM_NONLINEAR | VM_PFNMAP |		\
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 59fab62..8b00fb8 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -49,6 +49,7 @@ enum {
 
 	CKPT_HDR_TREE = 101,
 	CKPT_HDR_TASK,
+	CKPT_HDR_TASK_OBJS,
 	CKPT_HDR_RESTART_BLOCK,
 	CKPT_HDR_THREAD,
 	CKPT_HDR_CPU,
@@ -78,6 +79,7 @@ enum obj_type {
 	CKPT_OBJ_IGNORE = 0,
 	CKPT_OBJ_FILE,
 	CKPT_OBJ_INODE,
+	CKPT_OBJ_MM,
 	CKPT_OBJ_MAX
 };
 
@@ -139,6 +141,11 @@ struct ckpt_hdr_task {
 	__u32 task_comm_len;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_task_objs {
+	struct ckpt_hdr h;
+	__s32 mm_objref;
+} __attribute__((aligned(8)));
+
 /* (thread) restart blocks */
 struct ckpt_hdr_restart_block {
 	struct ckpt_hdr h;
-- 
1.5.4.3
