From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 53/54] Detect resource leaks for whole-container
	checkpoint
Date: Tue, 28 Apr 2009 19:24:23 -0400
Message-ID: <1240961064-13991-54-git-send-email-orenl@cs.columbia.edu>
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

Add a 'users' count to objhash items, and, for a !CHECKPOINT_SUBTREE
checkpoint, return an error code if the actual objects' counts are
higher, indicating leaks (references to the objects from a task not
being checkpointed).  Of course, by this time most of the checkpoint
image has been written out to disk, so this is purely advisory.  But
then, it's probably naive to argue that anything more than an advisory
'this went wrong' error code is useful.

The comparison of the objhash user counts to object refcounts as a
basis for checking for leaks comes from Alexey's OpenVZ-based c/r
patchset.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c    |    8 +++
 checkpoint/memory.c        |    2 +
 checkpoint/objhash.c       |  108 +++++++++++++++++++++++++++++++++++++++----
 include/linux/checkpoint.h |    2 +
 4 files changed, 110 insertions(+), 10 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 4319976..32a0a8e 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -498,6 +498,14 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		goto out;
 
+	if (!(ctx->flags & CHECKPOINT_SUBTREE)) {
+		/* verify that all objects are contained (no leaks) */
+		if (!ckpt_obj_contained(ctx)) {
+			ret = -EBUSY;
+			goto out;
+		}
+	}
+
 	/* on success, return (unique) checkpoint identifier */
 	ctx->crid = atomic_inc_return(&ctx_count);
 	ret = ctx->crid;
diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index 7637c1e..5ae2b41 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -687,6 +687,8 @@ static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 			ret = exe_objref;
 			goto out;
 		}
+		/* account for all references through vma/exe_file */
+		ckpt_obj_users_inc(ctx, mm->exe_file, mm->num_exe_file_vmas);
 	}
 
 	h->exefile_objref = exe_objref;
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index bdc719e..11522b2 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -28,19 +28,23 @@ struct ckpt_obj_ops {
 	enum obj_type obj_type;
 	void (*ref_drop)(void *ptr);
 	int (*ref_grab)(void *ptr);
+	int (*ref_users)(void *ptr);
 	int (*checkpoint)(struct ckpt_ctx *ctx, void *ptr);
 	void *(*restore)(struct ckpt_ctx *ctx);
 };
 
 struct ckpt_obj {
+	int users;
 	int objref;
 	void *ptr;
 	struct ckpt_obj_ops *ops;
 	struct hlist_node hash;
+	struct hlist_node next;
 };
 
 struct ckpt_obj_hash {
 	struct hlist_head *head;
+	struct hlist_head list;
 	int next_free_objref;
 };
 
@@ -56,13 +60,13 @@ void *restore_bad(struct ckpt_ctx *ctx)
 
 /*
  * helper grab/drop functions:
- *   obj_no_{drop,grab}: for objects ignored/skipped
- *   obj_file_{drop,grab}: for file objects
- *   obj_inode_{drop,grab}: for inode objects
- *   obj_mm_{drop,grab}: for mm_struct objects
- *   obj_ns_{drop,grab}: for nsproxy objects
- *   obj_uts_ns_{drop,grab}: for uts_namespace objects
- *   obj_ipc_ns_{drop,grab}: for ipc_namespace objects
+ *   obj_no_{drop,grab,users}: for objects ignored/skipped
+ *   obj_file_{drop,grab,users}: for file objects
+ *   obj_inode_{drop,grab,users}: for inode objects
+ *   obj_mm_{drop,grab,users}: for mm_struct objects
+ *   obj_ns_{drop,grab,users}: for nsproxy objects
+ *   obj_uts_ns_{drop,grab,users}: for uts_namespace objects
+ *   obj_ipc_ns_{drop,grab,users}: for ipc_namespace objects
  */
 
 static void obj_no_drop(void *ptr)
@@ -75,7 +79,12 @@ static int obj_no_grab(void *ptr)
 	return 0;
 }
 
-/* helper drop/grab functions */
+
+/*
+ * helper drop/grab functions
+ */
+
+/* file object */
 static int obj_file_grab(void *ptr)
 {
 	get_file((struct file *) ptr);
@@ -87,6 +96,12 @@ static void obj_file_drop(void *ptr)
 	fput((struct file *) ptr);
 }
 
+static int obj_file_users(void *ptr)
+{
+	return atomic_long_read(&((struct file *) ptr)->f_count);
+}
+
+/* inode object */
 static int obj_inode_grab(void *ptr)
 {
 	return (igrab((struct inode *) ptr) ? 0 : -EBADF);
@@ -97,6 +112,7 @@ static void obj_inode_drop(void *ptr)
 	iput((struct inode *) ptr);
 }
 
+/* inode object */
 static int obj_mm_grab(void *ptr)
 {
 	atomic_inc(&((struct mm_struct *) ptr)->mm_users);
@@ -108,6 +124,12 @@ static void obj_mm_drop(void *ptr)
 	mmput((struct mm_struct *) ptr);
 }
 
+static int obj_mm_users(void *ptr)
+{
+	return atomic_read(&((struct mm_struct *) ptr)->mm_users);
+}
+
+/* nsproxy object */
 static int obj_ns_grab(void *ptr)
 {
 	get_nsproxy((struct nsproxy *) ptr);
@@ -119,6 +141,7 @@ static void obj_ns_drop(void *ptr)
 	put_nsproxy((struct nsproxy *) ptr);
 }
 
+/* uts_namespace object */
 static int obj_uts_ns_grab(void *ptr)
 {
 	get_uts_ns((struct uts_namespace *) ptr);
@@ -130,6 +153,12 @@ static void obj_uts_ns_drop(void *ptr)
 	put_uts_ns((struct uts_namespace *) ptr);
 }
 
