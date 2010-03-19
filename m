From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 09/14][user-cr] checkpoint: Move main() to checkpoint-main.c
Date: Thu, 18 Mar 2010 23:33:39 -0700
Message-ID: <20100319063339.GI24844@us.ibm.com>
References: <20100319062659.GA23838@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100319062659.GA23838-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Date: Thu, 4 Mar 2010 22:28:34 -0800
Subject: [PATCH 09/14][user-cr] checkpoint: Move main() to checkpoint-main.c

---
 Makefile          |    4 +-
 checkpoint-main.c |  171 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 checkpoint.c      |  157 ------------------------------------------------
 3 files changed, 174 insertions(+), 158 deletions(-)
 create mode 100644 checkpoint-main.c

diff --git a/Makefile b/Makefile
index 7e1d701..6c9ff93 100644
--- a/Makefile
+++ b/Makefile
@@ -13,7 +13,7 @@ CKPT_HEADERS = include/linux/checkpoint.h \
 		include/linux/checkpoint_hdr.h \
 		include/asm/checkpoint_hdr.h
 
-CR_OBJS = checkpoint.o restart.o restart-main.o
+CR_OBJS = checkpoint.o checkpoint-main.o restart.o restart-main.o
 
 # detect architecture (for eclone)
 SUBARCH ?= $(patsubst i%86,x86_32,$(shell uname -m))
@@ -56,6 +56,8 @@ $(CR_OBJS): common.h app-checkpoint.h
 
 restart: restart.o restart-main.o
 
+checkpoint: checkpoint.o checkpoint-main.o
+
 # eclone() is architecture specific
 ifneq ($(SUBARCH),)
 $(ECLONE_PROGS): $(LIB_ECLONE) 
