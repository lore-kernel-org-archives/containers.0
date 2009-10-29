From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 10/17] define function to print error messages to user log
Date: Thu, 29 Oct 2009 15:54:35 -0500
Message-ID: <1256849682-858-11-git-send-email-serue@us.ibm.com>
References: <1256849682-858-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256849682-858-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Error messages are both sent to an optional user-provided logfile,
and, if CONFIG_CHECKPOINT_DEBUG=y, sent to syslog.

Changelog:
	Oct 29: Split ckpt_log_error() into ckpt_log_error_v() and have
		ckpt_write_err() call it to duplicate the checkpoint
		error message into the optional user-provided log file and
		(if CONFIG_CHECKPOINT_DEBUG=y) syslog as well.
		Define a fn writing an error prefix (containing
		current->pid etc) for ckpt_error().
	Oct 28: Don't use a third va_args, and use smaller on-stack
		buffer (mhelsley comments).  It still might be cleaner
		to always kmalloc, but always using two kmallocs per
		ckpt_error is getting kinda gross...  (open to comments
		on that).
	Oct 26: Per Oren suggestion, return -EBADF for bad
		logfile in ckpt_ctx_alloc().

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c          |    8 +++-
 checkpoint/objhash.c             |    2 +
 checkpoint/sys.c                 |   91 ++++++++++++++++++++++++++++++++++----
 include/linux/checkpoint.h       |    5 ++
 include/linux/checkpoint_types.h |    5 ++
 include/linux/syscalls.h         |    5 +-
 6 files changed, 103 insertions(+), 13 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 35fce15..30ec622 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -123,8 +123,6 @@ static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt, va_list ap)
 
 	va_end(aq);
 	kfree(format);
-
-	ckpt_debug("c/r: checkpoint error: %s\n", str);
 }
 
 /**
@@ -140,9 +138,15 @@ void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
 {
 	va_list ap;
 
+	/* write to checkpoint file */
 	va_start(ap, fmt);
 	__ckpt_generate_err(ctx, fmt, ap);
 	va_end(ap);
+
+	/* write to user log and syslog */
+	va_start(ap, fmt);
+	ckpt_log_error_v(ctx, fmt, ap);
+	va_end(ap);
 }
 
 /**
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
index 9b2de18..736606d 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -204,6 +204,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 
 	if (ctx->file)
 		fput(ctx->file);
+	if (ctx->logfile)
+		fput(ctx->logfile);
 
 	ckpt_obj_hash_free(ctx);
 	path_put(&ctx->fs_mnt);
@@ -220,12 +222,13 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 		put_task_struct(ctx->root_freezer);
 
 	kfree(ctx->pids_arr);
+	kfree(ctx->error_buf);
 
 	kfree(ctx);
 }
 
 static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
-				       unsigned long kflags)
+				       unsigned long kflags, int logfd)
 {
 	struct ckpt_ctx *ctx;
 	int err;
@@ -249,11 +252,23 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	spin_lock_init(&ctx->lock);
 #endif
 
+	err = -ENOMEM;
+	ctx->error_buf = kmalloc(CKPT_ERR_BUFSZ, GFP_KERNEL);
+	if (!ctx->error_buf)
+		goto err;
+	mutex_init(&ctx->error_buf_mutex);
+
 	err = -EBADF;
 	ctx->file = fget(fd);
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
@@ -351,8 +366,7 @@ int walk_task_subtree(struct task_struct *root,
  * PREFMT is constructed from @fmt by subtituting format snippets
  * according to the contents of @fmt.  The format characters in
  * @fmt can be %(E) (error), %(O) (objref), %(P) (pointer), %(S) (string),
- * %(C) (bytes read/written out of checkpoint image so far), * and %(V)
- * (variable/symbol). For example, %(E) will generate a "err %d"
+ * and %(V) (variable/symbol). For example, %(E) will generate a "err %d"
  * in PREFMT.
  *
  * If @fmt begins with %(T), PREFMT will begin with "pid %d tsk %s"
@@ -370,8 +384,6 @@ int walk_task_subtree(struct task_struct *root,
  *
  * Here, T is simply passed, E expects an integer (err), O expects an
  * integer (objref), and the last argument matches the format string.
- *
- * XXX Do we want 'T' and 'C' to simply always be prepended?
  */
 char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
 {
@@ -435,6 +447,66 @@ char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
 	return format;
 }
 
