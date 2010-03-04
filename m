From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 09/13][user-cr]: checkpoint: Remove args->output
Date: Wed, 3 Mar 2010 23:49:16 -0800
Message-ID: <20100304074916.GJ29320@us.ibm.com>
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
Date: Wed, 3 Mar 2010 10:49:19 -0800
Subject: [PATCH 09/13][user-cr]: checkpoint: Remove args->output

'struct args' has both an 'outfd' and an 'output' field. The ->output
field is only needed to parse arguments and by moving the open of
the output file into parse_args(), we can drop the ->output field
and just use ->outfd.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 checkpoint.c |   29 +++++++++++++++--------------
 1 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/checkpoint.c b/checkpoint.c
index 464e359..df405cb 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -40,7 +40,6 @@ static char usage_str[] =
 "";
 
 struct args {
-	char *output;
 	int outfd;
 	char *logfile;
 	int logfd;
@@ -84,10 +83,12 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ NULL,		0,			NULL, 0 }
 	};
 	static char optc[] = "hvco:l:";
+	char *output;
 
 	/* defaults */
 	args->outfd = -1;
 	args->logfd = -1;
+	output = NULL;
 
 	while (1) {
 		int c = getopt_long(argc, argv, optc, opts, NULL);
@@ -99,7 +100,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		case 'h':
 			usage(usage_str);
 		case 'o':
-			args->output = optarg;
+			output = optarg;
 			break;
 		case 1:
 			args->outfd = str2num(optarg);
@@ -129,10 +130,20 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		}
 	}
 
-	if (args->output && args->outfd >= 0) {
-		printf("Invalid used of both -o/--output and --output-fd\n");
+	if (output && args->outfd >= 0) {
+		printf("Invalid use of both -o/--output and --output-fd\n");
 		exit(1);
 	}
+
+	/* output file */
+	if (output) {
+		args->outfd = open(output, O_RDWR | O_CREAT | O_EXCL, 0644);
+		if (args->outfd < 0) {
+			perror("open output file");
+			exit(1);
+		}
+	}
+
 	if (args->logfile && args->logfd >= 0) {
 		printf("Invalid used of both -l/--logfile and --logfile-fd\n");
 		exit(1);
@@ -162,16 +173,6 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
-	/* output file */
-	if (args.output) {
-		args.outfd = open(args.output,
-				     O_RDWR | O_CREAT | O_EXCL, 0644);
-		if (args.outfd < 0) {
-			perror("open output file");
-			exit(1);
-		}
-	}
-
 	/* output file descriptor (default: stdout) */
 	if (args.outfd < 0)
 		args.outfd = STDOUT_FILENO;
-- 
1.6.0.4
