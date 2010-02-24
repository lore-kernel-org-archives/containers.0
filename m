From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 3/4][user-cr] Move main() in restart.c to restart-main.c
Date: Wed, 24 Feb 2010 00:36:52 -0800
Message-ID: <20100224083651.GE18758@us.ibm.com>
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


From 6553b7da33f56e9cb6927e7469af22df56b7f55f Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 23 Feb 2010 15:55:34 -0800
Subject: [PATCH 3/4][user-cr] Move main() in restart.c to restart-main.c

This would enable us to put restart.o into a library.

TODO:
	restart.c still has a whole bunch of external variables that
	would need to be addressed (maybe encapsulate in structure)

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 Makefile       |    2 +
 restart-main.c |  312 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 restart.c      |  293 ----------------------------------------------------
 3 files changed, 314 insertions(+), 293 deletions(-)
 create mode 100644 restart-main.c

diff --git a/Makefile b/Makefile
index b312358..4449081 100644
--- a/Makefile
+++ b/Makefile
@@ -21,6 +21,8 @@ CFLAGS += -g $(WARNS) $(CKPT_INCLUDE) $(DEBUG)
 BIN_INSTALL_DIR = /bin
 LIB_INSTALL_DIR = /lib
 
+restart: restart.o restart-main.o
+
 ECLONE_PROGS = restart nsexec
 PROGS =	checkpoint ckptinfo $(ECLONE_PROGS)
 LIB_ECLONE = libeclone.a
