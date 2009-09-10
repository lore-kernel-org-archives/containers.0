From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] cr: add a few more ckpt_write_err()s
Date: Thu, 10 Sep 2009 17:33:44 -0500
Message-ID: <20090910223344.GA11718@us.ibm.com>
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

The main point is for new-comers to the checkpoint/restart tree to
be able to help us debug their otherwise mysterious checkpoint failures.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c |   28 +++++++++++++++++++++++-----
 checkpoint/files.c      |   37 ++++++++++++++++++++++++++++++-------
 checkpoint/memory.c     |   17 ++++++++++++++---
 3 files changed, 67 insertions(+), 15 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index c19f812..7beee08 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -295,6 +295,8 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	if (t->exit_state == EXIT_DEAD) {
 		pr_warning("c/r: task %d is EXIT_DEAD\n", task_pid_vnr(t));
+		__ckpt_write_err(ctx, "task %d (%s) in state EXIT_DEAD",
+				 task_pid_vnr(t), t->comm);
 		return -EAGAIN;
 	}
 
@@ -335,12 +337,21 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	rcu_read_lock();
 	nsproxy = task_nsproxy(t);
-	if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns)
+	if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns) {
+		__ckpt_write_err(ctx, "task %d (%s) in bad mnt_ns",
+				 task_pid_vnr(t), t->comm);
 		ret = -EPERM;
-	if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns)
+	}
+	if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns) {
+		__ckpt_write_err(ctx, "task %d (%s) in bad pid_ns",
+				 task_pid_vnr(t), t->comm);
 		ret = -EPERM;
-	if (nsproxy->net_ns != ctx->root_nsproxy->net_ns)
+	}
+	if (nsproxy->net_ns != ctx->root_nsproxy->net_ns) {
+		__ckpt_write_err(ctx, "task %d (%s) in bad net_ns",
+				 task_pid_vnr(t), t->comm);
 		ret = -EPERM;
+	}
 	rcu_read_unlock();
 
 	return ret;
@@ -629,8 +640,11 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
 	/* container init ? */
 	ctx->root_init = is_container_init(task);
 
-	if (!(ctx->uflags & CHECKPOINT_SUBTREE) && !ctx->root_init)
+	if (!(ctx->uflags & CHECKPOINT_SUBTREE) && !ctx->root_init) {
+		ckpt_write_err(ctx, "Task is not container init"
+			" and CHECKPOINT_SUBTREE was not specified");
 		return -EINVAL;  /* cleanup by ckpt_ctx_free() */
+	}
 
 	/* root vfs (FIX: WILL CHANGE with mnt-ns etc */
 	task_lock(ctx->root_task);
@@ -669,9 +683,12 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 		 * and then compare to the objects' real user counts.
 		 */
 		ret = collect_objects(ctx);
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_write_err(ctx, "Error %d collecting objects", ret);
 			goto out;
+		}
 		if (!ckpt_obj_contained(ctx)) {
+			ckpt_write_err(ctx, "Container had leaks");
 			ret = -EAGAIN;
 			goto out;
 		}
@@ -689,6 +706,7 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 
 	/* verify that all objects were indeed visited */
 	if (!ckpt_obj_visited(ctx)) {
+		ckpt_write_err(ctx, "Not all objects were visited");
 		ret = -EAGAIN;
 		goto out;
 	}
diff --git a/checkpoint/files.c b/checkpoint/files.c
index 204055b..d16916a 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -84,8 +84,11 @@ int checkpoint_fname(struct ckpt_ctx *ctx, struct path *path, struct path *root)
 	if (!IS_ERR(fname))
 		ret = ckpt_write_obj_type(ctx, fname, flen,
 					  CKPT_HDR_FILE_NAME);
-	else
+	else {
+		ckpt_write_err(ctx, "Error writing file name for %s\n",
+			path->dentry->d_name.name);
 		ret = PTR_ERR(fname);
+	}
 
 	kfree(buf);
 	return ret;
