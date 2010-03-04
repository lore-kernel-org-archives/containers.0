From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 04/13][user-cr]: restart: Use ckpt_msg() to log
Date: Wed, 3 Mar 2010 23:47:23 -0800
Message-ID: <20100304074723.GE29320@us.ibm.com>
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
Date: Mon, 1 Mar 2010 20:04:12 -0800
Subject: [PATCH 04/13][user-cr]: restart: Use ckpt_msg() to log

Rather than implicitly redirecting messages to 'stdout' or 'stderr'
use global variables, 'global_ulogfd' and 'global_uerrfd'. That would
make it easier to implement additional command line options to redirect
these fds to other files, If we also later implement a library interface
to this restart code, it would enable callers to specify fds other than
'stdout' and 'stderr'.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |   90 ++++++++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 63 insertions(+), 27 deletions(-)

diff --git a/restart.c b/restart.c
index 1839330..c4c2158 100644
--- a/restart.c
+++ b/restart.c
@@ -31,6 +31,7 @@
 #include <sys/syscall.h>
 #include <sys/prctl.h>
 #include <sys/mount.h>
+#include <stdarg.h>
 
 #include <linux/sched.h>
 #include <linux/checkpoint.h>
@@ -101,16 +102,38 @@ static char usage_str[] =
  * of the checkpoint image stream.
  */
 
