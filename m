From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 1/9] Initialize of args->{outfd, logfd,
	infd} in main c/r programs
Date: Wed, 26 Jan 2011 11:19:00 -0500
Message-ID: <1296058748-21418-2-git-send-email-orenl@cs.columbia.edu>
References: <1296058748-21418-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1296058748-21418-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

The initialization belongs to the caller of the cr-library - i.e.
restart-main and checkpoint-main, and not in the cr-library.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint-main.c |    4 ++--
 checkpoint.c      |    8 --------
 restart-main.c    |    4 ++--
 3 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/checkpoint-main.c b/checkpoint-main.c
index a2a7d94..b2ec9c8 100644
--- a/checkpoint-main.c
+++ b/checkpoint-main.c
@@ -70,8 +70,8 @@ static void parse_args(struct cr_checkpoint_args *args, int argc, char *argv[])
 	char *logfile;
 
 	/* defaults */
-	args->outfd = -1;
-	args->logfd = -1;
+	args->outfd = fileno(stdout);
+	args->logfd = CHECKPOINT_FD_NONE;
 	args->uerrfd = fileno(stderr);
 	output = NULL;
 	logfile = NULL;
diff --git a/checkpoint.c b/checkpoint.c
index cce3d9d..f9b0b3b 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -37,14 +37,6 @@ int cr_checkpoint(int pid, struct cr_checkpoint_args *args)
 
 	global_uerrfd = args->uerrfd;
 
-	/* output file descriptor (default: stdout) */
-	if (args->outfd < 0)
-		args->outfd = STDOUT_FILENO;
-
-	/* output file descriptor (default: none) */
-	if (args->logfd < 0)
-		args->logfd = CHECKPOINT_FD_NONE;
-
 	if (!args->container)
 		args->flags |= CHECKPOINT_SUBTREE;
 
diff --git a/restart-main.c b/restart-main.c
index 6eed101..efa6a8f 100644
--- a/restart-main.c
+++ b/restart-main.c
@@ -146,10 +146,10 @@ static void parse_args(struct cr_restart_args *args, int argc, char *argv[])
 	/* defaults */
 	memset(args, 0, sizeof(*args));
 	args->wait = 1;
-	args->infd = -1;
-	args->klogfd = -1;
+	args->infd = fileno(stdin);
 	args->ulogfd = fileno(stdout);
 	args->uerrfd = fileno(stderr);
+	args->klogfd = CHECKPOINT_FD_NONE;
 	args->warn = CKPT_COND_WARN;
 	args->fail = CKPT_COND_FAIL;
 	no_pidns = 0;
-- 
1.7.1
