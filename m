From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 13/13][user-cr]: checkpoint: Use ckpt_perror()
Date: Wed, 3 Mar 2010 23:51:02 -0800
Message-ID: <20100304075102.GN29320@us.ibm.com>
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
Date: Wed, 3 Mar 2010 15:22:47 -0800
Subject: [PATCH 13/13] checkpoint: Use ckpt_perror()

Remove the implicit dependency on 'stderr' and redirect messages to
global_uerrfd. This would simplify implementing command line options
for these file descriptors and also enable implementing the checkpoint
functionality as a library interface

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 checkpoint.c |   60 +++++++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 49 insertions(+), 11 deletions(-)

diff --git a/checkpoint.c b/checkpoint.c
index 4044da8..ace17e2 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -14,6 +14,7 @@
 #include <errno.h>
 #include <getopt.h>
 #include <unistd.h>
+#include <stdarg.h>
 #include <fcntl.h>
 #include <sys/types.h>
 #include <sys/syscall.h>
@@ -39,9 +40,12 @@ static char usage_str[] =
 "  -v,--verbose          verbose output\n"
 "";
 
+static int global_uerrfd = -1;
+
 struct app_checkpoint_args {
 	int outfd;
 	int logfd;
+	int uerrfd;
 	int container;
 	int verbose;
 };
@@ -51,9 +55,38 @@ inline static int checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
 	return syscall(__NR_checkpoint, pid, fd, flags, logfd);
 }
 
+#define BUFSIZE  (4 * 4096)
+static inline void ckpt_msg(int fd, char *format, ...)
+{
+        va_list ap;
+        char *bufp;
+        if (fd < 0)
+                return;
+
+        va_start(ap, format);
+
+        bufp = malloc(BUFSIZE);
+        if(bufp) {
+                vsnprintf(bufp, BUFSIZE, format, ap);
+                write(fd, bufp, strlen(bufp));
+        }
+        free(bufp);
+
+        va_end(ap);
+}
+
+#define ckpt_err(...)  \
+	ckpt_msg(global_uerrfd, __VA_ARGS__)
+
+#define ckpt_perror(s)                                                  \
+        do {                                                            \
+                ckpt_msg(global_uerrfd, s);                             \
+                ckpt_msg(global_uerrfd, ": %s\n", strerror(errno));     \
+        } while (0)
+
 static void usage(char *str)
 {
-	fprintf(stderr, "%s", str);
+	ckpt_err("%s", str);
 	exit(1);
 }
 
@@ -88,6 +121,7 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 	/* defaults */
 	args->outfd = -1;
 	args->logfd = -1;
+	args->uerrfd = fileno(stderr);
 	output = NULL;
 	logfile = NULL;
 
@@ -106,7 +140,7 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 		case 1:
 			args->outfd = str2num(optarg);
 			if (args->outfd < 0) {
-				printf("checkpoint: invalid file descriptor\n");
+				ckpt_err("checkpoint: invalid file descriptor\n");
 				exit(1);
 			}
 			break;
@@ -116,7 +150,7 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 		case 2:
 			args->logfd = str2num(optarg);
 			if (args->logfd < 0) {
-				printf("checkpoint: invalid file descriptor\n");
+				ckpt_err("checkpoint: invalid file descriptor\n");
 				exit(1);
 			}
 			break;
@@ -132,7 +166,7 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 	}
 
 	if (output && args->outfd >= 0) {
-		printf("Invalid use of both -o/--output and --output-fd\n");
+		ckpt_err("Invalid use of both -o/--output and --output-fd\n");
 		exit(1);
 	}
 
@@ -140,13 +174,13 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 	if (output) {
 		args->outfd = open(output, O_RDWR | O_CREAT | O_EXCL, 0644);
 		if (args->outfd < 0) {
-			perror("open output file");
+			ckpt_perror("open output file");
 			exit(1);
 		}
 	}
 
 	if (logfile && args->logfd >= 0) {
-		printf("Invalid use of both -l/--logfile and --logfile-fd\n");
+		ckpt_err("Invalid use of both -l/--logfile and --logfile-fd\n");
 		exit(1);
 	}
 
@@ -154,7 +188,7 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 	if (logfile) {
 		args->logfd = open(logfile, O_RDWR | O_CREAT | O_EXCL, 0644);
 		if (args->logfd < 0) {
-			perror("open log file");
+			ckpt_perror("open log file");
 			exit(1);
 		}
 	}
@@ -165,6 +199,8 @@ int app_checkpoint(int pid, unsigned long flags,
 {
 	int ret;
 
+	global_uerrfd = args->uerrfd;
+
 	/* output file descriptor (default: stdout) */
 	if (args->outfd < 0)
 		args->outfd = STDOUT_FILENO;
@@ -176,10 +212,10 @@ int app_checkpoint(int pid, unsigned long flags,
 	ret = checkpoint(pid, args->outfd, flags, args->logfd);
 
 	if (ret < 0) {
-		perror("checkpoint");
-		fprintf(stderr, "(you may use 'ckptinfo -e' for more info)\n"); 
+		ckpt_perror("checkpoint");
+		ckpt_err("(you may use 'ckptinfo -e' for more info)\n"); 
 	} else if (args->verbose) {
-		fprintf(stderr, "checkpoint id %d\n", ret);
+		ckpt_err("checkpoint id %d\n", ret);
 	}
 
 	return (ret > 0 ? 0 : 1);
@@ -191,6 +227,8 @@ int main(int argc, char *argv[])
 	unsigned long flags = 0;
 	pid_t pid;
 
+	global_uerrfd = fileno(stderr);
+
 	memset(&args, 0, sizeof(args));
 	parse_args(&args, argc, argv);
 
@@ -200,7 +238,7 @@ int main(int argc, char *argv[])
 
 	pid = atoi(argv[optind]);
 	if (pid <= 0) {
-		printf("invalid pid\n");
+		ckpt_err("invalid pid\n");
 		exit(1);
 	}
 
-- 
1.6.0.4
