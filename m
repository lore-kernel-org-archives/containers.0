From: Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>
Subject: External checkpoint patch
Date: Tue, 21 Oct 2008 11:16:10 -0700
Message-ID: <1224612971.1848.193.camel@nimitz>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren,

Could you take a look over Cedric's external checkpoint patch?

http://git.kernel.org/?p=linux/kernel/git/daveh/linux-2.6-cr.git;a=commit;h=28ffabbc17d3641eee2a7eb66f714c266c400263

It seems pretty small to me.

--

From a2f88cbc023e2e9be5eb554fe64078a3d7d2ade6 Mon Sep 17 00:00:00 2001
From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Date: Tue, 30 Sep 2008 10:45:13 +0200
Subject: [PATCH] enable external checkpoint

Modify self checkpoint syscall to allow another process to initiate
checkpoint

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/mm/checkpoint.c   |    2 +-
 checkpoint/checkpoint.c    |    2 +-
 checkpoint/sys.c           |   28 +++++++++++++++++++++-------
 include/linux/checkpoint.h |    1 +
 4 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index d6c5263..202a579 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -164,7 +164,7 @@ void cr_write_cpu_fpu(struct cr_hdr_cpu *hh, struct task_struct *t)
 		 * except if we are in process context, in which case we do
 		 */
 		if (thread_info->status & TS_USEDFPU)
-			unlazy_fpu(current);
+			unlazy_fpu(t);
 
 		hh->has_fxsr = cpu_has_fxsr;
 		memcpy(&hh->xstate, &thread->xstate, sizeof(thread->xstate));
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 87420dc..c4e8242 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -227,7 +227,7 @@ int do_checkpoint(struct cr_ctx *ctx)
 	ret = cr_write_head(ctx);
 	if (ret < 0)
 		goto out;
-	ret = cr_write_task(ctx, current);
+	ret = cr_write_task(ctx, ctx->task);
 	if (ret < 0)
 		goto out;
 	ret = cr_write_tail(ctx);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 4fcd3e0..ec028c6 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -176,7 +176,8 @@ void cr_ctx_free(struct cr_ctx *ctx)
 	kfree(ctx);
 }
 
-struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
+struct cr_ctx *cr_ctx_alloc(struct task_struct *t, pid_t pid, int fd,
+			    unsigned long flags)
 {
 	struct cr_ctx *ctx;
 
@@ -184,6 +185,7 @@ struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
 	if (!ctx)
 		return ERR_PTR(-ENOMEM);
 
+	ctx->task = t;
 	ctx->file = fget(fd);
 	if (!ctx->file) {
 		cr_ctx_free(ctx);
@@ -205,7 +207,7 @@ struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
 	 * assume checkpointer is in container's root vfs
 	 * FIXME: this works for now, but will change with real containers
 	 */
-	ctx->vfsroot = &current->fs->root;
+	ctx->vfsroot = &t->fs->root;
 	path_get(ctx->vfsroot);
 
 	INIT_LIST_HEAD(&ctx->pgarr_list);
@@ -231,20 +233,32 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
 {
 	struct cr_ctx *ctx;
 	int ret;
+	struct task_struct *t;
 
 	/* no flags for now */
 	if (flags)
 		return -EINVAL;
 
-	ctx = cr_ctx_alloc(pid, fd, flags | CR_CTX_CKPT);
-	if (IS_ERR(ctx))
-		return PTR_ERR(ctx);
+	read_lock(&tasklist_lock);
+	t = find_task_by_vpid(pid);
+	if (t)
+		get_task_struct(t);
+	read_unlock(&tasklist_lock);
+
+	if (!t)
+		return -ESRCH;
 
+	ctx = cr_ctx_alloc(t, pid, fd, flags | CR_CTX_CKPT);
+	if (IS_ERR(ctx)) {
+		ret = PTR_ERR(ctx);
+		goto out;
+	}
+
 	ret = do_checkpoint(ctx);
 
 	if (!ret)
 		ret = ctx->crid;
-
+out:
 	cr_ctx_free(ctx);
 	return ret;
 }
@@ -267,7 +281,7 @@ asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
 	if (flags)
 		return -EINVAL;
 
-	ctx = cr_ctx_alloc(crid, fd, flags | CR_CTX_RSTR);
+	ctx = cr_ctx_alloc(current, crid, fd, flags | CR_CTX_RSTR);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 6c1e87f..2983700 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -17,6 +17,7 @@
 
 struct cr_ctx {
 	pid_t pid;		/* container identifier */
+	struct task_struct *task;
 	int crid;		/* unique checkpoint id */
 
 	unsigned long flags;
-- 
1.5.5.1



-- Dave