diff --git a/restart-main.c b/restart-main.c
new file mode 100644
index 0000000..805920f
--- /dev/null
+++ b/restart-main.c
@@ -0,0 +1,312 @@
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+#include <signal.h>
+#include <getopt.h>
+#include <limits.h>
+
+#include "usercr.h"
+#include "restart.h"
+#include "clone.h"
+
+extern int global_verbose;
+extern int global_send_sigint;
+
+static char usage_str[] =
+"usage: restart [opts]\n"
+"  restart restores from a checkpoint image by first creating in userspace\n"
+"  the original tasks tree, and then calling sys_restart by each task.\n"
+"Options:\n"
+"  -h,--help             print this help message\n"
+"  -p,--pidns            create a new pid namspace (default with --pids)\n"
+"  -P,--no-pidns         do not create a new pid namespace (default)\n"
+"     --pids             restore original pids (default with --pidns)\n"
+"     --self             restart a single task, usually from self-checkpoint\n"
+"  -r,--root=ROOT        restart under the directory ROOT instead of current\n"
+"     --signal=SIG       send SIG to root task on SIGINT (default: SIGKILL\n"
+"                        to container root, SIGINT otherwise)\n"
+"     --mntns            restart under a private mounts namespace\n"
+"     --mount-pty        start in a new devpts namespace to supprt ptys\n"
+"  -w,--wait             wait for root task to termiate (default)\n"
+"     --show-status      show exit status of root task (implies -w)\n"
+"     --copy-status      imitate exit status of root task (implies -w)\n"
+"  -W,--no-wait          do not wait for root task to terminate\n"
+"  -k,--keeplsm          try to recreate original LSM labels on all objects\n"
+"  -F,--freezer=CGROUP   freeze tasks in freezer group CGROUP on success\n"
+"  -i,--input=FILE       read data from FILE instead of standard input\n"
+"     --input-fd=FD      read data from file descriptor FD (instead of stdin)\n"
+"  -l,--logfile=FILE     write error and debug data to FILE (default=none)\n"
+"     --logfile-fd=FD    write error and debug data to file desctiptor FD\n"
+"     --inspect          inspect image on-the-fly for error records\n"
+"  -v,--verbose          verbose output\n"
+"  -d,--debug            debugging output\n"
+"     --skip-COND        skip condition COND, and proceed anyway\n"
+"     --warn-COND        warn on condition COND, but proceed anyway\n"
+"     --fail-COND        warn on condition COND, and abort operation\n"
+"  	  COND=any:        any condition\n"
+"  	  COND=pidzero:    task with sid/pgid zero in a --no-pidns restart\n"
+"  	  COND=mntproc:    /proc isn't already mounted at restart (def: warn)\n"
+"";
+
+static void usage(char *str)
+{
+	fprintf(stderr, "%s", str);
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
+static long cond_to_mask(const char *cond)
+{
+	static struct {
+		char *cond;
+		long mask;
+	} conditions[] = {
+		{"pidzero", CKPT_COND_PIDZERO},
+		{"mntproc", CKPT_COND_MNTPROC},
+		{"any", CKPT_COND_ANY},
+		{NULL, 0}
+	};
+
+	int i;
+
+	for (i = 0; conditions[i].cond; i++)
+		if (!strcmp(cond, conditions[i].cond))
+			return conditions[i].mask;
+
+	printf("restart: invalid warn/fail condition '%s'\n", cond);
+	exit(1);
+}
+
+extern struct signal_array signal_array[];
+extern int global_debug;
+
+static int str2sig(char *str)
+{
+	int sig = 0;
+
+	do {
+		if (!strcmp(signal_array[sig].sigstr, str))
+			return signal_array[sig].signum;
+	} while (signal_array[++sig].signum >= 0);
+
+	return -1;
+}
+
+static void parse_args(struct restart_args *args, int argc, char *argv[])
+{
+	static struct option opts[] = {
+		{ "help",	no_argument,		NULL, 'h' },
+		{ "pidns",	no_argument,		NULL, 'p' },
+		{ "no-pidns",	no_argument,		NULL, 'P' },
+		{ "pids",	no_argument,		NULL, 3 },
+		{ "self",	no_argument,		NULL, 6},
+		{ "signal",	required_argument,	NULL, 4 },
+		{ "inspect",	no_argument,		NULL, 5 },
+		{ "keeplsm",	no_argument,		NULL, 'k' },
+		{ "input",	required_argument,	NULL, 'i' },
+		{ "input-fd",	required_argument,	NULL, 7 },
+		{ "logfile",	required_argument,	NULL, 'l' },
+		{ "logfile-fd",	required_argument,	NULL, 8 },
+		{ "root",	required_argument,	NULL, 'r' },
+		{ "mntns",	no_argument,		NULL, 11 },
+		{ "wait",	no_argument,		NULL, 'w' },
+		{ "show-status",	no_argument,	NULL, 1 },
+		{ "copy-status",	no_argument,	NULL, 2 },
+		{ "no-wait",	no_argument,		NULL, 'W' },
+		{ "freezer",	required_argument,	NULL, 'F' },
+		{ "verbose",	no_argument,		NULL, 'v' },
+		{ "debug",	no_argument,		NULL, 'd' },
+		{ "warn-pidzero",	no_argument,	NULL, 9 },
+		{ "fail-pidzero",	no_argument,	NULL, 10 },
+		{ "mount-pty",	no_argument,		NULL, 12 },
+		{ NULL,		0,			NULL, 0 }
+	};
+	static char optc[] = "hdvkpPwWF:r:i:l:";
+
+	int optind;
+	int sig;
+
+	/* defaults */
+	memset(args, 0, sizeof(*args));
+	args->wait = 1;
+	args->infd = -1;
+	args->logfd = -1;
+	args->warn = CKPT_COND_WARN;
+	args->fail = CKPT_COND_FAIL;
+
+	while (1) {
+		int c = getopt_long(argc, argv, optc, opts, &optind);
+		if (c == -1)
+			break;
+		switch (c) {
+		case '?':
+			exit(1);
+		case 'h':
+			usage(usage_str);
+		case 'v':
+			global_verbose = 1;
+			break;
+		case 5:  /* --inspect */
+			args->inspect = 1;
+			break;
+		case 'i':
+			args->input = optarg;
+			break;
+		case 7:
+			args->infd = str2num(optarg);
+			if (args->infd < 0) {
+				printf("restart: invalid file descriptor\n");
+				exit(1);
+			}
+			break;
+		case 'l':
+			args->logfile = optarg;
+			break;
+		case 8:
+			args->logfd = str2num(optarg);
+			if (args->logfd < 0) {
+				printf("restart: invalid file descriptor\n");
+				exit(1);
+			}
+			break;
+		case 'p':
+			args->pidns = 1;
+			break;
+		case 'P':
+			args->no_pidns = 1;
+			break;
+		case 6:  /* --self */
+			args->self = 1;
+			break;
+		case 4:  /* --signal */
+			sig = str2sig(optarg);
+			if (sig < 0)
+				sig = str2num(optarg);
+			if (sig < 0 || sig >= NSIG) {
+				printf("restart: invalid signal\n");
+				exit(1);
+			}
+			global_send_sigint = sig;
+			break;
+		case 3:  /* --pids */
+			args->pids = 1;
+			args->pidns = 1;  /* implied */
+			break;
+		case 'r':
+			args->root = optarg;
+			break;
+		case 'w':
+			args->wait = 1;
+			break;
+		case 'W':
+			args->wait = 0;
+			break;
+		case 'k':
+			args->keep_lsm = 1;
+			break;
+		case 1:  /* --show-status */
+			args->wait = 1;
+			args->show_status = 1;
+			break;
+		case 2: /* --copy-status */
+			args->wait = 1;
+			args->copy_status = 1;
+			break;
+		case 'd':
+			global_debug = 1;
+			break;
+		case 'F':
+			args->freezer = optarg;
+			break;
+		case 9:
+			args->warn |= cond_to_mask(&opts[optind].name[5]);
+			break;
+		case 10:
+			args->fail |= cond_to_mask(&opts[optind].name[5]);
+			break;
+		case 11:
+			args->mntns = 1;
+			break;
+		case 12:
+			args->mnt_pty = 1;
+			break;
+		default:
+			usage(usage_str);
+		}
+	}
+
+	if (args->no_pidns)
+		args->pidns = 0;
+
+#ifndef CLONE_NEWPID
+	if (args->pidns) {
+		printf("This version of restart was compiled without "
+		       "support for --pidns.\n");
+		exit(1);
+	}
+#endif
+
+#ifndef CHECKPOINT_DEBUG
+	if (global_debug) {
+		printf("This version of restart was compiled without "
+		       "support for --debug.\n");
+		exit(1);
+	}
+#endif
+
+	if (args->pidns)
+		args->pids = 1;
+
+#if 0   /* Defered until __NR_eclone makes it to standard headers */
+#ifndef __NR_eclone
+	if (args->pids) {
+		printf("This version of restart was compiled without "
+		       "support for --pids.\n");
+		exit(1);
+	}
+#endif
+#endif
+
+	if (args->self &&
+	    (args->pids || args->pidns || args->no_pidns ||
+	     args->show_status || args->copy_status || args->freezer)) {
+		printf("Invalid mix of --self with multiprocess options\n");
+		exit(1);
+	}
+
+	if (args->input && args->infd >= 0) {
+		printf("Invalid used of both -i/--input and --input-fd\n");
+		exit(1);
+	}
+
+	if (args->logfile && args->logfd >= 0) {
+		printf("Invalid used of both -l/--logfile and --logfile-fd\n");
+		exit(1);
+	}
+
+	if (args->mnt_pty)
+		args->mntns = 1;
+}
+
+int main(int argc, char *argv[])
+{
+	struct restart_args args;
+
+	parse_args(&args, argc, argv);
+
+	return app_restart(&args);
+}
+
diff --git a/restart.c b/restart.c
index b2281fb..b1518f2 100644
--- a/restart.c
+++ b/restart.c
@@ -42,42 +42,6 @@
 #include "restart.h"
 #include "usercr.h"
 
-static char usage_str[] =
-"usage: restart [opts]\n"
-"  restart restores from a checkpoint image by first creating in userspace\n"
-"  the original tasks tree, and then calling sys_restart by each task.\n"
-"Options:\n"
-"  -h,--help             print this help message\n"
-"  -p,--pidns            create a new pid namspace (default with --pids)\n"
-"  -P,--no-pidns         do not create a new pid namespace (default)\n"
-"     --pids             restore original pids (default with --pidns)\n"
-"     --self             restart a single task, usually from self-checkpoint\n"
-"  -r,--root=ROOT        restart under the directory ROOT instead of current\n"
-"     --signal=SIG       send SIG to root task on SIGINT (default: SIGKILL\n"
-"                        to container root, SIGINT otherwise)\n"
-"     --mntns            restart under a private mounts namespace\n"
-"     --mount-pty        start in a new devpts namespace to supprt ptys\n"
-"  -w,--wait             wait for root task to termiate (default)\n"
-"     --show-status      show exit status of root task (implies -w)\n"
-"     --copy-status      imitate exit status of root task (implies -w)\n"
-"  -W,--no-wait          do not wait for root task to terminate\n"
-"  -k,--keeplsm          try to recreate original LSM labels on all objects\n"
-"  -F,--freezer=CGROUP   freeze tasks in freezer group CGROUP on success\n"
-"  -i,--input=FILE       read data from FILE instead of standard input\n"
-"     --input-fd=FD      read data from file descriptor FD (instead of stdin)\n"
-"  -l,--logfile=FILE     write error and debug data to FILE (default=none)\n"
-"     --logfile-fd=FD    write error and debug data to file desctiptor FD\n"
-"     --inspect          inspect image on-the-fly for error records\n"
-"  -v,--verbose          verbose output\n"
-"  -d,--debug            debugging output\n"
-"     --skip-COND        skip condition COND, and proceed anyway\n"
-"     --warn-COND        warn on condition COND, but proceed anyway\n"
-"     --fail-COND        warn on condition COND, and abort operation\n"
-"  	  COND=any:        any condition\n"
-"  	  COND=pidzero:    task with sid/pgid zero in a --no-pidns restart\n"
-"  	  COND=mntproc:    /proc isn't already mounted at restart (def: warn)\n"
-"";
-
 /*
  * By default, 'restart' creates a new pid namespace in which the
  * restart takes place, using the original pids from the time of the
@@ -176,18 +140,6 @@ static char *sig2str(int sig)
 	return "UNKNOWN SIGNAL";
 }
 
-static int str2sig(char *str)
-{
-	int sig = 0;
-
-	do {
-		if (!strcmp(signal_array[sig].sigstr, str))
-			return signal_array[sig].signum;
-	} while (signal_array[++sig].signum >= 0);
-
-	return -1;
-}
-
 inline static int restart(pid_t pid, int fd, unsigned long flags, int logfd)
 {
 	return syscall(__NR_restart, pid, fd, flags, logfd);
@@ -311,46 +263,6 @@ struct pid_swap {
 	pid_t new;
 };
 
-static void usage(char *str)
-{
-	fprintf(stderr, "%s", str);
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
-static long cond_to_mask(const char *cond)
-{
-	static struct {
-		char *cond;
-		long mask;
-	} conditions[] = {
-		{"pidzero", CKPT_COND_PIDZERO},
-		{"mntproc", CKPT_COND_MNTPROC},
-		{"any", CKPT_COND_ANY},
-		{NULL, 0}
-	};
-
-	int i;
-
-	for (i = 0; conditions[i].cond; i++)
-		if (!strcmp(cond, conditions[i].cond))
-			return conditions[i].mask;
-
-	printf("restart: invalid warn/fail condition '%s'\n", cond);
-	exit(1);
-}
-
 static inline int ckpt_cond_warn(struct ckpt_ctx *ctx, long mask)
 {
 	return (ctx->args->warn & mask);
@@ -361,202 +273,6 @@ static inline int ckpt_cond_fail(struct ckpt_ctx *ctx, long mask)
 	return (ctx->args->fail & mask);
 }
 
-static void parse_args(struct restart_args *args, int argc, char *argv[])
-{
-	static struct option opts[] = {
-		{ "help",	no_argument,		NULL, 'h' },
-		{ "pidns",	no_argument,		NULL, 'p' },
-		{ "no-pidns",	no_argument,		NULL, 'P' },
-		{ "pids",	no_argument,		NULL, 3 },
-		{ "self",	no_argument,		NULL, 6},
-		{ "signal",	required_argument,	NULL, 4 },
-		{ "inspect",	no_argument,		NULL, 5 },
-		{ "keeplsm",	no_argument,		NULL, 'k' },
-		{ "input",	required_argument,	NULL, 'i' },
-		{ "input-fd",	required_argument,	NULL, 7 },
-		{ "logfile",	required_argument,	NULL, 'l' },
-		{ "logfile-fd",	required_argument,	NULL, 8 },
-		{ "root",	required_argument,	NULL, 'r' },
-		{ "mntns",	no_argument,		NULL, 11 },
-		{ "wait",	no_argument,		NULL, 'w' },
-		{ "show-status",	no_argument,	NULL, 1 },
-		{ "copy-status",	no_argument,	NULL, 2 },
-		{ "no-wait",	no_argument,		NULL, 'W' },
-		{ "freezer",	required_argument,	NULL, 'F' },
-		{ "verbose",	no_argument,		NULL, 'v' },
-		{ "debug",	no_argument,		NULL, 'd' },
-		{ "warn-pidzero",	no_argument,	NULL, 9 },
-		{ "fail-pidzero",	no_argument,	NULL, 10 },
-		{ "mount-pty",	no_argument,		NULL, 12 },
-		{ NULL,		0,			NULL, 0 }
-	};
-	static char optc[] = "hdvkpPwWF:r:i:l:";
-
-	int optind;
-	int sig;
-
-	/* defaults */
-	memset(args, 0, sizeof(*args));
-	args->wait = 1;
-	args->infd = -1;
-	args->logfd = -1;
-	args->warn = CKPT_COND_WARN;
-	args->fail = CKPT_COND_FAIL;
-
-	while (1) {
-		int c = getopt_long(argc, argv, optc, opts, &optind);
-		if (c == -1)
-			break;
-		switch (c) {
-		case '?':
-			exit(1);
-		case 'h':
-			usage(usage_str);
-		case 'v':
-			global_verbose = 1;
-			break;
-		case 5:  /* --inspect */
-			args->inspect = 1;
-			break;
-		case 'i':
-			args->input = optarg;
-			break;
-		case 7:
-			args->infd = str2num(optarg);
-			if (args->infd < 0) {
-				printf("restart: invalid file descriptor\n");
-				exit(1);
-			}
-			break;
-		case 'l':
-			args->logfile = optarg;
-			break;
-		case 8:
-			args->logfd = str2num(optarg);
-			if (args->logfd < 0) {
-				printf("restart: invalid file descriptor\n");
-				exit(1);
-			}
-			break;
-		case 'p':
-			args->pidns = 1;
-			break;
-		case 'P':
-			args->no_pidns = 1;
-			break;
-		case 6:  /* --self */
-			args->self = 1;
-			break;
-		case 4:  /* --signal */
-			sig = str2sig(optarg);
-			if (sig < 0)
-				sig = str2num(optarg);
-			if (sig < 0 || sig >= NSIG) {
-				printf("restart: invalid signal\n");
-				exit(1);
-			}
-			global_send_sigint = sig;
-			break;
-		case 3:  /* --pids */
-			args->pids = 1;
-			args->pidns = 1;  /* implied */
-			break;
-		case 'r':
-			args->root = optarg;
-			break;
-		case 'w':
-			args->wait = 1;
-			break;
-		case 'W':
-			args->wait = 0;
-			break;
-		case 'k':
-			args->keep_lsm = 1;
-			break;
-		case 1:  /* --show-status */
-			args->wait = 1;
-			args->show_status = 1;
-			break;
-		case 2: /* --copy-status */
-			args->wait = 1;
-			args->copy_status = 1;
-			break;
-		case 'd':
-			global_debug = 1;
-			break;
-		case 'F':
-			args->freezer = optarg;
-			break;
-		case 9:
-			args->warn |= cond_to_mask(&opts[optind].name[5]);
-			break;
-		case 10:
-			args->fail |= cond_to_mask(&opts[optind].name[5]);
-			break;
-		case 11:
-			args->mntns = 1;
-			break;
-		case 12:
-			args->mnt_pty = 1;
-			break;
-		default:
-			usage(usage_str);
-		}
-	}
-
-	if (args->no_pidns)
-		args->pidns = 0;
-
-#ifndef CLONE_NEWPID
-	if (args->pidns) {
-		printf("This version of restart was compiled without "
-		       "support for --pidns.\n");
-		exit(1);
-	}
-#endif
-
-#ifndef CHECKPOINT_DEBUG
-	if (global_debug) {
-		printf("This version of restart was compiled without "
-		       "support for --debug.\n");
-		exit(1);
-	}
-#endif
-
-	if (args->pidns)
-		args->pids = 1;
-
-#if 0   /* Defered until __NR_eclone makes it to standard headers */
-#ifndef __NR_eclone
-	if (args->pids) {
-		printf("This version of restart was compiled without "
-		       "support for --pids.\n");
-		exit(1);
-	}
-#endif
-#endif
-
-	if (args->self &&
-	    (args->pids || args->pidns || args->no_pidns ||
-	     args->show_status || args->copy_status || args->freezer)) {
-		printf("Invalid mix of --self with multiprocess options\n");
-		exit(1);
-	}
-
-	if (args->input && args->infd >= 0) {
-		printf("Invalid used of both -i/--input and --input-fd\n");
-		exit(1);
-	}
-
-	if (args->logfile && args->logfd >= 0) {
-		printf("Invalid used of both -l/--logfile and --logfile-fd\n");
-		exit(1);
-	}
-
-	if (args->mnt_pty)
-		args->mntns = 1;
-}
-
 static void report_exit_status(int status, char *str, int debug)
 {
 	char msg[64];
@@ -689,15 +405,6 @@ static int freezer_register(struct ckpt_ctx *ctx, pid_t pid)
 	return ret;
 }
 
-int main(int argc, char *argv[])
-{
-	struct restart_args args;
-
-	parse_args(&args, argc, argv);
-
-	return app_restart(&args);
-}
-
 int app_restart(struct restart_args *args)
 {
 	struct ckpt_ctx ctx;
-- 
1.6.6.1