+static int obj_uts_ns_users(void *ptr)
+{
+	return atomic_read(&((struct uts_namespace *) ptr)->kref.refcount);
+}
+
+/* ipc_namespace object */
 static int obj_ipc_ns_grab(void *ptr)
 {
 	get_ipc_ns((struct ipc_namespace *) ptr);
@@ -141,6 +170,11 @@ static void obj_ipc_ns_drop(void *ptr)
 	put_ipc_ns((struct ipc_namespace *) ptr);
 }
 
+static int obj_ipc_ns_users(void *ptr)
+{
+	return atomic_read(&((struct ipc_namespace *) ptr)->count);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -155,6 +189,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.obj_type = CKPT_OBJ_FILE,
 		.ref_drop = obj_file_drop,
 		.ref_grab = obj_file_grab,
+		.ref_users = obj_file_users,
 		.checkpoint = checkpoint_file,
 		.restore = restore_file,
 	},
@@ -173,6 +208,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.obj_type = CKPT_OBJ_MM,
 		.ref_drop = obj_mm_drop,
 		.ref_grab = obj_mm_grab,
+		.ref_users = obj_mm_users,
 		.checkpoint = checkpoint_mm,
 		.restore = restore_mm,
 	},
@@ -191,6 +227,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.obj_type = CKPT_OBJ_UTS_NS,
 		.ref_drop = obj_uts_ns_drop,
 		.ref_grab = obj_uts_ns_grab,
+		.ref_users = obj_uts_ns_users,
 		.checkpoint = checkpoint_bad,
 		.restore = restore_bad,
 	},
@@ -200,6 +237,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.obj_type = CKPT_OBJ_IPC_NS,
 		.ref_drop = obj_ipc_ns_drop,
 		.ref_grab = obj_ipc_ns_grab,
+		.ref_users = obj_ipc_ns_users,
 		.checkpoint = checkpoint_bad,
 		.restore = restore_bad,
 	},
@@ -252,6 +290,7 @@ int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx)
 
 	obj_hash->head = head;
 	obj_hash->next_free_objref = 1;
+	INIT_HLIST_HEAD(&obj_hash->list);
 
 	ctx->obj_hash = obj_hash;
 	return 0;
@@ -310,6 +349,7 @@ static int obj_new(struct ckpt_ctx *ctx, void *ptr, int objref,
 
 	obj->ptr = ptr;
 	obj->ops = ops;
+	obj->users = 2;  /* extra reference that objhash itself takes */
 
 	if (objref) {
 		/* use @obj->objref to index (restart) */
@@ -322,10 +362,12 @@ static int obj_new(struct ckpt_ctx *ctx, void *ptr, int objref,
 	}
 
 	ret = ops->ref_grab(obj->ptr);
-	if (ret < 0)
+	if (ret < 0) {
 		kfree(obj);
-	else
+	} else {
 		hlist_add_head(&obj->hash, &ctx->obj_hash->head[i]);
+		hlist_add_head(&obj->next, &ctx->obj_hash->list);
+	}
 
 	return (ret < 0 ? : obj->objref);
 }
@@ -363,6 +405,7 @@ int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 		return -EINVAL;
 	} else {
 		objref = obj->objref;
+		obj->users++;
 		*first = 0;
 	}
 
@@ -370,6 +413,50 @@ int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 	return objref;
 }
 
+/* increment the 'users' count of an object */
+void ckpt_obj_users_inc(struct ckpt_ctx *ctx, void *ptr, int increment)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_ptr(ctx, ptr);
+	if (obj)
+		obj->users += increment;
+}
+
+/**
+ * ckpt_obj_contained - test if shared objects are "contained" in checkpoint
+ * @ctx: checkpoint
+ *
+ * Loops through all objects in the table and compares the number of
+ * references accumulated during checkpoint, with the reference count
+ * reported by the kernel.
+ *
+ * Return 1 if respective counts match for all objects, 0 otherwise.
+ */
+int ckpt_obj_contained(struct ckpt_ctx *ctx)
+{
+	struct ckpt_obj *obj;
+	struct hlist_node *node;
+
+	/* account for ctx->file reference (if in the table already) */
+	ckpt_obj_users_inc(ctx, ctx->file, 1);
+
+	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
+		if (!obj->ops->ref_users)
+			continue;
+		if (obj->ops->ref_users(obj->ptr) != obj->users) {
+			ckpt_debug("usage leak: %s\n", obj->ops->obj_name);
+			printk(KERN_NOTICE "c/r: %s users %d != count %d\n",
+			       obj->ops->obj_name,
+			       obj->ops->ref_users(obj->ptr),
+			       obj->users);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
 /**
  * checkpoint_obj - if not already in hash, add object and checkpoint
  * @ctx: checkpoint context
@@ -399,6 +486,7 @@ int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 	obj = obj_find_by_ptr(ctx, ptr);
 	if (obj) {
 		BUG_ON(obj->ops->obj_type != type);
+		obj->users++;
 		return obj->objref;
 	}
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 65838b4..2a09244 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -48,10 +48,12 @@ extern int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx);
 
 extern int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h);
 extern int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type);
+extern int ckpt_obj_contained(struct ckpt_ctx *ctx);
 extern void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref,
 			    enum obj_type type);
 extern int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 			       enum obj_type type, int *first);
+extern void ckpt_obj_users_inc(struct ckpt_ctx *ctx, void *ptr, int increment);
 extern int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
 			   enum obj_type type);
 
-- 
1.5.4.3
