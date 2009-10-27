From: Serge Hallyn <serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 11/17] define function to print error messages to user log
Date: Tue, 27 Oct 2009 17:46:21 -0500
Message-ID: <1256683587-23961-12-git-send-email-serge@us.ibm.com>
References: <1256683587-23961-1-git-send-email-serge@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256683587-23961-1-git-send-email-serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Error messages are both sent to an optional user-provided logfile,
and, if CONFIG_CHECKPOINT_DEBUG=y, sent to syslog.

Changelog:
	Oct 27: add %(C) for ctx->total.
	Oct 26: Per Oren suggestion, return -EBADF for bad
		logfile in ckpt_ctx_alloc().

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c             |    2 +
 checkpoint/sys.c                 |   67 +++++++++++++++++++++++++++++++++++---
 include/linux/checkpoint.h       |    5 +++
 include/linux/checkpoint_types.h |    1 +
 include/linux/syscalls.h         |    5 ++-
 5 files changed, 73 insertions(+), 7 deletions(-)

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
index 38e65e4..ab0f294 100644
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
@@ -254,6 +256,12 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	if (!ctx->file)
 		goto err;
 
+	if (logfd != -1) {
+		ctx->logfile = fget(logfd);
+		if (!ctx->logfile)
+			goto err;
+	}
+
 	err = -ENOMEM;
 	if (ckpt_obj_hash_alloc(ctx) < 0)
 		goto err;
@@ -401,6 +409,9 @@ char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
 		case 'E':
 			len += sprintf(format+len, "[%s]", "err %d");
 			break;
+		case 'C': /* count of bytes read/written to checkpoint image */
+			len += sprintf(format+len, "[%s]", "pos %d");
+			break;
 		case 'O':
 			len += sprintf(format+len, "[%s]", "obj %d");
 			break;
@@ -435,6 +446,51 @@ char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
 	return format;
 }
 
+void ckpt_log_error(struct ckpt_ctx *ctx, char *fmt, ...)
+{
+	mm_segment_t fs;
+	struct file *file;
+	int count;
+	va_list ap, aq, az;
+	char *format;
+	char buf[200], *bufp = buf;
+
+	if (!ctx || !ctx->logfile)
+		return;
+	file = ctx->logfile;
+
+	va_start(ap, fmt);
+	format = ckpt_generate_fmt(ctx, fmt);
+	va_copy(aq, ap);
+	va_copy(az, ap);
+	/* I'm not clear here - can I re-use aq, or do i need
+	 * a third copy? */
+	count = vsnprintf(bufp, 200, format ? : fmt, aq);
+	if (count > 200) {
+		bufp = kmalloc(count, GFP_KERNEL);
+		if (!bufp)
+		       goto out_free;
+		vsnprintf(bufp, count, format ? : fmt, az);
+	}
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	_ckpt_kwrite(file, bufp, count);
+	set_fs(fs);
+
+#ifdef CONFIG_CHECKPOINT_DEBUG
+	vprintk(format, aq);
+#endif
+
+out_free:
+	kfree(format);
+	va_end(aq);
+	va_end(ap);
+	va_end(az);
+	if (bufp != buf)
+		kfree(bufp);
+}
+
 /**
  * sys_checkpoint - checkpoint a container
  * @pid: pid of the container init(1) process
@@ -444,7 +500,8 @@ char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
  * Returns positive identifier on success, 0 when returning from restart
  * or negative value on error
  */
-SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
+SYSCALL_DEFINE4(checkpoint, pid_t, pid, int, fd, unsigned long, flags,
+		int, logfd)
 {
 	struct ckpt_ctx *ctx;
 	long ret;
@@ -457,7 +514,7 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
 
 	if (pid == 0)
 		pid = task_pid_vnr(current);
-	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT);
+	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT, logfd);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
@@ -479,7 +536,7 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
  * Returns negative value on error, or otherwise returns in the realm
  * of the original checkpoint
  */
-SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
+SYSCALL_DEFINE4(restart, pid_t, pid, int, fd, unsigned long, flags, int, logfd)
 {
 	struct ckpt_ctx *ctx = NULL;
 	long ret;
@@ -492,7 +549,7 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 		return -EPERM;
 
 	if (pid)
-		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART);
+		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART, logfd);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 8a1eaa7..91e0066 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -372,6 +372,11 @@ static inline void restore_debug_free(struct ckpt_ctx *ctx) {}
 #endif /* CONFIG_CHECKPOINT_DEBUG */
 
 extern char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt);
+extern void ckpt_log_error(struct ckpt_ctx *ctx, char *fmt, ...);
+
+#define ckpt_error(ctx, fmt, args...)					\
+	ckpt_log_error(ctx, "%s:%d %(C)" fmt, __func__, __LINE__,	\
+		       ctx ? ctx->total : -1, ## args);
 
 #endif /* CONFIG_CHECKPOINT */
 #endif /* __KERNEL__ */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 5cc11d9..c6dcd4f 100644
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