+#define BUFSIZE  (4 * 4096)
+
+static inline void ckpt_msg(int fd, char *format, ...)
+{
+	va_list ap;
+	char *bufp;
+	if (fd < 0)
+		return;
+
+	va_start(ap, format);
+
+	bufp = malloc(BUFSIZE);
+	if(bufp) {
+		vsnprintf(bufp, BUFSIZE, format, ap);
+		write(fd, bufp, strlen(bufp));
+	}
+	free(bufp);
+
+	va_end(ap);
+}
+
 #ifdef CHECKPOINT_DEBUG
 #define ckpt_dbg(_format, _args...)					\
 	do {								\
 		if (global_debug)					\
-			fprintf(stderr, "<%d>" _format, _gettid(), ##_args); \
+			ckpt_msg(global_uerrfd, "<%d>" _format, 	\
+					_gettid(), ##_args); 		\
 	} while (0)
-#define ckpt_dbg_cont(_format, _args...)			\
-	do {							\
-		if (global_debug)				\
-			fprintf(stderr, _format, ##_args);	\
+#define ckpt_dbg_cont(_format, _args...)				\
+	do {								\
+		if (global_debug)					\
+			ckpt_msg(global_uerrfd, _format, ##_args);	\
 	} while (0)
 #else
 #define ckpt_dbg(_format, _args...)  \
@@ -120,12 +143,12 @@ static char usage_str[] =
 #endif
 
 #define ckpt_err(...)  \
-	fprintf(stderr, __VA_ARGS__)
+	ckpt_msg(global_uerrfd, __VA_ARGS__)
 
-#define ckpt_verbose(...)			\
-	do {					\
-		if (global_verbose)		\
-			printf(__VA_ARGS__);	\
+#define ckpt_verbose(...)					\
+	do {							\
+		if (global_verbose)				\
+			ckpt_msg(global_ulogfd, __VA_ARGS__);	\
 	} while(0)
 
 #define SIGNAL_ENTRY(signal)  { SIG ## signal, #signal }
@@ -196,8 +219,6 @@ inline static int restart(pid_t pid, int fd, unsigned long flags, int klogfd)
 	return syscall(__NR_restart, pid, fd, flags, klogfd);
 }
 
-#define BUFSIZE  (4 * 4096)
-
 struct hashent {
 	long key;
 	void *data;
@@ -270,6 +291,12 @@ struct ckpt_ctx {
 	char *freezer;
 };
 
+/*
+ * TODO: Do we need to direct user-space restart messages to two different
+ * 	 fds (like stdout and stderr) or can we just use one ?
+ */
+int global_ulogfd;
+int global_uerrfd;
 int global_debug;
 int global_verbose;
 pid_t global_child_pid;
@@ -372,7 +399,7 @@ struct args {
 
 static void usage(char *str)
 {
-	fprintf(stderr, "%s", str);
+	ckpt_err("%s", str);
 	exit(1);
 }
 
@@ -406,7 +433,7 @@ static long cond_to_mask(const char *cond)
 		if (!strcmp(cond, conditions[i].cond))
 			return conditions[i].mask;
 
-	printf("restart: invalid warn/fail condition '%s'\n", cond);
+	ckpt_err("restart: invalid warn/fail condition '%s'\n", cond);
 	exit(1);
 }
 
@@ -489,7 +516,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		case 7:
 			args->infd = str2num(optarg);
 			if (args->infd < 0) {
-				printf("restart: invalid file descriptor\n");
+				ckpt_err("restart: invalid file descriptor\n");
 				exit(1);
 			}
 			break;
@@ -499,7 +526,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		case 8:
 			args->klogfd = str2num(optarg);
 			if (args->klogfd < 0) {
-				printf("restart: invalid file descriptor\n");
+				ckpt_err("restart: invalid file descriptor\n");
 				exit(1);
 			}
 			break;
@@ -517,7 +544,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 			if (sig < 0)
 				sig = str2num(optarg);
 			if (sig < 0 || sig >= NSIG) {
-				printf("restart: invalid signal\n");
+				ckpt_err("restart: invalid signal\n");
 				exit(1);
 			}
 			global_send_sigint = sig;
@@ -574,7 +601,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 
 #ifndef CLONE_NEWPID
 	if (args->pidns) {
-		printf("This version of restart was compiled without "
+		ckpt_err("This version of restart was compiled without "
 		       "support for --pidns.\n");
 		exit(1);
 	}
@@ -582,7 +609,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 
 #ifndef CHECKPOINT_DEBUG
 	if (global_debug) {
-		printf("This version of restart was compiled without "
+		ckpt_err("This version of restart was compiled without "
 		       "support for --debug.\n");
 		exit(1);
 	}
@@ -594,7 +621,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 #if 0   /* Defered until __NR_eclone makes it to standard headers */
 #ifndef __NR_eclone
 	if (args->pids) {
-		printf("This version of restart was compiled without "
+		ckpt_err("This version of restart was compiled without "
 		       "support for --pids.\n");
 		exit(1);
 	}
@@ -604,17 +631,17 @@ static void parse_args(struct args *args, int argc, char *argv[])
 	if (args->self &&
 	    (args->pids || args->pidns || no_pidns ||
 	     args->show_status || args->copy_status || args->freezer)) {
-		printf("Invalid mix of --self with multiprocess options\n");
+		ckpt_err("Invalid mix of --self with multiprocess options\n");
 		exit(1);
 	}
 
 	if (args->input && args->infd >= 0) {
-		printf("Invalid used of both -i/--input and --input-fd\n");
+		ckpt_err("Invalid use of both -i/--input and --input-fd\n");
 		exit(1);
 	}
 
 	if (klogfile && args->klogfd >= 0) {
-		printf("Invalid used of both -l/--logfile and --logfile-fd\n");
+		ckpt_err("Invalid use of both -l/--logfile and --logfile-fd\n");
 		exit(1);
 	}
 
@@ -770,6 +797,15 @@ int main(int argc, char *argv[])
 	struct args args;
 	int ret;
 
+	/*
+	 * Initialize the log/error fds early so even parse_args() errors
+	 * are redirected here. Even if we later implement command line options
+	 * that override these, any errors/messages that occur before those
+	 * new options are parsed still go to stdout/stderr
+	 */
+	global_ulogfd = fileno(stdout);
+	global_uerrfd = fileno(stderr);
+
 	memset(&ctx, 0, sizeof(ctx));
 
 	parse_args(&args, argc, argv);
@@ -891,16 +927,16 @@ static int ckpt_parse_status(int status, int mimic, int verbose)
 	int ret = 0;
 
 	if (verbose && global_sent_sigint)
-		printf("Terminated\n");
+		ckpt_verbose("Terminated\n");
 	if (WIFSIGNALED(status)) {
 		sig = WTERMSIG(status);
 		if (verbose && !global_sent_sigint)
-			printf("Killed %d\n", sig);
+			ckpt_verbose("Killed %d\n", sig);
 		ckpt_dbg("task terminated with signal %d\n", sig);
 	} else if (WIFEXITED(status)) {
 		ret = WEXITSTATUS(status);
 		if (verbose)
-			printf("Exited %d\n", ret);
+			ckpt_verbose("Exited %d\n", ret);
 		ckpt_dbg("task exited with status %d\n", ret);
 	}
 
@@ -1172,7 +1208,7 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 #else
 static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 {
-	printf("logical error: ckpt_coordinator_pidns unexpected\n");
+	ckpt_err("logical error: ckpt_coordinator_pidns unexpected\n");
 	exit(1);
 }
 #endif
-- 
1.6.0.4
