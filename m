From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 06/13][user-cr]: restart: Remove args->input
Date: Wed, 3 Mar 2010 23:47:59 -0800
Message-ID: <20100304074759.GG29320@us.ibm.com>
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
Date: Mon, 1 Mar 2010 20:24:15 -0800
Subject: [PATCH 06/13][user-cr]: restart: Remove args->input

Having both ->input and ->infd in 'struct args' is redundant.

The args->input field is used to store the name of the input file
(checkpoint-image).  If we move the code that opens this file from
main() to parse_args() and use the existing args->infd field, we
can remove the ->input field from struct args.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/restart.c b/restart.c
index eda864d..d028890 100644
--- a/restart.c
+++ b/restart.c
@@ -383,7 +383,6 @@ struct args {
 	int show_status;
 	int copy_status;
 	char *freezer;
-	char *input;
 	int infd;
 	int klogfd;
 	long warn;
@@ -489,6 +488,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 	int no_pidns;
 
 	char *klogfile;
+	char *input;
 
 	/* defaults */
 	memset(args, 0, sizeof(*args));
@@ -500,6 +500,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 	no_pidns = 0;
 
 	klogfile = NULL;
+	input = NULL;
 
 	while (1) {
 		int c = getopt_long(argc, argv, optc, opts, &optind);
@@ -517,7 +518,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 			args->inspect = 1;
 			break;
 		case 'i':
-			args->input = optarg;
+			input = optarg;
 			break;
 		case 7:
 			args->infd = str2num(optarg);
@@ -641,11 +642,20 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		exit(1);
 	}
 
-	if (args->input && args->infd >= 0) {
+	if (input && args->infd >= 0) {
 		ckpt_err("Invalid use of both -i/--input and --input-fd\n");
 		exit(1);
 	}
 
+	/* input file ? */
+	if (input) {
+		args->infd = open(input, O_RDONLY, 0);
+		if (args->infd < 0) {
+			ckpt_perror("open input file");
+			exit(1);
+		}
+	}
+
 	if (klogfile && args->klogfd >= 0) {
 		ckpt_err("Invalid use of both -l/--logfile and --logfile-fd\n");
 		exit(1);
@@ -817,15 +827,6 @@ int main(int argc, char *argv[])
 	parse_args(&args, argc, argv);
 	ctx.args = &args;
 
-	/* input file ? */
-	if (args.input) {
-		args.infd = open(args.input, O_RDONLY, 0);
-		if (args.infd < 0) {
-			ckpt_perror("open input file");
-			exit(1);
-		}
-	}
-
 	/* input file descriptor (default: stdin) */
 	if (args.infd >= 0) {
 		if (dup2(args.infd, STDIN_FILENO) < 0) {
-- 
1.6.0.4