diff --git a/checkpoint-main.c b/checkpoint-main.c
new file mode 100644
index 0000000..f6faa32
--- /dev/null
+++ b/checkpoint-main.c
@@ -0,0 +1,171 @@
+#include <stdio.h>
+#include <unistd.h>
+#include <stdarg.h>
+#include <stdlib.h>
+#include <string.h>
+#include <getopt.h>
+#include <fcntl.h>
+#include <errno.h>
+
+#include <linux/checkpoint.h>
+
+#include "app-checkpoint.h"
+#include "common.h"
+
+static int global_uerrfd = -1;
+
+static char usage_str[] =
+"usage: ckpt [opts] PID\n"
+"  'checkpoint' takes a checkpoint of the task indicated by PID, and all\n"
+"  its descendents, and outputs the checkpoint image. If the task is the\n"
+"  init(1) process of a container, it checkpoints the entire container.\n"
+"  By default 'checkpoint' allows to checkpoint any subtree of tasks. The\n"
+"  user can override this feature and request that only whole containers\n"
+"  be considered.\n"
+"\n"
+"\tOptions:\n"
+"  -h,--help             print this help message\n"
+"  -o,--output=FILE      write data to FILE instead of standard output\n"
+"     --output-fd=FD     write data to file descriptor FD instead of stdout\n"
+"  -l,--logfile=FILE     write error and debug data to FILE (default=none)\n"
+"     --logile-fd=FD     write error and debug data to file descriptor FD\n"
+"  -c,--container        require the PID is a container-init\n"
+"  -v,--verbose          verbose output\n"
+"";
+
+static void usage(char *str)
+{
+	ckpt_err("%s", str);
+	exit(1);
+}
+
+/* negative retval means error */
+static int str2num(char *str)
+{
+	char *nptr;
+	int num;
+
+	num = strtol(str, &nptr, 10);
+	if (nptr - str != strlen(str))
+		num = -1;
+	return num;
+}
+
+static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
+{
+	static struct option opts[] = {
+		{ "help",	no_argument,		NULL, 'h' },
+		{ "output",	required_argument,	NULL, 'o' },
+		{ "output-fd",	required_argument,	NULL, 1 },
+		{ "logfile",	required_argument,	NULL, 'l' },
+		{ "logfile-fd",	required_argument,	NULL, 2 },
+		{ "container",	no_argument,		NULL, 'c' },
+		{ "verbose",	no_argument,		NULL, 'v' },
+		{ NULL,		0,			NULL, 0 }
+	};
+	static char optc[] = "hvco:l:";
+	char *output;
+	char *logfile;
+
+	/* defaults */
+	args->outfd = -1;
+	args->logfd = -1;
+	args->uerrfd = fileno(stderr);
+	output = NULL;
+	logfile = NULL;
+
+	while (1) {
+		int c = getopt_long(argc, argv, optc, opts, NULL);
+		if (c == -1)
+			break;
+		switch (c) {
+		case '?':
+			exit(1);
+		case 'h':
+			usage(usage_str);
+		case 'o':
+			output = optarg;
+			break;
+		case 1:
+			args->outfd = str2num(optarg);
+			if (args->outfd < 0) {
+				ckpt_err("checkpoint: invalid file descriptor\n");
+				exit(1);
+			}
+			break;
+		case 'l':
+			logfile = optarg;
+			break;
+		case 2:
+			args->logfd = str2num(optarg);
+			if (args->logfd < 0) {
+				ckpt_err("checkpoint: invalid file descriptor\n");
+				exit(1);
+			}
+			break;
+		case 'c':
+			args->container = 1;
+			break;
+		case 'v':
+			args->verbose = 1;
+			break;
+		default:
+			usage(usage_str);
+		}
+	}
+
+	if (output && args->outfd >= 0) {
+		ckpt_err("Invalid use of both -o/--output and --output-fd\n");
+		exit(1);
+	}
+
+	/* output file */
+	if (output) {
+		args->outfd = open(output, O_RDWR | O_CREAT | O_EXCL, 0644);
+		if (args->outfd < 0) {
+			ckpt_perror("open output file");
+			exit(1);
+		}
+	}
+
+	if (logfile && args->logfd >= 0) {
+		ckpt_err("Invalid use of both -l/--logfile and --logfile-fd\n");
+		exit(1);
+	}
+
+	/* (optional) log file */
+	if (logfile) {
+		args->logfd = open(logfile, O_RDWR | O_CREAT | O_EXCL, 0644);
+		if (args->logfd < 0) {
+			ckpt_perror("open log file");
+			exit(1);
+		}
+	}
+}
+
+int main(int argc, char *argv[])
+{
+	struct app_checkpoint_args args;
+	unsigned long flags = 0;
+	pid_t pid;
+
+	global_uerrfd = fileno(stderr);
+
+	memset(&args, 0, sizeof(args));
+	parse_args(&args, argc, argv);
+
+	argc -= optind;
+	if (argc != 1)
+		usage(usage_str);
+
+	pid = atoi(argv[optind]);
+	if (pid <= 0) {
+		ckpt_err("invalid pid\n");
+		exit(1);
+	}
+
+	if (!args.container)
+		flags |= CHECKPOINT_SUBTREE;
+
+	return app_checkpoint(pid, flags, &args);
+}
diff --git a/checkpoint.c b/checkpoint.c
index 291cb36..e3a1ce8 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -24,25 +24,6 @@
 #include "app-checkpoint.h"
 #include "common.h"
 
-static char usage_str[] =
-"usage: ckpt [opts] PID\n"
-"  'checkpoint' takes a checkpoint of the task indicated by PID, and all\n"
-"  its descendents, and outputs the checkpoint image. If the task is the\n"
-"  init(1) process of a container, it checkpoints the entire container.\n"
-"  By default 'checkpoint' allows to checkpoint any subtree of tasks. The\n"
-"  user can override this feature and request that only whole containers\n"
-"  be considered.\n"
-"\n"
-"\tOptions:\n"
-"  -h,--help             print this help message\n"
-"  -o,--output=FILE      write data to FILE instead of standard output\n"
-"     --output-fd=FD     write data to file descriptor FD instead of stdout\n"
-"  -l,--logfile=FILE     write error and debug data to FILE (default=none)\n"
-"     --logile-fd=FD     write error and debug data to file descriptor FD\n"
-"  -c,--container        require the PID is a container-init\n"
-"  -v,--verbose          verbose output\n"
-"";
-
 static int global_uerrfd = -1;
 
 inline static int checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
