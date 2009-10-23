From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/3] define function to print error messages to user log
Date: Thu, 22 Oct 2009 23:13:49 -0500
Message-ID: <20091023041349.GA2915@us.ibm.com>
References: <20091023041325.GA2863@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091023041325.GA2863-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Error messages are both sent to an optional user-provided logfile,
and, if CONFIG_CHECKPOINT_DEBUG=y, sent to syslog.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c             |    2 +
 checkpoint/sys.c                 |   61 ++++++++++++++++++++++++++++++++++---
 include/linux/checkpoint.h       |    2 +-
 include/linux/checkpoint_types.h |    1 +
 include/linux/syscalls.h         |    5 ++-
 5 files changed, 63 insertions(+), 8 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 730dd82..c441ce6 100644
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
index 260a1ee..1840f90 100644
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
@@ -238,6 +240,9 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	ctx->kflags = kflags;
 	ctx->ktime_begin = ktime_get();
 
+	/* If logfd's a bad fd that's fine, no log output required... */
+	ctx->logfile = fget(logfd);
+
 	atomic_set(&ctx->refcount, 0);
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
@@ -339,6 +344,51 @@ int walk_task_subtree(struct task_struct *root,
 	return (ret < 0 ? ret : total);
 }
 
+/*
+ * currentpid:targetpid fmt%args
+ */
+void ckpt_log_error(struct ckpt_ctx *ctx, char *fmt, ...)
+{
+	mm_segment_t fs;
+	struct file *file;
+	int count;
+	char buf[200], *bufp = buf;
+	int mypid = current->pid;
+	int tpid = current->nsproxy ? task_pid_vnr(current) : -1;
+	va_list args;
+
+	if (!ctx || !ctx->logfile)
+		return;
+	file = ctx->logfile;
+
+	count = snprintf(buf, 200, "%d:%d ", mypid, tpid);
+	if (count > 200)
+		return; /* not possible */
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	_ckpt_kwrite(file, bufp, count);
+	set_fs(fs);
+
+	va_start(args, fmt);
+	count = vsnprintf(bufp, 200, fmt, args);
+	va_end(args);
+	if (count > 200) {
+		bufp = kmalloc(count, GFP_KERNEL);
+		if (!bufp)
+		       return;
+		va_start(args, fmt);
+		vsnprintf(bufp, count, fmt, args);
+		va_end(args);
+	}
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	_ckpt_kwrite(file, bufp, count);
+	set_fs(fs);
+
+	if (bufp != buf)
+		kfree(bufp);
+}
 
 /**
  * sys_checkpoint - checkpoint a container
@@ -349,7 +399,8 @@ int walk_task_subtree(struct task_struct *root,
  * Returns positive identifier on success, 0 when returning from restart
  * or negative value on error
  */
-SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
+SYSCALL_DEFINE4(checkpoint, pid_t, pid, int, fd, unsigned long, flags,
+		int, logfd)
 {
 	struct ckpt_ctx *ctx;
 	long ret;
@@ -362,7 +413,7 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
 
 	if (pid == 0)
 		pid = task_pid_vnr(current);
-	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT);
+	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT, logfd);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
@@ -384,7 +435,7 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
  * Returns negative value on error, or otherwise returns in the realm
  * of the original checkpoint
  */
-SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
+SYSCALL_DEFINE4(restart, pid_t, pid, int, fd, unsigned long, flags, int, logfd)
 {
 	struct ckpt_ctx *ctx = NULL;
 	long ret;
@@ -397,7 +448,7 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 		return -EPERM;
 
 	if (pid)
-		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART);
+		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART, logfd);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 351f9ac..daba68c 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -371,7 +371,7 @@ static inline void restore_debug_free(struct ckpt_ctx *ctx) {}
 
 #endif /* CONFIG_CHECKPOINT_DEBUG */
 
-#define ckpt_log_error(ctx, fmt, args...)	do { } while (0)
+extern void ckpt_log_error(struct ckpt_ctx *ctx, char *fmt, ...);
 
 #define ckpt_error(ctx, fmt, args...)					\
 	do {								\
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index fa57cdc..264afbd 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -48,6 +48,7 @@ struct ckpt_ctx {
 	unsigned long oflags;	/* restart: uflags from checkpoint */
 
 	struct file *file;	/* input/output file */
+	struct file *logfile;	/* debug log file */
 	int total;		/* total read/written */
 
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