@@ -192,16 +195,23 @@ EXPORT_SYMBOL(generic_file_checkpoint);
 int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
 {
 	struct file *file = (struct file *) ptr;
+	int ret;
 
 	if (!file->f_op || !file->f_op->checkpoint) {
+		ckpt_write_err(ctx, "Unsupproted file type: %pS", file->f_op);
 		ckpt_debug("f_op lacks checkpoint handler: %pS\n", file->f_op);
 		return -EBADF;
 	}
 	if (d_unlinked(file->f_dentry)) {
+		ckpt_write_err(ctx, "Unlinked file: %s", file->f_dentry->d_name.name);
 		ckpt_debug("unlinked files are unsupported\n");
 		return -EBADF;
 	}
-	return file->f_op->checkpoint(ctx, file);
+	ret = file->f_op->checkpoint(ctx, file);
+	if (ret)
+		ckpt_write_err(ctx, "f_op->checkpoint returned %d for %s",
+			ret, file->f_dentry->d_name.name);
+	return ret;
 }
 
 /**
@@ -238,8 +248,10 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
 
 	/* sanity check (although this shouldn't happen) */
 	ret = -EBADF;
-	if (!file)
+	if (!file) {
+		ckpt_write_err(ctx, "File no longer exists?");
 		goto out;
+	}
 
 	/*
 	 * if seen first time, this will add 'file' to the objhash, keep
@@ -312,8 +324,10 @@ int checkpoint_obj_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
 	int objref;
 
 	files = get_files_struct(t);
-	if (!files)
+	if (!files) {
+		ckpt_write_err(ctx, "couldn't get files struct");
 		return -EBUSY;
+	}
 	objref = checkpoint_obj(ctx, files, CKPT_OBJ_FILE_TABLE);
 	put_files_struct(files);
 
@@ -332,8 +346,12 @@ int ckpt_collect_file(struct ckpt_ctx *ctx, struct file *file)
 	if (ret <= 0)
 		return ret;
 	/* if first time for this file (ret > 0), invoke ->collect() */
-	if (file->f_op->collect)
+	if (file->f_op->collect) {
 		ret = file->f_op->collect(ctx, file);
+		if (ret)
+			ckpt_write_err(ctx, "Error %d collecing file %s",
+				ret, file->f_dentry->d_name.name);
+	}
 	return ret;
 }
 
@@ -351,8 +369,10 @@ static int collect_file_desc(struct ckpt_ctx *ctx,
 		get_file(file);
 	rcu_read_unlock();
 
-	if (!file)
+	if (!file) {
+		ckpt_write_err(ctx, "Failed to get file");
 		return -EAGAIN;
+	}
 
 	ret = ckpt_collect_file(ctx, file);
 	fput(file);
@@ -392,8 +412,11 @@ int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
 	int ret;
 
 	files = get_files_struct(t);
-	if (!files)
+	if (!files) {
+		ckpt_write_err(ctx, "Could not get files struct task %d (%s)",
+				 task_pid_vnr(t), t->comm);
 		return -EBUSY;
+	}
 	ret = collect_file_table(ctx, files);
 	put_files_struct(files);
 
diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index 487efbd..a6bbd1f 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -556,6 +556,7 @@ int generic_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
 
 	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
 		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
+		ckpt_write_err(ctx, "unsupported VMA %#lx", vma->vm_flags);
 		return -ENOSYS;
 	}
 
@@ -645,6 +646,7 @@ static int anonymous_checkpoint(struct ckpt_ctx *ctx,
 	/* should be private anonymous ... verify that this is the case */
 	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
 		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
+		ckpt_write_err(ctx, "unsupported VMA %#lx", vma->vm_flags);
 		return -ENOSYS;
 	}
 
@@ -711,8 +713,11 @@ static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 			ret = (*vma->vm_ops->checkpoint)(ctx, vma);
 		else
 			ret = -ENOSYS;
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_write_err(ctx, "vma checkpoint returrned %d",
+				ret);
 			goto out;
+		}
 	}
 
 	ret = checkpoint_mm_context(ctx, mm);
@@ -758,15 +763,21 @@ static int collect_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	down_read(&mm->mmap_sem);
 	if (mm->exe_file) {
 		ret = ckpt_collect_file(ctx, mm->exe_file);
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_write_err(ctx, "Err %d collecting mm->exe_file",
+					ret);
 			goto out;
+		}
 	}
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		file = vma->vm_file;
 		if (file) {
 			ret = ckpt_collect_file(ctx, file);
-			if (ret < 0)
+			if (ret < 0) {
+				ckpt_write_err(ctx, "Err %d collecting vm_file",
+					ret);
 				break;
+			}
 		}
 	}
  out:
-- 
1.6.1
