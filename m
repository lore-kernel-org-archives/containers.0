From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 00/13][user-cr]: Cleanups checkpoint.c, restart.c
Date: Wed, 3 Mar 2010 23:46:24 -0800
Message-ID: <20100304074624.GB29320@us.ibm.com>
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
Date: Mon, 1 Mar 2010 18:19:44 -0800
Subject: [PATCH 01/13][user-cr]: restart: Remove args->no_pidns.

args->no_pidns does not really need to be a field in the 'args' structure.
It is used to validate command line arguments and can just be a local
variable in parse_args().

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/restart.c b/restart.c
index f5d23bb..61abfaa 100644
--- a/restart.c
+++ b/restart.c
@@ -342,7 +342,6 @@ struct args {
 	int self;
 	int pids;
 	int pidns;
-	int no_pidns;
 	int inspect;
 	char *root;
 	int wait;
@@ -455,6 +454,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 
 	int optind;
 	int sig;
+	int no_pidns;
 
 	/* defaults */
 	memset(args, 0, sizeof(*args));
@@ -463,6 +463,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 	args->logfd = -1;
 	args->warn = CKPT_COND_WARN;
 	args->fail = CKPT_COND_FAIL;
+	no_pidns = 0;
 
 	while (1) {
 		int c = getopt_long(argc, argv, optc, opts, &optind);
@@ -503,7 +504,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 			args->pidns = 1;
 			break;
 		case 'P':
-			args->no_pidns = 1;
+			no_pidns = 1;
 			break;
 		case 6:  /* --self */
 			args->self = 1;
@@ -565,7 +566,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		}
 	}
 
-	if (args->no_pidns)
+	if (no_pidns)
 		args->pidns = 0;
 
 #ifndef CLONE_NEWPID
@@ -598,7 +599,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 #endif
 
 	if (args->self &&
-	    (args->pids || args->pidns || args->no_pidns ||
+	    (args->pids || args->pidns || no_pidns ||
 	     args->show_status || args->copy_status || args->freezer)) {
 		printf("Invalid mix of --self with multiprocess options\n");
 		exit(1);
-- 
1.6.0.4
