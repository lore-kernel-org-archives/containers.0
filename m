From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 54/54] Report failures during checkpoint as an object
	in the output stream
Date: Tue, 28 Apr 2009 19:24:24 -0400
Message-ID: <1240961064-13991-55-git-send-email-orenl@cs.columbia.edu>
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

One way to provide some meaningful information about the reason for
which a checkpoint failed, is to write the information as a regular
record to the output stream.

Specifically, if an error is detected, then we write a special 'struct
ckpt_hdr_error' record to the output file, followed by a string that
describes the details of why the checkpoint failed.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c        |   55 ++++++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint_hdr.h |   10 ++++++-
 2 files changed, 62 insertions(+), 3 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 32a0a8e..7f5c18c 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -95,6 +95,50 @@ int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
 	return ckpt_write_obj_type(ctx, str, len, CKPT_HDR_STRING);
 }
 
+/**
+ * ckpt_write_err - write an object describing an error
+ * @ctx: checkpoint context
+ * @fmt: error string format
+ * @...: error string arguments
+ */
+int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
+{
+	va_list args;
+	char str[128];
+	char *ptr = NULL;
+	int len, ret;
+
+	ret = ckpt_write_obj_type(ctx, NULL, sizeof(struct ckpt_hdr),
+				  CKPT_HDR_ERROR);
+	if (ret < 0)
+		return ret;
+
+	va_start(args, fmt);
+	len = vsnprintf(str, 128, fmt, args) + 1;
+	va_end(args);
+
+	if (len > 128) {
+		/* doesn't fit on stack, allocate memory */
+		ptr = kmalloc(len + 1, GFP_KERNEL);
+		/* if malloc failed, fallback to truncated string */
+		if (ptr) {
+			va_start(args, fmt);
+			len = vsnprintf(ptr, len, fmt, args) + 1;
+			va_end(args);
+		} else {
+			len = 128;
+			printk(KERN_NOTICE "c/r: error message truncated\n");
+		}
+	}
+
+	ckpt_debug("c/r: checkpoint error: %s\n", ptr ? : str);
+	ret = ckpt_write_string(ctx, ptr ? : str, len);
+
+	kfree(ptr);
+	return ret;
+}
+
+
 /***********************************************************************
  * Checkpoint
  */
@@ -198,8 +242,11 @@ static int may_checkpoint_task(struct task_struct *t, struct ckpt_ctx *ctx)
 		return -EPERM;
 
 	/* verify that the task is frozen (unless self) */
-	if (t != current && !frozen(t))
+	if (t != current && !frozen(t)) {
+		ckpt_write_err(ctx, "task %d(%s) not frozen\n",
+			       task_pid_vnr(t), t->comm);
 		return -EBUSY;
+	}
 
 	/* FIX: add support for ptraced tasks */
 	if (task_ptrace(t))
@@ -436,8 +483,11 @@ static int get_container(struct ckpt_ctx *ctx, pid_t pid)
 	ctx->root_init = is_container_init(task);
 
 	/* FIX: does this error code makes sense here ? */
-	if (!(ctx->flags & CHECKPOINT_SUBTREE) && !ctx->root_init)
+	if (!(ctx->flags & CHECKPOINT_SUBTREE) && !ctx->root_init) {
+		ckpt_write_err(ctx, "task %d(%s) not container init\n",
+			       task_pid_vnr(task), task->comm);
 		return -EBUSY;
+	}
 
 	return 0;
 
@@ -501,6 +551,7 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	if (!(ctx->flags & CHECKPOINT_SUBTREE)) {
 		/* verify that all objects are contained (no leaks) */
 		if (!ckpt_obj_contained(ctx)) {
+			ckpt_write_err(ctx, "container is not isolated\n");
 			ret = -EBUSY;
 			goto out;
 		}
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 0e15f3f..058412c 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -73,9 +73,17 @@ enum {
 	CKPT_HDR_IPC_MSG_MSG,
 	CKPT_HDR_IPC_SEM,
 
-	CKPT_HDR_TAIL = 5001
+	CKPT_HDR_TAIL = 5001,
+
+	CKPT_HDR_ERROR = 9999
 };
 
+/* error report */
+struct ckpt_hdr_error {
+	struct ckpt_hdr h;
+	/* followed by the error string */
+} __attribute__((aligned(8)));
+
 /* shared objrects (objref) */
 struct ckpt_hdr_objref {
 	struct ckpt_hdr h;
-- 
1.5.4.3
