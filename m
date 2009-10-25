From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] user-cr: add --input-fd to take input from a specific fd
Date: Sun, 25 Oct 2009 18:13:11 -0400
Message-ID: <1256508791-2394-1-git-send-email-orenl@librato.com>
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

This is useful if the user would like redirect the input from
e.g, a socket or any other already open file descriptor when
invoking 'restart'.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |   34 +++++++++++++++++++++++++++-------
 1 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/restart.c b/restart.c
index 14d8aec..ca8e062 100644
--- a/restart.c
+++ b/restart.c
@@ -72,7 +72,8 @@ static char usage_str[] =
 "     --copy-status      imitate exit status of root task (implies -w)\n"
 "  -W,--no-wait          do not wait for root task to terminate\n"
 "  -F,--freezer=CGROUP   freeze tasks in freezer group CGROUP on success\n"
-"  -i,--input=FILE      read data from FILE instead of standard input\n"
+"  -i,--input=FILE       read data from FILE instead of standard input\n"
+"     --input-fd=FD      read data from file descriptor FD (instead of stdin)\n"
 "     --inspect          inspect image on-the-fly for error records\n"
 "  -v,--verbose          verbose output\n"
 "  -d,--debug            debugging output\n"
@@ -353,6 +354,7 @@ struct args {
 	int copy_status;
 	char *freezer;
 	char *input;
+	int inputfd;
 };
 
 static void usage(char *str)
@@ -384,6 +386,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "signal",	required_argument,	NULL, 4 },
 		{ "inspect",	no_argument,		NULL, 5 },
 		{ "input",	required_argument,	NULL, 'i' },
+		{ "input-fd",	required_argument,	NULL, 7 },
 		{ "root",	required_argument,	NULL, 'r' },
 		{ "wait",	no_argument,		NULL, 'w' },
 		{ "show-status",	no_argument,	NULL, 1 },
@@ -401,6 +404,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 	/* defaults */
 	memset(args, 0, sizeof(*args));
 	args->wait = 1;
+	args->inputfd = -1;
 
 	while (1) {
 		int c = getopt_long(argc, argv, optc, opts, NULL);
@@ -420,6 +424,13 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		case 'i':
 			args->input = optarg;
 			break;
+		case 7:
+			args->inputfd = str2num(optarg);
+			if (args->inputfd < 0) {
+				printf("restart: invalid file descriptor\n");
+				exit(1);
+			}
+			break;
 		case 'p':
 			args->pidns = 1;
 			break;
@@ -507,6 +518,11 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		printf("Invalid mix of --self with multiprocess options\n");
 		exit(1);
 	}
+
+	if (args->input && args->inputfd >= 0) {
+		printf("Invalid used of both -i/--input and --input-fd\n");
+		exit(1);
+	}
 }
 
 static void report_exit_status(int status, char *str, int debug)
@@ -652,19 +668,23 @@ int main(int argc, char *argv[])
 	parse_args(&args, argc, argv);
 	ctx.args = &args;
 
-	/* input file (default: stdin) */
+	/* input file ? */
 	if (args.input) {
-		ret = open(args.input, O_RDONLY, 0);
-		if (ret < 0) {
+		args.inputfd = open(args.input, O_RDONLY, 0);
+		if (args.inputfd < 0) {
 			perror("open input file");
 			exit(1);
 		}
-		if (dup2(ret, STDIN_FILENO) < 0) {
+	}
+
+	/* input file descriptor (default: stdin) */
+	if (args.inputfd >= 0) {
+		if (dup2(args.inputfd, STDIN_FILENO) < 0) {
 			perror("dup2 input file");
 			exit(1);
 		}
-		if (ret != STDIN_FILENO)
-			close(ret);
+		if (args.inputfd != STDIN_FILENO)
+			close(args.inputfd);
 	}
 
 	/* freezer preparation */
-- 
1.6.0.4
