From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH user-cr] Allow for logfile for kernel debug messages (v2)
Date: Wed, 21 Oct 2009 16:05:33 -0500
Message-ID: <20091021210533.GA2165@us.ibm.com>
References: <20091021210507.GA2098@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091021210507.GA2098-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

If unspecified, -1 will be sent for logfd to the kernel, and there
will be no debug log.   If specified, then checkpoint and restart
debug msgs will be sent to the logfile.

Logfile is specified using -l LOGFILE or --logfile=LOGFILE, i.e.

	checkpoint $pid -o ckpt.out -l ckpt.debug
	restart -l rstr.debug -i ckpt.out

Changelog:
	oct 21: take a --logall flag

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint.c |   34 ++++++++++++++++++++++++++++++----
 restart.c    |   47 +++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 71 insertions(+), 10 deletions(-)

diff --git a/checkpoint.c b/checkpoint.c
index c116daf..553132c 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -32,6 +32,8 @@ static char usage_str[] =
 "\tOptions:\n"
 "  -h,--help             print this help message\n"
 "  -o,--output=FILE      write data to FILE instead of standard output\n"
+"  -l,--logfile=FILE     write kernel debug data to FILE (default=nowhere)\n"
+"  -a,--logall           have kernel output all debug data, not just errors\n"
 "  -c,--container        require the PID is a container-init\n"
 "  -v,--verbose          verbose output\n"
 "";
@@ -40,11 +42,13 @@ struct args {
 	char *output;
 	int container;
 	int verbose;
+	int logall;
+	char *logfile;
 };
 
-inline static int checkpoint(pid_t pid, int fd, unsigned long flags)
+inline static int checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
 {
-	return syscall(__NR_checkpoint, pid, fd, flags);
+	return syscall(__NR_checkpoint, pid, fd, flags, logfd);
 }
 
 static void usage(char *str)
@@ -59,10 +63,12 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "help",	no_argument,		NULL, 'h' },
 		{ "output",	required_argument,	NULL, 'o' },
 		{ "container",	no_argument,		NULL, 'c' },
+		{ "logfile",	required_argument,	NULL, 'l' },
+		{ "logall",	required_argument,	NULL, 'a' },
 		{ "verbose",	no_argument,		NULL, 'v' },
 		{ NULL,		0,			NULL, 0 }
 	};
-	static char optc[] = "hvco:";
+	static char optc[] = "ahvco:l:";
 
 	while (1) {
 		int c = getopt_long(argc, argv, optc, opts, NULL);
@@ -73,12 +79,18 @@ static void parse_args(struct args *args, int argc, char *argv[])
 			exit(1);
 		case 'h':
 			usage(usage_str);
+		case 'a':
+			args->logall = 1;
+			break;
 		case 'o':
 			args->output = optarg;
 			break;
 		case 'c':
 			args->container = 1;
 			break;
+		case 'l':
+			args->logfile = optarg;
+			break;
 		case 'v':
 			args->verbose = 1;
 			break;
@@ -94,6 +106,7 @@ int main(int argc, char *argv[])
 	unsigned long flags = 0;
 	pid_t pid;
 	int ret;
+	int logfd;
 
 	memset(&args, 0, sizeof(args));
 	parse_args(&args, argc, argv);
@@ -125,8 +138,21 @@ int main(int argc, char *argv[])
 		if (ret != STDOUT_FILENO)
 			close(ret);
 	}
+	if (args.logfile) {
+		logfd = open(args.logfile, O_RDWR | O_CREAT, 0600);
+		if (logfd < 0) {
+			perror("open logfile");
+			exit(1);
+		}
+	}
+
+	if (args.logall) {
+		if (!args.logfile)
+			printf("Warning: -a specified but no logfile\n");
+		flags |= CHECKPOINT_LOG_ALL;
+	}
 
-	ret = checkpoint(pid, STDOUT_FILENO, flags);
+	ret = checkpoint(pid, STDOUT_FILENO, flags, logfd);
 
 	if (ret < 0) {
 		perror("checkpoint");
diff --git a/restart.c b/restart.c
index fbaab88..6ba6445 100644
--- a/restart.c
+++ b/restart.c
@@ -75,6 +75,8 @@ static char usage_str[] =
 "  -i,--input=FILE      read data from FILE instead of standard input\n"
 "     --inspect          inspect image on-the-fly for error records\n"
 "  -v,--verbose          verbose output\n"
+"  -l,--log=FILE         logfile for kernel debug info\n"
+"  -a,--logall           have kernel write all debug info, not just errors\n"
 "  -d,--debug            debugging output\n"
 "";
 
@@ -194,9 +196,9 @@ static int str2sig(char *str)
 	return -1;
 }
 
