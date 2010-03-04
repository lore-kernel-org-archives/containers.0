From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 03/13][user-cr]: restart: Remove args->logfile
Date: Wed, 3 Mar 2010 23:47:01 -0800
Message-ID: <20100304074701.GD29320@us.ibm.com>
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
Date: Mon, 1 Mar 2010 18:45:59 -0800
Subject: [PATCH 03/13][user-cr]: restart: Remove args->logfile 

The args->logfile field is used to store the the name of the logfile to
which the kernel must write its output. If we move the code that opens this
args->logfile from main() to parse_args() and use the existing args->klogfd
field, we can remove the ->logfile field from struct args.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |   29 ++++++++++++++++-------------
 1 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/restart.c b/restart.c
index 7697189..1839330 100644
--- a/restart.c
+++ b/restart.c
@@ -352,7 +352,6 @@ struct args {
 	char *freezer;
 	char *input;
 	int infd;
-	char *logfile;
 	int klogfd;
 	long warn;
 	long fail;
@@ -456,6 +455,8 @@ static void parse_args(struct args *args, int argc, char *argv[])
 	int sig;
 	int no_pidns;
 
+	char *klogfile;
+
 	/* defaults */
 	memset(args, 0, sizeof(*args));
 	args->wait = 1;
@@ -465,6 +466,8 @@ static void parse_args(struct args *args, int argc, char *argv[])
 	args->fail = CKPT_COND_FAIL;
 	no_pidns = 0;
 
+	klogfile = NULL;
+
 	while (1) {
 		int c = getopt_long(argc, argv, optc, opts, &optind);
 		if (c == -1)
@@ -491,7 +494,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 			}
 			break;
 		case 'l':
-			args->logfile = optarg;
+			klogfile = optarg;
 			break;
 		case 8:
 			args->klogfd = str2num(optarg);
@@ -610,11 +613,21 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		exit(1);
 	}
 
-	if (args->logfile && args->klogfd >= 0) {
+	if (klogfile && args->klogfd >= 0) {
 		printf("Invalid used of both -l/--logfile and --logfile-fd\n");
 		exit(1);
 	}
 
+	/* (optional) log file */
+	if (klogfile) {
+		args->klogfd = open(klogfile, O_RDWR | O_CREAT | O_EXCL, 0644);
+		if (args->klogfd < 0) {
+			perror("open log file");
+			exit(1);
+		}
+	}
+
+
 	if (args->mnt_pty)
 		args->mntns = 1;
 }
@@ -781,16 +794,6 @@ int main(int argc, char *argv[])
 			close(args.infd);
 	}
 
-	/* (optional) log file */
-	if (args.logfile) {
-		args.klogfd = open(args.logfile,
-				  O_RDWR | O_CREAT | O_EXCL, 0644);
-		if (args.klogfd < 0) {
-			perror("open log file");
-			exit(1);
-		}
-	}
-
 	/* output file descriptor (default: none) */
 	if (args.klogfd < 0)
 		args.klogfd = CHECKPOINT_FD_NONE;
-- 
1.6.0.4
