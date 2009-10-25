From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] user-cr: add --output-fd to write output to a specific fd
Date: Sun, 25 Oct 2009 18:13:21 -0400
Message-ID: <1256508801-2426-1-git-send-email-orenl@librato.com>
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

This is useful if the user would like redirect the output to
e.g, a socket or any other already open file descriptor when
invoking 'checkpoint'.

Also useful if the user would like to append an existing file.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint.c |   47 +++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 41 insertions(+), 6 deletions(-)

diff --git a/checkpoint.c b/checkpoint.c
index c116daf..aef954b 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -32,12 +32,14 @@ static char usage_str[] =
 "\tOptions:\n"
 "  -h,--help             print this help message\n"
 "  -o,--output=FILE      write data to FILE instead of standard output\n"
+"     --output-fd=FD     write data to file descriptor FD instead of stdout\n"
 "  -c,--container        require the PID is a container-init\n"
 "  -v,--verbose          verbose output\n"
 "";
 
 struct args {
 	char *output;
+	int outputfd;
 	int container;
 	int verbose;
 };
@@ -53,17 +55,33 @@ static void usage(char *str)
 	exit(1);
 }
 
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
 static void parse_args(struct args *args, int argc, char *argv[])
 {
 	static struct option opts[] = {
 		{ "help",	no_argument,		NULL, 'h' },
 		{ "output",	required_argument,	NULL, 'o' },
+		{ "output-fd",	required_argument,	NULL, 1 },
 		{ "container",	no_argument,		NULL, 'c' },
 		{ "verbose",	no_argument,		NULL, 'v' },
 		{ NULL,		0,			NULL, 0 }
 	};
 	static char optc[] = "hvco:";
 
+	/* defaults */
+	args->outputfd = -1;
+
 	while (1) {
 		int c = getopt_long(argc, argv, optc, opts, NULL);
 		if (c == -1)
@@ -76,6 +94,13 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		case 'o':
 			args->output = optarg;
 			break;
+		case 1:
+			args->outputfd = str2num(optarg);
+			if (args->outputfd < 0) {
+				printf("checkpoint: invalid file descriptor\n");
+				exit(1);
+			}
+			break;
 		case 'c':
 			args->container = 1;
 			break;
@@ -86,6 +111,12 @@ static void parse_args(struct args *args, int argc, char *argv[])
 			usage(usage_str);
 		}
 	}
+
+	if (args->output && args->outputfd >= 0) {
+		printf("Invalid used of both -o/--output and --output-fd\n");
+		exit(1);
+	}
+	
 }
 
 int main(int argc, char *argv[])
@@ -111,19 +142,23 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
-	/* output file (default: stdout) */
+	/* output file */
 	if (args.output) {
-		ret = open(args.output, O_RDWR | O_CREAT, 0);
-		if (ret < 0) {
+		args.outputfd = open(args.output, O_RDWR | O_CREAT, 0);
+		if (args.outputfd < 0) {
 			perror("open output file");
 			exit(1);
 		}
-		if (dup2(ret, STDOUT_FILENO) < 0) {
+	}
+
+	/* output file descriptor (default: stdout) */
+	if (args.outputfd >= 0) {
+		if (dup2(args.outputfd, STDOUT_FILENO) < 0) {
 			perror("dup2 output file");
 			exit(1);
 		}
-		if (ret != STDOUT_FILENO)
-			close(ret);
+		if (args.outputfd != STDOUT_FILENO)
+			close(args.outputfd);
 	}
 
 	ret = checkpoint(pid, STDOUT_FILENO, flags);
-- 
1.6.0.4