@@ -50,116 +31,6 @@ inline static int checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
 	return syscall(__NR_checkpoint, pid, fd, flags, logfd);
 }
 
-static void usage(char *str)
-{
-	ckpt_err("%s", str);
-	exit(1);
-}
-
-/* negative retval means error */
-static int str2num(char *str)
-{
-	char *nptr;
-	int num;
-
-	num = strtol(str, &nptr, 10);
-	if (nptr - str != strlen(str))
-		num = -1;
-	return num;
-}
-
-static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
-{
-	static struct option opts[] = {
-		{ "help",	no_argument,		NULL, 'h' },
-		{ "output",	required_argument,	NULL, 'o' },
-		{ "output-fd",	required_argument,	NULL, 1 },
-		{ "logfile",	required_argument,	NULL, 'l' },
-		{ "logfile-fd",	required_argument,	NULL, 2 },
-		{ "container",	no_argument,		NULL, 'c' },
-		{ "verbose",	no_argument,		NULL, 'v' },
-		{ NULL,		0,			NULL, 0 }
-	};
-	static char optc[] = "hvco:l:";
-	char *output;
-	char *logfile;
-
-	/* defaults */
-	args->outfd = -1;
-	args->logfd = -1;
-	args->uerrfd = fileno(stderr);
-	output = NULL;
-	logfile = NULL;
-
-	while (1) {
-		int c = getopt_long(argc, argv, optc, opts, NULL);
-		if (c == -1)
-			break;
-		switch (c) {
-		case '?':
-			exit(1);
-		case 'h':
-			usage(usage_str);
-		case 'o':
-			output = optarg;
-			break;
-		case 1:
-			args->outfd = str2num(optarg);
-			if (args->outfd < 0) {
-				ckpt_err("checkpoint: invalid file descriptor\n");
-				exit(1);
-			}
-			break;
-		case 'l':
-			logfile = optarg;
-			break;
-		case 2:
-			args->logfd = str2num(optarg);
-			if (args->logfd < 0) {
-				ckpt_err("checkpoint: invalid file descriptor\n");
-				exit(1);
-			}
-			break;
-		case 'c':
-			args->container = 1;
-			break;
-		case 'v':
-			args->verbose = 1;
-			break;
-		default:
-			usage(usage_str);
-		}
-	}
-
-	if (output && args->outfd >= 0) {
-		ckpt_err("Invalid use of both -o/--output and --output-fd\n");
-		exit(1);
-	}
-
-	/* output file */
-	if (output) {
-		args->outfd = open(output, O_RDWR | O_CREAT | O_EXCL, 0644);
-		if (args->outfd < 0) {
-			ckpt_perror("open output file");
-			exit(1);
-		}
-	}
-
-	if (logfile && args->logfd >= 0) {
-		ckpt_err("Invalid use of both -l/--logfile and --logfile-fd\n");
-		exit(1);
-	}
-
-	/* (optional) log file */
-	if (logfile) {
-		args->logfd = open(logfile, O_RDWR | O_CREAT | O_EXCL, 0644);
-		if (args->logfd < 0) {
-			ckpt_perror("open log file");
-			exit(1);
-		}
-	}
-}
-
 int app_checkpoint(int pid, unsigned long flags,
 				struct app_checkpoint_args *args)
 {
@@ -186,31 +57,3 @@ int app_checkpoint(int pid, unsigned long flags,
 
 	return (ret > 0 ? 0 : 1);
 }
-
-int main(int argc, char *argv[])
-{
-	struct app_checkpoint_args args;
-	unsigned long flags = 0;
-	pid_t pid;
-
-	global_uerrfd = fileno(stderr);
-
-	memset(&args, 0, sizeof(args));
-	parse_args(&args, argc, argv);
-
-	argc -= optind;
-	if (argc != 1)
-		usage(usage_str);
-
-	pid = atoi(argv[optind]);
-	if (pid <= 0) {
-		ckpt_err("invalid pid\n");
-		exit(1);
-	}
-
-	if (!args.container)
-		flags |= CHECKPOINT_SUBTREE;
-
-	return app_checkpoint(pid, flags, &args);
-}
-
-- 
1.6.0.4
