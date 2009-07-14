From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Make do_restart() and do_checkpoint() return long
Date: Tue, 14 Jul 2009 15:56:39 -0400
Message-ID: <1247601399-20868-1-git-send-email-danms@us.ibm.com>
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
To: orenl-WLbs8XpHrcb2fBVCVOL8/A@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Since syscalls return a long, do_checkpoint() and do_restart() need to also
return a long.  On a 64-bit platform that uses a general-purpose register
for the return value, this is needed to avoid corrupting the value of that
saved register if checkpointed while in userspace.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c    |    4 ++--
 checkpoint/restart.c       |    8 ++++----
 checkpoint/sys.c           |    4 ++--
 include/linux/checkpoint.h |    4 ++--
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 2d4923c..1522e6f 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -642,9 +642,9 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
 	return 0;
 }
 
-int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
+long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 {
-	int ret;
+	long ret;
 
 	ret = init_checkpoint_ctx(ctx, pid);
 	if (ret < 0)
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index c28461c..56a737c 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -819,10 +819,10 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	return ret;
 }
 
-static int restore_retval(void)
+static long restore_retval(void)
 {
 	struct pt_regs *regs = task_pt_regs(current);
-	int ret;
+	long ret;
 
 	/*
 	 * For the restart, we entered the kernel via sys_restart(),
@@ -867,9 +867,9 @@ static int restore_retval(void)
 	return ret;
 }
 
-int do_restart(struct ckpt_ctx *ctx, pid_t pid)
+long do_restart(struct ckpt_ctx *ctx, pid_t pid)
 {
-	int ret;
+	long ret;
 
 	if (ctx)
 		ret = do_restore_coord(ctx, pid);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 5b17e42..525182a 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -284,7 +284,7 @@ void ckpt_ctx_put(struct ckpt_ctx *ctx)
 SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
 {
 	struct ckpt_ctx *ctx;
-	int ret;
+	long ret;
 
 	if (flags & ~CHECKPOINT_USER_FLAGS)
 		return -EINVAL;
@@ -319,7 +319,7 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
 SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 {
 	struct ckpt_ctx *ctx = NULL;
-	int ret;
+	long ret;
 
 	/* no flags for now */
 	if (flags & ~RESTART_USER_FLAGS)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index b8f99be..c0de01e 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -106,8 +106,8 @@ extern int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
 extern void ckpt_ctx_get(struct ckpt_ctx *ctx);
 extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
 
-extern int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
-extern int do_restart(struct ckpt_ctx *ctx, pid_t pid);
+extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
+extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
 
 /* task */
 extern int ckpt_activate_next(struct ckpt_ctx *ctx);
-- 
1.6.1
