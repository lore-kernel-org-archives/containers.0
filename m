From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/2] Add flags for user-space and in-kernel process creation
Date: Mon, 24 Nov 2008 18:39:34 +0300
Message-ID: <1227541175-30301-2-git-send-email-major__16910.1083688021$1227541646$gmane$org@openvz.org>
References: <1227541175-30301-1-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227541175-30301-1-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Introduce 2 flags for user-space and in-kernel process creation during
restart procedure.
Also a stub function for in-kernel process restart is introduced.

Signed-off-by: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 checkpoint/Makefile        |    2 +-
 checkpoint/restart.c       |    4 +++-
 checkpoint/rstr_process.c  |   20 ++++++++++++++++++++
 checkpoint/sys.c           |    4 ++--
 include/linux/checkpoint.h |    3 +++
 5 files changed, 29 insertions(+), 4 deletions(-)
 create mode 100644 checkpoint/rstr_process.c

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 88bbc10..7ead290 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -3,4 +3,4 @@
 #
 
 obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o objhash.o \
-		ckpt_mem.o rstr_mem.o ckpt_file.o rstr_file.o
+		ckpt_mem.o rstr_mem.o ckpt_file.o rstr_file.o rstr_process.o
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 5360c40..9259622 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -461,7 +461,9 @@ int do_restart(struct cr_ctx *ctx, pid_t pid)
 {
 	int ret;
 
-	if (ctx)
+	if (ctx && (ctx->flags & CR_CTX_RSTR_IN_KERNEL))
+		ret = do_restart_in_kernel(ctx);
+	else if (ctx)
 		ret = do_restart_root(ctx, pid);
 	else
 		ret = do_restart_task(ctx, pid);
diff --git a/checkpoint/rstr_process.c b/checkpoint/rstr_process.c
new file mode 100644
index 0000000..ec9e51b
--- /dev/null
+++ b/checkpoint/rstr_process.c
@@ -0,0 +1,20 @@
+/*
+ *  In-kernel process creation
+ *
+ *  Copyright (C) 2008 Parallels, Inc.
+ *
+ *  Author: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ *
+ */
+
+#include <linux/checkpoint.h>
+
+int do_restart_in_kernel(struct cr_ctx *ctx)
+{
+	return -ENOSYS;
+}
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 7745500..e4a9287 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -264,8 +264,8 @@ asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
 	pid_t pid;
 	int ret;
 
-	/* no flags for now */
-	if (flags)
+	if ((flags & (CR_CTX_RSTR_IN_USERSPACE | CR_CTX_RSTR_IN_USERSPACE)) ==
+			(CR_CTX_RSTR_IN_USERSPACE | CR_CTX_RSTR_IN_USERSPACE))
 		return -EINVAL;
 
 	/* FIXME: for now, we use 'crid' as a pid */
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index cab5e19..947469a 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -61,6 +61,8 @@ struct cr_ctx {
 /* cr_ctx: flags */
 #define CR_CTX_CKPT	0x1
 #define CR_CTX_RSTR	0x2
+#define CR_CTX_RSTR_IN_USERSPACE	0x4
+#define CR_CTX_RSTR_IN_KERNEL		0x8
 
 extern int cr_kwrite(struct cr_ctx *ctx, void *buf, int count);
 extern int cr_kread(struct cr_ctx *ctx, void *buf, int count);
@@ -108,6 +110,7 @@ extern int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_write_files(struct cr_ctx *ctx, struct task_struct *t);
 
 extern int do_restart(struct cr_ctx *ctx, pid_t pid);
+extern int do_restart_in_kernel(struct cr_ctx *ctx);
 extern int cr_read_mm(struct cr_ctx *ctx);
 extern int cr_read_files(struct cr_ctx *ctx);
 
-- 
1.5.6
