From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 02/13][user-cr]: restart: Rename args->logfd
Date: Wed, 3 Mar 2010 23:46:42 -0800
Message-ID: <20100304074642.GC29320@us.ibm.com>
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
Date: Mon, 1 Mar 2010 18:24:51 -0800
Subject: [PATCH 02/13][user-cr]: restart: Rename args->logfd

User-space restart code needs at least two different log files. The restart()
system call code in the kernel writes useful messages to one (currently,
args->logfd).

The user-space restart code writes messages to the other (currently via stdout/
stderr). Note that the user-level restart code creates several processes and
some processes can be in user-space and others in the kernel (sys_restart()).
If both kernel and user-space portions of the restart code logged messages to
the same file, the output would be garbled and hard to use.

To use different file descriptors for the kernel and user-space, first rename
the current ->logfd field to ->klogfd.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/restart.c b/restart.c
index 61abfaa..7697189 100644
--- a/restart.c
+++ b/restart.c
@@ -191,9 +191,9 @@ static int str2sig(char *str)
 	return -1;
 }
 
-inline static int restart(pid_t pid, int fd, unsigned long flags, int logfd)
+inline static int restart(pid_t pid, int fd, unsigned long flags, int klogfd)
 {
-	return syscall(__NR_restart, pid, fd, flags, logfd);
+	return syscall(__NR_restart, pid, fd, flags, klogfd);
 }
 
 #define BUFSIZE  (4 * 4096)
@@ -353,7 +353,7 @@ struct args {
 	char *input;
 	int infd;
 	char *logfile;
-	int logfd;
+	int klogfd;
 	long warn;
 	long fail;
 	int keep_lsm;
@@ -460,7 +460,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 	memset(args, 0, sizeof(*args));
 	args->wait = 1;
 	args->infd = -1;
-	args->logfd = -1;
+	args->klogfd = -1;
 	args->warn = CKPT_COND_WARN;
 	args->fail = CKPT_COND_FAIL;
 	no_pidns = 0;
@@ -494,8 +494,8 @@ static void parse_args(struct args *args, int argc, char *argv[])
 			args->logfile = optarg;
 			break;
 		case 8:
-			args->logfd = str2num(optarg);
-			if (args->logfd < 0) {
+			args->klogfd = str2num(optarg);
+			if (args->klogfd < 0) {
 				printf("restart: invalid file descriptor\n");
 				exit(1);
 			}
@@ -610,7 +610,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		exit(1);
 	}
 
-	if (args->logfile && args->logfd >= 0) {
+	if (args->logfile && args->klogfd >= 0) {
 		printf("Invalid used of both -l/--logfile and --logfile-fd\n");
 		exit(1);
 	}
@@ -783,17 +783,17 @@ int main(int argc, char *argv[])
 
 	/* (optional) log file */
 	if (args.logfile) {
-		args.logfd = open(args.logfile,
+		args.klogfd = open(args.logfile,
 				  O_RDWR | O_CREAT | O_EXCL, 0644);
-		if (args.logfd < 0) {
+		if (args.klogfd < 0) {
 			perror("open log file");
 			exit(1);
 		}
 	}
 
 	/* output file descriptor (default: none) */
-	if (args.logfd < 0)
-		args.logfd = CHECKPOINT_FD_NONE;
+	if (args.klogfd < 0)
+		args.klogfd = CHECKPOINT_FD_NONE;
 
 	/* freezer preparation */
 	if (args.freezer && freezer_prepare(&ctx) < 0)
@@ -817,7 +817,7 @@ int main(int argc, char *argv[])
 
 	/* self-restart ends here: */
 	if (args.self) {
-		restart(getpid(), STDIN_FILENO, RESTART_TASKSELF, args.logfd);
+		restart(getpid(), STDIN_FILENO, RESTART_TASKSELF, args.klogfd);
 		/* reach here if restart(2) failed ! */
 		perror("restart");
 		exit(1);
@@ -1202,7 +1202,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 	if (ctx->args->keep_lsm)
 		flags |= RESTART_KEEP_LSM;
 
-	ret = restart(root_pid, STDIN_FILENO, flags, ctx->args->logfd);
+	ret = restart(root_pid, STDIN_FILENO, flags, ctx->args->klogfd);
 
 	if (ret < 0) {
 		perror("restart failed");
-- 
1.6.0.4
