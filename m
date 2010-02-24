From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 2/4][user-cr] Rename struct args to struct restart_args
Date: Wed, 24 Feb 2010 00:36:23 -0800
Message-ID: <20100224083623.GD18758@us.ibm.com>
References: <20100224083452.GB18758@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100224083452.GB18758-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From 8a6fad2170fbbeb7a5e44c32239f9703c0b7d2f9 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 23 Feb 2010 15:33:04 -0800
Subject: [PATCH 2/4][user-cr] Rename struct args to struct restart_args

Rename struct args to struct restart_args and move to a new header file,
usercr.h. usercr.h will become part of the external API for application
checkpoint restart code.

Also move the bulk of the restart code into a separate function,
app_restart() and have main() call the function.

TODO:
	Cleanup 'struct restart_args' for a more consistent external API.
---
 restart.c |   77 ++++++++++++++++++++++++------------------------------------
 usercr.h  |   24 +++++++++++++++++++
 2 files changed, 55 insertions(+), 46 deletions(-)
 create mode 100644 usercr.h

diff --git a/restart.c b/restart.c
index 7140786..b2281fb 100644
--- a/restart.c
+++ b/restart.c
@@ -40,6 +40,7 @@
 #include "genstack.h"
 #include "compat.h"
 #include "restart.h"
+#include "usercr.h"
 
 static char usage_str[] =
 "usage: restart [opts]\n"
@@ -237,7 +238,7 @@ struct ckpt_ctx {
 	char container[BUFSIZE];
 	char tree[BUFSIZE];
 	char buf[BUFSIZE];
-	struct args *args;
+	struct restart_args *args;
 
 	char *freezer;
 };
@@ -310,28 +311,6 @@ struct pid_swap {
 	pid_t new;
 };
 
-struct args {
-	int self;
-	int pids;
-	int pidns;
-	int no_pidns;
-	int inspect;
-	char *root;
-	int wait;
-	int mntns;
-	int mnt_pty;
-	int show_status;
-	int copy_status;
-	char *freezer;
-	char *input;
-	int infd;
-	char *logfile;
-	int logfd;
-	long warn;
-	long fail;
-	int keep_lsm;
-};
-
 static void usage(char *str)
 {
 	fprintf(stderr, "%s", str);
@@ -382,7 +361,7 @@ static inline int ckpt_cond_fail(struct ckpt_ctx *ctx, long mask)
 	return (ctx->args->fail & mask);
 }
 
-static void parse_args(struct args *args, int argc, char *argv[])
+static void parse_args(struct restart_args *args, int argc, char *argv[])
 {
 	static struct option opts[] = {
 		{ "help",	no_argument,		NULL, 'h' },
@@ -712,71 +691,77 @@ static int freezer_register(struct ckpt_ctx *ctx, pid_t pid)
 
 int main(int argc, char *argv[])
 {
+	struct restart_args args;
+
+	parse_args(&args, argc, argv);
+
+	return app_restart(&args);
+}
+
+int app_restart(struct restart_args *args)
+{
 	struct ckpt_ctx ctx;
-	struct args args;
 	int ret;
 
 	memset(&ctx, 0, sizeof(ctx));
-
-	parse_args(&args, argc, argv);
-	ctx.args = &args;
+	ctx.args = args;
 
 	/* input file ? */
-	if (args.input) {
-		args.infd = open(args.input, O_RDONLY, 0);
-		if (args.infd < 0) {
+	if (args->input) {
+		args->infd = open(args->input, O_RDONLY, 0);
+		if (args->infd < 0) {
 			perror("open input file");
 			exit(1);
 		}
 	}
 
 	/* input file descriptor (default: stdin) */
-	if (args.infd >= 0) {
-		if (dup2(args.infd, STDIN_FILENO) < 0) {
+	if (args->infd >= 0) {
+		if (dup2(args->infd, STDIN_FILENO) < 0) {
 			perror("dup2 input file");
 			exit(1);
 		}
-		if (args.infd != STDIN_FILENO)
-			close(args.infd);
+		if (args->infd != STDIN_FILENO)
+			close(args->infd);
 	}
 
 	/* (optional) log file */
-	if (args.logfile) {
-		args.logfd = open(args.logfile,
+	if (args->logfile) {
+		args->logfd = open(args->logfile,
 				  O_RDWR | O_CREAT | O_EXCL, 0644);
-		if (args.logfd < 0) {
+		if (args->logfd < 0) {
 			perror("open log file");
 			exit(1);
 		}
 	}
 
 	/* output file descriptor (default: none) */
-	if (args.logfd < 0)
-		args.logfd = CHECKPOINT_FD_NONE;
+	if (args->logfd < 0)
+		args->logfd = CHECKPOINT_FD_NONE;
 
 	/* freezer preparation */
-	if (args.freezer && freezer_prepare(&ctx) < 0)
+	if (args->freezer && freezer_prepare(&ctx) < 0)
 		exit(1);
 
 	/* private mounts namespace ? */
-	if (args.mntns && unshare(CLONE_NEWNS | CLONE_FS) < 0) {
+	if (args->mntns && unshare(CLONE_NEWNS | CLONE_FS) < 0) {
 		perror("unshare");
 		exit(1);
 	}
 
 	/* chroot ? */
-	if (args.root && chroot(args.root) < 0) {
+	if (args->root && chroot(args->root) < 0) {
 		perror("chroot");
 		exit(1);
 	}
 
 	/* remount /dev/pts ? */
-	if (args.mnt_pty && ckpt_remount_devpts(&ctx) < 0)
+	if (args->mnt_pty && ckpt_remount_devpts(&ctx) < 0)
 		exit(1);
 
 	/* self-restart ends here: */
-	if (args.self) {
-		restart(getpid(), STDIN_FILENO, RESTART_TASKSELF, args.logfd);
+	if (args->self) {
+		restart(getpid(), STDIN_FILENO, RESTART_TASKSELF, args->logfd);
 		/* reach here if restart(2) failed ! */
 		perror("restart");
 		exit(1);
diff --git a/usercr.h b/usercr.h
new file mode 100644
index 0000000..71a36e6
--- /dev/null
+++ b/usercr.h
@@ -0,0 +1,24 @@
+
+struct restart_args {
+	int self;
+	int pids;
+	int pidns;
+	int no_pidns;
+	int inspect;
+	char *root;
+	int wait;
+	int mntns;
+	int mnt_pty;
+	int show_status;
+	int copy_status;
+	char *freezer;
+	char *input;
+	int infd;
+	char *logfile;
+	int logfd;
+	long warn;
+	long fail;
+	int keep_lsm;
+};
+
+extern int app_restart(struct restart_args *args);
-- 
1.6.6.1
