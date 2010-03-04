From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 10/13][user-cr]: checkpoint: Remove ->logfile
Date: Wed, 3 Mar 2010 23:49:42 -0800
Message-ID: <20100304074942.GK29320@us.ibm.com>
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
Date: Wed, 3 Mar 2010 11:03:52 -0800
Subject: [PATCH 10/13][user-cr]: checkpoint: Remove ->logfile

'struct args' has both an 'logfd' and a 'logfile' field. The ->logfile
field is only needed to parse arguments and by moving the open of
the logfile into parse_args(), we can drop the ->logfile field and just
use ->logfd.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 checkpoint.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/checkpoint.c b/checkpoint.c
index df405cb..ca77d8b 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -41,7 +41,6 @@ static char usage_str[] =
 
 struct args {
 	int outfd;
-	char *logfile;
 	int logfd;
 	int container;
 	int verbose;
@@ -84,11 +83,13 @@ static void parse_args(struct args *args, int argc, char *argv[])
 	};
 	static char optc[] = "hvco:l:";
 	char *output;
+	char *logfile;
 
 	/* defaults */
 	args->outfd = -1;
 	args->logfd = -1;
 	output = NULL;
+	logfile = NULL;
 
 	while (1) {
 		int c = getopt_long(argc, argv, optc, opts, NULL);
@@ -110,7 +111,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 			}
 			break;
 		case 'l':
-			args->logfile = optarg;
+			logfile = optarg;
 			break;
 		case 2:
 			args->logfd = str2num(optarg);
@@ -144,10 +145,19 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		}
 	}
 
-	if (args->logfile && args->logfd >= 0) {
-		printf("Invalid used of both -l/--logfile and --logfile-fd\n");
+	if (logfile && args->logfd >= 0) {
+		printf("Invalid use of both -l/--logfile and --logfile-fd\n");
 		exit(1);
 	}
+
+	/* (optional) log file */
+	if (logfile) {
+		args->logfd = open(logfile, O_RDWR | O_CREAT | O_EXCL, 0644);
+		if (args->logfd < 0) {
+			perror("open log file");
+			exit(1);
+		}
+	}
 }
 
 int main(int argc, char *argv[])
@@ -177,16 +187,6 @@ int main(int argc, char *argv[])
 	if (args.outfd < 0)
 		args.outfd = STDOUT_FILENO;
 
-	/* (optional) log file */
-	if (args.logfile) {
-		args.logfd = open(args.logfile,
-				  O_RDWR | O_CREAT | O_EXCL, 0644);
-		if (args.logfd < 0) {
-			perror("open log file");
-			exit(1);
-		}
-	}
-
 	/* output file descriptor (default: none) */
 	if (args.logfd < 0)
 		args.logfd = CHECKPOINT_FD_NONE;
-- 
1.6.0.4
