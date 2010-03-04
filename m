From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 12/13][user-cr]: Define app_checkpoint()
Date: Wed, 3 Mar 2010 23:50:28 -0800
Message-ID: <20100304075028.GM29320@us.ibm.com>
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
Date: Wed, 3 Mar 2010 11:35:47 -0800
Subject: [PATCH 12/13][user-cr]: Define app_checkpoint()

Move the bulk of the code that implements application checkpoint into
a separate function, app_checkpoint() and make a main() a wrapper to
that function. This would help export the core checkpoint functionality
as a library interface in a future patch.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 checkpoint.c |   50 +++++++++++++++++++++++++++++---------------------
 1 files changed, 29 insertions(+), 21 deletions(-)

diff --git a/checkpoint.c b/checkpoint.c
index d5fcfee..4044da8 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -160,12 +160,36 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 	}
 }
 
+int app_checkpoint(int pid, unsigned long flags,
+				struct app_checkpoint_args *args)
+{
+	int ret;
+
+	/* output file descriptor (default: stdout) */
+	if (args->outfd < 0)
+		args->outfd = STDOUT_FILENO;
+
+	/* output file descriptor (default: none) */
+	if (args->logfd < 0)
+		args->logfd = CHECKPOINT_FD_NONE;
+
+	ret = checkpoint(pid, args->outfd, flags, args->logfd);
+
+	if (ret < 0) {
+		perror("checkpoint");
+		fprintf(stderr, "(you may use 'ckptinfo -e' for more info)\n"); 
+	} else if (args->verbose) {
+		fprintf(stderr, "checkpoint id %d\n", ret);
+	}
+
+	return (ret > 0 ? 0 : 1);
+}
+
 int main(int argc, char *argv[])
 {
 	struct app_checkpoint_args args;
 	unsigned long flags = 0;
 	pid_t pid;
-	int ret;
 
 	memset(&args, 0, sizeof(args));
 	parse_args(&args, argc, argv);
@@ -174,31 +198,15 @@ int main(int argc, char *argv[])
 	if (argc != 1)
 		usage(usage_str);
 
-	if (!args.container)
-		flags |= CHECKPOINT_SUBTREE;
-
 	pid = atoi(argv[optind]);
 	if (pid <= 0) {
 		printf("invalid pid\n");
 		exit(1);
 	}
 
-	/* output file descriptor (default: stdout) */
-	if (args.outfd < 0)
-		args.outfd = STDOUT_FILENO;
-
-	/* output file descriptor (default: none) */
-	if (args.logfd < 0)
-		args.logfd = CHECKPOINT_FD_NONE;
-
-	ret = checkpoint(pid, args.outfd, flags, args.logfd);
-
-	if (ret < 0) {
-		perror("checkpoint");
-		fprintf(stderr, "(you may use 'ckptinfo -e' for more info)\n"); 
-	} else if (args.verbose) {
-		fprintf(stderr, "checkpoint id %d\n", ret);
-	}
+	if (!args.container)
+		flags |= CHECKPOINT_SUBTREE;
 
-	return (ret > 0 ? 0 : 1);
+	return app_checkpoint(pid, flags, &args);
 }
+
-- 
1.6.0.4
