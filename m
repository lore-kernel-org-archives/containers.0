From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 07/13][user-cr]: Define app_restart()
Date: Wed, 3 Mar 2010 23:48:15 -0800
Message-ID: <20100304074815.GH29320@us.ibm.com>
References: <20100304074354.GA29320@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100304074354.GA29320-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 2 Mar 2010 09:29:55 -0800
Subject: [PATCH 07/13][user-cr]: Define app_restart()

Move the bulk of code that implements application restart into a
separate function, and make main() a wrapper to that function.
This would help export the core restart functionality as a library
interface.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |   58 ++++++++++++++++++++++++++++++++--------------------------
 1 files changed, 32 insertions(+), 26 deletions(-)

diff --git a/restart.c b/restart.c
index d028890..369e9e6 100644
--- a/restart.c
+++ b/restart.c
@@ -807,63 +807,51 @@ static int freezer_register(struct ckpt_ctx *ctx, pid_t pid)
 	return ret;
 }
 
-int main(int argc, char *argv[])
+int app_restart(struct args *args)
 {
 	struct ckpt_ctx ctx;
-	struct args args;
 	int ret;
 
-	/*
-	 * Initialize the log/error fds early so even parse_args() errors
-	 * are redirected here. Even if we later implement command line options
-	 * that override these, any errors/messages that occur before those
-	 * new options are parsed still go to stdout/stderr
-	 */
-	global_ulogfd = fileno(stdout);
-	global_uerrfd = fileno(stderr);
-
 	memset(&ctx, 0, sizeof(ctx));
-
-	parse_args(&args, argc, argv);
-	ctx.args = &args;
+	ctx.args = args;
 
 	/* input file descriptor (default: stdin) */
-	if (args.infd >= 0) {
-		if (dup2(args.infd, STDIN_FILENO) < 0) {
+	if (args->infd >= 0) {
+		if (dup2(args->infd, STDIN_FILENO) < 0) {
 			ckpt_perror("dup2 input file");
 			exit(1);
 		}
-		if (args.infd != STDIN_FILENO)
-			close(args.infd);
+		if (args->infd != STDIN_FILENO)
+			close(args->infd);
 	}
 
 	/* output file descriptor (default: none) */
-	if (args.klogfd < 0)
-		args.klogfd = CHECKPOINT_FD_NONE;
+	if (args->klogfd < 0)
+		args->klogfd = CHECKPOINT_FD_NONE;
 
 	/* freezer preparation */
-	if (args.freezer && freezer_prepare(&ctx) < 0)
+	if (args->freezer && freezer_prepare(&ctx) < 0)
 		exit(1);
 
 	/* private mounts namespace ? */
-	if (args.mntns && unshare(CLONE_NEWNS | CLONE_FS) < 0) {
+	if (args->mntns && unshare(CLONE_NEWNS | CLONE_FS) < 0) {
 		ckpt_perror("unshare");
 		exit(1);
 	}
 
 	/* chroot ? */
-	if (args.root && chroot(args.root) < 0) {
+	if (args->root && chroot(args->root) < 0) {
 		ckpt_perror("chroot");
 		exit(1);
 	}
 
 	/* remount /dev/pts ? */
-	if (args.mnt_pty && ckpt_remount_devpts(&ctx) < 0)
+	if (args->mnt_pty && ckpt_remount_devpts(&ctx) < 0)
 		exit(1);
 
 	/* self-restart ends here: */
-	if (args.self) {
-		restart(getpid(), STDIN_FILENO, RESTART_TASKSELF, args.klogfd);
+	if (args->self) {
+		restart(getpid(), STDIN_FILENO, RESTART_TASKSELF, args->klogfd);
 		/* reach here if restart(2) failed ! */
 		ckpt_perror("restart");
 		exit(1);
@@ -928,6 +916,24 @@ int main(int argc, char *argv[])
 	return ret;
 }
 
+int main(int argc, char *argv[])
+{
+	struct args args;
+
+	/*
+	 * Initialize the log/error fds early so even parse_args() errors
+	 * are redirected here. Even if we later implement command line options
+	 * that override these, any errors/messages that occur before those
+	 * new options are parsed still go to stdout/stderr
+	 */
+	global_ulogfd = fileno(stdout);
+	global_uerrfd = fileno(stderr);
+
+	parse_args(&args, argc, argv);
+
+	return app_restart(&args);
+}
+
 static int ckpt_parse_status(int status, int mimic, int verbose)
 {
 	int sig = 0;
-- 
1.6.0.4