-inline static int restart(pid_t pid, int fd, unsigned long flags)
+inline static int restart(pid_t pid, int fd, unsigned long flags, int logfd)
 {
-	return syscall(__NR_restart, pid, fd, flags);
+	return syscall(__NR_restart, pid, fd, flags, logfd);
 }
 
 #define BUFSIZE  (4 * 4096)
@@ -252,6 +254,8 @@ struct ckpt_ctx {
 	int pipe_out;
 	int pids_nr;
 
+	int logfd;
+
 	int pipe_child[2];	/* for children to report status */
 	int pipe_feed[2];	/* for feeder to provide input */
 
@@ -352,6 +356,8 @@ struct args {
 	int copy_status;
 	char *freezer;
 	char *input;
+	char *logfile;
+	int logall;
 };
 
 static void usage(char *str)
@@ -390,10 +396,12 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "no-wait",	no_argument,		NULL, 'W' },
 		{ "freezer",	required_argument,	NULL, 'F' },
 		{ "verbose",	no_argument,		NULL, 'v' },
+		{ "log",	required_argument,	NULL, 'l' },
+		{ "logall",	required_argument,	NULL, 'a' },
 		{ "debug",	no_argument,		NULL, 'd' },
 		{ NULL,		0,			NULL, 0 }
 	};
-	static char optc[] = "hdvpPwWF:r:i:";
+	static char optc[] = "ahdvpPwWF:r:i:l:";
 
 	int sig;
 
@@ -408,6 +416,9 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		switch (c) {
 		case '?':
 			exit(1);
+		case 'a':
+			args->logall = 1;
+			break;
 		case 'h':
 			usage(usage_str);
 		case 'v':
@@ -416,6 +427,9 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		case 5:  /* --inspect */
 			args->inspect = 1;
 			break;
+		case 'l':
+			args->logfile = optarg;
+			break;
 		case 'i':
 			args->input = optarg;
 			break;
@@ -489,6 +503,9 @@ static void parse_args(struct args *args, int argc, char *argv[])
 	}
 #endif
 
+	if (args->logall && !args->logfile)
+		printf("Warning: -a specified but no logfile\n");
+
 	if (args->pidns)
 		args->pids = 1;
 
@@ -666,6 +683,15 @@ int main(int argc, char *argv[])
 			close(ret);
 	}
 
+	ctx.logfd = -1;
+	if (args.logfile) {
+		ctx.logfd = open(args.logfile, O_RDWR | O_CREAT, 0600);
+		if (ctx.logfd < 0) {
+			perror("open log file");
+			exit(1);
+		}
+	}
+
 	/* freezer preparation */
 	if (args.freezer && freezer_prepare(&ctx) < 0)
 		exit(1);
@@ -678,7 +704,10 @@ int main(int argc, char *argv[])
 
 	/* self-restart ends here: */
 	if (args.self) {
-		restart(getpid(), STDIN_FILENO, RESTART_TASKSELF);
+		int flags = RESTART_TASKSELF;
+		if (args.logall)
+			flags |= RESTART_LOG_ALL;
+		restart(getpid(), STDIN_FILENO, flags, ctx.logfd);
 		/* reach here if restart(2) failed ! */
 		perror("restart");
 		exit(1);
@@ -929,7 +958,10 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 	if (ctx->args->freezer)
 		flags |= RESTART_FROZEN;
 
-	ret = restart(root_pid, STDIN_FILENO, flags);
+	if (ctx->args->logall)
+		flags |= RESTART_LOG_ALL;
+
+	ret = restart(root_pid, STDIN_FILENO, flags, ctx->logfd);
 
 	if (ret < 0) {
 		perror("restart failed");
@@ -1588,9 +1620,12 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 	if (task->flags & (TASK_GHOST | TASK_DEAD))
 		flags |= RESTART_GHOST;
 
+	if (ctx->args->logall)
+		flags |= RESTART_LOG_ALL;
+
 	/* on success this doesn't return */
 	ckpt_dbg("about to call sys_restart(), flags %#lx\n", flags);
-	ret = restart(0, STDIN_FILENO, flags);
+	ret = restart(0, STDIN_FILENO, flags, ctx->logfd);
 	if (ret < 0)
 		perror("task restore failed");
 	return ret;
-- 
1.6.1.1