+/*
+ * called only by ckpt_log_error_v() to write out a prefix, which
+ * looks like:
+ *	[current->pid]=[task_pid_vnr(current)]:[ctx->total]:[ctx->errno]
+ * the ctx->error_buf_mutex is held by caller, so we are free to
+ * write to ctx->error_buf_mutex.  We also can assume that ctx is valid.
+ * Returns the number of characters written (not including trailing \0).
+ */
+static int ckpt_write_error_prefix(struct ckpt_ctx *ctx)
+{
+	return snprintf(ctx->error_buf, CKPT_ERR_BUFSZ, "[%d]=[%d]:[%lld]:[%d] ",
+			 current->pid, task_pid_vnr(current), ctx->total,
+			 ctx->errno);
+}
+
+void ckpt_log_error_v(struct ckpt_ctx *ctx, char *fmt, va_list ap)
+{
+	mm_segment_t fs;
+	char *format;
+	struct file *file = ctx->logfile;
+	char *bufp;
+	va_list aq;
+	int count, len;
+
+	format = ckpt_generate_fmt(ctx, fmt);
+	mutex_lock(&ctx->error_buf_mutex);
+	bufp = ctx->error_buf;
+	len = ckpt_write_error_prefix(ctx);
+	va_copy(aq, ap);
+	count = vsnprintf(bufp+len, CKPT_ERR_BUFSZ-len, format ? : fmt, aq);
+	va_end(aq);
+	count += len;
+	if (count > CKPT_ERR_BUFSZ) {
+		printk(KERN_WARNING "%s:%s:%d error string too long (%d)\n",
+		       __FILE__, __func__, __LINE__, count);
+		bufp[CKPT_ERR_BUFSZ-1] = '\0';
+	}
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	_ckpt_kwrite(file, bufp, count);
+	set_fs(fs);
+
+	ckpt_debug("%s", bufp);
+	mutex_unlock(&ctx->error_buf_mutex);
+	kfree(format);
+}
+
+void ckpt_log_error(struct ckpt_ctx *ctx, char *fmt, ...)
+{
+	va_list ap;
+
+	if (!ctx || !ctx->logfile)
+		return;
+
+	va_start(ap, fmt);
+	ckpt_log_error_v(ctx, fmt, ap);
+	va_end(ap);
+}
+
 /**
  * sys_checkpoint - checkpoint a container
  * @pid: pid of the container init(1) process
@@ -444,7 +516,8 @@ char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
  * Returns positive identifier on success, 0 when returning from restart
  * or negative value on error
  */
-SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
+SYSCALL_DEFINE4(checkpoint, pid_t, pid, int, fd, unsigned long, flags,
+		int, logfd)
 {
 	struct ckpt_ctx *ctx;
 	long ret;
@@ -457,7 +530,7 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
 
 	if (pid == 0)
 		pid = task_pid_vnr(current);
-	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT);
+	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT, logfd);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
@@ -479,7 +552,7 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
  * Returns negative value on error, or otherwise returns in the realm
  * of the original checkpoint
  */
-SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
+SYSCALL_DEFINE4(restart, pid_t, pid, int, fd, unsigned long, flags, int, logfd)
 {
 	struct ckpt_ctx *ctx = NULL;
 	long ret;
@@ -492,7 +565,7 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 		return -EPERM;
 
 	if (pid)
-		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART);
+		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART, logfd);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 8a1eaa7..d3348c5 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -372,6 +372,11 @@ static inline void restore_debug_free(struct ckpt_ctx *ctx) {}
 #endif /* CONFIG_CHECKPOINT_DEBUG */
 
 extern char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt);
+extern void ckpt_log_error_v(struct ckpt_ctx *ctx, char *fmt, va_list ap);
+extern void ckpt_log_error(struct ckpt_ctx *ctx, char *fmt, ...);
+
+#define ckpt_error(ctx, fmt, args...)					\
+	ckpt_log_error(ctx, "%s:%d " fmt, __func__, __LINE__, ## args);
 
 #endif /* CONFIG_CHECKPOINT */
 #endif /* __KERNEL__ */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 5cc11d9..57fd524 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -48,6 +48,7 @@ struct ckpt_ctx {
 	unsigned long oflags;	/* restart: uflags from checkpoint */
 
 	struct file *file;	/* input/output file */
+	struct file *logfile;	/* debug log file */
 	loff_t total;		/* total read/written */
 
 	atomic_t refcount;
@@ -85,6 +86,10 @@ struct ckpt_ctx {
 	struct list_head task_status;   /* list of status for each task */
 	spinlock_t lock;
 #endif
+
+#define CKPT_ERR_BUFSZ 1024
+	char *error_buf;		/* used by ckpt_error() */
+	struct mutex error_buf_mutex;
 };
 
 #endif /* __KERNEL__ */
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
