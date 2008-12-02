From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 2/4] checkpoint/restart: fix cr_ctx_checkpoint() locking
Date: Tue, 02 Dec 2008 10:57:36 -0800
Message-ID: <20081202185736.EF0F917D@kernel>
References: <20081202185734.F740150C@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081202185734.F740150C@kernel>
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
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


The existing ctx->vfsroot is dangerous.  We take it from
the root task via: ctx->root_task->fs->root and don't take
a ref on the 'fs' in there.  We also take a ref on the
fs.root which is worthless.

So, replace ctx->vfsroot with a reference to the 'fs'
instead.  This gives us easy access to fs.root later on,
and also lets us do proper refcounting.

This, of course, eventually needs to be done per-process
but this should at least remove a potential oops.

---

 linux-2.6.git-dave/checkpoint/checkpoint.c    |    7 ++-----
 linux-2.6.git-dave/checkpoint/ckpt_file.c     |    2 +-
 linux-2.6.git-dave/checkpoint/ckpt_mem.c      |    2 +-
 linux-2.6.git-dave/checkpoint/sys.c           |    4 ++--
 linux-2.6.git-dave/include/linux/checkpoint.h |    2 +-
 5 files changed, 7 insertions(+), 10 deletions(-)

diff -puN checkpoint/checkpoint.c~fix-cr_ctx_checkpoint-locking checkpoint/checkpoint.c
--- linux-2.6.git/checkpoint/checkpoint.c~fix-cr_ctx_checkpoint-locking	2008-12-02 10:21:52.000000000 -0800
+++ linux-2.6.git-dave/checkpoint/checkpoint.c	2008-12-02 10:21:52.000000000 -0800
@@ -511,12 +511,9 @@ static int cr_ctx_checkpoint(struct cr_c
 	 * assume checkpointer is in container's root vfs
 	 * FIXME: this works for now, but will change with real containers
 	 */
-	task_lock(ctx->root_task);
-	ctx->vfsroot = &ctx->root_task->fs->root;
-	task_unlock(ctx->root_task);
-	if (!ctx->vfsroot)
+	ctx->fs = get_fs_struct(ctx->root_task);
+	if (!ctx->fs)
 		return -EAGAIN;
-	path_get(ctx->vfsroot);
 
 	return 0;
 }
diff -puN checkpoint/ckpt_file.c~fix-cr_ctx_checkpoint-locking checkpoint/ckpt_file.c
--- linux-2.6.git/checkpoint/ckpt_file.c~fix-cr_ctx_checkpoint-locking	2008-12-02 10:21:52.000000000 -0800
+++ linux-2.6.git-dave/checkpoint/ckpt_file.c	2008-12-02 10:46:56.000000000 -0800
@@ -117,7 +117,7 @@ static int cr_write_fd_data(struct cr_ct
 	if (ret < 0)
 		return ret;
 
-	return cr_write_fname(ctx, &file->f_path, ctx->vfsroot);
+	return cr_write_fname(ctx, &file->f_path, &ctx->fs.root);
 }
 
 /**
diff -puN checkpoint/ckpt_mem.c~fix-cr_ctx_checkpoint-locking checkpoint/ckpt_mem.c
--- linux-2.6.git/checkpoint/ckpt_mem.c~fix-cr_ctx_checkpoint-locking	2008-12-02 10:21:52.000000000 -0800
+++ linux-2.6.git-dave/checkpoint/ckpt_mem.c	2008-12-02 10:21:52.000000000 -0800
@@ -436,7 +436,7 @@ static int cr_write_vma(struct cr_ctx *c
 
 	/* save the file name, if relevant */
 	if (vma->vm_file) {
-		ret = cr_write_fname(ctx, &vma->vm_file->f_path, ctx->vfsroot);
+		ret = cr_write_fname(ctx, &vma->vm_file->f_path, &ctx->fs.root);
 		if (ret < 0)
 			return ret;
 	}
diff -puN checkpoint/sys.c~fix-cr_ctx_checkpoint-locking checkpoint/sys.c
--- linux-2.6.git/checkpoint/sys.c~fix-cr_ctx_checkpoint-locking	2008-12-02 10:21:52.000000000 -0800
+++ linux-2.6.git-dave/checkpoint/sys.c	2008-12-02 10:21:52.000000000 -0800
@@ -152,8 +152,8 @@ static void cr_ctx_free(struct cr_ctx *c
 
 	kfree(ctx->hbuf);
 
-	if (ctx->vfsroot)
-		path_put(ctx->vfsroot);
+	if (ctx->fs)
+		put_fs_struct(ctx->fs);
 
 	cr_pgarr_free(ctx);
 	cr_objhash_free(ctx);
diff -puN include/linux/checkpoint.h~fix-cr_ctx_checkpoint-locking include/linux/checkpoint.h
--- linux-2.6.git/include/linux/checkpoint.h~fix-cr_ctx_checkpoint-locking	2008-12-02 10:21:52.000000000 -0800
+++ linux-2.6.git-dave/include/linux/checkpoint.h	2008-12-02 10:21:52.000000000 -0800
@@ -41,7 +41,7 @@ struct cr_ctx {
 
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 
-	struct path *vfsroot;	/* container root (FIXME) */
+	struct fs_struct *fs;		/* container root/pwd (FIXME) */
 
 	/* [multi-process checkpoint] */
 	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
_
