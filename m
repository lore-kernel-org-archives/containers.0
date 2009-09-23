From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] restart: add switch '-i/--input=FILE' to indicate an input
	file
Date: Tue, 22 Sep 2009 20:16:23 -0400
Message-ID: <1253664983-3406-1-git-send-email-orenl@librato.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This is useful when it isn't convenient to redirect/pipe in the
checkpoint image.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |   40 ++++++++++++++++++++++++++++++----------
 1 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/restart.c b/restart.c
index a25aaa9..600a282 100644
--- a/restart.c
+++ b/restart.c
@@ -1,5 +1,5 @@
 /*
- *  restart.c: restart of multiple processes
+ *  restart.c: restart process(es) from a checkpoint
  *
  *  Copyright (C) 2008-2009 Oren Laadan
  *
@@ -63,7 +63,6 @@ static char usage_str[] =
 "  -p,--pidns            create a new pid namspace (default with --pids)\n"
 "  -P,--no-pidns         do not create a new pid namespace (default)\n"
 "     --pids             restore original pids (default with --pidns)\n"
-"  -i,--inspect          inspect image on-the-fly for error records\n"
 "  -r,--root=ROOT        restart under the directory ROOT instead of current\n"
 "     --signal=SIG       send SIG to root task on SIGINT (default: SIGKILL\n"
 "                        to container root, SIGINT otherwise)\n"
@@ -72,6 +71,8 @@ static char usage_str[] =
 "     --copy-status      imitate exit status of root task (implies -w)\n"
 "  -W,--no-wait          do not wait for root task to terminate\n"
 "  -F,--freezer=CGROUP   freeze tasks in freezer group CGROUP on success\n"
+"  -i,--input=FILE      read data from FILE instead of standard input\n"
+"     --inspect          inspect image on-the-fly for error records\n"
 "  -v,--verbose          verbose output\n"
 "  -d,--debug            debugging output\n"
 "";
@@ -343,6 +344,7 @@ struct args {
 	int show_status;
 	int copy_status;
 	char *freezer;
+	char *input;
 };
 
 static void usage(char *str)
@@ -371,7 +373,8 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "no-pidns",	no_argument,		NULL, 'P' },
 		{ "pids",	no_argument,		NULL, 3 },
 		{ "signal",	required_argument,	NULL, 4 },
-		{ "inspect",	no_argument,		NULL, 'i' },
+		{ "inspect",	no_argument,		NULL, 5 },
+		{ "input",	required_argument,		NULL, 'i' },
 		{ "root",	required_argument,		NULL, 'r' },
 		{ "wait",	no_argument,		NULL, 'w' },
 		{ "show-status",	no_argument,	NULL, 1 },
@@ -382,7 +385,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "debug",	no_argument,		NULL, 'd' },
 		{ NULL,		0,			NULL, 0 }
 	};
-	static char optc[] = "hdivpPwWF:r:";
+	static char optc[] = "hdvpPwWF:r:i:";
 
 	int sig;
 
@@ -402,16 +405,19 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		case 'v':
 			global_verbose = 1;
 			break;
-		case 'i':
+		case 5:  /* --inspect */
 			args->inspect = 1;
 			break;
+		case 'i':
+			args->input = optarg;
+			break;
 		case 'p':
 			args->pidns = 1;
 			break;
 		case 'P':
 			args->no_pidns = 1;
 			break;
-		case 4:
+		case 4:  /* --signal */
 			sig = str2sig(optarg);
 			if (sig < 0)
 				sig = str2num(optarg);
@@ -421,7 +427,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 			}
 			global_send_sigint = sig;
 			break;
-		case 3:
+		case 3:  /* --pids */
 			args->pids = 1;
 			args->pidns = 1;  /* implied */
 			break;
@@ -434,11 +440,11 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		case 'W':
 			args->wait = 0;
 			break;
-		case 1:
+		case 1:  /* --show-status */
 			args->wait = 1;
 			args->show_status = 1;
 			break;
-		case 2:
+		case 2: /* --copy-status */
 			args->wait = 1;
 			args->copy_status = 1;
 			break;
@@ -625,14 +631,28 @@ int main(int argc, char *argv[])
 	memset(&ctx, 0, sizeof(ctx));
 
 	parse_args(&args, argc, argv);
-
 	ctx.args = &args;
 
+	/* input file (default: stdin) */
+	if (args.input) {
+		ret = open(args.input, O_RDONLY, 0);
+		if (ret < 0) {
+			perror("open input file");
+			exit(1);
+		}
+		if (dup2(ret, STDIN_FILENO) < 0) {
+			perror("dup2 input file");
+			exit(1);
+		}
+	}
+
+	/* freezer preparation */
 	if (args.freezer && freezer_prepare(&ctx) < 0)
 		exit(1);
 
 	setpgrp();
 
+	/* chroot ? */
 	if (args.root && chroot(args.root) < 0) {
 		perror("chroot");
 		exit(1);
-- 
1.6.0.4
