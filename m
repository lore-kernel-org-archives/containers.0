From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 13/22] add logfd to c/r api
Date: Fri, 30 Oct 2009 18:00:27 -0500
Message-ID: <1256943629-4531-6-git-send-email-serue@us.ibm.com>
References: <1256943629-4531-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256943629-4531-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c             |    2 ++
 checkpoint/sys.c                 |   22 +++++++++++++++++-----
 include/linux/checkpoint_types.h |    1 +
 include/linux/syscalls.h         |    5 +++--
 4 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index a152e69..25b9c10 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -858,6 +858,8 @@ int ckpt_obj_contained(struct ckpt_ctx *ctx)
 
 	/* account for ctx->file reference (if in the table already) */
 	ckpt_obj_users_inc(ctx, ctx->file, 1);
+	if (ctx->logfile)
+		ckpt_obj_users_inc(ctx, ctx->logfile, 1);
 	/* account for ctx->root_nsproxy reference (if in the table already) */
 	ckpt_obj_users_inc(ctx, ctx->root_nsproxy, 1);
 
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index e2c01df..b959b27 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -204,6 +204,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 
 	if (ctx->file)
 		fput(ctx->file);
+	if (ctx->logfile)
+		fput(ctx->logfile);
 
 	ckpt_obj_hash_free(ctx);
 	path_put(&ctx->fs_mnt);
@@ -225,7 +227,7 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 }
 
 static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
-				       unsigned long kflags)
+				       unsigned long kflags, int logfd)
 {
 	struct ckpt_ctx *ctx;
 	int err;
@@ -259,6 +261,13 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	if (!ctx->file)
 		goto err;
 
+	if (logfd == -1)
+		goto skiplogfd;
+	ctx->logfile = fget(logfd);
+	if (!ctx->logfile)
+		goto err;
+
+skiplogfd:
 	err = -ENOMEM;
 	if (ckpt_obj_hash_alloc(ctx) < 0)
 		goto err;
@@ -429,11 +438,13 @@ void ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
  * @pid: pid of the container init(1) process
  * @fd: file to which dump the checkpoint image
  * @flags: checkpoint operation flags
+ * @logfd: fd to which to dump debug and error messages
  *
  * Returns positive identifier on success, 0 when returning from restart
  * or negative value on error
  */
-SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
+SYSCALL_DEFINE4(checkpoint, pid_t, pid, int, fd, unsigned long, flags,
+		int, logfd)
 {
 	struct ckpt_ctx *ctx;
 	long ret;
@@ -446,7 +457,7 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
 
 	if (pid == 0)
 		pid = task_pid_vnr(current);
-	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT);
+	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT, logfd);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
@@ -464,11 +475,12 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
  * @pid: pid of task root (in coordinator's namespace), or 0
  * @fd: file from which read the checkpoint image
  * @flags: restart operation flags
+ * @logfd: fd to which to dump debug and error messages
  *
  * Returns negative value on error, or otherwise returns in the realm
  * of the original checkpoint
  */
-SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
+SYSCALL_DEFINE4(restart, pid_t, pid, int, fd, unsigned long, flags, int, logfd)
 {
 	struct ckpt_ctx *ctx = NULL;
 	long ret;
@@ -481,7 +493,7 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 		return -EPERM;
 
 	if (pid)
-		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART);
+		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART, logfd);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 46c58fb..d0b47f2 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -48,6 +48,7 @@ struct ckpt_ctx {
 	unsigned long oflags;	/* restart: uflags from checkpoint */
 
 	struct file *file;	/* input/output file */
+	struct file *logfile;	/* debug log file */
 	loff_t total;		/* total read/written */
 
 	atomic_t refcount;
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 33bce6e..4fce331 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -754,8 +754,9 @@ asmlinkage long sys_pselect6(int, fd_set __user *, fd_set __user *,
 asmlinkage long sys_ppoll(struct pollfd __user *, unsigned int,
 			  struct timespec __user *, const sigset_t __user *,
 			  size_t);
-asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags);
-asmlinkage long sys_restart(pid_t pid, int fd, unsigned long flags);
+asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags,
+			       int logfd);
+asmlinkage long sys_restart(pid_t pid, int fd, unsigned long flags, int logfd);
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
-- 
1.6.1
