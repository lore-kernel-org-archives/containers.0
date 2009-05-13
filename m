From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] cr: fix ckpt_obj_fetch return values (v2)
Date: Wed, 13 May 2009 16:06:41 -0500
Message-ID: <20090513210641.GA22784@us.ibm.com>
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

Sorry for the noise, but here is a corrected version of my patch
from earlier today.

ckpt_obj_fetch returned ERR_PTR(error) on some failures, NULL on
others.  Not all of its callers were checking for NULL, which
would lead to NULL dereferences.

Return -EINVAL if the object is not in the hash table.  Fix up
pipe_file_restore to do the right thing.

Changelog: May 13: fix typo in ckpt_obj_fetch.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c   |    4 +---
 checkpoint/memory.c  |    6 +-----
 checkpoint/objhash.c |    2 +-
 checkpoint/process.c |    4 +---
 fs/pipe.c            |    9 ++++-----
 5 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index c6a946b..bc9944c 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -484,9 +484,7 @@ static int restore_fd_ent(struct ckpt_ctx *ctx)
 		goto out;
 
 	file = ckpt_obj_fetch(ctx, h->fd_objref, CKPT_OBJ_FILE);
-	if (!file)
-		goto out;
-	else if (IS_ERR(file)) {
+	if (IS_ERR(file)) {
 		ret = PTR_ERR(file);
 		goto out;
 	}
diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index 92d4485..5f2930f 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -1207,8 +1207,6 @@ static struct mm_struct *do_restore_mm(struct ckpt_ctx *ctx)
 	/* restore the ->exe_file */
 	if (h->exefile_objref) {
 		file = ckpt_obj_fetch(ctx, h->exefile_objref, CKPT_OBJ_FILE);
-		if (!file)
-			file = ERR_PTR(-EINVAL);
 		if (IS_ERR(file)) {
 			up_write(&mm->mmap_sem);
 			ret = PTR_ERR(file);
@@ -1246,9 +1244,7 @@ int restore_mm_obj(struct ckpt_ctx *ctx, int mm_objref)
 	int ret;
 
 	mm = ckpt_obj_fetch(ctx, mm_objref, CKPT_OBJ_MM);
-	if (!mm)
-		return -EINVAL;
-	else if (IS_ERR(mm))
+	if (IS_ERR(mm))
 		return -EINVAL;
 
 	if (mm == current->mm)
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 3a860aa..09364e2 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -575,7 +575,7 @@ void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
 
 	obj = obj_find_by_objref(ctx, objref);
 	if (!obj)
-		return NULL;
+		return ERR_PTR(-EINVAL);
 	ckpt_debug("%s ref %d\n", obj->ops->obj_name, obj->objref);
 	return (obj->ops->obj_type == type ? obj->ptr : ERR_PTR(-EINVAL));
 }
diff --git a/checkpoint/process.c b/checkpoint/process.c
index cf7a44a..1c36ae2 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -595,9 +595,7 @@ static int restore_ns_obj(struct ckpt_ctx *ctx, int ns_objref)
 	struct nsproxy *nsproxy;
 
 	nsproxy = ckpt_obj_fetch(ctx, ns_objref, CKPT_OBJ_NS);
-	if (!nsproxy)
-		return -EINVAL;
-	else if (IS_ERR(nsproxy))
+	if (IS_ERR(nsproxy))
 		return PTR_ERR(nsproxy);
 
 	if (nsproxy != task_nsproxy(current))
diff --git a/fs/pipe.c b/fs/pipe.c
index ab2de3c..b284dcb 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -982,14 +982,12 @@ struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 		return ERR_PTR(-EINVAL);
 
 	file = ckpt_obj_fetch(ctx, h->pipe_objref, CKPT_OBJ_FILE);
-	if (IS_ERR(file))
-		return file;
 	/*
-	 * If ckpt_obj_fetch() returned NULL, then this is the first
+	 * If ckpt_obj_fetch() returned -EINVAL, then this is the first
 	 * time we see this pipe so need to restore the contents.
 	 * Otherwise, use the file pointer skip forward.
 	 */
-	if (!file) {
+	if (PTR_ERR(file) == -EINVAL) {
 		/* first encounter of this pipe: create it */
 		ret = do_pipe_flags(fds, 0);
 		if (ret < 0)
@@ -1025,7 +1023,8 @@ struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 		/* get rid of the file descriptors (caller sets that) */
 		sys_close(fds[which]);
 		sys_close(fds[1-which]);
-	}
+	} else if (IS_ERR(file))
+		return file;
 
 	ret = restore_file_common(ctx, file, ptr);
 	if (ret < 0) {
-- 
1.6.1
